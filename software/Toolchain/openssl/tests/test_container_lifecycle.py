"""Keep every framework stage on the same task-owned container."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

CASE = Path(__file__).resolve().parents[1]
SCRIPTS = CASE / "scripts"
FIXTURES = json.loads((CASE / "fixtures" / "scenarios.json").read_text(encoding="utf-8"))


def read(path: str) -> str:
    return (SCRIPTS / path).read_text(encoding="utf-8")


def test_only_build_loads_image_and_starts_container() -> None:
    build = read("builders/base.sh")
    start = read("stages/start.sh")
    test = read("stages/test.sh")
    stop = read("stages/stop.sh")

    assert "require_openssl_docker" in build
    assert "start_openssl_container" in build
    assert "require_openssl_docker" not in start + test
    assert "start_openssl_container" not in start + test
    assert "check_openssl_container" in start
    assert "check_openssl_container" in test
    assert "remove_openssl_container" in stop


def test_build_runs_inside_the_container() -> None:
    build = read("builders/base.sh")
    for needle in (
        "openssl_container_exec_root dnf install",
        "openssl_container_exec tar xzf",
        'openssl_container_exec_at "${src}" ./Configure no-shared',
        "make install_sw",
        'openssl_container_exec "$(openssl_bin)" speed -mr -seconds 1',
    ):
        assert needle in build, needle
    # OpenSSL cannot build out of tree, so Configure/make run with the source
    # tree as the working directory inside the container.
    assert 'openssl_container_exec_at "${src}" bash -c \'make -j"$(nproc)"\'' in build


def test_every_scenario_runs_through_docker_exec() -> None:
    test = read("stages/test.sh")
    common = read("common.sh")
    for scenario in FIXTURES["scenarios"]:
        assert scenario["name"] in common
        assert " ".join(scenario["args"]) in common
    assert "openssl_container_exec timeout 900" in test
    assert 'speed -mr -seconds "${OPENSSL_SPEED_SECONDS}"' in test
    assert '-bytes "${OPENSSL_BLOCK_BYTES}"' in test
    # stdout and stderr stay in separate files; each measured round is its own
    # process so a stuck run cannot poison the other scenarios.
    assert '2> "${err}"' in test


def test_workload_is_pinned_and_not_overridable() -> None:
    common = read("common.sh")
    assert "OPENSSL_SPEED_SECONDS=2" in common
    assert "OPENSSL_BLOCK_BYTES=16384" in common
    assert 'OPENSSL_SPEED_SECONDS="${OPENSSL_SPEED_SECONDS' not in common
    assert 'OPENSSL_BLOCK_BYTES="${OPENSSL_BLOCK_BYTES' not in common
    assert FIXTURES["seconds"] == 2
    assert FIXTURES["block_bytes"] == 16384


def test_optimized_fails_explicitly() -> None:
    optimized = read("builders/optimized.sh")
    assert "return 30" in optimized
    assert "not implemented" in optimized
    assert "base" in optimized


def test_stop_is_idempotent_and_guarded() -> None:
    stop = read("stages/stop.sh")
    assert "remove_openssl_container" in stop
    assert "command -v docker" in stop
    assert "still exists after cleanup" in stop
    assert "rm -rf" not in stop


def test_no_hardcoded_cpu_pinning() -> None:
    for relative in ("builders/base.sh", "stages/start.sh", "stages/test.sh"):
        text = read(relative)
        assert "taskset" not in text
        assert "numactl" not in text
        assert "--cpuset" not in text


def test_standalone_rejects_unknown_variant(tmp_path) -> None:
    result = subprocess.run(
        ["bash", str(CASE / "openssl_test.sh"), "--variant", "bogus",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "unsupported build variant" in result.stdout + result.stderr


def test_standalone_rejects_unsupported_version(tmp_path) -> None:
    result = subprocess.run(
        ["bash", str(CASE / "openssl_test.sh"), "--version", "4.0.0",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "only openssl 4.1.0 is supported" in result.stdout + result.stderr


def test_standalone_help_and_unknown_option_do_not_start_the_case() -> None:
    help_result = subprocess.run(
        ["bash", str(CASE / "openssl_test.sh"), "--help"],
        text=True, capture_output=True, check=False, timeout=30,
    )
    assert help_result.returncode == 0, help_result.stdout + help_result.stderr
    assert "Usage:" in help_result.stdout
    # the usage text must stay a literal: unquoted backticks would execute `openssl speed`
    assert "+DT:" not in help_result.stdout + help_result.stderr

    bad_result = subprocess.run(
        ["bash", str(CASE / "openssl_test.sh"), "--nonsense"],
        text=True, capture_output=True, check=False, timeout=30,
    )
    assert bad_result.returncode == 10, bad_result.stdout + bad_result.stderr
    assert "unsupported option" in bad_result.stdout + bad_result.stderr


def test_sampling_contract_matches_readme() -> None:
    test = read("stages/test.sh")
    assert "PERF_REPS=5" not in test  # default lives in common.sh
    common = read("common.sh")
    assert 'PERF_REPS="${PERF_REPS:-5}"' in common
    assert 'OPENSSL_WARMUPS="${OPENSSL_WARMUPS:-1}"' in common
    assert "below the 5-sample contract" in test
    assert FIXTURES["warmups"] == 1
    assert FIXTURES["reps"] == 5


def test_case_yaml_declares_the_contract() -> None:
    yaml = pytest.importorskip("yaml")
    case = yaml.safe_load((CASE / "case.yaml").read_text(encoding="utf-8"))
    assert case["name"] == "openssl"
    assert case["category"] == "Toolchain"
    assert case["versions"] == ["4.1.0"]
    assert case["execution"]["timeout_minutes"] >= 120
    assert case["metrics"]["source"] == "benchmark_result"
    assert case["metrics"]["collection"] == {
        "path": "results",
        "value_path": "value",
        "unit_path": "unit",
        "direction_path": "direction",
        "group_path": "group",
    }
    outputs = case["outputs"]
    assert outputs["benchmark_result"]["path"] == "speed_result.json"
    assert outputs["benchmark_result"]["required"] is True
    assert outputs["raw_output"]["path"] == "raw-output.log"
    assert outputs["run_samples"]["path"] == "runs"
    assert outputs["run_samples"]["format"] == "directory"


def test_readme_lists_the_sixteen_metrics() -> None:
    readme = (CASE / "README.md").read_text(encoding="utf-8")
    names = [metric for scenario in FIXTURES["scenarios"]
             for metric in scenario["metrics"].values()]
    assert len(names) == 16
    for name in names:
        assert f"`{name}`" in readme, name
    assert "指标总数 **16 项**" in readme
