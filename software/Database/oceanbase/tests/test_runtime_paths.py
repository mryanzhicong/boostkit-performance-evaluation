"""Keep OceanBase's task-private obshell socket within Linux's path limit."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "oceanbase_test.sh"


def test_runner_deployment_socket_fits() -> None:
    for architecture in ("aarch64", "x86_64"):
        work_dir = (
            f"/home/runner/boostkit-perf/oceanbase/4.2.5.6/"
            f"{architecture}/38360609746-1"
        )
        completed = subprocess.run(
            ["bash", "-c", 'source "$1"; configure_runtime_paths; printf "%s" "$OB_DEPLOY_HOME"',
             "bash", str(SCRIPT)],
            env={**os.environ, "PERF_WORK_DIR": work_dir},
            capture_output=True,
            text=True,
            check=True,
        )
        assert completed.stdout == f"{work_dir}/ob"
        socket_path = f"{completed.stdout}/oceanbase-ce/run/daemon.sock"
        assert len(socket_path.encode()) <= 107


def test_overlong_socket_path_fails_before_creating_workdir(tmp_path: Path) -> None:
    work_dir = tmp_path / ("long-name-" * 12)
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; initialize_runtime', "bash", str(SCRIPT)],
        env={**os.environ, "PERF_RUN_ID": "path-test", "PERF_WORK_DIR": str(work_dir),
             "RESULTS_DIR": str(tmp_path / "results")},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 20
    assert "obshell Unix socket path" in completed.stdout
    assert not work_dir.exists()
