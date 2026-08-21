#!/usr/bin/env python3
"""Validate protobuf benchmark outputs and expose only comparable raw metrics."""

from __future__ import annotations

import argparse
import json
import math
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


MESSAGE_CONFIGS = (
    "SimpleMessage",
    "RepeatedInt32",
    "RepeatedString",
    "NestedMessage",
    "LargeMessage",
)
SIZE_VALUES = (10, 50, 100, 500, 1000)


def load_required_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"required benchmark output is unavailable: {path.name}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"benchmark output is not an object: {path.name}")
    return payload


def require_mapping(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise RuntimeError(f"{label} must be an object")
    return value


def require_numeric(value: Any, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise RuntimeError(f"{label} must be numeric")
    numeric_value = float(value)
    if not math.isfinite(numeric_value) or numeric_value <= 0:
        raise RuntimeError(f"{label} must be finite and greater than zero")
    return numeric_value


def add_metric(
    metrics: dict[str, dict[str, Any]],
    value: Any,
    unit: str,
    direction: str,
    source_path: str,
) -> None:
    source_name = source_path
    if source_name in metrics:
        raise RuntimeError(f"duplicate metric source name: {source_name}")
    metrics[source_name] = {
        "source_name": source_name,
        "value": require_numeric(value, source_name),
        "unit": unit,
        "direction": direction,
        "source_path": source_path,
    }


def collect_serialization_metrics(ann_data: dict[str, Any], metrics: dict[str, dict[str, Any]]) -> None:
    parameters = require_mapping(ann_data.get("parameters"), "benchmark_ann.parameters")
    message_size = parameters.get("message_size")
    if not isinstance(message_size, int) or message_size <= 0:
        raise RuntimeError("benchmark_ann.parameters.message_size must be a positive integer")
    summary = require_mapping(ann_data.get("results_summary"), "benchmark_ann.results_summary")
    if tuple(summary) != MESSAGE_CONFIGS:
        raise RuntimeError("benchmark_ann message scenarios differ from the declared fixed suite")
    for scenario in MESSAGE_CONFIGS:
        result = require_mapping(summary.get(scenario), f"benchmark_ann.results_summary.{scenario}")
        if result.get("fidelity") != "passed":
            raise RuntimeError(f"fidelity validation did not pass for {scenario}")
        path_prefix = f"results_summary.{scenario}"
        add_metric(metrics, result.get("serialize_qps"), "messages/s", "higher_is_better", f"{path_prefix}.serialize_qps")
        add_metric(metrics, result.get("deserialize_qps"), "messages/s", "higher_is_better", f"{path_prefix}.deserialize_qps")
        add_metric(metrics, result.get("serialize_latency_us"), "us", "lower_is_better", f"{path_prefix}.serialize_latency_us")
        add_metric(metrics, result.get("deserialize_latency_us"), "us", "lower_is_better", f"{path_prefix}.deserialize_latency_us")


def collect_micro_metrics(micro_data: dict[str, Any], metrics: dict[str, dict[str, Any]]) -> None:
    parameters = require_mapping(micro_data.get("parameters"), "micro_benchmark.parameters")
    thread_counts = parameters.get("thread_counts")
    if thread_counts != [1, 2, 4, 8]:
        raise RuntimeError("micro_benchmark thread_counts must be the fixed suite [1, 2, 4, 8]")
    results = require_mapping(micro_data.get("results"), "micro_benchmark.results")

    single_serialize = require_mapping(results.get("single_serialize"), "micro_benchmark.single_serialize")
    add_metric(metrics, single_serialize.get("serialize_qps"), "messages/s", "higher_is_better", "results.single_serialize.serialize_qps")
    add_metric(metrics, single_serialize.get("serialize_latency_us"), "us", "lower_is_better", "results.single_serialize.serialize_latency_us")
    single_deserialize = require_mapping(results.get("single_deserialize"), "micro_benchmark.single_deserialize")
    add_metric(metrics, single_deserialize.get("deserialize_qps"), "messages/s", "higher_is_better", "results.single_deserialize.deserialize_qps")
    add_metric(metrics, single_deserialize.get("deserialize_latency_us"), "us", "lower_is_better", "results.single_deserialize.deserialize_latency_us")

    json_serialization = require_mapping(results.get("json_serialization"), "micro_benchmark.json_serialization")
    add_metric(metrics, json_serialization.get("binary_serialize_qps"), "messages/s", "higher_is_better", "results.json_serialization.binary_serialize_qps")
    add_metric(metrics, json_serialization.get("json_serialize_qps"), "messages/s", "higher_is_better", "results.json_serialization.json_serialize_qps")

    large_message = require_mapping(results.get("large_message"), "micro_benchmark.large_message")
    for operation, field, direction in (
        ("serialize", "serialize_qps", "higher_is_better"),
        ("serialize", "serialize_latency_us", "lower_is_better"),
        ("deserialize", "deserialize_qps", "higher_is_better"),
        ("deserialize", "deserialize_latency_us", "lower_is_better"),
    ):
        operation_result = require_mapping(large_message.get(operation), f"micro_benchmark.large_message.{operation}")
        unit = "messages/s" if field.endswith("qps") else "us"
        add_metric(metrics, operation_result.get(field), unit, direction, f"results.large_message.{operation}.{field}")

    for benchmark in ("multithread_serialize", "multithread_deserialize"):
        benchmark_results = require_mapping(results.get(benchmark), f"micro_benchmark.{benchmark}")
        expected_keys = tuple(f"threads_{count}" for count in thread_counts)
        if tuple(benchmark_results) != expected_keys:
            raise RuntimeError(f"micro_benchmark.{benchmark} does not match the fixed thread suite")
        for thread_count in thread_counts:
            name = f"threads_{thread_count}"
            item = require_mapping(benchmark_results.get(name), f"micro_benchmark.{benchmark}.{name}")
            add_metric(metrics, item.get("qps"), "messages/s", "higher_is_better", f"results.{benchmark}.{name}.qps")

    size_sweep = require_mapping(results.get("size_parameter_sweep"), "micro_benchmark.size_parameter_sweep")
    expected_sizes = tuple(f"size_{size}" for size in SIZE_VALUES)
    if tuple(size_sweep) != expected_sizes:
        raise RuntimeError("micro_benchmark.size_parameter_sweep does not match the fixed size suite")
    for size in SIZE_VALUES:
        item_name = f"size_{size}"
        item = require_mapping(size_sweep.get(item_name), f"micro_benchmark.size_parameter_sweep.{item_name}")
        for operation, field, direction in (
            ("serialize", "serialize_qps", "higher_is_better"),
            ("serialize", "serialize_latency_us", "lower_is_better"),
            ("deserialize", "deserialize_qps", "higher_is_better"),
            ("deserialize", "deserialize_latency_us", "lower_is_better"),
        ):
            operation_result = require_mapping(item.get(operation), f"micro_benchmark.size_parameter_sweep.{item_name}.{operation}")
            unit = "messages/s" if field.endswith("qps") else "us"
            add_metric(metrics, operation_result.get(field), unit, direction, f"results.size_parameter_sweep.{item_name}.{operation}.{field}")


def main() -> int:
    parser = argparse.ArgumentParser(description="validate and aggregate protobuf benchmark results")
    parser.add_argument("--results-dir", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    results_dir = Path(args.results_dir)
    ann_data = load_required_json(results_dir / "benchmark_ann.json")
    micro_data = load_required_json(results_dir / "micro_benchmark.json")
    metrics: dict[str, dict[str, Any]] = {}
    collect_serialization_metrics(ann_data, metrics)
    collect_micro_metrics(micro_data, metrics)
    if not metrics:
        raise RuntimeError("no protobuf metrics were collected")

    result = {
        "software": "protobuf",
        "version": os.environ.get("SOFTWARE_VERSION", ""),
        "test_time": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "serialization_benchmark": require_mapping(ann_data.get("parameters"), "benchmark_ann.parameters"),
            "micro_benchmark": require_mapping(micro_data.get("parameters"), "micro_benchmark.parameters"),
        },
        "metrics": metrics,
    }
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"[AGGREGATE] results saved to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
