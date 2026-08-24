#!/usr/bin/env python3
"""Generate a deterministic synthetic I420 (YUV 4:2:0) test clip.

x265 benchmarks need a raw video input. This module synthesizes a reproducible
I420 clip (no external corpus download required) so that the encode benchmark is
fully self-contained. The generated content is a simple deterministic gradient
pattern, which is sufficient to exercise the encoder deterministically.
"""

from __future__ import annotations

import os
import sys


def generate_yuv(width: int, height: int, frames: int, output_path: str) -> int:
    if width % 2 or height % 2:
        raise ValueError("width and height must be even for I420")
    y_size = width * height
    uv_w, uv_h = width // 2, height // 2
    uv_size = uv_w * uv_h

    row_tmpl = bytearray(width)
    for x in range(width):
        row_tmpl[x] = (x * 3 + 16) & 0xFF

    u_row_tmpl = bytearray(uv_w)
    for x in range(uv_w):
        u_row_tmpl[x] = (x * 2 + 40) & 0xFF

    v_plane_const = bytearray([128]) * uv_size

    with open(output_path, "wb") as f:
        for fr in range(frames):
            shift = (fr * 4) % width
            shift_u = (fr * 4) % uv_w
            y_plane = bytearray(y_size)
            u_plane = bytearray(uv_size)

            if shift:
                for y in range(height):
                    off = (y + shift) % width
                    if off:
                        y_plane[y * width:(y + 1) * width] = (
                            row_tmpl[-off:] + row_tmpl[:-off]
                        )
                    else:
                        y_plane[y * width:(y + 1) * width] = row_tmpl
            else:
                for y in range(height):
                    y_plane[y * width:(y + 1) * width] = row_tmpl

            for y in range(uv_h):
                off = (y + shift_u) % uv_w
                if off:
                    u_plane[y * uv_w:(y + 1) * uv_w] = (
                        u_row_tmpl[-off:] + u_row_tmpl[:-off]
                    )
                else:
                    u_plane[y * uv_w:(y + 1) * uv_w] = u_row_tmpl

            f.write(y_plane)
            f.write(u_plane)
            f.write(v_plane_const)

    return os.path.getsize(output_path)


def main() -> int:
    if len(sys.argv) < 5:
        print(
            "usage: gen_yuv.py WIDTH HEIGHT FRAMES OUTPUT_FILE",
            file=sys.stderr,
        )
        return 1
    width = int(sys.argv[1])
    height = int(sys.argv[2])
    frames = int(sys.argv[3])
    output_path = sys.argv[4]
    size = generate_yuv(width, height, frames, output_path)
    print(
        f"[gen-yuv] generated {width}x{height} I420, {frames} frames, "
        f"{size} bytes ({size / (1024 * 1024):.1f} MiB) -> {output_path}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())