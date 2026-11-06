#!/usr/bin/env python3
"""Self-contained environment collection and reporting for the MPFR case."""

from __future__ import annotations

import argparse
import json
import os
import platform
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def command(args: list[str]) -> str:
    try:
        completed = subprocess.run(
            args, capture_output=True, text=True, encoding="utf-8",
            errors="replace", timeout=10, check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def os_pretty_name() -> str:
    try:
        for line in Path("/etc/os-release").read_text(encoding="utf-8", errors="replace").splitlines():
            if line.startswith("PRETTY_NAME="):
                return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        pass
    return ""


def cpu_model() -> str:
    try:
        for line in Path("/proc/cpuinfo").read_text(encoding="utf-8", errors="replace").splitlines():
            if line.lower().startswith("model name") or line.lower().startswith("hardware"):
                return line.split(":", 1)[1].strip()
    except OSError:
        pass
    return ""


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "hostname": platform.node(),
        "os": os_pretty_name(),
        "kernel": platform.release(),
        "architecture": platform.machine(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count(),
        "memory_total_mib": None,
        "compiler": command(["gcc", "--version"]).splitlines()[:1],
    }


def collect_runtime_state() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "load_avg": os.getloadavg() if hasattr(os, "getloadavg") else None,
        "mem_available_kib": None,
        "uptime_seconds": None,
    }


def record_build_info(
    output: Path,
    requested: str,
    actual: str,
    architecture: str,
    run_id: str,
    compiler: str,
    configure_options: str,
) -> int:
    atomic_write_json(output, {
        "software": "mpfr",
        "category": "Toolchain",
        "requested_version": requested,
        "actual_version": actual,
        "architecture": architecture,
        "run_id": run_id,
        "compiler": compiler,
        "configure_options": shlex.split(configure_options) if configure_options else [],
        "build_targets": ["libraries (make)", "tune/speed (make -C tune speed)"],
        "benchmark": "fixed-workload MPFR harness",
    })
    return 0


def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    failed_stage: str | None,
) -> int:
    benchmark = load_json(output_dir / "benchmark_mpfr.json")
    error = ""
    metrics = benchmark.get("results", {})
    if command_status == "passed":
        if not benchmark or not metrics:
            command_status = "failed"
            failed_stage = failed_stage or "test"
            error = "benchmark_mpfr.json is missing or invalid"
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    result = {
        "software": "mpfr",
        "category": "Toolchain",
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage,
        "build_info": load_json(output_dir / "build_info.json"),
        "system_info": load_json(output_dir / "system_info.json"),
        "runtime_before": load_json(output_dir / "runtime_before.json"),
        "runtime_after": load_json(output_dir / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}),
        "metrics": metrics,
        "error": error or None,
    }
    atomic_write_json(output_dir / "results.json", result)
    atomic_write_json(output_dir / "status.json", {
        "software": "mpfr",
        "category": "Toolchain",
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": status,
        "failed_stage": failed_stage,
        "cleanup_status": cleanup_status,
        "error": error or None,
    })
    return 60 if error else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    system = subparsers.add_parser("system")
    system.add_argument("output", type=Path)
    runtime = subparsers.add_parser("runtime")
    runtime.add_argument("output", type=Path)
    build = subparsers.add_parser("build-info")
    build.add_argument("output", type=Path)
    build.add_argument("requested")
    build.add_argument("actual_file", type=Path)
    build.add_argument("architecture")
    build.add_argument("run_id")
    build.add_argument("compiler")
    build.add_argument("--configure-options", default="")
    final = subparsers.add_parser("finalize")
    final.add_argument("output_dir", type=Path)
    final.add_argument("version")
    final.add_argument("architecture")
    final.add_argument("run_id")
    final.add_argument("command_status")
    final.add_argument("cleanup_status")
    final.add_argument("failed_stage")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "system":
        atomic_write_json(args.output, collect_system_info())
        return 0
    if args.command == "runtime":
        atomic_write_json(args.output, collect_runtime_state())
        return 0
    if args.command == "build-info":
        actual = args.actual_file.read_text(encoding="utf-8").strip() if args.actual_file.is_file() else ""
        return record_build_info(
            args.output, args.requested, actual, args.architecture,
            args.run_id, args.compiler, args.configure_options,
        )
    return finalize(
        args.output_dir, args.version, args.architecture, args.run_id,
        args.command_status, args.cleanup_status,
        None if args.failed_stage in {"", "None", "null"} else args.failed_stage,
    )


if __name__ == "__main__":
    raise SystemExit(main())
