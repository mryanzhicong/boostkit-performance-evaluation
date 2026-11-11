#!/usr/bin/env python3
"""Measure cv2.norm(gray, cv2.NORM_L1) on 1920x1080 frame-0 luma, without pinning.

Ported from the untouched open-box task material (``Test/opencv/scripts/bench.py``)
with these deliberate differences:

* the reference locked the process to a single logical CPU and bound memory to
  one NUMA node; this harness pins nothing and records the full allowed CPU set
  plus every API-level setting it applies as evidence;
* inputs and output paths come from the container mount layout instead of the
  hard-coded ``/home/test/Test`` tree.

Everything else -- the pinned frame-0/RGB digests, the BT.601 conversion, the
``cv2.norm(gray, cv2.NORM_L1)`` workload, the 5 warm-up calls, 20 samples of 500
calls, the result cross-check against ``gray.sum()``, the build-information
assertions (no OpenMP, parallel framework none, no IPP, no OpenCL) and the
single-threaded ``cv2.setNumThreads(1)`` setting -- matches the reference.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import statistics
import sys
import time
from pathlib import Path

WIDTH, HEIGHT = 1920, 1080
FRAME_BYTES = WIDTH * HEIGHT * 3 // 2
COMPLETE_MARKER = "OPENCV_BENCH_COMPLETE"


def digest_file(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def load_media(args: argparse.Namespace) -> list[tuple[str, dict, bytes, str]]:
    import numpy as np

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    prepared = []
    for name, video in manifest["videos"].items():
        source = args.media_dir / video["filename"]
        if not source.is_file():
            raise ValueError(f"media input is missing: {source}")
        size = source.stat().st_size
        if size != video["bytes"]:
            raise ValueError(f"source size mismatch: {source} is {size}, expected {video['bytes']}")
        if digest_file(source) != video["sha256"]:
            raise ValueError(f"source sha256 mismatch: {source}")
        with source.open("rb") as stream:
            raw = stream.read(FRAME_BYTES)
        if hashlib.sha256(raw).hexdigest() != video["frame0_sha256"]:
            raise ValueError(f"frame 0 digest mismatch for {name}")
        data = np.frombuffer(raw, np.uint8)
        y = data[: WIDTH * HEIGHT].reshape(HEIGHT, WIDTH).astype(np.int32)
        u = (
            data[WIDTH * HEIGHT : WIDTH * HEIGHT * 5 // 4]
            .reshape(HEIGHT // 2, WIDTH // 2)
            .repeat(2, 0)
            .repeat(2, 1)
            .astype(np.int32)
            - 128
        )
        v = (
            data[WIDTH * HEIGHT * 5 // 4 :]
            .reshape(HEIGHT // 2, WIDTH // 2)
            .repeat(2, 0)
            .repeat(2, 1)
            .astype(np.int32)
            - 128
        )
        c = np.maximum(y - 16, 0)
        image = np.clip(
            np.stack(
                (
                    (298 * c + 409 * v + 128) >> 8,
                    (298 * c - 100 * u - 208 * v + 128) >> 8,
                    (298 * c + 516 * u + 128) >> 8,
                ),
                axis=2,
            ),
            0,
            255,
        ).astype(np.uint8)
        if hashlib.sha256(image.tobytes()).hexdigest() != video["rgb_sha256"]:
            raise ValueError(f"RGB conversion mismatch for {name}")
        prepared.append((name, video, raw[: WIDTH * HEIGHT], hashlib.sha256(raw).hexdigest()))
        print(f"prepared {name}: gray8 frame 0 verified", flush=True)
    return prepared


def check_build(cv2, install_dir: Path, manifest: dict) -> str:
    if str(install_dir) not in cv2.__file__:
        raise ValueError(f"cv2 was imported from {cv2.__file__}, expected the private prefix")
    build = cv2.getBuildInformation()
    if "-fopenmp" in build:
        raise ValueError("OpenCV was built with OpenMP")
    parallel = [
        line for line in build.splitlines() if "Parallel framework:" in line
    ]
    if not parallel or "none" not in parallel[0].lower():
        raise ValueError(f"unexpected parallel framework: {parallel}")
    if cv2.ipp.useIPP():
        raise ValueError("IPP must be disabled")
    cv2.setNumThreads(int(manifest["native_threads"]))
    cv2.ocl.setUseOpenCL(False)
    return build


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--media-dir", required=True, type=Path)
    parser.add_argument("--install-dir", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--results-dir", required=True, type=Path)
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--warmups", type=int, default=5)
    parser.add_argument("--samples", type=int, default=20)
    parser.add_argument("--calls", type=int, default=500)
    args = parser.parse_args(argv)

    if args.warmups < 1 or args.samples < 5 or args.calls < 1:
        print("ERROR: sampling contract requires >=1 warm-up, >=5 samples and >=1 call",
              file=sys.stderr)
        return 1

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.runs_dir.mkdir(parents=True, exist_ok=True)

    os.environ.update(OMP_NUM_THREADS="1", OMP_THREAD_LIMIT="1", OPENBLAS_NUM_THREADS="1")
    sys.path.insert(0, str(args.install_dir / "python"))
    import cv2  # noqa: E402  (must be imported after the prefix is on sys.path)
    import numpy as np  # noqa: E402

    try:
        build = check_build(cv2, args.install_dir, manifest)
        prepared = load_media(args)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    allowed = sorted(os.sched_getaffinity(0))
    print(f"cv2 {cv2.__version__}; allowed cpus: {len(allowed)} (not pinned)", flush=True)
    print(
        f"native threads: {manifest['native_threads']}; {args.warmups} warm-up calls; "
        f"{args.samples} samples x {args.calls} calls",
        flush=True,
    )

    evidence: dict = {
        "version": cv2.__version__,
        "build": build,
        "source_mode": "unpatched",
        "cpus_allowed": len(allowed),
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": int(manifest["native_threads"]),
        "warmups": args.warmups,
        "samples": args.samples,
        "calls_per_sample": args.calls,
        "statistic": "median",
        "cases": {},
    }
    csv_path = args.results_dir / "result_bench-opencv.csv"
    failures = 0
    print(f"{'scenario':<30} {'calls':>10} {'ms/call':>14} {'status':>6}", flush=True)
    with csv_path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["scenario", "iterations", "ms_per_call", "status"])
        for video_key, video, gray_data, frame_digest in prepared:
            name = video_key + "_norm_l1_gray8"
            scenario = next(item for item in manifest["scenarios"] if item["video"] == video_key)
            gray = np.frombuffer(gray_data, np.uint8).reshape(HEIGHT, WIDTH)
            try:
                expected = cv2.norm(gray, cv2.NORM_L1)
                if expected != float(gray.sum(dtype=np.uint64)):
                    raise ValueError("cv2.norm does not match the reference sum")
                for _ in range(args.warmups):
                    cv2.norm(gray, cv2.NORM_L1)
                samples = []
                for index in range(args.samples):
                    started = time.perf_counter_ns()
                    for _ in range(args.calls):
                        cv2.norm(gray, cv2.NORM_L1)
                    samples.append((time.perf_counter_ns() - started) / 1e6 / args.calls)
                    (args.runs_dir / name).mkdir(parents=True, exist_ok=True)
                    (args.runs_dir / name / f"rep{index + 1}.json").write_text(
                        json.dumps({"scenario": name, "rep": index + 1, "ms_per_call": samples[-1]})
                        + "\n",
                        encoding="utf-8",
                    )
                if cv2.norm(gray, cv2.NORM_L1) != expected:
                    raise ValueError("cv2.norm result changed during the measurement")
                median = statistics.median(samples)
                evidence["cases"][name] = {
                    "group": scenario["group"],
                    "subgroup": scenario["subgroup"],
                    "samples_ms": samples,
                    "mean_ms": statistics.mean(samples),
                    "median_ms": median,
                    "output": expected,
                    "input_sha256": hashlib.sha256(gray_data).hexdigest(),
                    "frame0_sha256": frame_digest,
                    "rgb_sha256": video["rgb_sha256"],
                }
                writer.writerow([name, args.calls * args.samples, f"{median:.6f}", "OK"])
                print(f"{name:<30} {args.calls * args.samples:>10} {median:>14.6f} {'OK':>6}",
                      flush=True)
            except (OSError, ValueError) as error:
                failures += 1
                evidence["cases"][name] = {"status": "FAIL", "error": str(error)}
                writer.writerow([name, args.calls * args.samples, "", "FAIL"])
                print(f"{name:<30} {args.calls * args.samples:>10} {'-':>14} {'FAIL':>6}",
                      file=sys.stderr)
                print(f"ERROR: {name}: {error}", file=sys.stderr, flush=True)
            stream.flush()

    (args.results_dir / "evidence.json").write_text(
        json.dumps(evidence, indent=2, allow_nan=False) + "\n", encoding="utf-8"
    )
    print(f"Result: {csv_path}")
    print("Read ms_per_call (milliseconds per call); lower is better.")
    if failures:
        print(f"ERROR: {failures} scenario(s) failed", file=sys.stderr)
        return 1
    print(COMPLETE_MARKER, flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
