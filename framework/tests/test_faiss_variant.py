"""Faiss build variants keep the existing base workload intact."""

import os
import subprocess

import pytest

from catalog import ROOT, validate_case


CASE_DIR = ROOT / "software" / "AI" / "faiss"


def test_faiss_case_uses_split_stages():
    case, errors = validate_case(CASE_DIR / "case.yaml", ROOT)
    assert errors == []
    assert case is not None
    assert case["execution"]["stages"]["build"]["script"] == "scripts/builders/dispatch.sh"
    assert case["outputs"]["build_variant"]["required"] is True


def test_optimized_build_never_falls_back(tmp_path):
    work_dir = tmp_path / "work"
    result_dir = tmp_path / "results"
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; build_faiss', "bash",
         str(CASE_DIR / "scripts" / "builders" / "dispatch.sh")],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(result_dir),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "optimized faiss build is not implemented" in completed.stdout
    assert not work_dir.exists()
    assert not (result_dir / "build_variant.json").exists()


def test_standalone_rejects_unknown_variant():
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "faiss_test.sh"), "--variant", "unknown"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


@pytest.mark.parametrize("variant", ["base", "optimized"])
def test_default_results_are_separate(variant, tmp_path):
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; configure_runtime_paths; printf "%s\\n" "$RESULTS_DIR"',
         "bash", str(CASE_DIR / "scripts" / "common.sh")],
        env={
            **os.environ,
            "PERF_VARIANT": variant,
            "PERF_RUN_ID": "unit-test",
            "PERF_WORK_DIR": str(tmp_path),
            "RESULTS_DIR": "",
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    suffix = "/1.14.3/optimized/unit-test" if variant == "optimized" else "/1.14.3/unit-test"
    assert completed.stdout.strip().endswith(suffix)
