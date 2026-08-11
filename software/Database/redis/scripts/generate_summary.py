#!/usr/bin/env python3
"""Render a concise human-readable Redis result summary."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: generate_summary.py INPUT OUTPUT", file=sys.stderr)
        return 1
    data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    environment = data["environment"]
    summary = data["summary"]
    lines = [
        "Redis performance benchmark",
        f"Version: {data['version']}",
        f"Architecture: {environment['architecture']}",
        f"CPU cores: {environment['cpu_cores']}",
        f"SET QPS at concurrency 50: {summary['set_qps_c50']} (higher is better)",
        f"GET QPS at concurrency 50: {summary['get_qps_c50']} (higher is better)",
        f"Average latency: {summary['avg_latency_ms']} ms (lower is better)",
        f"Maximum P99 latency: {summary['max_p99_latency_ms']} ms (lower is better)",
        f"Client concurrency scaling ratio: {summary['client_scaling_ratio']} (higher is better)",
    ]
    Path(sys.argv[2]).write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
