#!/usr/bin/env python3
"""Benchmark individual Faiss CPU APIs with deterministic inputs."""

from __future__ import annotations

import json
import os
import time
from collections.abc import Callable
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import faiss
import numpy as np

SCALE_TO_VECTOR_COUNT = {
    "1K": 1_000,
    "10K": 10_000,
    "100K": 100_000,
    "1M": 1_000_000,
}


def environment_integer(name: str, default: int, minimum: int = 1) -> int:
    raw_value = os.environ.get(name, str(default))
    try:
        value = int(raw_value)
    except ValueError as error:
        raise RuntimeError(f"{name} must be an integer, got {raw_value}") from error
    if value < minimum:
        raise RuntimeError(f"{name} must be at least {minimum}, got {value}")
    return value


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def average_measurement(iterations: int, operation: Callable[[], None]) -> float:
    measurements: list[float] = []
    for _ in range(iterations):
        started = time.perf_counter()
        operation()
        measurements.append(time.perf_counter() - started)
    elapsed = sum(measurements) / len(measurements)
    if elapsed <= 0:
        raise RuntimeError("Faiss operation returned a non-positive elapsed time")
    return elapsed


def main() -> int:
    results_dir = Path(os.environ["RESULTS_DIR"])
    data_scale = os.environ.get("DATA_SCALE", "100K")
    if data_scale not in SCALE_TO_VECTOR_COUNT:
        supported = ", ".join(SCALE_TO_VECTOR_COUNT)
        raise RuntimeError(f"DATA_SCALE must be one of {supported}, got {data_scale}")
    vector_count = SCALE_TO_VECTOR_COUNT[data_scale]
    dimension = environment_integer("DATA_DIM", 128)
    iterations = environment_integer("ITERATIONS", 1)
    k = environment_integer("K", 10)
    random_generator = np.random.default_rng(42)
    database = random_generator.random((vector_count, dimension), dtype=np.float32)

    def train_kmeans() -> None:
        kmeans = faiss.Kmeans(dimension, 100, niter=20, verbose=False)
        kmeans.train(database)

    kmeans_time = average_measurement(iterations, train_kmeans)

    def add_to_flat_index() -> None:
        index = faiss.IndexFlatL2(dimension)
        index.add(database)

    flat_add_time = average_measurement(iterations, add_to_flat_index)

    flat_index = faiss.IndexFlatL2(dimension)
    flat_index.add(database)
    single_query = database[:1]

    def search_single_query_batch() -> None:
        for _ in range(1_000):
            flat_index.search(single_query, k)

    single_search_time = average_measurement(iterations, search_single_query_batch)

    batch_queries = random_generator.random((1_000, dimension), dtype=np.float32)
    batch_search_time = average_measurement(
        iterations,
        lambda: flat_index.search(batch_queries, k),
    )
    range_queries = database[:100]
    range_search_time = average_measurement(
        iterations,
        lambda: flat_index.range_search(range_queries, 5.0),
    )

    product_quantizer = faiss.IndexPQ(dimension, 8, 8)
    product_quantizer.train(database[: min(vector_count, 50_000)])

    def add_to_product_quantizer() -> None:
        product_quantizer.reset()
        product_quantizer.add(database)

    product_quantizer_add_time = average_measurement(
        iterations, add_to_product_quantizer
    )

    results = {
        "Kmeans": {
            "train": {
                "elapsed_s": round(kmeans_time, 6),
            },
        },
        "IndexFlatL2": {
            "add": {
                "vectors_per_second": round(vector_count / flat_add_time, 6),
            },
            "search": {
                "single": {
                    "latency_us": round(single_search_time / 1_000 * 1_000_000, 6),
                },
                "batch": {
                    "queries_per_second": round(1_000 / batch_search_time, 6),
                },
            },
            "range_search": {
                "queries_per_second": round(100 / range_search_time, 6),
            },
        },
        "IndexPQ": {
            "add": {
                "vectors_per_second": round(
                    vector_count / product_quantizer_add_time, 6
                ),
            },
        },
    }
    payload = {
        "benchmark": "micro_operations",
        "software": "faiss",
        "version": str(faiss.__version__),
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "dataset": "numpy_random_float32_seed_42",
            "data_scale": data_scale,
            "num_vectors": vector_count,
            "dimension": dimension,
            "iterations": iterations,
            "k": k,
            "single_query_repetitions": 1_000,
            "batch_query_count": 1_000,
            "range_query_count": 100,
            "range_radius": 5.0,
            "Kmeans/k": 100,
            "Kmeans/niter": 20,
            "IndexPQ/M": 8,
            "IndexPQ/nbits": 8,
        },
        "results": results,
    }
    write_json(results_dir / "benchmark_micro.json", payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
