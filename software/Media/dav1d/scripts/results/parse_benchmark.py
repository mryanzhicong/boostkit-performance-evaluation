#!/usr/bin/env python3
"""Validate dav1d raw decode evidence and emit Framework metrics."""

from __future__ import annotations

import csv
import io
import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

EXPECTED_FRAMES = 30
EXPECTED_ITERATIONS = 20
EXPECTED_THREADS = 16
EXPECTED_WIDTH = 1920
EXPECTED_HEIGHT = 1080
EXPECTED_BIT_DEPTH = 8
EXPECTED_CQ_LEVEL = 32
SHA256 = re.compile(r"^[0-9a-f]{64}$")
HEADER = ["scenario", "frames", "ms_per_frame", "status"]
EXPECTED_SCENARIOS = {
    "BQTerrace": "BQTerrace_1080p_decode_c16",
    "messi": "messi_1080p_decode_c16",
}
EXPECTED_ENCODER_SETTINGS = {
    "codec": "av1",
    "good": True,
    "cpu_used": 8,
    "passes": 1,
    "threads": 1,
    "row_mt": 0,
    "tile_columns": 1,
    "end_usage": "q",
    "cq_level": EXPECTED_CQ_LEVEL,
    "limit": EXPECTED_FRAMES,
    "input_bit_depth": EXPECTED_BIT_DEPTH,
    "bit_depth": EXPECTED_BIT_DEPTH,
}


def number(value: object, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} is not numeric: {value!r}")
    numeric = float(value)
    if not math.isfinite(numeric) or numeric <= 0:
        raise ValueError(f"{label} is not a positive finite number: {value!r}")
    return numeric


def expected_parameters(manifest: dict) -> dict:
    for key, expected in (
        ("width", EXPECTED_WIDTH),
        ("height", EXPECTED_HEIGHT),
        ("frames", EXPECTED_FRAMES),
        ("bit_depth", EXPECTED_BIT_DEPTH),
        ("cq_level", EXPECTED_CQ_LEVEL),
    ):
        if manifest.get(key) != expected:
            raise ValueError(f"manifest {key} differs from the fixed workload")
    encoder = manifest.get("encoder")
    if not isinstance(encoder, dict) or encoder.get("version") != "aom-3.2.0":
        raise ValueError("manifest does not describe the AOM 3.2.0 input encoder")
    if encoder.get("settings") != EXPECTED_ENCODER_SETTINGS:
        raise ValueError("input encoder settings differ from the fixed workload")
    videos = manifest.get("videos")
    if not isinstance(videos, list) or len(videos) != 2:
        raise ValueError("manifest must contain exactly two videos")
    names = [video.get("name") for video in videos if isinstance(video, dict)]
    if sorted(names) != ["BQTerrace", "messi"]:
        raise ValueError(f"manifest video set differs: {names!r}")
    video_parameters = []
    for video in videos:
        for key in ("source_sha256", "stream_sha256"):
            if not isinstance(video.get(key), str) or not SHA256.fullmatch(video[key]):
                raise ValueError(f"manifest {key} is not a valid SHA-256")
        video_parameters.append({
            "filename": video.get("source_filename"),
            "sha256": video["source_sha256"],
            "fps": video.get("fps"),
        })
    return {
        "videos": video_parameters,
        "codec": "AV1",
        "bit_depth": EXPECTED_BIT_DEPTH,
        "width": EXPECTED_WIDTH,
        "height": EXPECTED_HEIGHT,
        "frames": EXPECTED_FRAMES,
        "cq_level": EXPECTED_CQ_LEVEL,
        "decode_threads": EXPECTED_THREADS,
        "iterations": EXPECTED_ITERATIONS,
        "warmup_iterations": 1,
        "timing": "whole_process_wall_clock/30",
        "affinity": "unbound",
        "decoder": "dav1d-1.5.4",
        "input_encoder": "aom-3.2.0",
        "encoder_settings": EXPECTED_ENCODER_SETTINGS,
    }


def read_csv(text: str) -> dict[str, dict]:
    rows = [row for row in csv.reader(io.StringIO(text)) if any(field.strip() for field in row)]
    if not rows or rows[0] != HEADER:
        raise ValueError(f"result CSV header must be {HEADER}")
    if len(rows) != 1 + len(EXPECTED_SCENARIOS):
        raise ValueError(f"result CSV must contain exactly two scenario rows, found {len(rows) - 1}")
    output: dict[str, dict] = {}
    for row in rows[1:]:
        if len(row) != len(HEADER):
            raise ValueError(f"malformed result CSV row: {row}")
        scenario, frames, value, status = row
        if scenario in output:
            raise ValueError(f"duplicate result CSV scenario: {scenario}")
        if status != "OK":
            raise ValueError(f"scenario {scenario} did not complete: {status!r}")
        if frames != str(EXPECTED_FRAMES):
            raise ValueError(f"scenario {scenario} frame count is {frames}")
        output[scenario] = {"ms_per_frame": number(float(value), f"{scenario} ms_per_frame")}
    return output


def command_option(command: list, name: str, scenario: str) -> str:
    try:
        return str(command[command.index(name) + 1])
    except (ValueError, IndexError):
        raise ValueError(f"scenario {scenario} timed command lacks {name}") from None


def parse(csv_text: str, evidence: dict, version: str, architecture: str) -> dict:
    if not isinstance(evidence, dict):
        raise ValueError("evidence root must be an object")
    if evidence.get("software") != "dav1d" or evidence.get("version") != version:
        raise ValueError("evidence does not describe the requested dav1d version")
    if evidence.get("architecture") != architecture:
        raise ValueError("evidence architecture differs from the requested architecture")
    manifest = evidence.get("manifest")
    if not isinstance(manifest, dict):
        raise ValueError("evidence manifest is missing")
    parameters = expected_parameters(manifest)
    if evidence.get("parameters") != parameters:
        raise ValueError("evidence benchmark parameters differ from the fixed workload")
    decoder = evidence.get("decoder")
    if not isinstance(decoder, dict) or "1.5.4" not in str(decoder.get("version_output", "")):
        raise ValueError("evidence does not contain the built dav1d 1.5.4 version output")
    if not SHA256.fullmatch(str(decoder.get("sha256", ""))):
        raise ValueError("evidence decoder checksum is invalid")
    expected_bytes = EXPECTED_WIDTH * EXPECTED_HEIGHT * 3 // 2 * EXPECTED_FRAMES
    csv_rows = read_csv(csv_text)
    scenarios = evidence.get("scenarios")
    if not isinstance(scenarios, list) or len(scenarios) != len(EXPECTED_SCENARIOS):
        raise ValueError("evidence must contain exactly two decode scenarios")
    video_by_name = {video["name"]: video for video in manifest["videos"]}
    results: dict[str, dict] = {}
    seen: set[str] = set()
    for item in scenarios:
        if not isinstance(item, dict):
            raise ValueError("evidence scenario must be an object")
        video_name = item.get("video")
        if video_name not in EXPECTED_SCENARIOS:
            raise ValueError(f"unexpected video name: {video_name!r}")
        if video_name in seen:
            raise ValueError(f"repeated decode scenario: {video_name}")
        seen.add(video_name)
        scenario = EXPECTED_SCENARIOS[video_name]
        if item.get("scenario") != scenario:
            raise ValueError(f"scenario name differs from the fixed definition: {item.get('scenario')!r}")
        if scenario not in csv_rows:
            raise ValueError(f"result CSV is missing scenario: {scenario}")
        if item.get("frames") != EXPECTED_FRAMES or item.get("iterations") != EXPECTED_ITERATIONS:
            raise ValueError(f"scenario {scenario} does not use 30 frames and 20 iterations")
        if item.get("threads") != EXPECTED_THREADS:
            raise ValueError(f"scenario {scenario} does not use 16 decoder threads")
        video = video_by_name.get(video_name)
        if video is None or item.get("input_sha256") != video["stream_sha256"]:
            raise ValueError(f"scenario {scenario} used a different input stream")
        samples = item.get("samples_ms_per_frame")
        if not isinstance(samples, list) or len(samples) != EXPECTED_ITERATIONS:
            raise ValueError(f"scenario {scenario} must record exactly 20 timing samples")
        values = [number(value, f"{scenario} sample") for value in samples]
        mean = sum(values) / len(values)
        recorded_mean = number(item.get("mean_ms_per_frame"), f"{scenario} mean")
        if abs(recorded_mean - mean) > max(1e-9, abs(mean) * 1e-9):
            raise ValueError(f"scenario {scenario} recorded mean differs from its samples")
        reported = csv_rows[scenario]["ms_per_frame"]
        if abs(reported - mean) > max(6e-7, abs(mean) * 1e-9):
            raise ValueError(f"scenario {scenario} CSV value differs from its samples")
        warmup = item.get("warmup")
        if not isinstance(warmup, dict):
            raise ValueError(f"scenario {scenario} is missing warm-up evidence")
        if warmup.get("output_bytes") != expected_bytes:
            raise ValueError(f"scenario {scenario} warm-up did not decode 30 frames")
        if not isinstance(warmup.get("output_sha256"), str) or not SHA256.fullmatch(warmup["output_sha256"]):
            raise ValueError(f"scenario {scenario} warm-up output checksum is invalid")
        timed_command = item.get("timed_command")
        if not isinstance(timed_command, list):
            raise ValueError(f"scenario {scenario} is missing the timed command")
        if command_option(timed_command, "--threads", scenario) != str(EXPECTED_THREADS):
            raise ValueError(f"scenario {scenario} timed command thread count differs")
        if command_option(timed_command, "--muxer", scenario) != "null" or \
                not timed_command or timed_command[-1] != "/dev/null":
            raise ValueError(f"scenario {scenario} timed command does not write to the null muxer")
        if command_option(timed_command, "--framedelay", scenario) != "0" or \
                command_option(timed_command, "--filmgrain", scenario) != "1":
            raise ValueError(f"scenario {scenario} timed command differs from the fixed protocol")
        if command_option(timed_command, "--input", scenario) != video.get("stream_path"):
            raise ValueError(f"scenario {scenario} timed command input differs from the manifest")
        results[scenario] = {
            "source_name": scenario,
            "value": reported,
            "unit": "ms/frame",
            "direction": "lower_is_better",
            "group": video_name,
        }
    if seen != set(EXPECTED_SCENARIOS):
        raise ValueError("evidence must contain both BQTerrace and messi scenarios")
    if set(csv_rows) != set(results):
        raise ValueError("result CSV and evidence scenarios differ")
    runtime_context = dict(evidence.get("runtime_context") or {})
    runtime_context.update({
        "stream_sha256": {video["name"]: video["stream_sha256"] for video in manifest["videos"]},
        "decoder_sha256": decoder.get("sha256"),
        "decoder_version_output": decoder.get("version_output"),
        "warmup_seconds": {item["scenario"]: item["warmup"]["seconds"] for item in scenarios},
    })
    return {
        "benchmark": "dav1d_decode",
        "software": "dav1d",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "runtime_context": runtime_context,
        "results": results,
    }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: parse_benchmark.py RESULT_CSV EVIDENCE_JSON OUTPUT_JSON", file=sys.stderr)
        return 2
    csv_path, evidence_path, output_path = (Path(value) for value in sys.argv[1:])
    version = os.environ["SOFTWARE_VERSION"]
    architecture = os.environ["EXPECTED_ARCH"]
    evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
    payload = parse(csv_path.read_text(encoding="utf-8", errors="replace"), evidence,
                    version, architecture)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"[dav1d] normalized {len(payload['results'])} decode metrics", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
