"""Render single-run, comparison, summary, and JUnit reports."""

from __future__ import annotations

import json
import re
from html import escape
from xml.etree.ElementTree import Element, SubElement, tostring

DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "neutral": "仅展示",
}
ARCHITECTURE_ORDER = ("x86_64", "aarch64")
ENVIRONMENT_ARCHITECTURES = (("x86_64", "x86_64"), ("aarch64", "aarch64"))
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
ENVIRONMENT_LABEL_COLUMN_WIDTH = 180
REPORT_TABLE_WIDTH = 1380
SUMMARY_STATUS_COLUMN_WIDTHS = (180, 220, 160, 220, 240, 360)
SINGLE_METRIC_COLUMN_WIDTHS = (180, 160, 420, 200, 160, 260)
CROSS_METRIC_COLUMN_WIDTHS = (160, 140, 340, 180, 160, 160, 240)
COMPARISON_METRIC_COLUMN_WIDTHS = (380, 200, 180, 180, 220, 220)
REPORT_METRIC_COLUMN_WIDTHS = (500, 280, 200, 400)
TEST_TOOL_COLUMN_WIDTHS = (500, 880)
SYSBENCH_METRIC_PATTERN = re.compile(
    r"^sysbench (?P<scenario>.+) --threads=(?P<threads>\d+): (?P<field>TPS|QPS|transactions)$"
)
SYSBENCH_FIELDS = ("TPS", "QPS", "transactions")
SYSBENCH_FIELD_UNITS = {
    "TPS": "transactions/s",
    "QPS": "queries/s",
    "transactions": "transactions",
}
SYSBENCH_SINGLE_COLUMN_WIDTHS = (180, 400, 400, 400)
SYSBENCH_COMPARISON_COLUMN_WIDTHS = (150, 300, 190, 190, 190, 360)


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


def _html_cell(value: object) -> str:
    if value is None or value == "":
        return "N/A"
    if isinstance(value, (dict, list)):
        rendered = json.dumps(value, ensure_ascii=False, sort_keys=True)
    else:
        rendered = str(value)
    return escape(rendered).replace("\r\n", "<br>").replace("\n", "<br>")


def _fixed_width_table(
    headers: tuple[str, ...],
    rows: list[list[object]],
    column_widths: tuple[int, ...],
) -> list[str]:
    if len(headers) != len(column_widths):
        raise ValueError("table headers and column widths differ")
    if sum(column_widths) != REPORT_TABLE_WIDTH:
        raise ValueError(f"table width must be {REPORT_TABLE_WIDTH}px")
    lines = [f'<table width="{REPORT_TABLE_WIDTH}">', "  <thead>", "    <tr>"]
    for header, width in zip(headers, column_widths, strict=True):
        lines.append(f'      <th width="{width}">{_html_cell(header)}</th>')
    lines.extend(["    </tr>", "  </thead>", "  <tbody>"])
    for row in rows:
        lines.append("    <tr>")
        for value, width in zip(row, column_widths, strict=True):
            lines.append(f'      <td width="{width}">{_html_cell(value)}</td>')
        lines.append("    </tr>")
    lines.extend(["  </tbody>", "</table>", ""])
    return lines


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
    architecture_columns: tuple[tuple[str, str], ...],
) -> list[str]:
    values_by_architecture: dict[str, dict] = {}
    all_fields: dict[str, object] = {}
    for architecture, _label in architecture_columns:
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
    headers = ("项目", *(label for _architecture, label in architecture_columns))
    value_column_width = (
        REPORT_TABLE_WIDTH - ENVIRONMENT_LABEL_COLUMN_WIDTH
    ) // len(architecture_columns)
    column_widths = (
        ENVIRONMENT_LABEL_COLUMN_WIDTH,
        *(value_column_width for _ in architecture_columns),
    )
    rows: list[list[object]] = []
    for field in fields:
        rows.append([
            FIELD_LABELS.get(field, field),
            *(
                values_by_architecture[architecture].get(field)
                for architecture, _label in architecture_columns
            ),
        ])
    lines = [f"{'#' * heading_level} {title}", ""]
    lines.extend(_fixed_width_table(headers, rows, column_widths))
    return lines


def _environment_tables(
    environments: dict[str, dict],
    heading_level: int = 3,
    architecture_columns: tuple[tuple[str, str], ...] = ENVIRONMENT_ARCHITECTURES,
) -> list[str]:
    lines: list[str] = []
    lines.extend(
        _environment_section(
            environments,
            "构建信息",
            "build_info",
            BUILD_FIELD_ORDER,
            heading_level,
            architecture_columns,
        )
    )
    lines.extend(
        _environment_section(
            environments,
            "系统信息",
            "system_info",
            SYSTEM_FIELD_ORDER,
            heading_level,
            architecture_columns,
        )
    )
    return lines


def _test_tools_section(test_tools: object, heading_level: int) -> list[str]:
    if not isinstance(test_tools, dict) or not test_tools:
        return []
    rows: list[list[object]] = []
    for name, definition in test_tools.items():
        if not isinstance(definition, dict):
            continue
        version = definition.get("version")
        revision = definition.get("revision")
        if isinstance(revision, str) and revision:
            version = f"{version} ({revision})"
        rows.append([name, version])
    if not rows:
        return []
    lines = [f"{'#' * heading_level} 测试工具", ""]
    lines.extend(
        _fixed_width_table(
            ("工具", "版本"),
            rows,
            TEST_TOOL_COLUMN_WIDTHS,
        )
    )
    return lines


def _sysbench_metric_groups(
    metrics: dict,
    metric_names: list[str],
) -> tuple[dict[str, dict[int, dict[str, dict]]], list[str]]:
    """Separate database_blue Sysbench metrics by workload and thread count."""
    groups: dict[str, dict[int, dict[str, dict]]] = {}
    other_names: list[str] = []
    for name in metric_names:
        metric = metrics.get(name)
        if not isinstance(metric, dict):
            other_names.append(name)
            continue
        match = SYSBENCH_METRIC_PATTERN.fullmatch(name)
        if match is None:
            other_names.append(name)
            continue
        scenario = match.group("scenario")
        threads = int(match.group("threads"))
        field = match.group("field")
        groups.setdefault(scenario, {}).setdefault(threads, {})[field] = metric
    return groups, other_names


def _sysbench_single_tables(
    groups: dict[str, dict[int, dict[str, dict]]],
    heading_level: int,
) -> list[str]:
    lines: list[str] = []
    headers = (
        "线程数",
        *(f"{field}（{SYSBENCH_FIELD_UNITS[field]}）" for field in SYSBENCH_FIELDS),
    )
    for scenario, by_threads in groups.items():
        lines.extend([f"{'#' * heading_level} {scenario}", ""])
        rows = []
        for threads in sorted(by_threads):
            rows.append([
                threads,
                *(
                    by_threads[threads].get(field, {}).get("value")
                    for field in SYSBENCH_FIELDS
                ),
            ])
        lines.extend(_fixed_width_table(headers, rows, SYSBENCH_SINGLE_COLUMN_WIDTHS))
        lines.extend(["> TPS、QPS 和 transactions 均为越大越好。", ""])
    return lines


def _sysbench_comparison_tables(
    groups: dict[str, dict[int, dict[str, dict]]],
    heading_level: int,
) -> list[str]:
    lines: list[str] = []
    for scenario, by_threads in groups.items():
        lines.extend([f"{'#' * heading_level} {scenario}", ""])
        rows = []
        for threads in sorted(by_threads):
            for field in SYSBENCH_FIELDS:
                metric = by_threads[threads].get(field, {})
                relative = metric.get("relative_performance")
                rows.append([
                    threads,
                    f"{field}（{SYSBENCH_FIELD_UNITS[field]}）",
                    direction_label(metric.get("direction")),
                    metric.get("x86_64"),
                    metric.get("aarch64"),
                    relative if relative is not None else "N/A",
                ])
        lines.extend(
            _fixed_width_table(
                ("线程数", "指标", "优化方向", "x86_64", "aarch64", "aarch64 相对性能"),
                rows,
                SYSBENCH_COMPARISON_COLUMN_WIDTHS,
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
    architecture_labels = dict(ENVIRONMENT_ARCHITECTURES)
    lines.extend(
        _environment_tables(
            {architecture: data},
            architecture_columns=((
                architecture,
                architecture_labels.get(architecture, architecture),
            ),),
        )
    )
    lines.extend(_test_tools_section(data.get("test_tools"), heading_level=3))
    lines.extend(["## 性能指标", ""])
    metrics = data.get("metrics", {})
    sysbench_groups, other_names = _sysbench_metric_groups(metrics, list(metrics))
    if sysbench_groups:
        lines.extend(_sysbench_single_tables(sysbench_groups, heading_level=3))
    if not other_names:
        return "\n".join(lines)
    metric_rows: list[list[object]] = []
    for name in other_names:
        metric = metrics[name]
        value = metric.get("value")
        metric_rows.append([
            name,
            value if value is not None else "N/A",
            metric.get("unit", ""),
            direction_label(metric.get("direction")),
        ])
    lines.extend(
        _fixed_width_table(
            ("指标", "数值", "单位", "优化方向"),
            metric_rows,
            REPORT_METRIC_COLUMN_WIDTHS,
        )
    )
    return "\n".join(lines)


def render_comparison(comparison: dict) -> str:
    lines = [f"# {comparison['software']} {comparison['version']} 跨架构对比", ""]
    metrics = comparison.get("metrics", {})
    sysbench_groups, other_names = _sysbench_metric_groups(metrics, list(metrics))
    if sysbench_groups:
        lines.extend(_sysbench_comparison_tables(sysbench_groups, heading_level=2))
    metric_rows: list[list[object]] = []
    for name in other_names:
        metric = metrics[name]
        raw = metric.get("raw_ratio")
        relative = metric.get("relative_performance")
        metric_rows.append([
            name,
            direction_label(metric.get("direction")),
            metric.get("x86_64", "N/A"),
            metric.get("aarch64", "N/A"),
            raw if raw is not None else "N/A",
            relative if relative is not None else "N/A",
        ])
    if metric_rows:
        lines.extend(
            _fixed_width_table(
                ("指标", "优化方向", "x86_64", "aarch64", "ARM/x86 原始比值", "相对性能"),
                metric_rows,
                COMPARISON_METRIC_COLUMN_WIDTHS,
            )
        )
    if sysbench_groups or metric_rows:
        lines.extend([
            "> 相对性能大于 1 表示 aarch64 更优，小于 1 表示 x86_64 更优。",
            "",
        ])
    environments = comparison.get("environments", {})
    if isinstance(environments, dict) and environments:
        lines.extend(["## 测试环境", ""])
        lines.extend(_environment_tables(environments))
    lines.extend(_test_tools_section(comparison.get("test_tools"), heading_level=3))
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
    ]
    status_rows: list[list[object]] = []
    for item in summary.get("items", []):
        status_rows.append([
            item.get("category"),
            item.get("software"),
            item.get("version"),
            item.get("architecture"),
            item.get("status"),
            item.get("cleanup_status"),
        ])
    lines.extend(
        _fixed_width_table(
            ("分类", "软件", "版本", "架构", "状态", "环境清理"),
            status_rows,
            SUMMARY_STATUS_COLUMN_WIDTHS,
        )
    )
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
            for environment in environments.values():
                test_tools = environment.get("test_tools")
                if isinstance(test_tools, dict) and test_tools:
                    lines.extend(_test_tools_section(test_tools, heading_level=4))
                    break
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
            lines.extend([f"### {architecture}", ""])
            metric_rows = []
            architecture_items = sorted(
                (item for item in metric_items if item.get("architecture") == architecture),
                key=_result_key,
            )
            for item in architecture_items:
                metric_names = _metric_names(item, comparison_orders)
                sysbench_groups, other_names = _sysbench_metric_groups(
                    item["metrics"], metric_names
                )
                if sysbench_groups:
                    lines.extend([f"#### {item.get('software')} {item.get('version')}", ""])
                    lines.extend(_sysbench_single_tables(sysbench_groups, heading_level=5))
                for name in other_names:
                    metric = item["metrics"][name]
                    metric_rows.append([
                        item.get("software"),
                        item.get("version"),
                        name,
                        metric.get("value"),
                        metric.get("unit", ""),
                        direction_label(metric.get("direction")),
                    ])
            if metric_rows:
                lines.extend(
                    _fixed_width_table(
                        ("软件", "版本", "指标", "数值", "单位", "优化方向"),
                        metric_rows,
                        SINGLE_METRIC_COLUMN_WIDTHS,
                    )
                )
    if comparisons:
        lines.extend(["## 跨架构指标", ""])
        comparison_rows: list[list[object]] = []
        for comparison in comparisons:
            metrics = comparison.get("metrics", {})
            sysbench_groups, other_names = _sysbench_metric_groups(metrics, list(metrics))
            if sysbench_groups:
                lines.extend([f"### {comparison.get('software')} {comparison.get('version')}", ""])
                lines.extend(_sysbench_comparison_tables(sysbench_groups, heading_level=4))
            for name in other_names:
                metric = metrics[name]
                relative = metric.get("relative_performance")
                comparison_rows.append([
                    comparison.get("software"),
                    comparison.get("version"),
                    name,
                    direction_label(metric.get("direction")),
                    metric.get("x86_64"),
                    metric.get("aarch64"),
                    relative if relative is not None else "N/A",
                ])
        if comparison_rows:
            lines.extend(
                _fixed_width_table(
                    ("软件", "版本", "指标", "优化方向", "x86_64", "aarch64", "aarch64 相对性能"),
                    comparison_rows,
                    CROSS_METRIC_COLUMN_WIDTHS,
                )
            )
        if comparison_rows or any(
            _sysbench_metric_groups(comparison.get("metrics", {}), list(comparison.get("metrics", {})))[0]
            for comparison in comparisons
        ):
            lines.extend([
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
