"""Validate the manually maintained case catalog and matrix defaults."""

from generate_matrix import build_matrix, configured_runner_labels
from validate_case import ROOT, discover_cases, validate_case


def test_all_current_cases_are_valid() -> None:
    cases = discover_cases(ROOT)
    assert len(cases) == 7
    for path in cases:
        case, errors = validate_case(path, ROOT)
        assert case is not None
        assert errors == []


def test_default_matrix_runs_both_architectures_with_global_runner_mapping() -> None:
    matrix = build_matrix("all", "all", "all", "smoke")["include"]
    labels = configured_runner_labels()
    assert len(matrix) == 28
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert all(item["runner_label"] == labels[item["arch"]] for item in matrix)


def test_software_and_version_filters_limit_scope() -> None:
    labels = configured_runner_labels()
    matrix = build_matrix("faiss", "1.14.3", "x86_64", "full")["include"]
    assert matrix == [{
        "category": "AI",
        "software": "faiss",
        "version": "1.14.3",
        "arch": "x86_64",
        "runner_label": labels["x86_64"],
        "test_mode": "full",
        "timeout_minutes": 180,
        "job_timeout_minutes": 210,
        "case_path": "software/AI/faiss/case.yaml",
    }]


def test_workflow_consumes_matrix_runner_label_without_duplicates() -> None:
    workflow = (ROOT / ".github" / "workflows" / "performance-test.yml").read_text(encoding="utf-8")
    assert "matrix.runner_label" in workflow
    assert all(label not in workflow for label in configured_runner_labels().values())
    assert "vars.PERF_RUNNER" not in workflow
