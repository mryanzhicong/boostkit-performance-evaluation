#!/usr/bin/env python3
"""Run the official OpenCV perf binaries and write structured results.

The OpenCV perf framework (modules/ts, GTest-driven) prints one
``[ PERFSTAT ]`` summary line per completed benchmark:

    [ RUN      ] Size_MatType_abs.abs/8, where GetParam() = (1920x1080, 8SC1)
    [ PERFSTAT ]    (samples=100   mean=0.56   median=0.55   min=0.53   stddev=0.02 (4.0%))
    [       OK ] Size_MatType_abs.abs/8 (61 ms)

All statistics are in milliseconds (ticks converted with
``* 1000.0f / tickFrequency`` in modules/ts/src/ts_perf.cpp).  The
collected metric is the official median; mean/min/stddev are kept for
reference.

The full perf matrix (4024 core + 5256 imgproc fixtures at 5.0.0) is
far beyond a deliverable benchmark size, so a deterministic slice is
selected from the official ``--gtest_list_tests`` metadata at run
time — every fixture family is represented, and inside a family the
largest official size (1920x1080, falling back to 1280x720, 640x480,
then the first fixture) is kept with at most 8 parameter combinations
per family.  OpenCL-only (OCL_) fixtures and DISABLED ones are
excluded (this is a pure-CPU build).  The slice is rebuilt from the
official listing for every run, so it never depends on hard-coded
fixture indices.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

RUN_TIMEOUT_SECONDS = 7200

# [ RUN      ] Size_MatType_abs.abs/8, where GetParam() = (1920x1080, 8SC1)
RUN_LINE = re.compile(r"^\[ RUN      \] (.+?)(?:\s*,\s*where\s+GetParam\(\).*)?$")
PERFSTAT_LINE = re.compile(
    r"^\[ PERFSTAT \]\s+\(samples=(\d+)\s+mean=([\d.]+)\s+median=([\d.]+)"
    r"\s+min=([\d.]+)\s+stddev=([\d.]+)"
)
SUMMARY_LINE = re.compile(
    r"^\[==========\] (\d+) tests? from .* ran\.", re.MULTILINE
)
PASSED_LINE = re.compile(r"^\[  PASSED  \] (\d+) tests?\.", re.MULTILINE)

LIST_SUITE_LINE = re.compile(r"^(\S+)\.$")
LIST_TEST_LINE = re.compile(r"^  (\S+)\s*(?:#\s*GetParam\(\)\s*=\s*(.*))?$")

# Slice rule: preferred fixture sizes in order, then the cap per family.
PREFERRED_SIZES: tuple[str, ...] = ("1920x1080", "1280x720", "640x480")
MAX_TESTS_PER_SUITE = 8
# A family is skipped entirely when fewer than this share of its
# selected fixtures produced PERFSTAT lines (default 0.8).
MIN_PERFSTAT_RATIO = 0.8


def list_fixtures(binary: Path) -> list[dict[str, Any]]:
    """Parse the official --gtest_list_tests output."""
    completed = subprocess.run(
        [str(binary), "--gtest_list_tests"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=600,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError(
            f"--gtest_list_tests failed for {binary} (exit {completed.returncode})"
        )
    suites: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    for line in completed.stdout.splitlines():
        suite_match = LIST_SUITE_LINE.match(line)
        if suite_match:
            current = {"suite": suite_match.group(1), "tests": []}
            suites.append(current)
            continue
        test_match = LIST_TEST_LINE.match(line)
        if test_match and current is not None:
            current["tests"].append({
                "name": test_match.group(1),
                "param": (test_match.group(2) or "").strip(),
            })
    if not suites:
        raise RuntimeError(f"{binary} listed no perf fixtures")
    return suites


def select_fixtures(suites: list[dict[str, Any]]) -> list[str]:
    """Deterministic official-metadata-driven slice (see module docstring)."""
    selected: list[str] = []
    for entry in suites:
        suite = entry["suite"]
        if suite.startswith("OCL_") or "DISABLED" in suite:
            continue
        tests = [t for t in entry["tests"] if "DISABLED" not in t["name"]]
        if not tests:
            continue
        picked: list[dict[str, Any]] = []
        for size in PREFERRED_SIZES:
            picked = [t for t in tests if size in t["param"]]
            if picked:
                break
        if not picked:
            picked = tests[:1]
        for test in picked[:MAX_TESTS_PER_SUITE]:
            selected.append(f"{suite}.{test['name']}")
    if not selected:
        raise RuntimeError("fixture selection produced an empty filter")
    return selected


def run_module(binary: Path, module: str) -> dict[str, Any]:
    """Select the slice for one opencv_perf_<module> binary, run it and
    parse its PERFSTAT lines."""
    suites = list_fixtures(binary)
    selected = select_fixtures(suites)
    filter_expression = ":".join(selected)
    print(
        f"[opencv-perf] running {binary} with {len(selected)} selected fixtures",
        flush=True,
    )
    completed = subprocess.run(
        [str(binary), f"--gtest_filter={filter_expression}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=RUN_TIMEOUT_SECONDS,
        check=False,
    )
    output = completed.stdout
    # Feed the full log forward for traceability.
    print(output, end="", flush=True)

    summary_matches = SUMMARY_LINE.findall(output)
    if not summary_matches:
        raise RuntimeError(
            f"module {module} produced no GTest summary line (binary crashed?)"
        )
    ran_total = int(summary_matches[-1])
    passed_total = sum(int(m) for m in PASSED_LINE.findall(output))

    measurements: list[dict[str, Any]] = []
    current: str | None = None
    for line in output.splitlines():
        run_match = RUN_LINE.match(line)
        if run_match:
            current = run_match.group(1).strip()
            continue
        perf_match = PERFSTAT_LINE.match(line)
        if perf_match and current:
            samples, mean, median, minimum, stddev = perf_match.groups()
            measurements.append({
                "module": module,
                "test": current,
                "samples": int(samples),
                "mean_ms": float(mean),
                "median_ms": float(median),
                "min_ms": float(minimum),
                "stddev_ms": float(stddev),
            })
            current = None
    if not measurements:
        raise RuntimeError(f"module {module} produced no PERFSTAT results")
    if ran_total != len(selected):
        raise RuntimeError(
            f"module {module} ran {ran_total} fixtures, expected {len(selected)}"
        )
    if len(measurements) < MIN_PERFSTAT_RATIO * len(selected):
        raise RuntimeError(
            f"module {module} produced {len(measurements)} PERFSTAT results "
            f"for {len(selected)} selected fixtures (below "
            f"{MIN_PERFSTAT_RATIO:.0%})"
        )
    print(
        f"[opencv-perf] {module}: {ran_total} fixtures ran, "
        f"{passed_total} passed, {len(measurements)} PERFSTAT results",
        flush=True,
    )
    return {
        "module": module,
        "exit_code": completed.returncode,
        "fixtures_selected": len(selected),
        "fixtures_ran": ran_total,
        "fixtures_passed": passed_total,
        "perfstat_results": len(measurements),
        "measurements": measurements,
    }


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: run_perf_tests.py BIN_DIR MODULES OUTPUT\n"
            "  BIN_DIR   build/bin directory holding opencv_perf_<module>\n"
            "  MODULES   space-separated module list (e.g. 'core imgproc')\n"
            "  OUTPUT    benchmark_opencv_perf.json path",
            file=sys.stderr,
        )
        return 1
    bin_dir = Path(sys.argv[1])
    modules = sys.argv[2].split()
    output = Path(sys.argv[3])
    if not bin_dir.is_dir():
        raise RuntimeError(f"bin directory is unavailable: {bin_dir}")
    if not modules:
        raise RuntimeError("module list is empty")

    binaries: list[tuple[Path, str]] = []
    for module in modules:
        binary = bin_dir / f"opencv_perf_{module}"
        if not binary.is_file():
            raise RuntimeError(f"official perf binary is unavailable: {binary}")
        if not os.access(binary, os.X_OK):
            raise RuntimeError(f"perf binary is not executable: {binary}")
        binaries.append((binary, module))

    module_reports: dict[str, Any] = {}
    results: dict[str, Any] = {}
    for binary, module in binaries:
        report = run_module(binary, module)
        module_reports[module] = {
            key: value
            for key, value in report.items()
            if key != "measurements"
        }
        for measurement in report["measurements"]:
            key = f"{module}/{measurement['test']}"
            if key in results:
                raise RuntimeError(f"duplicate perf test name: {key}")
            results[key] = measurement

    payload = {
        "benchmark": "opencv_perf",
        "software": "opencv",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "source_repository": os.environ.get(
                "OPENCV_SOURCE_URL",
                "https://github.com/opencv/opencv.git",
            ),
            "source_tag": os.environ["SOFTWARE_VERSION"],
            "extra_repository": os.environ.get(
                "OPENCV_EXTRA_SOURCE_URL",
                "https://github.com/opencv/opencv_extra.git",
            ),
            "tool": "official modules/<m>/perf (opencv_perf_<m>, GTest perf framework)",
            "modules": modules,
            "perf_strategy": "default (simple)",
            "perf_time_limit_seconds": 1,
            "fixture_selection": (
                "per fixture family: the largest official size "
                f"({' -> '.join(PREFERRED_SIZES)} fallback to the first "
                f"fixture), capped at {MAX_TESTS_PER_SUITE} combinations "
                "per family; OCL_/DISABLED fixtures excluded"
            ),
            "metric": "PERFSTAT median in ms, lower is better",
        },
        "modules_summary": module_reports,
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[opencv-perf] {len(results)} perf results collected", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
