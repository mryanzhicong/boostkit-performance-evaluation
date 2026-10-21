"""Validate the build-variant dispatch contract for the brpc entry scripts."""

import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]


def test_optimized_build_fails_without_running_base_build(tmp_path):
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_brpc',
            "bash",
            str(CASE_DIR / "scripts" / "builders" / "dispatch.sh"),
        ],
        env={**os.environ, "PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "optimized brpc build is not implemented" in completed.stdout
    assert not (tmp_path / "brpc-source").exists()


def test_standalone_variant_option_rejects_unknown_values():
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "brpc_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


def test_stop_stage_is_a_noop_without_a_running_service(tmp_path):
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; stop_brpc_service',
            "bash",
            str(CASE_DIR / "scripts" / "stages" / "stop.sh"),
        ],
        env={
            **os.environ,
            "PERF_RUN_ID": "test-1",
            "PERF_WORK_DIR": str(tmp_path / "work"),
            "RESULTS_DIR": str(tmp_path / "results"),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "no running service to stop" in completed.stdout
