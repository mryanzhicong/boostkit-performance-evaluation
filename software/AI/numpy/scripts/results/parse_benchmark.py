#!/usr/bin/env python3
"""Strictly validate one asv run and publish the numpy metric document.

The parser is the only component that may declare a measurement successful.  It
re-reads the asv results JSON produced inside the private container, the shipped
benchmark-id list and the measurement protocol environment, and refuses to
publish anything when a single invariant is violated: a wrong source commit, a
Python minor-version drift, an architecture drift, an id the run never covered,
a failed (``NaN``/``null``) combination, a non-finite result, a sample count that
does not match ``NUMPY_WARMUPS + NUMPY_REPS`` or a non-positive sample.  It never
fills a missing metric with a zero.

asv stores one row per benchmark in ``results``; ``result_columns`` gives the
positional layout, ``params`` holds the full parameter domain of that benchmark
and ``result``/``samples`` are flat row-major lists over
``itertools.product(*params)`` with ``NaN``/``null`` for combinations that were
not selected or failed.  A combination's metric id is ``name`` alone for a
zero-parameter benchmark and ``name(value0, value1, ...)`` using the stored repr
strings verbatim otherwise.

Usage:
    parse_benchmark.py --results FILE --list FILE --out BENCHMARK_RESULT.json \\
        --samples RUNS/samples.json [--benchmarks FILE] [--log-summary]

Exit codes
----------
0   every requested metric was validated and published
50  any contract violation (nothing is written)
"""

from __future__ import annotations

import argparse
import collections
import itertools
import json
import math
import os
import re
import statistics
import sys
from pathlib import Path

EVIDENCE_PREFIX = "[numpy] "
ESCAPE_SEQUENCE = re.compile(r"\\(.)")
RESULTS_API_VERSION = 2
REQUIRED_RESULT_COLUMNS = ("result", "params", "samples")
STATISTIC = "median"
METRIC_UNIT = "s"
METRIC_DIRECTION = "lower_is_better"

DEFAULT_REPS = 5
DEFAULT_WARMUPS = 1
REQUIRED_ENV = (
    "NUMPY_BASELINE_COMMIT",
    "NUMPY_PYTHON_SHORT",
    "SOFTWARE_VERSION",
    "PERF_VARIANT",
    "EXPECTED_ARCH",
    "ASV_SUITE_COMMIT",
    "ASV_VERSION",
)

EXIT_OK = 0
EXIT_INVALID = 50

Combo = collections.namedtuple("Combo", "benchmark index dims params")


class ValidationError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def read_bytes(path: Path) -> bytes:
    try:
        return path.read_bytes()
    except FileNotFoundError as exc:
        raise ValidationError(f"missing file: {path}") from exc


def read_json(path: Path) -> dict:
    try:
        payload = json.loads(read_bytes(path).decode("utf-8"))
    except UnicodeDecodeError as exc:
        raise ValidationError(f"{path} is not UTF-8: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(f"invalid JSON in {path}: {exc}") from exc
    require(isinstance(payload, dict), f"{path} is not a JSON object")
    return payload


def write_json(path: Path, document: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    scratch = path.with_name(path.name + ".tmp")
    scratch.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    os.replace(scratch, path)


def literal_id(line: str) -> str:
    return ESCAPE_SEQUENCE.sub(r"\1", line.strip())


def load_list(path: Path) -> list[str]:
    text = read_bytes(path).decode("utf-8")
    identifiers = [literal_id(line) for line in text.splitlines() if line.strip()]
    require(bool(identifiers), f"{path} contains no benchmark ids")
    duplicates = [
        identifier
        for identifier, count in collections.Counter(identifiers).items()
        if count > 1
    ]
    require(
        not duplicates,
        f"{path} repeats benchmark id(s): " + ", ".join(sorted(duplicates)),
    )
    return identifiers


def is_finite_number(value: object) -> bool:
    return (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and math.isfinite(float(value))
    )


def normalise_python(value: object) -> str:
    require(isinstance(value, str) and value.strip(), f"invalid python version: {value!r}")
    parts = value.strip().split(".")
    require(len(parts) >= 2 and all(part.isdigit() for part in parts[:2]), f"invalid python version: {value!r}")
    return f"{parts[0]}.{parts[1]}"


def normalise_arch(value: object) -> str:
    require(isinstance(value, str) and value.strip(), f"invalid architecture: {value!r}")
    lowered = value.strip().lower()
    if lowered in ("x86_64", "amd64"):
        return "x86_64"
    if lowered in ("aarch64", "arm64"):
        return "aarch64"
    return lowered


def commit_matches(actual: object, expected: str) -> bool:
    """Accept the pinned full hash or an unambiguous git-style prefix of it."""
    if not isinstance(actual, str) or not actual:
        return False
    actual = actual.strip().lower()
    expected = expected.strip().lower()
    if actual == expected:
        return True
    if len(expected) >= 7 and (actual.startswith(expected) or expected.startswith(actual)):
        return True
    return False


def result_columns(payload: dict, path: Path) -> dict[str, int]:
    columns = payload.get("result_columns")
    require(
        isinstance(columns, list) and all(isinstance(column, str) for column in columns),
        f"{path} has no string result_columns",
    )
    missing = [column for column in REQUIRED_RESULT_COLUMNS if column not in columns]
    require(not missing, f"{path}: result_columns lacks {', '.join(missing)}")
    return {column: index for index, column in enumerate(columns)}


def cell(row: list, column: int) -> object:
    return row[column] if column < len(row) else None


def decode_combinations(payload: dict, path: Path) -> tuple[dict[str, Combo], dict[str, list]]:
    """Return (id -> combo, benchmark name -> raw asv row)."""
    position = result_columns(payload, path)
    rows = payload.get("results")
    require(isinstance(rows, dict) and rows, f"{path} contains no results")

    combinations: dict[str, Combo] = {}
    for name, row in rows.items():
        require(isinstance(row, list), f"{path}: {name}: result row must be a list")
        params = cell(row, position["params"])
        require(isinstance(params, list), f"{path}: {name}: params must be a list")
        grids: list[list[str]] = []
        for grid in params:
            require(
                isinstance(grid, list) and grid and all(isinstance(v, str) for v in grid),
                f"{path}: {name}: every parameter grid must be a non-empty list of "
                "repr strings",
            )
            grids.append(grid)
        expected = 1
        for grid in grids:
            expected *= len(grid)
        result_cell = cell(row, position["result"])
        require(
            isinstance(result_cell, list),
            f"{path}: {name}: result must be a flat list",
        )
        require(
            len(result_cell) == expected,
            f"{path}: {name}: {len(result_cell)} result entries for {expected} "
            "parameter combination(s)",
        )
        if not grids:
            combinations[name] = Combo(name, (), (), [])
            continue
        for flat, combination in enumerate(itertools.product(*grids)):
            identifier = f"{name}({', '.join(combination)})"
            require(
                identifier not in combinations,
                f"{path} defines {identifier!r} twice",
            )
            index = tuple(grid.index(value) for grid, value in zip(grids, combination))
            combinations[identifier] = Combo(
                name, index, tuple(len(grid) for grid in grids), grids
            )
    return combinations, rows


def combo_flat(combo: Combo) -> int:
    """Row-major position of one combination in ``itertools.product(*params)``."""
    flat = 0
    for index, grid in zip(combo.index, combo.params):
        flat = flat * len(grid) + index
    return flat


def validate_environment() -> dict:
    missing = [name for name in REQUIRED_ENV if not os.environ.get(name)]
    require(not missing, f"missing environment variables: {', '.join(missing)}")
    try:
        reps = int(os.environ.get("NUMPY_REPS") or DEFAULT_REPS)
        warmups = int(os.environ.get("NUMPY_WARMUPS") or DEFAULT_WARMUPS)
    except ValueError as exc:
        raise ValidationError(f"NUMPY_REPS/NUMPY_WARMUPS must be integers: {exc}") from exc
    require(reps >= 1, "NUMPY_REPS must be at least 1")
    require(warmups >= 0, "NUMPY_WARMUPS must be non-negative")
    return {
        "reps": reps,
        "warmups": warmups,
        "baseline_commit": os.environ["NUMPY_BASELINE_COMMIT"].strip(),
        "python": normalise_python(os.environ["NUMPY_PYTHON_SHORT"]),
        "software_version": os.environ["SOFTWARE_VERSION"],
        "variant": os.environ["PERF_VARIANT"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "suite_commit": os.environ["ASV_SUITE_COMMIT"],
        "asv_version": os.environ["ASV_VERSION"],
    }


def validate_run_metadata(payload: dict, environment: dict, path: Path) -> str:
    require(
        payload.get("version") == RESULTS_API_VERSION,
        f"{path} declares asv results version {payload.get('version')!r}, "
        f"expected {RESULTS_API_VERSION}",
    )
    commit = payload.get("commit_hash")
    require(
        commit_matches(commit, environment["baseline_commit"]),
        f"results commit_hash {commit!r} does not match NUMPY_BASELINE_COMMIT "
        f"{environment['baseline_commit']!r}",
    )
    run_python = normalise_python(payload.get("python"))
    require(
        run_python == environment["python"],
        f"results python {run_python} does not match NUMPY_PYTHON_SHORT "
        f"{environment['python']}",
    )
    parameters = payload.get("params")
    require(isinstance(parameters, dict), f"{path} has no params block")
    machine = parameters.get("machine")
    require(
        isinstance(machine, str) and machine.strip(),
        f"{path}: params.machine is missing",
    )
    if parameters.get("arch") is not None:
        require(
            normalise_arch(parameters["arch"]) == normalise_arch(environment["architecture"]),
            f"results architecture {parameters['arch']!r} does not match "
            f"EXPECTED_ARCH {environment['architecture']!r}",
        )
    return machine.strip()


def extract_metric(
    identifier: str,
    combo: Combo,
    row: list,
    position: dict[str, int],
    environment: dict,
) -> tuple[dict, list[float]]:
    flat = combo_flat(combo)
    result_cell = cell(row, position["result"])
    require(
        is_finite_number(result_cell[flat]),
        f"{identifier}: asv stored no finite result (combination failed or was not "
        "selected)",
    )
    value = float(result_cell[flat])
    require(value > 0.0, f"{identifier}: non-positive result {value!r}")

    samples_cell = cell(row, position["samples"])
    require(
        isinstance(samples_cell, list) and flat < len(samples_cell),
        f"{identifier}: asv stored no sample row",
    )
    samples = samples_cell[flat]
    expected = environment["warmups"] + environment["reps"]
    require(
        isinstance(samples, list) and len(samples) == expected,
        f"{identifier}: {0 if not isinstance(samples, list) else len(samples)} "
        f"sample(s), expected {expected} (NUMPY_WARMUPS + NUMPY_REPS)",
    )
    for position_index, sample in enumerate(samples):
        require(
            is_finite_number(sample) and float(sample) > 0.0,
            f"{identifier}: sample {position_index} is not a finite positive number: "
            f"{sample!r}",
        )
    samples = [float(sample) for sample in samples]

    if "stats_repeat" in position:
        repeats = cell(row, position["stats_repeat"])
        if isinstance(repeats, list) and flat < len(repeats) and repeats[flat] is not None:
            require(
                repeats[flat] == expected,
                f"{identifier}: asv reported {repeats[flat]} repetition(s) but the "
                f"protocol requires {expected}",
            )
    if "stats_number" in position:
        numbers = cell(row, position["stats_number"])
        if isinstance(numbers, list) and flat < len(numbers) and numbers[flat] is not None:
            require(
                is_finite_number(numbers[flat]) and numbers[flat] > 0,
                f"{identifier}: asv reported an invalid iteration count "
                f"{numbers[flat]!r}",
            )

    warmups = environment["warmups"]
    warmup = samples[0] if warmups else None
    measured = samples[warmups:]
    require(
        len(measured) == environment["reps"],
        f"{identifier}: {len(measured)} measured sample(s) after dropping "
        f"{warmups} warm-up(s), expected {environment['reps']}",
    )
    median = statistics.median(measured)
    entry = {
        "source_name": identifier,
        "value": median,
        "unit": METRIC_UNIT,
        "direction": METRIC_DIRECTION,
        "group": combo.benchmark.rsplit(".", 1)[0],
        "samples": samples,
        "warmup": warmup,
        "median": median,
        "min": min(measured),
        "max": max(measured),
        "mean": statistics.fmean(measured),
    }
    require(
        math.isfinite(entry["value"]) and entry["value"] > 0.0,
        f"{identifier}: computed median is not a finite positive number",
    )
    return entry, samples


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate one numpy asv run and publish the metric document.",
        exit_on_error=False,
    )
    parser.add_argument("--results", required=True, type=Path, help="asv results JSON")
    parser.add_argument("--list", required=True, type=Path, help="benchmark id list")
    parser.add_argument("--out", required=True, type=Path, help="metric document to write")
    parser.add_argument("--samples", required=True, type=Path, help="raw sample mirror to write")
    parser.add_argument(
        "--benchmarks",
        type=Path,
        default=None,
        help="asv discovery file (accepted for compatibility, not needed anymore)",
    )
    parser.add_argument(
        "--log-summary", action="store_true", help="print a one-line evidence summary"
    )
    args = parser.parse_args(argv)
    if args.benchmarks is not None:
        print(
            f"{EVIDENCE_PREFIX}ignoring --benchmarks {args.benchmarks}: asv results "
            "JSON carries the selected parameter domain itself",
            file=sys.stderr,
        )
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    environment = validate_environment()
    payload = read_json(args.results)
    machine = validate_run_metadata(payload, environment, args.results)
    combinations, rows = decode_combinations(payload, args.results)
    identifiers = load_list(args.list)
    position = result_columns(payload, args.results)

    unresolved = [identifier for identifier in identifiers if identifier not in combinations]
    if unresolved:
        raise ValidationError(
            f"{len(unresolved)} benchmark id(s) are not covered by {args.results}: "
            + ", ".join(unresolved)
        )

    entries: dict[str, dict] = {}
    sample_cases: list[dict] = []
    seen: set[str] = set()
    for identifier in identifiers:
        require(identifier not in seen, f"duplicated metric: {identifier}")
        seen.add(identifier)
        combo = combinations[identifier]
        row = rows[combo.benchmark]
        entry, samples = extract_metric(identifier, combo, row, position, environment)
        entries[identifier] = entry
        sample_cases.append({"id": identifier, "samples": samples})

    # The Framework metric collector (framework/normalize_results.py) requires
    # `results` to be a non-empty JSON object keyed however we like; the keys are
    # the source names, insertion order preserved.
    require(bool(entries), "no metric was validated")
    require(
        len(entries) == len(identifiers),
        f"published {len(entries)} metric(s) for {len(identifiers)} requested id(s)",
    )

    document = {
        "software": "numpy",
        "version": environment["software_version"],
        "variant": environment["variant"],
        "architecture": environment["architecture"],
        "commit": payload.get("commit_hash"),
        "suite_commit": environment["suite_commit"],
        "python": environment["python"],
        "asv": environment["asv_version"],
        "machine": machine,
        "reps": environment["reps"],
        "warmups": environment["warmups"],
        "statistic": STATISTIC,
        "measured": len(entries),
        "results": entries,
    }
    samples_document = {
        "commit": payload.get("commit_hash"),
        "reps": environment["reps"],
        "warmups": environment["warmups"],
        "cases": sample_cases,
    }
    write_json(args.out, document)
    write_json(args.samples, samples_document)

    if args.log_summary:
        print(
            f"{EVIDENCE_PREFIX}parsed {len(entries)} metric(s) from "
            f"{args.results.name}: commit {str(payload.get('commit_hash'))[:12]}, "
            f"python {environment['python']}, "
            f"{environment['reps']} reps + {environment['warmups']} warm-up, "
            f"statistic {STATISTIC}, machine {machine}"
        )
    return EXIT_OK


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except ValidationError as exc:
        print(f"{EVIDENCE_PREFIX}result validation failed: {exc}", file=sys.stderr)
        raise SystemExit(EXIT_INVALID)
    except argparse.ArgumentError as exc:  # pragma: no cover - defensive
        print(f"{EVIDENCE_PREFIX}invalid arguments: {exc}", file=sys.stderr)
        raise SystemExit(EXIT_INVALID)
