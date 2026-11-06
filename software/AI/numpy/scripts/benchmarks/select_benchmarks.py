#!/usr/bin/env python3
"""Resolve the shipped numpy benchmark-id list into exact asv selectors.

The shipped fixture ``fixtures/1200+juhe_benches.txt`` is a CRLF text file with
one benchmark id per line, stored in *regex-escaped* form (``re.escape`` was
applied to the literal id, e.g.
``bench_ufunc.NDArrayGetItem.time_methods_getitem\\(\\(-1, 0\\), 'big'\\)``).
asv selects parameterized benchmarks by searching a regular expression against
``<name>(<param0>, <param1>, ...)`` (``asv/benchmarks.py:54-65``), so this tool
turns every line back into its literal id and emits either

* ``--emit-bench-args``: one anchored ``^...$`` regex per selected id on stdout,
  ready to be handed to ``asv run -b`` (one ``-b`` per line), or
* ``--emit-expected``: the expected-metric document that the strict parser
  reconciles the asv results JSON against, or
* ``--json``: a machine-readable summary the stage shell scripts can log.

Two resolution sources are supported, both optional:

* ``--benchmarks RESULTS/benchmarks.json`` -- the full asv discovery grid.  This
  is the start-stage pre-flight check: every id must be selectable before the
  long benchmark run starts.
* ``--results FILE.json`` -- an asv results file.  Its ``result_columns``/``params``
  rows are decoded into the exact set of ``<name>(<param>, ...)`` combinations
  that file covers, which is what the run stage actually measured.  ``--require-measured``
  additionally rejects ids whose combination carries no finite result yet.

Ids are never dropped silently: an id that does not resolve to exactly one
discovered combination is a hard error.

Exit codes
----------
0   every id was emitted
1   usage or I/O error (unreadable list, malformed discovery/results file)
2   the list repeats an id
3   an id does not resolve to any discovered benchmark/parameter combination
4   two distinct ids resolve to the same combination
"""

from __future__ import annotations

import argparse
import collections
import itertools
import json
import math
import os
import re
import sys
from pathlib import Path

ESCAPE_SEQUENCE = re.compile(r"\\(.)")
DISCOVERY_API_VERSION = 2
RESULTS_API_VERSION = 2
REQUIRED_RESULT_COLUMNS = ("result", "params", "samples")

EXIT_OK = 0
EXIT_USAGE = 1
EXIT_DUPLICATE = 2
EXIT_UNRESOLVED = 3
EXIT_COLLISION = 4

Combo = collections.namedtuple("Combo", "benchmark index dims flat measured")


class CombinationCollision(RuntimeError):
    """Two distinct ids decoded to the same benchmark/combination."""

    def __init__(self, identifier: str, first: str, second: str) -> None:
        super().__init__(f"{first} == {second} ({identifier})")
        self.identifier = identifier
        self.first = first
        self.second = second


def insert_combo(combos: dict[str, Combo], identifier: str, combo: Combo) -> None:
    if identifier in combos:
        raise CombinationCollision(identifier, combos[identifier].benchmark, combo.benchmark)
    combos[identifier] = combo


def literal_id(line: str) -> str:
    """Undo ``re.escape`` on one list line."""
    return ESCAPE_SEQUENCE.sub(r"\1", line.strip())


def exact_regex(identifier: str) -> str:
    """Anchored regex matching exactly one asv benchmark combination."""
    return "^" + re.escape(identifier) + "$"


def load_list(path: Path) -> tuple[list[str], int]:
    """Return (ids, blank_line_count), stripping CRLF and blank lines."""
    try:
        text = path.read_bytes().decode("utf-8")
    except FileNotFoundError as exc:
        raise SystemExit(f"{sys.argv[0]}: ERROR: missing list file: {path}") from exc
    except UnicodeDecodeError as exc:
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path} is not UTF-8: {exc}") from exc
    identifiers: list[str] = []
    blank = 0
    for line in text.splitlines():
        if not line.strip():
            blank += 1
            continue
        identifiers.append(literal_id(line))
    if not identifiers:
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path} contains no benchmark ids")
    return identifiers, blank


def read_json_object(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"{sys.argv[0]}: ERROR: missing file: {path}") from exc
    except json.JSONDecodeError as exc:
        raise SystemExit(f"{sys.argv[0]}: ERROR: invalid JSON in {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path} is not a JSON object")
    return payload


def validate_param_grids(name: str, params: object, where: Path) -> list[list[str]]:
    if not isinstance(params, list):
        raise SystemExit(f"{sys.argv[0]}: ERROR: {where}: {name}: params must be a list")
    grids: list[list[str]] = []
    for grid in params:
        if not isinstance(grid, list) or not grid or not all(
            isinstance(value, str) for value in grid
        ):
            raise SystemExit(
                f"{sys.argv[0]}: ERROR: {where}: {name}: every parameter grid must "
                "be a non-empty list of repr strings"
            )
        grids.append(grid)
    return grids


def combos_from_grids(
    name: str, grids: list[list[str]], measured: bool
) -> dict[str, Combo]:
    combos: dict[str, Combo] = {}
    if not grids:
        insert_combo(combos, name, Combo(name, (), (), 0, measured))
        return combos
    dims = tuple(len(grid) for grid in grids)
    for flat, combination in enumerate(itertools.product(*grids)):
        identifier = f"{name}({', '.join(combination)})"
        index = tuple(
            grids[position].index(value) for position, value in enumerate(combination)
        )
        insert_combo(combos, identifier, Combo(name, index, dims, flat, measured))
    return combos


def load_discovery_combos(path: Path) -> dict[str, Combo]:
    """Full asv discovery grid: every selectable combination (nothing measured yet)."""
    payload = read_json_object(path)
    version = payload.get("version")
    if version != DISCOVERY_API_VERSION:
        raise SystemExit(
            f"{sys.argv[0]}: ERROR: {path} declares asv discovery version "
            f"{version!r}, expected {DISCOVERY_API_VERSION}"
        )
    entries = {name: meta for name, meta in payload.items() if name != "version"}
    if not entries:
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path} does not describe any benchmark")
    combos: dict[str, Combo] = {}
    for name, meta in entries.items():
        if not isinstance(meta, dict):
            raise SystemExit(f"{sys.argv[0]}: ERROR: {name}: metadata must be an object")
        grids = validate_param_grids(name, meta.get("params"), path)
        param_names = meta.get("param_names")
        if not isinstance(param_names, list) or len(param_names) != len(grids):
            raise SystemExit(
                f"{sys.argv[0]}: ERROR: {name}: {len(grids)} parameter grid(s) but "
                f"{param_names!r} parameter names"
            )
        for identifier, combo in combos_from_grids(name, grids, measured=False).items():
            insert_combo(combos, identifier, combo)
    return combos


def result_row_value(row: list, column: int, name: str, path: Path) -> object:
    if not isinstance(row, list):
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path}: {name}: row must be a list")
    return row[column] if column < len(row) else None


def load_results_combos(path: Path) -> dict[str, Combo]:
    """Combinations covered by one asv results file, decoded row-major.

    asv stores, per benchmark, the full parameter domain in the ``params``
    column but only a flat ``result``/``samples`` row-major list: unselected or
    failed combinations are ``NaN``/``null`` at their product position.  The
    decoded id is ``name`` alone for zero-parameter benchmarks and
    ``name(value0, value1, ...)`` with the stored repr strings verbatim
    otherwise.
    """
    payload = read_json_object(path)
    version = payload.get("version")
    if version != RESULTS_API_VERSION:
        raise SystemExit(
            f"{sys.argv[0]}: ERROR: {path} declares asv results version "
            f"{version!r}, expected {RESULTS_API_VERSION}"
        )
    columns = payload.get("result_columns")
    if not isinstance(columns, list) or not all(isinstance(c, str) for c in columns):
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path}: missing result_columns")
    missing = [column for column in REQUIRED_RESULT_COLUMNS if column not in columns]
    if missing:
        raise SystemExit(
            f"{sys.argv[0]}: ERROR: {path}: result_columns lacks {', '.join(missing)}"
        )
    position = {column: index for index, column in enumerate(columns)}
    rows = payload.get("results")
    if not isinstance(rows, dict) or not rows:
        raise SystemExit(f"{sys.argv[0]}: ERROR: {path} contains no results")

    combos: dict[str, Combo] = {}
    for name, row in rows.items():
        grids = validate_param_grids(
            name, result_row_value(row, position["params"], name, path), path
        )
        result_cell = result_row_value(row, position["result"], name, path)
        if not isinstance(result_cell, list):
            raise SystemExit(
                f"{sys.argv[0]}: ERROR: {path}: {name}: result must be a flat list"
            )
        expected = 1
        for grid in grids:
            expected *= len(grid)
        if len(result_cell) != expected:
            raise SystemExit(
                f"{sys.argv[0]}: ERROR: {path}: {name}: {len(result_cell)} result "
                f"entries for {expected} parameter combination(s)"
            )
        measured_flags = [
            isinstance(value, (int, float))
            and not isinstance(value, bool)
            and math.isfinite(value)
            for value in result_cell
        ]
        if not grids:
            insert_combo(combos, name, Combo(name, (), (), 0, measured_flags[0]))
            continue
        dims = tuple(len(grid) for grid in grids)
        for flat, combination in enumerate(itertools.product(*grids)):
            identifier = f"{name}({', '.join(combination)})"
            index = tuple(
                grids[position_].index(value) for position_, value in enumerate(combination)
            )
            insert_combo(
                combos, identifier, Combo(name, index, dims, flat, measured_flags[flat])
            )
    return combos


def duplicate_ids(identifiers: list[str]) -> list[str]:
    counts = collections.Counter(identifiers)
    return [identifier for identifier, count in counts.items() if count > 1]


def collisions(identifiers: list[str], combos: dict[str, Combo]) -> list[list[str]]:
    by_combo: dict[tuple[str, int], list[str]] = collections.defaultdict(list)
    for identifier in identifiers:
        combo = combos[identifier]
        by_combo[(combo.benchmark, combo.flat)].append(identifier)
    return [ids for ids in by_combo.values() if len(ids) > 1]


def emit_entries(identifiers: list[str], combos: dict[str, Combo] | None) -> list[dict]:
    entries = []
    for identifier in identifiers:
        combo = combos[identifier] if combos is not None else None
        entries.append(
            {
                "id": identifier,
                "benchmark": combo.benchmark if combo else None,
                "index": list(combo.index) if combo else None,
                "regex": exact_regex(identifier),
            }
        )
    return entries


def write_expected(path: Path, entries: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    document = {"entries": entries}
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Resolve the numpy benchmark-id list into exact asv selectors."
    )
    parser.add_argument("--list", required=True, type=Path, help="benchmark id list (CRLF ok)")
    source = parser.add_mutually_exclusive_group()
    source.add_argument(
        "--benchmarks",
        type=Path,
        default=None,
        help="discovered asv benchmarks.json used to resolve every id",
    )
    source.add_argument(
        "--results",
        type=Path,
        default=None,
        help="asv results JSON whose covered combination set every id must resolve to",
    )
    parser.add_argument(
        "--require-measured",
        action="store_true",
        help="with --results, also require a finite result value for every id",
    )
    parser.add_argument(
        "--emit-bench-args",
        action="store_true",
        help="print one anchored regex per resolved id (only output on stdout)",
    )
    parser.add_argument(
        "--emit-expected",
        type=Path,
        default=None,
        help="write the expected-metric document the parser reconciles",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_summary",
        help="print a machine-readable summary instead of the human one",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    identifiers, blank = load_list(args.list)
    if args.require_measured and args.results is None:
        print(f"{sys.argv[0]}: ERROR: --require-measured needs --results", file=sys.stderr)
        return EXIT_USAGE

    duplicates = duplicate_ids(identifiers)
    if duplicates:
        print(
            f"{sys.argv[0]}: ERROR: the list repeats {len(duplicates)} benchmark id(s):",
            file=sys.stderr,
        )
        for identifier in duplicates:
            print(f"  {identifier}", file=sys.stderr)
        return EXIT_DUPLICATE

    combos: dict[str, Combo] | None = None
    source_kind = "none"
    discovered_benchmarks = 0
    measured_count: int | None = None
    try:
        if args.benchmarks is not None:
            source_kind = "benchmarks"
            combos = load_discovery_combos(args.benchmarks)
        elif args.results is not None:
            source_kind = "results"
            combos = load_results_combos(args.results)
    except CombinationCollision as exc:
        print(
            f"{sys.argv[0]}: ERROR: two ids resolve to the same combination: "
            f"{exc.identifier} ({exc.first} == {exc.second})",
            file=sys.stderr,
        )
        return EXIT_COLLISION
    if combos is not None:
        discovered_benchmarks = len({combo.benchmark for combo in combos.values()})
        if source_kind == "results":
            measured_count = sum(1 for combo in combos.values() if combo.measured)

    unresolved: list[str] = []
    if combos is not None:
        unresolved = [identifier for identifier in identifiers if identifier not in combos]
        if unresolved:
            print(
                f"{sys.argv[0]}: ERROR: {len(unresolved)} benchmark id(s) do not "
                f"resolve to a combination covered by {args.benchmarks or args.results}:",
                file=sys.stderr,
            )
            for identifier in unresolved:
                print(f"  {identifier}", file=sys.stderr)
            return EXIT_UNRESOLVED
        if args.require_measured:
            unmeasured = [
                identifier for identifier in identifiers if not combos[identifier].measured
            ]
            if unmeasured:
                print(
                    f"{sys.argv[0]}: ERROR: {len(unmeasured)} benchmark id(s) have no "
                    "finite result value in the given results file:",
                    file=sys.stderr,
                )
                for identifier in unmeasured:
                    print(f"  {identifier}", file=sys.stderr)
                return EXIT_UNRESOLVED
        colliding = collisions(identifiers, combos)
        if colliding:
            print(
                f"{sys.argv[0]}: ERROR: {len(colliding)} pair(s) of ids resolve to "
                "the same combination:",
                file=sys.stderr,
            )
            for group in colliding:
                print(f"  {' == '.join(group)}", file=sys.stderr)
            return EXIT_COLLISION

    entries = emit_entries(identifiers, combos)

    if args.emit_bench_args:
        try:
            sys.stdout.write("".join(entry["regex"] + "\n" for entry in entries))
            sys.stdout.flush()
        except BrokenPipeError:  # e.g. `| head`, keep stdout quiet at shutdown
            devnull = os.open(os.devnull, os.O_WRONLY)
            os.dup2(devnull, sys.stdout.fileno())
            return EXIT_OK

    if args.emit_expected is not None:
        write_expected(args.emit_expected, entries)
        print(
            f"{sys.argv[0]}: wrote {len(entries)} expected metric(s) to {args.emit_expected}",
            file=sys.stderr,
        )

    summary = {
        "list": str(args.list),
        "source": source_kind,
        "ids": len(identifiers),
        "unique_ids": len(set(identifiers)),
        "blank_lines": blank,
        "duplicates": 0,
        "discovered_benchmarks": discovered_benchmarks,
        "discovered_combos": len(combos) if combos is not None else None,
        "measured_combos": measured_count,
        "resolved": len(entries) if combos is not None else 0,
        "unresolved": 0,
        "collisions": 0,
        "expected": str(args.emit_expected) if args.emit_expected is not None else None,
    }
    if args.json_summary:
        stream = sys.stdout
        if args.emit_bench_args:
            sys.stderr.write(
                f"{sys.argv[0]}: WARNING: --json with --emit-bench-args writes the "
                "summary to stderr to keep stdout a pure regex list\n"
            )
            stream = sys.stderr
        stream.write(json.dumps(summary, indent=2) + "\n")
    elif not args.emit_bench_args:
        print(
            f"{sys.argv[0]}: {len(entries)} benchmark id(s) "
            f"({blank} blank line(s) skipped, {len(set(identifiers))} unique)"
        )
        if combos is not None:
            print(
                f"{sys.argv[0]}: resolved every id against {discovered_benchmarks} "
                f"benchmark(s) covering {len(combos)} combination(s)"
            )
    return EXIT_OK


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except BrokenPipeError:  # pragma: no cover - piping into head in a shell
        raise SystemExit(EXIT_OK)
