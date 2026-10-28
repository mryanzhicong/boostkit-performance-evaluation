"""Offline checks for comparisons assembled from two independent runs."""

import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PREPARE = ROOT / ".github/scripts/prepare_existing_comparison.py"
GENERATE = ROOT / "framework/generate_comparison.py"
X86_RUN = "40628396799-1"
ARM_RUN = "40294324387-1"
X86_DIRECTORY = f"2026-10-28-11-44-34_{X86_RUN}"
ARM_DIRECTORY = f"2026-10-26-16-44-12_{ARM_RUN}"


def invoke(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(PREPARE), *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )


def options() -> list[str]:
    return [
        "--software", "x265", "--version", "4.2",
        "--x86-run-id", X86_RUN, "--arm-run-id", ARM_RUN,
    ]


def test_prepare_writes_one_matrix_per_architecture(tmp_path: Path) -> None:
    result = invoke(
        "prepare", *options(),
        "--x86-result-directory", X86_DIRECTORY,
        "--arm-result-directory", ARM_DIRECTORY,
        "--output-dir", str(tmp_path),
    )
    assert result.returncode == 0, result.stderr
    for arch in ("x86_64", "aarch64"):
        matrix = json.loads((tmp_path / f"{arch}-matrix.json").read_text())
        assert matrix == {"include": [{
            "category": "Media", "software": "x265", "version": "4.2", "arch": arch,
        }]}


def test_prepare_rejects_mismatched_directory(tmp_path: Path) -> None:
    result = invoke(
        "prepare", *options(),
        "--x86-result-directory", ARM_DIRECTORY,
        "--arm-result-directory", ARM_DIRECTORY,
        "--output-dir", str(tmp_path),
    )
    assert result.returncode != 0
    assert "result directory must end with" in result.stderr


def test_verify_and_generate_two_independent_runs(tmp_path: Path) -> None:
    input_root = tmp_path / "input"
    for arch, run_id, value in (("x86_64", X86_RUN, 10), ("aarch64", ARM_RUN, 12)):
        directory = input_root / "Media" / "x265" / "4.2" / arch
        directory.mkdir(parents=True)
        result = {
            "category": "Media", "software": "x265", "version": "4.2",
            "architecture": arch, "run_id": run_id,
            "status": "passed", "cleanup_status": "passed",
            "parameters": {"input": "same-video"}, "parameter_signature": "same-signature",
            "test_tools": {"x265": {"version": "4.2"}},
            "metrics": {"total_fps": {"value": value, "unit": "fps", "direction": "higher_is_better"}},
        }
        (directory / "normalized_result.json").write_text(json.dumps(result))
    verify = invoke("verify", *options(), "--input-root", str(input_root))
    assert verify.returncode == 0, verify.stderr
    report_dir = tmp_path / "report"
    generate = subprocess.run(
        [sys.executable, str(GENERATE), "--input-root", str(input_root), "--output-dir", str(report_dir)],
        cwd=ROOT, capture_output=True, text=True, check=False,
    )
    assert generate.returncode == 0, generate.stderr
    verify_report = invoke(
        "verify", *options(), "--input-root", str(input_root), "--report-dir", str(report_dir)
    )
    assert verify_report.returncode == 0, verify_report.stderr
    report = json.loads((report_dir / "combined-report.json").read_text())
    assert report["summary"]["comparisons"] == 1


def test_verify_rejects_wrong_run_identity(tmp_path: Path) -> None:
    directory = tmp_path / "Media" / "x265" / "4.2" / "x86_64"
    directory.mkdir(parents=True)
    (directory / "normalized_result.json").write_text(json.dumps({
        "category": "Media", "software": "x265", "version": "4.2",
        "architecture": "x86_64", "run_id": ARM_RUN,
    }))
    result = invoke("verify", *options(), "--input-root", str(tmp_path))
    assert result.returncode != 0
    assert "result identity mismatch" in result.stderr
