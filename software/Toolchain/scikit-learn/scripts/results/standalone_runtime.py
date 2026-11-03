#!/usr/bin/env python3
"""Standalone helper for the scikit-learn case.

The Framework owns ``build_info.json`` inside a normal six-stage run, so this
helper is only used by the standalone entry point (``scikit-learn_test.sh``) and
by the build stage to record the build provenance next to the metadata that the
Framework never overwrites.
"""

from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

SOFTWARE = "scikit-learn"


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def read_json(path: Path, default: dict | None = None) -> dict:
    if not path.is_file():
        return dict(default or {})
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return dict(default or {})


def memory_info() -> dict:
    info: dict[str, object] = {}
    try:
        with open("/proc/meminfo", encoding="utf-8") as handle:
            for line in handle:
                key, _, value = line.partition(":")
                if key in ("MemTotal", "MemAvailable"):
                    info[key] = value.strip()
    except OSError:
        pass
    return info


def collect_system_info() -> dict:
    payload = {
        "recorded_at": utc_now(),
        "software": SOFTWARE,
        "platform": platform.platform(),
        "machine": platform.machine(),
        "processor": platform.processor(),
        "python": platform.python_version(),
        "cpu_count": os.cpu_count(),
        "memory": memory_info(),
        "kernel": platform.release(),
    }
    try:
        payload["distribution"] = subprocess.run(
            ["bash", "-c", ". /etc/os-release 2>/dev/null && echo \"${PRETTY_NAME:-unknown}\""],
            capture_output=True,
            text=True,
            check=False,
            timeout=10,
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        payload["distribution"] = "unknown"
    return payload


def collect_runtime_state() -> dict:
    load = os.getloadavg() if hasattr(os, "getloadavg") else (0.0, 0.0, 0.0)
    disk = shutil.disk_usage("/")
    return {
        "recorded_at": utc_now(),
        "load_average": list(load),
        "memory": memory_info(),
        "disk": {
            "total_bytes": disk.total,
            "used_bytes": disk.used,
            "free_bytes": disk.free,
        },
    }


def command_output(command: list[str]) -> str:
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, check=False, timeout=30
        )
    except (OSError, subprocess.SubprocessError):
        return "unknown"
    return (result.stdout or result.stderr or "unknown").strip()


def record_build_info(args: list[str]) -> int:
    if len(args) != 9:
        print(
            "usage: standalone_runtime.py build-info <output-dir> <version> "
            "<actual-version-file> <architecture> <run-id> <python-version> "
            "<compiler> <python-source-sha256> <sdist-sha256>",
            file=sys.stderr,
        )
        return 10
    (
        output_dir,
        requested_version,
        actual_version_file,
        architecture,
        run_id,
        python_version,
        compiler,
        python_source_sha256,
        sdist_sha256,
    ) = args
    output_path = Path(output_dir)
    actual_path = Path(actual_version_file)
    if not actual_path.is_file():
        print(f"ERROR: missing actual version file: {actual_path}", file=sys.stderr)
        return 20
    actual_version = actual_path.read_text(encoding="utf-8").strip()
    if actual_version != requested_version:
        print(
            f"ERROR: requested {requested_version}, built {actual_version}",
            file=sys.stderr,
        )
        return 20
    write_json(
        output_path / "build_info.json",
        {
            "recorded_at": utc_now(),
            "category": "Toolchain",
            "software": SOFTWARE,
            "requested_version": requested_version,
            "actual_version": actual_version,
            "architecture": architecture,
            "run_id": run_id,
        },
    )
    write_json(
        output_path / "build_provenance.json",
        {
            "recorded_at": utc_now(),
            "software": SOFTWARE,
            "architecture": architecture,
            "python_version": python_version,
            "compiler": compiler,
            "python_source_sha256": python_source_sha256,
            "source_distribution_sha256": sdist_sha256,
        },
    )
    print(f"[standalone] build identity recorded for {SOFTWARE} {actual_version}")
    return 0


def metrics_lines(results: dict) -> list[str]:
    lines: list[str] = []
    entries = results.get("results", {})
    if not isinstance(entries, dict):
        return lines
    for key in sorted(entries):
        entry = entries[key]
        statistics_payload = entry.get("statistics", {})
        lines.append(
            f"| `{key}` | {entry.get('group', '')} | {entry.get('value'):.6g} "
            f"{entry.get('unit', '')} | {statistics_payload.get('median', '')} "
            f"| {statistics_payload.get('min', '')} | {statistics_payload.get('max', '')} "
            f"| {statistics_payload.get('stdev', '')} |"
        )
    return lines


def render_report(output_dir: Path, command_status: str, cleanup_status: str) -> str:
    results = read_json(output_dir / "results.json")
    build_info = read_json(output_dir / "build_info.json")
    summary = results.get("summary", {})
    parameters = results.get("parameters", {})
    runtime = results.get("runtime", {})
    lines = [
        f"# {SOFTWARE} 性能测试报告",
        "",
        f"- 软件版本：`{build_info.get('actual_version', 'unknown')}`",
        f"- 架构：`{build_info.get('architecture', 'unknown')}`",
        f"- 运行编号：`{build_info.get('run_id', 'unknown')}`",
        f"- 执行状态：`{command_status}`，清理状态：`{cleanup_status}`",
        f"- 场景数量：{summary.get('scenario_count', 0)}，"
        f"每场景样本数：{summary.get('samples_per_scenario', 0)}，"
        f"统计量：`{summary.get('statistic', 'median')}`",
        "",
        "## 运行时与负载固定项",
        "",
    ]
    runtime_pins = parameters.get("runtime", {})
    if isinstance(runtime_pins, dict):
        for name in sorted(runtime_pins):
            lines.append(f"- `{name}` = `{runtime_pins[name]}`")
    asv = parameters.get("asv", {})
    if isinstance(asv, dict):
        lines.append(
            f"- 上游 asv 基准套件：`{asv.get('repository')}` @ `{asv.get('tag')}` "
            f"(commit `{asv.get('tag_commit')}`)"
        )
    measurement = parameters.get("measurement", {})
    if isinstance(measurement, dict):
        lines.append(
            f"- 采样协议：{measurement.get('warmups')} 次预热 + "
            f"{measurement.get('repetitions')} 次重复，取 "
            f"`{measurement.get('statistic')}`，每样本独立进程，测量期离线"
        )
    if runtime:
        lines.append(
            f"- 实测运行时：CPython `{runtime.get('python')}`，"
            f"pip `{runtime.get('pip')}`"
        )
    lines += [
        "",
        "## 指标（wall time 与 peak RSS 取样本中位数）",
        "",
        "| 指标 | 场景 | 中位数 | median | min | max | stdev |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    lines += metrics_lines(results)
    lines.append("")
    return "\n".join(lines) + "\n"


def finalize(args: list[str]) -> int:
    if len(args) != 7:
        print(
            "usage: standalone_runtime.py finalize <output-dir> <version> <architecture> "
            "<run-id> <command-status> <cleanup-status> <failed-stage>",
            file=sys.stderr,
        )
        return 10
    (
        output_dir,
        version,
        architecture,
        run_id,
        command_status,
        cleanup_status,
        failed_stage,
    ) = args
    output_path = Path(output_dir)
    results = read_json(output_path / "results.json")
    build_info = read_json(output_path / "build_info.json")
    status = "passed" if command_status == "passed" and not failed_stage else "failed"
    payload = {
        "status": status,
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "command_status": command_status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage or None,
        "recorded_at": utc_now(),
        "build_info": build_info,
        "summary": results.get("summary", {}),
        "results": results.get("results", {}),
        "parameters": results.get("parameters", {}),
        "runtime": results.get("runtime", {}),
        "asv_snapshot": results.get("asv_snapshot", {}),
    }
    write_json(output_path / "normalized_result.json", payload)
    write_json(
        output_path / "status.json",
        {
            "status": status,
            "stage": "complete" if status == "passed" else "failed",
            "failed_stage": failed_stage or None,
            "exit_code": 0 if status == "passed" else 1,
            "recorded_at": utc_now(),
        },
    )
    (output_path / "report.md").write_text(
        render_report(output_path, command_status, cleanup_status), encoding="utf-8"
    )
    print(f"[standalone] finalized {SOFTWARE} {version} ({status})")
    return 0 if status == "passed" else 1


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 10
    command, args = argv[1], argv[2:]
    if command == "system" and len(args) == 1:
        write_json(Path(args[0]), collect_system_info())
        return 0
    if command == "runtime" and len(args) == 1:
        write_json(Path(args[0]), collect_runtime_state())
        return 0
    if command == "build-info":
        return record_build_info(args)
    if command == "finalize":
        return finalize(args)
    print(f"unknown command: {command}", file=sys.stderr)
    return 10


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
