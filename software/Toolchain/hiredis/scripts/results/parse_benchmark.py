#!/usr/bin/env python3
"""Normalize the hiredis 1.5.0 parser/formatting matrix from the recorded samples.

Every scenario measures exactly one harness child process and contributes:

* the wall-clock median of that process in seconds (lower is better),
* the median peak resident set size of that process in MiB (lower is better),
* one or two workload metrics derived from the pinned fixture/iteration counts
  and the wall clock: parsed MiB/s and replies/s for the RESP reader modes,
  formatted commands/s for the command-formatting modes, and the number of
  upstream assertions passed for the server-free upstream test suite.

Each repetition's harness output is verified by ``scripts/verify_outputs.py``
immediately after the measured window; its compact report is stored as
``runs/<scenario>/rep<i>.check``.  The parser cross-checks every check line
against the pinned constants exported by ``scripts/common.sh``, so a truncated
replay or a changed workload cannot be reported as a valid measurement.

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
from typing import Any

MIB = 1024.0 * 1024.0

SCENARIO_GROUP = {
    "reader_pipeline": "resp_reader",
    "reader_bulk": "resp_reader",
    "reader_nested": "resp_reader",
    "reader_mixed": "resp_reader",
    "reader_fragmented": "resp_reader",
    "format_command": "command_format",
    "format_argv": "command_format",
    "upstream_local_suite": "upstream_suite",
}
SCENARIOS = list(SCENARIO_GROUP)

READER_SCENARIOS = {
    name for name in SCENARIOS if name.startswith("reader_")
}
FORMAT_SCENARIOS = {
    name for name in SCENARIOS if name.startswith("format_")
}


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
    declared_expected, actual = checks[name]
    if declared_expected != expected:
        raise ParseError(
            f"{scenario} rep{repetition}: check {name} declares expected={declared_expected}, "
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


def fixture_key(scenario: str) -> str:
    name = scenario[len("reader_"):]
    return "pipeline" if name == "fragmented" else name


def fixture_pins(scenario: str) -> tuple[int, int, int]:
    name = scenario[len("reader_"):].upper()
    key = fixture_key(scenario).upper()
    return (
        env_int(f"HIREDIS_FIXTURE_{key}_BYTES"),
        env_int(f"HIREDIS_FIXTURE_{key}_REPLIES"),
        env_int("HIREDIS_LOOPS_" + name),
    )


def iterations_pin(scenario: str) -> int:
    return env_int("HIREDIS_ITERATIONS_FORMAT_" + scenario[len("format_"):].upper())


def workload_checks(
    scenario: str, checks: dict[str, tuple[str, str]], repetition: int
) -> list[tuple[str, float, str, str]]:
    """Validate the scenario checks (returns no extra metrics beyond throughput)."""
    if scenario in READER_SCENARIOS:
        fixture_bytes, fixture_replies, loops = fixture_pins(scenario)
        require_check(checks, scenario, repetition, "harness_mode",
                      scenario[len("reader_"):])
        require_check(checks, scenario, repetition, "fixture_bytes", str(fixture_bytes))
        require_check(checks, scenario, repetition, "loops", str(loops))
        require_check(checks, scenario, repetition, "parsed_bytes",
                      str(fixture_bytes * loops))
        require_check(checks, scenario, repetition, "parsed_replies",
                      str(fixture_replies * loops))
        return []
    if scenario in FORMAT_SCENARIOS:
        iterations = iterations_pin(scenario)
        require_check(checks, scenario, repetition, "harness_mode",
                      "format_" + scenario[len("format_"):])
        require_check(checks, scenario, repetition, "iterations", str(iterations))
        require_positive_check(checks, scenario, repetition, "command_bytes")
        return []
    if scenario == "upstream_local_suite":
        passed = require_check(
            checks, scenario, repetition, "local_tests_passed",
            str(env_int("HIREDIS_EXPECT_LOCAL_TESTS")),
        )
        require_check(checks, scenario, repetition, "local_tests_failed", "0")
        require_check(checks, scenario, repetition, "local_tests_skipped", "0")
        return [("tests_passed", float(passed), "tests", "higher_is_better")]
    raise ParseError(f"unknown scenario: {scenario}")


def throughput_metric(
    scenario: str, wall_seconds: float
) -> tuple[str, float, str, str]:
    if scenario in READER_SCENARIOS:
        fixture_bytes, fixture_replies, loops = fixture_pins(scenario)
        return (
            "parse_mib_per_second",
            (float(fixture_bytes * loops) / MIB) / wall_seconds,
            "MiB/s",
            "higher_is_better",
        )
    if scenario in FORMAT_SCENARIOS:
        iterations = iterations_pin(scenario)
        return (
            "commands_per_second",
            float(iterations) / wall_seconds,
            "commands/s",
            "higher_is_better",
        )
    raise ParseError(f"scenario {scenario} has no wall-clock throughput metric")


def secondary_metric(scenario: str, wall_seconds: float) -> tuple[str, float, str, str] | None:
    if scenario in READER_SCENARIOS:
        fixture_bytes, fixture_replies, loops = fixture_pins(scenario)
        del fixture_bytes
        return (
            "replies_per_second",
            float(fixture_replies * loops) / wall_seconds,
            "replies/s",
            "higher_is_better",
        )
    return None


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
        reps = env_int("HIREDIS_REPS")
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
                if scenario != "upstream_local_suite":
                    name, value, unit, direction = throughput_metric(scenario, wall)
                    extracted.append((name, value, unit, direction))
                secondary = secondary_metric(scenario, wall)
                if secondary is not None:
                    extracted.append(secondary)

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
            "hiredis_version": version,
            "build_target": "static",
            "optimization": env("HIREDIS_OPTIMIZATION"),
            "harness_cflags": env("HIREDIS_HARNESS_CFLAGS"),
            "build_parallel_jobs": env_int("HIREDIS_BUILD_JOBS"),
            "source_archive": env("HIREDIS_SOURCE_NAME"),
            "source_sha256": env("HIREDIS_SOURCE_SHA256"),
            "upstream_expected_local_tests": env_int("HIREDIS_EXPECT_LOCAL_TESTS"),
            "reader_loops": {
                name[len("reader_"):]: env_int("HIREDIS_LOOPS_" + name[len("reader_"):].upper())
                for name in sorted(READER_SCENARIOS)
            },
            "format_iterations": {
                name[len("format_"):]: env_int("HIREDIS_ITERATIONS_FORMAT_" + name[len("format_"):].upper())
                for name in sorted(FORMAT_SCENARIOS)
            },
            "fixture_bytes": {
                name: env_int(f"HIREDIS_FIXTURE_{('pipeline' if name == 'fragmented' else name).upper()}_BYTES")
                for name in sorted(name[len("reader_"):] for name in READER_SCENARIOS)
            },
            "fixture_replies": {
                name: env_int(f"HIREDIS_FIXTURE_{('pipeline' if name == 'fragmented' else name).upper()}_REPLIES")
                for name in sorted(name[len("reader_"):] for name in READER_SCENARIOS)
            },
        }
        runtime_context: dict[str, Any] = {
            "c_compiler": env("HIREDIS_C_COMPILER") or "unknown",
            "measurement_network_mode": env("HIREDIS_NETWORK_MODE") or "unknown",
            "actual_version_string": env("HIREDIS_ACTUAL_VERSION_STRING"),
        }
    except (ParseError, KeyError) as exc:
        print(f"[hiredis-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    normalized = {
        "benchmark": "hiredis_resp_parser_matrix",
        "software": "hiredis",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "runtime_context": runtime_context,
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "throughput": {"unit": "MiB/s, replies/s or commands/s", "direction": "higher_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[hiredis-parse] normalized {len(results)} metrics across {len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
