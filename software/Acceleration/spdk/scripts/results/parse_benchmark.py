#!/usr/bin/env python3
"""Drive the SPDK bdevperf measurement matrix and parse it strictly.

The measurement is split into two halves so the container boundary stays honest:

* ``drive`` runs the matrix (warmup plus independent repetitions) and records,
  for every pass, the raw bdevperf log, a GNU time record (wall clock and peak
  RSS of the bdevperf process) and a ``<label>.json`` timing artifact.  It never
  converts a pass into a metric, so it cannot invent a sample.
* ``report`` runs on the host, reads those artifacts and applies the whole
  strict contract: every scenario must have one warmup pass and the requested
  number of measurement passes, every pass must have exited with 0, every field
  must be present exactly once and must be a finite number, and failures or
  timeouts reported by bdevperf are rejected instead of being silently kept.
  Nothing is estimated, interpolated or zero-filled: if a sample is missing the
  whole test stage fails and the caller maps it to exit code 50.

``measure`` keeps the historical single-process behaviour (drive then report) for
standalone use.  The measurement phase never touches the network.  All inputs
(the bdevperf binary, the DPDK runtime profile and the build metadata) are
produced by the build and start stages inside this run's private work directory.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from statistics import fmean, median, stdev
from typing import Any

SOFTWARE = "spdk"
CATEGORY = "Acceleration"
BENCHMARK_NAME = "SPDK bdevperf over Malloc bdev (SPDK userspace block stack path)"
MALLOC_BLOCK_SIZE = 512
MALLOC_BLOCKS = 32768  # 16 MiB per Malloc bdev
MAX_CORE_MASK = "0xF"

IOPS_LABEL = "IOPS"
BANDWIDTH_LABEL = "MiB/s"
AVG_LATENCY_LABEL = "avg_latency_us"
P99_LATENCY_LABEL = "p99_latency_us"
PEAK_RSS_LABEL = "peak_rss_mib"

METRIC_SPECS = (
    (IOPS_LABEL, "IOPS", "higher_is_better", "total row IOPS column of the bdevperf summary table"),
    (BANDWIDTH_LABEL, "MiB/s", "higher_is_better", "total row MiB/s column of the bdevperf summary table"),
    (AVG_LATENCY_LABEL, "us", "lower_is_better", "total row Average latency column of the bdevperf summary table"),
    (P99_LATENCY_LABEL, "us", "lower_is_better", "99.00000% cutoff of the bdevperf latency summary, maximum across jobs"),
    (PEAK_RSS_LABEL, "MiB", "lower_is_better", "peak VmHWM of the bdevperf process sampled from /proc/<pid>/status"),
)

TOTAL_PATTERN = re.compile(
    r"^\s*Total\s+:\s+(?P<iops>\d+\.\d+)\s+(?P<mibps>\d+\.\d+)\s+"
    r"(?P<fail>\d+\.\d+)\s+(?P<timeout>\d+\.\d+)\s+(?P<avg>\d+\.\d+)\s+"
    r"(?P<min>\d+\.\d+)\s+(?P<max>\d+\.\d+)\s*$"
)
JOB_PATTERN = re.compile(
    r"^\s+(?P<name>\S+)\s+:\s+(?P<runtime>\d+\.\d+)\s+(?P<iops>\d+\.\d+)\s+"
    r"(?P<mibps>\d+\.\d+)\s+(?P<fail>\d+\.\d+)\s+(?P<timeout>\d+\.\d+)\s+"
    r"(?P<avg>\d+\.\d+)\s+(?P<min>\d+\.\d+)\s+(?P<max>\d+\.\d+)\s*$"
)
JOB_HEADER_PATTERN = re.compile(
    r"^Job:\s+(?P<name>\S+)\s+\(Core Mask\s+0x[0-9a-fA-F]+,\s+workload:\s+"
    r"(?P<workload>[a-z_]+)(?:,\s+percentage:\s+(?P<percentage>\d+))?,\s+"
    r"depth:\s+(?P<queue_depth>\d+),\s+IO size:\s+(?P<io_size>\d+)\)\s*$"
)
LATENCY_JOB_PATTERN = re.compile(r"^\s*Job:\s+(?P<name>\S+)\s+\(Core Mask\s+0x[0-9a-fA-F]+\)\s*$")
CUTOFF_PATTERN = re.compile(r"^\s*(?P<percent>\d+\.\d+)%\s*:\s*(?P<value>\d+\.\d+)us\s*$")


class MeasurementError(RuntimeError):
    """Raised when one measurement pass cannot be used as a valid sample."""


@dataclass(frozen=True)
class Scenario:
    key: str
    workload: str
    io_size: int
    queue_depth: int
    bdev_count: int
    read_percentage: int | None = None

    @property
    def cpu_mask(self) -> str:
        return MAX_CORE_MASK if self.bdev_count > 1 else "0x1"

    @property
    def description(self) -> str:
        parts = [
            f"{self.workload}",
            f"bs={self.io_size}",
            f"qd={self.queue_depth}",
            f"bdevs={self.bdev_count}",
        ]
        if self.read_percentage is not None:
            parts.append(f"read={self.read_percentage}%")
        return " ".join(parts)


SCENARIOS = (
    Scenario("randread_bs4k_qd1_single", "randread", 4096, 1, 1),
    Scenario("randread_bs4k_qd32_single", "randread", 4096, 32, 1),
    Scenario("randread_bs4k_qd128_single", "randread", 4096, 128, 1),
    Scenario("randwrite_bs4k_qd32_single", "randwrite", 4096, 32, 1),
    Scenario("randrw_bs4k_qd32_single", "randrw", 4096, 32, 1, read_percentage=70),
    Scenario("randread_bs64k_qd32_single", "randread", 65536, 32, 1),
    Scenario("randread_bs128k_qd32_single", "randread", 131072, 32, 1),
    Scenario("randread_bs4k_qd32_multi4", "randread", 4096, 32, 4),
)


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def finite_positive(value: float, label: str) -> float:
    if not math.isfinite(value) or value <= 0:
        raise MeasurementError(f"{label} is not a finite positive number: {value!r}")
    return value


# --- bdevperf configuration and command line --------------------------------


def write_bdev_config(path: Path, bdev_count: int) -> None:
    config = {
        "subsystems": [
            {
                "subsystem": "bdev",
                "config": [
                    {
                        "method": "bdev_malloc_create",
                        "params": {
                            "name": f"Malloc{index}",
                            "block_size": MALLOC_BLOCK_SIZE,
                            "num_blocks": MALLOC_BLOCKS,
                        },
                    }
                    for index in range(bdev_count)
                ],
            }
        ]
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")


def write_jobs_config(path: Path, scenario: Scenario) -> None:
    lines = ["[global]", f"rw={scenario.workload}", f"bs={scenario.io_size}", ""]
    for index in range(scenario.bdev_count):
        lines.extend([f"[job{index}]", f"filename=Malloc{index}", ""])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def build_command(
    bdevperf: Path,
    scenario: Scenario,
    duration: int,
    config_path: Path,
    jobs_path: Path,
    runtime: dict[str, Any],
) -> list[str]:
    command = [
        str(bdevperf),
        "-m",
        scenario.cpu_mask,
        "-c",
        str(config_path),
        "-j",
        str(jobs_path),
        "-t",
        str(duration),
        "-l",
        "-q",
        str(scenario.queue_depth),
        "-o",
        str(scenario.io_size),
        "-w",
        scenario.workload,
    ]
    if scenario.read_percentage is not None:
        command.extend(["-M", str(scenario.read_percentage)])
    command.extend(str(value) for value in runtime.get("bdevperf_args", []))
    command.extend(str(value) for value in runtime.get("eal_args", []))
    return command


# --- one measurement pass ----------------------------------------------------

GNU_TIME_ELAPSED_PATTERN = re.compile(
    r"^\s*Elapsed \(wall clock\) time \(h:mm:ss or m:ss\):\s*"
    r"(?:(?P<hours>\d+):)?(?P<minutes>\d+):(?P<seconds>\d+(?:\.\d+)?)\s*$"
)
GNU_TIME_RSS_PATTERN = re.compile(
    r"^\s*Maximum resident set size \(kbytes\):\s*(?P<kib>\d+)\s*$"
)


def read_gnu_time(timing_path: Path, where: str) -> tuple[float, float]:
    """Return (wall seconds, peak RSS MiB) from a GNU time -v record."""
    try:
        text = timing_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise MeasurementError(f"{where}: cannot read the GNU time record {timing_path}: {exc}") from exc
    elapsed = None
    peak_kib = None
    for line in text.splitlines():
        match = GNU_TIME_ELAPSED_PATTERN.match(line)
        if match:
            hours = int(match.group("hours") or 0)
            minutes = int(match.group("minutes"))
            seconds = float(match.group("seconds"))
            elapsed = hours * 3600 + minutes * 60 + seconds
            continue
        match = GNU_TIME_RSS_PATTERN.match(line)
        if match:
            peak_kib = int(match.group("kib"))
    if elapsed is None:
        raise MeasurementError(f"{where}: the GNU time record has no elapsed time ({timing_path})")
    if peak_kib is None:
        raise MeasurementError(f"{where}: the GNU time record has no peak RSS ({timing_path})")
    return elapsed, peak_kib / 1024.0


def drive_pass(
    command: list[str],
    log_path: Path,
    timing_path: Path,
    scenario: Scenario,
    repetition: int,
    warmup: bool,
    timeout_seconds: float,
    run_dir: Path,
) -> None:
    """Run one bdevperf pass inside the caller's environment and record it."""
    log_path.parent.mkdir(parents=True, exist_ok=True)
    time_record = run_dir / f".{log_path.stem}.time"
    time_record.unlink(missing_ok=True)
    started_at = timestamp()
    started = time.monotonic()
    wrapped = ["/usr/bin/time", "-v", "-o", str(time_record), *command]
    process = subprocess.Popen(
        wrapped,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        cwd=str(run_dir),
    )
    try:
        output, _ = process.communicate(timeout=timeout_seconds)
    except subprocess.TimeoutExpired:
        process.kill()
        process.communicate()
        log_path.write_text(
            f"$ {shlex.join(command)}\n[TIMEOUT] bdevperf exceeded {timeout_seconds:.0f}s\n",
            encoding="utf-8",
        )
        raise MeasurementError(
            f"{scenario.key} rep{repetition}: bdevperf exceeded {timeout_seconds:.0f}s"
        )
    wall_observed = time.monotonic() - started
    finished_at = timestamp()
    log_path.write_text(f"$ {shlex.join(command)}\n{output}", encoding="utf-8")
    elapsed = wall_observed
    peak_rss_mib = 0.0
    timing_error = ""
    try:
        elapsed, peak_rss_mib = read_gnu_time(time_record, f"{scenario.key} rep{repetition}")
    except MeasurementError as exc:
        timing_error = str(exc)
    time_record.unlink(missing_ok=True)
    timing = {
        "scenario": scenario.key,
        "repetition": repetition,
        "warmup": warmup,
        "command": command,
        "started_at": started_at,
        "finished_at": finished_at,
        "duration_s": round(elapsed, 6),
        "exit_code": process.returncode,
        "peak_rss_mib": round(peak_rss_mib, 3),
        "log": str(log_path),
        "timing_error": timing_error,
    }
    atomic_write_json(timing_path, timing)
    if process.returncode != 0:
        raise MeasurementError(
            f"{scenario.key} rep{repetition}: bdevperf exited with {process.returncode}; "
            f"see {log_path}"
        )
    if timing_error:
        raise MeasurementError(f"{scenario.key} rep{repetition}: {timing_error}")
    return {"output": output, "timing": timing}


# --- strict parsing ----------------------------------------------------------


def _require_single(matches: list[re.Match[str]], description: str, where: str) -> re.Match[str]:
    if len(matches) != 1:
        raise MeasurementError(f"{where}: expected exactly one {description}, found {len(matches)}")
    return matches[0]


def parse_pass(output: str, scenario: Scenario, duration: int, where: str) -> dict[str, float]:
    total_matches: list[re.Match[str]] = []
    job_rows: list[re.Match[str]] = []
    job_headers: list[re.Match[str]] = []
    latency_jobs: list[tuple[str, float]] = []
    current_latency_job: str | None = None
    p99: dict[str, float] = {}

    for raw_line in output.splitlines():
        line = raw_line.replace("\r", "")
        header = JOB_HEADER_PATTERN.match(line)
        if header:
            job_headers.append(header)
            current_latency_job = None
            continue
        latency_header = LATENCY_JOB_PATTERN.match(line)
        if latency_header:
            current_latency_job = latency_header.group("name")
            continue
        cutoff = CUTOFF_PATTERN.match(line)
        if cutoff:
            if current_latency_job is None:
                raise MeasurementError(f"{where}: latency cutoff without a job section: {line.strip()}")
            if cutoff.group("percent") == "99.00000":
                p99[current_latency_job] = finite_positive(
                    float(cutoff.group("value")), f"{where}: p99 latency"
                )
            continue
        total = TOTAL_PATTERN.match(line)
        if total:
            total_matches.append(total)
            continue
        row = JOB_PATTERN.match(line)
        if row and not header:
            job_rows.append(row)

    total = _require_single(total_matches, "bdevperf total row", where)
    if len(job_headers) != scenario.bdev_count:
        raise MeasurementError(
            f"{where}: expected {scenario.bdev_count} job header(s), found {len(job_headers)}"
        )
    if len(job_rows) != scenario.bdev_count:
        raise MeasurementError(
            f"{where}: expected {scenario.bdev_count} job row(s), found {len(job_rows)}"
        )
    if len(p99) != scenario.bdev_count:
        raise MeasurementError(
            f"{where}: expected the latency summary of {scenario.bdev_count} job(s), "
            f"found {len(p99)} 99.00000% cutoff line(s)"
        )

    for header in job_headers:
        workload = header.group("workload")
        if workload != scenario.workload:
            raise MeasurementError(
                f"{where}: bdevperf reported workload {workload!r}, expected {scenario.workload!r}"
            )
        if int(header.group("queue_depth")) != scenario.queue_depth:
            raise MeasurementError(
                f"{where}: bdevperf reported queue depth {header.group('queue_depth')}, "
                f"expected {scenario.queue_depth}"
            )
        if int(header.group("io_size")) != scenario.io_size:
            raise MeasurementError(
                f"{where}: bdevperf reported IO size {header.group('io_size')}, "
                f"expected {scenario.io_size}"
            )
        if scenario.read_percentage is not None and header.group("percentage") is not None:
            if int(header.group("percentage")) != scenario.read_percentage:
                raise MeasurementError(
                    f"{where}: bdevperf reported read percentage "
                    f"{header.group('percentage')}, expected {scenario.read_percentage}"
                )

    job_iops = 0.0
    for row in job_rows:
        job_iops += finite_positive(float(row.group("iops")), f"{where}: job IOPS")
        for field in ("fail", "timeout"):
            if float(row.group(field)) != 0:
                raise MeasurementError(
                    f"{where}: bdevperf reported {field}={row.group(field)} for {row.group('name')}"
                )
        runtime = float(row.group("runtime"))
        if abs(runtime - duration) > 1.0:
            raise MeasurementError(
                f"{where}: bdevperf ran for {runtime:.2f}s, expected about {duration}s"
            )

    iops = finite_positive(float(total.group("iops")), f"{where}: total IOPS")
    bandwidth = finite_positive(float(total.group("mibps")), f"{where}: total MiB/s")
    average_latency = finite_positive(float(total.group("avg")), f"{where}: average latency")
    min_latency = finite_positive(float(total.group("min")), f"{where}: minimum latency")
    max_latency = finite_positive(float(total.group("max")), f"{where}: maximum latency")
    for field, value in (
        ("failure rate", float(total.group("fail"))),
        ("timeout rate", float(total.group("timeout"))),
    ):
        if value != 0:
            raise MeasurementError(f"{where}: bdevperf reported {field}={value}")
    if not min_latency <= average_latency <= max_latency:
        raise MeasurementError(
            f"{where}: inconsistent latency values min={min_latency} avg={average_latency} "
            f"max={max_latency}"
        )
    if abs(job_iops - iops) > max(1.0, iops * 0.01):
        raise MeasurementError(
            f"{where}: total IOPS {iops:.2f} differs from the job sum {job_iops:.2f}"
        )
    p99_latency = max(p99.values())
    if p99_latency < min_latency:
        raise MeasurementError(
            f"{where}: p99 latency {p99_latency} is smaller than the minimum {min_latency}"
        )
    return {
        IOPS_LABEL: iops,
        BANDWIDTH_LABEL: bandwidth,
        AVG_LATENCY_LABEL: average_latency,
        P99_LATENCY_LABEL: p99_latency,
    }


# --- statistics and JSON assembly -------------------------------------------


def summarize(samples: list[float]) -> dict[str, Any]:
    if not samples:
        raise MeasurementError("cannot summarise an empty sample list")
    for sample in samples:
        finite_positive(sample, "sample value")
    return {
        "repetitions": len(samples),
        "median": median(samples),
        "min": min(samples),
        "max": max(samples),
        "mean": fmean(samples),
        "stdev": stdev(samples) if len(samples) > 1 else None,
    }


def load_json(path: Path, description: str) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise MeasurementError(f"cannot read {description} ({path}): {exc}") from exc
    if not isinstance(payload, dict):
        raise MeasurementError(f"{description} ({path}) is not a JSON object")
    return payload


def validate_parameters(args: argparse.Namespace) -> None:
    if args.reps < 1 or args.reps > 20:
        raise MeasurementError(f"--reps must be between 1 and 20, got {args.reps}")
    if args.warmup < 1 or args.warmup > 5:
        raise MeasurementError(f"--warmup must be between 1 and 5, got {args.warmup}")
    if args.duration < 5 or args.duration > 10:
        raise MeasurementError(f"--duration must be between 5 and 10 seconds, got {args.duration}")


def resolve_layout(args: argparse.Namespace) -> tuple[Path, Path, Path, Path]:
    bdevperf = args.bdevperf.resolve()
    if not bdevperf.is_file():
        raise MeasurementError(f"bdevperf is missing: {bdevperf}")
    work_dir: Path = args.work_dir.resolve()
    results_dir: Path = args.results_dir.resolve()
    return bdevperf, work_dir, results_dir, results_dir / "runs"


def load_runtime_inputs(
    work_dir: Path,
) -> tuple[dict[str, Any], dict[str, str]]:
    runtime_profile = load_json(work_dir / "runtime.json", "the DPDK runtime profile")
    build_meta = load_json(work_dir / "build-meta.json", "the build metadata")
    if not runtime_profile.get("eal_args"):
        raise MeasurementError("the DPDK runtime profile has no eal_args")
    build_versions = {
        "spdk_full_version": build_meta.get("actual_full_version"),
        "dpdk_full_version": build_meta.get("dependencies", {}).get("dpdk", {}).get("version"),
        "isa_l_commit": build_meta.get("dependencies", {}).get("isa_l", {}).get("commit"),
        "source_tree_sha256": build_meta.get("sources", {}).get("spdk", {}).get("source_tree_sha256"),
        "dpdk_source_tree_sha256": build_meta.get("dependencies", {}).get("dpdk", {}).get("source_tree_sha256"),
        "isa_l_source_tree_sha256": build_meta.get("dependencies", {}).get("isa_l", {}).get("source_tree_sha256"),
    }
    for name, value in build_versions.items():
        if not isinstance(value, str) or not value:
            raise MeasurementError(f"the build metadata is missing {name}")
    return runtime_profile, build_versions


def drive(args: argparse.Namespace) -> int:
    """Run the whole matrix and record raw logs plus timing artifacts."""
    validate_parameters(args)
    bdevperf, work_dir, results_dir, runs_dir = resolve_layout(args)
    runs_dir.mkdir(parents=True, exist_ok=True)
    config_dir = work_dir / "matrix"
    config_dir.mkdir(parents=True, exist_ok=True)
    runtime_profile, _ = load_runtime_inputs(work_dir)
    timeout_seconds = args.duration + 120

    for scenario in SCENARIOS:
        config_path = config_dir / f"{scenario.key}.bdev.json"
        jobs_path = config_dir / f"{scenario.key}.jobs.ini"
        write_bdev_config(config_path, scenario.bdev_count)
        write_jobs_config(jobs_path, scenario)
        command = build_command(
            bdevperf, scenario, args.duration, config_path, jobs_path, runtime_profile
        )
        scenario_dir = runs_dir / scenario.key
        scenario_dir.mkdir(parents=True, exist_ok=True)
        print(f"[spdk-matrix] scenario {scenario.key}: {scenario.description}", flush=True)
        print(f"[spdk-matrix] $ {shlex.join(command)}", flush=True)

        drive_pass(
            command,
            scenario_dir / "warmup.log",
            scenario_dir / "warmup.json",
            scenario,
            0,
            True,
            timeout_seconds,
            scenario_dir,
        )
        for repetition in range(1, args.reps + 1):
            drive_pass(
                command,
                scenario_dir / f"rep{repetition}.log",
                scenario_dir / f"rep{repetition}.json",
                scenario,
                repetition,
                False,
                timeout_seconds,
                scenario_dir,
            )
            print(
                f"[spdk-matrix] {scenario.key} rep{repetition}/{args.reps}: recorded",
                flush=True,
            )

    print(
        f"[spdk-matrix] recorded {len(SCENARIOS)} scenarios "
        f"({args.warmup} warmup + {args.reps} measurement passes each) under {runs_dir}",
        flush=True,
    )
    return 0


def read_pass_artifacts(
    log_path: Path,
    timing_path: Path,
    scenario: Scenario,
    repetition: int,
    warmup: bool,
    expected_command: list[str],
) -> tuple[str, dict[str, Any]]:
    """Read one recorded pass and validate its timing artifact strictly."""
    where = f"{scenario.key} warmup" if warmup else f"{scenario.key} rep{repetition}"
    timing = load_json(timing_path, f"the timing record of {where}")
    if timing.get("scenario") != scenario.key:
        raise MeasurementError(f"{where}: timing record belongs to {timing.get('scenario')!r}")
    if timing.get("repetition") != repetition:
        raise MeasurementError(f"{where}: timing record repetition is {timing.get('repetition')!r}")
    if bool(timing.get("warmup")) is not warmup:
        raise MeasurementError(f"{where}: timing record warmup flag is {timing.get('warmup')!r}")
    if timing.get("exit_code") != 0:
        raise MeasurementError(f"{where}: recorded exit code is {timing.get('exit_code')!r}")
    if timing.get("command") != expected_command:
        raise MeasurementError(f"{where}: recorded command differs from the expected matrix command")
    recorded_log = Path(str(timing.get("log", "")))
    if recorded_log.name != log_path.name:
        raise MeasurementError(f"{where}: timing record points at {recorded_log.name}")
    duration = timing.get("duration_s")
    if not isinstance(duration, (int, float)) or isinstance(duration, bool) or duration <= 0:
        raise MeasurementError(f"{where}: recorded wall time is invalid: {duration!r}")
    peak_rss = finite_positive(
        float(timing.get("peak_rss_mib", 0.0)), f"{where}: peak RSS"
    )
    try:
        text = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise MeasurementError(f"{where}: cannot read the raw log {log_path}: {exc}") from exc
    lines = text.splitlines()
    if not lines or not lines[0].startswith("$ "):
        raise MeasurementError(f"{where}: raw log does not start with its command line")
    timing["duration_s"] = float(duration)
    timing["peak_rss_mib"] = peak_rss
    return "\n".join(lines[1:]), timing


def report(args: argparse.Namespace) -> int:
    """Parse the recorded matrix on the host and apply the strict contract."""
    validate_parameters(args)
    bdevperf, work_dir, results_dir, runs_dir = resolve_layout(args)
    config_dir = work_dir / "matrix"
    runs_dir.mkdir(parents=True, exist_ok=True)
    config_dir.mkdir(parents=True, exist_ok=True)
    runtime_profile, build_versions = load_runtime_inputs(work_dir)

    scenario_entries: list[dict[str, Any]] = []
    metric_samples: dict[str, list[float]] = {}
    raw_sections: list[str] = []

    for scenario in SCENARIOS:
        config_path = config_dir / f"{scenario.key}.bdev.json"
        jobs_path = config_dir / f"{scenario.key}.jobs.ini"
        write_bdev_config(config_path, scenario.bdev_count)
        write_jobs_config(jobs_path, scenario)
        command = build_command(
            bdevperf, scenario, args.duration, config_path, jobs_path, runtime_profile
        )
        scenario_dir = runs_dir / scenario.key
        scenario_dir.mkdir(parents=True, exist_ok=True)
        print(f"[spdk-matrix] scenario {scenario.key}: {scenario.description}", flush=True)
        print(f"[spdk-matrix] $ {shlex.join(command)}", flush=True)

        warmup_log = scenario_dir / "warmup.log"
        warmup_output, _ = read_pass_artifacts(
            warmup_log, scenario_dir / "warmup.json", scenario, 0, True, command
        )
        parse_pass(warmup_output, scenario, args.duration, f"{scenario.key} warmup")
        raw_sections.append(
            f"########## {scenario.key} / warmup\n# {scenario.description}\n"
            f"{warmup_log.read_text(encoding='utf-8')}"
        )

        scenario_metrics: dict[str, list[float]] = {
            spec[0]: [] for spec in METRIC_SPECS
        }
        rep_logs: list[str] = []
        rep_timings: list[dict[str, Any]] = []
        for repetition in range(1, args.reps + 1):
            log_path = scenario_dir / f"rep{repetition}.log"
            timing_path = scenario_dir / f"rep{repetition}.json"
            output, timing = read_pass_artifacts(
                log_path, timing_path, scenario, repetition, False, command
            )
            values = parse_pass(
                output, scenario, args.duration,
                f"{scenario.key} rep{repetition}",
            )
            values[PEAK_RSS_LABEL] = finite_positive(
                timing["peak_rss_mib"],
                f"{scenario.key} rep{repetition}: peak RSS",
            )
            for label, value in values.items():
                scenario_metrics[label].append(value)
            rep_logs.append(str(log_path))
            rep_timings.append(timing)
            raw_sections.append(
                f"########## {scenario.key} / rep{repetition}\n# {scenario.description}\n"
                f"{log_path.read_text(encoding='utf-8')}"
            )
            print(
                f"[spdk-matrix] {scenario.key} rep{repetition}/{args.reps}: "
                f"IOPS={values[IOPS_LABEL]:.2f} MiB/s={values[BANDWIDTH_LABEL]:.2f} "
                f"avg={values[AVG_LATENCY_LABEL]:.2f}us p99={values[P99_LATENCY_LABEL]:.2f}us "
                f"rss={values[PEAK_RSS_LABEL]:.2f}MiB",
                flush=True,
            )

        for label, samples in scenario_metrics.items():
            if len(samples) != args.reps:
                raise MeasurementError(
                    f"{scenario.key}: metric {label} has {len(samples)} samples, expected {args.reps}"
                )
            metric_samples[f"{scenario.key} / {label}"] = samples
        scenario_entries.append(
            {
                "key": scenario.key,
                "workload": scenario.workload,
                "io_size_bytes": scenario.io_size,
                "queue_depth": scenario.queue_depth,
                "bdev_count": scenario.bdev_count,
                "read_percentage": scenario.read_percentage,
                "cpu_mask": scenario.cpu_mask,
                "raw_logs": {"warmup": str(warmup_log), "reps": rep_logs},
                "timings": rep_timings,
            }
        )

    if len(metric_samples) != len(SCENARIOS) * len(METRIC_SPECS):
        raise MeasurementError(
            f"expected {len(SCENARIOS) * len(METRIC_SPECS)} metrics, "
            f"collected {len(metric_samples)}"
        )

    results: dict[str, Any] = {}
    for scenario in SCENARIOS:
        for label, unit, direction, raw_field in METRIC_SPECS:
            name = f"{scenario.key} / {label}"
            samples = metric_samples[name]
            statistics = summarize(samples)
            results[name] = {
                "source_name": name,
                "source_field": raw_field,
                "group": scenario.key,
                "aggregate": "median of the measurement repetitions",
                "value": statistics["median"],
                "unit": unit,
                "direction": direction,
                "samples": [round(sample, 6) for sample in samples],
                "statistics": statistics,
            }

    (results_dir / "benchmark_raw.txt").write_text(
        "\n".join(raw_sections), encoding="utf-8"
    )

    payload = {
        "software": SOFTWARE,
        "category": CATEGORY,
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "benchmark": BENCHMARK_NAME,
        "timestamp": timestamp(),
        "parameters": {
            "measurement_reps": args.reps,
            "warmup_reps": args.warmup,
            "duration_seconds": args.duration,
            "aggregate": "median across independent measurement repetitions",
            "bdev_type": "Malloc",
            "bdev_block_size": MALLOC_BLOCK_SIZE,
            "bdev_size_mib": MALLOC_BLOCK_SIZE * MALLOC_BLOCKS // (1024 * 1024),
            "io_direction": "all I/O stays inside the SPDK userspace block stack",
            "offline": True,
            "strict": True,
            "scenarios": [entry for entry in scenario_entries],
        },
        "runtime_context": {
            "eal_args": runtime_profile.get("eal_args", []),
            "bdevperf_args": runtime_profile.get("bdevperf_args", []),
            "hugepages": runtime_profile.get("hugepages", {}),
            "runtime_profile": runtime_profile.get("profile"),
            "cpu_count": os.cpu_count(),
            "build": build_versions,
        },
        "results": results,
    }
    atomic_write_json(results_dir / "benchmark_spdk.json", payload)
    print(
        f"[spdk-matrix] wrote {len(results)} metrics for {len(SCENARIOS)} scenarios "
        f"({args.reps} repetitions each) to {results_dir / 'benchmark_spdk.json'}",
        flush=True,
    )
    return 0


def measure(args: argparse.Namespace) -> int:
    """Run the matrix and parse it in one process (standalone convenience path)."""
    drive(args)
    return report(args)


def add_measurement_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--bdevperf", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--results-dir", required=True, type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True, choices=("x86_64", "aarch64"))
    parser.add_argument("--variant", default="base")
    parser.add_argument("--reps", type=int, default=5)
    parser.add_argument("--warmup", type=int, default=1)
    parser.add_argument("--duration", type=int, default=5)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)
    for name, handler, summary in (
        ("drive", drive, "run the matrix and record raw logs plus timing artifacts"),
        ("report", report, "parse the recorded matrix strictly on the host"),
        ("measure", measure, "drive and report in one process"),
    ):
        sub = subcommands.add_parser(name, help=summary)
        add_measurement_arguments(sub)
        sub.set_defaults(handler=handler)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        return args.handler(args)
    except MeasurementError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 50
    except OSError as exc:
        print(f"ERROR: measurement I/O failure: {exc}", file=sys.stderr)
        return 50


if __name__ == "__main__":
    raise SystemExit(main())
