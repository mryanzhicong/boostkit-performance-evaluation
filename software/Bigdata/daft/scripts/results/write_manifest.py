#!/usr/bin/env python3
"""Create the documented Parquet SHA-256 manifest after a one-host generation."""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path


def write_manifest(parquet: Path) -> Path:
    if not parquet.is_dir():
        raise ValueError(f"Parquet directory is missing: {parquet}")
    files = sorted(parquet.rglob("*.parquet"))
    if not files:
        raise ValueError("data generation produced no Parquet files")
    for table in ("lineitem", "orders", "customer", "part", "partsupp", "supplier", "nation", "region"):
        if not any(path.parent == parquet / table for path in files):
            raise ValueError(f"data generation is missing TPC-H table {table}")
    target = Path(f"{parquet}.sha256")
    if target.exists():
        raise ValueError(f"refusing to overwrite manifest: {target}")
    lines = []
    for path in files:
        relative = path.relative_to(parquet).as_posix()
        digest = hashlib.sha256()
        with path.open("rb") as source:
            for block in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(block)
        lines.append(f"{digest.hexdigest()}  ./{relative}\n")
    target.write_text("".join(lines), encoding="utf-8")
    return target


if __name__ == "__main__":
    try:
        print(write_manifest(Path(sys.argv[1])))
    except (OSError, ValueError) as error:
        print(f"[daft-data] ERROR: {error}", file=sys.stderr)
        raise SystemExit(1) from error
