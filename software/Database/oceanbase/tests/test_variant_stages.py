"""Contract tests for the oceanbase variant-aware stage split."""

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
    "oceanbase_benchmark_module", RESULTS_DIR / "benchmark_ob.py"
)
assert _SPEC is not None and _SPEC.loader is not None
benchmark_module = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(benchmark_module)


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_oceanbase",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_oceanbase_service",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_oceanbase_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_oceanbase_service",
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
            'source "$1"; build_oceanbase',
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
    assert "optimized oceanbase build is not implemented" in result.stdout
    assert not (tmp_path / "ob").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "oceanbase_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _run_faked_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, architecture: str
) -> dict:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    sysbench = bin_dir / "sysbench"
    sysbench.write_text(
        "#!/bin/sh\n"
        "printf '%s\\n' \"$@\"\n"
        "case \" $* \" in *' run '*)\n"
        "printf '%s\\n' 'transactions: 600 (20.00 per sec.)' "
        "'queries: 3000 (100.00 per sec.)' 'avg: 2.50' "
        "'95th percentile: 4.00' ;; esac\n",
        encoding="utf-8",
    )
    sysbench.chmod(0o755)
    lua_dir = tmp_path / "lua"
    lua_dir.mkdir(parents=True, exist_ok=True)
    (lua_dir / "oltp_insert.lua").write_text("", encoding="utf-8")
    results_dir = tmp_path / f"results-{architecture}"

    monkeypatch.setattr(benchmark_module, "WORKLOADS", ("insert",))
    monkeypatch.setattr(benchmark_module, "THREADS", (64,))
    monkeypatch.setattr(
        benchmark_module.sys,
        "argv",
        [str(RESULTS_DIR / "benchmark_ob.py"), "--host", "127.0.0.1", "--port",
         "2883", "--user", "root@test#demo", "--database", "obtest",
         "--results-dir", str(results_dir)],
    )
    monkeypatch.setenv("SYSBENCH_BIN", str(sysbench))
    monkeypatch.setenv("SYSBENCH_LUA_DIR", str(lua_dir))
    monkeypatch.setenv("SOFTWARE_VERSION", "4.2.5.6")
    monkeypatch.setenv("OB_PROXY_VERSION", "4.3.6.1")
    monkeypatch.setenv("EXPECTED_ARCH", architecture)
    monkeypatch.setenv("PERF_VARIANT", "base")
    assert benchmark_module.main() == 0
    payload = json.loads(
        (results_dir / "results.json").read_text(encoding="utf-8")
    )
    return payload


def test_normalized_parameters_align_across_architectures(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    payloads = [
        _run_faked_main(tmp_path, monkeypatch, architecture)
        for architecture in ("x86_64", "aarch64")
    ]
    assert payloads[0]["variant"] == "base"
    assert len(payloads[0]["results"]) == 4
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    assert not any(
        "boostkit-perf" in json.dumps(payload["parameters"]) for payload in payloads
    )
