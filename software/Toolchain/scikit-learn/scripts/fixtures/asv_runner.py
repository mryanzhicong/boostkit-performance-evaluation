#!/usr/bin/env python3
"""Run one scenario of the upstream scikit-learn asv benchmark suite.

The benchmark *definitions* are the upstream ones: the vendored files under
``asv_benchmarks/benchmarks`` are a byte-identical copy of scikit-learn 1.9.1
(tag commit recorded in ``fixtures/scenarios.json``).  This runner replaces the
``asv`` command line so that the repository's sampling protocol is used:

* ``--mode prefetch`` warms the joblib dataset cache and validates that the
  scenario runs at all; the build stage uses it as a correctness gate.  Nothing
  is timed.
* ``--mode measure`` performs the untimed setup (dataset load and, for the
  predictor scenarios, one untimed estimator fit) and then times exactly one
  call of the ``time_*`` method, which is what asv itself times.

The measured wall clock and the peak RSS are reported by ``run_timed.py``; this
script additionally prints one machine-readable evidence line per invocation so
that the strict parser can verify the workload really ran:

``[sklearn-bench] {"scenario": ..., "wall_seconds": ..., "data_shape": ...,
"score": ..., "score_kind": ...}``
"""

from __future__ import annotations

import argparse
import importlib
import json
import math
import os
import resource
import sys
import time
import traceback
import warnings
from pathlib import Path

BANNER = "[sklearn-env]"
EVIDENCE = "[sklearn-bench]"


def load_scenarios(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def pin_environment() -> None:
    """Pin the asv benchmark environment before the benchmark modules import."""
    os.environ.setdefault("SKLBENCH_PROFILE", "regular")
    os.environ.setdefault("SKLBENCH_NJOBS", "[1]")


def import_benchmark_class(benchmarks_dir: Path, module_name: str, class_name: str):
    if str(benchmarks_dir) not in sys.path:
        sys.path.insert(0, str(benchmarks_dir))
    module = importlib.import_module(module_name)
    return getattr(module, class_name)


def build_estimator_instance(cls, params: tuple):
    instance = cls()
    data = instance.make_data(params)
    instance.X, instance.X_val, instance.y, instance.y_val = data
    instance.estimator = instance.make_estimator(params)
    instance.estimator.fit(instance.X, instance.y)
    instance.make_scorers()
    return instance, "make_data+fit"


def build_plain_instance(cls, params: tuple):
    instance = cls()
    instance.setup(*params)
    return instance, "setup"


def compute_score(instance, scenario: dict, params: tuple) -> float:
    expected = scenario.get("expected", {})
    score_kind = expected.get("score_kind", "score")
    method_name = {
        "balanced_accuracy": "track_train_score",
        "r2": "track_train_score",
        "neg_inertia": "track_train_score",
        "accuracy": "track_crossval",
    }.get(score_kind, "track_train_score")
    track = getattr(instance, method_name, None)
    if track is None:
        raise RuntimeError(f"benchmark class has no {method_name} for score kind {score_kind}")
    value = track(*params)
    return float(value)


def print_environment_banner() -> None:
    import numpy
    import scipy
    import sklearn

    try:
        import joblib
        joblib_version = joblib.__version__
    except Exception:  # pragma: no cover - joblib is mandatory
        joblib_version = "missing"
    try:
        import narwhals
        narwhals_version = narwhals.__version__
    except Exception:
        narwhals_version = "missing"
    try:
        import threadpoolctl
        threadpoolctl_version = threadpoolctl.__version__
    except Exception:
        threadpoolctl_version = "missing"
    print(
        f"{BANNER} python={sys.version.split()[0]} sklearn={sklearn.__version__} "
        f"numpy={numpy.__version__} scipy={scipy.__version__} "
        f"joblib={joblib_version} narwhals={narwhals_version} "
        f"threadpoolctl={threadpoolctl_version}",
        flush=True,
    )


def run_once(args) -> int:
    payload = load_scenarios(Path(args.scenarios))
    scenario = next(
        (item for item in payload["scenarios"] if item["name"] == args.scenario), None
    )
    if scenario is None:
        print(f"{EVIDENCE} ERROR unknown scenario {args.scenario}", flush=True)
        return 10

    params = tuple(scenario["params"])
    benchmarks_dir = Path(args.benchmarks_dir).resolve()
    pin_environment()
    print_environment_banner()

    cls = import_benchmark_class(benchmarks_dir, scenario["module"], scenario["class"])
    if scenario["kind"] == "estimator":
        instance, setup_kind = build_estimator_instance(cls, params)
    elif scenario["kind"] == "plain":
        instance, setup_kind = build_plain_instance(cls, params)
    else:
        print(f"{EVIDENCE} ERROR unknown scenario kind {scenario['kind']}", flush=True)
        return 10

    method = getattr(instance, scenario["method"], None)
    if method is None:
        print(
            f"{EVIDENCE} ERROR benchmark class has no method {scenario['method']}",
            flush=True,
        )
        return 10

    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter("always")
        if args.mode == "prefetch":
            method(*params)
            wall_seconds = 0.0
        else:
            started = time.perf_counter()
            method(*params)
            wall_seconds = time.perf_counter() - started

    data_shape = list(instance.X.shape) if getattr(instance, "X", None) is not None else None
    score = compute_score(instance, scenario, params)
    if not math.isfinite(score):
        print(f"{EVIDENCE} ERROR non-finite score {score}", flush=True)
        return 10

    evidence = {
        "scenario": scenario["name"],
        "mode": args.mode,
        "module": scenario["module"],
        "benchmark_class": scenario["class"],
        "params": list(params),
        "method": scenario["method"],
        "metric": scenario["metric"],
        "setup_kind": setup_kind,
        "wall_seconds": wall_seconds,
        "data_shape": data_shape,
        "score": score,
        "score_kind": scenario.get("expected", {}).get("score_kind", "score"),
        "warnings": sorted({type(item.message).__name__ for item in caught}),
        "max_rss_mib": round(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024.0, 3),
        "n_jobs": 1,
    }
    print(f"{EVIDENCE} {json.dumps(evidence, sort_keys=True)}", flush=True)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--benchmarks-dir", required=True)
    parser.add_argument("--mode", choices=("prefetch", "measure"), required=True)
    args = parser.parse_args()
    try:
        return run_once(args)
    except Exception:
        traceback.print_exc()
        print(f"{EVIDENCE} ERROR scenario {args.scenario} failed", flush=True)
        return 10


if __name__ == "__main__":
    raise SystemExit(main())
