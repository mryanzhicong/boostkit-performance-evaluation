#!/usr/bin/env python3
"""Run database_blue's Redis SET/GET design without its VM harness.

database_blue's physical-machine Redis case runs Redis's own redis-benchmark
against one server and records the ``requests per second`` line for SET and
GET. Its test topology has separate client and server machines; this project
uses the same command and load parameters against the isolated local service
because each architecture job has one dedicated runner.
"""

from __future__ import annotations

import json
import math
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Fixed parameters from database_blue's physical-machine Redis performance
# case: virtuall_redis_ori_0001.py.
OPERATIONS = ("SET", "GET")
REQUEST_COUNT = 10_000_000
CLIENT_COUNT = 1_000
KEYSPACE_LENGTH = 10_000_000
THREAD_COUNT = 20
COMMAND_TIMEOUT_SECONDS = 1_500


def benchmark_command(binary: Path, port: int, operation: str) -> list[str]:
    return [
        str(binary),
        "-h",
        "127.0.0.1",
        "-p",
        str(port),
        "-n",
        str(REQUEST_COUNT),
        "-c",
        str(CLIENT_COUNT),
        "-r",
        str(KEYSPACE_LENGTH),
        "-t",
        operation.lower(),
        "--threads",
        str(THREAD_COUNT),
    ]


def parse_requests_per_second(output: str, operation: str) -> tuple[float, str]:
    patterns = (
        (
            f"{operation}: <value> requests per second",
            re.compile(
                rf"(?im)^\s*{re.escape(operation)}\s*:\s*"
                r"([0-9]+(?:\.[0-9]+)?)\s+requests per second\b"
            ),
        ),
        (
            "throughput summary: <value> requests per second",
            re.compile(
                r"(?im)^\s*throughput summary:\s*"
                r"([0-9]+(?:\.[0-9]+)?)\s+requests per second\b"
            ),
        ),
    )
    matches = [
        (source_field, value)
        for source_field, pattern in patterns
        for value in pattern.findall(output)
    ]
    if len(matches) != 1:
        raise RuntimeError(
            f"expected exactly one {operation} requests-per-second line or "
            f"throughput summary, "
            f"found {len(matches)}"
        )
    source_field, raw_value = matches[0]
    value = float(raw_value)
    if not math.isfinite(value) or value <= 0:
        raise RuntimeError(f"{operation} requests per second is invalid: {raw_value}")
    return value, source_field


def run_benchmark(
    binary: Path, port: int, operation: str
) -> tuple[list[str], str, float, str]:
    command = benchmark_command(binary, port, operation)
    print(f"[redis-benchmark] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=COMMAND_TIMEOUT_SECONDS,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(
            f"redis-benchmark {operation} exited with code {completed.returncode}"
        )
    value, source_field = parse_requests_per_second(completed.stdout, operation)
    return command, completed.stdout, value, source_field


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: benchmark_redis.py REDIS_BENCHMARK RAW_OUTPUT NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1

    benchmark_binary, raw_output, normalized_output = map(Path, sys.argv[1:])
    if not benchmark_binary.is_file() or not os.access(benchmark_binary, os.X_OK):
        raise RuntimeError(f"redis-benchmark executable is unavailable: {benchmark_binary}")

    port = int(os.environ["REDIS_SERVICE_PORT"])
    raw_sections: list[str] = []
    results: list[dict[str, Any]] = []
    for operation in OPERATIONS:
        command, output, value, source_field = run_benchmark(
            benchmark_binary, port, operation
        )
        raw_sections.append(f"$ {' '.join(command)}\n{output}")
        results.append(
            {
                "source_name": f"{operation}: requests per second",
                "source_field": source_field,
                "group": operation,
                "value": value,
                "unit": "requests/s",
                "direction": "higher_is_better",
            }
        )

    raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw_output.write_text("\n\n".join(raw_sections), encoding="utf-8")
    payload = {
        "benchmark": "database_blue_redis_benchmark_design",
        "software": "redis",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "reference_case": "database_blue virtuall_redis_ori_0001.py",
            "client_host": "127.0.0.1 (single-runner adaptation)",
            "operations": list(OPERATIONS),
            "requests": REQUEST_COUNT,
            "clients": CLIENT_COUNT,
            "keyspace_length": KEYSPACE_LENGTH,
            "threads": THREAD_COUNT,
            "metric_source": [
                "<operation>: <value> requests per second",
                "throughput summary: <value> requests per second",
            ],
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[redis-benchmark] normalized {len(results)} database_blue-style metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
