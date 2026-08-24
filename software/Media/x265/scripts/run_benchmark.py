#!/usr/bin/env python3
"""Run x265's official H.265/HEVC encode benchmarks and normalize fps metrics.

x265 is the HEVC encoder from the VideoLAN/x265 project. Its canonical
throughput signal is the summary line printed to stderr on every encode run::

    encoded N frames in X.XXs (Y.YY fps), K kb/s, Global PSNR: P.PPP

This driver reproduces the two official benchmark families shipped by the x265
test wrapper:

* **encode preset sweep** — encode the same deterministic I420 clip with each of
  the official ``--preset`` values (ultrafast/fast/medium/slow/veryslow) and
  record the reported frames-per-second;
* **micro scaling** — encode at three resolutions (resolution scaling) and at
  several ``--pools`` thread counts (thread scaling) at the ``medium`` preset.

Every metric name is built verbatim from the official ``--preset`` value,
``--input-res`` resolution or ``--pools`` thread count plus the official ``fps``
field, so each name is directly traceable to the official x265 CLI.
"""

from __future__ import annotations

import json
import math
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_yuv import generate_yuv

PRESETS = ["ultrafast", "fast", "medium", "slow", "veryslow"]
RESOLUTIONS = [(320, 240), (1280, 720), (1920, 1080)]
# "auto" omits --pools so x265 selects its default thread layout; the remaining
# values pass an explicit worker-pool count.
THREAD_COUNTS = ["1", "2", "4", "8", "auto"]

STATS_RE = re.compile(
    r"encoded\s+(\d+)\s+frames\s+in\s+([\d.]+)s\s+\(([\d.]+)\s+fps\)"
)
PSNR_RE = re.compile(r"PSNR.*?Y:\s*([\d.]+)", re.IGNORECASE)


def fail(message: str) -> None:
    print(f"[x265-benchmark] ERROR: {message}", file=sys.stderr)


def build_command(
    cli_bin: str,
    yuv_file: str,
    width: int,
    height: int,
    frames: int,
    preset: str,
    threads: str | None = None,
    psnr: bool = False,
) -> list[str]:
    command = [
        cli_bin,
        "--input-res", f"{width}x{height}",
        "--fps", "25",
        "--frames", str(frames),
        "--preset", preset,
    ]
    if psnr:
        command.append("--psnr")
    command.extend(["-o", os.devnull])
    if threads is not None and threads != "auto":
        command.extend(["--pools", threads])
    command.append(yuv_file)
    return command


def run_once(
    cli_bin: str,
    yuv_file: str,
    width: int,
    height: int,
    frames: int,
    preset: str,
    threads: str | None = None,
    psnr: bool = False,
) -> str:
    command = build_command(cli_bin, yuv_file, width, height, frames, preset, threads, psnr)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=7200,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError(
            f"x265 exited with code {completed.returncode}: {' '.join(command)}"
        )
    return completed.stdout


def parse_stats(text: str) -> dict[str, float | int]:
    match = STATS_RE.search(text)
    if not match:
        raise RuntimeError(
            "x265 output has no 'encoded N frames in X.XXs (Y.YY fps)' summary"
        )
    psnr_match = PSNR_RE.search(text)
    return {
        "fps": float(match.group(3)),
        "encode_time_s": float(match.group(2)),
        "psnr_db": float(psnr_match.group(1)) if psnr_match else 0.0,
        "frames": int(match.group(1)),
    }


def average_fps(runs: list[float]) -> float:
    usable = [fps for fps in runs if math.isfinite(fps) and fps > 0]
    if not usable:
        raise RuntimeError("no encode run produced a positive fps value")
    return sum(usable) / len(usable)


def encode_preset_sweep(
    cli_bin: str,
    yuv_file: str,
    width: int,
    height: int,
    frames: int,
    iterations: int,
    raw_lines: list[str],
) -> dict[str, dict[str, Any]]:
    results: dict[str, dict[str, Any]] = {}
    for preset in PRESETS:
        raw_lines.append(f"### preset {preset} ({width}x{height}, {frames} frames)")
        fps_values: list[float] = []
        stats: dict[str, float | int] = {}
        for _ in range(iterations):
            text = run_once(cli_bin, yuv_file, width, height, frames, preset, psnr=True)
            raw_lines.append(text.rstrip())
            stats = parse_stats(text)
            fps_values.append(float(stats["fps"]))
        fps = average_fps(fps_values)
        name = f"preset_{preset}_fps"
        results[name] = {
            "source_name": name,
            "source_field": "fps",
            "preset": preset,
            "resolution": f"{width}x{height}",
            "frames": frames,
            "raw_value": round(fps, 4),
            "value": round(fps, 4),
            "unit": "fps",
            "direction": "higher_is_better",
            "psnr_db": round(float(stats.get("psnr_db", 0.0)), 4),
            "encode_time_s": round(float(stats.get("encode_time_s", 0.0)), 4),
        }
    return results


def micro_resolution_scaling(
    cli_bin: str,
    iterations: int,
    raw_lines: list[str],
) -> dict[str, dict[str, Any]]:
    import tempfile

    results: dict[str, dict[str, Any]] = {}
    tmpdir = tempfile.mkdtemp(prefix="x265_res_")
    try:
        for width, height in RESOLUTIONS:
            yuv = os.path.join(tmpdir, f"{width}x{height}.yuv")
            generate_yuv(width, height, 10, yuv)
            raw_lines.append(f"### resolution {width}x{height} (medium, 10 frames)")
            fps_values: list[float] = []
            for _ in range(iterations):
                text = run_once(cli_bin, yuv, width, height, 10, "medium")
                raw_lines.append(text.rstrip())
                fps_values.append(float(parse_stats(text)["fps"]))
            fps = average_fps(fps_values)
            name = f"res_{width}x{height}_fps"
            results[name] = {
                "source_name": name,
                "source_field": "fps",
                "resolution": f"{width}x{height}",
                "preset": "medium",
                "frames": 10,
                "raw_value": round(fps, 4),
                "value": round(fps, 4),
                "unit": "fps",
                "direction": "higher_is_better",
                "encode_time_s": round(10 / fps, 6) if fps > 0 else 0.0,
            }
    finally:
        import shutil

        shutil.rmtree(tmpdir, ignore_errors=True)
    return results


def micro_thread_scaling(
    cli_bin: str,
    iterations: int,
    raw_lines: list[str],
) -> dict[str, dict[str, Any]]:
    import tempfile

    tmpdir = tempfile.mkdtemp(prefix="x265_thread_")
    try:
        width, height, frames = 1280, 720, 30
        yuv = os.path.join(tmpdir, f"{width}x{height}.yuv")
        generate_yuv(width, height, frames, yuv)
        results: dict[str, dict[str, Any]] = {}
        for threads in THREAD_COUNTS:
            raw_lines.append(f"### pools {threads} (1280x720, medium, 30 frames)")
            fps_values: list[float] = []
            for _ in range(iterations):
                text = run_once(cli_bin, yuv, width, height, frames, "medium", threads=threads)
                raw_lines.append(text.rstrip())
                fps_values.append(float(parse_stats(text)["fps"]))
            fps = average_fps(fps_values)
            name = f"threads_{threads}_fps"
            results[name] = {
                "source_name": name,
                "source_field": "fps",
                "resolution": f"{width}x{height}",
                "preset": "medium",
                "threads": threads,
                "frames": frames,
                "raw_value": round(fps, 4),
                "value": round(fps, 4),
                "unit": "fps",
                "direction": "higher_is_better",
            }
        return results
    finally:
        import shutil

        shutil.rmtree(tmpdir, ignore_errors=True)


def main() -> int:
    if len(sys.argv) < 8:
        print(
            "usage: run_benchmark.py X265_BIN YUV_FILE WIDTH HEIGHT FRAMES "
            "RAW_OUTPUT NORMALIZED_OUTPUT [ITERATIONS]",
            file=sys.stderr,
        )
        return 1
    cli_bin = sys.argv[1]
    yuv_file = sys.argv[2]
    width = int(sys.argv[3])
    height = int(sys.argv[4])
    frames = int(sys.argv[5])
    raw_output = Path(sys.argv[6])
    normalized_output = Path(sys.argv[7])
    iterations = int(sys.argv[8]) if len(sys.argv) >= 9 else 1

    if not os.path.isfile(cli_bin) or not os.access(cli_bin, os.X_OK):
        fail(f"official x265 binary is unavailable: {cli_bin}")
        return 1
    if not os.path.isfile(yuv_file):
        fail(f"YUV input is unavailable: {yuv_file}")
        return 1

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1
    version_string = os.environ.get("X265_VERSION_STRING", version)

    raw_lines: list[str] = []
    try:
        raw_lines.append("# x265 official encode benchmark (preset sweep)")
        encode_results = encode_preset_sweep(
            cli_bin, yuv_file, width, height, frames, iterations, raw_lines
        )
        raw_lines.append("# x265 micro benchmark (resolution scaling)")
        resolution_results = micro_resolution_scaling(cli_bin, iterations, raw_lines)
        raw_lines.append("# x265 micro benchmark (thread scaling)")
        thread_results = micro_thread_scaling(cli_bin, iterations, raw_lines)
    except (RuntimeError, OSError, subprocess.SubprocessError) as exc:
        fail(str(exc))
        return 1

    results: dict[str, dict[str, Any]] = {}
    results.update(encode_results)
    results.update(resolution_results)
    results.update(thread_results)

    normalized = {
        "benchmark": "x265_official_encode_fps",
        "software": "x265",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": ["x265", "--preset", "<preset>", "--fps", "25",
                        "--frames", "<frames>", "-o", os.devnull, "<yuv>"],
            "resolution": f"{width}x{height}",
            "frames": frames,
            "iterations": iterations,
            "presets": PRESETS,
            "resolutions": [f"{w}x{h}" for w, h in RESOLUTIONS],
            "thread_counts": THREAD_COUNTS,
            "metric_source": "x265 CLI 'encoded N frames in Xs (Y fps)' summary",
        },
        "metric_contract": {
            "scope": (
                "verbatim x265 --preset / --input-res / --pools fps from "
                "the official CLI output"
            ),
            "source_field": "fps",
            "unit": "fps",
            "direction": "higher_is_better",
        },
        "runtime_context": {
            "x265_version_string": version_string,
        },
        "results": results,
    }

    raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw_output.write_text("\n".join(raw_lines) + "\n", encoding="utf-8")
    normalized_output.parent.mkdir(parents=True, exist_ok=True)
    normalized_output.write_text(
        json.dumps(normalized, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[x265-benchmark] normalized {len(results)} fps metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())