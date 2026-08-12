"""Validate the manually maintained case catalog and matrix defaults."""

import pytest
from generate_matrix import build_matrix, configured_runner_labels
from validate_case import ROOT, discover_cases, validate_case


def test_redis_is_the_only_valid_case() -> None:
    cases = discover_cases(ROOT)
    assert cases == [ROOT / "software" / "Database" / "redis" / "case.yaml"]
    case, errors = validate_case(cases[0], ROOT)
    assert errors == []
    assert case is not None
    assert case["versions"] == ["7.4.10", "8.0.0", "8.0.6"]
    assert case["execution"]["timeout_minutes"] == 180
    assert case["execution"]["interface"] == "four-stage"


def test_default_matrix_runs_every_redis_version_on_both_architectures() -> None:
    matrix = build_matrix("all", "all", "all")["include"]
    assert len(matrix) == 6
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert {item["version"] for item in matrix} == {"7.4.10", "8.0.0", "8.0.6"}


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


def test_redis_entrypoint_exposes_every_workflow_stage() -> None:
    entrypoint = (ROOT / "software" / "Database" / "redis" / "redis_test.sh").read_text(
        encoding="utf-8"
    )
    for function in (
        "phase_build",
        "phase_start",
        "phase_test",
        "phase_stop",
    ):
        assert f"{function}()" in entrypoint
    for removed_function in (
        "phase_validate",
        "phase_start_service",
        "phase_stop_service",
        "phase_collect_report",
    ):
        assert f"{removed_function}()" not in entrypoint


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
