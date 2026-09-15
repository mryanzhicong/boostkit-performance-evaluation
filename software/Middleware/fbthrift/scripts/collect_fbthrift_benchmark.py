#!/usr/bin/env python3
"""Collect the fbthrift perf benchmark client logs into results.json."""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Scenario matrix: workloads crossed with the client ladder
# (mysql thread-ladder style).  The run-file slugs match
# fbthrift_test.sh.
WORKLOADS = ("noop", "sum", "download")
CLIENTS_LADDER = (1, 4, 16, 64)

# Report fields kept per (workload, clients) combination.  QPS comes
# from the upstream per-second stats (median over the measurement
# window); the round-trip latencies come from the harness-added
# sampled recorder (std::chrono::steady_clock, unit=ns).
FIELDS = (
    ("QPS", "qps", "ops/s", "higher_is_better"),
    ("avg RTT", "avg_rtt_ns", "ns", "lower_is_better"),
    ("p99 RTT", "p99_rtt_ns", "ns", "lower_is_better"),
)

TOTAL_QPS_RE = re.compile(r"TOTAL QPS: ([0-9.eE+-]+)")
LATENCY_RE = re.compile(
    r"LATENCY ns \| avg: ([0-9.eE+-]+) \| p50: ([0-9.eE+-]+) "
    r"\| p99: ([0-9.eE+-]+) \| max: ([0-9.eE+-]+) \| samples: ([0-9]+)"
)


def load_run(path: Path) -> dict[str, Any]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise ValueError(f"cannot read {path}: {exc}") from exc

    warmup = int(os.environ.get("FBTHRIFT_WARMUP_SECONDS", "5"))
    duration = int(os.environ.get("FBTHRIFT_DURATION_SECONDS", "30"))

    # The client prints one "TOTAL QPS" line per stats interval (1s)
    # from the very start; the first `warmup` lines cover the warm-up
    # window and are dropped before taking the median.
    qps_samples: list[float] = []
    for match in TOTAL_QPS_RE.finditer(text):
        qps_samples.append(float(match.group(1)))
    if len(qps_samples) < warmup + 1:
        raise ValueError(
            f"{path}: only {len(qps_samples)} QPS samples, need at least "
            f"{warmup + 1} ({warmup}s warm-up + measurement)"
        )
    measured = qps_samples[warmup:]
    median_qps = statistics.median(measured)

    latency_matches = LATENCY_RE.findall(text)
    if not latency_matches:
        raise ValueError(f"{path}: no LATENCY ns summary line")
    avg_rtt_ns, _p50, p99_rtt_ns, _max, samples = latency_matches[-1]
    if int(samples) <= 0:
        raise ValueError(f"{path}: latency summary has no samples")

    return {
        "qps": median_qps,
        "avg_rtt_ns": float(avg_rtt_ns),
        "p99_rtt_ns": float(p99_rtt_ns),
        "latency_samples": int(samples),
        "qps_samples_used": len(measured),
        "qps_samples_total": len(qps_samples),
        "warmup_seconds": warmup,
        "duration_seconds": duration,
    }


def validate_run(
    payload: dict[str, Any], workload: str, clients: int, path: Path
) -> None:
    for field, json_field, _unit, _direction in FIELDS:
        value = payload.get(json_field)
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"{path} is missing a numeric {json_field}")
        if not math.isfinite(float(value)) or value <= 0:
            raise ValueError(f"{path} has a non-positive {json_field}: {value}")


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: collect_fbthrift_benchmark.py RUNS_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1

    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    results: dict[str, dict[str, Any]] = {}

    for workload in WORKLOADS:
        for clients in CLIENTS_LADDER:
            run_path = runs_dir / f"{workload}-c{clients}.log"
            payload = load_run(run_path)
            validate_run(payload, workload, clients, run_path)
            for field, json_field, unit, direction in FIELDS:
                source_name = f"fbthrift {workload} --clients={clients}: {field}"
                if source_name in results:
                    raise ValueError(f"duplicate benchmark metric: {source_name}")
                results[source_name] = {
                    "source_name": source_name,
                    "workload": workload,
                    "clients": clients,
                    "source_field": field,
                    "value": payload[json_field],
                    "unit": unit,
                    "direction": direction,
                    "source_file": f"benchmark/runs/{run_path.name}",
                }

    expected = len(WORKLOADS) * len(CLIENTS_LADDER) * len(FIELDS)
    if len(results) != expected:
        raise ValueError(f"collected {len(results)} metrics, expected {expected}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "software": "fbthrift",
                "version": os.environ["SOFTWARE_VERSION"],
                "architecture": os.environ["EXPECTED_ARCH"],
                "timestamp": datetime.now(timezone.utc).strftime(
                    "%Y-%m-%dT%H:%M:%SZ"
                ),
                "parameters": {
                    "build": "official lockstep git tags "
                    "(folly/fizz/wangle/mvfst/fbthrift), source-built "
                    "third-party dependencies, isolated prefix",
                    "harness": "upstream thrift/perf/cpp2 "
                    "(official IDL, server, client) + sampled RTT "
                    "recorder",
                    "transport": os.environ.get("FBTHRIFT_TRANSPORT", "rocket"),
                    "client_mode": "async, one event base per client "
                    "thread, max_outstanding_ops=100",
                    "clock": "std::chrono::steady_clock (unit=ns)",
                    "warmup_seconds": int(
                        os.environ.get("FBTHRIFT_WARMUP_SECONDS", "5")
                    ),
                    "duration_seconds": int(
                        os.environ.get("FBTHRIFT_DURATION_SECONDS", "30")
                    ),
                    "chunk_size": 1024,
                    "clients_ladder": list(CLIENTS_LADDER),
                    "scenarios": {
                        "noop": "async_eb noop() — empty request/response "
                        "round trip (pure RPC overhead path)",
                        "sum": "async_eb sum(TwoInts)->TwoInts — small-"
                        "payload serialization on both ends",
                        "download": "sync download()->Chunk2 — 1 KiB "
                        "response payload on the worker path",
                    },
                },
                "results": results,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[fbthrift] recorded {len(results)} perf benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as exc:
        print(f"[fbthrift] ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
