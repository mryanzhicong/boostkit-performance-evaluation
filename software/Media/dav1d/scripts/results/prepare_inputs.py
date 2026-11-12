#!/usr/bin/env python3
"""Prepare the IVF streams used by the dav1d decode benchmark.

This mirrors the reference ``Test/dav1d/scripts/prepare_inputs.py``: AOM 3.2.0
(generic C build) encodes the first 30 frames of BQTerrace and messi with a
single encoder thread and fixed QP/CQ settings.  The encoder runs in the
writable output directory so its sidecar files never land on a read-only cwd.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

RECORDS = (
    {
        "name": "BQTerrace",
        "source_filename": "BQTerrace_1920x1080_60-dianbo.yuv",
        "fps": 60,
        "stream_filename": "BQTerrace-30.ivf",
    },
    {
        "name": "messi",
        "source_filename": "messi_1920x1080_25_1000.yuv",
        "fps": 25,
        "stream_filename": "messi-30.ivf",
    },
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


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--encoder", default="")
    parser.add_argument("--source-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--log-dir", required=True)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--frames", type=int, default=30)
    parser.add_argument("--cq-level", type=int, default=32)
    parser.add_argument("--bit-depth", type=int, default=8)
    parser.add_argument("--timeout", type=int, default=3600)
    parser.add_argument("--verify-only", action="store_true")
    return parser


def frame_bytes(args: argparse.Namespace) -> int:
    return args.width * args.height * 3 // 2 * args.frames


def command_for(encoder: Path, source: Path, output: Path, fps: int, args: argparse.Namespace) -> list[str]:
    return [
        str(encoder),
        "--codec=av1",
        "--good",
        "--cpu-used=8",
        "--passes=1",
        "--threads=1",
        "--row-mt=0",
        "--tile-columns=1",
        "--end-usage=q",
        f"--cq-level={args.cq_level}",
        f"--limit={args.frames}",
        f"--width={args.width}",
        f"--height={args.height}",
        f"--fps={fps}/1",
        f"--input-bit-depth={args.bit_depth}",
        f"--bit-depth={args.bit_depth}",
        "--ivf",
        "-o",
        str(output),
        str(source),
    ]


def verify_manifest(manifest: dict, args: argparse.Namespace) -> None:
    checks = {
        "width": args.width,
        "height": args.height,
        "frames": args.frames,
        "cq_level": args.cq_level,
        "bit_depth": args.bit_depth,
    }
    for key, expected in checks.items():
        if manifest.get(key) != expected:
            raise ValueError(f"manifest {key} differs: {manifest.get(key)!r} != {expected!r}")
    videos = manifest.get("videos")
    if not isinstance(videos, list) or len(videos) != len(RECORDS):
        raise ValueError("manifest must contain exactly two videos")
    by_name = {item.get("name"): item for item in videos if isinstance(item, dict)}
    if set(by_name) != {record["name"] for record in RECORDS}:
        raise ValueError("manifest video set differs from the fixed workload")
    for record in RECORDS:
        item = by_name[record["name"]]
        source = Path(args.source_dir) / record["source_filename"]
        stream = Path(args.output_dir) / record["stream_filename"]
        if item.get("fps") != record["fps"]:
            raise ValueError(f"manifest fps differs for {record['name']}")
        if not source.is_file() or source.stat().st_size < frame_bytes(args):
            raise ValueError(f"input video is missing or shorter than {args.frames} frames: {source}")
        if not stream.is_file() or stream.stat().st_size == 0:
            raise ValueError(f"prepared IVF stream is missing or empty: {stream}")
        if item.get("stream_bytes") != stream.stat().st_size:
            raise ValueError(f"prepared IVF stream size differs for {record['name']}")
        if item.get("stream_sha256") != sha256_file(stream):
            raise ValueError(f"prepared IVF stream checksum differs for {record['name']}")
        if item.get("source_sha256") != sha256_file(source):
            raise ValueError(f"input video checksum differs for {record['name']}")
        if item.get("source_bytes") != source.stat().st_size:
            raise ValueError(f"input video size differs for {record['name']}")
    print(f"Input verified: 2 videos, {args.frames} frames each", flush=True)


def main() -> int:
    args = build_parser().parse_args()
    source_dir = Path(args.source_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    manifest_path = Path(args.manifest).resolve()
    log_dir = Path(args.log_dir).resolve()
    if args.verify_only:
        if not manifest_path.is_file():
            raise ValueError(f"input manifest is missing: {manifest_path}")
        verify_manifest(json.loads(manifest_path.read_text(encoding="utf-8")), args)
        return 0

    if not args.encoder:
        raise ValueError("--encoder is required when preparing the input streams")
    encoder = Path(args.encoder).resolve()
    if not encoder.is_file() or not os.access(encoder, os.X_OK):
        raise ValueError(f"aomenc is missing or not executable: {encoder}")
    output_dir.mkdir(parents=True, exist_ok=True)
    log_dir.mkdir(parents=True, exist_ok=True)
    manifest_videos = []
    for record in RECORDS:
        source = source_dir / record["source_filename"]
        output = output_dir / record["stream_filename"]
        if not source.is_file():
            raise ValueError(f"input video is missing: {source}")
        if source.stat().st_size < frame_bytes(args):
            raise ValueError(
                f"input video needs at least {args.frames} frames "
                f"({frame_bytes(args)} bytes): {source}"
            )
        temporary = output.with_suffix(output.suffix + ".part")
        reuse = (
            output.is_file()
            and output.stat().st_size > 0
            and output.stat().st_mtime_ns >= source.stat().st_mtime_ns
        )
        command = command_for(encoder, source, temporary, record["fps"], args)
        logged_command = list(command)
        logged_command[logged_command.index("-o") + 1] = str(output)
        log_path = log_dir / f"{record['name']}.prepare.log"
        if reuse:
            print(f"Input already prepared: {output}", flush=True)
        else:
            temporary.unlink(missing_ok=True)
            with log_path.open("wb") as log_handle:
                result = subprocess.run(
                    command,
                    cwd=output.parent,
                    stdout=log_handle,
                    stderr=subprocess.STDOUT,
                    check=False,
                    timeout=args.timeout,
                )
            if result.returncode != 0:
                lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()[-40:]
                raise ValueError(
                    f"aomenc input encoding failed for {record['name']} with code {result.returncode}"
                    + ("\nencoder log tail:\n" + "\n".join(lines) if lines else "")
                )
            if not temporary.is_file() or temporary.stat().st_size == 0:
                raise ValueError(f"aomenc produced no IVF stream for {record['name']}")
            temporary.replace(output)
            print(f"Input ready: {record['name']} -> {output}", flush=True)
        manifest_videos.append({
            "name": record["name"],
            "source_filename": record["source_filename"],
            "source_path": str(source),
            "source_bytes": source.stat().st_size,
            "source_sha256": sha256_file(source),
            "fps": record["fps"],
            "stream_filename": record["stream_filename"],
            "stream_path": str(output),
            "stream_bytes": output.stat().st_size,
            "stream_sha256": sha256_file(output),
            "command": logged_command,
        })
    manifest = {
        "videos": manifest_videos,
        "frames": args.frames,
        "width": args.width,
        "height": args.height,
        "bit_depth": args.bit_depth,
        "cq_level": args.cq_level,
        "encoder": {
            "path": str(encoder),
            "version": "aom-3.2.0",
            "settings": {
                "codec": "av1",
                "good": True,
                "cpu_used": 8,
                "passes": 1,
                "threads": 1,
                "row_mt": 0,
                "tile_columns": 1,
                "end_usage": "q",
                "cq_level": args.cq_level,
                "limit": args.frames,
                "input_bit_depth": args.bit_depth,
                "bit_depth": args.bit_depth,
            },
        },
        "prepared_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    write_json(manifest_path, manifest)
    verify_manifest(json.loads(manifest_path.read_text(encoding="utf-8")), args)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        raise SystemExit(2)
