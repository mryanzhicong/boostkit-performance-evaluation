#!/usr/bin/env python3
"""Self-contained environment collection and reporting for the fbthrift case.

The framework owns the official report; this helper lets the standalone entry
(`fbthrift_test.sh`) produce results.json, status.json and report.md without
importing the framework package.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "fbthrift"
CATEGORY = "Acceleration"
BENCHMARK_FILENAME = "benchmark_fbthrift.json"
VALID_DIRECTIONS = {"higher_is_better", "lower_is_better", "neutral"}


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def command(args: list[str]) -> str:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def os_pretty_name() -> str:
    try:
        lines = (
            Path("/etc/os-release")
            .read_text(encoding="utf-8", errors="replace")
            .splitlines()
        )
    except OSError:
        return "ERROR"
    for line in lines:
        field, separator, value = line.partition("=")
        if separator and field.strip() == "PRETTY_NAME":
            try:
                parsed = shlex.split(value, posix=True)
            except ValueError:
                return "ERROR"
            return " ".join(parsed) if parsed else "ERROR"
    return "ERROR"


def cpu_model() -> str:
    for line in command(["lscpu"]).splitlines():
        field, separator, value = line.partition(":")
        if separator and field.strip().casefold() == "model name" and value.strip():
            return value.strip()
    return "unknown"


def gcc_version() -> str:
    value = command(["gcc", "-dumpfullversion", "-dumpversion"])
    return value.splitlines()[0] if value else "unknown"


def glibc_version() -> str:
    value = command(["getconf", "GNU_LIBC_VERSION"])
    if value:
        return value.splitlines()[0]
    implementation, version = platform.libc_ver()
    return f"{implementation} {version}" if implementation and version else "unknown"


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "architecture": platform.machine(),
        "platform": os_pretty_name(),
        "kernel": platform.release(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count() or 0,
        "python_version": platform.python_version(),
        "gcc_version": gcc_version(),
        "glibc_version": glibc_version(),
    }


def collect_runtime_state() -> dict[str, Any]:
    governor = command(
        [
            "sh",
            "-c",
            "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null",
        ]
    )
    return {
        "collected_at": timestamp(),
        "memory": command(["free", "-b"]),
        "cpu_governor": governor,
    }


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    compiler_path: str,
    compiler_version: str,
) -> None:
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("actual fbthrift source version is empty")
    atomic_write_json(
        output,
        {
            "recorded_at": timestamp(),
            "category": CATEGORY,
            "software": SOFTWARE,
            "requested_version": requested_version,
            "actual_version": actual_version,
            "architecture": architecture,
            "run_id": run_id,
            "compiler_path": compiler_path,
            "compiler_version": compiler_version,
        },
    )


def extract_metrics(
    benchmark: dict[str, Any], version: str, architecture: str
) -> dict[str, Any]:
    if benchmark.get("software") != SOFTWARE:
        raise RuntimeError(f"{BENCHMARK_FILENAME} has an invalid software identity")
    if benchmark.get("version") != version:
        raise RuntimeError(f"{BENCHMARK_FILENAME} version differs from this run")
    if benchmark.get("architecture") != architecture:
        raise RuntimeError(f"{BENCHMARK_FILENAME} architecture differs from this run")
    results = benchmark.get("results")
    if not isinstance(results, dict) or not results:
        raise RuntimeError(f"{BENCHMARK_FILENAME} is missing results")
    metrics: dict[str, Any] = {}
    for result_key, result in results.items():
        if not isinstance(result, dict):
            raise TypeError(f"benchmark result {result_key} must be an object")
        metric_name = result.get("name")
        if not isinstance(metric_name, str) or not metric_name:
            raise RuntimeError(f"benchmark result {result_key} has no name")
        if metric_name != result_key:
            raise RuntimeError(
                f"benchmark result key {result_key} differs from name {metric_name}"
            )
        if metric_name in metrics:
            raise RuntimeError(f"duplicate benchmark result: {metric_name}")
        value = result.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise TypeError(f"metric {metric_name} is missing or is not numeric")
        if not math.isfinite(float(value)):
            raise RuntimeError(f"metric {metric_name} must be finite")
        unit = result.get("unit")
        direction = result.get("direction")
        if not isinstance(unit, str) or not unit:
            raise RuntimeError(f"metric {metric_name} has no unit")
        if direction not in VALID_DIRECTIONS:
            raise RuntimeError(f"metric {metric_name} has an invalid direction")
        metric = {"value": value, "unit": unit, "direction": direction}
        if isinstance(result.get("group"), str) and result["group"]:
            metric["group"] = result["group"]
        metrics[metric_name] = metric
    if not metrics:
        raise RuntimeError(f"{BENCHMARK_FILENAME} contains no metrics")
    return metrics


def markdown_cell(value: Any) -> str:
    if value is None or value == "":
        return "N/A"
    return str(value).replace("|", "\\|").replace("\r\n", "<br>").replace("\n", "<br>")


def direction_label(direction: str) -> str:
    return {
        "higher_is_better": "越大越好",
        "lower_is_better": "越小越好",
        "neutral": "参考值",
    }[direction]


def format_number(value: Any) -> str:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return markdown_cell(value)
    if float(value).is_integer():
        return f"{int(value)}"
    return f"{float(value):.3f}"


def render_report(result: dict[str, Any]) -> str:
    lines = [
        f"# fbthrift {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 状态：`{result['status']}`",
        f"- 清理状态：`{result['cleanup_status']}`",
        "",
        "## 构建信息",
        "",
        "| 项目 | 值 |",
        "|---|---|",
    ]
    build_info = result.get("build_info", {})
    for label, field in (
        ("请求软件版本", "requested_version"),
        ("实际软件版本", "actual_version"),
        ("构建编译器", "compiler_version"),
        ("记录时间", "recorded_at"),
    ):
        lines.append(f"| {label} | {markdown_cell(build_info.get(field))} |")
    lines.extend(["", "## 系统信息", "", "| 项目 | 值 |", "|---|---|"])
    system_info = result.get("system_info", {})
    for label, field in (
        ("操作系统", "platform"),
        ("系统架构", "architecture"),
        ("CPU 型号", "cpu_model"),
        ("CPU 核数", "cpu_count"),
        ("内核", "kernel"),
        ("GCC 版本", "gcc_version"),
        ("glibc 版本", "glibc_version"),
    ):
        lines.append(f"| {label} | {markdown_cell(system_info.get(field))} |")

    parameters = result.get("parameters", {})
    matrix = parameters.get("matrix") if isinstance(parameters, dict) else None
    lines.extend(
        [
            "",
            "## 测试场景矩阵",
            "",
            f"- 场景数：{parameters.get('scenario_count', 'N/A')}",
            f"- 预热次数/场景：{parameters.get('warmup_runs_per_scenario', 'N/A')}",
            f"- 独立测量次数/场景：{parameters.get('measured_repetitions', 'N/A')}",
            f"- 单次最短测量时间：{parameters.get('benchmark_min_time', 'N/A')}",
            "",
        ]
    )
    if isinstance(matrix, list) and matrix:
        lines.extend(
            [
                "| 场景 | 分组 | ProtocolBench 用例 | 中位耗时 ns/op | 对象/s | 峰值 RSS MiB |",
                "|---|---|---|---:|---:|---:|",
            ]
        )
        for row in matrix:
            if not isinstance(row, dict):
                continue
            lines.append(
                f"| {markdown_cell(row.get('scenario'))} | {markdown_cell(row.get('group'))} | "
                f"{markdown_cell(row.get('benchmark_case'))} | "
                f"{format_number(row.get('ns_per_op'))} | "
                f"{format_number(row.get('objects_per_second'))} | "
                f"{format_number(row.get('peak_rss_mb'))} |"
            )
    lines.extend(
        [
            "",
            f"## 性能指标（共 {len(result.get('metrics', {}))} 个）",
            "",
            "| 指标 | 分组 | 数值 | 单位 | 优化方向 |",
            "|---|---|---:|---|---|",
        ]
    )
    for metric_name, metric in result.get("metrics", {}).items():
        lines.append(
            f"| {markdown_cell(metric_name)} | {markdown_cell(metric.get('group'))} | "
            f"{format_number(metric['value'])} | {metric['unit']} | "
            f"{direction_label(metric['direction'])} |"
        )
    if result.get("error"):
        lines.extend(["", "## 错误", "", markdown_cell(result["error"])])
    lines.append("")
    return "\n".join(lines)


def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    failed_stage: str | None,
) -> int:
    benchmark = load_json(output_dir / BENCHMARK_FILENAME)
    error = ""
    metrics: dict[str, Any] = {}
    if command_status == "passed":
        try:
            if not benchmark:
                raise RuntimeError(f"{BENCHMARK_FILENAME} is missing or invalid")
            metrics = extract_metrics(benchmark, version, architecture)
        except (RuntimeError, TypeError) as exc:
            command_status = "failed"
            failed_stage = failed_stage or "test"
            error = str(exc)
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    result = {
        "software": SOFTWARE,
        "category": CATEGORY,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage,
        "build_info": load_json(output_dir / "build_info.json"),
        "system_info": load_json(output_dir / "system_info.json"),
        "runtime_before": load_json(output_dir / "runtime_before.json"),
        "runtime_after": load_json(output_dir / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}),
        "metrics": metrics,
        "error": error or None,
    }
    atomic_write_json(output_dir / "results.json", result)
    atomic_write_json(
        output_dir / "status.json",
        {
            "software": SOFTWARE,
            "category": CATEGORY,
            "version": version,
            "architecture": architecture,
            "run_id": run_id,
            "status": status,
            "failed_stage": failed_stage,
            "cleanup_status": cleanup_status,
            "error": error or None,
        },
    )
    (output_dir / "report.md").write_text(render_report(result), encoding="utf-8")
    return 60 if error else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    for name in ("system", "runtime"):
        command_parser = subparsers.add_parser(name)
        command_parser.add_argument("output", type=Path)
    build = subparsers.add_parser("build-info")
    build.add_argument("output", type=Path)
    build.add_argument("requested_version")
    build.add_argument("actual_version_file", type=Path)
    build.add_argument("architecture")
    build.add_argument("run_id")
    build.add_argument("compiler_path")
    build.add_argument("compiler_version")
    final = subparsers.add_parser("finalize")
    final.add_argument("output_dir", type=Path)
    final.add_argument("version")
    final.add_argument("architecture")
    final.add_argument("run_id")
    final.add_argument("command_status", choices=("passed", "failed"))
    final.add_argument("cleanup_status", choices=("passed", "failed"))
    final.add_argument("failed_stage", nargs="?", default="")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "system":
        atomic_write_json(args.output, collect_system_info())
        return 0
    if args.command == "runtime":
        atomic_write_json(args.output, collect_runtime_state())
        return 0
    if args.command == "build-info":
        record_build_info(
            args.output,
            args.requested_version,
            args.actual_version_file,
            args.architecture,
            args.run_id,
            args.compiler_path,
            args.compiler_version,
        )
        return 0
    return finalize(
        args.output_dir,
        args.version,
        args.architecture,
        args.run_id,
        args.command_status,
        args.cleanup_status,
        args.failed_stage or None,
    )


if __name__ == "__main__":
    raise SystemExit(main())
