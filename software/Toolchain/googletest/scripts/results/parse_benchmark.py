#!/usr/bin/env python3
"""Normalize the raw GoogleTest evidence into ``results.json``.

The script is intentionally strict: every scenario must have exactly
``--repetitions`` measured repetitions plus one warm-up, each with a timing JSON
and a captured log, every log must carry the fixed correctness markers of its
scenario, and every value must be finite and strictly positive.  A missing
sample is a hard failure (the caller turns it into test-stage exit code 50); no
value is invented, estimated or zero-padded.

Two families of evidence are handled:

* the upstream GoogleTest suite (``gtest_unittest`` built from the pinned
  release archive), whose deterministic summary 1.18.0 reports 434 tests from
  104 test suites; and
* the case-owned assertion matrices (``scripts/bench/matrix.cc``), which report
  their expected workload in a fixed ``[gt-matrix]`` line plus the GoogleTest
  ``[  PASSED  ]`` summary.
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

WALL_UNIT = "s"
RSS_UNIT = "MiB"
TPS_UNIT = "tests/s"
APS_UNIT = "assertions/s"
US_UNIT = "us/test"
NS_UNIT = "ns/assertion"

LOWER = "lower_is_better"
HIGHER = "higher_is_better"

UPSTREAM_SCENARIO = "upstream_gtest_unittest"
LOOP_SCENARIO = "assertion_loop_5m"

MATRIX_SCENARIOS = ("matrix_1k", "matrix_10k")

SUMMARY_RE = re.compile(r"\[==========\] (\d+) tests? from (\d+) test suites? ran\.")
PASSED_RE = re.compile(r"\[  PASSED  \] (\d+) tests?\.")
WORKLOAD_RE = re.compile(
    r"\[gt-matrix\] mode=(\w+) registered_tests=(\d+) assertions=(\d+) rc=(\d+)"
)


class EvidenceError(RuntimeError):
    """Raised when a raw evidence file is missing or inconsistent."""


def read_json(path: Path) -> dict:
    if not path.is_file():
        raise EvidenceError(f"missing timing JSON: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise EvidenceError(f"invalid JSON in {path}: {exc}") from exc


def read_log(path: Path) -> str:
    if not path.is_file():
        raise EvidenceError(f"missing captured log: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def load_repetitions(runs_dir: Path, scenario: str, repetitions: int) -> tuple[list[dict], list[str]]:
    scenario_dir = runs_dir / scenario
    warmup_log = scenario_dir / "warmup.log"
    if not warmup_log.is_file():
        raise EvidenceError(f"{scenario}: missing warm-up log {warmup_log}")
    warmup_timing = read_json(scenario_dir / "warmup.json")
    if warmup_timing.get("exit_code") != 0:
        raise EvidenceError(f"{scenario}: warm-up exited with {warmup_timing.get('exit_code')}")
    logs: list[str] = [warmup_log.read_text(encoding="utf-8", errors="replace")]
    samples: list[dict] = []
    for index in range(1, repetitions + 1):
        timing = read_json(scenario_dir / f"rep{index}.json")
        log_text = read_log(scenario_dir / f"rep{index}.log")
        logs.append(log_text)
        if timing.get("exit_code") != 0:
            raise EvidenceError(f"{scenario}: rep{index} exited with {timing.get('exit_code')}")
        wall = timing.get("wall_seconds")
        rss = timing.get("max_rss_mib")
        if not isinstance(wall, (int, float)) or wall <= 0:
            raise EvidenceError(f"{scenario}: rep{index} has an invalid wall time: {wall!r}")
        if not isinstance(rss, (int, float)) or rss <= 0:
            raise EvidenceError(f"{scenario}: rep{index} has an invalid peak RSS: {rss!r}")
        samples.append(
            {
                "wall_seconds": float(wall),
                "max_rss_mib": float(rss),
                "log": log_text,
            }
        )
    return samples, logs


def median(values: list[float]) -> float:
    return float(statistics.median(values))


def metric(scenario: str, task: str, name: str, value: float, unit: str, direction: str, samples: list[float]) -> dict:
    return {
        "scenario": scenario,
        "task": task,
        "source_name": name,
        "value": value,
        "unit": unit,
        "direction": direction,
        "samples": samples,
    }


def parse_upstream(log_text: str) -> tuple[int, int]:
    summary = SUMMARY_RE.search(log_text)
    if summary is None:
        raise EvidenceError("upstream suite log has no '[==========] ... ran.' summary")
    passed = PASSED_RE.search(log_text)
    if passed is None:
        raise EvidenceError("upstream suite log has no '[  PASSED  ]' line")
    ran = int(summary.group(1))
    suites = int(summary.group(2))
    if ran != int(passed.group(1)):
        raise EvidenceError(
            f"upstream suite ran {ran} tests but reported {passed.group(1)} passed"
        )
    return ran, suites


def parse_matrix(log_text: str) -> tuple[str, int, int]:
    workload = WORKLOAD_RE.search(log_text)
    if workload is None:
        raise EvidenceError("matrix log has no '[gt-matrix]' workload line")
    mode = workload.group(1)
    tests = int(workload.group(2))
    assertions = int(workload.group(3))
    rc = int(workload.group(4))
    if rc != 0:
        raise EvidenceError(f"matrix workload line reports rc={rc}")
    summary = SUMMARY_RE.search(log_text)
    if summary is None:
        raise EvidenceError("matrix log has no '[==========] ... ran.' summary")
    passed = PASSED_RE.search(log_text)
    if passed is None:
        raise EvidenceError("matrix log has no '[  PASSED  ]' line")
    expected_passed = tests if tests > 0 else 1
    if int(passed.group(1)) != expected_passed:
        raise EvidenceError(
            f"matrix reported {passed.group(1)} passed tests, expected {expected_passed}"
        )
    return mode, tests, assertions


def normalize(
    scenario: str,
    repetitions: int,
    runs_dir: Path,
    matrix_1k: int,
    matrix_10k: int,
    assertion_loop: int,
    upstream_tests: int,
    upstream_suites: int,
) -> tuple[dict, list[str]]:
    samples, logs = load_repetitions(runs_dir, scenario, repetitions)
    metrics: dict[str, dict] = {}
    walls = [s["wall_seconds"] for s in samples]
    rss = [s["max_rss_mib"] for s in samples]

    if scenario == UPSTREAM_SCENARIO:
        task = "upstream_suite"
        for index, sample in enumerate(samples, start=1):
            ran, suites = parse_upstream(sample["log"])
            if ran != upstream_tests or suites != upstream_suites:
                raise EvidenceError(
                    f"{scenario}: rep{index} ran {ran} tests from {suites} suites, "
                    f"expected {upstream_tests}/{upstream_suites}"
                )
        tps = [upstream_tests / wall for wall in walls]
        us_per_test = [wall * 1_000_000.0 / upstream_tests for wall in walls]
        metrics[scenario] = metric(scenario, task, scenario, median(walls), WALL_UNIT, LOWER, walls)
        metrics[f"{scenario}_rss"] = metric(scenario, task, f"{scenario}_rss", median(rss), RSS_UNIT, LOWER, rss)
        metrics[f"{scenario}_tps"] = metric(scenario, task, f"{scenario}_tps", median(tps), TPS_UNIT, HIGHER, tps)
        metrics[f"{scenario}_us_per_test"] = metric(
            scenario, task, f"{scenario}_us_per_test", median(us_per_test), US_UNIT, LOWER, us_per_test
        )
        return metrics, logs

    task = "assertion_matrix"
    if scenario == LOOP_SCENARIO:
        expected_mode, expected_tests, expected_assertions = "loop", 0, assertion_loop
    elif scenario == "matrix_1k":
        expected_mode, expected_tests, expected_assertions = "registered", matrix_1k, 0
    elif scenario == "matrix_10k":
        expected_mode, expected_tests, expected_assertions = "registered", matrix_10k, 0
    else:
        raise EvidenceError(f"unknown scenario in runs directory: {scenario}")

    for index, sample in enumerate(samples, start=1):
        mode, tests, assertions = parse_matrix(sample["log"])
        if mode != expected_mode or tests != expected_tests or assertions != expected_assertions:
            raise EvidenceError(
                f"{scenario}: rep{index} reported mode={mode} tests={tests} "
                f"assertions={assertions}, expected {expected_mode}/{expected_tests}/{expected_assertions}"
            )

    metrics[scenario] = metric(scenario, task, scenario, median(walls), WALL_UNIT, LOWER, walls)
    metrics[f"{scenario}_rss"] = metric(scenario, task, f"{scenario}_rss", median(rss), RSS_UNIT, LOWER, rss)
    if scenario == LOOP_SCENARIO:
        aps = [assertion_loop / wall for wall in walls]
        ns_per_assertion = [wall * 1_000_000_000.0 / assertion_loop for wall in walls]
        metrics[f"{scenario}_aps"] = metric(scenario, task, f"{scenario}_aps", median(aps), APS_UNIT, HIGHER, aps)
        metrics[f"{scenario}_ns_per_assert"] = metric(
            scenario, task, f"{scenario}_ns_per_assert", median(ns_per_assertion), NS_UNIT, LOWER, ns_per_assertion
        )
    else:
        tps = [expected_tests / wall for wall in walls]
        us_per_test = [wall * 1_000_000.0 / expected_tests for wall in walls]
        metrics[f"{scenario}_tps"] = metric(scenario, task, f"{scenario}_tps", median(tps), TPS_UNIT, HIGHER, tps)
        metrics[f"{scenario}_us_per_test"] = metric(
            scenario, task, f"{scenario}_us_per_test", median(us_per_test), US_UNIT, LOWER, us_per_test
        )
    return metrics, logs


def build_payload(
    runs_dir: Path,
    repetitions: int,
    actual_version: str,
    matrix_1k: int,
    matrix_10k: int,
    assertion_loop: int,
    upstream_tests: int,
    upstream_suites: int,
) -> tuple[dict, list[str]]:
    expected = sorted([UPSTREAM_SCENARIO, *MATRIX_SCENARIOS, LOOP_SCENARIO])
    present = sorted(p.name for p in runs_dir.iterdir() if p.is_dir()) if runs_dir.is_dir() else []
    missing = [name for name in expected if name not in present]
    if missing:
        raise EvidenceError(f"scenario directories missing from {runs_dir}: {missing}")
    unexpected = [name for name in present if name not in expected]
    if unexpected:
        raise EvidenceError(f"unexpected scenario directories in {runs_dir}: {unexpected}")

    results: dict[str, dict] = {}
    logs: list[str] = []
    scenarios: dict[str, dict] = {}
    for scenario in expected:
        metrics, scenario_logs = normalize(
            scenario,
            repetitions,
            runs_dir,
            matrix_1k,
            matrix_10k,
            assertion_loop,
            upstream_tests,
            upstream_suites,
        )
        results.update(metrics)
        logs.extend(scenario_logs)
        if scenario == UPSTREAM_SCENARIO:
            scenarios[scenario] = {
                "task": "upstream_suite",
                "tests": upstream_tests,
                "test_suites": upstream_suites,
                "repetitions": repetitions,
            }
        elif scenario == LOOP_SCENARIO:
            scenarios[scenario] = {
                "task": "assertion_matrix",
                "mode": "loop",
                "registered_tests": 0,
                "assertions": assertion_loop,
                "repetitions": repetitions,
            }
        else:
            scenarios[scenario] = {
                "task": "assertion_matrix",
                "mode": "registered",
                "registered_tests": matrix_1k if scenario == "matrix_1k" else matrix_10k,
                "assertions": 0,
                "repetitions": repetitions,
            }

    payload = {
        "software": "googletest",
        "version": actual_version,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "repetitions": repetitions,
            "warmups": 1,
            "offline": False,
            "upstream_tests": upstream_tests,
            "upstream_test_suites": upstream_suites,
            "scenarios": scenarios,
        },
        "results": results,
    }
    return payload, logs


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--raw-output", required=True, type=Path)
    parser.add_argument("--actual-version-file", required=True, type=Path)
    parser.add_argument("--repetitions", required=True, type=int)
    parser.add_argument("--matrix-1k", required=True, type=int)
    parser.add_argument("--matrix-10k", required=True, type=int)
    parser.add_argument("--assertion-loop", required=True, type=int)
    parser.add_argument("--upstream-tests", required=True, type=int)
    parser.add_argument("--upstream-suites", required=True, type=int)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        if not args.actual_version_file.is_file():
            raise EvidenceError(f"missing actual-version file: {args.actual_version_file}")
        actual_version = args.actual_version_file.read_text(encoding="utf-8").strip()
        if not actual_version:
            raise EvidenceError("actual-version file is empty")
        payload, logs = build_payload(
            args.runs_dir,
            args.repetitions,
            actual_version,
            args.matrix_1k,
            args.matrix_10k,
            args.assertion_loop,
            args.upstream_tests,
            args.upstream_suites,
        )
    except EvidenceError as exc:
        print(f"[googletest-parse] ERROR: {exc}", file=sys.stderr, flush=True)
        return 50

    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(args.output)

    args.raw_output.parent.mkdir(parents=True, exist_ok=True)
    args.raw_output.write_text("\n".join(logs) + "\n", encoding="utf-8")

    print(
        f"[googletest-parse] normalized {len(payload['results'])} metrics across "
        f"{len(payload['parameters']['scenarios'])} scenarios",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
