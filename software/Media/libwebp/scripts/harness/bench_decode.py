#!/usr/bin/env python3
"""Measure the stock libwebp 1.2.1 lossy decode scenario, without CPU pinning.

Ported from the untouched open-box task material (``Test/libwebp/scripts/bench.py``)
with two deliberate differences:

* the reference confined the measurement to two logical CPUs and one NUMA
  memory node; this harness pins nothing and records the full allowed CPU set
  as evidence;
* inputs, work tree and result paths come from the container mount layout
  instead of the hard-coded ``/home/test/Test`` tree.

Everything else -- the YUV frame-0 conversion, the generated PNG/PPM, the pinned
input digests, ``cwebp -q 85 -m 4``, the golden PAM check, ``dwebp -mt`` and the
20 timed iterations -- matches the reference harness.
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
COMPLETE_MARKER = "LIBWEBP_BENCH_COMPLETE"


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
    """Write the same 8-bit truecolour PNG the reference harness produced.

    The reference streams RGB rows as stored (uncompressed) deflate blocks with
    filter type 0; the exact byte layout is preserved so the pinned PNG digest
    still applies.
    """
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


def write_ppm(path: Path, rgb: bytes) -> None:
    with path.open("wb") as stream:
        stream.write(b"P6\n1920 1080\n255\n")
        for y in range(HEIGHT):
            start = y * WIDTH * 3
            stream.write(rgb[start : start + WIDTH * 3])


def run(command: list[str], env: dict[str, str], timeout: int = 300) -> subprocess.CompletedProcess:
    return subprocess.run(
        command, env=env, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout
    )


def observe_threads(child: subprocess.Popen, deadline_seconds: float) -> int:
    """Watch the measured dwebp process and return the peak thread count."""
    maximum = 0
    deadline = time.monotonic() + deadline_seconds
    while child.poll() is None:
        if time.monotonic() > deadline:
            child.kill()
            raise TimeoutError("dwebp did not finish within the observation window")
        try:
            tasks = list((Path("/proc") / str(child.pid) / "task").iterdir())
        except FileNotFoundError:
            break
        maximum = max(maximum, len(tasks))
        time.sleep(0.0002)
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
    if len(scenarios) != 1:
        return fail(f"manifest must declare exactly one scenario, found {len(scenarios)}")

    scenario = scenarios[0]
    video = videos[scenario["video"]]
    source = args.media_dir / video["filename"]
    if not source.is_file():
        return fail(f"media input is missing: {source}")
    size = source.stat().st_size
    if size != video["bytes"]:
        return fail(f"source size mismatch: {source} is {size}, expected {video['bytes']}")
    source_digest = digest_file(source)
    if source_digest != video["sha256"]:
        return fail(f"source sha256 mismatch: {source} is {source_digest}")

    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.runs_dir.mkdir(parents=True, exist_ok=True)

    cwebp = args.install_dir / "bin" / "cwebp"
    dwebp = args.install_dir / "bin" / "dwebp"
    for binary in (cwebp, dwebp):
        if not binary.is_file():
            return fail(f"binary is missing: {binary}")

    env = os.environ.copy()
    env["LD_LIBRARY_PATH"] = str(args.install_dir / "lib")
    env.pop("OMP_NUM_THREADS", None)

    allowed = sorted(os.sched_getaffinity(0))
    print(f"allowed cpus: {len(allowed)} (not pinned)", flush=True)
    print(f"native threads: {scenario['native_threads']}; 1 warm-up + {args.samples} samples", flush=True)

    rgb = rgb_frame_from_yuv(source)
    rgb_digest = digest_bytes(rgb)
    if rgb_digest != video["rgb_frame0_sha256"]:
        return fail(f"frame-0 RGB conversion mismatch: {rgb_digest}")

    png = args.work_dir / "Film2012.png"
    write_png(png, rgb)
    png_digest = digest_file(png)
    if png_digest != video["png_sha256"]:
        return fail(f"generated PNG mismatch: {png_digest}")

    ppm = args.work_dir / "Film2012.ppm"
    write_ppm(ppm, rgb)
    webp = args.work_dir / (scenario["name"] + ".webp")
    run([str(cwebp), "-quiet", "-q", "85", "-m", "4", str(ppm), "-o", str(webp)], env)
    webp_digest = digest_file(webp)
    if webp_digest != video["webp_sha256"]:
        return fail(f"generated WebP mismatch: {webp_digest}")

    # Correctness: the decoded RGBA PAM must match the pinned golden digest.  This
    # run also acts as the measurement warm-up.
    reference_output = args.work_dir / "reference.pam"
    run([str(dwebp), str(webp), "-quiet", "-pam", "-o", str(reference_output)], env)
    pam_digest = digest_file(reference_output)
    if pam_digest != video["decoded_pam_sha256"]:
        return fail(f"decoded PAM mismatch: {pam_digest}")

    timed = [str(dwebp), str(webp), "-mt", "-quiet", "-pam", "-o", "/dev/null"]
    warmup_log = args.work_dir / "warmup.log"
    observed_threads = 0
    for index in range(args.warmups):
        with warmup_log.open("wb") as log:
            child = subprocess.Popen(timed, env=env, stdout=log, stderr=subprocess.STDOUT)
            observed_threads = max(observed_threads, observe_threads(child, 300))
            if child.wait() != 0:
                return fail("warm-up decode failed")
    if observed_threads != scenario["native_threads"]:
        return fail(
            f"dwebp -mt used {observed_threads} threads, expected {scenario['native_threads']}"
        )

    samples: list[float] = []
    for index in range(args.samples):
        start = time.perf_counter_ns()
        run(timed, env)
        samples.append((time.perf_counter_ns() - start) / 1e6)
        (args.runs_dir / scenario["name"]).mkdir(parents=True, exist_ok=True)
        (args.runs_dir / scenario["name"] / f"rep{index + 1}.json").write_text(
            json.dumps({"scenario": scenario["name"], "rep": index + 1, "ms": samples[-1]}) + "\n",
            encoding="utf-8",
        )

    # Re-run the reference decode once more so the final artifact is the checked one.
    run([str(dwebp), str(webp), "-quiet", "-pam", "-o", str(args.work_dir / "final.pam")], env)
    if digest_file(args.work_dir / "final.pam") != video["decoded_pam_sha256"]:
        return fail("post-measurement decode mismatch")

    mean = statistics.mean(samples)
    median = statistics.median(samples)
    evidence = {
        "scenario": scenario["name"],
        "group": scenario["group"],
        "subgroup": scenario["subgroup"],
        "samples_ms": samples,
        "mean_ms": mean,
        "median_ms": median,
        "iterations": args.samples,
        "warmups": args.warmups,
        "statistic": "median",
        "cpus_allowed": len(allowed),
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "observed_threads": observed_threads,
        "source": {"file": video["filename"], "bytes": size, "sha256": source_digest},
        "png_sha256": png_digest,
        "webp_sha256": webp_digest,
        "decoded_pam_sha256": pam_digest,
        "command": timed,
        "cwebp": {"path": str(cwebp), "options": scenario["encoder_options"]},
    }
    (args.results_dir / "evidence.json").write_text(
        json.dumps(evidence, indent=2, allow_nan=False) + "\n", encoding="utf-8"
    )

    csv_path = args.results_dir / "result_bench-libwebp.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["scenario", "iterations", "ms_per_image", "status"])
        writer.writerow([scenario["name"], args.samples, f"{median:.6f}", "OK"])

    print(f"{scenario['name']:<34} {args.samples:>4} {median:>12.6f} {'OK':>4}", flush=True)
    print(f"mean={mean:.6f} ms/image (reference statistic), median={median:.6f} ms/image (published)")
    print(f"Result: {csv_path}")
    print("Read ms_per_image (milliseconds per image); lower is better.")
    print(COMPLETE_MARKER, flush=True)
    return 0


def fail(message: str) -> int:
    print(f"ERROR: {message}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
