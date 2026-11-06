#!/usr/bin/env python3
"""Measure the stock libavif 0.9.3 + AOM 3.2.0 encode scenarios, without pinning.

Ported from the untouched open-box task material (``Test/libavif/scripts/bench.py``)
with two deliberate differences:

* the reference confined the encoder to eight logical CPUs and one NUMA memory
  node (CPU affinity plus NUMA memory binding); this harness pins nothing and
  records the full allowed CPU set plus the observed native thread count as
  evidence;
* inputs and output paths come from the container mount layout instead of the
  hard-coded ``/home/test/Test`` tree.

Everything else -- the YUV frame-0 conversion, the pinned PNG digests, the
`avifenc` parameter set (AOM, YUV420, speed 8, 8 jobs, 1x4 tiles, QP 20/32), the
20 timed iterations, the encoded-payload and decoded-pixel stability checks and
the linkage checks -- matches the reference harness.
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


def digest_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


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


def run(command: list[str], env: dict[str, str], timeout: int = 300) -> float:
    started = time.perf_counter_ns()
    result = subprocess.run(
        command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout
    )
    elapsed = (time.perf_counter_ns() - started) / 1e6
    if result.returncode:
        raise ValueError(result.stdout.decode(errors="replace")[-2000:])
    return elapsed


def run_traced(command: list[str], env: dict[str, str], deadline_seconds: float = 300) -> int:
    """Run one encode while observing its peak thread count, return the peak."""
    started = time.perf_counter_ns()
    child = subprocess.Popen(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    maximum = 0
    while child.poll() is None:
        if time.perf_counter_ns() - started > deadline_seconds * 1e9:
            child.kill()
            child.communicate()
            raise ValueError("encode warm-up timed out")
        try:
            status = (Path("/proc") / str(child.pid) / "status").read_text()
            threads = int(
                next(line.split()[1] for line in status.splitlines() if line.startswith("Threads:"))
            )
            maximum = max(maximum, threads)
        except (OSError, StopIteration):
            pass
        time.sleep(0.002)
    text = child.communicate()[0]
    if child.returncode:
        raise ValueError(text.decode(errors="replace")[-2000:])
    return maximum


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

    allowed = sorted(os.sched_getaffinity(0))
    print(f"allowed cpus: {len(allowed)} (not pinned)", flush=True)
    print(
        f"native encoding threads: {native_threads}; "
        f"1 warm-up + {args.samples} samples per scenario",
        flush=True,
    )

    prepared: dict[str, Path] = {}
    for name, video in videos.items():
        source = args.media_dir / video["filename"]
        if not source.is_file():
            return fail(f"media input is missing: {source}")
        size = source.stat().st_size
        if size != video["bytes"]:
            return fail(f"source size mismatch: {source} is {size}, expected {video['bytes']}")
        source_digest = digest_file(source)
        if source_digest != video["sha256"]:
            return fail(f"source sha256 mismatch: {source} is {source_digest}")
        image = args.work_dir / (name + ".png")
        rgb = rgb_frame_from_yuv(source)
        write_png(image, rgb)
        png_digest = digest_file(image)
        if png_digest != video["png_sha256"]:
            return fail(f"generated PNG mismatch for {name}: {png_digest}")
        prepared[name] = image
        print(f"prepared {name}: {image.name} ({png_digest[:12]})", flush=True)

    csv_path = args.results_dir / "result_bench-libavif.csv"
    evidence: dict = {
        "cpus_allowed": len(allowed),
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": native_threads,
        "warmups": args.warmups,
        "samples": args.samples,
        "statistic": "median",
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
            command = (
                [str(encoder)]
                + encoder_options
                + ["--min", str(scenario["qp"]), "--max", str(scenario["qp"])]
                + [str(image), str(encoded)]
            )
            try:
                observed_threads = run_traced(command, env)
                if observed_threads != native_threads:
                    raise ValueError(
                        f"encoder used {observed_threads} threads, expected {native_threads}"
                    )
                expected_encoded = digest_file(encoded)
                run([str(decoder), "--ignore-icc", str(encoded), str(decoded)], env)
                expected_decoded = digest_file(decoded)
                samples = []
                for index in range(args.samples):
                    samples.append(run(command, env))
                    if digest_file(encoded) != expected_encoded:
                        raise ValueError("repeated encoding output differs")
                    (args.runs_dir / name).mkdir(parents=True, exist_ok=True)
                    (args.runs_dir / name / f"rep{index + 1}.json").write_text(
                        json.dumps({"scenario": name, "rep": index + 1, "ms": samples[-1]}) + "\n",
                        encoding="utf-8",
                    )
                run([str(decoder), "--ignore-icc", str(encoded), str(decoded)], env)
                if digest_file(decoded) != expected_decoded:
                    raise ValueError("repeated decoded pixels differ")
                median = statistics.median(samples)
                evidence["cases"][name] = {
                    "group": scenario["group"],
                    "subgroup": scenario["subgroup"],
                    "qp": scenario["qp"],
                    "samples_ms": samples,
                    "mean_ms": statistics.mean(samples),
                    "median_ms": median,
                    "encoded_sha256": expected_encoded,
                    "decoded_yuv_sha256": expected_decoded,
                    "observed_threads": observed_threads,
                }
                writer.writerow([name, args.samples, f"{median:.6f}", "OK"])
                print(f"{name:<26} {args.samples:>10} {median:>14.6f} {'OK':>6}", flush=True)
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
