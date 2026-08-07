#!/usr/bin/env python3
"""Run one manually maintained software case."""

from __future__ import annotations

import argparse
import importlib.util
import platform
import shutil
import sys
from pathlib import Path

from aggregate_results import write_normalized
from command_adapter import run_command
from context import RunContext
from json_helper import atomic_write_json, load_json
from validate_case import ROOT, validate_case


def normalize_arch(value: str) -> str:
    lowered = value.lower()
    if lowered in {"x86_64", "amd64"}:
        return "x86_64"
    if lowered in {"aarch64", "arm64"}:
        return "aarch64"
    return lowered


def write_status(context: RunContext, status: str, stage: str, **extra: object) -> None:
    payload = {
        "category": context.category,
        "software": context.software,
        "version": context.version,
        "architecture": context.architecture,
        "test_mode": context.test_mode,
        "run_id": context.run_id,
        "status": status,
        "stage": stage,
        "failed_stage": None,
        "exit_code": None,
        "cleanup_status": "pending",
    }
    payload.update(extra)
    atomic_write_json(context.output_dir / "status.json", payload)


def build_context(args: argparse.Namespace, case: dict) -> RunContext:
    category = case["category"]
    software = case["name"]
    output_dir = ROOT / ".perf-output" / category / software / args.version / args.architecture / args.run_id
    work_dir = Path("/tmp/boostkit-perf") / args.run_id / category / software / args.version / args.architecture
    return RunContext(
        root=ROOT,
        case_path=args.case.resolve(),
        case=case,
        category=category,
        software=software,
        version=args.version,
        architecture=args.architecture,
        test_mode=args.test_mode,
        run_id=args.run_id,
        output_dir=output_dir,
        work_dir=work_dir,
    )


def run_optional_adapter(context: RunContext) -> tuple[int, tuple[str, ...]]:
    adapter_path = (context.case_dir / context.execution["entrypoint"]).resolve()
    spec = importlib.util.spec_from_file_location(f"adapter_{context.software}", adapter_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load adapter: {adapter_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    adapter = module.create_adapter(context)
    try:
        adapter.run()
    finally:
        adapter.cleanup()
    missing = tuple(
        name for name in context.execution.get("expected_outputs", [])
        if not (context.output_dir / name).is_file()
    )
    return 0, missing


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True, type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True, choices=("x86_64", "aarch64"))
    parser.add_argument("--test-mode", required=True, choices=("smoke", "full"))
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    case, errors = validate_case(args.case, ROOT)
    if errors or case is None:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 10
    if args.version not in case["versions"]:
        print(f"ERROR: version {args.version} is not declared", file=sys.stderr)
        return 10
    context = build_context(args, case)
    context.output_dir.mkdir(parents=True, exist_ok=True)
    write_status(context, "running", "initialized")

    if args.dry_run:
        atomic_write_json(context.output_dir / "dry_run.json", {
            "case": str(args.case),
            "version": args.version,
            "architecture": args.architecture,
            "test_mode": args.test_mode,
        })
        write_status(context, "passed", "dry_run", cleanup_status="passed")
        print(context.output_dir)
        return 0

    actual_arch = normalize_arch(platform.machine())
    if actual_arch != args.architecture:
        write_status(context, "failed", "architecture_check", failed_stage="architecture_check", exit_code=20)
        print(f"ERROR: expected {args.architecture}, runner is {actual_arch}", file=sys.stderr)
        return 20

    from collect_environment import collect
    from reporting.single_report import render

    atomic_write_json(context.output_dir / "environment_before.json", collect())
    write_status(context, "running", "execute")
    try:
        if context.execution.get("type") == "adapter":
            returncode, missing = run_optional_adapter(context)
        else:
            result = run_command(context)
            returncode, missing = result.returncode, result.missing_outputs
        atomic_write_json(context.output_dir / "environment_after.json", collect())
        command_status = "passed" if returncode == 0 and not missing else "failed"
        normalized_path = write_normalized(context, command_status)
        report = render(load_json(normalized_path, {}))
        (context.output_dir / "report.md").write_text(report, encoding="utf-8")
        if command_status == "failed":
            write_status(
                context,
                "failed",
                "execute",
                failed_stage="execute",
                exit_code=returncode or 60,
                missing_outputs=list(missing),
            )
            return returncode or 60
        write_status(context, "passed", "complete", exit_code=0)
        print(context.output_dir)
        return 0
    except Exception as exc:
        atomic_write_json(context.output_dir / "environment_after.json", collect())
        write_status(context, "failed", "execute", failed_stage="execute", exit_code=50, error=str(exc))
        print(f"ERROR: {exc}", file=sys.stderr)
        return 50
    finally:
        shutil.rmtree(context.work_dir, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
