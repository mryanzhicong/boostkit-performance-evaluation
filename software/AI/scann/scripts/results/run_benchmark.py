#!/usr/bin/env python3
"""Run the pinned ann-benchmarks ScaNN matrix and normalize its HDF5 results."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shutil
import subprocess
import sys
from pathlib import Path

REVISION = "2e081ad32c1eccab72dcb739ad886c310b90f715"
DATASETS = {
    "fashion-mnist-784-euclidean": ("euclidean", [500, math.nan, 4, "squared_l2"], [11, 75]),
    "sift-128-euclidean": ("euclidean", [2000, math.nan, 2, "squared_l2"], [33, 235]),
    "glove-100-angular": ("angular", [2000, 0.2, 2, "dot_product"], [180, 230]),
    "gist-960-euclidean": ("euclidean", [2000, math.nan, 4, "squared_l2"], [221, 670]),
    "deep-image-96-angular": ("angular", [2000, 0.2, 2, "dot_product"], [18, 230]),
}
METRICS = {
    "recall_at_10": ("ratio", "higher_is_better"),
    "qps": ("queries/s", "higher_is_better"),
    "build_time_s": ("s", "lower_is_better"),
    "candidates": ("count", "neutral"),
    "index_size_kb": ("kB", "neutral"),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(8 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def config_for(dataset: str, image_tag: str) -> dict:
    distance, arguments, query_arguments = DATASETS[dataset]
    return {
        "float": {
            distance: [{
                "base_args": {},
                "constructor": "Scann",
                "disabled": False,
                "docker_tag": image_tag,
                "module": "ann_benchmarks.algorithms.scann",
                "name": "scann",
                "run_groups": {
                    "adapter": {
                        "args": [[arg] for arg in arguments],
                        "query_args": [[query_arguments]],
                    }
                },
            }]
        }
    }


def write_configs(source: Path, image_tag: str) -> None:
    import yaml

    for dataset in DATASETS:
        path = source / "os-configs" / dataset / "scann" / "config.yml"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(yaml.safe_dump(config_for(dataset, image_tag), sort_keys=False), encoding="utf-8")


def dataset_info(directory: Path, dataset: str) -> dict[str, object]:
    import h5py

    path = directory / f"{dataset}.hdf5"
    if not path.is_file():
        directory.mkdir(parents=True, exist_ok=True)
        temporary = directory / f".{dataset}.hdf5.download"
        if temporary.exists():
            raise RuntimeError(f"refusing to overwrite an incomplete download: {temporary}")
        url = f"https://ann-benchmarks.com/{dataset}.hdf5"
        print(f"[scann] downloading {url}", flush=True)
        try:
            subprocess.run(
                ["curl", "--fail", "--location", "--retry", "3", "--connect-timeout", "30",
                 "--output", str(temporary), url],
                check=True,
            )
            with h5py.File(temporary, "r") as file:
                for key in ("train", "test", "neighbors", "distances"):
                    if key not in file or not file[key].shape:
                        raise RuntimeError(f"downloaded dataset is missing {key}: {dataset}")
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)
    else:
        print(f"[scann] using local dataset {path}", flush=True)
    with h5py.File(path, "r") as file:
        for key in ("train", "test", "neighbors", "distances"):
            if key not in file or not file[key].shape:
                raise RuntimeError(f"dataset is missing {key}: {path}")
        if file["test"].shape[0] != file["neighbors"].shape[0]:
            raise RuntimeError(f"dataset ground truth query count differs: {path}")
        if file["distances"].shape[1] < 10:
            raise RuntimeError(f"dataset has fewer than 10 ground truth neighbors: {path}")
        shape = list(file["train"].shape)
        queries = int(file["test"].shape[0])
    return {"sha256": sha256(path), "bytes": path.stat().st_size,
            "train_shape": shape, "queries": queries}


def run_official(source: Path, venv_python: Path, dataset: str, results: Path) -> None:
    command = [str(venv_python), "run.py", "--dataset", dataset,
               "--definitions", f"os-configs/{dataset}", "--algorithm", "scann",
               "--runs", "1", "--timeout", "86400", "--batch", "--force"]
    logfile = results / "ann-benchmarks-logs" / f"{dataset}.log"
    logfile.parent.mkdir(parents=True, exist_ok=True)
    print(f"[scann] running {' '.join(command)}", flush=True)
    with logfile.open("w", encoding="utf-8") as log:
        process = subprocess.Popen(
            command, cwd=source, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, encoding="utf-8", errors="replace", bufsize=1,
        )
        assert process.stdout is not None
        for line in process.stdout:
            log.write(line)
            log.flush()
            print(line, end="", flush=True)
        code = process.wait()
    if code:
        raise RuntimeError(f"ann-benchmarks {dataset} exited with {code}; see {logfile}")


def finite(value: object, label: str, *, positive: bool = False) -> float:
    number = float(value)
    if not math.isfinite(number) or (positive and number <= 0):
        raise RuntimeError(f"invalid {label}: {number}")
    return number


def parse_official_result(source: Path, data: Path, dataset: str, results: Path) -> dict[str, float]:
    import h5py
    import numpy as np

    files = list((source / "results" / dataset / "10" / "scann").glob("*.hdf5"))
    if len(files) != 1:
        raise RuntimeError(f"expected exactly one ScaNN result for {dataset}, found {len(files)}")
    path = files[0]
    with h5py.File(data / f"{dataset}.hdf5", "r") as original, h5py.File(path, "r") as result:
        if result.attrs.get("algo") != "scann" or result.attrs.get("dataset") != dataset:
            raise RuntimeError(f"result identity differs: {path}")
        batch_mode = result.attrs.get("batch_mode")
        if (not isinstance(batch_mode, (bool, np.bool_)) or not batch_mode
                or int(result.attrs.get("run_count", 0)) != 1):
            raise RuntimeError(f"unexpected query mode or run count: {path}")
        if int(result.attrs.get("count", 0)) != 10:
            raise RuntimeError(f"unexpected nearest-neighbor count: {path}")
        if result["distances"].shape != (original["test"].shape[0], 10):
            raise RuntimeError(f"result shape differs from query count: {path}")
        official = original["distances"][:, :10]
        returned = result["distances"][:]
        threshold = official[:, 9] + 1e-3
        recall = float(np.mean(np.sum(returned <= threshold[:, None], axis=1) / 10.0))
        times = result["times"][:]
        if (len(times) != original["test"].shape[0]
                or not np.all(np.isfinite(times)) or not np.all(times > 0)):
            raise RuntimeError(f"invalid query times: {path}")
        best_search_time = finite(result.attrs.get("best_search_time"), "best_search_time", positive=True)
        values = {
            "recall_at_10": recall,
            "qps": 1.0 / best_search_time,
            "build_time_s": finite(result.attrs.get("build_time"), "build_time", positive=True),
            "candidates": finite(result.attrs.get("candidates"), "candidates"),
            "index_size_kb": finite(result.attrs.get("index_size"), "index_size"),
        }
    if not 0 <= recall <= 1:
        raise RuntimeError(f"invalid recall: {recall}")
    for name, value in values.items():
        finite(value, name)
    raw = results / "ann-benchmarks-results" / dataset
    raw.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, raw / path.name)
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--results", type=Path, required=True)
    parser.add_argument("--wheel-version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--image-tag", required=True)
    args = parser.parse_args()
    if args.wheel_version != "1.4.2":
        raise RuntimeError("ScaNN wheel version must be 1.4.2")
    if subprocess.check_output(["git", "-C", str(args.source), "rev-parse", "HEAD"], text=True).strip() != REVISION:
        raise RuntimeError("ann-benchmarks checkout differs from pinned revision")
    args.results.mkdir(parents=True, exist_ok=True)
    data_link = args.source / "data"
    if data_link.exists() or data_link.is_symlink():
        raise RuntimeError(f"ann-benchmarks data path must be clean: {data_link}")
    data_link.symlink_to(args.data.resolve(), target_is_directory=True)
    write_configs(args.source, args.image_tag)
    dataset_details: dict[str, dict[str, object]] = {}
    results: dict[str, dict[str, object]] = {}
    for dataset in DATASETS:
        dataset_details[dataset] = dataset_info(args.data, dataset)
        run_official(args.source, Path(sys.executable), dataset, args.results)
        values = parse_official_result(args.source, args.data, dataset, args.results)
        for field, value in values.items():
            name = f"{dataset}/{field}"
            unit, direction = METRICS[field]
            results[name] = {"source_name": name, "group": dataset,
                             "value": value, "unit": unit, "direction": direction}
    parameters = {
        "ann_benchmarks_revision": REVISION,
        "datasets": dataset_details,
        "scenarios": {
            name: {"constructor_args": [None if isinstance(value, float) and math.isnan(value) else value
                                        for value in config[1]], "query_args": config[2]}
            for name, config in DATASETS.items()
        },
        "nearest_neighbors": 10,
        "runs": 1,
        "batch": True,
    }
    payload = {"benchmark": "ann-benchmarks_scann", "software": "scann",
               "version": args.wheel_version, "architecture": args.architecture,
               "parameters": parameters, "results": results}
    (args.results / "benchmark_scann.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n", encoding="utf-8"
    )
    print(f"[scann] normalized {len(results)} official measurements", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"[scann] ERROR: {error}", file=sys.stderr)
        raise SystemExit(1) from error
