#!/usr/bin/env python3
"""Benchmark Faiss CPU indexes with a deterministic synthetic data set."""

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


def generate_data(
    vector_count: int,
    query_count: int,
    dimension: int,
) -> tuple[np.ndarray, np.ndarray]:
    random_generator = np.random.default_rng(42)
    database = random_generator.random((vector_count, dimension), dtype=np.float32)
    queries = random_generator.random((query_count, dimension), dtype=np.float32)
    return database, queries


def recall_at_k(approximate: np.ndarray, exact: np.ndarray, k: int) -> float:
    matched_neighbors = 0
    for approximate_row, exact_row in zip(approximate, exact, strict=True):
        matched_neighbors += len(set(approximate_row) & set(exact_row))
    return matched_neighbors / (len(exact) * k)


def average(values: list[float]) -> float:
    return sum(values) / len(values)


def benchmark_index(
    constructor: Callable[[], Any],
    needs_training: bool,
    database: np.ndarray,
    queries: np.ndarray,
    exact_neighbors: np.ndarray,
    k: int,
    iterations: int,
) -> dict[str, float]:
    measurements: list[dict[str, float]] = []
    for _ in range(iterations):
        index = constructor()
        build_started = time.perf_counter()
        if needs_training:
            training_count = min(len(database), 50_000)
            index.train(database[:training_count])
        index.add(database)
        build_time = time.perf_counter() - build_started

        search_started = time.perf_counter()
        _, neighbors = index.search(queries, k)
        search_time = time.perf_counter() - search_started
        if search_time <= 0:
            raise RuntimeError("Faiss search returned a non-positive elapsed time")

        measurements.append(
            {
                "build_time_s": build_time,
                "qps": len(queries) / search_time,
                "latency_per_query_us": search_time / len(queries) * 1_000_000,
                "recall_at_k": recall_at_k(neighbors, exact_neighbors, k),
            }
        )

    return {
        field: round(average([measurement[field] for measurement in measurements]), 6)
        for field in measurements[0]
    }


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
    query_count = min(1_000, vector_count // 10)

    database, queries = generate_data(vector_count, query_count, dimension)
    ground_truth = faiss.IndexFlatL2(dimension)
    ground_truth.add(database)
    _, exact_neighbors = ground_truth.search(queries, k)

    index_definitions = {
        "IndexFlatL2": (lambda: faiss.IndexFlatL2(dimension), False),
        "IndexIVFFlat": (
            lambda: faiss.IndexIVFFlat(faiss.IndexFlatL2(dimension), dimension, 100),
            True,
        ),
        "IndexHNSWFlat": (lambda: faiss.IndexHNSWFlat(dimension, 32), False),
    }
    results: dict[str, dict[str, float]] = {}
    for index_name, (constructor, needs_training) in index_definitions.items():
        print(f"[faiss-ann] benchmarking {index_name}", flush=True)
        results[index_name] = benchmark_index(
            constructor,
            needs_training,
            database,
            queries,
            exact_neighbors,
            k,
            iterations,
        )

    payload = {
        "benchmark": "ann_search",
        "software": "faiss",
        "version": str(faiss.__version__),
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "dataset": "numpy_random_float32_seed_42",
            "data_scale": data_scale,
            "num_vectors": vector_count,
            "dimension": dimension,
            "num_queries": query_count,
            "k": k,
            "iterations": iterations,
            "IndexIVFFlat/nlist": 100,
            "IndexHNSWFlat/M": 32,
        },
        "results": results,
    }
    write_json(results_dir / "benchmark_ann.json", payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
