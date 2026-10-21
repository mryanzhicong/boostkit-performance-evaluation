"""Contract tests for normalizing sonic-cpp's official Google Benchmark JSON."""

import json
import os
import subprocess
import sys
from pathlib import Path

PARSER = (
    Path(__file__).resolve().parents[1] / "scripts" / "results" / "parse_benchmark.py"
)
CASE_DIR = Path(__file__).resolve().parents[1]


def test_normalizes_official_sonic_scenarios_with_verbatim_names(tmp_path):
    official = tmp_path / "benchmark.json"
    normalized = tmp_path / "benchmark_sonic_cpp.json"
    official.write_text(
        json.dumps(
            {
                "context": {
                    "num_cpus": 8,
                    "mhz_per_cpu": 2500,
                    "library_build_type": "release",
                },
                "benchmarks": [
                    {
                        "run_name": "Sonic_Get_Int/Get<Json>/docs/gb.json",
                        "run_type": "aggregate",
                        "aggregate_name": "median",
                        "cpu_time": 900.0,
                        "time_unit": "ns",
                    },
                    {
                        "run_name": "Sonic_Get_Int/Get<Json>/docs/gb.json",
                        "cpu_time": 1000.0,
                        "time_unit": "ns",
                    },
                    {
                        "run_name": "Sonic_Get_String/Get<Json>/docs/syntax.json",
                        "cpu_time": 2.0,
                        "time_unit": "us",
                    },
                ],
            }
        ),
        encoding="utf-8",
    )
    environment = {
        **os.environ,
        "SOFTWARE_VERSION": "69deb02",
        "PERF_VARIANT": "base",
        "EXPECTED_ARCH": "x86_64",
        "BENCHMARK_MIN_TIME": "3s",
    }
    completed = subprocess.run(
        [sys.executable, str(PARSER), str(official), str(normalized)],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    result = json.loads(normalized.read_text(encoding="utf-8"))
    assert list(result["results"]) == [
        "Sonic_Get_Int/Get<Json>/docs/gb.json",
        "Sonic_Get_String/Get<Json>/docs/syntax.json",
    ]
    assert result["results"]["Sonic_Get_Int/Get<Json>/docs/gb.json"]["value"] == 1000.0
    assert (
        result["results"]["Sonic_Get_String/Get<Json>/docs/syntax.json"]["value"]
        == 2000.0
    )
    assert result["variant"] == "base"
    assert result["parameters"]["variant"] == "base"
    assert result["parameters"]["benchmark_filter"] == "Sonic"
    assert result["parameters"]["benchmark_min_time"] == "3s"
    assert result["runtime_context"]["num_cpus"] == 8


def test_optimized_build_fails_without_running_base_build(tmp_path):
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_sonic_cpp',
            "bash",
            str(CASE_DIR / "scripts" / "builders" / "dispatch.sh"),
        ],
        env={**os.environ, "PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "optimized sonic-cpp build is not implemented" in completed.stdout
    assert not (tmp_path / "sonic-cpp-source").exists()


def test_standalone_variant_option_rejects_unknown_values():
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "sonic_cpp_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


def test_base_build_dispatch_preserves_private_workdir_contract(tmp_path):
    fake_bin = tmp_path / "fake-bin"
    fake_bin.mkdir()
    for command, body in {
        "git": (
            "#!/bin/bash\n"
            'if [ "$1" = "clone" ]; then\n'
            '    mkdir -p "${@: -1}"\n'
            "    exit 0\n"
            "fi\n"
            'if [ "$1" = "-C" ] && [ "$3" = "rev-parse" ]; then\n'
            "    printf '%s\\n' "
            "'69deb02c099361139dd387eb6c7034a4836ce9b3'\n"
            "fi\n"
            "exit 0\n"
        ),
        "cmake": (
            "#!/bin/bash\n"
            'build_dir=""\n'
            'while [ "$#" -gt 0 ]; do\n'
            '    if [ "$1" = "-B" ]; then\n'
            '        build_dir="$2"\n'
            "    fi\n"
            "    shift\n"
            "done\n"
            'if [ -n "${build_dir}" ]; then\n'
            '    mkdir -p "${build_dir}/benchmark"\n'
            "    printf '#!/bin/sh\\n' > \"${build_dir}/benchmark/bench\"\n"
            '    chmod +x "${build_dir}/benchmark/bench"\n'
            "fi\n"
            "exit 0\n"
        ),
        "c++": (
            "#!/bin/sh\n"
            'if [ "$1" = "--version" ]; then\n'
            "    printf 'fake-c++ 13.0.0\\n'\n"
            "fi\n"
            "exit 0\n"
        ),
        "make": "#!/bin/sh\nexit 0\n",
    }.items():
        executable = fake_bin / command
        executable.write_text(body, encoding="utf-8")
        executable.chmod(0o755)

    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    version_file = work_dir / "actual-version.txt"
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_sonic_cpp',
            "bash",
            str(CASE_DIR / "scripts" / "builders" / "dispatch.sh"),
        ],
        env={
            **os.environ,
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "PERF_VARIANT": "base",
            "SOFTWARE_VERSION": "69deb02",
            "EXPECTED_ARCH": os.uname().machine,
            "PERF_RUN_ID": "test-1",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(results_dir),
            "PERF_ACTUAL_VERSION_FILE": str(version_file),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert version_file.read_text(encoding="utf-8") == "69deb02\n"
    assert (
        json.loads((results_dir / "build_variant.json").read_text())["variant"]
        == "base"
    )
    assert (work_dir / "build" / "benchmark" / "bench").is_file()
