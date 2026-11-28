"""Verify MariaDB variant dispatch, container ownership guards, offline archive checks, and cleanup."""

from __future__ import annotations

import hashlib
import os
import stat
import subprocess
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]


def _make_executable(path: Path, content: str) -> Path:
    path.write_text(content, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return path


def _base_env(tmp_path: Path, bin_dir: Path, run_id: str = "mariadb-test-1") -> dict[str, str]:
    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{bin_dir}:{env['PATH']}",
            "SOFTWARE_VERSION": "11.8.10",
            "EXPECTED_ARCH": "x86_64",
            "PERF_RUN_ID": run_id,
            "PERF_WORK_DIR": str(tmp_path / "work"),
            "RESULTS_DIR": str(tmp_path / "results"),
            "PERF_ACTUAL_VERSION_FILE": str(tmp_path / "work" / "actual-version.txt"),
            "MARIADB_OFFLINE_DIR": str(tmp_path / "offline"),
        }
    )
    return env


def test_optimized_variant_fails_without_fallback_or_variant_json(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    env = _base_env(tmp_path, bin_dir)
    env["PERF_VARIANT"] = "optimized"

    proc = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/builders/dispatch.sh" && build_mariadb'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 30
    assert "optimized MariaDB build has not been implemented" in proc.stdout + proc.stderr
    assert not (tmp_path / "results" / "build_variant.json").exists()


def test_container_ownership_and_label_guards(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  info) exit 0 ;;
  container) exit 0 ;;
  inspect)
    if [[ "$*" == *"Labels"* ]]; then printf 'other-task-id\\n'; exit 0; fi
    if [[ "$*" == *"State.Running"* ]]; then printf 'true\\n'; exit 0; fi
    ;;
  stop|rm)
    printf 'FORBIDDEN_STOP_OR_RM\\n' >> "{docker_log}"
    exit 99
    ;;
esac
exit 0
""",
    )
    env = _base_env(tmp_path, bin_dir, run_id="mariadb-own-1")

    r_create = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && require_mariadb_container'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_create.returncode == 40
    assert "refusing to reuse or overwrite an existing container" in r_create.stdout + r_create.stderr

    r_check = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && check_mariadb_container'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_check.returncode == 40
    assert "container label mismatch" in r_check.stdout + r_check.stderr

    r_stop = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_mariadb_service'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_stop.returncode == 70
    assert "FORBIDDEN_STOP_OR_RM" not in docker_log.read_text(encoding="utf-8")


def test_stop_saves_service_logs_and_removes_matching_container(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  container) exit 0 ;;
  inspect) printf 'mariadb-match-7\\n'; exit 0 ;;
  logs) printf 'mariadb container log line\\n'; exit 0 ;;
  stop|rm) exit 0 ;;
esac
exit 0
""",
    )
    env = _base_env(tmp_path, bin_dir, run_id="mariadb-match-7")
    inst_dir = tmp_path / "work" / "instances" / "1"
    inst_dir.mkdir(parents=True)
    (inst_dir / "mariadb.err").write_text("mariadbd error log sample\n", encoding="utf-8")
    (tmp_path / "results").mkdir(parents=True)

    proc = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_mariadb_service'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0
    assert (tmp_path / "results" / "service-logs" / "mariadb-1.err").read_text(encoding="utf-8").strip() == "mariadbd error log sample"
    assert (tmp_path / "results" / "service-logs" / "container.log").read_text(encoding="utf-8").strip() == "mariadb container log line"
    assert not (tmp_path / "work" / "instances").exists()
    logged = docker_log.read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-mariadb-x86_64-mariadb-match-7-1" in logged
    assert "rm boostkit-mariadb-x86_64-mariadb-match-7-1" in logged


def test_offline_source_archive_sha256_hit_and_corrupt_download_cleanup(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    curl_log = tmp_path / "curl.log"
    _make_executable(
        bin_dir / "curl",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{curl_log}"
out=""
while (($#)); do
  if [[ "$1" == "-o" ]]; then out="$2"; shift 2; else shift; fi
done
printf 'bad-archive-bytes' > "$out"
exit 0
""",
    )
    valid_bytes = b"mariadb-11.8.10-source-tarball"
    valid_sha = hashlib.sha256(valid_bytes).hexdigest()

    offline_dir = tmp_path / "offline"
    offline_dir.mkdir()
    (offline_dir / "mariadb-11.8.10.tar.gz").write_bytes(valid_bytes)

    env = _base_env(tmp_path, bin_dir)
    env["MARIADB_SOURCE_SHA256"] = valid_sha

    hit = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && acquire_mariadb_source_archive'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert hit.returncode == 0
    assert (tmp_path / "work" / "mariadb-11.8.10.tar.gz").read_bytes() == valid_bytes
    assert not curl_log.exists()

    (offline_dir / "mariadb-11.8.10.tar.gz").write_bytes(b"corrupt")
    (tmp_path / "work" / "mariadb-11.8.10.tar.gz").write_bytes(b"half")

    miss = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && acquire_mariadb_source_archive'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert miss.returncode == 30
    assert curl_log.exists()
    assert not (tmp_path / "work" / "mariadb-11.8.10.tar.gz").exists()
    assert not (tmp_path / "work" / "mariadb-11.8.10.tar.gz.part").exists()


def test_standalone_failure_invokes_stop_and_keeps_caller_workdir(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
exit 1
""",
    )
    caller_work = tmp_path / "caller-work"
    caller_work.mkdir()
    sentinel = caller_work / "keep.txt"
    sentinel.write_text("caller\n", encoding="utf-8")

    env = _base_env(tmp_path, bin_dir, run_id="standalone-mariadb-fail")
    env["PERF_WORK_DIR"] = str(caller_work)
    results_dir = tmp_path / "standalone-results"

    proc = subprocess.run(
        [
            "bash",
            str(CASE_DIR / "mariadb_test.sh"),
            "--version",
            "11.8.10",
            "--variant",
            "base",
            "--results-dir",
            str(results_dir),
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 30
    assert sentinel.is_file()
    assert (results_dir / "status.json").is_file()
    assert "container inspect boostkit-mariadb-x86_64-standalone-mariadb-fail-1" in docker_log.read_text(encoding="utf-8")
