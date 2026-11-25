"""Ensure ZkBench CSV rows become a complete, strictly validated metric set."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("zookeeper_parse_benchmark", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

CSV_HEADER = (
    "label,arch,threads,mode,value_size,keyspace,ops_ok,ops_err,elapsed_s,"
    "throughput_ops,avg_us,p50_us,p95_us,p99_us,max_us\n"
)


def row(mode: str, threads: int, throughput: float, p99: float = 1200.0, ops_err: int = 0) -> dict:
    ops = 10000
    return {
        "mode": mode,
        "threads": threads,
        "ops_ok": ops,
        "throughput": throughput,
        "latencies_us": {
            "avg": 600.0,
            "p50_us": 500.0,
            "p95_us": p99 * 0.8,
            "p99_us": p99,
            "max_us": p99 * 2,
        },
        "_ops_err": ops_err,
    }


def clean(rows: list[dict]) -> list[dict]:
    return [{k: v for k, v in item.items() if k != "_ops_err"} for item in rows]


def test_builds_six_metrics_per_case_from_round_medians() -> None:
    rows = []
    for mode in ("read", "update"):
        for threads in (1, 8):
            for throughput, p99 in ((1000.0, 1000.0), (1100.0, 1400.0), (1050.0, 1200.0)):
                rows.append(row(mode, threads, throughput, p99))
    result = MODULE.build_result(clean(rows), ["read", "update"], [1, 8], 3, 1000000, 1024, 2000)
    assert len(result["results"]) == 2 * 2 * 6
    assert result["results"]["read-t1/throughput"]["value"] == 1050.0
    assert result["results"]["read-t1/p99_ms"]["value"] == 1.2
    assert result["results"]["read-t1/p99_ms"]["unit"] == "ms"
    assert result["results"]["read-t1/p99_ms"]["direction"] == "lower_is_better"
    assert result["results"]["update-t8/throughput"]["group"] == "update-t8"
    assert result["results"]["read-t1/single_core_throughput"]["value"] == 32.812


def test_records_the_fixed_workload_parameters() -> None:
    rows = [row("read", 1, 1000.0) for _ in range(3)]
    result = MODULE.build_result(
        clean(rows), ["read"], [1], 3, 1000000, 1024, 2000, cpus=32, jvm_flags="-Xmx4g"
    )
    parameters = result["parameters"]
    assert parameters["keyspace"] == 1000000
    assert parameters["value_size_bytes"] == 1024
    assert parameters["warmup_ops_per_thread"] == 2000
    assert parameters["ops_per_thread"] == {"1": 20000}
    assert parameters["container_cpus"] == 32
    assert parameters["jvm_flags"] == "-Xmx4g"


def test_reads_the_original_csv_columns(tmp_path: Path) -> None:
    path = tmp_path / "zk.csv"
    path.write_text(
        CSV_HEADER
        + "run,aarch64,32,read,1024,1000000,200000,0,4.152,48165.8,664.1,588.2,1201.4,2105.9,8821.3\n",
        encoding="utf-8",
    )
    rows = MODULE.read_rows(path)
    assert rows[0]["mode"] == "read"
    assert rows[0]["latencies_us"]["p99_us"] == 2105.9


def test_rejects_missing_rounds() -> None:
    rows = [row("read", 1, 1000.0), row("read", 1, 1000.0)]
    with pytest.raises(ValueError):
        MODULE.build_result(clean(rows), ["read"], [1], 3, 1000000, 1024, 2000)


def test_rejects_duplicate_or_unexpected_cases() -> None:
    rows = [row("read", 1, 1000.0) for _ in range(3)]
    rows.append(row("mixed", 8, 1000.0))
    with pytest.raises(ValueError):
        MODULE.build_result(clean(rows), ["read"], [1], 3, 1000000, 1024, 2000)


def csv_line(ops_ok: int = 10000, ops_err: int = 0, elapsed: float = 1.0,
             throughput: float = 10000.0, p50: float = 500.0, p95: float = 900.0,
             p99: float = 1200.0, maximum: float = 2000.0) -> str:
    return (
        f"run,aarch64,1,read,1024,1000000,{ops_ok},{ops_err},{elapsed},{throughput},"
        f"600.0,{p50},{p95},{p99},{maximum}\n"
    )


@pytest.mark.parametrize(
    "fields",
    [
        {"throughput": 0.0},
        {"p95": 99999.0},
        {"p50": -1.0},
        {"throughput": 1.0},
        {"ops_err": 2},
        {"ops_ok": 0},
        {"elapsed": 0.0},
    ],
)
def test_rejects_impossible_or_inconsistent_numbers(tmp_path: Path, fields: dict) -> None:
    path = tmp_path / "zk.csv"
    path.write_text(CSV_HEADER + csv_line(**fields), encoding="utf-8")
    with pytest.raises(ValueError):
        MODULE.read_rows(path)


def test_rejects_failed_operations_in_csv(tmp_path: Path) -> None:
    path = tmp_path / "zk.csv"
    path.write_text(
        CSV_HEADER
        + "run,aarch64,1,read,1024,1000000,199998,2,4.152,48165.8,664.1,588.2,1201.4,2105.9,8821.3\n",
        encoding="utf-8",
    )
    with pytest.raises(ValueError):
        MODULE.read_rows(path)


def test_rejects_unknown_mode_or_threads(tmp_path: Path) -> None:
    path = tmp_path / "zk.csv"
    path.write_text(
        CSV_HEADER
        + "run,aarch64,7,read,1024,1000000,200000,0,4.152,48165.8,664.1,588.2,1201.4,2105.9,8821.3\n",
        encoding="utf-8",
    )
    with pytest.raises(ValueError):
        MODULE.read_rows(path)
