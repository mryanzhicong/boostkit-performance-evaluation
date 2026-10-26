"""Exercise Redis's private container layout without a live Docker daemon."""

from __future__ import annotations

import os
import hashlib
import subprocess
from pathlib import Path


CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
BUILD = CASE_DIR / "scripts" / "builders" / "base.sh"
START = CASE_DIR / "scripts" / "stages" / "start.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"


def run_shell(script: str, work_dir: Path, **overrides: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PERF_WORK_DIR": str(work_dir),
        "PERF_RUN_ID": "unit-test",
        "RESULTS_DIR": str(work_dir / "results"),
        "EXPECTED_ARCH": os.uname().machine,
    } | overrides
    return subprocess.run(
        ["bash", "-c", script], env=environment,
        capture_output=True, text=True, check=False,
    )


def test_instance_layout_and_port_offsets(tmp_path: Path) -> None:
    completed = run_shell(
        f'source "{COMMON}"; initialize_runtime; '
        'printf "%s|%s|%s\n" "$REDIS_INSTANCE_ID" "$REDIS_SERVICE_PORT" "$SERVICE_DIR"; '
        'configure_redis_instance 3; '
        'printf "%s|%s|%s\n" "$REDIS_INSTANCE_ID" "$REDIS_SERVICE_PORT" "$SERVICE_DIR"',
        tmp_path, REDIS_INSTANCE_COUNT="3", REDIS_SERVICE_PORT="3307",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert completed.stdout.splitlines() == [
        f"1|3307|{tmp_path}/instances/1",
        f"3|3309|{tmp_path}/instances/3",
    ]


def test_build_compiles_on_host_before_preparing_image(tmp_path: Path) -> None:
    completed = run_shell(
        f'source "{BUILD}"; '
        'require_redis_commands() { :; }; '
        'git() { '
        '  local source_dir="${@: -1}"; '
        '  mkdir -p "$source_dir/src"; '
        '  printf "#!/bin/sh\\nprintf \'Redis server v=7.0.15\\n\'\\n" > "$source_dir/src/redis-server"; '
        '  chmod +x "$source_dir/src/redis-server"; '
        '  cp "$source_dir/src/redis-server" "$source_dir/src/redis-benchmark"; '
        '  cp "$source_dir/src/redis-server" "$source_dir/src/redis-cli"; '
        '}; '
        'make() { printf "make:%s:%s\\n" "$PWD" "$*" >> "$TEST_ROOT/calls"; }; '
        'prepare_redis_container_image() { printf "image-ready\\n" >> "$TEST_ROOT/calls"; }; '
        'build_redis_base',
        tmp_path,
        TEST_ROOT=str(tmp_path),
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "calls").read_text(encoding="utf-8").splitlines()
    assert calls[0].startswith(f"make:{tmp_path}/redis-source:-j")
    assert calls[0].endswith(" BUILD_TLS=no")
    assert calls[1] == "image-ready"


def test_image_loads_verified_local_archive_without_network(tmp_path: Path) -> None:
    archive_dir = tmp_path / "archives"
    archive_dir.mkdir()
    architecture = os.uname().machine
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = archive_dir / archive_name
    archive.write_bytes(b"test openEuler image")
    checksum = archive_dir / f"{archive_name}.sha256sum"
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
    environment = {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "REDIS_IMAGE_ARCHIVE_DIR": str(archive_dir),
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "IMAGE_ARCH": "amd64" if architecture == "x86_64" else "arm64",
    }
    script = f'source "{COMMON}"; initialize_runtime; prepare_redis_container_image'
    passed = run_shell(script, tmp_path / "work", **environment)
    assert passed.returncode == 0, passed.stdout + passed.stderr
    image_ref = tmp_path / "work" / "redis-container-image-24.03-LTS-SP4.txt"
    assert image_ref.read_text(encoding="utf-8").strip() == "openeuler-test:latest"
    assert f"load --input {archive}" in (tmp_path / "docker-calls.log").read_text(encoding="utf-8")

    image_ref.unlink()
    checksum.write_text("0" * 64 + f"  {archive_name}\n", encoding="utf-8")
    failed = run_shell(script, tmp_path / "work", **environment)
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout


def test_multi_container_start_uses_2u8g_and_private_mount(tmp_path: Path) -> None:
    bin_dir = tmp_path / "redis-source" / "src"
    bin_dir.mkdir(parents=True)
    (bin_dir / "redis-server").write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    (bin_dir / "redis-server").chmod(0o755)
    cli = bin_dir / "redis-cli"
    cli.write_text(
        '#!/bin/sh\n'
        'port=""\n'
        'while [ "$#" -gt 0 ]; do\n'
        '  if [ "$1" = -p ]; then port="$2"; shift 2; else shift; fi\n'
        'done\n'
        'if [ -f "$TEST_ROOT/started-$port" ]; then printf "PONG\\n"; else exit 1; fi\n',
        encoding="utf-8",
    )
    cli.chmod(0o755)
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'if [ "$1 $2" = "container inspect" ]; then exit 1; fi\n'
        'if [ "$1" = exec ]; then\n'
        '  while [ "$#" -gt 0 ]; do\n'
        '    if [ "$1" = --port ]; then touch "$TEST_ROOT/started-$2"; break; fi\n'
        '    shift\n'
        '  done\n'
        'fi\n'
        'exit 0\n', encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    completed = run_shell(
        f'source "{START}"; '
        'prepare_redis_container_image() { REDIS_CONTAINER_IMAGE=openeuler-test; }; '
        'select_redis_cpu_set() { printf "10,11,12 3\\n"; }; '
        'start_redis_service',
        tmp_path,
        PATH=f"{tmp_path}:{os.environ['PATH']}",
        TEST_ROOT=str(tmp_path),
        DOCKER_CALLS=str(tmp_path / "docker-calls.log"),
        REDIS_INSTANCE_COUNT="2",
        REDIS_SERVICE_PORT="3307",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (tmp_path / "redis-instance-count.txt").read_text(encoding="utf-8").strip() == "2"
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert calls.count("run --detach") == 2
    assert "--cpus=2" in calls and "--memory=8g" in calls
    assert "--cpuset-cpus=10,11,12" in calls and "--cpuset-mems=3" in calls
    assert f"source={tmp_path},target={tmp_path}" in calls
    assert "--privileged" not in calls
    assert "--port 3307" in calls and "--port 3308" in calls


def test_stop_reads_started_count_and_preserves_other_directories(tmp_path: Path) -> None:
    for instance_id in (1, 2, 3):
        data_dir = tmp_path / "instances" / str(instance_id)
        data_dir.mkdir(parents=True)
        (data_dir / "marker").write_text(str(instance_id), encoding="utf-8")
    (tmp_path / "redis-instance-count.txt").write_text("2\n", encoding="utf-8")
    completed = run_shell(
        f'source "{STOP}"; '
        'remove_redis_container() { return 0; }; '
        'stop_redis_service',
        tmp_path,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert not (tmp_path / "instances" / "1").exists()
    assert not (tmp_path / "instances" / "2").exists()
    assert (tmp_path / "instances" / "3" / "marker").read_text(encoding="utf-8") == "3"
    assert not (tmp_path / "redis-instance-count.txt").exists()
