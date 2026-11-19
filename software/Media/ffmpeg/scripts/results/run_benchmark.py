#!/usr/bin/env python3
"""Run the stock FFmpeg 7.1.1 1080p -> 640x360 RGB24 scale benchmark."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import statistics
import subprocess
import sys
import time
from pathlib import Path

VIDEOS = (
    {"name": "BQTerrace", "filename": "BQTerrace_1920x1080_60-dianbo.yuv", "fps": 60},
    {"name": "Film2012", "filename": "Film2012_1920x1080_25_8bit_8Mbps.yuv", "fps": 25},
    {"name": "messi", "filename": "messi_1920x1080_25_1000.yuv", "fps": 25},
)
FRAME_BYTES = 1920 * 1080 * 3 // 2
WIDTH = 640
HEIGHT = 360
PIXEL_FORMAT = "rgb24"


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def prepare_clip(source: Path, destination: Path, frames: int) -> None:
    required = FRAME_BYTES * frames
    if source.stat().st_size < required:
        raise ValueError(f"input video needs at least {frames} frames: {source}")
    with source.open("rb") as handle:
        destination.write_bytes(handle.read(required))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--video-dir", required=True)
    parser.add_argument("--clips-dir", required=True)
    parser.add_argument("--ffmpeg", required=True)
    parser.add_argument("--lib-dir", required=True)
    parser.add_argument("--csv", required=True)
    parser.add_argument("--evidence-dir", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--warmup-iterations", type=int, default=1)
    parser.add_argument("--frames", type=int, default=30)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    video_dir = Path(args.video_dir).resolve()
    clips_dir = Path(args.clips_dir).resolve()
    evidence_dir = Path(args.evidence_dir).resolve()
    csv_path = Path(args.csv).resolve()
    clips_dir.mkdir(parents=True, exist_ok=True)
    evidence_dir.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env.update(
        LD_LIBRARY_PATH=str(Path(args.lib_dir).resolve()),
        LC_ALL="C",
        OMP_NUM_THREADS="1",
        OMP_THREAD_LIMIT="1",
    )
    expected_bytes = WIDTH * HEIGHT * args.frames * 3
    evidence = {"source_mode": "unpatched", "cases": {}, "failures": {}}
    rows = []
    for video in VIDEOS:
        source = video_dir / video["filename"]
        if not source.is_file():
            raise ValueError(f"input video is missing: {source}")
        clip = clips_dir / f"{video['name']}-{args.frames}.yuv"
        prepare_clip(source, clip, args.frames)
        scenario = f"{video['name']}_{WIDTH}x{HEIGHT}_{PIXEL_FORMAT}"
        output = clips_dir / "output.raw"
        command = [
            args.ffmpeg, "-v", "error", "-nostdin", "-y",
            "-threads", "1", "-filter_threads", "1",
            "-f", "rawvideo", "-pixel_format", "yuv420p",
            "-video_size", "1920x1080", "-framerate", str(video["fps"]),
            "-i", str(clip),
            "-vf", f"scale={WIDTH}:{HEIGHT}:flags=bilinear+accurate_rnd+bitexact",
            "-frames:v", str(args.frames), "-threads", "1",
            "-c:v", "rawvideo", "-pix_fmt", PIXEL_FORMAT,
            "-f", "rawvideo", str(output),
        ]
        try:
            for _ in range(args.warmup_iterations):
                subprocess.run(command, env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, check=True, timeout=300)
            if output.stat().st_size != expected_bytes:
                raise ValueError("output frame data is incomplete")
            timed = command[:-1] + ["/dev/null"]
            samples = []
            for _ in range(args.iterations):
                started = time.perf_counter_ns()
                result = subprocess.run(timed, env=env, stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE, timeout=300)
                if result.returncode:
                    raise ValueError(result.stderr.decode(errors="replace")[-2000:])
                samples.append((time.perf_counter_ns() - started) / 1_000_000.0 / args.frames)
            evidence["cases"][scenario] = {
                "scenario": scenario,
                "video": video["name"],
                "frames": args.frames,
                "samples_ms_per_frame": samples,
                "input_sha256": digest(clip),
                "output_sha256": digest(output),
                "expected_output_bytes": expected_bytes,
                "command": command,
            }
            value = statistics.median(samples)
            rows.append([scenario, str(args.frames), f"{value:.6f}", "OK"])
            print(f"{scenario} {value:.6f} ms/frame", flush=True)
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            evidence["failures"][scenario] = {"error_type": type(error).__name__, "error": str(error)}
            rows.append([scenario, str(args.frames), "", "FAIL"])
            print(f"FAIL {scenario}: {type(error).__name__}: {error}", flush=True)
        finally:
            output.unlink(missing_ok=True)
        (evidence_dir / "evidence.json").write_text(
            json.dumps(evidence, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["scenario", "frames", "ms_per_frame", "status"])
        writer.writerows(rows)
    print(f"Result: {csv_path}", flush=True)
    print("查看 ms_per_frame 列，单位毫秒/帧，越小越好。", flush=True)
    if len(evidence["cases"]) != 3 or evidence["failures"]:
        print(f"ERROR: expected 3 successful cases, got {len(evidence['cases'])}", flush=True)
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", flush=True)
        raise SystemExit(2)
