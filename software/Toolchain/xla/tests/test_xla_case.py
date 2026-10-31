"""Keep the XLA result contract, case wiring and cross-architecture pairing stable."""

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
    "xla_collect_benchmark", SCRIPT_DIR / "results" / "collect_xla_benchmark.py"
)
assert COLLECT_SPEC is not None and COLLECT_SPEC.loader is not None
collector = importlib.util.module_from_spec(COLLECT_SPEC)
COLLECT_SPEC.loader.exec_module(collector)

STANDALONE_SPEC = importlib.util.spec_from_file_location(
    "xla_standalone_runtime", SCRIPT_DIR / "results" / "standalone_runtime.py"
)
assert STANDALONE_SPEC is not None and STANDALONE_SPEC.loader is not None
standalone = importlib.util.module_from_spec(STANDALONE_SPEC)
STANDALONE_SPEC.loader.exec_module(standalone)


def write_official_result(
    path: Path,
    benchmark: str,
    hardware_category: str,
    cpu_time: float,
    wall_time: float,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "benchmark_name": benchmark,
        "config_id": "cpu_x86" if hardware_category == "CPU_X86" else "cpu_arm64",
        "hardware_category": hardware_category,
        "run_status": "SUCCESS",
        "error_message": "",
        "commit_sha": "1930995a8aabe45a13854f701b5b39ab732aef94",
        "workflow_run_id": "test",
        "metrics": {
            "CPU_TIME": {"value": cpu_time, "unit": "ms"},
            "WALL_TIME": {"value": wall_time, "unit": "ms"},
        },
    }
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


@pytest.fixture()
def official_runs(tmp_path: Path) -> Path:
    runs = tmp_path / "benchmark_runs"
    expected = {
        "gemma3_1b_flax_call": (1200.5, 900.25),
        "gemma2_2b_keras_jax": (2500.75, 1800.5),
        "gemma4_2b_bf16": (1000.25, 700.125),
    }
    for benchmark, (cpu_time, wall_time) in expected.items():
        write_official_result(
            runs / benchmark / "results.json",
            benchmark, "CPU_X86", cpu_time, wall_time,
        )
    return runs


def test_collector_extracts_all_six_metrics(official_runs: Path) -> None:
    payload = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    assert set(payload["results"]) == {
        f"{benchmark}/{field}"
        for benchmark in collector.BENCHMARKS
        for field in collector.FIELDS
    }
    metric = payload["results"]["gemma3_1b_flax_call/CPU_TIME"]
    assert metric["value"] == pytest.approx(1200.5)
    assert metric["unit"] == "ms"
    assert metric["direction"] == "lower_is_better"
    assert metric["group"] == "gemma3_1b_flax_call"
    assert payload["parameters"]["xla_commit"] == \
        "1930995a8aabe45a13854f701b5b39ab732aef94"
    assert payload["parameters"]["num_repeats"] == 5
    assert payload["runtime_context"]["hardware_category"] == "CPU_X86"
    assert payload["runtime_context"]["config_id"] == "cpu_x86"
    assert "hardware_category" not in payload["parameters"]
    assert "config_id" not in payload["parameters"]
    assert payload["parameters"]["device_type"] == "host"
    assert len(payload["measurements"]) == 6


def test_collector_rejects_hardware_category_mismatch(official_runs: Path) -> None:
    with pytest.raises(ValueError, match="expected 'CPU_ARM64'"):
        collector.collect(official_runs, "1930995a8aab", "aarch64", 5)


def test_collector_rejects_failed_run(official_runs: Path) -> None:
    path = official_runs / "gemma2_2b_keras_jax" / "results.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["run_status"] = "STATS_FAILURE"
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(ValueError, match="did not complete successfully"):
        collector.collect(official_runs, "1930995a8aab", "x86_64", 5)


def test_collector_rejects_missing_metric(official_runs: Path) -> None:
    path = official_runs / "gemma4_2b_bf16" / "results.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    del payload["metrics"]["WALL_TIME"]
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(ValueError, match="missing the WALL_TIME metric"):
        collector.collect(official_runs, "1930995a8aab", "x86_64", 5)


def test_collector_rejects_wrong_unit(official_runs: Path) -> None:
    path = official_runs / "gemma3_1b_flax_call" / "results.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["metrics"]["CPU_TIME"]["unit"] = "us"
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(ValueError, match="expected 'ms'"):
        collector.collect(official_runs, "1930995a8aab", "x86_64", 5)


def test_standalone_validation_accepts_collected_payload(official_runs: Path) -> None:
    payload = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    metrics = standalone.validate_metrics(payload)
    assert len(metrics) == 6


def test_standalone_validation_rejects_incomplete_payload(official_runs: Path) -> None:
    payload = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    del payload["results"]["gemma4_2b_bf16/WALL_TIME"]
    with pytest.raises(RuntimeError, match="expected 6 XLA metrics"):
        standalone.validate_metrics(payload)


def normalized_xla_result(architecture: str, factor: float, payload: dict) -> dict:
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
        "software": "xla",
        "version": "1930995a8aab",
        "architecture": architecture,
        "status": "passed",
        "cleanup_status": "passed",
        "build_info": {
            "requested_version": "1930995a8aab",
            "actual_version": "1930995a8aab",
            "recorded_at": "2026-10-31T00:00:00Z",
        },
        "parameters": {
            "benchmark_xla.json": json.loads(json.dumps(payload["parameters"]))
        },
        "parameter_signature": "same-parameters",
        "test_tools": {
            "xla_benchmark_harness": {
                "version": "与被测软件版本一致",
                "revision": "1930995a8aabe45a13854f701b5b39ab732aef94",
            },
            "bazelisk": {"version": "v1.29.0"},
            "bazel": {"version": "8.8.2"},
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


def test_cross_architecture_report_pairs_identical_benchmarks(official_runs: Path) -> None:
    payload = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    x86 = normalized_xla_result("x86_64", 1.0, payload)
    arm = normalized_xla_result("aarch64", 1.5, payload)
    comparison = compare_pair(x86, arm)
    assert len(comparison["metrics"]) == 6
    # lower_is_better: a 50% slower aarch64 value compares as 0.666...
    sample = comparison["metrics"]["gemma3_1b_flax_call/CPU_TIME"]
    assert sample["raw_ratio"] == pytest.approx(1.5, abs=1e-3)
    assert sample["relative_performance"] == pytest.approx(2.0 / 3.0, abs=1e-3)
    markdown = render_comparison(comparison)
    assert "gemma3_1b_flax_call/CPU_TIME" in markdown
    assert "越小越好" in markdown


def test_cross_architecture_report_rejects_parameter_drift(official_runs: Path) -> None:
    payload = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    x86 = normalized_xla_result("x86_64", 1.0, payload)
    arm = normalized_xla_result("aarch64", 1.5, payload)
    arm["parameters"]["benchmark_xla.json"]["num_repeats"] = 3
    with pytest.raises(ValueError, match="parameters differ"):
        compare_pair(x86, arm)


def test_case_yaml_wiring_matches_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["name"] == "xla"
    assert case["category"] == "Toolchain"
    assert case["versions"] == ["1930995a8aab"]
    assert case["test_tools"]["xla_benchmark_harness"]["revision"] == \
        "1930995a8aabe45a13854f701b5b39ab732aef94"
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh", "function": "build_xla",
    }
    assert stages["start"]["function"] == "start_xla_runtime"
    assert stages["test"]["function"] == "run_xla_benchmarks"
    assert stages["stop"]["function"] == "stop_xla_runtime"
    for stage in ("start", "test", "stop"):
        assert (CASE_DIR / stages[stage]["script"]).is_file()
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_xla.json"
    collection = case["metrics"]["collection"]
    assert collection["path"] == "results"
    assert collection["value_path"] == "value"
    assert collection["unit_path"] == "unit"
    assert collection["direction_path"] == "direction"
    assert collection["group_path"] == "group"


def test_collector_parameters_match_across_architectures(official_runs: Path) -> None:
    # The cross-architecture comparison rejects differing parameters, so only
    # machine-dependent values may live in runtime_context.
    x86 = collector.collect(official_runs, "1930995a8aab", "x86_64", 5)
    arm_runs = official_runs.parent / "arm_runs"
    arm_runs.mkdir()
    for benchmark in collector.BENCHMARKS:
        write_official_result(
            arm_runs / benchmark / "results.json", benchmark, "CPU_ARM64", 1.0, 1.0
        )
    arm = collector.collect(arm_runs, "1930995a8aab", "aarch64", 5)
    assert x86["parameters"] == arm["parameters"]
    assert x86["runtime_context"]["hardware_category"] == "CPU_X86"
    assert arm["runtime_context"]["hardware_category"] == "CPU_ARM64"


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPT_DIR / "builders" / "optimized.sh").read_text(encoding="utf-8")
    assert "not implemented" in content
    assert "return 30" in content


def test_container_runs_without_pinning_and_mounts_results() -> None:
    content = (SCRIPT_DIR / "common.sh").read_text(encoding="utf-8")
    assert "--network=host" in content
    assert "--cpuset-cpus" not in content
    assert "--cpuset-mems" not in content
    assert "--cpus=" not in content
    assert 'type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}' in content
    assert 'type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}' in content
    assert "boostkit.xla.run-id=${PERF_RUN_ID}" in content
    assert "openEuler-24.03-LTS-SP4" in content
    assert "docker load" in content
    assert "update-ca-trust extract" in content
    assert "repo.huaweicloud.com" in content


def test_build_and_test_run_inside_container() -> None:
    base = (SCRIPT_DIR / "builders" / "base.sh").read_text(encoding="utf-8")
    start = (SCRIPT_DIR / "stages" / "start.sh").read_text(encoding="utf-8")
    test_stage = (SCRIPT_DIR / "stages" / "test.sh").read_text(encoding="utf-8")
    stop = (SCRIPT_DIR / "stages" / "stop.sh").read_text(encoding="utf-8")
    assert "require_xla_container" in base
    assert "container_exec_root dnf" in base
    assert "container_exec git clone" in base
    assert "container_exec sh -c" in base
    assert "hlo_runner_main" in base
    assert "container_exec" in start
    assert "container_exec env" in start
    assert "container_exec" in test_stage
    assert "run_official_benchmark" in test_stage
    assert "remove_xla_container" in stop
