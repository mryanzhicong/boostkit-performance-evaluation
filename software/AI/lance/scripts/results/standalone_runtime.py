#!/usr/bin/env python3
"""Capture standalone Lance environment and normalize its completed result."""

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
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False) + "\n", encoding="utf-8")


def load_json(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        return payload if isinstance(payload, dict) else {}
    except (OSError, json.JSONDecodeError):
        return {}


def command(*args: str) -> str:
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=10, check=False)
        return result.stdout.strip() if result.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def finalize(root: Path, version: str, arch: str, run_id: str, stage_status: str, cleanup: str, failed_stage: str) -> int:
    benchmark = load_json(root / "benchmark_lance.json")
    metrics = benchmark.get("results", {}) if stage_status == "passed" else {}
    if stage_status == "passed" and (not isinstance(metrics, dict) or len(metrics) != 84):
        stage_status, failed_stage, metrics = "failed", "test", {}
    status = "passed" if stage_status == cleanup == "passed" else "failed"
    result = {
        "software": "lance", "category": "AI", "version": version,
        "architecture": arch, "run_id": run_id, "status": status,
        "cleanup_status": cleanup, "failed_stage": failed_stage or None,
        "build_info": load_json(root / "build_info.json"),
        "system_info": load_json(root / "system_info.json"),
        "runtime_before": load_json(root / "runtime_before.json"),
        "runtime_after": load_json(root / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}), "metrics": metrics,
        "error": None if status == "passed" else "standalone Lance test or cleanup failed",
    }
    write_json(root / "results.json", result)
    write_json(root / "status.json", {key: result[key] for key in (
        "software", "category", "version", "architecture", "run_id", "status", "cleanup_status", "failed_stage", "error",
    )})
    lines = [f"# Lance {version} SIFT-1M 独立测试报告", "", f"- 架构：`{arch}`", f"- 状态：`{status}`", "", "| 场景 / 指标 | 数值 | 单位 |", "|---|---:|---|"]
    for name, item in metrics.items():
        lines.append(f"| {name} | {item['value']} | {item['unit']} |")
    (root / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0 if status == "passed" else 60


def main() -> int:
    action, *args = sys.argv[1:]
    if action == "system":
        write_json(Path(args[0]), {
            "collected_at": stamp(), "architecture": platform.machine(),
            "platform": platform.platform(), "kernel": platform.release(),
            "cpu_count": os.cpu_count(), "cpu_model": command("lscpu"),
        })
    elif action == "runtime":
        write_json(Path(args[0]), {"collected_at": stamp(), "memory": command("free", "-b")})
    elif action == "build-info":
        output, version, actual_file, arch, run_id = args
        actual = Path(actual_file).read_text(encoding="utf-8").strip()
        if actual != version:
            raise ValueError(f"requested {version}, built {actual}")
        write_json(Path(output), {
            "recorded_at": stamp(), "category": "AI", "software": "lance",
            "requested_version": version, "actual_version": actual,
            "architecture": arch, "run_id": run_id,
        })
    elif action == "finalize":
        return finalize(Path(args[0]), *args[1:])
    else:
        raise ValueError(f"unknown action: {action}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
