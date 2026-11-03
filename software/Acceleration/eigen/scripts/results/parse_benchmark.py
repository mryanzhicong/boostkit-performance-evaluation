#!/usr/bin/env python3
"""Normalize the measured upstream BTL matrix into ``results.json``.

Two upstream workloads are measured per scenario (one BTL action on one build
group):

1. the unmodified upstream BTL executable (``btl_eigen3_*`` from
   ``bench/btl``, built with ``-DEIGEN_BUILD_BTL=ON``) limited to a single BTL
   action through the upstream ``BTL_CONFIG`` variable.  It performs the upstream
   size sweep (``NB_POINT`` log-spaced sizes, ``MIN_TIME`` CPU seconds per
   point).  This run provides the scenario wall clock and peak RSS metrics;
   ``runs/<scenario>/warmup.log`` and ``runs/<scenario>/rep<i>.log`` are the raw
   evidence.
2. the fixed-dimension driver (``scripts/btl_single_point.cpp``) that reuses the
   same upstream action headers and the upstream ``Portable_Perf_Analyzer`` with
   the measured dimension pinned.  It provides the GFLOPS metrics at the
   reference dimensions (128/512/1024); its raw evidence lives in
   ``runs/<scenario>/size<dimension>/warmup.log`` and ``.../rep<i>.log``.

The upstream sweep cannot provide per-dimension throughput: its analyzer is
constructed once per action and keeps ``m_time_action``/``_nb_calc`` across
``eval_mflops()`` calls, so only the largest size of the sweep is really timed
and the rest of the printed curve is derived from that single measurement.

The parser requires one warm-up plus every declared independent repetition, the
complete upstream sweep (exactly ``NB_POINT`` monotonic measurement lines) and a
strictly positive finite value for every reported metric.  It never fills in,
estimates or zero-pads a value, and fails on a missing sample, a non-zero exit,
a timeout, a NaN/inf value or an unexpected sweep shape.
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

SIZE_LINE = re.compile(
    r"^\s*size\s*=\s*(\d+)\s+([0-9]+(?:\.[0-9]*)?(?:[eE][+-]?[0-9]+)?)\s+MFlops"
)
SINGLE_POINT_HEADER = re.compile(r"^# btl-single-point action=(\S+) size=(\d+)$")


def fail(message: str) -> None:
    print(f"[eigen-parse] ERROR: {message}", file=sys.stderr)


def split_csv(value: str, fallback: list[str]) -> list[str]:
    items = [item.strip() for item in value.split(",") if item.strip()]
    return items or fallback


def action_workload(action: str) -> str:
    return {
        "gemm": "dense matrix-matrix product (BTL matrix_matrix)",
        "gemv": "dense matrix-vector product (BTL matrix_vector)",
        "trisolve_matrix": "dense triangular solve with matrix right-hand side "
        "(BTL trisolve_matrix)",
        "cholesky": "dense Cholesky factorization (BTL cholesky)",
        "axpy": "BLAS-1 scaled vector addition (BTL axpy)",
    }.get(action, "unknown BTL action")


def action_expectation(action: str) -> tuple[str, str, str]:
    """Return (upstream executable, BTL result marker, BTL action selector)."""
    return {
        "gemm": ("btl_eigen3_matmat", "bench_matrix_matrix_eigen3.dat", "matrix_matrix"),
        "gemv": ("btl_eigen3_vecmat", "bench_matrix_vector_eigen3.dat", "matrix_vector"),
        "trisolve_matrix": (
            "btl_eigen3_adv",
            "bench_trisolve_matrix_eigen3.dat",
            "trisolve_matrix",
        ),
        "cholesky": ("btl_eigen3_adv", "bench_cholesky_eigen3.dat", "cholesky"),
        "axpy": ("btl_eigen3_linear", "bench_axpy_eigen3.dat", "axpy"),
    }[action]


def load_json_file(path: Path, description: str) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid {description} {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"{description} is not an object: {path}")
    return payload


def validate_evidence(
    evidence: dict[str, Any],
    evidence_path: Path,
    command_marker: str,
) -> tuple[float, float]:
    """Validate one repetition evidence file and return (wall, rss)."""
    exit_code = evidence.get("exit_code")
    if exit_code != 0:
        raise RuntimeError(f"repetition {evidence_path} failed with exit code {exit_code}")
    if evidence.get("timed_out") is True:
        raise RuntimeError(f"repetition {evidence_path} timed out")
    wall = evidence.get("wall_seconds")
    rss = evidence.get("max_rss_mib")
    if isinstance(wall, bool) or not isinstance(wall, (int, float)):
        raise RuntimeError(f"repetition {evidence_path} has no numeric wall time")
    if isinstance(rss, bool) or not isinstance(rss, (int, float)):
        raise RuntimeError(f"repetition {evidence_path} has no numeric RSS")
    if not math.isfinite(float(wall)) or wall <= 0:
        raise RuntimeError(f"repetition {evidence_path} wall time must be positive")
    if not math.isfinite(float(rss)) or rss <= 0:
        raise RuntimeError(f"repetition {evidence_path} RSS must be positive")
    command = evidence.get("command")
    if not isinstance(command, list) or not command:
        raise RuntimeError(f"repetition {evidence_path} has no recorded command")
    if not any(isinstance(item, str) and command_marker in item for item in command):
        raise RuntimeError(f"repetition {evidence_path} did not run {command_marker}")
    return float(wall), float(rss)


def read_log(log_path: Path) -> str:
    if not log_path.is_file() or log_path.stat().st_size == 0:
        raise RuntimeError(f"missing raw log: {log_path}")
    return log_path.read_text(encoding="utf-8", errors="replace")


def parse_sweep(log_path: Path, expected_points: int) -> list[tuple[int, float]]:
    """Parse the complete upstream size sweep, preserving the printed order.

    Upstream BTL reports an exact ``0 MFlops`` for the smallest sizes (the
    measured interval is too short for the float ratio), which is upstream
    behaviour and not a missing sample.  Only the sweep structure is validated
    here; the sweep values are not reported as metrics.
    """
    log_text = read_log(log_path)
    points: list[tuple[int, float]] = []
    zero_points = 0
    for line in log_text.splitlines():
        match = SIZE_LINE.match(line)
        if not match:
            continue
        size = int(match.group(1))
        mflops = float(match.group(2))
        if not math.isfinite(mflops) or mflops < 0:
            raise RuntimeError(
                f"{log_path}: size {size} reports a negative or non-finite MFlops value"
            )
        if mflops == 0:
            zero_points += 1
        points.append((size, mflops))
    if zero_points:
        print(
            f"[eigen-parse] note: {log_path.name} reports {zero_points} upstream "
            "zero-MFlops point(s) at the smallest sweep sizes (not used as metrics)"
        )
    if len(points) != expected_points:
        raise RuntimeError(
            f"{log_path}: the upstream sweep produced {len(points)} measurements, "
            f"expected {expected_points}"
        )
    sizes = [size for size, _ in points]
    # The upstream grid is log-spaced and can repeat one size at the boundary
    # between the 1..9 ramp and the log ramp; the sweep must still be monotonic.
    for previous, current in zip(sizes, sizes[1:]):
        if current > previous:
            raise RuntimeError(
                f"{log_path}: the sweep sizes are not monotonic ({previous} then {current})"
            )
    return points


def load_sweep_samples(
    scenario_dir: Path,
    reps: int,
    expected_binary: str,
    expected_marker: str,
    expected_points: int,
) -> tuple[list[float], list[float]]:
    """Wall times and peak RSS of the warm-up plus every repetition."""
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    wall_values: list[float] = []
    rss_values: list[float] = []
    for label in ["warmup"] + [f"rep{index}" for index in range(1, reps + 1)]:
        evidence = load_json_file(scenario_dir / f"{label}.json", "repetition evidence")
        wall, rss = validate_evidence(evidence, scenario_dir / f"{label}.json", expected_binary)
        log_text = read_log(scenario_dir / f"{label}.log")
        if expected_marker not in log_text:
            raise RuntimeError(
                f"{scenario_dir.name}/{label}: the upstream BTL action did not start "
                f"({expected_marker} is missing)"
            )
        parse_sweep(scenario_dir / f"{label}.log", expected_points)
        if label != "warmup":
            wall_values.append(round(wall, 6))
            rss_values.append(round(rss, 3))
    return wall_values, rss_values


def load_single_point_samples(
    dimension_dir: Path,
    reps: int,
    action_selector: str,
    dimension: int,
) -> list[float]:
    """GFLOPS samples of the fixed-dimension driver at one dimension."""
    if not dimension_dir.is_dir():
        raise RuntimeError(f"missing fixed-dimension directory: {dimension_dir}")
    gflops_values: list[float] = []
    for label in ["warmup"] + [f"rep{index}" for index in range(1, reps + 1)]:
        evidence = load_json_file(dimension_dir / f"{label}.json", "repetition evidence")
        validate_evidence(evidence, dimension_dir / f"{label}.json", "btl_single_point_")
        log_text = read_log(dimension_dir / f"{label}.log")
        headers = [SINGLE_POINT_HEADER.match(line) for line in log_text.splitlines()]
        headers = [match for match in headers if match]
        if len(headers) != 1:
            raise RuntimeError(
                f"{dimension_dir}/{label}: expected exactly one fixed-dimension header, "
                f"found {len(headers)}"
            )
        if headers[0].group(1) != action_selector:
            raise RuntimeError(
                f"{dimension_dir}/{label}: measured action {headers[0].group(1)}, "
                f"expected {action_selector}"
            )
        if int(headers[0].group(2)) != dimension:
            raise RuntimeError(
                f"{dimension_dir}/{label}: measured dimension {headers[0].group(2)}, "
                f"expected {dimension}"
            )
        points = [SIZE_LINE.match(line) for line in log_text.splitlines()]
        points = [match for match in points if match]
        if len(points) != 1:
            raise RuntimeError(
                f"{dimension_dir}/{label}: expected exactly one measurement line, "
                f"found {len(points)}"
            )
        if int(points[0].group(1)) != dimension:
            raise RuntimeError(
                f"{dimension_dir}/{label}: the measurement line reports dimension "
                f"{points[0].group(1)}, expected {dimension}"
            )
        mflops = float(points[0].group(2))
        if not math.isfinite(mflops) or mflops <= 0:
            raise RuntimeError(
                f"{dimension_dir}/{label}: the upstream analyzer reported a "
                f"non-positive or non-finite MFlops value"
            )
        if label != "warmup":
            gflops_values.append(round(mflops / 1000.0, 6))
    return gflops_values


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
    group: str,
    action: str,
    kind: str,
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
    extra: dict[str, Any],
) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "source_name": name,
        "scenario": scenario,
        "group": group,
        "action": action,
        "metric": kind,
        "workload": action_workload(action),
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }
    payload.update(extra)
    return payload


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIRECTORY NORMALIZED_OUTPUT", file=sys.stderr)
        return 1
    runs_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
        variant = os.environ.get("PERF_VARIANT", "base")
        reps = int(os.environ.get("EIGEN_REPS", "5"))
        points = int(os.environ.get("EIGEN_BTL_NB_POINT", "100"))
    except (KeyError, ValueError) as exc:
        fail(f"missing or invalid environment variable: {exc}")
        return 1
    if reps < 1:
        fail("EIGEN_REPS must be positive")
        return 1
    if points < 2:
        fail("EIGEN_BTL_NB_POINT must be at least 2")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    groups = split_csv(os.environ.get("EIGEN_GROUPS_CSV", ""), ["o3", "native"])
    actions = split_csv(
        os.environ.get("EIGEN_ACTIONS_CSV", ""),
        ["gemm", "gemv", "trisolve_matrix", "cholesky", "axpy"],
    )
    dimensions = [
        int(value)
        for value in split_csv(os.environ.get("EIGEN_SCALES_CSV", ""), ["128", "512", "1024"])
    ]

    results: dict[str, Any] = {}
    try:
        for group in groups:
            for action in actions:
                scenario = f"{group}_{action}"
                binary, marker, selector = action_expectation(action)
                wall_values, rss_values = load_sweep_samples(
                    runs_dir / scenario, reps, binary, marker, points
                )
                wall_stats = summarize(wall_values)
                results[f"{scenario}_wall"] = build_metric(
                    f"{scenario}_wall",
                    scenario,
                    group,
                    action,
                    "wall",
                    wall_stats["median"],
                    "s",
                    "lower_is_better",
                    wall_stats,
                    wall_values,
                    {"upstream_binary": binary, "repetitions": reps},
                )
                rss_stats = summarize(rss_values)
                results[f"{scenario}_rss"] = build_metric(
                    f"{scenario}_rss",
                    scenario,
                    group,
                    action,
                    "rss",
                    rss_stats["median"],
                    "MiB",
                    "lower_is_better",
                    rss_stats,
                    rss_values,
                    {"upstream_binary": binary, "repetitions": reps},
                )
                for dimension in dimensions:
                    gflops_values = load_single_point_samples(
                        runs_dir / scenario / f"size{dimension}",
                        reps,
                        selector,
                        dimension,
                    )
                    stats = summarize(gflops_values)
                    name = f"{scenario}_gflops_{dimension}"
                    results[name] = build_metric(
                        name,
                        scenario,
                        group,
                        action,
                        "gflops",
                        stats["median"],
                        "GFLOP/s",
                        "higher_is_better",
                        stats,
                        gflops_values,
                        {
                            "size": dimension,
                            "btl_action": selector,
                            "btl_driver": "scripts/btl_single_point.cpp",
                            "repetitions": reps,
                        },
                    )
    except (RuntimeError, KeyError, ValueError, TypeError) as exc:
        fail(str(exc))
        return 1

    probe_dir = Path(os.environ.get("EIGEN_PROBE_DIR", ""))
    group_macros: dict[str, list[str]] = {}
    for group in groups:
        probe_log = probe_dir / f"{group}.txt"
        if probe_log.is_file():
            group_macros[group] = sorted(
                line[len("define "):-len("=1")]
                for line in probe_log.read_text(encoding="utf-8", errors="replace").splitlines()
                if line.startswith("define ") and line.endswith("=1")
            )

    native_flag = os.environ.get("EIGEN_NATIVE_FLAG", "")
    group_flags = {"o3": "-g0 -O3 -DNDEBUG (upstream BTL default, no extra flag)"}
    group_flags["native"] = native_flag or "unresolved"

    normalized: dict[str, Any] = {
        "benchmark": "eigen_5.0.1_upstream_btl_matrix",
        "software": "eigen",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        # Fixed, architecture-independent workload description: identical on
        # x86_64 and aarch64, so cross-architecture pairing is possible.
        "parameters": {
            "variant": variant,
            "repetitions": reps,
            "warmups": 1,
            "offline": True,
            "upstream_entry": "bench/btl built with -DEIGEN_BUILD_BTL=ON",
            "upstream_sweep": {
                "btl_config": os.environ.get("EIGEN_BTL_CONFIG", "").strip(),
                "nb_point": points,
                "min_time_seconds": float(os.environ.get("EIGEN_BTL_MIN_TIME", "0.2")),
                "metrics": ["wall", "rss"],
            },
            "upstream_single_point": {
                "driver": "scripts/btl_single_point.cpp (unmodified upstream BTL "
                "actions + Portable_Perf_Analyzer, measured dimension pinned)",
                "btl_config": "-t 1",
                "dimensions": dimensions,
                "metrics": ["gflops"],
            },
            "groups": groups,
            "actions": actions,
            "reference_dimensions": dimensions,
            "archive_name": os.environ.get("EIGEN_ARCHIVE_NAME", ""),
            "archive_sha256": os.environ.get("EIGEN_ARCHIVE_SHA256", ""),
            "archive_url": os.environ.get("EIGEN_ARCHIVE_URL", ""),
            "cmake_policy_version_minimum": "3.5",
        },
        # Machine- and compiler-dependent facts; deliberately outside
        # ``parameters`` so the cross-architecture signature stays identical.
        "runtime_context": {
            "group_cxx_flags": group_flags,
            "group_isa_macros": group_macros,
            "cxx_compiler": os.environ.get("EIGEN_COMPILER", "unknown"),
            "cmake": os.environ.get("EIGEN_CMAKE", "unknown"),
            "build_parallel_jobs": int(os.environ.get("EIGEN_JOBS", "0") or 0),
            "clock": "wall clock around one measured process (scripts/run_timed.py)",
            "btl_internal_timer": "Portable_Timer CPU time, MIN_TIME=0.2 s per point",
            "upstream_sweep_note": "the BTL sweep times only its largest size and "
            "derives the remaining curve from it, so sweep MFlops are not reported",
        },
        "metric_contract": {
            "wall": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "gflops": {"unit": "GFLOP/s", "direction": "higher_is_better"},
            "statistic": "median of independent repetitions",
        },
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[eigen-parse] normalized {len(results)} metrics across {len(groups) * len(actions)} "
        f"scenarios ({len(groups)} groups x {len(actions)} actions, {reps} repetitions, "
        f"{len(dimensions)} fixed dimensions)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
