#!/usr/bin/env python3
"""Generate the deterministic RESP byte streams replayed by the hiredis case.

The streams are hand-written RESP2 encodings of reply pipelines that a Redis
client typically parses; they are generated from one fixed seed so both
architectures replay identical bytes.  The fixture manifest records the size,
SHA-256 digest and reply count of every stream; ``scripts/common.sh`` pins the
same values and the start stage verifies them.

Streams:

* ``pipeline_get.resp``   100,000 bulk-string replies of varying length, the
                          shape of a GET pipeline.
* ``bulk_256k.resp``        64 bulk-string replies of 256 KiB each, the shape of
                          large value reads (memory bandwidth bound).
* ``nested_arrays.resp``   50,000 replies of a two-element array containing an
                          integer and a nested array with a bulk string.
* ``mixed_types.resp``    100,000 replies cycling through simple string, error,
                          integer, empty bulk, nil bulk and empty array.
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

SEED = 20261102
PIPELINE_REPLIES = 100_000
BULK_REPLIES = 64
BULK_PAYLOAD_BYTES = 256 * 1024
NESTED_REPLIES = 50_000
MIXED_REPLIES = 100_000

WORDS = (
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "kernel", "driver", "network", "storage", "benchmark", "throughput",
)


class SplitMix64:
    def __init__(self, seed: int) -> None:
        self.state = seed & 0xFFFFFFFFFFFFFFFF

    def next(self) -> int:
        self.state = (self.state + 0x9E3779B97F4A7C15) & 0xFFFFFFFFFFFFFFFF
        value = self.state
        value = ((value ^ (value >> 30)) * 0xBF58476D1CE4E5B9) & 0xFFFFFFFFFFFFFFFF
        value = ((value ^ (value >> 27)) * 0x94D049BB133111EB) & 0xFFFFFFFFFFFFFFFF
        return value ^ (value >> 31)

    def pick(self, values):
        return values[self.next() % len(values)]


def bulk(payload: bytes) -> bytes:
    return b"$%d\r\n" % len(payload) + payload + b"\r\n"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: generate_resp_fixtures.py FIXTURE_DIRECTORY", file=sys.stderr)
        return 1
    root = Path(sys.argv[1])
    root.mkdir(parents=True, exist_ok=True)
    rng = SplitMix64(SEED)

    handles = {
        "pipeline_get.resp": (root / "pipeline_get.resp").open("wb"),
        "bulk_256k.resp": (root / "bulk_256k.resp").open("wb"),
        "nested_arrays.resp": (root / "nested_arrays.resp").open("wb"),
        "mixed_types.resp": (root / "mixed_types.resp").open("wb"),
    }

    def emit(name: str, digest: hashlib._Hash, payload: bytes, counters: dict) -> None:
        handles[name].write(payload)
        digest.update(payload)
        counters[name]["bytes"] += len(payload)

    digests = {name: hashlib.sha256() for name in handles}
    counters = {name: {"bytes": 0, "replies": 0} for name in handles}

    try:
        for index in range(PIPELINE_REPLIES):
            word = rng.pick(WORDS)
            payload = f"val:{word}:{index}".encode()
            emit("pipeline_get.resp", digests["pipeline_get.resp"], bulk(payload), counters)
            counters["pipeline_get.resp"]["replies"] += 1

        block = bytes(((index * 37 + 11) % 251) for index in range(65536))
        chunk = block * 4
        for _ in range(BULK_REPLIES):
            emit("bulk_256k.resp", digests["bulk_256k.resp"], bulk(chunk), counters)
            counters["bulk_256k.resp"]["replies"] += 1

        for index in range(NESTED_REPLIES):
            value = rng.next() % 1_000_000
            payload = (
                b"*2\r\n"
                + b":%d\r\n" % index
                + b"*2\r\n"
                + b":%d\r\n" % value
                + bulk(b"abcdef")
            )
            emit("nested_arrays.resp", digests["nested_arrays.resp"], payload, counters)
            counters["nested_arrays.resp"]["replies"] += 1

        for index in range(MIXED_REPLIES):
            kind = rng.next() % 6
            if kind == 0:
                payload = b"+OK\r\n"
            elif kind == 1:
                payload = b"-ERR unknown command\r\n"
            elif kind == 2:
                payload = b":%d\r\n" % index
            elif kind == 3:
                payload = b"$0\r\n\r\n"
            elif kind == 4:
                payload = b"$-1\r\n"
            else:
                payload = b"*0\r\n"
            emit("mixed_types.resp", digests["mixed_types.resp"], payload, counters)
            counters["mixed_types.resp"]["replies"] += 1
    finally:
        for handle in handles.values():
            handle.close()

    manifest = {
        "seed": SEED,
        "streams": {
            name: {
                "bytes": counters[name]["bytes"],
                "replies": counters[name]["replies"],
                "sha256": digests[name].hexdigest(),
            }
            for name in handles
        },
        "bulk_payload_bytes": BULK_PAYLOAD_BYTES,
    }
    (root / "fixtures.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    total = sum(item["bytes"] for item in manifest["streams"].values())
    print(
        f"[hiredis-fixtures] streams={len(handles)} total_bytes={total} "
        + " ".join(
            f"{name}={item['bytes']}B/{item['replies']}replies"
            for name, item in manifest["streams"].items()
        ),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
