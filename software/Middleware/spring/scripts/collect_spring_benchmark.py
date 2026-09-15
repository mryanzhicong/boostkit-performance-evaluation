#!/usr/bin/env python3
"""Collect the WebFlux echo benchmark run reports into results.json."""

from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Scenario matrix: message sizes crossed with the concurrency ladder
# (mysql thread-ladder style).  The run-file slugs match spring_test.sh.
SCENARIOS = (
    ("1k", 1024, "echo 1KiB"),
    ("16k", 16384, "echo 16KiB"),
)
CONCURRENCY_LADDER = (128, 256, 512, 1024)

# Report fields kept per (scenario, concurrency) combination.
FIELDS = (
    ("exchanges/s", "exchanges_per_second", "exchanges/s", "higher_is_better"),
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
    payload: dict[str, Any], scenario: str, size: int, concurrency: int, path: Path
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
    if payload.get("concurrency") != concurrency:
        raise ValueError(
            f"{path} reports concurrency {payload.get('concurrency')!r}, "
            f"expected {concurrency}"
        )
    drivers = payload.get("drivers")
    if not isinstance(drivers, int) or drivers <= 0:
        raise ValueError(f"{path} has an invalid drivers value: {drivers!r}")
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
            "usage: collect_spring_benchmark.py RUNS_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1

    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    results: dict[str, dict[str, Any]] = {}

    for slug, size, scenario in SCENARIOS:
        for concurrency in CONCURRENCY_LADDER:
            run_path = runs_dir / f"echo-{slug}-c{concurrency}.json"
            payload = load_run(run_path)
            validate_run(payload, scenario, size, concurrency, run_path)
            for field, json_field, unit, direction in FIELDS:
                source_name = f"Spring {scenario} --concurrency={concurrency}: {field}"
                if source_name in results:
                    raise ValueError(f"duplicate benchmark metric: {source_name}")
                results[source_name] = {
                    "source_name": source_name,
                    "scenario": scenario,
                    "concurrency": concurrency,
                    "source_field": field,
                    "value": payload[json_field],
                    "unit": unit,
                    "direction": direction,
                    "source_file": f"benchmark/runs/{run_path.name}",
                }

    expected = len(SCENARIOS) * len(CONCURRENCY_LADDER) * len(FIELDS)
    if len(results) != expected:
        raise ValueError(f"collected {len(results)} metrics, expected {expected}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "spring",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime(
                    "%Y-%m-%dT%H:%M:%SZ"
                ),
                "parameters": {
                    "pipeline": "WebFlux functional (POST /echo)",
                    "exchange_driver": "MockServerWebExchange (official spring-test)",
                    "drivers": int(os.environ.get("SPRING_DRIVERS", "16")),
                    "warmup_seconds": int(
                        os.environ.get("SPRING_WARMUP_SECONDS", "5")
                    ),
                    "duration_seconds": int(
                        os.environ.get("SPRING_DURATION_SECONDS", "30")
                    ),
                    "concurrency_ladder": list(CONCURRENCY_LADDER),
                    "scenarios": {
                        scenario: f"{size} byte echo request payloads"
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
    print(f"[spring] recorded {len(results)} WebFlux echo benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[spring] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
