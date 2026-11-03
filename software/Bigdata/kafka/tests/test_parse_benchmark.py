"""Ensure only complete official Kafka throughput summaries become metrics."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("kafka_parse_benchmark", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

PRODUCER = (
    "10000000 records sent, 125000.0 records/sec (122.07 MB/sec), 5.00 ms avg latency"
)
CONSUMER = (
    "start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, "
    "nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec\n"
    "2026-01-01, 2026-01-02, 9765.63, 100.25, 10000000, 102656.0, 0, 100000, 100.25, 102656.0\n"
)


def test_extracts_exactly_two_original_throughputs() -> None:
    result = MODULE.build_result(PRODUCER, CONSUMER, 10_000_000)
    assert result["results"]["producer/throughput"]["value"] == 122.07
    assert result["results"]["consumer/throughput"]["value"] == 100.25
    assert result["parameters"]["record_count"] == 10_000_000


@pytest.mark.parametrize(
    "producer,consumer,records",
    [
        (PRODUCER, CONSUMER, 9_999_999),
        (PRODUCER.replace("122.07", "0.00"), CONSUMER, 10_000_000),
        (PRODUCER, CONSUMER.replace("10000000", "9999999"), 10_000_000),
        (PRODUCER + "\n" + PRODUCER, CONSUMER, 10_000_000),
        (PRODUCER, "", 10_000_000),
    ],
)
def test_rejects_missing_or_wrong_results(
    producer: str, consumer: str, records: int
) -> None:
    with pytest.raises(ValueError):
        MODULE.build_result(producer, consumer, records)
