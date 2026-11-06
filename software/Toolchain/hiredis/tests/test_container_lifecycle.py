"""Check the hiredis container lifecycle without a live Docker daemon.

hiredis runs its build, fixture generation and every measured parser/formatting
process inside a per-run openEuler 24.03 LTS SP4 container.  These tests replace
``docker`` with a recording shim placed first on ``PATH`` so the contract can be
checked on a machine without a daemon:

* the container name/label carry the run id and the software prefix, mounts the
  shared work/result directories and is not privileged (only CAP_SYS_ADMIN for
  the optional network-namespace isolation);
* the image archive is loaded from the verified local archive and a corrupted
  checksum fails the build (exit 30) instead of silently using the archive;
* removing a container that does not carry this task's run-id label is refused
  (exit 60) and never reaches ``docker stop``/``docker rm``;
* the stop stage is idempotent when no container exists;
* container exec forwards the requested work directory and HOME.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"

FAKE_DOCKER = r"""#!/bin/sh
printf '%s\n' "$*" >> "$DOCKER_CALLS"
case "$1" in
  info) exit 0 ;;
  load)
    printf 'Loaded image: openeuler-test:latest\n'
    exit 0
    ;;
  image)
    if [ "$2" = "inspect" ] && [ "$3" = "--format" ]; then
      printf '%s\n' "$IMAGE_ARCH"
      exit 0
    fi
    exit 0
    ;;
  container)
    if [ "${FAKE_CONTAINER_EXISTS:-0}" = "1" ]; then exit 0; fi
    exit 1
    ;;
  inspect)
    if [ "$2" = "--format" ]; then
      case "$3" in
        *State.Running*) [ "${FAKE_CONTAINER_RUNNING:-0}" = "1" ] && printf 'true\n' || printf 'false\n'; exit 0 ;;
        *run-id*) printf '%s\n' "${FAKE_CONTAINER_LABEL:-unit-test}"; exit 0 ;;
      esac
    fi
    exit 0
    ;;
  run)
    case " $* " in
      *" cat /etc/os-release "*)
        printf 'NAME="openEuler"\nVERSION="24.03 (LTS-SP4)"\n'
        exit 0
        ;;
    esac
    exit 0
    ;;
  exec) exit 0 ;;
  stop|rm) exit 0 ;;
esac
exit 0
"""


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "PERF_PROXY": "",
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
    } | extra
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def write_fake_docker(tmp_path: Path) -> None:
    docker = tmp_path / "docker"
    docker.write_text(FAKE_DOCKER, encoding="utf-8")
    docker.chmod(0o755)


def docker_calls(tmp_path: Path) -> str:
    log = tmp_path / "docker-calls.log"
    return log.read_text(encoding="utf-8") if log.is_file() else ""


def test_container_name_label_and_network_capability(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir()
    results.mkdir()
    architecture = os.uname().machine
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        'PERF_RUN_ID=unit-test; '
        'prepare_hiredis_container_image() { HIREDIS_CONTAINER_IMAGE=openeuler-test:latest; }; '
        'start_hiredis_container'
    )
    completed = run_shell(
        script, tmp_path,
        IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    expected_name = f"boostkit-hiredis-{architecture}-unit-test"
    assert f"--name {expected_name}" in calls
    assert "--label boostkit.hiredis.run-id=unit-test" in calls
    assert "--network=host" in calls
    # unshare -n needs SYS_ADMIN and raising lo inside the new namespace
    # needs NET_ADMIN; only these two are granted, never --privileged.
    assert "--cap-add=SYS_ADMIN" in calls
    assert "--cap-add=NET_ADMIN" in calls
    assert "--privileged" not in calls
    assert f"source={work},target={work}" in calls
    assert f"source={results},target={results}" in calls
    assert "source=/etc/passwd,target=/etc/passwd,readonly" in calls


def test_image_archive_is_verified_before_load(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    architecture = os.uname().machine
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{work}/results"; '
        'PERF_RUN_ID=unit-test; '
        'prepare_hiredis_container_image'
    )
    completed = run_shell(
        script, tmp_path,
        HIREDIS_IMAGE_ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    assert f"load --input {archive}" in calls
    assert "openEuler container image is ready" in completed.stdout + completed.stderr

    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(
        script, tmp_path,
        HIREDIS_IMAGE_ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64",
        DOCKER_CALLS=str(tmp_path / "corrupt-calls.log"),
    )
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout + failed.stderr
    corrupt_log = tmp_path / "corrupt-calls.log"
    assert not corrupt_log.exists() or "load --input" not in corrupt_log.read_text(
        encoding="utf-8"
    )


def test_remove_refuses_a_container_without_this_run_label(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{work}/results"; '
        'PERF_RUN_ID=unit-test; '
        'remove_hiredis_container'
    )
    completed = run_shell(
        script, tmp_path,
        FAKE_CONTAINER_EXISTS="1",
        FAKE_CONTAINER_LABEL="another-run",
    )
    assert completed.returncode == 60
    assert (
        "refusing to remove a container without this task's run-id label"
        in completed.stdout + completed.stderr
    )
    calls = docker_calls(tmp_path)
    assert "stop --time 30" not in calls
    assert "rm boostkit-hiredis" not in calls


def test_stop_is_idempotent_when_container_is_absent(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{STOP}"; stop_hiredis_runtime'
    # The work directory is passed through the environment so it does not appear
    # on this shell's own command line (which the leftover scan looks at).
    completed = run_shell(
        script, tmp_path,
        PERF_WORK_DIR=str(work),
        RESULTS_DIR=str(work / "results"),
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "stop stage: private container removed" in completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    assert "stop --time 30" not in calls


def test_exec_forwards_workdir_and_home(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{work}/results"; '
        'PERF_RUN_ID=unit-test; '
        f'hiredis_container_exec_at "{work}/scenario" true'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    assert f"--workdir {work}/scenario" in calls
    assert f"HOME={work}/home" in calls
    assert "boostkit-hiredis-" in calls
