"""Contract tests for the gcc variant-aware stage split."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["versions"] == ["14.4.0", "12.5.0"]
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


@pytest.mark.parametrize("version", ["14.4.0", "12.5.0"])
def test_spec_configuration_uses_selected_version(tmp_path: Path, version: str) -> None:
    for architecture, config_name in (
        ("x86_64", "spec-gcc-x86.cfg"),
        ("aarch64", "spec-gcc-aarch64.cfg"),
    ):
        work_dir = tmp_path / architecture
        config_dir = work_dir / "cpu2017" / "config"
        result_dir = work_dir / "results"
        config_dir.mkdir(parents=True)
        result_dir.mkdir()
        compiler_dir = work_dir / "gcc-install"
        output_config = config_dir / config_name
        command = (
            'source "$1"; SOFTWARE_VERSION="$2"; INSTALL_DIR="$3"; '
            'SPEC_DIR="$4"; SPEC_CONFIG_NAME="$5"; SPEC_CONFIG_PATH="$6"; '
            'RESULTS_DIR="$7"; prepare_spec_configuration; printf "%s" "$SPEC_RESULT_DIR"'
        )
        result = subprocess.run(
            [
                "bash", "-c", command, "bash",
                str(CASE_DIR / "scripts/stages/test.sh"), version,
                str(compiler_dir), str(config_dir.parent), config_name,
                str(output_config), str(result_dir),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr or result.stdout
        assert result.stdout == str(config_dir.parent / "result" / "gnu" / f"{version}-base" / "result")
        rendered = output_config.read_text(encoding="utf-8")
        assert f"%   define label {version}-base" in rendered
        assert f"%   define  gcc_dir        {compiler_dir}" in rendered
        assert (result_dir / config_name).read_text(encoding="utf-8") == rendered


@pytest.mark.parametrize("version", ["14.4.0", "12.5.0"])
def test_normalized_parameters_align_across_architectures(tmp_path: Path, version: str) -> None:
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
                "SOFTWARE_VERSION": version,
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
                "GCC_VERSION_STRING": f"gcc (GCC) {version}",
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
