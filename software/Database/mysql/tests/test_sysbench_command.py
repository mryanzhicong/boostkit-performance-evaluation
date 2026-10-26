"""Keep the private Sysbench binary paired with its own Lua workloads."""

import hashlib
import os
import subprocess
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
TEST_SH = CASE_DIR / "scripts" / "stages" / "test.sh"
START_SH = CASE_DIR / "scripts" / "stages" / "start.sh"
STOP_SH = CASE_DIR / "scripts" / "stages" / "stop.sh"


def test_run_sysbench_uses_private_lua_workload(tmp_path: Path) -> None:
    fake_sysbench = tmp_path / "sysbench"
    fake_sysbench.write_text(
        '#!/bin/sh\nprintf "LUA_PATH=%s\\n" "$LUA_PATH"\n'
        'printf "ARG=%s\\n" "$@"\n',
        encoding="utf-8",
    )
    fake_sysbench.chmod(0o755)
    lua_directory = tmp_path / "src" / "lua"
    results = tmp_path / "results"
    environment = os.environ | {
        "TEST_SCRIPT": str(COMMON),
        "TEST_BIN": str(fake_sysbench),
        "TEST_LUA_DIR": str(lua_directory),
        "TEST_RESULTS_DIR": str(results),
    }
    completed = subprocess.run(
        [
            "bash", "-c",
            'source "$TEST_SCRIPT"; SYSBENCH_BIN="$TEST_BIN"; '
            'SYSBENCH_LUA_DIR="$TEST_LUA_DIR"; RESULTS_DIR="$TEST_RESULTS_DIR"; '
            'mkdir -p "$RESULTS_DIR/sysbench-runs"; '
            'run_sysbench read_write 2 0 prepare',
        ],
        env=environment,
        capture_output=True,
        text=True,
        check=True,
    )
    assert f"LUA_PATH={lua_directory}/?.lua;;" in completed.stdout
    assert f"ARG={lua_directory}/oltp_read_write.lua" in completed.stdout
    assert "ARG=prepare" in completed.stdout
    assert "ARG=--table_size=10000000" in completed.stdout
    assert "ARG=--tables=64" in completed.stdout


def test_formal_sysbench_runs_highest_thread_count_first() -> None:
    assert "threads_for_scenario=(256 128 32 1)" in TEST_SH.read_text(encoding="utf-8")


def test_instance_resources_are_numbered_and_only_one_is_enabled(tmp_path: Path) -> None:
    environment = os.environ | {
        "PERF_WORK_DIR": str(tmp_path),
        "PERF_RUN_ID": "unit-test",
        "RESULTS_DIR": str(tmp_path / "results"),
        "EXPECTED_ARCH": os.uname().machine,
        "MYSQL_PORT": "3307",
    }
    script = (
        f'source "{COMMON}"; initialize_runtime; '
        'printf "%s|%s|%s|%s|%s\n" "$MYSQL_INSTANCE_COUNT" "$MYSQL_PORT" '
        '"$SERVICE_DIR" "$MYSQL_SNAPSHOT_DIR" "$MYSQL_CONTAINER_NAME"; '
        'if configure_mysql_instance 2 >/dev/null; then exit 90; fi; '
        'MYSQL_INSTANCE_COUNT=2; configure_mysql_instance 2; '
        'printf "%s|%s|%s|%s\n" "$MYSQL_PORT" "$SERVICE_DIR" '
        '"$MYSQL_SNAPSHOT_DIR" "$MYSQL_CONTAINER_NAME"'
    )
    completed = subprocess.run(
        ["bash", "-c", script], env=environment, capture_output=True, text=True,
        check=True,
    )
    first, second = completed.stdout.splitlines()
    assert first == (
        f"1|3307|{tmp_path}/instances/1|{tmp_path}/instances/1/snapshot|"
        f"boostkit-mysql-{os.uname().machine}-unit-test-1"
    )
    assert second == (
        f"3308|{tmp_path}/instances/2|{tmp_path}/instances/2/snapshot|"
        f"boostkit-mysql-{os.uname().machine}-unit-test-2"
    )


def test_stop_cleans_only_enabled_instance(tmp_path: Path) -> None:
    instance_one = tmp_path / "instances" / "1"
    instance_two = tmp_path / "instances" / "2"
    instance_one.mkdir(parents=True)
    instance_two.mkdir(parents=True)
    (instance_one / "data-marker").write_text("one", encoding="utf-8")
    (instance_two / "data-marker").write_text("two", encoding="utf-8")
    environment = os.environ | {
        "PERF_WORK_DIR": str(tmp_path),
        "PERF_RUN_ID": "unit-test",
        "RESULTS_DIR": str(tmp_path / "results"),
        "EXPECTED_ARCH": os.uname().machine,
    }
    completed = subprocess.run(
        [
            "bash", "-c",
            f'source "{STOP_SH}"; '
            'shutdown_mysql_server() { return 0; }; '
            'remove_mysql_container() { return 0; }; '
            'stop_mysql_service',
        ],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert not instance_one.exists()
    assert (instance_two / "data-marker").read_text(encoding="utf-8") == "two"


def test_start_visits_only_instance_one(tmp_path: Path) -> None:
    bin_dir = tmp_path / "mysql" / "bin"
    bin_dir.mkdir(parents=True)
    for name in ("mysqld", "mysql"):
        binary = bin_dir / name
        binary.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        binary.chmod(0o755)
    environment = os.environ | {
        "PERF_WORK_DIR": str(tmp_path),
        "PERF_RUN_ID": "unit-test",
        "RESULTS_DIR": str(tmp_path / "results"),
        "EXPECTED_ARCH": os.uname().machine,
    }
    completed = subprocess.run(
        [
            "bash", "-c",
            f'source "{START_SH}"; '
            'start_mysql_instance() { printf "%s|%s\n" "$MYSQL_INSTANCE_ID" "$SERVICE_DIR"; }; '
            'start_mysql_service',
        ],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert completed.stdout.splitlines() == [f"1|{tmp_path}/instances/1"]
    assert not (tmp_path / "instances" / "2").exists()


def test_single_container_is_limited_and_keeps_sysbench_on_host(tmp_path: Path) -> None:
    archive_name = f"openEuler-docker.{os.uname().machine}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"test image archive")
    (tmp_path / f"{archive_name}.sha256sum").write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'case "$1 $2" in\n'
        '  "container inspect") exit 1 ;;\n'
        '  "image inspect") if [ "$3" = "--format" ]; then printf "%s\\n" "$DOCKER_TEST_ARCH"; fi; exit 0 ;;\n'
        'esac\n'
        'if [ "$1" = info ]; then exit 0; fi\n'
        'if [ "$1" = load ]; then printf "Loaded image: openeuler-24.03-lts-sp4:latest\\n"; exit 0; fi\n'
        'if [ "$1" = run ] && [ "$2" = --rm ]; then printf "ID=\\\"openEuler\\\"\\nVERSION=\\\"24.03 (LTS-SP4)\\\"\\n"; exit 0; fi\n'
        'if [ "$1" = run ]; then printf "test-container-id\\n"; exit 0; fi\n'
        'if [ "$1" = exec ]; then exit 0; fi\n'
        'exit 1\n', encoding="utf-8"
    )
    fake_docker.chmod(0o755)
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_WORK_DIR": str(tmp_path),
        "PERF_RUN_ID": "unit-test",
        "RESULTS_DIR": str(tmp_path / "results"),
        "EXPECTED_ARCH": os.uname().machine,
        "MYSQL_IMAGE_ARCHIVE_DIR": str(tmp_path),
        "DOCKER_TEST_ARCH": "amd64" if os.uname().machine == "x86_64" else "arm64",
    }
    completed = subprocess.run(
        ["bash", "-c", f'source "{COMMON}"; select_container_cpu_set() {{ printf "288-383 3\\n"; }}; initialize_runtime; require_mysql_container'],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "--cpus=8" in calls
    assert "--memory=32g" in calls
    assert "--cpuset-cpus=288-383" in calls
    assert "--cpuset-mems=3" in calls
    assert "--network=host" in calls
    assert f"source={tmp_path},target={tmp_path}" in calls
    assert f"load --input {archive}" in calls
    assert "pull" not in calls
    assert "sysbench" not in calls


def test_rejects_wrong_openeuler_image_release(tmp_path: Path) -> None:
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "ID=\\\"openEuler\\\"\\nVERSION=\\\"22.03 (LTS-SP4)\\\"\\n"\n',
        encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    completed = subprocess.run(
        ["bash", "-c", f'source "{COMMON}"; MYSQL_CONTAINER_IMAGE=old-image; verify_mysql_image_release'],
        env=os.environ | {"PATH": f"{tmp_path}:{os.environ['PATH']}"},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "not openEuler 24.03 LTS SP4" in completed.stdout


@pytest.mark.parametrize("mode", ["prepare", "benchmark"])
def test_mysql_launch_sets_and_checks_prepared_statement_limit(tmp_path: Path, mode: str) -> None:
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'if [ "$1" = inspect ]; then printf "true\\n"; exit 0; fi\n'
        'if [ "$1" = exec ]; then shift 2; "$@"; exit $?; fi\n'
        'exit 1\n', encoding="utf-8"
    )
    fake_docker.chmod(0o755)
    fake_mysqld = tmp_path / "mysqld"
    fake_mysqld.write_text('#!/bin/sh\nprintf "ARG=%s\\n" "$@"\n', encoding="utf-8")
    fake_mysqld.chmod(0o755)
    fake_mysql = tmp_path / "mysql"
    fake_mysql.write_text('#!/bin/sh\nprintf "%s\\n" "$TEST_EFFECTIVE_LIMIT"\n', encoding="utf-8")
    fake_mysql.chmod(0o755)
    fake_mysqladmin = tmp_path / "mysqladmin"
    fake_mysqladmin.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    fake_mysqladmin.chmod(0o755)
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "TEST_SCRIPT": str(COMMON),
        "TEST_MYSQLD": str(fake_mysqld),
        "TEST_MYSQL": str(fake_mysql),
        "TEST_MYSQLADMIN": str(fake_mysqladmin),
        "TEST_MODE": mode,
        "TEST_EFFECTIVE_LIMIT": "1048576",
        "TEST_ROOT": str(tmp_path),
    }
    command = (
        'source "$TEST_SCRIPT"; MYSQLD_BIN="$TEST_MYSQLD"; MYSQL_BIN="$TEST_MYSQL"; '
        'MYSQLADMIN_BIN="$TEST_MYSQLADMIN"; MYSQL_BASE_DIR="$TEST_ROOT"; '
        'DATADIR="$TEST_ROOT/data"; MYSQL_TMP_DIR="$TEST_ROOT/tmp"; '
        'SOCKET_PATH="$TEST_ROOT/mysql.sock"; PID_FILE="$TEST_ROOT/mysql.pid"; '
        'ERR_LOG="$TEST_ROOT/mysql.err"; MYSQL_HOST=127.0.0.1; MYSQL_PORT=3307; '
        'MYSQL_DB_USER=root; MYSQL_PASSWORD=test-password; '
        'MYSQL_CONTAINER_NAME=test-mysql; '
        'launch_mysql_server "$TEST_MODE"'
    )
    completed = subprocess.run(
        ["bash", "-c", command], env=environment, capture_output=True, text=True
    )
    assert completed.returncode == 0, completed.stderr
    assert "ARG=--max-prepared-stmt-count=1048576" in completed.stdout
    assert "mysqld is ready" in completed.stdout

    environment["TEST_EFFECTIVE_LIMIT"] = "16382"
    completed = subprocess.run(
        ["bash", "-c", command], env=environment, capture_output=True, text=True
    )
    assert completed.returncode != 0
    assert "max_prepared_stmt_count is 16382, expected 1048576" in completed.stdout
