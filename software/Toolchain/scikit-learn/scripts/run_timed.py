#!/usr/bin/env python3
"""Run one benchmark command and record wall clock, peak RSS and exit status.

The script is intentionally generic: the scikit-learn case uses it for every
scenario repetition so that ``runs/<scenario>/rep<i>.json`` always has the same
shape.  Wall clock is measured with ``time.monotonic`` around the child process,
peak RSS comes from ``resource.getrusage(RUSAGE_CHILDREN)`` (reported in MiB).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import resource
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)
        handle.write("\n")
    os.replace(tmp, path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--label", required=True)
    parser.add_argument("--log", required=True)
    parser.add_argument("--json", required=True)
    parser.add_argument("--timeout", type=float, default=600.0)
    parser.add_argument("--working-directory", default=None)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()

    command = list(args.command)
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        print("run_timed.py: no command given", file=sys.stderr)
        return 10

    log_path = Path(args.log)
    json_path = Path(args.json)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    working_directory = Path(args.working_directory) if args.working_directory else None
    started_at = utc_now()
    rss_before = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    started = time.monotonic()
    exit_code = 0
    timed_out = False

    with log_path.open("w", encoding="utf-8") as handle:
        handle.write(f"# label: {args.label}\n")
        handle.write(f"# command: {' '.join(command)}\n")
        handle.write(f"# working_directory: {working_directory or os.getcwd()}\n")
        handle.write(f"# started_at: {started_at}\n")
        handle.flush()
        try:
            result = subprocess.run(
                command,
                cwd=str(working_directory) if working_directory else None,
                stdout=handle,
                stderr=subprocess.STDOUT,
                timeout=args.timeout,
                check=False,
            )
            exit_code = result.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = 124
            handle.write(f"\n# timed out after {args.timeout} seconds\n")
        except FileNotFoundError as exc:
            handle.write(f"\n# command not found: {exc}\n")
            exit_code = 127

    wall_seconds = time.monotonic() - started
    rss_after = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    max_rss_mib = max(rss_before, rss_after) / 1024.0

    payload = {
        "label": args.label,
        "command": command,
        "working_directory": str(working_directory or os.getcwd()),
        "started_at": started_at,
        "finished_at": utc_now(),
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_mib": round(max_rss_mib, 3),
        "exit_code": exit_code,
        "timed_out": timed_out,
        "timeout_seconds": args.timeout,
    }
    write_json(json_path, payload)
    print(
        f"[sklearn-timing] {args.label}: wall={wall_seconds:.3f}s "
        f"rss={max_rss_mib:.1f}MiB exit={exit_code} timed_out={timed_out}",
        flush=True,
    )
    return 0 if exit_code == 0 and not timed_out else (50 if timed_out else exit_code)


if __name__ == "__main__":
    raise SystemExit(main())
