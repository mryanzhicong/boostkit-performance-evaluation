#!/usr/bin/env python3
"""Validate OpenVINO evidence and emit Framework metrics."""

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

SHA256 = re.compile(r"^[0-9a-f]{64}$")
HEADER = ["scenario", "iterations", "ms_per_image", "status"]
EXPECTED_ITERATIONS = 20
EXPECTED_WARMUP = 3

EXPECTED_VIDEOS = {
    "BQTerrace": (
        "BQTerrace_1920x1080_60-dianbo.yuv",
        "5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7",
    ),
    "Film2012": (
        "Film2012_1920x1080_25_8bit_8Mbps.yuv",
        "27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc",
    ),
    "messi": (
        "messi_1920x1080_25_1000.yuv",
        "1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b",
    ),
}
EXPECTED_MODEL = (
    "https://download.pytorch.org/models/resnet18-f37072fd.pth",
    "f37072fd47e89c5e827621c5baffa7500819f7896bbacec160b1a16c560e07ec",
)
EXPECTED_SCENARIOS = {f"{video}_resnet18_fp32_b1_c1": video for video in EXPECTED_VIDEOS}


def number(value: object, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} is not numeric: {value!r}")
    numeric = float(value)
    if not math.isfinite(numeric) or numeric <= 0:
        raise ValueError(f"{label} is not a positive finite number: {value!r}")
    return numeric


def expected_parameters() -> dict:
    return {
        "videos": [
            {"name": name, "filename": EXPECTED_VIDEOS[name][0], "sha256": EXPECTED_VIDEOS[name][1]}
            for name in ("BQTerrace", "Film2012", "messi")
        ],
        "model": {
            "name": "resnet18",
            "weights_url": EXPECTED_MODEL[0],
            "weights_sha256": EXPECTED_MODEL[1],
        },
        "precision": "FP32",
        "batch_size": 1,
        "input_size": 224,
        "threads": 1,
        "streams": 1,
        "performance_hint": "LATENCY",
        "inference_precision": "f32",
        "cpu_pinning": False,
        "warmup_iterations": EXPECTED_WARMUP,
        "iterations": EXPECTED_ITERATIONS,
        "timing": "synchronous_inference",
        "affinity": "unbound",
        "torch": "2.9.1",
        "torchvision": "0.24.1",
        "openvino": "2026.2.1",
        "onnx": "1.19.1",
        "numpy": "2.4.6",
        "pillow": "13.0.0",
    }


def read_csv(text: str) -> dict[str, dict]:
    rows = [row for row in csv.reader(io.StringIO(text)) if any(field.strip() for field in row)]
    if not rows or rows[0] != HEADER:
        raise ValueError(f"result CSV header must be {HEADER}")
    if len(rows) != 1 + len(EXPECTED_SCENARIOS):
        raise ValueError(f"result CSV must contain exactly three scenario rows, found {len(rows) - 1}")
    output: dict[str, dict] = {}
    for row in rows[1:]:
        if len(row) != len(HEADER):
            raise ValueError(f"malformed result CSV row: {row}")
        scenario, iterations, value, status = row
        if scenario in output:
            raise ValueError(f"duplicate result CSV scenario: {scenario}")
        if status != "OK":
            raise ValueError(f"scenario {scenario} did not complete: {status!r}")
        if iterations != str(EXPECTED_ITERATIONS):
            raise ValueError(f"scenario {scenario} iteration count is {iterations}")
        output[scenario] = {"ms_per_image": number(float(value), f"{scenario} ms_per_image")}
    return output


def parse(csv_text: str, evidence: dict, version: str, architecture: str) -> dict:
    if not isinstance(evidence, dict):
        raise ValueError("evidence root must be an object")
    if evidence.get("software") != "openvino" or evidence.get("version") != version:
        raise ValueError("evidence does not describe the requested OpenVINO version")
    if evidence.get("architecture") != architecture:
        raise ValueError("evidence architecture differs from the requested architecture")
    if evidence.get("failures"):
        raise ValueError(f"benchmark recorded failures: {evidence['failures']}")
    parameters = expected_parameters()
    if evidence.get("parameters") != parameters:
        raise ValueError("evidence benchmark parameters differ from the fixed workload")
    runtime = evidence.get("runtime")
    if not isinstance(runtime, dict):
        raise ValueError("evidence runtime is missing")
    if runtime.get("openvino") != "2026.2.1":
        raise ValueError("benchmark did not use OpenVINO 2026.2.1")
    if runtime.get("performance_hint") != "LATENCY" or runtime.get("inference_precision") != "f32":
        raise ValueError("benchmark runtime configuration is not the fixed workload")
    if runtime.get("cpu_pinning") is not False:
        raise ValueError("benchmark enabled CPU pinning")

    csv_rows = read_csv(csv_text)
    cases = evidence.get("cases")
    if not isinstance(cases, dict) or len(cases) != len(EXPECTED_SCENARIOS):
        raise ValueError("evidence must contain exactly three successful cases")
    if set(cases) != set(EXPECTED_SCENARIOS) or set(csv_rows) != set(EXPECTED_SCENARIOS):
        raise ValueError("evidence and CSV scenarios differ from the fixed three scenarios")
    results: dict[str, dict] = {}
    for scenario, video in EXPECTED_SCENARIOS.items():
        item = cases[scenario]
        if not isinstance(item, dict):
            raise ValueError(f"evidence case {scenario} must be an object")
        if item.get("video") != video or item.get("model") != "resnet18":
            raise ValueError(f"evidence case {scenario} has a different video/model identity")
        if item.get("iterations") != EXPECTED_ITERATIONS:
            raise ValueError(f"evidence case {scenario} does not use 20 iterations")
        if item.get("openvino") != "2026.2.1":
            raise ValueError(f"evidence case {scenario} did not use OpenVINO 2026.2.1")
        if item.get("threads") != 1 or item.get("streams") != 1:
            raise ValueError(f"evidence case {scenario} has different thread/stream settings")
        if item.get("performance_hint") != "LATENCY" or item.get("inference_precision") != "f32":
            raise ValueError(f"evidence case {scenario} has different OpenVINO hints")
        if item.get("cpu_pinning") is not False or item.get("affinity") != "unbound":
            raise ValueError(f"evidence case {scenario} is pinned or affinity-bound")
        if item.get("weights_url") != EXPECTED_MODEL[0] or item.get("weights_sha256") != EXPECTED_MODEL[1]:
            raise ValueError(f"evidence case {scenario} used different ResNet18 weights")
        for field in ("input_sha256", "model_sha256"):
            if not isinstance(item.get(field), str) or not SHA256.fullmatch(item[field]):
                raise ValueError(f"evidence case {scenario} {field} is invalid")
        samples = item.get("samples_ms")
        if not isinstance(samples, list) or len(samples) != EXPECTED_ITERATIONS:
            raise ValueError(f"evidence case {scenario} must record exactly 20 samples")
        values = [number(value, f"{scenario} sample") for value in samples]
        mean = sum(values) / len(values)
        recorded_mean = number(item.get("mean_ms_per_image"), f"{scenario} mean")
        if abs(recorded_mean - mean) > max(1e-9, abs(mean) * 1e-9):
            raise ValueError(f"evidence case {scenario} recorded mean differs from its samples")
        reported = csv_rows[scenario]["ms_per_image"]
        if abs(reported - mean) > max(6e-7, abs(mean) * 1e-9):
            raise ValueError(f"evidence case {scenario} CSV value differs from its samples")
        output = item.get("output")
        if not isinstance(output, list) or len(output) != 1 or not isinstance(output[0], list) or len(output[0]) != 1000:
            raise ValueError(f"evidence case {scenario} output shape is not (1, 1000)")
        if not all(isinstance(value, (int, float)) and math.isfinite(float(value)) for value in output[0]):
            raise ValueError(f"evidence case {scenario} output contains non-finite values")
        if not isinstance(item.get("top5"), list) or len(item["top5"]) != 5:
            raise ValueError(f"evidence case {scenario} top5 is invalid")
        results[scenario] = {
            "source_name": scenario,
            "value": reported,
            "unit": "ms/image",
            "direction": "lower_is_better",
            "group": "resnet18",
            "subgroup": video,
        }

    return {
        "benchmark": "openvino_resnet18_fp32",
        "software": "openvino",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "runtime_context": dict(runtime),
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
    print(f"[openvino] normalized {len(payload['results'])} benchmark metrics", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
