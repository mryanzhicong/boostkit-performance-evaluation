#!/usr/bin/env python3
"""Run one measured tsc invocation and record its wall time, peak RSS and input size.

The wrapper exists so that every measurement of the TypeScript matrix is
produced by exactly the same procedure on both architectures: one child process,
its complete stdout/stderr captured to a log, wall-clock measured around the
child, and the child's peak resident set size read from
``resource.getrusage(RUSAGE_CHILDREN)`` (which is per-process because this
wrapper waits for a single child and is itself a fresh process per repetition).

After the child exits the wrapper also counts the TypeScript source files of the
project it just compiled.  That count is produced outside the measured window
and is the input-correctness check: a scenario that silently compiles a
different project than the build stage measured must not be reported as a
sample.
"""

from __future__ import annotations

import argparse
import json
import resource
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def atomic_write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def count_source_files(root: Path) -> int:
    """Count the TypeScript sources of a project (declaration-only files excluded)."""
    if not root.is_dir():
        return 0
    total = 0
    for path in root.rglob("*.ts"):
        if not path.is_file():
            continue
        if path.name.endswith(".d.ts"):
            continue
        total += 1
    return total


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--timeout", type=float, default=1800.0)
    parser.add_argument("--count-root", type=Path, default=None)
    parser.add_argument("--label", default="")
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
    timeout_seconds = args.timeout
    exit_code = 0
    timed_out = False

    started = time.monotonic()
    with args.log.open("w", encoding="utf-8") as log:
        log.write(f"# command: {' '.join(args.command)}\n")
        log.write(f"# working_directory: {Path.cwd()}\n")
        log.write(f"# started_at: {started_at}\n")
        log.flush()
        try:
            completed = subprocess.run(
                args.command,
                stdout=log,
                stderr=subprocess.STDOUT,
                timeout=timeout_seconds,
                check=False,
            )
            exit_code = completed.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = 124
            log.write(f"# TIMEOUT after {timeout_seconds} seconds\n")
        except OSError as exc:
            exit_code = 127
            log.write(f"# ERROR: {exc}\n")
    wall_seconds = time.monotonic() - started

    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    max_rss_kib = int(usage.ru_maxrss)
    max_rss_mib = round(max_rss_kib / 1024.0, 3)
    source_files = None
    if args.count_root is not None:
        source_files = count_source_files(args.count_root)
    payload = {
        "label": args.label,
        "command": args.command,
        "working_directory": str(Path.cwd()),
        "started_at": started_at,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "timeout_seconds": timeout_seconds,
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_kib": max_rss_kib,
        "max_rss_mib": max_rss_mib,
        "source_files": source_files,
    }
    atomic_write_json(args.json, payload)
    print(
        f"[typescript-timing] {args.json.stem}: wall={wall_seconds:.3f}s "
        f"rss={max_rss_mib:.1f}MiB exit={exit_code} sources={source_files}",
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
