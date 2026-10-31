#!/usr/bin/env python3
"""Run one measured command and record wall clock, peak RSS and exit status.

Each invocation is a fresh process, so ``resource.getrusage(RUSAGE_CHILDREN)``
reports the maximum resident set size of *this* command's child processes (for GDB
that includes the interpreter and, when the workload starts an inferior, the
inferior process).  The command output is written verbatim to the log file, which
is the first-hand evidence the parser checks: besides the measured value the log
must contain the independent evidence lines the fixture uses (GDB version banner,
``+step`` trace lines, ``[gdb-py-eval]`` summary, breakpoint lines, ...).
"""

from __future__ import annotations

import argparse
import json
import os
import resource
import subprocess
import sys
import time
from pathlib import Path


def count_files(root: Path, suffixes: tuple[str, ...]) -> int:
    if not root.is_dir():
        return -1
    total = 0
    for path in root.iterdir():
        if path.is_file() and path.suffix in suffixes:
            total += 1
    return total


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--label", required=True)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--timeout", type=float, default=1800.0)
    parser.add_argument("--count-root", type=Path)
    parser.add_argument("--count-suffix", default=".c,.h,.cmd,.py,.json")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    arguments = parser.parse_args()

    command = list(arguments.command)
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        print("[gdb-timing] ERROR: no command given", flush=True)
        return 2

    suffixes = tuple(
        suffix.strip() for suffix in arguments.count_suffix.split(",") if suffix.strip()
    )
    arguments.log.parent.mkdir(parents=True, exist_ok=True)
    payload: dict[str, object] = {
        "label": arguments.label,
        "command": command,
        "working_directory": os.getcwd(),
        "started_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }

    timed_out = False
    exit_code: int | None = None
    begin = time.perf_counter()
    with arguments.log.open("w", encoding="utf-8", buffering=1) as log:
        log.write(f"# command: {' '.join(command)}\n")
        log.write(f"# working_directory: {os.getcwd()}\n")
        log.write(f"# started_at: {payload['started_at']}\n")
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        deadline = begin + arguments.timeout
        try:
            assert process.stdout is not None
            while True:
                line = process.stdout.readline()
                if line:
                    log.write(line)
                    sys.stdout.write(line)
                    sys.stdout.flush()
                    continue
                if process.poll() is not None:
                    break
                if time.perf_counter() > deadline:
                    timed_out = True
                    process.kill()
                    break
        finally:
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
            exit_code = process.returncode
            if timed_out:
                log.write("\n[gdb-timing] ERROR: the measured command timed out\n")
    wall = time.perf_counter() - begin

    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    payload.update(
        {
            "finished_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "wall_seconds": round(wall, 6),
            "max_rss_mib": round(usage.ru_maxrss / 1024.0, 3),
            "exit_code": exit_code,
            "timed_out": timed_out,
            "fixture_sources": count_files(arguments.count_root, suffixes)
            if arguments.count_root
            else None,
        }
    )
    arguments.json.parent.mkdir(parents=True, exist_ok=True)
    arguments.json.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(
        f"[gdb-timing] {arguments.label}: wall={wall:.3f}s "
        f"rss={payload['max_rss_mib']:.1f}MiB exit={exit_code} "
        f"fixtures={payload['fixture_sources']}",
        flush=True,
    )
    return 0 if (exit_code == 0 and not timed_out) else 1


if __name__ == "__main__":
    sys.exit(main())
