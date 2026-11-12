"""Contracts for the OpenVINO adapter and result conversion."""

from __future__ import annotations

import importlib.util
import json
import os
import subprocess
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPTS = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location(
    "openvino_parse_benchmark", SCRIPTS / "results/parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)


def evidence() -> dict:
    data = {
        "software": "openvino",
        "version": "2026.2.1",
        "architecture": "x86_64",
        "generated_at": "2026-01-01T00:00:00Z",
        "runtime": {
            "openvino": "2026.2.1",
            "openvino_module": "2026.2.1-21919",
            "threads": 1,
            "streams": 1,
            "performance_hint": "LATENCY",
            "inference_precision": "f32",
            "cpu_pinning": False,
            "cpu_count": 16,
            "cpu_model": "test cpu",
            "model_sha256": "b" * 64,
        },
        "cases": {},
        "failures": {},
    }
    data["parameters"] = parser.expected_parameters()
    for scenario, video in parser.EXPECTED_SCENARIOS.items():
        samples = [1.5 + index * 0.01 for index in range(20)]
        data["cases"][scenario] = {
            "scenario": scenario,
            "video": video,
            "model": "resnet18",
            "input_sha256": "a" * 64,
            "model_sha256": "b" * 64,
            "weights_url": parser.EXPECTED_MODEL[0],
            "weights_sha256": parser.EXPECTED_MODEL[1],
            "openvino": "2026.2.1",
            "threads": 1,
            "streams": 1,
            "performance_hint": "LATENCY",
            "inference_precision": "f32",
            "cpu_pinning": False,
            "affinity": "unbound",
            "iterations": 20,
            "samples_ms": samples,
            "mean_ms_per_image": sum(samples) / len(samples),
            "output": [[0.0] * 1000],
            "top5": [0, 1, 2, 3, 4],
        }
    return data


def csv_text(data: dict) -> str:
    lines = ["scenario,iterations,ms_per_image,status"]
    for scenario, item in data["cases"].items():
        lines.append(f"{scenario},20,{item['mean_ms_per_image']:.6f},OK")
    return "\n".join(lines) + "\n"


def test_valid_evidence_produces_three_fixed_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "2026.2.1", "x86_64")
    assert payload["benchmark"] == "openvino_resnet18_fp32"
    assert payload["parameters"]["precision"] == "FP32"
    assert payload["parameters"]["threads"] == 1
    assert payload["parameters"]["streams"] == 1
    assert payload["parameters"]["performance_hint"] == "LATENCY"
    assert len(payload["results"]) == 3
    item = payload["results"]["BQTerrace_resnet18_fp32_b1_c1"]
    assert item["unit"] == "ms/image"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "resnet18"
    assert item["subgroup"] == "BQTerrace"
    assert item["value"] == pytest.approx(1.595, abs=1e-9)


def test_rejects_missing_or_duplicate_csv_rows() -> None:
    data = evidence()
    lines = csv_text(data).splitlines()
    with pytest.raises(ValueError, match="exactly three"):
        parser.parse("\n".join(lines[:-1]) + "\n", data, "2026.2.1", "x86_64")
    with pytest.raises(ValueError, match="exactly three|duplicate"):
        parser.parse("\n".join(lines + [lines[1]]) + "\n", data, "2026.2.1", "x86_64")


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda d: d["cases"].pop(next(iter(d["cases"]))), "exactly three"),
        (lambda d: d["cases"][next(iter(d["cases"]))]["samples_ms"].pop(), "20 samples"),
        (lambda d: d["cases"][next(iter(d["cases"]))]["samples_ms"].__setitem__(0, 0), "positive"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("mean_ms_per_image", 99.0), "recorded mean"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("openvino", "2026.1.0"), "OpenVINO 2026.2.1"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("weights_sha256", "0" * 64), "ResNet18 weights"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("output", [[0.0] * 10]), "output shape"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("cpu_pinning", True), "pinned"),
        (lambda d: d["parameters"]["videos"][0].__setitem__("sha256", "0" * 64), "fixed workload"),
        (lambda d: d["runtime"].__setitem__("performance_hint", "THROUGHPUT"), "fixed workload"),
        (lambda d: d["runtime"].__setitem__("openvino", "2026.1.0"), "OpenVINO 2026.2.1"),
    ],
)
def test_rejects_incomplete_or_inconsistent_evidence(mutate, message: str) -> None:
    data = evidence()
    mutate(data)
    with pytest.raises(ValueError, match=message):
        parser.parse(csv_text(data), data, "2026.2.1", "x86_64")


def test_rejects_wrong_architecture_and_version() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="architecture"):
        parser.parse(csv_text(data), data, "2026.2.1", "aarch64")
    with pytest.raises(ValueError, match="requested OpenVINO version"):
        parser.parse(csv_text(data), data, "2026.1.0", "x86_64")


def test_rejects_failed_status_and_case_failures() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="did not complete"):
        parser.parse(csv_text(data).replace(",OK", ",FAIL", 1), data, "2026.2.1", "x86_64")
    data["failures"] = {"case": {"error": "boom"}}
    with pytest.raises(ValueError, match="recorded failures"):
        parser.parse(csv_text(data), data, "2026.2.1", "x86_64")


def test_case_declares_stages_and_outputs() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["category"] == "AI"
    assert case["versions"] == ["2026.2.1"]
    assert case["test_tools"]["torch"]["version"] == "2.9.1"
    assert case["test_tools"]["onnx"]["version"] == "1.19.1"
    assert case["execution"]["stages"] == {
        "build": {"script": "scripts/builders/dispatch.sh", "function": "build_openvino"},
        "start": {"script": "scripts/stages/start.sh", "function": "start_openvino_runtime"},
        "test": {"script": "scripts/stages/test.sh", "function": "run_openvino_benchmarks"},
        "stop": {"script": "scripts/stages/stop.sh", "function": "stop_openvino_runtime"},
    }
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_openvino.json"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-openvino.csv"
    assert case["outputs"]["benchmark_evidence"]["format"] == "directory"
    assert len(case["outputs"]) == 5


def test_optimized_build_fails_without_writing_variant(tmp_path: Path) -> None:
    results = tmp_path / "results"
    work = tmp_path / "work"
    environment = {
        **os.environ,
        "PERF_VARIANT": "optimized",
        "PERF_RUN_ID": "test-run",
        "EXPECTED_ARCH": "x86_64",
        "PERF_WORK_DIR": str(work),
        "RESULTS_DIR": str(results),
    }
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; build_openvino', "bash",
         str(CASE_DIR / "scripts/builders/dispatch.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 40
    assert "optimized OpenVINO build is not implemented" in result.stdout
    assert not (results / "build_variant.json").exists()


def test_container_name_is_derived_from_architecture_and_run_id(tmp_path: Path) -> None:
    environment = {
        **os.environ,
        "PERF_RUN_ID": "12345-1",
        "EXPECTED_ARCH": "aarch64",
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
    }
    result = subprocess.run(
        ["bash", "-c",
         'source "$1"; configure_runtime_paths; printf "%s\\n" "${OPENVINO_CONTAINER_NAME}"',
         "bash", str(SCRIPTS / "common.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-openvino-aarch64-12345-1"


def test_only_build_creates_the_container() -> None:
    for stage in ("start.sh", "test.sh", "stop.sh"):
        text = (SCRIPTS / "stages" / stage).read_text()
        assert "docker run" not in text
        assert "require_openvino_container" not in text
    assert "require_openvino_container" in (SCRIPTS / "builders/base.sh").read_text()
