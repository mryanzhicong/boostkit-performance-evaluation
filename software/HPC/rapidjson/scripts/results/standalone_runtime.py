#!/usr/bin/env python3
"""Environment capture and result files for standalone RapidJSON runs."""

from __future__ import annotations

import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

EXPECTED_METRIC_COUNT = 16
SOFTWARE = "rapidjson"
CATEGORY = "HPC"


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_json(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else {}
    except (OSError, json.JSONDecodeError):
        return {}


def command(*args: str) -> str:
    try:
        result = subprocess.run(args, text=True, capture_output=True, timeout=10, check=False)
        return result.stdout.strip() if result.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def finalize(args: list[str]) -> int:
    output, version, arch, run_id, command_status, cleanup_status, failed_stage = args
    root = Path(output)
    benchmark = load_json(root / "perftest_result.json")
    metrics = {}
    if command_status == "passed":
        for name, item in benchmark.get("results", {}).items():
            metrics[name] = {key: item[key] for key in ("value", "unit", "direction", "group")}
        if len(metrics) != EXPECTED_METRIC_COUNT:
            command_status, failed_stage = "failed", "test"
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    result = {
        "software": SOFTWARE,
        "category": CATEGORY,
        "version": version,
        "architecture": arch,
        "run_id": run_id,
        "status": status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage or None,
        "build_info": load_json(root / "build_info.json"),
        "build_variant": load_json(root / "build_variant.json"),
        "system_info": load_json(root / "system_info.json"),
        "runtime_before": load_json(root / "runtime_before.json"),
        "runtime_after": load_json(root / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}),
        "sampling": benchmark.get("sampling", {}),
        "metrics": metrics,
        "error": None if status == "passed" else "incomplete rapidjson result",
    }
    write_json(root / "results.json", result)
    write_json(root / "status.json", {
        key: result[key] for key in (
            "software", "category", "version", "architecture", "run_id",
            "status", "failed_stage", "cleanup_status", "error",
        )
    })
    groups: dict[str, list[str]] = {}
    for name, item in metrics.items():
        groups.setdefault(item["group"], []).append(name)
    lines = [
        f"# rapidjson {version} 独立测试报告",
        "",
        f"- 架构：`{arch}`",
        f"- 变体：`{benchmark.get('variant', 'unknown')}`",
        f"- 状态：`{status}`",
        f"- 采样：{benchmark.get('sampling', {}).get('warmups', 0)} 次预热 + "
        f"{benchmark.get('sampling', {}).get('reps', 0)} 次有效采样，取中位数",
        f"- 指标总数：{len(metrics)}",
        "",
    ]
    for group in sorted(groups):
        lines.append(f"## {group}")
        lines.append("")
        lines.append("| 指标 | 数值 | 单位 |")
        lines.append("|---|---:|---|")
        for name in sorted(groups[group]):
            item = metrics[name]
            lines.append(f"| {name} | {item['value']} | {item['unit']} |")
        lines.append("")
    (root / "report.md").write_text("\n".join(lines), encoding="utf-8")
    return 0 if status == "passed" else 60


def main() -> int:
    action, *args = sys.argv[1:]
    if action == "system":
        write_json(Path(args[0]), {
            "collected_at": stamp(),
            "architecture": platform.machine(),
            "platform": platform.platform(),
            "kernel": platform.release(),
            "cpu_count": os.cpu_count(),
            "cpu_model": command("lscpu"),
            "gcc_version": command("gcc", "-dumpfullversion"),
        })
    elif action == "runtime":
        write_json(Path(args[0]), {
            "collected_at": stamp(),
            "memory": command("free", "-b"),
            "disk": command("df", "-Pk", "/"),
        })
    elif action == "build-info":
        output, version, version_file, arch, run_id = args
        actual = Path(version_file).read_text(encoding="utf-8").strip()
        if actual != version:
            raise RuntimeError(f"built rapidjson version {actual} differs from requested {version}")
        write_json(Path(output), {
            "recorded_at": stamp(),
            "software": SOFTWARE,
            "category": CATEGORY,
            "requested_version": version,
            "actual_version": actual,
            "architecture": arch,
            "run_id": run_id,
        })
    elif action == "finalize":
        return finalize(args)
    else:
        raise ValueError(f"unknown action: {action}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
