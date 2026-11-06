#!/usr/bin/env python3
"""Unit tests for the Eigen GEMM parser (strict, no zero padding)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parent.parent
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
REPS = 5
TRIES = 5
REPEATS = 10
MATRIX = [(14, 28, 16), (32, 8, 4)]


def slug(m: int, k: int, n: int) -> str:
    return f"m{m}_k{k}_n{n}"


def write_point(
    runs: Path,
    point: tuple[int, int, int],
    gflops: list[float],
    reps: int = REPS,
    header_ok: bool = True,
    exit_code: int = 0,
    timed_out: bool = False,
) -> None:
    m, k, n = point
    directory = runs / slug(m, k, n)
    directory.mkdir(parents=True, exist_ok=True)
    for index, value in enumerate(gflops[: reps + 1]):
        label = "warmup" if index == 0 else f"rep{index}"
        header = f"Matrix sizes = {m}x{k} * {k}x{n}"
        if not header_ok:
            header = f"Matrix sizes = {m}x{k} * {k}x{n + 1}"
        log = (
            f"# command: /work/probe/gemm_bench -s {m} {n} {k} -t {TRIES} -p {REPEATS}\n"
            f"# started_at: 2026-01-01T00:00:00Z\n"
            "L1 cache size     = 48 KB\n"
            f"{header}\n"
            f"eigen cpu         1.0e-06s  \t{value:.4f} GFLOPS \t(5.0e-06s)\n"
            f"eigen real        1.1e-06s  \t{value * 0.9:.4f} GFLOPS \t(5.5e-06s)\n"
        )
        (directory / f"{label}.log").write_text(log, encoding="utf-8")
        (directory / f"{label}.json").write_text(
            json.dumps(
                {
                    "command": ["/work/probe/gemm_bench", "-s", str(m), str(n), str(k)],
                    "exit_code": exit_code,
                    "timed_out": timed_out,
                    "wall_seconds": 0.01,
                    "max_rss_mib": 12.5,
                }
            )
            + "\n",
            encoding="utf-8",
        )


def run_parser(
    tmp_path: Path,
    points: list[tuple[int, int, int]] | None = None,
    reps: int = REPS,
) -> subprocess.CompletedProcess:
    runs = tmp_path / "runs"
    for point in points if points is not None else MATRIX:
        write_point(runs, point, [10.0 + index for index in range(reps + 1)], reps=reps)
    matrix = ";".join(f"{m},{k},{n}" for m, k, n in (points if points is not None else MATRIX))
    return subprocess.run(
        [
            sys.executable,
            str(PARSER),
            str(runs),
            str(tmp_path / "results.json"),
            "--matrix", matrix,
            "--reps", str(reps),
            "--tries", str(TRIES),
            "--repeats", str(REPEATS),
            "--software-version", "5.0.1",
            "--architecture", "aarch64",
            "--variant", "base",
            "--run-id", "unit-test",
            "--compiler", "c++ (GCC) 12.3.1",
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def test_parser_writes_one_metric_per_matrix_point(tmp_path: Path) -> None:
    completed = run_parser(tmp_path)
    assert completed.returncode == 0, completed.stderr
    payload = json.loads((tmp_path / "results.json").read_text(encoding="utf-8"))
    assert payload["software"] == "eigen"
    assert payload["version"] == "5.0.1"
    assert payload["benchmark"]["matrix_points"] == len(MATRIX)
    results = payload["results"]
    assert set(results) == {"gemm_gflops_m14_k28_n16", "gemm_gflops_m32_k8_n4"}
    for item in results.values():
        assert item["unit"] == "GFLOP/s"
        assert item["direction"] == "higher_is_better"
        assert item["group"] == "gemm"
        assert item["samples"] == REPS
        assert len(item["sample_values"]) == REPS
        assert item["source_field"] == "eigen cpu GFLOPS"
    # median of 11.0,12.0,13.0,14.0,15.0 is 13.0
    assert results["gemm_gflops_m14_k28_n16"]["value"] == pytest.approx(13.0)
    assert results["gemm_gflops_m14_k28_n16"]["matrix"] == {"m": 14, "k": 28, "n": 16}


def test_parser_rejects_missing_repetition(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_point(runs, MATRIX[0], [10.0] * REPS)
    matrix = "14,28,16"
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", matrix, "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "base", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0


def test_parser_rejects_wrong_matrix_header(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_point(runs, MATRIX[0], [10.0] * (REPS + 1), header_ok=False)
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", "14,28,16", "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "base", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0
    assert "Matrix sizes" in completed.stderr


def test_parser_rejects_wrong_matrix_header_content(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_point(runs, MATRIX[0], [10.0] * (REPS + 1), header_ok=False)
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", "14,28,16", "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "base", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0


def test_parser_rejects_non_positive_gflops(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    directory = runs / slug(*MATRIX[0])
    directory.mkdir(parents=True)
    (directory / "warmup.log").write_text(
        f"# command: gemm_bench -s 14 16 28 -t {TRIES} -p {REPEATS}\n"
        "Matrix sizes = 14x28 * 28x16\n"
        "eigen cpu         1.0e-06s  \t10.0 GFLOPS \t(5.0e-06s)\n"
        "eigen real        1.1e-06s  \t9.0 GFLOPS \t(5.5e-06s)\n",
        encoding="utf-8",
    )
    (directory / "warmup.json").write_text(
        json.dumps({"exit_code": 0, "timed_out": False, "wall_seconds": 0.01, "max_rss_mib": 1.0}),
        encoding="utf-8",
    )
    for index in range(1, REPS + 1):
        (directory / f"rep{index}.log").write_text(
            f"# command: gemm_bench -s 14 16 28 -t {TRIES} -p {REPEATS}\n"
            "Matrix sizes = 14x28 * 28x16\n"
            "eigen cpu         1.0e-06s  \t0 GFLOPS \t(5.0e-06s)\n"
            "eigen real        1.1e-06s  \t0 GFLOPS \t(5.5e-06s)\n",
            encoding="utf-8",
        )
        (directory / f"rep{index}.json").write_text(
            json.dumps(
                {"exit_code": 0, "timed_out": False, "wall_seconds": 0.01, "max_rss_mib": 1.0}
            ),
            encoding="utf-8",
        )
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", "14,28,16", "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "base", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0
    assert "GFLOPS" in completed.stderr


def test_parser_rejects_timeout_evidence(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_point(runs, MATRIX[0], [10.0] * (REPS + 1), timed_out=True)
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", "14,28,16", "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "base", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0
    assert "timed out" in completed.stderr


def test_parser_rejects_duplicate_matrix_points(tmp_path: Path) -> None:
    completed = run_parser(tmp_path, points=[MATRIX[0], MATRIX[0]])
    assert completed.returncode != 0
    assert "duplicate matrix point" in completed.stderr


def test_parser_rejects_missing_matrix_directory(tmp_path: Path) -> None:
    completed = run_parser(tmp_path, points=[])
    assert completed.returncode != 0
    assert "matrix" in completed.stderr


def test_parser_rejects_invalid_variant(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    write_point(runs, MATRIX[0], [10.0] * (REPS + 1))
    completed = subprocess.run(
        [
            sys.executable, str(PARSER), str(runs), str(tmp_path / "results.json"),
            "--matrix", "14,28,16", "--reps", str(REPS), "--tries", str(TRIES),
            "--repeats", str(REPEATS), "--software-version", "5.0.1",
            "--architecture", "aarch64", "--variant", "nightly", "--run-id", "unit-test",
        ],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode != 0
    assert "invalid variant" in completed.stderr
