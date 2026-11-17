"""Contracts for the TensorFlow ModelZoo serving adapter."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPTS = CASE_DIR / "scripts"
PARSER = SCRIPTS / "results" / "parse_benchmark.py"
CSV_HEADER = "mode,dnn,target_qps,actual_qps,total,success,failure,p99_latency_us,server_cpu_pct_avg,server_cpu_cores_avg\n"


def run_parser(tmp_path: Path, rows: list[str], metadata: str = "warmup_s=5\nduration_s=30\n") -> subprocess.CompletedProcess:
    csv_path = tmp_path / "results.csv"
    csv_path.write_text(CSV_HEADER + "\n".join(rows) + "\n", encoding="utf-8")
    meta_path = tmp_path / "metadata.txt"
    meta_path.write_text(metadata, encoding="utf-8")
    output = tmp_path / "benchmark_tensorflow.json"
    env = {
        **os.environ,
        "SOFTWARE_VERSION": "2.20.0",
        "EXPECTED_ARCH": "aarch64",
        "TF_MODEL": "din_mmoe",
        "TF_IMAGE": "benchmark-infer:v1.0.0",
        "TF_IMAGE_SHA256": "a" * 64,
        "TF_SOURCE_COMMIT": "b" * 40,
        "TF_ASSET_SHA256": "c" * 64,
    }
    result = subprocess.run(
        ["python3", str(PARSER), str(csv_path), str(meta_path), str(output)],
        env=env, capture_output=True, text=True, check=False,
    )
    return result


def test_parser_extracts_four_metrics_per_row(tmp_path: Path) -> None:
    result = run_parser(tmp_path, ["baseline,false,565,560.5,1000,999,1,1234.5,12.5,0.13"])
    assert result.returncode == 0, result.stderr
    payload = json.loads((tmp_path / "benchmark_tensorflow.json").read_text())
    assert len(payload["results"]) == 8
    qps = payload["results"]["din_mmoe/baseline/qps=565/actual_qps"]
    assert qps["value"] == pytest.approx(560.5)
    assert qps["unit"] == "queries/s"
    assert qps["direction"] == "higher_is_better"
    assert qps["group"] == "din_mmoe"
    assert qps["subgroup"] == "baseline"
    p99 = payload["results"]["din_mmoe/baseline/qps=565/p99_latency_us"]
    assert p99["value"] == pytest.approx(1234.5)
    assert p99["direction"] == "lower_is_better"
    success = payload["results"]["din_mmoe/baseline/qps=565/success"]
    assert success["value"] == pytest.approx(999)
    assert success["direction"] == "higher_is_better"
    failure = payload["results"]["din_mmoe/baseline/qps=565/failure"]
    assert failure["value"] == pytest.approx(1)
    assert failure["direction"] == "lower_is_better"
    total = payload["results"]["din_mmoe/baseline/qps=565/total_requests"]
    assert total["direction"] == "neutral"
    assert payload["summary"]["actual_qps_sum"] == pytest.approx(560.5)
    assert payload["summary"]["success_total"] == pytest.approx(999)
    assert payload["parameters"]["model"] == "din_mmoe"
    assert payload["parameters"]["qps_list"] == [565]
    assert payload["parameters"]["run_modes"] == ["baseline"]
    assert payload["parameters"]["image_sha256"] == "a" * 64


def test_parser_uses_explicit_dropped_column(tmp_path: Path) -> None:
    csv_path = tmp_path / "results.csv"
    csv_path.write_text(
        "mode,dnn,target_qps,actual_qps,total,success,failure,dropped,"
        "p99_latency_us,server_cpu_pct_avg,server_cpu_cores_avg\n"
        "baseline,false,565,560,1000,998,1,1,1234,12,0.13\n",
        encoding="utf-8",
    )
    meta = tmp_path / "metadata.txt"
    meta.write_text("warmup_s=5\nduration_s=30\n", encoding="utf-8")
    output = tmp_path / "out.json"
    env = {
        **os.environ, "SOFTWARE_VERSION": "2.20.0", "EXPECTED_ARCH": "aarch64",
        "TF_MODEL": "din_mmoe", "TF_IMAGE": "benchmark-infer:v1.0.0",
        "TF_IMAGE_SHA256": "a" * 64, "TF_SOURCE_COMMIT": "b" * 40,
        "TF_ASSET_SHA256": "c" * 64,
    }
    result = subprocess.run(
        ["python3", str(PARSER), str(csv_path), str(meta), str(output)],
        env=env, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    payload = json.loads(output.read_text())
    dropped = payload["results"]["din_mmoe/baseline/qps=565/dropped"]
    assert dropped["value"] == 1
    assert dropped["derived"] is None


def test_parser_rejects_bad_header_and_values(tmp_path: Path) -> None:
    bad = tmp_path / "bad.csv"
    bad.write_text("mode,qps\nbaseline,565\n", encoding="utf-8")
    result = subprocess.run(
        ["python3", str(PARSER), str(bad), str(tmp_path / "meta.txt"), str(tmp_path / "out.json")],
        env={**os.environ, "SOFTWARE_VERSION": "2.20.0", "EXPECTED_ARCH": "aarch64"},
        capture_output=True, text=True, check=False,
    )
    assert result.returncode != 0
    result = run_parser(tmp_path, ["baseline,false,565,0,1000,0,1000,1234.5,12.5,0.13"])
    assert result.returncode != 0


def test_case_wiring_and_container_flags() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["name"] == "tensorflow"
    assert case["category"] == "AI"
    assert case["versions"] == ["2.20.0"]
    assert case["execution"]["stages"]["build"]["function"] == "build_tensorflow"
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_tensorflow.json"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "tensorflow-benchmark/results.csv"
    assert case["metrics"]["collection"]["subgroup_path"] == "subgroup"
    content = (SCRIPTS / "common.sh").read_text()
    assert "--privileged" in content
    assert "--cpuset-cpus=0-15" in content
    assert "--memory=128g" in content


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPTS / "builders" / "optimized.sh").read_text()
    assert "not implemented" in content
    assert "return 40" in content


def test_container_name_uses_arch_and_run_id() -> None:
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; PERF_RUN_ID=42-1; EXPECTED_ARCH=aarch64; configure_runtime_paths; printf "%s\\n" "$TF_CONTAINER_NAME"',
         "bash", str(SCRIPTS / "common.sh")],
        env={**os.environ, "PERF_WORK_DIR": "/tmp/tf-name-work", "RESULTS_DIR": "/tmp/tf-name-results"},
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-tensorflow-aarch64-42-1"
