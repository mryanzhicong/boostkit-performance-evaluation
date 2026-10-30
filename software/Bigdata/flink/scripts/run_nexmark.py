#!/usr/bin/env python3
"""Run upstream Nexmark V1 queries with bounded waits and parse its result table."""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path
from urllib.request import ProxyHandler, build_opener

from results.parse_benchmark import BENCH_EVENTS, QUERIES, RESULT_RE, parse_result

WARMUP_EVENTS = 500_000
BENCH_TPS = 1_000_000
WARMUP_TPS = 5_000
SLOTS = 16
DIRECT_OPENER = build_opener(ProxyHandler({}))


def rest_json(port: int, endpoint: str) -> dict:
    try:
        with DIRECT_OPENER.open(f"http://127.0.0.1:{port}{endpoint}", timeout=3) as response:
            return json.load(response)
    except (OSError, ValueError):
        return {}


def job_states(port: int) -> dict[str, str]:
    return {
        entry["jid"]: entry["state"]
        for entry in rest_json(port, "/jobs/overview").get("jobs", [])
        if "jid" in entry and "state" in entry
    }


def wait_idle(port: int, seconds: int = 180) -> None:
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        overview = rest_json(port, "/overview")
        if overview.get("jobs-running") == 0 and overview.get("slots-available", 0) >= SLOTS:
            return
        time.sleep(2)
    raise RuntimeError("Flink did not return to 0 running jobs and 16 available slots")


def set_workload(conf: Path, events: int, tps: int) -> None:
    text = conf.read_text(encoding="utf-8")
    updates = {
        "nexmark.workload.suite.100m.events.num": events,
        "nexmark.workload.suite.100m.tps": tps,
        "nexmark.workload.suite.100m.warmup.duration": "0s",
        "nexmark.workload.suite.100m.warmup.events.num": 0,
        "nexmark.workload.suite.100m.warmup.tps": 0,
    }
    for key, value in updates.items():
        pattern = re.compile(rf"^{re.escape(key)}:.*$", re.MULTILINE)
        text, count = pattern.subn(f"{key}: {value}", text)
        if count != 1:
            raise RuntimeError(f"expected exactly one upstream Nexmark key: {key}")
    conf.write_text(text, encoding="utf-8")


def terminate(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    os.killpg(process.pid, signal.SIGTERM)
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait(timeout=5)


def run_query(home: Path, port: int, phase: str, query: str, log_path: Path, timeout: int) -> tuple[int, bool]:
    previous = set(job_states(port))
    env = dict(os.environ)
    env["NEXMARK_HOME"] = str(home)
    with log_path.open("w+", encoding="utf-8") as output:
        process = subprocess.Popen(
            ["bash", "bin/run_query.sh", query], cwd=home, env=env,
            stdout=output, stderr=subprocess.STDOUT, start_new_session=True,
        )
        deadline = time.monotonic() + timeout
        finished_at: float | None = None
        printed_at = 0
        observed_finish = False
        while process.poll() is None:
            output.flush()
            with log_path.open(encoding="utf-8", errors="replace") as reader:
                reader.seek(printed_at)
                chunk = reader.read()
                printed_at = reader.tell()
            if chunk:
                print(chunk, end="", flush=True)
            states = {jid: state for jid, state in job_states(port).items() if jid not in previous}
            if any(state in {"FAILED", "CANCELED"} for state in states.values()):
                terminate(process)
                raise RuntimeError(f"{phase}/{query}: Flink job failed: {states}")
            if "FINISHED" in states.values():
                observed_finish = True
                finished_at = finished_at or time.monotonic()
            if finished_at is not None and time.monotonic() - finished_at > (5 if phase == "warmup" else 15):
                terminate(process)
                break
            if time.monotonic() > deadline:
                terminate(process)
                raise RuntimeError(f"{phase}/{query}: exceeded {timeout}s; see {log_path}")
            time.sleep(1)
        with log_path.open(encoding="utf-8", errors="replace") as reader:
            reader.seek(printed_at)
            print(reader.read(), end="", flush=True)
        return process.returncode or 0, observed_finish


def execute(args: argparse.Namespace) -> None:
    home = args.nexmark_home
    result_dir = args.results_dir
    result_dir.mkdir(parents=True, exist_ok=True)
    raw = result_dir / "benchmark_flink_raw.log"
    with raw.open("w", encoding="utf-8") as record:
        for phase, events, tps, timeout in (
            ("warmup", WARMUP_EVENTS, WARMUP_TPS, 90),
            ("bench", BENCH_EVENTS, BENCH_TPS, 1800),
        ):
            set_workload(home / "conf/nexmark.yaml", events, tps)
            for index, query in enumerate(QUERIES, 1):
                wait_idle(args.rest_port)
                print(f"[flink] {phase} {index}/{len(QUERIES)}: {query}", flush=True)
                log_path = result_dir / f"{phase}-{query}.log"
                rc, observed_finish = run_query(home, args.rest_port, phase, query, log_path, timeout)
                output = log_path.read_text(encoding="utf-8", errors="replace")
                record.write(f"## {phase}/{query} rc={rc}\n{output}\n")
                record.flush()
                if phase == "warmup":
                    if not observed_finish and not any(RESULT_RE.match(line) for line in output.splitlines()):
                        raise RuntimeError(f"warmup/{query} has no FINISHED Flink job or Nexmark result row")
                    if rc != 0 and not observed_finish:
                        raise RuntimeError(f"warmup/{query}: Nexmark runner failed with exit {rc}")
                    continue
                parse_result(output, query, BENCH_EVENTS)
                if rc != 0 and not observed_finish:
                    raise RuntimeError(f"bench/{query}: Nexmark runner failed with exit {rc}")
    print(f"[flink] completed {len(QUERIES)} official Nexmark queries; parsing results next", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--nexmark-home", required=True, type=Path)
    parser.add_argument("--flink-home", required=True, type=Path)
    parser.add_argument("--rest-port", required=True, type=int)
    parser.add_argument("--results-dir", required=True, type=Path)
    args = parser.parse_args()
    os.environ["FLINK_HOME"] = str(args.flink_home)
    try:
        execute(args)
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"[flink] ERROR: {exc}", file=sys.stderr, flush=True)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
