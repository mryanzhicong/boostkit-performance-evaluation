#!/usr/bin/env python3
"""Generate a deterministic single-module Gradle Java project for the build matrix.

The project is a plain `java` project without third-party dependencies, so every
measured Gradle invocation only exercises the build lifecycle itself (configuration,
compilation, jar assembly). Generation is idempotent: an existing tree with the
same requested class count is reused.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SETTINGS_TEMPLATE = """rootProject.name = 'matrix-{classes}'
"""

BUILD_TEMPLATE = """plugins {{
    id 'java'
}}

group = 'perf.matrix'
version = '1.0.0'

tasks.withType(JavaCompile).configureEach {{
    options.encoding = 'UTF-8'
}}

jar {{
    archiveBaseName = 'matrix-{classes}'
}}
"""

CLASS_TEMPLATE = """package bench;

public final class {name} {{
    private static final int SEED = {index};

    public int value() {{
        return (SEED * 31 + 7) & 0xffff;
    }}

    public int combine(int other) {{
        int result = value();
        for (int step = 0; step < 4; step++) {{
            result = (result * 33) ^ (other + step);
        }}
        return result;
    }}
}}
"""

INCREMENTAL_TEMPLATE = """package bench;

public final class {name} {{
    private static final int SEED = {index};
    private static final int REVISION = {revision};

    public int value() {{
        return (SEED * 31 + 7 + REVISION) & 0xffff;
    }}

    public int combine(int other) {{
        int result = value();
        for (int step = 0; step < 4; step++) {{
            result = (result * 33) ^ (other + step);
        }}
        return result;
    }}
}}
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--classes", required=True, type=int)
    parser.add_argument("--package", default="bench")
    parser.add_argument(
        "--incremental-revision",
        type=int,
        default=0,
        help="rewrite the first class with this revision so Gradle recompiles it",
    )
    return parser.parse_args()


def write_project(output: Path, classes: int) -> None:
    (output / "settings.gradle").write_text(
        SETTINGS_TEMPLATE.format(classes=classes), encoding="utf-8"
    )
    (output / "build.gradle").write_text(
        BUILD_TEMPLATE.format(classes=classes), encoding="utf-8"
    )


def main() -> int:
    args = parse_args()
    if args.classes <= 0:
        print("ERROR: --classes must be positive", file=sys.stderr)
        return 2
    if args.package != "bench":
        print("ERROR: only the 'bench' package is supported", file=sys.stderr)
        return 2

    source_dir = args.output / "src" / "main" / "java" / args.package
    source_dir.mkdir(parents=True, exist_ok=True)
    width = max(5, len(str(args.classes)))
    first_name = f"Class{1:0{width}d}"

    if args.incremental_revision > 0:
        (source_dir / f"{first_name}.java").write_text(
            INCREMENTAL_TEMPLATE.format(
                name=first_name, index=1, revision=args.incremental_revision
            ),
            encoding="utf-8",
        )
        print(
            f"[generate-project] rewrote {first_name}.java with revision "
            f"{args.incremental_revision}"
        )
        return 0

    marker = args.output / ".generated-classes"
    if marker.is_file() and marker.read_text(encoding="utf-8").strip() == str(args.classes):
        print(f"[generate-project] reusing {args.output} ({args.classes} classes)")
        return 0

    write_project(args.output, args.classes)
    for stale in source_dir.glob("Class*.java"):
        stale.unlink()
    for index in range(1, args.classes + 1):
        name = f"Class{index:0{width}d}"
        (source_dir / f"{name}.java").write_text(
            CLASS_TEMPLATE.format(name=name, index=index), encoding="utf-8"
        )
    marker.write_text(f"{args.classes}\n", encoding="utf-8")
    print(f"[generate-project] generated {args.classes} classes in {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
