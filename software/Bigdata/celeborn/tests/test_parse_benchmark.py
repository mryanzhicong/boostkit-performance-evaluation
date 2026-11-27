#!/usr/bin/env python3
"""Contract tests for the strict Celeborn result parser."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
STATEMENTS = ["query1.sql", "query2.sql", "query3.sql"]


def write_manifest(path: Path) -> Path:
    payload = {"scale_factor": 1.0, "tables": [], "statements": [{"name": name, "sha256": "0" * 64} for name in STATEMENTS]}
    path.write_text(json.dumps(payload), encoding="utf-8")
    return path


def write_sample(results_dir: Path, sample: int, durations: list[float]) -> None:
    sample_dir = results_dir / "runs" / f"sample{sample}"
    sample_dir.mkdir(parents=True, exist_ok=True)
    lines = [json.dumps({"record": "application", "sample": sample, "application_id": f"app-{sample}"})]
    for name, seconds in zip(STATEMENTS, durations):
        lines.append(json.dumps({"record": "statement", "name": name, "seconds": seconds, "rows": 1}))
    lines.append(json.dumps({"record": "summary", "sample": sample, "seconds": sum(durations)}))
    (sample_dir / "queries.jsonl").write_text("\n".join(lines) + "\n", encoding="utf-8")


def run_parser(tmp_path: Path, samples: int, shuffle_bytes: int | None = None) -> subprocess.CompletedProcess:
    manifest = write_manifest(tmp_path / "manifest.json")
    command = [
        sys.executable,
        str(PARSER),
        "--results-dir", str(tmp_path),
        "--manifest", str(manifest),
        "--samples", str(samples),
        "--scale-factor", "1",
        "--output", str(tmp_path / "benchmark.json"),
    ]
    if shuffle_bytes is not None:
        command += ["--shuffle-bytes", str(shuffle_bytes)]
    return subprocess.run(command, capture_output=True, text=True)


def build_samples(tmp_path: Path, samples: int = 6) -> None:
    for sample in range(1, samples + 1):
        write_sample(tmp_path, sample, [1.0 + sample, 2.0 + sample, 3.0 + sample])


def test_parser_reports_median_metrics(tmp_path: Path) -> None:
    build_samples(tmp_path)
    result = run_parser(tmp_path, samples=6, shuffle_bytes=1024 * 1024 * 60)
    assert result.returncode == 0, result.stderr
    payload = json.loads((tmp_path / "benchmark.json").read_text(encoding="utf-8"))
    metrics = payload["results"]
    assert payload["samples"] == {"total": 6, "warmup": 1, "measured": 5}
    # measured samples are 2..6; query1 durations 3,4,5,6,7 -> median 5
    assert metrics["celeborn.tpcds.query1.median"]["value"] == 5.0
    assert metrics["celeborn.tpcds.statements.executed"]["value"] == 3
    assert metrics["celeborn.shuffle.bytes.written"]["value"] == 1024 * 1024 * 60
    # 5 aggregate metrics + 2 shuffle metrics + 3 statement metrics
    assert len(payload["results"]) == 10
    for name, metric in payload["results"].items():
        assert name.startswith("celeborn.")
        assert metric["unit"] and metric["group"]
        assert metric["direction"] in {"higher_is_better", "lower_is_better", "neutral"}


def test_parser_rejects_missing_sample(tmp_path: Path) -> None:
    build_samples(tmp_path, samples=5)
    result = run_parser(tmp_path, samples=6)
    assert result.returncode == 2
    assert "missing sample file" in result.stderr


def test_parser_rejects_missing_statement(tmp_path: Path) -> None:
    build_samples(tmp_path)
    sample_file = tmp_path / "runs" / "sample3" / "queries.jsonl"
    kept = [line for line in sample_file.read_text(encoding="utf-8").splitlines() if '"query2.sql"' not in line]
    sample_file.write_text("\n".join(kept) + "\n", encoding="utf-8")
    result = run_parser(tmp_path, samples=6)
    assert result.returncode == 2
    assert "expected 3 statement results" in result.stderr


def test_parser_rejects_duplicate_statement(tmp_path: Path) -> None:
    build_samples(tmp_path)
    sample_file = tmp_path / "runs" / "sample4" / "queries.jsonl"
    lines = sample_file.read_text(encoding="utf-8").splitlines()
    lines.insert(1, json.dumps({"record": "statement", "name": "query1.sql", "seconds": 1.0, "rows": 1}))
    sample_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
    result = run_parser(tmp_path, samples=6)
    assert result.returncode == 2
    assert "expected 3 statement results" in result.stderr or "duplicated" in result.stderr


@pytest.mark.parametrize("bad_value", [0.0, -1.5])
def test_parser_rejects_non_positive_duration(tmp_path: Path, bad_value: float) -> None:
    build_samples(tmp_path)
    write_sample(tmp_path, 5, [1.0, bad_value, 3.0])
    result = run_parser(tmp_path, samples=6)
    assert result.returncode == 2
    assert "invalid duration" in result.stderr


def test_parser_requires_five_measured_samples(tmp_path: Path) -> None:
    build_samples(tmp_path, samples=5)
    result = run_parser(tmp_path, samples=5)
    assert result.returncode == 2
    assert "at least 5 measured samples" in result.stderr


def test_parser_rejects_zero_shuffle_bytes(tmp_path: Path) -> None:
    build_samples(tmp_path)
    result = run_parser(tmp_path, samples=6, shuffle_bytes=0)
    assert result.returncode == 2
    assert "no shuffle bytes" in result.stderr
