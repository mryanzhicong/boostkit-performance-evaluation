#!/usr/bin/env python3
"""Strict parser for the OpenViking v0.5.0 benchmark-kit evidence.

The upstream kit writes raw per-operation telemetry only:

* ``metrics/import_success.csv``             -- one row per committed session; the
  ``telemetry_json`` column carries the per-commit write stage summaries;
* ``metrics/search_telemetry_raw.jsonl``     -- one record per replayed search
  question with the search stage summary and the HTTP wall time;
* ``metrics/qa_results.csv``                 -- one row per LoCoMo QA question;
* ``metrics/agfs_spans.jsonl``               -- AGFS spans of the QA content reads.

This parser turns that evidence into the repository's metric contract.  The
grouping and formulas are exactly the ones the kit's own final report uses
(``analyze.py`` / ``report_local_stages.py`` of the v0.5.0 kit, revision
``b2b3df1``), reproduced here so the host parser stays independent of the
architecture-specific kit layout:

* write local groups (7): commit preparation, archive-summary local work,
  long-term preparation, local extraction, local streaming merge, long-term
  finalisation, and the relations/commit residual;
* search local items (5): query preparation, vector recall, result processing,
  and the two content-read items (AGFS span union, server-side processing).

The first ten metrics are medians over the per-item samples of the single
measured pass (61 write commits, 152 search questions).  The two content-read
items are run-level aggregates by definition -- the kit divides the sum over all
``content.read`` requests by the number of questions -- so they are published as
one aggregate sample per run (``ms/query``) and every per-request value is
retained in ``runs/search_read_samples.jsonl``.

The parser fails closed: missing telemetry, too few samples, absent essential
stages, missing AGFS spans or negative stage durations abort the run instead of
publishing partial numbers.  The only zero that is published on purpose is the
archive-summary group, which the kit's final report also reports as ``0`` while
OpenViking v0.5.0 keeps working memory disabled (``enable_working_memory=false``);
that fact is recorded under ``protocol.zero_by_design_metrics``.
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import NoReturn

WRITE_GROUP = "write"
SEARCH_GROUP = "search"
UNIT = "ms"
DIRECTION = "lower_is_better"

WRITE_RELATION_METRIC = "write_relation_and_commit"

# Leaf-stage groups of the kit's "write local 7 groups" report table (order of
# the report).  Parent stages (branch.*, parallel_extraction, extract_loop,
# streaming_update, merge_wait_apply) are never summed to avoid double counting;
# persist/vector-upsert and the parallel tail are not published as standalone
# metrics in the final kit report.
WRITE_LOCAL_GROUPS: dict[str, list[str]] = {
    "write_commit_prepare": ["context_prepare"],
    "write_archive_summary_local": ["archive_summary.input_prepare", "archive_summary.persist"],
    "write_long_term_prepare": ["long_term.default_files", "long_term.context_prepare"],
    "write_extraction_local": [
        "extract.long_term.prompt_schema",
        "extract.long_term.json_parse",
        "extract.long_term.resolve_operations",
        "extract.long_term.existing_check",
        "extract.long_term.patch_validate",
        "extract.long_term.finalize",
    ],
    "write_streaming_merge_local": [
        "long_term.streaming.route",
        "long_term.streaming.patch_merge",
    ],
    "write_long_term_finalize": ["long_term.memory_diff", "long_term.memory_diff_build"],
}

# Server-side search telemetry groups (per-question samples).  Query Embedding is
# a model call and therefore excluded, as in the kit report.
SEARCH_LOCAL_GROUPS: dict[str, list[str]] = {
    "search_query_prepare": ["request_prepare", "collection_check"],
    "search_vector_recall": ["vector_retrieval"],
    "search_result_processing": ["result_processing"],
}

# Content-read items (run aggregate): AGFS span union per request, and the
# server-side wall time not covered by those spans.
SEARCH_READ_AGFS = "search_read_agfs"
SEARCH_READ_SERVICE = "search_read_service_processing"

# Stages that prove the kit instrumentation is alive; a run without them is a
# broken measurement, not a fast one.  ``archive_summary.*`` is deliberately not
# required: v0.5.0 ships with working memory disabled and the kit reports the
# group as 0 in that case.
REQUIRED_WRITE_STAGES = (
    "context_prepare",
    "parallel_extraction",
    "queue_drain",
    "long_term.default_files",
    "long_term.context_prepare",
    "long_term.streaming.route",
    "long_term.memory_diff",
    "long_term.memory_diff_build",
    "extract.long_term.json_parse",
    "extract.long_term.finalize",
)
REQUIRED_SEARCH_STAGES = (
    "request_prepare",
    "collection_check",
    "vector_retrieval",
    "result_processing",
)

EXPECTED_WRITE_COMMITS = 61
EXPECTED_SEARCH_ROWS = 152
MIN_WRITE_SAMPLES = 50
MIN_SEARCH_SAMPLES = 120
MAX_SEARCH_ERROR_RATIO = 0.02


def fail(message: str) -> NoReturn:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def _duration(stages: dict, name: str) -> float:
    value = stages.get(name)
    if isinstance(value, dict):
        return float(value.get("duration_ms", 0) or 0)
    return 0.0


def _median(values: list[float]) -> float:
    return statistics.median(values) if values else 0.0


def _stats(values: list[float]) -> dict:
    ordered = sorted(values)
    return {
        "n": len(values),
        "median": _median(values),
        "avg": statistics.fmean(values) if values else 0.0,
        "p95": _percentile(ordered, 0.95),
        "min": ordered[0] if ordered else 0.0,
        "max": ordered[-1] if ordered else 0.0,
    }


def _percentile(ordered: list[float], quantile: float) -> float:
    if not ordered:
        return 0.0
    if len(ordered) == 1:
        return ordered[0]
    position = (len(ordered) - 1) * quantile
    lower = int(position)
    upper = min(lower + 1, len(ordered) - 1)
    fraction = position - lower
    return ordered[lower] * (1 - fraction) + ordered[upper] * fraction


def _union_ms(intervals: list[tuple[int, int]]) -> float:
    """Union length of AGFS intervals in ms (same algorithm as the kit)."""
    total = 0.0
    current_start: int | None = None
    current_end = 0
    for start, end in sorted(intervals):
        if current_start is None:
            current_start, current_end = start, end
        elif start <= current_end:
            current_end = max(current_end, end)
        else:
            total += (current_end - current_start) / 1e6
            current_start, current_end = start, end
    if current_start is not None:
        total += (current_end - current_start) / 1e6
    return total


def load_write_commits(run_root: Path) -> list[dict]:
    path = run_root / "metrics" / "import_success.csv"
    if not path.is_file():
        fail(f"the kit write telemetry is missing: {path}")
    commits: list[dict] = []
    with path.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if "telemetry_json" not in (reader.fieldnames or ()):
            fail(f"the kit write telemetry has no telemetry_json column: {path}")
        for row in reader:
            try:
                items = json.loads(row.get("telemetry_json") or "[]")
            except json.JSONDecodeError as error:
                fail(f"invalid telemetry_json in {path}: {error}")
            if not isinstance(items, list):
                fail(f"telemetry_json is not a list in {path}")
            for item in items:
                summary = item.get("summary") if isinstance(item, dict) else None
                if isinstance(summary, dict) and summary:
                    commits.append(summary)
    if not commits:
        fail(f"the kit write telemetry contains no per-commit summaries: {path}")
    return commits


def load_search_records(run_root: Path) -> list[dict]:
    path = run_root / "metrics" / "search_telemetry_raw.jsonl"
    if not path.is_file():
        fail(f"the kit search telemetry is missing: {path}")
    records: list[dict] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as error:
            fail(f"invalid search telemetry line in {path}: {error}")
        if not isinstance(record, dict):
            fail(f"invalid search telemetry record in {path}")
        records.append(record)
    if not records:
        fail(f"the kit search telemetry contains no records: {path}")
    return records


def find_agfs_spans(run_root: Path) -> Path:
    for relative in ("metrics/agfs_spans.jsonl", "agfs_spans.jsonl", "raw_metrics/agfs_spans.jsonl"):
        candidate = run_root / relative
        if candidate.is_file():
            return candidate
    fail(f"the kit AGFS spans are missing under {run_root} (content.read telemetry is required for the five-item search contract)")


def load_agfs_reads(run_root: Path) -> dict:
    """Per-request content.read timings, following the kit's analyze.py.

    ``agfs_ms`` is the union of the AGFS spans of that request (0 when the
    request has no spans); ``service_ms`` is the server-side wall time outside
    that union (the whole wall time when the request has no spans).
    """
    path = find_agfs_spans(run_root)
    http_read: dict[str, float] = {}
    agfs_intervals: dict[str, list[tuple[int, int]]] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(entry, dict):
            continue
        if entry.get("kind") == "http":
            if entry.get("route") == "content.read":
                http_read[str(entry.get("request_id") or "")] = float(entry.get("wall_ms") or 0.0)
        elif entry.get("request_id"):
            agfs_intervals.setdefault(str(entry["request_id"]), []).append(
                (int(entry.get("start_ns") or 0), int(entry.get("end_ns") or 0))
            )
    if not http_read:
        fail(f"the kit AGFS spans contain no content.read requests: {path}")
    rows: list[dict] = []
    without_spans = 0
    agfs_sum = 0.0
    service_sum = 0.0
    for request_id, wall_ms in http_read.items():
        intervals = agfs_intervals.get(request_id)
        if intervals:
            union = _union_ms(intervals)
            agfs_ms = union
            service_ms = max(wall_ms - union, 0.0)
        else:
            without_spans += 1
            agfs_ms = 0.0
            service_ms = wall_ms
        agfs_sum += agfs_ms
        service_sum += service_ms
        rows.append({"request_id": request_id, "agfs_ms": agfs_ms, "service_ms": service_ms})
    return {
        "path": str(path),
        "n_reads": len(rows),
        "reads_without_spans": without_spans,
        "agfs_sum_ms": agfs_sum,
        "service_sum_ms": service_sum,
        "rows": rows,
    }


def write_local_times(summary: dict) -> dict[str, float]:
    stages = summary.get("write", {}).get("stages", {})
    total = float(summary.get("duration_ms", 0) or 0)
    groups = {
        name: sum(_duration(stages, stage) for stage in stages_names)
        for name, stages_names in WRITE_LOCAL_GROUPS.items()
    }
    commit_tail = max(
        total
        - _duration(stages, "context_prepare")
        - _duration(stages, "parallel_extraction")
        - _duration(stages, "queue_drain"),
        0.0,
    )
    # The kit sums ``active_count_update`` too; the v0.5.0 telemetry does not
    # emit that stage, in which case the kit's own report also yields 0 for it.
    groups[WRITE_RELATION_METRIC] = _duration(stages, "active_count_update") + commit_tail
    return groups


def search_local_times(record: dict) -> dict[str, float]:
    summary = record.get("telemetry", {}).get("summary", {}) or {}
    stages = summary.get("search", {}) or {}
    return {
        name: sum(_duration(stages, stage) for stage in stages_names)
        for name, stages_names in SEARCH_LOCAL_GROUPS.items()
    }


def build_metric(name: str, values: list[float], group: str, sample_unit: str, details: dict) -> dict:
    stats = _stats(values)
    return {
        "source_name": name,
        "value": stats["median"],
        "unit": UNIT,
        "direction": DIRECTION,
        "group": group,
        "samples": stats["n"],
        "sample_unit": sample_unit,
        "aggregate": stats,
        "sample_values": [round(value, 6) for value in values],
        "all_samples_retained": True,
        "details": details,
    }


def build_aggregate_metric(name: str, total_ms: float, n_queries: int, details: dict) -> dict:
    """Run-level aggregate metric (one sample) expressed per query."""
    if n_queries <= 0:
        fail(f"cannot normalise {name}: there are no search questions")
    value = total_ms / n_queries
    aggregate = _stats([value])
    aggregate.update({"n_reads": details["n_reads"], "n_queries": n_queries, "total_ms": total_ms})
    return {
        "source_name": name,
        "value": value,
        "unit": UNIT,
        "direction": DIRECTION,
        "group": SEARCH_GROUP,
        "samples": 1,
        "sample_unit": "ms/query (run aggregate)",
        "aggregate": aggregate,
        "sample_values": [round(value, 6)],
        "all_samples_retained": True,
        "details": details,
    }


def parse_run(run_root: Path, args: argparse.Namespace | None) -> tuple[dict, dict[str, dict], list[dict], list[dict]]:
    commits = load_write_commits(run_root)
    records = load_search_records(run_root)
    valid_records = [record for record in records if record.get("telemetry", {}).get("summary")]
    errors = len(records) - len(valid_records)
    if errors / max(len(records), 1) > MAX_SEARCH_ERROR_RATIO:
        fail(f"{errors}/{len(records)} search telemetry records carry no summary; the search instrumentation is broken")
    if len(commits) < MIN_WRITE_SAMPLES:
        fail(f"only {len(commits)} write-commit samples were recorded, at least {MIN_WRITE_SAMPLES} are required")
    if len(valid_records) < MIN_SEARCH_SAMPLES:
        fail(f"only {len(valid_records)} search samples were recorded, at least {MIN_SEARCH_SAMPLES} are required")
    if len(commits) < EXPECTED_WRITE_COMMITS:
        print(
            f"WARNING: the kit protocol normally records {EXPECTED_WRITE_COMMITS} write commits, got {len(commits)}",
            file=sys.stderr,
        )
    if len(valid_records) < EXPECTED_SEARCH_ROWS:
        print(
            f"WARNING: the kit protocol normally records {EXPECTED_SEARCH_ROWS} search rows, got {len(valid_records)}",
            file=sys.stderr,
        )

    first_write_stages = commits[0].get("write", {}).get("stages", {})
    missing_write = [stage for stage in REQUIRED_WRITE_STAGES if stage not in first_write_stages]
    if missing_write:
        fail(f"the write telemetry is missing essential instrumentation stages: {missing_write}")
    first_search_stages = valid_records[0].get("telemetry", {}).get("summary", {}).get("search", {})
    missing_search = [stage for stage in REQUIRED_SEARCH_STAGES if stage not in first_search_stages]
    if missing_search:
        fail(f"the search telemetry is missing essential instrumentation stages: {missing_search}")

    observed_stages: set[str] = set()
    for summary in commits:
        observed_stages.update(summary.get("write", {}).get("stages", {}))

    write_groups: dict[str, list[float]] = {name: [] for name in WRITE_LOCAL_GROUPS}
    write_groups[WRITE_RELATION_METRIC] = []
    negative_write = 0
    for summary in commits:
        local = write_local_times(summary)
        for name, value in local.items():
            if not (value == value) or value in (float("inf"), float("-inf")):
                fail(f"the write stage telemetry contains a non-finite value for {name}")
            if value < 0:
                negative_write += 1
            write_groups[name].append(value)
    if negative_write > 0:
        fail(f"{negative_write} write sample values are negative; the telemetry is inconsistent")

    search_groups: dict[str, list[float]] = {name: [] for name in SEARCH_LOCAL_GROUPS}
    for record in valid_records:
        local = search_local_times(record)
        for name, value in local.items():
            if not (value == value) or value in (float("inf"), float("-inf")):
                fail(f"the search stage telemetry contains a non-finite value for {name}")
            if value < 0:
                fail(f"the search stage telemetry contains a negative value for {name}")
            search_groups[name].append(value)

    reads = load_agfs_reads(run_root)
    n_queries = len(valid_records)

    zero_by_design: list[dict] = []
    metrics: dict[str, dict] = {}
    for name in WRITE_LOCAL_GROUPS:
        stages_names = WRITE_LOCAL_GROUPS[name]
        if not any(stage in observed_stages for stage in stages_names):
            if name == "write_archive_summary_local":
                # The v0.5.0 kit ships with working memory disabled and its final
                # report publishes this group as 0; record why instead of hiding
                # the row.
                zero_by_design.append(
                    {
                        "metric": name,
                        "stages": stages_names,
                        "reason": (
                            "working memory is disabled in the kit protocol (enable_working_memory=false), "
                            "so the kit's final report also reports this group as 0"
                        ),
                    }
                )
            else:
                fail(f"the kit protocol did not instrument the stages of {name}: {stages_names}")
        metrics[name] = build_metric(
            name,
            write_groups[name],
            WRITE_GROUP,
            "ms/commit",
            {
                "pipeline": WRITE_GROUP,
                "stages": stages_names,
                "zero_by_design": name == "write_archive_summary_local"
                and not any(stage in observed_stages for stage in stages_names),
            },
        )
    metrics[WRITE_RELATION_METRIC] = build_metric(
        WRITE_RELATION_METRIC,
        write_groups[WRITE_RELATION_METRIC],
        WRITE_GROUP,
        "ms/commit",
        {
            "pipeline": WRITE_GROUP,
            "stages": ["active_count_update", "commit residual"],
            "formula": (
                "active_count_update + max(duration_ms - context_prepare - parallel_extraction "
                "- queue_drain, 0)"
            ),
        },
    )

    for name, values in search_groups.items():
        metrics[name] = build_metric(
            name,
            values,
            SEARCH_GROUP,
            "ms/query",
            {"pipeline": SEARCH_GROUP, "stages": SEARCH_LOCAL_GROUPS[name]},
        )
    metrics[SEARCH_READ_AGFS] = build_aggregate_metric(
        SEARCH_READ_AGFS,
        reads["agfs_sum_ms"],
        n_queries,
        {
            "pipeline": SEARCH_GROUP,
            "formula": "sum over content.read requests of the union of the AGFS spans, divided by the number of questions",
            "aggregate_over_requests": True,
            "n_reads": reads["n_reads"],
            "reads_without_spans": reads["reads_without_spans"],
        },
    )
    metrics[SEARCH_READ_SERVICE] = build_aggregate_metric(
        SEARCH_READ_SERVICE,
        reads["service_sum_ms"],
        n_queries,
        {
            "pipeline": SEARCH_GROUP,
            "formula": (
                "sum over content.read requests of max(server wall time - AGFS span union, 0), "
                "divided by the number of questions"
            ),
            "aggregate_over_requests": True,
            "n_reads": reads["n_reads"],
            "reads_without_spans": reads["reads_without_spans"],
        },
    )

    qa_rows = 0
    qa_path = run_root / "metrics" / "qa_results.csv"
    if qa_path.is_file():
        with qa_path.open(encoding="utf-8-sig", newline="") as handle:
            qa_rows = sum(1 for _ in csv.DictReader(handle))
    token_savings = None
    savings_path = run_root / "metrics" / "token_savings_summary.json"
    if savings_path.is_file():
        try:
            token_savings = json.loads(savings_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            token_savings = None

    coverage = None
    coverage_path = run_root / "metrics" / "instrumentation_coverage.json"
    if coverage_path.is_file():
        try:
            coverage = json.loads(coverage_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            coverage = None

    protocol = {
        "write_commits": len(commits),
        "write_commit_samples": len(commits),
        "write_stage_count": len(observed_stages),
        "search_rows": len(valid_records),
        "search_error_rows": errors,
        "expected_write_commits": EXPECTED_WRITE_COMMITS,
        "expected_search_rows": EXPECTED_SEARCH_ROWS,
        "qa_rows": qa_rows,
        "read_requests": reads["n_reads"],
        "read_requests_without_agfs_spans": reads["reads_without_spans"],
        "negative_write_samples": negative_write,
        "zero_by_design_metrics": zero_by_design,
        "omitted_metrics": [],
        "instrumentation_coverage": coverage,
        "token_savings_summary": token_savings,
    }
    return protocol, metrics, commits, reads["rows"]


def write_run_samples(runs_dir: Path, metrics: dict[str, dict], read_samples: list[dict] | None = None) -> None:
    runs_dir.mkdir(parents=True, exist_ok=True)
    write_names = list(WRITE_LOCAL_GROUPS) + [WRITE_RELATION_METRIC]
    write_rows = []
    count = max((len(metrics[name]["sample_values"]) for name in write_names), default=0)
    for index in range(count):
        row = {"rep": index + 1, "pipeline": WRITE_GROUP}
        for name in write_names:
            values = metrics[name]["sample_values"]
            if index < len(values):
                row[name] = values[index]
        write_rows.append(row)
    with (runs_dir / "write_samples.jsonl").open("w", encoding="utf-8") as handle:
        for row in write_rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    search_names = list(SEARCH_LOCAL_GROUPS)
    search_rows = []
    count = max((len(metrics[name]["sample_values"]) for name in search_names), default=0)
    for index in range(count):
        row = {"rep": index + 1, "pipeline": SEARCH_GROUP}
        for name in search_names:
            values = metrics[name]["sample_values"]
            if index < len(values):
                row[name] = values[index]
        search_rows.append(row)
    with (runs_dir / "search_samples.jsonl").open("w", encoding="utf-8") as handle:
        for row in search_rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    read_rows = read_samples or []
    with (runs_dir / "search_read_samples.jsonl").open("w", encoding="utf-8") as handle:
        for index, sample in enumerate(read_rows):
            row = {
                "rep": index + 1,
                "pipeline": "search_read",
                "request_id": sample.get("request_id", ""),
                "agfs_ms": round(float(sample.get("agfs_ms", 0.0)), 6),
                "service_ms": round(float(sample.get("service_ms", 0.0)), 6),
            }
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    (runs_dir / "metric_summary.json").write_text(
        json.dumps({name: metric["aggregate"] for name, metric in metrics.items()}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Parse the OpenViking benchmark-kit evidence")
    parser.add_argument("--run-root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--runs", required=True, type=Path)
    parser.add_argument("--software-version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--variant", required=True)
    parser.add_argument("--source-commit", default="")
    parser.add_argument("--kit-sha256", default="")
    parser.add_argument("--kit-archive", default="")
    parser.add_argument("--mock-model", default="")
    parser.add_argument("--mock-embedding-model", default="")
    args = parser.parse_args()

    if args.variant not in ("base", "optimized"):
        fail(f"invalid variant: {args.variant!r}")
    if not args.run_root.is_dir():
        fail(f"the kit run directory does not exist: {args.run_root}")

    protocol, metrics, _commits, read_samples = parse_run(args.run_root, args)

    env_info = {}
    env_path = args.run_root / "metrics" / "env_info.json"
    if env_path.is_file():
        try:
            env_info = json.loads(env_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            env_info = {}

    payload = {
        "software": "openviking",
        "version": args.software_version,
        "variant": args.variant,
        "architecture": args.architecture,
        "run_id": args.run_id,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "benchmark_kit": {
            "archive": args.kit_archive,
            "sha256": args.kit_sha256,
            "source_commit": args.source_commit,
            "protocol": "OpenViking v0.5.0 container benchmark kit, seven-step protocol (write, search, QA, coverage, reports)",
            "out_of_the_box": True,
            "numa_binding": False,
            "cpuset_pinning": False,
        },
        "providers": {
            "llm": args.mock_model,
            "embedding": args.mock_embedding_model,
            "external_network": False,
            "note": "deterministic local OpenAI-compatible mock; timings are meaningful, answer quality and token savings are not",
        },
        "environment": env_info,
        "protocol": protocol,
        "results": metrics,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(args.output)
    write_run_samples(args.runs, metrics, read_samples)

    for name in sorted(metrics):
        metric = metrics[name]
        print(
            f"{name}: {metric['value']:.3f} {metric['unit']} "
            f"({metric['samples']} samples, group={metric['group']})"
        )
    print(f"wrote {args.output} and {args.runs}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
