#!/usr/bin/env python3
"""Render a global workflow summary and its cross-architecture metrics."""

from __future__ import annotations


DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "target_is_better": "越接近目标越好",
    "neutral": "仅展示",
}


def render(summary: dict, comparisons: list[dict] | None = None) -> str:
    lines = [
        "# 性能测试汇总",
        "",
        f"- 任务总数：{summary.get('total', 0)}",
        f"- 成功：{summary.get('passed', 0)}",
        f"- 失败：{summary.get('failed', 0)}",
        f"- 跨架构对比：{summary.get('comparisons', 0)}",
        "",
        "| 分类 | 软件 | 版本 | 架构 | 状态 | 环境清理 |",
        "|---|---|---|---|---|---|",
    ]
    for item in summary.get("items", []):
        lines.append(
            f"| {item.get('category')} | {item.get('software')} | {item.get('version')} | "
            f"{item.get('architecture')} | {item.get('status')} | {item.get('cleanup_status')} |"
        )
    lines.append("")
    if comparisons:
        lines.extend([
            "## 跨架构指标",
            "",
            "| 软件 | 版本 | 指标 | 优化方向 | x86_64 | aarch64 | aarch64 相对性能 |",
            "|---|---|---|---|---:|---:|---:|",
        ])
        for comparison in comparisons:
            for name, metric in comparison.get("metrics", {}).items():
                direction = DIRECTION_LABELS.get(metric.get("direction"), metric.get("direction"))
                relative = metric.get("relative_performance")
                lines.append(
                    f"| {comparison.get('software')} | {comparison.get('version')} | {name} | "
                    f"{direction} | {metric.get('x86_64')} | {metric.get('aarch64')} | "
                    f"{relative if relative is not None else 'N/A'} |"
                )
        lines.extend([
            "",
            "> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。",
            "",
        ])
    return "\n".join(lines)
