#!/usr/bin/env python3
"""Export the ResNet18 ONNX model and prepare the three benchmark inputs.

The export/check/preprocess steps mirror ``Test/openvino/scripts/prepare.py``:
official torchvision FP32 ResNet18 weights, ONNX opset 17, constant folding
disabled, and the official ``weights.transforms()`` preprocessing.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import warnings
from pathlib import Path

os.environ.update(
    OMP_NUM_THREADS="1",
    OMP_THREAD_LIMIT="1",
    OPENBLAS_NUM_THREADS="1",
    MKL_NUM_THREADS="1",
)

import numpy as np  # noqa: E402
import onnx  # noqa: E402
import torch  # noqa: E402
import torchvision  # noqa: E402
from PIL import Image  # noqa: E402

warnings.filterwarnings("ignore", category=DeprecationWarning)
torch.set_num_threads(1)
torch.set_num_interop_threads(1)

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


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--video-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--verify-only", action="store_true")
    return parser


def verify_manifest(manifest: dict, args: argparse.Namespace) -> None:
    cases = manifest.get("cases")
    model = manifest.get("model")
    if not isinstance(cases, list) or len(cases) != 3:
        raise ValueError("manifest must contain exactly three cases")
    if not isinstance(model, dict) or model.get("name") != "resnet18":
        raise ValueError("manifest does not describe ResNet18")
    model_path = Path(model.get("path", ""))
    if not model_path.is_file() or model.get("sha256") != sha256_file(model_path):
        raise ValueError("ONNX model is missing or differs from the manifest")
    if not model.get("weights_sha256") or not model.get("weights_url"):
        raise ValueError("manifest is missing the ResNet18 weight identity")
    by_video = {case.get("video"): case for case in cases if isinstance(case, dict)}
    if set(by_video) != {video["name"] for video in VIDEOS}:
        raise ValueError("manifest video set differs from the fixed workload")
    for video in VIDEOS:
        case = by_video[video["name"]]
        source = Path(args.video_dir) / video["filename"]
        input_path = Path(case.get("input_path", ""))
        if not source.is_file() or source.stat().st_size < 1920 * 1080 * 3 // 2:
            raise ValueError(f"input video is missing or too short: {source}")
        if not input_path.is_file():
            raise ValueError(f"prepared input is missing: {input_path}")
        if case.get("input_sha256") != sha256_file(input_path):
            raise ValueError(f"prepared input checksum differs for {video['name']}")
        if case.get("model_sha256") != model["sha256"]:
            raise ValueError(f"case model checksum differs for {video['name']}")
    print("Inputs and ONNX model verified", flush=True)


def main() -> int:
    args = build_parser().parse_args()
    video_dir = Path(args.video_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    manifest_path = Path(args.manifest).resolve()
    if args.verify_only:
        if not manifest_path.is_file():
            raise ValueError(f"manifest is missing: {manifest_path}")
        verify_manifest(json.loads(manifest_path.read_text(encoding="utf-8")), args)
        return 0

    output_dir.mkdir(parents=True, exist_ok=True)
    images = {}
    source_hashes = {}
    for video in VIDEOS:
        source = video_dir / video["filename"]
        if not source.is_file():
            raise ValueError(f"input video is missing: {source}")
        source_hashes[video["name"]] = sha256_file(source)
        images[video["name"]] = Image.frombytes("RGB", (1920, 1080), prepare_rgb(source))

    weights = torchvision.models.ResNet18_Weights.DEFAULT
    model = torchvision.models.resnet18(weights=weights).eval()
    model_path = output_dir / "resnet18.onnx"
    with torch.inference_mode():
        torch.onnx.export(
            model,
            torch.zeros(1, 3, 224, 224),
            str(model_path),
            opset_version=17,
            input_names=["image"],
            output_names=["logits"],
            dynamo=False,
            do_constant_folding=False,
        )
    onnx.checker.check_model(onnx.load(str(model_path)))
    model_sha = sha256_file(model_path)
    weight_path = Path(torch.hub.get_dir()) / "checkpoints" / weights.url.rsplit("/", 1)[1]
    cases = []
    for video in VIDEOS:
        scenario = f"{video['name']}_resnet18_fp32_b1_c1"
        x = weights.transforms()(images[video["name"]]).unsqueeze(0).contiguous()
        input_path = output_dir / f"{scenario}.npy"
        np.save(input_path, x.numpy())
        cases.append({
            "name": scenario,
            "video": video["name"],
            "source_filename": video["filename"],
            "source_sha256": source_hashes[video["name"]],
            "input_filename": input_path.name,
            "input_path": str(input_path),
            "input_sha256": hashlib.sha256(x.numpy().tobytes()).hexdigest(),
            "model_filename": model_path.name,
            "model_path": str(model_path),
            "model_sha256": model_sha,
        })
    manifest = {
        "model": {
            "name": "resnet18",
            "filename": model_path.name,
            "path": str(model_path),
            "sha256": model_sha,
            "weights_url": weights.url,
            "weights_sha256": sha256_file(weight_path),
            "opset": 17,
            "constant_folding": False,
        },
        "cases": cases,
        "width": 224,
        "height": 224,
        "batch_size": 1,
        "precision": "FP32",
        "prepared_at": __import__("datetime").datetime.now(
            __import__("datetime").timezone.utc
        ).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    write_json(manifest_path, manifest)
    verify_manifest(json.loads(manifest_path.read_text(encoding="utf-8")), args)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", flush=True)
        raise SystemExit(2)
