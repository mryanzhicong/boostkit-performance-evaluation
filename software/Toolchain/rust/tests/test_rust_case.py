"""Keep the rustc-perf parsing contract and case wiring stable."""

from __future__ import annotations

import importlib.util
import json
import os
import sqlite3
import subprocess
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
    ("hashmap/bench_std", "bench_std"),
    ("hashmap/bench_fx", "bench_fx"),
    ("parsing/json_parse", "json_parse"),
)
RUNTIME_ITERATIONS = 5


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
        # The collector stores one row per runtime iteration; the parser must
        # report the minimum (fastest) one, like the upstream site.
        runtime_series = {
            "bench_std": {"wall-time": (21_500_000.0, 23_000_000.0, 25_000_000.0),
                          "instructions:u": (9_876_543.0, 9_900_000.0, 10_000_000.0)},
            "bench_fx": {"wall-time": (12_500_000.0, 13_000_000.0),
                         "instructions:u": (8_765_432.0, 8_800_000.0)},
            "json_parse": {"wall-time": (45_000_000.0, 46_000_000.0),
                           "instructions:u": (7_654_321.0, 7_700_000.0)},
        }
        for _log_name, benchmark in RUNTIME_BENCHMARKS:
            for metric, values in runtime_series[benchmark].items():
                series_id += 1
                connection.execute(
                    "INSERT INTO runtime_pstat_series VALUES (?, ?, ?, ?)",
                    (series_id, benchmark, TARGET_TRIPLE, metric),
                )
                for value in values:
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
        "\n".join(
            f"Finished {log_name} (1/{len(RUNTIME_BENCHMARKS)})"
            for log_name, _benchmark in RUNTIME_BENCHMARKS
        ) + "\n",
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
    # Runtime wall time is converted from nanoseconds to milliseconds and the
    # fastest (minimum) iteration is reported.
    assert results["runtime/bench_std/wall-time"]["value"] == pytest.approx(21.5)
    assert results["runtime/bench_std/wall-time"]["unit"] == "ms"
    assert results["runtime/bench_std/instructions"]["value"] == pytest.approx(9_876_543.0)
    assert results["runtime/json_parse/instructions"]["unit"] == "instructions"
    assert results["runtime/bench_std/wall-time"]["group"] == "runtime"
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


def test_parser_reports_fastest_runtime_iteration(fixture_results: Path) -> None:
    connection = sqlite3.connect(fixture_results / "rustc_perf.db")
    try:
        # Shrink the last iteration of bench_std so the minimum changes.
        connection.execute(
            "UPDATE runtime_pstat SET value = 20000000.0 WHERE value = 25000000.0"
        )
        connection.commit()
    finally:
        connection.close()
    payload = run_parser(fixture_results)
    assert payload["results"]["runtime/bench_std/wall-time"]["value"] == pytest.approx(20.0)


def test_parser_aggregates_compile_iterations(fixture_results: Path) -> None:
    connection = sqlite3.connect(fixture_results / "rustc_perf.db")
    try:
        # A slower second iteration must not replace the faster first one.
        connection.execute(
            "INSERT INTO pstat (series, aid, cid, value) SELECT series, aid, cid, value * 2 FROM pstat"
        )
        connection.commit()
    finally:
        connection.close()
    payload = run_parser(fixture_results)
    assert payload["results"]["compile/helloworld/check/threads=1/wall-time"]["value"] == pytest.approx(1.6)


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


def test_release_base_uses_domestic_mirror_without_proxy(tmp_path: Path) -> None:
    script = f'source "{SCRIPT_DIR}/common.sh"; printf "%s\\n" "$RUST_RELEASE_BASE"'
    direct = subprocess.run(
        ["bash", "-c", script],
        capture_output=True, text=True, check=False,
        env={**os.environ, "PERF_PROXY": ""},
    )
    assert direct.stdout.strip() == "https://mirrors.ustc.edu.cn/rust-static/dist"
    proxied = subprocess.run(
        ["bash", "-c", script],
        capture_output=True, text=True, check=False,
        env={**os.environ, "PERF_PROXY": "http://proxy.example"},
    )
    assert proxied.stdout.strip() == "https://static.rust-lang.org/dist"


def test_cargo_mirror_configured_only_without_proxy(tmp_path: Path) -> None:
    work = tmp_path / "work"
    results = tmp_path / "results"
    script = f"""
source "{SCRIPT_DIR}/common.sh"
export PERF_WORK_DIR="{work}"
export RESULTS_DIR="{results}"
export CARGO_HOME="{work}/cargo"
export EXPECTED_ARCH=x86_64
configure_runtime_paths
configure_cargo_mirror
cat "${{CARGO_HOME}}/config.toml"
"""
    direct = subprocess.run(
        ["bash", "-c", script], capture_output=True, text=True, check=False,
        env={**os.environ, "PERF_PROXY": ""},
    )
    assert direct.returncode == 0
    assert 'replace-with = "ustc"' in direct.stdout
    assert "sparse+https://mirrors.ustc.edu.cn/crates.io-index/" in direct.stdout
    proxied_work = tmp_path / "work-proxy"
    proxied_script = script.replace(f'export PERF_WORK_DIR="{work}"', f'export PERF_WORK_DIR="{proxied_work}"').replace(
        f'export CARGO_HOME="{work}/cargo"', f'export CARGO_HOME="{proxied_work}/cargo"'
    )
    proxied = subprocess.run(
        ["bash", "-c", proxied_script], capture_output=True, text=True, check=False,
        env={**os.environ, "PERF_PROXY": "http://proxy.example"},
    )
    assert proxied.returncode != 0
    assert not (proxied_work / "cargo" / "config.toml").exists()


def test_container_runs_without_pinning_and_mounts_results() -> None:
    content = (SCRIPT_DIR / "common.sh").read_text(encoding="utf-8")
    assert "--network=host" in content
    assert "--cap-add=PERFMON" in content
    assert "--security-opt seccomp=unconfined" in content
    assert "--cpuset-cpus" not in content
    assert "--cpuset-mems" not in content
    assert "--cpus=" not in content
    assert 'type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}' in content
    assert 'type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}' in content
    assert "boostkit.rust.run-id=${PERF_RUN_ID}" in content
    assert "openEuler-24.03-LTS-SP4" in content
    assert "docker load" in content
    assert "update-ca-trust extract" in content
    assert "repo.huaweicloud.com" in content


def test_build_and_test_run_inside_container() -> None:
    base = (SCRIPT_DIR / "builders" / "base.sh").read_text(encoding="utf-8")
    start = (SCRIPT_DIR / "stages" / "start.sh").read_text(encoding="utf-8")
    test_stage = (SCRIPT_DIR / "stages" / "test.sh").read_text(encoding="utf-8")
    stop = (SCRIPT_DIR / "stages" / "stop.sh").read_text(encoding="utf-8")
    assert "require_rust_container" in base
    assert "container_exec_root dnf" in base
    assert "container_exec sh -c" in base
    assert "cargo build -p collector" in base
    assert 'export PATH=\\"${RUST_HOME}/bin:\\$PATH\\"' in base
    assert "container_exec" in start
    assert "container_exec perf stat" in start
    assert 'export PATH=\\"${RUST_HOME}/bin:\\$PATH\\"' in start
    assert "container_exec sh -c" in test_stage
    assert "bench_local" in test_stage
    assert "bench_runtime_local" in test_stage
    assert 'export PATH=\\"${RUST_HOME}/bin:\\$PATH\\"' in test_stage
    assert "remove_rust_container" in stop


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
    assert "runtime/bench_std/wall-time" in markdown
    assert "越小越好" in markdown


def test_cross_architecture_report_rejects_parameter_drift(fixture_results: Path) -> None:
    payload = run_parser(fixture_results)
    x86 = normalized_rust_result("x86_64", 1.0, payload)
    arm = normalized_rust_result("aarch64", 1.25, payload)
    arm["parameters"]["benchmark_rust.json"]["profiles"] = ["check", "opt"]
    with pytest.raises(ValueError, match="parameters differ"):
        compare_pair(x86, arm)
