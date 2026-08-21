#!/usr/bin/env python3
"""Normalize official glibc benchtest outputs into the framework schema.

The raw outputs are produced by ``make bench`` inside the glibc source tree.
Two JSON shapes exist in the official benchtests:

* full documents (emitted through ``json_document_begin``) such as
  ``bench-fclose.out`` and ``bench-random-lock.out``;
* bare fragments (emitted by ``bench-skeleton.c``) such as
  ``bench-math-inlines.out`` and ``bench-sprintf.out`` that only contain the
  top-level benchmark object and must be wrapped in braces before parsing.

Two outputs repeat JSON keys and therefore cannot be loaded into plain dicts:

* ``bench-math-inlines.out`` emits every function once per input category
  (``inf/nan`` and ``normal``), repeating the function keys while keeping
  distinct variant names;
* ``bench-random-lock.out`` repeats the ``functions.random`` key once per
  bench-variant (single-threaded / multi-threaded).

All outputs are parsed with ordered pairs preserved. Every metric name is the
verbatim JSON path of a named numeric field in the official output; all
timings run through ``clock_gettime`` (``USE_CLOCK_GETTIME=1``) and are
reported in nanoseconds on every architecture.
"""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# glibc benchtests hard-code the timing_type string "hp_timing" regardless of
# the USE_CLOCK_GETTIME setting; it only proves the output comes from an
# official benchtest, while the nanosecond unit is guaranteed by the
# USE_CLOCK_GETTIME=1 build flag recorded in parameters.
REQUIRED_TIMING_TYPE = "hp_timing"

Pair = tuple[str, Any]
PairList = list[Pair]


def fail(message: str) -> None:
    print(f"[glibc-parse] ERROR: {message}", file=sys.stderr)


def read_output_text(path: Path) -> str:
    if not path.is_file():
        raise RuntimeError(f"benchtest output is missing: {path}")
    text = path.read_text(encoding="utf-8", errors="replace")
    if not text.strip():
        raise RuntimeError(f"benchtest output is empty: {path}")
    return text


def load_pairs_output(path: Path, wrap_fragment: bool = False) -> PairList:
    """Load a benchtest output as a list of ordered key/value pairs.

    Nested objects are pair lists too, so repeated keys (math-inlines
    functions, random-lock variants) stay distinguishable. Skeleton fragments
    are wrapped in braces to form a valid document.
    """
    text = read_output_text(path)
    if wrap_fragment:
        text = "{" + text.strip() + "}"
    try:
        loaded = json.loads(text, object_pairs_hook=lambda pairs: pairs)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"benchtest output is not valid JSON: {path}") from exc
    if not isinstance(loaded, list):
        raise RuntimeError(f"benchtest output has an unexpected shape: {path}")
    return loaded


def require_single_pair(pairs: PairList, key: str, source_file: str) -> Any:
    values = [value for pair_key, value in pairs if pair_key == key]
    if len(values) != 1:
        raise RuntimeError(f"{source_file} must contain exactly one {key} object")
    return values[0]


def require_timing_type(root: PairList, source_file: str) -> None:
    timing_type = require_single_pair(root, "timing_type", source_file)
    if timing_type != REQUIRED_TIMING_TYPE:
        raise RuntimeError(
            f"{source_file} reports timing_type {timing_type!r}, "
            f"expected {REQUIRED_TIMING_TYPE!r}"
        )


def require_positive(value: Any, name: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise TypeError(f"metric {name} is not numeric: {value!r}")
    if not math.isfinite(float(value)) or value <= 0:
        raise RuntimeError(f"metric {name} must be positive and finite, got {value!r}")
    return float(value)


def record_metric(
    results: dict[str, Any],
    name: str,
    source_field: str,
    value: Any,
    source_file: str,
) -> None:
    if name in results:
        raise RuntimeError(f"duplicate metric: {name}")
    results[name] = {
        "source_name": name,
        "source_field": source_field,
        "raw_value": require_positive(value, name),
        "raw_unit": "ns",
        "value": require_positive(value, name),
        "unit": "ns",
        "source_file": source_file,
    }


def extract_math_inlines(benchtests_dir: Path, results: dict[str, Any]) -> None:
    source_file = "bench-math-inlines.out"
    root = load_pairs_output(benchtests_dir / source_file, wrap_fragment=True)
    functions = require_single_pair(root, "math-inlines", source_file)
    if not isinstance(functions, list) or not functions:
        raise RuntimeError(f"{source_file} has no math functions")
    for function, variants in functions:
        if not isinstance(variants, list) or not variants:
            raise RuntimeError(f"{source_file} function {function} has no variants")
        for variant, fields in variants:
            if not isinstance(fields, list):
                raise RuntimeError(
                    f"{source_file} function {function} variant {variant} is malformed"
                )
            mean = require_single_pair(fields, "mean", f"{source_file} {function}/{variant}")
            record_metric(
                results,
                f"math-inlines.{function}.{variant}.mean",
                "mean",
                mean,
                source_file,
            )


def extract_sprintf(benchtests_dir: Path, results: dict[str, Any]) -> None:
    source_file = "bench-sprintf.out"
    root = load_pairs_output(benchtests_dir / source_file, wrap_fragment=True)
    variants = require_single_pair(root, "sprintf", source_file)
    if not isinstance(variants, list) or not variants:
        raise RuntimeError(f"{source_file} has no variants")
    for variant, fields in variants:
        if not isinstance(fields, list):
            raise RuntimeError(f"{source_file} variant {variant} is malformed")
        mean = require_single_pair(fields, "mean", f"{source_file} {variant}")
        record_metric(results, f"sprintf.{variant}.mean", "mean", mean, source_file)


def extract_fclose(benchtests_dir: Path, results: dict[str, Any]) -> None:
    source_file = "bench-fclose.out"
    root = load_pairs_output(benchtests_dir / source_file)
    require_timing_type(root, source_file)
    functions = require_single_pair(root, "functions", source_file)
    if not isinstance(functions, list) or [key for key, _ in functions] != ["fclose"]:
        raise RuntimeError(f"{source_file} does not describe the fclose function")
    fclose = functions[0][1]
    if not isinstance(fclose, list):
        raise RuntimeError(f"{source_file} fclose entry is malformed")
    duration = require_single_pair(fclose, "duration", source_file)
    record_metric(results, "fclose.duration", "duration", duration, source_file)


def extract_random_lock(benchtests_dir: Path, results: dict[str, Any]) -> None:
    source_file = "bench-random-lock.out"
    # The document repeats the "functions.random" key once per bench-variant
    # (single-threaded / multi-threaded), so object pairs must be preserved.
    root = load_pairs_output(benchtests_dir / source_file)
    require_timing_type(root, source_file)
    functions = require_single_pair(root, "functions", source_file)
    if not isinstance(functions, list) or not functions:
        raise RuntimeError(f"{source_file} has no functions object")
    seen_variants: set[str] = set()
    for entry_key, entry in functions:
        if entry_key != "random":
            raise RuntimeError(f"{source_file} contains unexpected function: {entry_key}")
        bench_variant = require_single_pair(entry, "bench-variant", source_file)
        result_values = require_single_pair(entry, "results", source_file)
        if not isinstance(bench_variant, str) or not bench_variant:
            raise RuntimeError(f"{source_file} random entry has no bench-variant")
        if bench_variant in seen_variants:
            raise RuntimeError(f"{source_file} repeats bench-variant: {bench_variant}")
        seen_variants.add(bench_variant)
        if not isinstance(result_values, list) or len(result_values) != 1:
            raise RuntimeError(
                f"{source_file} bench-variant {bench_variant} has no single result"
            )
        record_metric(
            results,
            f"random.{bench_variant}",
            "results[0]",
            result_values[0],
            source_file,
        )


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py BENCHTESTS_OUTPUT_DIR NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    benchtests_dir, normalized_output = Path(sys.argv[1]), Path(sys.argv[2])

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    benchset = [item for item in os.environ.get("GLIBC_BENCHSET", "").split() if item]
    if not benchset:
        fail("GLIBC_BENCHSET is empty")
        return 1
    try:
        use_clock_gettime = int(os.environ.get("GLIBC_USE_CLOCK_GETTIME", "1"))
    except ValueError:
        fail("GLIBC_USE_CLOCK_GETTIME is not an integer")
        return 1
    if use_clock_gettime != 1:
        fail("GLIBC_USE_CLOCK_GETTIME must be 1 so all timings are nanoseconds")
        return 1
    timing_type_output = os.environ.get("TIMING_TYPE_OUTPUT", "")

    if not benchtests_dir.is_dir():
        fail(f"benchtest output directory does not exist: {benchtests_dir}")
        return 1

    results: dict[str, Any] = {}
    try:
        extract_math_inlines(benchtests_dir, results)
        extract_sprintf(benchtests_dir, results)
        extract_fclose(benchtests_dir, results)
        extract_random_lock(benchtests_dir, results)
    except (RuntimeError, TypeError) as exc:
        fail(str(exc))
        return 1

    runtime_context: dict[str, Any] = {"bench_timing_type": timing_type_output}
    normalized = {
        "benchmark": "glibc_official_benchtests",
        "software": "glibc",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": [
                "make",
                "bench",
                f"BENCHSET={' '.join(benchset)}",
                "USE_CLOCK_GETTIME=1",
            ],
            "benchset": benchset,
            "use_clock_gettime": use_clock_gettime,
            "timing_backend": "clock_gettime (CLOCK_MONOTONIC, ns)",
            "bench_duration_seconds": 1,
            "official_suite": "glibc benchtests (make bench, benchtests/Makefile)",
        },
        "metric_contract": {
            "scope": "verbatim named JSON paths from official glibc benchtest outputs",
            "source_fields": ["mean", "duration", "results[0]"],
            "normalized_unit": "ns",
            "direction": "lower_is_better",
        },
        "runtime_context": runtime_context,
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[glibc-parse] normalized {len(results)} official glibc benchtest metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
