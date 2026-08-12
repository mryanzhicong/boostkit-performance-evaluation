"""Validate the manually maintained case catalog and matrix defaults."""

import os
import subprocess

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


def test_redis_is_the_only_valid_case() -> None:
    cases = discover_cases(ROOT)
    assert cases == [ROOT / "software" / "Database" / "redis" / "case.yaml"]
    case, errors = validate_case(cases[0], ROOT)
    assert errors == []
    assert case is not None
    assert case["versions"] == ["7.4.10", "8.0.0", "8.0.6"]
    assert case["execution"]["timeout_minutes"] == 180
    assert case["execution"]["type"] == "shell-functions"
    assert case["execution"]["stages"] == {
        stage: {"script": "redis_test.sh", "function": stage}
        for stage in ("build", "start", "test", "stop")
    }


def test_software_registry_normalizes_empty_categories() -> None:
    registry = configured_software(ROOT)
    assert registry["Database"] == ["redis"]
    assert all(
        software == []
        for category, software in registry.items()
        if category != "Database"
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
            "expected_outputs": ["results.json"],
        },
        "metrics": {
            "throughput": {
                "source": "results.json",
                "path": "summary.throughput",
                "unit": "ops/s",
                "direction": "higher_is_better",
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


def test_default_matrix_runs_every_redis_version_on_both_architectures() -> None:
    matrix = build_matrix("all", "all", "all")["include"]
    assert len(matrix) == 6
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert {item["version"] for item in matrix} == {"7.4.10", "8.0.0", "8.0.6"}
    assert [(item["version"], item["arch"]) for item in matrix] == [
        ("7.4.10", "x86_64"),
        ("7.4.10", "aarch64"),
        ("8.0.0", "x86_64"),
        ("8.0.0", "aarch64"),
        ("8.0.6", "x86_64"),
        ("8.0.6", "aarch64"),
    ]


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
    for function in ("build", "start", "test", "stop"):
        assert f"{function}()" in entrypoint
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
            'source "$1"; declare -F build start test stop >/dev/null',
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
