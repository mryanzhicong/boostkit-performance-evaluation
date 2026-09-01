#!/usr/bin/env python3
"""Benchmark upstream hnswlib on five ANN-Benchmarks datasets."""

from __future__ import annotations

import argparse
import json
import math
import time
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

BUILD_THREADS = 64
EF_CONSTRUCTION = 60
EF_SEARCH = 15
HNSW_M = 16
K = 10
QUERY_REPETITIONS = 3
DATASET_BASE_URL = "https://ann-benchmarks.com"


@dataclass(frozen=True)
class Dataset:
    name: str
    title: str
    filename: str
    space: str


DATASETS = (
    Dataset("fashion", "Fashion-MNIST", "fashion-mnist-784-euclidean.hdf5", "l2"),
    Dataset("gist", "GIST", "gist-960-euclidean.hdf5", "l2"),
    Dataset("sift", "SIFT", "sift-128-euclidean.hdf5", "l2"),
    Dataset("glove", "GloVe-100", "glove-100-angular.hdf5", "cosine"),
    Dataset("deep", "DEEP1B", "deep-image-96-angular.hdf5", "cosine"),
)


class RawLog:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.handle = path.open("w", encoding="utf-8")

    def write(self, message: str) -> None:
        print(message, flush=True)
        self.handle.write(message + "\n")
        self.handle.flush()

    def close(self) -> None:
        self.handle.close()


def finite(value: float, field: str, *, positive: bool = False) -> float:
    result = float(value)
    if not math.isfinite(result) or (positive and result <= 0.0):
        raise ValueError(f"{field} must be a finite{' positive' if positive else ''} number")
    return result


def download_dataset(dataset: Dataset, data_root: Path, raw: RawLog) -> Path:
    path = data_root / dataset.filename
    if path.is_file() and path.stat().st_size > 0:
        raw.write(f"[hnswlib-ann] using local dataset: {path}")
        return path

    temporary = path.with_name(f".{path.name}.download")
    url = f"{DATASET_BASE_URL}/{dataset.filename}"
    raw.write(f"[hnswlib-ann] downloading {url}")
    try:
        urllib.request.urlretrieve(url, temporary)
        if temporary.stat().st_size <= 0:
            raise OSError("downloaded file is empty")
        temporary.replace(path)
    except OSError as exc:
        temporary.unlink(missing_ok=True)
        raise RuntimeError(f"{dataset.name}: failed to download ANN-Benchmarks dataset: {exc}") from exc
    return path


def metric(
    source_name: str,
    value: float,
    unit: str,
    direction: str,
    group: str,
    *,
    positive: bool = True,
) -> dict[str, Any]:
    return {
        "source_name": source_name,
        "source_field": source_name.rsplit(" :: ", 1)[-1],
        "value": finite(value, source_name, positive=positive),
        "unit": unit,
        "direction": direction,
        "group": group,
    }


def recall_at_k(labels: Any, neighbors: Any) -> float:
    total = 0
    correct = 0
    for predicted, expected in zip(labels, neighbors, strict=True):
        expected_ids = {int(identifier) for identifier in expected[:K]}
        correct += sum(int(identifier) in expected_ids for identifier in predicted[:K])
        total += K
    if total == 0:
        raise ValueError("dataset has no query ground truth")
    return correct / total


def benchmark_dataset(dataset: Dataset, data_root: Path, raw: RawLog) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    try:
        import h5py
        import hnswlib
    except ImportError as exc:
        raise RuntimeError(f"{dataset.name}: benchmark dependency is unavailable: {exc}") from exc

    path = download_dataset(dataset, data_root, raw)
    raw.write(f"[hnswlib-ann] {dataset.title}: opening {path}")
    with h5py.File(path, "r") as handle:
        required = ("train", "test", "neighbors")
        missing = [name for name in required if name not in handle]
        if missing:
            raise ValueError(f"{dataset.name}: dataset is missing {', '.join(missing)}")
        train = handle["train"][()]
        test = handle["test"][()]
        neighbors = handle["neighbors"][()]

    if train.ndim != 2 or test.ndim != 2 or neighbors.ndim != 2:
        raise ValueError(f"{dataset.name}: ANN-Benchmarks arrays must be two-dimensional")
    if train.shape[1] != test.shape[1] or len(test) != len(neighbors):
        raise ValueError(f"{dataset.name}: inconsistent ANN-Benchmarks array dimensions")
    if len(neighbors[0]) < K:
        raise ValueError(f"{dataset.name}: ground truth contains fewer than {K} neighbors")

    raw.write(
        f"[hnswlib-ann] {dataset.title}: train={train.shape[0]}x{train.shape[1]}, "
        f"test={test.shape[0]}, k={K}"
    )
    index = hnswlib.Index(space=dataset.space, dim=int(train.shape[1]))
    start = time.perf_counter()
    index.init_index(max_elements=int(train.shape[0]), ef_construction=EF_CONSTRUCTION, M=HNSW_M)
    index.add_items(train, num_threads=BUILD_THREADS)
    construction_time = finite(time.perf_counter() - start, f"{dataset.name}: construction_time", positive=True)
    index.set_ef(EF_SEARCH)

    labels, _ = index.knn_query(test[: min(len(test), K)], k=K, num_threads=1)
    del labels
    query_durations = []
    labels = None
    for repetition in range(QUERY_REPETITIONS):
        start = time.perf_counter()
        labels, _ = index.knn_query(test, k=K, num_threads=1)
        duration = finite(time.perf_counter() - start, f"{dataset.name}: query duration", positive=True)
        query_durations.append(duration)
        raw.write(
            f"[hnswlib-ann] {dataset.title}: query run {repetition + 1}/{QUERY_REPETITIONS} "
            f"{len(test) / duration:.6f} QPS"
        )
    if labels is None:
        raise RuntimeError(f"{dataset.name}: hnswlib returned no query labels")
    recall = recall_at_k(labels, neighbors)
    if not 0.0 <= recall <= 1.0:
        raise ValueError(f"{dataset.name}: recall is outside [0, 1]")
    qps = sum(len(test) / duration for duration in query_durations) / len(query_durations)
    raw.write(
        f"[hnswlib-ann] {dataset.title}: construction_time={construction_time:.6f}s "
        f"qps={qps:.6f} recall={recall:.6f}"
    )

    parameters = {
        "dataset": dataset.filename,
        "space": dataset.space,
        "train_vectors": int(train.shape[0]),
        "test_vectors": int(test.shape[0]),
        "dimension": int(train.shape[1]),
    }
    metrics = [
        metric(f"{dataset.name} :: construction_time", construction_time, "seconds", "lower_is_better", dataset.title),
        metric(f"{dataset.name} :: qps", qps, "queries/s", "higher_is_better", dataset.title),
        metric(
            f"{dataset.name} :: recall",
            recall,
            "ratio",
            "higher_is_better",
            dataset.title,
            positive=False,
        ),
    ]
    return parameters, metrics


def atomic_write(path: Path, payload: dict[str, Any]) -> None:
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--raw-output", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    args = parser.parse_args()

    args.data_root.mkdir(parents=True, exist_ok=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw = RawLog(args.raw_output)
    try:
        results: dict[str, dict[str, Any]] = {}
        datasets: dict[str, dict[str, Any]] = {}
        for dataset in DATASETS:
            parameters, metrics = benchmark_dataset(dataset, args.data_root, raw)
            datasets[dataset.name] = parameters
            for entry in metrics:
                results[entry["source_name"]] = entry
        if not results:
            raise RuntimeError("hnswlib benchmark produced no metrics")
    except (OSError, RuntimeError, ValueError) as exc:
        raw.write(f"[hnswlib-ann] ERROR: {exc}")
        return 1
    finally:
        raw.close()

    atomic_write(
        args.output,
        {
            "software": "hnswlib",
            "version": args.version,
            "architecture": args.architecture,
            "benchmark": "ANN-Benchmarks datasets with upstream hnswlib",
            "reference": "https://github.com/erikbern/ann-benchmarks",
            "parameters": {
                "M": HNSW_M,
                "ef_construction": EF_CONSTRUCTION,
                "ef_search": EF_SEARCH,
                "construction_threads": BUILD_THREADS,
                "query_threads": 1,
                "k": K,
                "query_repetitions": QUERY_REPETITIONS,
                "datasets": datasets,
            },
            "results": results,
        },
    )
    print(f"[hnswlib-ann] normalized {len(results)} metrics", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
