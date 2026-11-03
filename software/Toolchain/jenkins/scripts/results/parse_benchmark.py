#!/usr/bin/env python3
"""Normalize the Jenkins 2.588 controller workload matrix.

Every scenario contributes two metrics: the wall-clock median of the measured
window (seconds, lower is better) and the median peak resident set size of the
controller JVM (MiB, lower is better).  Raw per-repetition logs and driver
JSON files stay in ``runs/<scenario>/`` as the primary evidence; this script
only aggregates them and fails loudly when a declared scenario is incomplete,
a repetition failed or timed out, a sample is missing or non-finite, the
scenario checks do not match the committed expectations, or the matrix
directory contains an unexpected scenario.
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
from typing import Any

RESULT_PATTERN = re.compile(
    r"RESULT\s+scenario=(\S+)\s+wall=([0-9.]+)\s+rss_kib=(\d+)\s+checks=(\{.*\})"
)
DEFAULT_MANIFEST = Path(__file__).resolve().parents[2] / "benchmarks" / "scenarios.psv"
SUPPORTED_ACTIONS = {"startup_cold", "startup_warm", "job_batch", "api_list", "api_scan"}
SUPPORTED_CHECKS = {"ready", "builds", "api_jobs"}


def fail(message: str) -> None:
    print(f"[jenkins-parse] ERROR: {message}", file=sys.stderr)


class MatrixError(RuntimeError):
    """A matrix, sample or workload validation failure."""


def load_manifest(path: Path) -> list[dict[str, Any]]:
    if not path.is_file():
        raise MatrixError(f"workload matrix manifest does not exist: {path}")
    rows: list[dict[str, Any]] = []
    seen: set[str] = set()
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.split("|")
        if len(fields) != 7:
            raise MatrixError(
                f"manifest line {lineno} must have 7 pipe-separated fields, got {len(fields)}"
            )
        scenario, dimension, action, scale, check, expected, workload = (
            field.strip() for field in fields
        )
        if not scenario or scenario in seen:
            raise MatrixError(f"manifest line {lineno} has an empty or duplicate scenario name")
        seen.add(scenario)
        if action not in SUPPORTED_ACTIONS:
            raise MatrixError(f"manifest line {lineno} has an unsupported action: {action}")
        if check not in SUPPORTED_CHECKS:
            raise MatrixError(f"manifest line {lineno} has an unsupported check: {check}")
        if not scale.isdigit():
            raise MatrixError(f"manifest line {lineno} needs a non-negative integer scale")
        if not expected.isdigit():
            raise MatrixError(f"manifest line {lineno} needs a non-negative integer expectation")
        expected_scale = {"ready": 0, "builds": int(scale), "api_jobs": int(scale)}[check]
        if check in {"builds", "api_jobs"} and int(expected) != expected_scale:
            raise MatrixError(
                f"manifest line {lineno} expects {expected} but scale is {scale} for check {check}"
            )
        if check == "ready" and int(expected) != 1:
            raise MatrixError(f"manifest line {lineno} must expect exactly one ready event")
        rows.append(
            {
                "scenario": scenario,
                "dimension": dimension,
                "action": action,
                "scale": int(scale),
                "check": check,
                "expected": int(expected),
                "workload": workload,
            }
        )
    if not rows:
        raise MatrixError(f"workload matrix manifest is empty: {path}")
    return rows


def validate_checks(payload: dict[str, Any], row: dict[str, Any], version: str) -> None:
    scenario = row["scenario"]
    checks = payload.get("checks")
    if not isinstance(checks, dict):
        raise MatrixError(f"scenario {scenario} sample has no checks object")
    if checks.get("jenkins_version") != version:
        raise MatrixError(
            f"scenario {scenario} reported X-Jenkins {checks.get('jenkins_version')!r}, "
            f"expected {version!r}"
        )
    if row["check"] == "ready":
        if checks.get("ready") is not True:
            raise MatrixError(f"scenario {scenario} did not report a ready controller")
        return
    if row["check"] == "builds":
        total = checks.get("builds_total")
        success = checks.get("builds_success")
        if total != row["expected"]:
            raise MatrixError(
                f"scenario {scenario} built {total!r} jobs, expected {row['expected']}"
            )
        if success != row["expected"]:
            raise MatrixError(
                f"scenario {scenario} only {success!r} builds succeeded, expected {row['expected']}"
            )
        if checks.get("builds_result") != "SUCCESS":
            raise MatrixError(f"scenario {scenario} is missing the SUCCESS build result marker")
        return
    jobs = checks.get("api_jobs")
    failures = checks.get("api_failures")
    requests = checks.get("api_requests")
    if jobs != row["expected"]:
        raise MatrixError(
            f"scenario {scenario} observed {jobs!r} jobs over the API, expected {row['expected']}"
        )
    if failures != 0:
        raise MatrixError(f"scenario {scenario} recorded {failures!r} API failures")
    if not isinstance(requests, int) or requests <= 0:
        raise MatrixError(f"scenario {scenario} recorded an invalid API request count")


def validate_log(text: str, payload: dict[str, Any], row: dict[str, Any]) -> None:
    scenario = row["scenario"]
    matches = RESULT_PATTERN.findall(text)
    if len(matches) != 1:
        raise MatrixError(
            f"scenario {scenario} log must contain exactly one RESULT line, found {len(matches)}"
        )
    result_scenario, wall_text, rss_text, checks_text = matches[0]
    if result_scenario != scenario:
        raise MatrixError(f"scenario {scenario} log reports RESULT scenario={result_scenario}")
    if abs(float(wall_text) - float(payload["wall_seconds"])) > 0.001:
        raise MatrixError(f"scenario {scenario} log wall time disagrees with the sample JSON")
    if int(rss_text) != int(payload["max_rss_kib"]):
        raise MatrixError(f"scenario {scenario} log RSS disagrees with the sample JSON")
    try:
        log_checks = json.loads(checks_text)
    except json.JSONDecodeError as exc:
        raise MatrixError(f"scenario {scenario} log has an unreadable checks object: {exc}") from exc
    if log_checks != payload.get("checks"):
        raise MatrixError(f"scenario {scenario} log checks disagree with the sample JSON")


def load_samples(scenario_dir: Path, reps: int, row: dict[str, Any], version: str) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not sample_path.is_file():
            raise MatrixError(f"missing repetition sample: {sample_path}")
        if not log_path.is_file():
            raise MatrixError(f"missing raw repetition log: {log_path}")
        try:
            payload = json.loads(sample_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise MatrixError(f"invalid repetition sample {sample_path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise MatrixError(f"repetition sample is not an object: {sample_path}")
        if payload.get("scenario") != row["scenario"] or payload.get("action") != row["action"]:
            raise MatrixError(f"repetition sample {sample_path} describes a different scenario")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise MatrixError(
                f"repetition {sample_path.name} for {scenario_dir.name} failed "
                f"with exit code {exit_code} (timed_out={payload.get('timed_out')})"
            )
        if payload.get("timed_out") is not False:
            raise MatrixError(
                f"repetition {sample_path.name} for {scenario_dir.name} was not a completed run"
            )
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise MatrixError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise MatrixError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or wall <= 0:
            raise MatrixError(f"repetition {sample_path.name} wall time must be a positive finite number")
        if not math.isfinite(float(rss)) or rss <= 0:
            raise MatrixError(f"repetition {sample_path.name} RSS must be a positive finite number")
        if log_path.stat().st_size == 0:
            raise MatrixError(f"raw repetition log is empty: {log_path}")
        validate_checks(payload, row, version)
        validate_log(log_path.read_text(encoding="utf-8", errors="replace"), payload, row)
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "checks": payload.get("checks"),
                "log": f"rep{index}.log",
            }
        )
    return samples


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
        "stdev": round(float(statistics.stdev(values)), 6) if len(values) > 1 else 0.0,
    }


def build_metric(
    source_name: str,
    row: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": source_name,
        "scenario": row["scenario"],
        "dimension": row["dimension"],
        "action": row["action"],
        "scale": row["scale"],
        "workload": row["workload"],
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print(
            "usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT [SCENARIOS_MANIFEST]",
            file=sys.stderr,
        )
        return 1
    runs_dir = Path(sys.argv[1])
    normalized_output = Path(sys.argv[2])
    manifest_path = Path(sys.argv[3]) if len(sys.argv) == 4 else DEFAULT_MANIFEST
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        reps = int(os.environ.get("JENKINS_REPS", os.environ.get("PERF_REPS", "5")))
        port = int(os.environ.get("JENKINS_PORT", "0"))
    except ValueError:
        fail("JENKINS_REPS and JENKINS_PORT must be integers")
        return 1
    if reps < 1:
        fail("JENKINS_REPS must be positive")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    try:
        rows = load_manifest(manifest_path)
        expected_scenarios = [row["scenario"] for row in rows]
        unexpected = sorted(
            entry.name
            for entry in runs_dir.iterdir()
            if entry.is_dir() and entry.name not in expected_scenarios
        )
        if unexpected:
            raise MatrixError(
                "runs directory contains scenarios that are not in the matrix: "
                + ", ".join(unexpected)
            )
        results: dict[str, Any] = {}
        scenarios_payload: list[dict[str, Any]] = []
        for row in rows:
            scenario = row["scenario"]
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise MatrixError(f"missing scenario directory: {scenario_dir}")
            samples = load_samples(scenario_dir, reps, row, version)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            results[scenario] = build_metric(
                scenario, row, wall_stats["median"], "s", "lower_is_better", wall_stats, wall_values
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                row,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                rss_values,
            )
            scenarios_payload.append(
                {
                    "scenario": scenario,
                    "dimension": row["dimension"],
                    "action": row["action"],
                    "scale": row["scale"],
                    "workload": row["workload"],
                    "checks": [sample["checks"] for sample in samples],
                }
            )
    except MatrixError as exc:
        fail(str(exc))
        return 1

    normalized: dict[str, Any] = {
        "benchmark": "jenkins_controller_workload_matrix",
        "software": "jenkins",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "build_variant": {"variant": variant},
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "controller_port": port,
            "controller_heap": "-Xms512m -Xmx512m",
            "controller_flags": [
                "-Djenkins.install.runSetupWizard=false",
                "-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true",
                "-Dhudson.model.UpdateCenter.updateCenterUrl=http://127.0.0.1:1/update-center.json",
                "-Djenkins.model.DownloadService.noSignatureCheck=true",
                "-Dhudson.model.UsageStatistics.disabled=true",
            ],
            "measurement_window": {
                "startup_cold": "process spawn to the first HTTP 200 from /api/json",
                "startup_warm": "process spawn to the first HTTP 200 from /api/json",
                "job_batch": "first build trigger to the last completed build result",
                "api_list": "twenty sequential /api/json job-list reads",
                "api_scan": "one /job/<name>/api/json read per pre-created job",
            },
            "matrix": expected_scenarios,
            "dimensions": sorted({row["dimension"] for row in rows}),
        },
        "inputs": {
            "war": f"https://get.jenkins.io/war/{version}/jenkins.war",
            "war_sha256": "e84790335e973f1c051f32cb1e64808049a31a17dbeaa98014937842710bf37a",
            "war_size": 52583800,
            "war_urls": [
                f"https://get.jenkins.io/war/{version}/jenkins.war",
                f"https://mirrors.huaweicloud.com/jenkins/war/{version}/jenkins.war",
                f"https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/{version}/jenkins.war",
                f"https://mirrors.aliyun.com/jenkins/war/{version}/jenkins.war",
            ],
            "jdk": "Eclipse Temurin 21.0.13+9 (OpenJDK21U)",
            "jdk_sha256_x64": "d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041447ea740c7d66d1c",
            "jdk_sha256_aarch64": "e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578",
            "workload_generator": "in-repo deterministic freestyle shell job template",
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "scenarios": scenarios_payload,
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[jenkins-parse] normalized {len(results)} metrics across {len(expected_scenarios)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
