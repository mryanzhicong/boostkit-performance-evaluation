#!/usr/bin/env python3
"""Parse TensorFlow ModelZoo serving benchmark CSV into Framework metrics."""

from __future__ import annotations

import csv
import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HEADER = [
    "mode", "dnn", "target_qps", "actual_qps", "total", "success", "failure",
    "p99_latency_us", "server_cpu_pct_avg", "server_cpu_cores_avg",
]


def number(value: str, label: str) -> float:
    try:
        numeric = float(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"{label} is not numeric: {value!r}") from exc
    if not math.isfinite(numeric):
        raise ValueError(f"{label} is not finite: {value!r}")
    return numeric


def parse_metadata(path: Path) -> dict[str, str]:
    metadata: dict[str, str] = {}
    if not path.is_file():
        return metadata
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        key, separator, value = line.partition("=")
        if separator:
            metadata[key.strip()] = value.strip()
    return metadata


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.DictReader(handle)
        fieldnames = set(reader.fieldnames or [])
        required = set(HEADER)
        optional = {"dropped", "avg_latency_us"}
        if not required.issubset(fieldnames) or fieldnames - required - optional:
            raise ValueError(f"unexpected results.csv header: {reader.fieldnames}")
        rows = []
        for row in reader:
            if not any((value or "").strip() for value in row.values()):
                continue
            rows.append({key: (value or "").strip() for key, value in row.items()})
    if not rows:
        raise ValueError("results.csv has no benchmark rows")
    return rows


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: parse_benchmark.py RESULTS_CSV METADATA_TXT OUTPUT_JSON", file=sys.stderr)
        return 2
    csv_path, metadata_path, output_path = (Path(value) for value in sys.argv[1:])
    rows = read_rows(csv_path)
    metadata = parse_metadata(metadata_path)
    model = os.environ.get("TF_MODEL", "din_mmoe")
    image = os.environ.get("TF_IMAGE", "")
    image_sha = os.environ.get("TF_IMAGE_SHA256", "")
    source_commit = os.environ.get("TF_SOURCE_COMMIT", "")
    asset_sha = os.environ.get("TF_ASSET_SHA256", "")
    run_modes = sorted({row["mode"] for row in rows})
    qps_values = sorted({int(number(row["target_qps"], "target_qps")) for row in rows})
    parameters = {
        "model": model,
        "run_modes": run_modes,
        "qps_list": qps_values,
        "warmup_s": int(metadata.get("warmup_s", os.environ.get("TF_WARMUP", "5"))),
        "duration_s": int(metadata.get("duration_s", os.environ.get("TF_DURATION", "30"))),
        "thread_num": int(metadata.get("thread_num", os.environ.get("TF_THREAD_NUM", "16"))),
        "client_thread_num": int(metadata.get("client_thread_num", os.environ.get("TF_CLIENT_THREAD_NUM", "1"))),
        "request_batch_size": metadata.get("request_batch_size", "1-100"),
        "max_inflight": int(metadata.get("max_inflight", os.environ.get("TF_MAX_INFLIGHT", "100"))),
        "image": image,
        "image_sha256": image_sha,
        "source_commit": source_commit,
        "assets_sha256": asset_sha,
        "tensorflow_version": "2.20.0",
        "source_branch": "dev_2.20.0",
    }
    results: dict[str, Any] = {}
    actual_qps_sum = 0.0
    total_sum = 0.0
    success_total = 0.0
    failure_total = 0.0
    dropped_total = 0.0
    p99_sum = 0.0
    cpu_pct_sum = 0.0
    for row_index, row in enumerate(rows):
        mode = row["mode"]
        target_qps = int(number(row["target_qps"], f"row {row_index} target_qps"))
        actual_qps = number(row["actual_qps"], f"row {row_index} actual_qps")
        total = number(row["total"], f"row {row_index} total")
        success = number(row["success"], f"row {row_index} success")
        failure = number(row["failure"], f"row {row_index} failure")
        dropped_raw = row.get("dropped", "")
        dropped_derived = not bool(dropped_raw)
        if dropped_derived:
            dropped = max(total - success - failure, 0.0)
        else:
            dropped = number(dropped_raw, f"row {row_index} dropped")
        p99 = number(row["p99_latency_us"], f"row {row_index} p99")
        cpu_pct = number(row["server_cpu_pct_avg"], f"row {row_index} cpu")
        cpu_cores = number(row["server_cpu_cores_avg"], f"row {row_index} cores")
        if (actual_qps <= 0 or p99 <= 0 or total < 0 or success < 0 or
                failure < 0 or dropped < 0 or cpu_pct < 0 or cpu_cores < 0):
            raise ValueError(f"row {row_index} contains invalid benchmark values")
        actual_qps_sum += actual_qps
        total_sum += total
        success_total += success
        failure_total += failure
        dropped_total += dropped
        p99_sum += p99
        cpu_pct_sum += cpu_pct
        prefix = f"{model}/{mode}/qps={target_qps}"
        values = {
            "actual_qps": (actual_qps, "queries/s", "higher_is_better", "actual_qps"),
            "total_requests": (total, "requests", "neutral", "total"),
            "success": (success, "requests", "higher_is_better", "success"),
            "failure": (failure, "requests", "lower_is_better", "failure"),
            "dropped": (dropped, "requests", "lower_is_better", "dropped"),
            "p99_latency_us": (p99, "us", "lower_is_better", "p99_latency_us"),
            "server_cpu_pct_avg": (cpu_pct, "%", "lower_is_better", "server_cpu_pct_avg"),
            "server_cpu_cores_avg": (cpu_cores, "cores", "lower_is_better", "server_cpu_cores_avg"),
        }
        for suffix, (value, unit, direction, field) in values.items():
            name = f"{prefix}/{suffix}"
            results[name] = {
                "source_name": name,
                "source_file": str(csv_path.name),
                "source_field": f"results[{row_index}].{field}",
                "group": model,
                "subgroup": mode,
                "value": value,
                "unit": unit,
                "direction": direction,
            }
            if suffix == "dropped":
                results[name]["derived"] = (
                    "max(total - success - failure, 0)" if dropped_derived else None
                )
    summary = {
        "rows": len(rows),
        "actual_qps_sum": actual_qps_sum,
        "total_requests_sum": total_sum,
        "success_total": success_total,
        "failure_total": failure_total,
        "dropped_total": dropped_total,
        "avg_p99_latency_us": p99_sum / len(rows),
        "avg_server_cpu_pct": cpu_pct_sum / len(rows),
    }
    payload = {
        "benchmark": "tensorflow_modelzoo_serving",
        "software": "tensorflow",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameters,
        "summary": summary,
        "runtime_context": {
            "tensorflow_version": "2.20.0",
            "image": image,
            "image_sha256": image_sha,
            "source_commit": source_commit,
            "assets_sha256": asset_sha,
            "benchmark_metadata": metadata,
        },
        "results": results,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[tensorflow] normalized {len(results)} benchmark metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(2)
