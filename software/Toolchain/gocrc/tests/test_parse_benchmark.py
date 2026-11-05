#!/usr/bin/env python3
"""Unit tests for the gocrc 1.24.6 CRC32 benchmark parser (single measured toolchain)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parent.parent
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
REPS = 6


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
        name = f"CRC32/poly=Castagnoli/size={size}kB"
        if align is not None:
            name += f"/align={align}"
        lines.append(f"{name}\t{values[0]:.2f}n ± 1%")
    return "\n".join(lines) + "\n"


def run_parser(
    tmp_path: Path,
    raw: str,
    reps: int = REPS,
    variant: str = "base",
    benchstat: str | None = None,
    measured_version: str = "1.24.6",
    software_version: str = "1.24.6",
) -> subprocess.CompletedProcess:
    raw_file = tmp_path / "benchmark_go1.24.6.txt"
    benchstat_file = tmp_path / "benchstat.txt"
    raw_file.write_text(raw, encoding="utf-8")
    benchstat_file.write_text(
        benchstat if benchstat is not None else benchstat_output(valid_samples()), encoding="utf-8"
    )
    output = tmp_path / "benchmark_go.json"
    runs = tmp_path / "runs"
    return subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--raw", str(raw_file),
            "--benchstat", str(benchstat_file),
            "--output", str(output),
            "--runs", str(runs),
            "--reps", str(reps),
            "--software-version", software_version,
            "--measured-version", measured_version,
            "--bootstrap-version", "1.23.0",
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
        (4, 0): [150.0, 151.0, 149.0, 152.0, 150.0, 150.5],
        (4, 1): [148.0, 147.0, 149.0, 148.5, 147.5, 148.2],
        (32, 0): [1130.0, 1132.0, 1128.0, 1131.0, 1129.0, 1130.0],
        (32, 1): [1150.0, 1148.0, 1152.0, 1149.0, 1151.0, 1150.0],
    }


def test_parser_writes_measured_results_and_runs(tmp_path: Path) -> None:
    completed = run_parser(tmp_path, raw_output(valid_samples()))
    assert completed.returncode == 0, completed.stderr
    payload = json.loads((tmp_path / "benchmark_go.json").read_text(encoding="utf-8"))
    assert payload["software"] == "gocrc"
    assert payload["version"] == "1.24.6"
    assert payload["variant"] == "base"
    assert payload["architecture"] == "x86_64"
    assert payload["toolchains"]["bootstrap"]["version"] == "1.23.0"
    assert payload["toolchains"]["bootstrap"]["measured"] is False
    assert payload["toolchains"]["measured"]["version"] == "1.24.6"
    assert payload["toolchains"]["measured"]["goroot"] == "/home/local/golang"
    assert payload["toolchains"]["measured"]["source_commit"].startswith("d222f2d")
    results = payload["results"]
    assert set(results) == {
        "crc32_castagnoli_4kb_align0",
        "crc32_castagnoli_4kb_align1",
        "crc32_castagnoli_32kb_align0",
        "crc32_castagnoli_32kb_align1",
    }
    assert results["crc32_castagnoli_4kb_align0"]["value"] == pytest.approx(150.25)
    assert results["crc32_castagnoli_32kb_align1"]["value"] == pytest.approx(1150.0)
    for item in results.values():
        assert item["unit"] == "ns/op"
        assert item["direction"] == "lower_is_better"
        assert item["samples"] == REPS
        assert len(item["sample_values"]) == REPS
    scenario_dir = tmp_path / "runs" / "crc32-castagnoli"
    for index in range(1, REPS + 1):
        record = json.loads((scenario_dir / f"rep{index}.json").read_text(encoding="utf-8"))
        assert record["rep"] == index
        assert record["toolchain"] == "measured"
        assert set(record["samples"]) == {
            "4kB/align=0",
            "4kB/align=1",
            "32kB/align=0",
            "32kB/align=1",
        }
        assert (scenario_dir / f"rep{index}.log").is_file()


def test_parser_accepts_legacy_two_benchmark_set(tmp_path: Path) -> None:
    samples = {(size, None): valid_samples()[(size, 0)] for size in (4, 32)}
    completed = run_parser(tmp_path, raw_output(samples))
    assert completed.returncode == 0, completed.stderr
    payload = json.loads((tmp_path / "benchmark_go.json").read_text(encoding="utf-8"))
    assert set(payload["results"]) == {
        "crc32_castagnoli_4kb",
        "crc32_castagnoli_32kb",
    }


def test_parser_rejects_missing_samples(tmp_path: Path) -> None:
    samples = valid_samples()
    samples[(32, 0)] = samples[(32, 0)][:-1]
    completed = run_parser(tmp_path, raw_output(samples))
    assert completed.returncode != 0
    assert f"expected {REPS} ns/op samples for 32kB/align=0" in completed.stderr


def test_parser_rejects_incomplete_scenario_set(tmp_path: Path) -> None:
    samples = valid_samples()
    del samples[(4, 1)]
    completed = run_parser(tmp_path, raw_output(samples))
    assert completed.returncode != 0
    assert "does not contain one complete CRC32 Castagnoli set" in completed.stderr


def test_parser_rejects_non_positive_values(tmp_path: Path) -> None:
    samples = valid_samples()
    samples[(4, 0)][2] = 0.0
    completed = run_parser(tmp_path, raw_output(samples))
    assert completed.returncode != 0
    assert "non-positive" in completed.stderr


def test_parser_rejects_unknown_benchmark(tmp_path: Path) -> None:
    raw = raw_output(valid_samples()) + (
        "BenchmarkCRC32/poly=IEEE/size=4kB-1\t1000000\t100.00 ns/op\n"
    )
    completed = run_parser(tmp_path, raw)
    assert completed.returncode != 0
    assert "unexpected benchmark line" in completed.stderr


def test_parser_requires_five_repetitions(tmp_path: Path) -> None:
    samples = {key: values[:4] for key, values in valid_samples().items()}
    completed = run_parser(tmp_path, raw_output(samples), reps=4)
    assert completed.returncode != 0
    assert "at least 5 measured repetitions" in completed.stderr


def test_parser_rejects_empty_benchstat_report(tmp_path: Path) -> None:
    completed = run_parser(tmp_path, raw_output(valid_samples()), benchstat="")
    assert completed.returncode != 0
    assert "benchstat report is empty" in completed.stderr


def test_parser_rejects_version_mismatch(tmp_path: Path) -> None:
    completed = run_parser(
        tmp_path, raw_output(valid_samples()), measured_version="1.23.0"
    )
    assert completed.returncode != 0
    assert "must match" in completed.stderr


def test_parser_rejects_invalid_variant(tmp_path: Path) -> None:
    completed = run_parser(tmp_path, raw_output(valid_samples()), variant="nightly")
    assert completed.returncode != 0
    assert "invalid variant" in completed.stderr
