#!/usr/bin/env python3
"""Run Redis's complete default benchmark suite with database_blue load settings.

database_blue's physical-machine Redis case supplies the common load parameters
for Redis's own redis-benchmark. This project uses those parameters against the
isolated local service because each architecture job has one dedicated runner,
but deliberately omits ``-t`` so redis-benchmark runs its complete official
default operation set for the built Redis version.
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


# Load parameters from database_blue's physical-machine Redis performance case:
# virtuall_redis_ori_0001.py. The operation list is intentionally not declared:
# without -t, redis-benchmark selects its own complete default operation set.
REQUEST_COUNT = 10_000_000
CLIENT_COUNT = 1_000
KEYSPACE_LENGTH = 10_000_000
THREAD_COUNT = 20
COMMAND_TIMEOUT_SECONDS = 14_400
OPERATION_HEADER = re.compile(r"(?m)^======\s*(.+?)\s*======\s*$")
THROUGHPUT_SUMMARY = re.compile(
    r"(?im)^\s*throughput summary:\s*"
    r"([0-9]+(?:\.[0-9]+)?)\s+requests per second\b"
)


def benchmark_command(binary: Path, port: int) -> list[str]:
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
        "--threads",
        str(THREAD_COUNT),
    ]


def parse_default_operation_results(output: str) -> list[dict[str, Any]]:
    headers = list(OPERATION_HEADER.finditer(output))
    if not headers:
        raise RuntimeError("redis-benchmark output contains no default-operation headers")

    results: list[dict[str, Any]] = []
    seen_operations: set[str] = set()
    for index, header in enumerate(headers):
        operation = header.group(1).strip()
        if not operation or operation in seen_operations:
            raise RuntimeError(f"redis-benchmark has an invalid or duplicate operation: {operation!r}")
        section_end = headers[index + 1].start() if index + 1 < len(headers) else len(output)
        section = output[header.end():section_end]
        summaries = THROUGHPUT_SUMMARY.findall(section)
        if len(summaries) != 1:
            raise RuntimeError(
                f"redis-benchmark operation {operation} must contain exactly one "
                f"throughput summary, found {len(summaries)}"
            )
        value = float(summaries[0])
        if not math.isfinite(value) or value <= 0:
            raise RuntimeError(
                f"redis-benchmark operation {operation} has an invalid throughput: {summaries[0]}"
            )
        seen_operations.add(operation)
        results.append({
            "source_name": f"{operation}: requests per second",
            "source_field": "throughput summary: <value> requests per second",
            "group": operation,
            "value": value,
            "unit": "requests/s",
            "direction": "higher_is_better",
        })
    return results


def run_benchmark(binary: Path, port: int) -> tuple[list[str], str]:
    command = benchmark_command(binary, port)
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
        raise RuntimeError(f"redis-benchmark exited with code {completed.returncode}")
    return command, completed.stdout


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
    command, output = run_benchmark(benchmark_binary, port)
    results = parse_default_operation_results(output)

    raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw_output.write_text(f"$ {' '.join(command)}\n{output}", encoding="utf-8")
    payload = {
        "benchmark": "redis_default_benchmark_with_database_blue_load",
        "software": "redis",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "reference_case": "database_blue virtuall_redis_ori_0001.py",
            "client_host": "127.0.0.1 (single-runner adaptation)",
            "operations": "redis-benchmark default operation set (no -t)",
            "requests": REQUEST_COUNT,
            "clients": CLIENT_COUNT,
            "keyspace_length": KEYSPACE_LENGTH,
            "threads": THREAD_COUNT,
            "metric_source": "throughput summary: <value> requests per second",
        },
        "results": results,
    }
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[redis-benchmark] normalized {len(results)} default-operation metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
