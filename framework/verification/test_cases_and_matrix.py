"""Validate the manually maintained case catalog and matrix defaults."""

from generate_matrix import build_matrix
from validate_case import ROOT, discover_cases, validate_case


def test_all_current_cases_are_valid() -> None:
    cases = discover_cases(ROOT)
    assert len(cases) == 7
    for path in cases:
        case, errors = validate_case(path, ROOT)
        assert case is not None
        assert errors == []


def test_default_matrix_runs_both_architectures_without_runner_labels() -> None:
    matrix = build_matrix("all", "all", "all", "smoke")["include"]
    assert len(matrix) == 28
    assert {item["arch"] for item in matrix} == {"x86_64", "aarch64"}
    assert all("runner" not in item and "runner_label" not in item for item in matrix)


def test_software_and_version_filters_limit_scope() -> None:
    matrix = build_matrix("faiss", "1.14.3", "x86_64", "full")["include"]
    assert matrix == [{
        "category": "AI",
        "software": "faiss",
        "version": "1.14.3",
        "arch": "x86_64",
        "test_mode": "full",
        "timeout_minutes": 180,
        "job_timeout_minutes": 210,
        "case_path": "software/AI/faiss/case.yaml",
    }]
