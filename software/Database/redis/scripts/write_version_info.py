#!/usr/bin/env python3
"""Write Redis and runner identity captured immediately after the source build."""

from __future__ import annotations

import json
import os
import platform
import sys
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 5:
        print("usage: write_version_info.py OUTPUT REQUESTED ACTUAL ARCH", file=sys.stderr)
        return 1
    output, requested, actual, architecture = sys.argv[1:]
    payload = {
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "software": "redis",
        "software_version": actual,
        "requested_version": requested,
        "architecture": architecture,
        "cpu_model": platform.processor() or "unknown",
        "cpu_cores": os.cpu_count(),
        "os": platform.platform(),
        "kernel": platform.release(),
        "python_version": platform.python_version(),
    }
    path = Path(output)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
