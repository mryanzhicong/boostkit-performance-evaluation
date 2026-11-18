#!/usr/bin/env python3
"""Static checks for the fbthrift RPC case layout."""
from __future__ import annotations

import re
import sys
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        FAILURES.append(message)


def main() -> int:
    case_yaml = (CASE / "case.yaml").read_text(encoding="utf-8")
    check("name: fbthrift" in case_yaml, "case.yaml must register the fbthrift case name")
    check('"2022.11.14.00"' in case_yaml, "case.yaml must pin the 2022.11.14.00 stack")
    for function in ("build_fbthrift", "start_fbthrift_runtime", "run_fbthrift_benchmarks", "stop_fbthrift_runtime"):
        check(f"function: {function}" in case_yaml, f"case.yaml must reference {function}")
        found = any(function in path.read_text(encoding="utf-8") for path in (CASE / "scripts").rglob("*.sh"))
        check(found, f"{function} is not defined in the scripts")
    common = (CASE / "scripts" / "common.sh").read_text(encoding="utf-8")
    for marker in ("# >>> container-runtime:begin", "# >>> container-runtime:end"):
        check(marker in common, f"common.sh is missing the {marker} marker")
    check("FBTHRIFT_MATRIX" in common, "common.sh must expose the matrix selector")
    check("THRIFT_ENABLE_ARM_SVE2" in (CASE / "scripts" / "build_acclib_stack.sh").read_text(encoding="utf-8"),
          "the build script must record the wiki SVE2 flag")
    matrix = (CASE / "scripts" / "results" / "run_matrix.py").read_text(encoding="utf-8")
    check("--use_io_uring=false" in matrix, "the matrix driver must pin io_uring off for upstream sources")
    check("165" in (CASE / "README.md").read_text(encoding="utf-8") if (CASE / "README.md").is_file() else False,
          "README must document the 165-cell full matrix")
    if FAILURES:
        print("FAILED:")
        for failure in FAILURES:
            print(f"  - {failure}")
        return 1
    print("ok: fbthrift case layout is consistent")
    return 0


def test_case_layout() -> None:
    assert main() == 0, FAILURES


if __name__ == "__main__":
    sys.exit(main())
