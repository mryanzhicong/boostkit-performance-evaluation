"""Contract tests for the glibc variant-aware stage split."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
RESULTS_DIR = CASE_DIR / "scripts" / "results"


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_glibc",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_glibc_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_glibc_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_glibc_runtime",
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
            'source "$1"; build_glibc',
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
    assert "optimized glibc build is not implemented" in result.stdout
    assert not (tmp_path / "glibc-src").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "glibc_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        directory = tmp_path / f"benchtests-{architecture}"
        directory.mkdir()
        for function in ("memcpy", "memcmp"):
            rows = []
            for length in (2048, 4096):
                row = {
                    "length": length,
                    "align1": 0,
                    "align2": 0,
                    "timings": [90.0, float(length // 1024)],
                }
                if function == "memcmp":
                    row["result"] = 0
                else:
                    row["dst > src"] = 0
                rows.append(row)
            (directory / f"bench-{function}.out").write_text(
                json.dumps(
                    {
                        "timing_type": "clock_gettime_ns",
                        "functions": {
                            function: {
                                "ifuncs": [f"generic_{function}", function],
                                "results": rows,
                            }
                        },
                    }
                ),
                encoding="utf-8",
            )
        output = tmp_path / f"benchmark_glibc-{architecture}.json"
        result = subprocess.run(
            [
                "python3",
                str(RESULTS_DIR / "parse_benchmark.py"),
                str(directory),
                str(output),
            ],
            env={
                **os.environ,
                "SOFTWARE_VERSION": "2.44",
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
                "TIMING_TYPE_OUTPUT": "clock_gettime_ns",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        normalized = json.loads(output.read_text(encoding="utf-8"))
        assert normalized["variant"] == "base"
        assert len(normalized["results"]) == 4
        parameters.append(normalized["parameters"])
    assert parameters[0] == parameters[1]
    assert not any("boostkit-perf" in json.dumps(parameter) for parameter in parameters)
