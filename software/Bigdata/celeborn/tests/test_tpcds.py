#!/usr/bin/env python3
"""Contract tests for the pinned TPC-DS metadata helpers."""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(CASE_DIR / "scripts" / "workload"))

import tpcds  # noqa: E402

DDL = """
create external table if not exists date_dim(
      d_date_sk bigint
,     d_date_id varchar(16)
,     d_year int
,     d_amount decimal(7,2)
)
row format delimited fields terminated by '|'
location '${LOCATION}/date_dim'
;

create external table if not exists store_sales(
      ss_sold_date_sk bigint
,     ss_quantity int
)
row format delimited fields terminated by '|'
location '${LOCATION}/store_sales'
;
"""


def test_parse_ddl_keeps_every_column() -> None:
    tables = {table.name: table for table in tpcds.parse_ddl(DDL)}
    assert list(tables) == ["date_dim", "store_sales"]
    date_dim = tables["date_dim"]
    assert [name for name, _ in date_dim.columns] == ["d_date_sk", "d_date_id", "d_year", "d_amount"]
    assert date_dim.location == "${LOCATION}/date_dim"


def test_parse_ddl_maps_types_for_spark() -> None:
    tables = {table.name: table for table in tpcds.parse_ddl(DDL)}
    assert tables["date_dim"].spark_columns == [
        ("d_date_sk", "bigint"),
        ("d_date_id", "string"),
        ("d_year", "int"),
        ("d_amount", "decimal(7,2)"),
    ]


def test_parse_ddl_rejects_unknown_types() -> None:
    broken = DDL.replace("ss_quantity int", "ss_quantity interval")
    with pytest.raises(ValueError):
        {table.name: table.spark_columns for table in tpcds.parse_ddl(broken)}


def write_query_dir(target: Path, count: int) -> Path:
    target.mkdir(parents=True, exist_ok=True)
    for index in range(1, count + 1):
        (target / f"query{index}.sql").write_text(f"select {index};\n", encoding="utf-8")
    return target


def test_statement_files_are_ordered_by_number(tmp_path: Path) -> None:
    query_dir = write_query_dir(tmp_path / "queries", 3)
    (query_dir / "query1.sql").write_text("select 100;\n", encoding="utf-8")
    files = tpcds.statement_files(query_dir)
    assert [path.name for path in files] == ["query1.sql", "query2.sql", "query3.sql"]
    assert files[0].read_text(encoding="utf-8") == "select 100;\n"


def test_statement_files_reject_gaps(tmp_path: Path) -> None:
    query_dir = write_query_dir(tmp_path / "queries", 2)
    (query_dir / "query4.sql").write_text("select 4;\n", encoding="utf-8")
    with pytest.raises(ValueError):
        tpcds.statement_files(query_dir)


def test_manifest_records_every_statement_digest(tmp_path: Path) -> None:
    query_dir = write_query_dir(tmp_path / "queries", 3)
    payload = tpcds.manifest(tpcds.parse_ddl(DDL), query_dir, 2)
    assert [entry["name"] for entry in payload["statements"]] == ["query1.sql", "query2.sql"]
    assert all(len(entry["sha256"]) == 64 for entry in payload["statements"])
    assert [table["name"] for table in payload["tables"]] == ["date_dim", "store_sales"]
