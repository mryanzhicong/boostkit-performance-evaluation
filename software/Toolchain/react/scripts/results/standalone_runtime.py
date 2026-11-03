#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for React.

The framework drives React through ``framework/run_case.py`` in CI.  This module
provides the same stages for the standalone entry point so that a developer can
run the whole pipeline outside of the framework, with identical evidence files.
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

SOFTWARE = "react"
CATEGORY = "Toolchain"


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def command_output(args: list[str], timeout: int = 15) -> str:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def os_pretty_name() -> str:
    try:
        lines = Path("/etc/os-release").read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return "unknown"
    for line in lines:
        field, separator, value = line.partition("=")
        if separator and field.strip() == "PRETTY_NAME":
            try:
                parsed = shlex.split(value, posix=True)
            except ValueError:
                return "unknown"
            return " ".join(parsed) if parsed else "unknown"
    return "unknown"


def cpu_model() -> str:
    output = command_output(["lscpu"])
    for line in output.splitlines():
        field, separator, value = line.partition(":")
        if separator and field.strip() == "Model name":
            return value.strip()
    return platform.processor() or "unknown"


def memory_total_mib() -> int:
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemTotal:"):
                return int(line.split()[1]) // 1024
    except (OSError, ValueError, IndexError):
        pass
    return 0


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "os": os_pretty_name(),
        "kernel": platform.release(),
        "machine": platform.machine(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count(),
        "memory_total_mib": memory_total_mib(),
        "python": platform.python_version(),
    }


def collect_runtime_state() -> dict[str, Any]:
    load = os.getloadavg() if hasattr(os, "getloadavg") else (0.0, 0.0, 0.0)
    available_mib = 0
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemAvailable:"):
                available_mib = int(line.split()[1]) // 1024
                break
    except (OSError, ValueError, IndexError):
        pass
    return {
        "collected_at": timestamp(),
        "load_average": [round(value, 3) for value in load],
        "memory_available_mib": available_mib,
        "process_count": len(list(Path("/proc").glob("[0-9]*"))),
    }


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    node_version: str,
    npm_version: str,
    yarn_version: str,
    java_version: str,
    react_dom_version: str,
    scheduler_version: str,
    source_version: str,
    node_archive_name: str,
    node_archive_sha256: str,
    node_archive_url: str,
    react_archive_sha256: str,
    react_dom_archive_sha256: str,
    scheduler_archive_sha256: str,
    source_url: str,
    source_sha256: str,
    registry: str,
) -> None:
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("reported actual React version is empty")
    if actual_version != requested_version:
        raise RuntimeError(f"requested React {requested_version} but installed {actual_version}")
    if react_dom_version != requested_version:
        raise RuntimeError(f"react-dom is {react_dom_version}, expected {requested_version}")
    if not node_archive_sha256 or not source_sha256:
        raise RuntimeError("a pinned SHA-256 is empty")
    for label, value in (
        ("react", react_archive_sha256),
        ("react-dom", react_dom_archive_sha256),
        ("scheduler", scheduler_archive_sha256),
    ):
        if len(value) != 64:
            raise RuntimeError(f"pinned {label} SHA-256 is malformed")
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
            "react_dom_version": react_dom_version,
            "scheduler_version": scheduler_version,
            "upstream_source_version": source_version,
            "node_version": node_version,
            "npm_version": npm_version,
            "yarn_version": yarn_version,
            "java_version": java_version,
            "node_archive": {
                "name": node_archive_name,
                "url": node_archive_url,
                "sha256": node_archive_sha256,
            },
            "npm_packages": {
                "react": {
                    "version": actual_version,
                    "sha256": react_archive_sha256,
                    "registry": registry,
                },
                "react-dom": {
                    "version": react_dom_version,
                    "sha256": react_dom_archive_sha256,
                    "registry": registry,
                },
                "scheduler": {
                    "version": scheduler_version,
                    "sha256": scheduler_archive_sha256,
                    "registry": registry,
                },
            },
            "upstream_source": {
                "url": source_url,
                "sha256": source_sha256,
            },
            "build_command": (
                "pinned Node.js runtime; pinned react/react-dom/scheduler tarballs "
                "installed offline; upstream facebook/react source release installed "
                "with the pinned Yarn; upstream workload builds the release production "
                "bundle set of the SSR entry points with the repository's rollup script"
            ),
        },
    )


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def extract_metrics(
    benchmark: dict[str, Any], version: str, architecture: str
) -> dict[str, Any]:
    if benchmark.get("software") != SOFTWARE:
        raise RuntimeError("results.json has an invalid software identity")
    if benchmark.get("version") != version or benchmark.get("architecture") != architecture:
        raise RuntimeError("results.json identity differs from this run")
    results = benchmark.get("results")
    if not isinstance(results, dict) or not results:
        raise RuntimeError("results.json is missing results")
    metrics: dict[str, Any] = {}
    for key, result in results.items():
        if not isinstance(result, dict):
            raise TypeError(f"metric {key} must be an object")
        name = result.get("source_name")
        if not isinstance(name, str) or not name:
            raise RuntimeError(f"metric {key} has no source_name")
        if name != key:
            raise RuntimeError(f"metric key {key} differs from source_name {name}")
        if name in metrics:
            raise RuntimeError(f"duplicate metric: {name}")
        value = result.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise TypeError(f"metric {name} is not numeric")
        if not math.isfinite(float(value)) or value <= 0:
            raise RuntimeError(f"metric {name} must be finite and positive")
        unit = result.get("unit")
        direction = result.get("direction")
        if not isinstance(unit, str) or not unit:
            raise RuntimeError(f"metric {name} has no unit")
        if direction not in {"higher_is_better", "lower_is_better", "neutral"}:
            raise RuntimeError(f"metric {name} has an invalid direction")
        group = result.get("scenario")
        metrics[name] = {"value": value, "unit": unit, "direction": direction}
        if isinstance(group, str) and group:
            metrics[name]["group"] = group
        subgroup = result.get("task")
        if isinstance(subgroup, str) and subgroup:
            metrics[name]["subgroup"] = subgroup
    if not metrics:
        raise RuntimeError("results.json contains no metrics")
    return metrics


def markdown_cell(value: Any) -> str:
    if value is None or value == "":
        return "N/A"
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def render_report(result: dict[str, Any]) -> str:
    benchmark = result["sources"]["benchmark_result"]
    raw_results = benchmark.get("results", {})
    task_order = {"render_to_string": 0, "static_markup": 1, "stream": 2}
    matrix_metrics = [
        (name, item)
        for name, item in raw_results.items()
        if isinstance(item, dict)
        and item.get("unit") == "s"
        and item.get("task") in task_order
    ]
    matrix_metrics.sort(
        key=lambda pair: (task_order[pair[1].get("task")], pair[1].get("scale_items") or 0)
    )
    rows = []
    for name, item in matrix_metrics:
        scenario = item.get("scenario", name)
        rps = raw_results.get(f"{scenario}_rps", {})
        rss = raw_results.get(f"{scenario}_rss", {})
        rows.append(
            "| {scenario} | {api} | {scale} | {renders} | {seconds:.4f} | {rps:.1f} | {rss:.1f} | {samples} |".format(
                scenario=markdown_cell(scenario),
                api=markdown_cell(item.get("api")),
                scale=markdown_cell(item.get("scale_items")),
                renders=markdown_cell(item.get("renders_per_repetition")),
                seconds=float(item.get("value", 0.0)),
                rps=float(rps.get("value", 0.0)) if isinstance(rps, dict) else 0.0,
                rss=float(rss.get("value", 0.0)) if isinstance(rss, dict) else 0.0,
                samples=len(item.get("samples", [])),
            )
        )
    upstream = raw_results.get("upstream_build", {})
    upstream_rss = raw_results.get("upstream_build_rss", {})
    if isinstance(upstream, dict) and upstream:
        rows.append(
            "| {scenario} | 上游服务端生产 bundle 构建（stable） | - | - | {seconds:.1f} | - | {rss:.0f} | {samples} |".format(
                scenario=markdown_cell(upstream.get("scenario", "upstream_build")),
                seconds=float(upstream.get("value", 0.0)),
                rss=float(upstream_rss.get("value", 0.0)) if isinstance(upstream_rss, dict) else 0.0,
                samples=len(upstream.get("samples", [])),
            )
        )
    parameters = benchmark.get("parameters", {})
    build = result["build_info"]
    lines = [
        f"# React {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build.get('actual_version', 'unknown')}`（react-dom `{build.get('react_dom_version', 'unknown')}`，scheduler `{build.get('scheduler_version', 'unknown')}`）",
        f"- Node.js：`{build.get('node_version', 'unknown')}`，npm `{build.get('npm_version', 'unknown')}`，Yarn `{build.get('yarn_version', 'unknown')}`",
        f"- 上游构建 JRE：`{build.get('java_version', 'unknown')}`",
        f"- 采样：每场景 {parameters.get('repetitions', 0)} 次独立测量取中位数，每轮预热 {parameters.get('warmup_renders', 0)} 次渲染",
        f"- 测量阶段网络：`offline`（依赖与源码在构建阶段准备完毕）",
        f"- 固定渲染次数：100 项 × {parameters.get('renders_per_repetition', {}).get('100', '?')}，1000 项 × {parameters.get('renders_per_repetition', {}).get('1000', '?')}，10000 项 × {parameters.get('renders_per_repetition', {}).get('10000', '?')}",
        "",
        "## 完整口径矩阵",
        "",
        "| 场景 | 服务端 API | 列表项数 | 渲染次数 | 批量墙钟中位数 (s) | 吞吐中位数 (render/s) | 峰值 RSS 中位数 (MiB) | 样本数 |",
        "|---|---|---:|---:|---:|---:|---:|---:|",
    ]
    lines.extend(rows)
    lines.extend(
        [
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64 运行。",
            "- 矩阵场景的计时由 `scripts/bench_ssr.js` 在 Node.js 进程内部用 `process.hrtime.bigint()` 完成，只覆盖固定渲染批次；进程启动与模块加载时间不计入批量指标，但仍计入外部墙钟与峰值 RSS。",
            "- `upstream_build` 场景测量上游 facebook/react 源码树在同版本 Yarn 下执行 rollup release 构建的完整墙钟（每次先清空 `build/`），包含其内置的 closure-compiler（JRE）步骤。",
            "- x86_64 只做功能与链路验证，不作为性能结论。",
            "",
        ]
    )
    return "\n".join(lines)


def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    stage_exit_code: int,
    failed_stage: str | None,
) -> int:
    status = {
        "category": CATEGORY,
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": "passed" if command_status == "passed" else "failed",
        "stage": "complete" if command_status == "passed" else (failed_stage or "test"),
        "failed_stage": None if command_status == "passed" else (failed_stage or "test"),
        "exit_code": 0 if command_status == "passed" else stage_exit_code,
        "cleanup_status": cleanup_status,
    }
    atomic_write_json(output_dir / "status.json", status)
    benchmark = load_json(output_dir / "results.json")
    build_info = load_json(output_dir / "build_info.json")
    if not build_info:
        build_info = {
            "actual_version": "unknown",
            "node_version": "",
            "yarn_version": "",
        }
    result: dict[str, Any] = {
        "software": SOFTWARE,
        "category": CATEGORY,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "variant": (benchmark.get("variant") if benchmark else None) or "base",
        "status": command_status,
        "cleanup_status": cleanup_status,
        "build_info": build_info,
        "sources": {"benchmark_result": benchmark},
        "metrics": {},
    }
    report: str
    if command_status == "passed":
        try:
            result["metrics"] = extract_metrics(benchmark, version, architecture)
        except (RuntimeError, TypeError) as exc:
            print(f"[react-standalone] ERROR: {exc}", flush=True)
            status["status"] = "failed"
            status["stage"] = "finalize"
            status["failed_stage"] = "finalize"
            atomic_write_json(output_dir / "status.json", status)
            return 60
        try:
            report = render_report(result)
        except (KeyError, TypeError, ValueError) as exc:
            print(f"[react-standalone] ERROR: report rendering failed: {exc}", flush=True)
            return 60
    else:
        report = (
            f"# React {version} 独立性能测试报告\n\n"
            f"- Run ID：`{run_id}`\n"
            f"- 架构：`{architecture}`\n"
            f"- 状态：`failed`（失败阶段：`{failed_stage or 'unknown'}`）\n\n"
            "测试未通过，未生成指标；原始输出保留在结果目录。\n"
        )
    (output_dir / "normalized_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "report.md").write_text(report, encoding="utf-8")
    print(f"[react-standalone] wrote {output_dir}/report.md", flush=True)
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    for name in ("system", "runtime"):
        subparser = subparsers.add_parser(name)
        subparser.add_argument("output", type=Path)
    build = subparsers.add_parser("build-info")
    build.add_argument("output", type=Path)
    build.add_argument("requested_version")
    build.add_argument("actual_version_file", type=Path)
    build.add_argument("architecture")
    build.add_argument("run_id")
    build.add_argument("node_version")
    build.add_argument("npm_version")
    build.add_argument("yarn_version")
    build.add_argument("java_version")
    build.add_argument("react_dom_version")
    build.add_argument("scheduler_version")
    build.add_argument("source_version")
    build.add_argument("node_archive_name")
    build.add_argument("node_archive_sha256")
    build.add_argument("node_archive_url")
    build.add_argument("react_archive_sha256")
    build.add_argument("react_dom_archive_sha256")
    build.add_argument("scheduler_archive_sha256")
    build.add_argument("--source-url", required=True)
    build.add_argument("--source-sha256", required=True)
    build.add_argument("--registry", required=True)
    final = subparsers.add_parser("finalize")
    final.add_argument("output_dir", type=Path)
    final.add_argument("version")
    final.add_argument("architecture")
    final.add_argument("run_id")
    final.add_argument("command_status", choices=("passed", "failed"))
    final.add_argument("cleanup_status", choices=("passed", "failed"))
    final.add_argument("stage_exit_code", type=int)
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
            args.node_version,
            args.npm_version,
            args.yarn_version,
            args.java_version,
            args.react_dom_version,
            args.scheduler_version,
            args.source_version,
            args.node_archive_name,
            args.node_archive_sha256,
            args.node_archive_url,
            args.react_archive_sha256,
            args.react_dom_archive_sha256,
            args.scheduler_archive_sha256,
            args.source_url,
            args.source_sha256,
            args.registry,
        )
        return 0
    return finalize(
        args.output_dir,
        args.version,
        args.architecture,
        args.run_id,
        args.command_status,
        args.cleanup_status,
        args.stage_exit_code,
        args.failed_stage or None,
    )


if __name__ == "__main__":
    raise SystemExit(main())
