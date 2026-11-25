#!/usr/bin/env python3
"""Aggregate the upstream git t/perf results into benchmark_git.json."""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

# Fixed upstream subset and its observed subtest counts for v2.56.0 on the
# pinned depth-1 checkout. p0000 (harness self-test), p0001 (history
# traversal) and p0006 (requires HEAD^) are excluded; see the README.
EXPECTED_SCRIPTS = (
    ("p0002-read-cache.sh", 1),
    ("p0003-delta-base-cache.sh", 2),
    ("p0004-lazy-init-name-hash.sh", 2),
    ("p0005-status.sh", 1),
    ("p0007-write-cache.sh", 1),
    ("p0008-odb-fsync.sh", 16),
    ("p0009-diff-pathspec.sh", 1),
    ("p0071-sort.sh", 9),
    ("p0090-cache-tree.sh", 12),
    ("p0100-globbing.sh", 12),
)
RESULT_RE = re.compile(
    r"^(?:(\d+):)?(\d+):(\d+(?:\.\d+)?) (\d+(?:\.\d+)?) (\d+(?:\.\d+)?)$"
)


class ParseError(ValueError):
    pass


def parse_elapsed(line: str, source: Path) -> float:
    match = RESULT_RE.match(line.strip())
    if not match:
        raise ParseError(f"malformed perf result line in {source}: {line!r}")
    minutes = float(match.group(1)) if match.group(1) else 0.0
    return (minutes * 60 + float(match.group(2))) * 60 + float(match.group(3))


def collect(results_dir: Path, version: str, architecture: str, repeats: int) -> dict:
    results: dict[str, dict] = {}
    measurements: list[dict] = []
    for script, expected in EXPECTED_SCRIPTS:
        base = script[:-3]  # strip .sh
        subtests_path = results_dir / f"{base}.subtests"
        if not subtests_path.is_file():
            raise ParseError(f"missing subtest list for {script}")
        subtests = [line.strip() for line in subtests_path.read_text().splitlines() if line.strip()]
        if len(subtests) != expected:
            raise ParseError(
                f"{script} recorded {len(subtests)} subtests, expected {expected}"
            )
        for subtest in subtests:
            prefix = f"{base}.{subtest}"
            descr_path = results_dir / f"{prefix}.descr"
            result_path = results_dir / f"{prefix}.result"
            if not descr_path.is_file() or not result_path.is_file():
                raise ParseError(f"missing description or result for {prefix}")
            descr = descr_path.read_text(encoding="utf-8").strip()
            if not descr:
                raise ParseError(f"empty description for {prefix}")
            elapsed = parse_elapsed(result_path.read_text(), result_path)
            if not math.isfinite(elapsed) or elapsed < 0:
                raise ParseError(f"invalid elapsed time for {prefix}")
            name = f"{prefix}: {descr}"
            if name in results:
                raise ParseError(f"duplicate perf metric: {name}")
            results[name] = {
                "value": round(elapsed, 3),
                "unit": "s",
                "direction": "lower_is_better",
                "group": base,
                "source_name": name,
                "source_file": f"git_perf_results/{prefix}.result",
            }
            measurements.append({
                "script": script, "subtest": int(subtest),
                "descr": descr, "value": round(elapsed, 3), "unit": "s",
                "source_name": name,
            })
    return {
        "parameters": {
            "suite": "git t/perf",
            "git_version": version,
            "git_tag": "v2.56.0",
            "repeats": repeats,
            "scripts": [script for script, _count in EXPECTED_SCRIPTS],
            "workload_repo": "git.git v2.56.0 depth-1 checkout",
        },
        "runtime_context": {
            "architecture": architecture,
            "collected_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
        "measurements": measurements,
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("results_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("version")
    parser.add_argument("architecture")
    parser.add_argument("repeats", type=int)
    args = parser.parse_args()
    try:
        payload = collect(args.results_dir, args.version, args.architecture, args.repeats)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"[git] ERROR: {exc}", file=sys.stderr)
        return 1
    total = len(payload["results"])
    print(f"[git] collected {total} metrics from {len(EXPECTED_SCRIPTS)} perf scripts")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
