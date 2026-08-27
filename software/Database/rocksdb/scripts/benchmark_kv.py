#!/usr/bin/env python3
"""Run the official RocksDB db_bench KV operations benchmark.

The workload names (fillseq, readrandom, overwrite, readwhilewriting) and the
field labels (micros/op, ops/sec, MB/s) are taken verbatim from db_bench's
stdout.  This script only parses and preserves those official tokens; it writes
the raw db_bench output next to the parsed JSON so the numbers stay traceable.
"""

from __future__ import annotations

import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

WORKLOADS = ("fillseq", "readrandom", "overwrite", "readwhilewriting")

BENCH_RE = re.compile(
    r"(\w+)\s*:\s*([\d.]+)\s*micros/op\s+([\d.]+)\s+ops/sec"
    r"(?:.*?([\d.]+)\s*MB/s)?"
)

RAW_LOG: list[str] = []


def detect_architecture() -> str:
    value = (os.environ.get("EXPECTED_ARCH") or platform.machine()).lower()
    if value in ("amd64", "x86_64"):
        return "x86_64"
    if value in ("arm64", "aarch64"):
        return "aarch64"
    return value


def run_db_bench(db_bench_bin, db_path, benchmarks, num, key_size, value_size,
                 threads=1, compression="snappy"):
    cmd = [
        db_bench_bin,
        "--db=" + db_path,
        "--benchmarks=" + benchmarks,
        "--num=" + str(num),
        "--key_size=" + str(key_size),
        "--value_size=" + str(value_size),
        "--threads=" + str(threads),
        "--compression_type=" + compression,
        "--statistics=0",
        "--stats_dump_period_sec=0",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    raw = result.stdout + "\n" + result.stderr
    RAW_LOG.append(raw)
    return raw


def parse_bench_output(text):
    results = {}
    for match in BENCH_RE.finditer(text):
        name = match.group(1)
        results[name] = {
            "micros_per_op": round(float(match.group(2)), 2),
            "ops_per_sec": round(float(match.group(3)), 2),
            "mb_per_sec": round(float(match.group(4)), 2) if match.group(4) else 0.0,
        }
    return results


def main():
    if len(sys.argv) != 7:
        print(
            "Usage: benchmark_kv.py DB_BENCH OUTPUT_JSON NUM KEYSIZE VALUESIZE ITERATIONS",
            file=sys.stderr,
        )
        return 2
    db_bench_bin = sys.argv[1]
    output_file = Path(sys.argv[2])
    num = int(sys.argv[3])
    key_size = int(sys.argv[4])
    value_size = int(sys.argv[5])
    iterations = int(sys.argv[6])

    if not os.path.isfile(db_bench_bin):
        print(f"[BENCHMARK_KV] db_bench not found: {db_bench_bin}", file=sys.stderr)
        return 1

    version_str = os.environ.get("SOFTWARE_VERSION", "11.8.1")
    all_runs: list[dict] = []
    for iteration in range(iterations):
        db_path = tempfile.mkdtemp(prefix="rocksdb_bench_")
        try:
            print(f"[BENCHMARK_KV] iteration {iteration + 1}/{iterations}, DB: {db_path}")
            text = run_db_bench(
                db_bench_bin, db_path, ",".join(WORKLOADS),
                num, key_size, value_size, threads=1, compression="snappy",
            )
            parsed = parse_bench_output(text)
            missing = [wl for wl in WORKLOADS if wl not in parsed]
            if missing:
                raise RuntimeError(
                    f"db_bench did not report workloads: {', '.join(missing)}"
                )
            all_runs.append(parsed)
        finally:
            shutil.rmtree(db_path, ignore_errors=True)

    results_summary = {}
    for workload in WORKLOADS:
        entries = [run[workload] for run in all_runs]
        results_summary[workload] = {
            "micros_per_op": round(sum(e["micros_per_op"] for e in entries) / len(entries), 2),
            "ops_per_sec": round(sum(e["ops_per_sec"] for e in entries) / len(entries), 2),
            "mb_per_sec": round(sum(e["mb_per_sec"] for e in entries) / len(entries), 2),
        }

    payload = {
        "benchmark": "kv_ops",
        "description": (
            "RocksDB LSM-tree KV operations benchmark "
            f"({num} keys, {key_size}B key, {value_size}B value, snappy compression)"
        ),
        "reference": "https://github.com/facebook/rocksdb",
        "software": "rocksdb",
        "version": version_str,
        "architecture": detect_architecture(),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "num_keys": num,
            "key_size": key_size,
            "value_size": value_size,
            "compression": "snappy",
            "threads": 1,
            "iterations": iterations,
            "workloads": list(WORKLOADS),
        },
        "results_summary": results_summary,
    }
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    output_file.with_suffix(".log").write_text(
        "".join(RAW_LOG), encoding="utf-8"
    )
    print(f"[BENCHMARK_KV] output written to {output_file} ({len(results_summary)} workloads)")
    for workload, result in results_summary.items():
        print(
            f"[BENCHMARK_KV] {workload}: ops/sec={result['ops_per_sec']}, "
            f"latency={result['micros_per_op']}us, throughput={result['mb_per_sec']}MB/s"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())