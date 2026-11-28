#!/usr/bin/env python3
"""Strictly parse `openssl speed -mr` outputs into speed_result.json.

Inputs (all produced by scripts/stages/test.sh):
  runs/<scenario>/rep<i>.log   machine readable (`-mr`) rows of one measured run

The parser never re-measures and never fills gaps: a missing round, a missing or
duplicated machine readable row, a header that does not match the pinned
workload, or a throughput that contradicts the reported op count aborts the run.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path

MACHINE_LINE = re.compile(r"^\+(?P<token>[A-Z]+)(?P<index>\d*):(?P<rest>.*)$")
EXPECTED_METRIC_COUNT = 16
CONSISTENCY_TOLERANCE = 0.01


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
    for key in ("seconds", "block_bytes", "scenarios"):
        if key not in data:
            fail(f"{path}: missing key {key}")
    scenarios = data["scenarios"]
    if not isinstance(scenarios, list) or len(scenarios) != 8:
        fail(f"{path}: expected the 8 pinned scenarios, found {len(scenarios)!r}")
    names = [scenario.get("name") for scenario in scenarios]
    if len(set(names)) != len(names):
        fail(f"{path}: duplicate scenario names")
    metric_names: list[str] = []
    for scenario in scenarios:
        metrics = scenario.get("metrics") or {}
        kind = scenario.get("kind")
        if kind == "symmetric":
            keys = ("bytes_per_s", "ops_per_s")
        elif kind == "signature":
            keys = ("sign", "verify")
        else:
            fail(f"{path}: scenario {scenario.get('name')} has unsupported kind {kind!r}")
        for key in keys:
            if not metrics.get(key):
                fail(f"{path}: scenario {scenario['name']} is missing metrics.{key}")
            metric_names.append(metrics[key])
    if len(metric_names) != EXPECTED_METRIC_COUNT or len(set(metric_names)) != len(metric_names):
        fail(f"{path}: scenarios do not describe {EXPECTED_METRIC_COUNT} unique metrics")
    return data


def checked_positive(where: str, value) -> float:
    try:
        number = float(value)
    except (TypeError, ValueError):
        fail(f"{where}: expected a number, got {value!r}")
    if not math.isfinite(number) or number <= 0:
        fail(f"{where}: expected a finite positive number, got {value!r}")
    return number


def checked_count(where: str, value: str) -> float:
    if not re.fullmatch(r"[0-9]+", value):
        fail(f"{where}: expected an integer op count, got {value!r}")
    number = float(value)
    if number <= 0:
        fail(f"{where}: expected a positive op count, got {value!r}")
    return number


def read_records(path: Path) -> list[dict]:
    """Split the machine readable output into one record per `+` line.

    `openssl speed -mr` writes the per-block headers and op counts to stderr and
    the throughput rows to stdout, so both durable sample files are required and
    read together.
    """
    stderr_path = path.with_suffix(".err")
    if not path.is_file():
        fail(f"missing sample log: {path}")
    if not stderr_path.is_file():
        fail(f"missing sample stderr log: {stderr_path}")
    try:
        text = (stderr_path.read_text(encoding="utf-8", errors="replace")
                + "\n" + path.read_text(encoding="utf-8", errors="replace"))
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    records: list[dict] = []
    for raw in text.replace("\r", "\n").splitlines():
        line = raw.strip()
        if not line:
            continue
        if not line.startswith("+"):
            # `openssl speed` without -mr prints a human table; a stray line here
            # means the wrong command was recorded, but only `+` lines carry
            # measurements, so informational lines are ignored on purpose.
            continue
        match = MACHINE_LINE.match(line)
        if not match:
            fail(f"{path}: unrecognised machine readable line: {line!r}")
        token = match.group("token")
        if token not in {"DT", "DTP", "R", "H", "F"}:
            fail(f"{path}: unrecognised machine readable row: {line!r}")
        index = match.group("index")
        rest = match.group("rest")
        fields = rest.split(":") if rest != "" else []
        record = {
            "token": token,
            "index": int(index) if index else None,
            "fields": fields,
            "line": line,
        }
        if token == "F":
            if record["index"] is None:
                if not fields or not fields[0].isdigit():
                    fail(f"{path}: malformed +F row index: {line!r}")
                record["f_index"] = int(fields[0])
                record["values"] = fields[1:]
            else:
                record["f_index"] = record["index"]
                record["values"] = fields
        records.append(record)
    if not records:
        fail(f"{path}: no machine readable (+...) rows were recorded")
    return records


def paired_rate(records: list[dict], position: int, path: Path, label: str) -> dict:
    if position + 1 >= len(records):
        fail(f"{path}: {label} header is not followed by a +R rate row")
    follower = records[position + 1]
    if follower["token"] != "R" or len(follower["fields"]) != 3:
        fail(f"{path}: {label} header is not followed by a +R rate row")
    return follower


def parse_symmetric(path: Path, scenario: dict, seconds: int, block_bytes: int) -> dict:
    records = read_records(path)
    mr_name = scenario["mr_name"]
    expected_dt = [mr_name, str(seconds), str(block_bytes)]

    headers = [position for position, record in enumerate(records)
               if record["token"] == "DT" and record["fields"][:1] == [mr_name]]
    if len(headers) != 1:
        fail(f"{path}: expected exactly one +DT:{mr_name} header, found {len(headers)}")
    position = headers[0]
    if records[position]["fields"] != expected_dt:
        fail(f"{path}: +DT header is {records[position]['fields']}, expected {expected_dt}")

    rate = paired_rate(records, position, path, f"+DT:{mr_name}")
    count = checked_count(f"{path}: +R op count", rate["fields"][0])
    if rate["fields"][1] != mr_name:
        fail(f"{path}: +R algorithm {rate['fields'][1]!r} differs from {mr_name!r}")
    rate_seconds = checked_positive(f"{path}: +R seconds", rate["fields"][2])

    block_headers = [record for record in records if record["token"] == "H"]
    if len(block_headers) != 1 or block_headers[0]["fields"] != [str(block_bytes)]:
        fail(f"{path}: expected exactly one +H:{block_bytes} row, found "
             f"{[record['line'] for record in block_headers]}")

    f_index = int(scenario["f_index"])
    throughput_rows = [record for record in records
                       if record["token"] == "F" and record.get("f_index") == f_index]
    if len(throughput_rows) != 1:
        fail(f"{path}: expected exactly one +F{f_index} row for {mr_name}, "
             f"found {len(throughput_rows)}")
    values = throughput_rows[0]["values"]
    if len(values) != 2 or values[0] != mr_name:
        fail(f"{path}: +F row {throughput_rows[0]['line']!r} is not the single-block "
             f"{mr_name} row the fixture pins")
    bytes_per_s = checked_positive(f"{path}: {mr_name} bytes/s", values[1])

    ops_per_s = count / rate_seconds
    expected_bytes = block_bytes * ops_per_s
    if abs(bytes_per_s - expected_bytes) / bytes_per_s > CONSISTENCY_TOLERANCE:
        fail(f"{path}: {mr_name} throughput {bytes_per_s} B/s contradicts "
             f"{count} ops in {rate_seconds} s ({expected_bytes:.2f} B/s expected)")

    return {
        "metrics": {
            scenario["metrics"]["bytes_per_s"]: bytes_per_s,
            scenario["metrics"]["ops_per_s"]: ops_per_s,
        },
        "evidence": {
            "block_bytes": block_bytes,
            "rate_count": count,
            "rate_seconds": rate_seconds,
            "bytes_per_s": bytes_per_s,
        },
    }


def parse_signature(path: Path, scenario: dict, seconds: int) -> dict:
    records = read_records(path)
    dtp = scenario["dtp"]
    f_spec = scenario["f"]
    dtp_header = [str(item) for item in dtp["header"]]
    dtp_name = dtp.get("name")
    expected_rate_name = dtp_name if dtp_name else dtp_header[-1]

    rates: dict[str, dict] = {}
    for role in ("sign", "verify"):
        expected = dtp_header + [dtp[role]] + ([dtp_name] if dtp_name else []) + [str(seconds)]
        matches = [position for position, record in enumerate(records)
                   if record["token"] == "DTP" and record["fields"] == expected]
        if len(matches) != 1:
            fail(f"{path}: expected exactly one +DTP:{':'.join(expected)} header, "
                 f"found {len(matches)}")
        position = matches[0]
        rate = paired_rate(records, position, path, f"+DTP:{':'.join(expected)}")
        if rate["fields"][1] != expected_rate_name:
            fail(f"{path}: +R algorithm {rate['fields'][1]!r} differs from "
                 f"{expected_rate_name!r}")
        rates[role] = {
            "count": checked_count(f"{path}: +R {role} op count", rate["fields"][0]),
            "seconds": checked_positive(f"{path}: +R {role} seconds", rate["fields"][2]),
            "row": rate["line"],
        }

    f_index = int(f_spec["index"])
    f_header = [str(item) for item in f_spec["header"]]
    throughput_rows = [record for record in records
                       if record["token"] == "F" and record.get("f_index") == f_index]
    if len(throughput_rows) != 1:
        fail(f"{path}: expected exactly one +F{f_index} row, found {len(throughput_rows)}")
    values = throughput_rows[0]["values"]
    if values[:len(f_header)] != f_header:
        fail(f"{path}: +F{f_index} row {throughput_rows[0]['line']!r} does not start with "
             f"the expected {f_header} header")
    sign_index = int(f_spec["sign_index"])
    verify_index = int(f_spec["verify_index"])
    if max(sign_index, verify_index) >= len(values):
        fail(f"{path}: +F{f_index} row {throughput_rows[0]['line']!r} has too few columns")
    if len(values) != max(sign_index, verify_index) + 1:
        fail(f"{path}: +F{f_index} row {throughput_rows[0]['line']!r} has unexpected "
             f"extra columns")
    reported = {
        "sign": checked_positive(f"{path}: sign/s", values[sign_index]),
        "verify": checked_positive(f"{path}: verify/s", values[verify_index]),
    }

    for role in ("sign", "verify"):
        rate = rates[role]
        derived = rate["count"] / rate["seconds"]
        if abs(reported[role] - derived) / reported[role] > CONSISTENCY_TOLERANCE:
            fail(f"{path}: {scenario['name']} {role}/s {reported[role]} contradicts "
                 f"{rate['count']} ops in {rate['seconds']} s ({derived:.2f}/s expected)")

    return {
        "metrics": {
            scenario["metrics"]["sign"]: reported["sign"],
            scenario["metrics"]["verify"]: reported["verify"],
        },
        "evidence": {
            "sign_count": rates["sign"]["count"],
            "sign_seconds": rates["sign"]["seconds"],
            "sign_per_s": reported["sign"],
            "verify_count": rates["verify"]["count"],
            "verify_seconds": rates["verify"]["seconds"],
            "verify_per_s": reported["verify"],
        },
    }


def parse_round(runs_dir: Path, scenarios: list[dict], index: int,
                seconds: int, block_bytes: int) -> dict[str, dict]:
    parsed: dict[str, dict] = {}
    for scenario in scenarios:
        path = runs_dir / scenario["name"] / f"rep{index}.log"
        if scenario["kind"] == "symmetric":
            result = parse_symmetric(path, scenario, seconds, block_bytes)
        else:
            result = parse_signature(path, scenario, seconds)
        parsed[scenario["name"]] = result
    return parsed


def collect_rounds(runs_dir: Path, scenarios: list[dict], total: int) -> None:
    expected = set(range(total))
    for scenario in scenarios:
        directory = runs_dir / scenario["name"]
        if not directory.is_dir():
            fail(f"missing sample directory: {directory}")
        found = set()
        for item in directory.iterdir():
            match = re.fullmatch(r"rep(\d+)\.log", item.name)
            if match:
                found.add(int(match.group(1)))
        if found != expected:
            fail(f"{directory}: sample rounds {sorted(found)} differ from expected "
                 f"{sorted(expected)}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Strictly parse openssl speed -mr outputs")
    parser.add_argument("--runs-dir", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    default_fixtures = Path(__file__).resolve().parents[2] / "fixtures" / "scenarios.json"
    parser.add_argument("--fixtures", type=Path, default=default_fixtures)
    parser.add_argument("--warmups", type=int, default=None,
                        help="warmup rounds before the measured ones (default: fixtures)")
    parser.add_argument("--reps", type=int, default=None,
                        help="measured rounds (default: fixtures)")
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--variant", default="base")
    parser.add_argument("--run-id", default="")
    args = parser.parse_args()

    fixtures = load_fixtures(args.fixtures)
    if args.warmups is None:
        args.warmups = int(fixtures.get("warmups", 1))
    if args.reps is None:
        args.reps = int(fixtures.get("reps", 5))
    if args.reps < 1:
        fail("--reps must be positive")
    if args.warmups < 0:
        fail("--warmups must not be negative")

    scenarios = fixtures["scenarios"]
    seconds = int(fixtures["seconds"])
    block_bytes = int(fixtures["block_bytes"])
    args.results_dir.mkdir(parents=True, exist_ok=True)
    total = args.warmups + args.reps
    collect_rounds(args.runs_dir, scenarios, total)

    per_round: dict[int, dict[str, dict]] = {}
    for index in range(total):
        per_round[index] = parse_round(args.runs_dir, scenarios, index, seconds, block_bytes)

    measured = [index for index in range(total) if index >= args.warmups]
    if len(measured) != args.reps:
        fail("measured round count differs from --reps")

    results: dict[str, dict] = {}
    samples: dict[str, dict] = {}
    evidence: dict[str, dict] = {}
    for scenario in scenarios:
        group = scenario["name"]
        evidence[group] = {}
        for index in range(total):
            evidence[group][f"rep{index}"] = per_round[index][group]["evidence"]
        for key, metric_name in scenario["metrics"].items():
            unit = "B/s" if key == "bytes_per_s" else "op/s"
            values = [per_round[index][group]["metrics"][metric_name] for index in measured]
            median = statistics.median(values)
            results[metric_name] = {
                "value": round(median, 6),
                "unit": unit,
                "direction": "higher_is_better",
                "group": group,
            }
            samples[metric_name] = {
                "values": [round(value, 6) for value in values],
                "median": round(median, 6),
                "min": round(min(values), 6),
                "max": round(max(values), 6),
                "samples": len(values),
            }
    if len(results) != EXPECTED_METRIC_COUNT:
        fail(f"produced {len(results)} metrics, expected {EXPECTED_METRIC_COUNT}")

    for index in range(total):
        for scenario in scenarios:
            name = scenario["name"]
            payload = {
                "scenario": name,
                "round": index,
                "warmup": index < args.warmups,
                "metrics": {metric: round(value, 6)
                            for metric, value in per_round[index][name]["metrics"].items()},
                "evidence": per_round[index][name]["evidence"],
            }
            (args.runs_dir / name / f"rep{index}.json").write_text(
                json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    output = {
        "software": "openssl",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "run_id": args.run_id,
        "parameters": {
            "seconds": seconds,
            "block_bytes": block_bytes,
            "warmups": args.warmups,
            "reps": args.reps,
            "scenarios": [
                {
                    "name": scenario["name"],
                    "kind": scenario["kind"],
                    "args": scenario["args"],
                    "description": scenario.get("description", ""),
                }
                for scenario in scenarios
            ],
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
        "evidence": evidence,
    }
    (args.results_dir / "speed_result.json").write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    groups: dict[str, int] = {}
    for item in results.values():
        groups[item["group"]] = groups.get(item["group"], 0) + 1
    print(f"parsed {len(results)} metrics from {len(measured)} measured round(s): "
          + ", ".join(f"{name}={count}" for name, count in sorted(groups.items())),
          file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
