#!/usr/bin/env python3
"""Run one measured APR-util harness command and record wall time and peak RSS.

Every measurement of the case goes through this wrapper so both architectures
use exactly the same procedure: one child process (optionally started inside a
fresh network namespace with ``unshare -n`` for the offline measurement
guarantee), an optional working directory (``--cwd``; APR-util's upstream
``testall`` loads data files relative to its own directory), complete stdout
and stderr captured into a log, wall clock measured around the child, and the
peak resident set size read from the kernel's own high-water mark
(``VmHWM``) of that child.

``resource.getrusage(RUSAGE_CHILDREN)`` is deliberately not used: a child forked
from the (large) Python interpreter inherits the parent's resident pages before
exec, so its reported maximum is the interpreter's RSS rather than the
workload's.  ``VmHWM`` belongs to the address space of the executed program and
is therefore the honest per-workload peak; the only floor is the small pre-exec
footprint of ``unshare`` (about 1.7 MiB), recorded as a known bias.

Non-zero child exits are recorded verbatim; the parser rejects such a
repetition.  Nothing is estimated or zero-padded.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

POLL_INTERVAL_SECONDS = 0.005


def atomic_write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def read_peak_rss_kib(pid: int) -> int | None:
    try:
        with open(f"/proc/{pid}/status", encoding="ascii", errors="replace") as handle:
            for line in handle:
                if line.startswith("VmHWM:"):
                    return int(line.split()[1])
    except (OSError, ValueError, IndexError):
        return None
    return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--stdout-file", type=Path, default=None)
    parser.add_argument("--timeout", type=float, default=3600.0)
    parser.add_argument(
        "--offline",
        action="store_true",
        help="run the child inside a fresh network namespace (unshare -n)",
    )
    parser.add_argument(
        "--offline-prep",
        type=Path,
        default=None,
        help="launcher exec-ed inside the network namespace before the command",
    )
    parser.add_argument(
        "--cwd",
        type=Path,
        default=None,
        help="working directory for the measured child (default: inherit)",
    )
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
    command = list(args.command)

    if args.offline:
        unshare = shutil.which("unshare")
        if unshare is None:
            print("[apr-util-timing] ERROR: --offline requested but unshare is unavailable", flush=True)
            return 127
        prefix = [unshare, "-n", "--"]
        if args.offline_prep is not None:
            if not args.offline_prep.is_file():
                print(
                    f"[apr-util-timing] ERROR: offline launcher is missing: {args.offline_prep}",
                    flush=True,
                )
                return 127
            prefix.append(str(args.offline_prep))
        command = [*prefix, *command]

    exit_code = 0
    timed_out = False
    peak_rss_kib: int | None = None
    rss_samples = 0
    stdout_handle = None
    try:
        with args.log.open("w", encoding="utf-8") as log:
            log.write(f"# command: {' '.join(command)}\n")
            log.write(f"# started_at: {started_at}\n")
            log.write(f"# offline: {bool(args.offline)}\n")
            log.write(f"# cwd: {args.cwd if args.cwd is not None else '(inherit)'}\n")
            if args.offline_prep is not None:
                log.write(f"# offline_prep: {args.offline_prep}\n")
            if args.stdout_file is not None:
                log.write(f"# stdout_file: {args.stdout_file}\n")
                args.stdout_file.parent.mkdir(parents=True, exist_ok=True)
                stdout_handle = args.stdout_file.open("wb")
                child_stdout = stdout_handle
                child_stderr = log
            else:
                # The measured harness writes a small summary line to stdout;
                # capture it together with stderr in the raw log.
                child_stdout = log
                child_stderr = subprocess.STDOUT
            log.flush()
            started = time.monotonic()
            try:
                process = subprocess.Popen(
                    command,
                    stdout=child_stdout,
                    stderr=child_stderr,
                    start_new_session=True,
                    cwd=str(args.cwd) if args.cwd is not None else None,
                )
            except OSError as exc:
                log.write(f"# ERROR: {exc}\n")
                wall_seconds = time.monotonic() - started
                atomic_write_json(
                    args.json,
                    {
                        "command": command,
                        "started_at": started_at,
                        "offline": bool(args.offline),
                        "cwd": str(args.cwd) if args.cwd is not None else "",
                        "exit_code": 127,
                        "timed_out": False,
                        "wall_seconds": round(wall_seconds, 6),
                        "max_rss_kib": 0,
                        "max_rss_mib": 0.0,
                        "rss_samples": 0,
                    },
                )
                print(f"[apr-util-timing] {args.json.stem}: ERROR {exc}", flush=True)
                return 127
            while True:
                current = read_peak_rss_kib(process.pid)
                if current is not None:
                    rss_samples += 1
                    peak_rss_kib = current if peak_rss_kib is None else max(peak_rss_kib, current)
                if process.poll() is not None:
                    break
                if time.monotonic() - started > args.timeout:
                    timed_out = True
                    process.kill()
                    process.wait(timeout=30)
                    log.write(f"# TIMEOUT after {args.timeout} seconds\n")
                    break
                time.sleep(POLL_INTERVAL_SECONDS)
            current = read_peak_rss_kib(process.pid)
            if current is not None:
                rss_samples += 1
                peak_rss_kib = current if peak_rss_kib is None else max(peak_rss_kib, current)
            exit_code = 124 if timed_out else (
                process.returncode if process.returncode is not None else 1
            )
        wall_seconds = time.monotonic() - started
    finally:
        if stdout_handle is not None:
            stdout_handle.close()

    if peak_rss_kib is None or rss_samples == 0:
        print("[apr-util-timing] ERROR: could not read the peak RSS of the measured child", flush=True)
        return 70
    max_rss_mib = round(peak_rss_kib / 1024.0, 3)
    atomic_write_json(
        args.json,
        {
            "command": command,
            "started_at": started_at,
            "offline": bool(args.offline),
            "cwd": str(args.cwd) if args.cwd is not None else "",
            "exit_code": exit_code,
            "timed_out": timed_out,
            "timeout_seconds": args.timeout,
            "wall_seconds": round(wall_seconds, 6),
            "max_rss_kib": peak_rss_kib,
            "max_rss_mib": max_rss_mib,
            "rss_samples": rss_samples,
            "rss_source": "proc_vmhwm_poll",
            "stdout_file": str(args.stdout_file) if args.stdout_file is not None else "",
        },
    )
    print(
        f"[apr-util-timing] {args.json.stem}: wall={wall_seconds:.3f}s "
        f"rss={max_rss_mib:.1f}MiB exit={exit_code}",
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
