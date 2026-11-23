#!/usr/bin/env python3
"""Run the formal TorchVision official-INT8 CPU benchmark.

The model construction, image preparation, downloads and output checks follow
the reference ``Test/torchvision/scripts/bench.py``.  Only the forward pass is
timed: 3 warm-ups and 20 measured iterations per model/video, one thread.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import platform
import shutil
import statistics
import time
import warnings
from datetime import datetime, timezone
from pathlib import Path

os.environ.update(
    OMP_NUM_THREADS="1",
    OMP_THREAD_LIMIT="1",
    MKL_NUM_THREADS="1",
    OPENBLAS_NUM_THREADS="1",
)

import numpy as np  # noqa: E402
import PIL  # noqa: E402
import torch  # noqa: E402
import torchvision  # noqa: E402
from PIL import Image  # noqa: E402

warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", message="must run observer before calling calculate_qparams.*")
torch.set_num_threads(1)
torch.set_num_interop_threads(1)
torch.backends.quantized.engine = "qnnpack"

VIDEOS = (
    {"name": "BQTerrace", "filename": "BQTerrace_1920x1080_60-dianbo.yuv"},
    {"name": "Film2012", "filename": "Film2012_1920x1080_25_8bit_8Mbps.yuv"},
    {"name": "messi", "filename": "messi_1920x1080_25_1000.yuv"},
)


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


def prepare_rgb(source: Path) -> bytes:
    size = 1920 * 1080 * 3 // 2
    if source.stat().st_size < size:
        raise ValueError("Input video is too short: " + str(source))
    with source.open("rb") as stream:
        raw = stream.read(size)
    data = np.frombuffer(raw, np.uint8)
    y = data[: 1920 * 1080].reshape(1080, 1920).astype(np.int32)
    u = data[1920 * 1080 : 1920 * 1080 * 5 // 4].reshape(540, 960).repeat(2, 0).repeat(2, 1).astype(np.int32) - 128
    v = data[1920 * 1080 * 5 // 4 :].reshape(540, 960).repeat(2, 0).repeat(2, 1).astype(np.int32) - 128
    c = np.maximum(y - 16, 0)
    image = np.clip(
        np.stack(
            (
                298 * c + 409 * v + 128 >> 8,
                298 * c - 100 * u - 208 * v + 128 >> 8,
                298 * c + 516 * u + 128 >> 8,
            ),
            axis=2,
        ),
        0,
        255,
    ).astype(np.uint8)
    return image.tobytes()


def stage_weight(weights, weight_dir: Path) -> None:
    filename = weights.url.rsplit("/", 1)[1]
    local = weight_dir / filename
    target = Path(torch.hub.get_dir()) / "checkpoints" / filename
    if local.is_file() and not target.is_file():
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(local, target)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--video-dir", required=True)
    parser.add_argument("--weight-dir", required=True)
    parser.add_argument("--evidence-dir", required=True)
    parser.add_argument("--csv", required=True)
    parser.add_argument("--work-dir", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--warmup-iterations", type=int, default=3)
    parser.add_argument("--threads", type=int, default=1)
    parser.add_argument("--batch-size", type=int, default=1)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    video_dir = Path(args.video_dir).resolve()
    weight_dir = Path(args.weight_dir).resolve()
    evidence_dir = Path(args.evidence_dir).resolve()
    work_dir = Path(args.work_dir).resolve()
    evidence_dir.mkdir(parents=True, exist_ok=True)
    work_dir.mkdir(parents=True, exist_ok=True)
    if args.threads != 1 or args.batch_size != 1:
        raise ValueError("the fixed workload requires one compute thread and batch size 1")

    videos = []
    for record in VIDEOS:
        source = video_dir / record["filename"]
        if not source.is_file():
            raise ValueError(f"input video is missing: {source}")
        videos.append({**record, "source": source, "sha256": sha256_file(source)})
    images = {
        video["name"]: Image.frombytes("RGB", (1920, 1080), prepare_rgb(video["source"]))
        for video in videos
    }

    models = [
        (
            "mobilenet_v2",
            torchvision.models.quantization.mobilenet_v2,
            torchvision.models.quantization.MobileNet_V2_QuantizedWeights.DEFAULT,
        ),
        (
            "mobilenet_v3_large",
            torchvision.models.quantization.mobilenet_v3_large,
            torchvision.models.quantization.MobileNet_V3_Large_QuantizedWeights.DEFAULT,
        ),
    ]
    model_info = []
    for name, builder, weights in models:
        stage_weight(weights, weight_dir)
        model_info.append({
            "name": name,
            "builder": builder,
            "weights": weights,
            "weights_url": weights.url,
        })

    parameters = {
        "videos": [
            {"name": video["name"], "filename": video["filename"], "sha256": video["sha256"]}
            for video in videos
        ],
        "models": [
            {"name": item["name"], "weights_url": item["weights_url"]}
            for item in model_info
        ],
        "precision": "official quantized INT8",
        "quantized_engine": "qnnpack",
        "batch_size": 1,
        "input_size": 224,
        "compute_threads": 1,
        "interop_threads": 1,
        "warmup_iterations": args.warmup_iterations,
        "iterations": args.iterations,
        "timing": "model_forward_only",
        "affinity": "unbound",
        "torch": "2.9.1",
        "torchvision": "0.24.1",
        "numpy": "2.4.6",
        "pillow": "13.0.0",
    }
    evidence = {
        "software": "torchvision",
        "version": "0.24.1",
        "architecture": platform.machine(),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "runtime": {
            "torch": torch.__version__,
            "torchvision": torchvision.__version__,
            "numpy": np.__version__,
            "pillow": PIL.__version__,
            "quantized_engine": torch.backends.quantized.engine,
            "threads": torch.get_num_threads(),
            "interop_threads": torch.get_num_interop_threads(),
            "torch_home": os.environ.get("TORCH_HOME", ""),
            "cpu_count": os.cpu_count(),
            "cpu_model": cpu_model(),
        },
        "parameters": parameters,
        "cases": {},
        "failures": {},
    }
    write_json(evidence_dir / "evidence.json", evidence)

    rows = []
    for item in model_info:
        model = item["builder"](weights=item["weights"], quantize=True).eval()
        weightfile = Path(torch.hub.get_dir()) / "checkpoints" / item["weights_url"].rsplit("/", 1)[1]
        weight_sha = sha256_file(weightfile)
        quantized_ops = sum(
            isinstance(module, (torch.ao.nn.quantized.Conv2d, torch.ao.nn.quantized.Linear))
            for module in model.modules()
        )
        for video in videos:
            scenario = f"{video['name']}_{item['name']}_official_int8_b1_c1"
            try:
                x = item["weights"].transforms()(images[video["name"]]).unsqueeze(0).contiguous()
                with torch.inference_mode():
                    for _ in range(args.warmup_iterations):
                        result = model(x)
                    reference = result.numpy().copy()
                    assert reference.shape == (1, 1000) and np.isfinite(reference).all()
                    samples = []
                    for _ in range(args.iterations):
                        started = time.perf_counter_ns()
                        result = model(x)
                        samples.append((time.perf_counter_ns() - started) / 1_000_000.0)
                mean = statistics.mean(samples)
                evidence["cases"][scenario] = {
                    "scenario": scenario,
                    "video": video["name"],
                    "model": item["name"],
                    "input_sha256": hashlib.sha256(x.numpy().tobytes()).hexdigest(),
                    "weights_url": item["weights_url"],
                    "weights_sha256": weight_sha,
                    "quantized_engine": torch.backends.quantized.engine,
                    "quantized_conv_linear_modules": quantized_ops,
                    "iterations": args.iterations,
                    "samples_ms": samples,
                    "mean_ms_per_image": mean,
                    "output": reference.tolist(),
                    "top5": np.argsort(reference[0], kind="stable")[-5:].tolist(),
                }
                rows.append([scenario, str(args.iterations), f"{mean:.6f}", "OK"])
                print(f"{scenario} {mean:.6f} ms/image", flush=True)
            except Exception as error:  # noqa: BLE001 - keep the reference's failure row
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
    if len(evidence["cases"]) != 6 or evidence["failures"]:
        print(f"ERROR: expected 6 successful cases, got {len(evidence['cases'])}; failures={evidence['failures']}", flush=True)
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", flush=True)
        raise SystemExit(2)
