#!/usr/bin/env python3
"""Collect and report one independently run Flink/Nexmark benchmark."""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


QUERIES = tuple(f"q{i}" for i in range(24) if i != 6)


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def command(args: list[str]) -> str:
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=10, check=False)
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def load_json(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return value if isinstance(value, dict) else {}


def system_info() -> dict:
    release = platform.platform()
    try:
        for line in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():
            if line.startswith("PRETTY_NAME="):
                release = line.partition("=")[2].strip('"')
                break
    except OSError:
        pass
    return {
        "collected_at": timestamp(), "architecture": platform.machine(),
        "platform": release, "kernel": platform.release(),
        "cpu_count": os.cpu_count() or 0,
        "cpu_model": command(["lscpu"]).split("Model name:")[-1].splitlines()[0].strip(),
        "numa": command(["numactl", "--hardware"]),
    }


def runtime_info() -> dict:
    return {"collected_at": timestamp(), "memory": command(["free", "-b"])}


def build_info(version: str, actual_file: Path, architecture: str, run_id: str) -> dict:
    actual = actual_file.read_text(encoding="utf-8").strip()
    if actual != version:
        raise RuntimeError(f"actual Flink version {actual!r} differs from requested {version!r}")
    return {
        "recorded_at": timestamp(), "category": "Bigdata", "software": "flink",
        "requested_version": version, "actual_version": actual,
        "architecture": architecture, "run_id": run_id,
    }


def validate_metrics(benchmark: dict) -> dict:
    results = benchmark.get("results")
    rows = benchmark.get("measurements")
    expected = {f"{query}/{kind}" for query in QUERIES for kind in ("throughput", "time")}
    if not isinstance(results, dict) or set(results) != expected:
        raise RuntimeError("benchmark_flink.json must contain all 46 Nexmark query metrics")
    if not isinstance(rows, list) or len(rows) != len(QUERIES) or \
            {row.get("query") for row in rows if isinstance(row, dict)} != set(QUERIES):
        raise RuntimeError("benchmark_flink.json must contain 23 distinct official query rows")
    for name, metric in results.items():
        if not isinstance(metric, dict):
            raise RuntimeError(f"invalid Nexmark metric: {name}")
        value = metric.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)) or \
                not math.isfinite(value) or value <= 0:
            raise RuntimeError(f"missing or non-positive Nexmark metric: {name}")
        if metric.get("unit") != ("events/s" if name.endswith("/throughput") else "s"):
            raise RuntimeError(f"unexpected unit for {name}")
    return results


def markdown_cell(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def render_report(result: dict) -> str:
    lines = [
        f"# Flink {result['version']} 独立性能测试报告", "",
        f"- Run ID：`{result['run_id']}`", f"- 架构：`{result['architecture']}`",
        f"- 状态：`{result['status']}`", f"- 清理状态：`{result['cleanup_status']}`", "",
        "## 构建信息", "", "| 项目 | 值 |", "|---|---|",
        f"| 请求版本 | {result['version']} |",
        f"| 实际版本 | {result['build_info'].get('actual_version', 'N/A')} |",
        f"| 构建变体 | {result['build_variant'].get('variant', 'N/A')} |", "",
        "## 系统信息", "", "| 项目 | 值 |", "|---|---|",
    ]
    for key, label in (("platform", "操作系统"), ("architecture", "系统架构"),
                       ("cpu_model", "CPU 型号"), ("cpu_count", "CPU 核数"),
                       ("kernel", "内核")):
        lines.append(f"| {label} | {markdown_cell(result['system_info'].get(key, 'N/A'))} |")
    lines += ["", "## 正式 Nexmark 指标", ""]
    for query in QUERIES:
        lines += [f"### {query}", "", "| 指标 | 数值 | 单位 | 优化方向 |", "|---|---:|---|---|"]
        for name, label, direction in (("throughput", "Throughput", "越大越好"),
                                       ("time", "Time(s)", "越小越好")):
            metric = result["metrics"].get(f"{query}/{name}")
            if metric:
                lines.append(f"| {label} | {metric['value']} | {metric['unit']} | {direction} |")
        lines.append("")
    if result.get("error"):
        lines += ["## 错误", "", result["error"].replace("|", "\\|"), ""]
    return "\n".join(lines)


def finalize(args: argparse.Namespace) -> int:
    output = args.output_dir
    benchmark = load_json(output / "benchmark_flink.json")
    variant = load_json(output / "build_variant.json")
    error = None
    metrics = {}
    if args.command_status == "passed":
        try:
            if variant.get("variant") != "base":
                raise RuntimeError("build_variant.json must identify the completed base build")
            metrics = validate_metrics(benchmark)
        except RuntimeError as exc:
            error = str(exc)
    status = "passed" if args.command_status == args.cleanup_status == "passed" and not error else "failed"
    failed_stage = args.failed_stage or ("test" if error else None)
    result = {
        "category": "Bigdata", "software": "flink", "version": args.version,
        "architecture": args.architecture, "run_id": args.run_id, "status": status,
        "cleanup_status": args.cleanup_status, "failed_stage": failed_stage,
        "build_info": load_json(output / "build_info.json"), "build_variant": variant,
        "system_info": load_json(output / "system_info.json"),
        "runtime_before": load_json(output / "runtime_before.json"),
        "runtime_after": load_json(output / "runtime_after.json"),
        "parameters": benchmark.get("parameters", {}), "metrics": metrics, "error": error,
    }
    write_json(output / "results.json", result)
    write_json(output / "status.json", {key: result[key] for key in (
        "category", "software", "version", "architecture", "run_id", "status",
        "cleanup_status", "failed_stage", "error")})
    (output / "report.md").write_text(render_report(result), encoding="utf-8")
    return 60 if error else 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("system", "runtime"):
        sub.add_parser(name).add_argument("output", type=Path)
    build = sub.add_parser("build-info")
    build.add_argument("output", type=Path)
    build.add_argument("version")
    build.add_argument("actual_version_file", type=Path)
    build.add_argument("architecture")
    build.add_argument("run_id")
    finish = sub.add_parser("finalize")
    finish.add_argument("output_dir", type=Path)
    for name in ("version", "architecture", "run_id"):
        finish.add_argument(name)
    finish.add_argument("command_status", choices=("passed", "failed"))
    finish.add_argument("cleanup_status", choices=("passed", "failed"))
    finish.add_argument("failed_stage", nargs="?", default="")
    args = parser.parse_args()
    try:
        if args.command == "system":
            write_json(args.output, system_info())
        elif args.command == "runtime":
            write_json(args.output, runtime_info())
        elif args.command == "build-info":
            write_json(args.output, build_info(args.version, args.actual_version_file,
                                               args.architecture, args.run_id))
        else:
            return finalize(args)
    except (OSError, RuntimeError) as exc:
        print(f"[flink] ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
