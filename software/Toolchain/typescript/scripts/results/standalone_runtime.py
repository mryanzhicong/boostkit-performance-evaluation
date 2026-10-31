#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for TypeScript.

The framework drives the case through ``framework/run_case.py`` in CI.  This
module provides the same stages for the standalone entry point so that a
developer can run the whole pipeline outside of the framework with identical
evidence files.
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

SOFTWARE = "typescript"
CATEGORY = "Toolchain"

SCENARIO_ORDER = (
    "check_small",
    "check_medium",
    "check_large",
    "check_upstream",
    "emit_medium",
    "incremental_warm_medium",
    "incremental_change_medium",
    "references_build",
)


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


BUILD_INFO_FIELDS = (
    "recorded_at",
    "category",
    "software",
    "requested_version",
    "actual_version",
    "architecture",
    "run_id",
)


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    node_version: str,
    node_url: str,
    node_sha256: str,
    typescript_url: str,
    typescript_sha256: str,
    typescript_sha512: str,
    native_backend: str,
    native_backend_url: str,
    native_backend_sha256: str,
    native_backend_sha512: str,
    typescript_engines: str,
    registry: str,
) -> None:
    """Write the framework-compatible build information and its provenance.

    build_info.json keeps exactly the seven fields the framework owns, so an
    independent run is indistinguishable from a framework run.  Everything that
    documents *where* the pinned toolchain came from goes to build_provenance.json
    next to it.
    """
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("reported actual TypeScript version is empty")
    if actual_version != requested_version:
        raise RuntimeError(
            f"requested TypeScript {requested_version} but built {actual_version}"
        )
    if not node_version:
        raise RuntimeError("the pinned Node.js runtime version is empty")
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
        },
    )
    atomic_write_json(
        output.parent / "build_provenance.json",
        {
            "recorded_at": timestamp(),
            "node_version": node_version,
            "node_distribution_url": node_url,
            "node_distribution_sha256": node_sha256,
            "typescript_tarball_url": typescript_url,
            "typescript_tarball_sha256": typescript_sha256,
            "typescript_tarball_sha512_integrity": typescript_sha512,
            "native_backend_package": native_backend,
            "native_backend_tarball_url": native_backend_url,
            "native_backend_tarball_sha256": native_backend_sha256,
            "native_backend_tarball_sha512_integrity": native_backend_sha512,
            "typescript_engines_node": typescript_engines,
            "registry": registry,
            "build_command": "official Node.js binary archive + official TypeScript tarballs, no compiler build",
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
    if not metrics:
        raise RuntimeError("results.json contains no metrics")
    return metrics


def markdown_cell(value: Any) -> str:
    if value is None or value == "":
        return "N/A"
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def render_report(result: dict[str, Any]) -> str:
    benchmark = result["sources"]["benchmark_result"]
    items = benchmark.get("results", {})
    parameters = benchmark.get("parameters", {})
    build = result["build_info"]
    provenance = result.get("build_provenance") or {}
    rows = []
    for scenario in SCENARIO_ORDER:
        wall = items.get(scenario, {})
        rss = items.get(f"{scenario}_rss", {})
        if not wall:
            continue
        rows.append(
            "| {scenario} | {project} | {sources} | {wall:.3f} | {rss:.1f} | {reps} |".format(
                scenario=markdown_cell(scenario),
                project=markdown_cell(wall.get("project")),
                sources=markdown_cell(wall.get("source_files")),
                wall=float(wall.get("value", 0.0)),
                rss=float(rss.get("value", 0.0)),
                reps=len(wall.get("samples", [])),
            )
        )
    project_rows = []
    for name, project in sorted(parameters.get("projects", {}).items()):
        project_rows.append(
            "| {name} | {modules} | `{digest}` |".format(
                name=markdown_cell(name),
                modules=markdown_cell(project.get("modules")),
                digest=markdown_cell(str(project.get("digest", ""))[:16] + "…"),
            )
        )
    upstream = parameters.get("upstream_project", {})
    lines = [
        f"# TypeScript {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build.get('actual_version', 'unknown')}`",
        f"- Node.js：`{provenance.get('node_version', 'unknown')}`（TypeScript engines.node `{parameters.get('typescript_engines_node', 'unknown')}`）",
        f"- 原生编译器后端：`{provenance.get('native_backend_package', 'unknown')}`",
        f"- 采样：每场景 {parameters.get('repetitions', 0)} 次独立测量取中位数，预热 {parameters.get('warmups', 0)} 次",
        f"- 测量离线：`{parameters.get('network', 'unknown')}`",
        f"- 上游工程：`{upstream.get('name', 'unknown')}@{upstream.get('version', 'unknown')}`",
        "",
        "## 完整口径矩阵",
        "",
        "| 场景 | 工程 | 源文件数 | 墙钟中位数 (s) | 峰值 RSS 中位数 (MiB) | 样本数 |",
        "|---|---|---:|---:|---:|---:|",
    ]
    lines.extend(rows)
    lines.extend(
        [
            "",
            "## 确定性生成的工程",
            "",
            "| 工程 | 模块数 | 树摘要（前 16 位） |",
            "|---|---:|---|",
        ]
    )
    lines.extend(project_rows)
    lines.extend(
        [
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64 运行。",
            "- 墙钟为本任务启动的单个 tsc 子进程耗时；RSS 为该子进程 `ru_maxrss`；测量统一由 `scripts/run_timed.py` 产生。",
            "- 每个场景在每次测量前都重置工程状态：删除 build info / 输出目录并从模板重建，因此样本之间没有状态污染。",
            "- 所有测量都在关闭网络的包装器下运行（`scripts/common.sh` 写入的 `tsc` wrapper），测量窗口内不访问网络。",
            "- 该架构以外（x86_64）只做功能与链路验证，不作为性能结论。",
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
        "exit_code": 0 if command_status == "passed" else 50,
        "cleanup_status": cleanup_status,
    }
    atomic_write_json(output_dir / "status.json", status)
    benchmark = load_json(output_dir / "results.json")
    build_info = load_json(output_dir / "build_info.json")
    provenance = load_json(output_dir / "build_provenance.json")
    if not build_info:
        build_info = {"actual_version": "unknown"}
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
        "build_provenance": provenance,
        "sources": {"benchmark_result": benchmark},
        "metrics": {},
    }
    report: str
    if command_status == "passed":
        try:
            result["metrics"] = extract_metrics(benchmark, version, architecture)
        except (RuntimeError, TypeError) as exc:
            print(f"[typescript-standalone] ERROR: {exc}", flush=True)
            status["status"] = "failed"
            status["stage"] = "finalize"
            status["failed_stage"] = "finalize"
            atomic_write_json(output_dir / "status.json", status)
            return 60
        try:
            report = render_report(result)
        except (KeyError, TypeError, ValueError) as exc:
            print(f"[typescript-standalone] ERROR: report rendering failed: {exc}", flush=True)
            return 60
    else:
        report = (
            f"# TypeScript {version} 独立性能测试报告\n\n"
            f"- Run ID：`{run_id}`\n"
            f"- 架构：`{architecture}`\n"
            f"- 状态：`failed`（失败阶段：`{failed_stage or 'unknown'}`）\n\n"
            "测试未通过，未生成指标；原始输出保留在结果目录。\n"
        )
    (output_dir / "normalized_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "report.md").write_text(report, encoding="utf-8")
    print(f"[typescript-standalone] wrote {output_dir}/report.md", flush=True)
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
    build.add_argument("--node-url", required=True)
    build.add_argument("--node-sha256", required=True)
    build.add_argument("--typescript-url", required=True)
    build.add_argument("--typescript-sha256", required=True)
    build.add_argument("--typescript-sha512", required=True)
    build.add_argument("--native-backend", default="")
    build.add_argument("--native-backend-url", default="")
    build.add_argument("--native-backend-sha256", default="")
    build.add_argument("--native-backend-sha512", default="")
    build.add_argument("--typescript-engines", default="")
    build.add_argument("--registry", default="")
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
            args.node_version,
            args.node_url,
            args.node_sha256,
            args.typescript_url,
            args.typescript_sha256,
            args.typescript_sha512,
            args.native_backend,
            args.native_backend_url,
            args.native_backend_sha256,
            args.native_backend_sha512,
            args.typescript_engines,
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
        args.failed_stage or None,
    )


if __name__ == "__main__":
    raise SystemExit(main())
