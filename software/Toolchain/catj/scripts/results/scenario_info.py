#!/usr/bin/env python3
"""Expose the pinned catj scenario definitions to the shell stages."""

import argparse
import hashlib
import json
import sys
from pathlib import Path


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--scenario")
    parser.add_argument("--fields", action="store_true")
    parser.add_argument("--list-inputs", action="store_true")
    parser.add_argument("--output")
    args = parser.parse_args()

    payload = load(Path(args.scenarios))
    if args.list_inputs:
        for entry in payload["inputs"]:
            print(f"{entry['name']} {entry['sha256']} {entry['bytes']}")
        return 0
    if args.scenario:
        for entry in payload["scenarios"]:
            if entry["id"] == args.scenario:
                if args.output:
                    digest = hashlib.sha256(Path(args.output).read_bytes()).hexdigest()
                    print(digest)
                    return 0
                print(f"{entry['input']} {entry['mode']} {entry['iterations']}")
                return 0
        print(f"unknown scenario: {args.scenario}", file=sys.stderr)
        return 2
    for entry in payload["scenarios"]:
        print(entry["id"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
