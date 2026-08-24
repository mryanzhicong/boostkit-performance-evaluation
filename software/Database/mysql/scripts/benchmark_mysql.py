#!/usr/bin/env python3
"""Run configured sysbench OLTP commands and preserve their raw output."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

WORKLOADS = ["oltp_point_select", "oltp_read_write", "oltp_read_only", "oltp_write_only"]
THREAD_LEVELS = [1, 4, 16, 32]
TPS_RE = re.compile(r"transactions:\s+\d+\s+\(([\d.]+)\s+per sec\.\)")
QPS_RE = re.compile(r"queries:\s+\d+\s+\(([\d.]+)\s+per sec\.\)")
AVG_LAT_RE = re.compile(r"avg:\s+([\d.]+)")
P95_LAT_RE = re.compile(r"95th percentile:\s+([\d.]+)")


def architecture() -> str:
    value = os.environ.get("EXPECTED_ARCH", "")
    return value if value in ("x86_64", "aarch64") else os.uname().machine.lower()


def write_raw_output(path: Path, lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def record_command_output(lines: list[str], command: list[str], output: str) -> None:
    displayed = [
        "--mysql-password=***" if argument.startswith("--mysql-password=") else argument
        for argument in command
    ]
    lines.extend(("$ " + " ".join(displayed), output.rstrip(), ""))


def mysql_command(host: str, port: str, user: str, password: str) -> list[str]:
    command = [os.environ.get("MYSQL_CLIENT_BIN", "mysql"), f"-h{host}", f"-P{port}", f"-u{user}"]
    if password:
        command.append(f"-p{password}")
    return command


def check_mysql(host: str, port: str, user: str, password: str) -> bool:
    result = subprocess.run(
        mysql_command(host, port, user, password) + ["-e", "SELECT 1"],
        capture_output=True, text=True, timeout=10, check=False,
    )
    return result.returncode == 0


def create_database(host: str, port: str, user: str, password: str, db_name: str) -> bool:
    result = subprocess.run(
        mysql_command(host, port, user, password)
        + ["-e", f"CREATE DATABASE IF NOT EXISTS {db_name}"],
        capture_output=True, text=True, timeout=10, check=False,
    )
    return result.returncode == 0


def sysbench_prepare(
    host: str, port: str, user: str, password: str, db_name: str, tables: int,
    table_size: int, raw_lines: list[str],
) -> None:
    command = [
        "sysbench", "oltp_point_select", "--db-driver=mysql",
        f"--mysql-host={host}", f"--mysql-port={port}",
        f"--mysql-user={user}", f"--mysql-password={password}",
        f"--mysql-db={db_name}", f"--tables={tables}", f"--table-size={table_size}",
        "--db-ps-mode=disable", "prepare",
    ]
    completed = subprocess.run(
        command, capture_output=True, text=True, timeout=600, check=False
    )
    record_command_output(raw_lines, command, completed.stdout + completed.stderr)
    if completed.returncode != 0:
        raise RuntimeError(f"sysbench prepare failed with exit code {completed.returncode}")


def sysbench_run(
    host: str, port: str, user: str, password: str, db_name: str, workload: str,
    threads: int, tables: int, table_size: int, time_sec: int, raw_lines: list[str],
) -> dict[str, float]:
    command = [
        "sysbench", workload, "--db-driver=mysql",
        f"--mysql-host={host}", f"--mysql-port={port}",
        f"--mysql-user={user}", f"--mysql-password={password}",
        f"--mysql-db={db_name}", f"--tables={tables}", f"--table-size={table_size}",
        f"--threads={threads}", f"--time={time_sec}",
        "--db-ps-mode=disable", "--report-interval=0", "run",
    ]
    completed = subprocess.run(
        command, capture_output=True, text=True, timeout=time_sec + 120, check=False
    )
    output = completed.stdout + completed.stderr
    record_command_output(raw_lines, command, output)
    if completed.returncode != 0:
        raise RuntimeError(
            f"sysbench {workload} --threads={threads} failed with exit code {completed.returncode}"
        )
    matches = {
        "transactions (per sec.)": TPS_RE.search(output),
        "queries (per sec.)": QPS_RE.search(output),
        "avg:": AVG_LAT_RE.search(output),
        "95th percentile:": P95_LAT_RE.search(output),
    }
    missing = [name for name, match in matches.items() if match is None]
    if missing:
        raise RuntimeError(
            f"sysbench {workload} --threads={threads} is missing: {', '.join(missing)}"
        )
    return {name: float(match.group(1)) for name, match in matches.items()}


def add_metrics(
    results: dict[str, dict[str, Any]], workload: str, threads: int, tables: int,
    values: dict[str, float],
) -> None:
    context = f"sysbench {workload} --threads={threads} --tables={tables}"
    definitions = (
        ("transactions (per sec.)", "transactions/s", "higher_is_better"),
        ("queries (per sec.)", "queries/s", "higher_is_better"),
        ("avg:", "ms", "lower_is_better"),
        ("95th percentile:", "ms", "lower_is_better"),
    )
    for raw_name, unit, direction in definitions:
        source_name = f"{context}: {raw_name}"
        if source_name in results:
            raise RuntimeError(f"duplicate sysbench metric: {source_name}")
        results[source_name] = {
            "source_name": source_name,
            "source_field": raw_name,
            "value": values[raw_name],
            "unit": unit,
            "direction": direction,
        }


def main() -> int:
    if len(sys.argv) != 12:
        print(
            "usage: benchmark_mysql.py OUTPUT RAW_OUTPUT HOST PORT USER PASSWORD DB "
            "TABLES TABLE_SIZE ITERATIONS TIME_SECONDS",
            file=sys.stderr,
        )
        return 1
    output_path, raw_output_path = Path(sys.argv[1]), Path(sys.argv[2])
    host, port, user, password, db_name = sys.argv[3:8]
    tables, table_size, iterations, time_sec = map(int, sys.argv[8:12])
    raw_lines: list[str] = ["# sysbench raw output: MySQL OLTP"]
    try:
        if iterations != 1:
            raise RuntimeError("ITERATIONS must be 1; derived averages are not accepted metrics")
        if not check_mysql(host, port, user, password):
            raise RuntimeError(f"cannot connect to MySQL at {host}:{port}")
        if not create_database(host, port, user, password, db_name):
            raise RuntimeError(f"cannot create database {db_name}")
        sysbench_prepare(host, port, user, password, db_name, tables, table_size, raw_lines)
        results: dict[str, dict[str, Any]] = {}
        for workload in WORKLOADS:
            for threads in THREAD_LEVELS:
                values = sysbench_run(
                    host, port, user, password, db_name, workload, threads,
                    tables, table_size, time_sec, raw_lines,
                )
                add_metrics(results, workload, threads, tables, values)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps({
            "software": "mysql",
            "version": os.environ["SOFTWARE_VERSION"],
            "architecture": architecture(),
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "parameters": {
                "workloads": WORKLOADS,
                "thread_levels": THREAD_LEVELS,
                "tables": tables,
                "table_size": table_size,
                "time_per_test": time_sec,
                "iterations": iterations,
            },
            "results": results,
        }, indent=2) + "\n", encoding="utf-8")
        print(f"[mysql] recorded {len(results)} sysbench metrics")
        return 0
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as exc:
        print(f"[mysql] ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        write_raw_output(raw_output_path, raw_lines)


if __name__ == "__main__":
    raise SystemExit(main())
