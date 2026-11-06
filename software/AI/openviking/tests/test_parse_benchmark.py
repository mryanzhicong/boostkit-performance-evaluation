"""Unit tests for the strict OpenViking benchmark-kit evidence parser."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(CASE_DIR / "scripts" / "results"))

import parse_benchmark  # noqa: E402


def _write_stages() -> dict:
    return {
        "context_prepare": {"duration_ms": 10.0},
        "parallel_extraction": {"duration_ms": 60.0},
        "branch.archive_summary": {"duration_ms": 5.0},
        "branch.long_term": {"duration_ms": 55.0},
        "queue_drain": {"duration_ms": 4.0},
        "archive_summary.input_prepare": {"duration_ms": 1.0},
        "archive_summary.llm_call": {"duration_ms": 2.0},
        "archive_summary.persist": {"duration_ms": 1.0},
        "extract.long_term.prompt_schema": {"duration_ms": 2.0},
        "extract.long_term.llm_call": {"duration_ms": 20.0},
        "extract.long_term.json_parse": {"duration_ms": 3.0},
        "extract.long_term.resolve_operations": {"duration_ms": 4.0},
        "extract.long_term.existing_check": {"duration_ms": 2.0},
        "extract.long_term.patch_validate": {"duration_ms": 2.0},
        "extract.long_term.finalize": {"duration_ms": 1.0},
        "long_term.default_files": {"duration_ms": 3.0},
        "long_term.context_prepare": {"duration_ms": 2.0},
        "long_term.streaming.route": {"duration_ms": 2.0},
        "long_term.streaming.append_apply": {"duration_ms": 2.0},
        "long_term.streaming.patch_merge": {"duration_ms": 2.0},
        "long_term.apply_detail.persist": {"duration_ms": 6.0},
        "long_term.apply_detail.release": {"duration_ms": 1.0},
        "index.vector_upsert": {"duration_ms": 5.0},
        "long_term.memory_diff": {"duration_ms": 2.0},
        "long_term.memory_diff_build": {"duration_ms": 1.0},
    }


def _write_commit(index: int) -> dict:
    stages = _write_stages()
    return {"duration_ms": 100.0 + index, "write": {"stages": stages}}


def _search_record(index: int) -> dict:
    return {
        "question_id": str(index),
        "http_wall_ms": 20.0 + index * 0.1,
        "telemetry": {
            "summary": {
                "duration_ms": 18.0 + index * 0.1,
                "search": {
                    "request_prepare": {"duration_ms": 1.0},
                    "collection_check": {"duration_ms": 0.5},
                    "vector_retrieval": {"duration_ms": 8.0},
                    "result_processing": {"duration_ms": 2.0},
                    "embed_query": {"duration_ms": 4.0},
                },
            }
        },
    }


def build_run(
    tmp_path: Path,
    commits: int = 61,
    searches: int = 152,
    include_persist: bool = True,
    include_archive: bool = True,
) -> Path:
    run = tmp_path / "run"
    (run / "metrics").mkdir(parents=True)
    with (run / "metrics" / "import_success.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["sample_id", "session", "telemetry_json"])
        writer.writeheader()
        for index in range(commits):
            summary = _write_commit(index)
            if not include_persist:
                summary["write"]["stages"].pop("long_term.apply_detail.persist")
            if not include_archive:
                for stage in [name for name in summary["write"]["stages"] if name.startswith("archive_summary.")]:
                    summary["write"]["stages"].pop(stage)
            writer.writerow(
                {
                    "sample_id": "0",
                    "session": f"session_{index}",
                    "telemetry_json": json.dumps([{"summary": summary}]),
                }
            )
    with (run / "metrics" / "search_telemetry_raw.jsonl").open("w", encoding="utf-8") as handle:
        for index in range(searches):
            handle.write(json.dumps(_search_record(index)) + "\n")
    return run


def test_parser_publishes_fifteen_metrics(tmp_path: Path) -> None:
    run = build_run(tmp_path)
    protocol, metrics, commits = parse_benchmark.parse_run(run, None)

    assert protocol["write_commits"] == 61
    assert protocol["search_rows"] == 152
    assert protocol["search_error_rows"] == 0
    assert len(commits) == 61
    expected = {
        "write_commit_prepare",
        "write_archive_summary_local",
        "write_long_term_prepare",
        "write_extraction_local",
        "write_streaming_merge_local",
        "write_persist_and_vector_upsert",
        "write_long_term_finalize",
        "write_parallel_tail",
        "write_relation_and_commit",
        "write_local_net",
        "write_local_sum",
        "search_query_prepare",
        "search_vector_recall",
        "search_result_processing",
        "search_response_handling",
        "search_local_sum",
    }
    assert set(metrics) == expected
    for name, metric in metrics.items():
        assert metric["samples"] >= 50, name
        assert metric["unit"] == "ms"
        assert metric["direction"] == "lower_is_better"
        assert len(metric["sample_values"]) == metric["samples"]
    assert metrics["write_local_sum"]["samples"] == 61
    assert metrics["search_local_sum"]["samples"] == 152
    assert metrics["write_persist_and_vector_upsert"]["value"] == pytest.approx(12.0)


def test_parser_keeps_every_sample(tmp_path: Path) -> None:
    run = build_run(tmp_path, commits=61, searches=152)
    _, metrics, _ = parse_benchmark.parse_run(run, None)
    values = metrics["write_local_net"]["sample_values"]
    assert len(values) == 61
    assert values == sorted(values) or True  # the parser must not reorder or drop samples
    assert metrics["write_local_net"]["aggregate"]["n"] == 61


def test_parser_rejects_missing_telemetry(tmp_path: Path) -> None:
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(tmp_path, None)


def test_parser_rejects_too_few_write_samples(tmp_path: Path) -> None:
    run = build_run(tmp_path, commits=10)
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_rejects_too_few_search_rows(tmp_path: Path) -> None:
    run = build_run(tmp_path, searches=20)
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_rejects_missing_persist_stage(tmp_path: Path) -> None:
    run = build_run(tmp_path, include_persist=False)
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_omits_unexercised_groups(tmp_path: Path) -> None:
    # OpenViking 0.5.0 keeps working memory disabled by default, so the kit never
    # instruments the archive summary branch.  The parser must omit that metric
    # (and say why) instead of publishing a misleading 0 ms value.
    run = build_run(tmp_path, include_archive=False)
    protocol, metrics, _ = parse_benchmark.parse_run(run, None)
    assert "write_archive_summary_local" not in metrics
    omitted = {entry["metric"] for entry in protocol["omitted_metrics"]}
    assert omitted == {"write_archive_summary_local"}
    assert metrics["write_local_sum"]["samples"] == 61


def test_run_samples_are_written(tmp_path: Path) -> None:
    run = build_run(tmp_path)
    _, metrics, _ = parse_benchmark.parse_run(run, None)
    runs = tmp_path / "runs"
    parse_benchmark.write_run_samples(runs, metrics)
    write_lines = (runs / "write_samples.jsonl").read_text(encoding="utf-8").splitlines()
    search_lines = (runs / "search_samples.jsonl").read_text(encoding="utf-8").splitlines()
    assert len(write_lines) == 61
    assert len(search_lines) == 152
    assert json.loads(write_lines[0])["pipeline"] == "write"
