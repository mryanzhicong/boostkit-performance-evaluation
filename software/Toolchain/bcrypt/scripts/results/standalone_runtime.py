#!/usr/bin/env python3
"""Standalone helper for the bcrypt case (system info, build identity, finalize)."""

from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

SOFTWARE = "bcrypt"


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
        "disk": {"total_bytes": disk.total, "used_bytes": disk.used, "free_bytes": disk.free},
    }


def build_info(args: list[str]) -> int:
    if len(args) != 8:
        print(
            "usage: standalone_runtime.py build-info <output-dir> <version> <actual-version-file> "
            "<architecture> <run-id> <node-version> <node-archive-sha256> <bcrypt-tarball-sha256>",
            file=sys.stderr,
        )
        return 10
    output_dir, requested, actual_file, architecture, run_id, node_version, node_sha, bcrypt_sha = args
    actual_path = Path(actual_file)
    if not actual_path.is_file():
        print(f"ERROR: missing actual version file: {actual_path}", file=sys.stderr)
        return 20
    actual_version = actual_path.read_text(encoding="utf-8").strip()
    if actual_version != requested:
        print(f"ERROR: requested {requested}, built {actual_version}", file=sys.stderr)
        return 20
    write_json(
        Path(output_dir) / "build_info.json",
        {
            "recorded_at": utc_now(),
            "category": "Toolchain",
            "software": SOFTWARE,
            "requested_version": requested,
            "actual_version": actual_version,
            "architecture": architecture,
            "run_id": run_id,
        },
    )
    write_json(
        Path(output_dir) / "build_provenance.json",
        {
            "recorded_at": utc_now(),
            "software": SOFTWARE,
            "node_version": node_version,
            "node_archive_sha256": node_sha,
            "bcrypt_tarball_sha256": bcrypt_sha,
        },
    )
    print(f"[standalone] build identity recorded for {SOFTWARE} {actual_version}")
    return 0


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
        f"- 场景数量：{summary.get('scenario_count', 0)}，每场景样本数：{summary.get('samples_per_scenario', 0)}，"
        f"统计量：`{summary.get('statistic', 'median')}`",
        "",
        "## 运行时与负载固定项",
        "",
    ]
    node = parameters.get("node", {})
    if isinstance(node, dict):
        lines.append(f"- Node.js：`{node.get('version')}`（archive sha256 `{node.get('archive_sha256')}`）")
    package = parameters.get("package", {})
    if isinstance(package, dict):
        lines.append(
            f"- bcrypt：`{package.get('version')}`（tarball sha256 `{package.get('tarball_sha256')}`，"
            f"预编译 N-API 二进制 `{package.get('native_binary')}` sha256 `{package.get('native_binary_sha256')}`）"
        )
    measurement = parameters.get("measurement", {})
    if isinstance(measurement, dict):
        lines.append(
            f"- 采样协议：{measurement.get('warmups')} 次预热 + {measurement.get('repetitions')} 次重复，"
            f"每样本独立进程，每样本 {measurement.get('operations_per_sample')} 次操作，测量期离线"
        )
    if runtime:
        lines.append(
            f"- 实测运行时：Node.js `{runtime.get('node', {}).get('version')}`，"
            f"bcrypt `{runtime.get('bcrypt', {}).get('version')}`，napi `{runtime.get('bcrypt', {}).get('native', {}).get('napi')}`"
        )
    lines += ["", "## 指标（样本中位数）", "", "| 指标 | 场景 | 单位 | 中位数 | min | max | stdev |", "| --- | --- | --- | --- | --- | --- | --- |"]
    entries = results.get("results", {})
    if isinstance(entries, dict):
        for key in sorted(entries):
            entry = entries[key]
            stats = entry.get("statistics", {})
            lines.append(
                f"| `{key}` | {entry.get('group', '')} | {entry.get('unit', '')} | "
                f"{stats.get('median', '')} | {stats.get('min', '')} | {stats.get('max', '')} | {stats.get('stdev', '')} |"
            )
    lines.append("")
    return "\n".join(lines) + "\n"


def finalize(args: list[str]) -> int:
    if len(args) != 8:
        print(
            "usage: standalone_runtime.py finalize <output-dir> <version> <architecture> <run-id> "
            "<command-status> <cleanup-status> <failed-stage>",
            file=sys.stderr,
        )
        return 10
    output_dir, version, architecture, run_id, command_status, cleanup_status, failed_stage = args
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
    (output_path / "report.md").write_text(render_report(output_path, command_status, cleanup_status), encoding="utf-8")
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
        return build_info(args)
    if command == "finalize":
        return finalize(args)
    print(f"unknown command: {command}", file=sys.stderr)
    return 10


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
