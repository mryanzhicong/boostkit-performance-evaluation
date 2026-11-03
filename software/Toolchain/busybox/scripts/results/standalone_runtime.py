#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for BusyBox.

The framework drives the case through ``framework/run_case.py`` in CI.  This
module provides the same evidence for the standalone entry point
(``busybox_test.sh``), so a developer can run the complete pipeline outside the
framework and get the identical system/runtime/build/report files.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "busybox"
CATEGORY = "Toolchain"


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def command_output(args: list[str], timeout: int = 20) -> str:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def os_pretty_name() -> str:
    try:
        lines = Path("/etc/os-release").read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return "unknown"
    for line in lines:
        field, separator, value = line.partition("=")
        if separator and field.strip() == "PRETTY_NAME":
            try:
                parsed = shlex.split(value, posix=True)
            except ValueError:
                return "unknown"
            return " ".join(parsed) if parsed else "unknown"
    return "unknown"


def cpu_model() -> str:
    for line in command_output(["lscpu"]).splitlines():
        field, separator, value = line.partition(":")
        if separator and field.strip() == "Model name":
            return value.strip()
    return platform.processor() or "unknown"


def memory_total_mib() -> int:
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemTotal:"):
                return int(line.split()[1]) // 1024
    except (OSError, ValueError, IndexError):
        pass
    return 0


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "os": os_pretty_name(),
        "kernel": platform.release(),
        "machine": platform.machine(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count(),
        "memory_total_mib": memory_total_mib(),
        "python": platform.python_version(),
    }


def collect_runtime_state() -> dict[str, Any]:
    load = os.getloadavg() if hasattr(os, "getloadavg") else (0.0, 0.0, 0.0)
    available_mib = 0
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemAvailable:"):
                available_mib = int(line.split()[1]) // 1024
                break
    except (OSError, ValueError, IndexError):
        pass
    return {
        "collected_at": timestamp(),
        "load_average": [round(value, 3) for value in load],
        "memory_available_mib": available_mib,
        "open_file_limit": command_output(["bash", "-c", "ulimit -n"]),
        "process_count": len(command_output(["ps", "-e", "-o", "pid="]).splitlines()),
    }


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    compiler: str,
    source_name: str,
    source_sha256: str,
    configure_options: str,
    cflags: str,
) -> None:
    if not actual_version_file.is_file():
        raise SystemExit(
            f"build did not report its actual version through {actual_version_file}"
        )
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise SystemExit("reported actual version is empty")
    if actual_version != requested_version:
        raise SystemExit(
            f"requested version {requested_version}, built version {actual_version}"
        )
    atomic_write_json(
        output,
        {
            "recorded_at": timestamp(),
            "category": CATEGORY,
            "software": SOFTWARE,
            "requested_version": requested_version,
            "actual_version": actual_version,
            "architecture": architecture,
            "run_id": run_id,
            "c_compiler": compiler,
            "source_archive": source_name,
            "source_sha256": source_sha256,
            "configure_options": configure_options,
            "cflags": cflags,
        },
    )


def metric_rows(normalized: dict[str, Any]) -> list[dict[str, Any]]:
    results = normalized.get("results")
    if not isinstance(results, dict):
        return []
    rows: list[dict[str, Any]] = []
    for name, item in sorted(results.items()):
        if not isinstance(item, dict):
            raise SystemExit(f"metric {name} is not an object")
        value = item.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise SystemExit(f"metric {name} is not numeric")
        if not math.isfinite(float(value)) or float(value) <= 0:
            raise SystemExit(f"metric {name} must be finite and positive")
        rows.append(
            {
                "name": name,
                "value": float(value),
                "unit": str(item.get("unit", "")),
                "direction": str(item.get("direction", "")),
                "group": str(item.get("group", "")),
                "scenario": str(item.get("scenario", "")),
            }
        )
    return rows


def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    stage_exit_code: int,
    failed_stage: str | None,
) -> None:
    normalized_path = output_dir / "normalized_result.json"
    source = normalized_path if normalized_path.is_file() else output_dir / "results.json"
    normalized: dict[str, Any] = {}
    rows: list[dict[str, Any]] = []
    if source.is_file():
        normalized = json.loads(source.read_text(encoding="utf-8"))
        if not isinstance(normalized, dict):
            raise SystemExit("results file is not a JSON object")
        atomic_write_json(normalized_path, normalized)
        rows = metric_rows(normalized)
    runtime_after = output_dir / "runtime_after.json"
    runtime = (
        json.loads(runtime_after.read_text(encoding="utf-8"))
        if runtime_after.is_file()
        else {}
    )
    summary = {
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": command_status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage or "",
        "stage_exit_code": stage_exit_code,
        "metric_count": len(rows),
        "scenario_count": len({row["scenario"] for row in rows}),
        "group_count": len({row["group"] for row in rows}),
        "runtime_after": runtime,
        "parameters": normalized.get("parameters", {}),
    }
    atomic_write_json(output_dir / "standalone_summary.json", summary)

    header = [
        f"# BusyBox {version} ({architecture}) standalone report",
        "",
        f"- run id: `{run_id}`",
        f"- status: **{command_status}**",
        f"- cleanup: {cleanup_status}",
        f"- failed stage: `{failed_stage or 'none'}` (exit code {stage_exit_code})",
    ]
    if not rows:
        header.append("- no benchmark metrics were produced; see `results.log`")
        (output_dir / "report.md").write_text("\n".join(header) + "\n", encoding="utf-8")
        print(f"[busybox-standalone] {command_status}: no metrics produced", flush=True)
        return
    lines = header + [
        f"- metrics: {len(rows)} across {summary['scenario_count']} scenarios "
        f"in {summary['group_count']} groups",
        f"- generated: {timestamp()}",
        "",
        "| metric | value | unit | direction | group |",
        "|---|---:|---|---|---|",
    ]
    for row in rows:
        lines.append(
            f"| `{row['name']}` | {row['value']:.6f} | {row['unit']} | "
            f"{row['direction']} | {row['group']} |"
        )
    lines.append("")
    lines.append(
        "Values are medians of independent repetitions; the complete samples, "
        "min/max/mean/stdev and the raw per-repetition logs stay in `results.json` "
        "and `runs/<scenario>/`."
    )
    (output_dir / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "command", choices=("system", "runtime", "build-info", "finalize")
    )
    parser.add_argument("output", type=Path)
    parser.add_argument("requested_version", nargs="?")
    parser.add_argument("actual_version_file", nargs="?")
    parser.add_argument("architecture", nargs="?")
    parser.add_argument("run_id", nargs="?")
    parser.add_argument("compiler", nargs="?")
    parser.add_argument("source_name", nargs="?")
    parser.add_argument("source_sha256", nargs="?")
    parser.add_argument("configure_options", nargs="?")
    parser.add_argument("cflags", nargs="?")
    parser.add_argument("--command-status", default="passed")
    parser.add_argument("--cleanup-status", default="pending")
    parser.add_argument("--stage-exit-code", type=int, default=0)
    parser.add_argument("--failed-stage", default="")
    parser.add_argument("--architecture", dest="architecture_opt", default="")
    parser.add_argument("--run-id", dest="run_id_opt", default="")
    args = parser.parse_args()

    if args.command == "system":
        atomic_write_json(args.output, collect_system_info())
        return 0
    if args.command == "runtime":
        atomic_write_json(args.output, collect_runtime_state())
        return 0
    if args.command == "build-info":
        if not args.requested_version or not args.actual_version_file:
            parser.error("build-info requires requested version and actual version file")
        record_build_info(
            args.output,
            args.requested_version,
            Path(args.actual_version_file),
            args.architecture or "unknown",
            args.run_id or "unknown",
            args.compiler or "unknown",
            args.source_name or "",
            args.source_sha256 or "",
            args.configure_options or "",
            args.cflags or "",
        )
        return 0
    finalize(
        args.output,
        args.requested_version or "unknown",
        args.architecture_opt or args.architecture or "unknown",
        args.run_id_opt or args.run_id or "unknown",
        args.command_status,
        args.cleanup_status,
        args.stage_exit_code,
        args.failed_stage or None,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
