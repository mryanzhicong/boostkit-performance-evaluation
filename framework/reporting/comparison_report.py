#!/usr/bin/env python3
"""Render one x86_64/aarch64 comparison as Markdown."""

from __future__ import annotations

DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "target_is_better": "越接近目标越好",
    "neutral": "仅展示",
}


def render(comparison: dict) -> str:
    lines = [
        f"# {comparison['software']} {comparison['version']} 跨架构对比",
        "",
        "| 指标 | 优化方向 | x86_64 | aarch64 | ARM/x86 原始比值 | 相对性能 |",
        "|---|---|---:|---:|---:|---:|",
    ]
    for name, metric in comparison.get("metrics", {}).items():
        direction = DIRECTION_LABELS.get(metric.get("direction"), metric.get("direction"))
        raw = metric.get("raw_ratio")
        relative = metric.get("relative_performance")
        lines.append(
            f"| {name} | {direction} | {metric.get('x86_64', 'N/A')} | "
            f"{metric.get('aarch64', 'N/A')} | {raw if raw is not None else 'N/A'} | "
            f"{relative if relative is not None else 'N/A'} |"
        )
    lines.extend([
        "",
        "> 相对性能大于 1 表示 aarch64 更优，小于 1 表示 x86_64 更优。目标型指标按目标偏差判断。",
        "",
    ])
    return "\n".join(lines)
