"""Check the GDB container lifecycle without a live Docker daemon.

The case runs every stage inside a private openEuler 24.03 LTS SP4 container.
These tests pin the parts of that contract that regressions would silently
break: the container name and run-id label, the verified local image archive,
the host-network / directory-mount command line, the ``docker exec`` environment
and the refusal to remove a container that belongs to another run.
"""

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


def write_image_archive(tmp_path: Path, architecture: str) -> Path:
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    return archive


def image_architecture() -> str:
    return "amd64" if os.uname().machine == "x86_64" else "arm64"


def test_container_name_carries_arch_and_run_id(tmp_path: Path) -> None:
    work = tmp_path / "work"
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; gdb_configure_container; '
        'printf "%s\\n" "${GDB_CONTAINER_NAME}"; printf "%s\\n" "${GDB_CONTAINER_HOME}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    name, home = completed.stdout.splitlines()
    assert name == f"boostkit-gdb-{os.uname().machine}-unit-test"
    assert home == f"{work}/home"


def test_image_uses_local_verified_sp4_archive(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    archive = write_image_archive(tmp_path, os.uname().machine)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        "prepare_gdb_container_image"
    )
    completed = run_shell(
        script,
        tmp_path,
        IMAGE_ARCH=image_architecture(),
        GDB_IMAGE_ARCHIVE_DIR=str(tmp_path),
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert f"load --input {archive}" in calls
    assert "image is ready: openeuler-24.03-lts-sp4:latest" in completed.stdout

    checksum = archive.with_name(archive.name + ".sha256sum")
    checksum.write_text("0" * 64 + f"  {archive.name}\n", encoding="utf-8")
    failed = run_shell(
        script,
        tmp_path,
        IMAGE_ARCH=image_architecture(),
        GDB_IMAGE_ARCHIVE_DIR=str(tmp_path),
    )
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout


def test_image_rejects_wrong_architecture(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    write_image_archive(tmp_path, os.uname().machine)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; prepare_gdb_container_image'
    wrong = "arm64" if os.uname().machine == "x86_64" else "amd64"
    completed = run_shell(script, tmp_path, IMAGE_ARCH=wrong)
    assert completed.returncode == 30
    assert "architecture" in completed.stdout


def test_start_uses_host_network_and_mounts_task_directories(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    write_image_archive(tmp_path, os.uname().machine)
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir()
    results.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; SCRIPT_DIR="{CASE_DIR}"; '
        'start_gdb_container'
    )
    completed = run_shell(
        script, tmp_path,
        IMAGE_ARCH=image_architecture(), GDB_IMAGE_ARCHIVE_DIR=str(tmp_path),
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    run_line = next(line for line in calls.splitlines() if line.startswith("run --detach"))
    assert "--network=host" in run_line
    assert "--label boostkit.gdb.run-id=unit-test" in run_line
    assert f"source={work},target={work}" in run_line
    assert f"source={results},target={results}" in run_line
    assert f"source={CASE_DIR},target={CASE_DIR},readonly" in run_line
    assert "--user " in run_line
    assert "sleep infinity" in run_line


def test_exec_forwards_workdir_home_and_container(tmp_path: Path) -> None:
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; '
        'gdb_container_exec_at /tmp/scenario echo hello'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert (
        "exec -e HOME=" + str(work) + "/home -e TMPDIR=" + str(tmp_path / "tmp")
        + " -e PERF_RUN_ID=unit-test --workdir /tmp/scenario boostkit-gdb-"
    ) in calls
    assert "echo hello" in calls


def test_stop_refuses_foreign_label_then_removes_own_container(tmp_path: Path) -> None:
    write_fake_docker(tmp_path, container_exists=True)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; remove_gdb_container'
    refused = run_shell(script, tmp_path, LABEL="another-run")
    assert refused.returncode == 60
    assert "refusing to remove" in refused.stdout
    assert "stop --time 30" not in (tmp_path / "docker-calls.log").read_text(encoding="utf-8")

    (tmp_path / "docker-calls.log").unlink()
    removed = run_shell(script, tmp_path, LABEL="unit-test")
    assert removed.returncode == 0, removed.stdout + removed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-gdb-" in calls
    assert "rm boostkit-gdb-" in calls


def test_stop_removes_nothing_without_a_container(tmp_path: Path) -> None:
    write_fake_docker(tmp_path, container_exists=False)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; remove_gdb_container'
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "container inspect boostkit-gdb-" in calls
    assert "stop --time 30" not in calls
    assert "rm boostkit-gdb-" not in calls


def test_stop_runtime_removes_container_and_keeps_evidence(tmp_path: Path) -> None:
    """The stop stage removes the private container and keeps the evidence tree."""
    write_fake_docker(tmp_path, container_exists=False)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{STOP}"; '
        f'initialize_runtime() {{ PERF_WORK_DIR="{work}"; }}; '
        'stop_gdb_runtime'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert work.is_dir()
    assert "no leftover GDB or testsuite processes" in completed.stdout

def test_build_dependencies_are_installed_inside_the_container() -> None:
    """The GDB build must not fall back to host package installation."""
    helpers = (CASE_DIR / "scripts" / "builders" / "base_helpers.sh").read_text(encoding="utf-8")
    assert "prepare_gdb_build_container" in helpers
    assert "gdb_container_exec_root dnf" in helpers
    assert "python3-devel" in helpers
    assert "gmp-devel" in helpers
    assert "dejagnu" in helpers
    assert "dnf\\" not in helpers.replace("gdb_container_exec_root dnf", "")


def test_every_stage_uses_the_container_wrappers() -> None:
    """Start/test/stop must enter (or clean up) the private container."""
    stages = CASE_DIR / "scripts" / "stages"
    expectations = {
        "start.sh": "check_gdb_container",
        "test.sh": "gdb_container_exec_at",
        "stop.sh": "remove_gdb_container",
    }
    for script, token in expectations.items():
        body = (stages / script).read_text(encoding="utf-8")
        assert token in body, f"{script} does not reference {token}"