#!/usr/bin/env python3
"""Generate the deterministic PCRE 8.45 workload fixtures.

The case ships no binary corpus: every input is produced by this program from
explicit, version independent rules (an integer splitmix64 hash, no ``random``
module, no clock, no environment), so the SHA-256 of each file is a property of
the source tree.  ``scripts/common.sh`` pins the expected digests, the start
stage verifies them before any measurement, and the parser rejects a run whose
fixture manifest is missing or whose pinned match counts were not reproduced.

Outputs (under the target directory):

``pcretest_literal.txt``      pcretest input: literal / anchored / classify patterns
``pcretest_backtrack.txt``    pcretest input: backtracking dominated patterns
``pcretest_utf8.txt``         pcretest input: UTF-8 and Unicode property patterns
``pcretest_dfa.txt``          pcretest input: DFA compatible patterns
``scan_patterns.txt``         one pcregrep pattern per line (8 patterns)
``scan_corpus.txt``           large deterministic line corpus for pcregrep
``fixtures.json``             sizes, digests and the expected match counts
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

# --------------------------------------------------------------- literals ----
# The pcretest input syntax is one pattern per block followed by data lines and
# terminated by an empty line; see doc/pcretest.txt in the PCRE distribution.
PCRETEST_LITERAL = r"""/\b(?:quick|lazy)\s+brown\s+(?:fox|dog)\b/
the quick brown fox jumps over the lazy dog
The Quick Brown Fox jumped

/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/
user.name+tag@example.co.uk
not-an-address@

/\b(\d{4})-(\d{2})-(\d{2})\b/
release 2026-11-02 build 7
no date in this line

/(?:error|warning):\s+([^\n]+)/i
ERROR: disk quota exceeded
Warning: cache lookup miss
info: everything is fine

/(?:\w+\s+){3}\d+/
alpha beta gamma 42
only two words 7

/\A(?:[a-z]+\/)+[a-z]+\.log\z/
var/log/app.log
/var/log/app.log

"""

PCRETEST_BACKTRACK = r"""/^(a+)+[bc]/
aaaaaaaaaaaaaaaaa

/^([a-z]+)+\.([a-z]+)+$/
abcdefghijklmnop

/^(\w+\s?)*$/
word word word word word word word

"""

PCRETEST_UTF8 = r"""/^\p{Lu}\p{Ll}+\s+\p{Han}+/8
\x{39f}\x{3bb}\x{3ac}\x{3bd}\x{3b4}\x{3c1}\x{3b1} \x{4e2d}\x{6587}

/\p{Greek}+/8
abc \x{3b1}\x{3b2}\x{3b3} def

/[\x{4e00}-\x{9fff}]{3,}/8
\x{4e2d}\x{6587}\x{6d4b}\x{8bd5}

/\X/8
\x{1f600}\x{1f64f}

"""

PCRETEST_DFA = r"""/(?:quick|lazy)\s+brown\s+(?:fox|dog)/
the quick brown fox jumps over the lazy dog
the lazy dog sleeps all day

/[a-z]+@[a-z]+\.[a-z]{2,}/
contact user@example.com for details

/^\d{4}-\d{2}-\d{2}$/
2026-11-02
2026-1-2

"""

# ---------------------------------------------------------------- corpus ----

CORPUS_LINES = 800_000
MASK64 = 0xFFFFFFFFFFFFFFFF

KEY_TOKENS = ("alpha", "beta", "gamma", "delta")
TAG_TOKENS = ("red", "green", "blue", "amber")


def splitmix64(value: int) -> int:
    """Deterministic 64-bit mixing function (no library state, no version drift)."""
    value = (value + 0x9E3779B97F4A7C15) & MASK64
    value = ((value ^ (value >> 30)) * 0xBF58476D1CE4E5B9) & MASK64
    value = ((value ^ (value >> 27)) * 0x94D049BB133111EB) & MASK64
    return (value ^ (value >> 31)) & MASK64


def derive(index: int, stream: int) -> int:
    return splitmix64((index << 8) ^ (stream * 0x9E3779B97F4A7C15))


def corpus_record(index: int) -> dict[str, object]:
    key = KEY_TOKENS[derive(index, 1) % 4]
    tag = TAG_TOKENS[derive(index, 2) % 4]
    value = derive(index, 3) & 0xFFFFFFFF
    trace = derive(index, 4) & 0xFFFFFFFF
    marker_hit = (derive(index, 5) % 8) == 3
    return {
        "idx": index,
        "key": key,
        "tag": tag,
        "value": f"{value:08x}",
        "trace": f"{trace:08x}",
        "marker": "hit" if marker_hit else "miss",
        "hit": marker_hit,
        "even": index % 2 == 0,
    }


def corpus_line(record: dict[str, object]) -> str:
    # "marker" is deliberately the last field: the pcregrep patterns anchor on
    # the line end without needing a lookahead.
    return (
        f"idx={int(record['idx']):06d} key={record['key']} "
        f"value={record['value']} tag={record['tag']} "
        f"trace={record['trace']} marker={record['marker']}\n"
    )


# pcregrep patterns and the equivalent predicates.  Each predicate is a plain
# restatement of the regular expression for this record layout, so the expected
# match count is computed without running a regular expression engine.
SCAN_PATTERNS: tuple[tuple[str, str], ...] = (
    (r"key=(?:alpha|beta) .*marker=hit$", "key in (alpha, beta) and hit"),
    (r"key=gamma .*tag=red", "key == gamma and tag == red"),
    (r"tag=blue .*marker=miss$", "tag == blue and not hit"),
    (r"value=[0-9a-f]{8} tag=amber", "tag == amber"),
    (r"^idx=000[0-9]{3} key=delta", "idx < 1000 and key == delta"),
    (r"trace=[0-9a-f]{8} marker=hit$", "hit"),
    (r"key=alpha .*tag=green", "key == alpha and tag == green"),
    (r"^idx=[0-9]{5}[02468] key=beta", "even idx and key == beta"),
)


def scan_predicate(name: str, record: dict[str, object]) -> bool:
    if name == r"key=(?:alpha|beta) .*marker=hit$":
        return record["key"] in ("alpha", "beta") and record["hit"]
    if name == r"key=gamma .*tag=red":
        return record["key"] == "gamma" and record["tag"] == "red"
    if name == r"tag=blue .*marker=miss$":
        return record["tag"] == "blue" and not record["hit"]
    if name == r"value=[0-9a-f]{8} tag=amber":
        return record["tag"] == "amber"
    if name == r"^idx=000[0-9]{3} key=delta":
        return int(record["idx"]) < 1000 and record["key"] == "delta"
    if name == r"trace=[0-9a-f]{8} marker=hit$":
        return record["hit"]
    if name == r"key=alpha .*tag=green":
        return record["key"] == "alpha" and record["tag"] == "green"
    if name == r"^idx=[0-9]{5}[02468] key=beta":
        return record["even"] and record["key"] == "beta"
    raise KeyError(f"no predicate for pattern: {name}")


def write_text(path: Path, text: str) -> str:
    path.write_text(text, encoding="utf-8", newline="\n")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("output_directory", type=Path)
    args = parser.parse_args()
    target = args.output_directory
    target.mkdir(parents=True, exist_ok=True)

    digests: dict[str, str] = {}
    for name, text in (
        ("pcretest_literal.txt", PCRETEST_LITERAL),
        ("pcretest_backtrack.txt", PCRETEST_BACKTRACK),
        ("pcretest_utf8.txt", PCRETEST_UTF8),
        ("pcretest_dfa.txt", PCRETEST_DFA),
    ):
        digests[name] = write_text(target / name, text)

    patterns = [pattern for pattern, _ in SCAN_PATTERNS]
    digests["scan_patterns.txt"] = write_text(
        target / "scan_patterns.txt", "\n".join(patterns) + "\n"
    )

    corpus_path = target / "scan_corpus.txt"
    expected = [0] * len(SCAN_PATTERNS)
    with corpus_path.open("w", encoding="utf-8", newline="\n") as handle:
        for index in range(CORPUS_LINES):
            record = corpus_record(index)
            handle.write(corpus_line(record))
            for position, (pattern, _) in enumerate(SCAN_PATTERNS):
                if scan_predicate(pattern, record):
                    expected[position] += 1
    digests["scan_corpus.txt"] = hashlib.sha256(corpus_path.read_bytes()).hexdigest()

    for count in expected:
        if count <= 0:
            print("[pcre-fixtures] ERROR: a scan pattern does not match any record")
            return 1

    manifest = {
        "generator": "scripts/fixtures/generate_fixtures.py",
        "corpus_lines": CORPUS_LINES,
        "corpus_bytes": corpus_path.stat().st_size,
        "scan_patterns": patterns,
        "expected_scan_matches": expected,
        "expected_scan_matches_total": sum(expected),
        "sha256": digests,
    }
    (target / "fixtures.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"[pcre-fixtures] wrote {len(digests)} files to {target} "
        f"(corpus {manifest['corpus_bytes']} bytes, "
        f"{manifest['expected_scan_matches_total']} matching lines total)"
    )
    for name in sorted(digests):
        print(f"[pcre-fixtures] {name} sha256={digests[name]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
