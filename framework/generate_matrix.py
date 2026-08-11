#!/usr/bin/env python3
"""Expand manually maintained cases into a GitHub Actions matrix."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from validate_case import ROOT, discover_cases, load_yaml, validate_case

DEFAULT_ARCHITECTURES = ("x86_64", "aarch64")


def configured_runner_labels() -> dict[str, str]:
    defaults = load_yaml(ROOT / "config" / "defaults.yaml")
    labels = defaults.get("runner_labels")
    if not isinstance(labels, dict):
        raise ValueError("config/defaults.yaml must define runner_labels")
    missing = set(DEFAULT_ARCHITECTURES) - set(labels)
    if missing:
        raise ValueError(f"runner labels not configured for: {', '.join(sorted(missing))}")
    if not all(isinstance(labels[arch], str) and labels[arch] for arch in DEFAULT_ARCHITECTURES):
        raise ValueError("runner labels must be non-empty strings")
    return {arch: labels[arch] for arch in DEFAULT_ARCHITECTURES}


def build_matrix(software: str, version: str, architecture: str, test_mode: str) -> dict:
    selected_software = None if software == "all" else {v.strip() for v in software.split(",") if v.strip()}
    selected_versions = None if version == "all" else {v.strip() for v in version.split(",") if v.strip()}
    architectures = DEFAULT_ARCHITECTURES if architecture == "all" else (architecture,)
    runner_labels = configured_runner_labels()
    include: list[dict] = []
    matched_software: set[str] = set()
    matched_versions: set[str] = set()

    for path in discover_cases(ROOT):
        case, errors = validate_case(path, ROOT)
        if errors or case is None:
            raise ValueError(f"invalid case {path}: {'; '.join(errors)}")
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
            mode = case["modes"][test_mode]
            timeout = int(mode.get("timeout_minutes", 180))
            for arch in architectures:
                include.append({
                    "category": case["category"],
                    "software": name,
                    "version": case_version,
                    "arch": arch,
                    "runner_label": runner_labels[arch],
                    "test_mode": test_mode,
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
    include.sort(key=lambda row: (row["category"], row["software"], row["version"], row["arch"]))
    return {"include": include}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--software", default="all")
    parser.add_argument("--version", default="all")
    parser.add_argument("--architecture", choices=("all", *DEFAULT_ARCHITECTURES), default="all")
    parser.add_argument("--test-mode", choices=("smoke", "full"), default="full")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()
    try:
        matrix = build_matrix(args.software, args.version, args.architecture, args.test_mode)
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(json.dumps(matrix, indent=2 if args.pretty else None, separators=None if args.pretty else (",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
