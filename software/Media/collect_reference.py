#!/usr/bin/env python3
"""Validate and normalize the untouched reference x264/x265 shell-script output."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from pathlib import Path

VIDEO_NAMES = (
    "Dota2_1920x1080_60",
    "xihuanni_1920x1080_30_1000",
    "showSingText_1920x1080_40",
    "1_Yuanshen_1920x1080_60_8bit_12M",
    "BQTerrace_1920x1080_60",
    "Film2012_1920x1080_25_8bit_8Mbps",
    "BQTerrace_1920x1080_60-dianbo",
    "messi_1920x1080_25_1000",
    "BasketballDrive_1920x1080_50",
    "BQTerrace_1920x1080_60-biaozhun",
    "Cactus_1920x1080_50",
    "Kimono_1920x1080_24",
    "ParkScene_1920x1080_24",
)
BITRATES = (2000, 4000, 6000, 8000)
FRAME_BYTES = 1920 * 1080 * 3 // 2
MAX_FRAMES = 9999
REFERENCE_REVISION = "8d36fe4cca75fb36af5aafbf18c2a09ebee587b2"
X264_SUMMARY = re.compile(r"encoded\s+(\d+)\s+frames,\s+([\d.]+)\s+fps")
X265_SUMMARY = re.compile(r"encoded\s+(\d+)\s+frames\s+in\s+[\d.]+s\s+\(([\d.]+)\s+fps\)")
CSV_FIELDS = ("Bitrate", "Video Directory", "Total FPS", "Average Bin Size")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(8 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_videos(
    video_dir: Path, hash_files: bool = True, allow_subset: bool = False
) -> dict[str, dict[str, object]]:
    if not video_dir.is_dir():
        raise ValueError(f"reference video directory does not exist: {video_dir}")
    actual = {path.stem for path in video_dir.glob("*.yuv")}
    expected = set(VIDEO_NAMES)
    if not actual:
        raise ValueError(f"reference video directory contains no YUV inputs: {video_dir}")
    if actual - expected or (not allow_subset and actual != expected):
        raise ValueError(
            f"reference video set differs: missing={sorted(expected - actual)}, "
            f"extra={sorted(actual - expected)}"
        )
    videos: dict[str, dict[str, object]] = {}
    for name in VIDEO_NAMES:
        if name not in actual:
            continue
        path = video_dir / f"{name}.yuv"
        size = path.stat().st_size
        if size == 0 or size % FRAME_BYTES:
            raise ValueError(f"video has incomplete 1920x1080 I420 frames: {path}")
        videos[name] = {
            "bytes": size,
            "frames": min(MAX_FRAMES, size // FRAME_BYTES),
        }
        if hash_files:
            videos[name]["sha256"] = sha256_file(path)
    return videos


def positive_decimal(value: str, description: str) -> Decimal:
    try:
        number = Decimal(value.strip())
    except InvalidOperation as error:
        raise ValueError(f"{description} is not numeric: {value!r}") from error
    if not number.is_finite() or number <= 0:
        raise ValueError(f"{description} must be positive and finite: {value!r}")
    return number


def read_summary(
    path: Path, selected_names: set[str] | None = None
) -> dict[tuple[str, int], tuple[Decimal, Decimal]]:
    if not path.is_file():
        raise ValueError(f"reference score CSV is missing: {path}")
    if selected_names is None:
        selected_names = set(VIDEO_NAMES)
    expected_rows = {(name, bitrate) for name in selected_names for bitrate in BITRATES}
    rows: dict[tuple[str, int], tuple[Decimal, Decimal]] = {}
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if tuple(reader.fieldnames or ()) != CSV_FIELDS:
            raise ValueError(f"reference score CSV has unexpected columns: {reader.fieldnames}")
        for row in reader:
            name = row["Video Directory"]
            bitrate_text = row["Bitrate"]
            if name not in selected_names or bitrate_text not in {f"{n}k" for n in BITRATES}:
                raise ValueError(f"unexpected reference score row: {row}")
            key = (name, int(bitrate_text[:-1]))
            if key in rows:
                raise ValueError(f"duplicate reference score row: {key}")
            rows[key] = (
                positive_decimal(row["Total FPS"], f"{key} total FPS"),
                positive_decimal(row["Average Bin Size"], f"{key} average bin size"),
            )
    if set(rows) != expected_rows:
        raise ValueError(
            f"reference score CSV rows differ: missing={sorted(expected_rows - set(rows))}, "
            f"extra={sorted(set(rows) - expected_rows)}"
        )
    return rows


def parse_fps(encoder: str, output: str, expected_frames: int) -> Decimal:
    pattern = X264_SUMMARY if encoder == "x264" else X265_SUMMARY
    matches = pattern.findall(output.replace("\r", "\n"))
    if not matches:
        raise ValueError(f"{encoder} route log has no official encoded-frame FPS summary")
    frames, fps_text = matches[-1]
    if int(frames) != expected_frames:
        raise ValueError(f"{encoder} encoded {frames} frames, expected {expected_frames}")
    return positive_decimal(fps_text, f"{encoder} official FPS")


def collect(
    encoder: str,
    work_dir: Path,
    raw_output: Path,
    rows: dict[tuple[str, int], tuple[Decimal, Decimal]],
    videos: dict[str, dict[str, object]],
) -> dict[str, dict[str, object]]:
    results: dict[str, dict[str, object]] = {}
    output_base = work_dir / f"outputfiles-{encoder}"
    with raw_output.open("a", encoding="utf-8") as combined:
        for name in VIDEO_NAMES:
            if name not in videos:
                continue
            for bitrate in BITRATES:
                route_dir = output_base / f"{bitrate}k" / name
                log_path = route_dir / f"log_{name}_{bitrate}k_1.txt"
                bitstream = route_dir / f"{name}_{bitrate}k_1.bin"
                if not log_path.is_file() or not bitstream.is_file():
                    raise ValueError(f"reference route output is incomplete: {route_dir}")
                output = log_path.read_text(encoding="utf-8", errors="replace")
                combined.write(f"\n### {name} {bitrate}k: {log_path}\n{output}\n")
                route_fps = parse_fps(encoder, output, int(videos[name]["frames"]))
                csv_fps, csv_size = rows[(name, bitrate)]
                if abs(route_fps - csv_fps) > Decimal("0.01"):
                    raise ValueError(f"reference score FPS differs from route log: {name} {bitrate}k")
                size = bitstream.stat().st_size
                if size <= 0 or abs(csv_size - size) > Decimal("0.01"):
                    raise ValueError(f"reference score size differs from bitstream: {name} {bitrate}k")
                value = float(csv_fps)
                if not math.isfinite(value):
                    raise ValueError(f"reference score FPS is not finite: {name} {bitrate}k")
                key = f"{name}/{bitrate}k/total_fps"
                results[key] = {
                    "source_name": key,
                    "source_field": "fps",
                    "group": f"{bitrate} kb/s",
                    "value": value,
                    "average_bin_size_bytes": float(csv_size),
                }
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check-only", action="store_true")
    parser.add_argument("--allow-video-subset", action="store_true")
    parser.add_argument("--encoder", choices=("x264", "x265"))
    parser.add_argument("--video-dir", required=True, type=Path)
    parser.add_argument("--work-dir", type=Path)
    parser.add_argument("--raw-output", type=Path)
    parser.add_argument("--summary", type=Path)
    parser.add_argument("--normalized-output", type=Path)
    parser.add_argument("--version")
    parser.add_argument("--architecture", choices=("x86_64", "aarch64"))
    args = parser.parse_args()
    try:
        videos = inspect_videos(
            args.video_dir,
            hash_files=not args.check_only,
            allow_subset=args.allow_video_subset,
        )
        if args.check_only:
            print(f"[reference-video] verified {len(videos)} YUV inputs", flush=True)
            return 0
        required = ("encoder", "work_dir", "raw_output", "summary", "normalized_output", "version", "architecture")
        missing = [field for field in required if getattr(args, field) is None]
        if missing:
            raise ValueError(f"missing result collection arguments: {', '.join(missing)}")
        rows = read_summary(args.summary, set(videos))
        results = collect(args.encoder, args.work_dir, args.raw_output, rows, videos)
        payload = {
            "benchmark": f"{args.encoder}_reference_shell_suite",
            "software": args.encoder,
            "version": args.version,
            "architecture": args.architecture,
            "variant": os.environ.get("PERF_VARIANT", "base"),
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "parameters": {
                "videos": videos,
                "resolution": "1920x1080",
                "color_format": "I420_8bit",
                "bitrates_kbps": list(BITRATES),
                "frames_argument": MAX_FRAMES,
                "cpu_binding": "8core",
                "routes": 1,
                "reference_revision": REFERENCE_REVISION,
            },
            "results": results,
        }
        args.normalized_output.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
            encoding="utf-8",
        )
        print(f"[reference-video] normalized {len(results)} FPS measurements", flush=True)
        return 0
    except (OSError, ValueError) as error:
        print(f"[reference-video] ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
