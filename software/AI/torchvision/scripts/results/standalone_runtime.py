#!/usr/bin/env python3
"""Environment capture and result files for standalone TorchVision runs."""

from __future__ import annotations

import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


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
    benchmark = load_json(root / "benchmark_torchvision.json")
    metrics = {}
    if command_status == "passed":
        for name, item in benchmark.get("results", {}).items():
            metrics[name] = {key: item[key] for key in ("value", "unit", "direction", "group", "subgroup")}
        if len(metrics) != 6:
            command_status, failed_stage = "failed", "test"
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    result = {
        "software": "torchvision", "category": "AI", "version": version,
        "architecture": arch, "run_id": run_id, "status": status,
        "cleanup_status": cleanup_status, "failed_stage": failed_stage or None,
        "build_info": load_json(root / "build_info.json"),
        "system_info": load_json(root / "system_info.json"),
        "runtime_before": load_json(root / "runtime_before.json"),
        "runtime_after": load_json(root / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}), "metrics": metrics,
        "error": "incomplete torchvision result" if command_status == "failed" and len(metrics) != 6 else None,
    }
    write_json(root / "results.json", result)
    write_json(root / "status.json", {
        key: result[key] for key in ("software", "category", "version", "architecture", "run_id", "status", "failed_stage", "cleanup_status", "error")
    })
    lines = [f"# torchvision {version} 独立测试报告", "", f"- 架构：`{arch}`", f"- 状态：`{status}`", "", "## 指标", "",
             "| 场景 | 数值 | 单位 | 分组 | 子组 |", "|---|---:|---|---|---|"]
    for name, item in metrics.items():
        lines.append(f"| {name} | {item['value']} | {item['unit']} | {item['group']} | {item['subgroup']} |")
    (root / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0 if status == "passed" else 60


def main() -> int:
    action, *args = sys.argv[1:]
    if action == "system":
        write_json(Path(args[0]), {
            "collected_at": stamp(), "architecture": platform.machine(),
            "platform": platform.platform(), "kernel": platform.release(),
            "cpu_count": os.cpu_count(), "cpu_model": command("lscpu"),
            "gcc_version": command("gcc", "-dumpfullversion", "-dumpversion"),
        })
    elif action == "runtime":
        write_json(Path(args[0]), {"collected_at": stamp(), "memory": command("free", "-b")})
    elif action == "build-info":
        output, version, version_file, arch, run_id = args
        actual = Path(version_file).read_text(encoding="utf-8").strip()
        if actual != version:
            raise RuntimeError("built torchvision version differs from requested version")
        write_json(Path(output), {
            "recorded_at": stamp(), "software": "torchvision", "category": "AI",
            "requested_version": version, "actual_version": actual,
            "architecture": arch, "run_id": run_id,
        })
    elif action == "finalize":
        return finalize(args)
    else:
        raise ValueError(f"unknown action: {action}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
