#!/usr/bin/env python3
"""Find processes whose command line references the performance work root."""

from __future__ import annotations

import argparse
import os
from pathlib import Path


def references_root(command_line: bytes, root: Path) -> bool:
    root_bytes = os.fsencode(str(root))
    prefix = root_bytes.rstrip(b"/") + b"/"
    arguments = [argument for argument in command_line.split(b"\0") if argument]
    return any(argument == root_bytes or prefix in argument for argument in arguments)


def matching_processes(root: Path, excluded: set[int] | None = None) -> list[int]:
    excluded_pids = set(excluded or ())
    excluded_pids.update({os.getpid(), os.getppid()})
    matches: list[int] = []
    for process_dir in Path("/proc").glob("[0-9]*"):
        try:
            pid = int(process_dir.name)
        except ValueError:
            continue
        if pid in excluded_pids:
            continue
        try:
            command_line = (process_dir / "cmdline").read_bytes()
        except (FileNotFoundError, PermissionError, ProcessLookupError, OSError):
            continue
        if command_line and references_root(command_line, root):
            matches.append(pid)
    return sorted(matches)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--exclude", action="append", default=[], type=int)
    args = parser.parse_args()
    for pid in matching_processes(args.root, set(args.exclude)):
        print(pid)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
