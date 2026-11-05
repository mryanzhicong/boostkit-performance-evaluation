#!/usr/bin/env python3
"""Unit tests for the Go CRC32 benchmark parser (official vs optimized)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parent.parent
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
REPS = 5


def raw_output(samples: dict[tuple[int, int | None], list[float]]) -> str:
    lines = []
    for (size, align), values in samples.items():
        for value in values:
            name = f"BenchmarkCRC32/poly=Castagnoli/size={size}kB"
            if align is not None:
                name += f"/align={align}"
            lines.append(f"{name}\t1000000\t{value:.2f} ns/op\t43000.00 MB/s")
    lines.extend(["PASS", "ok  \thash/crc32\t3.512s"])
    return "\n".join(lines) + "\n"


def benchstat_output(samples: dict[tuple[int, int | None], list[float]]) -> str:
    lines = ["goos: linux", "goarch: amd64", "pkg: hash/crc32"]
    for (size, align), values in samples.items():
        name = f"BenchmarkCRC32/poly=Castagnoli/size={size}kB"
        if align is not None:
            name += f"/align={align}"
        lines.append(f"{name}-8\t{values[0]:.2f}n\t± 1%\t{values[0] * 0.98:.2f}n\t± 1%\t-2.00% (p=0.016 n=5)")
    return "\n".join(lines) + "\n"


def run_parser(
    tmp_path: Path,
    official: str,
    optimized: str,
    reps: int = REPS,
    variant: str = "base",
    benchstat: str | None = None,
) -> subprocess.CompletedProcess:
    official_file = tmp_path / "benchmark_official.txt"
    optimized_file = tmp_path / "benchmark_optimized.txt"
    benchstat_file = tmp_path / "benchstat.txt"
    official_file.write_text(official, encoding="utf-8")
    optimized_file.write_text(optimized, encoding="utf-8")
    benchstat_file.write_text(
        benchstat if benchstat is not None else benchstat_output(valid_samples()), encoding="utf-8"
    )
    output = tmp_path / "benchmark_go.json"
    runs = tmp_path / "runs"
    return subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--official-raw", str(official_file),
            "--optimized-raw", str(optimized_file),
            "--benchstat", str(benchstat_file),
            "--output", str(output),
            "--runs", str(runs),
            "--reps", str(reps),
            "--software-version", "1.23.0",
            "--official-version", "1.23.0",
            "--optimized-version", "1.24.6",
            "--source-commit", "d222f2d94fcc375acd48d9752f1d89d0dc29770a",
            "--arch", "x86_64",
            "--run-id", "test-run",
            "--variant", variant,
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def valid_samples() -> dict[tuple[int, int | None], list[float]]:
    return {
        (4, 0): [120.0, 121.0, 119.0, 122.0, 120.0],
        (4, 1): [118.0, 117.0, 119.0, 118.5, 117.5],
        (32, 0): [430.0, 432.0, 428.0, 431.0, 429.0],
        (32, 1): [428.0, 427.0, 429.0, 428.5, 427.5],
    }


def optimized_samples() -> dict[tuple[int, int | None], list[float]]:
    return {
        (4, 0): [60.0, 61.0, 59.0, 62.0, 60.5],
        (4, 1): [58.0, 57.0, 59.0, 58.5, 57.5],
        (32, 0): [215.0, 216.0, 214.0, 215.5, 214.5],
        (32, 1): [214.0, 213.0, 215.0, 214.5, 213.5],
    }


def test_parser_writes_both_toolchains_and_speedup(tmp_path: Path) -> None:
    completed = run_parser(
        tmp_path, raw_output(valid_samples()), raw_output(optimized_samples())
    )
    assert completed.returncode == 0, completed.stderr
    payload = json.loads((tmp_path / "benchmark_go.json").read_text(encoding="utf-8"))
    assert payload["software"] == "go"
    assert payload["variant"] == "base"
    assert payload["toolchains"]["official"]["version"] == "1.23.0"
    assert payload["toolchains"]["optimized"]["version"] == "1.24.6"
    assert payload["architecture"] == "x86_64"
    results = payload["results"]
    assert results["official_crc32_castagnoli_4kb_align0"]["value"] == pytest.approx(120.0)
    assert results["optimized_crc32_castagnoli_4kb_align0"]["value"] == pytest.approx(60.5)
    assert results["speedup_crc32_castagnoli_4kb_align0"]["value"] == pytest.approx(120.0 / 60.5)
    assert results["speedup_crc32_castagnoli_4kb_align0"]["direction"] == "higher_is_better"
    assert results["speedup_crc32_castagnoli_4kb_align0"]["unit"] == "x"
    for name, item in results.items():
        if name.startswith(("official_", "optimized_")):
            assert item["unit"] == "ns/op"
            assert item["direction"] == "lower_is_better"
            assert item["samples"] == REPS
    for toolchain in ("official", "optimized"):
        scenario_dir = tmp_path / "runs" / f"crc32-castagnoli-{toolchain}"
        for index in range(1, REPS + 1):
            record = json.loads(
                (scenario_dir / f"rep{index}.json").read_text(encoding="utf-8")
            )
            assert record["rep"] == index
            assert record["toolchain"] == toolchain
            assert set(record["samples"]) == {
                "4kB/align=0",
                "4kB/align=1",
                "32kB/align=0",
                "32kB/align=1",
            }
            assert (scenario_dir / f"rep{index}.log").is_file()


def test_parser_accepts_legacy_two_benchmark_set(tmp_path: Path) -> None:
    official = {(size, None): valid_samples()[(size, 0)] for size in (4, 32)}
    optimized = {(size, None): optimized_samples()[(size, 0)] for size in (4, 32)}
    completed = run_parser(tmp_path, raw_output(official), raw_output(optimized))
    assert completed.returncode == 0, completed.stderr
    payload = json.loads((tmp_path / "benchmark_go.json").read_text(encoding="utf-8"))
    assert set(payload["results"]) == {
        "official_crc32_castagnoli_4kb",
        "official_crc32_castagnoli_32kb",
        "optimized_crc32_castagnoli_4kb",
        "optimized_crc32_castagnoli_32kb",
        "speedup_crc32_castagnoli_4kb",
        "speedup_crc32_castagnoli_32kb",
    }


def test_parser_rejects_missing_samples(tmp_path: Path) -> None:
    samples = valid_samples()
    samples[(32, 0)] = samples[(32, 0)][:4]
    completed = run_parser(tmp_path, raw_output(samples), raw_output(optimized_samples()))
    assert completed.returncode != 0
    assert "official: expected 5 ns/op samples for 32kB/align=0" in completed.stderr


def test_parser_rejects_incomplete_scenario_set(tmp_path: Path) -> None:
    samples = valid_samples()
    del samples[(4, 1)]
    completed = run_parser(tmp_path, raw_output(samples), raw_output(optimized_samples()))
    assert completed.returncode != 0
    assert "does not contain one complete CRC32 Castagnoli set" in completed.stderr


def test_parser_rejects_non_positive_values(tmp_path: Path) -> None:
    samples = valid_samples()
    samples[(4, 0)][2] = 0.0
    completed = run_parser(tmp_path, raw_output(samples), raw_output(optimized_samples()))
    assert completed.returncode != 0
    assert "non-positive" in completed.stderr


def test_parser_rejects_unknown_benchmark(tmp_path: Path) -> None:
    raw = raw_output(valid_samples()) + (
        "BenchmarkCRC32/poly=IEEE/size=4kB-1\t1000000\t100.00 ns/op\n"
    )
    completed = run_parser(tmp_path, raw, raw_output(optimized_samples()))
    assert completed.returncode != 0
    assert "unexpected benchmark line" in completed.stderr


def test_parser_rejects_unknown_benchmark_in_optimized_output(tmp_path: Path) -> None:
    raw = raw_output(optimized_samples()) + (
        "BenchmarkCRC32/poly=IEEE/size=32kB-1\t1000000\t100.00 ns/op\n"
    )
    completed = run_parser(tmp_path, raw_output(valid_samples()), raw)
    assert completed.returncode != 0
    assert "optimized: unexpected benchmark line" in completed.stderr


def test_parser_requires_five_repetitions(tmp_path: Path) -> None:
    samples = {key: values[:4] for key, values in valid_samples().items()}
    completed = run_parser(
        tmp_path,
        raw_output(samples),
        raw_output({key: values[:4] for key, values in optimized_samples().items()}),
        reps=4,
    )
    assert completed.returncode != 0
    assert "at least 5 measured repetitions" in completed.stderr


def test_parser_rejects_empty_benchstat_report(tmp_path: Path) -> None:
    completed = run_parser(
        tmp_path,
        raw_output(valid_samples()),
        raw_output(optimized_samples()),
        benchstat="",
    )
    assert completed.returncode != 0
    assert "benchstat report is empty" in completed.stderr


def test_parser_rejects_mismatched_scenario_sets(tmp_path: Path) -> None:
    official = valid_samples()
    optimized = {(size, None): optimized_samples()[(size, 0)] for size in (4, 32)}
    completed = run_parser(tmp_path, raw_output(official), raw_output(optimized))
    assert completed.returncode != 0
    assert "different benchmark sets" in completed.stderr
