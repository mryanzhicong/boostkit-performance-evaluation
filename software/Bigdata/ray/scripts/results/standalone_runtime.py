#!/usr/bin/env python3
"""Use the project Framework to finalize an independently executed Ray case."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "framework"))

from build_info import record_build_info  # noqa: E402
from catalog import validate_case  # noqa: E402
from collect_environment import collect_runtime_state, collect_system_info  # noqa: E402
from context import RunContext  # noqa: E402
from json_helper import atomic_write_json, load_json  # noqa: E402
from normalize_results import write_normalized  # noqa: E402
from reporting import render_single  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("prepare", "build-info", "finalize"))
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--results-dir", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--status", choices=("passed", "failed"), default="passed")
    parser.add_argument("--failed-stage", default="")
    args = parser.parse_args()
    case_path = ROOT / "software/Bigdata/ray/case.yaml"
    case, errors = validate_case(case_path, ROOT)
    if errors or case is None:
        raise RuntimeError(f"invalid Ray case: {errors}")
    context = RunContext(ROOT, case_path, case, "Bigdata", "ray", args.version,
                         args.architecture, args.run_id, args.results_dir, args.work_dir)
    args.results_dir.mkdir(parents=True, exist_ok=True)
    if args.action == "prepare":
        atomic_write_json(args.results_dir / "system_info.json", collect_system_info())
        atomic_write_json(args.results_dir / "runtime_before.json", collect_runtime_state())
    elif args.action == "build-info":
        record_build_info(context)
    else:
        atomic_write_json(args.results_dir / "runtime_after.json", collect_runtime_state())
        status = {"category": "Bigdata", "software": "ray", "version": args.version,
                  "architecture": args.architecture, "run_id": args.run_id,
                  "status": args.status, "stage": "complete" if args.status == "passed" else args.failed_stage,
                  "failed_stage": args.failed_stage or None, "exit_code": 0 if args.status == "passed" else 1,
                  "cleanup_status": "passed"}
        atomic_write_json(args.results_dir / "status.json", status)
        if args.status == "passed":
            result = write_normalized(context, "passed")
            (args.results_dir / "report.md").write_text(render_single(load_json(result, {})), encoding="utf-8")
            atomic_write_json(args.results_dir / "results.json", load_json(result, {}))
        else:
            atomic_write_json(args.results_dir / "results.json", status)
            (args.results_dir / "report.md").write_text(
                f"# Ray {args.version} standalone test failed\n\nStage: {args.failed_stage}\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
