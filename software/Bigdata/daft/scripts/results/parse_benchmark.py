#!/usr/bin/env python3
"""Normalize the documented 22-query Daft TPC-H native run."""

from __future__ import annotations

import hashlib
import json
import math
import statistics
import sys
from pathlib import Path


def parse(timings: Path, manifest: Path, revision_file: Path, sf: int, rounds: int) -> dict:
    rows = [json.loads(line) for line in timings.read_text(encoding="utf-8").splitlines() if line.strip()]
    expected = {(round_number, query) for round_number in range(1, rounds + 1) for query in range(1, 23)}
    actual = {(row.get("round"), row.get("q")) for row in rows}
    if len(rows) != len(expected) or actual != expected:
        raise ValueError(f"expected {len(expected)} unique round/query measurements; got {len(rows)}")
    samples: dict[int, list[float]] = {query: [] for query in range(1, 23)}
    for row in rows:
        if row.get("runner") != "native" or "error" in row:
            raise ValueError(f"query failed or used a different runner: {row}")
        value = row.get("wall_s")
        if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or value <= 0:
            raise ValueError(f"invalid official wall time: {row}")
        if row["round"] > 1:
            samples[row["q"]].append(float(value))
    signature = hashlib.sha256(manifest.read_bytes()).hexdigest()
    revision = revision_file.read_text(encoding="utf-8").strip()
    if not revision or len(revision) != 40:
        raise ValueError("missing full upstream revision")
    return {
        "parameters": {
            "scale_factor": sf, "rounds": rounds, "warmup_rounds": 1,
            "runner": "native", "queries": list(range(1, 23)),
            "dataset_manifest_sha256": signature, "upstream_revision": revision,
            "q13_compatibility_change": "Expression.match -> Expression.regexp",
        },
        "results": {
            f"q{query:02d}/wall_time": {
                "value": statistics.median(samples[query]), "unit": "s",
                "direction": "lower_is_better", "group": f"TPC-H SF{sf}",
                "source_name": f"tpch_q{query}",
            }
            for query in range(1, 23)
        },
    }


def main() -> int:
    try:
        source, manifest, revision, sf, rounds, output = sys.argv[1:]
        result = parse(Path(source), Path(manifest), Path(revision), int(sf), int(rounds))
        Path(output).write_text(json.dumps(result, ensure_ascii=False, indent=2, allow_nan=False) + "\n", encoding="utf-8")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[daft-parse] ERROR: {error}", file=sys.stderr)
        return 1
    print("[daft-parse] normalized 22 official TPC-H query times")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
