"""Ensure PerformanceEvaluation output becomes a complete HBase metric set."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("hbase_parse_benchmark", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

WRITE = """===== randomWrite =====
2026-01-01 INFO mapreduce.Job:  map 100% reduce 0%
Elapsed time in milliseconds=25040
Row count=2097152
"""


def read_section(round_number: int, tps: float, latency: float) -> str:
    return f"""
===== randomRead round {round_number} =====
[RandomReadTest duration ]   Min: 199453ms   Max: 209255ms   Avg: 203626ms
[ Avg latency (us)]   {latency}
[ Avg TPS/QPS]        {tps}    row per second
"""


def raw(rounds: int = 3) -> str:
    return WRITE + "".join(read_section(index, 40000.0 + index, 190.0 + index)
                           for index in range(1, rounds + 1))


def test_extracts_three_metrics() -> None:
    result = MODULE.build_result(raw(), 3, 2, 16, 8, 100000)
    assert set(result["results"]) == {
        "pe-randomWrite/throughput", "pe-randomRead/throughput",
        "pe-randomRead/avg_latency",
    }
    assert result["results"]["pe-randomWrite/throughput"]["value"] == pytest.approx(83752.0, rel=1e-3)
    assert result["results"]["pe-randomRead/throughput"]["value"] == 40002.0
    assert result["results"]["pe-randomRead/avg_latency"]["value"] == pytest.approx(0.192, abs=1e-4)
    assert result["parameters"]["presplit_regions"] == 16


def test_does_not_use_the_duration_average_as_throughput() -> None:
    result = MODULE.build_result(raw(), 3, 2, 16, 8, 100000)
    assert result["results"]["pe-randomRead/throughput"]["value"] != 203626


def test_rejects_missing_read_round() -> None:
    with pytest.raises(ValueError):
        MODULE.build_result(raw(rounds=2), 3, 2, 16, 8, 100000)


def test_uses_the_driver_summary_after_per_map_summaries() -> None:
    per_map = "".join(
        f"\t\tElapsed time in milliseconds={elapsed}\n\t\tRow count=524288\n"
        for elapsed in (5761, 5511, 5693, 5800)
    )
    driver = "\t\tElapsed time in milliseconds=22765\n\t\tRow count=2097152\n"
    write = "===== randomWrite =====\n" + per_map + driver
    result = MODULE.build_result(write + raw()[len(WRITE):], 3, 2, 16, 8, 100000)
    assert result["results"]["pe-randomWrite/throughput"]["value"] == pytest.approx(
        2097152 / 22.765, rel=1e-6
    )


@pytest.mark.parametrize("body", [
    WRITE.replace("Row count=2097152", ""),
    WRITE.replace("Elapsed time in milliseconds=25040", ""),
    WRITE.replace("2097152", "0"),
])
def test_rejects_incomplete_write_output(body: str) -> None:
    with pytest.raises(ValueError):
        MODULE.build_result(body + raw()[len(WRITE):], 3, 2, 16, 8, 100000)


def test_rejects_zero_read_metrics() -> None:
    bad = WRITE + "".join(
        read_section(index, 0.0 if index == 2 else 40000.0 + index, 190.0)
        for index in range(1, 4)
    )
    with pytest.raises(ValueError):
        MODULE.build_result(bad, 3, 2, 16, 8, 100000)
