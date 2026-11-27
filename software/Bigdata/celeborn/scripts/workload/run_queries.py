#!/usr/bin/env python3
"""Measure one TPC-DS pass with the Celeborn shuffle service.

One Spark application executes every pinned statement in order and records the
wall-clock time of ``spark.sql(...).collect()`` per statement.  The Spark
application id is written next to the timings so the caller can attribute the
shuffle files that Celeborn stored for this pass.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

from pyspark.sql import SparkSession

sys.path.insert(0, str(Path(__file__).resolve().parent))
import tpcds  # noqa: E402


def build_session(args: argparse.Namespace) -> SparkSession:
    return (
        SparkSession.builder.appName(f"celeborn-tpcds-{args.sample}")
        .config("spark.sql.warehouse.dir", args.warehouse)
        .config("spark.sql.catalogImplementation", "hive")
        .config(
            "spark.hadoop.javax.jdo.option.ConnectionURL",
            f"jdbc:derby:;databaseName={args.metastore}/metastore_db;create=true",
        )
        .config("spark.ui.enabled", "false")
        .config("spark.sql.session.timeZone", "UTC")
        # AQE re-plans joins from runtime statistics, which changes how much data
        # each pass shuffles (observed 540 MB vs 884 MB for the same 99 queries).
        # The case keeps a deterministic plan so runs stay comparable.
        .config("spark.sql.adaptive.enabled", "false")
        .config("spark.sql.shuffle.partitions", str(args.shuffle_partitions))
        .enableHiveSupport()
        .getOrCreate()
    )


def shuffle_usage(directories: str, app_id: str) -> dict[str, object]:
    """Size the Celeborn storage of one application only.

    The worker keeps the data under ``<storage>/celeborn-worker/shuffle_data/<appId>``;
    scanning the whole storage root would also count applications that Celeborn has
    not expired yet, which is why the post-run ``du`` values drift.
    """
    total = 0
    files = 0
    seen: list[str] = []
    if not app_id:
        return {"bytes": 0, "files": 0, "directories": seen}
    for entry in [item.strip() for item in directories.split(",") if item.strip()]:
        root = Path(entry) / "celeborn-worker" / "shuffle_data" / app_id
        seen.append(str(root))
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            if path.is_file():
                total += path.stat().st_size
                files += 1
    return {"bytes": total, "files": files, "directories": seen}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--query-dir", required=True)
    parser.add_argument("--warehouse", required=True)
    parser.add_argument("--metastore", required=True)
    parser.add_argument("--sample", required=True, type=int)
    parser.add_argument("--out", required=True)
    parser.add_argument("--shuffle-partitions", default=200, type=int)
    parser.add_argument(
        "--shuffle-dirs",
        default="",
        help="Comma separated Celeborn worker storage directories to size before the application stops",
    )
    args = parser.parse_args()

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    statements = [entry["name"] for entry in manifest["statements"]]
    if not statements:
        raise SystemExit("ERROR: the workload manifest lists no statements")

    spark = build_session(args)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    try:
        with out_path.open("w", encoding="utf-8") as handle:
            handle.write(
                json.dumps(
                    {
                        "record": "application",
                        "sample": args.sample,
                        "application_id": spark.sparkContext.applicationId,
                        "statements": len(statements),
                    },
                    sort_keys=True,
                )
                + "\n"
            )
            handle.flush()
            for index, name in enumerate(statements, start=1):
                sql = tpcds.statement_text(Path(args.query_dir) / name)
                begin = time.monotonic()
                rows = spark.sql(sql).collect()
                elapsed = time.monotonic() - begin
                handle.write(
                    json.dumps(
                        {
                            "record": "statement",
                            "index": index,
                            "name": name,
                            "seconds": round(elapsed, 6),
                            "rows": len(rows),
                        },
                        sort_keys=True,
                    )
                    + "\n"
                )
                handle.flush()
                print(f"[celeborn] sample {args.sample} {name}: {elapsed:.3f}s rows={len(rows)}", flush=True)
        total = time.monotonic() - started
        # Celeborn deletes a finished application's shuffle data asynchronously, so
        # the storage directories are measured while the application is still alive.
        usage = shuffle_usage(args.shuffle_dirs, spark.sparkContext.applicationId)
        with out_path.open("a", encoding="utf-8") as handle:
            handle.write(
                json.dumps(
                    {
                        "record": "shuffle_usage",
                        "sample": args.sample,
                        "bytes": usage["bytes"],
                        "files": usage["files"],
                        "directories": usage["directories"],
                    },
                    sort_keys=True,
                )
                + "\n"
            )
        print(
            f"[celeborn] sample {args.sample} stored {usage['bytes']} shuffle bytes "
            f"in {usage['files']} files",
            flush=True,
        )
        handle_summary = {
            "record": "summary",
            "sample": args.sample,
            "application_id": spark.sparkContext.applicationId,
            "statements": len(statements),
            "seconds": round(total, 6),
        }
        with out_path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(handle_summary, sort_keys=True) + "\n")
    finally:
        spark.stop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
