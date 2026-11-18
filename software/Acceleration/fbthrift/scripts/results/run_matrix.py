#!/usr/bin/env python3
"""Drive the AccLibBenchmark press_client matrix and emit benchmark_fbthrift.json.

The benchmark binary, the matrix shape and the client flags follow the BoostKit
wiki (close_loop over rocket transport, 1 warmup-free steady-state window per
cell, numactl binding).  Upstream v2022.11.14.00 has no io_uring RPC path, so
``--use_io_uring`` is always false and the exclusion is recorded in the result.
"""

from __future__ import annotations

import argparse
import hashlib
import itertools
import json
import math
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

# Wiki matrix: 11 data types x 5 connection shapes x 3 queue depths = 165 cells.
DATA_SETS = {
    "small": [
        ("binary-256B", ["--fields=none", "--payload_size=256"]),
    ],
    "full": [
        ("binary-256B", ["--fields=none", "--payload_size=256"]),
        ("binary-1024B", ["--fields=none", "--payload_size=1024"]),
        ("binary-4096B", ["--fields=none", "--payload_size=4096"]),
        ("binary-8192B", ["--fields=none", "--payload_size=8192"]),
        ("binary-16384B", ["--fields=none", "--payload_size=16384"]),
        ("i32-2048B", ["--fields=int_val", "--payload_size=2048"]),
        ("i64-1024B", ["--fields=long_val", "--payload_size=1024"]),
        ("double-512B", ["--fields=double_val", "--payload_size=512"]),
        ("list-i32-4096B", ["--fields=int_list", "--int_list_size=32", "--payload_size=4096"]),
        ("list-i64-2048B", ["--fields=i64_list", "--int_list_size=32", "--payload_size=2048"]),
        ("string-8192B", ["--fields=str_val", "--payload_size=8192"]),
    ],
}
CONN_SETS = {
    # [cpu_threads, io_threads, connections]
    "small": [[8, 8, 500], [16, 16, 1000]],
    "full": [[1, 1, 50], [10, 10, 500], [20, 20, 1000], [40, 40, 1000], [40, 40, 2000]],
}
QD_SETS = {"small": [10, 50], "full": [10, 25, 50]}

METRICS = (
    ("Throughput", "MB/s", "higher_is_better"),
    ("QPS", "ops/s", "higher_is_better"),
    ("Success Rate", "%", "higher_is_better"),
    ("Failed Requests", "requests", "neutral"),
    ("latencyAvg", "us", "lower_is_better"),
    ("latencyP99", "us", "lower_is_better"),
    ("Client CPU (%)", "%", "neutral"),
    ("Server CPU (%)", "%", "neutral"),
)


def parse_output(text: str) -> dict[str, str]:
    data: dict[str, str] = {}
    match = re.search(r"Payload:\s*(\d+)", text)
    data["payload"] = match.group(1) if match else "N/A"
    match = re.search(r"Throughput:\s*([\d.]+)\s*MB/s", text)
    data["Throughput"] = match.group(1) if match else "N/A"
    match = re.search(r"Latency \(us\):.*?avg=([\d.]+).*?p99=([\d.]+)", text)
    if match:
        data["latencyAvg"] = match.group(1)
        data["latencyP99"] = match.group(2)
    else:
        data["latencyAvg"] = "N/A"
        data["latencyP99"] = "N/A"
    for label, key in (("Server CPU (%)", "Server CPU (%)"), ("Client CPU (%)", "Client CPU (%)")):
        match = re.search(rf"{re.escape(label)}:.*?avg=([\d.]+)", text)
        data[key] = f"{float(match.group(1)):.2f}" if match else "N/A"
    qps = re.search(r"QPS:\s*([\d.]+)", text)
    success = re.search(r"Success:\s*(\d+)", text)
    fail = re.search(r"Fail:\s*(\d+)", text)
    if qps and success and fail:
        total = int(success.group(1)) + int(fail.group(1))
        rate = (int(success.group(1)) / total * 100) if total else 0.0
        data["QPS"] = qps.group(1)
        data["Success Rate"] = f"{rate:.2f}"
        data["Failed Requests"] = fail.group(1)
    else:
        data["QPS"] = data["Success Rate"] = data["Failed Requests"] = "N/A"
    return data


def resolve_numa(requested: int) -> tuple[int, bool]:
    try:
        output = subprocess.run(["numactl", "--hardware"], capture_output=True, text=True, check=False).stdout
    except FileNotFoundError:
        return 0, False
    match = re.search(r"available: (\d+) nodes", output)
    if not match:
        return 0, False
    nodes = int(match.group(1))
    if 0 <= requested < nodes:
        return requested, True
    print(f"[fbthrift] WARNING: NUMA node {requested} is unavailable ({nodes} nodes); using 0", flush=True)
    return 0, True


def run_cell(client: Path, prefix: list[str], dynamic: list[str], label: str, raw_dir: Path) -> tuple[str, dict[str, str]]:
    command = prefix + [str(client), *dynamic]
    print(f"[fbthrift] {label}: {' '.join(command)}", flush=True)
    try:
        completed = subprocess.run(command, capture_output=True, text=True, check=False)
    except OSError as error:
        raise RuntimeError(f"cannot execute press_client: {error}") from error
    output = (completed.stdout or "") + (completed.stderr or "")
    (raw_dir / f"{label}.log").write_text(output, encoding="utf-8", errors="replace")
    if completed.returncode != 0:
        raise RuntimeError(f"press_client failed for {label}: exit {completed.returncode}")
    return output, parse_output(output)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--client", required=True)
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--numa-node", type=int, default=1)
    parser.add_argument("--matrix", choices=("small", "full"), default="full")
    parser.add_argument("--test-seconds", type=int, default=120)
    parser.add_argument("--rpc-timeout-ms", type=int, default=2000)
    parser.add_argument("--version", required=True)
    parser.add_argument("--arch", required=True)
    parser.add_argument("--results-json", required=True)
    parser.add_argument("--raw-dir", required=True)
    args = parser.parse_args()

    client = Path(args.client)
    if not client.is_file():
        print(f"[fbthrift] ERROR: press_client is missing: {client}", file=sys.stderr)
        return 30
    raw_dir = Path(args.raw_dir)
    raw_dir.mkdir(parents=True, exist_ok=True)
    results_json = Path(args.results_json)

    node, has_numactl = resolve_numa(args.numa_node)
    data_sets = DATA_SETS[args.matrix]
    conn_sets = CONN_SETS[args.matrix]
    qd_sets = QD_SETS[args.matrix]
    total = len(data_sets) * len(conn_sets) * len(qd_sets)
    print(f"[fbthrift] {args.matrix} matrix: {len(data_sets)} x {len(conn_sets)} x {len(qd_sets)} = {total} cells", flush=True)

    results: dict[str, dict[str, object]] = {}
    order: list[str] = []
    started = datetime.now(timezone.utc)
    for index, ((data_name, data_args), conn, qd) in enumerate(itertools.product(data_sets, conn_sets, qd_sets), start=1):
        cpu_threads, io_threads, connections = conn
        label = f"{data_name}-conn{connections}-qd{qd}-cpu{cpu_threads}"
        prefix = (["numactl", "-N", str(node)] if has_numactl else [])
        dynamic = [
            "--mode=close_loop",
            "--host=127.0.0.1",
            f"--port={args.port}",
            "--transport=rocket",
            f"--test_seconds={args.test_seconds}",
            "--compression=none",
            f"--rpc_timeout_ms={args.rpc_timeout_ms}",
            "--echo_attachment=false",
            "--use_io_uring=false",
            "--random_fields=true",
            f"--cpu_threads={cpu_threads}",
            f"--io_threads={io_threads}",
            f"--connections={connections}",
            f"--queue_depth={qd}",
            *data_args,
        ]
        print(f"[fbthrift] cell {index}/{total} {label}", flush=True)
        _, metrics = run_cell(client, prefix, dynamic, label, raw_dir)
        for metric_name, unit, direction in METRICS:
            raw = metrics.get(metric_name, "N/A")
            if raw == "N/A":
                raise RuntimeError(f"press_client omitted {metric_name} for {label}")
            value = float(raw)
            if not math.isfinite(value) or value < 0:
                raise RuntimeError(f"press_client reported invalid {metric_name} for {label}: {raw}")
            key = f"{label} :: {metric_name}"
            results[key] = {
                "source_name": key,
                "value": value,
                "unit": unit,
                "direction": direction,
                "group": data_name,
                "scenario": {
                    "payload": data_name,
                    "cpu_threads": cpu_threads,
                    "io_threads": io_threads,
                    "connections": connections,
                    "queue_depth": qd,
                },
            }
            order.append(key)

    payload = {
        "case": "fbthrift",
        "version": args.version,
        "architecture": args.arch,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "run": {
            "matrix": args.matrix,
            "cells": total,
            "test_seconds": args.test_seconds,
            "rpc_timeout_ms": args.rpc_timeout_ms,
            "transport": "rocket",
            "compression": "none",
            "mode": "close_loop",
            "numa_node": node if has_numactl else None,
            "numactl": has_numactl,
            "io_uring": False,
            "io_uring_reason": "upstream v2022.11.14.00 has no io_uring RPC path",
            "client": str(client),
            "started_at": started.isoformat(),
            "finished_at": datetime.now(timezone.utc).isoformat(),
        },
        "results": results,
    }
    results_json.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[fbthrift] wrote {len(results)} metrics from {total} cells to {results_json}", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"[fbthrift] ERROR: {error}", file=sys.stderr)
        raise SystemExit(40)
