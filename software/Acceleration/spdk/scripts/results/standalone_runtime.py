#!/usr/bin/env python3
"""Self-contained environment collection and reporting for the SPDK case.

The framework only calls the build/start/test/stop shell stages.  The
standalone entry point (`spdk_test.sh`) additionally uses this helper to record
system/runtime/build evidence and to render a single-architecture report.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "spdk"
CATEGORY = "Acceleration"
EXPECTED_METRICS = 40


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def command(args: list[str]) -> str:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=15,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def os_pretty_name() -> str:
    try:
        lines = Path("/etc/os-release").read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return "ERROR"
    for line in lines:
        field, separator, value = line.partition("=")
        if separator and field.strip() == "PRETTY_NAME":
            try:
                parsed = shlex.split(value, posix=True)
            except ValueError:
                return "ERROR"
            return " ".join(parsed) if parsed else "ERROR"
    return "ERROR"


def cpu_model() -> str:
    for line in command(["sh", "-c", "LC_ALL=C lscpu"]).splitlines():
        field, separator, value = line.partition(":")
        if separator and field.strip().casefold() == "model name" and value.strip():
            return value.strip()
    return "unknown"


def gcc_version() -> str:
    value = command(["gcc", "-dumpfullversion", "-dumpversion"])
    if value:
        return value.splitlines()[0]
    value = command(["cc", "--version"])
    return value.splitlines()[0] if value else "unknown"


def glibc_version() -> str:
    value = command(["getconf", "GNU_LIBC_VERSION"])
    if value:
        return value.splitlines()[0]
    implementation, version = platform.libc_ver()
    return f"{implementation} {version}" if implementation and version else "unknown"


def meminfo_kib(key: str) -> int:
    try:
        lines = Path("/proc/meminfo").read_text(encoding="utf-8").splitlines()
    except OSError:
        return 0
    for line in lines:
        fields = line.split()
        if len(fields) >= 2 and fields[0] == f"{key}:" and fields[1].isdigit():
            return int(fields[1])
    return 0


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "hostname": platform.node(),
        "architecture": platform.machine(),
        "platform": os_pretty_name(),
        "kernel": platform.release(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count() or 0,
        "memory_total_mib": meminfo_kib("MemTotal") // 1024,
        "python_version": platform.python_version(),
        "gcc_version": gcc_version(),
        "glibc_version": glibc_version(),
        "hugepages": {
            "total": meminfo_kib("HugePages_Total"),
            "free": meminfo_kib("HugePages_Free"),
            "size_kib": meminfo_kib("Hugepagesize"),
        },
    }


def collect_runtime_state() -> dict[str, Any]:
    governor = ""
    for path in Path("/sys/devices/system/cpu").glob("cpu[0-9]*/cpufreq/scaling_governor"):
        value = command(["cat", str(path)])
        if value:
            governor = value.splitlines()[0]
            break
    return {
        "collected_at": timestamp(),
        "architecture": platform.machine(),
        "memory_available_mib": meminfo_kib("MemAvailable") // 1024,
        "hugepages_free": meminfo_kib("HugePages_Free"),
        "cpu_governor": governor or "unknown",
        "load_average": list(os.getloadavg()) if hasattr(os, "getloadavg") else [],
    }


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    compiler: str,
    compiler_version: str,
    build_meta_file: Path | None = None,
) -> None:
    actual_version = ""
    try:
        actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    except OSError:
        actual_version = ""
    build_meta = load_json(build_meta_file) if build_meta_file is not None else {}
    payload = {
        "recorded_at": timestamp(),
        "software": SOFTWARE,
        "category": CATEGORY,
        "requested_version": requested_version,
        "actual_version": actual_version or "unknown",
        "architecture": architecture,
        "run_id": run_id,
        "compiler": compiler,
        "compiler_version": compiler_version or "unknown",
        "build_metadata": build_meta or None,
    }
    atomic_write_json(output, payload)


def validate_benchmark(benchmark: dict[str, Any], version: str, architecture: str) -> dict[str, Any]:
    if benchmark.get("software") != SOFTWARE:
        raise ValueError("benchmark_spdk.json does not describe the spdk case")
    for field, expected in (
        ("category", CATEGORY),
        ("version", version),
        ("architecture", architecture),
    ):
        if benchmark.get(field) != expected:
            raise ValueError(
                f"benchmark_spdk.json field {field} is {benchmark.get(field)!r}, "
                f"expected {expected!r}"
            )
    parameters = benchmark.get("parameters")
    if not isinstance(parameters, dict):
        raise ValueError("benchmark_spdk.json has no parameters object")
    if int(parameters.get("measurement_reps", 0)) < 1:
        raise ValueError("benchmark_spdk.json records no measurement repetitions")
    if int(parameters.get("warmup_reps", 0)) < 1:
        raise ValueError("benchmark_spdk.json records no warmup repetition")
    if parameters.get("offline") is not True:
        raise ValueError("benchmark_spdk.json does not mark the measurement as offline")
    scenarios = parameters.get("scenarios")
    if not isinstance(scenarios, list) or not scenarios:
        raise ValueError("benchmark_spdk.json records no scenarios")
    results = benchmark.get("results")
    if not isinstance(results, dict) or not results:
        raise ValueError("benchmark_spdk.json has no metrics")
    if len(results) != EXPECTED_METRICS:
        raise ValueError(
            f"benchmark_spdk.json has {len(results)} metrics, expected {EXPECTED_METRICS}"
        )
    repetitions = int(parameters["measurement_reps"])
    for name, item in results.items():
        if not isinstance(item, dict):
            raise ValueError(f"metric {name} is not an object")
        value = item.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"metric {name} is not numeric")
        if not math.isfinite(float(value)) or float(value) <= 0:
            raise ValueError(f"metric {name} is not a finite positive number")
        for field in ("unit", "direction", "group"):
            if not isinstance(item.get(field), str) or not item[field]:
                raise ValueError(f"metric {name} has no {field}")
        samples = item.get("samples")
        if not isinstance(samples, list) or len(samples) != repetitions:
            raise ValueError(
                f"metric {name} has {len(samples) if isinstance(samples, list) else 0} samples, "
                f"expected {repetitions}"
            )
        for sample in samples:
            if not isinstance(sample, (int, float)) or not math.isfinite(float(sample)):
                raise ValueError(f"metric {name} has a non-finite sample")
    return results


def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    failed_stage: str | None,
) -> int:
    benchmark = load_json(output_dir / "benchmark_spdk.json")
    results: dict[str, Any] = {}
    error = ""
    executed = command_status == "passed"
    # Only a successfully executed run has benchmark output worth validating;
    # a failed stage must report its own failure, not a misleading parse error.
    if executed:
        try:
            results = validate_benchmark(benchmark, version, architecture)
        except ValueError as exc:
            error = str(exc)
    status = "passed" if (not error and executed and cleanup_status == "passed") else "failed"
    metrics = {
        name: {
            "value": item["value"],
            "unit": item["unit"],
            "direction": item["direction"],
            "group": item["group"],
            "statistics": item.get("statistics", {}),
            "samples": item.get("samples", []),
        }
        for name, item in results.items()
    }
    payload = {
        "software": SOFTWARE,
        "category": CATEGORY,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": status,
        "command_status": command_status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage or None,
        "error": error or None,
        "parameters": benchmark.get("parameters", {}),
        "runtime_context": benchmark.get("runtime_context", {}),
        "metrics": metrics,
    }
    atomic_write_json(output_dir / "results.json", payload)
    atomic_write_json(
        output_dir / "status.json",
        {
            "category": CATEGORY,
            "software": SOFTWARE,
            "version": version,
            "architecture": architecture,
            "run_id": run_id,
            "status": status,
            "stage": "complete",
            "failed_stage": failed_stage or None,
            "exit_code": 0 if status == "passed" else 1,
            "cleanup_status": cleanup_status,
            "error": error or None,
        },
    )
    (output_dir / "report.md").write_text(render_report(payload), encoding="utf-8")
    return 0


def render_report(payload: dict[str, Any]) -> str:
    lines = [
        f"# SPDK {payload['version']} ({payload['architecture']}) single-architecture report",
        "",
        f"- run_id: `{payload['run_id']}`",
        f"- status: **{payload['status']}**",
        f"- cleanup_status: `{payload['cleanup_status']}`",
        f"- failed_stage: `{payload['failed_stage']}`",
        "",
    ]
    if payload.get("error"):
        lines.extend([f"> ERROR: {payload['error']}", ""])
    lines.extend([
        "All numbers below are medians of independent bdevperf measurement",
        "repetitions over Malloc bdevs. They describe the SPDK userspace block",
        "stack path, not a physical SSD.",
        "",
        "| scenario / metric | median | unit | direction |",
        "|---|---:|---|---|",
    ])
    for name in sorted(payload["metrics"]):
        item = payload["metrics"][name]
        lines.append(
            f"| {name} | {float(item['value']):.3f} | {item['unit']} | {item['direction']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    system_parser = subparsers.add_parser("system")
    system_parser.add_argument("output", type=Path)
    runtime_parser = subparsers.add_parser("runtime")
    runtime_parser.add_argument("output", type=Path)
    build_parser = subparsers.add_parser("build-info")
    build_parser.add_argument("output", type=Path)
    build_parser.add_argument("requested_version")
    build_parser.add_argument("actual_version_file", type=Path)
    build_parser.add_argument("architecture")
    build_parser.add_argument("run_id")
    build_parser.add_argument("compiler")
    build_parser.add_argument("compiler_version")
    build_parser.add_argument("build_meta_file", nargs="?", default=None)
    finalize_parser = subparsers.add_parser("finalize")
    finalize_parser.add_argument("output_dir", type=Path)
    finalize_parser.add_argument("version")
    finalize_parser.add_argument("architecture")
    finalize_parser.add_argument("run_id")
    finalize_parser.add_argument("command_status")
    finalize_parser.add_argument("cleanup_status")
    finalize_parser.add_argument("failed_stage", nargs="?", default=None)
    args = parser.parse_args()

    if args.command == "system":
        atomic_write_json(args.output, collect_system_info())
        return 0
    if args.command == "runtime":
        atomic_write_json(args.output, collect_runtime_state())
        return 0
    if args.command == "build-info":
        record_build_info(
            args.output,
            args.requested_version,
            args.actual_version_file,
            args.architecture,
            args.run_id,
            args.compiler,
            args.compiler_version,
            Path(args.build_meta_file) if args.build_meta_file else None,
        )
        return 0
    return finalize(
        args.output_dir,
        args.version,
        args.architecture,
        args.run_id,
        args.command_status,
        args.cleanup_status,
        args.failed_stage,
    )


if __name__ == "__main__":
    raise SystemExit(main())
