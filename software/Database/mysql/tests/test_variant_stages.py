"""Contract tests for the mysql variant-aware stage split."""

from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path

import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
RESULTS_DIR = SCRIPT_DIR / "results"


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_mysql",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_mysql_service",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_mysql_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_mysql_service",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


def test_stage_scripts_do_not_depend_on_builder_only_functions() -> None:
    """Framework stages run standalone; they must not call builder-only helpers."""
    builder_functions: set[str] = set()
    for builder in sorted((SCRIPT_DIR / "builders").glob("*.sh")):
        builder_functions.update(
            re.findall(r"^([a-z_]+)\(\)", builder.read_text(encoding="utf-8"), re.MULTILINE)
        )
    assert builder_functions
    for stage in sorted((SCRIPT_DIR / "stages").glob("*.sh")):
        content = stage.read_text(encoding="utf-8")
        referenced = {
            name for name in builder_functions if re.search(rf"\b{name}\b", content)
        }
        assert not referenced, f"{stage.name} references builder-only functions: {referenced}"


def test_optimized_build_fails_without_running_base_build(tmp_path: Path) -> None:
    result = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_mysql',
            "bash",
            str(SCRIPT_DIR / "builders" / "dispatch.sh"),
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
    assert "optimized mysql build is not implemented" in result.stdout
    assert not (tmp_path / "mysql").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "mysql_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        runs_dir = tmp_path / f"sysbench-runs-{architecture}"
        runs_dir.mkdir()
        for scenario in ("read_only", "read_write", "write_only"):
            for threads in (1, 32, 128, 256):
                (runs_dir / f"run-{scenario}-threads{threads}.log").write_text(
                    "transactions: 120 (12.00 per sec.)\n"
                    "queries: 240 (24.00 per sec.)\n"
                    "Latency (ms):\n    95th percentile: 3.14\n",
                    encoding="utf-8",
                )
        output = tmp_path / f"results-{architecture}.json"
        result = subprocess.run(
            [
                "python3",
                str(RESULTS_DIR / "collect_sysbench.py"),
                str(runs_dir),
                str(output),
            ],
            env={
                **os.environ,
                "SOFTWARE_VERSION": "8.0.43",
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        normalized = json.loads(output.read_text(encoding="utf-8"))
        assert normalized["variant"] == "base"
        assert len(normalized["results"]) == 36
        parameters.append(normalized["parameters"])
    assert parameters[0] == parameters[1]
    assert not any(
        "boostkit-perf" in json.dumps(parameter) for parameter in parameters
    )
