#!/usr/bin/env python3
"""Normalize the TypeScript workload matrix from the recorded per-repetition samples.

Every scenario contributes two metrics: the wall-clock median of the measured tsc
invocation (seconds, lower is better) and the median peak resident set size of
the tsc process (MiB, lower is better).  Raw per-repetition logs and timing JSON
files stay in ``runs/<scenario>/`` as the primary evidence; this script only
aggregates them and fails when a declared scenario is incomplete, when a
repetition did not exit cleanly, when the compiler did not really compile the
declared program, or when a scenario did not produce the artifacts it promises.
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

SCENARIOS = (
    "check_small",
    "check_medium",
    "check_large",
    "check_upstream",
    "emit_medium",
    "incremental_warm_medium",
    "incremental_change_medium",
    "references_build",
)

# A tsc log must never be accepted as evidence when the compiler reported a
# diagnostic: the scenario commands are supposed to compile clean programs, so a
# diagnostic means the measured input changed under us.
DIAGNOSTIC_PATTERN = re.compile(r"error TS\d+")
SPACED_DIAGNOSTIC_PATTERN = re.compile(r"\berror\s+TS\d+")
FILES_PATTERN = re.compile(r"^Files:\s+(\d+)\s*$", re.MULTILINE)
CHECK_TIME_PATTERN = re.compile(r"^Check time:\s+([0-9.]+)s\s*$", re.MULTILINE)
EMIT_TIME_PATTERN = re.compile(r"^Emit time:\s+([0-9.]+)s\s*$", re.MULTILINE)
TOTAL_TIME_PATTERN = re.compile(r"^Total time:\s+([0-9.]+)s\s*$", re.MULTILINE)


def fail(message: str) -> None:
    print(f"[typescript-parse] ERROR: {message}", file=sys.stderr)


def load_metadata(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise RuntimeError(f"cannot read fixture metadata {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"invalid JSON in fixture metadata {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError("fixture metadata must be a JSON object")
    scenarios = payload.get("scenarios")
    if not isinstance(scenarios, dict) or not scenarios:
        raise RuntimeError("fixture metadata has no scenario table")
    for scenario in SCENARIOS:
        entry = scenarios.get(scenario)
        if not isinstance(entry, dict):
            raise RuntimeError(f"fixture metadata has no entry for scenario {scenario}")
        project = entry.get("project")
        if not isinstance(project, str) or not project:
            raise RuntimeError(f"fixture metadata has no project for {scenario}")
        source_files = entry.get("source_files")
        if isinstance(source_files, bool) or not isinstance(source_files, int) or source_files <= 0:
            raise RuntimeError(f"fixture metadata has no positive source_files for {scenario}")
    return payload


def parse_float(pattern: re.Pattern[str], text: str) -> float | None:
    match = pattern.search(text)
    if match is None:
        return None
    return float(match.group(1))


def check_log_semantics(scenario: str, log_path: Path, entry: dict[str, Any]) -> dict[str, Any]:
    """Validate that the log proves the declared compiler work really happened."""
    try:
        text = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise RuntimeError(f"cannot read repetition log {log_path}: {exc}") from exc
    if not text.strip():
        raise RuntimeError(f"repetition log is empty: {log_path}")
    if DIAGNOSTIC_PATTERN.search(text) or SPACED_DIAGNOSTIC_PATTERN.search(text):
        for line in text.splitlines():
            if DIAGNOSTIC_PATTERN.search(line) or SPACED_DIAGNOSTIC_PATTERN.search(line):
                raise RuntimeError(
                    f"the measured {scenario} run reported a compiler diagnostic: {line.strip()}"
                )
    evidence: dict[str, Any] = {}
    required_build_lines = entry.get("required_build_lines")
    if required_build_lines is not None:
        building = [line for line in text.splitlines() if "Building project" in line]
        if len(building) < int(required_build_lines):
            raise RuntimeError(
                f"the measured {scenario} build announced {len(building)} projects, "
                f"expected at least {required_build_lines}"
            )
        evidence["built_projects"] = len(building)
        return evidence

    files_match = FILES_PATTERN.search(text)
    if files_match is None:
        raise RuntimeError(f"the measured {scenario} run produced no 'Files:' diagnostic line")
    files = int(files_match.group(1))
    minimum = entry.get("expected_files_min")
    maximum = entry.get("expected_files_max")
    if isinstance(minimum, int) and files < minimum:
        raise RuntimeError(
            f"the measured {scenario} run compiled {files} files, expected at least {minimum}"
        )
    if isinstance(maximum, int) and files > maximum:
        raise RuntimeError(
            f"the measured {scenario} run compiled {files} files, expected at most {maximum}"
        )
    evidence["compiled_files"] = files

    check_time = parse_float(CHECK_TIME_PATTERN, text)
    if check_time is None:
        raise RuntimeError(f"the measured {scenario} run produced no 'Check time:' diagnostic line")
    check_min = entry.get("expected_check_time_min")
    check_max = entry.get("expected_check_time_max")
    if isinstance(check_min, (int, float)) and check_time < float(check_min):
        raise RuntimeError(
            f"the measured {scenario} run spent {check_time:.3f}s checking types, "
            f"which is too little to be a real check"
        )
    if isinstance(check_max, (int, float)) and check_time > float(check_max):
        raise RuntimeError(
            f"the measured {scenario} run spent {check_time:.3f}s checking types, "
            f"which means the incremental state was not used"
        )
    evidence["check_time_seconds"] = round(check_time, 3)

    emit_min = entry.get("expected_emit_time_min")
    if isinstance(emit_min, (int, float)):
        emit_time = parse_float(EMIT_TIME_PATTERN, text)
        if emit_time is None:
            raise RuntimeError(f"the measured {scenario} run produced no 'Emit time:' diagnostic line")
        if emit_time < float(emit_min):
            raise RuntimeError(
                f"the measured {scenario} run spent {emit_time:.3f}s emitting files, "
                f"which is too little to be a real emit"
            )
        evidence["emit_time_seconds"] = round(emit_time, 3)

    total_time = parse_float(TOTAL_TIME_PATTERN, text)
    if total_time is not None:
        evidence["reported_total_seconds"] = round(total_time, 3)
    return evidence


def load_samples(
    scenario_dir: Path,
    reps: int,
    entry: dict[str, Any],
) -> list[dict[str, Any]]:
    scenario = scenario_dir.name
    expected_sources = int(entry["source_files"])
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        sample_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not sample_path.is_file():
            raise RuntimeError(f"missing repetition sample: {sample_path}")
        if not log_path.is_file():
            raise RuntimeError(f"missing repetition log: {log_path}")
        if log_path.stat().st_size == 0:
            raise RuntimeError(f"repetition log is empty: {log_path}")
        try:
            payload = json.loads(sample_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"invalid repetition sample {sample_path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise RuntimeError(f"repetition sample is not an object: {sample_path}")
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario} failed "
                f"with exit code {exit_code}"
            )
        if payload.get("timed_out"):
            raise RuntimeError(f"repetition {sample_path.name} for {scenario} timed out")
        wall = payload.get("wall_seconds")
        rss = payload.get("max_rss_mib")
        sources = payload.get("source_files")
        if isinstance(wall, bool) or not isinstance(wall, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric wall time")
        if isinstance(rss, bool) or not isinstance(rss, (int, float)):
            raise RuntimeError(f"repetition {sample_path.name} has no numeric RSS")
        if not math.isfinite(float(wall)) or wall <= 0:
            raise RuntimeError(f"repetition {sample_path.name} wall time must be positive")
        if not math.isfinite(float(rss)) or rss <= 0:
            raise RuntimeError(f"repetition {sample_path.name} RSS must be positive")
        if isinstance(sources, bool) or not isinstance(sources, int) or sources <= 0:
            raise RuntimeError(f"repetition {sample_path.name} has no source file count")
        if sources != expected_sources:
            raise RuntimeError(
                f"repetition {sample_path.name} for {scenario} compiled {sources} source "
                f"files, expected {expected_sources}"
            )
        evidence = check_log_semantics(scenario, log_path, entry)
        samples.append(
            {
                "repetition": index,
                "wall_seconds": round(float(wall), 6),
                "max_rss_mib": round(float(rss), 3),
                "source_files": sources,
                "compiler_evidence": evidence,
                "log": f"rep{index}.log",
            }
        )
    return samples


def check_artifacts(
    scenario: str,
    entry: dict[str, Any],
    projects_dir: Path,
) -> dict[str, int]:
    """Verify that the scenario's promised output really exists on disk."""
    artifacts = entry.get("required_artifacts") or []
    if not artifacts:
        return {}
    project_dir = projects_dir / str(entry["project"])
    if not project_dir.is_dir():
        raise RuntimeError(f"the work directory of scenario {scenario} is missing: {project_dir}")
    observed: dict[str, int] = {}
    for artifact in artifacts:
        pattern = str(artifact["pattern"])
        minimum = int(artifact["min"])
        found = [path for path in project_dir.glob(pattern) if path.is_file()]
        if len(found) < minimum:
            raise RuntimeError(
                f"scenario {scenario} produced {len(found)} files matching {pattern!r}, "
                f"expected at least {minimum}"
            )
        observed[pattern] = len(found)
    return observed


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
        "stdev": round(float(statistics.stdev(values)), 6) if len(values) > 1 else 0.0,
    }


def build_metric(
    name: str,
    scenario: str,
    project: str,
    source_files: int,
    command: str,
    native_backend: str,
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        "scenario": scenario,
        "project": project,
        "source_files": source_files,
        "command": command,
        "native_backend": native_backend,
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def scenario_command_text(scenario_dir: Path) -> str:
    command_file = scenario_dir / "command.txt"
    try:
        text = command_file.read_text(encoding="utf-8").strip()
    except OSError:
        return ""
    return text.replace("\n", " ")


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
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    try:
        reps = int(os.environ.get("TS_REPS", "5"))
    except ValueError:
        fail("TS_REPS must be an integer")
        return 1
    if reps < 1:
        fail("TS_REPS must be positive")
        return 1
    metadata_path_raw = os.environ.get("TS_FIXTURE_METADATA", "")
    if not metadata_path_raw:
        fail("TS_FIXTURE_METADATA is not set")
        return 1
    projects_dir_raw = os.environ.get("TS_PROJECTS_DIR", "")
    if not projects_dir_raw:
        fail("TS_PROJECTS_DIR is not set")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1
    try:
        metadata = load_metadata(Path(metadata_path_raw))
    except RuntimeError as exc:
        fail(str(exc))
        return 1
    scenario_table = metadata["scenarios"]
    projects_dir = Path(projects_dir_raw)
    native_backend = str(metadata.get("native_backend", "unknown"))

    results: dict[str, Any] = {}
    scenario_parameters: dict[str, Any] = {}
    artifact_evidence: dict[str, Any] = {}
    try:
        for scenario in SCENARIOS:
            entry = scenario_table[scenario]
            scenario_dir = runs_dir / scenario
            if not scenario_dir.is_dir():
                raise RuntimeError(f"missing scenario directory: {scenario_dir}")
            samples = load_samples(scenario_dir, reps, entry)
            wall_values = [sample["wall_seconds"] for sample in samples]
            rss_values = [sample["max_rss_mib"] for sample in samples]
            wall_stats = summarize(wall_values)
            rss_stats = summarize(rss_values)
            command = scenario_command_text(scenario_dir)
            project = str(entry["project"])
            source_files = int(entry["source_files"])
            artifacts = check_artifacts(scenario, entry, projects_dir)
            artifact_evidence[scenario] = artifacts
            results[scenario] = build_metric(
                scenario, scenario, project, source_files, command, native_backend,
                wall_stats["median"], "s", "lower_is_better", wall_stats, wall_values,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss", scenario, project, source_files, command, native_backend,
                rss_stats["median"], "MiB", "lower_is_better", rss_stats, rss_values,
            )
            scenario_parameters[scenario] = {
                "project": project,
                "source_files": source_files,
                "command": command,
            }
    except (RuntimeError, KeyError, TypeError) as exc:
        fail(str(exc))
        return 1

    # Parameters are hashed into the cross-architecture parameter signature, so
    # they must only contain values that are identical on every architecture.
    # The native backend package name and the compiler binary are architecture
    # specific, therefore they are reported per metric as evidence instead of as
    # a workload parameter.
    projects_table: dict[str, Any] = {}
    for name, entry in sorted(metadata.get("projects", {}).items()):
        if not isinstance(entry, dict):
            continue
        projects_table[name] = {
            "modules": entry.get("modules"),
            "digest": entry.get("digest"),
            **({"packages": entry["packages"]} if "packages" in entry else {}),
        }
    upstream = metadata.get("upstream_project", {})
    normalized: dict[str, Any] = {
        "benchmark": "typescript_workload_matrix",
        "software": "typescript",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "network": "measured runs have no network access (closed proxy)",
            "statistic": "median of independent repetitions",
            "typescript_version": metadata.get("typescript_version", version),
            "node_version": metadata.get("node_version", "unknown"),
            "typescript_engines_node": metadata.get("typescript_engines_node", "unknown"),
            "registry": metadata.get("registry", "unknown"),
            "typescript_tarball_sha256": metadata.get("tarballs", {}).get("typescript", {}).get("sha256", "unknown"),
            "typescript_tarball_sha512_integrity": metadata.get("tarballs", {}).get("typescript", {}).get("sha512_integrity", "unknown"),
            "projects": projects_table,
            "upstream_project": {
                "name": upstream.get("name", "unknown"),
                "version": upstream.get("version", "unknown"),
                "source": upstream.get("source", "unknown"),
                "tarball_sha256": upstream.get("tarball_sha256", "unknown"),
                "manifest_sha256": upstream.get("manifest_sha256", "unknown"),
                "modules": upstream.get("modules", "unknown"),
            },
            "scenarios": scenario_parameters,
        },
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "artifact_evidence": artifact_evidence,
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"[typescript-parse] normalized {len(results)} metrics across {len(SCENARIOS)} scenarios"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
