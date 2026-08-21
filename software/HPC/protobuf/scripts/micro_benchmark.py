#!/usr/bin/env python3
"""Run fixed protobuf micro-benchmark scenarios and retain every raw sample."""

from __future__ import annotations

import argparse
import datetime
import json
import os
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


PROTO_CONTENT = '''
syntax = "proto3";
package perfbench;

message SimpleMessage { int32 id = 1; string name = 2; float value = 3; bool flag = 4; }
message RepeatedInt32 { repeated int32 values = 1; }
message SubMessage { int32 sub_id = 1; string sub_name = 2; float sub_value = 3; }
message NestedMessage { int32 id = 1; SubMessage sub = 2; repeated SubMessage subs = 3; }
'''

SIZE_VALUES = (10, 50, 100, 500, 1000)


def median(values: list[float]) -> float:
    if not values:
        raise RuntimeError("cannot calculate a median from no samples")
    return float(statistics.median(values))


def parse_thread_counts(value: str, num_messages: int) -> list[int]:
    try:
        counts = [int(item.strip()) for item in value.split(",") if item.strip()]
    except ValueError as exc:
        raise ValueError("thread-counts must be a comma-separated list of integers") from exc
    if not counts or any(count <= 0 or count > num_messages for count in counts):
        raise ValueError("every thread count must be between 1 and num-messages")
    if len(set(counts)) != len(counts):
        raise ValueError("thread-counts must not contain duplicates")
    return counts


def compile_proto(proto_dir: Path) -> None:
    proto_file = proto_dir / "perfbench.proto"
    proto_file.write_text(PROTO_CONTENT, encoding="utf-8")
    protoc = os.environ.get("PROTOC_BIN") or shutil.which("protoc")
    if not protoc:
        raise RuntimeError("private protoc is unavailable")
    completed = subprocess.run(
        [protoc, "--proto_path", str(proto_dir), "--python_out", str(proto_dir), str(proto_file)],
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(f"protoc compilation failed: {completed.stderr.strip()}")


def create_simple_message(pb2: object) -> object:
    message = pb2.SimpleMessage()
    message.id, message.name, message.value, message.flag = 42, "test_message", 3.14, True
    return message


def create_repeated_int32_message(pb2: object, size: int) -> object:
    message = pb2.RepeatedInt32()
    message.values.extend(range(size))
    return message


def create_nested_message(pb2: object) -> object:
    message = pb2.NestedMessage()
    message.id, message.sub.sub_id, message.sub.sub_name, message.sub.sub_value = 42, 1, "sub", 2.71
    for index in range(100):
        child = message.subs.add()
        child.sub_id, child.sub_name, child.sub_value = index, f"item_{index}", index * 0.1
    return message


def require_fidelity(message: object) -> bytes:
    serialized = message.SerializeToString()
    decoded = type(message)()
    decoded.ParseFromString(serialized)
    if decoded.SerializeToString() != serialized:
        raise RuntimeError("fidelity validation failed")
    return serialized


def collect_samples(operation, iterations: int) -> list[dict[str, float]]:
    samples = []
    for _ in range(iterations):
        samples.append(operation())
    return samples


def median_result(samples: list[dict[str, float]]) -> dict[str, object]:
    if not samples:
        raise RuntimeError("benchmark produced no samples")
    return {
        "aggregation": "median",
        "samples": samples,
        **{field: median([sample[field] for sample in samples]) for field in samples[0]},
    }


def serialize_metrics(message: object, num_messages: int) -> dict[str, float]:
    started = time.perf_counter()
    for _ in range(num_messages):
        message.SerializeToString()
    elapsed = time.perf_counter() - started
    if elapsed <= 0:
        raise RuntimeError("invalid serialization timing result")
    return {
        "serialize_qps": num_messages / elapsed,
        "serialize_latency_us": elapsed * 1_000_000 / num_messages,
    }


def deserialize_metrics(serialized: bytes, message_class: type, num_messages: int) -> dict[str, float]:
    started = time.perf_counter()
    for _ in range(num_messages):
        decoded = message_class()
        decoded.ParseFromString(serialized)
    elapsed = time.perf_counter() - started
    if elapsed <= 0:
        raise RuntimeError("invalid deserialization timing result")
    return {
        "deserialize_qps": num_messages / elapsed,
        "deserialize_latency_us": elapsed * 1_000_000 / num_messages,
    }


def split_work(total: int, workers: int) -> list[int]:
    base, remainder = divmod(total, workers)
    return [base + (1 if index < remainder else 0) for index in range(workers)]


def multithread_metrics(operation, num_messages: int, thread_count: int) -> dict[str, float]:
    work_items = split_work(num_messages, thread_count)
    started = time.perf_counter()
    with ThreadPoolExecutor(max_workers=thread_count) as executor:
        futures = [executor.submit(operation, count) for count in work_items]
        completed = sum(future.result() for future in futures)
    elapsed = time.perf_counter() - started
    if completed != num_messages or elapsed <= 0:
        raise RuntimeError("invalid multithread benchmark result")
    return {"qps": completed / elapsed}


def serialize_worker(message: object, count: int) -> int:
    for _ in range(count):
        message.SerializeToString()
    return count


def deserialize_worker(serialized: bytes, message_class: type, count: int) -> int:
    for _ in range(count):
        decoded = message_class()
        decoded.ParseFromString(serialized)
    return count


def json_metrics(message: object, num_messages: int) -> dict[str, float]:
    from google.protobuf.json_format import MessageToJson

    binary_started = time.perf_counter()
    for _ in range(num_messages):
        message.SerializeToString()
    binary_elapsed = time.perf_counter() - binary_started
    json_started = time.perf_counter()
    for _ in range(num_messages):
        MessageToJson(message)
    json_elapsed = time.perf_counter() - json_started
    if binary_elapsed <= 0 or json_elapsed <= 0:
        raise RuntimeError("invalid JSON benchmark timing result")
    return {
        "binary_serialize_qps": num_messages / binary_elapsed,
        "json_serialize_qps": num_messages / json_elapsed,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="protobuf micro benchmarks")
    parser.add_argument("--output", required=True)
    parser.add_argument("--num-messages", type=int, required=True)
    parser.add_argument("--iterations", type=int, required=True)
    parser.add_argument("--thread-counts", required=True)
    args = parser.parse_args()
    if args.num_messages <= 0 or args.iterations <= 0:
        raise ValueError("num-messages and iterations must be positive")
    thread_counts = parse_thread_counts(args.thread_counts, args.num_messages)

    proto_dir = Path(tempfile.mkdtemp(prefix="protobuf_micro_"))
    try:
        print(f"[MICRO] compiling benchmark schemas in {proto_dir}")
        compile_proto(proto_dir)
        sys.path.insert(0, str(proto_dir))
        import perfbench_pb2 as pb2

        simple_message = create_simple_message(pb2)
        simple_serialized = require_fidelity(simple_message)
        nested_message = create_nested_message(pb2)
        nested_serialized = require_fidelity(nested_message)
        results: dict[str, object] = {
            "single_serialize": median_result(
                collect_samples(lambda: serialize_metrics(simple_message, args.num_messages), args.iterations)
            ),
            "single_deserialize": median_result(
                collect_samples(
                    lambda: deserialize_metrics(simple_serialized, type(simple_message), args.num_messages),
                    args.iterations,
                )
            ),
            "json_serialization": median_result(
                collect_samples(lambda: json_metrics(simple_message, args.num_messages), args.iterations)
            ),
            "large_message": {
                "serialized_size_bytes": len(nested_serialized),
                "serialize": median_result(
                    collect_samples(lambda: serialize_metrics(nested_message, args.num_messages), args.iterations)
                ),
                "deserialize": median_result(
                    collect_samples(
                        lambda: deserialize_metrics(nested_serialized, type(nested_message), args.num_messages),
                        args.iterations,
                    )
                ),
            },
            "multithread_serialize": {},
            "multithread_deserialize": {},
            "size_parameter_sweep": {},
        }
        for thread_count in thread_counts:
            label = f"threads_{thread_count}"
            results["multithread_serialize"][label] = median_result(
                collect_samples(
                    lambda: multithread_metrics(
                        lambda count: serialize_worker(simple_message, count), args.num_messages, thread_count
                    ),
                    args.iterations,
                )
            )
            results["multithread_deserialize"][label] = median_result(
                collect_samples(
                    lambda: multithread_metrics(
                        lambda count: deserialize_worker(simple_serialized, type(simple_message), count),
                        args.num_messages,
                        thread_count,
                    ),
                    args.iterations,
                )
            )
        for size in SIZE_VALUES:
            message = create_repeated_int32_message(pb2, size)
            serialized = require_fidelity(message)
            results["size_parameter_sweep"][f"size_{size}"] = {
                "serialized_size_bytes": len(serialized),
                "serialize": median_result(
                    collect_samples(lambda: serialize_metrics(message, args.num_messages), args.iterations)
                ),
                "deserialize": median_result(
                    collect_samples(
                        lambda: deserialize_metrics(serialized, type(message), args.num_messages), args.iterations
                    )
                ),
            }

        output = {
            "benchmark": "micro_operations",
            "reference": "https://github.com/protocolbuffers/protobuf",
            "timestamp": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "parameters": {
                "num_messages": args.num_messages,
                "iterations": args.iterations,
                "thread_counts": thread_counts,
                "size_values": list(SIZE_VALUES),
                "aggregation": "median",
            },
            "results": results,
        }
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
        print(f"[MICRO] results saved to: {output_path}")
        return 0
    finally:
        shutil.rmtree(proto_dir, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
