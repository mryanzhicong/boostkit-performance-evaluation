#!/usr/bin/env python3
"""Generate the deterministic GDB workload: C fixtures, GDB command files and Python.

The workload is generated instead of committed so that the size of every symbol
table is explicit and reproducible.  fixtures/fixtures.json records the SHA-256 of
every generated file, so a change in the input is detected by the build stage
instead of silently changing what was measured.

Generated inputs:
  symbols_<N>.c    N global functions with debug information (symbol table size)
  steps_500.c      a function with 600 simple statements (single stepping)
  deep_2000.c      a recursion 2000 frames deep plus a leaf function (backtrace)
  breakpoints.cmd  200 function breakpoints on symbols_50000 (no inferior)
  steps.cmd        500 single-step commands after breaking at main
  python_eval.py   5000 symbol lookups through the GDB Python API
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

FUNCTION_COUNTS = {"symbols_1000": 1000, "symbols_10000": 10000, "symbols_50000": 50000}
BREAKPOINT_COUNT = 200
STEP_COUNT = 500
LOOKUP_COUNT = 5000
DEEP_FRAMES = 2000

SYMBOLS_TEMPLATE = """\
/* Deterministic symbol-table fixture: {count} global functions with debug info. */
{functions}
int main(void) {{
    return fn_{first:05d}(0);
}}
"""

STEPS_TEMPLATE = """\
/* Deterministic single-step fixture: one function with {statements} statements. */
int stepped(int seed) {{
    int x = seed;
{body}
    return x;
}}

int main(void) {{
    return stepped(0);
}}
"""

DEEP_TEMPLATE = """\
/* Deterministic deep-stack fixture: a recursion {frames} frames deep. */
volatile int deep_sink;

__attribute__((noinline)) void crash_here(int depth) {{
    deep_sink = depth;
}}

__attribute__((noinline)) void recurse(int depth) {{
    if (depth <= 0) {{
        crash_here(0);
    }} else {{
        recurse(depth - 1);
    }}
}}

int main(void) {{
    recurse({frames});
    return 0;
}}
"""

BREAKPOINTS_TEMPLATE = """\
set pagination off
set confirm off
{breaks}
quit
"""

STEPS_CMD_TEMPLATE = """\
set pagination off
set confirm off
set trace-commands on
break main
run
{steps}
quit
"""

PYTHON_TEMPLATE = """\
import gdb

looked_up = 0
found = 0
for index in range({lookups}):
    symbol = gdb.lookup_global_symbol("fn_%05d" % index)
    looked_up += 1
    if symbol is not None:
        found += 1
print("[gdb-py-eval] looked_up=%d found=%d" % (looked_up, found))
"""


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def generate_symbols(directory: Path, name: str, count: int) -> None:
    functions = "\n".join(
        f"int fn_{index:05d}(int value) {{ return value + {index}; }}"
        for index in range(count)
    )
    write(
        directory / f"{name}.c",
        SYMBOLS_TEMPLATE.format(count=count, functions=functions, first=0),
    )


def generate_steps(directory: Path) -> None:
    statements = max(STEP_COUNT + 100, 600)
    body = "\n".join(f"    x += {index % 7 + 1};" for index in range(statements))
    write(directory / "steps_500.c", STEPS_TEMPLATE.format(statements=statements, body=body))


def generate_deep(directory: Path) -> None:
    write(directory / "deep_2000.c", DEEP_TEMPLATE.format(frames=DEEP_FRAMES))


def generate_command_files(directory: Path) -> None:
    # 200 breakpoints spread over the 50000 functions of symbols_50000.
    stride = max(1, FUNCTION_COUNTS["symbols_50000"] // BREAKPOINT_COUNT)
    breaks = "\n".join(
        f"break fn_{index * stride:05d}" for index in range(BREAKPOINT_COUNT)
    )
    write(directory / "breakpoints.cmd", BREAKPOINTS_TEMPLATE.format(breaks=breaks))
    steps = "\n".join("step" for _ in range(STEP_COUNT))
    write(directory / "steps.cmd", STEPS_CMD_TEMPLATE.format(steps=steps))
    write(directory / "python_eval.py", PYTHON_TEMPLATE.format(lookups=LOOKUP_COUNT))


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generate(directory: Path) -> dict:
    directory.mkdir(parents=True, exist_ok=True)
    for name, count in FUNCTION_COUNTS.items():
        generate_symbols(directory, name, count)
    generate_steps(directory)
    generate_deep(directory)
    generate_command_files(directory)

    fixtures = {}
    for path in sorted(directory.glob("*")):
        if not path.is_file():
            continue
        fixtures[path.name] = {
            "sha256": digest(path),
            "bytes": path.stat().st_size,
        }
    return {
        "generator": "gdb-workload-matrix",
        "generator_version": 1,
        "parameters": {
            "function_counts": FUNCTION_COUNTS,
            "breakpoints": BREAKPOINT_COUNT,
            "steps": STEP_COUNT,
            "lookups": LOOKUP_COUNT,
            "deep_frames": DEEP_FRAMES,
        },
        "fixtures": fixtures,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--summary", type=Path, required=True)
    arguments = parser.parse_args()
    summary = generate(arguments.output)
    arguments.summary.parent.mkdir(parents=True, exist_ok=True)
    arguments.summary.write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    for name, entry in sorted(summary["fixtures"].items()):
        print(f"[gdb-fixtures] {name:<20} {entry['bytes']:>8} B  {entry['sha256'][:16]}…", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
