#!/usr/bin/env python3
"""Generate fixed LCG-filled PPM images (identical bytes on every arch)."""

from __future__ import annotations

import sys


def gen(path: str, width: int, height: int) -> None:
    # A plain 32-bit LCG (integer arithmetic only): the generated image is
    # byte-for-byte identical on every architecture and every run, so the
    # encoder always sees the exact same input.
    state = 0x1234567

    def lcg() -> int:
        nonlocal state
        state = (state * 1664525 + 1013904223) & 0xFFFFFFFF
        return state

    row = bytearray(width * 3)
    with open(path, "wb") as handle:
        handle.write(f"P6\n{width} {height}\n255\n".encode())
        for _ in range(height):
            for i in range(0, len(row), 3):
                value = lcg()
                row[i] = (value >> 24) & 0xFF
                row[i + 1] = (value >> 16) & 0xFF
                row[i + 2] = (value >> 8) & 0xFF
            handle.write(row)


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: gen_ppm.py OUTPUT WIDTH HEIGHT", file=sys.stderr)
        return 1
    gen(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
