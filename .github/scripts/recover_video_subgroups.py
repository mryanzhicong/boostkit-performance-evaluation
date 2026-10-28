#!/usr/bin/env python3
"""Align video headings between results recorded before and after subgroups.

Only the downloaded report copy is modified. Benchmark values are untouched.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


MODE_GROUPS = {"single": "单路", "whole_machine": "整机"}


def align_subgroups(x86: dict, arm: dict, software: str, version: str) -> int:
    for field, expected in (("category", "Media"), ("software", software), ("version", version)):
        if x86.get(field) != expected or arm.get(field) != expected:
            raise ValueError(f"unexpected result identity: {field}")
    if x86.get("architecture") != "x86_64" or arm.get("architecture") != "aarch64":
        raise ValueError("unexpected result architectures")
    x_metrics = x86.get("metrics")
    a_metrics = arm.get("metrics")
    if (
        not isinstance(x_metrics, dict)
        or not isinstance(a_metrics, dict)
        or not x_metrics
        or set(x_metrics) != set(a_metrics)
    ):
        raise ValueError(f"{software} metric names differ between architectures")

    changed = 0
    for name, x_metric in x_metrics.items():
        a_metric = a_metrics[name]
        if not isinstance(x_metric, dict) or not isinstance(a_metric, dict):
            raise ValueError(f"invalid metric: {name}")
        parts = name.split("/")
        if len(parts) != 4 or parts[0] not in MODE_GROUPS or not parts[1] or parts[3] != "total_fps":
            raise ValueError(f"unexpected {software} metric name: {name}")
        expected_group = MODE_GROUPS[parts[0]]
        video = parts[1]
        if x_metric.get("group") != expected_group or a_metric.get("group") != expected_group:
            raise ValueError(f"metric group differs from name: {name}")
        if x_metric.get("subgroup") != video:
            raise ValueError(f"x86_64 subgroup differs from video name: {name}")
        if a_metric.get("subgroup") is None:
            a_metric["subgroup"] = video
            changed += 1
        elif a_metric["subgroup"] != video:
            raise ValueError(f"aarch64 subgroup differs from video name: {name}")
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-root", required=True, type=Path)
    parser.add_argument("--software", required=True, choices=("x264", "x265"))
    parser.add_argument("--version", required=True)
    args = parser.parse_args()
    base = args.input_root / "Media" / args.software / args.version
    x86_path = base / "x86_64" / "normalized_result.json"
    arm_path = base / "aarch64" / "normalized_result.json"
    x86 = json.loads(x86_path.read_text(encoding="utf-8"))
    arm = json.loads(arm_path.read_text(encoding="utf-8"))
    changed = align_subgroups(x86, arm, args.software, args.version)
    if changed:
        temporary = arm_path.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(arm, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        temporary.replace(arm_path)
    print(f"[{args.software}-recovery] aligned {changed} historical aarch64 video subgroups")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
