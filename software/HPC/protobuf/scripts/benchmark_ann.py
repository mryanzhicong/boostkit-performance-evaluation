#!/usr/bin/env python3
"""Benchmark the protobuf Python runtime with fixed, comparable message scenarios."""

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
from pathlib import Path


PROTO_CONTENT = '''
syntax = "proto3";
package perfbench;

message SimpleMessage { int32 id = 1; string name = 2; float value = 3; bool flag = 4; }
message RepeatedInt32 { repeated int32 values = 1; }
message RepeatedString { repeated string items = 1; }
message SubMessage { int32 sub_id = 1; string sub_name = 2; float sub_value = 3; }
message NestedMessage { int32 id = 1; SubMessage sub = 2; repeated SubMessage subs = 3; }
message LargeMessage {
  int32 id = 1; string name = 2; repeated int32 values = 3; repeated string labels = 4;
  repeated SubMessage items = 5; float score = 6; bool active = 7;
}
'''

MESSAGE_CONFIGS = {
    "SimpleMessage": "Simple message with scalar fields",
    "RepeatedInt32": "Message with a repeated int32 field",
    "RepeatedString": "Message with a repeated string field",
    "NestedMessage": "Message with nested and repeated nested fields",
    "LargeMessage": "Message with mixed scalar, repeated, and nested fields",
}


def median(values: list[float]) -> float:
    if not values:
        raise RuntimeError("cannot calculate a median from no samples")
    return float(statistics.median(values))


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


def create_message(pb2: object, config_name: str, size: int) -> object:
    if config_name == "SimpleMessage":
        message = pb2.SimpleMessage()
        message.id, message.name, message.value, message.flag = 42, "test_message_name", 3.14, True
        return message
    if config_name == "RepeatedInt32":
        message = pb2.RepeatedInt32()
        message.values.extend(range(size))
        return message
    if config_name == "RepeatedString":
        message = pb2.RepeatedString()
        message.items.extend(f"item_{index}" for index in range(size))
        return message
    if config_name == "NestedMessage":
        message = pb2.NestedMessage()
        message.id, message.sub.sub_id, message.sub.sub_name, message.sub.sub_value = 42, 1, "sub_test", 2.71
        for index in range(size):
            child = message.subs.add()
            child.sub_id, child.sub_name, child.sub_value = index, f"sub_item_{index}", index * 0.1
        return message
    if config_name == "LargeMessage":
        message = pb2.LargeMessage()
        message.id, message.name, message.score, message.active = 42, "large_test", 99.5, True
        message.values.extend(range(size))
        message.labels.extend(("label_a", "label_b"))
        for index in range(min(size, 10)):
            child = message.items.add()
            child.sub_id, child.sub_name, child.sub_value = index, f"item_{index}", index * 0.5
        return message
    raise ValueError(f"unknown protobuf message scenario: {config_name}")


def measure_scenario(pb2: object, config_name: str, size: int, num_messages: int, iterations: int) -> dict[str, object]:
    message = create_message(pb2, config_name, size)
    message_class = type(message)
    serialized = message.SerializeToString()
    fidelity_message = message_class()
    fidelity_message.ParseFromString(serialized)
    if fidelity_message.SerializeToString() != serialized:
        raise RuntimeError(f"fidelity validation failed for {config_name}")

    samples: list[dict[str, float]] = []
    for iteration in range(1, iterations + 1):
        print(f"[ANN] {config_name} size={size} iteration {iteration}/{iterations}")
        serialize_start = time.perf_counter()
        for _ in range(num_messages):
            message.SerializeToString()
        serialize_elapsed = time.perf_counter() - serialize_start

        deserialize_start = time.perf_counter()
        for _ in range(num_messages):
            decoded = message_class()
            decoded.ParseFromString(serialized)
        deserialize_elapsed = time.perf_counter() - deserialize_start
        if serialize_elapsed <= 0 or deserialize_elapsed <= 0:
            raise RuntimeError(f"invalid timing result for {config_name}")
        samples.append(
            {
                "serialize_qps": num_messages / serialize_elapsed,
                "deserialize_qps": num_messages / deserialize_elapsed,
                "serialize_latency_us": serialize_elapsed * 1_000_000 / num_messages,
                "deserialize_latency_us": deserialize_elapsed * 1_000_000 / num_messages,
            }
        )

    return {
        "description": MESSAGE_CONFIGS[config_name],
        "serialized_size_bytes": len(serialized),
        "fidelity": "passed",
        "aggregation": "median",
        "serialize_qps": median([sample["serialize_qps"] for sample in samples]),
        "deserialize_qps": median([sample["deserialize_qps"] for sample in samples]),
        "serialize_latency_us": median([sample["serialize_latency_us"] for sample in samples]),
        "deserialize_latency_us": median([sample["deserialize_latency_us"] for sample in samples]),
        "samples": samples,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="protobuf serialization benchmark")
    parser.add_argument("--output", required=True)
    parser.add_argument("--num-messages", type=int, required=True)
    parser.add_argument("--iterations", type=int, required=True)
    parser.add_argument("--message-size", type=int, required=True)
    args = parser.parse_args()
    if args.num_messages <= 0 or args.iterations <= 0 or args.message_size <= 0:
        raise ValueError("num-messages, iterations, and message-size must be positive")

    proto_dir = Path(tempfile.mkdtemp(prefix="protobuf_bench_"))
    try:
        print(f"[ANN] compiling benchmark schemas in {proto_dir}")
        compile_proto(proto_dir)
        sys.path.insert(0, str(proto_dir))
        import perfbench_pb2 as pb2

        results = {
            name: measure_scenario(pb2, name, args.message_size, args.num_messages, args.iterations)
            for name in MESSAGE_CONFIGS
        }
        output = {
            "benchmark": "serialization_search",
            "reference": "https://github.com/protocolbuffers/protobuf",
            "timestamp": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "parameters": {
                "num_messages": args.num_messages,
                "iterations": args.iterations,
                "message_size": args.message_size,
                "message_configs": list(MESSAGE_CONFIGS),
                "aggregation": "median",
            },
            "results_summary": results,
        }
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
        print(f"[ANN] results saved to: {output_path}")
        return 0
    finally:
        shutil.rmtree(proto_dir, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
