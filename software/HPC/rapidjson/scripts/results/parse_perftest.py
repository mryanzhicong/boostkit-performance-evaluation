#!/usr/bin/env python3
"""Strictly parse RapidJSON perftest output into perftest_result.json.

Inputs (all produced by scripts/stages/test.sh):

  runs/<scenario>/rep<i>.log   stdout of one ``perftest`` process
  runs/<scenario>/rep<i>.err   stderr of the same process
  runs/<scenario>/rep<i>.xml   gtest XML of the same process
  fixtures/scenarios.json      canonical scenario, corpus and iteration table

Each process runs one upstream case with ``--gtest_repeat=5``; every one of the
five iterations prints one integer-millisecond summary line.  gtest rewrites the
XML on each iteration, so the XML only proves that the last iteration ran one
passing case; the metrics are computed from the five stdout lines.  The parser
never re-measures and never fills gaps: a missing or extra round, a wrong line
count, a non-positive time, a failing case or a missing file aborts the run.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path
from xml.etree import ElementTree

SUMMARY = re.compile(r"^\[==========\] 1 test from 1 test suite ran\. \((\d+) ms total\)$")
FAILED = re.compile(r"^\[  FAILED  \]")

NS_UNIT = "ns/op"
GB_UNIT = "GB/s"
LOWER = "lower_is_better"
HIGHER = "higher_is_better"
EXPECTED_SCENARIO_COUNT = 8
EXPECTED_METRIC_COUNT = 16
REQUIRED_SCENARIO_KEYS = ("name", "case", "corpus", "iterations")
REQUIRED_CORPUS_KEYS = ("path", "bytes", "sha256")


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    except json.JSONDecodeError as error:
        fail(f"invalid JSON in {path}: {error}")


def load_fixtures(path: Path) -> dict:
    data = load_json(path)
    for key in ("version", "gtest_suite", "gtest_repeat", "architecture_suffixes", "corpora", "scenarios"):
        if key not in data:
            fail(f"{path}: missing key {key}")
    repeat = data["gtest_repeat"]
    if not isinstance(repeat, int) or repeat <= 0:
        fail(f"{path}: gtest_repeat must be a positive integer")
    suffixes = data["architecture_suffixes"]
    if not isinstance(suffixes, list) or not suffixes or len(set(suffixes)) != len(suffixes):
        fail(f"{path}: architecture_suffixes must be a unique non-empty list")
    corpora = data["corpora"]
    if not isinstance(corpora, dict) or not corpora:
        fail(f"{path}: corpora must be a non-empty object")
    for name, corpus in corpora.items():
        if not isinstance(corpus, dict):
            fail(f"{path}: corpus {name} must be an object")
        for key in REQUIRED_CORPUS_KEYS:
            if key not in corpus:
                fail(f"{path}: corpus {name} is missing {key}")
        if not isinstance(corpus["bytes"], int) or corpus["bytes"] <= 0:
            fail(f"{path}: corpus {name} has an invalid byte count")
        if not isinstance(corpus["sha256"], str) or not re.fullmatch(r"[0-9a-f]{64}", corpus["sha256"]):
            fail(f"{path}: corpus {name} has an invalid sha256")
        if not isinstance(corpus["path"], str) or not corpus["path"]:
            fail(f"{path}: corpus {name} has an invalid path")
    scenarios = data["scenarios"]
    if not isinstance(scenarios, list) or len(scenarios) != EXPECTED_SCENARIO_COUNT:
        fail(f"{path}: expected {EXPECTED_SCENARIO_COUNT} scenarios, got "
             f"{len(scenarios) if isinstance(scenarios, list) else 'none'}")
    names: set[str] = set()
    cases: set[str] = set()
    for item in scenarios:
        if not isinstance(item, dict):
            fail(f"{path}: every scenario must be an object")
        for key in REQUIRED_SCENARIO_KEYS:
            if key not in item:
                fail(f"{path}: a scenario is missing {key}")
        if not isinstance(item["name"], str) or not item["name"]:
            fail(f"{path}: a scenario has an invalid name")
        if not isinstance(item["case"], str) or not item["case"]:
            fail(f"{path}: scenario {item['name']} has an invalid case name")
        if item["corpus"] not in corpora:
            fail(f"{path}: scenario {item['name']} references unknown corpus {item['corpus']}")
        if not isinstance(item["iterations"], int) or item["iterations"] <= 0:
            fail(f"{path}: scenario {item['name']} must define positive iterations")
        if item["name"] in names:
            fail(f"{path}: duplicate scenario name {item['name']}")
        if item["case"] in cases:
            fail(f"{path}: duplicate case name {item['case']}")
        names.add(item["name"])
        cases.add(item["case"])
    return data


def metric_names(fixtures: dict) -> list[str]:
    names: list[str] = []
    for item in fixtures["scenarios"]:
        names.append(f"{item['name']}_ns_per_op")
        names.append(f"{item['name']}_gb_per_s")
    if len(names) != EXPECTED_METRIC_COUNT:
        fail(f"fixtures describe {len(names)} metrics, the case contract fixes {EXPECTED_METRIC_COUNT}")
    if len(set(names)) != len(names):
        fail("fixtures produce duplicate metric names")
    return names


def parse_log(path: Path, repeat: int) -> list[int]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    values: list[int] = []
    for line in text.replace("\r", "\n").splitlines():
        stripped = line.strip()
        if FAILED.match(stripped):
            fail(f"{path}: contains a failing gtest case")
        match = SUMMARY.match(stripped)
        if match:
            values.append(int(match.group(1)))
    if len(values) != repeat:
        fail(f"{path}: found {len(values)} completed iteration(s), expected {repeat} (--gtest_repeat={repeat})")
    for value in values:
        if value <= 0:
            fail(f"{path}: non-positive iteration time {value} ms")
    return values


def parse_xml(path: Path, base_case: str, suffixes: list[str], suite: str) -> tuple[str, str]:
    """Return (architecture suffix, full testcase name) of the last iteration."""
    try:
        tree = ElementTree.parse(path)
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    except ElementTree.ParseError as error:
        fail(f"invalid XML in {path}: {error}")
    root = tree.getroot()
    if root.get("failures", "0") != "0":
        fail(f"{path}: gtest XML reports failures={root.get('failures')}")
    testcases = list(root.iter("testcase"))
    if len(testcases) != 1:
        fail(f"{path}: expected exactly one testcase, found {len(testcases)}")
    testcase = testcases[0]
    if any(child.tag in {"failure", "error"} for child in testcase):
        fail(f"{path}: the testcase reports a failure element")
    classname = testcase.get("classname")
    if classname is not None and classname != suite:
        fail(f"{path}: testcase classname {classname} is not {suite}")
    name = testcase.get("name") or ""
    for suffix in suffixes:
        full = f"{base_case}_{suffix}"
        if name == full:
            return suffix, full
    fail(f"{path}: testcase {name!r} does not match {base_case}_<{'|'.join(suffixes)}>")


def rep_indices(directory: Path, extension: str) -> set[int]:
    pattern = re.compile(rf"^rep(\d+)\.{re.escape(extension)}$")
    found: set[int] = set()
    for item in directory.iterdir():
        match = pattern.match(item.name)
        if match:
            found.add(int(match.group(1)))
    return found


def check_rounds(directory: Path, total: int) -> None:
    expected = set(range(total))
    for extension in ("log", "err", "xml"):
        found = rep_indices(directory, extension)
        if found != expected:
            fail(f"{directory}: {extension} rounds {sorted(found)} differ from expected {sorted(expected)}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Strictly parse RapidJSON perftest output")
    parser.add_argument("--runs-dir", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--fixtures", type=Path, required=True)
    parser.add_argument("--warmups", type=int, required=True)
    parser.add_argument("--reps", type=int, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--variant", default="base")
    parser.add_argument("--run-id", default="")
    args = parser.parse_args()

    if args.reps < 5:
        fail(f"--reps must be at least 5 (sampling contract), got {args.reps}")
    if args.warmups < 1:
        fail(f"--warmups must be at least 1, got {args.warmups}")
    fixtures = load_fixtures(args.fixtures)
    if fixtures["version"] != args.version:
        fail(f"fixtures are pinned to {fixtures['version']}, requested {args.version}")
    repeat = fixtures["gtest_repeat"]
    suffixes = fixtures["architecture_suffixes"]
    suite = fixtures["gtest_suite"]
    args.results_dir.mkdir(parents=True, exist_ok=True)

    scenario_names = [item["name"] for item in fixtures["scenarios"]]
    expected_names = metric_names(fixtures)
    total = args.warmups + args.reps

    if not args.runs_dir.is_dir():
        fail(f"missing runs directory: {args.runs_dir}")
    found_dirs = {entry.name for entry in args.runs_dir.iterdir() if entry.is_dir()}
    missing = sorted(set(scenario_names) - found_dirs)
    extra = sorted(found_dirs - set(scenario_names))
    if missing or extra:
        fail(f"{args.runs_dir}: scenario directories differ from fixtures (missing={missing}, unexpected={extra})")
    for scenario in scenario_names:
        check_rounds(args.runs_dir / scenario, total)

    per_rep: dict[int, dict[str, float]] = {}
    groups: dict[str, str] = {}
    suffix_by_scenario: dict[str, str] = {}
    evidence_ms: dict[str, dict[str, int]] = {}
    evidence_case: dict[str, dict[str, str]] = {}

    for rep in range(total):
        metrics: dict[str, float] = {}
        for item in fixtures["scenarios"]:
            scenario = item["name"]
            base_case = item["case"]
            corpus = fixtures["corpora"][item["corpus"]]
            log_path = args.runs_dir / scenario / f"rep{rep}.log"
            xml_path = args.runs_dir / scenario / f"rep{rep}.xml"
            ms_values = parse_log(log_path, repeat)
            suffix, full_name = parse_xml(xml_path, base_case, suffixes, suite)
            previous = suffix_by_scenario.setdefault(scenario, suffix)
            if previous != suffix:
                fail(f"{scenario}: architecture suffix changed between rounds ({previous} -> {suffix})")
            total_ms = sum(ms_values)
            ns_per_op = total_ms * 1_000_000 / (repeat * item["iterations"])
            gb_per_s = corpus["bytes"] * repeat * item["iterations"] * 1000 / (total_ms * 1_000_000_000)
            for name, value in (
                (f"{scenario}_ns_per_op", ns_per_op),
                (f"{scenario}_gb_per_s", gb_per_s),
            ):
                if name in metrics:
                    fail(f"duplicate metric produced by the parser: {name}")
                if not math.isfinite(value) or value <= 0:
                    fail(f"{scenario} rep{rep}: computed a non-positive value for {name}: {value!r}")
                metrics[name] = value
                groups[name] = scenario
            evidence_ms.setdefault(scenario, {})[f"rep{rep}"] = total_ms
            evidence_case.setdefault(scenario, {})[f"rep{rep}"] = full_name
        if set(metrics) != set(expected_names):
            fail(f"round {rep} produced an unexpected metric set")
        per_rep[rep] = metrics

    measured = [index for index in range(total) if index >= args.warmups]
    if len(measured) != args.reps:
        fail("measured round count differs from --reps")

    results: dict[str, dict] = {}
    samples: dict[str, dict] = {}
    for name in expected_names:
        values = [per_rep[index][name] for index in measured]
        unit = NS_UNIT if name.endswith("_ns_per_op") else GB_UNIT
        direction = LOWER if unit == NS_UNIT else HIGHER
        median = statistics.median(values)
        results[name] = {
            "value": round(median, 6),
            "unit": unit,
            "direction": direction,
            "group": groups[name],
        }
        samples[name] = {
            "values": [round(value, 6) for value in values],
            "median": round(median, 6),
            "min": round(min(values), 6),
            "max": round(max(values), 6),
            "samples": len(values),
        }
    if len(results) != EXPECTED_METRIC_COUNT:
        fail(f"produced {len(results)} metrics, expected {EXPECTED_METRIC_COUNT}")

    for rep in range(total):
        for scenario in scenario_names:
            selected = {
                name: round(value, 6)
                for name, value in per_rep[rep].items()
                if groups[name] == scenario
            }
            payload = {
                "scenario": scenario,
                "round": rep,
                "warmup": rep < args.warmups,
                "gtest_repeat": repeat,
                "ms_total_sum": evidence_ms[scenario][f"rep{rep}"],
                "testcase": evidence_case[scenario][f"rep{rep}"],
                "metrics": selected,
            }
            (args.runs_dir / scenario / f"rep{rep}.json").write_text(
                json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )

    output = {
        "software": "rapidjson",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "run_id": args.run_id,
        "parameters": {
            "gtest_repeat": repeat,
            "warmups": args.warmups,
            "reps": args.reps,
            "corpora": {
                name: {"path": corpus["path"], "bytes": corpus["bytes"], "sha256": corpus["sha256"]}
                for name, corpus in fixtures["corpora"].items()
            },
            "scenarios": [
                {
                    "name": item["name"],
                    "case": item["case"],
                    "corpus": item["corpus"],
                    "iterations": item["iterations"],
                }
                for item in fixtures["scenarios"]
            ],
            "metric_formula": {
                "ns_per_op": "sum_ms * 1e6 / (gtest_repeat * iterations)",
                "gb_per_s": "corpus_bytes * gtest_repeat * iterations * 1000 / (sum_ms * 1e9)",
            },
        },
        "sampling": {
            "warmups": args.warmups,
            "reps": args.reps,
            "aggregation": "median",
            "samples_per_metric": len(measured),
            "metric_count": len(results),
        },
        "results": results,
        "samples": samples,
        "evidence": {
            "gtest_repeat": repeat,
            "architecture_suffixes": suffix_by_scenario,
            "iterations": {item["name"]: item["iterations"] for item in fixtures["scenarios"]},
            "corpus_bytes": {
                item["name"]: fixtures["corpora"][item["corpus"]]["bytes"]
                for item in fixtures["scenarios"]
            },
            "ms_total_sum": evidence_ms,
            "xml_testcase": evidence_case,
        },
    }
    (args.results_dir / "perftest_result.json").write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    group_counts: dict[str, int] = {}
    for item in results.values():
        group_counts[item["group"]] = group_counts.get(item["group"], 0) + 1
    print(
        f"parsed {len(results)} metrics from {len(measured)} measured round(s): "
        + ", ".join(f"{name}={count}" for name, count in sorted(group_counts.items())),
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
