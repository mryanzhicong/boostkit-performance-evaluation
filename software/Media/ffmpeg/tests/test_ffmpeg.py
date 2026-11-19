"""Contracts for the stock FFmpeg scaling adapter."""

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
    "ffmpeg_parse_benchmark", SCRIPTS / "results" / "parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)

SCENARIOS = {
    "BQTerrace_640x360_rgb24": "BQTerrace",
    "Film2012_640x360_rgb24": "Film2012",
    "messi_640x360_rgb24": "messi",
}


def evidence() -> dict:
    cases = {}
    for scenario, video in SCENARIOS.items():
        samples = [5.0 + index * 0.01 for index in range(20)]
        cases[scenario] = {
            "scenario": scenario,
            "video": video,
            "frames": 30,
            "samples_ms_per_frame": samples,
            "input_sha256": "a" * 64,
            "output_sha256": "b" * 64,
            "expected_output_bytes": 640 * 360 * 30 * 3,
            "command": ["ffmpeg", "-threads", "1", "-filter_threads", "1"],
        }
    return {
        "software": "ffmpeg",
        "version": "7.1.1",
        "source_mode": "unpatched",
        "cases": cases,
        "failures": {},
    }


def csv_text(data: dict) -> str:
    lines = ["scenario,frames,ms_per_frame,status"]
    for scenario, item in data["cases"].items():
        value = statistics.median(item["samples_ms_per_frame"])
        lines.append(f"{scenario},30,{value:.6f},OK")
    return "\n".join(lines) + "\n"


def test_parser_produces_three_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "7.1.1", "x86_64")
    assert len(payload["results"]) == 3
    item = payload["results"]["BQTerrace_640x360_rgb24"]
    assert item["value"] == pytest.approx(5.095)
    assert item["unit"] == "ms/frame"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "ffmpeg"
    assert item["subgroup"] == "BQTerrace"
    assert payload["parameters"]["threads"] == 1
    assert payload["parameters"]["source_mode"] == "unpatched"


def test_parser_rejects_missing_case_and_bad_median() -> None:
    data = evidence()
    data["cases"].pop(next(iter(data["cases"])))
    with pytest.raises(ValueError, match="exactly"):
        parser.parse(csv_text(data), data, "7.1.1", "x86_64")
    data = evidence()
    with pytest.raises(ValueError, match="median"):
        parser.parse(csv_text(data).replace("5.095000", "9.000000", 1), data, "7.1.1", "x86_64")


def test_parser_rejects_incomplete_samples() -> None:
    data = evidence()
    data["cases"]["messi_640x360_rgb24"]["samples_ms_per_frame"].pop()
    with pytest.raises(ValueError, match="20 samples"):
        parser.parse(csv_text(data), data, "7.1.1", "x86_64")


def test_case_wiring_and_build_flags() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["name"] == "ffmpeg"
    assert case["category"] == "Media"
    assert case["versions"] == ["7.1.1"]
    assert case["execution"]["stages"]["build"]["function"] == "build_ffmpeg"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-ffmpeg.csv"
    assert case["metrics"]["collection"]["subgroup_path"] == "subgroup"
    base = (SCRIPTS / "builders" / "base.sh").read_text()
    assert "--enable-filter=scale,format,null,psnr,setpts" in base
    assert "--extra-cflags='-O3 -ffp-contract=off'" in base
    assert "make -j8" in base
    runner = (SCRIPTS / "results" / "run_benchmark.py").read_text()
    assert "bilinear+accurate_rnd+bitexact" in runner
    assert '"-threads", "1", "-filter_threads", "1"' in runner
    assert "statistics.median" in runner


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPTS / "builders" / "optimized.sh").read_text()
    assert "not implemented" in content
    assert "return 40" in content


def test_container_name_and_uid_flags() -> None:
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; PERF_RUN_ID=42-1; EXPECTED_ARCH=aarch64; configure_runtime_paths; printf "%s\\n" "$FFMPEG_CONTAINER_NAME"',
         "bash", str(SCRIPTS / "common.sh")],
        env={**os.environ, "PERF_WORK_DIR": "/tmp/ffmpeg-name-work", "RESULTS_DIR": "/tmp/ffmpeg-name-results",
             "FFMPEG_VIDEO_DIR": "/tmp"},
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-ffmpeg-aarch64-42-1"
    content = (SCRIPTS / "common.sh").read_text()
    assert '--user "$(id -u):$(id -g)"' in content
    assert "no CPU, memory or NUMA limit" in content
