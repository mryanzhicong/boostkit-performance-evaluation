#!/usr/bin/env python3
"""Verify the raw output of one measured hiredis harness repetition.

The harness prints a machine-readable summary line plus its own PERF-CHECK lines;
this verifier re-derives the expected counters from the pinned constants exported
by ``scripts/common.sh`` (fixture bytes, replies per fixture, loop counts,
iteration counts, upstream test count) and writes the compact
``runs/<scenario>/rep<i>.check`` report that the parser consumes:

    PERF-CHECK name=<check> expected=<value> actual=<value> status=ok|failed
    PERF-RESULT status=ok|failed

Verification runs immediately after each repetition, outside the measured
window.  The parser requires every check to be ``ok`` and cross-checks the
declared expectations against the same pinned constants, so a truncated replay
or a changed workload cannot be reported as a valid measurement.

Usage:
    verify_outputs.py SCENARIO LOG_FILE CHECK_FILE REP_INDEX
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

SUMMARY_TOKEN = re.compile(r"([A-Za-z0-9_]+)=([^\s]+)")
LOCAL_RESULT = re.compile(r"local tests=(\d+) fails=(\d+) skips=(\d+)")


class VerificationError(RuntimeError):
    pass


def env_int(name: str) -> int:
    raw = os.environ.get(name, "")
    if not raw.strip():
        raise VerificationError(f"missing required environment variable {name}")
    try:
        return int(raw)
    except ValueError as exc:
        raise VerificationError(f"{name} is not an integer: {raw!r}") from exc


def parse_summary(text: str) -> dict[str, str]:
    for line in text.splitlines():
        if line.startswith("mode="):
            tokens: dict[str, str] = {}
            for key, value in SUMMARY_TOKEN.findall(line):
                tokens[key] = value
            return tokens
    raise VerificationError("harness summary line is missing from the measured output")


def require_result_line(text: str) -> None:
    for line in text.splitlines():
        if line.startswith("PERF-RESULT "):
            if line.split("status=", 1)[-1].strip() == "ok":
                return
            raise VerificationError(f"harness self-check failed: {line}")
    raise VerificationError("harness PERF-RESULT line is missing from the measured output")


def read_log(path: Path) -> str:
    if not path.is_file():
        raise VerificationError(f"missing measured log: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def expect(summary: dict[str, str], key: str) -> int:
    try:
        return int(summary[key])
    except (KeyError, ValueError) as exc:
        raise VerificationError(f"harness summary does not contain an integer {key}") from exc


def verify_reader(scenario: str, text: str) -> list[tuple[str, object, object]]:
    name = scenario[len("reader_"):]
    fixture_key = "pipeline" if name == "fragmented" else name
    fixture_bytes = env_int(f"HIREDIS_FIXTURE_{fixture_key.upper()}_BYTES")
    fixture_replies = env_int(f"HIREDIS_FIXTURE_{fixture_key.upper()}_REPLIES")
    loops = env_int("HIREDIS_LOOPS_" + name.upper())
    expected_bytes = fixture_bytes * loops
    expected_replies = fixture_replies * loops
    require_result_line(text)
    summary = parse_summary(text)
    return [
        ("harness_mode", name, summary.get("mode", "")),
        ("fixture_bytes", fixture_bytes, expect(summary, "fixture_bytes")),
        ("loops", loops, expect(summary, "loops")),
        ("parsed_bytes", expected_bytes, expect(summary, "bytes")),
        ("parsed_replies", expected_replies, expect(summary, "replies")),
    ]


def verify_format(scenario: str, text: str) -> list[tuple[str, object, object]]:
    name = scenario[len("format_"):]
    iterations = env_int("HIREDIS_ITERATIONS_FORMAT_" + name.upper())
    require_result_line(text)
    summary = parse_summary(text)
    command_bytes = expect(summary, "command_bytes")
    return [
        ("harness_mode", f"format_{name}", summary.get("mode", "")),
        ("iterations", iterations, expect(summary, "iterations")),
        ("command_bytes", "gt0", command_bytes),
    ]


def verify_upstream(text: str) -> list[tuple[str, object, object]]:
    expected_tests = env_int("HIREDIS_EXPECT_LOCAL_TESTS")
    require_result_line(text)
    match = LOCAL_RESULT.search(text)
    if match is None:
        raise VerificationError("upstream local test summary line is missing")
    passed, failed, skipped = (int(group) for group in match.groups())
    return [
        ("local_tests_passed", expected_tests, passed),
        ("local_tests_failed", 0, failed),
        ("local_tests_skipped", 0, skipped),
    ]


def check_status(expected: object, actual: object) -> str:
    if str(expected) == "gt0":
        try:
            return "ok" if float(actual) > 0 else "failed"
        except (TypeError, ValueError):
            return "failed"
    return "ok" if str(expected) == str(actual) else "failed"


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "usage: verify_outputs.py SCENARIO LOG_FILE CHECK_FILE REP",
            file=sys.stderr,
        )
        return 2
    scenario, log_text, check_text, rep = sys.argv[1:]
    log = Path(log_text)
    check_path = Path(check_text)
    lines = [f"# scenario: {scenario}", f"# repetition: {rep}"]
    try:
        text = read_log(log)
        if scenario.startswith("reader_"):
            checks = verify_reader(scenario, text)
        elif scenario.startswith("format_"):
            checks = verify_format(scenario, text)
        elif scenario == "upstream_local_suite":
            checks = verify_upstream(text)
        else:
            raise VerificationError(f"unknown scenario: {scenario}")
        failures = 0
        for name, expected, actual in checks:
            status = check_status(expected, actual)
            if status == "failed":
                failures += 1
            lines.append(
                f"PERF-CHECK name={name} expected={expected} actual={actual} status={status}"
            )
        lines.append(f"PERF-RESULT status={'ok' if failures == 0 else 'failed'}")
        status = 0 if failures == 0 else 1
    except VerificationError as exc:
        lines.append(f"# verification error: {exc}")
        lines.append("PERF-RESULT status=failed")
        print(f"[hiredis-verify] {scenario} {rep}: {exc}", file=sys.stderr)
        status = 1
    check_path.parent.mkdir(parents=True, exist_ok=True)
    check_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
