#!/usr/bin/env python3
"""Collect real runner environment data before and after a benchmark."""

from __future__ import annotations

import argparse
import os
import platform
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from json_helper import atomic_write_json


def _command(args: list[str]) -> str:
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=10, check=False)
        return result.stdout.strip() if result.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def _cpu_model() -> str:
    try:
        for line in Path("/proc/cpuinfo").read_text(encoding="utf-8", errors="replace").splitlines():
            if line.lower().startswith(("model name", "hardware", "processor")) and ":" in line:
                value = line.split(":", 1)[1].strip()
                if value:
                    return value
    except OSError:
        pass
    return platform.processor() or "unknown"


def collect() -> dict:
    return {
        "collected_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "architecture": platform.machine(),
        "platform": platform.platform(),
        "kernel": platform.release(),
        "cpu_model": _cpu_model(),
        "cpu_count": os.cpu_count() or 0,
        "python_version": platform.python_version(),
        "memory": _command(["free", "-b"]),
        "numa": _command(["numactl", "--hardware"]),
        "cpu_governor": _command(["sh", "-c", "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null"]),
        "container_runtime": _command(["docker", "version", "--format", "{{.Server.Version}}"]),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    atomic_write_json(args.output, collect())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
