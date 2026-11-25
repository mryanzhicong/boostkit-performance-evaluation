"""Contract tests for the strict simdjson result parser."""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE = Path(__file__).resolve().parents[1]
PARSER = CASE / "scripts/results/parse_benchmark.py"
FIXTURES = CASE / "fixtures/benchmarks.json"
README = CASE / "README.md"
SUITES = ("bench_parse_call", "bench_dom_api", "bench_ondemand")
SCENARIOS = ("dom_parse", "dom_parse_stream", *SUITES)
AGGREGATED = {"bench_parse_call"}

SPEC = importlib.util.spec_from_file_location("simdjson_benchmark_parser", PARSER)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def fixtures() -> dict:
    return json.loads(FIXTURES.read_text(encoding="utf-8"))


def write_dom(path: Path, overall: float, stage1: float = 12.0) -> None:
    lines = [f'"{name}"\t\t\t\t\t{overall:.6f}\t{stage1:.6f}\t12.008080'
             for name in ("twitter", "citm_catalog")]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_stream(path: Path, speed: float, batch: int = 2507500) -> None:
    """parse_stream writes the batch table on stdout and the summary on stderr."""
    path.write_text(
        "Batch Size\tGigabytes/second\tNb of documents parsed\n"
        "10000\t0.392\t793\n"
        f"{batch}\t{speed:.3f}\t793\n",
        encoding="utf-8",
    )
    path.with_suffix(".err").write_text(
        "parse_many: Speed per batch_size... from 10000 bytes to 10000000 bytes...\n"
        f"Seemingly optimal batch_size: {batch}...\n"
        f"Best speed: {speed:.5f}...\n",
        encoding="utf-8",
    )


def write_suite(path: Path, suite: str, rows: list[str], rep: int, value_for) -> None:
    benchmarks = []
    for row in rows:
        value = value_for(row, rep)
        if suite in AGGREGATED:
            benchmarks.append({
                "name": f"{row}_median", "run_name": row, "run_type": "aggregate",
                "aggregate_name": "median", "cpu_time": value,
            })
        benchmarks.append({
            "name": row, "run_name": row, "run_type": "iteration", "cpu_time": value / 2,
        })
    path.write_text(json.dumps({"context": {}, "benchmarks": benchmarks}), encoding="utf-8")


def build_inputs(root: Path, reps: int = 5, warmups: int = 1,
                 value_for=None, stream_speed=None, dom_overall=None) -> Path:
    data = fixtures()
    runs = root / "runs"
    for scenario in SCENARIOS:
        (runs / scenario).mkdir(parents=True)
    if value_for is None:
        def value_for(row, rep):
            return 100.0 + rep
    for rep in range(warmups + reps):
        write_dom(runs / "dom_parse" / f"rep{rep}.log",
                  6.0 + rep * 0.01 if dom_overall is None else dom_overall)
        write_stream(runs / "dom_parse_stream" / f"rep{rep}.log",
                     5.0 + rep * 0.01 if stream_speed is None else stream_speed)
        for suite in SUITES:
            write_suite(runs / suite / f"rep{rep}.benchmark.json", suite,
                        data["suites"][suite], rep, value_for)
            (runs / suite / f"rep{rep}.log").write_text("benchmark log\n", encoding="utf-8")
    return runs


def run_parser(runs: Path, results: Path, reps: int = 5, warmups: int = 1) -> subprocess.CompletedProcess:
    command = [
        sys.executable, str(PARSER),
        "--runs-dir", str(runs), "--results-dir", str(results),
        "--fixtures", str(FIXTURES),
        "--warmups", str(warmups), "--reps", str(reps),
        "--version", "4.6.11", "--architecture", "x86_64",
        "--bench-min-time", "1s", "--variant", "base", "--run-id", "test-run",
    ]
    return subprocess.run(command, text=True, capture_output=True, check=False)


def test_full_run_produces_all_metrics(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode == 0, result.stderr
    payload = json.loads((tmp_path / "results/benchmark_simdjson.json").read_text(encoding="utf-8"))
    assert len(payload["results"]) == 66
    assert payload["sampling"]["warmups"] == 1
    assert payload["sampling"]["reps"] == 5
    assert payload["sampling"]["metric_count"] == 66
    groups = {}
    for item in payload["results"].values():
        groups[item["group"]] = groups.get(item["group"], 0) + 1
    assert groups == {
        "dom_parse": 4, "dom_parse_stream": 1,
        "bench_parse_call": 9, "bench_dom_api": 24, "bench_ondemand": 28,
    }
    assert payload["results"]["dom_parse_twitter_gb_per_s"]["unit"] == "GB/s"
    assert payload["results"]["dom_parse_twitter_gb_per_s"]["direction"] == "higher_is_better"
    assert payload["results"]["bench_ondemand_large_random_simdjson_ondemand_ns"]["unit"] == "ns"
    assert payload["results"]["bench_ondemand_large_random_simdjson_ondemand_ns"]["direction"] == "lower_is_better"
    assert (tmp_path / "results/benchmark_google.json").is_file()
    for scenario in SCENARIOS:
        for rep in range(6):
            assert (runs / scenario / f"rep{rep}.json").is_file()


def test_external_row_names_are_normalized() -> None:
    assert MODULE.normalize("amazon_cellphones<simdjson_ondemand<THREADED>>") == \
        "amazon_cellphones_simdjson_ondemand_THREADED"
    names = MODULE.expected_metric_names(fixtures())
    assert len(names) == 66
    assert "bench_ondemand_amazon_cellphones_simdjson_ondemand_THREADED_ns" in names
    assert len(set(names)) == 66


def test_median_is_used_instead_of_mean(tmp_path: Path) -> None:
    values = {0: 99.0, 1: 100.0, 2: 101.0, 3: 102.0, 4: 300.0, 5: 400.0}

    def skewed(row: str, rep: int) -> float:
        return values[rep] if row == "parse_twitter" else 100.0 + rep

    runs = build_inputs(tmp_path / "case", value_for=skewed)
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode == 0, result.stderr
    payload = json.loads((tmp_path / "results/benchmark_simdjson.json").read_text(encoding="utf-8"))
    metric = payload["results"]["bench_parse_call_parse_twitter_ns"]
    assert metric["value"] == 102.0
    assert payload["samples"]["bench_parse_call_parse_twitter_ns"]["values"] == [100.0, 101.0, 102.0, 300.0, 400.0]
    assert payload["samples"]["bench_parse_call_parse_twitter_ns"]["max"] == 400.0


def test_warmup_round_is_not_measured(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode == 0, result.stderr
    payload = json.loads((tmp_path / "results/benchmark_simdjson.json").read_text(encoding="utf-8"))
    dom = payload["results"]["dom_parse_twitter_gb_per_s"]
    assert dom["value"] == 6.03  # measured rounds 1..5 -> 6.01 .. 6.05
    warmup = json.loads((runs / "dom_parse/rep0.json").read_text(encoding="utf-8"))
    assert warmup["warmup"] is True
    measured = json.loads((runs / "dom_parse/rep1.json").read_text(encoding="utf-8"))
    assert measured["warmup"] is False


def test_rejects_missing_benchmark_row(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "bench_dom_api/rep2.benchmark.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["benchmarks"] = data["benchmarks"][:-1]
    path.write_text(json.dumps(data), encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "differ from fixtures" in result.stderr


def test_rejects_unexpected_benchmark_row(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "bench_ondemand/rep1.benchmark.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["benchmarks"].append({"name": "extra", "run_name": "extra", "run_type": "iteration", "cpu_time": 1.0})
    path.write_text(json.dumps(data), encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "unexpected=['extra']" in result.stderr


def test_rejects_error_row(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "bench_parse_call/rep0.benchmark.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["benchmarks"][0]["error_occurred"] = True
    data["benchmarks"][0]["error_message"] = "did not run"
    path.write_text(json.dumps(data), encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "reported an error" in result.stderr


def test_rejects_duplicate_dom_row(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "dom_parse/rep1.log"
    path.write_text(path.read_text(encoding="utf-8") + '"twitter"\t\t\t\t\t1.0\t2.0\t3.0\n', encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "duplicate row" in result.stderr


def test_rejects_missing_sample_round(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    (runs / "dom_parse_stream/rep3.log").unlink()
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "sample rounds" in result.stderr


def test_rejects_non_positive_value(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case", stream_speed=0.0)
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "finite positive" in result.stderr


def test_rejects_missing_best_speed_line(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    stream = runs / "dom_parse_stream/rep2.log"
    stream.write_text("no summary here\n", encoding="utf-8")
    stream.with_suffix(".err").write_text("no summary here\n", encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "Best speed" in result.stderr


def test_rejects_wrong_reps_argument(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    result = run_parser(runs, tmp_path / "results", reps=4)
    assert result.returncode != 0
    assert "sample rounds" in result.stderr


def test_case_contract_matches_readme() -> None:
    readme = README.read_text(encoding="utf-8")
    assert "指标总数 **66 项**" in readme
    case = (CASE / "case.yaml").read_text(encoding="utf-8")
    for needle in ("path: results", "value_path: value", "unit_path: unit",
                   "direction_path: direction", "group_path: group"):
        assert needle in case
    assert MODULE.EXPECTED_METRIC_COUNT == 66


@pytest.mark.parametrize("field", ["value", "unit", "direction", "group", "values", "median"])
def test_result_and_sample_fields(tmp_path: Path, field: str) -> None:
    runs = build_inputs(tmp_path / "case")
    assert run_parser(runs, tmp_path / "results").returncode == 0
    payload = json.loads((tmp_path / "results/benchmark_simdjson.json").read_text(encoding="utf-8"))
    target = payload["results"] if field in ("value", "unit", "direction", "group") else payload["samples"]
    assert all(field in item for item in target.values())
