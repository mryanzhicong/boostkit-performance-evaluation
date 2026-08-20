"""Validate the generic case catalog contract and matrix behavior."""

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
    registry = configured_software(ROOT)
    expected_paths = sorted(
        ROOT / "software" / category / software / "case.yaml"
        for category, software_names in registry.items()
        for software in software_names
    )
    entries, errors = validate_catalog(ROOT)
    assert errors == []
    assert discover_cases(ROOT) == expected_paths
    assert sorted(path for path, _case in entries) == expected_paths
    for path, case in entries:
        relative = path.relative_to(ROOT / "software")
        assert case["category"] == relative.parts[0]
        assert case["name"] == relative.parts[1]


def test_software_registry_normalizes_empty_categories() -> None:
    raw_categories = yaml.safe_load(
        (ROOT / "config" / "categories.yaml").read_text(encoding="utf-8")
    )["categories"]
    registry = configured_software(ROOT)
    assert list(registry) == list(raw_categories)
    assert all(isinstance(software_names, list) for software_names in registry.values())
    for category, configured_names in raw_categories.items():
        assert registry[category] == (configured_names or [])


def test_catalog_rejects_unregistered_and_missing_cases(tmp_path) -> None:
    config = tmp_path / "config"
    config.mkdir()
    (config / "categories.yaml").write_text(
        "categories:\n  Database:\n", encoding="utf-8"
    )
    unregistered = tmp_path / "software" / "Database" / "sample" / "case.yaml"
    unregistered.parent.mkdir(parents=True)
    unregistered.write_text("{}\n", encoding="utf-8")
    _entries, errors = validate_catalog(tmp_path)
    assert any("case is not registered" in error for error in errors)

    (config / "categories.yaml").write_text(
        "categories:\n  Database:\n    - sample\n    - missing\n",
        encoding="utf-8",
    )
    _entries, errors = validate_catalog(tmp_path)
    assert any("registered case is missing" in error and "missing" in error for error in errors)


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

    payload["metrics"] = {
        "source": "result",
        "collection": {
            "path": "results",
            "name_path": "name",
            "value_path": "speed",
            "unit": "MB/s",
            "direction": "higher_is_better",
        },
    }
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert errors == []

    payload["metrics"]["definitions"] = {
        "throughput": {
            "path": "summary.throughput",
            "unit": "ops/s",
            "direction": "higher_is_better",
        }
    }
    case_path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    _case, errors = validate_case(case_path, tmp_path)
    assert any("exactly one of definitions or collection" in error for error in errors)


def test_default_matrix_runs_every_version_on_both_architectures() -> None:
    matrix = build_matrix("all", "all", "all")["include"]
    entries, errors = validate_catalog(ROOT)
    assert errors == []
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert {
        (item["software"], item["version"], item["arch"])
        for item in matrix
    } == {
        (case["name"], version, architecture)
        for _path, case in entries
        if case["enabled"]
        for version in case["versions"]
        for architecture in ("x86_64", "aarch64")
    }


def test_manual_filters_limit_any_case_to_one_architecture_and_version() -> None:
    entries, errors = validate_catalog(ROOT)
    assert errors == []
    path, case = next((path, case) for path, case in entries if case["enabled"])
    version = case["versions"][0]
    matrix = build_matrix(case["name"], version, "aarch64")["include"]
    assert len(matrix) == 1
    assert matrix[0]["case_path"] == str(path.relative_to(ROOT))
    assert matrix[0]["software"] == case["name"]
    assert matrix[0]["version"] == version
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


def test_workflow_uses_default_pypi_on_ubuntu_and_huawei_on_runners() -> None:
    workflow = (ROOT / ".github" / "workflows" / "performance-test.yml").read_text(
        encoding="utf-8"
    )
    prepare_job, performance_and_report = workflow.split("  performance:", 1)
    assert "--index-url" not in prepare_job
    assert workflow.count("https://mirrors.huaweicloud.com/repository/pypi/simple") == 1
    assert "https://mirrors.huaweicloud.com/repository/pypi/simple" in performance_and_report
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
