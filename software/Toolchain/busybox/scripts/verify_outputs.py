#!/usr/bin/env python3
"""Verify the output of one measured BusyBox applet repetition.

Verification runs immediately after each repetition (outside the measured
window) and writes a compact ``rep<i>.check`` report next to the raw log:

    PERF-CHECK name=<check> expected=<value> actual=<value> status=ok|failed
    PERF-RESULT status=ok|failed

The parser requires every declared check to be ``ok`` and cross-checks the
``expected`` values against the pinned constants exported by ``scripts/common.sh``,
so a silently changed workload cannot be reported as a valid measurement.

Usage:
    verify_outputs.py SCENARIO OUTPUT_FILE LOG_FILE CHECK_FILE REP_INDEX

``OUTPUT_FILE`` may be ``-`` for scenarios whose measured command prints only a
small digest/count/aggregate to stdout (captured in the log).
"""

from __future__ import annotations

import hashlib
import os
import subprocess
import sys
from pathlib import Path

BUSYBOX_BIN = os.environ.get("BUSYBOX_BIN", "")
CORPUS_BYTES = int(os.environ.get("BUSYBOX_FIXTURE_CORPUS_BYTES", "0"))
GZIP_BYTES = int(os.environ.get("BUSYBOX_FIXTURE_GZIP_BYTES", "0"))
SORT_LINES = int(os.environ.get("BUSYBOX_FIXTURE_SORT_LINES", "0"))
TAR_ENTRIES = int(os.environ.get("BUSYBOX_FIXTURE_TAR_ENTRIES", "0"))
TAR_BYTES = int(os.environ.get("BUSYBOX_FIXTURE_TAR_BYTES", "0"))
SORT_SHA256SUM_ARGS = int(os.environ.get("BUSYBOX_CORPUS_SHA256SUM_ARGS", "8"))
EXPECT_GREP_MATCHES = int(os.environ.get("BUSYBOX_EXPECT_GREP_MATCHES", "0"))
EXPECT_SED_SHA256 = os.environ.get("BUSYBOX_EXPECT_SED_SHA256", "")
EXPECT_CUT_SHA256 = os.environ.get("BUSYBOX_EXPECT_CUT_SHA256", "")
EXPECT_AWK_SUM = int(os.environ.get("BUSYBOX_EXPECT_AWK_SUM", "0"))
EXPECT_CORPUS_SHA256 = os.environ.get("BUSYBOX_FIXTURE_CORPUS_SHA256", "")
EXPECT_GZIP_SHA256 = os.environ.get("BUSYBOX_FIXTURE_GZIP_SHA256", "")


class VerificationError(RuntimeError):
    pass


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def read_lines(path: Path) -> list[str]:
    if not path.is_file():
        raise VerificationError(f"missing log file: {path}")
    return [
        line for line in path.read_text(encoding="utf-8", errors="replace").splitlines()
        if not line.startswith("#") and line.strip()
    ]


def require_artifact(path: Path) -> int:
    if not path.is_file():
        raise VerificationError(f"measured output artifact is missing: {path}")
    size = path.stat().st_size
    if size <= 0:
        raise VerificationError(f"measured output artifact is empty: {path}")
    return size


def run_busybox(args: list[str], stdin_path: Path | None = None) -> subprocess.CompletedProcess:
    if not BUSYBOX_BIN:
        raise VerificationError("BUSYBOX_BIN is not set")
    command = [BUSYBOX_BIN, *args]
    stdin = stdin_path.open("rb") if stdin_path is not None else None
    try:
        return subprocess.run(
            command, stdin=stdin, capture_output=True, text=True, check=False
        )
    finally:
        if stdin is not None:
            stdin.close()


def verify_sha256sum(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del output
    lines = read_lines(log)
    digests = []
    for line in lines:
        fields = line.split()
        if len(fields) >= 2 and len(fields[0]) == 64 and all(
            character in "0123456789abcdef" for character in fields[0]
        ):
            digests.append(fields[0])
    if len(digests) != SORT_SHA256SUM_ARGS:
        raise VerificationError(
            f"expected {SORT_SHA256SUM_ARGS} digest lines, found {len(digests)}"
        )
    unique = set(digests)
    return [
        ("digest_lines", SORT_SHA256SUM_ARGS, len(digests)),
        ("digest_value", EXPECT_CORPUS_SHA256, sorted(unique)[0] if unique else "none"),
        (
            "digest_unique_values",
            1,
            len(unique),
        ),
    ]


def verify_sort(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del log
    size = require_artifact(output)
    check = run_busybox(["sort", "-n", "-c", str(output)])
    if check.returncode != 0:
        raise VerificationError(
            f"sort -n -c rejects the measured output: {check.stderr.strip()[:200]}"
        )
    lines = run_busybox(["wc", "-l", str(output)])
    try:
        line_count = int(lines.stdout.split()[0])
    except (ValueError, IndexError) as exc:
        raise VerificationError("cannot read the measured sort output line count") from exc
    return [
        ("sorted_order", 0, check.returncode),
        ("sorted_lines", SORT_LINES, line_count),
        ("artifact_bytes_positive", "gt0", size),
    ]


def verify_grep(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del output
    lines = read_lines(log)
    numbers = [line.strip() for line in lines if line.strip().isdigit()]
    if len(numbers) != 1:
        raise VerificationError(f"expected one grep count line, found {len(numbers)}")
    return [("matched_lines", EXPECT_GREP_MATCHES, int(numbers[0]))]


def verify_sed(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del log
    size = require_artifact(output)
    digest = sha256_of(output)
    return [
        ("output_sha256", EXPECT_SED_SHA256, digest),
        ("artifact_bytes_positive", "gt0", size),
    ]


def verify_awk(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del output
    lines = read_lines(log)
    numbers = [line.strip() for line in lines if line.strip().lstrip("-").isdigit()]
    if len(numbers) != 1:
        raise VerificationError(f"expected one awk aggregate line, found {len(numbers)}")
    return [("aggregate_sum", EXPECT_AWK_SUM, int(numbers[0]))]


def verify_gzip(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del log
    size = require_artifact(output)
    if not BUSYBOX_BIN:
        raise VerificationError("BUSYBOX_BIN is not set")
    decompressed = subprocess.run(
        [BUSYBOX_BIN, "gzip", "-d", "-c", str(output)],
        capture_output=True,
        check=False,
    )
    if decompressed.returncode != 0:
        raise VerificationError(
            f"gzip round-trip decode failed: {decompressed.stderr[:200]!r}"
        )
    digest = hashlib.sha256(decompressed.stdout).hexdigest()
    return [
        ("roundtrip_sha256", EXPECT_GZIP_SHA256, digest),
        ("compressed_bytes_positive", "gt0", size),
    ]


def verify_tar(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del log
    size = require_artifact(output)
    listing = run_busybox(["tar", "-tzf", str(output)])
    if listing.returncode != 0:
        raise VerificationError(f"tar listing failed: {listing.stderr.strip()[:200]}")
    entries = len([line for line in listing.stdout.splitlines() if line.strip()])
    return [
        ("archive_entries", TAR_ENTRIES, entries),
        ("archive_bytes_positive", "gt0", size),
    ]


def verify_cut(output: Path, log: Path) -> list[tuple[str, object, object]]:
    del log
    size = require_artifact(output)
    digest = sha256_of(output)
    return [
        ("output_sha256", EXPECT_CUT_SHA256, digest),
        ("artifact_bytes_positive", "gt0", size),
    ]


VERIFIERS = {
    "sha256sum_hash": verify_sha256sum,
    "sort_numeric": verify_sort,
    "grep_count": verify_grep,
    "sed_substitute": verify_sed,
    "awk_aggregate": verify_awk,
    "gzip_compress": verify_gzip,
    "tar_gzip_create": verify_tar,
    "cut_fields": verify_cut,
}


def format_value(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def check_status(expected: object, actual: object) -> str:
    """Compare a declared check value with its actual value.

    ``gt0`` is a range assertion (the recorded value only has to be positive);
    every other check is an exact string/number comparison.
    """
    if format_value(expected) == "gt0":
        try:
            return "ok" if float(actual) > 0 else "failed"
        except (TypeError, ValueError):
            return "failed"
    return "ok" if format_value(expected) == format_value(actual) else "failed"


def main() -> int:
    if len(sys.argv) != 6:
        print(
            "usage: verify_outputs.py SCENARIO OUTPUT_FILE LOG_FILE CHECK_FILE REP",
            file=sys.stderr,
        )
        return 2
    scenario, output_text, log_text, check_text, rep = sys.argv[1:]
    output = Path(output_text) if output_text != "-" else Path("-")
    log = Path(log_text)
    check_path = Path(check_text)
    verifier = VERIFIERS.get(scenario)
    if verifier is None:
        print(f"[busybox-verify] unknown scenario: {scenario}", file=sys.stderr)
        return 2
    lines = [f"# scenario: {scenario}", f"# repetition: {rep}"]
    try:
        checks = verifier(output, log)
        failures = 0
        for name, expected, actual in checks:
            status = check_status(expected, actual)
            if status == "failed":
                failures += 1
            lines.append(
                f"PERF-CHECK name={name} expected={format_value(expected)} "
                f"actual={format_value(actual)} status={status}"
            )
        lines.append(f"PERF-RESULT status={'ok' if failures == 0 else 'failed'}")
        status = 0 if failures == 0 else 1
    except VerificationError as exc:
        lines.append(f"# verification error: {exc}")
        lines.append("PERF-RESULT status=failed")
        print(f"[busybox-verify] {scenario} rep{rep}: {exc}", file=sys.stderr)
        status = 1
    check_path.parent.mkdir(parents=True, exist_ok=True)
    check_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
