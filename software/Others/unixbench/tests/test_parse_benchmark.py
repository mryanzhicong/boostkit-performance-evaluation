"""UnixBench parser regression tests, including cross-architecture copy identity."""

from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

import pytest


PARSER = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = spec_from_file_location("unixbench_parser", PARSER)
assert SPEC and SPEC.loader
MODULE = module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def report(cpus: int = 16, missing: str = "", partial: bool = False) -> str:
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
    assert parsed["runtime_context"]["copy_counts"] == [1, 16]
    assert "16 copies/System Benchmarks Index Score" in parsed["results"]


def test_real_upstream_row_layout() -> None:
    line = "Dhrystone 2 using register variables       51763945.4 lps   (10.0 s, 10 samples)"
    match = MODULE.RAW.match(line)
    assert match and match.group(1) == "Dhrystone 2 using register variables"
    assert match.group(2) == "51763945.4"


def test_different_cpu_counts_change_metric_identity_not_parameters() -> None:
    x86 = MODULE.parse_report(report(16), "6.0.1", "x86_64")
    arm = MODULE.parse_report(report(32), "6.0.1", "aarch64")
    assert x86["parameters"] == arm["parameters"]
    assert set(x86["results"]) & set(arm["results"]) == {
        name for name in x86["results"] if name.startswith("1 copy/")
    }


@pytest.mark.parametrize("content", [report(missing="Pipe Throughput"), report(partial=True)])
def test_incomplete_index_fails(content: str) -> None:
    with pytest.raises(ValueError):
        MODULE.parse_report(content, "6.0.1", "x86_64")


def test_build_and_test_use_private_container() -> None:
    case_dir = Path(__file__).resolve().parents[1]
    common = (case_dir / "scripts/common.sh").read_text(encoding="utf-8")
    build = (case_dir / "scripts/builders/base.sh").read_text(encoding="utf-8")
    test = (case_dir / "scripts/stages/test.sh").read_text(encoding="utf-8")
    stop = (case_dir / "scripts/stages/stop.sh").read_text(encoding="utf-8")
    assert "openEuler-24.03-LTS-SP4" in common
    assert "docker load" in common
    assert "--network=host" in common
    assert "--cpus=" not in common and "--memory=" not in common
    assert "--cpuset-cpus" not in common and "--cpuset-mems" not in common
    assert 'source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}' in common
    assert 'source=${RESULTS_DIR},target=${RESULTS_DIR}' in common
    assert 'boostkit.unixbench.run-id=${PERF_RUN_ID}' in common
    assert "require_unixbench_container" in build
    assert "container_exec_root dnf" in build
    assert "container_exec tar -xzf" in build
    assert "container_exec make -C" in build
    assert "container_exec sh -c" in test
    assert "remove_unixbench_container" in stop


def test_local_archive_uses_upstream_url_basename() -> None:
    case_dir = Path(__file__).resolve().parents[1]
    base = (case_dir / "scripts/builders/base.sh").read_text(encoding="utf-8")
    readme = (case_dir / "README.md").read_text(encoding="utf-8")
    assert '${UNIXBENCH_ARCHIVE_DIR}/v6.0.1.tar.gz' in base
    assert '/home/runner/software/unixbench/v6.0.1.tar.gz' in readme
