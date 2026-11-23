#!/usr/bin/env python3
"""Validate the uavs3d raw decode evidence and emit Framework metrics."""

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

EXPECTED_FRAMES = 120
EXPECTED_ITERATIONS = 20
EXPECTED_THREADS = (16, 24)
EXPECTED_WIDTH = 1920
EXPECTED_HEIGHT = 1080
EXPECTED_QP = 32
EXPECTED_BIT_DEPTH = 8
EXPECTED_FPS = 25
SHA256 = re.compile(r"^[0-9a-f]{64}$")
HEADER = ["scenario", "frames", "ms_per_frame", "status"]


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
        ("qp", EXPECTED_QP),
        ("bit_depth", EXPECTED_BIT_DEPTH),
        ("fps", EXPECTED_FPS),
    ):
        if manifest.get(key) != expected:
            raise ValueError(f"manifest {key} differs from the fixed workload")
    encoder = manifest.get("encoder")
    if not isinstance(encoder, dict) or encoder.get("version") != "uavs3e-1.3":
        raise ValueError("manifest does not describe the uavs3e 1.3 input encoder")
    settings = encoder.get("settings")
    if settings != {
        "wpp_threads": 4,
        "frm_threads": 2,
        "speed_level": 4,
        "gop": 7,
        "preset": 0,
        "fps_num": 25,
        "fps_den": 1,
    }:
        raise ValueError(f"input encoder settings differ from the fixed workload: {settings!r}")
    for key in ("source_sha256", "stream_sha256"):
        if not isinstance(manifest.get(key), str) or not SHA256.fullmatch(manifest[key]):
            raise ValueError(f"manifest {key} is not a valid SHA-256")
    return {
        "video": manifest.get("source_filename"),
        "video_sha256": manifest["source_sha256"],
        "stream": manifest.get("stream_filename"),
        "codec": "AVS3-P2",
        "bit_depth": EXPECTED_BIT_DEPTH,
        "width": EXPECTED_WIDTH,
        "height": EXPECTED_HEIGHT,
        "frames": EXPECTED_FRAMES,
        "fps": EXPECTED_FPS,
        "qp": EXPECTED_QP,
        "decode_threads": list(EXPECTED_THREADS),
        "iterations": EXPECTED_ITERATIONS,
        "warmup_iterations": 1,
        "timing": "whole_process_wall_clock/120",
        "affinity": "unbound",
        "decoder": "uavs3d-1.2",
        "input_encoder": "uavs3e-1.3",
        "encoder_settings": settings,
    }


def read_csv(text: str) -> dict[str, dict]:
    rows = [row for row in csv.reader(io.StringIO(text)) if any(field.strip() for field in row)]
    if not rows or rows[0] != HEADER:
        raise ValueError(f"result CSV header must be {HEADER}")
    if len(rows) != 1 + len(EXPECTED_THREADS):
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
    if evidence.get("software") != "uavs3d" or evidence.get("version") != version:
        raise ValueError("evidence does not describe the requested uavs3d version")
    if evidence.get("architecture") != architecture:
        raise ValueError("evidence architecture differs from the requested architecture")
    manifest = evidence.get("manifest")
    if not isinstance(manifest, dict):
        raise ValueError("evidence manifest is missing")
    parameters = expected_parameters(manifest)
    if evidence.get("parameters") != parameters:
        raise ValueError("evidence benchmark parameters differ from the fixed workload")
    if manifest.get("name") != "Film2012":
        raise ValueError("evidence manifest does not identify the Film2012 sequence")
    if not SHA256.fullmatch(str(manifest.get("stream_sha256", ""))):
        raise ValueError("evidence stream checksum is invalid")
    decoder = evidence.get("decoder")
    if not isinstance(decoder, dict) or \
            not re.search(r"uavs2d:\s*1\.2(?:[._]|$)", str(decoder.get("version_output", ""))):
        raise ValueError("evidence does not contain the built uavs3d 1.2 version output")
    if not SHA256.fullmatch(str(decoder.get("sha256", ""))):
        raise ValueError("evidence decoder checksum is invalid")
    expected_bytes = EXPECTED_WIDTH * EXPECTED_HEIGHT * 3 // 2 * EXPECTED_FRAMES

    csv_rows = read_csv(csv_text)
    scenarios = evidence.get("scenarios")
    if not isinstance(scenarios, list) or len(scenarios) != len(EXPECTED_THREADS):
        raise ValueError("evidence must contain exactly two decode scenarios")
    results: dict[str, dict] = {}
    seen_threads: set[int] = set()
    for item in scenarios:
        if not isinstance(item, dict):
            raise ValueError("evidence scenario must be an object")
        threads = item.get("threads")
        if threads not in EXPECTED_THREADS or threads in seen_threads:
            raise ValueError(f"unexpected or repeated decode thread count: {threads!r}")
        seen_threads.add(threads)
        scenario = f"{manifest['name']}_{EXPECTED_HEIGHT}p_q{manifest['qp']}_decode_c{threads}"
        if item.get("scenario") != scenario:
            raise ValueError(f"scenario name differs from the fixed definition: {item.get('scenario')!r}")
        if scenario not in csv_rows:
            raise ValueError(f"result CSV is missing scenario: {scenario}")
        if item.get("frames") != EXPECTED_FRAMES or item.get("iterations") != EXPECTED_ITERATIONS:
            raise ValueError(f"scenario {scenario} does not use 120 frames and 20 iterations")
        if item.get("input_sha256") != manifest["stream_sha256"]:
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
            raise ValueError(f"scenario {scenario} warm-up did not decode 120 frames")
        if not isinstance(warmup.get("output_sha256"), str) or \
                not SHA256.fullmatch(warmup["output_sha256"]):
            raise ValueError(f"scenario {scenario} warm-up output checksum is invalid")
        timed_command = item.get("timed_command")
        if not isinstance(timed_command, list):
            raise ValueError(f"scenario {scenario} is missing the timed command")
        if command_option(timed_command, "-t", scenario) != str(threads):
            raise ValueError(f"scenario {scenario} timed command thread count differs")
        if command_option(timed_command, "-o", scenario) != "/dev/null" or \
                command_option(timed_command, "-l", scenario) != "1" or \
                command_option(timed_command, "-s", scenario) != "0":
            raise ValueError(f"scenario {scenario} timed command does not match the fixed protocol")
        if command_option(timed_command, "-i", scenario) != manifest.get("stream_path"):
            raise ValueError(f"scenario {scenario} timed command input differs from the manifest")
        results[scenario] = {
            "source_name": scenario,
            "value": reported,
            "unit": "ms/frame",
            "direction": "lower_is_better",
            "group": f"{threads} threads",
        }
    if seen_threads != set(EXPECTED_THREADS):
        raise ValueError("evidence must contain both 16-thread and 24-thread decode scenarios")
    if set(csv_rows) != set(results):
        raise ValueError("result CSV and evidence scenarios differ")

    runtime_context = dict(evidence.get("runtime_context") or {})
    runtime_context.update({
        "stream_sha256": manifest["stream_sha256"],
        "decoder_sha256": (evidence.get("decoder") or {}).get("sha256"),
        "decoder_version_output": (evidence.get("decoder") or {}).get("version_output"),
        "warmup_seconds": {
            item["scenario"]: item["warmup"]["seconds"] for item in scenarios
        },
    })
    return {
        "benchmark": "uavs3d_decode",
        "software": "uavs3d",
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
    print(f"[uavs3d] normalized {len(payload['results'])} decode metrics", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
