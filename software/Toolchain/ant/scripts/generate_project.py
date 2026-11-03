#!/usr/bin/env python3
"""Generate the fixed Java source corpus and its Ant build file.

The corpus is a flat package of ``--classes`` independent compilation units of
increasing size plus one ``build.xml`` with the same targets for every scale:

* ``clean``     - remove ``build/``
* ``compile``   - javac of ``src`` into ``build/classes``
* ``jar``       - package ``build/classes`` into ``build/bench.jar``
* ``clean_jar`` - ``clean`` then ``jar``

Nothing is downloaded and no dependency resolution is involved, so the same
sources and the same build file are used on both architectures of the matrix.
"""

from __future__ import annotations

import argparse
from pathlib import Path

CLASS_TEMPLATE = """package bench;

public final class Class{index:04d} {{
    private final int seed;

    public Class{index:04d}(int seed) {{
        this.seed = seed;
    }}

    public long compute(int rounds) {{
        long acc = seed + {index}L;
        for (int i = 0; i < rounds; i++) {{
            acc = (acc * 6364136223846793005L + 1442695040888963407L) % 1000000007L;
            if ((acc & 1L) == 0L) {{
                acc /= 2L;
            }} else {{
                acc += i;
            }}
        }}
        return acc;
    }}
}}
"""

BUILD_XML = """<?xml version="1.0" encoding="UTF-8"?>
<project name="bench-{classes}" default="jar" basedir=".">
    <property name="src.dir" value="src"/>
    <property name="build.dir" value="build"/>
    <property name="classes.dir" value="${{build.dir}}/classes"/>
    <property name="jar.file" value="${{build.dir}}/bench.jar"/>

    <target name="clean">
        <delete dir="${{build.dir}}"/>
    </target>

    <target name="compile">
        <mkdir dir="${{classes.dir}}"/>
        <javac srcdir="${{src.dir}}" destdir="${{classes.dir}}"
               includeantruntime="false" encoding="UTF-8"
               source="21" target="21" debug="true"/>
    </target>

    <target name="jar" depends="compile">
        <jar destfile="${{jar.file}}" basedir="${{classes.dir}}"/>
    </target>

    <target name="clean_jar" depends="clean,jar"/>
</project>
"""


def write_project(output: Path, classes: int) -> None:
    source_dir = output / "src" / "bench"
    source_dir.mkdir(parents=True, exist_ok=True)
    for index in range(1, classes + 1):
        (source_dir / f"Class{index:04d}.java").write_text(
            CLASS_TEMPLATE.format(index=index), encoding="utf-8"
        )
    (output / "build.xml").write_text(BUILD_XML.format(classes=classes), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--classes", required=True, type=int)
    args = parser.parse_args()
    if args.classes <= 0:
        parser.error("--classes must be positive")
    write_project(args.output, args.classes)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
