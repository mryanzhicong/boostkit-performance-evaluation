"""Ensure Doris end-to-end timings become a complete TPC-H metric set."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("doris_parse_benchmark", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

HEADER = "round,query,wall_ms\n"


def csv_text(rounds: int = 3) -> str:
    lines = [HEADER.strip()]
    for round_number in range(1, rounds + 1):
        for query in range(1, 23):
            lines.append(f"{round_number},{query},{50.0 + query}")
    return "\n".join(lines) + "\n"


def write(tmp_path: Path, text: str) -> Path:
    path = tmp_path / "tpch_wall.csv"
    path.write_text(text, encoding="utf-8")
    return path


def test_builds_total_and_per_query_medians(tmp_path: Path) -> None:
    rows = MODULE.read_rows(write(tmp_path, csv_text()))
    result = MODULE.build_result(rows, 3, 1, 32, 107374182400)
    assert len(result["results"]) == 23
    assert result["results"]["tpch-22-total/total_time"]["unit"] == "s"
    assert result["results"]["tpch-q01/duration_ms"]["value"] == 51.0
    assert result["results"]["tpch-q01/duration_ms"]["direction"] == "lower_is_better"
    assert result["parameters"]["parallel_pipeline_task_num"] == 32
    assert result["parameters"]["replication_num"] == 1


def test_total_is_the_sum_of_the_22_queries(tmp_path: Path) -> None:
    rows = MODULE.read_rows(write(tmp_path, csv_text()))
    result = MODULE.build_result(rows, 3, 1, 32, 1)
    expected = sum(50.0 + query for query in range(1, 23)) / 1000.0
    assert result["results"]["tpch-22-total/total_time"]["value"] == round(expected, 3)


def test_rejects_missing_queries(tmp_path: Path) -> None:
    text = "\n".join(line for line in csv_text().splitlines() if not line.startswith("2,7,")) + "\n"
    rows = MODULE.read_rows(write(tmp_path, text))
    with pytest.raises(ValueError):
        MODULE.build_result(rows, 3, 1, 32, 1)


def test_rejects_duplicate_rows(tmp_path: Path) -> None:
    text = csv_text() + "1,1,10.0\n"
    with pytest.raises(ValueError):
        MODULE.read_rows(write(tmp_path, text))


@pytest.mark.parametrize("bad", ["1,1,0", "1,1,nan", "1,23,10", "x,1,10"])
def test_rejects_invalid_rows(tmp_path: Path, bad: str) -> None:
    text = "\n".join(line for line in csv_text().splitlines() if not line.startswith("1,1,")) + "\n" + bad + "\n"
    with pytest.raises(ValueError):
        MODULE.read_rows(write(tmp_path, text))
