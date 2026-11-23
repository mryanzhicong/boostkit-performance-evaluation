#!/usr/bin/env python3
"""Verify the pre-placed Ultrascan hsbench dataset and write a manifest.

The benchmark inputs are supplied outside the repository, under
``/home/runner/software/Ultrascan`` by default.  This script never downloads or
copies the multi-gigabyte corpus: it verifies the exact files in place, reads the
SQLite corpus metadata and records the values that the host-side parser uses to
reject a different corpus being substituted between runs.

``verify``
    Verify every file in ``dataset-lock.json`` (size + CRC32/SHA-256), validate
    the SQLite schema and compute ``corpus_bytes`` / ``corpus_blocks`` / streams.
    The resulting ``dataset-manifest.json`` is consumed by the timing driver and
    the strict parser.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sqlite3
import sys
import zlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

EXPECTED_SCHEMA = [
    (0, "id", "integer", 0, None, 1),
    (1, "stream_id", "integer", 1, None, 0),
    (2, "data", "blob", 0, None, 0),
]


def fail(message: str) -> None:
    print(f"[ultrascan-dataset] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def crc32_file(path: Path) -> str:
    value = 0
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(4 * 1024 * 1024), b""):
            value = zlib.crc32(chunk, value)
    return f"{value & 0xffffffff:08x}"


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except OSError as error:
        raise SystemExit(f"cannot read {path}: {error}") from error
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid JSON in {path}: {error}") from error


def sqlite_stats(path: Path) -> dict[str, int]:
    try:
        connection = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    except sqlite3.Error as error:
        fail(f"cannot open SQLite corpus {path}: {error}")
    try:
        table = connection.execute(
            "SELECT name, type FROM sqlite_master WHERE name = 'chunk'"
        ).fetchone()
        if table is None or table[1] != "table":
            fail(f"{path} has no chunk table")
        columns = connection.execute("PRAGMA table_info(chunk)").fetchall()
        # SQLite reports the declared type in upper case even for lower-case
        # DDL; normalise it before comparing against the pinned schema.
        normalized = [
            (row[0], row[1], str(row[2] or "").lower(), row[3], row[4], row[5])
            for row in columns
        ]
        if normalized != EXPECTED_SCHEMA:
            fail(f"{path} has an unexpected chunk schema: {normalized!r}")
        row = connection.execute(
            "SELECT COUNT(*), COALESCE(SUM(LENGTH(data)), 0), "
            "COUNT(DISTINCT stream_id) FROM chunk"
        ).fetchone()
        if row is None:
            fail(f"cannot read corpus statistics from {path}")
        chunks, corpus_bytes, streams = int(row[0]), int(row[1]), int(row[2])
        if chunks <= 0 or corpus_bytes <= 0 or streams <= 0:
            fail(f"{path} contains no corpus data")
        return {
            "corpus_blocks": chunks,
            "corpus_bytes": corpus_bytes,
            "streams": streams,
        }
    finally:
        connection.close()


def count_rule_expressions(path: Path) -> int:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        fail(f"cannot read rules file {path}: {error}")
    lines = [line for line in text.splitlines() if line.strip()]
    if not lines:
        fail(f"rules file is empty: {path}")
    return len(lines)


def verify(root: Path, lock_path: Path, manifest_path: Path) -> int:
    lock = load_json(lock_path)
    files = lock.get("files")
    if not isinstance(files, dict) or not files:
        fail(f"{lock_path} has no files mapping")
    if not root.is_dir():
        fail(f"dataset directory is missing: {root}")

    manifest: dict[str, Any] = {
        "schema": 1,
        "verified_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "root": str(root),
        "source_zip": lock.get("source_zip"),
        "source_zip_sha256": lock.get("source_zip_sha256"),
        "files": {},
    }
    for name in sorted(files):
        expected = files[name]
        path = root / name
        if not path.is_file():
            fail(f"required dataset member is missing: {path}")
        actual_size = path.stat().st_size
        if actual_size != int(expected["bytes"]):
            fail(
                f"{name} size mismatch: {actual_size} != {expected['bytes']}"
            )
        actual_sha = sha256_file(path) if "sha256" in expected else ""
        if actual_sha and actual_sha != expected["sha256"]:
            fail(f"{name} SHA-256 mismatch: {actual_sha} != {expected['sha256']}")
        actual_crc = crc32_file(path) if "crc32" in expected else ""
        if actual_crc and actual_crc != expected["crc32"]:
            fail(f"{name} CRC32 mismatch: {actual_crc} != {expected['crc32']}")
        if not actual_sha and not actual_crc:
            fail(f"{name} lock entry has neither sha256 nor crc32")
        entry: dict[str, Any] = {
            "kind": expected["kind"],
            "bytes": actual_size,
        }
        if actual_sha:
            entry["sha256"] = actual_sha
        if actual_crc:
            entry["crc32"] = actual_crc
        if expected["kind"] == "corpus":
            stats = sqlite_stats(path)
            for key in ("corpus_bytes", "corpus_blocks", "streams"):
                if key in expected and int(expected[key]) != stats[key]:
                    fail(
                        f"{name} {key} mismatch: {stats[key]} != {expected[key]}"
                    )
            entry.update(stats)
        else:
            expressions = count_rule_expressions(path)
            if "expressions" in expected and int(expected["expressions"]) != expressions:
                fail(
                    f"{name} expression count mismatch: "
                    f"{expressions} != {expected['expressions']}"
                )
            entry["expressions"] = expressions
            entry["lines"] = expressions
        manifest["files"][name] = entry
        digest_note = (
            f"sha256={actual_sha[:16]}…" if actual_sha else f"crc32={actual_crc}"
        )
        print(
            f"[ultrascan-dataset] {name}: {actual_size} bytes, {digest_note}",
            flush=True,
        )
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[ultrascan-dataset] wrote {manifest_path}", flush=True)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--root", required=True, type=Path)
    verify_parser.add_argument("--lock", required=True, type=Path)
    verify_parser.add_argument("--manifest", required=True, type=Path)
    args = parser.parse_args()
    return verify(args.root, args.lock, args.manifest)


if __name__ == "__main__":
    raise SystemExit(main())
