"""Verify DPDK variant dispatch, container ownership guards, offline archive verification, and cleanup."""

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


def _base_env(tmp_path: Path, bin_dir: Path, run_id: str = "dpdk-test-1") -> dict[str, str]:
    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{bin_dir}:{env['PATH']}",
            "SOFTWARE_VERSION": "26.11.0",
            "EXPECTED_ARCH": "x86_64",
            "PERF_RUN_ID": run_id,
            "PERF_WORK_DIR": str(tmp_path / "work"),
            "RESULTS_DIR": str(tmp_path / "results"),
            "PERF_ACTUAL_VERSION_FILE": str(tmp_path / "work" / "actual-version.txt"),
            "DPDK_OFFLINE_DIR": str(tmp_path / "offline"),
        }
    )
    return env


def test_optimized_variant_fails_without_fallback_or_variant_json(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    env = _base_env(tmp_path, bin_dir)
    env["PERF_VARIANT"] = "optimized"

    proc = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/builders/dispatch.sh" && build_dpdk'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 30
    assert "optimized DPDK build has not been implemented" in proc.stdout + proc.stderr
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
    if [[ "$*" == *"Labels"* ]]; then printf 'foreign-run-id\\n'; exit 0; fi
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
    env = _base_env(tmp_path, bin_dir, run_id="my-run-1")

    r_create = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && require_dpdk_container'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_create.returncode == 40
    assert "refusing to reuse or overwrite an existing container" in r_create.stdout + r_create.stderr

    r_check = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && check_dpdk_container'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_check.returncode == 40
    assert "container label mismatch" in r_check.stdout + r_check.stderr

    r_stop = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_dpdk_runtime'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r_stop.returncode == 70
    assert "FORBIDDEN_STOP_OR_RM" not in docker_log.read_text(encoding="utf-8")


def test_stop_saves_logs_and_removes_matching_container(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  container) exit 0 ;;
  inspect) printf 'dpdk-match-9\\n'; exit 0 ;;
  logs) printf 'dpdk container diag\\n'; exit 0 ;;
  stop|rm) exit 0 ;;
esac
exit 0
""",
    )
    env = _base_env(tmp_path, bin_dir, run_id="dpdk-match-9")
    (tmp_path / "results").mkdir(parents=True)

    proc = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_dpdk_runtime'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0
    assert (tmp_path / "results" / "container.log").read_text(encoding="utf-8").strip() == "dpdk container diag"
    logged = docker_log.read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-dpdk-x86_64-dpdk-match-9" in logged
    assert "rm boostkit-dpdk-x86_64-dpdk-match-9" in logged


def test_offline_tarball_md5_hit_and_corrupt_download_cleanup(tmp_path: Path) -> None:
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
printf 'corrupted_payload' > "$out"
exit 0
""",
    )
    valid_bytes = b"dpdk-26.11-test-archive-content"
    valid_md5 = hashlib.md5(valid_bytes).hexdigest()

    offline_dir = tmp_path / "offline"
    offline_dir.mkdir()
    (offline_dir / "dpdk-26.11.tar.xz").write_bytes(valid_bytes)

    env = _base_env(tmp_path, bin_dir)
    env["DPDK_EXPECTED_MD5"] = valid_md5

    hit = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && acquire_dpdk_tarball'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert hit.returncode == 0
    assert (tmp_path / "work" / "dpdk-26.11.tar.xz").read_bytes() == valid_bytes
    assert not curl_log.exists()

    (offline_dir / "dpdk-26.11.tar.xz").write_bytes(b"bad")
    (tmp_path / "work" / "dpdk-26.11.tar.xz").write_bytes(b"half")

    miss = subprocess.run(
        ["bash", "-c", f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && acquire_dpdk_tarball'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert miss.returncode == 30
    assert curl_log.exists()
    assert not (tmp_path / "work" / "dpdk-26.11.tar.xz").exists()
    assert not (tmp_path / "work" / "dpdk-26.11.tar.xz.part").exists()


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

    env = _base_env(tmp_path, bin_dir, run_id="standalone-dpdk-fail")
    env["PERF_WORK_DIR"] = str(caller_work)
    results_dir = tmp_path / "standalone-results"

    proc = subprocess.run(
        [
            "bash",
            str(CASE_DIR / "dpdk_test.sh"),
            "--version",
            "26.11.0",
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
    assert "container inspect boostkit-dpdk-x86_64-standalone-dpdk-fail" in docker_log.read_text(encoding="utf-8")
