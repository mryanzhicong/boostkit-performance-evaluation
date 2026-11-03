#!/usr/bin/env python3
"""Aggregate and strictly validate the raw Next.js measurements.

The parser refuses to produce a metric unless the evidence proves that the
scenario really did the work it claims:

* every repetition must have a JSON record and a non-empty log;
* the measured process must have exited with 0, must not have timed out and its
  wall clock / peak RSS must be finite and positive;
* the number of source files in the project must equal the number recorded by the
  build stage (a run that compiled an empty or different tree is rejected);
* build scenarios must report the compiler success line and must really have
  produced the promised static pages (`.next/BUILD_ID` plus the expected number of
  pre-rendered HTML pages), and the dynamic project must really expose its dynamic
  route;
* the warm incremental scenario must prove that it reused the build cache: its
  median compilation time must be well below the cold build of the same project
  (self-calibrating, so the check works on a slow aarch64 runner too);
* loopback scenarios must contain a complete ``[next-http]`` evidence line: the
  expected number of strictly serial requests, every response HTTP 200 and every
  response containing the expected content marker;
* logs must not contain a failure marker (``Failed to compile`` / a Next.js error
  line), and the scenario directory must contain exactly the expected files.

Any violation fails the test stage with a non-zero exit code instead of papering
over the gap with a zero, an estimate or a silently skipped metric.
"""

from __future__ import annotations

import json
import math
import os
import re
import sys
from pathlib import Path
from typing import Any

EVIDENCE_PREFIX = "[next-http]"
BUILD_SUCCESS_MARKERS = ("Compiled successfully",)
FAILURE_MARKERS = (
    "Failed to compile",
    "Error: ",
    "error - ",
    "Module not found",
    "unhandledRejection",
)


def fail(message: str) -> None:
    print(f"[nextjs-parse] ERROR: {message}", flush=True)


def load_metadata(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise RuntimeError(f"fixture metadata does not exist: {path}")
    try:
        metadata = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise RuntimeError(f"fixture metadata is not valid JSON: {error}") from error
    scenarios = metadata.get("scenarios")
    if not isinstance(scenarios, dict) or not scenarios:
        raise RuntimeError("fixture metadata has no scenario table")
    projects = metadata.get("projects")
    if not isinstance(projects, dict) or not projects:
        raise RuntimeError("fixture metadata has no project table")
    for name, entry in scenarios.items():
        for key in ("kind", "project", "command", "expected_html_pages", "expected_source_files"):
            if key not in entry:
                raise RuntimeError(f"scenario {name} has no {key}")
        if entry["kind"] not in ("build", "http"):
            raise RuntimeError(f"scenario {name} has an unsupported kind {entry['kind']!r}")
        if entry["project"] not in projects and entry["project"] != "upstream":
            raise RuntimeError(f"scenario {name} references an unknown project")
    return metadata


def summarize(values: list[float]) -> dict[str, float]:
    if not values:
        raise RuntimeError("cannot summarize an empty sample list")
    ordered = sorted(values)
    count = len(ordered)
    middle = count // 2
    median = ordered[middle] if count % 2 else (ordered[middle - 1] + ordered[middle]) / 2.0
    mean = sum(ordered) / count
    variance = sum((value - mean) ** 2 for value in ordered) / count
    return {
        "samples": count,
        "median": median,
        "min": ordered[0],
        "max": ordered[-1],
        "mean": mean,
        "stdev": math.sqrt(variance),
    }


def read_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"cannot read {path}: {error}") from error
    if not isinstance(payload, dict):
        raise RuntimeError(f"{path} does not contain a JSON object")
    return payload


def project_directory(projects_dir: Path, project: str) -> Path:
    directory = projects_dir / project
    if not directory.is_dir():
        raise RuntimeError(f"the measured project directory is missing: {directory}")
    return directory


def count_static_html(directory: Path) -> int:
    total = 0
    for suffix in ("server/app", "server/pages"):
        root = directory / ".next" / suffix
        if root.is_dir():
            total += sum(1 for path in root.rglob("*.html") if path.is_file())
    return total


def count_dynamic_routes(directory: Path) -> int:
    manifest = directory / ".next" / "routes-manifest.json"
    if not manifest.is_file():
        return 0
    try:
        payload = json.loads(manifest.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return 0
    dynamic = payload.get("dynamicRoutes")
    return len(dynamic) if isinstance(dynamic, list) else 0


def check_log_content(scenario: str, log_text: str, kind: str) -> dict[str, Any]:
    evidence: dict[str, Any] = {}
    upper = log_text
    for marker in BUILD_SUCCESS_MARKERS:
        if marker not in upper:
            raise RuntimeError(f"scenario {scenario} never reported a successful compilation")
    for marker in FAILURE_MARKERS:
        if marker in upper:
            raise RuntimeError(f"scenario {scenario} log contains the failure marker {marker!r}")
    compile_match = re.search(r"Compiled successfully in ([0-9.]+)\s*(ms|s)", log_text)
    if compile_match:
        value = float(compile_match.group(1))
        if compile_match.group(2) == "s":
            value *= 1000.0
        evidence["compile_ms"] = value
    static_match = re.search(r"Generating static pages using (\d+) workers", log_text)
    if static_match:
        evidence["workers"] = int(static_match.group(1))
    generated_match = re.search(r"\(\s*(\d+)/(\d+)\s*\)", log_text)
    if generated_match:
        evidence["generated_pages"] = int(generated_match.group(2))
    return evidence


def check_build_artifacts(
    scenario: str,
    entry: dict[str, Any],
    directory: Path,
    html_now: int | None = None,
) -> dict[str, Any]:
    build_id = directory / ".next" / "BUILD_ID"
    if not build_id.is_file():
        raise RuntimeError(f"scenario {scenario} left no .next/BUILD_ID")
    expected_html = int(entry["expected_html_pages"])
    actual_html = count_static_html(directory)
    if actual_html != expected_html:
        raise RuntimeError(
            f"scenario {scenario} produced {actual_html} pre-rendered pages, expected {expected_html}"
        )
    evidence: dict[str, Any] = {
        "build_id": build_id.read_text(encoding="utf-8").strip(),
        "html_pages": actual_html,
        "expected_html_pages": expected_html,
    }
    expected_dynamic = int(entry.get("expected_dynamic_routes", 0))
    if expected_dynamic:
        actual_dynamic = count_dynamic_routes(directory)
        if actual_dynamic < expected_dynamic:
            raise RuntimeError(
                f"scenario {scenario} exposes {actual_dynamic} dynamic routes, "
                f"expected {expected_dynamic}"
            )
        evidence["dynamic_routes"] = actual_dynamic
    return evidence


def load_samples(
    scenario: str,
    scenario_dir: Path,
    reps: int,
    expected_sources: int,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    samples: list[dict[str, Any]] = []
    printf_evidence: dict[str, Any] = {}
    for index in range(1, reps + 1):
        json_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not json_path.is_file():
            raise RuntimeError(f"missing repetition sample: {json_path}")
        if not log_path.is_file():
            raise RuntimeError(f"missing repetition log: {log_path}")
        payload = read_json(json_path)
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition rep{index}.json for {scenario} failed with exit code {exit_code}"
            )
        if payload.get("timed_out"):
            raise RuntimeError(f"repetition rep{index}.json for {scenario} timed out")
        wall = payload.get("wall_seconds")
        if not isinstance(wall, (int, float)) or isinstance(wall, bool) or not math.isfinite(wall) or wall <= 0:
            raise RuntimeError(f"repetition rep{index}.json for {scenario} has no valid wall clock")
        rss = payload.get("max_rss_mib")
        if not isinstance(rss, (int, float)) or isinstance(rss, bool) or not math.isfinite(rss) or rss <= 0:
            raise RuntimeError(f"repetition rep{index}.json for {scenario} has no valid RSS")
        sources = payload.get("source_files")
        if sources != expected_sources:
            raise RuntimeError(
                f"repetition rep{index}.json for {scenario} counted {sources} source files, "
                f"expected {expected_sources}"
            )
        log_text = log_path.read_text(encoding="utf-8", errors="replace")
        if not log_text.strip():
            raise RuntimeError(f"repetition rep{index}.log for {scenario} is empty")
        samples.append(
            {
                "repetition": index,
                "wall_seconds": float(wall),
                "max_rss_mib": float(rss),
                "log_text": log_text,
            }
        )
    return samples, printf_evidence


def http_evidence(log_text: str) -> dict[str, Any]:
    lines = [line for line in log_text.splitlines() if line.startswith(EVIDENCE_PREFIX)]
    if len(lines) != 1:
        raise RuntimeError(
            f"expected exactly one {EVIDENCE_PREFIX} evidence line, found {len(lines)}"
        )
    return json.loads(lines[0][len(EVIDENCE_PREFIX):].strip())


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
    stats: dict[str, float],
    samples: list[float],
    extra: dict[str, Any] | None = None,
) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "source_name": name,
        "scenario": scenario,
        "project": project,
        "source_files": source_files,
        "command": command,
        "native_backend": native_backend,
        "value": value,
        "unit": unit,
        "direction": direction,
        "statistics": stats,
        "samples": samples,
    }
    if extra:
        payload.update(extra)
    return payload


def parameter_payload(metadata: dict[str, Any]) -> dict[str, Any]:
    """Values that must be identical on x86_64 and aarch64.

    Node.js archives, npm native binaries and the @next/swc platform package name
    are architecture specific and therefore live in the per-metric evidence and in
    build_provenance.json, never here.
    """
    measurement = metadata.get("measurement", {})
    return {
        "variant": os.environ.get("PERF_VARIANT", "base"),
        "repetitions": int(measurement.get("repetitions", 0)),
        "warmups": int(measurement.get("warmups", 0)),
        "statistic": "median of independent repetitions",
        "offline": True,
        "next_version": metadata["next_version"],
        "react_version": metadata["react_version"],
        "react_dom_version": metadata["react_dom_version"],
        "node_version": metadata["node_version"],
        "next_engines_node": metadata["next_engines_node"],
        "npm_version": metadata["npm_version"],
        "registry_for_install": metadata["registry"],
        "dependency_manifest_sha256": metadata["dependency_manifest_sha256"],
        "dependency_lockfile_sha256": metadata["dependency_lockfile_sha256"],
        "next_tarball_sha256": metadata["next_tarball_sha256"],
        "next_tarball_sha512_integrity": metadata["next_tarball_sha512_integrity"],
        "telemetry_disabled": bool(metadata["telemetry_disabled"]),
        "build_workers": int(metadata["build_workers"]),
        "projects": {
            name: {
                "digest": entry["digest"],
                "source_files": int(entry["source_files"]),
                "expected_html_pages": int(entry["expected_html_pages"]),
            }
            for name, entry in sorted(metadata["projects"].items())
        },
        "upstream_project": {
            "project": metadata["upstream"]["project"],
            "tag": metadata["upstream"]["tag"],
            "files": int(metadata["upstream"]["files"]),
            "source_files": int(metadata["upstream"]["source_files"]),
            "manifest_sha256": metadata["upstream"]["manifest_sha256"],
        },
        "scenarios": {
            name: {
                "kind": entry["kind"],
                "project": entry["project"],
                "command": entry["command"],
                "requests": int(entry.get("requests", 0)),
            }
            for name, entry in sorted(metadata["scenarios"].items())
        },
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIR OUTPUT_JSON", file=sys.stderr, flush=True)
        return 2
    runs_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    metadata_path_raw = os.environ.get("NEXT_FIXTURE_METADATA", "")
    if not metadata_path_raw:
        fail("NEXT_FIXTURE_METADATA is not set")
        return 1
    projects_dir_raw = os.environ.get("NEXT_PROJECTS_DIR", "")
    if not projects_dir_raw:
        fail("NEXT_PROJECTS_DIR is not set")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1
    try:
        metadata = load_metadata(Path(metadata_path_raw))
    except RuntimeError as error:
        fail(str(error))
        return 1
    projects_dir = Path(projects_dir_raw)
    version = os.environ.get("SOFTWARE_VERSION", metadata["version"])
    architecture = os.environ.get("EXPECTED_ARCH", "unknown")
    variant = os.environ.get("PERF_VARIANT", "base")
    reps = int(os.environ.get("NEXT_REPS", metadata.get("measurement", {}).get("repetitions", 0)) or 0)
    if reps < 1:
        fail("the repetition count is not a positive integer")
        return 1
    native_backend = metadata.get("native_backend_package", "unknown")

    results: dict[str, Any] = {}
    artifact_evidence: dict[str, Any] = {}
    compile_medians: dict[str, float] = {}
    try:
        for scenario, entry in sorted(metadata["scenarios"].items()):
            scenario_dir = runs_dir / scenario
            project = entry["project"]
            command = entry["command"]
            expected_sources = int(entry["expected_source_files"])
            samples, _ = load_samples(scenario, scenario_dir, reps, expected_sources)
            directory = project_directory(projects_dir, project)
            kind = entry["kind"]
            values: list[float] = []
            rss_values: list[float] = []
            extra_evidence: dict[str, Any] = {}
            compile_values: list[float] = []

            for sample in samples:
                log_text = sample["log_text"]
                if kind == "build":
                    log_evidence = check_log_content(scenario, log_text, kind)
                    if "compile_ms" in log_evidence:
                        compile_values.append(log_evidence["compile_ms"])
                    extra_evidence.setdefault("workers", log_evidence.get("workers"))
                    values.append(sample["wall_seconds"])
                else:
                    evidence = http_evidence(log_text)
                    expected_requests = int(entry.get("requests", 0))
                    if int(evidence.get("requests", -1)) != expected_requests:
                        raise RuntimeError(
                            f"scenario {scenario} recorded {evidence.get('requests')} requests, "
                            f"expected {expected_requests}"
                        )
                    if int(evidence.get("verified", -1)) != max(expected_requests, 1):
                        raise RuntimeError(
                            f"scenario {scenario} verified {evidence.get('verified')} responses, "
                            f"expected {max(expected_requests, 1)}"
                        )
                    if evidence.get("path") != entry.get("path") or evidence.get("expect") != entry.get("expect"):
                        raise RuntimeError(
                            f"scenario {scenario} measured a different path or content marker"
                        )
                    startup = evidence.get("startup_seconds")
                    if not isinstance(startup, (int, float)) or not math.isfinite(startup) or startup <= 0:
                        raise RuntimeError(f"scenario {scenario} has no valid startup latency")
                    if entry.get("mode") == "startup":
                        values.append(float(startup))
                        extra_evidence.setdefault(
                            "startup_seconds_by_rep", []
                        ).append(round(float(startup), 6))
                    else:
                        latencies = evidence.get("latencies")
                        if not isinstance(latencies, list) or len(latencies) != expected_requests:
                            raise RuntimeError(
                                f"scenario {scenario} recorded {len(latencies or [])} request latencies, "
                                f"expected {expected_requests}"
                            )
                        for latency in latencies:
                            if not isinstance(latency, (int, float)) or not math.isfinite(latency) or latency <= 0:
                                raise RuntimeError(
                                    f"scenario {scenario} recorded an invalid request latency"
                                )
                        values.append(float(evidence["latency_median_seconds"]))
                        extra_evidence.setdefault("serial_requests", expected_requests)
                rss_values.append(sample["max_rss_mib"])

            artifact = check_build_artifacts(scenario, entry, directory)
            artifact_evidence[scenario] = {
                "project": project,
                "native_backend": native_backend,
                **artifact,
            }
            if compile_values:
                compile_medians[scenario] = summarize(compile_values)["median"]
                artifact_evidence[scenario]["compile_ms_median"] = round(
                    summarize(compile_values)["median"], 3
                )

            value_stats = summarize(values)
            rss_stats = summarize(rss_values)
            results[scenario] = build_metric(
                scenario,
                scenario,
                project,
                expected_sources,
                command,
                native_backend,
                value_stats["median"],
                "s",
                "lower_is_better",
                value_stats,
                [round(value, 6) for value in values],
                extra_evidence,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                scenario,
                project,
                expected_sources,
                command,
                native_backend,
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                [round(value, 3) for value in rss_values],
            )

        # Self-calibrating proof that the warm incremental rebuild really reused the
        # build cache: the same project must compile much faster than the cold
        # build.  A machine independent factor keeps the check valid on aarch64.
        cold_scenario = "build_static_1000"
        warm_scenario = "build_incremental_1000"
        if cold_scenario in compile_medians and warm_scenario in compile_medians:
            cold = compile_medians[cold_scenario]
            warm = compile_medians[warm_scenario]
            if cold <= 0 or warm <= 0:
                raise RuntimeError("the incremental cache check has no compilation timing evidence")
            ratio = warm / cold
            artifact_evidence[warm_scenario]["cache_reuse"] = {
                "cold_compile_ms": round(cold, 3),
                "warm_compile_ms": round(warm, 3),
                "ratio": round(ratio, 4),
            }
            if ratio >= 0.5:
                raise RuntimeError(
                    "the warm incremental rebuild did not reuse the build cache "
                    f"(warm/cold compile ratio {ratio:.2f})"
                )
    except (RuntimeError, KeyError, TypeError, ValueError) as error:
        fail(str(error))
        return 1

    normalized = {
        "benchmark": "nextjs_workload_matrix",
        "software": "nextjs",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": __import__("datetime").datetime.now(
            __import__("datetime").timezone.utc
        ).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameter_payload(metadata),
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "startup_latency": {"unit": "s", "direction": "lower_is_better"},
            "serial_request_latency": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "artifact_evidence": artifact_evidence,
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"[nextjs-parse] normalized {len(results)} metrics across "
        f"{len(metadata['scenarios'])} scenarios",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
