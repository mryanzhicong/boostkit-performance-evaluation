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

All outputs are parsed with ordered pairs preserved.  The normalized result is
a deliberately small set of representative, directly comparable official
fields; it does not average unrelated APIs into a synthetic score.  Every
metric name records the exact official JSON field and its fixed test scenario.
All timings run through ``clock_gettime`` (``USE_CLOCK_GETTIME=1``) and are
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


def pairs_to_mapping(pairs: PairList, source_file: str) -> dict[str, Any]:
    """Convert an object that must not contain repeated keys into a mapping."""
    values: dict[str, Any] = {}
    for key, value in pairs:
        if key in values:
            raise RuntimeError(f"{source_file} repeats object key: {key}")
        values[key] = value
    return values


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
    # The official output contains internal, inline and compiler-builtin
    # variants for every operation and input class.  They are useful raw
    # evidence but not independent report metrics.  Keep the public API with
    # the regular-input case for the four distinct operations covered here.
    selected_functions = {"isnan", "isinf", "isfinite", "isnormal"}
    selected_count: set[str] = set()
    for function, variants in functions:
        if function not in selected_functions:
            continue
        if not isinstance(variants, list) or not variants:
            raise RuntimeError(f"{source_file} function {function} has no variants")
        for variant, fields in variants:
            if variant != "normal":
                continue
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
            selected_count.add(function)
    missing_functions = selected_functions - selected_count
    if missing_functions:
        raise RuntimeError(
            f"{source_file} is missing selected math functions: "
            f"{', '.join(sorted(missing_functions))}"
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


def extract_named_string_timing(
    benchtests_dir: Path,
    results: dict[str, Any],
    source_file: str,
    function: str,
    implementation: str,
    scenario: dict[str, int],
) -> None:
    """Extract one named official string implementation from a fixed scenario.

    String benchtests list implementation timings in ``ifuncs`` order.  That
    order is architecture-dependent, therefore the required implementation is
    located by name instead of assuming a fixed array index.  glibc removes the
    public symbol (for example ``memcpy``) from this list when IFUNC dispatch
    is available, so the contract uses the named generic implementation that
    is emitted on both architectures.
    """
    root = load_pairs_output(benchtests_dir / source_file)
    require_timing_type(root, source_file)
    functions = require_single_pair(root, "functions", source_file)
    if not isinstance(functions, list):
        raise RuntimeError(f"{source_file} has malformed functions object")
    function_data = require_single_pair(functions, function, source_file)
    if not isinstance(function_data, list):
        raise RuntimeError(f"{source_file} {function} entry is malformed")
    ifuncs = require_single_pair(function_data, "ifuncs", source_file)
    rows = require_single_pair(function_data, "results", source_file)
    if not isinstance(ifuncs, list) or not all(isinstance(item, str) for item in ifuncs):
        raise RuntimeError(f"{source_file} {function} has malformed ifuncs")
    if implementation not in ifuncs:
        raise RuntimeError(
            f"{source_file} has no {implementation} timing for {function}"
        )
    if not isinstance(rows, list):
        raise RuntimeError(f"{source_file} {function} has malformed results")

    matched_rows: list[dict[str, Any]] = []
    for row in rows:
        if not isinstance(row, list):
            raise RuntimeError(f"{source_file} {function} has malformed result row")
        row_values = pairs_to_mapping(row, source_file)
        if all(row_values.get(name) == expected for name, expected in scenario.items()):
            matched_rows.append(row_values)
    if not matched_rows:
        selectors = ",".join(f"{name}={value}" for name, value in scenario.items())
        raise RuntimeError(
            f"{source_file} {function} has no scenario: {selectors}"
        )
    implementation_index = ifuncs.index(implementation)
    samples: list[float] = []
    for row in matched_rows:
        timings = row.get("timings")
        if not isinstance(timings, list) or implementation_index >= len(timings):
            raise RuntimeError(
                f"{source_file} {function} has no {implementation} timing value"
            )
        samples.append(require_positive(timings[implementation_index], function))
    selectors = ",".join(f"{name}={value}" for name, value in scenario.items())
    metric_name = (
        f"{function}.results[{selectors}].timings[ifuncs='{implementation}']."
        "arithmetic_mean"
    )
    source_field = (
        f"functions.{function}.results[{selectors}].timings[{implementation_index}]"
    )
    record_metric(
        results,
        metric_name,
        source_field,
        sum(samples) / len(samples),
        source_file,
    )
    results[metric_name]["aggregation"] = "arithmetic_mean"
    results[metric_name]["sample_count"] = len(samples)


def extract_string_api_metrics(benchtests_dir: Path, results: dict[str, Any]) -> None:
    """Normalize fixed generic string API scenarios from string-benchset."""
    scenarios = (
        ("bench-memcpy.out", "memcpy", "generic_memcpy", {"length": 4096, "align1": 0, "align2": 0, "dst > src": 0}),
        ("bench-memmove.out", "memmove", "generic_memmove", {"length": 4096, "align1": 0, "align2": 32}),
        ("bench-memset.out", "memset", "generic_memset", {"length": 4096, "alignment": 0, "char": 0}),
        ("bench-strlen.out", "strlen", "generic_strlen", {"length": 4096, "alignment": 0}),
        ("bench-strcmp.out", "strcmp", "generic_strcmp", {"length": 4096, "align1": 0, "align2": 0}),
        ("bench-strstr.out", "strstr", "twoway_strstr", {"len_haystack": 4096, "len_needle": 64, "align_haystack": 1, "align_needle": 11, "fail": 0}),
    )
    for source_file, function, implementation, scenario in scenarios:
        extract_named_string_timing(
            benchtests_dir,
            results,
            source_file,
            function,
            implementation,
            scenario,
        )


def load_named_function_fields(
    benchtests_dir: Path,
    source_file: str,
    function: str,
    variant: str,
) -> dict[str, Any]:
    """Load an official ``functions.<function>.<variant>`` object."""
    root = load_pairs_output(benchtests_dir / source_file)
    require_timing_type(root, source_file)
    functions = require_single_pair(root, "functions", source_file)
    if not isinstance(functions, list):
        raise RuntimeError(f"{source_file} has malformed functions object")
    function_data = require_single_pair(functions, function, source_file)
    if not isinstance(function_data, list):
        raise RuntimeError(f"{source_file} {function} entry is malformed")
    variant_data = require_single_pair(function_data, variant, source_file)
    if not isinstance(variant_data, list):
        raise RuntimeError(f"{source_file} {function}.{variant} entry is malformed")
    return pairs_to_mapping(variant_data, source_file)


def require_exact_number(fields: dict[str, Any], key: str, expected: int, source_file: str) -> None:
    actual = fields.get(key)
    if actual != expected:
        raise RuntimeError(f"{source_file} must report {key}={expected}, got {actual!r}")


def extract_malloc_metrics(benchtests_dir: Path, results: dict[str, Any]) -> None:
    """Normalize fixed official malloc scenarios from glibc's bench-malloc."""
    simple_file = "bench-malloc-simple-64.out"
    simple_fields = load_named_function_fields(
        benchtests_dir, simple_file, "malloc", ""
    )
    require_exact_number(simple_fields, "malloc_block_size", 64, simple_file)
    simple_field = "main_arena_st_allocs_0100_time"
    record_metric(
        results,
        "malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time",
        f"functions.malloc.''.{simple_field}",
        simple_fields.get(simple_field),
        simple_file,
    )

    tcache_file = "bench-malloc-tcache-64.out"
    fields = load_named_function_fields(benchtests_dir, tcache_file, "malloc", "optimized")
    require_exact_number(fields, "alloc_size", 64, tcache_file)
    record_metric(
        results,
        "malloc-tcache.optimized[alloc_size=64].time_per_iteration",
        "functions.malloc.optimized.time_per_iteration",
        fields.get("time_per_iteration"),
        tcache_file,
    )

    thread_file = "bench-malloc-thread-8.out"
    thread_fields = load_named_function_fields(
        benchtests_dir, thread_file, "malloc", ""
    )
    require_exact_number(thread_fields, "threads", 8, thread_file)
    record_metric(
        results,
        "malloc-thread.results[threads=8].time_per_iteration",
        "functions.malloc.''.time_per_iteration",
        thread_fields.get("time_per_iteration"),
        thread_file,
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
        extract_string_api_metrics(benchtests_dir, results)
        extract_malloc_metrics(benchtests_dir, results)
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
            "scope": "representative verbatim named JSON paths from official glibc benchtest outputs",
            "selection_policy": (
                "one fixed scenario per distinct operation; no average across unrelated APIs"
            ),
            "source_fields": [
                "mean",
                "duration",
                "results[0]",
                "timings[ifuncs='<named generic implementation>'] (arithmetic mean of duplicate scenarios)",
                "time_per_iteration",
                "main_arena_st_allocs_0100_time",
            ],
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
