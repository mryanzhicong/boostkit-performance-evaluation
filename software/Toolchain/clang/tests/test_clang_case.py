"""Keep the SQLite/Clang metric contract, wiring and cross-architecture pairing stable."""

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
    "clang_collect_benchmark", SCRIPT_DIR / "results" / "collect_clang_benchmark.py"
)
assert COLLECT_SPEC is not None and COLLECT_SPEC.loader is not None
collector = importlib.util.module_from_spec(COLLECT_SPEC)
COLLECT_SPEC.loader.exec_module(collector)

STANDALONE_SPEC = importlib.util.spec_from_file_location(
    "clang_standalone_runtime", SCRIPT_DIR / "results" / "standalone_runtime.py"
)
assert STANDALONE_SPEC is not None and STANDALONE_SPEC.loader is not None
standalone = importlib.util.module_from_spec(STANDALONE_SPEC)
STANDALONE_SPEC.loader.exec_module(standalone)


def raw_log_text(rounds: int = 5) -> str:
    lines = []
    for index in range(rounds):
        for option in ("-O0", "-O2", "-Os"):
            lines.append(
                f"result scenario=compile workload={option} round={index + 1} "
                f"wall_seconds={10.0 + index + len(option)} artifact_bytes={1000000 + index * 7}"
            )
        for size in (100000, 500000):
            lines.append(
                f"result scenario=speedtest1 workload={size} round={index + 1} "
                f"wall_seconds={2.0 + index + size / 1000000} artifact_bytes={500000 + index}"
            )
    return "\n".join(lines) + "\n"


@pytest.fixture()
def raw_log(tmp_path: Path) -> Path:
    path = tmp_path / "sqlite_clang_raw.log"
    path.write_text(raw_log_text(), encoding="utf-8")
    return path


def test_collector_extracts_fifteen_metrics(raw_log: Path) -> None:
    payload = collector.collect(raw_log, "23.1.4", "x86_64", 5)
    assert len(payload["results"]) == 15
    metric = payload["results"]["compile sqlite3.c --opt=-O2: median wall time"]
    assert metric["value"] == pytest.approx(15.0)
    assert metric["unit"] == "s"
    assert metric["direction"] == "lower_is_better"
    assert metric["group"] == "compile"
    assert metric["workload"] == "-O2"
    assert metric["source_field"] == "median wall time"
    artifact = payload["results"]["speedtest1 --size=100000: artifact size"]
    assert artifact["unit"] == "KiB"
    assert payload["parameters"]["sqlite_version"] == "3.54.1"
    assert payload["parameters"]["rounds"] == 5
    assert payload["parameters"]["compile_options"] == ["-O0", "-O2", "-Os"]
    assert payload["parameters"]["speedtest_sizes"] == [100000, 500000]
    assert "architecture" not in payload["parameters"]


def test_collector_rejects_missing_workload(raw_log: Path) -> None:
    text = raw_log.read_text(encoding="utf-8")
    kept = "\n".join(
        line for line in text.splitlines() if "workload=-Os" not in line
    ) + "\n"
    raw_log.write_text(kept, encoding="utf-8")
    with pytest.raises(ValueError, match="missing results"):
        collector.collect(raw_log, "23.1.4", "x86_64", 5)


def test_collector_rejects_unexpected_round_count(raw_log: Path) -> None:
    raw_log.write_text(raw_log_text(rounds=3), encoding="utf-8")
    with pytest.raises(ValueError, match="expected 5 rounds"):
        collector.collect(raw_log, "23.1.4", "x86_64", 5)


def test_collector_rejects_unknown_scenario(raw_log: Path) -> None:
    with raw_log.open("a", encoding="utf-8") as handle:
        handle.write(
            "result scenario=other workload=x round=1 wall_seconds=1.0 artifact_bytes=1\n"
        )
    with pytest.raises(ValueError, match="unknown benchmark scenario"):
        collector.collect(raw_log, "23.1.4", "x86_64", 5)


def test_standalone_validation_accepts_payload(raw_log: Path) -> None:
    payload = collector.collect(raw_log, "23.1.4", "x86_64", 5)
    metrics = standalone.validate_metrics(payload)
    assert len(metrics) == 15


def test_standalone_validation_rejects_incomplete_payload(raw_log: Path) -> None:
    payload = collector.collect(raw_log, "23.1.4", "x86_64", 5)
    del payload["results"]["speedtest1 --size=500000: artifact size"]
    with pytest.raises(RuntimeError, match="expected 15 Clang metrics"):
        standalone.validate_metrics(payload)


def normalized_clang_result(architecture: str, factor: float, payload: dict) -> dict:
    metrics = {}
    for name, metric in payload["results"].items():
        metrics[name] = {
            "value": metric["value"] * factor,
            "unit": metric["unit"],
            "direction": metric["direction"],
            "group": metric["group"],
            "matrix": {
                "group": metric["group"],
                "row": metric["workload"],
                "column": metric["source_field"],
                "row_label": "负载档位",
                "column_order": list(collector.FIELDS[0:3]),
            },
        }
        metrics[name]["matrix"]["column_order"] = [
            field for field, _unit in collector.FIELDS
        ]
    return {
        "category": "Toolchain",
        "software": "clang",
        "version": "23.1.4",
        "architecture": architecture,
        "status": "passed",
        "cleanup_status": "passed",
        "build_info": {
            "requested_version": "23.1.4",
            "actual_version": "23.1.4",
            "recorded_at": "2026-10-31T00:00:00Z",
        },
        "parameters": {
            "benchmark_clang.json": json.loads(json.dumps(payload["parameters"]))
        },
        "parameter_signature": "same-parameters",
        "test_tools": {"sqlite": {"version": "3.54.1"}},
        "system_info": {
            "architecture": architecture,
            "cpu_model": "Example CPU",
            "cpu_count": 64 if architecture == "x86_64" else 96,
        },
        "runtime_before": {"memory": "before"},
        "runtime_after": {"memory": "after"},
        "metrics": metrics,
    }


def test_cross_architecture_report_pairs_same_workloads(raw_log: Path) -> None:
    payload = collector.collect(raw_log, "23.1.4", "x86_64", 5)
    x86 = normalized_clang_result("x86_64", 1.0, payload)
    arm = normalized_clang_result("aarch64", 1.25, payload)
    comparison = compare_pair(x86, arm)
    assert len(comparison["metrics"]) == 15
    sample = comparison["metrics"]["compile sqlite3.c --opt=-O2: median wall time"]
    assert sample["raw_ratio"] == pytest.approx(1.25, abs=1e-3)
    assert sample["relative_performance"] == pytest.approx(0.8, abs=1e-3)
    markdown = render_comparison(comparison)
    assert "## compile" in markdown
    assert "## speedtest1" in markdown
    assert ">−Os<" in markdown or "-Os" in markdown
    assert ">500000<" in markdown or "500000" in markdown
    assert "median wall time" in markdown
    assert "artifact size" in markdown
    assert "越小越好" in markdown


def test_cross_architecture_report_rejects_parameter_drift(raw_log: Path) -> None:
    payload = collector.collect(raw_log, "23.1.4", "x86_64", 5)
    x86 = normalized_clang_result("x86_64", 1.0, payload)
    arm = normalized_clang_result("aarch64", 1.25, payload)
    arm["parameters"]["benchmark_clang.json"]["rounds"] = 3
    with pytest.raises(ValueError, match="parameters differ"):
        compare_pair(x86, arm)


def test_case_yaml_wiring_matches_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["name"] == "clang"
    assert case["category"] == "Toolchain"
    assert case["versions"] == ["23.1.4"]
    assert case["test_tools"]["sqlite"]["version"] == "3.54.1"
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh", "function": "build_clang",
    }
    assert stages["start"]["function"] == "start_clang_runtime"
    assert stages["test"]["function"] == "run_clang_benchmarks"
    assert stages["stop"]["function"] == "stop_clang_runtime"
    for stage in ("start", "test", "stop"):
        assert (CASE_DIR / stages[stage]["script"]).is_file()
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_clang.json"
    assert case["outputs"]["sqlite_benchmark_output"]["path"] == "sqlite_clang_raw.log"
    matrix = case["metrics"]["collection"]["matrix"]
    assert matrix["group_path"] == "group"
    assert matrix["row_path"] == "workload"
    assert matrix["column_path"] == "source_field"
    assert matrix["column_order"] == [
        "median wall time", "fastest wall time", "artifact size",
    ]


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPT_DIR / "builders" / "optimized.sh").read_text(encoding="utf-8")
    assert "not implemented" in content
    assert "return 30" in content
