#!/usr/bin/env python3
"""Unit tests for the libvirt unixbench parser; the fixtures are real report crops."""

from __future__ import annotations

import importlib.util
import json
import os
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER_PATH = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"

TESTS = (
    ("Dhrystone 2 using register variables", "dhrystone2"),
    ("Double-Precision Whetstone", "whetstone_double"),
    ("Execl Throughput", "execl"),
    ("File Copy 1024 bufsize 2000 maxblocks", "file_copy_1024"),
    ("File Copy 256 bufsize 500 maxblocks", "file_copy_256"),
    ("File Copy 4096 bufsize 8000 maxblocks", "file_copy_4096"),
    ("Pipe Throughput", "pipe_throughput"),
    ("Pipe-based Context Switching", "pipe_context_switch"),
    ("Process Creation", "process_creation"),
    ("System Call Overhead", "syscall_overhead"),
    ("Shell Scripts (1 concurrent)", "shell_scripts_1"),
    ("Shell Scripts (8 concurrent)", "shell_scripts_8"),
)


def load_parser():
    spec = importlib.util.spec_from_file_location("libvirt_unixbench_parser", PARSER_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def report(copies: int = 4, score: str = "1234.5") -> str:
    lines = [
        "================================================================================",
        "   BYTE UNIX Benchmarks (Version 6.0.1)",
        "",
        "   System: vmm: Linux",
        "   OS: Linux -- 5.10.0-182.0.0.95.oe2203 -- aarch64",
        "   Machine: aarch64",
        '   Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")',
        f"   {copies} CPUs in system; running {copies} parallel copies of tests",
        "",
    ]
    index_lines = [
        "System Benchmarks Index Values               BASELINE       RESULT    INDEX",
    ]
    for number, (label, _slug) in enumerate(TESTS, start=1):
        raw = 1000.0 * number
        baseline = 10.0 * number
        index = raw / baseline
        lines.append(f"{label}  {raw:.1f} lps   (10.0 s, 7 samples)")
        index_lines.append(f"{label}  {baseline:.1f} {raw:.1f} {index:.1f}")
    index_lines.append("")
    index_lines.append(f"System Benchmarks Index Score                                        {score}")
    return "\n".join(
        [
            "Benchmark Run: Sat Nov 28 2026 08:00:00 UTC",
            *lines,
            "",
            *index_lines,
            "",
        ]
    )


def test_parses_a_complete_single_pass_report() -> None:
    parser = load_parser()
    parsed = parser.parse_report(report(), 4, 0, 1)
    assert parsed["index_score"] == pytest.approx(1234.5)
    assert parsed["dhrystone2"] == pytest.approx(100.0)
    assert parsed["shell_scripts_8"] == pytest.approx(12000.0 / 120.0)


def test_rejects_a_report_without_the_version_banner() -> None:
    parser = load_parser()
    with pytest.raises(ValueError, match="not an official UnixBench 6.0.1 report"):
        parser.parse_report(report().replace("6.0.1", "5.1.3"), 4, 0, 1)


def test_rejects_the_wrong_copy_count() -> None:
    parser = load_parser()
    with pytest.raises(ValueError, match="expected 4 parallel copies"):
        parser.parse_report(report(copies=8), 4, 0, 1)


def test_rejects_two_passes() -> None:
    parser = load_parser()
    doubled = "\n".join(
        [
            "Benchmark Run: Sat Nov 28 2026 08:00:00 UTC",
            report(),
            "Benchmark Run: Sat Nov 28 2026 08:20:00 UTC",
            report(),
        ]
    )
    with pytest.raises(ValueError, match="exactly one pass"):
        parser.parse_report(doubled, 4, 0, 1)


def test_rejects_a_missing_test_line() -> None:
    parser = load_parser()
    broken = report().replace(
        "Shell Scripts (8 concurrent)  12000.0 lps   (10.0 s, 7 samples)\n", ""
    )
    with pytest.raises(ValueError, match="raw results incomplete"):
        parser.parse_report(broken, 4, 0, 1)


def test_rejects_a_partial_index() -> None:
    parser = load_parser()
    broken = report().replace("System Benchmarks Index Values", "System Benchmarks Partial Index")
    with pytest.raises(ValueError, match="partial index|complete system-index table"):
        parser.parse_report(broken, 4, 0, 1)


def test_rejects_a_missing_score() -> None:
    parser = load_parser()
    broken = report().replace("System Benchmarks Index Score                                        1234.5", "")
    with pytest.raises(ValueError, match="index score is missing"):
        parser.parse_report(broken, 4, 0, 1)


def test_rejects_non_positive_measurements() -> None:
    parser = load_parser()
    broken = report().replace(
        "Dhrystone 2 using register variables  1000.0 lps   (10.0 s, 7 samples)",
        "Dhrystone 2 using register variables  0 lps   (10.0 s, 7 samples)",
    )
    with pytest.raises(ValueError):
        parser.parse_report(broken, 4, 0, 1)


def write_runs(root: Path, reps: int, warmup: int, vms: int, copies: int, scale: float = 1.0) -> None:
    for rep in range(1, reps + 1):
        directory = root / f"rep{rep}"
        directory.mkdir(parents=True, exist_ok=True)
        for vm in range(vms):
            score = (1000.0 + 10.0 * vm + rep) * scale
            (directory / f"vm{vm}.log").write_text(report(copies, f"{score:.1f}"), encoding="utf-8")


def test_aggregates_medians_over_repetitions_and_vms(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    runs = tmp_path / "runs"
    write_runs(runs, reps=6, warmup=1, vms=3, copies=4)
    output = tmp_path / "benchmark_unixbench.json"
    per_vm = tmp_path / "per-vm-scores.json"
    monkeypatch.setenv("LIBVIRT_REPS", "6")
    monkeypatch.setenv("LIBVIRT_WARMUP_REPS", "1")
    monkeypatch.setenv("LIBVIRT_VM_COUNT", "3")
    monkeypatch.setenv("LIBVIRT_COPIES", "4")
    monkeypatch.setenv("SOFTWARE_VERSION", "6.0.1")
    monkeypatch.setenv("EXPECTED_ARCH", "aarch64")
    monkeypatch.setattr(
        "sys.argv",
        ["parse_benchmark.py", str(runs), str(output), str(per_vm)],
    )
    assert parser.main() == 0
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert len(payload["results"]) == 19
    # the per-VM medians of the measured repetitions 2..6 are 1012..1016, so the median is 1014
    assert payload["results"]["unixbench.index_score"]["value"] == pytest.approx(1014.0)
    # the lowest measured sample is repetition 2 on VM 0: 1000 + 0 + 2
    assert payload["results"]["unixbench.index_score_min"]["value"] == pytest.approx(1002.0)
    assert payload["results"]["libvirt.vm_count"]["value"] == 3
    assert payload["results"]["libvirt.total_benchmark_runs"]["value"] == 15
    assert payload["parameters"]["measured_repetitions"] == 5
    stored = json.loads(per_vm.read_text(encoding="utf-8"))
    assert set(stored["per_vm"]) == {"1", "2", "3", "4", "5", "6"}


def test_fails_when_a_report_is_missing(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    runs = tmp_path / "runs"
    write_runs(runs, reps=6, warmup=1, vms=2, copies=4)
    (runs / "rep4" / "vm1.log").unlink()
    monkeypatch.setenv("LIBVIRT_REPS", "6")
    monkeypatch.setenv("LIBVIRT_WARMUP_REPS", "1")
    monkeypatch.setenv("LIBVIRT_VM_COUNT", "2")
    monkeypatch.setenv("LIBVIRT_COPIES", "4")
    monkeypatch.setenv("SOFTWARE_VERSION", "6.0.1")
    monkeypatch.setenv("EXPECTED_ARCH", "x86_64")
    monkeypatch.setattr(
        "sys.argv",
        ["parse_benchmark.py", str(runs), str(tmp_path / "out.json"), str(tmp_path / "per.json")],
    )
    with pytest.raises(SystemExit, match="missing benchmark report"):
        parser.main()


def test_rejects_a_reduced_sampling_contract(monkeypatch) -> None:
    parser = load_parser()
    monkeypatch.setenv("LIBVIRT_REPS", "5")
    monkeypatch.setenv("LIBVIRT_WARMUP_REPS", "1")
    monkeypatch.setenv("LIBVIRT_VM_COUNT", "1")
    monkeypatch.setenv("LIBVIRT_COPIES", "4")
    monkeypatch.setattr(
        "sys.argv",
        ["parse_benchmark.py", "/nonexistent", "/nonexistent/out.json", "/nonexistent/per.json"],
    )
    with pytest.raises(SystemExit, match="at least five measured repetitions"):
        parser.main()


def test_workload_contract_defaults() -> None:
    common = (CASE_DIR / "scripts" / "common.sh").read_text(encoding="utf-8")
    assert 'LIBVIRT_VM_CORES="${LIBVIRT_VM_CORES:-4}"' in common
    assert 'LIBVIRT_VM_MEM_MIB="${LIBVIRT_VM_MEM_MIB:-8192}"' in common
    assert "nproc / 4" not in common
    assert "LIBVIRT_REPS - LIBVIRT_WARMUP_REPS >= 5" in common
    test_stage = (CASE_DIR / "scripts" / "stages" / "test.sh").read_text(encoding="utf-8")
    assert "./Run -c ${LIBVIRT_COPIES}" in test_stage
    build = (CASE_DIR / "scripts" / "builders" / "base.sh").read_text(encoding="utf-8")
    assert "make all" in (CASE_DIR / "scripts" / "common.sh").read_text(encoding="utf-8")
    assert (CASE_DIR / "case.yaml").is_file()
    del build


@pytest.mark.parametrize("copies", [1, 4, 8])
def test_copy_count_is_respected(copies: int) -> None:
    parser = load_parser()
    parsed = parser.parse_report(report(copies), copies, 0, 1)
    assert parsed["index_score"] > 0
