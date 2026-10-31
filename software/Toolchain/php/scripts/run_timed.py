#!/usr/bin/env python3
"""Run one measured PHP workload and record its wall time and peak RSS.

Every measurement of the PHP matrix is produced by exactly the same procedure
on both architectures: one child process, its complete stdout/stderr captured
to a log, wall-clock time measured around the child, and the child's peak
resident set size reported by GNU ``time`` (``%M``), which reads the rusage of
the workload process itself.

``ru_maxrss`` from ``resource.getrusage(RUSAGE_CHILDREN)`` cannot be used
here: when this Python wrapper forks, the not-yet-exec'ed child still shares
the interpreter's pages, and that inherited peak is retained in ``ru_maxrss``
after exec.  For short PHP scenarios it would dominate the real workload RSS,
so RSS is taken from ``/usr/bin/time -f %M`` instead, which forks a small C
program that only ever tracks the workload.
"""

from __future__ import annotations

import argparse
import json
import os
import signal
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

GNU_TIME = "/usr/bin/time"


def atomic_write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--timeout", type=float, default=1800.0)
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
    if not os.access(GNU_TIME, os.X_OK):
        print(
            f"[php-timing] ERROR: {GNU_TIME} is required to measure peak RSS "
            "(install the 'time' package)",
            flush=True,
        )
        return 127
    args.log.parent.mkdir(parents=True, exist_ok=True)
    rss_path = args.log.with_name(f".{args.log.name}.rss")
    rss_path.unlink(missing_ok=True)
    started_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    timeout_seconds = args.timeout
    exit_code = 0
    timed_out = False

    wrapped_command = [GNU_TIME, "-f", "%M", "-o", str(rss_path), "--", *args.command]
    started = time.monotonic()
    with args.log.open("w", encoding="utf-8") as log:
        log.write(f"# command: {' '.join(args.command)}\n")
        log.write(f"# started_at: {started_at}\n")
        log.flush()
        process: subprocess.Popen[str] | None = None
        try:
            process = subprocess.Popen(
                wrapped_command,
                stdout=log,
                stderr=subprocess.STDOUT,
                start_new_session=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
            exit_code = process.wait(timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = 124
            log.write(f"# TIMEOUT after {timeout_seconds} seconds\n")
            if process is not None:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
        except OSError as exc:
            exit_code = 127
            log.write(f"# ERROR: {exc}\n")
    wall_seconds = time.monotonic() - started

    max_rss_kib = 0
    try:
        max_rss_kib = int(rss_path.read_text(encoding="utf-8").strip())
    except (OSError, ValueError):
        if not timed_out:
            exit_code = 127 if exit_code == 0 else exit_code
            with args.log.open("a", encoding="utf-8") as log:
                log.write("# ERROR: GNU time did not report a max RSS value\n")
    finally:
        rss_path.unlink(missing_ok=True)

    max_rss_mib = round(max_rss_kib / 1024.0, 3)
    payload = {
        "command": args.command,
        "started_at": started_at,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "timeout_seconds": timeout_seconds,
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_kib": max_rss_kib,
        "max_rss_mib": max_rss_mib,
        "rss_source": "GNU time %M (wall-clock: time.monotonic around the workload)",
    }
    atomic_write_json(args.json, payload)
    print(
        f"[php-timing] {args.json.stem}: wall={wall_seconds:.3f}s "
        f"rss={max_rss_mib:.1f}MiB exit={exit_code}",
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
