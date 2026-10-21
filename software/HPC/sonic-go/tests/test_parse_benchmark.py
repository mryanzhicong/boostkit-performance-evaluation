"""Contract tests for normalizing sonic-go's official sonic_bench result JSON."""

import json
import os
import subprocess
import sys
from pathlib import Path

PARSER = (
    Path(__file__).resolve().parents[1] / "scripts" / "results" / "parse_sonic_bench.py"
)
CASE_DIR = Path(__file__).resolve().parents[1]


def run_parser(
    tmp_path: Path,
    payload: dict,
    architecture: str = "x86_64",
) -> subprocess.CompletedProcess[str]:
    raw = tmp_path / f"result-{architecture}.json"
    normalized = tmp_path / f"benchmark_sonic_go-{architecture}.json"
    raw.write_text(json.dumps(payload), encoding="utf-8")
    environment = {
        **os.environ,
        "SOFTWARE_VERSION": "1.15.2",
        "EXPECTED_ARCH": architecture,
        "PERF_VARIANT": "base",
        "SONIC_GO_TOOLCHAIN": "go1.24.6-default",
        "SONIC_GO_VERSION": "1.24.6",
    }
    return subprocess.run(
        [sys.executable, str(PARSER), str(raw), str(normalized)],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )


def official_payload() -> dict:
    return {
        "runs": [
            {"subject": "encoder", "mode": "default", "exit_code": 0},
            {"subject": "decoder", "mode": "default", "exit_code": 0},
        ],
        "results": [
            {
                "subject": "encoder",
                "mode": "default",
                "benchmark": "BenchmarkEncoder_Marshal",
                "iterations": 100,
                "ns_per_op": 1234.5,
                "bytes_per_op": 256,
                "allocs_per_op": 4,
            },
            {
                "subject": "parser",
                "mode": "default",
                "benchmark": "BenchmarkParser_Get",
                "iterations": 50,
                "ns_per_op": 987.5,
                "bytes_per_op": "",
                "allocs_per_op": 0,
            },
        ],
        "test_cmd": "go test -run='^$' -benchmem -benchtime=5s ./encoder",
        "toolchain_version": "go version go1.24.6 linux/amd64",
        "benchtime": "5s",
        "env": {"cpu_bind": "taskset:0-95", "sonic_no_async_gc": "1"},
    }


def test_normalizes_official_bench_rows_with_verbatim_names(tmp_path):
    completed = run_parser(tmp_path, official_payload())
    assert completed.returncode == 0, completed.stderr
    result = json.loads(
        (tmp_path / "benchmark_sonic_go-x86_64.json").read_text(encoding="utf-8")
    )
    encoder_ns = "encoder :: default :: BenchmarkEncoder_Marshal :: ns/op"
    assert next(iter(result["results"])).startswith("encoder :: default ::")
    assert result["results"][encoder_ns]["value"] == 1234.5
    assert result["results"][encoder_ns]["unit"] == "ns/op"
    assert result["results"][encoder_ns]["direction"] == "lower_is_better"
    assert result["results"][encoder_ns]["group"] == "encoder/default"
    parser_allocs = "parser :: default :: BenchmarkParser_Get :: allocs/op"
    assert result["results"][parser_allocs]["value"] == 0
    assert "parser :: default :: BenchmarkParser_Get :: B/op" not in result["results"]
    assert result["variant"] == "base"
    assert result["parameters"]["variant"] == "base"
    assert result["parameters"]["toolchain_target"] == "go1.24.6-default"
    assert result["parameters"]["go_source_version"] == "1.24.6"


def test_failed_run_exit_codes_fail_the_parse(tmp_path):
    payload = official_payload()
    payload["runs"][1]["exit_code"] = 2
    completed = run_parser(tmp_path, payload)
    assert completed.returncode == 1
    assert "sonic benchmark runs failed" in completed.stderr


def test_parameters_stay_identical_across_architectures(tmp_path):
    # Regression: the framework compares resolved workload parameters between
    # x86_64 and aarch64 and rejects the comparison when they differ. The
    # official test_cmd embeds the architecture-specific work directory
    # (cd $SONIC_DIR && ...), so it must never leak into parameters.
    parameters = {}
    for architecture in ("x86_64", "aarch64"):
        payload = official_payload()
        payload["test_cmd"] = (
            f"cd /home/runner/boostkit-perf/sonic-go/1.15.2/{architecture}/1/"
            "objects/go/src/sonic && go test -run='^$' -benchmem -benchtime=5s"
            " ./encoder"
        )
        completed = run_parser(tmp_path, payload, architecture=architecture)
        assert completed.returncode == 0, completed.stderr
        normalized = json.loads(
            (tmp_path / f"benchmark_sonic_go-{architecture}.json").read_text(
                encoding="utf-8"
            )
        )
        assert "boostkit-perf" not in json.dumps(normalized["parameters"])
        parameters[architecture] = normalized["parameters"]
    assert parameters["x86_64"] == parameters["aarch64"]


def test_optimized_build_fails_without_running_base_build(tmp_path):
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_sonic_go',
            "bash",
            str(CASE_DIR / "scripts" / "builders" / "dispatch.sh"),
        ],
        env={**os.environ, "PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "optimized sonic-go build is not implemented" in completed.stdout
    assert not (tmp_path / "objects").exists()


def test_standalone_variant_option_rejects_unknown_values():
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "sonic_go_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


def test_base_build_dispatch_loads_the_base_builder(tmp_path):
    fake_bin = tmp_path / "fake-bin"
    fake_bin.mkdir()
    for command, body in {
        "git": "#!/bin/sh\nexit 1\n",
        "go": "#!/bin/sh\nprintf 'go version go1.27.0 linux/amd64\\n'\n",
        "curl": "#!/bin/sh\nexit 0\n",
        "gcc": "#!/bin/sh\nexit 0\n",
        "tar": "#!/bin/sh\nexit 0\n",
        "gzip": "#!/bin/sh\nexit 0\n",
        "sha256sum": "#!/bin/sh\nexit 0\n",
        "awk": "#!/bin/sh\nexit 0\n",
        "taskset": "#!/bin/sh\nexit 0\n",
        "python3": f'#!/bin/sh\nexec "{sys.executable}" "$@"\n',
    }.items():
        executable = fake_bin / command
        executable.write_text(body, encoding="utf-8")
        executable.chmod(0o755)

    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_sonic_go',
            "bash",
            str(CASE_DIR / "scripts" / "builders" / "dispatch.sh"),
        ],
        env={
            **os.environ,
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "PERF_VARIANT": "base",
            "SOFTWARE_VERSION": "1.15.2",
            "EXPECTED_ARCH": os.uname().machine,
            "PERF_RUN_ID": "test-1",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(results_dir),
            "PERF_ACTUAL_VERSION_FILE": str(results_dir / "actual-version.txt"),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "failed to clone Go source branch" in completed.stdout
    assert (work_dir / "objects" / "go" / "src").is_dir()
    assert not (results_dir / "build_variant.json").exists()


def test_stop_stage_removes_the_private_runtime_directory(tmp_path):
    work_dir = tmp_path / "work"
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; stop_sonic_go_runtime',
            "bash",
            str(CASE_DIR / "scripts" / "stages" / "stop.sh"),
        ],
        env={
            **os.environ,
            "PERF_RUN_ID": "test-1",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(tmp_path / "results"),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "removed private Sonic Go runtime directory" in completed.stdout
    assert not (work_dir / "runtime").exists()
