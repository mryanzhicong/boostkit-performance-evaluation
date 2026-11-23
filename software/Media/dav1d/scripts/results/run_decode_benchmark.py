#!/usr/bin/env python3
"""Run the formal dav1d decode benchmark.

The measurement follows the reference ``Test/dav1d/scripts/bench.py``: one
untimed warm-up decode that verifies all 30 output frames, then 20 timed
decodes whose whole-process wall clock is divided by 30 frames.  Both videos
use 16 frame-level decoder threads without CPU affinity.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import platform
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


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


def cpu_model() -> str:
    try:
        for line in Path("/proc/cpuinfo").read_text(encoding="utf-8").splitlines():
            key, separator, value = line.partition(":")
            if separator and key.strip().lower() in {"model name", "cpu model", "hardware"}:
                return value.strip()
    except OSError:
        pass
    return ""


def run_logged(command: list[str], log_path: Path, env: dict, timeout: int, label: str,
               cwd: Path | None = None) -> None:
    result = subprocess.run(
        command,
        env=env,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        timeout=timeout,
    )
    output = result.stdout.decode("utf-8", errors="replace")
    with log_path.open("a", encoding="utf-8") as log:
        log.write(f"===== {label} =====\n")
        log.write("command: " + " ".join(command) + "\n")
        log.write(output)
        if not output.endswith("\n"):
            log.write("\n")
    if result.returncode != 0:
        raise RuntimeError(f"{label} exited with code {result.returncode}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--decoder", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--library-dir", required=True)
    parser.add_argument("--evidence-dir", required=True)
    parser.add_argument("--csv", required=True)
    parser.add_argument("--work-dir", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--warmup-iterations", type=int, default=1)
    parser.add_argument("--frames", type=int, default=30)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--threads", type=int, default=16)
    parser.add_argument("--timeout", type=int, default=300)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    decoder = Path(args.decoder).resolve()
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    evidence_dir = Path(args.evidence_dir).resolve()
    evidence_dir.mkdir(parents=True, exist_ok=True)
    work_dir = Path(args.work_dir).resolve()
    work_dir.mkdir(parents=True, exist_ok=True)
    if not decoder.is_file() or not os.access(decoder, os.X_OK):
        raise ValueError(f"dav1d is missing or not executable: {decoder}")
    videos = manifest.get("videos")
    if not isinstance(videos, list) or len(videos) != 2:
        raise ValueError("manifest must contain exactly two videos")
    if manifest.get("frames") != args.frames:
        raise ValueError("manifest frame count differs from the benchmark definition")
    if manifest.get("width") != args.width or manifest.get("height") != args.height:
        raise ValueError("manifest resolution differs from the benchmark definition")
    if manifest.get("bit_depth") != 8 or manifest.get("cq_level") != 32:
        raise ValueError("manifest bit depth or CQ level differs from the fixed workload")
    for video in videos:
        stream = Path(video["stream_path"]).resolve()
        if not stream.is_file() or video.get("stream_sha256") != sha256_file(stream):
            raise ValueError(f"prepared IVF stream differs from the manifest: {stream}")
    expected_bytes = args.width * args.height * 3 // 2 * args.frames
    env = os.environ.copy()
    env["LD_LIBRARY_PATH"] = args.library_dir + (":" + env["LD_LIBRARY_PATH"] if env.get("LD_LIBRARY_PATH") else "")
    version_result = subprocess.run(
        [str(decoder), "--version"], env=env, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=False, timeout=30,
    )
    decoder_version_output = version_result.stdout.decode("utf-8", errors="replace").strip()
    parameters = {
        "videos": [
            {
                "filename": video["source_filename"],
                "sha256": video["source_sha256"],
                "fps": video["fps"],
            }
            for video in videos
        ],
        "codec": "AV1",
        "bit_depth": manifest["bit_depth"],
        "width": args.width,
        "height": args.height,
        "frames": args.frames,
        "cq_level": manifest["cq_level"],
        "decode_threads": args.threads,
        "iterations": args.iterations,
        "warmup_iterations": args.warmup_iterations,
        "timing": "whole_process_wall_clock/30",
        "affinity": "unbound",
        "decoder": "dav1d-1.5.4",
        "input_encoder": manifest["encoder"]["version"],
        "encoder_settings": manifest["encoder"]["settings"],
    }
    evidence = {
        "software": "dav1d",
        "version": "1.5.4",
        "architecture": platform.machine(),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "decoder": {
            "path": str(decoder),
            "sha256": sha256_file(decoder),
            "version_output": decoder_version_output,
        },
        "manifest": manifest,
        "parameters": parameters,
        "runtime_context": {
            "cpu_count": os.cpu_count(),
            "machine": platform.machine(),
            "cpu_model": cpu_model(),
            "python": platform.python_version(),
        },
        "scenarios": [],
    }
    write_json(evidence_dir / "evidence.json", evidence)
    rows = []
    for video in videos:
        scenario = f"{video['name']}_{args.height}p_decode_c{args.threads}"
        scenario_dir = evidence_dir / video["name"]
        scenario_dir.mkdir(parents=True, exist_ok=True)
        (scenario_dir / "timed.log").write_text("", encoding="utf-8")
        (scenario_dir / "warmup.log").write_text("", encoding="utf-8")
        stream = Path(video["stream_path"]).resolve()
        warmup_output = work_dir / f"{video['name']}_output.yuv"
        warmup_output.unlink(missing_ok=True)
        warmup_command = [
            str(decoder), "--input", str(stream), "--threads", str(args.threads),
            "--framedelay", "0", "--filmgrain", "1", "--quiet",
            "--muxer", "yuv", "--output", str(warmup_output),
        ]
        timed_command = list(warmup_command)
        timed_command[timed_command.index("--muxer") + 1] = "null"
        timed_command[-1] = "/dev/null"
        write_json(scenario_dir / "command.json", {
            "scenario": scenario,
            "threads": args.threads,
            "warmup_command": warmup_command,
            "timed_command": timed_command,
        })
        print(f"[{scenario}] warm-up decode", flush=True)
        started = time.perf_counter()
        for warmup_index in range(args.warmup_iterations):
            run_logged(warmup_command, scenario_dir / "warmup.log", env, args.timeout,
                       f"warm-up {warmup_index + 1}/{args.warmup_iterations}", cwd=work_dir)
        if not warmup_output.is_file():
            raise RuntimeError("warm-up decode produced no output file")
        output_bytes = warmup_output.stat().st_size
        if output_bytes != expected_bytes:
            raise RuntimeError(
                f"warm-up output is {output_bytes} bytes, expected {expected_bytes}"
            )
        output_sha256 = sha256_file(warmup_output)
        warmup_output.unlink()
        warmup_seconds = time.perf_counter() - started
        samples: list[float] = []
        for iteration in range(1, args.iterations + 1):
            started_ns = time.perf_counter_ns()
            run_logged(timed_command, scenario_dir / "timed.log", env, args.timeout,
                       f"timed {iteration}/{args.iterations}", cwd=work_dir)
            elapsed_ns = time.perf_counter_ns() - started_ns
            sample = elapsed_ns / 1_000_000.0 / args.frames
            samples.append(sample)
            print(
                f"[{scenario}] {iteration}/{args.iterations}: {sample:.6f} ms/frame",
                flush=True,
            )
        mean = statistics.mean(samples)
        result = {
            "scenario": scenario,
            "video": video["name"],
            "threads": args.threads,
            "frames": args.frames,
            "iterations": args.iterations,
            "input_sha256": video["stream_sha256"],
            "warmup": {
                "command": warmup_command,
                "seconds": warmup_seconds,
                "output_bytes": output_bytes,
                "output_sha256": output_sha256,
            },
            "timed_command": timed_command,
            "samples_ms_per_frame": samples,
            "mean_ms_per_frame": mean,
            "median_ms_per_frame": statistics.median(samples),
            "min_ms_per_frame": min(samples),
            "max_ms_per_frame": max(samples),
            "stdev_ms_per_frame": statistics.stdev(samples),
            "total_seconds": sum(samples) * args.frames / 1000.0,
        }
        write_json(scenario_dir / "result.json", result)
        evidence["scenarios"].append(result)
        write_json(evidence_dir / "evidence.json", evidence)
        rows.append([scenario, str(args.frames), f"{mean:.6f}", "OK"])
        print(f"[{scenario}] mean {mean:.6f} ms/frame", flush=True)

    csv_path = Path(args.csv).resolve()
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["scenario", "frames", "ms_per_frame", "status"])
        writer.writerows(rows)
    print(f"Result: {csv_path}", flush=True)
    print("查看 ms_per_frame 列，单位毫秒/帧，越小越好。", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
