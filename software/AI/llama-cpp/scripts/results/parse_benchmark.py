#!/usr/bin/env python3
"""Parse and strictly validate upstream llama-bench JSON output."""

from __future__ import annotations

import argparse
import json
import math
import statistics
from pathlib import Path
from typing import Any


EXPECTED_MODEL_NAME = "bge-m3-q8_0.gguf"
EXPECTED_WORKLOAD = {
    "backends": "CPU",
    "n_prompt": 512,
    "n_gen": 0,
    "n_depth": 0,
    "n_batch": 512,
    "n_ubatch": 512,
    "n_threads": 1,
    "flash_attn": False,
    "embeddings": False,
    "use_mmap": True,
}
EXPECTED_REPETITIONS = 5
SCENARIO_GROUP = "pp512,b512,t1"


def require_finite_number(value: Any, label: str, *, positive: bool = False) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} must be numeric, got {type(value).__name__}")
    numeric = float(value)
    if not math.isfinite(numeric):
        raise ValueError(f"{label} is not finite")
    if positive and numeric <= 0:
        raise ValueError(f"{label} must be > 0, got {numeric}")
    if not positive and numeric < 0:
        raise ValueError(f"{label} must be >= 0, got {numeric}")
    return numeric


def require_int(value: Any, label: str, *, positive: bool = False) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValueError(f"{label} must be an integer, got {type(value).__name__}")
    if positive and value <= 0:
        raise ValueError(f"{label} must be > 0, got {value}")
    if not positive and value < 0:
        raise ValueError(f"{label} must be >= 0, got {value}")
    return value


def parse_llama_bench_json(
    path: Path,
    model_sha256: str,
    expected_commit: str = "3ac67535c86",
) -> dict[str, Any]:
    sha = model_sha256.strip().lower()
    if len(sha) != 64 or any(ch not in "0123456789abcdef" for ch in sha):
        raise ValueError(f"invalid model SHA-256: {model_sha256!r}")

    try:
        raw_payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"failed to read llama-bench JSON output: {exc}") from exc

    if not isinstance(raw_payload, list) or len(raw_payload) != 1:
        raise ValueError(
            f"expected exactly 1 llama-bench scenario entry, got "
            f"{len(raw_payload) if isinstance(raw_payload, list) else type(raw_payload).__name__}"
        )
    entry = raw_payload[0]
    if not isinstance(entry, dict):
        raise ValueError("llama-bench JSON entry must be an object")

    required_fields = (
        "build_commit",
        "build_number",
        "cpu_info",
        "backends",
        "model_filename",
        "model_type",
        "model_size",
        "model_n_params",
        "n_batch",
        "n_ubatch",
        "n_threads",
        "n_prompt",
        "n_gen",
        "n_depth",
        "flash_attn",
        "use_mmap",
        "embeddings",
        "test_time",
        "avg_ns",
        "stddev_ns",
        "avg_ts",
        "stddev_ts",
        "samples_ns",
        "samples_ts",
    )
    missing = [field for field in required_fields if field not in entry]
    if missing:
        raise ValueError(f"llama-bench JSON missing required fields: {', '.join(missing)}")

    build_commit = str(entry["build_commit"]).strip().lower()
    if not build_commit or build_commit == "unknown" or len(build_commit) < 7:
        raise ValueError(f"invalid build_commit in llama-bench output: {entry['build_commit']!r}")
    if expected_commit and not expected_commit.lower().startswith(build_commit):
        raise ValueError(
            f"llama-bench build_commit {build_commit!r} does not match expected {expected_commit!r}"
        )

    model_filename = str(entry["model_filename"])
    model_name = Path(model_filename).name
    if model_name != EXPECTED_MODEL_NAME:
        raise ValueError(
            f"unexpected model filename {model_name!r}, expected {EXPECTED_MODEL_NAME!r}"
        )

    for key, expected_value in EXPECTED_WORKLOAD.items():
        if entry[key] != expected_value:
            raise ValueError(
                f"workload parameter mismatch for {key}: got {entry[key]!r}, expected {expected_value!r}"
            )

    model_type = str(entry["model_type"]).strip()
    if not model_type:
        raise ValueError("model_type must not be empty")
    model_size = require_int(entry["model_size"], "model_size", positive=True)
    model_n_params = require_int(entry["model_n_params"], "model_n_params", positive=True)
    build_number = require_int(entry["build_number"], "build_number", positive=False)

    samples_ns_raw = entry["samples_ns"]
    samples_ts_raw = entry["samples_ts"]
    if (
        not isinstance(samples_ns_raw, list)
        or not isinstance(samples_ts_raw, list)
        or len(samples_ns_raw) != EXPECTED_REPETITIONS
        or len(samples_ts_raw) != EXPECTED_REPETITIONS
    ):
        raise ValueError(
            f"expected {EXPECTED_REPETITIONS} timed repetitions in samples_ns/samples_ts"
        )
    samples_ns = [
        require_int(value, f"samples_ns[{index}]", positive=True)
        for index, value in enumerate(samples_ns_raw)
    ]
    samples_ts = [
        require_finite_number(value, f"samples_ts[{index}]", positive=True)
        for index, value in enumerate(samples_ts_raw)
    ]

    avg_ns = require_finite_number(entry["avg_ns"], "avg_ns", positive=True)
    stddev_ns = require_finite_number(entry["stddev_ns"], "stddev_ns", positive=False)
    avg_ts = require_finite_number(entry["avg_ts"], "avg_ts", positive=True)
    stddev_ts = require_finite_number(entry["stddev_ts"], "stddev_ts", positive=False)

    mean_samples_ts = statistics.fmean(samples_ts)
    if abs(avg_ts - mean_samples_ts) / mean_samples_ts > 0.01:
        raise ValueError(
            f"avg_ts ({avg_ts}) diverges from mean(samples_ts) ({mean_samples_ts})"
        )
    mean_samples_ns = statistics.fmean(samples_ns)
    if abs(avg_ns - mean_samples_ns) / mean_samples_ns > 0.01:
        raise ValueError(
            f"avg_ns ({avg_ns}) diverges from mean(samples_ns) ({mean_samples_ns})"
        )

    avg_latency_ms = round(avg_ns / 1e6, 6)
    latency_stddev_ms = round(stddev_ns / 1e6, 6)

    results = {
        f"{SCENARIO_GROUP}/prompt_throughput": {
            "value": round(avg_ts, 6),
            "unit": "tokens/s",
            "direction": "higher_is_better",
            "group": SCENARIO_GROUP,
        },
        f"{SCENARIO_GROUP}/prompt_throughput_stddev": {
            "value": round(stddev_ts, 6),
            "unit": "tokens/s",
            "direction": "neutral",
            "group": SCENARIO_GROUP,
        },
        f"{SCENARIO_GROUP}/avg_latency_ms": {
            "value": avg_latency_ms,
            "unit": "ms",
            "direction": "lower_is_better",
            "group": SCENARIO_GROUP,
        },
        f"{SCENARIO_GROUP}/latency_stddev_ms": {
            "value": latency_stddev_ms,
            "unit": "ms",
            "direction": "neutral",
            "group": SCENARIO_GROUP,
        },
    }

    return {
        "parameters": {
            "backends": "CPU",
            "embeddings": False,
            "flash_attn": False,
            "model_n_params": model_n_params,
            "model_name": model_name,
            "model_sha256": sha,
            "model_size": model_size,
            "model_type": model_type,
            "n_batch": 512,
            "n_depth": 0,
            "n_gen": 0,
            "n_prompt": 512,
            "n_threads": 1,
            "n_ubatch": 512,
            "omp_num_threads": 1,
            "repetitions": EXPECTED_REPETITIONS,
            "use_mmap": True,
        },
        "runtime_context": {
            "build_commit": build_commit,
            "build_number": build_number,
            "cpu_info": str(entry.get("cpu_info", "")),
            "gpu_info": str(entry.get("gpu_info", "")),
            "model_filename": model_filename,
            "test_time": str(entry.get("test_time", "")),
            "samples_ns": samples_ns,
            "samples_ts": [round(val, 6) for val in samples_ts],
            "metric_sources": {
                f"{SCENARIO_GROUP}/prompt_throughput": "avg_ts (tokens/s, direct)",
                f"{SCENARIO_GROUP}/prompt_throughput_stddev": "stddev_ts (tokens/s, direct)",
                f"{SCENARIO_GROUP}/avg_latency_ms": "avg_ns / 1e6 (ns -> ms)",
                f"{SCENARIO_GROUP}/latency_stddev_ms": "stddev_ns / 1e6 (ns -> ms)",
            },
        },
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Raw llama-bench -o json output path")
    parser.add_argument("output", type=Path, help="Normalized benchmark_llama_cpp.json output path")
    parser.add_argument("--model-sha256", required=True, help="Verified SHA-256 of bge-m3-q8_0.gguf")
    parser.add_argument(
        "--expected-commit",
        default="3ac67535c86",
        help="Expected upstream llama.cpp commit prefix",
    )
    args = parser.parse_args()
    payload = parse_llama_bench_json(args.input, args.model_sha256, args.expected_commit)
    args.output.write_text(
        json.dumps(payload, indent=2, sort_keys=True, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
