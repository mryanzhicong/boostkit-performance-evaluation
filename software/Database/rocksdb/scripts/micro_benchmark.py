#!/usr/bin/env python3
"""Run the auxiliary RocksDB db_bench micro benchmarks.

Thread-scaling, compression-type and value-size sweeps reuse the official
db_bench workload names as their source identifiers.  Results are stored in a
secondary JSON output while the primary cross-architecture metrics come from
benchmark_kv.py via aggregate_results.py.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmark_kv  # noqa: E402
from benchmark_kv import (  # noqa: E402
    detect_architecture,
    parse_bench_output,
    run_db_bench,
)

THREAD_COUNTS = [1, 2, 4, 8, "all"]
COMPRESSION_TYPES = ["none", "snappy", "zstd"]
VALUE_SIZES = [64, 256, 1024, 4096]


def get_max_threads():
    try:
        return int(os.cpu_count() or 4)
    except (TypeError, ValueError):
        return 4


def bench_thread_scaling(db_bench_bin, num, key_size, value_size, iterations):
    max_threads = get_max_threads()
    thread_counts = [t if t != "all" else max_threads for t in THREAD_COUNTS]
    results = {}
    for count in thread_counts:
        label = f"threads_{count}"
        db_path = tempfile.mkdtemp(prefix="rocksdb_mt_")
        try:
            run_db_bench(db_bench_bin, db_path, "fillseq", num, key_size, value_size)
            values = []
            for _ in range(iterations):
                text = run_db_bench(
                    db_bench_bin, db_path, "readrandom", num, key_size, value_size,
                    threads=count,
                )
                parsed = parse_bench_output(text)
                if "readrandom" in parsed:
                    values.append(parsed["readrandom"]["ops_per_sec"])
            if values:
                results[label] = {"ops_per_sec": round(sum(values) / len(values), 2)}
            print(f"[MICRO] thread {label}: {results.get(label, {})}")
        finally:
            shutil.rmtree(db_path, ignore_errors=True)
    return results


def bench_compression_sweep(db_bench_bin, num, key_size, value_size, iterations):
    results = {}
    for compression in COMPRESSION_TYPES:
        label = f"compression_{compression}"
        db_path = tempfile.mkdtemp(prefix=f"rocksdb_comp_{compression}_")
        try:
            values = []
            for _ in range(iterations):
                text = run_db_bench(
                    db_bench_bin, db_path, "fillseq", num, key_size, value_size,
                    compression=compression,
                )
                parsed = parse_bench_output(text)
                if "fillseq" in parsed:
                    values.append(parsed["fillseq"])
            if values:
                results[label] = {
                    "ops_per_sec": round(sum(v["ops_per_sec"] for v in values) / len(values), 2),
                    "mb_per_sec": round(sum(v["mb_per_sec"] for v in values) / len(values), 2),
                }
            print(f"[MICRO] {label}: {results.get(label, {})}")
        finally:
            shutil.rmtree(db_path, ignore_errors=True)
    return results


def bench_value_size_sweep(db_bench_bin, num, key_size, iterations):
    results = {}
    for value_size in VALUE_SIZES:
        label = f"value_size_{value_size}"
        db_path = tempfile.mkdtemp(prefix=f"rocksdb_vs{value_size}_")
        try:
            values = []
            for _ in range(iterations):
                text = run_db_bench(
                    db_bench_bin, db_path, "fillseq", num, key_size, value_size,
                )
                parsed = parse_bench_output(text)
                if "fillseq" in parsed:
                    values.append(parsed["fillseq"])
            if values:
                results[label] = {
                    "ops_per_sec": round(sum(v["ops_per_sec"] for v in values) / len(values), 2),
                    "mb_per_sec": round(sum(v["mb_per_sec"] for v in values) / len(values), 2),
                }
            print(f"[MICRO] {label}: {results.get(label, {})}")
        finally:
            shutil.rmtree(db_path, ignore_errors=True)
    return results


def main():
    if len(sys.argv) < 6:
        print(
            "Usage: micro_benchmark.py DB_BENCH OUTPUT_JSON NUM KEYSIZE VALUESIZE [ITERATIONS]",
            file=sys.stderr,
        )
        return 2
    db_bench_bin = sys.argv[1]
    output_file = Path(sys.argv[2])
    num = int(sys.argv[3])
    key_size = int(sys.argv[4])
    value_size = int(sys.argv[5])
    iterations = int(sys.argv[6]) if len(sys.argv) >= 7 else 1

    if not os.path.isfile(db_bench_bin):
        print(f"[MICRO] db_bench not found: {db_bench_bin}", file=sys.stderr)
        return 1

    version_str = os.environ.get("SOFTWARE_VERSION", "11.8.1")
    max_threads = get_max_threads()

    print("[MICRO] thread scaling")
    thread_results = bench_thread_scaling(db_bench_bin, num, key_size, value_size, iterations)

    print("[MICRO] compression sweep")
    comp_results = bench_compression_sweep(db_bench_bin, num, key_size, value_size, iterations)

    print("[MICRO] value size sweep")
    vs_results = bench_value_size_sweep(db_bench_bin, num, key_size, iterations)

    payload = {
        "benchmark": "micro_operations",
        "description": "RocksDB micro: thread scaling, compression type sweep, value size sweep",
        "reference": "https://github.com/facebook/rocksdb",
        "software": "rocksdb",
        "version": version_str,
        "architecture": detect_architecture(),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "num_keys": num,
            "key_size": key_size,
            "value_size": value_size,
            "max_threads": max_threads,
            "iterations": iterations,
            "thread_counts": [str(t) for t in THREAD_COUNTS],
            "compression_types": COMPRESSION_TYPES,
            "value_sizes": VALUE_SIZES,
        },
        "results": {
            "thread_scaling": thread_results,
            "compression_sweep": comp_results,
            "value_size_sweep": vs_results,
        },
    }
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    output_file.with_suffix(".log").write_text(
        "".join(benchmark_kv.RAW_LOG), encoding="utf-8"
    )
    print(f"[MICRO] output written to {output_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())