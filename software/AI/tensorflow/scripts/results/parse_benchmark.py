#!/usr/bin/env python3
"""Parse TensorFlow ModelZoo serving benchmark CSVs into Framework metrics.

The test stage runs ``TF_REPEAT`` independent repetitions (each with its own
warmup) and stores them as ``<out>/rep-<n>/results.csv``.  Every metric is
reported as the median over the repetitions, and the per-repetition values are
kept in ``sample_values``/``samples`` so the evidence stays auditable.
"""

from __future__ import annotations

import csv
import json
import math
import os
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HEADER = [
    "mode", "dnn", "target_qps", "actual_qps", "total", "success", "failure",
    "p99_latency_us", "server_cpu_pct_avg", "server_cpu_cores_avg",
]
OPTIONAL = {"dropped", "avg_latency_us"}
AGGREGATE_HEADER = ["rep"] + HEADER


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
        if not required.issubset(fieldnames) or fieldnames - required - OPTIONAL:
            raise ValueError(f"unexpected results.csv header: {reader.fieldnames}")
        rows = []
        for row in reader:
            if not any((value or "").strip() for value in row.values()):
                continue
            rows.append({key: (value or "").strip() for key, value in row.items()})
    if not rows:
        raise ValueError(f"{path} has no benchmark rows")
    return rows


def collect_repetitions(source: Path) -> list[tuple[int, list[dict[str, str]]]]:
    """Return (rep_index, rows) pairs sorted by repetition index."""
    if source.is_dir():
        rep_dirs = sorted(
            (item for item in source.iterdir() if item.is_dir() and item.name.startswith("rep-")),
            key=lambda item: int(item.name.split("-", 1)[1]),
        )
        repetitions = []
        for rep_dir in rep_dirs:
            csv_path = rep_dir / "results.csv"
            if not csv_path.is_file():
                continue
            repetitions.append((int(rep_dir.name.split("-", 1)[1]), read_rows(csv_path)))
        if not repetitions:
            raise ValueError(f"no rep-*/results.csv under {source}")
        return repetitions
    return [(1, read_rows(source))]


def aggregate(repetitions: list[tuple[int, list[dict[str, str]]]]) -> dict[tuple[str, int], dict[str, Any]]:
    grouped: dict[tuple[str, int], list[dict[str, str]]] = {}
    for _rep, rows in repetitions:
        for row in rows:
            key = (row["mode"], int(number(row["target_qps"], "target_qps")))
            grouped.setdefault(key, []).append(row)
    aggregated: dict[tuple[str, int], dict[str, Any]] = {}
    for key, rows in grouped.items():
        sample: dict[str, Any] = {"rows": rows}
        for field in ("actual_qps", "total", "success", "failure", "p99_latency_us",
                      "server_cpu_pct_avg", "server_cpu_cores_avg"):
            sample.setdefault("values", {})[field] = [
                number(row[field], f"{key} {field}") for row in rows
            ]
        sample.setdefault("values", {})["dropped"] = []
        for row in rows:
            raw = row.get("dropped", "")
            if raw:
                sample["values"]["dropped"].append(number(raw, f"{key} dropped"))
            else:
                total = number(row["total"], "total")
                success = number(row["success"], "success")
                failure = number(row["failure"], "failure")
                sample["values"]["dropped"].append(max(total - success - failure, 0.0))
        sample["dropped_derived"] = not any(row.get("dropped", "") for row in rows)
        sample["medians"] = {
            field: statistics.median(values) for field, values in sample["values"].items()
        }
        aggregated[key] = sample
    return aggregated


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: parse_benchmark.py RESULTS_DIR_OR_CSV METADATA_TXT OUTPUT_JSON",
              file=sys.stderr)
        return 2
    source, metadata_path, output_path = (Path(value) for value in sys.argv[1:])
    repetitions = collect_repetitions(source)
    aggregated = aggregate(repetitions)
    metadata = parse_metadata(metadata_path)
    model = os.environ.get("TF_MODEL", "din_mmoe")
    repeat = int(os.environ.get("TF_REPEAT", str(len(repetitions))))
    parameters = {
        "model": model,
        "run_modes": sorted({mode for mode, _qps in aggregated}),
        "qps_list": sorted({qps for _mode, qps in aggregated}),
        "warmup_s": int(metadata.get("warmup_s", os.environ.get("TF_WARMUP", "5"))),
        "duration_s": int(metadata.get("duration_s", os.environ.get("TF_DURATION", "30"))),
        "repetitions": repeat,
        "thread_num": int(metadata.get("thread_num", os.environ.get("TF_THREAD_NUM", "16"))),
        "client_thread_num": int(
            metadata.get("client_thread_num", os.environ.get("TF_CLIENT_THREAD_NUM", "1"))
        ),
        "request_batch_size": metadata.get("request_batch_size", "1-100"),
        "max_inflight": int(metadata.get("max_inflight", os.environ.get("TF_MAX_INFLIGHT", "100"))),
        "image": os.environ.get("TF_IMAGE", ""),
        "image_sha256": os.environ.get("TF_IMAGE_SHA256", ""),
        "source_commit": os.environ.get("TF_SOURCE_COMMIT", ""),
        "assets_sha256": os.environ.get("TF_ASSET_SHA256", ""),
        "tensorflow_version": "2.20.0",
        "source_branch": "dev_2.20.0",
    }
    results: dict[str, Any] = {}
    totals = {"actual_qps": 0.0, "total": 0.0, "success": 0.0, "failure": 0.0,
              "dropped": 0.0, "p99_latency_us": 0.0, "server_cpu_pct_avg": 0.0}
    definitions = {
        "actual_qps": ("queries/s", "higher_is_better"),
        "total_requests": ("requests", "neutral"),
        "success": ("requests", "higher_is_better"),
        "failure": ("requests", "lower_is_better"),
        "dropped": ("requests", "lower_is_better"),
        "p99_latency_us": ("us", "lower_is_better"),
        "server_cpu_pct_avg": ("%", "lower_is_better"),
        "server_cpu_cores_avg": ("cores", "lower_is_better"),
    }
    for (mode, target_qps), sample in sorted(aggregated.items(), key=lambda item: (item[0][0], item[0][1])):
        medians = sample["medians"]
        if medians["actual_qps"] <= 0 or medians["p99_latency_us"] <= 0:
            raise ValueError(
                f"{mode} qps={target_qps} has non-positive throughput or latency: {medians}"
            )
        for field in ("total", "success", "failure", "dropped",
                      "server_cpu_pct_avg", "server_cpu_cores_avg"):
            if medians[field] < 0:
                raise ValueError(f"{mode} qps={target_qps} {field} is negative: {medians[field]}")
        for field in ("actual_qps", "total", "success", "failure", "dropped",
                      "p99_latency_us", "server_cpu_pct_avg"):
            totals[field] += medians[field]
        prefix = f"{model}/{mode}/qps={target_qps}"
        for suffix, (unit, direction) in definitions.items():
            field = "total" if suffix == "total_requests" else suffix
            name = f"{prefix}/{suffix}"
            results[name] = {
                "source_name": name,
                "source_file": "results.csv",
                "source_field": f"median(results[*].{field})",
                "group": model,
                "subgroup": mode,
                "value": medians[field],
                "unit": unit,
                "direction": direction,
                "samples": len(sample["values"][field]),
                "sample_values": sample["values"][field],
                "statistic": "median",
            }
            if suffix == "dropped":
                results[name]["derived"] = (
                    "max(total - success - failure, 0)" if sample["dropped_derived"] else None
                )
    aggregate_csv = source if source.is_file() else source / "results.csv"
    if source.is_dir():
        with aggregate_csv.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=AGGREGATE_HEADER)
            writer.writeheader()
            for rep, rows in repetitions:
                for row in rows:
                    payload = {key: row.get(key, "") for key in HEADER}
                    payload["rep"] = rep
                    writer.writerow(payload)
    metric_count = len(aggregated)
    summary = {
        "repetitions": len(repetitions),
        "rows": len(repetitions[0][1]),
        "rows_per_repetition": len(repetitions[0][1]),
        "metric_groups": metric_count,
        "aggregate_csv": str(aggregate_csv),
        "actual_qps_sum": totals["actual_qps"],
        "total_requests_sum": totals["total"],
        "success_total": totals["success"],
        "failure_total": totals["failure"],
        "dropped_total": totals["dropped"],
        "avg_p99_latency_us": totals["p99_latency_us"] / max(metric_count, 1),
        "avg_server_cpu_pct": totals["server_cpu_pct_avg"] / max(metric_count, 1),
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
            "image": parameters["image"],
            "image_sha256": parameters["image_sha256"],
            "source_commit": parameters["source_commit"],
            "assets_sha256": parameters["assets_sha256"],
            "benchmark_metadata": metadata,
        },
        "results": results,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[tensorflow] normalized {len(results)} metrics from {len(repetitions)} repetitions")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(2)
