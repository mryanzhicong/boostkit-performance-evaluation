"""Render single-run, comparison, summary, and JUnit reports."""

from __future__ import annotations

import json
from xml.etree.ElementTree import Element, SubElement, tostring

DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "neutral": "仅展示",
}
ARCHITECTURE_ORDER = ("aarch64", "x86_64")
ENVIRONMENT_ARCHITECTURES = (("x86_64", "x86"), ("aarch64", "aarch64"))
FIELD_LABELS = {
    "recorded_at": "构建信息记录时间",
    "requested_version": "请求软件版本",
    "actual_version": "实际软件版本",
    "collected_at": "采集时间",
    "architecture": "系统架构",
    "platform": "操作系统",
    "kernel": "内核",
    "cpu_model": "CPU 型号",
    "cpu_count": "CPU 核数",
    "python_version": "Python 版本",
    "gcc_version": "GCC 版本",
    "glibc_version": "glibc 版本",
    "numa": "NUMA",
    "memory": "内存状态",
    "cpu_governor": "CPU governor",
}
BUILD_FIELD_ORDER = ("requested_version", "actual_version", "recorded_at")
SYSTEM_FIELD_ORDER = (
    "collected_at",
    "architecture",
    "cpu_model",
    "cpu_count",
    "platform",
    "kernel",
    "python_version",
    "gcc_version",
    "glibc_version",
    "numa",
)


def direction_label(direction: object) -> str:
    value = str(direction)
    return DIRECTION_LABELS.get(value, value)


def _cell(value: object) -> str:
    if value is None or value == "":
        return "N/A"
    if isinstance(value, (dict, list)):
        rendered = json.dumps(value, ensure_ascii=False, sort_keys=True)
    else:
        rendered = str(value)
    return rendered.replace("|", "\\|").replace("\r\n", "<br>").replace("\n", "<br>")


def _ordered_fields(data: dict, preferred: tuple[str, ...]) -> list[str]:
    ordered = [field for field in preferred if field in data]
    ordered.extend(sorted(field for field in data if field not in ordered))
    return ordered


def _environment_section(
    environments: dict[str, dict],
    title: str,
    source: str,
    preferred_fields: tuple[str, ...],
    heading_level: int,
) -> list[str]:
    values_by_architecture: dict[str, dict] = {}
    all_fields: dict[str, object] = {}
    for architecture, _label in ENVIRONMENT_ARCHITECTURES:
        environment = environments.get(architecture, {})
        values = environment.get(source, {}) if isinstance(environment, dict) else {}
        if not isinstance(values, dict):
            values = {}
        values_by_architecture[architecture] = values
        all_fields.update(values)
    fields = [
        field
        for field in _ordered_fields(all_fields, preferred_fields)
        if field not in {"category", "software", "run_id"}
    ]
    if not fields:
        return []
    headers = ("项目", *(label for _architecture, label in ENVIRONMENT_ARCHITECTURES))
    lines = [
        f"{'#' * heading_level} {title}",
        "",
        "| " + " | ".join(headers) + " |",
        "|" + "|".join("---" for _ in headers) + "|",
    ]
    for field in fields:
        row = [
            FIELD_LABELS.get(field, field),
            *(values_by_architecture[architecture].get(field) for architecture, _ in ENVIRONMENT_ARCHITECTURES),
        ]
        lines.append("| " + " | ".join(_cell(value) for value in row) + " |")
    lines.append("")
    return lines


def _environment_tables(
    environments: dict[str, dict], heading_level: int = 3
) -> list[str]:
    lines: list[str] = []
    lines.extend(
        _environment_section(
            environments, "构建信息", "build_info", BUILD_FIELD_ORDER, heading_level
        )
    )
    lines.extend(
        _environment_section(
            environments, "系统信息", "system_info", SYSTEM_FIELD_ORDER, heading_level
        )
    )
    return lines


def render_single(data: dict) -> str:
    lines = [
        f"# {data.get('software')} {data.get('version')} 性能报告",
        "",
        f"- 架构：`{data.get('architecture')}`",
        f"- 状态：`{data.get('status')}`",
        f"- Run ID：`{data.get('run_id')}`",
        "",
        "## 测试环境",
        "",
    ]
    architecture = str(data.get("architecture", ""))
    lines.extend(_environment_tables({architecture: data}))
    lines.extend([
        "## 性能指标",
        "",
        "| 指标 | 数值 | 单位 | 优化方向 |",
        "|---|---:|---|---|",
    ])
    for name, metric in data.get("metrics", {}).items():
        value = metric.get("value")
        lines.append(
            f"| {name} | {value if value is not None else 'N/A'} | "
            f"{metric.get('unit', '')} | {direction_label(metric.get('direction'))} |"
        )
    lines.append("")
    return "\n".join(lines)


def render_comparison(comparison: dict) -> str:
    lines = [
        f"# {comparison['software']} {comparison['version']} 跨架构对比",
        "",
        "| 指标 | 优化方向 | x86_64 | aarch64 | ARM/x86 原始比值 | 相对性能 |",
        "|---|---|---:|---:|---:|---:|",
    ]
    for name, metric in comparison.get("metrics", {}).items():
        raw = metric.get("raw_ratio")
        relative = metric.get("relative_performance")
        lines.append(
            f"| {name} | {direction_label(metric.get('direction'))} | "
            f"{metric.get('x86_64', 'N/A')} | {metric.get('aarch64', 'N/A')} | "
            f"{raw if raw is not None else 'N/A'} | "
            f"{relative if relative is not None else 'N/A'} |"
        )
    lines.extend([
        "",
        "> 相对性能大于 1 表示 aarch64 更优，小于 1 表示 x86_64 更优。",
        "",
    ])
    environments = comparison.get("environments", {})
    if isinstance(environments, dict) and environments:
        lines.extend(["## 测试环境", ""])
        lines.extend(_environment_tables(environments))
    return "\n".join(lines)


def _result_key(item: dict) -> tuple[str, str, str]:
    return (
        str(item.get("category", "")),
        str(item.get("software", "")),
        str(item.get("version", "")),
    )


def _metric_names(
    item: dict, comparison_orders: dict[tuple[str, str, str], list[str]]
) -> list[str]:
    metrics = item.get("metrics", {})
    comparison_order = comparison_orders.get(_result_key(item), [])
    ordered = [name for name in comparison_order if name in metrics]
    ordered.extend(sorted(name for name in metrics if name not in ordered))
    return ordered


def render_summary(summary: dict, comparisons: list[dict] | None = None) -> str:
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
            f"{item.get('architecture')} | {item.get('status')} | "
            f"{item.get('cleanup_status')} |"
        )
    lines.append("")
    environment_items = [
        item
        for item in summary.get("items", [])
        if any(item.get(field) for field in (
            "build_info", "system_info", "runtime_before", "runtime_after"
        ))
    ]
    if environment_items:
        lines.extend(["## 测试环境", ""])
        grouped_environments: dict[tuple[str, str, str], dict[str, dict]] = {}
        for item in sorted(environment_items, key=_result_key):
            key = _result_key(item)
            architecture = str(item.get("architecture", ""))
            grouped_environments.setdefault(key, {})[architecture] = item
        for (_category, software, version), environments in grouped_environments.items():
            lines.extend([f"### {software} {version}", ""])
            lines.extend(_environment_tables(environments, heading_level=4))
    metric_items = [item for item in summary.get("items", []) if item.get("metrics")]
    if metric_items:
        comparison_orders = {
            _result_key(comparison): list(comparison.get("metrics", {}))
            for comparison in comparisons or []
        }
        available_architectures = {str(item.get("architecture")) for item in metric_items}
        architecture_order = [
            architecture
            for architecture in ARCHITECTURE_ORDER
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
                    lines.append(
                        f"| {item.get('software')} | {item.get('version')} | {name} | "
                        f"{metric.get('value')} | {metric.get('unit', '')} | "
                        f"{direction_label(metric.get('direction'))} |"
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
                relative = metric.get("relative_performance")
                lines.append(
                    f"| {comparison.get('software')} | {comparison.get('version')} | {name} | "
                    f"{direction_label(metric.get('direction'))} | {metric.get('x86_64')} | "
                    f"{metric.get('aarch64')} | "
                    f"{relative if relative is not None else 'N/A'} |"
                )
        lines.extend([
            "",
            "> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。",
            "",
        ])
    return "\n".join(lines)


def render_junit(results: list[dict]) -> str:
    failures = sum(1 for result in results if result.get("status") != "passed")
    suite = Element(
        "testsuite", name="performance", tests=str(len(results)), failures=str(failures)
    )
    for result in results:
        case = SubElement(
            suite,
            "testcase",
            classname=f"{result.get('category')}.{result.get('software')}",
            name=f"{result.get('version')}.{result.get('architecture')}",
        )
        if result.get("status") != "passed":
            failure = SubElement(case, "failure", message="performance task failed")
            failure.text = str(result.get("status"))
    return tostring(suite, encoding="unicode") + "\n"
