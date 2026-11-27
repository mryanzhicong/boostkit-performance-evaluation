#!/usr/bin/env python3
"""Load the generated TPC-DS text files into flat ORC tables.

Spark reads the pipe-delimited dsdgen output with the schema of the pinned DDL,
casts every column to its declared Spark type and writes one ORC table per
TPC-DS entity into the run's warehouse.  The run's Hive-compatible metastore
(embedded Derby) keeps the tables visible to every later measurement sample.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

from pyspark.sql import SparkSession
from pyspark.sql.types import (
    BooleanType,
    DateType,
    DecimalType,
    DoubleType,
    FloatType,
    IntegerType,
    LongType,
    ShortType,
    StringType,
    StructField,
    StructType,
    TimestampType,
)

sys.path.insert(0, str(Path(__file__).resolve().parent))
import tpcds  # noqa: E402

SPARK_TYPES = {
    "int": IntegerType,
    "bigint": LongType,
    "smallint": ShortType,
    "tinyint": ShortType,
    "float": FloatType,
    "double": DoubleType,
    "string": StringType,
    "boolean": BooleanType,
    "date": DateType,
    "timestamp": TimestampType,
}


def struct_field(name: str, spark_type: str) -> StructField:
    if spark_type.startswith("decimal("):
        precision, scale = spark_type[len("decimal(") : -1].split(",")
        return StructField(name, DecimalType(int(precision), int(scale)), True)
    if spark_type not in SPARK_TYPES:
        raise ValueError(f"unsupported Spark type: {spark_type}")
    return StructField(name, SPARK_TYPES[spark_type](), True)


DATA_FILE_RE = re.compile(r"^(?P<table>[a-z_]+?)(?:_\d+_\d+)?\.dat(?:\.\d+)?$")


def data_file_matches(table: str, name: str) -> bool:
    """dsdgen writes either <table>.dat or <table>_<child>_<total>.dat."""
    match = DATA_FILE_RE.match(name)
    return bool(match) and match.group("table") == table


def build_session(warehouse: str, metastore: str) -> SparkSession:
    return (
        SparkSession.builder.appName("celeborn-tpcds-load")
        .config("spark.sql.warehouse.dir", warehouse)
        .config("spark.sql.catalogImplementation", "hive")
        .config(
            "spark.hadoop.javax.jdo.option.ConnectionURL",
            f"jdbc:derby:;databaseName={metastore}/metastore_db;create=true",
        )
        .config("spark.ui.enabled", "false")
        .config("spark.sql.session.timeZone", "UTC")
        .enableHiveSupport()
        .getOrCreate()
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ddl", required=True)
    parser.add_argument("--data-dir", required=True)
    parser.add_argument("--warehouse", required=True)
    parser.add_argument("--metastore", required=True)
    parser.add_argument("--scale-factor", required=True)
    parser.add_argument("--summary", required=True)
    args = parser.parse_args()

    tables = tpcds.load_tables(Path(args.ddl))
    data_dir = Path(args.data_dir)
    spark = build_session(args.warehouse, args.metastore)
    summary = {"scale_factor": args.scale_factor, "warehouse": args.warehouse, "tables": []}
    try:
        for table in tables:
            files = sorted(str(path) for path in data_dir.iterdir() if data_file_matches(table.name, path.name))
            if not files:
                raise SystemExit(f"ERROR: no generated data files for {table.name} under {data_dir}")
            columns = table.spark_columns
            schema = StructType([struct_field(name, kind) for name, kind in columns])
            schema = StructType(list(schema.fields) + [StructField("_trailing", StringType(), True)])
            frame = (
                spark.read.option("sep", "|")
                .option("header", "false")
                .option("encoding", "UTF-8")
                .option("mode", "PERMISSIVE")
                .option("columnNameOfCorruptRecord", "_corrupt")
                .schema(schema)
                .csv(files)
            )
            selected = frame.select(
                *[
                    frame[name].cast(kind).alias(name)
                    if kind != "string"
                    else frame[name].alias(name)
                    for name, kind in columns
                ]
            )
            spark.sql(f"DROP TABLE IF EXISTS {table.name}")
            selected.write.mode("overwrite").format("orc").saveAsTable(table.name)
            rows = spark.table(table.name).count()
            summary["tables"].append({"name": table.name, "files": len(files), "rows": rows})
            print(f"[celeborn] loaded {table.name}: {rows} rows from {len(files)} file(s)", flush=True)
    finally:
        spark.stop()

    Path(args.summary).write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
