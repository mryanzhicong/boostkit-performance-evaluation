#!/usr/bin/env python3
"""Run the formal OpenVINO ResNet18 FP32 CPU benchmark.

Matches the reference ``Test/openvino/scripts/bench.py`` + ``worker.py``:
official FP32 ResNet18 exported to ONNX with constant folding disabled, three
first-frame inputs, 3 warm-ups + 20 synchronous inferences per case, one
inference thread, one stream, LATENCY hint, CPU pinning disabled.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import platform
import statistics
import time
from datetime import datetime, timezone
from importlib.metadata import version
from pathlib import Path

os.environ.update(
    OMP_NUM_THREADS="1",
    OMP_THREAD_LIMIT="1",
    OPENBLAS_NUM_THREADS="1",
    MKL_NUM_THREADS="1",
)

import numpy as np  # noqa: E402
import openvino as ov  # noqa: E402

CONFIG = {
    "INFERENCE_NUM_THREADS": 1,
    "NUM_STREAMS": 1,
    "PERFORMANCE_HINT": "LATENCY",
    "INFERENCE_PRECISION_HINT": "f32",
    "ENABLE_CPU_PINNING": False,
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def cpu_model() -> str:
    try:
        for line in Path("/proc/cpuinfo").read_text(encoding="utf-8").splitlines():
            key, separator, value = line.partition(":")
            if separator and key.strip().lower() in {"model name", "cpu model", "hardware"}:
                return value.strip()
    except OSError:
        pass
    return ""


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".part")
    temporary.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--evidence-dir", required=True)
    parser.add_argument("--csv", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--warmup-iterations", type=int, default=3)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    evidence_dir = Path(args.evidence_dir).resolve()
    evidence_dir.mkdir(parents=True, exist_ok=True)
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    model = manifest["model"]
    cases = manifest["cases"]
    if len(cases) != 3 or model.get("name") != "resnet18":
        raise ValueError("manifest is not the fixed three-case ResNet18 workload")
    videos = [
        {
            "name": case["video"],
            "filename": case["source_filename"],
            "sha256": case["source_sha256"],
        }
        for case in cases
    ]
    parameters = {
        "videos": videos,
        "model": {
            "name": "resnet18",
            "weights_url": model["weights_url"],
            "weights_sha256": model["weights_sha256"],
        },
        "precision": "FP32",
        "batch_size": 1,
        "input_size": 224,
        "threads": 1,
        "streams": 1,
        "performance_hint": "LATENCY",
        "inference_precision": "f32",
        "cpu_pinning": False,
        "warmup_iterations": args.warmup_iterations,
        "iterations": args.iterations,
        "timing": "synchronous_inference",
        "affinity": "unbound",
        "torch": "2.9.1",
        "torchvision": "0.24.1",
        "openvino": "2026.2.1",
        "onnx": "1.19.1",
        "numpy": "2.4.6",
        "pillow": "13.0.0",
    }
    evidence = {
        "software": "openvino",
        "version": "2026.2.1",
        "architecture": platform.machine(),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "runtime": {
            "openvino": version("openvino"),
            "openvino_module": ov.__version__,
            "threads": 1,
            "streams": 1,
            "performance_hint": "LATENCY",
            "inference_precision": "f32",
            "cpu_pinning": False,
            "cpu_count": os.cpu_count(),
            "cpu_model": cpu_model(),
            "model_sha256": model["sha256"],
        },
        "parameters": parameters,
        "cases": {},
        "failures": {},
    }
    write_json(evidence_dir / "evidence.json", evidence)

    rows = []
    for case in cases:
        scenario = case["name"]
        try:
            array = np.load(case["input_path"])
            input_sha = hashlib.sha256(array.tobytes()).hexdigest()
            model_path = Path(case["model_path"])
            model_sha = sha256_file(model_path)
            if input_sha != case["input_sha256"]:
                raise ValueError("prepared input checksum differs")
            if model_sha != case["model_sha256"] or model_sha != model["sha256"]:
                raise ValueError("ONNX model checksum differs")
            core = ov.Core()
            compiled = core.compile_model(str(model_path), "CPU", CONFIG)
            request = compiled.create_infer_request()
            with np.errstate(all="ignore"):
                for _ in range(args.warmup_iterations):
                    output = request.infer({0: array})[compiled.output(0)].copy()
                if output.shape != (1, 1000) or not np.isfinite(output).all():
                    raise ValueError("Inference returned an invalid output.")
                samples = []
                for _ in range(args.iterations):
                    started = time.perf_counter_ns()
                    request.infer({0: array})
                    samples.append((time.perf_counter_ns() - started) / 1_000_000.0)
            mean = statistics.mean(samples)
            evidence["cases"][scenario] = {
                "scenario": scenario,
                "video": case["video"],
                "model": "resnet18",
                "input_sha256": input_sha,
                "model_sha256": model_sha,
                "weights_url": model["weights_url"],
                "weights_sha256": model["weights_sha256"],
                "openvino": version("openvino"),
                "threads": 1,
                "streams": 1,
                "performance_hint": "LATENCY",
                "inference_precision": "f32",
                "cpu_pinning": False,
                "affinity": "unbound",
                "iterations": args.iterations,
                "samples_ms": samples,
                "mean_ms_per_image": mean,
                "output": output.tolist(),
                "top5": np.argsort(output[0], kind="stable")[-5:].tolist(),
            }
            rows.append([scenario, str(args.iterations), f"{mean:.6f}", "OK"])
            print(f"{scenario} {mean:.6f} ms/image", flush=True)
        except Exception as error:  # noqa: BLE001 - keep a failure row for diagnosis
            evidence["failures"][scenario] = {
                "error_type": type(error).__name__,
                "error": str(error),
            }
            rows.append([scenario, str(args.iterations), "", "FAIL"])
            print(f"FAIL {scenario}: {type(error).__name__}: {error}", flush=True)
        write_json(evidence_dir / "evidence.json", evidence)

    csv_path = Path(args.csv).resolve()
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["scenario", "iterations", "ms_per_image", "status"])
        writer.writerows(rows)
    print(f"Result: {csv_path}", flush=True)
    print("查看 ms_per_image 列，单位毫秒/张，越小越好。", flush=True)
    if len(evidence["cases"]) != 3 or evidence["failures"]:
        print(f"ERROR: expected 3 successful cases, got {len(evidence['cases'])}; failures={evidence['failures']}", flush=True)
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", flush=True)
        raise SystemExit(2)
