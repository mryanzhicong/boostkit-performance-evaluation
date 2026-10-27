"""Check the RocksDB 2U8G container lifecycle without a live Docker daemon."""

from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path


CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
START = CASE_DIR / "scripts" / "stages" / "start.sh"
TEST = CASE_DIR / "scripts" / "stages" / "test.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"


def run_shell(script: str, tmp_path: Path, **extra: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
    } | extra
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


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
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'if [ "$1" = load ]; then printf "Loaded image: openeuler-test:latest\\n"; fi\n'
        'if [ "$1 $2 $3" = "image inspect --format" ]; then printf "%s\\n" "$IMAGE_ARCH"; fi\n'
        'if [ "$1" = run ]; then printf "ID=\\\"openEuler\\\"\\nVERSION=\\\"24.03 (LTS-SP4)\\\"\\n"; fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; PERF_WORK_DIR="{work}"; '
        f'ROCKSDB_IMAGE_REF_FILE="{work}/image-ref.txt"; prepare_rocksdb_container_image'
    )
    completed = run_shell(
        script, tmp_path, ROCKSDB_IMAGE_ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (work / "image-ref.txt").read_text(encoding="utf-8").strip() == "openeuler-test:latest"
    assert f"load --input {archive}" in (tmp_path / "docker-calls.log").read_text(encoding="utf-8")

    (work / "image-ref.txt").unlink()
    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(
        script, tmp_path, ROCKSDB_IMAGE_ARCHIVE_DIR=str(tmp_path),
        IMAGE_ARCH="amd64" if architecture == "x86_64" else "arm64",
    )
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout


def test_start_mounts_private_paths_and_limits_resources(tmp_path: Path) -> None:
    work = tmp_path / "work"
    results = tmp_path / "results"
    (work / "dist" / "bin").mkdir(parents=True)
    (work / "dist" / "bin" / "ycsb").write_text("#!/bin/sh\n", encoding="utf-8")
    results.mkdir()
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'if [ "$1 $2" = "container inspect" ]; then exit 1; fi\n'
        'case " $* " in *" java -version "*) printf "openjdk version \\"11.0.1\\"\\n" >&2 ;; esac\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    script = (
        f'source "{START}"; initialize_runtime() {{ :; }}; '
        'prepare_rocksdb_container_image() { ROCKSDB_CONTAINER_IMAGE=openeuler-test; }; '
        'select_rocksdb_cpu_set() { printf "10,11,12 3\\n"; }; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; '
        f'YCSB_DIST_DIR="{work}/dist"; BENCH_DATA_DIR="{work}/data"; '
        'ROCKSDB_CONTAINER_NAME=rocksdb-unit-test; ROCKSDB_NUMA_NODE=3; '
        'prepare_rocksdb_benchmark_data'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "--cpus=2" in calls and "--memory=8g" in calls
    assert "--cpuset-cpus=10,11,12" in calls and "--cpuset-mems=3" in calls
    assert f"source={work},target={work}" in calls
    assert f"source={results},target={results}" in calls
    assert "--privileged" not in calls
    assert (work / "data").is_dir()


def test_benchmark_executes_inside_container(tmp_path: Path) -> None:
    work = tmp_path / "work"
    (work / "dist" / "bin").mkdir(parents=True)
    (work / "dist" / "bin" / "ycsb").write_text("#!/bin/sh\n", encoding="utf-8")
    (work / "data").mkdir()
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'if [ "$1 $2" = "inspect --format" ]; then\n'
        '  case "$3" in *State.Running*) printf "true\\n" ;; *) printf "unit-test\\n" ;; esac\n'
        'fi\n'
        'if [ "$1" = exec ]; then wc -c <&0 > "$SCRIPT_BYTES"; fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    script = (
        f'source "{TEST}"; initialize_runtime() {{ :; }}; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{tmp_path}/results"; '
        f'YCSB_DIST_DIR="{work}/dist"; BENCH_DATA_DIR="{work}/data"; '
        f'TMPDIR="{work}/tmp"; ROCKSDB_CONTAINER_NAME=rocksdb-unit-test; '
        'run_rocksdb_benchmarks'
    )
    completed = run_shell(script, tmp_path, SCRIPT_BYTES=str(tmp_path / "script-bytes"))
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "exec -i" in calls and "python3 -" in calls
    assert "ROCKSDB_BENCH_DATA_DIR=" in calls
    assert int((tmp_path / "script-bytes").read_text(encoding="utf-8")) > 1000


def test_stop_removes_only_owned_container_and_task_data(tmp_path: Path) -> None:
    work = tmp_path / "work"
    (work / "data").mkdir(parents=True)
    (work / "keep").mkdir()
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'if [ "$1" = inspect ]; then printf "unit-test\\n"; fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    script = (
        f'source "{STOP}"; initialize_runtime() {{ :; }}; '
        f'PERF_WORK_DIR="{work}"; ROCKSDB_DATA_ROOT="{work}/data"; '
        f'BENCH_DATA_DIR="{work}/data"; ROCKSDB_CONTAINER_NAME=rocksdb-unit-test; '
        'cleanup_rocksdb_benchmark_data'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert not (work / "data").exists()
    assert (work / "keep").is_dir()
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 rocksdb-unit-test" in calls
    assert "rm rocksdb-unit-test" in calls
