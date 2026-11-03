"""Check the Jenkins container lifecycle and the containerised stage wiring.

The tests need no live Docker daemon: a small ``docker`` shim records every call
and answers the queries the container block makes, so the name/label contract,
the image archive verification path, the foreign-label refusal and the
idempotent removal are exercised offline.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
BASE = CASE_DIR / "scripts" / "builders" / "base.sh"
START = CASE_DIR / "scripts" / "stages" / "start.sh"
TEST = CASE_DIR / "scripts" / "stages" / "test.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"

FAKE_DOCKER = """#!/bin/sh
printf '%s\\n' "$*" >> "$DOCKER_CALLS"
case "$1 $2" in
  "container inspect")
    [ "${CONTAINER_PRESENT:-0}" = "1" ] && exit 0
    exit 1
    ;;
  "image inspect")
    if [ "$3" = "--format" ]; then printf '%s\\n' "${ARCH_VALUE:-amd64}"; fi
    exit 0
    ;;
  "inspect --format")
    case "$*" in
      *"boostkit.jenkins.run-id"*) printf '%s\\n' "${LABEL_VALUE:-unit-test}" ;;
      *"State.Running"*) printf 'true\\n' ;;
      *) printf '%s\\n' "${ARCH_VALUE:-amd64}" ;;
    esac
    exit 0
    ;;
esac
case "$1" in
  load) printf 'Loaded image: openeuler-test:latest\\n' ;;
  run) printf 'ID="openEuler"\\nVERSION="24.03 (LTS-SP4)"\\n' ;;
  info|image|exec|stop|rm) exit 0 ;;
esac
exit 0
"""


def install_fake_docker(tmp_path: Path) -> Path:
    fake = tmp_path / "docker"
    fake.write_text(FAKE_DOCKER, encoding="utf-8")
    fake.chmod(0o755)
    return fake


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "PERF_PROXY": "",
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
    } | extra
    (tmp_path / "work").mkdir(exist_ok=True)
    (tmp_path / "results").mkdir(exist_ok=True)
    return subprocess.run(
        ["bash", "-c", script],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )


def docker_calls(tmp_path: Path) -> str:
    log = tmp_path / "docker-calls.log"
    return log.read_text(encoding="utf-8") if log.exists() else ""


def test_container_name_and_label_follow_the_contract(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    completed = run_shell(
        f'source "{COMMON}"; jenkins_configure_container; '
        'printf "%s\\n" "$JENKINS_CONTAINER_NAME" "$JENKINS_CONTAINER_HOME"',
        tmp_path,
    )
    assert completed.returncode == 0, completed.stderr
    name, home = completed.stdout.strip().splitlines()[-2:]
    arch = os.uname().machine
    assert name == f"boostkit-jenkins-{arch}-unit-test"
    assert home == str(tmp_path / "work" / "home")


def test_image_uses_local_verified_sp4_archive(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    arch = os.uname().machine
    archive_name = f"openEuler-docker.{arch}.tar.xz"
    image_archive = tmp_path / archive_name
    image_archive.write_bytes(b"openEuler 24.03 LTS SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    digest = hashlib.sha256(image_archive.read_bytes()).hexdigest()
    checksum.write_text(f"{digest}  {archive_name}\n", encoding="utf-8")
    script = (
        f'source "{COMMON}"; prepare_jenkins_container_image; '
        'printf "%s\\n" "$JENKINS_CONTAINER_IMAGE"'
    )
    completed = run_shell(script, tmp_path, JENKINS_IMAGE_ARCHIVE_DIR=str(tmp_path))
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert completed.stdout.strip().splitlines()[-1] == "openeuler-test:latest"
    calls = docker_calls(tmp_path)
    assert f"load --input {image_archive}" in calls
    assert "repo.openeuler.org" not in calls
    assert "--privileged" not in calls

    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(script, tmp_path, JENKINS_IMAGE_ARCHIVE_DIR=str(tmp_path))
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout


def test_remove_refuses_foreign_run_id_and_is_idempotent(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    script = f'source "{COMMON}"; remove_jenkins_container'
    foreign = run_shell(
        script, tmp_path, CONTAINER_PRESENT="1", LABEL_VALUE="some-other-run"
    )
    assert foreign.returncode == 60
    assert "refusing to remove" in foreign.stdout

    absent = run_shell(script, tmp_path, CONTAINER_PRESENT="0")
    assert absent.returncode == 0


def test_stages_run_measured_work_inside_the_container(tmp_path: Path) -> None:
    base = BASE.read_text(encoding="utf-8")
    start = START.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    stop = STOP.read_text(encoding="utf-8")

    # The build installs the JDK inside the container and never on the host.
    assert "jenkins_container_exec_root dnf" in base
    assert "--setopt=install_weak_deps=False" in base
    assert "JDK_PACKAGES[@]" in base
    # The war version probe and the JENKINS_HOME template boot run in the container.
    assert "jenkins_container_env_exec timeout" in base
    assert "jenkins_container_env_exec_at" in base
    assert "--prepare-template" in base
    # start/test verify the container before reading its artefacts.
    assert "check_jenkins_container || return $?" in start
    assert "check_jenkins_container || return $?" in test
    # The per-sample driver, and therefore every controller JVM, runs in the container.
    assert "jenkins_container_env_exec_at" in test
    assert "python3 \"${JENKINS_DRIVER}\"" in test
    assert "--java" in test
    # stop stops the service first and only then removes the container.
    assert stop.index("stop_stray_controllers_in_container || return 0") < stop.index(
        "remove_jenkins_container || return $?"
    )
    # The strict parser still runs on the host.
    assert 'python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py"' in test
