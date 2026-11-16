"""Check the Eigen 5.0.1 container lifecycle without a live Docker daemon.

The case runs every build, self-check and measured process inside a per-run
openEuler container.  These tests pin the parts that are easy to break while
editing the case: the derived container name/label, the verified image load, the
private bind mounts, the run-id label guard in ``remove_eigen_container`` and the
fact that the stages really go through the container helpers.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
BUILDERS = CASE_DIR / "scripts" / "builders" / "base.sh"
START = CASE_DIR / "scripts" / "stages" / "start.sh"
TEST = CASE_DIR / "scripts" / "stages" / "test.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
    } | extra
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def write_fake_docker(tmp_path: Path, extra: str = "") -> Path:
    """Write a docker shim; ``extra`` runs first so it can override the defaults."""
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        f'{extra}'
        'if [ "$1" = info ]; then exit 0; fi\n'
        'if [ "$1" = load ]; then printf "Loaded image: openeuler-test:latest\\n"; exit 0; fi\n'
        'if [ "$1 $2 $3" = "image inspect --format" ]; then printf "%s\\n" "${IMAGE_ARCH:-amd64}"; exit 0; fi\n'
        'if [ "$1" = run ] && [ "$2 $3" = "--rm --network=none" ]; then\n'
        '  printf "ID=\\\"openEuler\\\"\\nVERSION=\\\"24.03 (LTS-SP4)\\\"\\nPRETTY_NAME=\\\"openEuler 24.03 (LTS-SP4)\\\"\\n"\n'
        '  exit 0\n'
        'fi\n'
        'if [ "$1 $2" = "container inspect" ]; then exit 1; fi\n'
        'if [ "$1 $2" = "ps -a" ]; then exit 0; fi\n'
        'if [ "$1" = exec ]; then exit 1; fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    return fake_docker


def test_container_name_and_home_are_derived_from_run_id(tmp_path: Path) -> None:
    work = tmp_path / "work"
    work.mkdir()
    completed = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        'eigen_configure_container; '
        'printf "%s\\n%s\\n" "$EIGEN_CONTAINER_NAME" "$EIGEN_CONTAINER_HOME"',
        tmp_path,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    architecture = os.uname().machine
    expected = f"boostkit-eigen-{architecture}-unit-test"
    assert completed.stdout.splitlines() == [expected, f"{work}/home"]

    configured = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        'EIGEN_CONTAINER_NAME=eigen-fixed-name; EIGEN_CONTAINER_HOME=/tmp/home; '
        'eigen_configure_container; printf "%s %s\\n" "$EIGEN_CONTAINER_NAME" "$EIGEN_CONTAINER_HOME"',
        tmp_path,
    )
    assert configured.stdout.strip() == "eigen-fixed-name /tmp/home"


def test_image_uses_local_verified_sp4_archive(tmp_path: Path) -> None:
    architecture = os.uname().machine
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        f'EIGEN_IMAGE_ARCHIVE_DIR="{tmp_path}"; '
        'prepare_eigen_container_image; printf "IMAGE=%s\\n" "$EIGEN_CONTAINER_IMAGE"'
    )
    completed = run_shell(
        script, tmp_path, IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64"
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "IMAGE=openeuler-test:latest" in completed.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert f"load --input {archive}" in calls
    assert "run --rm --network=none openeuler-test:latest cat /etc/os-release" in calls

    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(
        script, tmp_path, IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64"
    )
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout


def test_start_mounts_private_paths_and_labels_the_run(tmp_path: Path) -> None:
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir()
    results.mkdir()
    write_fake_docker(tmp_path)
    completed = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        'EIGEN_IMAGE_ARCHIVE_DIR="${ARCHIVE_DIR}"; '
        'prepare_eigen_container_image() { EIGEN_CONTAINER_IMAGE="openeuler-test:latest"; }; '
        'start_eigen_container',
        tmp_path,
        ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if os.uname().machine == "x86_64" else "arm64",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "run --detach --name boostkit-eigen-" in calls
    assert "boostkit.eigen.run-id=unit-test" in calls
    assert f"type=bind,source={work},target={work}" in calls
    assert f"type=bind,source={results},target={results}" in calls
    assert "source=/etc/passwd,target=/etc/passwd,readonly" in calls


def test_remove_refuses_foreign_run_id_and_removes_owned_container(tmp_path: Path) -> None:
    work = tmp_path / "work"
    work.mkdir()
    write_fake_docker(
        tmp_path,
        'if [ "$1 $2" = "container inspect" ]; then exit 0; fi\n'
        'if [ "$1" = inspect ]; then printf "%s\\n" "${LABEL_RUN_ID:-other-run}"; exit 0; fi\n',
    )
    script = (
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; remove_eigen_container'
    )
    refused = run_shell(script, tmp_path)
    assert refused.returncode == 60
    assert "refusing to remove a container without this task's run-id label" in refused.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30" not in calls

    owned = run_shell(script, tmp_path, LABEL_RUN_ID="unit-test")
    assert owned.returncode == 0, owned.stdout + owned.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    name = f"boostkit-eigen-{os.uname().machine}-unit-test"
    assert f"stop --time 30 {name}" in calls
    assert f"rm {name}" in calls
    assert "removed managed container" in owned.stdout


def test_check_requires_a_running_container(tmp_path: Path) -> None:
    work = tmp_path / "work"
    work.mkdir()
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'if [ "$1" = inspect ]; then printf "%s\\n" "${RUNNING:-false}"; exit 0; fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; check_eigen_container'
    stopped = run_shell(script, tmp_path)
    assert stopped.returncode == 40
    assert "managed container is not running" in stopped.stdout

    running = run_shell(script, tmp_path, RUNNING="true")
    assert running.returncode == 0, running.stdout + running.stderr


def test_stages_go_through_the_container_helpers() -> None:
    start = START.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    stop = STOP.read_text(encoding="utf-8")
    builders = BUILDERS.read_text(encoding="utf-8")
    # Start and test must refuse to work without the managed container.
    assert "check_eigen_container" in start
    assert "check_eigen_container" in test
    # Every measured process is spawned inside the container's scenario workdir.
    assert 'eigen_container_exec_at "${workdir}"' in test
    assert "run_timed.py" in test
    # The strict parser stays on the host.
    assert 'python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py"' in test
    # Stop removes this task's container before cleaning anything else.
    body = stop.split("stop_eigen_runtime() {", 1)[1]
    assert "remove_eigen_container || return $?" in body
    assert body.index("remove_eigen_container") < body.index("SCRATCH_DIR")
    # Dependency installation, extraction, compilation and version probing happen
    # inside the container; the host no longer runs cmake/c++/dnf for this case.
    assert "prepare_eigen_build_container" in builders
    assert "eigen_container_exec_root dnf" in builders
    assert "eigen_container_exec tar -xzf" in builders
    assert "eigen_container_exec c++ " in builders
    assert "\n    cmake -S " not in builders
