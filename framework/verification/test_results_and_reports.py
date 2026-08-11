"""Verify normalization and cross-architecture direction semantics."""

import subprocess
import sys
from pathlib import Path

from aggregate_results import normalize
from context import RunContext
from generate_comparison import compare_pair, generate
from json_helper import atomic_write_json
from mark_cleanup import mark
from process_scanner import matching_processes, references_root
from reporting.comparison_report import render


def normalized_result(architecture: str, higher: float, lower: float) -> dict:
    return {
        "category": "AI",
        "software": "sample",
        "version": "1.0",
        "architecture": architecture,
        "test_mode": "smoke",
        "status": "passed",
        "parameter_signature": "same-parameters",
        "metrics": {
            "throughput": {"value": higher, "unit": "ops/s", "direction": "higher_is_better"},
            "latency": {"value": lower, "unit": "us", "direction": "lower_is_better"},
        },
    }


def test_normalizer_extracts_declared_legacy_metric(tmp_path: Path) -> None:
    output = tmp_path / "output"
    output.mkdir()
    atomic_write_json(output / "results.json", {"summary": {"qps": 42.5}})
    case = {
        "execution": {"expected_outputs": ["results.json"]},
        "modes": {"smoke": {"environment": {"ITERATIONS": 1}}},
        "metrics": {
            "qps": {
                "source": "results.json",
                "path": "summary.qps",
                "unit": "queries/s",
                "direction": "higher_is_better",
            }
        },
    }
    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case=case,
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        test_mode="smoke",
        run_id="unit-run",
        output_dir=output,
        work_dir=tmp_path / "work",
    )
    result = normalize(context, "passed")
    assert result["metrics"]["qps"]["value"] == 42.5
    assert result["metrics"]["qps"]["direction"] == "higher_is_better"


def test_comparison_inverts_lower_is_better_and_explains_direction() -> None:
    comparison = compare_pair(
        normalized_result("x86_64", higher=100, lower=20),
        normalized_result("aarch64", higher=120, lower=10),
    )
    assert comparison["metrics"]["throughput"]["relative_performance"] == 1.2
    assert comparison["metrics"]["latency"]["relative_performance"] == 2.0
    markdown = render(comparison)
    assert "越大越好" in markdown
    assert "越小越好" in markdown


def test_report_generator_pairs_architectures(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    atomic_write_json(input_root / "x86" / "normalized_result.json", normalized_result("x86_64", 100, 20))
    atomic_write_json(input_root / "arm" / "normalized_result.json", normalized_result("aarch64", 120, 10))
    summary = generate(input_root, tmp_path / "report")
    assert summary["total"] == 2
    assert summary["comparisons"] == 1
    assert (tmp_path / "report" / "combined-report.md").is_file()
    assert (tmp_path / "report" / "junit.xml").is_file()
    combined = (tmp_path / "report" / "combined-report.md").read_text(encoding="utf-8")
    assert "越大越好" in combined
    assert "越小越好" in combined


def test_cleanup_failure_is_persisted(tmp_path: Path) -> None:
    atomic_write_json(tmp_path / "status.json", {"status": "passed", "cleanup_status": "pending"})
    atomic_write_json(tmp_path / "normalized_result.json", {"status": "passed"})
    mark(tmp_path, "failure")
    import json

    status = json.loads((tmp_path / "status.json").read_text(encoding="utf-8"))
    normalized = json.loads((tmp_path / "normalized_result.json").read_text(encoding="utf-8"))
    assert status["exit_code"] == 80
    assert status["cleanup_status"] == "failed"
    assert normalized["failed_stage"] == "cleanup"


def test_report_includes_status_when_execution_has_no_normalized_result(tmp_path: Path) -> None:
    atomic_write_json(tmp_path / "artifacts" / "failed" / "status.json", {
        "category": "AI",
        "software": "sample",
        "version": "1.0",
        "architecture": "x86_64",
        "status": "failed",
        "failed_stage": "architecture_check",
    })
    summary = generate(tmp_path / "artifacts", tmp_path / "report")
    assert summary["total"] == 1
    assert summary["failed"] == 1


def test_process_scanner_does_not_match_its_own_root_argument(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    scanner = Path(__file__).resolve().parents[1] / "process_scanner.py"
    completed = subprocess.run(
        [sys.executable, str(scanner), "--root", str(work_root)],
        check=True,
        capture_output=True,
        text=True,
    )
    assert completed.stdout == ""
    assert references_root(
        b"python3\0worker.py\0/tmp/boostkit-perf/case-work\0",
        Path("/tmp/boostkit-perf"),
    )


def test_process_scanner_finds_real_work_root_process(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    process = subprocess.Popen([
        sys.executable,
        "-c",
        "import time; time.sleep(30)",
        str(work_root / "case-work"),
    ])
    try:
        assert process.pid in matching_processes(work_root)
    finally:
        process.terminate()
        process.wait(timeout=5)
