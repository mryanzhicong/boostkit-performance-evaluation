#!/usr/bin/env python3
"""Normalize the PCRE 8.45 measurement matrix from the recorded samples.

Every scenario contributes the wall-clock median of one measured child process
(seconds, lower is better) and the median peak resident set size of that process
(MiB, lower is better).  Scenarios additionally contribute one or more workload
metrics derived from their own raw output:

* ``pcretest`` timing scenarios report the number of match / compile operations
  the upstream tool performed per second (``pcretest -t`` iterates each pattern
  and each data line a fixed number of times; the wall clock around that process
  is the precise timer, the tool's own 0.1 microsecond quantised output is kept
  in the log as evidence only).
* the ``RunTest`` scenario reports the number of upstream assertions that
  passed.
* the ``pcre_bench`` harness reports its own per-call cost and throughput, which
  it measured with ``CLOCK_MONOTONIC`` around the fixed loop.
* ``pcregrep`` reports matched lines and scanned MiB/s over the pinned corpus.

The parser is strict by design: the scenario set must match exactly, every
declared repetition sample and raw log must exist, every child must have exited
zero without a timeout, every expected metric line must appear, every workload
self-check must report ``ok`` and every value must be finite and positive.  It
never fills in, interpolates or zero-pads a missing measurement.
"""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

# Scenario table.  The order is the execution order of scripts/stages/test.sh;
# a scenario directory that is missing or unexpected aborts the parse.
SCENARIO_GROUP = {
    "pcretest_timing_literal": "pcretest_upstream",
    "pcretest_timing_backtrack": "pcretest_upstream",
    "pcretest_timing_utf8": "pcretest_upstream",
    "pcretest_dfa": "pcretest_upstream",
    "upstream_runtest": "runtest_upstream",
    "pcre_exec_literal": "pcre_exec_matrix",
    "pcre_exec_backtrack": "pcre_exec_matrix",
    "pcre_exec_utf8": "pcre_exec_matrix",
    "pcre_exec_dfa": "pcre_exec_matrix",
    "pcre_exec_jit": "pcre_exec_matrix",
    "pcre_compile": "pcre_exec_matrix",
    "pcregrep_scan": "pcregrep_tool",
}
SCENARIOS = list(SCENARIO_GROUP)

# Fixed shape of the pcretest input files: (pattern blocks, data lines).
PCRETEST_SHAPE = {
    "pcretest_timing_literal": (6, 13),
    "pcretest_timing_backtrack": (3, 3),
    "pcretest_timing_utf8": (4, 4),
    "pcretest_dfa": (3, 5),
}
# Scenarios that measure the compile loop as well as the match loop (-t without
# -TM).  The DFA scenario uses -TM, which times matches only.
PCRETEST_COMPILE_SCENARIOS = {
    "pcretest_timing_literal",
    "pcretest_timing_backtrack",
    "pcretest_timing_utf8",
}

BENCH_METRICS = {
    "pcre_exec_literal": (("match_ns_per_op", "ns/op", "lower_is_better"),
                          ("ops_per_second", "ops/s", "higher_is_better")),
    "pcre_exec_backtrack": (("match_ns_per_op", "ns/op", "lower_is_better"),
                            ("ops_per_second", "ops/s", "higher_is_better")),
    "pcre_exec_utf8": (("match_ns_per_op", "ns/op", "lower_is_better"),
                       ("ops_per_second", "ops/s", "higher_is_better")),
    "pcre_exec_jit": (("match_ns_per_op", "ns/op", "lower_is_better"),
                      ("ops_per_second", "ops/s", "higher_is_better")),
    "pcre_exec_dfa": (("dfa_ns_per_op", "ns/op", "lower_is_better"),
                      ("ops_per_second", "ops/s", "higher_is_better")),
    "pcre_compile": (("compile_ns_per_op", "ns/op", "lower_is_better"),
                     ("compiles_per_second", "ops/s", "higher_is_better")),
}

METRIC_LINE = re.compile(r"^PERF-METRIC name=(\S+) value=(\S+) unit=(\S+) direction=(\S+)$")
CHECK_LINE = re.compile(r"^PERF-CHECK name=(\S+) expected=(\S+) actual=(\S+) status=(\S+)$")
RESULT_LINE = re.compile(r"^PERF-RESULT status=(\S+)$")
EXECUTE_TIME = re.compile(r"^Execute time ([0-9.]+) milliseconds$")
COMPILE_TIME = re.compile(r"^Compile time ([0-9.]+) milliseconds$")
SCAN_SUMMARY = re.compile(
    r"^SCAN corpus_bytes=(\d+) patterns=(\d+) matched_lines=(\d+)$"
)
RUNTEST_OK = re.compile(r"^\s+OK")
RUNTEST_FAILURE = re.compile(r"(?i)(\bfailed\b|\*\*|segmentation|assertion)")


class ParseError(RuntimeError):
    """Raised when the recorded evidence does not satisfy the case contract."""


def env_int(name: str) -> int:
    raw = os.environ.get(name)
    if raw is None or raw == "":
        raise ParseError(f"missing environment variable: {name}")
    try:
        return int(raw)
    except ValueError as exc:
        raise ParseError(f"environment variable {name} must be an integer: {raw}") from exc


def read_log(path: Path) -> str:
    if not path.is_file() or path.stat().st_size == 0:
        raise ParseError(f"missing or empty raw log: {path}")
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise ParseError(f"cannot read raw log {path}: {exc}") from exc


def metric_value(lines: list[str], name: str, source: str) -> float:
    matches = [line for line in lines if line.startswith(f"PERF-METRIC name={name} ")]
    if len(matches) != 1:
        raise ParseError(
            f"{source}: expected exactly one PERF-METRIC line for {name}, found {len(matches)}"
        )
    match = METRIC_LINE.match(matches[0])
    if match is None:
        raise ParseError(f"{source}: malformed metric line: {matches[0]}")
    try:
        value = float(match.group(2))
    except ValueError as exc:
        raise ParseError(f"{source}: metric {name} is not numeric") from exc
    if not math.isfinite(value) or value <= 0:
        raise ParseError(f"{source}: metric {name} must be finite and positive, got {value}")
    return value


def validate_checks(lines: list[str], source: str, required: tuple[str, ...]) -> None:
    seen: dict[str, str] = {}
    for line in lines:
        match = CHECK_LINE.match(line)
        if match is None:
            continue
        name, expected, actual, status = match.groups()
        if name in seen:
            raise ParseError(f"{source}: duplicate PERF-CHECK for {name}")
        if status != "ok":
            raise ParseError(
                f"{source}: workload self-check {name} failed (expected {expected}, got {actual})"
            )
        seen[name] = status
    missing = [name for name in required if name not in seen]
    if missing:
        raise ParseError(f"{source}: missing workload self-check(s): {', '.join(missing)}")
    result = [line for line in lines if RESULT_LINE.match(line)]
    if len(result) != 1 or RESULT_LINE.match(result[0]).group(1) != "ok":  # type: ignore[union-attr]
        raise ParseError(f"{source}: missing successful PERF-RESULT line")


FORBIDDEN_TOKEN = re.compile(r"\b(?:nan|[+-]?inf)\b", re.IGNORECASE)


def forbidden_text(log: str, source: str) -> None:
    for token in ("** Unknown modifier", "** Failed", "Segmentation fault"):
        if token in log:
            raise ParseError(f"{source}: raw log contains forbidden marker: {token}")
    if FORBIDDEN_TOKEN.search(log):
        raise ParseError(f"{source}: raw log contains a NaN/non-finite value")


def extract_pcretest(
    scenario: str,
    log: str,
    wall_seconds: float,
    iterations: int,
) -> list[tuple[str, float, str, str]]:
    source = scenario
    forbidden_text(log, source)
    expected_patterns, expected_data_lines = PCRETEST_SHAPE[scenario]
    lines = log.splitlines()
    execute_times = []
    compile_times = []
    for line in lines:
        match = EXECUTE_TIME.match(line)
        if match is not None:
            execute_times.append(float(match.group(1)))
            continue
        match = COMPILE_TIME.match(line)
        if match is not None:
            compile_times.append(float(match.group(1)))
    if len(execute_times) != expected_data_lines:
        raise ParseError(
            f"{source}: expected {expected_data_lines} executed data lines, found {len(execute_times)}"
        )
    if scenario in PCRETEST_COMPILE_SCENARIOS:
        if len(compile_times) != expected_patterns:
            raise ParseError(
                f"{source}: expected {expected_patterns} compiled patterns, found {len(compile_times)}"
            )
    if scenario == "pcretest_dfa":
        # -TM (timing-only mode) prints the upstream totals block at the end.
        if "Total execute time" not in log:
            raise ParseError(f"{source}: upstream timing total is missing")
    metrics: list[tuple[str, float, str, str]] = []
    matches_per_second = iterations * len(execute_times) / wall_seconds
    metrics.append(("matches_per_second", matches_per_second, "matches/s", "higher_is_better"))
    if scenario in PCRETEST_COMPILE_SCENARIOS:
        compiles_per_second = iterations * len(compile_times) / wall_seconds
        metrics.append(
            ("compiles_per_second", compiles_per_second, "compiles/s", "higher_is_better")
        )
    return metrics


def extract_runtest(
    scenario: str, log: str, wall_seconds: float, iterations: int
) -> list[tuple[str, float, str, str]]:
    del wall_seconds, iterations
    source = scenario
    lines = log.splitlines()
    ok_lines = [line for line in lines if RUNTEST_OK.match(line)]
    failures = [
        line
        for line in lines
        if RUNTEST_FAILURE.search(line) and not line.strip().startswith("OK")
    ]
    if failures:
        raise ParseError(
            f"{source}: upstream RunTest reported failures: {failures[0].strip()[:160]}"
        )
    if not ok_lines:
        raise ParseError(f"{source}: upstream RunTest produced no OK lines")
    minimum = env_int("PCRE_RUNTEST_MIN_OK")
    if len(ok_lines) < minimum:
        raise ParseError(
            f"{source}: only {len(ok_lines)} passing assertions, expected at least {minimum}"
        )
    return [("tests_ok", float(len(ok_lines)), "tests", "higher_is_better")]


def extract_bench(
    scenario: str, log: str, wall_seconds: float, iterations: int
) -> list[tuple[str, float, str, str]]:
    del wall_seconds
    source = scenario
    forbidden_text(log, source)
    lines = log.splitlines()
    required_checks = {
        "pcre_exec_literal": ("verified_matches", "exec_completed", "exec_iterations"),
        "pcre_exec_backtrack": ("verified_matches", "exec_completed", "exec_iterations"),
        "pcre_exec_utf8": ("verified_matches", "exec_completed", "exec_iterations"),
        "pcre_exec_jit": ("jit_available", "jit_executable", "jit_matched_calls"),
        "pcre_exec_dfa": ("dfa_verified_matches", "dfa_matched_calls"),
        "pcre_compile": ("compiled_patterns",),
    }[scenario]
    validate_checks(lines, source, required_checks)
    completed_marker = next(
        (line for line in lines if line.startswith("PERF-CHECK name=exec_completed ")), None
    )
    if completed_marker is not None:
        match = CHECK_LINE.match(completed_marker)
        if match is None or match.group(3) != str(iterations):
            raise ParseError(f"{source}: harness did not complete the fixed iteration count")
    metrics: list[tuple[str, float, str, str]] = []
    for name, unit, direction in BENCH_METRICS[scenario]:
        metrics.append((name, metric_value(lines, name, source), unit, direction))
    return metrics


def extract_pcregrep(
    scenario: str, log: str, wall_seconds: float, iterations: int
) -> list[tuple[str, float, str, str]]:
    del iterations
    source = scenario
    forbidden_text(log, source)
    lines = log.splitlines()
    validate_checks(lines, source, ("scan_matched_lines", "scan_patterns"))
    summaries = [SCAN_SUMMARY.match(line) for line in lines]
    summary = next((match for match in summaries if match is not None), None)
    if summary is None:
        raise ParseError(f"{source}: scan summary line is missing")
    corpus_bytes, patterns, matched_lines = (int(value) for value in summary.groups())
    pinned_bytes = env_int("PCRE_SCAN_CORPUS_BYTES")
    pinned_patterns = env_int("PCRE_SCAN_PATTERNS")
    pinned_matches = env_int("PCRE_SCAN_MATCHES_TOTAL")
    if corpus_bytes != pinned_bytes:
        raise ParseError(f"{source}: corpus size {corpus_bytes} != pinned {pinned_bytes}")
    if patterns != pinned_patterns:
        raise ParseError(f"{source}: pattern count {patterns} != pinned {pinned_patterns}")
    if matched_lines != pinned_matches:
        raise ParseError(f"{source}: matched lines {matched_lines} != pinned {pinned_matches}")
    scanned_mib = corpus_bytes * patterns / (1024.0 * 1024.0)
    return [
        ("matched_lines", float(matched_lines), "lines", "higher_is_better"),
        ("scan_mib_per_second", scanned_mib / wall_seconds, "MiB/s", "higher_is_better"),
    ]


EXTRACTORS: dict[str, Callable[[str, str, float, int], list[tuple[str, float, str, str]]]] = {}
for _name in PCRETEST_SHAPE:
    EXTRACTORS[_name] = extract_pcretest
EXTRACTORS["upstream_runtest"] = extract_runtest
for _name in BENCH_METRICS:
    EXTRACTORS[_name] = extract_bench
EXTRACTORS["pcregrep_scan"] = extract_pcregrep


def iteration_variable(scenario: str) -> str:
    return {
        "pcretest_timing_literal": "PCRE_PCRETEST_LITERAL_ITERS",
        "pcretest_timing_backtrack": "PCRE_PCRETEST_BACKTRACK_ITERS",
        "pcretest_timing_utf8": "PCRE_PCRETEST_UTF8_ITERS",
        "pcretest_dfa": "PCRE_PCRETEST_DFA_ITERS",
        "upstream_runtest": "PCRE_RUNTEST_ITERATIONS",
        "pcre_exec_literal": "PCRE_BENCH_LITERAL_ITERS",
        "pcre_exec_backtrack": "PCRE_BENCH_BACKTRACK_ITERS",
        "pcre_exec_utf8": "PCRE_BENCH_UTF8_ITERS",
        "pcre_exec_dfa": "PCRE_BENCH_DFA_ITERS",
        "pcre_exec_jit": "PCRE_BENCH_JIT_ITERS",
        "pcre_compile": "PCRE_BENCH_COMPILE_ITERS",
        "pcregrep_scan": "PCRE_SCAN_PATTERNS",
    }[scenario]


def load_sample(
    scenario_dir: Path, scenario: str, index: int
) -> dict[str, Any]:
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
    log_path = scenario_dir / f"rep{index}.log"
    read_log(log_path)
    return {
        "wall_seconds": float(wall),
        "max_rss_mib": float(rss),
        "log_path": log_path,
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
        reps = env_int("PCRE_REPS")
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
        wall_values: dict[str, list[float]] = {}
        rss_values: dict[str, list[float]] = {}
        workload_samples: dict[str, dict[str, list[float]]] = {}

        for scenario in SCENARIOS:
            scenario_dir = runs_dir / scenario
            iterations = env_int(iteration_variable(scenario))
            extractor = EXTRACTORS[scenario]
            wall_samples: list[float] = []
            rss_samples: list[float] = []
            samples: dict[str, list[float]] = {}
            descriptor: dict[str, tuple[str, str]] = {}
            for index in range(1, reps + 1):
                sample = load_sample(scenario_dir, scenario, index)
                log = read_log(sample["log_path"])
                wall = sample["wall_seconds"]
                wall_samples.append(wall)
                rss_samples.append(sample["max_rss_mib"])
                extracted = extractor(scenario, log, wall, iterations)
                names_this_rep = set()
                for name, value, unit, direction in extracted:
                    if name in names_this_rep:
                        raise ParseError(
                            f"{scenario} repetition {index}: duplicate metric {name}"
                        )
                    names_this_rep.add(name)
                    if not math.isfinite(value) or value <= 0:
                        raise ParseError(
                            f"{scenario} repetition {index}: metric {name} must be finite "
                            f"and positive, got {value}"
                        )
                    samples.setdefault(name, []).append(float(value))
                    previous = descriptor.setdefault(name, (unit, direction))
                    if previous != (unit, direction):
                        raise ParseError(
                            f"{scenario}: metric {name} changed unit/direction between repetitions"
                        )
                if index == 1:
                    expected_metrics = names_this_rep
                elif names_this_rep != expected_metrics:
                    raise ParseError(
                        f"{scenario} repetition {index}: metric set differs from the first "
                        f"repetition (missing={sorted(expected_metrics - names_this_rep)}, "
                        f"unexpected={sorted(names_this_rep - expected_metrics)})"
                    )
            wall_values[scenario] = wall_samples
            rss_values[scenario] = rss_samples
            workload_samples[scenario] = samples
            for name in sorted(expected_metrics):
                if len(samples[name]) != reps:
                    raise ParseError(
                        f"{scenario}: metric {name} has {len(samples[name])} samples, "
                        f"expected {reps}"
                    )
                unit, direction = descriptor[name]
                stats = summarize(samples[name])
                metric_name = f"{scenario}_{name}"
                results[metric_name] = build_metric(
                    metric_name, scenario, stats["median"], unit, direction,
                    stats, samples[name],
                )

        for scenario in SCENARIOS:
            wall_stats = summarize(wall_values[scenario])
            results[f"{scenario}_wall_s"] = build_metric(
                f"{scenario}_wall_s", scenario, wall_stats["median"], "s",
                "lower_is_better", wall_stats, wall_values[scenario],
            )
            rss_stats = summarize(rss_values[scenario])
            results[f"{scenario}_rss_mib"] = build_metric(
                f"{scenario}_rss_mib", scenario, rss_stats["median"], "MiB",
                "lower_is_better", rss_stats, rss_values[scenario],
            )

        parameters: dict[str, Any] = {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "pcre_version": version,
            "pcre_configure_options": os.environ.get("PCRE_CONFIGURE_OPTIONS_TEXT", ""),
            "cflags": os.environ.get("PCRE_CFLAGS", ""),
            "build_parallel_jobs": env_int("PCRE_BUILD_JOBS"),
            "source_archive": os.environ.get("PCRE_SOURCE_NAME", ""),
            "source_sha256": os.environ.get("PCRE_SOURCE_SHA256", ""),
            "pcretest_patterns": {
                scenario: PCRETEST_SHAPE[scenario][0] for scenario in PCRETEST_SHAPE
            },
            "pcretest_data_lines": {
                scenario: PCRETEST_SHAPE[scenario][1] for scenario in PCRETEST_SHAPE
            },
            "pcretest_iterations": {
                scenario: env_int(iteration_variable(scenario))
                for scenario in PCRETEST_SHAPE
            },
            "benchmark_iterations": {
                scenario: env_int(iteration_variable(scenario))
                for scenario in BENCH_METRICS
            },
            "benchmark_modes": sorted(BENCH_METRICS),
            "run_tests": os.environ.get("PCRE_RUNTEST_TESTS_TEXT", ""),
            "scan_patterns": env_int("PCRE_SCAN_PATTERNS"),
            "scan_corpus_bytes": env_int("PCRE_SCAN_CORPUS_BYTES"),
            "scan_expected_matched_lines": env_int("PCRE_SCAN_MATCHES_TOTAL"),
            "fixture_sha256": {
                "pcretest_literal.txt": os.environ.get("PCRE_FIXTURE_LITERAL_SHA256", ""),
                "pcretest_backtrack.txt": os.environ.get("PCRE_FIXTURE_BACKTRACK_SHA256", ""),
                "pcretest_utf8.txt": os.environ.get("PCRE_FIXTURE_UTF8_SHA256", ""),
                "pcretest_dfa.txt": os.environ.get("PCRE_FIXTURE_DFA_SHA256", ""),
                "scan_patterns.txt": os.environ.get("PCRE_FIXTURE_SCAN_PATTERNS_SHA256", ""),
                "scan_corpus.txt": os.environ.get("PCRE_FIXTURE_SCAN_CORPUS_SHA256", ""),
            },
        }
        runtime_context: dict[str, Any] = {
            "c_compiler": os.environ.get("PCRE_C_COMPILER", "unknown"),
            "measurement_network_mode": os.environ.get("PCRE_NETWORK_MODE", "unknown"),
            "pcretest_build_features": os.environ.get("PCRE_PCRETEST_FEATURES", ""),
            "actual_version_string": os.environ.get("PCRE_ACTUAL_VERSION_STRING", ""),
        }
    except (ParseError, KeyError) as exc:
        print(f"[pcre-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    normalized = {
        "benchmark": "pcre_match_compile_matrix",
        "software": "pcre",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "runtime_context": runtime_context,
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "per_call_cost": {"unit": "ns/op", "direction": "lower_is_better"},
            "throughput": {"unit": "ops/s", "direction": "higher_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[pcre-parse] normalized {len(results)} metrics across {len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
