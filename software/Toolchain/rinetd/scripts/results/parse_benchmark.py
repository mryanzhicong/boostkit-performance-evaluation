#!/usr/bin/env python3
"""Aggregate the rinetd loopback TCP measurements into per-scenario metrics.

Every repetition runs one client process against one server process, either
directly on the loopback address or through the rinetd instance.  The client
prints exactly one ``RESULT`` line: throughput scenarios report the transferred
bytes and the measured seconds, latency scenarios report the mean and 99th
percentile round-trip time.  The parser keeps all raw samples, derives the
published metrics, reports medians and fails when a declared scenario is
incomplete, when a repetition exited non-zero, when the server did not report a
matching byte count, or when a value is missing or not a positive finite number.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path
from typing import Any

MIB = 1024 * 1024
THROUGHPUT_SCENARIOS: tuple[dict[str, Any], ...] = (
    {"scenario": "throughput_4m_direct", "mode": "throughput", "payload": 4 * MIB, "connections": 1},
    {"scenario": "throughput_4m_forwarded", "mode": "throughput", "payload": 4 * MIB, "connections": 1},
    {"scenario": "throughput_16m_direct", "mode": "throughput", "payload": 16 * MIB, "connections": 1},
    {"scenario": "throughput_16m_forwarded", "mode": "throughput", "payload": 16 * MIB, "connections": 1},
    {"scenario": "throughput_4m_8conn_direct", "mode": "throughput", "payload": 4 * MIB, "connections": 8},
    {"scenario": "throughput_4m_8conn_forwarded", "mode": "throughput", "payload": 4 * MIB, "connections": 8},
)
LATENCY_SCENARIOS: tuple[dict[str, Any], ...] = (
    {"scenario": "latency_64b_direct", "mode": "latency", "request_bytes": 64, "round_trips": 2000},
    {"scenario": "latency_64b_forwarded", "mode": "latency", "request_bytes": 64, "round_trips": 2000},
)
SCENARIOS = THROUGHPUT_SCENARIOS + LATENCY_SCENARIOS
SCENARIO_BY_NAME: dict[str, dict[str, Any]] = {item["scenario"]: item for item in SCENARIOS}

THROUGHPUT_LINE = re.compile(
    r"^RESULT mode=throughput payload=(?P<payload>\d+) connections=(?P<connections>\d+) "
    r"seconds=(?P<seconds>[0-9.eE+-]+) bytes=(?P<bytes>\d+) bytes_per_second=(?P<rate>[0-9.eE+-]+)\s*$"
)
LATENCY_LINE = re.compile(
    r"^RESULT mode=latency request_bytes=(?P<request>\d+) round_trips=(?P<round_trips>\d+) "
    r"seconds=(?P<seconds>[0-9.eE+-]+) bytes=(?P<bytes>\d+) "
    r"rtt_mean_us=(?P<mean>[0-9.eE+-]+) rtt_p99_us=(?P<p99>[0-9.eE+-]+) "
    r"bytes_per_second=(?P<rate>[0-9.eE+-]+)\s*$"
)
SERVER_LINE = re.compile(r"^SERVER role=(?P<role>\S+) .*bytes=(?P<bytes>\d+)\s*$")
MAX_BYTES_PER_SECOND = 1e12


def fail(message: str) -> None:
    print(f"[rinetd-parse] ERROR: {message}", file=sys.stderr)


def positive(value: str, label: str, path: Path) -> float:
    number = float(value)
    if not math.isfinite(number) or number <= 0.0:
        raise RuntimeError(f"{path} reports an invalid {label}: {value}")
    return number


def parse_client_log(path: Path, scenario: dict[str, Any]) -> dict[str, float]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    if scenario["mode"] == "throughput":
        matches = [m for m in (THROUGHPUT_LINE.match(line) for line in text.splitlines()) if m]
        if len(matches) != 1:
            raise RuntimeError(f"{path} must contain exactly one throughput RESULT line, found {len(matches)}")
        match = matches[0]
        payload = int(match.group("payload"))
        connections = int(match.group("connections"))
        if payload != scenario["payload"]:
            raise RuntimeError(f"{path} measured payload {payload}, expected {scenario['payload']}")
        if connections != scenario["connections"]:
            raise RuntimeError(f"{path} measured {connections} connections, expected {scenario['connections']}")
        seconds = positive(match.group("seconds"), "seconds", path)
        transferred = int(match.group("bytes"))
        expected = scenario["payload"] * scenario["connections"]
        if transferred != expected:
            raise RuntimeError(f"{path} transferred {transferred} bytes, expected {expected}")
        rate = positive(match.group("rate"), "bytes_per_second", path)
        if rate >= MAX_BYTES_PER_SECOND:
            raise RuntimeError(f"{path} reports an implausible bytes_per_second: {rate}")
        if abs(rate - transferred / seconds) > max(1.0, rate * 0.01):
            raise RuntimeError(f"{path} bytes_per_second is inconsistent with bytes/seconds")
        return {"bytes_per_second": rate, "seconds": seconds, "bytes": float(transferred)}
    matches = [m for m in (LATENCY_LINE.match(line) for line in text.splitlines()) if m]
    if len(matches) != 1:
        raise RuntimeError(f"{path} must contain exactly one latency RESULT line, found {len(matches)}")
    match = matches[0]
    if int(match.group("request")) != scenario["request_bytes"]:
        raise RuntimeError(f"{path} measured request_bytes {match.group('request')}, expected {scenario['request_bytes']}")
    if int(match.group("round_trips")) != scenario["round_trips"]:
        raise RuntimeError(f"{path} recorded {match.group('round_trips')} round trips, expected {scenario['round_trips']}")
    mean_us = positive(match.group("mean"), "rtt_mean_us", path)
    p99_us = positive(match.group("p99"), "rtt_p99_us", path)
    if p99_us < mean_us:
        raise RuntimeError(f"{path} reports p99 {p99_us} below mean {mean_us}")
    rate = positive(match.group("rate"), "bytes_per_second", path)
    seconds = positive(match.group("seconds"), "seconds", path)
    return {
        "rtt_mean_us": mean_us,
        "rtt_p99_us": p99_us,
        "bytes_per_second": rate,
        "seconds": seconds,
        "bytes": float(match.group("bytes")),
    }


def check_server_log(path: Path) -> None:
    if not path.is_file():
        raise RuntimeError(f"missing server log: {path}")
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = [m for m in (SERVER_LINE.match(line) for line in text.splitlines()) if m]
    if len(lines) != 1:
        raise RuntimeError(f"{path} must contain exactly one SERVER line, found {len(lines)}")
    if int(lines[0].group("bytes")) <= 0:
        raise RuntimeError(f"{path} reports no transferred bytes")


def load_sample(run_dir: Path, label: str, check_value: bool) -> dict[str, Any]:
    sample_path = run_dir / f"{label}.json"
    if not sample_path.is_file():
        raise RuntimeError(f"missing sample: {sample_path}")
    try:
        payload = json.loads(sample_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid sample {sample_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"sample is not an object: {sample_path}")
    if payload.get("exit_code") != 0:
        raise RuntimeError(f"{sample_path} failed with exit code {payload.get('exit_code')}")
    if payload.get("timed_out") is True:
        raise RuntimeError(f"{sample_path} timed out")
    wall = payload.get("wall_seconds")
    rss = payload.get("max_rss_mib")
    if isinstance(wall, bool) or not isinstance(wall, (int, float)):
        raise RuntimeError(f"{sample_path} has no numeric wall time")
    if isinstance(rss, bool) or not isinstance(rss, (int, float)):
        raise RuntimeError(f"{sample_path} has no numeric RSS")
    if not math.isfinite(float(wall)) or wall <= 0.0:
        raise RuntimeError(f"{sample_path} wall time must be positive")
    if not math.isfinite(float(rss)) or rss <= 0.0:
        raise RuntimeError(f"{sample_path} RSS must be positive")
    log_path = run_dir / f"{label}.log"
    if not log_path.is_file() or log_path.stat().st_size == 0:
        raise RuntimeError(f"missing raw client log: {log_path}")
    check_server_log(run_dir / f"server-{label}.log")
    sample: dict[str, Any] = {
        "label": label,
        "wall_seconds": round(float(wall), 6),
        "max_rss_mib": round(float(rss), 3),
    }
    if check_value:
        sample.update(parse_client_log(log_path, SCENARIO_BY_NAME[run_dir.name]))
    return sample


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "min": round(float(min(values)), 9),
        "max": round(float(max(values)), 9),
        "mean": round(float(statistics.fmean(values)), 9),
        "median": round(float(statistics.median(values)), 9),
        "stdev": round(float(statistics.stdev(values)), 9) if len(values) > 1 else 0.0,
    }


def build_result(
    scenario: dict[str, Any],
    metric: str,
    unit: str,
    direction: str,
    values: list[float],
    extra: dict[str, Any],
) -> dict[str, Any]:
    return {
        "source_name": f"{scenario['scenario']}.{metric}",
        "scenario": scenario["scenario"],
        "group": scenario["scenario"],
        "path": "direct" if scenario["scenario"].endswith("_direct") else "forwarded",
        "unit": unit,
        "direction": direction,
        "value": round(float(statistics.median(values)), 9),
        "samples": [round(float(value), 9) for value in values],
        "statistics": summarize(values),
        "repetitions": len(values),
        **extra,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--reps", required=True, type=int)
    parser.add_argument("--warmup-reps", type=int, default=1)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.reps < 1:
        fail("--reps must be at least 1")
        return 1
    results: dict[str, Any] = {}
    for scenario in SCENARIOS:
        run_dir = args.runs / scenario["scenario"]
        try:
            for index in range(1, args.warmup_reps + 1):
                load_sample(run_dir, f"warmup{index}", check_value=False)
            samples = [
                load_sample(run_dir, f"rep{index}", check_value=True)
                for index in range(1, args.reps + 1)
            ]
        except RuntimeError as exc:
            fail(f"scenario {scenario['scenario']}: {exc}")
            return 1
        wall = [sample["wall_seconds"] for sample in samples]
        rss = [sample["max_rss_mib"] for sample in samples]
        extra = {"raw_log": f"runs/{scenario['scenario']}/rep1.log"}
        if scenario["mode"] == "throughput":
            rates = [sample["bytes_per_second"] for sample in samples]
            mib_rates = [value / MIB for value in rates]
            extra["payload_bytes"] = scenario["payload"]
            extra["connections"] = scenario["connections"]
            metrics = (
                ("throughput_mib_per_second", "MiB/s", "higher_is_better", mib_rates),
                ("bytes_per_second", "B/s", "higher_is_better", rates),
                ("wall_seconds", "s", "lower_is_better", wall),
                ("peak_rss_mib", "MiB", "lower_is_better", rss),
            )
        else:
            means = [sample["rtt_mean_us"] for sample in samples]
            p99s = [sample["rtt_p99_us"] for sample in samples]
            extra["request_bytes"] = scenario["request_bytes"]
            extra["round_trips"] = scenario["round_trips"]
            metrics = (
                ("rtt_mean_us", "us", "lower_is_better", means),
                ("rtt_p99_us", "us", "lower_is_better", p99s),
                ("wall_seconds", "s", "lower_is_better", wall),
                ("peak_rss_mib", "MiB", "lower_is_better", rss),
            )
        for metric, unit, direction, values in metrics:
            entry = build_result(scenario, metric, unit, direction, values, extra)
            results[entry["source_name"]] = entry

    payload = {
        "software": "rinetd",
        "category": "Toolchain",
        "benchmark": "loopback TCP direct versus rinetd-forwarded, fixed matrix",
        "parameters": {
            "measurement_reps": args.reps,
            "warmup_reps": args.warmup_reps,
            "offline_measurement": True,
            "strict_parser": True,
            "invocation": "one client process per scenario, one server process per process",
            "matrix": "4 MiB and 16 MiB single connection, 4 MiB x 8 connections, 64-byte round trips",
            "client_clock": "CLOCK_MONOTONIC",
        },
        "scenarios": [scenario["scenario"] for scenario in SCENARIOS],
        "results": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[rinetd-parse] wrote {len(results)} metrics to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
