#!/usr/bin/env python3
"""Run non-duplicated sysbench scaling commands and preserve raw output."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from benchmark_mysql import (  # noqa: E402
    add_metrics,
    check_mysql,
    create_database,
    sysbench_prepare,
    sysbench_run,
    write_raw_output,
)

THREAD_SCALE_LEVELS = [8, 64]
TABLE_COUNTS = [1, 4, 10]


def main() -> int:
    if len(sys.argv) != 11:
        print(
            "usage: micro_benchmark.py OUTPUT RAW_OUTPUT HOST PORT USER PASSWORD "
            "TABLES TABLE_SIZE ITERATIONS TIME_SECONDS",
            file=sys.stderr,
        )
        return 1
    output_path, raw_output_path = Path(sys.argv[1]), Path(sys.argv[2])
    host, port, user, password = sys.argv[3:7]
    tables, table_size, iterations, time_sec = map(int, sys.argv[7:11])
    raw_lines: list[str] = ["# sysbench raw output: MySQL scaling commands"]
    try:
        if iterations != 1:
            raise RuntimeError("ITERATIONS must be 1; derived averages are not accepted metrics")
        if not check_mysql(host, port, user, password):
            raise RuntimeError(f"cannot connect to MySQL at {host}:{port}")
        results: dict[str, dict[str, Any]] = {}

        scaling_database = "sbtest_thread_scaling"
        if not create_database(host, port, user, password, scaling_database):
            raise RuntimeError(f"cannot create database {scaling_database}")
        sysbench_prepare(
            host, port, user, password, scaling_database, tables, table_size, raw_lines
        )
        for threads in THREAD_SCALE_LEVELS:
            values = sysbench_run(
                host, port, user, password, scaling_database, "oltp_point_select",
                threads, tables, table_size, time_sec, raw_lines,
            )
            add_metrics(results, "oltp_point_select", threads, tables, values)

        for table_count in TABLE_COUNTS:
            if table_count == tables:
                continue
            database = f"sbtest_tables_{table_count}"
            if not create_database(host, port, user, password, database):
                raise RuntimeError(f"cannot create database {database}")
            sysbench_prepare(
                host, port, user, password, database, table_count, table_size, raw_lines
            )
            values = sysbench_run(
                host, port, user, password, database, "oltp_point_select", 16,
                table_count, table_size, time_sec, raw_lines,
            )
            add_metrics(results, "oltp_point_select", 16, table_count, values)

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps({
            "software": "mysql",
            "version": os.environ["SOFTWARE_VERSION"],
            "architecture": os.environ["EXPECTED_ARCH"],
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "parameters": {
                "thread_scale_levels": THREAD_SCALE_LEVELS,
                "table_counts": [count for count in TABLE_COUNTS if count != tables],
                "table_size": table_size,
                "time_per_test": time_sec,
                "iterations": iterations,
            },
            "results": results,
        }, indent=2) + "\n", encoding="utf-8")
        print(f"[mysql] recorded {len(results)} sysbench scaling metrics")
        return 0
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as exc:
        print(f"[mysql] ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        write_raw_output(raw_output_path, raw_lines)


if __name__ == "__main__":
    raise SystemExit(main())
