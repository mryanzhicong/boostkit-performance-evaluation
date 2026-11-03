#!/usr/bin/env python3
"""Verify that one catj run produced the pinned, byte-identical flattening output."""

import argparse
import hashlib
import json
import sys
from pathlib import Path


class VerificationError(RuntimeError):
    pass


def load_scenario(path: Path, scenario_id: str) -> tuple[dict, dict, dict]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    scenario = next((item for item in payload["scenarios"] if item["id"] == scenario_id), None)
    if scenario is None:
        raise VerificationError(f"unknown scenario: {scenario_id}")
    entry = next((item for item in payload["inputs"] if item["name"] == scenario["input"]), None)
    if entry is None:
        raise VerificationError(f"scenario {scenario_id} references an unknown input")
    return payload, scenario, entry


def verify(scenarios_file: Path, scenario_id: str, output: Path) -> dict:
    _, scenario, entry = load_scenario(scenarios_file, scenario_id)
    if not output.is_file():
        raise VerificationError(f"missing output file: {output}")
    data = output.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if digest != entry["output_sha256"]:
        raise VerificationError(
            f"{scenario_id}: output sha256 {digest} != pinned {entry['output_sha256']}"
        )
    lines = data.count(b"\n")
    if lines != entry["output_lines"]:
        raise VerificationError(f"{scenario_id}: {lines} output lines, expected {entry['output_lines']}")
    text = data.decode("utf-8")
    if scenario["expected_last_token"] not in text:
        raise VerificationError(f"{scenario_id}: last token {scenario['expected_last_token']!r} is missing")
    if scenario["expected_value_token"] not in text:
        raise VerificationError(f"{scenario_id}: value token {scenario['expected_value_token']!r} is missing")
    return {
        "output_sha256": digest,
        "output_bytes": len(data),
        "output_lines": lines,
        "input_sha256": entry["sha256"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    try:
        detail = verify(Path(args.scenarios), args.scenario, Path(args.output))
    except VerificationError as exc:
        print(f"[catj-verify] FAILED: {exc}", file=sys.stderr)
        return 2
    print(f"[catj-verify] {json.dumps({'scenario': args.scenario, **detail}, sort_keys=True)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
