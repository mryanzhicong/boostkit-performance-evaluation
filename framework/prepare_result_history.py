#!/usr/bin/env python3
"""Prepare compact, permanent performance history for the results branch."""

from __future__ import annotations

import argparse
import json
import shutil
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from generate_comparison import build_summary
from json_helper import atomic_write_json, load_json
from reporting import render_summary

PERMANENT_TEXT_FILES = {"raw-output.log", "report.md"}
REQUIRED_IDENTITY_FIELDS = ("category", "software", "version", "architecture", "run_id")


def _copy_permanent_files(source: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for path in sorted(source.iterdir()):
        if not path.is_file():
            continue
        if path.suffix == ".json" or path.name in PERMANENT_TEXT_FILES:
            shutil.copy2(path, destination / path.name)


def _identity(result: dict) -> tuple[str, str, str, str, str]:
    missing = [field for field in REQUIRED_IDENTITY_FIELDS if not result.get(field)]
    if missing:
        raise ValueError(f"normalized result is missing identity fields: {', '.join(missing)}")
    return tuple(str(result[field]) for field in REQUIRED_IDENTITY_FIELDS)  # type: ignore[return-value]


def prepare(
    input_root: Path,
    report_dir: Path,
    output_root: Path,
    *,
    run_id: str,
    repository: str,
    source_commit: str,
    workflow_url: str,
    update_baseline: bool = False,
) -> list[Path]:
    normalized_paths = sorted(input_root.rglob("normalized_result.json"))
    if not normalized_paths:
        raise ValueError("no normalized_result.json files were downloaded")

    output_root.mkdir(parents=True, exist_ok=True)
    (output_root / "README.md").write_text(
        "# Performance result history\n\n"
        "This branch is maintained by the manually triggered performance workflow.\n"
        "Each architecture keeps its normalized data, report, declared JSON outputs, "
        "and original test-stage stdout/stderr in raw-output.log. Other stage logs "
        "remain in GitHub Actions artifacts.\n",
        encoding="utf-8",
    )
    created_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    grouped: dict[tuple[str, str, str], list[tuple[dict, Path]]] = defaultdict(list)
    for normalized_path in normalized_paths:
        result = load_json(normalized_path, {})
        category, software, version, architecture, result_run_id = _identity(result)
        if result_run_id != run_id:
            raise ValueError(f"result run_id {result_run_id} does not match requested {run_id}")
        if result.get("status") != "passed" or result.get("cleanup_status") != "passed":
            raise ValueError(
                f"permanent history requires passed test and cleanup: "
                f"{software} {version} {architecture}"
            )
        grouped[(category, software, version)].append((result, normalized_path.parent))

    prepared: list[Path] = []
    for (category, software, version), entries in sorted(grouped.items()):
        run_root = output_root / category / software / version / run_id
        architecture_dirs: dict[str, Path] = {}
        parameter_signatures: set[str] = set()
        result_summaries: list[dict] = []
        for result, source_dir in entries:
            architecture = str(result["architecture"])
            destination = run_root / architecture
            _copy_permanent_files(source_dir, destination)
            architecture_dirs[architecture] = destination
            if result.get("parameter_signature"):
                parameter_signatures.add(str(result["parameter_signature"]))
            result_summaries.append({
                "architecture": architecture,
                "status": result.get("status"),
                "cleanup_status": result.get("cleanup_status"),
            })

        stem = f"{category}-{software}-{version}"
        comparison_json = report_dir / f"{stem}.json"
        comparison = load_json(comparison_json, {}) if comparison_json.is_file() else None
        if comparison_json.is_file():
            shutil.copy2(comparison_json, run_root / "comparison.json")
        scoped_comparisons = [comparison] if comparison else []
        scoped_summary = build_summary(
            [result for result, _source_dir in entries], scoped_comparisons
        )
        (run_root / "combined-report.md").write_text(
            render_summary(scoped_summary, scoped_comparisons),
            encoding="utf-8",
        )
        manifest = {
            "category": category,
            "software": software,
            "version": version,
            "run_id": run_id,
            "created_at": created_at,
            "repository": repository,
            "source_commit": source_commit,
            "workflow_url": workflow_url,
            "architectures": sorted(architecture_dirs),
            "parameter_signatures": sorted(parameter_signatures),
            "results": result_summaries,
        }
        atomic_write_json(run_root / "manifest.json", manifest)
        prepared.append(run_root)

        if update_baseline:
            expected = {"x86_64", "aarch64"}
            if set(architecture_dirs) != expected:
                raise ValueError(
                    f"baseline update for {software} {version} requires both architectures"
                )
            if not comparison_json.is_file():
                raise ValueError(f"baseline update for {software} {version} requires a comparison")
            comparison = load_json(comparison_json, {})
            atomic_write_json(
                output_root / category / software / version / "baseline.json",
                {
                    "run_id": run_id,
                    "result_path": f"{category}/{software}/{version}/{run_id}",
                    "updated_at": created_at,
                    "source_commit": source_commit,
                    "workflow_url": workflow_url,
                    "parameter_signature": comparison.get("parameter_signature"),
                    "metrics": comparison.get("metrics", {}),
                },
            )
    return prepared


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-root", required=True, type=Path)
    parser.add_argument("--report-dir", required=True, type=Path)
    parser.add_argument("--output-root", required=True, type=Path)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--workflow-url", required=True)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args()
    paths = prepare(
        args.input_root,
        args.report_dir,
        args.output_root,
        run_id=args.run_id,
        repository=args.repository,
        source_commit=args.source_commit,
        workflow_url=args.workflow_url,
        update_baseline=args.update_baseline,
    )
    print(json.dumps([str(path) for path in paths], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
