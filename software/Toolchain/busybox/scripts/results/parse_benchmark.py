#!/usr/bin/env python3
"""Normalize the BusyBox 1.38.0 applet matrix from the recorded samples.

Every scenario measures exactly one BusyBox child process (one applet
invocation) and contributes:

* the wall-clock median of that process in seconds (lower is better),
* the median peak resident set size of that process in MiB (lower is better),
* one workload metric derived from the pinned input size and the wall clock,
  e.g. MiB of input hashed/scanned/compressed per second or sorted lines per
  second (higher is better).

The applet output of each repetition is verified by ``scripts/verify_outputs.py``
immediately after the measured window; its compact report is stored as
``runs/<scenario>/rep<i>.check``.  The parser cross-checks every check line
against the pinned constants exported by ``scripts/common.sh``, so a changed
workload cannot be reported as a valid measurement.

The parser is strict by design: the scenario set must match exactly, every
declared repetition sample/log/check file must exist, every child must have
exited zero without a timeout, every check must be ``ok`` with the expected
value, and every metric must be finite and positive.  Nothing is filled in,
interpolated or zero-padded.
"""

from __future__ import annotations

import json
import math
import os
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

MIB = 1024.0 * 1024.0

SCENARIO_GROUP = {
    "sha256sum_hash": "hashing",
    "sort_numeric": "sorting",
    "grep_count": "text_scan",
    "sed_substitute": "text_transform",
    "awk_aggregate": "text_transform",
    "gzip_compress": "compression",
    "tar_gzip_create": "compression",
    "cut_fields": "text_transform",
}
SCENARIOS = list(SCENARIO_GROUP)


class ParseError(RuntimeError):
    pass


def env_int(name: str) -> int:
    raw = os.environ.get(name)
    if raw is None or not raw.strip():
        raise ParseError(f"missing required environment variable {name}")
    try:
        return int(raw)
    except ValueError as exc:
        raise ParseError(f"environment variable {name} is not an integer: {raw!r}") from exc


def env(name: str) -> str:
    return os.environ.get(name, "")


def read_text(path: Path, what: str) -> str:
    if not path.is_file():
        raise ParseError(f"missing {what}: {path}")
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise ParseError(f"cannot read {what} {path}: {exc}") from exc


def parse_check_file(path: Path, scenario: str, repetition: int) -> dict[str, tuple[str, str]]:
    """Return the declared checks of one repetition (name -> (expected, actual))."""
    text = read_text(path, f"verification report of {scenario} rep{repetition}")
    checks: dict[str, tuple[str, str]] = {}
    result_status: str | None = None
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("PERF-CHECK "):
            fields: dict[str, str] = {}
            for token in line.split()[1:]:
                key, _, value = token.partition("=")
                fields[key] = value
            name = fields.get("name")
            if not name or name in checks:
                raise ParseError(
                    f"{scenario} rep{repetition}: malformed or duplicate check line: {line}"
                )
            if fields.get("status") != "ok":
                raise ParseError(
                    f"{scenario} rep{repetition}: check {name} failed "
                    f"(expected={fields.get('expected')} actual={fields.get('actual')})"
                )
            checks[name] = (fields.get("expected", ""), fields.get("actual", ""))
        elif line.startswith("PERF-RESULT "):
            result_status = line.split("status=", 1)[-1].strip()
        else:
            raise ParseError(f"{scenario} rep{repetition}: unexpected line: {line}")
    if result_status != "ok":
        raise ParseError(
            f"{scenario} rep{repetition}: verification result is {result_status!r}, not 'ok'"
        )
    return checks


def require_check(
    checks: dict[str, tuple[str, str]],
    scenario: str,
    repetition: int,
    name: str,
    expected: str,
) -> str:
    if name not in checks:
        raise ParseError(f"{scenario} rep{repetition}: missing check {name}")
    actual_expected, actual = checks[name]
    if actual_expected != expected:
        raise ParseError(
            f"{scenario} rep{repetition}: check {name} declares expected={actual_expected}, "
            f"the pinned value is {expected}"
        )
    return actual


def require_positive_check(
    checks: dict[str, tuple[str, str]], scenario: str, repetition: int, name: str
) -> float:
    actual = require_check(checks, scenario, repetition, name, "gt0")
    try:
        value = float(actual)
    except ValueError as exc:
        raise ParseError(f"{scenario} rep{repetition}: check {name} is not numeric: {actual}") from exc
    if not math.isfinite(value) or value <= 0:
        raise ParseError(f"{scenario} rep{repetition}: check {name} must be positive, got {value}")
    return value


def workload_checks(
    scenario: str, checks: dict[str, tuple[str, str]], repetition: int
) -> list[tuple[str, float, str, str]]:
    """Validate the scenario checks and return its per-repetition workload metrics."""
    if scenario == "sha256sum_hash":
        digest_lines = require_check(
            checks, scenario, repetition, "digest_lines", str(env_int("BUSYBOX_CORPUS_SHA256SUM_ARGS"))
        )
        if int(digest_lines) != env_int("BUSYBOX_CORPUS_SHA256SUM_ARGS"):
            raise ParseError(f"{scenario} rep{repetition}: wrong digest line count {digest_lines}")
        require_check(
            checks, scenario, repetition, "digest_value", env("BUSYBOX_FIXTURE_CORPUS_SHA256")
        )
        require_check(checks, scenario, repetition, "digest_unique_values", "1")
        return []
    if scenario == "sort_numeric":
        require_check(checks, scenario, repetition, "sorted_order", "0")
        sorted_lines = require_check(
            checks, scenario, repetition, "sorted_lines",
            str(env_int("BUSYBOX_FIXTURE_SORT_LINES")),
        )
        require_positive_check(checks, scenario, repetition, "artifact_bytes_positive")
        return [("sorted_lines", float(sorted_lines), "lines", "higher_is_better")]
    if scenario == "grep_count":
        matched = require_check(
            checks, scenario, repetition, "matched_lines",
            str(env_int("BUSYBOX_EXPECT_GREP_MATCHES")),
        )
        return [("matched_lines", float(matched), "lines", "higher_is_better")]
    if scenario == "sed_substitute":
        require_check(
            checks, scenario, repetition, "output_sha256", env("BUSYBOX_EXPECT_SED_SHA256")
        )
        require_positive_check(checks, scenario, repetition, "artifact_bytes_positive")
        return []
    if scenario == "awk_aggregate":
        total = require_check(
            checks, scenario, repetition, "aggregate_sum", str(env_int("BUSYBOX_EXPECT_AWK_SUM"))
        )
        return [("aggregate_value", float(total), "bytes", "higher_is_better")]
    if scenario == "gzip_compress":
        require_check(
            checks, scenario, repetition, "roundtrip_sha256", env("BUSYBOX_FIXTURE_GZIP_SHA256")
        )
        require_positive_check(checks, scenario, repetition, "compressed_bytes_positive")
        return []
    if scenario == "tar_gzip_create":
        entries = require_check(
            checks, scenario, repetition, "archive_entries",
            str(env_int("BUSYBOX_FIXTURE_TAR_ENTRIES")),
        )
        require_positive_check(checks, scenario, repetition, "archive_bytes_positive")
        return [("archive_entries", float(entries), "files", "higher_is_better")]
    if scenario == "cut_fields":
        require_check(
            checks, scenario, repetition, "output_sha256", env("BUSYBOX_EXPECT_CUT_SHA256")
        )
        require_positive_check(checks, scenario, repetition, "artifact_bytes_positive")
        return []
    raise ParseError(f"unknown scenario: {scenario}")


def wall_metric_name(scenario: str) -> str:
    return {
        "sha256sum_hash": ("hash_mib_per_second", env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")
                           * env_int("BUSYBOX_CORPUS_SHA256SUM_ARGS")),
        "sort_numeric": ("sorted_lines_per_second", None),
        "grep_count": ("scan_mib_per_second", env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")),
        "sed_substitute": ("sed_mib_per_second", env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")),
        "awk_aggregate": ("aggregate_mib_per_second", env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")),
        "gzip_compress": ("gzip_mib_per_second", env_int("BUSYBOX_FIXTURE_GZIP_BYTES")),
        "tar_gzip_create": ("archive_mib_per_second", env_int("BUSYBOX_FIXTURE_TAR_BYTES")),
        "cut_fields": ("cut_mib_per_second", env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")),
    }[scenario]


def wall_throughput(scenario: str, wall_seconds: float, unit: str) -> float:
    if scenario == "sort_numeric":
        return env_int("BUSYBOX_FIXTURE_SORT_LINES") / wall_seconds
    if unit == "lines":
        return env_int("BUSYBOX_EXPECT_GREP_MATCHES") / wall_seconds
    if unit == "files":
        return env_int("BUSYBOX_FIXTURE_TAR_ENTRIES") / wall_seconds
    return (float(_wall_throughput_base(scenario)) / MIB) / wall_seconds


def _wall_throughput_base(scenario: str) -> int:
    return {
        "sha256sum_hash": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES")
        * env_int("BUSYBOX_CORPUS_SHA256SUM_ARGS"),
        "grep_count": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES"),
        "sed_substitute": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES"),
        "awk_aggregate": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES"),
        "gzip_compress": env_int("BUSYBOX_FIXTURE_GZIP_BYTES"),
        "tar_gzip_create": env_int("BUSYBOX_FIXTURE_TAR_BYTES"),
        "cut_fields": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES"),
    }[scenario]


def load_sample(scenario_dir: Path, scenario: str, index: int) -> dict[str, Any]:
    sample_path = scenario_dir / f"rep{index}.json"
    if not sample_path.is_file():
        raise ParseError(f"missing repetition sample: {sample_path}")
    try:
        payload = json.loads(sample_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ParseError(f"invalid repetition sample {sample_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ParseError(f"repetition sample is not an object: {sample_path}")
    if payload.get("exit_code") != 0:
        raise ParseError(
            f"repetition {index} of {scenario} failed with exit code {payload.get('exit_code')}"
        )
    if payload.get("timed_out") is True:
        raise ParseError(f"repetition {index} of {scenario} timed out")
    wall = payload.get("wall_seconds")
    rss = payload.get("max_rss_mib")
    for label, value in (("wall_seconds", wall), ("max_rss_mib", rss)):
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ParseError(f"repetition {index} of {scenario} has no numeric {label}")
        if not math.isfinite(float(value)) or float(value) <= 0:
            raise ParseError(f"repetition {index} of {scenario} {label} must be positive")
    if payload.get("rss_source") != "proc_vmhwm_poll":
        raise ParseError(
            f"repetition {index} of {scenario} does not declare the VmHWM RSS source"
        )
    read_text(scenario_dir / f"rep{index}.log", "repetition log")
    return {
        "wall_seconds": float(wall),
        "max_rss_mib": float(rss),
        "scenario_dir": scenario_dir,
    }


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": statistics.median(values),
        "mean": statistics.fmean(values),
        "min": min(values),
        "max": max(values),
        "stdev": statistics.stdev(values) if len(values) > 1 else 0.0,
    }


def build_metric(
    metric_name: str,
    scenario: str,
    value: float,
    unit: str,
    direction: str,
    stats: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": metric_name,
        "scenario": scenario,
        "group": SCENARIO_GROUP[scenario],
        "value": round(value, 6),
        "unit": unit,
        "direction": direction,
        "median": round(stats["median"], 6),
        "mean": round(stats["mean"], 6),
        "min": round(stats["min"], 6),
        "max": round(stats["max"], 6),
        "stdev": round(stats["stdev"], 6),
        "samples": [round(sample, 6) for sample in samples],
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    runs_dir = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
        reps = env_int("BUSYBOX_REPS")
        if not runs_dir.is_dir():
            raise ParseError(f"runs directory does not exist: {runs_dir}")

        present = sorted(entry.name for entry in runs_dir.iterdir() if entry.is_dir())
        if present != sorted(SCENARIOS):
            raise ParseError(
                "scenario set differs from the expected set: "
                f"missing={sorted(set(SCENARIOS) - set(present))} "
                f"unexpected={sorted(set(present) - set(SCENARIOS))}"
            )

        results: dict[str, Any] = {}
        for scenario in SCENARIOS:
            scenario_dir = runs_dir / scenario
            wall_samples: list[float] = []
            rss_samples: list[float] = []
            workload_samples: dict[str, list[float]] = {}
            descriptor: dict[str, tuple[str, str]] = {}
            expected_metrics: set[str] | None = None
            for index in range(1, reps + 1):
                sample = load_sample(scenario_dir, scenario, index)
                checks = parse_check_file(scenario_dir / f"rep{index}.check", scenario, index)
                wall = sample["wall_seconds"]
                wall_samples.append(wall)
                rss_samples.append(sample["max_rss_mib"])

                extracted = workload_checks(scenario, checks, index)
                throughput_name, base_bytes = wall_metric_name(scenario)
                if base_bytes is None:
                    throughput_value = wall_throughput(scenario, wall, "lines")
                    throughput_unit = "lines/s"
                else:
                    throughput_value = (float(base_bytes) / MIB) / wall
                    throughput_unit = "MiB/s"
                extracted.append((throughput_name, throughput_value, throughput_unit, "higher_is_better"))

                names_this_rep: set[str] = set()
                for name, value, unit, direction in extracted:
                    if name in names_this_rep:
                        raise ParseError(f"{scenario} repetition {index}: duplicate metric {name}")
                    names_this_rep.add(name)
                    if not math.isfinite(value) or value <= 0:
                        raise ParseError(
                            f"{scenario} repetition {index}: metric {name} must be finite "
                            f"and positive, got {value}"
                        )
                    workload_samples.setdefault(name, []).append(float(value))
                    previous = descriptor.setdefault(name, (unit, direction))
                    if previous != (unit, direction):
                        raise ParseError(
                            f"{scenario}: metric {name} changed unit/direction between repetitions"
                        )
                if expected_metrics is None:
                    expected_metrics = names_this_rep
                elif names_this_rep != expected_metrics:
                    raise ParseError(
                        f"{scenario} repetition {index}: metric set differs from the first "
                        f"repetition (missing={sorted(expected_metrics - names_this_rep)}, "
                        f"unexpected={sorted(names_this_rep - expected_metrics)})"
                    )

            for name in sorted(expected_metrics or set()):
                if len(workload_samples[name]) != reps:
                    raise ParseError(
                        f"{scenario}: metric {name} has {len(workload_samples[name])} samples, "
                        f"expected {reps}"
                    )
                unit, direction = descriptor[name]
                stats = summarize(workload_samples[name])
                metric_name = f"{scenario}_{name}"
                results[metric_name] = build_metric(
                    metric_name, scenario, stats["median"], unit, direction,
                    stats, workload_samples[name],
                )

            wall_stats = summarize(wall_samples)
            results[f"{scenario}_wall_s"] = build_metric(
                f"{scenario}_wall_s", scenario, wall_stats["median"], "s",
                "lower_is_better", wall_stats, wall_samples,
            )
            rss_stats = summarize(rss_samples)
            results[f"{scenario}_rss_mib"] = build_metric(
                f"{scenario}_rss_mib", scenario, rss_stats["median"], "MiB",
                "lower_is_better", rss_stats, rss_samples,
            )

        parameters: dict[str, Any] = {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "busybox_version": version,
            "build_configuration": "defconfig",
            "cflags": env("BUSYBOX_CFLAGS"),
            "build_parallel_jobs": env_int("BUSYBOX_BUILD_JOBS"),
            "source_archive": env("BUSYBOX_SOURCE_NAME"),
            "source_sha256": env("BUSYBOX_SOURCE_SHA256"),
            "required_applets": env("BUSYBOX_REQUIRED_APPLETS_TEXT"),
            "sha256sum_arguments": env_int("BUSYBOX_CORPUS_SHA256SUM_ARGS"),
            "corpus_lines": env_int("BUSYBOX_FIXTURE_CORPUS_LINES"),
            "corpus_bytes": env_int("BUSYBOX_FIXTURE_CORPUS_BYTES"),
            "gzip_input_lines": env_int("BUSYBOX_FIXTURE_GZIP_LINES"),
            "gzip_input_bytes": env_int("BUSYBOX_FIXTURE_GZIP_BYTES"),
            "sort_input_lines": env_int("BUSYBOX_FIXTURE_SORT_LINES"),
            "sort_input_bytes": env_int("BUSYBOX_FIXTURE_SORT_BYTES"),
            "tar_tree_files": env_int("BUSYBOX_FIXTURE_TAR_FILES"),
            "tar_tree_bytes": env_int("BUSYBOX_FIXTURE_TAR_BYTES"),
            "tar_archive_entries": env_int("BUSYBOX_FIXTURE_TAR_ENTRIES"),
            "expected_grep_matches": env_int("BUSYBOX_EXPECT_GREP_MATCHES"),
            "expected_awk_aggregate": env_int("BUSYBOX_EXPECT_AWK_SUM"),
            "fixture_sha256": {
                "corpus_text.txt": env("BUSYBOX_FIXTURE_SHA256_CORPUS"),
                "gzip_input.txt": env("BUSYBOX_FIXTURE_SHA256_GZIP"),
                "sort_input.txt": env("BUSYBOX_FIXTURE_SHA256_SORT"),
                "tar_tree": env("BUSYBOX_FIXTURE_SHA256_TAR"),
            },
            "expected_output_sha256": {
                "sed_substitute": env("BUSYBOX_EXPECT_SED_SHA256"),
                "cut_fields": env("BUSYBOX_EXPECT_CUT_SHA256"),
                "gzip_roundtrip": env("BUSYBOX_FIXTURE_GZIP_SHA256"),
            },
        }
        runtime_context: dict[str, Any] = {
            "c_compiler": env("BUSYBOX_C_COMPILER") or "unknown",
            "measurement_network_mode": env("BUSYBOX_NETWORK_MODE") or "unknown",
            "actual_version_string": env("BUSYBOX_ACTUAL_VERSION_STRING"),
            "applet_count": env_int("BUSYBOX_APPLET_COUNT"),
        }
    except (ParseError, KeyError) as exc:
        print(f"[busybox-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    normalized = {
        "benchmark": "busybox_applet_matrix",
        "software": "busybox",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "runtime_context": runtime_context,
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "throughput": {"unit": "MiB/s or lines/s", "direction": "higher_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[busybox-parse] normalized {len(results)} metrics across {len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
