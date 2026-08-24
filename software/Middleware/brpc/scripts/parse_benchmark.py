#!/usr/bin/env python3
"""Normalize brpc's official benchmark_http bvar output into named metrics.

The official benchmark client (example/http_c++/benchmark_http.cpp) exposes a
bvar::LatencyRecorder named "client"; its counters (client_qps,
client_latency, client_latency_80/90/99/999/9999, client_max_latency,
client_count) are dumped verbatim from the client's dummy server endpoint
/vars/client_*. This script extracts the scalar values and preserves the
official bvar names verbatim.
"""

from __future__ import annotations

import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# Official bvar names emitted by bvar::LatencyRecorder("client") with the
# default bvar_latency_p1/p2/p3 percentiles (80/90/99). Each entry maps the
# verbatim bvar name to its official unit and optimization direction.
METRIC_CONTRACT: dict[str, tuple[str, str]] = {
    "client_qps": ("requests/s", "higher_is_better"),
    "client_count": ("requests", "higher_is_better"),
    "client_latency": ("us", "lower_is_better"),
    "client_max_latency": ("us", "lower_is_better"),
    "client_latency_80": ("us", "lower_is_better"),
    "client_latency_90": ("us", "lower_is_better"),
    "client_latency_99": ("us", "lower_is_better"),
    "client_latency_999": ("us", "lower_is_better"),
    "client_latency_9999": ("us", "lower_is_better"),
}


def parse_bvar_dump(path: Path) -> dict[str, float]:
    values: dict[str, float] = {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise RuntimeError(f"cannot read bvar dump: {exc}") from exc
    for line in lines:
        match = re.fullmatch(r"(\S+)\s+:\s+(.+)", line)
        if match is None:
            continue
        name, raw_value = match.groups()
        if not name.startswith("client_"):
            continue
        try:
            value = float(raw_value)
        except ValueError:
            # Series variables (client_latency_cdf, client_latency_percentiles)
            # have no single scalar value and are not reportable metrics.
            continue
        if not math.isfinite(value) or value < 0:
            raise RuntimeError(f"bvar {name} has an invalid scalar value: {raw_value}")
        values[name] = value
    if not values:
        raise RuntimeError("bvar dump contains no scalar client_* values")
    return values


def normalize_results(values: dict[str, float]) -> dict[str, dict[str, Any]]:
    missing = sorted(set(METRIC_CONTRACT) - set(values))
    if missing:
        raise RuntimeError(f"official bvar dump is missing metrics: {missing}")
    results: dict[str, dict[str, Any]] = {}
    for name, (unit, direction) in METRIC_CONTRACT.items():
        results[name] = {
            "source_name": name,
            "source_field": "bvar",
            "raw_value": values[name],
            "raw_unit": unit,
            "value": values[name],
            "unit": unit,
            "direction": direction,
        }
    return results


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: parse_benchmark.py BVAR_DUMP_TEXT NORMALIZED_OUTPUT",
            file=sys.stderr,
        )
        return 1
    bvar_path, normalized_output = Path(sys.argv[1]), Path(sys.argv[2])

    try:
        values = parse_bvar_dump(bvar_path)
        results = normalize_results(values)
    except (RuntimeError, TypeError, ValueError) as exc:
        print(f"[brpc-parse] ERROR: {exc}", file=sys.stderr)
        return 1

    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    thread_num = os.environ.get("BENCHMARK_HTTP_THREAD_NUM", "50")
    duration_s = os.environ.get("BENCHMARK_HTTP_DURATION_S", "60")
    warmup_s = os.environ.get("BENCHMARK_HTTP_WARMUP_S", "5")
    server_port = os.environ.get("HTTP_SERVER_PORT", "18010")
    normalized = {
        "benchmark": "brpc_official_benchmark_http",
        "software": "brpc",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "official_entry": "example/http_c++/benchmark_http.cpp",
            "official_server": "example/http_c++/http_server.cpp",
            "url": f"127.0.0.1:{server_port}/HttpService/Echo",
            "protocol": "http",
            "thread_num": int(thread_num),
            "duration_s": int(duration_s),
            "warmup_s": int(warmup_s),
            "metric_source": "/vars/client_* of the benchmark_http dummy server",
        },
        "metric_contract": {
            "scope": "scalar client_* bvar values of the official LatencyRecorder",
            "source_field": "bvar",
            "direction_by_metric": {
                name: direction for name, (_, direction) in METRIC_CONTRACT.items()
            },
            "unit_by_metric": {
                name: unit for name, (unit, _) in METRIC_CONTRACT.items()
            },
        },
        "results": results,
    }

    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[brpc-parse] normalized {len(results)} official bvar metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
