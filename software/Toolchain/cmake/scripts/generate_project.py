#!/usr/bin/env python3
"""Generate a deterministic C project for the CMake configure/build matrix.

The project is one executable target with an explicit list of ``N`` generated
translation units plus ``main.c``.  Explicitly listing every source file keeps
configure cost dominated by CMake itself (CMakeLists parsing, target modelling
and Makefile generation) instead of a filesystem walk, and it makes the input
byte-for-byte reproducible on both architectures.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

CMAKE_LISTS_HEADER = """cmake_minimum_required(VERSION 3.20)
project(cmake_matrix_{count} C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_executable(bench
  main.c
"""

UNIT_TEMPLATE = """int {name}(void) {{
    return ({index} * 31 + 7) & 0xffff;
}}
"""

MAIN_TEMPLATE = """/* Generated deterministic benchmark driver: calls every unit once. */
#include <stdio.h>

{declarations}

int main(void) {{
    long long total = 0;
{calls}
    printf("%lld\\n", total);
    return 0;
}}
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--sources", required=True, type=int)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.sources <= 0:
        print("ERROR: --sources must be positive", file=sys.stderr)
        return 2

    marker = args.output / ".generated-sources"
    if marker.is_file():
        existing = marker.read_text(encoding="utf-8").strip()
        if existing == str(args.sources):
            print(f"[generate-project] reusing {args.output} ({args.sources} sources)")
            return 0
        print(
            f"[generate-project] source count changed ({existing} -> {args.sources}), regenerating",
            flush=True,
        )

    source_dir = args.output / "src"
    source_dir.mkdir(parents=True, exist_ok=True)
    for stale in source_dir.glob("unit_*.c"):
        stale.unlink()

    width = max(5, len(str(args.sources)))
    cmake_lines = [CMAKE_LISTS_HEADER.format(count=args.sources)]
    declarations: list[str] = []
    calls: list[str] = []
    for index in range(1, args.sources + 1):
        name = f"unit_{index:0{width}d}"
        (source_dir / f"{name}.c").write_text(
            UNIT_TEMPLATE.format(name=name, index=index), encoding="utf-8"
        )
        cmake_lines.append(f"  src/{name}.c\n")
        declarations.append(f"int {name}(void);")
        calls.append(f"    total += {name}();")
    cmake_lines.append(")\n")

    (args.output / "CMakeLists.txt").write_text("".join(cmake_lines), encoding="utf-8")
    (args.output / "main.c").write_text(
        MAIN_TEMPLATE.format(
            declarations="\n".join(declarations),
            calls="\n".join(calls),
        ),
        encoding="utf-8",
    )
    marker.write_text(f"{args.sources}\n", encoding="utf-8")
    print(f"[generate-project] generated {args.sources} sources in {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
