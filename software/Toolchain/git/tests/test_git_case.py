"""Keep the git t/perf metric contract, wiring and cross-architecture pairing stable."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
FRAMEWORK_DIR = CASE_DIR.parents[2] / "framework"
sys.path.insert(0, str(FRAMEWORK_DIR))

from generate_comparison import compare_pair  # noqa: E402
from reporting import render_comparison  # noqa: E402

COLLECT_SPEC = importlib.util.spec_from_file_location(
    "git_collect_benchmark", SCRIPT_DIR / "results" / "collect_git_benchmark.py"
)
assert COLLECT_SPEC is not None and COLLECT_SPEC.loader is not None
collector = importlib.util.module_from_spec(COLLECT_SPEC)
COLLECT_SPEC.loader.exec_module(collector)

STANDALONE_SPEC = importlib.util.spec_from_file_location(
    "git_standalone_runtime", SCRIPT_DIR / "results" / "standalone_runtime.py"
)
assert STANDALONE_SPEC is not None and STANDALONE_SPEC.loader is not None
standalone = importlib.util.module_from_spec(STANDALONE_SPEC)
STANDALONE_SPEC.loader.exec_module(standalone)


def build_results_dir(root: Path) -> Path:
    results = root / "git_perf_results"
    results.mkdir()
    for script, count in collector.EXPECTED_SCRIPTS:
        base = script[:-3]
        (results / f"{base}.subtests").write_text(
            "".join(f"{index}\n" for index in range(1, count + 1)), encoding="utf-8"
        )
        for index in range(1, count + 1):
            (results / f"{base}.{index}.descr").write_text(
                f"{base} subtest {index}\n", encoding="utf-8"
            )
            (results / f"{base}.{index}.result").write_text(
                f"0:00.{index:02d} 0.00 0.01\n", encoding="utf-8"
            )
    return results


def test_collector_extracts_all_metrics(tmp_path: Path) -> None:
    results = build_results_dir(tmp_path)
    payload = collector.collect(results, "2.56.0", "x86_64", 5)
    assert len(payload["results"]) == 57
    metric = payload["results"]["p0002-read-cache.1: p0002-read-cache subtest 1"]
    assert metric["value"] == pytest.approx(0.01)
    assert metric["unit"] == "s"
    assert metric["direction"] == "lower_is_better"
    assert metric["group"] == "p0002-read-cache"
    assert payload["parameters"]["git_version"] == "2.56.0"
    assert payload["parameters"]["repeats"] == 5
    assert "architecture" not in payload["parameters"]
    assert len(payload["parameters"]["scripts"]) == 10


def test_collector_accepts_zero_elapsed(tmp_path: Path) -> None:
    results = build_results_dir(tmp_path)
    (results / "p0002-read-cache.1.result").write_text("0:00.00 0.00 0.00\n", encoding="utf-8")
    payload = collector.collect(results, "2.56.0", "x86_64", 5)
    assert payload["results"]["p0002-read-cache.1: p0002-read-cache subtest 1"]["value"] == 0.0


def test_collector_rejects_wrong_subtest_count(tmp_path: Path) -> None:
    results = build_results_dir(tmp_path)
    (results / "p0071-sort.subtests").write_text("1\n2\n", encoding="utf-8")
    with pytest.raises(ValueError, match="expected 9"):
        collector.collect(results, "2.56.0", "x86_64", 5)


def test_collector_rejects_missing_script(tmp_path: Path) -> None:
    results = build_results_dir(tmp_path)
    (results / "p0090-cache-tree.subtests").unlink()
    with pytest.raises(ValueError, match="missing subtest list"):
        collector.collect(results, "2.56.0", "x86_64", 5)


def test_collector_rejects_malformed_result(tmp_path: Path) -> None:
    results = build_results_dir(tmp_path)
    (results / "p0005-status.1.result").write_text("garbage\n", encoding="utf-8")
    with pytest.raises(ValueError, match="malformed perf result line"):
        collector.collect(results, "2.56.0", "x86_64", 5)


def test_standalone_validation_accepts_payload(tmp_path: Path) -> None:
    payload = collector.collect(build_results_dir(tmp_path), "2.56.0", "x86_64", 5)
    metrics = standalone.validate_metrics(payload)
    assert len(metrics) == 57


def test_standalone_validation_rejects_incomplete_payload(tmp_path: Path) -> None:
    payload = collector.collect(build_results_dir(tmp_path), "2.56.0", "x86_64", 5)
    del payload["results"]["p0100-globbing.12: p0100-globbing subtest 12"]
    with pytest.raises(RuntimeError, match="expected 57 git perf metrics"):
        standalone.validate_metrics(payload)


def normalized_git_result(architecture: str, factor: float, payload: dict) -> dict:
    metrics = {}
    for name, metric in payload["results"].items():
        metrics[name] = {
            "value": metric["value"] * factor,
            "unit": metric["unit"],
            "direction": metric["direction"],
            "group": metric["group"],
        }
    return {
        "category": "Toolchain",
        "software": "git",
        "version": "2.56.0",
        "architecture": architecture,
        "status": "passed",
        "cleanup_status": "passed",
        "build_info": {
            "requested_version": "2.56.0",
            "actual_version": "2.56.0",
            "recorded_at": "2026-10-31T00:00:00Z",
        },
        "parameters": {"benchmark_git.json": json.loads(json.dumps(payload["parameters"]))},
        "parameter_signature": "same-parameters",
        "test_tools": {
            "git_perf_suite": {
                "version": "与被测软件版本一致",
                "revision": "a018953688f1b10bddf91bff8747068f5f4746a4",
            },
            "gnu_time": {"version": "unknown"},
        },
        "system_info": {
            "architecture": architecture,
            "cpu_model": "Example CPU",
            "cpu_count": 64 if architecture == "x86_64" else 96,
        },
        "runtime_before": {"memory": "before"},
        "runtime_after": {"memory": "after"},
        "metrics": metrics,
    }


def test_cross_architecture_report_pairs_same_subtests(tmp_path: Path) -> None:
    payload = collector.collect(build_results_dir(tmp_path), "2.56.0", "x86_64", 5)
    x86 = normalized_git_result("x86_64", 1.0, payload)
    arm = normalized_git_result("aarch64", 1.5, payload)
    comparison = compare_pair(x86, arm)
    assert len(comparison["metrics"]) == 57
    sample = comparison["metrics"]["p0002-read-cache.1: p0002-read-cache subtest 1"]
    assert sample["raw_ratio"] == pytest.approx(1.5, abs=1e-3)
    assert sample["relative_performance"] == pytest.approx(2.0 / 3.0, abs=1e-3)
    markdown = render_comparison(comparison)
    assert "p0002-read-cache" in markdown
    assert "p0100-globbing" in markdown
    assert "越小越好" in markdown


def test_cross_architecture_report_rejects_parameter_drift(tmp_path: Path) -> None:
    payload = collector.collect(build_results_dir(tmp_path), "2.56.0", "x86_64", 5)
    x86 = normalized_git_result("x86_64", 1.0, payload)
    arm = normalized_git_result("aarch64", 1.5, payload)
    arm["parameters"]["benchmark_git.json"]["repeats"] = 3
    with pytest.raises(ValueError, match="parameters differ"):
        compare_pair(x86, arm)


def test_case_yaml_wiring_matches_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["name"] == "git"
    assert case["category"] == "Toolchain"
    assert case["versions"] == ["2.56.0"]
    assert case["test_tools"]["git_perf_suite"]["revision"] == \
        "a018953688f1b10bddf91bff8747068f5f4746a4"
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh", "function": "build_git",
    }
    assert stages["start"]["function"] == "start_git_runtime"
    assert stages["test"]["function"] == "run_git_benchmarks"
    assert stages["stop"]["function"] == "stop_git_runtime"
    for stage in ("start", "test", "stop"):
        assert (CASE_DIR / stages[stage]["script"]).is_file()
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_git.json"
    assert case["outputs"]["perf_raw_results"]["path"] == "git_perf_results"
    collection = case["metrics"]["collection"]
    assert collection["path"] == "results"
    assert collection["value_path"] == "value"
    assert collection["unit_path"] == "unit"
    assert collection["direction_path"] == "direction"
    assert collection["group_path"] == "group"


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPT_DIR / "builders" / "optimized.sh").read_text(encoding="utf-8")
    assert "not implemented" in content
    assert "return 30" in content
