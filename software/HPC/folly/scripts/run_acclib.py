#!/usr/bin/env python3
"""Run the local AccLibBenchmark RPC matrix against an upstream Folly stack."""

from __future__ import annotations

import importlib.util
import itertools
import hashlib
import json
import math
import re
import shlex
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


NUMERIC_FIELDS = (
    ("Throughput", "MB/s", "higher_is_better"),
    ("latencyAvg", "us", "lower_is_better"),
    ("latencyP99", "us", "lower_is_better"),
    ("Client CPU (%)", "%", "neutral"),
    ("Server CPU (%)", "%", "neutral"),
)


def load_original_driver(path: Path):
    spec = importlib.util.spec_from_file_location("acclib_original_run", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load AccLibBenchmark run.py: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    if not module.DATA_SETUPS or not module.CONN_SETUPS or not module.QD_SETUPS:
        raise RuntimeError("AccLibBenchmark run.py has an empty test matrix")
    return module


def client_base(original, binary: Path, port: int) -> list[str]:
    prefix = list(original.PREFIX_CMD)
    if len(prefix) < 5 or prefix[:3] != ["numactl", "-N", "0"]:
        raise RuntimeError("unexpected AccLibBenchmark run.py command prefix")
    if prefix[3] != original.EXECUTABLE:
        raise RuntimeError("AccLibBenchmark executable declaration differs from its prefix")
    # Only the launch location, NUMA binding, network endpoint and disabled
    # io_uring flag change for a single-machine, cross-architecture comparison.
    args = [str(binary)]
    for arg in prefix[4:]:
        if arg.startswith("--host="):
            arg = "--host=127.0.0.1"
        elif arg.startswith("--port="):
            arg = f"--port={port}"
        elif arg.startswith("--use_io_uring="):
            arg = "--use_io_uring=false"
        args.append(arg)
    for name in ("--host=", "--port=", "--test_seconds=", "--transport="):
        if sum(arg.startswith(name) for arg in args) != 1:
            raise RuntimeError(f"AccLibBenchmark prefix needs exactly one {name} option")
    return args


def measurement_rows(output: str, original) -> dict[str, float]:
    parsed = original.parse_output(output)
    success = re.search(r"\bSuccess:\s*(\d+)\b", output)
    fail = re.search(r"\bFail:\s*(\d+)\b", output)
    qps = re.search(r"\bQPS:\s*([0-9]+(?:\.[0-9]+)?)\b", output)
    if not success or not fail or not qps:
        raise RuntimeError("press_client omitted Success, Fail or QPS")
    if int(success.group(1)) <= 0 or int(fail.group(1)) != 0:
        raise RuntimeError(
            f"press_client had Success={success.group(1)}, Fail={fail.group(1)}"
        )
    values = {"QPS": float(qps.group(1))}
    for field, unit, _direction in NUMERIC_FIELDS:
        raw = parsed.get(field, "N/A")
        if field == "Throughput" and raw.endswith("MB/s"):
            raw = raw[:-4]
        if raw == "N/A":
            raise RuntimeError(f"press_client omitted {field}")
        values[field] = float(raw)
        if not math.isfinite(values[field]) or values[field] < 0 or (
            field not in {"Client CPU (%)", "Server CPU (%)"} and values[field] == 0
        ):
            raise RuntimeError(f"press_client reported invalid {field} ({unit})")
    if not math.isfinite(values["QPS"]) or values["QPS"] <= 0:
        raise RuntimeError("press_client reported invalid QPS")
    return values


def run(original, run_py: Path, binary: Path, port: int, result_path: Path,
        raw_dir: Path, version: str, architecture: str) -> None:
    if not binary.is_file():
        raise RuntimeError(f"press_client is unavailable: {binary}")
    base = client_base(original, binary, port)
    raw_dir.mkdir(parents=True, exist_ok=True)
    result_path.parent.mkdir(parents=True, exist_ok=True)
    results = {}
    commands = []
    matrix = itertools.product(original.DATA_SETUPS, original.CONN_SETUPS,
                               original.QD_SETUPS)
    expected = len(original.DATA_SETUPS) * len(original.CONN_SETUPS) * len(original.QD_SETUPS)
    for index, ((data_type, data_args), (cpu_threads, io_threads, connections),
                queue_depth) in enumerate(matrix, 1):
        command = base + [
            f"--cpu_threads={cpu_threads}", f"--io_threads={io_threads}",
            f"--connections={connections}", f"--queue_depth={queue_depth}",
            *data_args,
        ]
        payload_arg = next((arg for arg in data_args if arg.startswith("--payload_size=")), None)
        if payload_arg is None:
            raise RuntimeError(f"AccLibBenchmark case {index} has no payload size")
        payload = int(payload_arg.split("=", 1)[1])
        scenario = (f"{data_type} / payload={payload}B / cpu={cpu_threads} / "
                    f"io={io_threads} / connections={connections} / qd={queue_depth}")
        log_path = raw_dir / f"case-{index:03d}.log"
        print(f"[folly-acclib] [{index}/{expected}] {scenario}", flush=True)
        print(f"[folly-acclib] {shlex.join(command)}", flush=True)
        completed = subprocess.run(command, capture_output=True, text=True,
                                   encoding="utf-8", errors="replace", check=False)
        output = completed.stdout + completed.stderr
        log_path.write_text(f"$ {shlex.join(command)}\n{output}", encoding="utf-8")
        commands.append({"scenario": scenario, "command": command,
                         "raw_output": str(log_path.relative_to(result_path.parent))})
        if completed.returncode:
            raise RuntimeError(f"{scenario}: press_client exited with {completed.returncode}; see {log_path}")
        values = measurement_rows(output, original)
        for field, unit, direction in (*NUMERIC_FIELDS,
                                       ("QPS", "ops/s", "higher_is_better")):
            name = f"{scenario} / {field}"
            if name in results:
                raise RuntimeError(f"duplicate AccLibBenchmark metric: {name}")
            results[name] = {
                "source_name": name, "source_field": field, "group": data_type,
                "value": values[field], "unit": unit, "direction": direction,
            }
        # Preserve every completed scenario even if a later one fails.
        (raw_dir / "commands.json").write_text(
            json.dumps(commands, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        if index < expected:
            time.sleep(5)
    metrics_per_case = len(NUMERIC_FIELDS) + 1
    if len(results) != expected * metrics_per_case:
        raise RuntimeError(
            f"expected {expected * metrics_per_case} AccLibBenchmark metrics, got {len(results)}"
        )
    benchmark_source = run_py.parent.parent / "fbthrift_folly_benchmark"
    source_hashes = {
        relative: hashlib.sha256((benchmark_source / relative).read_bytes()).hexdigest()
        for relative in ("CMakeLists.txt", "server/PressServer.cpp",
                         "client/PressTestClient.cpp", "press.thrift")
    }
    result_path.write_text(json.dumps({
        "software": "folly", "version": version, "architecture": architecture,
        "benchmark": "AccLibBenchmark/fbthrift_folly_benchmark",
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "cases": expected, "data_setups": original.DATA_SETUPS,
            "connection_setups": original.CONN_SETUPS,
            "queue_depths": original.QD_SETUPS, "server_threads": 40,
            "host": "127.0.0.1", "numa_binding": None,
            "io_uring": False,
            "source_sha256": source_hashes,
            "run_py_sha256": hashlib.sha256(run_py.read_bytes()).hexdigest(),
        },
        "runtime_context": {"port": port},
        "results": results,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 8:
        print("usage: run_acclib.py RUN_PY PRESS_CLIENT PORT RESULT_JSON RAW_DIR VERSION ARCH", file=sys.stderr)
        return 2
    run_py, client, port, result, raw, version, architecture = sys.argv[1:]
    original = load_original_driver(Path(run_py))
    run(original, Path(run_py), Path(client), int(port), Path(result), Path(raw),
        version, architecture)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
