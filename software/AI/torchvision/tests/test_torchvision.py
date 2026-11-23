"""Contracts for the TorchVision INT8 adapter and result conversion."""

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
    "torchvision_parse_benchmark", SCRIPTS / "results/parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)


def evidence() -> dict:
    data = {
        "software": "torchvision",
        "version": "0.24.1",
        "architecture": "x86_64",
        "generated_at": "2026-01-01T00:00:00Z",
        "runtime": {
            "torch": "2.9.1+cpu",
            "torchvision": "0.24.1",
            "numpy": "2.4.6",
            "pillow": "13.0.0",
            "quantized_engine": "qnnpack",
            "threads": 1,
            "interop_threads": 1,
            "cpu_count": 16,
            "cpu_model": "test cpu",
        },
        "cases": {},
        "failures": {},
    }
    data["parameters"] = parser.expected_parameters(data)
    for scenario, (video, model) in parser.EXPECTED_SCENARIOS.items():
        samples = [2.0 + index * 0.01 for index in range(20)]
        weight_url, weight_sha = parser.EXPECTED_MODELS[model]
        source_sha = parser.EXPECTED_VIDEOS[video][1]
        data["cases"][scenario] = {
            "scenario": scenario,
            "video": video,
            "model": model,
            "input_sha256": "a" * 64,
            "weights_url": weight_url,
            "weights_sha256": weight_sha,
            "quantized_engine": "qnnpack",
            "quantized_conv_linear_modules": 10,
            "iterations": 20,
            "samples_ms": samples,
            "mean_ms_per_image": sum(samples) / len(samples),
            "output": [[0.0] * 1000],
            "top5": [0, 1, 2, 3, 4],
        }
        assert len(source_sha) == 64
    return data


def csv_text(data: dict) -> str:
    lines = ["scenario,iterations,ms_per_image,status"]
    for scenario, item in data["cases"].items():
        lines.append(f"{scenario},20,{item['mean_ms_per_image']:.6f},OK")
    return "\n".join(lines) + "\n"


def test_valid_evidence_produces_six_fixed_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "0.24.1", "x86_64")
    assert payload["benchmark"] == "torchvision_official_int8"
    assert payload["parameters"]["precision"] == "official quantized INT8"
    assert payload["parameters"]["compute_threads"] == 1
    assert payload["parameters"]["warmup_iterations"] == 3
    assert len(payload["results"]) == 6
    item = payload["results"]["BQTerrace_mobilenet_v2_official_int8_b1_c1"]
    assert item["unit"] == "ms/image"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "mobilenet_v2"
    assert item["subgroup"] == "BQTerrace"
    assert item["value"] == pytest.approx(2.095, abs=1e-9)
    assert payload["runtime_context"]["quantized_engine"] == "qnnpack"


def test_rejects_missing_or_duplicate_csv_rows() -> None:
    data = evidence()
    lines = csv_text(data).splitlines()
    with pytest.raises(ValueError, match="exactly six"):
        parser.parse("\n".join(lines[:-1]) + "\n", data, "0.24.1", "x86_64")
    with pytest.raises(ValueError, match="exactly six|duplicate"):
        parser.parse("\n".join(lines + [lines[1]]) + "\n", data, "0.24.1", "x86_64")


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda d: d["cases"].pop(next(iter(d["cases"]))), "exactly six"),
        (lambda d: d["cases"][next(iter(d["cases"]))]["samples_ms"].pop(), "20 samples"),
        (lambda d: d["cases"][next(iter(d["cases"]))]["samples_ms"].__setitem__(0, 0), "positive"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("mean_ms_per_image", 99.0), "recorded mean"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("quantized_engine", "x86"), "QNNPACK"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("weights_sha256", "0" * 64), "official weights"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("output", [[0.0] * 10]), "output shape"),
        (lambda d: d["cases"][next(iter(d["cases"]))].__setitem__("quantized_conv_linear_modules", 0), "quantized Conv2d"),
        (lambda d: d["parameters"]["videos"][0].__setitem__("sha256", "0" * 64), "fixed workload"),
        (lambda d: d["runtime"].__setitem__("quantized_engine", "x86"), "QNNPACK"),
    ],
)
def test_rejects_incomplete_or_inconsistent_evidence(mutate, message: str) -> None:
    data = evidence()
    mutate(data)
    with pytest.raises(ValueError, match=message):
        parser.parse(csv_text(data), data, "0.24.1", "x86_64")


def test_rejects_wrong_architecture_and_version() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="architecture"):
        parser.parse(csv_text(data), data, "0.24.1", "aarch64")
    with pytest.raises(ValueError, match="requested torchvision version"):
        parser.parse(csv_text(data), data, "0.23.0", "x86_64")


def test_rejects_failed_status_and_case_failures() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="did not complete"):
        parser.parse(csv_text(data).replace(",OK", ",FAIL", 1), data, "0.24.1", "x86_64")
    data["failures"] = {"case": {"error": "boom"}}
    with pytest.raises(ValueError, match="recorded failures"):
        parser.parse(csv_text(data), data, "0.24.1", "x86_64")


def test_case_declares_stages_and_outputs() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["category"] == "AI"
    assert case["versions"] == ["0.24.1"]
    assert case["test_tools"]["torch"]["version"] == "2.9.1"
    assert case["execution"]["stages"] == {
        "build": {"script": "scripts/builders/dispatch.sh", "function": "build_torchvision"},
        "start": {"script": "scripts/stages/start.sh", "function": "start_torchvision_runtime"},
        "test": {"script": "scripts/stages/test.sh", "function": "run_torchvision_benchmarks"},
        "stop": {"script": "scripts/stages/stop.sh", "function": "stop_torchvision_runtime"},
    }
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_torchvision.json"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-torchvision.csv"
    assert case["outputs"]["benchmark_evidence"]["format"] == "directory"
    assert case["metrics"]["collection"]["subgroup_path"] == "subgroup"
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
        ["bash", "-c", 'source "$1"; build_torchvision', "bash",
         str(CASE_DIR / "scripts/builders/dispatch.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 40
    assert "optimized torchvision build is not implemented" in result.stdout
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
         'source "$1"; configure_runtime_paths; printf "%s\\n" "${TORCHVISION_CONTAINER_NAME}"',
         "bash", str(SCRIPTS / "common.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-torchvision-aarch64-12345-1"


def test_only_build_creates_the_container() -> None:
    for stage in ("start.sh", "test.sh", "stop.sh"):
        text = (SCRIPTS / "stages" / stage).read_text()
        assert "docker run" not in text
        assert "require_torchvision_container" not in text
    assert "require_torchvision_container" in (SCRIPTS / "builders/base.sh").read_text()
