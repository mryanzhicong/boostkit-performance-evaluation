"""Regression tests for the supplied malloc_benchmark summary format."""

import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "framework"))

from context import RunContext
from generate_comparison import compare_pair, generate
from normalize_results import normalize
from reporting import render_comparison


PARSER = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("jemalloc_benchmark_parser", PARSER)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_parse_all_modes(tmp_path: Path) -> None:
    for mode in (0, 1, 2):
        (tmp_path / f"benchmark_mode_{mode}.log").write_text(
            f"Mode: {mode}, Time:  3.500 seconds, Average RSS:  0.200 GB, "
            "Max RSS:  0.300 GB. Average speed:  1.250, Max speed:  2.000.\n",
            encoding="utf-8",
        )
        metrics = MODULE.parse_mode(tmp_path / f"benchmark_mode_{mode}.log", mode)
        assert len(metrics) == 5
        assert metrics[3] == {
            "name": f"mode_{mode}/average_speed", "group": f"mode_{mode}",
            "value": 1.25, "unit": "score", "direction": "higher_is_better",
        }


def test_rejects_wrong_mode_and_missing_summary(tmp_path: Path) -> None:
    path = tmp_path / "benchmark_mode_0.log"
    path.write_text("benchmark crashed\n", encoding="utf-8")
    with pytest.raises(ValueError, match="exactly one"):
        MODULE.parse_mode(path, 0)
    path.write_text(
        "Mode: 1, Time:  3.500 seconds, Average RSS:  0.200 GB, "
        "Max RSS:  0.300 GB. Average speed:  1.250, Max speed:  2.000.\n",
        encoding="utf-8",
    )
    with pytest.raises(ValueError, match="expected mode 0"):
        MODULE.parse_mode(path, 0)


def test_framework_normalization_and_cross_architecture_report(tmp_path: Path) -> None:
    case_path = ROOT / "software/HPC/jemalloc/case.yaml"
    case = yaml.safe_load(case_path.read_text(encoding="utf-8"))
    normalized = []
    for architecture, elapsed, speed, binary_hash in (
        ("x86_64", 4.0, 1.25, "a" * 64),
        ("aarch64", 2.0, 1.50, "b" * 64),
    ):
        output = tmp_path / architecture
        output.mkdir()
        (output / "build_variant.json").write_text(
            '{"variant":"base","parameters":{"variant":"base"}}\n', encoding="utf-8"
        )
        for mode in (0, 1, 2):
            (output / f"benchmark_mode_{mode}.log").write_text(
                f"Mode: {mode}, Time: {elapsed:.3f} seconds, "
                f"Average RSS: 0.200 GB, Max RSS: 0.300 GB. "
                f"Average speed: {speed:.3f}, Max speed: 2.000.\n",
                encoding="utf-8",
            )
        subprocess.run(
            [sys.executable, str(PARSER), "--results-dir", str(output),
             "--threads", "384", "--binary-sha256", binary_hash],
            check=True,
        )
        benchmark = json.loads((output / "benchmark_jemalloc.json").read_text(encoding="utf-8"))
        assert len(benchmark["results"]) == 15
        assert benchmark["benchmark_binary_sha256"] == binary_hash
        context = RunContext(
            root=ROOT, case_path=case_path, case=case, category="HPC",
            software="jemalloc", version="5.4.0", architecture=architecture,
            run_id=f"test-{architecture}", output_dir=output, work_dir=tmp_path / f"work-{architecture}",
        )
        (output / "build_info.json").write_text(
            json.dumps({
                "recorded_at": "2026-11-06T00:00:00Z", "category": "HPC",
                "software": "jemalloc", "requested_version": "5.4.0", "actual_version": "5.4.0",
                "architecture": architecture, "run_id": context.run_id,
            }), encoding="utf-8",
        )
        result = normalize(context, "passed")
        result["cleanup_status"] = "passed"
        (output / "normalized_result.json").write_text(
            json.dumps(result, ensure_ascii=False), encoding="utf-8"
        )
        normalized.append(result)

    x86, arm = normalized
    assert x86["parameters"] == arm["parameters"]
    assert x86["parameter_signature"] == arm["parameter_signature"]
    comparison = compare_pair(x86, arm)
    assert len(comparison["metrics"]) == 15
    assert comparison["metrics"]["mode_0/average_speed"]["relative_performance"] == 1.2
    assert comparison["metrics"]["mode_0/elapsed_seconds"]["relative_performance"] == 2.0
    report = render_comparison(comparison)
    assert "## mode_0" in report
    assert "## mode_1" in report
    assert "## mode_2" in report
    summary = generate(tmp_path, tmp_path / "consolidated")
    assert summary["comparisons"] == 1
    assert (tmp_path / "consolidated/HPC-jemalloc-5.4.0.json").is_file()
    assert "mode_0" in (tmp_path / "consolidated/combined-report.md").read_text(encoding="utf-8")
