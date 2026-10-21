"""Contract tests for the gcc variant-aware stage split."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_gcc",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_gcc_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_gcc_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_gcc_runtime",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


def test_optimized_build_fails_without_running_base_build(tmp_path: Path) -> None:
    result = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_gcc',
            "bash",
            str(CASE_DIR / "scripts/builders/dispatch.sh"),
        ],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "PERF_WORK_DIR": str(tmp_path),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 30
    assert "optimized gcc build is not implemented" in result.stdout
    assert not (tmp_path / "gcc-src").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "gcc_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        result_directory = tmp_path / f"spec-results-{architecture}"
        result_directory.mkdir()
        (result_directory / "intrate.001-01.txt").write_text(
            "Est. SPECrate2017_int_base      123.4\n",
            encoding="utf-8",
        )
        output = tmp_path / f"benchmark_gcc-{architecture}.json"
        result = subprocess.run(
            [
                sys.executable,
                str(PARSER),
                str(result_directory),
                str(output),
            ],
            env={
                **os.environ,
                "SOFTWARE_VERSION": "14.4.0",
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
                "GCC_VERSION_STRING": "gcc (GCC) 14.4.0",
                "SPEC_CONFIG_NAME": f"spec-gcc-{'x86' if architecture == 'x86_64' else 'aarch64'}.cfg",
                "SPEC_COPIES": "384",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        normalized = json.loads(output.read_text(encoding="utf-8"))
        assert normalized["variant"] == "base"
        assert normalized["results"]["SPECrate2017_int_base"]["value"] == 123.4
        parameters.append(normalized["parameters"])
    assert parameters[0] == parameters[1]
    assert not any("boostkit-perf" in json.dumps(parameter) for parameter in parameters)
