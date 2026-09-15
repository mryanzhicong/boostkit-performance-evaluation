#!/usr/bin/env python3
"""Build an hsbench corpus database from the fixed hyperscan source-tree
text file set (python3 equivalent of the official tools/hsbench/scripts
CorpusBuilder.py, which is python2-only).

Schema and post-processing (stream_id index, vacuum, analyze) replicate
the official CorpusBuilder exactly.  Corpus layout: one stream per
input file, file contents split into <=CHUNK_SIZE blocks on line
boundaries.
"""

from __future__ import annotations

import hashlib
import sqlite3
import sys
from pathlib import Path

CHUNK_SIZE = 16 * 1024

# The fixed corpus source set: everything matched by these globs inside
# the cloned v5.4.2.1 source tree (tag-pinned, so the content is fixed).
CORPUS_GLOBS = (
    "src/**/*.cpp",
    "src/**/*.c",
    "src/**/*.h",
    "src/**/*.hh",
    "src/**/*.rl",
    "doc/dev-reference/*.rst",
    "examples/*.c",
    "examples/*.cc",
    "CHANGELOG.md",
)


def collect_files(source_root: Path) -> list[Path]:
    files: set[Path] = set()
    for pattern in CORPUS_GLOBS:
        files.update(p for p in source_root.glob(pattern) if p.is_file())
    return sorted(files)


def file_chunks(path: Path):
    """Yield <=CHUNK_SIZE byte chunks of the file, split on newlines."""
    with path.open("rb") as handle:
        pending = bytearray()
        for line in handle:
            pending.extend(line)
            if len(pending) >= CHUNK_SIZE:
                yield bytes(pending)
                pending = bytearray()
        if pending:
            yield bytes(pending)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: build_corpus.py SOURCE_ROOT OUTPUT_DB", file=sys.stderr)
        return 1
    source_root, output_db = Path(sys.argv[1]), Path(sys.argv[2])
    if output_db.exists():
        raise RuntimeError(f"refusing to overwrite existing database: {output_db}")

    files = collect_files(source_root)
    if not files:
        raise RuntimeError("no corpus source files matched")

    manifest = []
    db = sqlite3.connect(str(output_db))
    db.execute(
        "CREATE TABLE chunk ("
        "id integer primary key, "
        "stream_id integer not null, "
        "data blob)"
    )
    chunk_id = 0
    total_bytes = 0
    for stream_id, path in enumerate(files):
        size = 0
        for data in file_chunks(path):
            db.execute(
                "insert into chunk (id, stream_id, data) values (?, ?, ?)",
                (chunk_id, stream_id, sqlite3.Binary(data)),
            )
            chunk_id += 1
            size += len(data)
        total_bytes += size
        manifest.append(
            {
                "file": str(path.relative_to(source_root)),
                "bytes": size,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
        )
    db.commit()
    db.execute("create index chunk_stream_id_idx on chunk(stream_id)")
    db.commit()
    db.execute("vacuum")
    db.execute("analyze")
    db.commit()
    db.close()

    print(
        f"[corpus] {len(files)} files, {chunk_id} chunks, "
        f"{total_bytes} bytes -> {output_db}"
    )
    for entry in manifest[:3]:
        print(f"[corpus]   {entry['file']} ({entry['bytes']} bytes)")
    print(f"[corpus]   ... and {len(manifest) - 3} more")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
