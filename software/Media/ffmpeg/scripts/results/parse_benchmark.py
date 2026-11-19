#!/usr/bin/env python3
"""Validate FFmpeg evidence and emit Framework metrics."""

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
HEADER = ["scenario", "frames", "ms_per_frame", "status"]
FRAMES = 30
ITERATIONS = 20
VIDEOS = {
    "BQTerrace": ("BQTerrace_1920x1080_60-dianbo.yuv", "5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7"),
    "Film2012": ("Film2012_1920x1080_25_8bit_8Mbps.yuv", "27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc"),
    "messi": ("messi_1920x1080_25_1000.yuv", "1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b"),
}
SCENARIOS = {f"{video}_640x360_rgb24": video for video in VIDEOS}


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
        scenario, frames, value, status = row
        if scenario in values:
            raise ValueError(f"duplicate scenario: {scenario}")
        if status != "OK":
            raise ValueError(f"scenario {scenario} did not complete: {status}")
        if frames != str(FRAMES):
            raise ValueError(f"scenario {scenario} frame count is {frames}")
        values[scenario] = number(float(value), f"{scenario} ms_per_frame")
    return values


def parse(csv_text: str, evidence: dict, version: str, architecture: str) -> dict:
    if evidence.get("software") != "ffmpeg" or evidence.get("version") != version:
        raise ValueError("evidence does not describe the requested FFmpeg version")
    parameters = {
        "videos": [
            {"name": name, "filename": VIDEOS[name][0], "sha256": VIDEOS[name][1]}
            for name in ("BQTerrace", "Film2012", "messi")
        ],
        "width": 640,
        "height": 360,
        "pixel_format": "rgb24",
        "scale_flags": "bilinear+accurate_rnd+bitexact",
        "frames": FRAMES,
        "warmup_iterations": 1,
        "iterations": ITERATIONS,
        "threads": 1,
        "filter_threads": 1,
        "timing": "full_command",
        "affinity": "unbound",
        "source_mode": "unpatched",
        "ffmpeg": "7.1.1",
        "configure": "--disable-everything --enable-ffmpeg --enable-ffprobe --enable-filter=scale,format,null,psnr,setpts --enable-swscale",
        "source_archive_sha256": "9a6e57a446b671012612aaeb9df5126794d5ac8f2015ca220934f99a6a4e0601",
    }
    if evidence.get("source_mode") != "unpatched":
        raise ValueError("evidence does not describe the unpatched source")
    if evidence.get("failures"):
        raise ValueError(f"benchmark recorded failures: {evidence['failures']}")
    cases = evidence.get("cases")
    if not isinstance(cases, dict) or set(cases) != set(SCENARIOS):
        raise ValueError("evidence must contain exactly the three fixed cases")
    csv_values = read_csv(csv_text)
    if set(csv_values) != set(SCENARIOS):
        raise ValueError("CSV and evidence scenarios differ")
    results = {}
    for scenario, video in SCENARIOS.items():
        item = cases[scenario]
        if not isinstance(item, dict) or item.get("video") != video:
            raise ValueError(f"evidence case {scenario} has a different video")
        if item.get("frames") != FRAMES:
            raise ValueError(f"evidence case {scenario} has a different frame count")
        if item.get("expected_output_bytes") != 640 * 360 * FRAMES * 3:
            raise ValueError(f"evidence case {scenario} has an unexpected output size")
        if not isinstance(item.get("input_sha256"), str) or not SHA256.fullmatch(item["input_sha256"]):
            raise ValueError(f"evidence case {scenario} input SHA is invalid")
        if not isinstance(item.get("output_sha256"), str) or not SHA256.fullmatch(item["output_sha256"]):
            raise ValueError(f"evidence case {scenario} output SHA is invalid")
        command = item.get("command")
        if not isinstance(command, list) or "-threads" not in command or "-filter_threads" not in command:
            raise ValueError(f"evidence case {scenario} command is incomplete")
        samples = item.get("samples_ms_per_frame")
        if not isinstance(samples, list) or len(samples) != ITERATIONS:
            raise ValueError(f"evidence case {scenario} must record exactly 20 samples")
        sample_values = [number(value, f"{scenario} sample") for value in samples]
        mean_median = statistics.median(sample_values)
        csv_value = csv_values[scenario]
        if abs(csv_value - mean_median) > max(1e-6, abs(mean_median) * 1e-9):
            raise ValueError(f"evidence case {scenario} CSV value is not the median")
        results[scenario] = {
            "source_name": scenario,
            "value": csv_value,
            "unit": "ms/frame",
            "direction": "lower_is_better",
            "group": "ffmpeg",
            "subgroup": video,
        }
    return {
        "benchmark": "ffmpeg_7.1.1_scale",
        "software": "ffmpeg",
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
    evidence["software"] = "ffmpeg"
    evidence["version"] = os.environ["SOFTWARE_VERSION"]
    payload = parse(csv_path.read_text(encoding="utf-8", errors="replace"), evidence,
                    os.environ["SOFTWARE_VERSION"], os.environ["EXPECTED_ARCH"])
    output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[ffmpeg] normalized {len(payload['results'])} benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(2)
