"""Validate the manually maintained case catalog and matrix defaults."""

import hashlib
import importlib.util
import json
import os
import platform
import shutil
import subprocess
import tarfile
import zipfile
from pathlib import Path

import pytest
import yaml
from catalog import (
    ROOT,
    build_matrix,
    configured_runner_labels,
    configured_software,
    discover_cases,
    validate_case,
    validate_catalog,
)


def test_registered_cases_are_valid() -> None:
    cases = discover_cases(ROOT)
    assert cases == [
        ROOT / "software" / "Database" / "redis" / "case.yaml",
        ROOT / "software" / "HPC" / "lz4" / "case.yaml",
    ]
    case, errors = validate_case(cases[0], ROOT)
    assert errors == []
    assert case is not None
    assert case["versions"] == ["7.4.10", "8.0.0", "8.0.6"]
    assert case["execution"]["timeout_minutes"] == 600
    assert case["execution"]["type"] == "shell-functions"
    assert "environment" not in case["execution"]
    assert case["execution"]["stages"] == {
        "build": {"script": "redis_test.sh", "function": "build_redis"},
        "start": {"script": "redis_test.sh", "function": "start_redis_service"},
        "test": {"script": "redis_test.sh", "function": "run_redis_benchmarks"},
        "stop": {"script": "redis_test.sh", "function": "stop_redis_service"},
    }
    assert case["outputs"] == {
        "primary_benchmark": {
            "path": "benchmark_redis.json",
            "stage": "test",
            "format": "json",
            "required": True,
        },
        "micro_benchmark": {
            "path": "micro_benchmark.json",
            "stage": "test",
            "format": "json",
            "required": True,
        },
        "aggregate_result": {
            "path": "results.json",
            "stage": "test",
            "format": "json",
            "required": True,
        },
    }
    assert case["metrics"]["source"] == "aggregate_result"
    assert list(case["metrics"]["definitions"]) == [
        "set_qps_c50",
        "get_qps_c50",
        "average_latency",
        "maximum_p99_latency",
        "client_scaling_ratio",
    ]
    assert all(
        "source" not in definition and "target" not in definition
        for definition in case["metrics"]["definitions"].values()
    )

    lz4_case, errors = validate_case(cases[1], ROOT)
    assert errors == []
    assert lz4_case is not None
    assert lz4_case["versions"] == ["1.9.4", "1.10.0"]
    assert lz4_case["execution"]["stages"] == {
        "build": {"script": "lz4_test.sh", "function": "build_lz4"},
        "start": {"script": "lz4_test.sh", "function": "start_lz4_runtime"},
        "test": {"script": "lz4_test.sh", "function": "run_lz4_benchmarks"},
        "stop": {"script": "lz4_test.sh", "function": "stop_lz4_runtime"},
    }
    assert list(lz4_case["metrics"]["definitions"]) == [
        "compress_speed_64k",
        "decompress_speed_64k",
        "compress_speed_4m",
        "decompress_speed_4m",
    ]


def test_software_registry_normalizes_empty_categories() -> None:
    registry = configured_software(ROOT)
    assert registry["Database"] == ["redis"]
    assert registry["HPC"] == ["lz4"]
    assert all(
        software == []
        for category, software in registry.items()
        if category not in {"Database", "HPC"}
    )


def test_catalog_rejects_unregistered_and_missing_cases(tmp_path) -> None:
    config = tmp_path / "config"
    config.mkdir()
    (config / "categories.yaml").write_text(
        "categories:\n  Database:\n", encoding="utf-8"
    )
    unregistered = tmp_path / "software" / "Database" / "redis" / "case.yaml"
    unregistered.parent.mkdir(parents=True)
    unregistered.write_text("{}\n", encoding="utf-8")
    _entries, errors = validate_catalog(tmp_path)
    assert any("case is not registered" in error for error in errors)

    (config / "categories.yaml").write_text(
        "categories:\n  Database:\n    - redis\n    - postgresql\n",
        encoding="utf-8",
    )
    _entries, errors = validate_catalog(tmp_path)
    assert any("registered case is missing" in error and "postgresql" in error for error in errors)


def test_catalog_validates_explicit_stage_scripts_and_functions(tmp_path) -> None:
    config = tmp_path / "config"
    config.mkdir()
    (config / "categories.yaml").write_text(
        "categories:\n  AI:\n    - sample\n", encoding="utf-8"
    )
    case_dir = tmp_path / "software" / "AI" / "sample"
    case_dir.mkdir(parents=True)
    (case_dir / "sample_test.sh").write_text(
        "build() { :; }\nstart() { :; }\ntest() { :; }\nstop() { :; }\n",
        encoding="utf-8",
    )
    payload = {
        "name": "sample",
        "category": "AI",
        "enabled": True,
        "versions": ["1.0"],
        "execution": {
            "type": "shell-functions",
            "stages": {
                stage: {"script": "sample_test.sh", "function": stage}
                for stage in ("build", "start", "test", "stop")
            },
            "timeout_minutes": 10,
            "environment": {},
        },
        "outputs": {
            "result": {
                "path": "results.json",
                "stage": "test",
                "format": "json",
                "required": True,
            }
        },
        "metrics": {
            "source": "result",
            "definitions": {
                "throughput": {
                    "path": "summary.throughput",
                    "unit": "ops/s",
                    "direction": "higher_is_better",
                }
            }
        },
    }
    case_path = case_dir / "case.yaml"

    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert errors == []

    del payload["execution"]["stages"]["stop"]
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("execution.stages is missing: stop" in error for error in errors)

    payload["execution"]["stages"]["stop"] = {
        "script": "sample_test.sh",
        "function": "invalid-function",
    }
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("valid Shell function name" in error for error in errors)

    payload["execution"]["stages"]["stop"] = {
        "script": "../outside.sh",
        "function": "stop",
    }
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("must remain inside the software directory" in error for error in errors)

    payload["execution"]["stages"]["stop"] = {
        "script": "sample_test.sh",
        "function": "stop",
        "arguments": ["--legacy"],
    }
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("contains unsupported fields: arguments" in error for error in errors)


def test_catalog_validates_structured_outputs(tmp_path) -> None:
    config = tmp_path / "config"
    config.mkdir()
    (config / "categories.yaml").write_text(
        "categories:\n  AI:\n    - sample\n", encoding="utf-8"
    )
    case_dir = tmp_path / "software" / "AI" / "sample"
    case_dir.mkdir(parents=True)
    (case_dir / "sample_test.sh").write_text(
        "build() { :; }\nstart() { :; }\ntest() { :; }\nstop() { :; }\n",
        encoding="utf-8",
    )
    payload = {
        "name": "sample",
        "category": "AI",
        "enabled": True,
        "versions": ["1.0"],
        "execution": {
            "type": "shell-functions",
            "stages": {
                stage: {"script": "sample_test.sh", "function": stage}
                for stage in ("build", "start", "test", "stop")
            },
            "timeout_minutes": 10,
            "environment": {},
        },
        "outputs": {
            "result": {
                "path": "results.json",
                "stage": "test",
                "format": "json",
                "required": True,
            }
        },
        "metrics": {
            "source": "result",
            "definitions": {
                "throughput": {
                    "path": "summary.throughput",
                    "unit": "ops/s",
                    "direction": "higher_is_better",
                }
            }
        },
    }
    case_path = case_dir / "case.yaml"
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert errors == []

    payload["outputs"]["result"]["stage"] = "finalize"
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("output result.stage must be one of" in error for error in errors)

    payload["outputs"]["result"]["stage"] = "test"
    payload["outputs"]["result"]["format"] = "text"
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("source must be a JSON output" in error for error in errors)

    payload["outputs"]["result"]["format"] = "json"
    payload["outputs"]["result"]["required"] = False
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("source must be a required output" in error for error in errors)

    payload["outputs"]["result"]["required"] = True
    payload["outputs"]["result"]["path"] = "./build_info.json"
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("Framework-reserved: build_info.json" in error for error in errors)

    payload["outputs"]["result"]["path"] = "results.json"
    payload["metrics"]["definitions"]["throughput"]["target"] = 1000
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("contains unsupported fields: target" in error for error in errors)

    del payload["metrics"]["definitions"]["throughput"]["target"]
    payload["metrics"]["definitions"]["throughput"]["direction"] = "target_is_better"
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("has invalid direction" in error for error in errors)


def test_default_matrix_runs_every_version_on_both_architectures() -> None:
    matrix = build_matrix("all", "all", "all")["include"]
    assert len(matrix) == 10
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert {
        (item["software"], item["version"], item["arch"])
        for item in matrix
    } == {
        (software, version, architecture)
        for software, versions in {
            "redis": ("7.4.10", "8.0.0", "8.0.6"),
            "lz4": ("1.9.4", "1.10.0"),
        }.items()
        for version in versions
        for architecture in ("x86_64", "aarch64")
    }


def test_manual_filters_limit_redis_to_one_architecture_and_version() -> None:
    matrix = build_matrix("redis", "8.0.6", "aarch64")["include"]
    assert len(matrix) == 1
    assert matrix[0]["case_path"] == "software/Database/redis/case.yaml"
    assert matrix[0]["runner_label"] == configured_runner_labels()["aarch64"]


def test_unknown_software_is_rejected() -> None:
    with pytest.raises(ValueError, match="unknown or disabled software"):
        build_matrix("missing", "all", "all")


def test_global_runner_mapping_still_defines_both_architectures() -> None:
    labels = configured_runner_labels()
    assert set(labels) == {"x86_64", "aarch64"}
    assert all(labels.values())


def test_workflow_consumes_matrix_runner_label_without_duplicates() -> None:
    workflow = (ROOT / ".github" / "workflows" / "performance-test.yml").read_text(encoding="utf-8")
    assert (
        'run-name: "Performance evaluation - ${{ inputs.software }} '
        '${{ inputs.version }} (${{ inputs.architecture }})"'
    ) in workflow
    assert "matrix.runner_label" in workflow
    assert all(label not in workflow for label in configured_runner_labels().values())
    assert "vars.PERF_RUNNER" not in workflow
    assert "test_mode:" not in workflow
    assert "performance-results" in workflow
    assert "prepare_result_history.py" in workflow
    assert "publish_result_history.sh" in workflow
    assert "contents: write" in workflow
    assert "baseline-candidates" not in workflow
    assert "update_baseline requires architecture=all" in workflow
    assert "framework/catalog.py matrix" in workflow
    assert "framework/validate_case.py" not in workflow
    assert "framework/generate_matrix.py" not in workflow
    for stage in (
        "prepare",
        "build",
        "start",
        "test",
        "stop",
        "finalize",
    ):
        assert f"--stage {stage}" in workflow
    for removed_stage in ("validate", "start-service", "stop-service", "collect-report"):
        assert f"--stage {removed_stage}" not in workflow


def test_workflow_uses_default_pypi_on_ubuntu_and_aliyun_on_runners() -> None:
    workflow = (ROOT / ".github" / "workflows" / "performance-test.yml").read_text(
        encoding="utf-8"
    )
    prepare_job, performance_and_report = workflow.split("  performance:", 1)
    assert "--index-url" not in prepare_job
    assert workflow.count("https://mirrors.aliyun.com/pypi/simple/") == 1
    assert "https://mirrors.aliyun.com/pypi/simple/" in performance_and_report
    assert workflow.count('"PyYAML==6.0.2"') == 2
    assert workflow.count("--target") == 2
    assert "Verify preinstalled framework runtime" not in workflow
    assert not (ROOT / "pyproject.toml").exists()


def test_framework_uses_consolidated_catalog_results_and_report_modules() -> None:
    for path in (
        "framework/build_info.py",
        "framework/catalog.py",
        "framework/normalize_results.py",
        "framework/reporting.py",
    ):
        assert (ROOT / path).is_file()
    for removed_path in (
        "framework/adapter_base.py",
        "framework/aggregate_results.py",
        "framework/generate_matrix.py",
        "framework/validate_case.py",
        "framework/reporting",
        "framework/schemas",
    ):
        assert not (ROOT / removed_path).exists()


def test_redis_script_exposes_every_declared_stage_function() -> None:
    entrypoint = (ROOT / "software" / "Database" / "redis" / "redis_test.sh").read_text(
        encoding="utf-8"
    )
    for function in (
        "build_redis",
        "start_redis_service",
        "run_redis_benchmarks",
        "stop_redis_service",
    ):
        assert f"{function}()" in entrypoint
    for ambiguous_function in ("build", "start", "test", "stop"):
        assert f"\n{ambiguous_function}()" not in entrypoint
    assert "phase_build()" not in entrypoint
    assert "run_all()" not in entrypoint
    assert 'case "${1:-all}"' not in entrypoint


def test_redis_script_is_safe_to_source_without_running_a_stage(tmp_path) -> None:
    script = ROOT / "software" / "Database" / "redis" / "redis_test.sh"
    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    environment = dict(os.environ)
    environment.update({
        "PERF_WORK_DIR": str(work_dir),
        "RESULTS_DIR": str(results_dir),
        "TMPDIR": str(work_dir / "tmp"),
    })
    completed = subprocess.run(
        [
            "bash",
            "--noprofile",
            "--norc",
            "-c",
            (
                'source "$1"; declare -F build_redis start_redis_service '
                'run_redis_benchmarks stop_redis_service >/dev/null'
            ),
            "source-contract",
            str(script),
        ],
        check=False,
        env=environment,
    )
    assert completed.returncode == 0
    assert not work_dir.exists()
    assert not results_dir.exists()


def test_redis_build_preserves_the_original_script_command() -> None:
    entrypoint = (ROOT / "software" / "Database" / "redis" / "redis_test.sh").read_text(
        encoding="utf-8"
    )
    assert "make -j$(nproc) BUILD_TLS=no" in entrypoint
    assert 'REDIS_SERVER_BIN="${SOURCE_DIR}/src/redis-server"' in entrypoint
    assert 'REDIS_BENCHMARK_BIN="${SOURCE_DIR}/src/redis-benchmark"' in entrypoint
    assert 'REDIS_CLI_BIN="${SOURCE_DIR}/src/redis-cli"' in entrypoint
    for structural_regression in (
        "make install",
        "INSTALL_DIR",
        "DEPENDENCY_JOBS",
        "REDIS_MALLOC",
        'make -C "${SOURCE_DIR}/deps"',
    ):
        assert structural_regression not in entrypoint


def test_redis_workload_parameters_have_one_script_source() -> None:
    case = yaml.safe_load(
        (ROOT / "software" / "Database" / "redis" / "case.yaml").read_text(
            encoding="utf-8"
        )
    )
    assert "environment" not in case["execution"]

    benchmark = (
        ROOT / "software" / "Database" / "redis" / "scripts" / "benchmark_redis.py"
    ).read_text(encoding="utf-8")
    micro = (
        ROOT / "software" / "Database" / "redis" / "scripts" / "micro_benchmark.py"
    ).read_text(encoding="utf-8")
    entrypoint = (ROOT / "software" / "Database" / "redis" / "redis_test.sh").read_text(
        encoding="utf-8"
    )
    assert 'COMMANDS = ["SET", "GET", "INCR", "LPUSH"' in benchmark
    assert "CONCURRENCY_LEVELS = [1, 10, 50, 100, 200]" in benchmark
    assert "NUM_REQUESTS = 100000" in benchmark
    assert "ITERATIONS = 3" in benchmark
    assert "DATA_SIZES = [64, 256, 1024, 4096]" in micro
    assert 'PERSISTENCE_MODES = ["none", "aof", "rdb"]' in micro
    assert 'readonly REDIS_SERVICE_PORT="16379"' in entrypoint
    for variable in (
        "ITERATIONS",
        "BENCH_COMMANDS",
        "CONCURRENCY_LEVELS",
        "NUM_REQUESTS",
        "DATA_SIZES",
        "CLIENT_COUNTS",
        "PERSISTENCE_MODES",
    ):
        assert f'os.environ.get("{variable}"' not in benchmark
        assert f'os.environ.get("{variable}"' not in micro


def test_redis_does_not_duplicate_framework_logs_or_reports() -> None:
    entrypoint = (ROOT / "software" / "Database" / "redis" / "redis_test.sh").read_text(
        encoding="utf-8"
    )
    assert "results.log" not in entrypoint
    assert "results.txt" not in entrypoint
    assert not (
        ROOT / "software" / "Database" / "redis" / "scripts" / "generate_summary.py"
    ).exists()
    assert "PERF_ACTUAL_VERSION_FILE" in entrypoint
    assert not (
        ROOT / "software" / "Database" / "redis" / "scripts" / "write_version_info.py"
    ).exists()


def test_redis_aggregate_uses_framework_version_context(tmp_path) -> None:
    (tmp_path / "benchmark_redis.json").write_text(
        json.dumps({
            "results_summary": {
                "SET": {
                    "concurrency_50": {
                        "qps": 100,
                        "avg_latency_ms": 1,
                        "p99_latency_ms": 2,
                    }
                },
                "GET": {
                    "concurrency_50": {
                        "qps": 120,
                        "avg_latency_ms": 0.8,
                        "p99_latency_ms": 1.5,
                    }
                },
            }
        }),
        encoding="utf-8",
    )
    (tmp_path / "micro_benchmark.json").write_text(
        json.dumps({
            "runtime_context": {"max_clients": 4},
            "results": {
                "client_scaling": {
                    "clients_1": {"qps": 10},
                    "clients_4": {"qps": 20},
                }
            },
        }),
        encoding="utf-8",
    )
    output = tmp_path / "results.json"
    environment = dict(os.environ)
    environment["SOFTWARE_VERSION"] = "8.0.6"
    completed = subprocess.run(
        [
            "python3",
            str(
                ROOT
                / "software"
                / "Database"
                / "redis"
                / "scripts"
                / "aggregate_results.py"
            ),
            str(tmp_path),
            str(output),
        ],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    assert completed.returncode == 0, completed.stderr
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["version"] == "8.0.6"
    assert "environment" not in payload
    assert not (tmp_path / "version_info.json").exists()


def test_lz4_script_exposes_source_safe_four_stage_contract(tmp_path) -> None:
    script = ROOT / "software" / "HPC" / "lz4" / "lz4_test.sh"
    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    environment = dict(os.environ)
    environment.update({
        "PERF_WORK_DIR": str(work_dir),
        "RESULTS_DIR": str(results_dir),
        "TMPDIR": str(work_dir / "tmp"),
    })
    completed = subprocess.run(
        [
            "bash",
            "--noprofile",
            "--norc",
            "-c",
            (
                'source "$1"; declare -F build_lz4 start_lz4_runtime '
                'run_lz4_benchmarks stop_lz4_runtime >/dev/null'
            ),
            "source-contract",
            str(script),
        ],
        check=False,
        env=environment,
    )
    assert completed.returncode == 0
    assert not work_dir.exists()
    assert not results_dir.exists()


def test_lz4_uses_the_approved_official_fullbench_contract() -> None:
    entrypoint = (ROOT / "software" / "HPC" / "lz4" / "lz4_test.sh").read_text(
        encoding="utf-8"
    )
    runner = (
        ROOT / "software" / "HPC" / "lz4" / "scripts" / "run_fullbench.py"
    ).read_text(encoding="utf-8")
    assert (
        'readonly SILESIA_REPOSITORY_URL="https://github.com/'
        'MiloszKrajewski/SilesiaCorpus.git"' in entrypoint
    )
    assert (
        'readonly SILESIA_REPOSITORY_COMMIT="'
        '3f3fa2cdbbb3795c903b74e774acb309e1360337"' in entrypoint
    )
    assert 'fetch --quiet --depth 1 --no-tags' in entrypoint
    assert 'scripts/prepare_silesia.py' in entrypoint
    assert "/opt/perf-datasets" not in entrypoint
    assert 'make -C tests fullbench' in entrypoint
    assert 'FULLBENCH_BIN="${SOURCE_DIR}/tests/fullbench"' in entrypoint
    assert "PERF_ACTUAL_VERSION_FILE" in entrypoint
    assert 'if [[ "${BASH_SOURCE[0]}" == "$0" ]]' in entrypoint
    assert 'scripts/standalone_runtime.py' in entrypoint
    assert not (
        ROOT / "software" / "HPC" / "lz4" / "scripts" / "write_version_info.py"
    ).exists()
    assert "ITERATION_LOOPS = 3" in runner
    assert '"block_option": "B4"' in runner
    assert '"block_option": "B7"' in runner
    assert '"operation_option": "c1"' in runner
    assert '"operation_option": "d4"' in runner
    assert '"function": "LZ4_compress_default"' in runner
    assert '"function": "LZ4_decompress_safe"' in runner
    for duplicate_or_unsafe_behavior in (
        "results.txt",
        "shunit2",
        "sudo apt-get",
        "sudo dnf",
        "/usr/local/lib",
        "cmake",
        "lz4_benchmark.cc",
    ):
        assert duplicate_or_unsafe_behavior not in entrypoint

    runtime_path = (
        ROOT / "software" / "HPC" / "lz4" / "scripts" / "standalone_runtime.py"
    )
    spec = importlib.util.spec_from_file_location("lz4_standalone_runtime", runtime_path)
    assert spec is not None and spec.loader is not None
    runtime = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runtime)
    case = yaml.safe_load(
        (ROOT / "software" / "HPC" / "lz4" / "case.yaml").read_text(
            encoding="utf-8"
        )
    )
    definitions = case["metrics"]["definitions"]
    assert list(runtime.METRICS) == list(definitions)
    for metric_name, (result_name, unit, direction) in runtime.METRICS.items():
        assert definitions[metric_name] == {
            "path": f"results.{result_name}.speed_mbs",
            "unit": unit,
            "direction": direction,
        }


def test_lz4_directory_is_a_self_contained_standalone_test_unit(tmp_path) -> None:
    source = ROOT / "software" / "HPC" / "lz4"
    portable = tmp_path / "lz4"
    shutil.copytree(source, portable)
    benchmark_fixture = tmp_path / "benchmark.json"
    benchmark_fixture.write_text(
        json.dumps({
            "benchmark": "lz4_fullbench",
            "software": "lz4",
            "version": "1.10.0",
            "architecture": "x86_64",
            "parameters": {"iteration_loops": 3, "corpus": "Silesia Corpus"},
            "results": {
                "block_64k_compression": {"speed_mbs": 700.5},
                "block_64k_decompression": {"speed_mbs": 4100.5},
                "block_4m_compression": {"speed_mbs": 750.5},
                "block_4m_decompression": {"speed_mbs": 4300.5},
            },
        }),
        encoding="utf-8",
    )
    results_dir = tmp_path / "results"
    run_id = f"portable-{os.getpid()}-{tmp_path.parent.name}-{tmp_path.name}"
    expected_work_dir = Path(f"/tmp/lz4-perf/local-{run_id}")
    assert not expected_work_dir.exists()
    environment = dict(os.environ)
    for name in (
        "RESULTS_DIR",
        "PERF_WORK_DIR",
        "PERF_ACTUAL_VERSION_FILE",
        "TMPDIR",
    ):
        environment.pop(name, None)
    environment.update({
        "EXPECTED_ARCH": platform.machine(),
        "PERF_RUN_ID": run_id,
    })
    completed = subprocess.run(
        [
            "bash",
            "--noprofile",
            "--norc",
            "-c",
            r'''
source "$1"
BENCHMARK_FIXTURE="$2"
build_lz4() {
    initialize_runtime
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
}
start_lz4_runtime() { initialize_runtime; }
run_lz4_benchmarks() {
    initialize_runtime
    cp "${BENCHMARK_FIXTURE}" "${RESULTS_DIR}/benchmark_fullbench.json"
}
stop_lz4_runtime() { log "fake LZ4 runtime stopped"; }
main --version 1.10.0 --results-dir "$3"
''',
            "portable-lz4",
            str(portable / "lz4_test.sh"),
            str(benchmark_fixture),
            str(results_dir),
        ],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert not expected_work_dir.exists()
    expected_files = {
        "actual-version.txt",
        "benchmark_fullbench.json",
        "build_info.json",
        "report.md",
        "results.json",
        "results.log",
        "runtime_after.json",
        "runtime_before.json",
        "status.json",
        "system_info.json",
    }
    assert {path.name for path in results_dir.iterdir()} == expected_files
    result = json.loads((results_dir / "results.json").read_text(encoding="utf-8"))
    assert result["status"] == "passed"
    assert result["cleanup_status"] == "passed"
    assert result["metrics"] == {
        "compress_speed_64k": {
            "value": 700.5,
            "unit": "MB/s",
            "direction": "higher_is_better",
        },
        "decompress_speed_64k": {
            "value": 4100.5,
            "unit": "MB/s",
            "direction": "higher_is_better",
        },
        "compress_speed_4m": {
            "value": 750.5,
            "unit": "MB/s",
            "direction": "higher_is_better",
        },
        "decompress_speed_4m": {
            "value": 4300.5,
            "unit": "MB/s",
            "direction": "higher_is_better",
        },
    }
    assert "独立性能测试报告" in (results_dir / "report.md").read_text(
        encoding="utf-8"
    )


def test_lz4_standalone_failure_still_reports_and_cleans(tmp_path) -> None:
    script = ROOT / "software" / "HPC" / "lz4" / "lz4_test.sh"
    results_dir = tmp_path / "results"
    run_id = f"failure-{os.getpid()}-{tmp_path.parent.name}-{tmp_path.name}"
    expected_work_dir = Path(f"/tmp/lz4-perf/local-{run_id}")
    assert not expected_work_dir.exists()
    environment = dict(os.environ)
    for name in (
        "RESULTS_DIR",
        "PERF_WORK_DIR",
        "PERF_ACTUAL_VERSION_FILE",
        "TMPDIR",
    ):
        environment.pop(name, None)
    environment.update({
        "EXPECTED_ARCH": platform.machine(),
        "PERF_RUN_ID": run_id,
    })
    completed = subprocess.run(
        [
            "bash",
            "--noprofile",
            "--norc",
            "-c",
            r'''
source "$1"
build_lz4() { initialize_runtime; return 33; }
stop_lz4_runtime() { log "fake failed runtime stopped"; }
main --results-dir "$2"
''',
            "failed-portable-lz4",
            str(script),
            str(results_dir),
        ],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    assert completed.returncode == 33, completed.stdout + completed.stderr
    assert not expected_work_dir.exists()
    status = json.loads((results_dir / "status.json").read_text(encoding="utf-8"))
    assert status["status"] == "failed"
    assert status["failed_stage"] == "build"
    assert status["cleanup_status"] == "passed"
    assert (results_dir / "runtime_before.json").is_file()
    assert (results_dir / "runtime_after.json").is_file()
    assert (results_dir / "report.md").is_file()


def test_lz4_silesia_packaging_is_reproducible(tmp_path) -> None:
    script = ROOT / "software" / "HPC" / "lz4" / "scripts" / "prepare_silesia.py"
    spec = importlib.util.spec_from_file_location("prepare_silesia", script)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    source_dir = tmp_path / "source"
    source_dir.mkdir()
    members = []
    for name, content in (("first", b"alpha"), ("second", b"beta")):
        with zipfile.ZipFile(source_dir / f"{name}.zip", "w") as archive:
            archive.writestr(name, content)
        members.append(
            module.CorpusMember(name, len(content), hashlib.md5(content).hexdigest())
        )

    first_tar = tmp_path / "first.tar"
    second_tar = tmp_path / "second.tar"
    first_digest = module.build_corpus(source_dir, first_tar, members)
    second_digest = module.build_corpus(source_dir, second_tar, members)

    assert first_digest == second_digest
    assert first_tar.read_bytes() == second_tar.read_bytes()
    with tarfile.open(first_tar) as corpus:
        assert corpus.getnames() == ["first", "second"]
        assert [entry.mtime for entry in corpus.getmembers()] == [0, 0]


def test_lz4_fullbench_runner_executes_and_parses_all_four_cases(tmp_path) -> None:
    fullbench = tmp_path / "fullbench"
    fullbench.write_text(
        """#!/usr/bin/env bash
set -euo pipefail
case "$*" in
  *"-B4 -c1"*) printf ' 1-LZ4_compress_default : 211938580 -> 100000000 (47.18%%), 700.5 MB/s\n' >&2 ;;
  *"-B4 -d4"*) printf ' 4-LZ4_decompress_safe : 211938580 -> 4100.5 MB/s\n' >&2 ;;
  *"-B7 -c1"*) printf ' 1-LZ4_compress_default : 211938580 -> 100000000 (47.18%%), 750.5 MB/s\n' >&2 ;;
  *"-B7 -d4"*) printf ' 4-LZ4_decompress_safe : 211938580 -> 4300.5 MB/s\n' >&2 ;;
  *) exit 2 ;;
esac
""",
        encoding="utf-8",
    )
    fullbench.chmod(0o755)
    corpus = tmp_path / "silesia.tar"
    corpus.write_bytes(b"fixed-silesia-corpus")
    output = tmp_path / "benchmark_fullbench.json"
    environment = dict(os.environ)
    environment.update({
        "SOFTWARE_VERSION": "1.10.0",
        "EXPECTED_ARCH": "aarch64",
        "SILESIA_REPOSITORY_URL": (
            "https://github.com/MiloszKrajewski/SilesiaCorpus.git"
        ),
        "SILESIA_REPOSITORY_COMMIT": (
            "3f3fa2cdbbb3795c903b74e774acb309e1360337"
        ),
    })
    completed = subprocess.run(
        [
            "python3",
            str(ROOT / "software" / "HPC" / "lz4" / "scripts" / "run_fullbench.py"),
            str(fullbench),
            str(corpus),
            str(output),
        ],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    assert completed.returncode == 0, completed.stderr
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["parameters"]["iteration_loops"] == 3
    assert payload["parameters"]["corpus_repository"].startswith("https://github.com/")
    assert payload["parameters"]["corpus_commit"] == (
        "3f3fa2cdbbb3795c903b74e774acb309e1360337"
    )
    assert payload["parameters"]["corpus_size_bytes"] == len(b"fixed-silesia-corpus")
    assert len(payload["parameters"]["corpus_sha256"]) == 64
    assert {
        name: result["speed_mbs"] for name, result in payload["results"].items()
    } == {
        "block_64k_compression": 700.5,
        "block_64k_decompression": 4100.5,
        "block_4m_compression": 750.5,
        "block_4m_decompression": 4300.5,
    }
