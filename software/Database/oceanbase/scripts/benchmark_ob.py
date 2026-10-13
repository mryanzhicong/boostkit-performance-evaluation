#!/usr/bin/env python3
"""Run stock OceanBase Sysbench workloads through the local OBProxy."""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import shlex
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

WORKLOADS = ("read_only", "insert", "read_write", "write_only")
THREADS = (1, 64, 256)
TABLE_SIZE = 500000
DURATION_SECONDS = 300
PAUSE_SECONDS = 60
IGNORED_ERRORS = "1062,6002,6001,4012,1213,1020,1205,4038,6004"
FIELD_DEFS = {
    "tps": (r"transactions:\s+\d+\s+\(([\d.]+) per sec\.\)", "transactions/s", "higher_is_better"),
    "qps": (r"queries:\s+\d+\s+\(([\d.]+) per sec\.\)", "queries/s", "higher_is_better"),
    "avg_latency_ms": (r"^\s*avg:\s+([\d.]+)\s*$", "ms", "lower_is_better"),
    "p95_latency_ms": (r"^\s*95th percentile:\s+([\d.]+)\s*$", "ms", "lower_is_better"),
}


def parse_summary(text: str, workload: str, threads: int) -> dict[str, float]:
    values: dict[str, float] = {}
    for field, (pattern, _, _) in FIELD_DEFS.items():
        matches = re.findall(pattern, text, re.MULTILINE)
        if len(matches) != 1:
            raise ValueError(f"{workload}/{threads}: expected one {field} field, found {len(matches)}")
        value = float(matches[0])
        if not math.isfinite(value) or value <= 0:
            raise ValueError(f"{workload}/{threads}: invalid {field}={value}")
        values[field] = value
    return values


def run_command(command: list[str], raw, output_path: Path, label: str) -> str:
    print(f"[oceanbase-benchmark] {label}", flush=True)
    print(f"[oceanbase-benchmark] {shlex.join(command)}", flush=True)
    lines: list[str] = []
    header = f"# {label}: {shlex.join(command)}\n"
    with output_path.open("w", encoding="utf-8") as case_log:
        raw.write(header)
        case_log.write(header)
        raw.flush()
        with subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, bufsize=1,
            env={**os.environ, "LUA_PATH": f"{os.environ['SYSBENCH_LUA_DIR']}/?.lua;;"},
        ) as process:
            assert process.stdout is not None
            for line in process.stdout:
                print(line, end="", flush=True)
                raw.write(line)
                raw.flush()
                case_log.write(line)
                lines.append(line)
            exit_code = process.wait()
    if exit_code:
        raise RuntimeError(f"{label}: Sysbench exited with code {exit_code}")
    return "".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--database", required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    args = parser.parse_args()
    args.results_dir.mkdir(parents=True, exist_ok=True)
    runs_dir = args.results_dir / "sysbench-runs"
    runs_dir.mkdir(exist_ok=True)
    lua_dir = Path(os.environ["SYSBENCH_LUA_DIR"])
    results: dict[str, dict] = {}

    try:
        with (args.results_dir / "sysbench_raw.log").open("w", encoding="utf-8") as raw:
            for workload in WORKLOADS:
                script = lua_dir / f"oltp_{workload}.lua"
                if not script.is_file():
                    raise RuntimeError(f"missing official Sysbench workload: {script}")
                for threads in THREADS:
                    common = [
                        os.environ["SYSBENCH_BIN"], "--db-driver=mysql", f"--mysql-host={args.host}",
                        f"--mysql-port={args.port}", f"--mysql-user={args.user}",
                        f"--mysql-db={args.database}", "--db-ps-mode=disable",
                        f"--threads={threads}", f"--table_size={TABLE_SIZE}",
                    ]
                    label = f"{workload}-threads{threads}"
                    for action in ("cleanup", "prepare", "run"):
                        command = common.copy()
                        if action == "run":
                            command.extend([
                                "--report-interval=1", f"--mysql-ignore-errors={IGNORED_ERRORS}",
                                f"--time={DURATION_SECONDS}", "--max-requests=0",
                                "--rand-type=uniform",
                            ])
                        command.extend((str(script), action))
                        output = run_command(
                            command, raw, runs_dir / f"{label}-{action}.log", f"{label}: {action}"
                        )
                        if action == "run":
                            measurements = parse_summary(output, workload, threads)
                            for field, value in measurements.items():
                                _, unit, direction = FIELD_DEFS[field]
                                name = f"{workload} :: threads={threads} :: {field}"
                                results[name] = {
                                    "source_name": name, "source_field": field,
                                    "group": workload, "value": value,
                                    "unit": unit, "direction": direction,
                                }
                    if not (workload == WORKLOADS[-1] and threads == THREADS[-1]):
                        print(f"[oceanbase-benchmark] resting {PAUSE_SECONDS} seconds", flush=True)
                        subprocess.run(["sleep", str(PAUSE_SECONDS)], check=True)
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"[oceanbase-benchmark] ERROR: {exc}", file=sys.stderr)
        return 1

    expected_count = len(WORKLOADS) * len(THREADS) * len(FIELD_DEFS)
    if len(results) != expected_count:
        print(f"[oceanbase-benchmark] ERROR: collected {len(results)}/{expected_count} metrics", file=sys.stderr)
        return 1
    payload = {
        "benchmark": "oceanbase_sysbench_via_obproxy", "software": "oceanbase",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "connection": "obproxy", "proxy_version": os.environ["OB_PROXY_VERSION"],
            "tenant": "test", "database": args.database,
            "workloads": list(WORKLOADS), "threads": list(THREADS),
            "table_size": TABLE_SIZE, "duration_seconds": DURATION_SECONDS,
            "pause_seconds": PAUSE_SECONDS, "iterations": 1,
            "db_ps_mode": "disable", "rand_type": "uniform",
            "mysql_ignore_errors": IGNORED_ERRORS,
        },
        "results": results,
    }
    (args.results_dir / "results.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[oceanbase-benchmark] collected {len(results)} metrics", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
