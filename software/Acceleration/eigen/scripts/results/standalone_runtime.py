#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for Eigen.

The framework drives the case through ``framework/run_case.py`` in CI.  This
module provides the same evidence for the standalone entry point
(``eigen_test.sh``), so a developer can run the whole pipeline outside the
framework with identical files: ``system_info.json``, ``runtime_before.json``,
``build_info.json``, ``runtime_after.json``, ``normalized_result.json``,
``report.md`` and ``status.json``.
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

SOFTWARE = "eigen"
CATEGORY = "Acceleration"


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
    compiler: str,
    cmake: str,
    native_flag: str,
    archive_name: str,
    archive_url: str,
    archive_sha256: str,
) -> None:
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("reported actual Eigen version is empty")
    if actual_version != requested_version:
        raise RuntimeError(
            f"requested Eigen {requested_version} but the built headers are {actual_version}"
        )
    if not archive_sha256:
        raise RuntimeError("pinned archive SHA-256 is empty")
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
            "source": {
                "archive_name": archive_name,
                "archive_url": archive_url,
                "archive_sha256": archive_sha256,
                "upstream_project": "https://gitlab.com/libeigen/eigen",
            },
            "cxx_compiler": compiler,
            "cmake": cmake,
            "build_groups": {
                "o3": "-g0 -O3 -DNDEBUG (upstream BTL default, no extra flag)",
                "native": native_flag or "unresolved",
            },
            "upstream_entry": "bench/btl built with -DEIGEN_BUILD_BTL=ON",
            "build_command": (
                "header-only library: the pinned archive is extracted and the upstream "
                "BTL benchmark suite is compiled twice (base -O3 and native instruction "
                "set) with the Runner C++ compiler"
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
    parameters = benchmark.get("parameters", {})
    dimensions = parameters.get("reference_dimensions", [])
    scenario_rows: list[str] = []
    wall_metrics = {
        name: item
        for name, item in raw_results.items()
        if isinstance(item, dict) and item.get("metric") == "wall"
    }
    for scenario in sorted(wall_metrics):
        item = wall_metrics[scenario]
        action = item.get("action", "")
        group = item.get("group", "")
        rss = raw_results.get(f"{scenario}_rss", {})
        gflops_cells = []
        for dimension in dimensions:
            gflops = raw_results.get(f"{scenario}_gflops_{dimension}", {})
            gflops_cells.append(
                f"{float(gflops.get('value', 0.0)):.1f}" if isinstance(gflops, dict) else "N/A"
            )
        scenario_rows.append(
            "| {scenario} | {group} | {action} | {wall:.3f} | {rss:.1f} | {gflops} |".format(
                scenario=markdown_cell(scenario),
                group=markdown_cell(group),
                action=markdown_cell(action),
                wall=float(item.get("value", 0.0)),
                rss=float(rss.get("value", 0.0)) if isinstance(rss, dict) else 0.0,
                gflops=" | ".join(gflops_cells),
            )
        )
    build = result["build_info"]
    dimensions_header = " | ".join(f"GFLOPS@{dimension}" for dimension in dimensions)
    lines = [
        f"# Eigen {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build.get('actual_version', 'unknown')}`",
        f"- C++ 编译器：`{build.get('cxx_compiler', 'unknown')}`",
        f"- 上游入口：`{build.get('upstream_entry', 'unknown')}`",
        f"- 采样：每场景 {parameters.get('repetitions', 0)} 次独立测量取中位数，预热 {parameters.get('warmups', 0)} 次（上游 sweep 与每个固定维度各自预热）",
        f"- 测量阶段网络：`offline`（本用例不需要网络）",
        "",
        "## 完整口径矩阵",
        "",
        f"| 场景 | 编译组 | 运算 | 墙钟中位数 (s) | 峰值 RSS 中位数 (MiB) | {dimensions_header} |",
        "|---|---|---|---:|---:|" + "---:|" * len(dimensions),
    ]
    lines.extend(scenario_rows)
    lines.extend(
        [
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64 运行。",
            "- 每个场景 = 一次未修改的上游 BTL 可执行文件运行（通过上游 `BTL_CONFIG` 只保留一个 action），墙钟为该进程耗时，RSS 为该进程树 `ru_maxrss` 峰值，均由 `scripts/run_timed.py` 统一产生。",
            "- GFLOPS 由固定维度驱动 `scripts/btl_single_point.cpp` 产生：它复用上游 `bench/btl` 的 action 头文件与 `Portable_Perf_Analyzer`，只固定被测维度并输出 BTL 同格式的 MFlops 行，再换算为 GFLOP/s。之所以不能直接用 sweep 的曲线：上游 `Portable_Perf_Analyzer` 在每个 action 中只构造一次，`eval_mflops()` 复用首次（最大维度）的计时结果，sweep 其余维度并非独立测量。",
            "- 每组场景 1 次预热 + N 次独立测量，报中位数并保留全样本与 min/max/mean/stdev；缺样本、非零退出、NaN/零值一律判定失败，不补零不估算。",
            "- x86_64 只做功能与链路验证，不作性能结论。",
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
        build_info = {"actual_version": "unknown", "cxx_compiler": "", "upstream_entry": ""}
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
            print(f"[eigen-standalone] ERROR: {exc}", flush=True)
            status["status"] = "failed"
            status["stage"] = "finalize"
            status["failed_stage"] = "finalize"
            atomic_write_json(output_dir / "status.json", status)
            return 60
        try:
            report = render_report(result)
        except (KeyError, TypeError, ValueError) as exc:
            print(f"[eigen-standalone] ERROR: report rendering failed: {exc}", flush=True)
            return 60
    else:
        report = (
            f"# Eigen {version} 独立性能测试报告\n\n"
            f"- Run ID：`{run_id}`\n"
            f"- 架构：`{architecture}`\n"
            f"- 状态：`failed`（失败阶段：`{failed_stage or 'unknown'}`）\n\n"
            "测试未通过，未生成指标；原始输出保留在结果目录。\n"
        )
    (output_dir / "normalized_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "report.md").write_text(report, encoding="utf-8")
    print(f"[eigen-standalone] wrote {output_dir}/report.md", flush=True)
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
    build.add_argument("compiler")
    build.add_argument("cmake")
    build.add_argument("--native-flag", default="")
    build.add_argument("--archive-name", required=True)
    build.add_argument("--archive-url", required=True)
    build.add_argument("--archive-sha256", required=True)
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
            args.compiler,
            args.cmake,
            args.native_flag,
            args.archive_name,
            args.archive_url,
            args.archive_sha256,
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
