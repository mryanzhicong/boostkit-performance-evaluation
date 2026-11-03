#!/usr/bin/env python3
"""Extract only the original Kafka perf tools' final producer/consumer MB/s."""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
from pathlib import Path

PRODUCER = re.compile(
    r"^\s*(?P<records>\d+) records sent,\s*[\d.]+ records/sec\s*"
    r"\((?P<mbps>[\d.]+) MB/sec\)",
    re.MULTILINE,
)


def producer_result(text: str, expected_records: int) -> float:
    rows = list(PRODUCER.finditer(text))
    if len(rows) != 1:
        raise ValueError(f"expected one Kafka producer summary, found {len(rows)}")
    row = rows[0]
    if int(row["records"]) != expected_records:
        raise ValueError("Kafka producer did not send the expected record count")
    return positive(float(row["mbps"]))


def consumer_result(text: str, expected_records: int) -> float:
    rows = list(csv.reader(text.splitlines()))
    summaries: list[tuple[int, float]] = []
    for index, row in enumerate(rows[:-1]):
        columns = [column.strip() for column in row]
        if "MB.sec" not in columns or "data.consumed.in.nMsg" not in columns:
            continue
        value = [column.strip() for column in rows[index + 1]]
        if len(value) != len(columns):
            raise ValueError("Kafka consumer summary has a mismatched CSV row")
        count = int(value[columns.index("data.consumed.in.nMsg")])
        throughput = positive(float(value[columns.index("MB.sec")]))
        summaries.append((count, throughput))
    if len(summaries) != 1:
        raise ValueError(f"expected one Kafka consumer summary, found {len(summaries)}")
    if summaries[0][0] != expected_records:
        raise ValueError("Kafka consumer did not receive the expected record count")
    return summaries[0][1]


def positive(value: float) -> float:
    if not math.isfinite(value) or value <= 0:
        raise ValueError("Kafka throughput must be positive and finite")
    return value


def build_result(producer: str, consumer: str, expected_records: int) -> dict:
    return {
        "parameters": {
            "record_count": expected_records,
            "record_size_bytes": 1024,
            "partitions": 72,
            "replication_factor": 1,
            "producer": {
                "compression.type": "lz4",
                "acks": "1",
                "linger.ms": 500,
                "batch.size": 65536,
                "buffer.memory": 134217728,
                "throughput_limit": -1,
            },
            "consumer": {"fetch_size_bytes": 1024},
        },
        "results": {
            "producer/throughput": {
                "value": producer_result(producer, expected_records),
                "unit": "MB/s",
                "direction": "higher_is_better",
                "group": "生产者",
            },
            "consumer/throughput": {
                "value": consumer_result(consumer, expected_records),
                "unit": "MB/s",
                "direction": "higher_is_better",
                "group": "消费者",
            },
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--producer", required=True, type=Path)
    parser.add_argument("--consumer", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--expected-records", required=True, type=int)
    args = parser.parse_args()
    if args.expected_records <= 0:
        parser.error("expected records must be positive")
    result = build_result(
        args.producer.read_text(encoding="utf-8"),
        args.consumer.read_text(encoding="utf-8"),
        args.expected_records,
    )
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
