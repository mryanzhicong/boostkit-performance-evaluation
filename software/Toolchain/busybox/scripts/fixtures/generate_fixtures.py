#!/usr/bin/env python3
"""Generate the deterministic BusyBox applet benchmark corpora.

Every byte the applet scenarios consume is produced here from one fixed seed,
so the two architectures read identical inputs and the expected outputs
(checksums, counters, aggregates, entry counts) can be pinned in
``scripts/common.sh`` and re-verified on each run.

Layout (all paths are relative to the fixture directory):

* ``corpus_text.txt``  - 900,000 lines of tagged words, used by grep / sed /
  cut / awk / sha256sum
* ``sort_input.txt``   - 1,000,000 numeric key lines for ``sort -n``
* ``gzip_input.txt``   - a line-aligned prefix of the corpus for ``gzip -6``
* ``tar_tree/``        - 16,000 small text files for ``tar -czf``
* ``fixtures.json``    - sizes, SHA-256 digests and expected workload results

The generator computes the expected sed/cut output digests while it writes the
corpus, so the start stage can verify generation and the parser can verify the
measured applet output without ever trusting an unverified file.
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

SEED = 20261102
CORPUS_LINES = 900_000
SORT_LINES = 1_000_000
GZIP_LINES = 400_000
TAR_FILES = 16_000
TAR_LINES_PER_FILE = 100

WORDS = (
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "quick", "brown", "fox", "lazy", "dog", "kernel", "driver", "network",
    "storage", "toolchain", "benchmark", "throughput",
)
TAG_WORD = "alpha"
GREP_TAG = f"tag={TAG_WORD}"


def splitmix64(seed: int):
    state = seed & 0xFFFFFFFFFFFFFFFF

    def next_value() -> int:
        nonlocal state
        state = (state + 0x9E3779B97F4A7C15) & 0xFFFFFFFFFFFFFFFF
        z = state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & 0xFFFFFFFFFFFFFFFF
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & 0xFFFFFFFFFFFFFFFF
        return z ^ (z >> 31)

    return next_value


def corpus_line(index: int, next_value) -> str:
    words = [WORDS[next_value() % len(WORDS)] for _ in range(6)]
    if next_value() % 20 == 0:
        tag = GREP_TAG
    else:
        tag = "tag=" + WORDS[next_value() % len(WORDS)]
    return f"{index:08d} " + " ".join(words) + " " + tag


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: generate_fixtures.py FIXTURE_DIRECTORY", file=sys.stderr)
        return 1
    root = Path(sys.argv[1])
    root.mkdir(parents=True, exist_ok=True)
    tree = root / "tar_tree"
    tree.mkdir(parents=True, exist_ok=True)

    next_value = splitmix64(SEED)
    corpus_path = root / "corpus_text.txt"
    gzip_path = root / "gzip_input.txt"
    sort_path = root / "sort_input.txt"

    corpus_hash = hashlib.sha256()
    sed_hash = hashlib.sha256()
    cut_hash = hashlib.sha256()
    gzip_hash = hashlib.sha256()
    grep_matches = 0
    awk_sum = 0
    corpus_bytes = 0
    gzip_bytes = 0

    with corpus_path.open("w", encoding="utf-8", newline="\n") as corpus, \
            gzip_path.open("w", encoding="utf-8", newline="\n") as gzip_file:
        for index in range(CORPUS_LINES):
            line = corpus_line(index, next_value)
            encoded = (line + "\n").encode("utf-8")
            corpus.write(line + "\n")
            corpus_hash.update(encoded)
            corpus_bytes += len(encoded)
            awk_sum += len(line)
            if GREP_TAG in line:
                grep_matches += 1
            sed_line = (line.replace("alpha", "ALPHA").replace("beta", "BETA") + "\n")
            sed_hash.update(sed_line.encode("utf-8"))
            fields = line.split(" ")
            cut_hash.update((fields[0] + " " + fields[2] + "\n").encode("utf-8"))
            if index < GZIP_LINES:
                gzip_file.write(line + "\n")
                gzip_hash.update(encoded)
                gzip_bytes += len(encoded)

    sort_hash = hashlib.sha256()
    sort_max_key = 0
    with sort_path.open("w", encoding="utf-8", newline="\n") as handle:
        for _ in range(SORT_LINES):
            key = next_value() % 100_000_000
            payload = next_value() % 1000
            line = f"{key:08d} k{payload:03d}\n"
            handle.write(line)
            sort_hash.update(line.encode("utf-8"))
            sort_max_key = max(sort_max_key, key)

    tree_hash = hashlib.sha256()
    tree_bytes = 0
    for file_index in range(TAR_FILES):
        lines = []
        for line_index in range(TAR_LINES_PER_FILE):
            lines.append(
                f"file {file_index:05d} line {line_index:03d} "
                f"payload {next_value() % 1_000_000:06d}"
            )
        content = "\n".join(lines) + "\n"
        (tree / f"part{file_index:05d}.txt").write_text(
            content, encoding="utf-8", newline="\n"
        )
        tree_hash.update(content.encode("utf-8"))
        tree_bytes += len(content.encode("utf-8"))

    def sha(path: Path) -> str:
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for block in iter(lambda: handle.read(1 << 20), b""):
                digest.update(block)
        return digest.hexdigest()

    manifest = {
        "seed": SEED,
        "corpus_text.txt": {
            "lines": CORPUS_LINES,
            "bytes": corpus_bytes,
            "sha256": corpus_hash.hexdigest(),
        },
        "gzip_input.txt": {
            "lines": GZIP_LINES,
            "bytes": gzip_bytes,
            "sha256": gzip_hash.hexdigest(),
        },
        "sort_input.txt": {
            "lines": SORT_LINES,
            "bytes": sort_path.stat().st_size,
            "sha256": sort_hash.hexdigest(),
            "max_key": sort_max_key,
        },
        "tar_tree": {
            "files": TAR_FILES,
            "lines_per_file": TAR_LINES_PER_FILE,
            "bytes": tree_bytes,
            "content_sha256": tree_hash.hexdigest(),
        },
        "expected": {
            "grep_matches_tag_alpha": grep_matches,
            "sed_output_sha256": sed_hash.hexdigest(),
            "cut_output_sha256": cut_hash.hexdigest(),
            "awk_line_bytes_sum": awk_sum,
            "sha256sum_digest": corpus_hash.hexdigest(),
            "gzip_roundtrip_sha256": gzip_hash.hexdigest(),
        },
    }
    (root / "fixtures.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[busybox-fixtures] corpus={corpus_bytes}B lines={CORPUS_LINES} "
        f"gzip={gzip_bytes}B sort={manifest['sort_input.txt']['bytes']}B "
        f"tar_files={TAR_FILES} grep_matches={grep_matches} awk_sum={awk_sum}",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
