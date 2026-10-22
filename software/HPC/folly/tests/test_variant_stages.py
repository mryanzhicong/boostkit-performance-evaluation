"""Contract tests for the folly variant-aware stage split."""

from __future__ import annotations

import importlib.util
import json
import os
import re
import subprocess
from pathlib import Path
from types import SimpleNamespace

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
RESULTS_DIR = SCRIPT_DIR / "results"

_SPEC = importlib.util.spec_from_file_location(
    "folly_acclib_module", RESULTS_DIR / "run_acclib.py"
)
assert _SPEC is not None and _SPEC.loader is not None
acclib_module = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(acclib_module)


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_folly",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_folly_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_folly_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_folly_runtime",
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
            re.findall(
                r"^([a-z_]+)\(\)", builder.read_text(encoding="utf-8"), re.MULTILINE
            )
        )
    assert builder_functions
    for stage in sorted((SCRIPT_DIR / "stages").glob("*.sh")):
        content = stage.read_text(encoding="utf-8")
        referenced = {
            name for name in builder_functions if re.search(rf"\b{name}\b", content)
        }
        assert not referenced, (
            f"{stage.name} references builder-only functions: {referenced}"
        )


def test_optimized_build_fails_without_running_base_build(tmp_path: Path) -> None:
    result = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_folly',
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
    assert "optimized folly build is not implemented" in result.stdout
    assert not (tmp_path / "folly-source").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "folly_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _run_faked_matrix(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, architecture: str
) -> dict:
    private_root = tmp_path / "AccLibBenchmark"
    run_py = private_root / "fb_folly_autobuild" / "run.py"
    run_py.parent.mkdir(parents=True, exist_ok=True)
    run_py.write_text("# fixture\n", encoding="utf-8")
    source = private_root / "fbthrift_folly_benchmark"
    for relative in ("CMakeLists.txt", "server/PressServer.cpp",
                     "client/PressTestClient.cpp", "press.thrift"):
        path = source / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(relative, encoding="utf-8")
    binary = tmp_path / "press_client"
    binary.write_text("#!/bin/sh\n", encoding="utf-8")
    binary.chmod(0o755)
    original = SimpleNamespace(
        EXECUTABLE="/reference/press_client",
        PREFIX_CMD=["numactl", "-N", "0", "/reference/press_client",
                    "--host=192.0.2.1", "--port=23456", "--test_seconds=90",
                    "--transport=rocket", "--use_io_uring=false"],
        DATA_SETUPS=[["binary payload", ["--fields=none", "--payload_size=256"]]],
        CONN_SETUPS=[[1, 1, 50]], QD_SETUPS=[10],
        parse_output=lambda _output: {
            "Throughput": "2.50MB/s", "latencyAvg": "11.00",
            "latencyP99": "20.00", "Server CPU (%)": "4.00",
            "Client CPU (%)": "5.00",
        },
    )
    result_path = tmp_path / f"results-{architecture}" / "benchmark_folly.json"

    def fake_run(command, **kwargs):
        return subprocess.CompletedProcess(
            command, 0,
            "Success: 10\nFail: 0\nQPS: 10.00\nThroughput: 2.50MB/s\n"
            "Latency (us): avg=11.00 p99=20.00\nServer CPU (%): avg=4.00\n"
            "Client CPU (%): avg=5.00\n",
            "",
        )

    monkeypatch.setattr(acclib_module.subprocess, "run", fake_run)
    monkeypatch.setattr(acclib_module.time, "sleep", lambda seconds: None)
    monkeypatch.setenv("PERF_VARIANT", "base")
    acclib_module.run(
        original, run_py, binary, 41000, result_path,
        result_path.parent / "press_client_raw", "2022.11.14.00", architecture,
    )
    return json.loads(result_path.read_text(encoding="utf-8"))


def test_normalized_parameters_align_across_architectures(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    payloads = [
        _run_faked_matrix(tmp_path, monkeypatch, architecture)
        for architecture in ("x86_64", "aarch64")
    ]
    assert payloads[0]["variant"] == "base"
    assert len(payloads[0]["results"]) == 8
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    assert not any(
        "boostkit-perf" in json.dumps(payload["parameters"]) for payload in payloads
    )
