"""Check the RUBY container lifecycle without a live Docker daemon.

The shim below implements just enough of the Docker CLI for the container block
in ``scripts/common.sh``: image loading/verification, private container creation
and idempotent removal.  Every invocation is appended to ``DOCKER_CALLS`` so the
tests can assert on the exact command lines the case sends.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"

ARCH = os.uname().machine
IMAGE_ARCH = "amd64" if ARCH == "x86_64" else "arm64"

DOCKER_SHIM = """#!/bin/sh
printf '%s\\n' "$*" >> "$DOCKER_CALLS"
case "${1-}" in
  info) exit 0 ;;
  container) exit 1 ;;
  ps) exit 0 ;;
  load) printf 'Loaded image: openeuler-test:latest\\n'; exit 0 ;;
  image) printf '%s\\n' "$IMAGE_ARCH"; exit 0 ;;
  run)
    case " $* " in
      *" --rm "*) printf 'ID="openEuler"\\nVERSION_ID="24.03"\\nPRETTY_NAME="openEuler 24.03 (LTS-SP4)"\\n' ;;
    esac
    exit 0 ;;
  exec)
    case " $* " in
      *" test -f /etc/yum.repos.d/openEuler.repo"*) exit 1 ;;
    esac
    exit 0 ;;
  inspect)
    exit 1 ;;
  stop|rm) exit 0 ;;
esac
exit 0
"""


def install_fake_docker(tmp_path: Path) -> None:
    shim = tmp_path / "docker"
    shim.write_text(DOCKER_SHIM, encoding="utf-8")
    shim.chmod(0o755)


def write_image_fixture(directory: Path) -> Path:
    archive = directory / f"openEuler-docker.{ARCH}.tar.xz"
    archive.parent.mkdir(parents=True, exist_ok=True)
    archive.write_bytes(b"openEuler 24.03 LTS SP4 image fixture")
    checksum = directory / f"{archive.name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive.name}\n",
        encoding="utf-8",
    )
    return archive


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": ARCH,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
        "IMAGE_ARCH": IMAGE_ARCH,
        "RUBY_IMAGE_ARCHIVE_DIR": str(tmp_path),
    } | extra
    return subprocess.run(
        ["bash", "-c", script],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )


def start_script(tmp_path: Path) -> str:
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir(exist_ok=True)
    results.mkdir(exist_ok=True)
    return (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        f'RUBY_CONTAINER_EXTRA_ARGS=(); '
        "start_ruby_container"
    )


def test_start_creates_labeled_container_with_expected_mounts(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    write_image_fixture(tmp_path)
    completed = run_shell(start_script(tmp_path), tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    work = tmp_path / "work"
    results = tmp_path / "results"
    assert f"--name boostkit-ruby-{ARCH}-unit-test" in calls
    assert "--label boostkit.ruby.run-id=unit-test" in calls
    assert "--network=host" in calls
    assert f"type=bind,source={work},target={work}" in calls
    assert f"type=bind,source={results},target={results}" in calls
    assert f"type=bind,source={COMMON.parent.parent},target={COMMON.parent.parent},readonly" in calls
    assert "sleep infinity" in calls
    assert "--privileged" not in calls
    assert (work / "home").is_dir()


def test_start_rejects_existing_container(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    write_image_fixture(tmp_path)
    completed = run_shell(
        'source "%s"; PERF_WORK_DIR="%s"; RESULTS_DIR="%s"; docker() { '
        'case "${1-} ${2-}" in "container inspect") return 0 ;; esac; '
        'case "${1-}" in info) return 0 ;; esac; return 0; }; start_ruby_container'
        % (COMMON, tmp_path / "work", tmp_path / "results"),
        tmp_path,
    )
    assert completed.returncode == 40
    assert "refusing to reuse an existing container" in completed.stdout


def test_image_checksum_mismatch_fails(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    archive = write_image_fixture(tmp_path)
    (tmp_path / f"{archive.name}.sha256sum").write_text(
        "0" * 64 + f"  {archive.name}\n", encoding="utf-8"
    )
    completed = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{tmp_path}/work"; '
        f'RESULTS_DIR="{tmp_path}/results"; prepare_ruby_container_image',
        tmp_path,
    )
    assert completed.returncode == 30
    assert "container image checksum mismatch" in completed.stdout


def test_remove_refuses_foreign_label(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    completed = run_shell(
        'source "%s"; PERF_WORK_DIR="%s"; RESULTS_DIR="%s"; '
        'docker() { case "${1-} ${2-}" in '
        '"container inspect") return 0 ;; '
        '"inspect --format") printf "other-run\\n"; return 0 ;; '
        'esac; return 0; }; remove_ruby_container'
        % (COMMON, tmp_path / "work", tmp_path / "results"),
        tmp_path,
    )
    assert completed.returncode == 60
    assert "refusing to remove a container without this task's run-id label" in completed.stdout


def test_remove_is_idempotent_and_stops_labelled_container(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    work = tmp_path / "work"
    results = tmp_path / "results"
    removed = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        "remove_ruby_container",
        tmp_path,
    )
    assert removed.returncode == 0
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "container inspect" in calls

    (tmp_path / "docker-calls.log").unlink()
    completed = run_shell(
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        'docker() { printf "%s\\n" "$*" >> "$DOCKER_CALLS"; '
        'case "${1-} ${2-}" in '
        '"container inspect") return 0 ;; '
        '"inspect --format") printf "unit-test\\n"; return 0 ;; '
        "esac; return 0; }; remove_ruby_container",
        tmp_path,
    )
    assert completed.returncode == 0
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-ruby-" in calls
    assert calls.index("stop --time 30") < calls.index("rm boostkit-ruby-")


def test_stop_removes_container_before_reporting_workdir(tmp_path: Path) -> None:
    install_fake_docker(tmp_path)
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir()
    results.mkdir()
    completed = run_shell(
        f'source "{COMMON}"; source "{STOP}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        "initialize_runtime() { :; }; stop_ruby_runtime",
        tmp_path,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "private container removed" in completed.stdout
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "container inspect" in calls
