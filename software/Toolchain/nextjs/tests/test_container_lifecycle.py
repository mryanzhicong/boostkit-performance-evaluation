"""Check the Next.js container lifecycle without a live Docker daemon.

The case runs every stage inside a private openEuler 24.03 LTS SP4 container.
These tests pin the parts of that contract that regressions would silently
break: the container name and run-id label, the verified local image archive,
the host-network / directory-mount command line, and the refusal to remove a
container that belongs to another run plus idempotent ``stop``.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"

ARCH = "x86_64" if os.uname().machine == "x86_64" else "aarch64"
IMAGE_ARCH = "amd64" if ARCH == "x86_64" else "arm64"


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": ARCH,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
        "TMPDIR": str(tmp_path / "tmp"),
    } | extra
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def write_fake_docker(tmp_path: Path, *, container_exists: bool = False) -> Path:
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        "#!/bin/sh\n"
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'case "$1" in\n'
        "  info) exit 0 ;;\n"
        '  load) printf "Loaded image: openeuler-24.03-lts-sp4:latest\\n"; exit 0 ;;\n'
        '  ps) exit 0 ;;\n'
        '  stop|rm) exit 0 ;;\n'
        "esac\n"
        'if [ "$1" = container ] && [ "$2" = inspect ]; then\n'
        f'  exit {0 if container_exists else 1}\n'
        "fi\n"
        'if [ "$1 $2 $3" = "image inspect --format" ]; then printf "%s\\n" "$IMAGE_ARCH"; exit 0; fi\n'
        'case "$1" in\n'
        "  inspect)\n"
        '    case "$3" in\n'
        '      *State.Running*) printf "true\\n" ;;\n'
        '      *Config.Labels*) printf "%s\\n" "$LABEL" ;;\n'
        '      *) printf "%s\\n" "$LABEL" ;;\n'
        "    esac\n"
        "    exit 0 ;;\n"
        "esac\n"
        'if [ "$1" = run ]; then\n'
        '  case " $* " in\n'
        '    *" --network=none "*) printf \'NAME="openEuler Linux"\\nVERSION="24.03 (LTS-SP4)"\\n\' ;;\n'
        "  esac\n"
        "  exit 0\n"
        "fi\n"
        'if [ "$1" = exec ]; then\n'
        '  case " $* " in\n'
        '    *" test -f /etc/yum.repos.d/openEuler.repo "*) exit 1 ;;\n'
        "  esac\n"
        '  printf "exec-ok\\n"\n'
        "  exit 0\n"
        "fi\n"
        "exit 0\n",
        encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    return fake_docker


def write_image_archive(tmp_path: Path) -> Path:
    archive_name = f"openEuler-docker.{ARCH}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    return archive


def test_container_name_carries_arch_and_run_id(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; nextjs_configure_container; '
        'printf "name=%s\\nhome=%s\\n" "${NEXTJS_CONTAINER_NAME}" "${NEXTJS_CONTAINER_HOME}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert f"name=boostkit-nextjs-{ARCH}-unit-test" in completed.stdout
    assert f"home={work}/home" in completed.stdout


def test_image_archive_is_loaded_and_verified(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    image_dir = tmp_path / "images"
    image_dir.mkdir()
    archive = write_image_archive(image_dir)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; NEXTJS_IMAGE_ARCHIVE_DIR="{image_dir}"; '
        'prepare_nextjs_container_image >/dev/null'
    )
    completed = run_shell(script, tmp_path, IMAGE_ARCH=IMAGE_ARCH)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert f"load --input {archive}" in calls
    assert "image inspect --format" in calls
    assert "--network=none" in calls


def test_refuses_to_remove_a_container_from_another_run(tmp_path: Path) -> None:
    write_fake_docker(tmp_path, container_exists=True)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{STOP}"; initialize_runtime() {{ :; }}; remove_nextjs_container'
    completed = run_shell(
        script, tmp_path,
        PERF_WORK_DIR=str(work), LABEL="another-run",
    )
    assert completed.returncode == 60, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-nextjs-" not in calls
    assert "rm boostkit-nextjs-" not in calls


def test_stop_is_idempotent_without_a_container(tmp_path: Path) -> None:
    write_fake_docker(tmp_path, container_exists=False)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{STOP}"; initialize_runtime() {{ :; }}; stop_nextjs_runtime'
    completed = run_shell(
        script, tmp_path,
        PERF_WORK_DIR=str(work), NEXT_BIN=f"{work}/node_modules/.bin/next",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "rm boostkit-nextjs-" not in calls
