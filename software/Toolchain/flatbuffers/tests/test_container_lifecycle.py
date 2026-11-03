"""Exercise the FlatBuffers container lifecycle without a live Docker daemon."""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
    } | extra
    for directory in (tmp_path / "work", tmp_path / "results"):
        directory.mkdir(parents=True, exist_ok=True)
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def fake_docker(tmp_path: Path, body: str) -> None:
    path = tmp_path / "docker"
    path.write_text(
        '#!/bin/sh\nprintf "%s\\n" "$*" >> "$DOCKER_CALLS"\n' + body,
        encoding="utf-8",
    )
    path.chmod(0o755)


def docker_calls(tmp_path: Path) -> str:
    return (tmp_path / "docker-calls.log").read_text(encoding="utf-8")


def test_container_name_and_labels(tmp_path: Path) -> None:
    fake_docker(
        tmp_path,
        'if [ "$1 $2" = "container inspect" ]; then exit 1; fi\n'
        'if [ "$1" = ps ]; then exit 0; fi\n'
        'if [ "$1" = exec ]; then exit 0; fi\n'
        'exit 0\n',
    )
    script = (
        f'source "{COMMON}"; configure_runtime_paths; '
        'prepare_flatbuffers_container_image() { FLATBUFFERS_CONTAINER_IMAGE=openeuler-test:latest; }; '
        'start_flatbuffers_container; printf "%s\\n" "${FLATBUFFERS_CONTAINER_NAME}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    architecture = {
        "x86_64": "x86_64", "amd64": "x86_64",
        "aarch64": "aarch64", "arm64": "aarch64",
    }[os.uname().machine]
    expected_name = f"boostkit-flatbuffers-{architecture}-unit-test"
    assert completed.stdout.strip().splitlines()[-1] == expected_name
    calls = docker_calls(tmp_path)
    assert f"--label boostkit.flatbuffers.run-id=unit-test" in calls
    assert f"run --detach --name {expected_name}" in calls
    assert "--network=host" in calls
    assert f"source={tmp_path / 'work'},target={tmp_path / 'work'}" in calls
    assert f"source={tmp_path / 'results'},target={tmp_path / 'results'}" in calls
    assert "sleep infinity" in calls
    assert "--cap-add" not in calls


def test_start_refuses_existing_container(tmp_path: Path) -> None:
    fake_docker(
        tmp_path,
        'if [ "$1 $2" = "container inspect" ]; then exit 0; fi\n'
        'exit 0\n',
    )
    script = (
        f'source "{COMMON}"; configure_runtime_paths; '
        'prepare_flatbuffers_container_image() { FLATBUFFERS_CONTAINER_IMAGE=openeuler-test:latest; }; '
        'start_flatbuffers_container'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 40
    assert "run --detach" not in docker_calls(tmp_path)


def test_image_uses_verified_local_sp4_archive(tmp_path: Path) -> None:
    architecture = os.uname().machine
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 LTS SP4 image fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    image_arch = "amd64" if architecture == "x86_64" else "arm64"
    fake_docker(
        tmp_path,
        'if [ "$1" = load ]; then printf "Loaded image: openeuler-test:latest\\n"; fi\n'
        'if [ "$1 $2 $3" = "image inspect --format" ]; then printf "%s\\n" "$IMAGE_ARCH"; fi\n'
        'if [ "$1" = run ]; then printf \'PRETTY_NAME="openEuler 24.03 (LTS-SP4)"\\n\'; fi\n'
        'exit 0\n',
    )
    script = (
        f'source "{COMMON}"; configure_runtime_paths; '
        'prepare_flatbuffers_container_image'
    )
    completed = run_shell(
        script, tmp_path,
        FLATBUFFERS_IMAGE_ARCHIVE_DIR=str(tmp_path), IMAGE_ARCH=image_arch,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert f"load --input {archive}" in docker_calls(tmp_path)

    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(
        script, tmp_path,
        FLATBUFFERS_IMAGE_ARCHIVE_DIR=str(tmp_path), IMAGE_ARCH=image_arch,
    )
    assert failed.returncode == 30, failed.stdout + failed.stderr
    assert "checksum mismatch" in failed.stdout + failed.stderr


def test_remove_refuses_foreign_run_label(tmp_path: Path) -> None:
    fake_docker(
        tmp_path,
        'if [ "$1 $2" = "container inspect" ]; then exit 0; fi\n'
        'if [ "$1" = inspect ]; then printf "another-run\\n"; fi\n'
        'exit 0\n',
    )
    script = f'source "{COMMON}"; configure_runtime_paths; remove_flatbuffers_container'
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 60, completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    assert "stop --time 30" not in calls
    assert not any(line.startswith("rm ") for line in calls.splitlines())


def test_exec_wrapper_uses_container_workdir_and_root_user(tmp_path: Path) -> None:
    fake_docker(tmp_path, 'if [ "$1" = exec ]; then exit 0; fi\nexit 0\n')
    script = (
        f'source "{COMMON}"; configure_runtime_paths; '
        'flatbuffers_container_exec_at /tmp/unit-work echo inside; '
        'flatbuffers_container_exec_root echo root-only'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = docker_calls(tmp_path)
    assert "--user 0" in calls
    assert "--workdir /tmp/unit-work" in calls
    assert "echo inside" in calls
    assert "root-only" in calls


def test_stop_is_idempotent_when_container_is_absent(tmp_path: Path) -> None:
    fake_docker(
        tmp_path,
        'if [ "$1 $2" = "container inspect" ]; then exit 1; fi\n'
        'exit 0\n',
    )
    completed = run_shell(f'source "{STOP}"; stop_flatbuffers_runtime', tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
