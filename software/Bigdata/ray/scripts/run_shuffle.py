#!/usr/bin/env python3
"""Run upstream Ray's shuffle_test.py on one private local Ray node."""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import signal
import statistics
import subprocess
import sys
import threading
from pathlib import Path


CPUS = 16
PARTITIONS = 50
PARTITION_SIZE = 80_000_000
OBJECT_STORE_BYTES = 16 * 1024**3
WARMUPS = 1
FORMAL_ROUNDS = 7
ROUND_TIMEOUT = 1800


def parse_round(path: Path) -> float:
    payload = json.loads(path.read_text(encoding="utf-8"))
    values = payload.get("perf_metrics")
    if not isinstance(values, list) or len(values) != 1:
        raise ValueError(f"{path}: official perf_metrics must contain one item")
    metric = values[0]
    value = payload.get("shuffle_time")
    if (metric.get("perf_metric_name") != "shuffle_time"
            or metric.get("perf_metric_type") != "LATENCY"
            or metric.get("perf_metric_value") != value):
        raise ValueError(f"{path}: official shuffle_time fields disagree")
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or value <= 0:
        raise ValueError(f"{path}: shuffle_time is not positive and finite")
    return float(value)


def run_round(script: Path, output: Path, log, address: str, index: int, warmup: bool) -> float:
    label = "warmup" if warmup else "formal"
    print(f"[ray] {label} round {index} starting", flush=True)
    log.write(f"\n===== {label} round {index} =====\n")
    log.flush()
    env = os.environ.copy()
    env["PATH"] = f"{Path(sys.executable).parent}:{env.get('PATH', '')}"
    env["VIRTUAL_ENV"] = str(Path(sys.executable).parent.parent)
    env["RAY_ADDRESS"] = address
    env["TEST_OUTPUT_JSON"] = str(output)
    env["RAY_memory_monitor_refresh_ms"] = "0"
    command = [sys.executable, str(script), "--num-partitions", str(PARTITIONS),
               "--partition-size", str(PARTITION_SIZE)]
    with subprocess.Popen(command, env=env, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, bufsize=1,
                          start_new_session=True) as process:
        assert process.stdout is not None

        def stream_output() -> None:
            for line in process.stdout:
                log.write(line)
                log.flush()
                print(line, end="", flush=True)

        reader = threading.Thread(target=stream_output, daemon=True)
        reader.start()
        try:
            code = process.wait(timeout=ROUND_TIMEOUT)
        except subprocess.TimeoutExpired as exc:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            raise RuntimeError(f"{label} round {index} exceeded {ROUND_TIMEOUT}s") from exc
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
            reader.join(timeout=10)
    if code != 0:
        raise RuntimeError(f"{label} round {index} failed with exit code {code}")
    value = parse_round(output)
    print(f"[ray] {label} round {index}: {value:.3f} s", flush=True)
    return value


def run(script: Path, work_dir: Path, result_dir: Path) -> dict:
    os.environ["RAY_memory_monitor_refresh_ms"] = "0"
    import ray

    work_dir.mkdir(parents=True, exist_ok=True)
    result_dir.mkdir(parents=True, exist_ok=True)
    rounds_dir = result_dir / "shuffle-rounds"
    rounds_dir.mkdir(exist_ok=True)
    ray_temp = work_dir / "ray-temp"
    ray_temp.mkdir(exist_ok=True)
    raw_log = result_dir / "benchmark_ray_raw.log"
    measurements = []
    try:
        context = ray.init(address="local", num_cpus=CPUS, resources={"node": 1},
                           object_store_memory=OBJECT_STORE_BYTES,
                           _temp_dir=str(ray_temp), include_dashboard=False,
                           logging_level="ERROR")
        address = context.address_info["address"]
        with raw_log.open("w", encoding="utf-8") as log:
            for index in range(1, WARMUPS + FORMAL_ROUNDS + 1):
                warmup = index <= WARMUPS
                output = rounds_dir / f"round-{index:02d}.json"
                value = run_round(script, output, log, address, index, warmup)
                measurements.append({"round": index, "warmup": warmup,
                                     "included": not warmup, "shuffle_time_s": value})
    finally:
        ray.shutdown()
    formal = [row["shuffle_time_s"] for row in measurements if row["included"]]
    if len(formal) != FORMAL_ROUNDS:
        raise ValueError(f"expected {FORMAL_ROUNDS} formal rounds, got {len(formal)}")
    median = statistics.median(formal)
    return {
        "parameters": {"suite": "official-ray-shuffle-single-node-g5",
                       "ray_version": ray.__version__, "nodes": 1, "num_cpus": CPUS,
                       "num_partitions": PARTITIONS, "partition_size_bytes": PARTITION_SIZE,
                       "object_store_bytes": OBJECT_STORE_BYTES,
                       "warmup_rounds": WARMUPS, "formal_rounds": FORMAL_ROUNDS},
        "runtime_context": {"architecture": platform.machine(),
                            "available_cpus": os.cpu_count()},
        "measurements": measurements,
        "results": {"shuffle_time": median},
    }


def main() -> int:
    def interrupt(_signum: int, _frame: object) -> None:
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, interrupt)
    parser = argparse.ArgumentParser()
    parser.add_argument("--shuffle-script", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--results-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        payload = run(args.shuffle_script, args.work_dir, args.results_dir)
        target = args.results_dir / "benchmark_ray.json"
        target.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"[ray] ERROR: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("[ray] ERROR: benchmark interrupted", file=sys.stderr)
        return 130
    print(f"[ray] official Shuffle median over {FORMAL_ROUNDS} rounds: {payload['results']['shuffle_time']:.3f} s")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
