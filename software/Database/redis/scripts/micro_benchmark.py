#!/usr/bin/env python3
"""Run Redis data-size, client-scaling, and persistence microbenchmarks."""

from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from benchmark_redis import run_redis_benchmark, start_redis_server, stop_redis_server


def csv_list(name: str, default: str) -> list[str]:
    return [item.strip() for item in os.environ.get(name, default).split(",") if item.strip()]


DATA_SIZES = [int(value) for value in csv_list("DATA_SIZES", "64,256,1024,4096")]
CLIENT_VALUES = csv_list("CLIENT_COUNTS", "1,10,50,100,all")
PERSISTENCE_MODES = csv_list("PERSISTENCE_MODES", "none,aof,rdb")


def temporary_dir(prefix: str) -> Path:
    return Path(tempfile.mkdtemp(prefix=prefix, dir=os.environ.get("TMPDIR")))


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: micro_benchmark.py REDIS_SERVER REDIS_BENCHMARK OUTPUT", file=sys.stderr)
        return 1
    redis_server, redis_benchmark, output = sys.argv[1:]
    max_clients = os.cpu_count() or 1
    client_counts = [max_clients if value == "all" else int(value) for value in CLIENT_VALUES]
    external_port = os.environ.get("REDIS_SERVICE_PORT")
    base_port = int(external_port) if external_port else 17390 + os.getpid() % 500
    data_dir: Path | None = None
    try:
        if external_port is None:
            data_dir = temporary_dir("redis-micro-")
            start_redis_server(redis_server, base_port, data_dir)
        data_size_results = {
            f"data_size_{size}": run_redis_benchmark(
                redis_benchmark, base_port, "SET", 50, data_size=size
            )
            for size in DATA_SIZES
        }
        client_results = {
            f"clients_{clients}": run_redis_benchmark(
                redis_benchmark, base_port, "GET", clients
            )
            for clients in client_counts
        }
    finally:
        if data_dir is not None:
            stop_redis_server(base_port, data_dir)
            shutil.rmtree(data_dir, ignore_errors=True)

    persistence_results: dict[str, dict[str, float]] = {}
    for index, mode in enumerate(PERSISTENCE_MODES):
        mode_dir = temporary_dir(f"redis-{mode}-")
        port = 18390 + os.getpid() % 500 + index
        extra_args: list[str] = []
        if mode == "aof":
            extra_args = ["--appendonly", "yes", "--appendfsync", "everysec"]
        elif mode == "rdb":
            extra_args = ["--save", "1 1"]
        elif mode != "none":
            raise ValueError(f"unsupported persistence mode: {mode}")
        try:
            start_redis_server(redis_server, port, mode_dir, extra_args)
            persistence_results[f"persistence_{mode}"] = run_redis_benchmark(
                redis_benchmark, port, "SET", 50
            )
        finally:
            stop_redis_server(port, mode_dir)
            shutil.rmtree(mode_dir, ignore_errors=True)

    payload = {
        "benchmark": "redis_micro",
        "software": "redis",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "data_sizes": DATA_SIZES,
            "client_counts": client_counts,
            "max_clients": max_clients,
            "persistence_modes": PERSISTENCE_MODES,
        },
        "results": {
            "data_size_sweep": data_size_results,
            "client_scaling": client_results,
            "persistence_sweep": persistence_results,
        },
    }
    Path(output).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
