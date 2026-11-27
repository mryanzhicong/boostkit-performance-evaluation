#!/usr/bin/env python3
"""Tests for the E2B sandbox-bench report parser."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
sys.path.insert(0, str(PARSER.parent))

import parse_benchmark as pb  # noqa: E402


def make_report(total: int = 60, planned: int | None = None, success: int | None = None,
                failed: int = 0, not_executed: int = 0, rate: float = 1.0,
                p50: float = 400.0, p95: float = 650.0, p99: float = 700.0,
                qps: float = 4.9, delete_rate: float = 1.0,
                delete_p50: float = 3.4, timed_out: bool = False) -> dict:
    planned = total if planned is None else planned
    success = total if success is None else success
    return {
        "generated_at": "2026-11-27T00:00:00Z",
        "scenario": "create",
        "config": {"requests": total, "concurrency": 1, "rounds": 1, "warmup": 0},
        "summary": {
            "planned": planned, "success": success, "failed": failed,
            "not_executed": not_executed, "success_rate": rate,
            "avg_ms": p50, "min_ms": p50 / 2, "p50_ms": p50, "p95_ms": p95,
            "p99_ms": p99, "max_ms": p99, "throughput_per_sec": qps,
            "wall_ms": 1000.0, "e2e_ms": 990.0,
            "post_p50_ms": p50 * 0.98, "ready_p50_ms": 0.5,
        },
        "delete_summary": {
            "planned": success, "success": success, "failed": 0, "not_executed": 0,
            "success_rate": delete_rate, "avg_ms": delete_p50, "p50_ms": delete_p50,
            "p95_ms": delete_p50 * 2, "p99_ms": delete_p50 * 3,
            "throughput_per_sec": 6.8, "wall_ms": 0, "e2e_ms": None,
        },
        "before": {"alive_count": 0, "used_mb": 1.0},
        "after": {"alive_count": success, "used_mb": 2.0},
        "memory_delta": {"delta_mib": 1.0, "new_instances": success,
                         "per_instance_mib": 1.0, "scope": "host", "unavailable_reason": None},
        "rounds": [{
            "phase": "measurement", "operation": "create", "planned": total,
            "failed": failed, "not_executed": not_executed, "ok": success,
            "wall_ms": 1000.0, "e2e_ms": 990.0,
            "events": [{"seq": i, "phase": "measurement", "success": True,
                        "timed_out": timed_out, "duration_ms": p50,
                        "post_ms": p50 * 0.98, "ready_ms": 0.5}
                       for i in range(1, total + 1)],
        }],
    }


def write_level(root: Path, scenario: str, level: int, samples: int, warmups: int = 1,
                **kwargs) -> None:
    directory = root / scenario / f"c{level}"
    directory.mkdir(parents=True, exist_ok=True)
    for index in range(1, warmups + 1):
        (directory / f"warmup{index}.log").write_text("warmup\n", encoding="utf-8")
    for index in range(1, samples + 1):
        report = make_report(**kwargs)
        (directory / f"rep{index}.json").write_text(json.dumps(report), encoding="utf-8")
        (directory / f"rep{index}.log").write_text("log\n", encoding="utf-8")


def test_collect_uses_median_and_emits_every_metric(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3)
    results, samples = pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)

    assert len(results) == len(pb.METRICS)
    assert len(samples) == len(pb.METRICS)
    assert results["sandbox-create-latency-p50-c1"]["value"] == pytest.approx(400.0)
    assert results["sandbox-create-latency-p50-c1"]["unit"] == "ms"
    assert results["sandbox-create-latency-p50-c1"]["direction"] == "lower_is_better"
    assert results["sandbox-create-latency-p50-c1"]["group"] == "concurrency_1"
    assert results["sandbox-create-success-rate-c1"]["value"] == pytest.approx(100.0)
    assert results["sandbox-create-throughput-c1"]["direction"] == "higher_is_better"


def test_collect_averages_multiple_samples(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, p50=100.0)
    directory = tmp_path / "create" / "c1"
    for index, p50 in enumerate((100.0, 200.0, 300.0), start=1):
        (directory / f"rep{index}.json").write_text(
            json.dumps(make_report(p50=p50)), encoding="utf-8")
    results, _ = pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)
    assert results["sandbox-create-latency-p50-c1"]["value"] == pytest.approx(200.0)


def test_missing_sample_report_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=2)
    with pytest.raises(pb.ParseError, match="missing sample report"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_missing_warmup_log_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, warmups=0)
    with pytest.raises(pb.ParseError, match="missing warmup log"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_failed_requests_fail(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, success=59, failed=1, rate=59 / 60)
    with pytest.raises(pb.ParseError, match="lost requests"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_partial_success_rate_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, rate=0.5)
    with pytest.raises(pb.ParseError, match="success_rate"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_wrong_planned_total_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, planned=30, success=60)
    with pytest.raises(pb.ParseError, match="does not match total"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_timed_out_event_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, timed_out=True)
    with pytest.raises(pb.ParseError, match="timed-out"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_delete_failure_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3, delete_rate=0.5)
    with pytest.raises(pb.ParseError, match="delete_summary.success_rate"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_unexpected_extra_report_fails(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=3)
    (tmp_path / "create" / "c1" / "rep9.json").write_text(
        json.dumps(make_report()), encoding="utf-8")
    with pytest.raises(pb.ParseError, match="unexpected sample reports"):
        pb.collect(tmp_path, warmups=1, samples=3, levels=(1,), total=60)


def test_cli_rejects_too_few_samples(tmp_path: Path) -> None:
    exit_code = pb.main([
        "--runs-dir", str(tmp_path), "--results-dir", str(tmp_path / "out"),
        "--samples", "4",
    ])
    assert exit_code == 40


def test_cli_writes_benchmark_payload(tmp_path: Path) -> None:
    write_level(tmp_path, "create", 1, samples=5)
    exit_code = pb.main([
        "--runs-dir", str(tmp_path), "--results-dir", str(tmp_path / "out"),
        "--warmups", "1", "--samples", "5", "--levels", "1", "--scenarios", "create",
        "--total", "60", "--version", "2026.09", "--architecture", "aarch64",
    ])
    assert exit_code == 0
    payload = json.loads((tmp_path / "out" / "benchmark_e2b.json").read_text(encoding="utf-8"))
    assert payload["software"] == "e2b"
    assert payload["metric_count"] == len(payload["results"])
    assert payload["scenarios"] == ["create"]
    assert (tmp_path / "out" / "samples.json").is_file()
