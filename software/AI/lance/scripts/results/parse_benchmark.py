#!/usr/bin/env python3
"""Normalize the unmodified upstream metrics.py CSV without dropping scenarios."""

import argparse
import csv
import json
import math
from pathlib import Path


PROBES = (1, 10, 25, 50, 75, 100)
REFINEMENTS = (None, 1, 10, 20, 30, 40, 50)


def parse_float(value: str, label: str) -> float:
    result = float(value)
    if not math.isfinite(result):
        raise ValueError(f"{label} is not finite")
    return result


def parse_csv(path: Path, base_sha: str, query_sha: str) -> dict:
    with path.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream)
        required = {"ivf", "pq", "nprobes", "nsamples", "queries", "topk", "refine_factor", "recall@k", "mean_time_sec"}
        if not required.issubset(reader.fieldnames or []):
            raise ValueError("upstream metrics CSV is missing required fields")
        rows = list(reader)
    if len(rows) != len(PROBES) * len(REFINEMENTS):
        raise ValueError(f"expected 42 upstream scenarios, got {len(rows)}")
    results = {}
    seen = set()
    for row in rows:
        ivf, pq, samples, topk = (int(row[key]) for key in ("ivf", "pq", "nsamples", "topk"))
        if (ivf, pq, samples, topk) != (256, 16, 1000, 1):
            raise ValueError("upstream workload parameters differ from selected SIFT profile")
        probe = int(row["nprobes"])
        refinement = row["refine_factor"]
        if refinement in ("", "None", "nan"):
            refine = None
        else:
            refine_value = parse_float(refinement, "refine_factor")
            if not refine_value.is_integer():
                raise ValueError(f"non-integer refine_factor: {refinement}")
            refine = int(refine_value)
        scenario = (probe, refine)
        if probe not in PROBES or refine not in REFINEMENTS or scenario in seen:
            raise ValueError(f"unexpected or duplicate scenario: {scenario}")
        seen.add(scenario)
        label = f"nprobes={probe},refine_factor={refine if refine is not None else 'none'}"
        recall = parse_float(row["recall@k"], "recall@k")
        latency = parse_float(row["mean_time_sec"], "mean_time_sec")
        if not 0 <= recall <= 1 or latency <= 0:
            raise ValueError(f"invalid recall or latency for {label}")
        results[f"{label}/recall_at_1"] = {
            "value": recall, "unit": "ratio", "direction": "higher_is_better", "group": label,
        }
        results[f"{label}/mean_query_time"] = {
            "value": latency, "unit": "s", "direction": "lower_is_better", "group": label,
        }
    if seen != {(probe, refine) for probe in PROBES for refine in REFINEMENTS}:
        raise ValueError("upstream scenario matrix is incomplete")
    return {
        "parameters": {
            "dataset": "SIFT-1M", "base_sha256": base_sha, "query_sha256": query_sha,
            "dimension": 128, "vectors": 1_000_000, "query_vectors": 1_000,
            "index_type": "IVF_PQ", "metric": "l2", "ivf_partitions": 256,
            "pq_subvectors": 16, "top_k": 1, "samples": 1_000,
            "nprobes": list(PROBES), "refine_factors": ["none", 1, 10, 20, 30, 40, 50],
        },
        "results": results,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("base_sha")
    parser.add_argument("query_sha")
    args = parser.parse_args()
    for label, value in (("base", args.base_sha), ("query", args.query_sha)):
        if len(value) != 64 or any(char not in "0123456789abcdef" for char in value):
            raise ValueError(f"invalid {label} SHA-256")
    payload = parse_csv(args.input, args.base_sha, args.query_sha)
    args.output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
