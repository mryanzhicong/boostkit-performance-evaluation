#!/usr/bin/env python3
"""Generate a deterministic text corpus for the ripgrep search scenario.

The corpus consists of ordinary text lines with a fixed seed; every 1000th
line additionally contains the search needle, so the ripgrep invocation used
by the benchmark always matches and exits successfully.  The same seed and
size always produce byte-identical corpora on every architecture.
"""

from __future__ import annotations

import random
import sys
from pathlib import Path


MIB = 1024 * 1024
WORDS = (
    "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo "
    "lima mike november oscar papa quebec romeo sierra tango uniform victor "
    "whiskey xray yankee zulu boostkit performance evaluation deterministic "
    "corpus generator rustc cargo ripgrep benchmark needle search haystack"
).split()
LINES_PER_MATCH = 1000


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: gen_corpus.py SIZE_MIB OUTPUT_PATH NEEDLE",
            file=sys.stderr,
        )
        return 1

    size_mib = int(sys.argv[1])
    if size_mib <= 0:
        print(f"[rust] ERROR: corpus size must be positive: {size_mib}", file=sys.stderr)
        return 1
    output_path = Path(sys.argv[2])
    needle = sys.argv[3]
    if not needle or any(character.isspace() for character in needle):
        print("[rust] ERROR: needle must be a non-empty single-token string", file=sys.stderr)
        return 1

    rng = random.Random(20260910)
    target_bytes = size_mib * MIB
    written = 0
    line_index = 0

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="\n") as output:
        chunk: list[str] = []
        chunk_bytes = 0
        while written + chunk_bytes < target_bytes:
            line_index += 1
            if line_index % LINES_PER_MATCH == 0:
                line = f"{rng.choice(WORDS)} {needle} {rng.choice(WORDS)} {rng.choice(WORDS)}"
            else:
                words = [rng.choice(WORDS) for _ in range(12)]
                line = " ".join(words)
            chunk.append(line)
            chunk_bytes += len(line) + 1
            if chunk_bytes >= 8 * MIB:
                output.write("\n".join(chunk) + "\n")
                written += chunk_bytes
                chunk = []
                chunk_bytes = 0
        if chunk:
            output.write("\n".join(chunk) + "\n")
            written += chunk_bytes

    print(
        f"[rust] generated {written} bytes ({written / MIB:.1f} MiB) with "
        f"{line_index // LINES_PER_MATCH} needle matches at {output_path}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
