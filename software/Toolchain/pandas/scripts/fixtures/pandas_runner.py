#!/usr/bin/env python3
"""Execute one upstream pandas asv benchmark scenario in an isolated process.

The runner reproduces what asv does for a single parameter combination:

* import the upstream benchmark module from the vendored snapshot,
* run ``setup_cache`` (when present) and ``setup`` with the pinned parameters,
* verify the produced dataset with an independent computation,
* time a batch of ``iterations`` calls of the selected ``time_*`` method and
  report the per-call mean.

The upstream ``time_*`` methods do not return their result, so the correctness
gate recomputes the benchmarked operation outside the timed window and compares
it with an independent reference (a numpy reduction, a Python string operation,
or the ungrouped frame itself).  The seeded random state and the pinned
iteration count make every sample and both architectures execute the same work.
"""

import argparse
import importlib
import json
import resource
import sys
import time
import warnings
from pathlib import Path

import numpy as np

EVIDENCE_PREFIX = "[pandas-bench] "
ENVIRONMENT_PREFIX = "[pandas-env] "


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("prefetch", "measure"), required=True)
    parser.add_argument("--benchmarks-dir", required=True)
    parser.add_argument("--scenarios-file", required=True)
    parser.add_argument("--scenario", required=True)
    return parser.parse_args()


def load_scenario(path: Path, scenario_id: str) -> tuple[dict, dict]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    for entry in payload["scenarios"]:
        if entry["id"] == scenario_id:
            return payload, entry
    known = ", ".join(entry["id"] for entry in payload["scenarios"])
    raise SystemExit(f"scenario {scenario_id!r} is not in {path} (known: {known})")


def call_setup(instance: object, params: list, cached: object | None) -> None:
    if cached is not None:
        instance.setup(cached, *params)
    else:
        instance.setup(*params)


def call_timed(instance: object, method: str, params: list, cached: object | None) -> None:
    target = getattr(instance, method)
    if cached is not None:
        target(cached, *params)
    else:
        target(*params)


def verify_groupby_sum_total(instance: object, spec: dict) -> tuple[str, list[int]]:
    frame = getattr(instance, spec["frame"])
    grouped = frame.groupby(spec["key"], sort=True)[spec["value"]].sum()
    distinct = np.unique(frame[spec["key"]].to_numpy()).size
    if len(grouped) != distinct:
        raise AssertionError(f"grouped sum returned {len(grouped)} groups, expected {distinct}")
    expected = float(frame[spec["value"]].sum())
    actual = float(grouped.sum())
    tolerance = max(abs(expected) * 1e-9, 1e-6)
    if abs(actual - expected) > tolerance:
        raise AssertionError(f"grouped sum {actual!r} != frame sum {expected!r}")
    return f"grouped sum matched the frame total over {distinct} groups", [int(distinct)]


def verify_groupby_max_columns(instance: object, spec: dict) -> tuple[str, list[int]]:
    frame = getattr(instance, spec["frame"])
    group_keys = list(spec["group_keys"])
    aggregated = [column for column in frame.columns if column not in group_keys]
    if not aggregated:
        raise AssertionError("groupby benchmark has no aggregated column")
    grouped = frame.groupby(group_keys).max()
    for column in aggregated:
        expected = float(frame[column].max())
        actual = float(grouped[column].max())
        if actual != expected:
            raise AssertionError(f"grouped max of {column!r} {actual!r} != {expected!r}")
    return (
        f"grouped max of {len(aggregated)} aggregated columns matched the ungrouped maxima",
        [int(len(grouped)), int(len(aggregated))],
    )


def verify_join_row_count(instance: object, spec: dict) -> tuple[str, list[int]]:
    frame = getattr(instance, spec["frame"])
    lookup = getattr(instance, spec["lookup"])
    joined = frame.join(lookup, on=spec["key"], sort=True)
    if len(joined) != len(frame):
        raise AssertionError(f"join produced {len(joined)} rows, expected {len(frame)}")
    if len(joined.columns) < spec["minimum_columns"]:
        raise AssertionError(
            f"join produced {len(joined.columns)} columns, "
            f"expected at least {spec['minimum_columns']}"
        )
    return (
        f"join kept {len(joined)} rows and {len(joined.columns)} columns",
        [int(len(joined)), int(len(joined.columns))],
    )


def verify_merge_asof_rows(instance: object, spec: dict) -> tuple[str, list[int]]:
    import pandas

    left = getattr(instance, spec["left"])
    right = getattr(instance, spec["right"])
    merged = pandas.merge_asof(
        left,
        right,
        on=spec["key"],
        direction=spec["direction"],
        tolerance=spec["tolerance"],
    )
    if len(merged) != len(left):
        raise AssertionError(f"asof merge produced {len(merged)} rows, expected {len(left)}")
    if not merged[spec["key"]].is_monotonic_increasing:
        raise AssertionError("asof merge did not keep the left time key sorted")
    return (
        f"asof merge kept all {len(left)} left rows and stayed sorted on {spec['key']!r}",
        [int(len(merged)), int(len(merged.columns))],
    )


def verify_frame_skew(instance: object, spec: dict) -> tuple[str, list[int]]:
    values = instance.df_func(axis=spec["axis"])
    if len(values) != spec["columns"]:
        raise AssertionError(f"skew returned {len(values)} values, expected {spec['columns']}")
    array = np.asarray(values.to_numpy(), dtype=float)
    if not np.all(np.isfinite(array)):
        raise AssertionError("skew produced a non-finite value")
    return f"skew returned {len(values)} finite per-column values", [int(len(values))]


def verify_rolling_mean_last(instance: object, spec: dict) -> tuple[str, list[int]]:
    rolling = getattr(instance, spec["window_attribute"])
    frame = rolling._selected_obj
    values = frame.to_numpy(dtype=float)
    window = int(spec["window_size"])
    result = rolling.mean()
    if len(result) != len(values):
        raise AssertionError(f"rolling mean produced {len(result)} rows, expected {len(values)}")
    expected = float(np.mean(values[-window:], axis=0)[0])
    actual = float(result.iloc[-1, 0])
    tolerance = max(abs(expected) * 1e-9, 1e-12)
    if abs(actual - expected) > tolerance:
        raise AssertionError(f"rolling mean last value {actual!r} != numpy window mean {expected!r}")
    return f"last rolling mean matched the numpy window mean ({actual:.6f})", [int(len(result))]


def verify_dropdup_unique_count(instance: object, spec: dict) -> tuple[str, list[int]]:
    frame = getattr(instance, spec["frame"])
    expected = int(np.unique(frame[spec["column"]].to_numpy()).size)
    deduplicated = frame.drop_duplicates()
    if len(deduplicated) != expected:
        raise AssertionError(f"drop_duplicates kept {len(deduplicated)} rows, expected {expected}")
    if not deduplicated[spec["column"]].is_unique:
        raise AssertionError("drop_duplicates left duplicate keys")
    return f"drop_duplicates kept exactly {expected} distinct keys", [int(len(deduplicated))]


def verify_reshape_unstack(instance: object, spec: dict) -> tuple[str, list[int]]:
    frame = getattr(instance, spec["frame"])
    result = frame.unstack(int(spec["level"]))
    expected_shape = (spec["rows"], spec["columns"])
    if tuple(result.shape) != expected_shape:
        raise AssertionError(f"unstack shape {tuple(result.shape)} != {expected_shape}")
    values = result.to_numpy(dtype=float)
    if np.isnan(values).any():
        raise AssertionError("unstack produced missing cells for a complete MultiIndex product")
    levels = spec["rows"]
    columns_per_level = spec["columns"] // len(frame.columns)
    first_level = np.arange(levels).repeat(columns_per_level)
    second_level = np.roll(np.tile(np.arange(columns_per_level), levels), int(spec["roll"]))
    source = frame.to_numpy(dtype=float)
    column_names = list(frame.columns)
    for position in (0, int(len(source) // 2) - 3, len(source) - 1):
        row = int(first_level[position])
        column = int(second_level[position])
        for offset, name in enumerate(column_names):
            expected = float(source[position, offset])
            actual = float(result.loc[row, (name, column)])
            if actual != expected:
                raise AssertionError(
                    f"unstack cell ({row}, ({column}, {name!r})) {actual!r} != source {expected!r}"
                )
    return (
        f"unstack produced the full {expected_shape[0]}x{expected_shape[1]} grid with source values",
        [int(expected_shape[0]), int(expected_shape[1])],
    )


def verify_string_upper(instance: object, spec: dict) -> tuple[str, list[int]]:
    series = getattr(instance, spec["series"])
    expected = [str(value).upper() for value in series.tolist()]
    actual = [str(value) for value in series.str.upper().tolist()]
    if actual != expected:
        raise AssertionError("str.upper result does not match the Python upper() reference")
    return f"str.upper matched the Python reference for {len(expected)} values", [int(len(expected))]


VERIFIERS = {
    "groupby_sum_total": verify_groupby_sum_total,
    "groupby_max_columns": verify_groupby_max_columns,
    "join_row_count": verify_join_row_count,
    "merge_asof_rows": verify_merge_asof_rows,
    "frame_skew": verify_frame_skew,
    "rolling_mean_last": verify_rolling_mean_last,
    "dropdup_unique_count": verify_dropdup_unique_count,
    "reshape_unstack": verify_reshape_unstack,
    "string_upper": verify_string_upper,
}


def main() -> int:
    args = parse_args()
    benchmarks_dir = str(Path(args.benchmarks_dir).resolve())
    if benchmarks_dir not in sys.path:
        sys.path.insert(0, benchmarks_dir)

    payload, scenario = load_scenario(Path(args.scenarios_file), args.scenario)
    np.random.seed(int(payload.get("seed", 1234)))

    import pandas

    module = importlib.import_module(scenario["module"])
    instance = getattr(module, scenario["class"])()
    params = list(scenario.get("params") or [])

    setup_started = time.perf_counter()
    has_cache = hasattr(instance, "setup_cache")
    cached = instance.setup_cache() if has_cache else None
    if has_cache and not hasattr(instance, "setup"):
        pass
    else:
        call_setup(instance, params, cached)
    setup_seconds = time.perf_counter() - setup_started

    verify_started = time.perf_counter()
    verifier = VERIFIERS[scenario["verification"]["kind"]]
    detail, data_shape = verifier(instance, scenario["verification"])
    verify_seconds = time.perf_counter() - verify_started

    environment = {
        "python": ".".join(str(part) for part in sys.version_info[:3]),
        "pandas": pandas.__version__,
        "numpy": np.__version__,
    }
    try:
        import dateutil

        environment["python-dateutil"] = dateutil.__version__
    except Exception:  # pragma: no cover - informational only
        pass

    evidence = {
        "scenario": scenario["id"],
        "module": scenario["module"],
        "class": scenario["class"],
        "params": params,
        "method": scenario["method"],
        "iterations": int(scenario["iterations"]),
        "setup_seconds": round(setup_seconds, 6),
        "verify_seconds": round(verify_seconds, 6),
        "data_shape": data_shape,
        "correctness": {"kind": scenario["verification"]["kind"], "ok": True, "detail": detail},
        "n_jobs": 1,
    }

    if args.mode == "prefetch":
        evidence["mode"] = "prefetch"
        print(f"{ENVIRONMENT_PREFIX}{json.dumps(environment, sort_keys=True)}")
        print(f"{EVIDENCE_PREFIX}{json.dumps(evidence, sort_keys=True)}")
        return 0

    iterations = int(scenario["iterations"])
    warmup_iterations = max(1, iterations // 10)
    warmup_started = time.perf_counter()
    for _ in range(warmup_iterations):
        call_timed(instance, scenario["method"], params, cached)
    warmup_seconds = time.perf_counter() - warmup_started

    warnings.simplefilter("always")
    with warnings.catch_warnings(record=True) as caught:
        batch_started = time.perf_counter()
        for _ in range(iterations):
            call_timed(instance, scenario["method"], params, cached)
        batch_seconds = time.perf_counter() - batch_started
        captured_warnings = sorted({f"{item.category.__name__}: {item.message}" for item in caught})

    wall_seconds = batch_seconds / iterations
    if wall_seconds <= 0:
        raise SystemExit("the timed batch reported a non-positive duration")

    peak_rss_kib = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    evidence.update(
        {
            "mode": "measure",
            "warmup_iterations": warmup_iterations,
            "warmup_seconds": round(warmup_seconds, 6),
            "batch_seconds": round(batch_seconds, 6),
            "wall_seconds": round(wall_seconds, 9),
            "warnings": captured_warnings,
            "max_rss_mib": round(peak_rss_kib / 1024.0, 3),
        }
    )
    print(f"{ENVIRONMENT_PREFIX}{json.dumps(environment, sort_keys=True)}")
    print(f"{EVIDENCE_PREFIX}{json.dumps(evidence, sort_keys=True)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
