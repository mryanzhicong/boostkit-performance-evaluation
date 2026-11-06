#!/usr/bin/env python3
"""Run one measured RINETD harness invocation and record wall time and peak RSS.

The wrapper keeps every scenario repetition identical on both architectures: a
single child process, its complete stdout/stderr kept in the run log, wall clock
measured around the child and the peak resident set size of the child read from
``resource.getrusage(RUSAGE_CHILDREN)``.
"""

from __future__ import annotations

import argparse
import json
import resource
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path


def atomic_write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--timeout", type=float, default=900.0)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = list(args.command)
    while command and command[0] == "--":
        command.pop(0)
    if not command:
        parser.error("a command to measure is required")
    args.command = command
    return args


def main() -> int:
    args = parse_args()
    args.log.parent.mkdir(parents=True, exist_ok=True)
    started_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    exit_code = 0
    timed_out = False

    started = time.monotonic()
    with args.log.open("w", encoding="utf-8") as log:
        log.write(f"# command: {' '.join(args.command)}\n")
        log.write(f"# started_at: {started_at}\n")
        log.flush()
        try:
            completed = subprocess.run(
                args.command, stdout=log, stderr=subprocess.STDOUT,
                timeout=args.timeout, check=False,
            )
            exit_code = completed.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = 124
            log.write(f"# TIMEOUT after {args.timeout} seconds\n")
        except OSError as exc:
            exit_code = 127
            log.write(f"# ERROR: {exc}\n")
    wall_seconds = time.monotonic() - started

    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    max_rss_kib = int(usage.ru_maxrss)
    payload = {
        "command": args.command,
        "started_at": started_at,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "timeout_seconds": args.timeout,
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_kib": max_rss_kib,
        "max_rss_mib": round(max_rss_kib / 1024.0, 3),
    }
    atomic_write_json(args.json, payload)
    print(
        f"[rinetd-timing] {args.json.stem}: wall={wall_seconds:.3f}s "
        f"rss={payload['max_rss_mib']:.1f}MiB exit={exit_code}",
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
