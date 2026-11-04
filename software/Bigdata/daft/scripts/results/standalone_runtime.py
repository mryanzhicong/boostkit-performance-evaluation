#!/usr/bin/env python3
"""Produce the ordinary independent-run result contract from Daft's normalized output."""

from __future__ import annotations

import json
import os
import platform
import sys
from pathlib import Path


def load(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        return payload if isinstance(payload, dict) else {}
    except (OSError, json.JSONDecodeError):
        return {}


def write(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n", encoding="utf-8")


def main() -> int:
    root, version, arch, run_id, stage, cleanup, failed = sys.argv[1:]
    directory = Path(root)
    benchmark = load(directory / "benchmark_daft.json")
    metrics = benchmark.get("results", {}) if stage == "passed" else {}
    if stage == "passed" and (not isinstance(metrics, dict) or len(metrics) != 22):
        stage, failed, metrics = "failed", "test", {}
    status = "passed" if stage == cleanup == "passed" else "failed"
    result = {
        "category": "Bigdata", "software": "daft", "version": version,
        "architecture": arch, "run_id": run_id, "status": status,
        "cleanup_status": cleanup, "failed_stage": failed or None,
        "error": None if status == "passed" else "Daft test or cleanup failed",
        "system_info": {"architecture": platform.machine(), "cpu_count": os.cpu_count()},
        "parameters": benchmark.get("parameters", {}), "metrics": metrics,
    }
    write(directory / "results.json", result)
    write(directory / "status.json", {key: result[key] for key in (
        "software", "category", "version", "architecture", "run_id", "status", "failed_stage", "cleanup_status", "error")})
    lines = [f"# Daft {version} TPC-H 独立测试报告", "", f"- 架构：`{arch}`", f"- 状态：`{status}`", "",
             "| 查询 | 正式轮次中位数 (s) |", "|---|---:|"]
    for name, item in metrics.items():
        lines.append(f"| {name} | {item['value']:.4f} |")
    (directory / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0 if status == "passed" else 60


if __name__ == "__main__":
    raise SystemExit(main())
