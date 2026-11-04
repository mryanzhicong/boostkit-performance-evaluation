"""The SIFT CSV must retain every upstream scenario and official result field."""

import csv
import importlib.util
import json
from pathlib import Path

import pytest


PARSER = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("lance_parse_benchmark", PARSER)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def write_csv(path: Path, missing: tuple[int, int | None] | None = None) -> None:
    with path.open("w", newline="", encoding="utf-8") as output:
        writer = csv.DictWriter(output, fieldnames=(
            "ivf", "pq", "nprobes", "nsamples", "queries", "topk",
            "refine_factor", "recall@k", "mean_time_sec",
        ))
        writer.writeheader()
        for probe in MODULE.PROBES:
            for refine in MODULE.REFINEMENTS:
                if (probe, refine) == missing:
                    continue
                writer.writerow({
                    "ivf": 256, "pq": 16, "nprobes": probe, "nsamples": 1000,
                    "queries": "sift_query.lance", "topk": 1,
                    "refine_factor": "" if refine is None else refine,
                    "recall@k": 0.75, "mean_time_sec": 0.004,
                })


def test_complete_matrix(tmp_path: Path) -> None:
    path = tmp_path / "benchmark.csv"
    write_csv(path)
    output = MODULE.parse_csv(path, "a" * 64, "b" * 64)
    assert len(output["results"]) == 84
    assert output["results"]["nprobes=1,refine_factor=none/recall_at_1"]["value"] == 0.75
    assert output["results"]["nprobes=100,refine_factor=50/mean_query_time"]["value"] == 0.004


def test_missing_scenario_fails(tmp_path: Path) -> None:
    path = tmp_path / "benchmark.csv"
    write_csv(path, (100, 50))
    with pytest.raises(ValueError, match="expected 42"):
        MODULE.parse_csv(path, "a" * 64, "b" * 64)


def test_standalone_report_preserves_all_metrics(tmp_path: Path) -> None:
    path = tmp_path / "benchmark.csv"
    write_csv(path)
    (tmp_path / "benchmark_lance.json").write_text(
        json.dumps(MODULE.parse_csv(path, "a" * 64, "b" * 64)), encoding="utf-8"
    )
    runtime_path = PARSER.with_name("standalone_runtime.py")
    runtime_spec = importlib.util.spec_from_file_location("lance_standalone_runtime", runtime_path)
    assert runtime_spec and runtime_spec.loader
    runtime = importlib.util.module_from_spec(runtime_spec)
    runtime_spec.loader.exec_module(runtime)
    assert runtime.finalize(tmp_path, "13.0.0", "x86_64", "test-1", "passed", "passed", "") == 0
    assert len(json.loads((tmp_path / "results.json").read_text())["metrics"]) == 84
    assert "nprobes=100,refine_factor=50" in (tmp_path / "report.md").read_text()
