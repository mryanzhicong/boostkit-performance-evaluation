from __future__ import annotations
import os
from pathlib import Path
import subprocess
import pytest

ROOT = Path(__file__).resolve().parents[1]
COMMON = ROOT / "scripts/common.sh"

def shell(code, **env):
    return subprocess.run(["bash", "-c", f'source "{COMMON}"; {code}'],
                          env=os.environ | env, capture_output=True, text=True)

def test_optimized_does_not_fall_back(tmp_path):
    p = shell("configure_runtime_paths", PERF_VARIANT="optimized", RESULTS_DIR=str(tmp_path))
    assert p.returncode == 10
    assert not (tmp_path / "build_variant.json").exists()

def test_wrong_image_architecture_is_rejected():
    assert shell("validate_image_architecture amd64", EXPECTED_ARCH="aarch64").returncode == 30
    assert shell("validate_image_architecture arm64", EXPECTED_ARCH="aarch64").returncode == 0

def test_refuses_results_inside_work_directory():
    p = shell("configure_runtime_paths", PERF_WORK_DIR="/home/runner/boostkit-perf/spark/unit",
              RESULTS_DIR="/home/runner/boostkit-perf/spark/unit/results")
    assert p.returncode == 10

def test_cleanup_is_idempotent_if_no_container():
    p = shell('docker() { return 1; }; remove_spark_container')
    assert p.returncode == 0

def test_cleanup_refuses_unrelated_container():
    p = shell('docker() { if [[ "$1" == container ]]; then return 0; fi; echo other-run; }; remove_spark_container')
    assert p.returncode == 70

def test_cleanup_removes_owned_container_even_when_collection_fails(tmp_path):
    p = shell('docker() { if [[ "$1" == inspect ]]; then echo unit; else echo "$*" >> "$CALLS"; fi; }; '
              'container_exec() { return 1; }; remove_spark_container',
              PERF_RUN_ID="unit", CALLS=str(tmp_path / "calls"))
    assert p.returncode == 70
    calls = (tmp_path / "calls").read_text()
    assert "stop --time 30 boostkit-spark-" in calls and "rm boostkit-spark-" in calls

@pytest.mark.parametrize("work", ["/", "/home/runner/boostkit-perf/other/task",
                                  "/home/runner/boostkit-perf/spark/../other"])
def test_private_path_guard(work):
    p = shell("configure_runtime_paths", PERF_WORK_DIR=work)
    assert p.returncode == 10
