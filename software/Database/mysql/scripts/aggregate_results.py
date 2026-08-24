#!/usr/bin/env python3
"""Merge preserved, individually named sysbench metrics without derivation."""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def load(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"JSON root must be an object: {path}")
    return data


def merge_results(target: dict[str, dict[str, Any]], source: dict[str, Any], path: Path) -> None:
    results = source.get("results")
    if not isinstance(results, dict) or not results:
        raise ValueError(f"results must be a non-empty object: {path}")
    for key, result in results.items():
        if not isinstance(key, str) or not isinstance(result, dict):
            raise ValueError(f"invalid result entry in {path}")
        source_name = result.get("source_name")
        if not isinstance(source_name, str) or not source_name:
            raise ValueError(f"result has no source_name in {path}")
        if source_name in target:
            raise ValueError(f"duplicate source metric {source_name}")
        target[source_name] = result


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: aggregate_results.py RESULTS_DIR OUTPUT", file=sys.stderr)
        return 1
    results_dir, output_path = Path(sys.argv[1]), Path(sys.argv[2])
    try:
        primary = load(results_dir / "benchmark_mysql.json")
        micro = load(results_dir / "micro_benchmark.json")
        for payload, path in ((primary, results_dir / "benchmark_mysql.json"),
                              (micro, results_dir / "micro_benchmark.json")):
            if payload.get("software") != "mysql":
                raise ValueError(f"invalid software identity: {path}")
            if payload.get("version") != os.environ["SOFTWARE_VERSION"]:
                raise ValueError(f"version differs from this run: {path}")
            if payload.get("architecture") != os.environ["EXPECTED_ARCH"]:
                raise ValueError(f"architecture differs from this run: {path}")
        results: dict[str, dict[str, Any]] = {}
        merge_results(results, primary, results_dir / "benchmark_mysql.json")
        merge_results(results, micro, results_dir / "micro_benchmark.json")
        output_path.write_text(json.dumps({
            "software": "mysql",
            "version": os.environ["SOFTWARE_VERSION"],
            "architecture": os.environ["EXPECTED_ARCH"],
            "test_time": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "results": results,
        }, indent=2) + "\n", encoding="utf-8")
        print(f"[mysql] merged {len(results)} source metrics")
        return 0
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"[mysql] ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
