#!/usr/bin/env python3
"""Tests for the CubeSandbox cube-bench report parser."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
sys.path.insert(0, str(PARSER.parent))

import parse_benchmark as pb  # noqa: E402


def make_report(total: int = 300, rate: float = 1.0, avg: float = 47.8, p95: float = 120.0,
                p99: float = 180.0, qps: float = 17.9) -> dict:
    successful = int(total * rate)
    return {
        "timestamp": "2026-11-26T00:00:00Z",
        "config": {"concurrency": 1, "total": total, "mode": "create-only", "warmup": 3},
        "summary": {
            "total_time_s": 28.0,
            "successful": successful,
            "errors": total - successful,
            "success_rate": rate,
            "throughput_qps": qps,
        },
        # cube-bench records latency only for successful creates.
        "create": {"count": successful, "min": 1.0, "max": 900.0, "avg": avg, "std": 1.0,
                   "p50": avg, "p90": p95, "p95": p95, "p99": p99},
        "delete": None,
        "raw": [{"seq": i, "create_ms": avg, "delete_ms": 0.0} for i in range(total)],
    }


def write_level(root: Path, level: int, samples: int, warmups: int = 1, **kwargs) -> None:
    scenario = root / f"c{level}"
    scenario.mkdir(parents=True, exist_ok=True)
    for i in range(1, warmups + 1):
        (scenario / f"warmup{i}.log").write_text("warmup\n", encoding="utf-8")
    for i in range(1, samples + 1):
        payload = make_report(**kwargs)
        payload["summary"]["throughput_qps"] = kwargs.get("qps", 17.9) + i
        (scenario / f"rep{i}.json").write_text(json.dumps(payload), encoding="utf-8")
        (scenario / f"rep{i}.log").write_text("log\n", encoding="utf-8")


def test_collect_computes_medians(tmp_path: Path) -> None:
    for level in (1, 20, 50):
        write_level(tmp_path, level, samples=6)
    results, samples = pb.collect(tmp_path, warmups=1, samples=6)
    assert set(samples) == {
        f"{name}-c{level}" for level in (1, 20, 50) for name, *_ in pb.METRICS
    }
    rate = results["sandbox-create-success-rate-c50"]
    assert rate["value"] == pytest.approx(100.0)
    assert rate["unit"] == "%"
    assert rate["direction"] == "higher_is_better"
    assert rate["group"] == "concurrency_50"
    mean = results["sandbox-create-latency-mean-c1"]
    assert mean["value"] == pytest.approx(47.8)
    assert mean["direction"] == "lower_is_better"
    throughput = results["sandbox-create-throughput-c20"]
    assert throughput["unit"] == "sandboxes/s"
    assert throughput["samples"] == 6


def test_partial_success_is_recorded_not_hidden(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6, rate=0.8)
    results, _ = pb.collect(tmp_path, warmups=1, samples=6, levels=(1,))
    rate = results["sandbox-create-success-rate-c1"]
    assert rate["value"] == pytest.approx(80.0)
    assert results["sandbox-create-latency-mean-c1"]["value"] == pytest.approx(47.8)


def test_count_mismatch_with_successful_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6, rate=0.8)
    path = tmp_path / "c1" / "rep3.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["create"]["count"] = 500
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6, levels=(1,))


def test_missing_sample_report_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6)
    (tmp_path / "c1" / "rep4.json").unlink()
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6)


def test_unexpected_sample_report_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6)
    (tmp_path / "c1" / "rep7.json").write_text("{}", encoding="utf-8")
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6)


def test_total_mismatch_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6, total=100)
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6, total=300)


def test_missing_warmup_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6, warmups=1)
    (tmp_path / "c1" / "warmup1.log").unlink()
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6)


def test_missing_field_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6)
    payload = json.loads((tmp_path / "c1" / "rep2.json").read_text(encoding="utf-8"))
    del payload["create"]["p99"]
    (tmp_path / "c1" / "rep2.json").write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6)


def test_zero_success_rate_fails(tmp_path: Path) -> None:
    write_level(tmp_path, 1, samples=6, rate=0.0)
    with pytest.raises(pb.ParseError):
        pb.collect(tmp_path, warmups=1, samples=6, levels=(1,))


def test_cli_writes_results(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    out = tmp_path / "out"
    for level in (1, 20, 50):
        write_level(runs, level, samples=6)
    code = pb.main([
        "--runs-dir", str(runs), "--results-dir", str(out),
        "--warmups", "1", "--samples", "6", "--levels", "1,20,50",
        "--version", "0.8.0", "--architecture", "aarch64", "--variant", "base",
    ])
    assert code == 0
    payload = json.loads((out / "benchmark_cubesandbox.json").read_text(encoding="utf-8"))
    assert payload["software"] == "cubesandbox"
    assert payload["version"] == "0.8.0"
    assert len(payload["results"]) == 15
    assert (out / "samples.json").is_file()


def test_cli_rejects_small_sample_count(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_level(runs, 1, samples=4)
    code = pb.main(["--runs-dir", str(runs), "--results-dir", str(tmp_path / "out"),
                    "--samples", "4", "--levels", "1"])
    assert code == 40


def test_cli_reports_parse_error(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_level(runs, 1, samples=6)
    (runs / "c1" / "rep6.json").unlink()
    code = pb.main(["--runs-dir", str(runs), "--results-dir", str(tmp_path / "out"),
                    "--samples", "6", "--levels", "1"])
    assert code == 40


def test_script_is_executable_from_shell(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    for level in (1, 20, 50):
        write_level(runs, level, samples=6)
    result = subprocess.run(
        [sys.executable, str(PARSER), "--runs-dir", str(runs),
         "--results-dir", str(tmp_path / "out"), "--levels", "1"],
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert "sandbox-create-latency-mean" in result.stdout
