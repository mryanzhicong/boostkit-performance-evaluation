#!/usr/bin/env python3
"""Strict parser for the fixed, unmodified 103-query Spark SQL workload."""
from __future__ import annotations
import hashlib
import math
from pathlib import Path
import re
import statistics

QUERY_RE = re.compile(r"q([1-9][0-9]?)([ab]?)\.sql$")
TIME_RE = re.compile(r"Time taken:\s*([0-9]+(?:\.[0-9]+)?)\s+seconds(?:,\s*Fetched\s+([0-9]+)\s+row\(s\))?")
ERROR_RE = re.compile(r"Error in query|FAILED:|ParseException|AnalysisException|"
                      r"Exception in thread|OutOfMemoryError|Application .* (?:FAILED|KILLED)|"
                      r"SparkException:|SQLSTATE:", re.I)

def query_key(name: str) -> tuple[int, str]:
    match = QUERY_RE.fullmatch(name)
    if not match:
        raise ValueError(f"Unexpected query name: {name}")
    return int(match[1]), match[2]

def query_names() -> list[str]:
    split = {14, 23, 24, 39}
    return [f"q{n}{s}.sql" for n in range(1, 100)
            for s in (("a", "b") if n in split else ("",))]

def verify_queries(root: Path, manifest: dict[str, str]) -> list[str]:
    expected = set(query_names())
    if set(manifest) != expected or {p.name for p in root.glob("*.sql")} != expected:
        raise ValueError("Expected exactly 103 queries, including all four a/b pairs")
    for name, digest in manifest.items():
        if hashlib.sha256((root / name).read_bytes()).hexdigest() != digest:
            raise ValueError(f"Query checksum mismatch: {name}")
    return sorted(expected, key=query_key)

def parse_log(text: str, exit_code: int) -> tuple[float, int]:
    if exit_code != 0 or ERROR_RE.search(text):
        raise ValueError(f"Spark query failed (exit {exit_code})")
    times = TIME_RE.findall(text)
    if len(times) != 1:
        raise ValueError("Expected exactly one completed query timing")
    seconds = float(times[0][0])
    if not math.isfinite(seconds) or seconds <= 0:
        raise ValueError("Invalid query timing")
    # Spark SQL CLI omits the Fetched suffix when zero rows were returned.
    return seconds, int(times[0][1] or 0)

def summarize(records: list[dict], manifest: dict, runtime: dict) -> dict:
    expected = set(query_names())
    groups: dict[str, dict[int, dict]] = {q: {} for q in expected}
    for row in records:
        name, round_id = row["query"], row["round"]
        if name not in groups or type(round_id) is not int or round_id not in range(4):
            raise ValueError("Unexpected query or round")
        if round_id in groups[name]:
            raise ValueError("Duplicate query/round")
        if row["status"] != "passed" or row["exit_code"] != 0:
            raise ValueError("Failed query in measurement set")
        value = row["query_time_seconds"]
        if type(value) not in (int, float) or not math.isfinite(value) or value <= 0:
            raise ValueError("Invalid measurement")
        if row.get("phase") != ("warmup" if round_id == 0 else "measurement"):
            raise ValueError("Round/phase mismatch")
        if type(row.get("row_count")) is not int or row["row_count"] < 0:
            raise ValueError("Missing result row count")
        groups[name][round_id] = row
    if any(set(rows) != set(range(4)) for rows in groups.values()):
        raise ValueError("Incomplete 412-execution workload")
    metrics = {}
    for name in sorted(expected, key=query_key):
        samples = [groups[name][r]["query_time_seconds"] for r in (1, 2, 3)]
        metrics[f"{name[:-4]}/query_time"] = {
            "value": statistics.median(samples), "unit": "s", "direction": "lower_is_better",
            "group": f"TPC-DS SF{runtime.get('scale_factor', 100)} / {runtime.get('software', 'spark')} / ORC", "samples": samples,
            "warmup_seconds": groups[name][0]["query_time_seconds"],
            "row_counts": [groups[name][r]["row_count"] for r in range(4)],
        }
    return {"software": runtime.get("software", "spark"), "version": runtime.get("version", "3.5.2"), "results": metrics,
            "parameters": {"scale_factor": runtime.get("scale_factor", 100), "format": "orc", "schema": "decimal",
                           "query_count": 103, "warmup_rounds": 1, "measurement_rounds": 3,
                           "query_manifest": manifest, "resource_profile": runtime["resource_profile"],
                           "spark_conf": runtime["spark_conf"], "variant": "base"},
            "runtime_context": runtime}
