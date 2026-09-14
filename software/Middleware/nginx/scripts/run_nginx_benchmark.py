#!/usr/bin/env python3
"""Run the k6 static-file scenarios against nginx and normalize results."""

from __future__ import annotations

import argparse
import json
import math
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Static-file scenarios and the concurrency ladder (mysql thread-ladder
# style).  Each scenario runs once per VU level with HTTP keepalive.
SCENARIOS = (
    ("file-1k.bin", "1KiB"),
    ("file-100k.bin", "100KiB"),
)
VUS_LADDER = (128, 256, 512, 1024)

# k6 summary fields kept per (scenario, vus) combination.
FIELDS = (
    ("RPS", "http_reqs", "rate", "requests/s", "higher_is_better"),
    ("avg latency", "http_req_duration", "avg", "ms", "lower_is_better"),
    ("p95 latency", "http_req_duration", "p(95)", "ms", "lower_is_better"),
)

SCRIPT = """import http from 'k6/http';

export default function () {
  http.get(__ENV.NGINX_TARGET);
}
"""


def duration_seconds() -> int:
    try:
        value = int(os.environ.get("K6_DURATION_SECONDS", "30"))
    except ValueError as exc:
        raise RuntimeError(f"invalid K6_DURATION_SECONDS: {exc}") from exc
    if value <= 0:
        raise RuntimeError("K6_DURATION_SECONDS must be positive")
    return value


def value(metrics: dict[str, Any], metric: str, field: str, label: str) -> float:
    entry = metrics.get(metric)
    if not isinstance(entry, dict):
        raise RuntimeError(f"{label}: k6 summary is missing {metric}")
    values = entry.get("values", entry)
    if not isinstance(values, dict):
        raise RuntimeError(f"{label}: k6 summary has invalid {metric} values")
    result = values.get(field)
    if isinstance(result, bool) or not isinstance(result, (int, float)):
        raise RuntimeError(f"{label}: k6 summary is missing {metric}.{field}")
    result = float(result)
    if not math.isfinite(result) or result < 0:
        raise RuntimeError(f"{label}: k6 summary has invalid {metric}.{field}")
    return result


def parse_summary(path: Path, label: str) -> dict[str, tuple[float, str, str]]:
    try:
        summary = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"{label}: cannot read k6 summary: {exc}") from exc
    metrics = summary.get("metrics")
    if not isinstance(metrics, dict):
        raise RuntimeError(f"{label}: k6 summary is missing metrics")

    request_count = value(metrics, "http_reqs", "count", label)
    failed_rate = value(metrics, "http_req_failed", "rate", label)
    if request_count <= 0:
        raise RuntimeError(f"{label}: k6 produced no HTTP requests")
    if failed_rate != 0:
        raise RuntimeError(f"{label}: k6 reported a non-zero http_req_failed rate: {failed_rate}")

    extracted: dict[str, tuple[float, str, str]] = {}
    for field, metric, metric_field, unit, direction in FIELDS:
        extracted[field] = (
            value(metrics, metric, metric_field, label),
            unit,
            direction,
        )
    return extracted


def run_scenario(
    k6: Path,
    script: Path,
    label: str,
    url: str,
    vus: int,
    duration: int,
    raw: Any,
) -> Path:
    summary = script.parent / f"benchmark_{label}_vus{vus}_summary.json"
    command = [
        str(k6),
        "run",
        "--vus",
        str(vus),
        "--duration",
        f"{duration}s",
        "--summary-export",
        str(summary),
        str(script),
    ]
    raw.write(f"[nginx-k6] scenario: {label} --vus={vus}\n")
    raw.write("[nginx-k6] command: " + " ".join(command) + "\n")
    completed = subprocess.run(
        command,
        env={**os.environ, "NGINX_TARGET": url},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    raw.write(completed.stdout)
    raw.write("\n")
    if completed.returncode != 0:
        raise RuntimeError(f"{label} --vus={vus}: k6 exited with code {completed.returncode}")
    if not summary.is_file():
        raise RuntimeError(f"{label} --vus={vus}: k6 did not write its summary JSON")
    return summary


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--k6", type=Path, required=True)
    parser.add_argument("--url-base", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--raw-output", type=Path, required=True)
    args = parser.parse_args()

    if not args.k6.is_file() or not (args.k6.stat().st_mode & 0o111):
        print("[nginx-k6] ERROR: k6 executable is unavailable", file=sys.stderr)
        return 1
    duration = duration_seconds()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.raw_output.parent.mkdir(parents=True, exist_ok=True)
    script = args.output.parent / "nginx_k6_request.js"
    script.write_text(SCRIPT, encoding="utf-8")

    try:
        results: dict[str, dict[str, Any]] = {}
        with args.raw_output.open("w", encoding="utf-8") as raw:
            for file_name, scenario in SCENARIOS:
                url = f"{args.url_base.rstrip('/')}/{file_name}"
                for vus in VUS_LADDER:
                    label = f"static {scenario}"
                    summary = run_scenario(
                        args.k6, script, label, url, vus, duration, raw
                    )
                    extracted = parse_summary(summary, f"{label} --vus={vus}")
                    for field, (result, unit, direction) in extracted.items():
                        source_name = f"k6 static {scenario} --vus={vus}: {field}"
                        if source_name in results:
                            raise RuntimeError(f"duplicate k6 metric: {source_name}")
                        results[source_name] = {
                            "source_name": source_name,
                            "scenario": scenario,
                            "vus": vus,
                            "source_field": field,
                            "value": result,
                            "unit": unit,
                            "direction": direction,
                            "source_file": args.raw_output.name,
                        }
        if not results:
            raise RuntimeError("k6 produced no nginx metrics")
        expected = len(SCENARIOS) * len(VUS_LADDER) * len(FIELDS)
        if len(results) != expected:
            raise RuntimeError(
                f"k6 produced {len(results)} metrics, expected {expected}"
            )
    except (RuntimeError, OSError) as exc:
        print(f"[nginx-k6] ERROR: {exc}", file=sys.stderr)
        return 1

    payload = {
        "software": "nginx",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "tool": "k6",
            "k6_version": os.environ.get("K6_VERSION", "2.2.0"),
            "duration_seconds": duration,
            "connection_reuse": True,
            "scenarios": {
                scenario: f"HTTP GET static file {file_name}"
                for file_name, scenario in SCENARIOS
            },
            "vus_ladder": list(VUS_LADDER),
        },
        "results": results,
    }
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[nginx-k6] normalized {len(results)} static-file metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
