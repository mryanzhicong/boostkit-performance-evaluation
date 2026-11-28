#!/usr/bin/env python3
"""Environment capture and result files for standalone libvirt unixbench runs."""

from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

METRIC_COUNT = 19


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
    benchmark = load_json(root / "benchmark_unixbench.json")
    metrics = {}
    if command_status == "passed":
        for name, item in benchmark.get("results", {}).items():
            metrics[name] = {key: item[key] for key in ("value", "unit", "direction", "group")}
        if len(metrics) != METRIC_COUNT:
            command_status, failed_stage = "failed", "test"
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    result = {
        "software": "libvirt-unixbench",
        "category": "Virtualization",
        "version": version,
        "architecture": arch,
        "run_id": run_id,
        "status": status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage or None,
        "timestamp": stamp(),
        "metrics": metrics,
    }
    write_json(root / "status.json", result)
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0 if status == "passed" else 1


def system(path: str) -> int:
    payload = {
        "captured_at": stamp(),
        "hostname": command("hostname"),
        "architecture": command("uname", "-m"),
        "kernel": command("uname", "-r"),
        "os_release": command("cat", "/etc/os-release"),
        "cpu_model": command("sh", "-c", "lscpu | sed -n 's/^Model name: *//p'"),
        "cpu_count": command("nproc", "--all"),
        "numa_nodes": command("sh", "-c", "lscpu | sed -n 's/^NUMA node(s): *//p'"),
        "virsh_version": command("sh", "-c", "virsh --version 2>/dev/null || true"),
    }
    write_json(Path(path), payload)
    return 0


def runtime(path: str) -> int:
    payload = {
        "captured_at": stamp(),
    }
    write_json(Path(path), payload)
    return 0


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: standalone_runtime.py finalize|system|runtime ...", file=sys.stderr)
        return 2
    action = sys.argv[1]
    if action == "finalize":
        return finalize(sys.argv[2:])
    if action == "system":
        return system(sys.argv[2])
    if action == "runtime":
        return runtime(sys.argv[2])
    print(f"unknown action: {action}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
