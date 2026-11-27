#!/usr/bin/env python3
"""Reject unsafe paths in the pinned STREAM source archive before extraction."""

import sys
import tarfile

EXPECTED_ROOT = "STREAM-"


def main() -> int:
    count = 0
    has_source = False
    for name in sys.stdin:
        entry = name.rstrip("\n")
        if not entry.startswith(EXPECTED_ROOT):
            print(f"unsafe archive entry: {entry}", file=sys.stderr)
            return 1
        path = entry.split("/")
        if ".." in path or entry.startswith("/"):
            print(f"unsafe archive entry: {entry}", file=sys.stderr)
            return 1
        if entry.endswith("/stream.c"):
            has_source = True
        count += 1
    if count < 5 or not has_source:
        print("source archive is unexpectedly small or misses stream.c", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
