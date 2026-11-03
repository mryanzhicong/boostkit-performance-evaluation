#!/usr/bin/env python3
"""Reject unsafe paths in the pinned upstream source archive before extraction."""

import sys
from pathlib import PurePosixPath


def main() -> int:
    count = 0
    for line in sys.stdin:
        name = line.rstrip("\n")
        path = PurePosixPath(name)
        if path.is_absolute() or ".." in path.parts or not path.parts or path.parts[0] != "byte-unixbench-6.0.1":
            print(f"unsafe archive entry: {name}", file=sys.stderr)
            return 1
        count += 1
    if count < 30:
        print("source archive is unexpectedly small", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
