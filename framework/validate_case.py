#!/usr/bin/env python3
"""Validate manually maintained software case manifests."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
VALID_DIRECTIONS = {"higher_is_better", "lower_is_better", "target_is_better", "neutral"}


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if not isinstance(data, dict):
        raise ValueError("manifest root must be a mapping")
    return data


def configured_categories(root: Path = ROOT) -> list[str]:
    data = load_yaml(root / "config" / "categories.yaml")
    categories = data.get("categories")
    if not isinstance(categories, list) or not all(isinstance(v, str) for v in categories):
        raise ValueError("config/categories.yaml must contain a string list named categories")
    return categories


def discover_cases(root: Path = ROOT) -> list[Path]:
    return sorted((root / "software").glob("*/*/case.yaml"))


def validate_case(path: Path, root: Path = ROOT) -> tuple[dict[str, Any] | None, list[str]]:
    errors: list[str] = []
    try:
        case = load_yaml(path)
    except Exception as exc:
        return None, [f"cannot load YAML: {exc}"]

    required = ("name", "category", "enabled", "versions", "execution", "metrics")
    for field in required:
        if field not in case:
            errors.append(f"missing required field: {field}")

    name = case.get("name")
    category = case.get("category")
    if not isinstance(name, str) or not name:
        errors.append("name must be a non-empty string")
    if category not in configured_categories(root):
        errors.append(f"category must be one of {configured_categories(root)}")

    try:
        relative = path.resolve().relative_to((root / "software").resolve())
        path_category, path_software = relative.parts[0], relative.parts[1]
        if category != path_category:
            errors.append(f"category {category!r} does not match directory {path_category!r}")
        if name != path_software:
            errors.append(f"name {name!r} does not match directory {path_software!r}")
    except (ValueError, IndexError):
        errors.append("case.yaml must be at software/<category>/<software>/case.yaml")

    versions = case.get("versions")
    if not isinstance(versions, list) or not versions or not all(isinstance(v, str) and v for v in versions):
        errors.append("versions must be a non-empty list of strings")
    elif len(versions) != len(set(versions)):
        errors.append("versions must not contain duplicates")

    execution = case.get("execution")
    if not isinstance(execution, dict):
        errors.append("execution must be a mapping")
    else:
        exec_type = execution.get("type")
        if exec_type != "command":
            errors.append("execution.type must be command for the staged workflow")
        if execution.get("interface") != "staged":
            errors.append("execution.interface must be staged")
        entrypoint = execution.get("entrypoint")
        if not isinstance(entrypoint, str) or not entrypoint:
            errors.append("execution.entrypoint must be a non-empty string")
        else:
            resolved = (path.parent / entrypoint).resolve()
            try:
                resolved.relative_to(path.parent.resolve())
            except ValueError:
                errors.append("execution.entrypoint must remain inside the software directory")
            if not resolved.is_file():
                errors.append(f"execution.entrypoint does not exist: {entrypoint}")
        outputs = execution.get("expected_outputs")
        if not isinstance(outputs, list) or not outputs or not all(isinstance(v, str) for v in outputs):
            errors.append("execution.expected_outputs must be a non-empty string list")
        timeout = execution.get("timeout_minutes")
        if not isinstance(timeout, int) or isinstance(timeout, bool) or timeout <= 0:
            errors.append("execution.timeout_minutes must be a positive integer")
        environment = execution.get("environment")
        if not isinstance(environment, dict):
            errors.append("execution.environment must be a mapping")

    metrics = case.get("metrics")
    if not isinstance(metrics, dict) or not metrics:
        errors.append("metrics must be a non-empty mapping")
    else:
        for metric_name, metric in metrics.items():
            if not isinstance(metric, dict):
                errors.append(f"metric {metric_name} must be a mapping")
                continue
            if metric.get("direction") not in VALID_DIRECTIONS:
                errors.append(f"metric {metric_name} has invalid direction")
            if not isinstance(metric.get("unit"), str):
                errors.append(f"metric {metric_name} must define unit")
            if metric.get("direction") != "neutral" and not isinstance(metric.get("path"), str):
                errors.append(f"metric {metric_name} must define path")

    for forbidden in ("architectures", "runner", "runner_label"):
        if forbidden in case:
            errors.append(f"{forbidden} must not be configured in a software manifest")

    return case, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", type=Path)
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()
    if not args.all and not args.case:
        parser.error("one of --case or --all is required")

    paths = discover_cases() if args.all else [args.case]
    if not paths:
        # An empty catalog is a valid repository baseline. Matrix generation still
        # rejects an actual workflow run until at least one enabled case exists.
        print("OK no case manifests found; software catalog is empty")
        return 0

    failed = False
    seen: set[str] = set()
    for path in paths:
        case, errors = validate_case(path)
        if case and case.get("name") in seen:
            errors.append(f"duplicate software name: {case['name']}")
        if case:
            seen.add(str(case.get("name")))
        if errors:
            failed = True
            for error in errors:
                print(f"ERROR {path}: {error}", file=sys.stderr)
        else:
            print(f"OK {path}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
