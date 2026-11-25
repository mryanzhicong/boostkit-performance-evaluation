"""Keep every framework stage on the same task-owned container."""

from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"


def read(path: str) -> str:
    return (SCRIPTS / path).read_text(encoding="utf-8")


def test_only_build_loads_image_and_starts_container() -> None:
    build = read("builders/base.sh")
    start = read("stages/start.sh")
    test = read("stages/test.sh")
    stop = read("stages/stop.sh")

    assert "require_simdjson_docker" in build
    assert "start_simdjson_container" in build
    assert "require_simdjson_docker" not in start + test
    assert "start_simdjson_container" not in start + test
    assert "check_simdjson_container" in start
    assert "check_simdjson_container" in test
    assert "remove_simdjson_container" in stop


def test_build_runs_inside_the_container() -> None:
    build = read("builders/base.sh")
    for needle in (
        "simdjson_container_exec_root dnf install",
        "simdjson_container_exec tar xzf",
        'simdjson_container_exec cmake -S "${SCRIPT_DIR}/scripts/benchmarks"',
        "simdjson_container_exec bash -c 'cmake --build",
        'simdjson_container_exec "${build}/parse"',
    ):
        assert needle in build, needle


def test_every_scenario_runs_through_docker_exec() -> None:
    test = read("stages/test.sh")
    for scenario in (
        "dom_parse",
        "dom_parse_stream",
        "bench_parse_call",
        "bench_dom_api",
        "bench_ondemand",
    ):
        assert scenario in test
    # Every measured process is started by the docker exec helper, never on the host.
    assert "simdjson_container_exec timeout 2400" in test
    assert '"${build}/parse"' in test
    assert '"${build}/parse_stream"' in test
    assert '"${build}/${suite}"' in test
    assert "--benchmark_out=" in test
    # stdout and stderr stay in separate files: DOM tools print a progress bar on
    # stderr and the measured rows on stdout.
    assert '2> "${err}"' in test


def test_optimized_fails_explicitly() -> None:
    optimized = read("builders/optimized.sh")
    assert "return 30" in optimized
    assert "not implemented" in optimized


def test_stop_is_idempotent_and_guarded() -> None:
    stop = read("stages/stop.sh")
    assert "remove_simdjson_container" in stop
    assert "command -v docker" in stop
    assert "still exists after cleanup" in stop
    assert "rm -rf" not in stop


def test_no_hardcoded_cpu_pinning() -> None:
    for relative in ("builders/base.sh", "stages/start.sh", "stages/test.sh"):
        text = read(relative)
        assert "taskset" not in text
        assert "numactl" not in text
        assert "--cpuset" not in text


def test_harness_disables_fma_contraction() -> None:
    cmake = read("benchmarks/CMakeLists.txt")
    assert "add_compile_options(-ffp-contract=off)" in cmake
    readme = (Path(__file__).resolve().parents[1] / "README.md").read_text(encoding="utf-8")
    assert "-ffp-contract=off" in readme


def test_standalone_rejects_unknown_variant(tmp_path) -> None:
    import subprocess

    case = Path(__file__).resolve().parents[1]
    result = subprocess.run(
        ["bash", str(case / "simdjson_test.sh"), "--variant", "bogus",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "unsupported build variant" in result.stdout + result.stderr


def test_standalone_rejects_unsupported_version(tmp_path) -> None:
    import subprocess

    case = Path(__file__).resolve().parents[1]
    result = subprocess.run(
        ["bash", str(case / "simdjson_test.sh"), "--version", "4.6.10",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "only simdjson 4.6.11 is supported" in result.stdout + result.stderr


def test_sampling_contract_matches_readme() -> None:
    test = read("stages/test.sh")
    assert "PERF_REPS=5" not in test  # default lives in common.sh
    common = read("common.sh")
    assert 'PERF_REPS="${PERF_REPS:-5}"' in common
    assert 'SIMDJSON_WARMUPS="${SIMDJSON_WARMUPS:-1}"' in common
    assert "below the 5-sample contract" in test
