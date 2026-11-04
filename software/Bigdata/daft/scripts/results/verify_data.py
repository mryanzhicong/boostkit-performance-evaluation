#!/usr/bin/env python3
"""Verify the copied, immutable TPC-H Parquet set before timing."""

from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

TABLES = ("lineitem", "orders", "customer", "part", "partsupp", "supplier", "nation", "region")
ENTRY = re.compile(r"^([0-9a-fA-F]{64})  (\./[A-Za-z0-9_./-]+\.parquet)$")


def verify(parquet: Path, manifest: Path) -> str:
    if not parquet.is_dir() or not manifest.is_file():
        raise ValueError(f"TPC-H data or checksum manifest is missing: {parquet}, {manifest}")
    entries: dict[str, str] = {}
    for line in manifest.read_text(encoding="utf-8").splitlines():
        match = ENTRY.fullmatch(line)
        if match is None:
            raise ValueError("invalid SHA-256 manifest entry")
        digest, relative = match.groups()
        relative = relative[2:]
        if relative in entries:
            raise ValueError(f"duplicate manifest entry: {relative}")
        entries[relative] = digest.lower()
    if not entries:
        raise ValueError("empty TPC-H checksum manifest")
    disk_files = {path.relative_to(parquet).as_posix() for path in parquet.rglob("*.parquet")}
    if disk_files != set(entries):
        raise ValueError(f"TPC-H file set differs: missing={sorted(set(entries)-disk_files)}, extra={sorted(disk_files-set(entries))}")
    for table in TABLES:
        if not any(name.startswith(f"{table}/") for name in entries):
            raise ValueError(f"TPC-H table is missing: {table}")
    for name, expected in sorted(entries.items()):
        path = parquet / name
        if path.is_symlink() or not path.is_file():
            raise ValueError(f"unsafe or missing TPC-H file: {name}")
        digest = hashlib.sha256()
        with path.open("rb") as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(block)
        if digest.hexdigest() != expected:
            raise ValueError(f"TPC-H SHA-256 mismatch: {name}")
    signature = hashlib.sha256(manifest.read_bytes()).hexdigest()
    return signature


def main() -> int:
    try:
        print(f"[daft-data] verified dataset manifest SHA-256: {verify(Path(sys.argv[1]), Path(sys.argv[2]))}")
    except (OSError, ValueError) as error:
        print(f"[daft-data] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
