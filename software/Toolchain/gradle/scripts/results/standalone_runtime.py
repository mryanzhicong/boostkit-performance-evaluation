#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for Gradle.

The framework drives Gradle through ``framework/run_case.py`` in CI.  This module
provides the same stages for the standalone entry point so that a developer can
run the whole pipeline outside of the framework, with identical evidence files.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "gradle"
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
    gradle_version: str,
    java_version: str,
    jdk_release: str,
    gradle_zip_name: str,
    gradle_zip_sha256: str,
    gradle_zip_url: str,
    jdk_tarball_name: str,
    jdk_tarball_sha256: str,
    jdk_tarball_url: str,
    source_name: str,
    source_url: str,
    source_sha256: str,
    source_revision: str,
) -> None:
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("reported actual Gradle version is empty")
    if actual_version != requested_version:
        raise RuntimeError(
            f"requested Gradle {requested_version} but installed {actual_version}"
        )
    if gradle_version != requested_version:
        raise RuntimeError(
            f"gradle --version reports {gradle_version}, expected {requested_version}"
        )
    if not gradle_zip_sha256 or not source_sha256 or not jdk_tarball_sha256:
        raise RuntimeError("a pinned SHA-256 is empty")
    for label, value in (
        ("gradle distribution", gradle_zip_sha256),
        ("gradle source release", source_sha256),
        ("Temurin JDK", jdk_tarball_sha256),
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
            "gradle_version": gradle_version,
            "java_version": java_version,
            "jdk_release": jdk_release,
            "gradle_distribution": {
                "name": gradle_zip_name,
                "url": gradle_zip_url,
                "sha256": gradle_zip_sha256,
            },
            "jdk_distribution": {
                "name": jdk_tarball_name,
                "url": jdk_tarball_url,
                "sha256": jdk_tarball_sha256,
            },
            "upstream_source": {
                "name": source_name,
                "url": source_url,
                "sha256": source_sha256,
                "revision": source_revision,
            },
            "build_command": (
                "pinned Gradle distribution for the runner architecture; pinned "
                "Temurin JDK 21; deterministic Gradle matrix projects generated "
                "locally; pinned upstream source release extracted and its "
                "multi-module sample projects built with the same distribution"
            ),
        },
    )


def markdown_cell(value: Any) -> str:
    if value is None:
        return "-"
    return str(value).replace("|", "\\|")


def render_report(result: dict[str, Any]) -> str:
    benchmark = result.get("benchmark_result") or {}
    raw_results = benchmark.get("results") or {}
    build = result.get("build_info") or {}
    task_order = {"clean_build": 0, "incremental_build": 1, "noop_build": 2}
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
        cps = raw_results.get(f"{scenario}_cps", {})
        rss = raw_results.get(f"{scenario}_rss", {})
        cps_value = (
            float(cps.get("value", 0.0))
            if isinstance(cps, dict) and cps.get("value") is not None
            else None
        )
        rows.append(
            "| {scenario} | {task} | {scale} | {seconds:.4f} | {cps} | {rss:.1f} | {samples} |".format(
                scenario=markdown_cell(scenario),
                task=markdown_cell(item.get("task")),
                scale=markdown_cell(item.get("scale_items")),
                seconds=float(item.get("value", 0.0)),
                cps=f"{cps_value:.1f}" if cps_value is not None else "-",
                rss=float(rss.get("value", 0.0)) if isinstance(rss, dict) else 0.0,
                samples=len(item.get("samples", [])),
            )
        )
    upstream_name = "upstream_multiproject_build"
    upstream = raw_results.get(upstream_name, {})
    upstream_rss = raw_results.get(f"{upstream_name}_rss", {})
    if isinstance(upstream, dict) and upstream:
        rows.append(
            "| {scenario} | upstream multi-module build | - | {seconds:.1f} | - | {rss:.0f} | {samples} |".format(
                scenario=markdown_cell(upstream.get("scenario", upstream_name)),
                seconds=float(upstream.get("value", 0.0)),
                rss=float(upstream_rss.get("value", 0.0)) if isinstance(upstream_rss, dict) else 0.0,
                samples=len(upstream.get("samples", [])),
            )
        )
    parameters = benchmark.get("parameters", {})
    lines = [
        f"# Gradle {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build.get('actual_version', 'unknown')}`（JDK `{build.get('java_version', 'unknown')}`，Temurin `{build.get('jdk_release', 'unknown')}`）",
        f"- Gradle 发行版：`{build.get('gradle_distribution', {}).get('name', 'unknown')}`，SHA-256 `{build.get('gradle_distribution', {}).get('sha256', 'unknown')}`",
        f"- 上游源码：`{build.get('upstream_source', {}).get('revision', 'unknown')}`，SHA-256 `{build.get('upstream_source', {}).get('sha256', 'unknown')}`",
        f"- 采样：每场景 {parameters.get('repetitions', 0)} 次独立测量取中位数，每场景先预热 1 次",
        f"- 测量阶段网络：`offline`（发行版、JDK、源码与依赖在构建阶段准备完毕）",
        f"- daemon 策略：`{parameters.get('daemon', 'unknown')}`，`max-workers={parameters.get('max_workers', '?')}`，build cache `{parameters.get('build_cache', 'unknown')}`",
        "",
        "## 完整口径矩阵",
        "",
        "| 场景 | 任务 | 类数 | 墙钟中位数 (s) | 吞吐中位数 (classes/s) | 峰值 RSS 中位数 (MiB) | 样本数 |",
        "|---|---|---:|---:|---:|---:|---:|",
    ]
    lines.extend(rows)
    lines.extend(
        [
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64 运行。",
            "- 每个场景是独立进程：`gradle --no-daemon --max-workers=1 --offline --no-build-cache`，墙钟包含 JVM 启动与单次 daemon 进程，符合手册“包含 JVM 启动、不与驻留 daemon 结果混用”的要求。",
            "- `clean_build_*` 每次执行 `clean build`；`incremental_build_*` 先完整构建，再改写一个源文件后执行 `build`；`noop_build_*` 先完整构建，再执行无变更 `build`（所有任务 up-to-date）。",
            "- 上游负载为 Gradle 官方源码归档 tag `v9.8.2` 中的两个多模块示例工程（`library` + 注解生成器 `processor` + 使用注解的 `user`），每次重复前删除各工程的 `build/` 与工程级 `.gradle/` 缓存后再执行全量 `build`。",
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
    status_path = output_dir / "status.json"
    if status_path.is_file():
        status = json.loads(status_path.read_text(encoding="utf-8"))
    else:
        status = {
            "software": SOFTWARE,
            "version": version,
            "architecture": architecture,
            "run_id": run_id,
            "status": command_status,
            "stage": "complete" if command_status == "passed" else "failed",
            "exit_code": stage_exit_code,
            "cleanup_status": cleanup_status,
        }
        if failed_stage:
            status["failed_stage"] = failed_stage
        atomic_write_json(status_path, status)
    if command_status == "passed" and status.get("status") != "passed":
        command_status = status.get("status", command_status)
    results_path = output_dir / "results.json"
    benchmark: dict[str, Any] = {}
    if command_status == "passed" and results_path.is_file():
        benchmark = json.loads(results_path.read_text(encoding="utf-8"))
    build_info_path = output_dir / "build_info.json"
    build_info = (
        json.loads(build_info_path.read_text(encoding="utf-8"))
        if build_info_path.is_file()
        else {}
    )
    result = {
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "variant": os.environ.get("PERF_VARIANT", "base"),
        "status": command_status,
        "stage_exit_code": stage_exit_code,
        "failed_stage": failed_stage,
        "cleanup_status": cleanup_status,
        "build_info": build_info,
        "benchmark_result": benchmark,
    }
    normalized = output_dir / "normalized_result.json"
    payload = {
        "software": SOFTWARE,
        "version": version,
        "architecture": architecture,
        "generated_at": timestamp(),
        "status": command_status,
        "sources": {
            "build_info": build_info,
            "benchmark_result": benchmark,
        },
        "metrics": {
            name: {
                "value": item.get("value"),
                "unit": item.get("unit"),
                "direction": item.get("direction"),
                "scenario": item.get("scenario"),
                "task": item.get("task"),
            }
            for name, item in (benchmark.get("results") or {}).items()
            if isinstance(item, dict)
        },
    }
    atomic_write_json(normalized, payload)
    report = render_report(result)
    (output_dir / "report.md").write_text(report, encoding="utf-8")
    print("[gradle-standalone] wrote {}".format(output_dir / "report.md"))
    return stage_exit_code if command_status != "passed" else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    system = subparsers.add_parser("system")
    system.add_argument("output", type=Path)

    runtime = subparsers.add_parser("runtime")
    runtime.add_argument("output", type=Path)

    build_info = subparsers.add_parser("build-info")
    build_info.add_argument("output", type=Path)
    build_info.add_argument("requested_version")
    build_info.add_argument("actual_version_file", type=Path)
    build_info.add_argument("architecture")
    build_info.add_argument("run_id")
    build_info.add_argument("gradle_version")
    build_info.add_argument("java_version")
    build_info.add_argument("jdk_release")
    build_info.add_argument("--gradle-zip-name", default="")
    build_info.add_argument("--gradle-zip-sha256", default="")
    build_info.add_argument("--gradle-zip-url", default="")
    build_info.add_argument("--jdk-tarball-name", default="")
    build_info.add_argument("--jdk-tarball-sha256", default="")
    build_info.add_argument("--jdk-tarball-url", default="")
    build_info.add_argument("--source-name", default="")
    build_info.add_argument("--source-url", default="")
    build_info.add_argument("--source-sha256", default="")
    build_info.add_argument("--source-revision", default="")

    finalize_parser = subparsers.add_parser("finalize")
    finalize_parser.add_argument("output_dir", type=Path)
    finalize_parser.add_argument("version")
    finalize_parser.add_argument("architecture")
    finalize_parser.add_argument("run_id")
    finalize_parser.add_argument("command_status", choices=["passed", "failed"])
    finalize_parser.add_argument("cleanup_status", choices=["passed", "failed", "pending"])
    finalize_parser.add_argument("stage_exit_code", type=int)
    finalize_parser.add_argument("failed_stage", nargs="?", default="")
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
            args.gradle_version,
            args.java_version,
            args.jdk_release,
            args.gradle_zip_name,
            args.gradle_zip_sha256,
            args.gradle_zip_url,
            args.jdk_tarball_name,
            args.jdk_tarball_sha256,
            args.jdk_tarball_url,
            args.source_name,
            args.source_url,
            args.source_sha256,
            args.source_revision,
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
