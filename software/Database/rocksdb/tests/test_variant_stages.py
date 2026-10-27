"""Contract tests for the rocksdb variant-aware stage split."""

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
    "rocksdb_run_ycsb_module", RESULTS_DIR / "run_ycsb.py"
)
assert _SPEC is not None and _SPEC.loader is not None
benchmark_module = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(benchmark_module)


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_rocksdb",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "prepare_rocksdb_benchmark_data",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_rocksdb_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "cleanup_rocksdb_benchmark_data",
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
            'source "$1"; build_rocksdb',
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
    assert "optimized rocksdb build is not implemented" in result.stdout
    assert not (tmp_path / "rocksdb-source").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "rocksdb_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _run_faked_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, architecture: str
) -> dict:
    distribution = tmp_path / "ycsb-dist"
    (distribution / "bin").mkdir(parents=True, exist_ok=True)
    (distribution / "lib").mkdir(parents=True, exist_ok=True)
    (distribution / "workloads").mkdir(parents=True, exist_ok=True)
    for workload in benchmark_module.WORKLOADS:
        (distribution / "workloads" / workload).write_text(workload, encoding="utf-8")
    (distribution / "lib" / "rocksdbjni-6.26.1.jar").write_bytes(b"fixture")
    (distribution / "bin" / "ycsb").write_text("#!/bin/sh\n", encoding="utf-8")
    raw_output = tmp_path / f"raw-{architecture}.log"
    normalized_output = tmp_path / f"results-{architecture}.json"

    def fake_run_phase(
        distribution: Path,
        action: str,
        workload: str,
        threads: int,
        data_dir: Path,
        raw_log: object,
        phase: str,
    ) -> float:
        data_dir.mkdir(parents=True, exist_ok=True)
        return 200.5

    monkeypatch.setattr(benchmark_module, "run_phase", fake_run_phase)
    monkeypatch.setattr(
        benchmark_module.subprocess,
        "run",
        lambda *args, **kwargs: SimpleNamespace(returncode=0, stderr='openjdk version "11.0.1"\n', stdout=""),
    )
    monkeypatch.setattr(
        benchmark_module.sys,
        "argv",
        ["run_ycsb.py", str(distribution), str(normalized_output), str(raw_output)],
    )
    monkeypatch.setenv("PERF_WORK_DIR", str(tmp_path))
    monkeypatch.setenv("ROCKSDB_BENCH_DATA_DIR", str(tmp_path / f"data-{architecture}"))
    monkeypatch.setenv("SOFTWARE_VERSION", "6.26.1")
    monkeypatch.setenv("EXPECTED_ARCH", architecture)
    monkeypatch.setenv("PERF_VARIANT", "base")
    assert benchmark_module.main() == 0
    payload = json.loads(normalized_output.read_text(encoding="utf-8"))
    return payload


def test_normalized_parameters_align_across_architectures(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    payloads = [
        _run_faked_main(tmp_path, monkeypatch, architecture)
        for architecture in ("x86_64", "aarch64")
    ]
    assert payloads[0]["variant"] == "base"
    assert len(payloads[0]["results"]) == 6
    assert payloads[0]["parameters"]["recordcount"] == 10_000_000
    assert payloads[0]["parameters"]["operationcount"] == 5_000_000
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    assert not any(
        "boostkit-perf" in json.dumps(payload["parameters"]) for payload in payloads
    )
