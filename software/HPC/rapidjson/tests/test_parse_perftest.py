"""Contract tests for the strict RapidJSON perftest parser."""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
PARSER = CASE / "scripts/results/parse_perftest.py"
FIXTURES = CASE / "fixtures/scenarios.json"
README = CASE / "README.md"

SPEC = importlib.util.spec_from_file_location("rapidjson_perftest_parser", PARSER)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

SUMMARY = "[==========] 1 test from 1 test suite ran. ({} ms total)"


def fixtures() -> dict:
    return json.loads(FIXTURES.read_text(encoding="utf-8"))


def write_round(directory: Path, base_case: str, rep: int, ms: int, *,
                suffix: str = "SSE42", iterations: int = 5, failures: int = 0,
                testcase_name: str | None = None) -> None:
    lines: list[str] = []
    for _ in range(iterations):
        lines.append("[==========] Running 1 test from 1 test suite.")
        lines.append("[----------] 1 test from RapidJson")
        lines.append(f"[       OK ] RapidJson.{base_case}_{suffix} (1 ms)")
        lines.append(SUMMARY.format(ms))
        lines.append("[  PASSED  ] 1 test.")
    (directory / f"rep{rep}.log").write_text("\n".join(lines) + "\n", encoding="utf-8")
    (directory / f"rep{rep}.err").write_text("", encoding="utf-8")
    name = testcase_name or f"{base_case}_{suffix}"
    (directory / f"rep{rep}.xml").write_text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        f"<testsuites tests=\"1\" failures=\"{failures}\" disabled=\"0\" errors=\"0\" time=\"0.1\" name=\"AllTests\">\n"
        f"  <testsuite name=\"RapidJson\" tests=\"1\" failures=\"{failures}\" disabled=\"0\" skipped=\"0\" errors=\"0\" time=\"0.1\">\n"
        f"    <testcase name=\"{name}\" file=\"rapidjsontest.cpp\" line=\"217\" status=\"run\" "
        "result=\"completed\" time=\"0.1\" classname=\"RapidJson\" />\n"
        "  </testsuite>\n"
        "</testsuites>\n",
        encoding="utf-8",
    )


def build_inputs(root: Path, reps: int = 5, warmups: int = 1, ms_for=None,
                 suffix: str = "SSE42") -> Path:
    data = fixtures()
    runs = root / "runs"
    for item in data["scenarios"]:
        (runs / item["name"]).mkdir(parents=True)
    for rep in range(warmups + reps):
        for item in data["scenarios"]:
            ms = ms_for(item["name"], rep) if ms_for else 10
            write_round(runs / item["name"], item["case"], rep, ms, suffix=suffix)
    return runs


def run_parser(runs: Path, results: Path, reps: int = 5, warmups: int = 1) -> subprocess.CompletedProcess:
    command = [
        sys.executable, str(PARSER),
        "--runs-dir", str(runs), "--results-dir", str(results),
        "--fixtures", str(FIXTURES),
        "--warmups", str(warmups), "--reps", str(reps),
        "--version", "1.1.0", "--architecture", "x86_64",
        "--variant", "base", "--run-id", "test-run",
    ]
    return subprocess.run(command, text=True, capture_output=True, check=False)


def read_result(results: Path) -> dict:
    return json.loads((results / "perftest_result.json").read_text(encoding="utf-8"))


def test_full_run_produces_sixteen_metrics(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode == 0, result.stderr
    payload = read_result(tmp_path / "results")
    assert len(payload["results"]) == 16
    assert payload["sampling"] == {
        "warmups": 1,
        "reps": 5,
        "aggregation": "median",
        "samples_per_metric": 5,
        "metric_count": 16,
    }
    assert payload["results"]["dom_parse_ns_per_op"]["unit"] == "ns/op"
    assert payload["results"]["dom_parse_ns_per_op"]["direction"] == "lower_is_better"
    assert payload["results"]["dom_parse_gb_per_s"]["unit"] == "GB/s"
    assert payload["results"]["dom_parse_gb_per_s"]["direction"] == "higher_is_better"
    assert payload["results"]["dom_parse_ns_per_op"]["group"] == "dom_parse"
    # 5 iterations x 10 ms for 1000 operations: 50 ms -> 10000 ns/op.
    assert payload["results"]["dom_parse_ns_per_op"]["value"] == 10000.0
    # 687,491 bytes x 5 x 1000 operations / 50 ms -> 68.7491 GB/s.
    assert payload["results"]["dom_parse_gb_per_s"]["value"] == 68.7491
    assert payload["results"]["sax_parse_paragraphs_ns_per_op"]["value"] == 1000.0
    assert payload["results"]["sax_parse_paragraphs_gb_per_s"]["value"] == 33.764
    for item in fixtures()["scenarios"]:
        assert (runs / item["name"] / "rep0.json").is_file()
        warmup = json.loads((runs / item["name"] / "rep0.json").read_text(encoding="utf-8"))
        measured = json.loads((runs / item["name"] / "rep1.json").read_text(encoding="utf-8"))
        assert warmup["warmup"] is True
        assert measured["warmup"] is False
        assert measured["testcase"] == f"{item['case']}_SSE42"


def test_median_of_measured_rounds_is_used(tmp_path: Path) -> None:
    def ms_for(_scenario: str, rep: int) -> int:
        return (rep + 1) * 10

    runs = build_inputs(tmp_path / "case", ms_for=ms_for)
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode == 0, result.stderr
    payload = read_result(tmp_path / "results")
    metric = payload["results"]["dom_parse_ns_per_op"]
    # rounds 1..5 sum to 100..500 ms -> 20000..60000 ns/op, median 40000.
    assert metric["value"] == 40000.0
    assert payload["samples"]["dom_parse_ns_per_op"]["values"] == [
        20000.0, 30000.0, 40000.0, 50000.0, 60000.0,
    ]
    assert payload["samples"]["dom_parse_ns_per_op"]["samples"] == 5


def test_rejects_wrong_iteration_count(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "dom_parse/rep2.log"
    lines = path.read_text(encoding="utf-8").splitlines()
    path.write_text("\n".join(lines[:-5]) + "\n", encoding="utf-8")  # drop one iteration
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "expected 5" in result.stderr


def test_rejects_non_positive_time(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "sax_parse/rep1.log"
    path.write_text(path.read_text(encoding="utf-8").replace("(10 ms total)", "(0 ms total)"),
                    encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "non-positive" in result.stderr


def test_rejects_failed_case(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "writer_string_buffer/rep0.log"
    path.write_text(path.read_text(encoding="utf-8") + "[  FAILED  ] 1 test, listed below:\n",
                    encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "failing gtest case" in result.stderr


def test_rejects_missing_xml(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    (runs / "pretty_writer_string_buffer/rep1.xml").unlink()
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "xml rounds" in result.stderr


def test_rejects_xml_failure(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    base_case = fixtures()["scenarios"][0]["case"]
    write_round(runs / "dom_parse", base_case, 1, 10, failures=1)
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "failures=1" in result.stderr


def test_rejects_two_testcases_in_xml(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    path = runs / "dom_parse/rep1.xml"
    text = path.read_text(encoding="utf-8").replace(
        "</testsuite>",
        "    <testcase name=\"DocumentParse_MemoryPoolAllocator_SSE42\" classname=\"RapidJson\" />\n  </testsuite>",
    )
    path.write_text(text, encoding="utf-8")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "exactly one testcase" in result.stderr


def test_rejects_wrong_architecture_suffix(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    item = fixtures()["scenarios"][2]
    write_round(runs / item["name"], item["case"], 1, 10, suffix="AVX2")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "does not match" in result.stderr


def test_rejects_suffix_change_between_rounds(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    item = fixtures()["scenarios"][0]
    write_round(runs / item["name"], item["case"], 2, 10, suffix="SSE2")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "suffix changed" in result.stderr


def test_rejects_missing_scenario_directory(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    import shutil

    shutil.rmtree(runs / "sax_parse_paragraphs")
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "scenario directories differ" in result.stderr


def test_rejects_unexpected_scenario_directory(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    (runs / "extra_scenario").mkdir()
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "scenario directories differ" in result.stderr


def test_rejects_missing_sample_round(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    (runs / "sax_parse/rep3.log").unlink()
    result = run_parser(runs, tmp_path / "results")
    assert result.returncode != 0
    assert "log rounds" in result.stderr


def test_rejects_fewer_than_five_measured_rounds(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case", reps=4)
    result = run_parser(runs, tmp_path / "results", reps=4)
    assert result.returncode != 0
    assert "at least 5" in result.stderr


def test_result_fields_and_contract(tmp_path: Path) -> None:
    runs = build_inputs(tmp_path / "case")
    assert run_parser(runs, tmp_path / "results").returncode == 0
    payload = read_result(tmp_path / "results")
    for item in payload["results"].values():
        assert {"value", "unit", "direction", "group"} <= set(item)
    for item in payload["samples"].values():
        assert {"values", "median", "min", "max", "samples"} <= set(item)
    assert MODULE.EXPECTED_METRIC_COUNT == 16
    assert len(fixtures()["scenarios"]) * 2 == 16
    readme = README.read_text(encoding="utf-8")
    assert "指标总数 **16 项**" in readme
    case = (CASE / "case.yaml").read_text(encoding="utf-8")
    for needle in ("path: results", "value_path: value", "unit_path: unit",
                   "direction_path: direction", "group_path: group"):
        assert needle in case, needle
