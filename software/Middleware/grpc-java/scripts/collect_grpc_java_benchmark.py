#!/usr/bin/env python3
"""Collect the unary echo benchmark run reports into results.json."""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Scenario matrix: message sizes crossed with the channel ladder
# (mysql thread-ladder style).  The run-file slugs match
# grpc_java_test.sh.
SCENARIOS = (
    ("1k", 1024, "unary 1KiB"),
    ("16k", 16384, "unary 16KiB"),
)
CHANNELS_LADDER = (128, 256, 512, 1024)

# Report fields kept per (scenario, channels) combination.
FIELDS = (
    ("calls/s", "calls_per_second", "calls/s", "higher_is_better"),
    ("avg RTT", "avg_rtt_ms", "ms", "lower_is_better"),
    ("p99 RTT", "p99_rtt_ms", "ms", "lower_is_better"),
)


def load_run(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError(f"{path} is not a JSON object")
    return payload


def validate_run(
    payload: dict[str, Any], scenario: str, size: int, channels: int, path: Path
) -> None:
    if payload.get("scenario") != scenario:
        raise ValueError(
            f"{path} reports scenario {payload.get('scenario')!r}, "
            f"expected {scenario!r}"
        )
    if payload.get("message_size") != size:
        raise ValueError(
            f"{path} reports message_size {payload.get('message_size')!r}, "
            f"expected {size}"
        )
    if payload.get("channels") != channels:
        raise ValueError(
            f"{path} reports channels {payload.get('channels')!r}, "
            f"expected {channels}"
        )
    pipeline = payload.get("pipeline")
    if not isinstance(pipeline, int) or pipeline <= 0:
        raise ValueError(f"{path} has an invalid pipeline value: {pipeline!r}")
    if not payload.get("duration_seconds", 0) > 0:
        raise ValueError(f"{path} has a non-positive duration")
    for field, json_field, _unit, _direction in FIELDS:
        value = payload.get(json_field)
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"{path} is missing a numeric {json_field}")
        if not math.isfinite(float(value)) or value <= 0:
            raise ValueError(f"{path} has a non-positive {json_field}: {value}")


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_grpc_java_benchmark.py RUNS_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1

    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    results: dict[str, dict[str, Any]] = {}

    for slug, size, scenario in SCENARIOS:
        for channels in CHANNELS_LADDER:
            run_path = runs_dir / f"unary-{slug}-c{channels}.json"
            payload = load_run(run_path)
            validate_run(payload, scenario, size, channels, run_path)
            for field, json_field, unit, direction in FIELDS:
                source_name = (
                    f"gRPC-Java {scenario} --channels={channels}: {field}"
                )
                if source_name in results:
                    raise ValueError(f"duplicate benchmark metric: {source_name}")
                results[source_name] = {
                    "source_name": source_name,
                    "scenario": scenario,
                    "channels": channels,
                    "source_field": field,
                    "value": payload[json_field],
                    "unit": unit,
                    "direction": direction,
                    "source_file": f"benchmark/runs/{run_path.name}",
                }

    expected = len(SCENARIOS) * len(CHANNELS_LADDER) * len(FIELDS)
    if len(results) != expected:
        raise ValueError(f"collected {len(results)} metrics, expected {expected}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "grpc-java",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime(
                    "%Y-%m-%dT%H:%M:%SZ"
                ),
                "parameters": {
                    "transport": "grpc-netty-shaded (default)",
                    "pipeline": int(os.environ.get("GRPC_PIPELINE", "8")),
                    "warmup_seconds": int(
                        os.environ.get("GRPC_WARMUP_SECONDS", "5")
                    ),
                    "duration_seconds": int(
                        os.environ.get("GRPC_DURATION_SECONDS", "30")
                    ),
                    "channels_ladder": list(CHANNELS_LADDER),
                    "scenarios": {
                        scenario: f"{size} byte unary echo requests"
                        for _slug, size, scenario in SCENARIOS
                    },
                },
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[grpc-java] recorded {len(results)} unary echo benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[grpc-java] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
