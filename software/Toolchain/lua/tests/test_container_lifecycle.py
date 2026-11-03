"""Check the Lua container lifecycle without a live Docker daemon."""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path


CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"

FAKE_DOCKER = """#!/bin/sh
printf '%s\\n' "$*" >> "$DOCKER_CALLS"
mode="${FAKE_DOCKER_MODE:-start}"
case "$1 $2" in
    "info ")
        exit 0
        ;;
    "load --input")
        printf 'Loaded image: openeuler-test:latest\\n'
        exit 0
        ;;
    "image inspect")
        case "$*" in
            *--format*) printf '%s\\n' "${IMAGE_ARCH:-amd64}" ;;
        esac
        exit 0
        ;;
    "container inspect")
        if [ "${mode}" = "start" ]; then exit 1; fi
        exit 0
        ;;
    "ps -a")
        exit 0
        ;;
    "run --rm")
        printf 'ID="openEuler"\\nVERSION_ID="24.03"\\n'
        exit 0
        ;;
    "inspect --format")
        case "$*" in
            *Label*|*label*) printf '%s\\n' "${FAKE_RUN_LABEL:-unit-test}" ;;
            *Running*) printf '%s\\n' "${FAKE_CONTAINER_RUNNING:-true}" ;;
        esac
        exit 0
        ;;
    "stop --time"|"rm --force")
        exit 0
        ;;
esac
case "$1" in
    exec|run|stop|rm)
        exit 0
        ;;
esac
exit 0
"""


def _make_archive(tmp_path: Path, corrupt: bool = False) -> str:
    architecture = os.uname().machine
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    (tmp_path / f"{archive_name}.sha256sum").write_text(
        f"{'0' * 64 if corrupt else digest}  {archive_name}\n", encoding="utf-8"
    )
    return archive_name


def _install_fake_docker(tmp_path: Path) -> str:
    docker = tmp_path / "docker"
    docker.write_text(FAKE_DOCKER, encoding="utf-8")
    docker.chmod(0o755)
    return f"{tmp_path}{os.pathsep}{os.environ['PATH']}"


def run_shell(
    script: str, tmp_path: Path, mode: str = "start", **extra: str
) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": _install_fake_docker(tmp_path),
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
        "FAKE_DOCKER_MODE": mode,
    } | extra
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def _case_script(tmp_path: Path, body: str) -> str:
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir(exist_ok=True)
    results.mkdir(exist_ok=True)
    return (
        f'source "{COMMON}"; set +e; export PERF_WORK_DIR="{work}"; '
        f'export RESULTS_DIR="{results}"; '
        f'export LUA_IMAGE_ARCHIVE_DIR="{tmp_path}"; {body}'
    )


def test_image_uses_local_verified_sp4_archive(tmp_path: Path) -> None:
    archive_name = _make_archive(tmp_path)
    script = _case_script(
        tmp_path,
        'prepare_lua_container_image; rc=$?; printf "rc=%s\\n" "${rc}"; '
        'printf "image=%s\\n" "${LUA_CONTAINER_IMAGE}"',
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "rc=0" in completed.stdout
    assert "image=openeuler-test:latest" in completed.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "load --input" in calls

    _make_archive(tmp_path, corrupt=True)
    (tmp_path / archive_name).write_bytes(b"openEuler 24.03 SP4 fixture")
    failed = run_shell(script, tmp_path)
    assert "rc=30" in failed.stdout
    assert "checksum mismatch" in failed.stdout


def test_start_mounts_private_paths_and_labels_container(tmp_path: Path) -> None:
    _make_archive(tmp_path)
    script = _case_script(
        tmp_path,
        'start_lua_container; rc=$?; printf "rc=%s\\n" "${rc}"',
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "rc=0" in completed.stdout
    assert "private container is running" in completed.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "boostkit-lua-x86_64-unit-test" in calls
    assert "boostkit.lua.run-id=unit-test" in calls
    assert f"source={tmp_path / 'work'}" in calls
    assert f"source={tmp_path / 'results'}" in calls

    reuse = run_shell(
        _case_script(tmp_path, 'start_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
        mode="reuse",
    )
    assert "rc=40" in reuse.stdout


def test_check_reports_missing_container_and_remove_refuses_foreign_label(
    tmp_path: Path,
) -> None:
    missing = run_shell(
        _case_script(tmp_path, 'check_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
        FAKE_CONTAINER_RUNNING="false",
    )
    assert "rc=40" in missing.stdout

    running = run_shell(
        _case_script(tmp_path, 'check_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
    )
    assert "rc=0" in running.stdout

    foreign = run_shell(
        _case_script(tmp_path, 'remove_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
        mode="remove",
        FAKE_RUN_LABEL="another-run",
    )
    assert "rc=60" in foreign.stdout
    assert "refusing to remove" in foreign.stdout

    benign = run_shell(
        _case_script(tmp_path, 'remove_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
        mode="remove",
    )
    assert "rc=0" in benign.stdout
    absent = run_shell(
        _case_script(tmp_path, 'remove_lua_container; printf "rc=%s\\n" "$?"'),
        tmp_path,
        mode="start",
    )
    assert "rc=0" in absent.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-lua-x86_64-unit-test" in calls
    assert "rm boostkit-lua-x86_64-unit-test" in calls
