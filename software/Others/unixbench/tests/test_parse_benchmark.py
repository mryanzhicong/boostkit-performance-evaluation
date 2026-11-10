"""UnixBench parser regression tests, including reference VM copy identity."""

from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

import pytest


PARSER = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = spec_from_file_location("unixbench_parser", PARSER)
assert SPEC and SPEC.loader
MODULE = module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def report(cpus: int = 32, missing: str = "", partial: bool = False) -> str:
    parts = ["BYTE UNIX Benchmarks (Version 6.0.1)"]
    for copies in (1, cpus):
        parts.extend([
            f"Benchmark Run: Mon Nov 02 2026 10:00:00 - 12:00:00",
            f"{cpus} CPUs in system; running {copies} parallel "
            + ("copy" if copies == 1 else "copies") + " of tests",
        ])
        for label in MODULE.TESTS:
            if label != missing:
                samples = 7 if label in {
                    "Dhrystone 2 using register variables", "Double-Precision Whetstone",
                    "Pipe Throughput", "Pipe-based Context Switching", "System Call Overhead",
                } else 2
                parts.append(f"{label:<40} 1000.0 lps   (10.0 s, {samples} samples)")
        parts.append("System Benchmarks Partial Index" if partial else "System Benchmarks Index Values")
        for label in MODULE.TESTS:
            if label != missing:
                parts.append(f"{label:<40} 100.0 1000.0 10.0")
        parts.append("System Benchmarks Index Score                         10.0")
    return "\n".join(parts)


def test_complete_report_has_twenty_six_index_metrics() -> None:
    parsed = MODULE.parse_report(report(), "6.0.1", "x86_64")
    assert len(parsed["results"]) == 26
    assert not any(name.endswith("/result") for name in parsed["results"])
    assert len([name for name in parsed["results"] if name.startswith("1 copy/")]) == 13
    assert parsed["runtime_context"]["copy_counts"] == [1, 32]
    assert "32 copies/System Benchmarks Index Score" in parsed["results"]
    assert parsed["parameters"]["execution_environment"] == "kvm-vm"
    assert parsed["parameters"]["vm_vcpus"] == 32
    assert parsed["parameters"]["vm_memory_gib"] == 64


def test_real_upstream_row_layout() -> None:
    line = "Dhrystone 2 using register variables       51763945.4 lps   (10.0 s, 10 samples)"
    match = MODULE.RAW.match(line)
    assert match and match.group(1) == "Dhrystone 2 using register variables"
    assert match.group(2) == "51763945.4"


def test_different_cpu_counts_change_metric_identity_not_parameters() -> None:
    x86 = MODULE.parse_report(report(16), "6.0.1", "x86_64", expected_copies=16)
    arm = MODULE.parse_report(report(32), "6.0.1", "aarch64")
    assert x86["parameters"] == arm["parameters"]
    assert set(x86["results"]) & set(arm["results"]) == {
        name for name in x86["results"] if name.startswith("1 copy/")
    }


def test_reference_vm_copy_count_is_enforced() -> None:
    with pytest.raises(ValueError):
        MODULE.parse_report(report(16), "6.0.1", "x86_64")


@pytest.mark.parametrize("content", [report(missing="Pipe Throughput"), report(partial=True)])
def test_incomplete_index_fails(content: str) -> None:
    with pytest.raises(ValueError):
        MODULE.parse_report(content, "6.0.1", "x86_64")


def test_build_and_test_use_reference_vm() -> None:
    case_dir = Path(__file__).resolve().parents[1]
    common = (case_dir / "scripts/common.sh").read_text(encoding="utf-8")
    build = (case_dir / "scripts/builders/base.sh").read_text(encoding="utf-8")
    test = (case_dir / "scripts/stages/test.sh").read_text(encoding="utf-8")
    stop = (case_dir / "scripts/stages/stop.sh").read_text(encoding="utf-8")
    assert "openEuler-24.03-LTS-SP4" not in common or "cloud" in common
    assert "libvirt" in common or "virsh" in common
    assert "hugepages" in common
    assert "--cpus=" not in common and "--memory=" not in common
    assert "docker" not in common
    assert "require_unixbench_vm_host" in build
    assert "start_unixbench_vm" in build
    assert "verify_unixbench_guest_os" in build
    assert "install_unixbench_guest_packages" in build
    assert "vm_copy_in" in build
    assert "vm_exec make -C" in build
    assert "vm_exec_shell" in test and "./Run" in test
    assert "stop_unixbench_vm" in stop


def test_reference_vm_operating_system_is_verified() -> None:
    case_dir = Path(__file__).resolve().parents[1]
    common = (case_dir / "scripts/common.sh").read_text(encoding="utf-8")
    assert "verify_unixbench_guest_os()" in common
    assert "VERSION_ID" in common
    assert "guest os-release" in common


def test_local_archive_uses_upstream_url_basename() -> None:
    case_dir = Path(__file__).resolve().parents[1]
    base = (case_dir / "scripts/builders/base.sh").read_text(encoding="utf-8")
    readme = (case_dir / "README.md").read_text(encoding="utf-8")
    assert '${UNIXBENCH_ARCHIVE_DIR}/v6.0.1.tar.gz' in base
    assert '/home/runner/software/unixbench/v6.0.1.tar.gz' in readme
