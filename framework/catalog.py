#!/usr/bin/env python3
"""Validate the software catalog and generate the execution matrix."""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ARCHITECTURES = ("x86_64", "aarch64")
VALID_DIRECTIONS = {"higher_is_better", "lower_is_better", "target_is_better", "neutral"}


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if not isinstance(data, dict):
        raise ValueError("manifest root must be a mapping")
    return data


def configured_software(root: Path = ROOT) -> dict[str, list[str]]:
    data = load_yaml(root / "config" / "categories.yaml")
    categories = data.get("categories")
    if not isinstance(categories, dict) or not categories:
        raise ValueError("config/categories.yaml must contain a non-empty categories mapping")
    registry: dict[str, list[str]] = {}
    software_categories: dict[str, str] = {}
    for category, configured_names in categories.items():
        if not isinstance(category, str) or not category:
            raise ValueError("category names must be non-empty strings")
        if Path(category).parts != (category,) or category in {".", ".."}:
            raise ValueError(f"category {category!r} must be a single directory name")
        if configured_names is None:
            names: list[str] = []
        elif isinstance(configured_names, list) and all(
            isinstance(name, str) and name for name in configured_names
        ):
            names = list(configured_names)
        else:
            raise ValueError(
                f"category {category} must be empty or contain a string software list"
            )
        if len(names) != len(set(names)):
            raise ValueError(f"category {category} must not contain duplicate software names")
        for name in names:
            if Path(name).parts != (name,) or name in {".", ".."}:
                raise ValueError(f"software {name!r} must be a single directory name")
            if name in software_categories:
                raise ValueError(
                    f"software {name!r} is registered in both "
                    f"{software_categories[name]} and {category}"
                )
            software_categories[name] = category
        registry[category] = names
    return registry


def configured_categories(root: Path = ROOT) -> list[str]:
    return list(configured_software(root))


def configured_runner_labels(root: Path = ROOT) -> dict[str, str]:
    defaults = load_yaml(root / "config" / "defaults.yaml")
    labels = defaults.get("runner_labels")
    if not isinstance(labels, dict):
        raise ValueError("config/defaults.yaml must define runner_labels")
    missing = set(DEFAULT_ARCHITECTURES) - set(labels)
    if missing:
        raise ValueError(f"runner labels not configured for: {', '.join(sorted(missing))}")
    if not all(
        isinstance(labels[architecture], str) and labels[architecture]
        for architecture in DEFAULT_ARCHITECTURES
    ):
        raise ValueError("runner labels must be non-empty strings")
    return {architecture: labels[architecture] for architecture in DEFAULT_ARCHITECTURES}


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
    try:
        categories = configured_categories(root)
    except (OSError, ValueError) as exc:
        errors.append(str(exc))
        categories = []
    if category not in categories:
        errors.append(f"category must be one of {categories}")

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
    if (
        not isinstance(versions, list)
        or not versions
        or not all(isinstance(value, str) and value for value in versions)
    ):
        errors.append("versions must be a non-empty list of strings")
    elif len(versions) != len(set(versions)):
        errors.append("versions must not contain duplicates")

    outputs: Any = None
    execution = case.get("execution")
    if not isinstance(execution, dict):
        errors.append("execution must be a mapping")
    else:
        if execution.get("type") != "command":
            errors.append("execution.type must be command for the four-stage workflow")
        if execution.get("interface") != "four-stage":
            errors.append("execution.interface must be four-stage")
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
        if not isinstance(outputs, list) or not outputs or not all(
            isinstance(value, str) and value for value in outputs
        ):
            errors.append("execution.expected_outputs must be a non-empty string list")
        elif len(outputs) != len(set(outputs)):
            errors.append("execution.expected_outputs must not contain duplicates")
        else:
            for output in outputs:
                output_path = Path(output)
                if output_path.is_absolute() or ".." in output_path.parts:
                    errors.append(
                        f"expected output must remain inside the result directory: {output}"
                    )
            if "results.json" not in outputs:
                errors.append("execution.expected_outputs must include results.json")
        timeout = execution.get("timeout_minutes")
        if not isinstance(timeout, int) or isinstance(timeout, bool) or timeout <= 0:
            errors.append("execution.timeout_minutes must be a positive integer")
        if not isinstance(execution.get("environment"), dict):
            errors.append("execution.environment must be a mapping")

    metrics = case.get("metrics")
    if not isinstance(metrics, dict) or not metrics:
        errors.append("metrics must be a non-empty mapping")
    else:
        for metric_name, metric in metrics.items():
            if not isinstance(metric_name, str) or not metric_name:
                errors.append("metric names must be non-empty strings")
                continue
            if not isinstance(metric, dict):
                errors.append(f"metric {metric_name} must be a mapping")
                continue
            if metric.get("direction") not in VALID_DIRECTIONS:
                errors.append(f"metric {metric_name} has invalid direction")
            if not isinstance(metric.get("unit"), str) or not metric.get("unit"):
                errors.append(f"metric {metric_name} must define a non-empty unit")
            source = metric.get("source")
            if not isinstance(source, str) or not source:
                errors.append(f"metric {metric_name} must define source")
            elif source not in (outputs if isinstance(outputs, list) else []):
                errors.append(f"metric {metric_name} source is not an expected output")
            elif not source.endswith(".json"):
                errors.append(f"metric {metric_name} source must be a JSON file")
            if not isinstance(metric.get("path"), str) or not metric.get("path"):
                errors.append(f"metric {metric_name} must define path")
            target = metric.get("target")
            if target is not None and (
                isinstance(target, bool) or not isinstance(target, (int, float))
            ):
                errors.append(f"metric {metric_name} target must be numeric")
            elif isinstance(target, (int, float)) and not math.isfinite(float(target)):
                errors.append(f"metric {metric_name} target must be finite")

    for forbidden in ("architectures", "runner", "runner_label"):
        if forbidden in case:
            errors.append(f"{forbidden} must not be configured in a software manifest")
    return case, errors


def validate_catalog(root: Path = ROOT) -> tuple[list[tuple[Path, dict[str, Any]]], list[str]]:
    entries: list[tuple[Path, dict[str, Any]]] = []
    errors: list[str] = []
    try:
        registry = configured_software(root)
    except (OSError, ValueError) as exc:
        return [], [f"{root / 'config' / 'categories.yaml'}: {exc}"]

    registered_paths: list[Path] = []
    for category, software_names in registry.items():
        for software_name in software_names:
            registered_paths.append(
                root / "software" / category / software_name / "case.yaml"
            )
    registered_set = {path.resolve() for path in registered_paths}
    actual_paths = discover_cases(root)
    actual_set = {path.resolve() for path in actual_paths}

    for path in registered_paths:
        if path.resolve() not in actual_set:
            errors.append(f"registered case is missing: {path}")
            continue
        case, case_errors = validate_case(path, root)
        if case is not None:
            entries.append((path, case))
        errors.extend(f"{path}: {error}" for error in case_errors)

    for path in actual_paths:
        if path.resolve() not in registered_set:
            errors.append(
                f"case is not registered in config/categories.yaml: {path}"
            )
    return entries, errors


def build_matrix(software: str, version: str, architecture: str) -> dict:
    entries, errors = validate_catalog(ROOT)
    if errors:
        raise ValueError("invalid software catalog: " + "; ".join(errors))
    selected_software = (
        None
        if software == "all"
        else {value.strip() for value in software.split(",") if value.strip()}
    )
    selected_versions = (
        None
        if version == "all"
        else {value.strip() for value in version.split(",") if value.strip()}
    )
    architectures = DEFAULT_ARCHITECTURES if architecture == "all" else (architecture,)
    runner_labels = configured_runner_labels()
    include: list[dict[str, Any]] = []
    matched_software: set[str] = set()
    matched_versions: set[str] = set()

    for path, case in entries:
        if not case.get("enabled", False):
            continue
        name = case["name"]
        if selected_software is not None and name not in selected_software:
            continue
        matched_software.add(name)
        for case_version in case["versions"]:
            if selected_versions is not None and case_version not in selected_versions:
                continue
            matched_versions.add(case_version)
            timeout = int(case["execution"].get("timeout_minutes", 180))
            for selected_architecture in architectures:
                include.append({
                    "category": case["category"],
                    "software": name,
                    "version": case_version,
                    "arch": selected_architecture,
                    "runner_label": runner_labels[selected_architecture],
                    "timeout_minutes": timeout,
                    "job_timeout_minutes": timeout + 30,
                    "case_path": str(path.relative_to(ROOT)),
                })

    if selected_software is not None:
        missing = selected_software - matched_software
        if missing:
            raise ValueError(f"unknown or disabled software: {', '.join(sorted(missing))}")
    if selected_versions is not None:
        missing = selected_versions - matched_versions
        if missing:
            raise ValueError(f"selected versions not found: {', '.join(sorted(missing))}")
    if not include:
        raise ValueError("selection produced an empty matrix")
    return {"include": include}


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("validate")
    matrix_parser = subparsers.add_parser("matrix")
    matrix_parser.add_argument("--software", default="all")
    matrix_parser.add_argument("--version", default="all")
    matrix_parser.add_argument(
        "--architecture", choices=("all", *DEFAULT_ARCHITECTURES), default="all"
    )
    matrix_parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    if args.command == "validate":
        entries, errors = validate_catalog(ROOT)
        if errors:
            for error in errors:
                print(f"ERROR {error}", file=sys.stderr)
            return 1
        if not entries:
            print("OK no case manifests found; software catalog is empty")
        for path, _case in entries:
            print(f"OK {path}")
        return 0
    try:
        matrix = build_matrix(args.software, args.version, args.architecture)
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(
        json.dumps(
            matrix,
            indent=2 if args.pretty else None,
            separators=None if args.pretty else (",", ":"),
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
