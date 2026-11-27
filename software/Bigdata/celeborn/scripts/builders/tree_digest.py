#!/usr/bin/env python3
"""Canonical digest of an extracted source tree.

The TPC-DS kit archive is served by GitHub's codeload service, which re-packs
archives from time to time, so the *compressed* bytes are not stable even for a
pinned commit. The extracted tree is stable, so the case pins a digest over
(sorted relative path, sha256(content)) pairs instead of the tarball.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path


def tree_digest(root: Path) -> str:
    entries: list[str] = []
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        entries.append(f"{relative}\t{digest}\n")
    if not entries:
        raise SystemExit(f"ERROR: {root} contains no files")
    return hashlib.sha256("".join(entries).encode("utf-8")).hexdigest()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="extracted source tree")
    parser.add_argument(
        "--expected",
        help="fail unless the canonical digest equals this value",
    )
    args = parser.parse_args(argv)
    digest = tree_digest(args.root)
    print(digest)
    if args.expected and digest != args.expected.lower():
        print(
            f"ERROR: tree digest mismatch for {args.root} "
            f"(expected {args.expected.lower()}, got {digest})",
            file=sys.stderr,
        )
        return 30
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
