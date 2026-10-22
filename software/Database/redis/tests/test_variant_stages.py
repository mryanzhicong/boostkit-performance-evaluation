"""Contract tests for the redis variant-aware stage split."""

from __future__ import annotations

import importlib.util
import json
import os
import re
import subprocess
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
RESULTS_DIR = SCRIPT_DIR / "results"

_SPEC = importlib.util.spec_from_file_location(
    "redis_benchmark_module", RESULTS_DIR / "benchmark_redis.py"
)
assert _SPEC is not None and _SPEC.loader is not None
benchmark_module = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(benchmark_module)


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_redis",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_redis_service",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_redis_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_redis_service",
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
            'source "$1"; build_redis',
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
    assert "optimized redis build is not implemented" in result.stdout
    assert not (tmp_path / "redis-source").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "redis_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _run_faked_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, architecture: str
) -> dict:
    benchmark = tmp_path / "redis-benchmark"
    redis_cli = tmp_path / "redis-cli"
    for binary in (benchmark, redis_cli):
        binary.touch(mode=0o755)
        binary.chmod(0o755)
    raw_output = tmp_path / f"raw-{architecture}.log"
    normalized_output = tmp_path / f"benchmark-{architecture}.json"

    def fake_flush(command: list[str], **_: object) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(command, 0, "OK\n", "")

    def fake_benchmark(
        binary: Path, port: int, clients: int, raw: Path, deadline: float
    ) -> None:
        with raw.open("a", encoding="utf-8") as stream:
            stream.write(
                f"# clients={clients}\n"
                f"SET: {clients * 1000}.50 requests per second\n"
                f"GET: {clients * 1200}.25 requests per second\n"
            )

    monkeypatch.setattr(benchmark_module.subprocess, "run", fake_flush)
    monkeypatch.setattr(benchmark_module, "run_benchmark", fake_benchmark)
    monkeypatch.setattr(
        benchmark_module.sys,
        "argv",
        ["benchmark_redis.py", str(benchmark), str(raw_output), str(normalized_output)],
    )
    monkeypatch.setenv("REDIS_SERVICE_PORT", "30000")
    monkeypatch.setenv("SOFTWARE_VERSION", "7.0.15")
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
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    assert not any(
        "boostkit-perf" in json.dumps(payload["parameters"]) for payload in payloads
    )
