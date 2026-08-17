#!/usr/bin/env python3
"""Run the existing Redis command/concurrency benchmark on either architecture."""

from __future__ import annotations

import csv
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


COMMANDS = ["SET", "GET", "INCR", "LPUSH", "LRANGE_100", "SADD", "HSET", "ZADD"]
CONCURRENCY_LEVELS = [1, 10, 50, 100, 200]
NUM_REQUESTS = 100000
ITERATIONS = 3
REDIS_CLI = os.environ["REDIS_CLI_BIN"]


def start_redis_server(redis_server: str, port: int, data_dir: Path, extra_args: list[str] | None = None) -> None:
    data_dir.mkdir(parents=True, exist_ok=True)
    command = [
        redis_server,
        "--bind", "127.0.0.1",
        "--protected-mode", "yes",
        "--port", str(port),
        "--dir", str(data_dir),
        "--save", "",
        "--appendonly", "no",
        "--daemonize", "yes",
        "--loglevel", "warning",
        "--pidfile", str(data_dir / "redis.pid"),
    ]
    if extra_args:
        command.extend(extra_args)
    completed = subprocess.run(command, capture_output=True, text=True, timeout=15, check=False)
    if completed.returncode:
        raise RuntimeError(f"redis-server failed: {completed.stderr.strip()}")
    for _ in range(30):
        ping = subprocess.run(
            [REDIS_CLI, "-h", "127.0.0.1", "-p", str(port), "PING"],
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        if ping.returncode == 0 and ping.stdout.strip() == "PONG":
            return
        time.sleep(0.2)
    raise RuntimeError("redis-server did not become ready")


def stop_redis_server(port: int, data_dir: Path) -> None:
    try:
        subprocess.run(
            [REDIS_CLI, "-h", "127.0.0.1", "-p", str(port), "SHUTDOWN", "NOSAVE"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
    except subprocess.TimeoutExpired:
        pass
    pidfile = data_dir / "redis.pid"
    if pidfile.exists():
        try:
            os.kill(int(pidfile.read_text(encoding="utf-8").strip()), 9)
        except (OSError, ValueError):
            pass


def parse_benchmark(output: str, expected_command: str) -> dict[str, float]:
    expected = expected_command.upper()
    for row in csv.reader(output.splitlines()):
        reported = row[0].strip().upper().split()[0] if row else ""
        if len(row) >= 7 and reported == expected:
            return {
                "qps": round(float(row[1]), 2),
                "avg_latency_ms": round(float(row[2]), 4),
                "p99_latency_ms": round(float(row[6]), 4),
            }
    raise RuntimeError(f"cannot parse redis-benchmark CSV for {expected_command}")


def run_redis_benchmark(
    redis_benchmark: str,
    port: int,
    command: str,
    concurrency: int,
    *,
    data_size: int | None = None,
) -> dict[str, float]:
    samples: list[dict[str, float]] = []
    for _ in range(ITERATIONS):
        invocation = [
            redis_benchmark,
            "-h", "127.0.0.1",
            "-p", str(port),
            "-t", command.lower(),
            "-c", str(concurrency),
            "-n", str(NUM_REQUESTS),
            "--csv",
        ]
        if data_size is not None:
            invocation.extend(["-d", str(data_size)])
        completed = subprocess.run(invocation, capture_output=True, text=True, timeout=300, check=False)
        if completed.returncode:
            raise RuntimeError(f"redis-benchmark {command} failed: {completed.stderr.strip()}")
        samples.append(parse_benchmark(completed.stdout, command))
    return {
        field: round(sum(sample[field] for sample in samples) / len(samples), 4)
        for field in ("qps", "avg_latency_ms", "p99_latency_ms")
    }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: benchmark_redis.py REDIS_SERVER REDIS_BENCHMARK OUTPUT", file=sys.stderr)
        return 1
    redis_server, redis_benchmark, output = sys.argv[1:]
    for binary in (redis_server, redis_benchmark, REDIS_CLI):
        if not os.path.isfile(binary) or not os.access(binary, os.X_OK):
            raise RuntimeError(f"Redis executable is unavailable: {binary}")

    port = int(os.environ["REDIS_SERVICE_PORT"])
    results: dict[str, dict[str, dict[str, float]]] = {}
    for command in COMMANDS:
        results[command] = {}
        for concurrency in CONCURRENCY_LEVELS:
            label = f"concurrency_{concurrency}"
            print(f"[primary] {command} {label}", flush=True)
            results[command][label] = run_redis_benchmark(
                redis_benchmark, port, command, concurrency
            )

    payload = {
        "benchmark": "redis_ops",
        "software": "redis",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "commands": COMMANDS,
            "concurrency_levels": CONCURRENCY_LEVELS,
            "num_requests": NUM_REQUESTS,
            "iterations": ITERATIONS,
            "persistence": "none",
        },
        "results_summary": results,
    }
    Path(output).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
