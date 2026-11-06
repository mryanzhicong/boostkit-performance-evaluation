#!/usr/bin/env python3
"""Strict parser for the OpenViking v0.5.0 benchmark-kit evidence.

The upstream kit writes raw per-operation telemetry only:

* ``metrics/import_success.csv``             -- one row per committed session; the
  ``telemetry_json`` column carries the per-commit write stage summaries;
* ``metrics/search_telemetry_raw.jsonl``     -- one record per replayed search
  question with the search stage summary and the HTTP wall time;
* ``metrics/qa_results.csv``                 -- one row per LoCoMo QA question;
* ``metrics/agfs_spans.jsonl``               -- AGFS spans (kept as evidence).

This parser turns that evidence into the repository's metric contract.  The
grouping and local-time formulas are the ones published with the kit
(``analyze.py`` in the v0.5.0 kit), reproduced here so the host parser stays
independent of the architecture-specific kit layout:

* write local groups: the seven leaf-stage groups of the write pipeline, plus the
  two residual groups (parallel tail, relations/commit);
* search local groups: query preparation, vector recall, result processing, and
  the HTTP response handling residual.

Sampling contract: the kit protocol is a single end-to-end pass, but every
published metric is the median over the individual samples of that pass
(61 write commits, 152 search questions) and every sample is retained in the run
directory.  The parser fails closed: missing telemetry, too few samples, absent
essential stages or corrupted (negative) local times abort the run instead of
publishing partial numbers.
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

WINDOW_SUFFIX = ".window_wait"

# Leaf stage groups copied from the kit's analyze.py (v0.5.0).  The names are the
# instrumentation stage names emitted by the kit overlay.
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
        "long_term.streaming.append_apply",
        "long_term.streaming.patch_merge",
        "long_term.streaming.merge_detail.group_prepare",
        "long_term.streaming.merge_detail.enqueue",
        "long_term.streaming.merge_detail.dispatch_wait",
        "long_term.streaming.merge_detail.batch_execute",
        "long_term.streaming.merge_detail.result_return",
        "long_term.streaming.merge_detail.group_join",
        "long_term.streaming.merge_detail.result_combine",
        "long_term.streaming.merge_detail.post_group_links",
    ],
    "write_persist_and_vector_upsert": [
        "long_term.apply_detail.lock_wait",
        "long_term.apply_detail.path_lease",
        "long_term.apply_detail.persist",
        "long_term.apply_detail.release",
        "index.vector_upsert",
    ],
    "write_long_term_finalize": ["long_term.memory_diff", "long_term.memory_diff_build"],
}

SEARCH_LOCAL_GROUPS: dict[str, list[str]] = {
    "search_query_prepare": ["request_prepare", "collection_check"],
    "search_vector_recall": ["vector_retrieval"],
    "search_result_processing": ["result_processing"],
}

# Stages that prove the kit instrumentation is alive; a run without them is a
# broken measurement, not a fast one.
REQUIRED_WRITE_STAGES = (
    "context_prepare",
    "parallel_extraction",
    "queue_drain",
    "extract.long_term.json_parse",
    "long_term.apply_detail.persist",
)
REQUIRED_SEARCH_STAGES = ("request_prepare", "vector_retrieval")

EXPECTED_WRITE_COMMITS = 61
EXPECTED_SEARCH_ROWS = 152
MIN_WRITE_SAMPLES = 50
MIN_SEARCH_SAMPLES = 120
MAX_SEARCH_ERROR_RATIO = 0.02
MAX_NEGATIVE_RATIO = 0.05


def fail(message: str) -> NoReturn:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def _duration(stages: dict, name: str) -> float:
    value = stages.get(name)
    if isinstance(value, dict):
        return float(value.get("duration_ms", 0) or 0)
    return 0.0


def _is_model_stage(name: str) -> bool:
    return name.endswith(".llm_call") or "embedding" in name or "embed_query" in name


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


def write_local_times(summary: dict) -> dict[str, float]:
    stages = summary.get("write", {}).get("stages", {})
    total = float(summary.get("duration_ms", 0) or 0)
    groups = {name: sum(_duration(stages, stage) for stage in names) for name, names in WRITE_LOCAL_GROUPS.items()}
    parallel = _duration(stages, "parallel_extraction")
    branches = max(_duration(stages, "branch.archive_summary"), _duration(stages, "branch.long_term"))
    groups["write_parallel_tail"] = max(parallel - branches, 0.0)
    commit_tail = max(total - _duration(stages, "context_prepare") - parallel - _duration(stages, "queue_drain"), 0.0)
    groups["write_relation_and_commit"] = _duration(stages, "queue_drain") + commit_tail
    merge_llm = _duration(stages, "long_term.streaming.merge_detail.llm_call")
    if merge_llm > 0:
        groups["write_streaming_merge_local"] = max(
            groups["write_streaming_merge_local"]
            - _duration(stages, "long_term.streaming.patch_merge")
            - _duration(stages, "long_term.streaming.merge_detail.batch_execute"),
            0.0,
        )
    return groups


def write_local_net(summary: dict) -> float:
    stages = summary.get("write", {}).get("stages", {})
    total = float(summary.get("duration_ms", 0) or 0)
    archive_model = sum(
        _duration(stages, name)
        for name in stages
        if name.startswith("archive_summary.") and _is_model_stage(name)
    )
    extraction_model = sum(
        _duration(stages, name)
        for name in stages
        if name.startswith("extract.long_term.") and _is_model_stage(name)
    )
    merge_llm = _duration(stages, "long_term.streaming.merge_detail.llm_call")
    merge_wall = _duration(stages, "long_term.streaming.merge_detail.batch_execute")
    long_term_model = extraction_model + (min(merge_llm, merge_wall) if merge_llm > 0 else 0.0)
    window_wait = sum(_duration(stages, name) for name in stages if name.endswith(WINDOW_SUFFIX))
    union = max(archive_model, long_term_model + window_wait)
    return total - union - _duration(stages, "extract.long_term.prefetch")


def search_local_times(record: dict) -> dict[str, float]:
    summary = record.get("telemetry", {}).get("summary", {})
    stages = summary.get("search", {})
    total = float(record.get("http_wall_ms") or summary.get("duration_ms", 0) or 0)
    groups = {name: sum(_duration(stages, stage) for stage in names) for name, names in SEARCH_LOCAL_GROUPS.items()}
    named = sum(groups.values()) + sum(_duration(stages, name) for name in stages if _is_model_stage(name))
    groups["search_response_handling"] = max(total - named, 0.0)
    return groups


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


def metric_metadata(name: str, details: dict) -> dict:
    return details


def parse_run(run_root: Path, args: argparse.Namespace) -> tuple[dict, list[dict], list[dict]]:
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

    write_groups: dict[str, list[float]] = {name: [] for name in WRITE_LOCAL_GROUPS}
    write_groups["write_parallel_tail"] = []
    write_groups["write_relation_and_commit"] = []
    write_net: list[float] = []
    write_sum: list[float] = []
    for summary in commits:
        local = write_local_times(summary)
        for name, value in local.items():
            write_groups[name].append(value)
        write_net.append(write_local_net(summary))
        write_sum.append(sum(local.values()))

    negative_write = sum(1 for value in write_net if value < 0)
    if negative_write / len(write_net) > MAX_NEGATIVE_RATIO:
        fail(f"{negative_write}/{len(write_net)} write samples have a negative local time; the telemetry is inconsistent")

    search_groups: dict[str, list[float]] = {name: [] for name in SEARCH_LOCAL_GROUPS}
    search_groups["search_response_handling"] = []
    search_sum: list[float] = []
    for record in valid_records:
        local = search_local_times(record)
        for name, value in local.items():
            search_groups[name].append(value)
        search_sum.append(sum(local.values()))

    metrics: dict[str, dict] = {}
    observed_stages = set()
    for summary in commits:
        observed_stages.update(summary.get("write", {}).get("stages", {}))
    omitted: list[dict] = []
    for name, values in write_groups.items():
        if name in WRITE_LOCAL_GROUPS:
            if not any(stage in observed_stages for stage in WRITE_LOCAL_GROUPS[name]):
                # The kit did not exercise this branch (for example the archive
                # summary branch is skipped while working memory keeps the v0.5.0
                # default of being disabled), so publishing a zero would claim a
                # measurement that never happened.
                omitted.append(
                    {
                        "metric": name,
                        "stages": WRITE_LOCAL_GROUPS[name],
                        "reason": "the kit protocol did not instrument these stages in this run",
                    }
                )
                continue
        metrics[name] = build_metric(
            name, values, WRITE_GROUP, "ms/commit",
            {"pipeline": WRITE_GROUP, "stages": WRITE_LOCAL_GROUPS.get(name, ["residual"])},
        )
    metrics["write_local_net"] = build_metric(
        "write_local_net", write_net, WRITE_GROUP, "ms/commit",
        {"pipeline": WRITE_GROUP, "formula": "commit wall time minus the parallel model branches and the streaming window wait"},
    )
    metrics["write_local_sum"] = build_metric(
        "write_local_sum", write_sum, WRITE_GROUP, "ms/commit",
        {"pipeline": WRITE_GROUP, "formula": "sum of the nine local write groups"},
    )
    for name, values in search_groups.items():
        metrics[name] = build_metric(
            name, values, SEARCH_GROUP, "ms/query",
            {"pipeline": SEARCH_GROUP, "stages": SEARCH_LOCAL_GROUPS.get(name, ["residual"])},
        )
    metrics["search_local_sum"] = build_metric(
        "search_local_sum", search_sum, SEARCH_GROUP, "ms/query",
        {"pipeline": SEARCH_GROUP, "formula": "sum of the four local search groups"},
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
        "negative_write_samples": negative_write,
        "omitted_metrics": omitted,
        "instrumentation_coverage": coverage,
        "token_savings_summary": token_savings,
    }
    return protocol, metrics, commits


def write_run_samples(runs_dir: Path, metrics: dict[str, dict]) -> None:
    runs_dir.mkdir(parents=True, exist_ok=True)
    write_rows = []
    count = max((len(metric["sample_values"]) for name, metric in metrics.items() if name.startswith("write_")), default=0)
    for index in range(count):
        row = {"rep": index + 1, "pipeline": WRITE_GROUP}
        for name, metric in metrics.items():
            if name.startswith("write_") and index < len(metric["sample_values"]):
                row[name] = metric["sample_values"][index]
        write_rows.append(row)
    with (runs_dir / "write_samples.jsonl").open("w", encoding="utf-8") as handle:
        for row in write_rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    search_rows = []
    count = max((len(metric["sample_values"]) for name, metric in metrics.items() if name.startswith("search_")), default=0)
    for index in range(count):
        row = {"rep": index + 1, "pipeline": SEARCH_GROUP}
        for name, metric in metrics.items():
            if name.startswith("search_") and index < len(metric["sample_values"]):
                row[name] = metric["sample_values"][index]
        search_rows.append(row)
    with (runs_dir / "search_samples.jsonl").open("w", encoding="utf-8") as handle:
        for row in search_rows:
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

    protocol, metrics, _commits = parse_run(args.run_root, args)

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
    write_run_samples(args.runs, metrics)

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
