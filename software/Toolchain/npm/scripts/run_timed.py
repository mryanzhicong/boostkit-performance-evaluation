#!/usr/bin/env python3
"""Run one measured npm command and record its wall time, peak RSS and tree size.

The wrapper exists so that every measurement of the npm matrix is produced by
exactly the same procedure on both architectures: one child process, its
complete stdout/stderr captured to a log, wall-clock measured around the child,
and the child's peak resident set size read from
``resource.getrusage(RUSAGE_CHILDREN)`` (which is per-process because this
wrapper waits for a single child and is itself a fresh process per repetition).

After the child exits the wrapper also counts the ``package.json`` files of the
installed tree.  That count is produced outside the measured window and is the
install-correctness check: a scenario that silently installs a different number
of packages than the build stage measured must not be reported as a sample.
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


def count_installed_packages(node_modules: Path) -> int:
    """Return the authoritative installed-tree size recorded by npm itself."""
    if not node_modules.is_dir():
        return 0
    hidden = node_modules / ".package-lock.json"
    if hidden.is_file():
        try:
            payload = json.loads(hidden.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            payload = {}
        packages = payload.get("packages") if isinstance(payload, dict) else None
        if isinstance(packages, dict):
            count = len([key for key in packages if key])
            if count:
                return count
    total = 0
    for entry in node_modules.iterdir():
        if entry.name.startswith("."):
            continue
        if entry.name.startswith("@") and entry.is_dir():
            for scoped in entry.iterdir():
                if (scoped / "package.json").is_file():
                    total += 1
        elif (entry / "package.json").is_file():
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
    installed_packages = None
    if args.count_root is not None:
        installed_packages = count_installed_packages(args.count_root)
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
        "installed_packages": installed_packages,
    }
    atomic_write_json(args.json, payload)
    print(
        f"[npm-timing] {args.json.stem}: wall={wall_seconds:.3f}s "
        f"rss={max_rss_mib:.1f}MiB exit={exit_code} packages={installed_packages}",
        flush=True,
    )
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
