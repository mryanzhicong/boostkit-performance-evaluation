#!/usr/bin/env python3
"""Render a global workflow summary and its cross-architecture metrics."""

from __future__ import annotations


DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "target_is_better": "越接近目标越好",
    "neutral": "仅展示",
}

ARCHITECTURE_ORDER = ("aarch64", "x86_64")


def _result_key(item: dict) -> tuple[str, str, str]:
    return (
        str(item.get("category", "")),
        str(item.get("software", "")),
        str(item.get("version", "")),
    )


def _metric_names(item: dict, comparison_orders: dict[tuple[str, str, str], list[str]]) -> list[str]:
    metrics = item.get("metrics", {})
    comparison_order = comparison_orders.get(_result_key(item), [])
    ordered = [name for name in comparison_order if name in metrics]
    ordered.extend(sorted(name for name in metrics if name not in ordered))
    return ordered


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
    metric_items = [item for item in summary.get("items", []) if item.get("metrics")]
    if metric_items:
        comparison_orders = {
            _result_key(comparison): list(comparison.get("metrics", {}))
            for comparison in comparisons or []
        }
        available_architectures = {str(item.get("architecture")) for item in metric_items}
        architecture_order = [
            architecture for architecture in ARCHITECTURE_ORDER
            if architecture in available_architectures
        ]
        architecture_order.extend(sorted(available_architectures - set(architecture_order)))
        lines.extend(["## 单架构指标", ""])
        for architecture in architecture_order:
            lines.extend([
                f"### {architecture}",
                "",
                "| 软件 | 版本 | 指标 | 数值 | 单位 | 优化方向 |",
                "|---|---|---|---:|---|---|",
            ])
            architecture_items = sorted(
                (item for item in metric_items if item.get("architecture") == architecture),
                key=_result_key,
            )
            for item in architecture_items:
                for name in _metric_names(item, comparison_orders):
                    metric = item["metrics"][name]
                    direction = DIRECTION_LABELS.get(
                        metric.get("direction"), metric.get("direction")
                    )
                    lines.append(
                        f"| {item.get('software')} | {item.get('version')} | "
                        f"{name} | {metric.get('value')} | "
                        f"{metric.get('unit', '')} | {direction} |"
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
