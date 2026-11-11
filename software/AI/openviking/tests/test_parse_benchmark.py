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


def _read_spans(index: int) -> list[dict]:
    """One content.read request per question, with two overlapping AGFS spans.

    The union is 10 ms while the server wall time is 12 ms, so every request
    contributes 10 ms to the AGFS item and 2 ms to the service item.
    """
    request_id = f"req-{index}"
    return [
        {"kind": "http", "route": "content.read", "request_id": request_id, "wall_ms": 12.0},
        {"kind": "agfs", "request_id": request_id, "start_ns": 0, "end_ns": 6_000_000},
        {"kind": "agfs", "request_id": request_id, "start_ns": 4_000_000, "end_ns": 10_000_000},
    ]


def build_run(
    tmp_path: Path,
    commits: int = 61,
    searches: int = 152,
    include_archive: bool = True,
    include_agfs: bool = True,
    drop_write_stages: tuple[str, ...] = (),
    drop_search_stages: tuple[str, ...] = (),
    negative_stage: str | None = None,
) -> Path:
    run = tmp_path / "run"
    (run / "metrics").mkdir(parents=True)
    with (run / "metrics" / "import_success.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["sample_id", "session", "telemetry_json"])
        writer.writeheader()
        for index in range(commits):
            summary = _write_commit(index)
            stages = summary["write"]["stages"]
            if not include_archive:
                for stage in [name for name in stages if name.startswith("archive_summary.")]:
                    stages.pop(stage)
            for stage in drop_write_stages:
                stages.pop(stage, None)
            if negative_stage is not None:
                stages[negative_stage] = {"duration_ms": -1.0}
            writer.writerow(
                {
                    "sample_id": "0",
                    "session": f"session_{index}",
                    "telemetry_json": json.dumps([{"summary": summary}]),
                }
            )
    with (run / "metrics" / "search_telemetry_raw.jsonl").open("w", encoding="utf-8") as handle:
        for index in range(searches):
            record = _search_record(index)
            for stage in drop_search_stages:
                record["telemetry"]["summary"]["search"].pop(stage, None)
            handle.write(json.dumps(record) + "\n")
    if include_agfs:
        with (run / "metrics" / "agfs_spans.jsonl").open("w", encoding="utf-8") as handle:
            for index in range(searches):
                for entry in _read_spans(index):
                    handle.write(json.dumps(entry) + "\n")
    return run


def test_parser_publishes_the_final_report_metrics(tmp_path: Path) -> None:
    run = build_run(tmp_path)
    protocol, metrics, commits, read_samples = parse_benchmark.parse_run(run, None)

    assert protocol["write_commits"] == 61
    assert protocol["search_rows"] == 152
    assert protocol["search_error_rows"] == 0
    assert protocol["read_requests"] == 152
    assert protocol["read_requests_without_agfs_spans"] == 0
    assert len(commits) == 61
    assert len(read_samples) == 152
    expected = {
        "write_commit_prepare",
        "write_archive_summary_local",
        "write_long_term_prepare",
        "write_extraction_local",
        "write_streaming_merge_local",
        "write_long_term_finalize",
        "write_relation_and_commit",
        "search_query_prepare",
        "search_vector_recall",
        "search_result_processing",
        "search_read_agfs",
        "search_read_service_processing",
    }
    assert set(metrics) == expected
    for name, metric in metrics.items():
        assert metric["unit"] == "ms"
        assert metric["direction"] == "lower_is_better"
        assert metric["group"] in {"write", "search"}
        assert len(metric["sample_values"]) == metric["samples"], name
    for name in (
        "write_commit_prepare",
        "write_archive_summary_local",
        "write_long_term_prepare",
        "write_extraction_local",
        "write_streaming_merge_local",
        "write_long_term_finalize",
        "write_relation_and_commit",
    ):
        assert metrics[name]["samples"] == 61, name
    for name in ("search_query_prepare", "search_vector_recall", "search_result_processing"):
        assert metrics[name]["samples"] == 152, name
    for name in ("search_read_agfs", "search_read_service_processing"):
        assert metrics[name]["samples"] == 1, name
        assert metrics[name]["sample_unit"] == "ms/query (run aggregate)"

    # Write groups: the fixture stages sum to the values below; the relations
    # metric is active_count_update (absent -> 0) plus the commit residual.
    assert metrics["write_commit_prepare"]["value"] == pytest.approx(10.0)
    assert metrics["write_archive_summary_local"]["value"] == pytest.approx(2.0)
    assert metrics["write_long_term_prepare"]["value"] == pytest.approx(5.0)
    assert metrics["write_extraction_local"]["value"] == pytest.approx(14.0)
    assert metrics["write_streaming_merge_local"]["value"] == pytest.approx(4.0)
    assert metrics["write_long_term_finalize"]["value"] == pytest.approx(3.0)
    assert metrics["write_relation_and_commit"]["value"] == pytest.approx(56.0)  # 26 + index, index=30
    # Search groups and the two run-aggregate content-read items.
    assert metrics["search_query_prepare"]["value"] == pytest.approx(1.5)
    assert metrics["search_vector_recall"]["value"] == pytest.approx(8.0)
    assert metrics["search_result_processing"]["value"] == pytest.approx(2.0)
    assert metrics["search_read_agfs"]["value"] == pytest.approx(10.0)
    assert metrics["search_read_service_processing"]["value"] == pytest.approx(2.0)


def test_parser_keeps_every_sample(tmp_path: Path) -> None:
    run = build_run(tmp_path)
    _, metrics, _, read_samples = parse_benchmark.parse_run(run, None)
    write_values = metrics["write_commit_prepare"]["sample_values"]
    assert len(write_values) == 61
    assert metrics["write_commit_prepare"]["aggregate"]["n"] == 61
    assert metrics["write_relation_and_commit"]["aggregate"]["n"] == 61
    assert metrics["search_query_prepare"]["aggregate"]["n"] == 152
    assert len(read_samples) == 152
    assert metrics["search_read_agfs"]["aggregate"]["n_reads"] == 152
    assert metrics["search_read_agfs"]["aggregate"]["n_queries"] == 152
    assert metrics["search_read_agfs"]["aggregate"]["total_ms"] == pytest.approx(1520.0)


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


def test_parser_rejects_missing_agfs_spans(tmp_path: Path) -> None:
    run = build_run(tmp_path, include_agfs=False)
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_rejects_missing_write_stage(tmp_path: Path) -> None:
    run = build_run(tmp_path, drop_write_stages=("long_term.memory_diff",))
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_rejects_missing_search_stage(tmp_path: Path) -> None:
    run = build_run(tmp_path, drop_search_stages=("collection_check",))
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_rejects_negative_stage_duration(tmp_path: Path) -> None:
    run = build_run(tmp_path, negative_stage="context_prepare")
    with pytest.raises(SystemExit):
        parse_benchmark.parse_run(run, None)


def test_parser_publishes_zero_archive_group_by_design(tmp_path: Path) -> None:
    # OpenViking 0.5.0 keeps working memory disabled by default, so the kit never
    # instruments the archive-summary branch.  The kit's final report publishes
    # that group as 0; the parser does the same and records the reason.
    run = build_run(tmp_path, include_archive=False)
    protocol, metrics, _, _ = parse_benchmark.parse_run(run, None)
    assert metrics["write_archive_summary_local"]["value"] == pytest.approx(0.0)
    assert metrics["write_archive_summary_local"]["samples"] == 61
    assert metrics["write_archive_summary_local"]["details"]["zero_by_design"] is True
    zero_by_design = {entry["metric"] for entry in protocol["zero_by_design_metrics"]}
    assert zero_by_design == {"write_archive_summary_local"}
    assert protocol["omitted_metrics"] == []
    assert set(metrics) == {
        "write_commit_prepare",
        "write_archive_summary_local",
        "write_long_term_prepare",
        "write_extraction_local",
        "write_streaming_merge_local",
        "write_long_term_finalize",
        "write_relation_and_commit",
        "search_query_prepare",
        "search_vector_recall",
        "search_result_processing",
        "search_read_agfs",
        "search_read_service_processing",
    }


def test_run_samples_are_written(tmp_path: Path) -> None:
    run = build_run(tmp_path)
    _, metrics, _, read_samples = parse_benchmark.parse_run(run, None)
    runs = tmp_path / "runs"
    parse_benchmark.write_run_samples(runs, metrics, read_samples)
    write_lines = (runs / "write_samples.jsonl").read_text(encoding="utf-8").splitlines()
    search_lines = (runs / "search_samples.jsonl").read_text(encoding="utf-8").splitlines()
    read_lines = (runs / "search_read_samples.jsonl").read_text(encoding="utf-8").splitlines()
    assert len(write_lines) == 61
    assert len(search_lines) == 152
    assert len(read_lines) == 152
    assert json.loads(write_lines[0])["pipeline"] == "write"
    first_search = json.loads(search_lines[0])
    assert set(first_search) == {
        "rep",
        "pipeline",
        "search_query_prepare",
        "search_vector_recall",
        "search_result_processing",
    }
    first_read = json.loads(read_lines[0])
    assert first_read["pipeline"] == "search_read"
    assert first_read["agfs_ms"] == pytest.approx(10.0)
    assert first_read["service_ms"] == pytest.approx(2.0)
    summary = json.loads((runs / "metric_summary.json").read_text(encoding="utf-8"))
    assert "search_read_agfs" in summary
