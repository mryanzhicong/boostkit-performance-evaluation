#!/usr/bin/env python3
"""Normalize the React SSR matrix and the upstream build workload.

Every matrix scenario contributes three metrics: the median wall time of the
fixed render batch (seconds, lower is better), the median throughput derived
from that batch (renders per second, higher is better) and the median peak
resident set size of the measuring process (MiB, lower is better).  The upstream
build workload contributes its wall time and peak RSS.

The script reads the recorded repetitions and fails when a declared scenario is
incomplete, when a measurement exited non-zero or timed out, when the render
harness reports inconsistent inputs or a different markup, or when a sampled
value is not a positive finite number.  It never fills in, estimates or
zero-pads a missing measurement.
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

SOFTWARE = "react"

SCALES = (100, 1000, 10000)
TASKS = ("render_to_string", "static_markup", "stream")
TASK_API = {
    "render_to_string": "renderToString",
    "static_markup": "renderToStaticMarkup",
    "stream": "renderToPipeableStream",
}
TASK_MODES = {
    "render_to_string": "sync",
    "static_markup": "sync",
    "stream": "stream",
}
RENDERS_PER_SCALE = {100: 2000, 1000: 1000, 10000: 200}
WARMUP_RENDERS = 10
UPSTREAM_SCENARIOS = ("upstream_build",)
MATRIX_WORKLOAD = "deterministic React element tree rendered by the pinned React 19.3.1 runtime"
UPSTREAM_WORKLOAD = "upstream facebook/react v19.3.1 source tree, rollup release build"


def fail(message: str) -> None:
    print(f"[react-parse] ERROR: {message}", file=sys.stderr)


def expected_matrix_scenarios() -> list[str]:
    return [f"{task}_{scale}" for scale in SCALES for task in TASKS]


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 9),
        "mean": round(float(statistics.fmean(values)), 9),
        "min": round(float(min(values)), 9),
        "max": round(float(max(values)), 9),
        "stdev": round(float(statistics.stdev(values)), 9) if len(values) > 1 else 0.0,
    }


def require_finite_positive(value: Any, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise RuntimeError(f"{label} is not numeric")
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise RuntimeError(f"{label} must be a positive finite number")
    return number


def load_run_record(scenario_dir: Path, scenario: str, index: int) -> tuple[dict[str, Any], float, float]:
    sample_path = scenario_dir / f"rep{index}.json"
    if not sample_path.is_file():
        raise RuntimeError(f"missing repetition sample: {sample_path}")
    try:
        payload = json.loads(sample_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid repetition sample {sample_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"repetition sample is not an object: {sample_path}")
    if payload.get("exit_code") != 0:
        raise RuntimeError(
            f"repetition {sample_path.name} for {scenario} failed with exit code "
            f"{payload.get('exit_code')}"
        )
    if payload.get("timed_out") is True:
        raise RuntimeError(f"repetition {sample_path.name} for {scenario} timed out")
    wall_seconds = require_finite_positive(
        payload.get("wall_seconds"), f"{scenario} {sample_path.name} wall time"
    )
    rss_mib = require_finite_positive(
        payload.get("max_rss_mib"), f"{scenario} {sample_path.name} peak RSS"
    )
    log_path = scenario_dir / f"rep{index}.log"
    if not log_path.is_file() or log_path.stat().st_size == 0:
        raise RuntimeError(f"missing raw log for repetition {sample_path.name}")
    return payload, wall_seconds, rss_mib


def load_bench_record(
    scenario_dir: Path, scenario: str, index: int, scale: int, task: str, version: str
) -> dict[str, Any]:
    bench_path = scenario_dir / f"rep{index}.bench.json"
    if not bench_path.is_file():
        raise RuntimeError(f"missing render harness result: {bench_path}")
    try:
        payload = json.loads(bench_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid render harness result {bench_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"render harness result is not an object: {bench_path}")
    if payload.get("task") != task:
        raise RuntimeError(f"{bench_path.name}: task {payload.get('task')!r} != {task!r}")
    if payload.get("api") != TASK_API[task]:
        raise RuntimeError(f"{bench_path.name}: api {payload.get('api')!r} != {TASK_API[task]!r}")
    if payload.get("mode") != TASK_MODES[task]:
        raise RuntimeError(f"{bench_path.name}: mode {payload.get('mode')!r} != {TASK_MODES[task]!r}")
    if payload.get("items") != scale:
        raise RuntimeError(f"{bench_path.name}: items {payload.get('items')!r} != {scale}")
    if payload.get("renders") != RENDERS_PER_SCALE[scale]:
        raise RuntimeError(
            f"{bench_path.name}: renders {payload.get('renders')!r} != {RENDERS_PER_SCALE[scale]}"
        )
    if payload.get("warmup_renders") != WARMUP_RENDERS:
        raise RuntimeError(
            f"{bench_path.name}: warmup_renders {payload.get('warmup_renders')!r} != {WARMUP_RENDERS}"
        )
    if payload.get("list_items") != scale:
        raise RuntimeError(
            f"{bench_path.name}: rendered {payload.get('list_items')!r} list items, expected {scale}"
        )
    if payload.get("node_env") != "production":
        raise RuntimeError(f"{bench_path.name}: NODE_ENV must be production")
    for field in ("react_version", "react_dom_version"):
        if payload.get(field) != version:
            raise RuntimeError(f"{bench_path.name}: {field} {payload.get(field)!r} != {version!r}")
    markup_sha256 = payload.get("markup_sha256")
    if not isinstance(markup_sha256, str) or len(markup_sha256) != 64:
        raise RuntimeError(f"{bench_path.name}: markup_sha256 is missing or malformed")
    require_finite_positive(payload.get("markup_bytes_first"), f"{bench_path.name} markup size")
    require_finite_positive(payload.get("batch_bytes"), f"{bench_path.name} batch bytes")
    payload["batch_seconds"] = require_finite_positive(
        payload.get("batch_seconds"), f"{bench_path.name} batch time"
    )
    payload["renders_per_second"] = require_finite_positive(
        payload.get("renders_per_second"), f"{bench_path.name} throughput"
    )
    return payload


def matrix_metadata(scenario: str) -> dict[str, Any]:
    task, _, scale = scenario.rpartition("_")
    return {
        "scenario": scenario,
        "task": task,
        "api": TASK_API[task],
        "mode": TASK_MODES[task],
        "scale_items": int(scale),
        "renders_per_repetition": RENDERS_PER_SCALE[int(scale)],
        "warmup_renders": WARMUP_RENDERS,
        "workload": MATRIX_WORKLOAD,
    }


def build_metric(
    name: str,
    metadata: dict[str, Any],
    value: float,
    unit: str,
    direction: str,
    statistics_payload: dict[str, float],
    samples: list[float],
) -> dict[str, Any]:
    return {
        "source_name": name,
        **metadata,
        "value": value,
        "unit": unit,
        "direction": direction,
        **statistics_payload,
        "samples": samples,
    }


def load_matrix_scenario(
    runs_dir: Path, scenario: str, reps: int, version: str
) -> tuple[list[float], list[float], list[float], dict[str, Any]]:
    metadata = matrix_metadata(scenario)
    scale = metadata["scale_items"]
    task = metadata["task"]
    scenario_dir = runs_dir / scenario
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    batch_seconds: list[float] = []
    throughput: list[float] = []
    rss_mib: list[float] = []
    markups: set[str] = set()
    for index in range(1, reps + 1):
        _record, wall_seconds, rss = load_run_record(scenario_dir, scenario, index)
        bench = load_bench_record(scenario_dir, scenario, index, scale, task, version)
        if bench["batch_seconds"] > wall_seconds + 1e-6:
            raise RuntimeError(
                f"{scenario} rep{index}: batch time {bench['batch_seconds']}s exceeds "
                f"the measured process wall time {wall_seconds}s"
            )
        batch_seconds.append(bench["batch_seconds"])
        throughput.append(bench["renders_per_second"])
        rss_mib.append(rss)
        markups.add(bench["markup_sha256"])
    if len(markups) != 1:
        raise RuntimeError(f"{scenario}: rendered markup differs between repetitions")
    return batch_seconds, throughput, rss_mib, metadata


def load_upstream_scenario(runs_dir: Path, reps: int) -> tuple[list[float], list[float], dict[str, Any]]:
    scenario = "upstream_build"
    scenario_dir = runs_dir / scenario
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    wall: list[float] = []
    rss_mib: list[float] = []
    for index in range(1, reps + 1):
        _record, wall_seconds, rss = load_run_record(scenario_dir, scenario, index)
        wall.append(wall_seconds)
        rss_mib.append(rss)
    metadata = {
        "scenario": scenario,
        "task": "upstream_build",
        "api": None,
        "mode": None,
        "scale_items": None,
        "renders_per_repetition": None,
        "warmup_renders": None,
        "workload": UPSTREAM_WORKLOAD,
    }
    return wall, rss_mib, metadata


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
        reps = int(os.environ.get("REACT_REPS", "5"))
    except ValueError:
        fail("REACT_REPS must be an integer")
        return 1
    if reps < 1:
        fail("REACT_REPS must be positive")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1

    try:
        results: dict[str, Any] = {}
        for scenario in expected_matrix_scenarios():
            batch_seconds, throughput, rss_mib, metadata = load_matrix_scenario(
                runs_dir, scenario, reps, version
            )
            results[scenario] = build_metric(
                scenario,
                metadata,
                statistics.median(batch_seconds),
                "s",
                "lower_is_better",
                summarize(batch_seconds),
                batch_seconds,
            )
            results[f"{scenario}_rps"] = build_metric(
                f"{scenario}_rps",
                metadata,
                statistics.median(throughput),
                "render/s",
                "higher_is_better",
                summarize(throughput),
                throughput,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                metadata,
                statistics.median(rss_mib),
                "MiB",
                "lower_is_better",
                summarize(rss_mib),
                rss_mib,
            )
        for scenario in UPSTREAM_SCENARIOS:
            wall, rss_mib, metadata = load_upstream_scenario(runs_dir, reps)
            results[scenario] = build_metric(
                scenario,
                metadata,
                statistics.median(wall),
                "s",
                "lower_is_better",
                summarize(wall),
                wall,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                metadata,
                statistics.median(rss_mib),
                "MiB",
                "lower_is_better",
                summarize(rss_mib),
                rss_mib,
            )
    except (RuntimeError, TypeError, ValueError) as exc:
        fail(str(exc))
        return 1

    parameters = {
        "variant": variant,
        "repetitions": reps,
        "warmup_renders": WARMUP_RENDERS,
        "offline": True,
        "node_env": "production",
        "node_version": os.environ.get("REACT_NODE_VERSION", ""),
        "npm_version": os.environ.get("REACT_NPM_VERSION", ""),
        "yarn_version": os.environ.get("REACT_YARN_VERSION", ""),
        "react_version": os.environ.get("REACT_APP_VERSION", version),
        "react_dom_version": os.environ.get("REACT_APP_REACT_DOM_VERSION", version),
        "scheduler_version": os.environ.get("REACT_APP_SCHEDULER_VERSION", ""),
        "react_source_version": os.environ.get("REACT_SOURCE_VERSION", version),
        "node_archive_sha256": os.environ.get("REACT_NODE_ARCHIVE_SHA256", ""),
        "react_archive_sha256": os.environ.get("REACT_ARCHIVE_SHA256", ""),
        "react_dom_archive_sha256": os.environ.get("REACT_DOM_ARCHIVE_SHA256", ""),
        "scheduler_archive_sha256": os.environ.get("SCHEDULER_ARCHIVE_SHA256", ""),
        "react_source_sha256": os.environ.get("REACT_SOURCE_SHA256", ""),
        "registry": os.environ.get("REACT_REGISTRY", ""),
        "scales_items": list(SCALES),
        "tasks": list(TASKS),
        "renders_per_repetition": {str(scale): count for scale, count in RENDERS_PER_SCALE.items()},
        "upstream_build_script": os.environ.get("REACT_UPSTREAM_BUILD_SCRIPT", ""),
        "upstream_build_entries": os.environ.get("REACT_UPSTREAM_BUILD_ENTRIES", ""),
        "upstream_build_types": os.environ.get("REACT_UPSTREAM_BUILD_TYPES", ""),
        "upstream_release_channel": os.environ.get("REACT_UPSTREAM_RELEASE_CHANNEL", ""),
        "upstream_build_output": os.environ.get("REACT_UPSTREAM_BUILD_OUTPUT", ""),
        "upstream_scenarios": list(UPSTREAM_SCENARIOS),
    }
    payload = {
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "measurement": {
            "repetitions": reps,
            "warmup_renders": WARMUP_RENDERS,
            "offline": True,
            "clock": "process.hrtime.bigint (monotonic) inside the harness; wall time around the process",
        },
        "parameters": parameters,
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[react-parse] normalized {len(results)} metrics across "
        f"{len(expected_matrix_scenarios()) + len(UPSTREAM_SCENARIOS)} scenarios",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
