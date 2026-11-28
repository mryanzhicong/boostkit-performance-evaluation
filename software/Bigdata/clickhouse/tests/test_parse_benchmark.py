"""Ensure ClickHouse query_log rows become a complete TPC-H metric set."""

from __future__ import annotations

import importlib.util
import re
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("clickhouse_parse_benchmark", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def tsv(rounds: int = 3, query_count: int = 22) -> str:
    lines = []
    for round_number in range(1, rounds + 1):
        for query in range(1, query_count + 1):
            lines.append(f"ck-run-1-r{round_number}-q{query:02d}\t{100.0 + query}\t1000\t4096")
    return "\n".join(lines) + "\n"


def write(tmp_path: Path, text: str) -> Path:
    path = tmp_path / "query_log.tsv"
    path.write_text(text, encoding="utf-8")
    return path


def test_builds_total_and_per_query_medians(tmp_path: Path) -> None:
    rows = MODULE.read_query_log(write(tmp_path, tsv()))
    result = MODULE.build_result(rows, 3, 1, 32, 110000000000, 120000000000)
    assert len(result["results"]) == 23
    assert result["results"]["tpch-22-total/total_time"]["unit"] == "s"
    assert result["results"]["tpch-22-total/total_time"]["direction"] == "lower_is_better"
    assert result["results"]["tpch-q01/duration_ms"]["value"] == 101.0
    assert result["parameters"]["queries"] == 22
    assert result["parameters"]["sf"] == 1


def test_total_is_the_median_of_the_round_sums(tmp_path: Path) -> None:
    text = tsv()
    lines = text.splitlines()
    rounds = {}
    for line in lines:
        qid, duration, *_ = line.split("\t")
        round_number = int(re.search(r"-r(\d+)-q\d{2}$", qid).group(1))
        rounds[round_number] = rounds.get(round_number, 0.0) + float(duration)
    rows = MODULE.read_query_log(write(tmp_path, text))
    result = MODULE.build_result(rows, 3, 1, 32, 1, 2)
    expected = sorted(rounds.values())[1] / 1000.0
    assert result["results"]["tpch-22-total/total_time"]["value"] == round(expected, 3)


def test_rejects_missing_queries(tmp_path: Path) -> None:
    text = "\n".join(line for line in tsv().splitlines() if "-q07" not in line) + "\n"
    rows = MODULE.read_query_log(write(tmp_path, text))
    with pytest.raises(ValueError):
        MODULE.build_result(rows, 3, 1, 32, 1, 2)


def test_rejects_duplicate_rows(tmp_path: Path) -> None:
    text = tsv() + "ck-run-1-r1-q01\t5.0\t1\t1\n"
    with pytest.raises(ValueError):
        MODULE.read_query_log(write(tmp_path, text))


@pytest.mark.parametrize("bad", ["ck-run-1-r1-q01\t0\t1\t1", "ck-run-1-r1-q01\tnan\t1\t1",
                                 "ck-run-1-r1-q23\t5\t1\t1", "not-a-query-id\t5\t1\t1"])
def test_rejects_invalid_rows(tmp_path: Path, bad: str) -> None:
    text = "\n".join(line for line in tsv().splitlines() if "-r1-q01" not in line) + "\n" + bad + "\n"
    with pytest.raises(ValueError):
        MODULE.read_query_log(write(tmp_path, text))
