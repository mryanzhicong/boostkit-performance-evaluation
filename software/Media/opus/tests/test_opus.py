"""Contracts for the fixed-point Opus adapter."""

from __future__ import annotations

import importlib.util
import json
import os
import statistics
import subprocess
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPTS = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location(
    "opus_parse_benchmark", SCRIPTS / "results" / "parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)


def evidence() -> dict:
    cases = {}
    for scenario in parser.CASES:
        samples = [100.0 + index * 0.1 for index in range(20)]
        cases[scenario] = {
            "input_sha256": "a" * 64,
            "encoded_sha256": "b" * 64,
            "decoded_sha256": "c" * 64,
            "output_bytes": 21504,
            "decoded_frames": 518400,
            "input_frames": 518400,
            "samples_ms_per_audio_second": samples,
            "command": ["opus_demo", "-e", "voip", "48000", "1", "16000", "-complexity", "5", "-framesize", "20"],
        }
    return {
        "version": "1.6.1",
        "source_mode": "unpatched",
        "build_system": "autotools",
        "fixed_point": True,
        "threads": 1,
        "cases": cases,
    }


def csv_text(data: dict) -> str:
    lines = ["scenario,iterations,ms_per_audio_second,status"]
    for scenario, item in data["cases"].items():
        value = statistics.mean(item["samples_ms_per_audio_second"])
        lines.append(f"{scenario},20,{value:.6f},OK")
    return "\n".join(lines) + "\n"


def test_parser_produces_three_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "1.6.1", "aarch64")
    assert len(payload["results"]) == 3
    item = payload["results"]["speech_orig_16000_complexity5"]
    assert item["value"] == pytest.approx(100.95)
    assert item["unit"] == "ms/audio second"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "opus"
    assert item["subgroup"] == "16kbps_c5"
    assert payload["parameters"]["fixed_point"] is True
    assert payload["parameters"]["threads"] == 1
    assert payload["parameters"]["audio"]["seconds"] == 10.8


def test_parser_rejects_missing_case_and_bad_mean() -> None:
    data = evidence()
    data["cases"].pop(next(iter(data["cases"])))
    with pytest.raises(ValueError, match="exactly"):
        parser.parse(csv_text(data), data, "1.6.1", "aarch64")
    data = evidence()
    with pytest.raises(ValueError, match="mean"):
        parser.parse(csv_text(data).replace("100.950000", "200.000000", 1), data, "1.6.1", "aarch64")


def test_parser_rejects_incomplete_samples() -> None:
    data = evidence()
    data["cases"]["speech_orig_24000_complexity10"]["samples_ms_per_audio_second"].pop()
    with pytest.raises(ValueError, match="20 samples"):
        parser.parse(csv_text(data), data, "1.6.1", "aarch64")


def test_case_wiring_and_original_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["name"] == "opus"
    assert case["category"] == "Media"
    assert case["versions"] == ["1.6.1"]
    assert case["execution"]["stages"]["build"]["function"] == "build_opus"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-opus.csv"
    assert case["metrics"]["collection"]["subgroup_path"] == "subgroup"
    base = (SCRIPTS / "builders" / "base.sh").read_text()
    assert "build_install.sh" in base
    assert "BENCH_ENV_READY" in base
    reference = (SCRIPTS / "reference" / "build_install.sh").read_text()
    assert "--enable-fixed-point" in reference
    assert "--enable-extra-programs" in reference
    assert "make -j8 check" in reference
    assert (SCRIPTS / "reference" / "run_bench.sh").is_file()
    assert (SCRIPTS / "reference" / "bench.py").is_file()
    test_stage = (SCRIPTS / "stages" / "test.sh").read_text()
    assert "run_bench.sh" in test_stage
    assert "BENCH_ENV_READY" in test_stage


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPTS / "builders" / "optimized.sh").read_text()
    assert "not implemented" in content
    assert "return 40" in content


def test_container_name_and_no_affinity_flags() -> None:
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; PERF_RUN_ID=42-1; EXPECTED_ARCH=x86_64; configure_runtime_paths; printf "%s\\n" "$OPUS_CONTAINER_NAME"',
         "bash", str(SCRIPTS / "common.sh")],
        env={**os.environ, "PERF_WORK_DIR": "/tmp/opus-name-work", "RESULTS_DIR": "/tmp/opus-name-results"},
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-opus-x86_64-42-1"
    content = (SCRIPTS / "common.sh").read_text()
    assert '--user "$(id -u):$(id -g)"' in content
    assert "--cpuset-cpus" not in content
    assert "--cpus=" not in content
    assert "no CPU, memory or NUMA limit" in content
