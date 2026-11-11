#!/usr/bin/env python3
"""Run the formal uavs3d decode benchmark.

The measurement follows the reference ``Test/uavs3d/scripts/bench.py``:
one untimed warm-up decode that verifies the full output frame count, then 20
timed decodes whose whole-process wall clock is divided by 120 frames.  The
two fixed scenarios use 16 and 24 frame-level threads without CPU affinity.
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


def run_logged(command: list[str], log_path: Path, timeout: int, label: str) -> None:
    result = subprocess.run(
        command,
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
    parser.add_argument("--stream", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--evidence-dir", required=True)
    parser.add_argument("--csv", required=True)
    parser.add_argument("--work-dir", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--warmup-iterations", type=int, default=1)
    parser.add_argument("--frames", type=int, default=120)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--threads", type=int, nargs="+", default=[16, 24])
    parser.add_argument("--timeout", type=int, default=300)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    decoder = Path(args.decoder).resolve()
    stream = Path(args.stream).resolve()
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    evidence_dir = Path(args.evidence_dir).resolve()
    evidence_dir.mkdir(parents=True, exist_ok=True)
    work_dir = Path(args.work_dir).resolve()
    work_dir.mkdir(parents=True, exist_ok=True)
    if not decoder.is_file() or not os.access(decoder, os.X_OK):
        raise ValueError(f"uavs3dec is missing or not executable: {decoder}")
    if manifest.get("stream_sha256") != sha256_file(stream):
        raise ValueError("prepared AVS3 stream checksum differs from the manifest")
    if manifest.get("frames") != args.frames:
        raise ValueError("manifest frame count differs from the benchmark definition")
    if manifest.get("width") != args.width or manifest.get("height") != args.height:
        raise ValueError("manifest resolution differs from the benchmark definition")
    if manifest.get("qp") != 32 or manifest.get("bit_depth") != 8:
        raise ValueError("manifest QP or bit depth differs from the fixed workload")
    expected_bytes = args.width * args.height * 3 // 2 * args.frames
    version_result = subprocess.run(
        [str(decoder), "-v", "1"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        check=False, timeout=30,
    )
    decoder_version_output = version_result.stdout.decode("utf-8", errors="replace").strip()
    parameters = {
        "video": manifest["source_filename"],
        "video_sha256": manifest["source_sha256"],
        "stream": manifest["stream_filename"],
        "codec": "AVS3-P2",
        "bit_depth": manifest["bit_depth"],
        "width": args.width,
        "height": args.height,
        "frames": args.frames,
        "fps": manifest["fps"],
        "qp": manifest["qp"],
        "decode_threads": list(args.threads),
        "iterations": args.iterations,
        "warmup_iterations": args.warmup_iterations,
        "timing": "whole_process_wall_clock/120",
        "affinity": "unbound",
        "decoder": "uavs3d-1.2",
        "input_encoder": manifest["encoder"]["version"],
        "encoder_settings": manifest["encoder"]["settings"],
    }
    evidence = {
        "software": "uavs3d",
        "version": "1.2",
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
    for threads in args.threads:
        scenario = f"{manifest['name']}_{args.height}p_q{manifest['qp']}_decode_c{threads}"
        scenario_dir = evidence_dir / f"c{threads}"
        scenario_dir.mkdir(parents=True, exist_ok=True)
        (scenario_dir / "timed.log").write_text("", encoding="utf-8")
        (scenario_dir / "warmup.log").write_text("", encoding="utf-8")
        warmup_output = work_dir / f"warmup_c{threads}.yuv"
        warmup_output.unlink(missing_ok=True)
        warmup_command = [
            str(decoder), "-i", str(stream), "-o", str(warmup_output),
            "-t", str(threads), "-l", "2", "-s", "1",
        ]
        timed_command = list(warmup_command)
        timed_command[timed_command.index("-o") + 1] = "/dev/null"
        timed_command[timed_command.index("-l") + 1] = "1"
        timed_command[timed_command.index("-s") + 1] = "0"
        write_json(scenario_dir / "command.json", {
            "scenario": scenario,
            "threads": threads,
            "warmup_command": warmup_command,
            "timed_command": timed_command,
        })
        print(f"[{scenario}] warm-up decode", flush=True)
        started = time.perf_counter()
        for warmup_index in range(args.warmup_iterations):
            run_logged(warmup_command, scenario_dir / "warmup.log", args.timeout,
                       f"warm-up {warmup_index + 1}/{args.warmup_iterations}")
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
            run_logged(timed_command, scenario_dir / "timed.log", args.timeout,
                       f"timed {iteration}/{args.iterations}")
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
            "threads": threads,
            "frames": args.frames,
            "iterations": args.iterations,
            "input_sha256": manifest["stream_sha256"],
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
