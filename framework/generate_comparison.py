#!/usr/bin/env python3
"""Aggregate downloaded task artifacts and generate cross-architecture reports."""

from __future__ import annotations

import argparse
import json
import math
from collections import defaultdict
from pathlib import Path
from typing import Any

from json_helper import atomic_write_json, load_json
from reporting import render_comparison, render_junit, render_summary


def _number(value: Any) -> float | None:
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return float(value)
    return None


def compare_pair(x86: dict, arm: dict) -> dict:
    for field in ("category", "software", "version"):
        if x86.get(field) != arm.get(field):
            raise ValueError(f"result identity differs for {field}")
    if x86.get("parameters", {}) != arm.get("parameters", {}):
        raise ValueError("resolved workload parameters differ")
    if x86.get("parameter_signature") != arm.get("parameter_signature"):
        raise ValueError("parameter signatures differ")
    x_metrics = x86.get("metrics", {})
    a_metrics = arm.get("metrics", {})
    if not isinstance(x_metrics, dict) or not isinstance(a_metrics, dict) or not x_metrics:
        raise ValueError("both architectures must contain metrics")
    if set(x_metrics) != set(a_metrics):
        raise ValueError("metric sets differ between architectures")
    metrics: dict[str, Any] = {}
    for name in sorted(x_metrics):
        x_metric = x_metrics[name]
        a_metric = a_metrics[name]
        if x_metric.get("unit") != a_metric.get("unit"):
            raise ValueError(f"metric {name} units differ between architectures")
        if x_metric.get("direction") != a_metric.get("direction"):
            raise ValueError(f"metric {name} directions differ between architectures")
        x_value = _number(x_metric.get("value"))
        a_value = _number(a_metric.get("value"))
        if (
            x_value is None
            or a_value is None
            or not math.isfinite(x_value)
            or not math.isfinite(a_value)
        ):
            raise ValueError(f"metric {name} must contain finite numeric values")
        direction = a_metric["direction"]
        raw_ratio = a_value / x_value if x_value not in (None, 0) and a_value is not None else None
        relative = None
        if raw_ratio is not None:
            if direction == "higher_is_better":
                relative = raw_ratio
            elif direction == "lower_is_better" and raw_ratio != 0:
                relative = 1 / raw_ratio
        metrics[name] = {
            "x86_64": x_metric.get("value"),
            "aarch64": a_metric.get("value"),
            "unit": a_metric.get("unit", x_metric.get("unit", "")),
            "direction": direction,
            "raw_ratio": round(raw_ratio, 4) if raw_ratio is not None else None,
            "relative_performance": round(relative, 4) if relative is not None else None,
        }
    return {
        "category": arm["category"],
        "software": arm["software"],
        "version": arm["version"],
        "parameter_signature": arm.get("parameter_signature"),
        "environments": {
            architecture: {
                field: result.get(field, {})
                for field in (
                    "build_info",
                    "system_info",
                    "runtime_before",
                    "runtime_after",
                )
            }
            for architecture, result in (("x86_64", x86), ("aarch64", arm))
        },
        "metrics": metrics,
    }


def generate(input_root: Path, output_dir: Path) -> dict:
    normalized_paths = sorted(input_root.rglob("normalized_result.json"))
    normalized_dirs = {path.parent.resolve() for path in normalized_paths}
    results = [load_json(path, {}) for path in normalized_paths]
    for status_path in sorted(input_root.rglob("status.json")):
        if status_path.parent.resolve() in normalized_dirs:
            continue
        status = load_json(status_path, {})
        if status:
            results.append({
                "category": status.get("category", "unknown"),
                "software": status.get("software", "unknown"),
                "version": status.get("version", "unknown"),
                "architecture": status.get("architecture", "unknown"),
                "run_id": status.get("run_id"),
                "status": status.get("status", "failed"),
                "failed_stage": status.get("failed_stage"),
                "cleanup_status": status.get("cleanup_status"),
                "metrics": {},
            })
    results = [result for result in results if result]
    grouped: dict[tuple, dict[str, dict]] = defaultdict(dict)
    for result in results:
        key = (result.get("category"), result.get("software"), result.get("version"))
        grouped[key][result.get("architecture")] = result

    output_dir.mkdir(parents=True, exist_ok=True)
    comparisons: list[dict] = []
    for key, architectures in sorted(grouped.items()):
        if "x86_64" not in architectures or "aarch64" not in architectures:
            continue
        x86 = architectures["x86_64"]
        arm = architectures["aarch64"]
        if any(
            result.get("status") != "passed" or result.get("cleanup_status") != "passed"
            for result in (x86, arm)
        ):
            continue
        comparison = compare_pair(x86, arm)
        comparisons.append(comparison)
        stem = f"{comparison['category']}-{comparison['software']}-{comparison['version']}"
        atomic_write_json(output_dir / f"{stem}.json", comparison)
        (output_dir / f"{stem}.md").write_text(render_comparison(comparison), encoding="utf-8")

    items = [{
        "category": result.get("category"),
        "software": result.get("software"),
        "version": result.get("version"),
        "architecture": result.get("architecture"),
        "status": result.get("status"),
        "cleanup_status": result.get("cleanup_status", "unknown"),
        "build_info": result.get("build_info", {}),
        "system_info": result.get("system_info", {}),
        "runtime_before": result.get("runtime_before", {}),
        "runtime_after": result.get("runtime_after", {}),
        "metrics": result.get("metrics", {}),
    } for result in results]
    summary = {
        "total": len(results),
        "passed": sum(1 for result in results if result.get("status") == "passed"),
        "failed": sum(1 for result in results if result.get("status") != "passed"),
        "comparisons": len(comparisons),
        "items": items,
    }
    atomic_write_json(
        output_dir / "combined-report.json",
        {"summary": summary, "comparisons": comparisons},
    )
    (output_dir / "combined-report.md").write_text(
        render_summary(summary, comparisons), encoding="utf-8"
    )
    (output_dir / "junit.xml").write_text(render_junit(results), encoding="utf-8")
    return summary


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()
    summary = generate(args.input_root, args.output_dir)
    print(json.dumps(summary, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
