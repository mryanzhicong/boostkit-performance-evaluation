#!/usr/bin/env python3
"""Measure the stock libavif 0.9.3 + AOM 3.2.0 encode scenarios, without pinning.

Ported from the current open-box task material (``Test/libavif/scripts/bench.py``
at ``6c69c13d``, "Simplify benchmark deployment and runtime checks").  The
measurement recipe is kept as-is:

* frame 0 of three 1920x1080 clips is converted to a PNG and encoded at QP 20
  and QP 32 with ``avifenc --codec aom --yuv 420 --speed 8 --jobs 8`` and a
  1x4 tile layout;
* nothing is pinned -- no CPU affinity, no NUMA memory binding -- so the
  operating system schedules the encoder freely;
* one warm-up encode plus one warm-up decode establish the reference payload;
  their sha256 digests are recorded as evidence only (they are not compared
  against later iterations);
* the encoder thread count is not observed or asserted; the manifest-declared
  value is recorded as documentation;
* the timed iterations are plain encodes; the reported statistic is the mean.

Only two things differ from the reference harness: paths come from the container
mount layout instead of the hard-coded ``/home/test/Test`` tree, and each video
may be archived on a runner under an alternate file name (the BQTerrace clip is
published as ``...-dianbo.yuv`` but the runner archive keeps the older name).
"""

from __future__ import annotations

import argparse
import binascii
import csv
import hashlib
import json
import os
import statistics
import struct
import subprocess
import sys
import time
import zlib
from pathlib import Path

WIDTH, HEIGHT = 1920, 1080
FRAME_BYTES = WIDTH * HEIGHT * 3 // 2
COMPLETE_MARKER = "LIBAVIF_BENCH_COMPLETE"
DECODER_TIMEOUT = 300


def digest_file(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def png_chunk(stream, kind: bytes, data: bytes) -> None:
    stream.write(struct.pack(">I", len(data)) + kind + data)
    stream.write(struct.pack(">I", binascii.crc32(kind + data) & 0xFFFFFFFF))


def rgb_frame_from_yuv(path: Path) -> bytes:
    """Return the RGB24 rendering of frame 0 using the reference BT.601 path."""
    with path.open("rb") as stream:
        raw = stream.read(FRAME_BYTES)
    y_plane = raw[: WIDTH * HEIGHT]
    u_plane = raw[WIDTH * HEIGHT : WIDTH * HEIGHT * 5 // 4]
    v_plane = raw[WIDTH * HEIGHT * 5 // 4 :]
    output = bytearray(WIDTH * HEIGHT * 3)
    for y in range(HEIGHT):
        row = y * WIDTH
        for x in range(WIDTH):
            c = max(y_plane[row + x] - 16, 0)
            index = (y // 2) * (WIDTH // 2) + x // 2
            u = u_plane[index] - 128
            v = v_plane[index] - 128
            values = (
                (298 * c + 409 * v + 128) >> 8,
                (298 * c - 100 * u - 208 * v + 128) >> 8,
                (298 * c + 516 * u + 128) >> 8,
            )
            offset = (row + x) * 3
            for position, value in enumerate(values):
                output[offset + position] = 0 if value < 0 else (255 if value > 255 else value)
    return bytes(output)


def write_png(path: Path, rgb: bytes) -> None:
    """Write the same 8-bit truecolour PNG the reference harness produced."""
    with path.open("wb") as stream:
        stream.write(b"\x89PNG\r\n\x1a\n")
        png_chunk(stream, b"IHDR", struct.pack(">IIBBBBB", WIDTH, HEIGHT, 8, 2, 0, 0, 0))
        png_chunk(stream, b"IDAT", b"\x78\x01")
        checksum = 1
        for y in range(HEIGHT):
            start = y * WIDTH * 3
            row = b"\x00" + rgb[start : start + WIDTH * 3]
            checksum = zlib.adler32(row, checksum)
            png_chunk(stream, b"IDAT", b"\0" + struct.pack("<HH", len(row), 65535 - len(row)) + row)
        png_chunk(stream, b"IDAT", b"\x01\x00\x00\xff\xff" + struct.pack(">I", checksum & 0xFFFFFFFF))
        png_chunk(stream, b"IEND", b"")


def resolve_video(media_dir: Path, name: str, video: dict) -> Path:
    """Return the first archived file name for a video, in declared order."""
    candidates = [video["filename"]] + list(video.get("alternate_filenames") or [])
    for candidate in candidates:
        path = media_dir / candidate
        if path.is_file():
            return path
    raise ValueError(
        f"media input is missing for {name}; looked for: "
        + ", ".join(str(media_dir / candidate) for candidate in candidates)
    )


def prepare_image(source: Path, work_dir: Path, name: str) -> Path:
    """Slice frame 0 of the YUV source into the PNG the encoder consumes."""
    source_size = source.stat().st_size
    if source_size < FRAME_BYTES:
        raise ValueError(
            f"input video is too short: {source} is {source_size} bytes, "
            f"need at least {FRAME_BYTES}"
        )
    image = work_dir / (name + ".png")
    if image.is_file() and image.stat().st_size > 0 and image.stat().st_mtime_ns >= source.stat().st_mtime_ns:
        print(f"reusing prepared image: {image.name}", flush=True)
        return image
    write_png(image, rgb_frame_from_yuv(source))
    print(f"prepared {name}: {image.name} (sha256 {digest_file(image)[:12]})", flush=True)
    return image


def run(command: list[str], env: dict[str, str], timeout: int = DECODER_TIMEOUT) -> float:
    started = time.perf_counter_ns()
    result = subprocess.run(
        command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout
    )
    elapsed = (time.perf_counter_ns() - started) / 1e6
    if result.returncode:
        raise ValueError(result.stdout.decode(errors="replace")[-2000:])
    return elapsed


def allowed_cpu_count() -> int:
    """Count the CPUs this process may run on, without pinning anything."""
    try:
        allowed = os.sched_getaffinity(0)
    except (AttributeError, OSError):
        return os.cpu_count() or 1
    return len(allowed)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--media-dir", required=True, type=Path)
    parser.add_argument("--install-dir", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--results-dir", required=True, type=Path)
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--samples", type=int, default=20)
    args = parser.parse_args(argv)

    if args.warmups < 1 or args.samples < 5:
        return fail("sampling contract requires >=1 warm-up and >=5 samples")

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    videos = manifest["videos"]
    scenarios = manifest["scenarios"]
    native_threads = int(manifest["native_threads"])
    encoder_options = list(manifest["encoder_options"])

    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.runs_dir.mkdir(parents=True, exist_ok=True)

    encoder = args.install_dir / "bin" / "avifenc"
    decoder = args.install_dir / "bin" / "avifdec"
    for binary in (encoder, decoder):
        if not binary.is_file():
            return fail(f"binary is missing: {binary}")

    env = os.environ.copy()
    env["LD_LIBRARY_PATH"] = str(args.install_dir / "lib") + ":" + env.get("LD_LIBRARY_PATH", "")
    env.update({"OMP_NUM_THREADS": "1", "OMP_THREAD_LIMIT": "1", "LC_ALL": "C"})

    cpus_allowed = allowed_cpu_count()
    print(f"CPU affinity: unbound; allowed cpus: {cpus_allowed}", flush=True)
    print(
        f"native encoding threads: {native_threads} (declared); "
        f"{args.warmups} warm-up(s) + {args.samples} timed samples per scenario",
        flush=True,
    )

    prepared: dict[str, Path] = {}
    for name, video in videos.items():
        source = resolve_video(args.media_dir, name, video)
        print(f"media input {name}: {source.name}", flush=True)
        prepared[name] = prepare_image(source, args.work_dir, name)

    csv_path = args.results_dir / "result_bench-libavif.csv"
    evidence: dict = {
        "cpus_allowed": cpus_allowed,
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "affinity": "unbound",
        "native_threads": native_threads,
        "warmups": args.warmups,
        "samples": args.samples,
        "statistic": "mean",
        "source_mode": "unpatched",
        "cases": {},
    }
    failures = 0
    print(f"{'scenario':<26} {'iterations':>10} {'ms/image':>14} {'status':>6}", flush=True)
    with csv_path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["scenario", "iterations", "ms_per_image", "status"])
        for scenario in scenarios:
            name = scenario["name"]
            image = prepared[scenario["video"]]
            encoded = args.work_dir / (name + ".avif")
            decoded = args.work_dir / (name + ".y4m")
            decode_command = [str(decoder), "--ignore-icc", str(encoded), str(decoded)]
            command = (
                [str(encoder)]
                + encoder_options
                + ["--min", str(scenario["qp"]), "--max", str(scenario["qp"])]
                + [str(image), str(encoded)]
            )
            try:
                # Warm-up: one untimed encode and one decode establish the
                # reference payload.  Their digests are recorded, never compared.
                for _ in range(args.warmups):
                    run(command, env)
                encoded_sha256 = digest_file(encoded)
                run(decode_command, env)
                decoded_yuv_sha256 = digest_file(decoded)

                samples = []
                for index in range(args.samples):
                    samples.append(run(command, env))
                    (args.runs_dir / name).mkdir(parents=True, exist_ok=True)
                    (args.runs_dir / name / f"rep{index + 1}.json").write_text(
                        json.dumps({"scenario": name, "rep": index + 1, "ms": samples[-1]}) + "\n",
                        encoding="utf-8",
                    )
                # Leave a final decoded artifact behind; no digest comparison.
                run(decode_command, env)

                mean = statistics.mean(samples)
                evidence["cases"][name] = {
                    "group": scenario["group"],
                    "subgroup": scenario["subgroup"],
                    "qp": scenario["qp"],
                    "samples_ms": samples,
                    "mean_ms": mean,
                    "encoded_sha256": encoded_sha256,
                    "decoded_yuv_sha256": decoded_yuv_sha256,
                }
                writer.writerow([name, args.samples, f"{mean:.6f}", "OK"])
                print(f"{name:<26} {args.samples:>10} {mean:>14.6f} {'OK':>6}", flush=True)
            except (OSError, ValueError, subprocess.SubprocessError) as error:
                failures += 1
                evidence["cases"][name] = {"status": "FAIL", "error": str(error)}
                writer.writerow([name, args.samples, "", "FAIL"])
                print(f"{name:<26} {args.samples:>10} {'-':>14} {'FAIL':>6}", file=sys.stderr)
                print(f"ERROR: {name}: {error}", file=sys.stderr, flush=True)
            stream.flush()

    (args.results_dir / "evidence.json").write_text(
        json.dumps(evidence, indent=2, allow_nan=False) + "\n", encoding="utf-8"
    )
    print(f"Result: {csv_path}")
    print("Read ms_per_image (milliseconds per image); lower is better.")
    if failures:
        print(f"ERROR: {failures} scenario(s) failed", file=sys.stderr)
        return 1
    print(COMPLETE_MARKER, flush=True)
    return 0


def fail(message: str) -> int:
    print(f"ERROR: {message}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
