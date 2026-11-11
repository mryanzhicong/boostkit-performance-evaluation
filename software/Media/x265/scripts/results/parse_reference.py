#!/usr/bin/env python3
"""Validate the original Test/x265 output and expose its two FPS values."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import shutil
import sys
from pathlib import Path


VIDEO_NAME = "BQTerrace_1920x1080_60-dianbo.yuv"
SCENARIOS = {
    f"BQTerrace_medium_crf{crf}_offline": crf for crf in (24, 28)
}
REFERENCE_REVISION = "21154155f56328b708e2c78f4ce6bac08101fe68"
X265_PARAMS = "pools=16:frame-threads=15:ctu=16:aq-mode=4:bframes=7"


def sha256_file(path: Path) -> str:
    checksum = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def option_value(command: list[str], option: str) -> str:
    if command.count(option) != 1:
        raise ValueError(f"reference command must contain one {option}")
    index = command.index(option)
    if index + 1 >= len(command):
        raise ValueError(f"reference command has no value for {option}")
    return command[index + 1]


def validate_record(record: dict, scenario: str, crf: int,
                    video: Path, private_root: Path) -> dict:
    if record.get("scenario") != scenario:
        raise ValueError(f"unexpected reference scenario: {record.get('scenario')}")
    item = record.get("item", {})
    if item.get("name") != "BQTerrace" or item.get("filename") != VIDEO_NAME or item.get("fps") != 60:
        raise ValueError(f"{scenario}: reference video identity differs")
    data = record.get("data", {})
    rows = data.get("rows", [])
    if data.get("affinity") != "unbound" or len(rows) != 1:
        raise ValueError(f"{scenario}: expected one unbound result row")
    row = rows[0]
    if row.get("status") != "OK" or row.get("frames") != 600 or row.get("affinity") != "unbound":
        raise ValueError(f"{scenario}: reference run did not finish 600 frames unbound")
    if row.get("phase") != "confirm" or row.get("start_frame") != 0:
        raise ValueError(f"{scenario}: reference run phase differs")
    settings = row.get("settings", {})
    expected = {
        "cores": 16, "preset": "medium", "frame_threads": 15,
        "pool_threads": 16, "ctu_size": 16, "bframes": 7,
        "aq_mode": 4, "crf": crf, "maxrate_kbps": 6000,
        "bufsize_kbits": 12000,
    }
    if any(settings.get(key) != value for key, value in expected.items()):
        raise ValueError(f"{scenario}: reference x265 settings differ")
    source = settings.get("video", {})
    if (source.get("width") != 1920 or source.get("height") != 1080 or
            source.get("fps") != "60" or source.get("pix_fmt") != "yuv420p" or
            source.get("start_frame") != 0 or source.get("screen_frames") != 600 or
            Path(source.get("path", "")).resolve() != video.resolve()):
        raise ValueError(f"{scenario}: reference YUV input settings differ")
    seconds = row.get("seconds")
    fps = row.get("fps")
    if (not isinstance(seconds, (int, float)) or isinstance(seconds, bool) or
            not isinstance(fps, (int, float)) or isinstance(fps, bool) or
            not math.isfinite(seconds) or not math.isfinite(fps) or
            seconds <= 0 or fps <= 0 or
            not math.isclose(fps, 600 / seconds, rel_tol=1e-9)):
        raise ValueError(f"{scenario}: reference FPS is not 600 / full command seconds")

    output = Path(record["output"]).resolve()
    command_file = Path(record["command_file"]).resolve()
    if not output.is_relative_to(private_root) or not command_file.is_relative_to(private_root):
        raise ValueError(f"{scenario}: reference evidence escaped the private directory")
    if not output.is_file() or output.stat().st_size <= 0 or not command_file.is_file():
        raise ValueError(f"{scenario}: reference MP4 or command evidence is missing")
    command = json.loads(command_file.read_text())
    if (not isinstance(command, list) or not command or
            Path(command[0]).name != "ffmpeg" or command[-1] != str(output) or
            any(Path(part).name in {"taskset", "numactl"} for part in command)):
        raise ValueError(f"{scenario}: reference command identity differs")
    for option, value in (
        ("-frames:v", "600"), ("-preset", "medium"),
        ("-crf", str(crf)), ("-maxrate", "6000k"),
        ("-bufsize", "12000k"), ("-x265-params", X265_PARAMS),
    ):
        if option_value(command, option) != value:
            raise ValueError(f"{scenario}: reference command {option} differs")
    if row.get("output_bytes") != output.stat().st_size:
        raise ValueError(f"{scenario}: reference output size differs")
    folder = command_file.parent
    for filename in ("progress.txt", "encode.log", "probe.json", "result.json"):
        if not (folder / filename).is_file():
            raise ValueError(f"{scenario}: missing original {filename}")
    return {"row": row, "evidence": folder}


def parse(args: argparse.Namespace) -> dict:
    if args.version != "4.2" or args.architecture not in {"x86_64", "aarch64"}:
        raise ValueError("expected x265 4.2 on x86_64 or aarch64")
    if args.video.name != VIDEO_NAME or not args.video.is_file():
        raise ValueError("required reference BQTerrace video is missing")
    scripts = args.reference_dir / "scripts"
    private_root = scripts.resolve()
    evidence = json.loads((scripts / ".work/evidence.json").read_text())
    records = evidence.get("runs", [])
    if evidence.get("affinity") != "unbound" or len(records) != 2:
        raise ValueError("reference run must finish two unbound scenes")
    by_scenario = {record.get("scenario"): record for record in records}
    if set(by_scenario) != set(SCENARIOS):
        raise ValueError("reference CRF 24/28 scene set differs")
    with (scripts / "result_bench-x265.csv").open(newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != ["scenario", "frames", "fps", "status"]:
            raise ValueError("reference CSV columns differ")
        csv_rows = list(reader)
    if len(csv_rows) != 2 or {row["scenario"] for row in csv_rows} != set(SCENARIOS):
        raise ValueError("reference CSV must contain exactly two scenes")
    csv_by_scenario = {row["scenario"]: row for row in csv_rows}
    args.results_dir.mkdir(parents=True, exist_ok=True)
    raw_path = args.results_dir / "benchmark_encode.txt"
    results = {}
    measurements = []
    for scenario, crf in SCENARIOS.items():
        parsed = validate_record(by_scenario[scenario], scenario, crf,
                                 args.video, private_root)
        row = parsed["row"]
        csv_row = csv_by_scenario[scenario]
        rounded = f'{row["fps"]:.3f}'
        if csv_row != {"scenario": scenario, "frames": "600", "fps": rounded, "status": "OK"}:
            raise ValueError(f"{scenario}: CSV FPS differs from original result row")
        name = f"single/BQTerrace/medium_crf{crf}_offline/fps"
        results[name] = {
            "source_name": name, "source_field": "fps",
            "group": "单路", "subgroup": "BQTerrace", "value": float(rounded),
        }
        measurements.append({
            "scenario": scenario, "frames": 600, "crf": crf,
            "seconds": row["seconds"], "fps": row["fps"],
            "output_bytes": row["output_bytes"],
            "output_sha256": row["output_sha256"],
            "pool_thread_counts": row.get("pool_thread_counts", []),
        })
        destination = args.results_dir / "scenarios" / scenario
        destination.mkdir(parents=True, exist_ok=False)
        for filename in ("command.txt", "progress.txt", "encode.log", "probe.json", "result.json"):
            source = parsed["evidence"] / filename
            if source.is_file():
                shutil.copy2(source, destination / filename)
        with raw_path.open("a") as raw:
            raw.write(f"\n{scenario}: {row['seconds']:.6f} seconds, {row['fps']:.6f} fps\n")
            raw.write((parsed["evidence"] / "encode.log").read_text(errors="replace"))
    return {
        "software": "x265", "version": args.version,
        "architecture": args.architecture,
        "parameters": {
            "reference_revision": REFERENCE_REVISION,
            "source_video": VIDEO_NAME,
            "source_video_sha256": sha256_file(args.video),
            "width": 1920, "height": 1080, "pixel_format": "yuv420p",
            "source_fps": 60, "frames": 600,
            "encoder": "stock x265 4.2 via FFmpeg 7.0.1",
            "preset": "medium", "crfs": [24, 28],
            "maxrate_kbps": 6000, "bufsize_kbits": 12000,
            "pools": 16, "frame_threads": 15, "ctu": 16,
            "bframes": 7, "aq_mode": 4,
            "cpu_affinity": "unbound", "numa_affinity": "unbound",
            "repetitions": 1,
            "timing": "600 frames / full encode command seconds",
        },
        "measurements": measurements, "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--video", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    args = parser.parse_args()
    try:
        payload = parse(args)
        (args.results_dir / "benchmark_x265.json").write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    except (OSError, KeyError, ValueError, TypeError) as exc:
        print(f"[x265] ERROR: reference result conversion failed: {exc}", file=sys.stderr)
        return 1
    print("[x265] collected both original reference CSV FPS values", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
