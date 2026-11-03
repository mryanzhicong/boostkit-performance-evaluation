#!/usr/bin/env python3
"""Write standalone Kafka results without depending on the repository Framework."""

from __future__ import annotations

import argparse
import json
import os
import platform
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def write(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def load(path: Path) -> dict:
    if not path.is_file():
        return {}
    value = json.loads(path.read_text(encoding="utf-8"))
    return value if isinstance(value, dict) else {}


def command(*args: str) -> str:
    try:
        result = subprocess.run(
            args, capture_output=True, text=True, timeout=10, check=False
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "action", choices=("system", "runtime", "build-info", "finalize")
    )
    parser.add_argument("path", type=Path)
    parser.add_argument("rest", nargs="*")
    args = parser.parse_args()
    if args.action == "system":
        write(
            args.path,
            {
                "collected_at": now(),
                "architecture": platform.machine(),
                "platform": platform.platform(),
                "kernel": platform.release(),
                "cpu_count": os.cpu_count() or 0,
                "cpu_model": command("lscpu"),
            },
        )
    elif args.action == "runtime":
        write(args.path, {"collected_at": now(), "memory": command("free", "-b")})
    elif args.action == "build-info":
        version, actual_path, arch, run_id = args.rest
        actual = Path(actual_path).read_text(encoding="utf-8").strip()
        if actual != version:
            raise ValueError(
                f"installed Kafka version {actual!r} differs from {version!r}"
            )
        write(
            args.path,
            {
                "recorded_at": now(),
                "category": "Bigdata",
                "software": "kafka",
                "requested_version": version,
                "actual_version": actual,
                "architecture": arch,
                "run_id": run_id,
            },
        )
    else:
        version, arch, run_id, status, cleanup, failed_stage = args.rest
        benchmark = load(args.path / "benchmark_kafka.json")
        metrics = benchmark.get("results", {}) if status == "passed" else {}
        if status == "passed" and set(metrics) != {
            "producer/throughput",
            "consumer/throughput",
        }:
            raise ValueError("both Kafka throughput metrics are required")
        result = {
            "software": "kafka",
            "category": "Bigdata",
            "version": version,
            "architecture": arch,
            "run_id": run_id,
            "status": status,
            "cleanup_status": cleanup,
            "failed_stage": failed_stage or None,
            "build_info": load(args.path / "build_info.json"),
            "build_variant": load(args.path / "build_variant.json"),
            "system_info": load(args.path / "system_info.json"),
            "metrics": metrics,
            "parameters": benchmark.get("parameters", {}),
        }
        write(args.path / "results.json", result)
        lines = [
            f"# Kafka {version} 独立性能测试报告",
            "",
            f"- 架构：{arch}",
            f"- 状态：{status}",
            "",
            "| 场景 | 吞吐量 (MB/s) |",
            "|---|---:|",
        ]
        for name, label in (
            ("producer/throughput", "生产者"),
            ("consumer/throughput", "消费者"),
        ):
            if name in metrics:
                lines.append(f"| {label} | {metrics[name]['value']} |")
        (args.path / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
