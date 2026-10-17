#!/usr/bin/env python3
"""Run the official Eigen perf_monitoring matrix and write structured results."""

from __future__ import annotations

import json
import math
import os
import statistics
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# The official runall.sh workload set with the official settings ladder
# each workload is driven by, and the number of columns each ladder row
# carries (gemm family: m n k; gemv family: m n).  lazy_gemm is
# excluded: its "#include \"../../BenchTimer.h\"" resolves to the
# repository root, where no BenchTimer.h exists, so the official run.sh
# recipe cannot compile it from the 5.0.1 tree.
WORKLOADS: tuple[tuple[str, str, int], ...] = (
    ("gemm", "gemm_settings.txt", 3),
    ("gemv", "gemv_settings.txt", 2),
    ("gemvt", "gemv_settings.txt", 2),
    ("trmv_up", "gemv_square_settings.txt", 2),
    ("trmv_lo", "gemv_square_settings.txt", 2),
    ("trmv_upt", "gemv_square_settings.txt", 2),
    ("trmv_lot", "gemv_square_settings.txt", 2),
    ("llt", "gemm_square_settings.txt", 3),
)

# The official run.sh scalar ladder: binary prefix, scalar type used on
# the compiler command line, and the display name used in metric names.
SCALARS: tuple[tuple[str, str, str], ...] = (
    ("s", "float", "float"),
    ("d", "double", "double"),
    ("c", "std::complex<double>", "complex"),
)

# The official run.sh compile recipe (fixed part).
COMPILE_RECIPE = "-O3 -DNDEBUG -march=native"

RUN_TIMEOUT_SECONDS = 3600


def load_ladder(settings: Path, columns: int) -> list[list[int]]:
    """Return the official settings rows, validating the column count."""
    rows: list[list[int]] = []
    for line in settings.read_text(encoding="utf-8").splitlines():
        parts = line.split()
        if not parts or parts[0].startswith("#"):
            continue
        if len(parts) != columns:
            raise RuntimeError(
                f"{settings.name} row {line!r} has {len(parts)} columns, expected {columns}"
            )
        rows.append([int(value) for value in parts])
    if not rows:
        raise RuntimeError(f"{settings.name} contains no settings rows")
    return rows


def parse_gflops(output: str) -> list[float]:
    """Parse the one-line space-separated GFLOPS output of a benchmark."""
    tokens = output.split()
    if not tokens:
        raise RuntimeError("the benchmark printed no GFLOPS values")
    values = [float(token) for token in tokens]
    for value in values:
        if not math.isfinite(value) or value <= 0:
            raise RuntimeError(f"the benchmark reported a non-positive GFLOPS value: {value}")
    return values


def run_case(
    binary: Path,
    settings: Path,
    columns: int,
) -> dict[str, Any]:
    rows = load_ladder(settings, columns)
    command = [str(binary), str(settings)]
    print(f"[perf_monitoring] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=RUN_TIMEOUT_SECONDS,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"{binary.name} exited with code {completed.returncode}")
    values = parse_gflops(completed.stdout)
    if len(values) != len(rows):
        raise RuntimeError(
            f"{binary.name} reported {len(values)} GFLOPS values for "
            f"{len(rows)} settings rows"
        )
    ladder = [
        {"size": row, "gflops": value}
        for row, value in zip(rows, values)
    ]
    return {
        "ladder": ladder,
        "gflops_median": statistics.median(values),
        "gflops_peak": max(values),
        "raw_output": completed.stdout,
    }


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: run_perf_monitoring.py BIN_DIR PERF_MONITORING_DIR OUTPUT",
            file=sys.stderr,
        )
        return 1
    bin_dir, perf_monitoring_dir, output = map(Path, sys.argv[1:4])

    results: dict[str, dict[str, Any]] = {}
    for workload, settings_file, columns in WORKLOADS:
        settings = perf_monitoring_dir / settings_file
        if not settings.is_file():
            raise RuntimeError(f"official settings file is unavailable: {settings}")
        for prefix, scalar, display in SCALARS:
            binary = bin_dir / f"{prefix}_{workload}"
            if not binary.is_file() or not os.access(binary, os.X_OK):
                raise RuntimeError(f"official benchmark binary is unavailable: {binary}")
            case = run_case(binary, settings, columns)
            results[f"{workload}/{display}"] = {
                "workload": workload,
                "scalar": scalar,
                "scalar_display": display,
                "settings_file": settings_file,
                "binary": binary.name,
                "command_display": workload,
                **case,
            }
            print(
                f"[perf_monitoring] {workload}/{display}: "
                f"median {case['gflops_median']:.6g} GFLOPS, "
                f"peak {case['gflops_peak']:.6g} GFLOPS",
                flush=True,
            )

    payload = {
        "benchmark": "eigen_perf_monitoring",
        "software": "eigen",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "source_repository": os.environ.get("EIGEN_SOURCE_URL", ""),
            "source_tag": os.environ["SOFTWARE_VERSION"],
            "compiler": os.environ.get("EIGEN_CXX", "g++"),
            "compile_recipe": COMPILE_RECIPE,
            "cxx_flags": os.environ.get("EIGEN_CXX_FLAGS", ""),
            "timer": "official bench/BenchTimer.h (best of tries)",
            "metric": "GFLOPS over the official settings ladder",
            "workloads": [
                {"workload": workload, "settings_file": settings_file}
                for workload, settings_file, _ in WORKLOADS
            ],
            "scalars": [
                {"prefix": prefix, "scalar": scalar, "display": display}
                for prefix, scalar, display in SCALARS
            ],
        },
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
