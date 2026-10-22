"""Deployment errors must survive the workflow's work-directory cleanup."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT = CASE_DIR / "oceanbase_test.sh"
COMMON = CASE_DIR / "scripts" / "common.sh"
BASE = CASE_DIR / "scripts" / "builders" / "base.sh"
TRACE_ID = "3695df80-c6d8-11f1-8e0c-20fadb934f02"


def run_shell(tmp_path: Path, command: str, helpers: dict[str, str]) -> subprocess.CompletedProcess[str]:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    for name, script in helpers.items():
        binary = bin_dir / name
        binary.write_text(f"#!/bin/sh\n{script}\n", encoding="utf-8")
        binary.chmod(0o755)
    return subprocess.run(
        ["bash", "-c",
         f'source "$1"; source "$2"; configure_runtime_paths; {command}',
         "bash", str(SCRIPT), str(BASE)],
        env={**os.environ, "PERF_WORK_DIR": str(tmp_path / "work"),
             "RESULTS_DIR": str(tmp_path / "results"),
             "PATH": f"{bin_dir}:{os.environ['PATH']}"},
        capture_output=True,
        text=True,
        check=False,
    )


def test_obd_and_obshell_errors_are_saved_and_passwords_redacted(tmp_path: Path) -> None:
    work = tmp_path / "work"
    work.mkdir()
    results = tmp_path / "results"
    results.mkdir()
    (work / "ob-root-password").write_text("secret123", encoding="utf-8")
    (work / "obd-deploy.log").write_text(f"Trace ID: {TRACE_ID}\n", encoding="utf-8")
    obshell_dir = work / "ob" / "oceanbase-ce" / "log" / "log_obshell"
    obshell_dir.mkdir(parents=True)
    (obshell_dir / "obshell.log").write_text(
        "take over failed password=secret123\n", encoding="utf-8"
    )
    result = run_shell(
        tmp_path, 'collect_deployment_diagnostics "$PERF_WORK_DIR/obd-deploy.log"',
        {"obd": 'echo "trace error password=secret123 -p\'another-secret\'"'},
    )
    assert result.returncode == 0, result.stderr
    trace = (results / "obd-trace.log").read_text(encoding="utf-8")
    obshell = (results / "obshell-diagnostic.log").read_text(encoding="utf-8")
    assert "trace error" in trace
    assert "take over failed" in obshell
    assert "secret123" not in trace + obshell
    assert "another-secret" not in trace


def test_proxy_connection_error_is_not_discarded(tmp_path: Path) -> None:
    work = tmp_path / "work"
    work.mkdir()
    results = tmp_path / "results"
    results.mkdir()
    (work / "ob-root-password").write_text("secret123", encoding="utf-8")
    result = run_shell(
        tmp_path, "capture_proxy_connection_error",
        {"mysql": 'echo "ERROR 1045: Access denied password=secret123" >&2; exit 1'},
    )
    assert result.returncode == 1
    message = (results / "obproxy-connection-error.log").read_text(encoding="utf-8")
    assert "ERROR 1045" in message
    assert "secret123" not in message + result.stdout


def test_sys_tenant_memory_is_increased_and_verified(tmp_path: Path) -> None:
    result = run_shell(
        tmp_path,
        "ob_mysql() { case \"$*\" in *ALTER*) return 0 ;; *SELECT*) printf '17179869184\\n' ;; esac; }; "
        "configure_sys_tenant_memory",
        {},
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "setting sys tenant memory to 16G" in result.stdout

    rejected = run_shell(
        tmp_path / "rejected",
        "ob_mysql() { case \"$*\" in *ALTER*) return 0 ;; *SELECT*) printf '1073741824\\n' ;; esac; }; "
        "configure_sys_tenant_memory",
        {},
    )
    assert rejected.returncode == 40
    assert "sys tenant memory quota is 1073741824" in rejected.stdout


def test_test_tenant_memory_is_fixed_and_checked_before_creation(tmp_path: Path) -> None:
    base_script = BASE.read_text(encoding="utf-8")
    assert '"--memory-size=${OB_TEST_TENANT_MEMORY}"' in base_script
    assert "check_test_tenant_memory || return $?" in base_script

    available = run_shell(
        tmp_path,
        "ob_mysql() { printf '42949672960\\n'; }; check_test_tenant_memory",
        {},
    )
    assert available.returncode == 0, available.stdout + available.stderr
    assert "32G test tenant" in available.stdout

    insufficient = run_shell(
        tmp_path / "insufficient",
        "ob_mysql() { printf '33285996544\\n'; }; check_test_tenant_memory",
        {},
    )
    assert insufficient.returncode == 40
    assert "observer has only 33285996544 available bytes" in insufficient.stdout


def test_log_disk_is_sized_and_checked_before_tenant_creation(tmp_path: Path) -> None:
    common_script = COMMON.read_text(encoding="utf-8")
    base_script = BASE.read_text(encoding="utf-8")
    assert 'OB_LOG_DISK_SIZE="128G"' in common_script
    assert '"--oceanbase-ce.log_disk_size=${OB_LOG_DISK_SIZE}"' in base_script
    assert base_script.index("check_test_tenant_log_disk || return $?") < base_script.index(
        'obd cluster tenant create demo -n test'
    )

    available = run_shell(
        tmp_path,
        "ob_mysql() { printf '132070244352\\n'; }; check_test_tenant_log_disk",
        {},
    )
    assert available.returncode == 0, available.stdout + available.stderr
    assert "needs 103079215104" in available.stdout

    insufficient = run_shell(
        tmp_path / "insufficient-log-disk",
        "ob_mysql() { printf '9663676416\\n'; }; check_test_tenant_log_disk",
        {},
    )
    assert insufficient.returncode == 40
    assert "observer has only 9663676416 available bytes" in insufficient.stdout


def test_data_file_is_sized_and_verified_before_tenant_creation(tmp_path: Path) -> None:
    common_script = COMMON.read_text(encoding="utf-8")
    base_script = BASE.read_text(encoding="utf-8")
    assert 'OB_DATAFILE_SIZE="512G"' in common_script
    assert '"--oceanbase-ce.datafile_size=${OB_DATAFILE_SIZE}"' in base_script
    assert base_script.index("check_observer_data_disk || return $?") < base_script.index(
        'obd cluster tenant create demo -n test'
    )

    available = run_shell(
        tmp_path,
        "ob_mysql() { printf '549755813888\\n'; }; check_observer_data_disk",
        {},
    )
    assert available.returncode == 0, available.stdout + available.stderr
    assert "observer data disk capacity is 549755813888" in available.stdout

    insufficient = run_shell(
        tmp_path / "insufficient-data-disk",
        "ob_mysql() { printf '8589934592\\n'; }; check_observer_data_disk",
        {},
    )
    assert insufficient.returncode == 40
    assert "observer data disk capacity is 8589934592 bytes" in insufficient.stdout


def test_deployment_checks_filesystem_before_installing(tmp_path: Path) -> None:
    base_script = BASE.read_text(encoding="utf-8")
    assert base_script.index("check_deployment_disk_space || return $?") < base_script.index(
        "install_oceanbase_dependencies || return $?"
    )

    available = run_shell(
        tmp_path,
        "check_deployment_disk_space",
        {"df": "printf 'Avail\\n858993459200\\n'"},
    )
    assert available.returncode == 0, available.stdout + available.stderr

    insufficient = run_shell(
        tmp_path / "insufficient-physical-disk",
        "check_deployment_disk_space",
        {"df": "printf 'Avail\\n536870912000\\n'"},
    )
    assert insufficient.returncode == 40
    assert "deployment needs at least 721554505728 bytes" in insufficient.stdout


def test_service_logs_survive_stop_and_are_redacted(tmp_path: Path) -> None:
    work = tmp_path / "work"
    results = tmp_path / "results"
    results.mkdir()
    (work / "ob-root-password").parent.mkdir(parents=True)
    (work / "ob-root-password").write_text("secret123", encoding="utf-8")
    observer = work / "ob" / "oceanbase-ce" / "log" / "observer.log.wf"
    proxy = work / "ob" / "obproxy-ce" / "run" / "log_obproxy" / "obproxy.log"
    for path, message in ((observer, "observer connection rejected"),
                          (proxy, "proxy handshake failed")):
        path.parent.mkdir(parents=True)
        path.write_text(f"{message} password=secret123\n", encoding="utf-8")
    result = run_shell(
        tmp_path, "stop_oceanbase_service",
        {"obd": f'rm -rf -- "{work / "ob"}"'},
    )
    assert result.returncode == 0, result.stderr
    assert not (work / "ob").exists()
    observer_log = (results / "oceanbase-ce-diagnostic.log").read_text(encoding="utf-8")
    proxy_log = (results / "obproxy-ce-diagnostic.log").read_text(encoding="utf-8")
    assert "observer connection rejected" in observer_log
    assert "proxy handshake failed" in proxy_log
    assert "secret123" not in observer_log + proxy_log
