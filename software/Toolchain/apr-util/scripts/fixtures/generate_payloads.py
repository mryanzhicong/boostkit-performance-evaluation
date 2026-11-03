#!/usr/bin/env python3
"""Generate the deterministic base64 payloads for the APR-util case.

The payloads are generated from a fixed splitmix64 stream (seed 20261102), so
the exact same bytes are produced on every machine and every architecture.
The start stage re-runs this generator and verifies the byte counts and SHA-256
digests against the pins in ``scripts/common.sh``; the manifest written here is
cross-checked as well.

Usage:
    generate_payloads.py OUTPUT_DIRECTORY
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

SEED = 20261102
MASK64 = 0xFFFFFFFFFFFFFFFF
PAYLOAD_SIZES = (64, 1024, 65536, 1048576)

# splitmix64 constants.
GOLDEN_GAMMA = 0x9E3779B97F4A7C15
MIX1 = 0xBF58476D1CE4E5B9
MIX2 = 0x94D049BB133111EB


class SplitMix64:
    def __init__(self, seed: int) -> None:
        self.state = seed & MASK64

    def next_u64(self) -> int:
        self.state = (self.state + GOLDEN_GAMMA) & MASK64
        value = self.state
        value = ((value ^ (value >> 30)) * MIX1) & MASK64
        value = ((value ^ (value >> 27)) * MIX2) & MASK64
        return value ^ (value >> 31)


def generate_payload(size: int) -> bytes:
    generator = SplitMix64(SEED)
    output = bytearray(size)
    filled = 0
    while filled < size:
        value = generator.next_u64()
        for shift in range(0, 64, 8):
            if filled >= size:
                break
            output[filled] = (value >> shift) & 0xFF
            filled += 1
    return bytes(output)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: generate_payloads.py OUTPUT_DIRECTORY", file=sys.stderr)
        return 2
    output_dir = Path(sys.argv[1])
    output_dir.mkdir(parents=True, exist_ok=True)
    payloads: dict[str, dict[str, object]] = {}
    for size in PAYLOAD_SIZES:
        data = generate_payload(size)
        name = f"payload_{size}.bin"
        path = output_dir / name
        path.write_bytes(data)
        payloads[name] = {
            "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
            "seed": SEED,
            "generator": "splitmix64",
        }
    manifest = {
        "generator": "generate_payloads.py",
        "seed": SEED,
        "algorithm": "splitmix64 byte stream",
        "payloads": payloads,
    }
    (output_dir / "payloads.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    for name, entry in sorted(payloads.items()):
        print(f"{name} bytes={entry['bytes']} sha256={entry['sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
