"""Check the Ultrascan 5.8.0 container lifecycle without a live Docker daemon.

This case builds hsbench and drives the scan matrix inside a per-run openEuler
container.  These tests pin the parts that are easy to break while editing the
case: the derived container name/label, the verified image load, the private bind
mounts, the run-id label guard in ``remove_ultrascan_container``, the container
bootstrap (dnf plus the host transfer tools), and the split between the
container-side ``drive`` step and the strict host-side ``report`` step.
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
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"


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
        'ultrascan_configure_container; '
        'printf "%s\\n%s\\n" "$ULTRASCAN_CONTAINER_NAME" "$ULTRASCAN_CONTAINER_HOME"',
        tmp_path,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    architecture = os.uname().machine
    expected = f"boostkit-ultrascan-{architecture}-unit-test"
    assert completed.stdout.splitlines() == [expected, f"{work}/home"]

    configured = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        'ULTRASCAN_CONTAINER_NAME=ultrascan-fixed-name; ULTRASCAN_CONTAINER_HOME=/tmp/home; '
        'ultrascan_configure_container; printf "%s %s\\n" "$ULTRASCAN_CONTAINER_NAME" "$ULTRASCAN_CONTAINER_HOME"',
        tmp_path,
    )
    assert configured.stdout.strip() == "ultrascan-fixed-name /tmp/home"


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
        f'ULTRASCAN_IMAGE_ARCHIVE_DIR="{tmp_path}"; '
        'prepare_ultrascan_container_image; printf "IMAGE=%s\\n" "$ULTRASCAN_CONTAINER_IMAGE"'
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
        'ULTRASCAN_IMAGE_ARCHIVE_DIR="${ARCHIVE_DIR}"; '
        'prepare_ultrascan_container_image() { ULTRASCAN_CONTAINER_IMAGE="openeuler-test:latest"; }; '
        'start_ultrascan_container',
        tmp_path,
        ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if os.uname().machine == "x86_64" else "arm64",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "run --detach --name boostkit-ultrascan-" in calls
    assert "boostkit.ultrascan.run-id=unit-test" in calls
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
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; remove_ultrascan_container'
    refused = run_shell(script, tmp_path)
    assert refused.returncode == 60
    assert "refusing to remove a container without this task's run-id label" in refused.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30" not in calls

    owned = run_shell(script, tmp_path, LABEL_RUN_ID="unit-test")
    assert owned.returncode == 0, owned.stdout + owned.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    name = f"boostkit-ultrascan-{os.uname().machine}-unit-test"
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
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; check_ultrascan_container'
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
    common = COMMON.read_text(encoding="utf-8")
    parser = PARSER.read_text(encoding="utf-8")
    # Start and test must refuse to work without the managed container.
    assert "check_ultrascan_container" in start
    assert "check_ultrascan_container" in test
    # The measurement driver runs in the container; the strict parser does not.
    assert 'ultrascan_container_exec_at "${PERF_WORK_DIR}"' in test
    assert 'parse_benchmark.py" drive' in test
    assert 'parse_benchmark.py" report' in test
    assert 'def report(args: argparse.Namespace)' in parser
    assert 'def drive(args: argparse.Namespace)' in parser
    # Stop removes this task's container before it reports success.
    body = stop.split("stop_ultrascan_runtime() {", 1)[1]
    assert "remove_ultrascan_container || return $?" in body
    # Dependency installation, extraction, version proof and the build itself all
    # happen inside the container; the host keeps only the download tools.
    assert "prepare_ultrascan_build_container" in common
    assert "ultrascan_container_exec_root dnf" in common
    assert "--setopt=install_weak_deps=False" in common
    assert "ultrascan_container_exec tar -C" in builders
    assert 'ultrascan_container_exec_at "${BUILD_DIR}"' in builders
    assert "util-linux" in common
    assert "\n        cmake -S " not in builders
