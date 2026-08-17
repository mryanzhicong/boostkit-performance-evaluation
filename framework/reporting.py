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
RUNTIME_FIELD_ORDER = ("collected_at", "memory", "cpu_governor")


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


def _environment_rows(data: dict) -> list[tuple[str, str, object, object, object]]:
    build_info = data.get("build_info", {})
    system_info = data.get("system_info", {})
    runtime_before = data.get("runtime_before", {})
    runtime_after = data.get("runtime_after", {})
    rows: list[tuple[str, str, object, object, object]] = []
    if isinstance(build_info, dict) and build_info:
        for field in _ordered_fields(build_info, BUILD_FIELD_ORDER):
            if field in {"category", "software", "architecture", "run_id"}:
                continue
            rows.append(
                ("构建信息", FIELD_LABELS.get(field, field), build_info[field], None, None)
            )
    if isinstance(system_info, dict) and system_info:
        for field in _ordered_fields(system_info, SYSTEM_FIELD_ORDER):
            rows.append(
                ("系统信息", FIELD_LABELS.get(field, field), system_info[field], None, None)
            )
    before = runtime_before if isinstance(runtime_before, dict) else {}
    after = runtime_after if isinstance(runtime_after, dict) else {}
    if before or after:
        fields = _ordered_fields({**before, **after}, RUNTIME_FIELD_ORDER)
        for field in fields:
            rows.append(
                (
                    "运行状态",
                    FIELD_LABELS.get(field, field),
                    None,
                    before.get(field),
                    after.get(field),
                )
            )
    return rows


def _environment_table(
    entries: list[tuple[tuple[object, ...], dict]],
    identity_headers: tuple[str, ...] = (),
) -> list[str]:
    rows = [
        (*identity, *environment_row)
        for identity, data in entries
        for environment_row in _environment_rows(data)
    ]
    if not rows:
        return []
    headers = (*identity_headers, "类型", "项目", "固定值", "测试前", "测试后")
    lines = [
        "| " + " | ".join(headers) + " |",
        "|" + "|".join("---" for _ in headers) + "|",
    ]
    lines.extend(
        "| " + " | ".join(_cell(value) for value in row) + " |" for row in rows
    )
    lines.append("")
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
    lines.extend(_environment_table([((), data)]))
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
        entries = [
            ((architecture,), environments[architecture])
            for architecture in ARCHITECTURE_ORDER
            if isinstance(environments.get(architecture), dict)
            and environments[architecture]
        ]
        lines.extend(_environment_table(entries, ("架构",)))
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
        sorted_items = sorted(
            environment_items,
            key=lambda value: (*_result_key(value), str(value.get("architecture", ""))),
        )
        entries = [
            ((item.get("software"), item.get("version"), item.get("architecture")), item)
            for item in sorted_items
        ]
        lines.extend(_environment_table(entries, ("软件", "版本", "架构")))
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
