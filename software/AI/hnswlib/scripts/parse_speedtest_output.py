#!/usr/bin/env python3
"""Convert official hnswlib ``tests/python/speedtest.py`` stdout to JSON.

The official script prints three query measurements followed by this summary:

``np.mean(times), np.median(times), np.std(times), construction_time, recall, name``

Those expressions and variable names are retained verbatim as report metric
names. The adapter only maps the positional official summary to JSON.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path
from typing import Any

OFFICIAL_SCRIPT_SHA256 = (
    "18f03fca047d2e649adacbcc7b030b5e55d465a920a7a949e8114d23ec26b20b"
)
OFFICIAL_NAME = "hnswlib"
QUERY_REPETITIONS = 3
QUERY_LINE_RE = re.compile(
    r"^([0-9]+(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?) seconds, "
    r"recall= ([0-9]+(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)$"
)


def finite_float(text: str, field: str, *, positive: bool = False) -> float:
    try:
        value = float(text)
    except ValueError as exc:
        raise ValueError(f"{field} is not numeric: {text!r}") from exc
    if not math.isfinite(value):
        raise ValueError(f"{field} must be finite")
    if positive and value <= 0.0:
        raise ValueError(f"{field} must be greater than zero")
    return value


def parse_query_line(line: str, line_number: int) -> tuple[float, float]:
    match = QUERY_LINE_RE.fullmatch(line)
    if match is None:
        raise ValueError(
            f"unrecognised official speedtest query line {line_number}: {line!r}"
        )
    seconds = finite_float(match.group(1), "tt", positive=True)
    recall = finite_float(match.group(2), "recall")
    if not 0.0 <= recall <= 1.0:
        raise ValueError(f"recall must be between zero and one: {recall}")
    return seconds, recall


def parse_summary(line: str) -> tuple[dict[str, float], str]:
    fields = [field.strip() for field in line.split(",")]
    if len(fields) != 6:
        raise ValueError(
            "official speedtest summary must contain exactly six comma-separated fields"
        )
    name = fields[5]
    if name != OFFICIAL_NAME:
        raise ValueError(
            f"official speedtest summary name must be {OFFICIAL_NAME!r}, got {name!r}"
        )
    values = {
        "mean": finite_float(fields[0], "np.mean(times)", positive=True),
        "median": finite_float(fields[1], "np.median(times)", positive=True),
        "std": finite_float(fields[2], "np.std(times)"),
        "construction_time": finite_float(
            fields[3], "construction_time", positive=True
        ),
        "recall": finite_float(fields[4], "recall"),
    }
    if values["std"] < 0.0:
        raise ValueError("np.std(times) must not be negative")
    if not 0.0 <= values["recall"] <= 1.0:
        raise ValueError("summary recall must be between zero and one")
    return values, name


def close_enough(actual: float, expected: float) -> bool:
    return math.isclose(actual, expected, rel_tol=1e-12, abs_tol=1e-15)


def validate_summary(
    query_seconds: list[float],
    query_recalls: list[float],
    summary: dict[str, float],
) -> None:
    sorted_seconds = sorted(query_seconds)
    mean = sum(query_seconds) / len(query_seconds)
    median = sorted_seconds[len(sorted_seconds) // 2]
    variance = sum((value - mean) ** 2 for value in query_seconds) / len(query_seconds)
    expected = {
        "mean": mean,
        "median": median,
        "std": math.sqrt(variance),
        "recall": query_recalls[-1],
    }
    for field, expected_value in expected.items():
        if not close_enough(summary[field], expected_value):
            raise ValueError(
                f"official summary {field}={summary[field]} does not match "
                f"query output {expected_value}"
            )


def result_record(source_name: str, value: float, unit: str) -> dict[str, Any]:
    return {
        "source_name": source_name,
        "source_field": source_name,
        "raw_value": value,
        "raw_unit": unit,
        "value": value,
        "unit": unit,
    }


def parse_stdout(raw_text: str, version: str, architecture: str) -> dict[str, Any]:
    lines = [line.strip() for line in raw_text.splitlines() if line.strip()]
    expected_line_count = QUERY_REPETITIONS + 1
    if len(lines) != expected_line_count:
        raise ValueError(
            f"official speedtest output must contain {expected_line_count} non-empty "
            f"lines, found {len(lines)}"
        )

    query_seconds: list[float] = []
    query_recalls: list[float] = []
    for line_number, line in enumerate(lines[:QUERY_REPETITIONS], start=1):
        seconds, recall = parse_query_line(line, line_number)
        query_seconds.append(seconds)
        query_recalls.append(recall)

    summary, name = parse_summary(lines[-1])
    validate_summary(query_seconds, query_recalls, summary)
    return {
        "software": "hnswlib",
        "category": "AI",
        "version": version,
        "architecture": architecture,
        "benchmark": "tests/python/speedtest.py",
        "reference": "official hnswlib tests/python/speedtest.py",
        "official_script_sha256": OFFICIAL_SCRIPT_SHA256,
        "parameters": {
            "dimension": 128,
            "name": name,
            "search_threads": 1,
            "construction_threads": 64,
            "num_elements": 400000,
            "ef_construction": 60,
            "M": 16,
            "search_ef": 15,
            "query_count": 5000,
            "query_repetitions": QUERY_REPETITIONS,
            "numpy_seed": 1,
            "official_script_sha256": OFFICIAL_SCRIPT_SHA256,
        },
        "raw_query_runs": [
            {"tt": seconds, "recall": recall}
            for seconds, recall in zip(query_seconds, query_recalls, strict=True)
        ],
        "results": {
            "mean": result_record("np.mean(times)", summary["mean"], "seconds"),
            "median": result_record("np.median(times)", summary["median"], "seconds"),
            "std": result_record("np.std(times)", summary["std"], "seconds"),
            "construction_time": result_record(
                "construction_time", summary["construction_time"], "seconds"
            ),
            "recall": result_record("recall", summary["recall"], "ratio"),
        },
    }


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--raw-output", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    args = parser.parse_args()

    payload = parse_stdout(
        args.raw_output.read_text(encoding="utf-8", errors="strict"),
        args.version,
        args.architecture,
    )
    atomic_write_json(args.output, payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
