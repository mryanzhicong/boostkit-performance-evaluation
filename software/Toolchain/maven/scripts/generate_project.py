#!/usr/bin/env python3
"""Generate a deterministic single-module Java project for the build matrix.

The project is a plain jar with no third-party dependencies, so every measured
Maven invocation only exercises the build lifecycle itself. Generation is
idempotent: an existing tree with the same requested class count is reused.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

POM_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>perf.matrix</groupId>
  <artifactId>matrix-{classes}</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.release>17</maven.compiler.release>
  </properties>
</project>
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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--classes", required=True, type=int)
    parser.add_argument("--package", default="bench")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.classes <= 0:
        print("ERROR: --classes must be positive", file=sys.stderr)
        return 2
    if args.package != "bench":
        print("ERROR: only the 'bench' package is supported", file=sys.stderr)
        return 2

    marker = args.output / ".generated-classes"
    if marker.is_file():
        existing = marker.read_text(encoding="utf-8").strip()
        if existing == str(args.classes):
            print(f"[generate-project] reusing {args.output} ({args.classes} classes)")
            return 0
        print(
            f"[generate-project] class count changed ({existing} -> {args.classes}), regenerating",
            flush=True,
        )

    source_dir = args.output / "src" / "main" / "java" / args.package
    source_dir.mkdir(parents=True, exist_ok=True)
    for stale in source_dir.glob("Class*.java"):
        stale.unlink()

    (args.output / "pom.xml").write_text(
        POM_TEMPLATE.format(classes=args.classes), encoding="utf-8"
    )

    width = max(5, len(str(args.classes)))
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
