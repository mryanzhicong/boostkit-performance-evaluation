#!/usr/bin/env python3
"""Collect and report one independently run rustc-perf benchmark."""

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
    }


def runtime_info() -> dict:
    return {"collected_at": timestamp(), "memory": command(["free", "-b"])}


def build_info(version: str, actual_file: Path, architecture: str, run_id: str) -> dict:
    actual = actual_file.read_text(encoding="utf-8").strip()
    if actual != version:
        raise RuntimeError(f"actual Rust version {actual!r} differs from requested {version!r}")
    return {
        "recorded_at": timestamp(), "category": "Toolchain", "software": "rust",
        "requested_version": version, "actual_version": actual,
        "architecture": architecture, "run_id": run_id,
    }


def validate_metrics(benchmark: dict) -> dict:
    results = benchmark.get("results")
    expected = benchmark.get("expected")
    if not isinstance(results, dict) or not results:
        raise RuntimeError("benchmark_rust.json must contain parsed metrics")
    if not isinstance(expected, dict):
        raise RuntimeError("benchmark_rust.json must contain its expected series counts")
    compile_benchmarks = expected.get("compile_benchmarks")
    compile_series = expected.get("compile_series")
    runtime_benchmarks = expected.get("runtime_benchmarks")
    for name, value in (
        ("compile_benchmarks", compile_benchmarks),
        ("compile_series", compile_series),
        ("runtime_benchmarks", runtime_benchmarks),
    ):
        if not isinstance(value, int) or value <= 0:
            raise RuntimeError(f"invalid expected {name} count")
    runtime_instructions = benchmark.get("runtime_context", {}).get(
        "runtime_instructions_recorded"
    )
    expected_total = compile_series + runtime_benchmarks * (2 if runtime_instructions else 1)
    if len(results) != expected_total:
        raise RuntimeError(
            f"expected {expected_total} metrics, benchmark_rust.json contains {len(results)}"
        )
    for name, metric in results.items():
        if not isinstance(metric, dict):
            raise RuntimeError(f"invalid rustc-perf metric: {name}")
        value = metric.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)) or \
                not math.isfinite(value) or value <= 0:
            raise RuntimeError(f"missing or non-positive rustc-perf metric: {name}")
        if metric.get("direction") != "lower_is_better":
            raise RuntimeError(f"unexpected direction for {name}")
        if not isinstance(metric.get("unit"), str) or not metric.get("unit"):
            raise RuntimeError(f"missing unit for {name}")
    groups = {metric.get("group") for metric in results.values()}
    if not groups or groups - {"compile", "runtime"}:
        raise RuntimeError("metrics use unexpected groups")
    return results


def markdown_cell(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def render_compile_tables(results: dict) -> list[str]:
    profiles = ("check", "debug", "opt")
    wall = {}
    instructions = {}
    for name, metric in results.items():
        parts = name.split("/")
        if len(parts) != 5 or parts[0] != "compile":
            continue
        _, crate, profile, threads, label = parts
        if label == "wall-time":
            wall[(crate, profile, threads)] = metric
        else:
            instructions[(crate, profile, threads)] = metric
    crates = sorted({crate for (crate, _p, _t) in wall})
    lines: list[str] = []
    for title, table in (("编译墙钟时间（s，越小越好）", wall),
                         ("编译指令数（instructions，越小越好）", instructions)):
        if not table:
            continue
        lines += [f"### {title}", "",
                  "| 基准 | 前端线程 | Check | Debug | Opt |", "|---|---|---:|---:|---:|"]
        for crate in crates:
            thread_counts = sorted({t for (c, _p, t) in table if c == crate})
            for threads in thread_counts:
                cells = []
                for profile in profiles:
                    metric = table.get((crate, profile, threads))
                    cells.append(
                        f"{metric['value']:.6g}" if metric else "N/A"
                    )
                lines.append(f"| {crate} | {threads} | " + " | ".join(cells) + " |")
        lines.append("")
    return lines


def render_runtime_table(results: dict) -> list[str]:
    rows = []
    for name, metric in sorted(results.items()):
        if not name.startswith("runtime/"):
            continue
        rows.append((name, metric))
    if not rows:
        return []
    lines = ["### 运行时基准（越小越好）", "",
             "| 基准 | 数值 | 单位 |", "|---|---:|---|"]
    for name, metric in rows:
        lines.append(f"| {name} | {metric['value']:.6g} | {metric['unit']} |")
    lines.append("")
    return lines


def render_report(result: dict) -> str:
    lines = [
        f"# Rust {result['version']} 独立性能测试报告", "",
        f"- Run ID：`{result['run_id']}`", f"- 架构：`{result['architecture']}`",
        f"- 状态：`{result['status']}`", f"- 清理状态：`{result['cleanup_status']}`", "",
        "## 构建信息", "", "| 项目 | 值 |", "|---|---|",
        f"| 请求版本 | {result['version']} |",
        f"| 实际版本 | {markdown_cell(result['build_info'].get('actual_version', 'N/A'))} |",
        f"| rustc | {markdown_cell(result['parameters'].get('rustc_version', 'N/A'))} |",
        f"| 构建变体 | {result['build_variant'].get('variant', 'N/A')} |", "",
        "## 系统信息", "", "| 项目 | 值 |", "|---|---|",
    ]
    for key, label in (("platform", "操作系统"), ("architecture", "系统架构"),
                       ("cpu_model", "CPU 型号"), ("cpu_count", "CPU 核数"),
                       ("kernel", "内核")):
        lines.append(f"| {label} | {markdown_cell(result['system_info'].get(key, 'N/A'))} |")
    lines += ["", "## rustc-perf 指标", ""]
    metrics = result["metrics"]
    if metrics:
        lines += render_compile_tables(metrics)
        lines += render_runtime_table(metrics)
    else:
        lines += ["无可用指标。", ""]
    if result.get("error"):
        lines += ["## 错误", "", result["error"].replace("|", "\\|"), ""]
    return "\n".join(lines)


def finalize(args: argparse.Namespace) -> int:
    output = args.output_dir
    benchmark = load_json(output / "benchmark_rust.json")
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
        "category": "Toolchain", "software": "rust", "version": args.version,
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
        print(f"[rust] ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
