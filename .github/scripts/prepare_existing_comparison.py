#!/usr/bin/env python3
"""Validate two independently uploaded results for an OBS-only comparison."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


RUN_ID = re.compile(r"[0-9]+-[0-9]+\Z")
COMPONENT = re.compile(r"[A-Za-z0-9][A-Za-z0-9._+-]*\Z")
RESULT_DIRECTORY = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}_[0-9]+-[0-9]+\Z")


def category_for(software: str, root: Path) -> str:
    if not COMPONENT.fullmatch(software):
        raise ValueError(f"invalid software name: {software!r}")
    cases = list((root / "software").glob(f"*/{software}/case.yaml"))
    if len(cases) != 1:
        raise ValueError(f"expected one registered case for {software}, found {len(cases)}")
    return cases[0].parent.parent.name


def validate_input(run_id: str, directory: str, architecture: str) -> None:
    if not RUN_ID.fullmatch(run_id):
        raise ValueError(f"invalid {architecture} run ID: {run_id!r}")
    if not RESULT_DIRECTORY.fullmatch(directory) or not directory.endswith(f"_{run_id}"):
        raise ValueError(f"{architecture} result directory must end with _{run_id}: {directory!r}")


def prepare(args: argparse.Namespace) -> None:
    root = Path(__file__).resolve().parents[2]
    category = category_for(args.software, root)
    if not COMPONENT.fullmatch(args.version):
        raise ValueError(f"invalid version: {args.version!r}")
    for arch, run_id, directory in (
        ("x86_64", args.x86_run_id, args.x86_result_directory),
        ("aarch64", args.arm_run_id, args.arm_result_directory),
    ):
        validate_input(run_id, directory, arch)
        matrix = {"include": [{
            "category": category,
            "software": args.software,
            "version": args.version,
            "arch": arch,
        }]}
        target = args.output_dir / f"{arch}-matrix.json"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(matrix) + "\n", encoding="utf-8")
    print(f"Prepared OBS lookup for {category}/{args.software}/{args.version}")


def verify(args: argparse.Namespace) -> None:
    root = Path(__file__).resolve().parents[2]
    category = category_for(args.software, root)
    for arch, run_id in (("x86_64", args.x86_run_id), ("aarch64", args.arm_run_id)):
        path = args.input_root / category / args.software / args.version / arch / "normalized_result.json"
        result = json.loads(path.read_text(encoding="utf-8"))
        expected = (category, args.software, args.version, arch, run_id)
        actual = tuple(result.get(key) for key in (
            "category", "software", "version", "architecture", "run_id"
        ))
        if actual != expected:
            raise ValueError(f"result identity mismatch in {path}: {actual!r}")
        if result.get("status") != "passed" or result.get("cleanup_status") != "passed":
            raise ValueError(f"result is not passed with clean shutdown: {path}")
        build_variant = result.get("parameters", {}).get("build_variant", {})
        recorded_variant = build_variant.get("variant") if isinstance(build_variant, dict) else None
        if (args.variant == "optimized" and recorded_variant != "optimized") or (
            recorded_variant is not None and recorded_variant != args.variant
        ):
            raise ValueError(f"result build variant differs from {args.variant}: {path}")
    if args.report_dir:
        report = json.loads((args.report_dir / "combined-report.json").read_text(encoding="utf-8"))
        summary = report.get("summary", {})
        if summary.get("total") != 2 or summary.get("passed") != 2 or summary.get("comparisons") != 1:
            raise ValueError("expected exactly two passed results and one cross-architecture comparison")
    print("Validated both architecture results and their comparison")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("prepare", "verify"))
    parser.add_argument("--software", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--x86-run-id", required=True)
    parser.add_argument("--arm-run-id", required=True)
    parser.add_argument("--x86-result-directory")
    parser.add_argument("--arm-result-directory")
    parser.add_argument("--variant", choices=("base", "optimized"), default="base")
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--input-root", type=Path)
    parser.add_argument("--report-dir", type=Path)
    args = parser.parse_args()
    if args.command == "prepare":
        if not args.output_dir or not args.x86_result_directory or not args.arm_result_directory:
            parser.error("prepare requires --output-dir and both result directories")
        prepare(args)
    else:
        if not args.input_root:
            parser.error("verify requires --input-root")
        verify(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
