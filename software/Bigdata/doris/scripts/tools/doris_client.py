#!/usr/bin/env python3
"""Small Doris control client used by the start and test stages."""

from __future__ import annotations

import argparse
import csv
import sys
import time
from pathlib import Path

import pymysql


def connect(port: int, database: str | None = None):
    return pymysql.connect(host="127.0.0.1", port=port, user="root", password="",
                           database=database, charset="utf8mb4", autocommit=True)


def wait_fe(port: int, timeout: int) -> int:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            connection = connect(port)
            connection.close()
            print("FE_READY")
            return 0
        except Exception:
            time.sleep(1)
    print("FE_NOT_READY", file=sys.stderr)
    return 1


def add_backend(port: int, host: str, heartbeat_port: int) -> int:
    connection = connect(port)
    with connection.cursor() as cursor:
        cursor.execute(f'ALTER SYSTEM ADD BACKEND "{host}:{heartbeat_port}"')
    connection.close()
    print("BACKEND_ADDED")
    return 0


def wait_backend(port: int, timeout: int) -> int:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            connection = connect(port)
            with connection.cursor() as cursor:
                cursor.execute("SHOW BACKENDS")
                columns = [column[0].lower() for column in cursor.description]
                rows = cursor.fetchall()
            connection.close()
            alive = columns.index("alive") if "alive" in columns else None
            if rows and alive is not None and all(str(row[alive]).lower() in ("true", "1") for row in rows):
                print("BACKEND_READY")
                return 0
        except Exception:
            pass
        time.sleep(2)
    print("BACKEND_NOT_READY", file=sys.stderr)
    return 1


def execute_file(port: int, path: Path, database: str | None) -> int:
    sql = path.read_text(encoding="utf-8")
    connection = connect(port, database)
    with connection.cursor() as cursor:
        cursor.execute(sql)
        while cursor.nextset():
            pass
    connection.close()
    print("SQL_OK")
    return 0


def query(port: int, sql: str, database: str | None) -> int:
    connection = connect(port, database)
    with connection.cursor() as cursor:
        cursor.execute(sql)
        for row in cursor.fetchall():
            print("\t".join("" if value is None else str(value) for value in row))
    connection.close()
    return 0


def run_tpch(port: int, database: str, queries: Path, rounds: int, output: Path,
             parallel_tasks: int, exec_mem_limit: int, timeout_seconds: int) -> int:
    rows = []
    connection = connect(port, database)
    with connection.cursor() as cursor:
        cursor.execute(f"SET parallel_pipeline_task_num = {parallel_tasks}")
        cursor.execute(f"SET exec_mem_limit = {exec_mem_limit}")
        cursor.execute(f"SET query_timeout = {timeout_seconds}")
        for round_number in range(1, rounds + 1):
            for query_number in range(1, 23):
                statement = (queries / f"q{query_number}.sql").read_text(encoding="utf-8")
                started = time.perf_counter()
                cursor.execute(statement)
                cursor.fetchall()
                elapsed_ms = (time.perf_counter() - started) * 1000.0
                rows.append((round_number, query_number, round(elapsed_ms, 3)))
                print(f"round={round_number} q={query_number:02d} wall_ms={elapsed_ms:.3f}",
                      flush=True)
    connection.close()
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["round", "query", "wall_ms"])
        writer.writerows(rows)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="action", required=True)

    p_wait = sub.add_parser("wait-fe")
    p_wait.add_argument("--port", type=int, required=True)
    p_wait.add_argument("--timeout", type=int, default=180)

    p_add = sub.add_parser("add-backend")
    p_add.add_argument("--port", type=int, required=True)
    p_add.add_argument("--host", default="127.0.0.1")
    p_add.add_argument("--heartbeat-port", type=int, required=True)

    p_backend = sub.add_parser("wait-backend")
    p_backend.add_argument("--port", type=int, required=True)
    p_backend.add_argument("--timeout", type=int, default=180)

    p_exec = sub.add_parser("exec")
    p_exec.add_argument("--port", type=int, required=True)
    p_exec.add_argument("--database", default=None)
    p_exec.add_argument("--file", type=Path, required=True)

    p_query = sub.add_parser("query")
    p_query.add_argument("--port", type=int, required=True)
    p_query.add_argument("--database", default=None)
    p_query.add_argument("--sql", required=True)

    p_run = sub.add_parser("run")
    p_run.add_argument("--port", type=int, required=True)
    p_run.add_argument("--database", required=True)
    p_run.add_argument("--queries", type=Path, required=True)
    p_run.add_argument("--rounds", type=int, required=True)
    p_run.add_argument("--output", type=Path, required=True)
    p_run.add_argument("--parallel-tasks", type=int, required=True)
    p_run.add_argument("--exec-mem-limit", type=int, required=True)
    p_run.add_argument("--timeout-seconds", type=int, required=True)

    args = parser.parse_args()
    if args.action == "wait-fe":
        return wait_fe(args.port, args.timeout)
    if args.action == "add-backend":
        return add_backend(args.port, args.host, args.heartbeat_port)
    if args.action == "wait-backend":
        return wait_backend(args.port, args.timeout)
    if args.action == "exec":
        return execute_file(args.port, args.file, args.database)
    if args.action == "query":
        return query(args.port, args.sql, args.database)
    return run_tpch(args.port, args.database, args.queries, args.rounds, args.output,
                    args.parallel_tasks, args.exec_mem_limit, args.timeout_seconds)


if __name__ == "__main__":
    raise SystemExit(main())
