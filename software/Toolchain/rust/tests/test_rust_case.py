"""Keep the rustc-perf parsing contract and case wiring stable."""

from __future__ import annotations

import importlib.util
import json
import sqlite3
import sys
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
FRAMEWORK_DIR = CASE_DIR.parents[2] / "framework"
sys.path.insert(0, str(FRAMEWORK_DIR))

from generate_comparison import compare_pair  # noqa: E402
from reporting import render_comparison  # noqa: E402

SPEC = importlib.util.spec_from_file_location(
    "rust_parse_benchmark", SCRIPT_DIR / "results" / "parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)

STANDALONE_SPEC = importlib.util.spec_from_file_location(
    "rust_standalone_runtime", SCRIPT_DIR / "results" / "standalone_runtime.py"
)
assert STANDALONE_SPEC is not None and STANDALONE_SPEC.loader is not None
standalone = importlib.util.module_from_spec(STANDALONE_SPEC)
STANDALONE_SPEC.loader.exec_module(standalone)

ARTIFACT_ID = "boostkit-1.99.1-base"
TARGET_TRIPLE = "x86_64-unknown-linux-gnu"

COMPILE_BENCHMARKS = {
    "helloworld": (1,),
    "cargo-0.87.1": (1, 4),
    "serde-1.0.219": (1,),
    "typenum-1.18.0": (1, 4),
}
RUNTIME_BENCHMARKS = (
    "hashmap/bench_std",
    "hashmap/bench_fx",
    "parsing/json_parse",
)


def create_database(path: Path) -> None:
    connection = sqlite3.connect(path)
    try:
        connection.executescript(
            """
            CREATE TABLE artifact (id INTEGER PRIMARY KEY, name TEXT, date TEXT, type TEXT);
            CREATE TABLE collection (id INTEGER PRIMARY KEY, perf_commit TEXT);
            CREATE TABLE benchmark (name TEXT PRIMARY KEY, stabilized INTEGER, category TEXT);
            CREATE TABLE pstat_series (
                id INTEGER PRIMARY KEY, "crate" TEXT, profile TEXT, scenario TEXT,
                backend TEXT, target TEXT, frontend_threads INTEGER, metric TEXT);
            CREATE TABLE pstat (series INTEGER, aid INTEGER, cid INTEGER, value REAL);
            CREATE TABLE runtime_pstat_series (
                id INTEGER PRIMARY KEY, benchmark TEXT, target TEXT, metric TEXT);
            CREATE TABLE runtime_pstat (series INTEGER, aid INTEGER, cid INTEGER, value REAL);
            """
        )
        connection.execute(
            "INSERT INTO artifact (id, name, date, type) VALUES (1, ?, 'x', 'master')",
            (ARTIFACT_ID,),
        )
        connection.execute(
            "INSERT INTO artifact (id, name, date, type) VALUES (2, 'other', 'x', 'master')"
        )
        series_id = 0
        for crate, thread_counts in COMPILE_BENCHMARKS.items():
            for profile in ("check", "debug", "opt"):
                for threads in thread_counts:
                    for metric, value in (
                        ("wall-time", 1.5 + threads * 0.1),
                        ("instructions:u", 1234567.0),
                    ):
                        series_id += 1
                        connection.execute(
                            'INSERT INTO pstat_series VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                            (series_id, crate, profile, "full", "llvm",
                             TARGET_TRIPLE, threads, metric),
                        )
                        connection.execute(
                            "INSERT INTO pstat VALUES (?, ?, ?, ?)",
                            (series_id, 1, 1, value),
                        )
        for benchmark, (metric, value) in (
            ("hashmap/bench_std", ("wall-time", 21_500_000.0)),
            ("hashmap/bench_std", ("instructions:u", 9876543.0)),
            ("hashmap/bench_fx", ("wall-time", 12_500_000.0)),
            ("hashmap/bench_fx", ("instructions:u", 8765432.0)),
            ("parsing/json_parse", ("wall-time", 45_000_000.0)),
            ("parsing/json_parse", ("instructions:u", 7654321.0)),
        ):
            series_id += 1
            connection.execute(
                "INSERT INTO runtime_pstat_series VALUES (?, ?, ?, ?)",
                (series_id, benchmark, TARGET_TRIPLE, metric),
            )
            connection.execute(
                "INSERT INTO runtime_pstat VALUES (?, ?, ?, ?)",
                (series_id, 1, 1, value),
            )
        connection.commit()
    finally:
        connection.close()


@pytest.fixture()
def fixture_results(tmp_path: Path) -> Path:
    results_dir = tmp_path / "results"
    results_dir.mkdir()
    for crate, threads in COMPILE_BENCHMARKS.items():
        crate_dir = results_dir / "compile-benchmarks" / crate
        crate_dir.mkdir(parents=True)
        (crate_dir / "Cargo.toml").write_text("[package]\n", encoding="utf-8")
        category = "primary" if crate != "serde-1.0.219" else "primary"
        payload = {"category": category}
        if len(threads) > 1:
            payload["frontend_threads"] = list(threads)
        (crate_dir / "perf-config.json").write_text(
            json.dumps(payload), encoding="utf-8"
        )
    excluded = results_dir / "compile-benchmarks" / "coercions"
    excluded.mkdir(parents=True)
    (excluded / "Cargo.toml").write_text("[package]\n", encoding="utf-8")
    (excluded / "perf-config.json").write_text(
        json.dumps({"category": "secondary"}), encoding="utf-8"
    )
    create_database(results_dir / "rustc_perf.db")
    (results_dir / "benchmark_rust_runtime.log").write_text(
        "\n".join(f"Finished {name} (1/3)" for name in RUNTIME_BENCHMARKS) + "\n",
        encoding="utf-8",
    )
    (results_dir / "rustc-version.txt").write_text(
        "rustc 1.99.1 (58cf8f9c3 2026-10-13)\n", encoding="utf-8"
    )
    return results_dir


def run_parser(fixture: Path) -> dict:
    payload = parser.parse_benchmark(
        fixture / "rustc_perf.db",
        fixture / "compile-benchmarks",
        fixture / "benchmark_rust_runtime.log",
        fixture / "rustc-version.txt",
        TARGET_TRIPLE,
        ARTIFACT_ID,
    )
    destination = fixture / "benchmark_rust.json"
    destination.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return payload


def test_parser_extracts_expected_metrics(fixture_results: Path) -> None:
    payload = run_parser(fixture_results)
    results = payload["results"]
    # 4 primary crates; two of them expand to 2 frontend thread counts.
    combos = 2 * 1 + 2 * 2  # 6 (crate, threads) combos
    expected_compile = combos * 3 * 2  # x profiles x metrics = 36
    assert expected_compile == 36
    expected_runtime = len(RUNTIME_BENCHMARKS) * 2
    assert len(results) == expected_compile + expected_runtime
    assert "compile/helloworld/check/threads=1/wall-time" in results
    assert "compile/cargo-0.87.1/debug/threads=4/instructions" in results
    assert results["compile/helloworld/check/threads=1/wall-time"]["unit"] == "s"
    assert results["compile/helloworld/check/threads=1/wall-time"]["group"] == "compile"
    # Runtime wall time is converted from nanoseconds to milliseconds.
    assert results["runtime/hashmap/bench_std/wall-time"]["value"] == pytest.approx(21.5)
    assert results["runtime/hashmap/bench_std/wall-time"]["unit"] == "ms"
    assert results["runtime/parsing/json_parse/instructions"]["unit"] == "instructions"
    assert all(
        metric["direction"] == "lower_is_better" for metric in results.values()
    )
    assert payload["parameters"]["rustc_perf_revision"] == \
        "9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c"
    assert payload["parameters"]["profiles"] == ["check", "debug", "opt"]
    assert payload["runtime_context"]["rustc_version"].startswith("rustc 1.99.1 ")


def test_parser_rejects_missing_compile_series(fixture_results: Path) -> None:
    connection = sqlite3.connect(fixture_results / "rustc_perf.db")
    try:
        connection.execute(
            'DELETE FROM pstat WHERE series = ('
            ' SELECT id FROM pstat_series WHERE "crate" = \'helloworld\' '
            " AND profile = 'check' AND metric = 'wall-time')"
        )
        connection.commit()
    finally:
        connection.close()
    with pytest.raises(Exception, match="missing"):
        run_parser(fixture_results)


def test_parser_rejects_runtime_mismatch(fixture_results: Path) -> None:
    (fixture_results / "benchmark_rust_runtime.log").write_text(
        "Finished hashmap/bench_std (1/1)\nFinished hashmap/bench_extra (2/2)\n",
        encoding="utf-8",
    )
    with pytest.raises(Exception, match="do not match"):
        run_parser(fixture_results)


def test_parser_rejects_non_positive_values(fixture_results: Path) -> None:
    connection = sqlite3.connect(fixture_results / "rustc_perf.db")
    try:
        connection.execute(
            "UPDATE pstat SET value = 0 WHERE value > 1200000 AND value < 1400000"
        )
        connection.commit()
    finally:
        connection.close()
    with pytest.raises(Exception, match="non-positive"):
        run_parser(fixture_results)


def test_standalone_validation_accepts_consistent_payload(
    fixture_results: Path,
) -> None:
    payload = run_parser(fixture_results)
    metrics = standalone.validate_metrics(payload)
    assert len(metrics) == payload["expected"]["compile_series"] + \
        len(RUNTIME_BENCHMARKS) * 2


def test_standalone_validation_rejects_wrong_counts(fixture_results: Path) -> None:
    payload = run_parser(fixture_results)
    payload["expected"]["compile_series"] += 1
    with pytest.raises(Exception, match="expected"):
        standalone.validate_metrics(payload)


def test_case_yaml_wiring_matches_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["name"] == "rust"
    assert case["category"] == "Toolchain"
    assert case["versions"] == ["1.99.1"]
    assert case["test_tools"]["rustc-perf"]["revision"] == \
        "9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c"
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh", "function": "build_rust",
    }
    assert stages["start"]["function"] == "start_rust_runtime"
    assert stages["test"]["function"] == "run_rust_benchmarks"
    assert stages["stop"]["function"] == "stop_rust_runtime"
    for stage in ("start", "test", "stop"):
        assert (CASE_DIR / stages[stage]["script"]).is_file()
    for output in case["outputs"].values():
        assert (CASE_DIR / "scripts" / "results" / "parse_benchmark.py").is_file()
    collection = case["metrics"]["collection"]
    assert collection["path"] == "results"
    assert collection["value_path"] == "value"
    assert collection["unit_path"] == "unit"
    assert collection["direction_path"] == "direction"
    assert collection["group_path"] == "group"


def test_optimized_builder_fails_explicitly() -> None:
    content = (SCRIPT_DIR / "builders" / "optimized.sh").read_text(encoding="utf-8")
    assert "not implemented" in content
    assert "return 30" in content


def normalized_rust_result(architecture: str, factor: float, payload: dict) -> dict:
    metrics = {}
    for name, metric in payload["results"].items():
        metrics[name] = {
            "value": metric["value"] * factor,
            "unit": metric["unit"],
            "direction": metric["direction"],
            "group": metric["group"],
        }
    return {
        "category": "Toolchain",
        "software": "rust",
        "version": "1.99.1",
        "architecture": architecture,
        "status": "passed",
        "cleanup_status": "passed",
        "build_info": {
            "requested_version": "1.99.1",
            "actual_version": "1.99.1",
            "recorded_at": "2026-10-31T00:00:00Z",
        },
        "parameters": {"benchmark_rust.json": json.loads(json.dumps(payload["parameters"]))},
        "parameter_signature": "same-parameters",
        "test_tools": {
            "rustc-perf": {
                "version": "0.1.0",
                "revision": "9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c",
            }
        },
        "system_info": {
            "architecture": architecture,
            "cpu_model": "Example CPU",
            "cpu_count": 64 if architecture == "x86_64" else 96,
        },
        "runtime_before": {"memory": "before"},
        "runtime_after": {"memory": "after"},
        "metrics": metrics,
    }


def test_cross_architecture_report_aligns_same_metrics(fixture_results: Path) -> None:
    payload = run_parser(fixture_results)
    x86 = normalized_rust_result("x86_64", 1.0, payload)
    arm = normalized_rust_result("aarch64", 1.25, payload)
    comparison = compare_pair(x86, arm)
    metrics = comparison["metrics"]
    assert len(metrics) == len(payload["results"])
    # lower_is_better: a 25% slower aarch64 value must compare as 0.8.
    sample = metrics["compile/helloworld/check/threads=1/wall-time"]
    assert sample["relative_performance"] == pytest.approx(0.8)
    groups = {metric["group"] for metric in metrics.values()}
    assert groups == {"compile", "runtime"}
    markdown = render_comparison(comparison)
    assert "compile/helloworld/check/threads=1/wall-time" in markdown
    assert "runtime/hashmap/bench_std/wall-time" in markdown
    assert "越小越好" in markdown


def test_cross_architecture_report_rejects_parameter_drift(fixture_results: Path) -> None:
    payload = run_parser(fixture_results)
    x86 = normalized_rust_result("x86_64", 1.0, payload)
    arm = normalized_rust_result("aarch64", 1.25, payload)
    arm["parameters"]["benchmark_rust.json"]["profiles"] = ["check", "opt"]
    with pytest.raises(ValueError, match="parameters differ"):
        compare_pair(x86, arm)
