#!/usr/bin/env python3
"""Prepare the AVS3 stream used by the uavs3d decode benchmark.

This mirrors the reference ``Test/uavs3d/scripts/prepare_inputs.py``: the
uavs3e encoder converts the first 120 frames of the supplied YUV material to
an AVS3 bitstream with an 8-thread configuration (4 WPP + 2 frame threads).
Only the file locations and failure reporting are adapted for this case.
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
    parser.add_argument("--source", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--log", default="")
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--frames", type=int, default=120)
    parser.add_argument("--fps", type=int, default=25)
    parser.add_argument("--qp", type=int, default=32)
    parser.add_argument("--bit-depth", type=int, default=8)
    parser.add_argument("--wpp-threads", type=int, default=4)
    parser.add_argument("--frm-threads", type=int, default=2)
    parser.add_argument("--speed-level", type=int, default=4)
    parser.add_argument("--gop", type=int, default=7)
    parser.add_argument("--preset", type=int, default=0)
    parser.add_argument("--timeout", type=int, default=3600)
    parser.add_argument("--verify-only", action="store_true")
    return parser


def expected_source_bytes(args: argparse.Namespace) -> int:
    return args.width * args.height * 3 // 2 * args.frames


def verify_manifest(manifest: dict, args: argparse.Namespace) -> None:
    source = Path(args.source)
    output = Path(args.output)
    checks = {
        "width": args.width,
        "height": args.height,
        "frames": args.frames,
        "fps": args.fps,
        "qp": args.qp,
        "bit_depth": args.bit_depth,
    }
    for key, expected in checks.items():
        if manifest.get(key) != expected:
            raise ValueError(f"manifest {key} differs: {manifest.get(key)!r} != {expected!r}")
    if not source.is_file() or source.stat().st_size < expected_source_bytes(args):
        raise ValueError(f"input video is missing or shorter than {args.frames} frames: {source}")
    if not output.is_file() or output.stat().st_size == 0:
        raise ValueError(f"prepared AVS3 stream is missing or empty: {output}")
    if manifest.get("stream_bytes") != output.stat().st_size:
        raise ValueError("prepared AVS3 stream size differs from the manifest")
    stream_sha256 = sha256_file(output)
    if manifest.get("stream_sha256") != stream_sha256:
        raise ValueError("prepared AVS3 stream checksum differs from the manifest")
    source_sha256 = sha256_file(source)
    if manifest.get("source_sha256") != source_sha256:
        raise ValueError("input video checksum differs from the manifest")
    if manifest.get("source_bytes") != source.stat().st_size:
        raise ValueError("input video size differs from the manifest")
    print(
        f"Input verified: {manifest.get('name')} "
        f"({args.frames} frames, stream {manifest['stream_sha256']})",
        flush=True,
    )


def main() -> int:
    args = build_parser().parse_args()
    source = Path(args.source).resolve()
    output = Path(args.output).resolve()
    manifest_path = Path(args.manifest).resolve()
    if args.verify_only:
        if not manifest_path.is_file():
            raise ValueError(f"input manifest is missing: {manifest_path}")
        verify_manifest(json.loads(manifest_path.read_text(encoding="utf-8")), args)
        return 0

    if not args.encoder:
        raise ValueError("--encoder is required when preparing the input stream")
    encoder = Path(args.encoder).resolve()
    if not encoder.is_file() or not os.access(encoder, os.X_OK):
        raise ValueError(f"uavs3e encoder is missing or not executable: {encoder}")
    if not source.is_file():
        raise ValueError(f"input video is missing: {source}")
    if source.stat().st_size < expected_source_bytes(args):
        raise ValueError(
            f"input video needs at least {args.frames} frames "
            f"({expected_source_bytes(args)} bytes): {source}"
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".part")
    reuse = (
        output.is_file()
        and output.stat().st_size > 0
        and output.stat().st_mtime_ns >= source.stat().st_mtime_ns
    )
    command = [
        str(encoder),
        "-i", str(source),
        "-o", str(temporary),
        "-w", str(args.width),
        "-h", str(args.height),
        "-d", str(args.bit_depth),
        "--fps_num", str(args.fps),
        "--fps_den", "1",
        "-f", str(args.frames),
        "-q", str(args.qp),
        "-g", str(args.gop),
        "-p", str(args.preset),
        "--speed_level", str(args.speed_level),
        "--wpp_threads", str(args.wpp_threads),
        "--frm_threads", str(args.frm_threads),
        "-s", "1",
        "-v", "0",
    ]
    logged_command = list(command)
    logged_command[logged_command.index("-o") + 1] = str(output)
    log_path = Path(args.log).resolve() if args.log else None
    if reuse:
        print(f"Input already prepared: {output}", flush=True)
    else:
        temporary.unlink(missing_ok=True)
        log_handle = None
        if log_path is not None:
            log_path.parent.mkdir(parents=True, exist_ok=True)
            log_handle = log_path.open("wb")
        try:
            result = subprocess.run(
                command,
                # Upstream uavs3enc writes psnr.txt relative to its working directory.
                cwd=output.parent,
                stdout=log_handle if log_handle is not None else subprocess.DEVNULL,
                stderr=subprocess.STDOUT,
                check=False,
                timeout=args.timeout,
            )
        finally:
            if log_handle is not None:
                log_handle.close()
        if result.returncode != 0:
            tail = ""
            if log_path is not None and log_path.is_file():
                lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
                tail = "\n".join(lines[-40:])
            message = f"uavs3e input encoding failed with code {result.returncode}"
            if tail:
                message = f"{message}\nencoder log tail:\n{tail}"
            raise ValueError(message)
        if not temporary.is_file() or temporary.stat().st_size == 0:
            raise ValueError("uavs3e produced no AVS3 stream")
        temporary.replace(output)
        print(f"Input ready: {output}", flush=True)

    manifest = {
        "name": "Film2012",
        "source_filename": source.name,
        "source_path": str(source),
        "source_bytes": source.stat().st_size,
        "source_sha256": sha256_file(source),
        "frames": args.frames,
        "width": args.width,
        "height": args.height,
        "fps": args.fps,
        "qp": args.qp,
        "bit_depth": args.bit_depth,
        "stream_filename": output.name,
        "stream_path": str(output),
        "stream_bytes": output.stat().st_size,
        "stream_sha256": sha256_file(output),
        "encoder": {
            "path": str(encoder),
            "version": "uavs3e-1.3",
            "settings": {
                "wpp_threads": args.wpp_threads,
                "frm_threads": args.frm_threads,
                "speed_level": args.speed_level,
                "gop": args.gop,
                "preset": args.preset,
                "fps_num": args.fps,
                "fps_den": 1,
            },
            "command": logged_command,
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
