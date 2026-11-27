"""Verify variant dispatch, container ownership guards, offline model caching, and failure cleanup."""

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


def _base_env(tmp_path: Path, bin_dir: Path, run_id: str = "test-run-1") -> dict[str, str]:
    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{bin_dir}:{env['PATH']}",
            "SOFTWARE_VERSION": "3ac67535c86",
            "EXPECTED_ARCH": "x86_64",
            "PERF_RUN_ID": run_id,
            "PERF_WORK_DIR": str(tmp_path / "work"),
            "RESULTS_DIR": str(tmp_path / "results"),
            "PERF_ACTUAL_VERSION_FILE": str(tmp_path / "work" / "actual-version.txt"),
            "LLAMA_CPP_OFFLINE_DIR": str(tmp_path / "offline"),
        }
    )
    return env


def test_optimized_variant_fails_without_fallback_or_variant_json(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    env = _base_env(tmp_path, bin_dir)
    env["PERF_VARIANT"] = "optimized"

    proc = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/builders/dispatch.sh" && build_llama_cpp',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 30
    assert "optimized llama-cpp build has not been implemented" in proc.stdout + proc.stderr
    assert not (tmp_path / "results" / "build_variant.json").exists()


def test_refuses_to_overwrite_existing_container_and_preserves_other_run_label(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  info) exit 0 ;;
  container)
    if [[ "$2" == inspect ]]; then exit 0; fi
    ;;
  inspect)
    if [[ "$*" == *"Labels"* ]]; then printf 'other-run-999\\n'; exit 0; fi
    if [[ "$*" == *"State.Running"* ]]; then printf 'true\\n'; exit 0; fi
    ;;
  stop|rm)
    printf 'UNEXPECTED_DESTRUCTIVE_CALL\\n' >> "{docker_log}"
    exit 99
    ;;
esac
exit 0
""",
    )
    env = _base_env(tmp_path, bin_dir, run_id="run-123")

    create = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && require_llama_cpp_container',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert create.returncode == 40
    assert "refusing to reuse or overwrite an existing container" in create.stdout + create.stderr

    check = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && check_llama_cpp_container',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert check.returncode == 40
    assert "container label mismatch" in check.stdout + check.stderr

    remove = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_llama_cpp_runtime',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert remove.returncode == 70
    assert "UNEXPECTED_DESTRUCTIVE_CALL" not in docker_log.read_text(encoding="utf-8")


def test_stop_saves_logs_and_removes_only_matching_label_container(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  container) exit 0 ;;
  inspect) printf 'run-match-42\\n'; exit 0 ;;
  logs) printf 'diagnostic container line\\n'; exit 0 ;;
  stop|rm) exit 0 ;;
esac
exit 0
""",
    )
    env = _base_env(tmp_path, bin_dir, run_id="run-match-42")
    (tmp_path / "results").mkdir(parents=True)

    proc = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/stages/stop.sh" && stop_llama_cpp_runtime',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0
    assert (tmp_path / "results" / "container.log").read_text(encoding="utf-8").strip() == "diagnostic container line"
    logged = docker_log.read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-llama-cpp-x86_64-run-match-42" in logged
    assert "rm boostkit-llama-cpp-x86_64-run-match-42" in logged


def test_offline_model_hit_skips_network_and_corrupt_download_leaves_no_cache(tmp_path: Path) -> None:
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
printf 'NOT_A_VALID_MODEL' > "$out"
exit 0
""",
    )
    valid_bytes = b"GGUF" + b"0123456789abcdef" * 32
    valid_sha = hashlib.sha256(valid_bytes).hexdigest()

    offline_dir = tmp_path / "offline"
    offline_dir.mkdir()
    (offline_dir / "bge-m3-q8_0.gguf").write_bytes(valid_bytes)

    env = _base_env(tmp_path, bin_dir)
    env["LLAMA_CPP_MODEL_SHA256"] = valid_sha

    hit = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && prepare_bge_m3_model',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert hit.returncode == 0
    assert (tmp_path / "work" / "models" / "bge-m3-q8_0.gguf").read_bytes() == valid_bytes
    assert not curl_log.exists()

    # Corrupt offline file + invalid private copy -> falls back to curl, rejects bad checksum, leaves no file
    (offline_dir / "bge-m3-q8_0.gguf").write_bytes(b"corrupt")
    (tmp_path / "work" / "models" / "bge-m3-q8_0.gguf").write_bytes(b"partial")

    miss = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/common.sh" && initialize_runtime && prepare_bge_m3_model',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert miss.returncode == 50
    assert curl_log.exists()
    assert not (tmp_path / "work" / "models" / "bge-m3-q8_0.gguf").exists()
    assert not (tmp_path / "work" / "models" / "bge-m3-q8_0.gguf.part").exists()


def test_standalone_failure_invokes_stop_and_keeps_caller_workdir(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  info) exit 1 ;;
  container) exit 1 ;;
esac
exit 1
""",
    )
    caller_work = tmp_path / "caller-work"
    caller_work.mkdir()
    sentinel = caller_work / "keep-me.txt"
    sentinel.write_text("caller-owned\n", encoding="utf-8")

    env = _base_env(tmp_path, bin_dir, run_id="standalone-fail-1")
    env["PERF_WORK_DIR"] = str(caller_work)
    results_dir = tmp_path / "standalone-results"

    proc = subprocess.run(
        [
            "bash",
            str(CASE_DIR / "llama-cpp_test.sh"),
            "--version",
            "3ac67535c86",
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
    assert (results_dir / "results.json").is_file()
    assert "container inspect boostkit-llama-cpp-x86_64-standalone-fail-1" in docker_log.read_text(encoding="utf-8")


def test_start_and_test_reuse_container_and_propagate_benchmark_failure(tmp_path: Path) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_log = tmp_path / "docker.log"
    valid_bytes = b"GGUF" + b"0123456789abcdef" * 32
    valid_sha = hashlib.sha256(valid_bytes).hexdigest()

    offline_dir = tmp_path / "offline"
    offline_dir.mkdir()
    (offline_dir / "bge-m3-q8_0.gguf").write_bytes(valid_bytes)

    work_dir = tmp_path / "work"
    bench_bin = work_dir / "build" / "bin" / "llama-bench"
    bench_bin.parent.mkdir(parents=True)
    _make_executable(bench_bin, "#!/usr/bin/env bash\nexit 0\n")

    _make_executable(
        bin_dir / "docker",
        f"""#!/usr/bin/env bash
printf '%s\\n' "$*" >> "{docker_log}"
case "$1" in
  run|load)
    printf 'FORBIDDEN_DOCKER_RUN_OR_LOAD\\n' >> "{docker_log}"
    exit 99
    ;;
  inspect)
    if [[ "$*" == *"State.Running"* ]]; then printf 'true\\n'; exit 0; fi
    if [[ "$*" == *"Labels"* ]]; then printf 'reuse-run-7\\n'; exit 0; fi
    ;;
  exec)
    if [[ "$*" == *"--help"* || "$*" == *"test -r"* ]]; then exit 0; fi
    if [[ "$*" == *"llama-bench"* ]]; then
      printf 'llama-bench: benchmark 1/1: starting\\n' >&2
      printf '[]\\n'
      exit 7
    fi
    ;;
esac
exit 0
""",
    )

    env = _base_env(tmp_path, bin_dir, run_id="reuse-run-7")
    env["LLAMA_CPP_MODEL_SHA256"] = valid_sha

    start_proc = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/stages/start.sh" && start_llama_cpp_runtime',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert start_proc.returncode == 0

    test_proc = subprocess.run(
        [
            "bash",
            "-c",
            f'source "{CASE_DIR}/scripts/stages/test.sh" && run_llama_cpp_benchmarks',
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    assert test_proc.returncode == 50
    assert not (tmp_path / "results" / "benchmark_llama_cpp.json").exists()
    assert "llama-bench: benchmark 1/1: starting" in (
        tmp_path / "results" / "benchmark_llama_bench.log"
    ).read_text(encoding="utf-8")
    logged = docker_log.read_text(encoding="utf-8")
    assert "FORBIDDEN_DOCKER_RUN_OR_LOAD" not in logged
    assert logged.count("boostkit-llama-cpp-x86_64-reuse-run-7") >= 4

