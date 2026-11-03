#!/usr/bin/env python3
"""Verify the raw output of one measured APR-util harness repetition.

The base64 harness prints a machine-readable summary line plus its own
PERF-CHECK lines; the upstream ``testall`` program prints one module result per
line and an ``All tests passed.`` trailer.  This verifier re-derives the
expected counters from the pinned constants exported by ``scripts/common.sh``
(payload bytes, loop counts, upstream test-module count) and writes the compact
``runs/<scenario>/rep<i>.check`` report that the parser consumes:

    PERF-CHECK name=<check> expected=<value> actual=<value> status=ok|failed
    PERF-RESULT status=ok|failed

Verification runs immediately after each repetition, outside the measured
window.  The parser requires every check to be ``ok`` and cross-checks the
declared expectations against the same pinned constants, so a truncated payload
or a changed loop count cannot be reported as a valid measurement.

Usage:
    verify_outputs.py SCENARIO LOG_FILE CHECK_FILE REP_INDEX
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

SUMMARY_TOKEN = re.compile(r"([A-Za-z0-9_]+)=([^\s]+)")
TESTALL_SUCCESS = re.compile(r"^\s*\w+\s*:\s+SUCCESS\s*$")
TESTALL_FAILURE = re.compile(r"^\s*\w+\s*:\s+FAILED\s*$")


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


def harness_checks(text: str) -> dict[str, tuple[str, str]]:
    """Collect the harness's own PERF-CHECK lines as name -> (expected, actual)."""
    checks: dict[str, tuple[str, str]] = {}
    for line in text.splitlines():
        if not line.startswith("PERF-CHECK "):
            continue
        fields: dict[str, str] = {}
        for token in line.split()[1:]:
            key, _, value = token.partition("=")
            fields[key] = value
        name = fields.get("name")
        if not name:
            continue
        if fields.get("status") != "ok":
            raise VerificationError(f"harness check {name} failed: {line}")
        checks[name] = (fields.get("expected", ""), fields.get("actual", ""))
    return checks


def read_log(path: Path) -> str:
    if not path.is_file():
        raise VerificationError(f"missing measured log: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def expect(summary: dict[str, str], key: str) -> int:
    try:
        return int(summary[key])
    except (KeyError, ValueError) as exc:
        raise VerificationError(f"harness summary does not contain an integer {key}") from exc


def scenario_parts(scenario: str) -> tuple[str, str]:
    """Return (mode, size_key) for a base64 scenario, e.g. ('encode', '64B')."""
    if not scenario.startswith("base64_"):
        raise VerificationError(f"not a base64 scenario: {scenario}")
    remainder = scenario[len("base64_"):]
    mode, _, key = remainder.partition("_")
    if mode not in ("encode", "decode") or key not in ("64b", "1kib", "64kib", "1mib"):
        raise VerificationError(f"malformed base64 scenario name: {scenario}")
    return mode, key.upper()


def expected_encoded_length(payload_bytes: int) -> int:
    """apr_base64_encode_len(): ((len + 2) / 3 * 4) + 1, including the NUL."""
    return ((payload_bytes + 2) // 3) * 4 + 1


def verify_base64(scenario: str, text: str) -> list[tuple[str, object, object]]:
    mode, key = scenario_parts(scenario)
    payload_bytes = env_int(f"APR_UTIL_PAYLOAD_{key}_BYTES")
    loops = env_int(f"APR_UTIL_LOOPS_{mode.upper()}_{key}")
    encoded_length = expected_encoded_length(payload_bytes)
    require_result_line(text)
    summary = parse_summary(text)
    declared = harness_checks(text)
    roundtrip = declared.get("roundtrip", ("", ""))[1]
    checks: list[tuple[str, object, object]] = [
        ("harness_mode", mode, summary.get("mode", "")),
        ("payload_bytes", payload_bytes, expect(summary, "payload_bytes")),
        ("loops", loops, expect(summary, "loops")),
        ("encoded_length", encoded_length, expect(summary, "encoded_length")),
        ("roundtrip", "ok", roundtrip),
    ]
    if mode == "encode":
        checks.append(
            ("encoded_bytes", (encoded_length - 1) * loops, expect(summary, "encoded_bytes"))
        )
        checks.append(("input_bytes", payload_bytes * loops, expect(summary, "input_bytes")))
    else:
        checks.append(
            ("decoded_bytes", payload_bytes * loops, expect(summary, "decoded_bytes"))
        )
        decoded_length = declared.get("decoded_length", ("", ""))[1]
        checks.append(("decoded_length", payload_bytes, decoded_length))
    return checks


def verify_testall(text: str) -> list[tuple[str, object, object]]:
    expected_modules = env_int("APR_UTIL_EXPECT_TESTALL_MODULES")
    passed = sum(1 for line in text.splitlines() if TESTALL_SUCCESS.match(line))
    failed = sum(1 for line in text.splitlines() if TESTALL_FAILURE.match(line))
    if "All tests passed." not in text:
        raise VerificationError("testall did not print 'All tests passed.'")
    return [
        ("test_modules_passed", expected_modules, passed),
        ("test_modules_failed", 0, failed),
        ("all_tests_passed", "ok", "ok"),
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
        if scenario.startswith("base64_"):
            checks = verify_base64(scenario, text)
        elif scenario == "upstream_testall":
            checks = verify_testall(text)
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
        print(f"[apr-util-verify] {scenario} {rep}: {exc}", file=sys.stderr)
        status = 1
    check_path.parent.mkdir(parents=True, exist_ok=True)
    check_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
