#!/usr/bin/env python3
"""Run one catj CLI timing sample in a fresh, isolated process and record it.

The wall time contains the whole invocation - Node.js start-up, JSON parsing,
flattening and writing the complete stdout stream to disk - which is exactly the
load described by the catj release manual.  The peak RSS is taken from
``wait4`` and cross-checked against ``/proc/<pid>/status`` while the child runs.
"""

import argparse
import json
import os
import signal
import sys
import time
from pathlib import Path

PREMATURE_EXIT = 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--label", required=True)
    parser.add_argument("--timeout", type=int, required=True)
    parser.add_argument("--json-out", required=True)
    parser.add_argument("--stdout-out", required=True)
    parser.add_argument("--stderr-out", required=True)
    parser.add_argument("--stdin-file")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.command and args.command[0] == "--":
        args.command = args.command[1:]
    if not args.command:
        parser.error("a command is required after --")
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    return args


def peak_rss_kib(pid: int) -> int:
    try:
        with open(f"/proc/{pid}/status", encoding="utf-8") as handle:
            for line in handle:
                if line.startswith("VmHWM:"):
                    return int(line.split()[1])
    except OSError:
        return 0
    return 0


def measure(args: argparse.Namespace) -> dict:
    stdout_path = Path(args.stdout_out)
    stderr_path = Path(args.stderr_out)
    stdout_path.parent.mkdir(parents=True, exist_ok=True)
    stderr_path.parent.mkdir(parents=True, exist_ok=True)
    stdin_fd = os.open(args.stdin_file, os.O_RDONLY) if args.stdin_file else os.open(os.devnull, os.O_RDONLY)
    stdout_fd = os.open(stdout_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
    stderr_fd = os.open(stderr_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
    environment = dict(os.environ)
    started = time.perf_counter()
    pid = os.fork()
    if pid == 0:  # pragma: no cover - child process
        try:
            os.setsid()
            os.dup2(stdin_fd, 0)
            os.dup2(stdout_fd, 1)
            os.dup2(stderr_fd, 2)
            for fd in (stdin_fd, stdout_fd, stderr_fd):
                os.close(fd)
            os.execvpe(args.command[0], args.command, environment)
        except BaseException:
            os._exit(127)
    os.close(stdin_fd)
    os.close(stdout_fd)
    os.close(stderr_fd)

    timed_out = False
    exit_code = 255
    status = 0
    rusage = None
    deadline = started + args.timeout
    peak = 0
    while True:
        done_pid, status, rusage = os.wait4(pid, os.WNOHANG)
        peak = max(peak, peak_rss_kib(pid))
        if done_pid == pid:
            break
        if time.perf_counter() > deadline:
            timed_out = True
            try:
                os.killpg(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            try:
                os.killpg(pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            done_pid, status, rusage = os.wait4(pid, 0)
            if done_pid != pid:
                raise SystemExit("failed to reap the timed-out measurement process")
            break
        time.sleep(0.005)
    wall_seconds = time.perf_counter() - started
    if os.WIFEXITED(status):
        exit_code = os.WEXITSTATUS(status)
    elif os.WIFSIGNALED(status):
        exit_code = 128 + os.WTERMSIG(status)
    else:
        exit_code = 255
    rss_kib = max(int(rusage.ru_maxrss), peak)
    return {
        "label": args.label,
        "command": args.command,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "timeout_seconds": args.timeout,
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_mib": round(rss_kib / 1024.0, 3),
        "stdin": "file" if args.stdin_file else "none",
    }


def main() -> int:
    args = parse_args()
    result = measure(args)
    Path(args.json_out).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(
        f"[catj-timing] {result['label']}: wall={result['wall_seconds']:.3f}s "
        f"rss={result['max_rss_mib']:.1f}MiB exit={result['exit_code']} "
        f"timed_out={result['timed_out']}"
    )
    if result["timed_out"]:
        return PREMATURE_EXIT
    return 0 if result["exit_code"] == 0 else PREMATURE_EXIT


if __name__ == "__main__":
    raise SystemExit(main())
