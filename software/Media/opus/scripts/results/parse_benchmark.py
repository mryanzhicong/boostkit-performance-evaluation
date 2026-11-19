#!/usr/bin/env python3
"""Validate fixed-point Opus 1.6.1 evidence and emit Framework metrics."""

from __future__ import annotations

import csv
import io
import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

SHA256 = re.compile(r"^[0-9a-f]{64}$")
HEADER = ["scenario", "iterations", "ms_per_audio_second", "status"]
ITERATIONS = 20
AUDIO_SECONDS = 10.8
AUDIO_FRAMES = 518400
SOURCE_SHA256 = "6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1"
CASES = {
    "speech_orig_16000_complexity5": ("16kbps_c5", 16000, 5),
    "speech_orig_16000_complexity10": ("16kbps_c10", 16000, 10),
    "speech_orig_24000_complexity10": ("24kbps_c10", 24000, 10),
}


def number(value: object, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} is not numeric")
    numeric = float(value)
    if not math.isfinite(numeric) or numeric <= 0:
        raise ValueError(f"{label} is not a positive finite number")
    return numeric


def read_csv(text: str) -> dict[str, float]:
    rows = [row for row in csv.reader(io.StringIO(text)) if any(cell.strip() for cell in row)]
    if not rows or rows[0] != HEADER:
        raise ValueError(f"result CSV header must be {HEADER}")
    if len(rows) != 4:
        raise ValueError(f"result CSV must contain exactly three scenario rows, found {len(rows) - 1}")
    values: dict[str, float] = {}
    for row in rows[1:]:
        if len(row) != 4:
            raise ValueError(f"malformed result CSV row: {row}")
        scenario, iterations, value, status = row
        if scenario in values:
            raise ValueError(f"duplicate scenario: {scenario}")
        if status != "OK" or iterations != str(ITERATIONS):
            raise ValueError(f"scenario {scenario} did not complete 20 iterations")
        values[scenario] = number(float(value), f"{scenario} ms_per_audio_second")
    return values


def parse(csv_text: str, evidence: dict, version: str, architecture: str) -> dict:
    if evidence.get("version") != version:
        raise ValueError("evidence version differs from the requested Opus version")
    if evidence.get("source_mode") != "unpatched":
        raise ValueError("evidence does not describe the unpatched source")
    if evidence.get("build_system") != "autotools" or evidence.get("fixed_point") is not True:
        raise ValueError("evidence does not describe the fixed-point autotools build")
    if evidence.get("threads") != 1:
        raise ValueError("evidence does not use a single thread")
    cases = evidence.get("cases")
    if not isinstance(cases, dict) or set(cases) != set(CASES):
        raise ValueError("evidence must contain exactly the three fixed Opus cases")
    csv_values = read_csv(csv_text)
    if set(csv_values) != set(CASES):
        raise ValueError("CSV and evidence scenarios differ")
    audio_sha = None
    results = {}
    for scenario, (subgroup, bitrate, complexity) in CASES.items():
        item = cases[scenario]
        if not isinstance(item, dict):
            raise ValueError(f"evidence case {scenario} is not an object")
        for field in ("input_sha256", "encoded_sha256", "decoded_sha256"):
            if not isinstance(item.get(field), str) or not SHA256.fullmatch(item[field]):
                raise ValueError(f"evidence case {scenario} {field} is invalid")
        if item.get("input_frames") != AUDIO_FRAMES:
            raise ValueError(f"evidence case {scenario} has a different input frame count")
        if not isinstance(item.get("decoded_frames"), int) or abs(item["decoded_frames"] - AUDIO_FRAMES) > 1920:
            raise ValueError(f"evidence case {scenario} decoded frame count is invalid")
        if not isinstance(item.get("output_bytes"), int) or item["output_bytes"] <= 0:
            raise ValueError(f"evidence case {scenario} output size is invalid")
        command = item.get("command")
        if not isinstance(command, list) or "-complexity" not in command or "-framesize" not in command:
            raise ValueError(f"evidence case {scenario} command is incomplete")
        samples = item.get("samples_ms_per_audio_second")
        if not isinstance(samples, list) or len(samples) != ITERATIONS:
            raise ValueError(f"evidence case {scenario} must record exactly 20 samples")
        sample_values = [number(value, f"{scenario} sample") for value in samples]
        mean = statistics.mean(sample_values)
        if abs(csv_values[scenario] - mean) > max(1e-6, abs(mean) * 1e-9):
            raise ValueError(f"evidence case {scenario} CSV value is not the mean")
        audio_sha = item["input_sha256"]
        results[scenario] = {
            "source_name": scenario,
            "value": csv_values[scenario],
            "unit": "ms/audio second",
            "direction": "lower_is_better",
            "group": "opus",
            "subgroup": subgroup,
            "bitrate": bitrate,
            "complexity": complexity,
        }
    parameters = {
        "audio": {
            "name": "speech_orig",
            "url": "https://media.xiph.org/opus/samples/examples/speech_orig.wav",
            "sha256": audio_sha,
            "seconds": AUDIO_SECONDS,
            "frames": AUDIO_FRAMES,
            "channels": 1,
            "sample_rate": 48000,
            "sample_width": 2,
        },
        "cases": [
            {"name": name, "bitrate": bitrate, "complexity": complexity}
            for name, (_subgroup, bitrate, complexity) in CASES.items()
        ],
        "application": "voip",
        "frame_size_ms": 20,
        "iterations": ITERATIONS,
        "warmup_iterations": 1,
        "threads": 1,
        "fixed_point": True,
        "build_system": "autotools",
        "source_mode": "unpatched",
        "timing": "full_encode",
        "affinity": "unbound",
        "opus": "1.6.1",
        "source_archive_sha256": SOURCE_SHA256,
    }
    return {
        "benchmark": "opus_1.6.1_fixed_point",
        "software": "opus",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "results": results,
    }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: parse_benchmark.py RESULT_CSV EVIDENCE_JSON OUTPUT_JSON", file=sys.stderr)
        return 2
    csv_path, evidence_path, output_path = (Path(value) for value in sys.argv[1:])
    evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
    payload = parse(csv_path.read_text(encoding="utf-8", errors="replace"), evidence,
                    os.environ["SOFTWARE_VERSION"], os.environ["EXPECTED_ARCH"])
    output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[opus] normalized {len(payload['results'])} benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(2)
