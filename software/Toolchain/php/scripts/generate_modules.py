#!/usr/bin/env python3
"""Generate the deterministic include-module tree for the include scenario.

Every module declares a fixed number of small pure functions plus one global
array literal, which makes the include scenario measure PHP's file compilation
and inclusion path rather than trivially small files.  Generation happens once
in the build stage; the measurement stage only reads the generated tree.
"""

from __future__ import annotations

import argparse
from pathlib import Path

FUNCTION_TEMPLATE = (
    "function rich_{index:04d}_{slot:03d}(int $v): int {{ "
    "$acc = $v + {offset}; "
    "for ($k = 0; $k < 3; $k++) {{ $acc = ($acc * 1103515245 + 12345) & 0x7fffffff; }} "
    "return $acc; }}"
)
ARRAY_ELEMENTS = 500
FUNCTIONS_PER_MODULE = 100


def module_text(index: int) -> str:
    functions = "\n".join(
        FUNCTION_TEMPLATE.format(index=index, slot=slot, offset=index * 37 + slot)
        for slot in range(FUNCTIONS_PER_MODULE)
    )
    data = ",".join(str((index * 7919 + position) % 100000) for position in range(ARRAY_ELEMENTS))
    return f"<?php\n{functions}\n$rich_{index:04d} = [{data}];\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--count", required=True, type=int)
    args = parser.parse_args()
    if args.count < 1:
        parser.error("--count must be positive")
    output = args.output
    output.mkdir(parents=True, exist_ok=True)
    for index in range(1, args.count + 1):
        (output / f"module_{index:04d}.php").write_text(module_text(index), encoding="utf-8")
    (output / "count.txt").write_text(f"{args.count}\n", encoding="utf-8")
    print(
        f"[php-generate] wrote {args.count} include modules "
        f"({FUNCTIONS_PER_MODULE} functions, {ARRAY_ELEMENTS} array elements each) under {output}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
