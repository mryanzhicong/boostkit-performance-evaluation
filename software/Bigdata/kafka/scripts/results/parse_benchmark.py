#!/usr/bin/env python3
"""Extract only the original Kafka perf tools' final producer/consumer MB/s."""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
from pathlib import Path

PRODUCER_SUMMARY = re.compile(
    r"^\s*(?P<records>\d+) records sent,\s*[\d.]+ records/sec\s*"
    r"\((?P<mbps>[\d.]+) MB/sec\)",
    re.MULTILINE,
)
CONSUMER_COLUMNS = ("MB.sec", "data.consumed.in.nMsg")


def positive(value: float, metric: str) -> float:
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"{metric} throughput must be positive and finite")
    return value


def producer_result(text: str, expected_records: int) -> float:
    summaries = [
        row
        for row in PRODUCER_SUMMARY.finditer(text)
        if int(row["records"]) == expected_records
    ]
    if len(summaries) != 1:
        raise ValueError(
            f"expected one Kafka producer final summary for {expected_records} "
            f"records, found {len(summaries)}"
        )
    return positive(float(summaries[0]["mbps"]), "Kafka producer")


def consumer_result(text: str, expected_records: int) -> float:
    rows = [[cell.strip() for cell in row] for row in csv.reader(text.splitlines())]
    summaries: list[tuple[int, float]] = []
    for index, columns in enumerate(rows[:-1]):
        if not set(CONSUMER_COLUMNS).issubset(columns):
            continue
        values = rows[index + 1]
        if len(values) != len(columns):
            raise ValueError("Kafka consumer summary has a mismatched CSV row")
        record = dict(zip(columns, values))
        summaries.append(
            (int(record["data.consumed.in.nMsg"]), float(record["MB.sec"]))
        )
    if len(summaries) != 1:
        raise ValueError(f"expected one Kafka consumer summary, found {len(summaries)}")
    count, throughput = summaries[0]
    if count != expected_records:
        raise ValueError("Kafka consumer did not receive the expected record count")
    return positive(throughput, "Kafka consumer")


def build_result(
    producer: str,
    consumer: str,
    expected_records: int,
    fetch_size: int = 1048576,
    threads: int = 8,
    record_size: int = 1024,
    partitions: int = 72,
    replication_factor: int = 1,
    producer_processes: int = 1,
) -> dict:
    return {
        "parameters": {
            "record_count": expected_records,
            "record_size_bytes": record_size,
            "partitions": partitions,
            "replication_factor": replication_factor,
            "producer_processes": producer_processes,
            "producer": {
                "acks": "all",
                "linger.ms": 500,
                "batch.size": 65536,
                "buffer.memory": 134217728,
                "retries": 0,
                "socket.send.buffer.bytes": 524288,
                "socket.receive.buffer.bytes": 524288,
                "throughput_limit": -1,
            },
            "consumer": {"fetch_size_bytes": fetch_size, "threads": threads},
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
    parser.add_argument("--fetch-size", type=int, default=1048576)
    parser.add_argument("--threads", type=int, default=8)
    parser.add_argument("--record-size", type=int, default=1024)
    parser.add_argument("--partitions", type=int, default=72)
    parser.add_argument("--replication-factor", type=int, default=1)
    parser.add_argument("--producer-processes", type=int, default=1)
    args = parser.parse_args()
    for name in (
        "expected_records",
        "fetch_size",
        "threads",
        "record_size",
        "partitions",
        "replication_factor",
        "producer_processes",
    ):
        if getattr(args, name) <= 0:
            parser.error(f"{name.replace('_', ' ')} must be positive")
    result = build_result(
        args.producer.read_text(encoding="utf-8"),
        args.consumer.read_text(encoding="utf-8"),
        args.expected_records,
        fetch_size=args.fetch_size,
        threads=args.threads,
        record_size=args.record_size,
        partitions=args.partitions,
        replication_factor=args.replication_factor,
        producer_processes=args.producer_processes,
    )
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
