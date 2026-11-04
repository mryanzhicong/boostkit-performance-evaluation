#!/usr/bin/env python3
"""Deterministically generate the fixed Scala 3 source corpus used by the case.

Two modes are used by the build stage:

``compile``
    Write ``--classes`` generated source files plus a ``bench.Main`` entry point
    into ``<output>/src/bench``.  The corpus only uses the Scala 3 standard
    library, so the compiler never needs to reach the network.

``workload``
    Write a single ``bench.Main`` program implementing one fixed computation
    (``arith``, ``collections`` or ``strings``) into ``<output>/src/bench``.
    These programs are compiled once during the build stage and are executed by
    the measured run scenarios.
"""

from __future__ import annotations

import argparse
from pathlib import Path

CLASS_TEMPLATE = """package bench

final class Class{index:04d}(seed: Int) {{
  def compute(rounds: Int): Long = {{
    var acc = seed.toLong + {index}
    var i = 0
    while (i < rounds) {{
      acc = (acc * 6364136223846793005L + 1442695040888963407L) % 1000000007L
      if ((acc & 1L) == 0L) acc = acc / 2L else acc = acc + i
      i += 1
    }}
    acc
  }}
}}
"""

MAIN_TEMPLATE = """package bench

object Main {{
  def main(args: Array[String]): Unit = {{
    val rounds = if (args.length > 0) args(0).toInt else 50
    var checksum = 0L
{instantiations}
    println(s"checksum=$checksum rounds=$rounds")
  }}
}}
"""

INSTANTIATION_TEMPLATE = "    checksum = (checksum * 31L + new Class{i:04d}({i}).compute(rounds)) % 1000000007L"

ARITH_TEMPLATE = """package bench

object Main {
  def main(args: Array[String]): Unit = {
    val rounds = if (args.length > 0) args(0).toInt else 40000000
    var acc = 0L
    var i = 0
    while (i < rounds) {
      acc = (acc * 1103515245L + 12345L + i) % 2147483647L
      i += 1
    }
    println(s"arith=$acc rounds=$rounds")
  }
}
"""

COLLECTIONS_TEMPLATE = """package bench

object Main {
  def main(args: Array[String]): Unit = {
    val size = if (args.length > 0) args(0).toInt else 400000
    var checksum = 0L
    var round = 0
    while (round < 5) {
      val values = Vector.tabulate(size)(i => (i * 2654435761L + round) % 1000003L)
      val grouped = values.groupBy(value => (value % 97L).toInt)
      val folded = values.foldLeft(0L)((acc, value) => (acc + value) % 1000000007L)
      val sorted = values.sorted
      checksum = (checksum + folded + sorted.head + sorted.last + grouped.size) % 1000000007L
      round += 1
    }
    println(s"collections=$checksum size=$size")
  }
}
"""

STRINGS_TEMPLATE = """package bench

object Main {
  def main(args: Array[String]): Unit = {
    val rounds = if (args.length > 0) args(0).toInt else 20
    val builder = new StringBuilder
    var round = 0
    var checksum = 0L
    while (round < rounds) {
      builder.clear()
      var index = 0
      while (index < 50000) {
        builder.append(f"item-$index%06d-round-$round%03d;")
        index += 1
      }
      val rendered = builder.toString
      checksum = (checksum + rendered.length + rendered.count(_ == ';')) % 1000000007L
      round += 1
    }
    println(s"strings=$checksum rounds=$rounds")
  }
}
"""

WORKLOADS = {
    "arith": ARITH_TEMPLATE,
    "collections": COLLECTIONS_TEMPLATE,
    "strings": STRINGS_TEMPLATE,
}


def write_compile_corpus(output: Path, classes: int) -> None:
    source_dir = output / "src" / "bench"
    source_dir.mkdir(parents=True, exist_ok=True)
    for index in range(1, classes + 1):
        (source_dir / f"Class{index:04d}.scala").write_text(
            CLASS_TEMPLATE.format(index=index), encoding="utf-8"
        )
    instantiations = "\n".join(
        INSTANTIATION_TEMPLATE.format(i=index) for index in range(1, classes + 1)
    )
    (source_dir / "Main.scala").write_text(
        MAIN_TEMPLATE.format(instantiations=instantiations), encoding="utf-8"
    )


def write_workload_corpus(output: Path, workload: str) -> None:
    source_dir = output / "src" / "bench"
    source_dir.mkdir(parents=True, exist_ok=True)
    (source_dir / "Main.scala").write_text(WORKLOADS[workload], encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="mode", required=True)
    compile_parser = subparsers.add_parser("compile")
    compile_parser.add_argument("--output", required=True, type=Path)
    compile_parser.add_argument("--classes", required=True, type=int)
    workload_parser = subparsers.add_parser("workload")
    workload_parser.add_argument("--output", required=True, type=Path)
    workload_parser.add_argument("--workload", required=True, choices=sorted(WORKLOADS))
    args = parser.parse_args()
    if getattr(args, "classes", 0) is not None and getattr(args, "classes", 1) <= 0:
        parser.error("--classes must be positive")
    return args


def main() -> int:
    args = parse_args()
    if args.mode == "compile":
        write_compile_corpus(args.output, args.classes)
    else:
        write_workload_corpus(args.output, args.workload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

