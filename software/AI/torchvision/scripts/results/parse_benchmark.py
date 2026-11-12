#!/usr/bin/env python3
"""Validate TorchVision official-INT8 evidence and emit Framework metrics."""

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
EXPECTED_MODELS = {
    "mobilenet_v2": (
        "https://download.pytorch.org/models/quantized/mobilenet_v2_qnnpack_37f702c5.pth",
        "a9225f174880dcd1a662adaa01ea71b06b6a78822d3a4a5a4bd2d4ee5709a8da",
    ),
    "mobilenet_v3_large": (
        "https://download.pytorch.org/models/quantized/mobilenet_v3_large_qnnpack-5bcacf28.pth",
        "5bcacf2876b29c80e6ef777b76ae2a9cbde265af9b51e287c9b7f04a38cb53b1",
    ),
}
EXPECTED_SCENARIOS = {
    f"{video}_{model}_official_int8_b1_c1": (video, model)
    for video in EXPECTED_VIDEOS
    for model in EXPECTED_MODELS
}


def number(value: object, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} is not numeric: {value!r}")
    numeric = float(value)
    if not math.isfinite(numeric) or numeric <= 0:
        raise ValueError(f"{label} is not a positive finite number: {value!r}")
    return numeric


def expected_parameters(evidence: dict) -> dict:
    return {
        "videos": [
            {"name": name, "filename": EXPECTED_VIDEOS[name][0], "sha256": EXPECTED_VIDEOS[name][1]}
            for name in ("BQTerrace", "Film2012", "messi")
        ],
        "models": [
            {"name": name, "weights_url": EXPECTED_MODELS[name][0]}
            for name in ("mobilenet_v2", "mobilenet_v3_large")
        ],
        "precision": "official quantized INT8",
        "quantized_engine": "qnnpack",
        "batch_size": 1,
        "input_size": 224,
        "compute_threads": 1,
        "interop_threads": 1,
        "warmup_iterations": EXPECTED_WARMUP,
        "iterations": EXPECTED_ITERATIONS,
        "timing": "model_forward_only",
        "affinity": "unbound",
        "torch": "2.9.1",
        "torchvision": "0.24.1",
        "numpy": "2.4.6",
        "pillow": "13.0.0",
    }


def read_csv(text: str) -> dict[str, dict]:
    rows = [row for row in csv.reader(io.StringIO(text)) if any(field.strip() for field in row)]
    if not rows or rows[0] != HEADER:
        raise ValueError(f"result CSV header must be {HEADER}")
    if len(rows) != 1 + len(EXPECTED_SCENARIOS):
        raise ValueError(f"result CSV must contain exactly six scenario rows, found {len(rows) - 1}")
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
    if evidence.get("software") != "torchvision" or evidence.get("version") != version:
        raise ValueError("evidence does not describe the requested torchvision version")
    if evidence.get("architecture") != architecture:
        raise ValueError("evidence architecture differs from the requested architecture")
    if evidence.get("failures"):
        raise ValueError(f"benchmark recorded failures: {evidence['failures']}")
    parameters = expected_parameters(evidence)
    if evidence.get("parameters") != parameters:
        raise ValueError("evidence benchmark parameters differ from the fixed workload")
    runtime = evidence.get("runtime")
    if not isinstance(runtime, dict):
        raise ValueError("evidence runtime is missing")
    if runtime.get("quantized_engine") != "qnnpack":
        raise ValueError("benchmark did not use the QNNPACK quantized engine")
    if str(runtime.get("torch", "")).split("+")[0] != "2.9.1":
        raise ValueError("benchmark did not use PyTorch 2.9.1")
    if str(runtime.get("torchvision", "")).split("+")[0] != "0.24.1":
        raise ValueError("benchmark did not use torchvision 0.24.1")

    csv_rows = read_csv(csv_text)
    cases = evidence.get("cases")
    if not isinstance(cases, dict) or len(cases) != len(EXPECTED_SCENARIOS):
        raise ValueError("evidence must contain exactly six successful cases")
    if set(cases) != set(EXPECTED_SCENARIOS) or set(csv_rows) != set(EXPECTED_SCENARIOS):
        raise ValueError("evidence and CSV scenarios differ from the fixed six scenarios")
    results: dict[str, dict] = {}
    for scenario, (video, model) in EXPECTED_SCENARIOS.items():
        item = cases[scenario]
        if not isinstance(item, dict):
            raise ValueError(f"evidence case {scenario} must be an object")
        if item.get("video") != video or item.get("model") != model:
            raise ValueError(f"evidence case {scenario} has a different video/model identity")
        if item.get("iterations") != EXPECTED_ITERATIONS:
            raise ValueError(f"evidence case {scenario} does not use 20 iterations")
        if item.get("quantized_engine") != "qnnpack":
            raise ValueError(f"evidence case {scenario} did not use QNNPACK")
        if not isinstance(item.get("quantized_conv_linear_modules"), int) or item["quantized_conv_linear_modules"] <= 0:
            raise ValueError(f"evidence case {scenario} has no quantized Conv2d/Linear modules")
        expected_url, expected_weight_sha = EXPECTED_MODELS[model]
        if item.get("weights_url") != expected_url or item.get("weights_sha256") != expected_weight_sha:
            raise ValueError(f"evidence case {scenario} used different official weights")
        if not isinstance(item.get("input_sha256"), str) or not SHA256.fullmatch(item["input_sha256"]):
            raise ValueError(f"evidence case {scenario} input checksum is invalid")
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
            "group": model,
            "subgroup": video,
        }

    runtime_context = dict(runtime)
    return {
        "benchmark": "torchvision_official_int8",
        "software": "torchvision",
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
    print(f"[torchvision] normalized {len(payload['results'])} benchmark metrics", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
