#!/usr/bin/env python3
"""Self-contained environment capture, build identity and reporting for Eigen.

The framework drives the case through ``framework/run_case.py`` in CI.  This
module provides the same evidence for the standalone entry point
(``eigen_test.sh``), so a developer can run the whole pipeline outside the
framework with identical files: ``system_info.json``, ``runtime_before.json``,
``build_info.json``, ``runtime_after.json``, ``normalized_result.json``,
``report.md`` and ``status.json``.

The measured workload is the unmodified upstream ``bench/bench_gemm.cpp`` of the
pinned Eigen 5.0.1 release (Eigen's dense single-thread float matrix-matrix
product benchmark), run once per pinned ``(m, k, n)`` matrix point.  The only
reported metric is the upstream ``eigen cpu ... GFLOPS`` line, in GFLOP/s; this
module validates that ``results.json`` carries exactly the pinned matrix points
and renders them as a Markdown table.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import re
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "eigen"
CATEGORY = "Acceleration"

# The pinned matrix: one metric per (m, k, n) dense GEMM point.  The parser owns
# the authoritative list; this module only enforces that the standalone report
# covers the same number of points and derives (m, k, n) from the metric name.
MATRIX_POINTS = 44
GFLOP_METRIC = re.compile(r"^gemm_gflops_m(?P<m>[0-9]+)_k(?P<k>[0-9]+)_n(?P<n>[0-9]+)$")
GFLOP_UNIT = "GFLOP/s"
UPSTREAM_ENTRY = (
    "bench/bench_gemm.cpp (upstream Eigen dense single-thread float "
    "matrix-matrix product benchmark)"
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


def record_build_info(
    output: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    compiler: str,
    archive_name: str,
    archive_url: str,
    archive_sha256: str,
) -> None:
    """Record the source and the container toolchain that built this run.

    The case has no cmake step and no per-flag build groups: Eigen is
    header-only, so the pinned archive is extracted inside the private container
    and the upstream GEMM driver is compiled once with the container ``c++``.
    Hence the only build identity recorded here is that compiler plus the
    upstream entry; an unknown compiler is reported as ``unknown`` instead of
    being silently replaced by the host toolchain.
    """
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("reported actual Eigen version is empty")
    if actual_version != requested_version:
        raise RuntimeError(
            f"requested Eigen {requested_version} but the built headers are {actual_version}"
        )
    if not archive_sha256:
        raise RuntimeError("pinned archive SHA-256 is empty")
    identity = compiler.strip() or "unknown"
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
            "cxx_compiler": identity,
            "compiler_source": "container c++ --version (first line), read inside the private container",
            "upstream_entry": UPSTREAM_ENTRY,
            "compile_command": (
                "c++ -std=c++17 -O3 -DNDEBUG -I <extracted source> "
                "<source>/bench/bench_gemm.cpp -o <work>/probe/gemm_bench "
                "(single translation unit, built directly by the container c++ driver)"
            ),
        },
    )


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def metric_matrix(name: str, result: dict[str, Any]) -> tuple[int, int, int]:
    """Return the (m, k, n) triple of a matrix-point metric, validated."""
    match = GFLOP_METRIC.match(name)
    if not match:
        raise RuntimeError(f"unexpected metric name in results.json: {name}")
    expected = (int(match.group("m")), int(match.group("k")), int(match.group("n")))
    matrix = result.get("matrix")
    if not isinstance(matrix, dict):
        raise RuntimeError(f"metric {name} has no matrix dimensions")
    for axis, value in zip(("m", "k", "n"), expected):
        actual = matrix.get(axis)
        if isinstance(actual, bool) or not isinstance(actual, int) or actual != value:
            raise RuntimeError(
                f"metric {name} reports {axis}={actual!r}, expected {value}"
            )
    return expected


def metric_samples(name: str, result: dict[str, Any]) -> list[float]:
    """Return the measured GFLOP/s samples of one matrix point, validated."""
    samples = result.get("samples")
    values = result.get("sample_values")
    if isinstance(samples, bool) or not isinstance(samples, int) or samples < 1:
        raise RuntimeError(f"metric {name} has no usable sample count")
    if not isinstance(values, list) or len(values) != samples:
        raise RuntimeError(
            f"metric {name} declares {samples} samples but carries "
            f"{len(values) if isinstance(values, list) else 'no'} values"
        )
    parsed: list[float] = []
    for value in values:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise TypeError(f"metric {name} has a non-numeric sample")
        number = float(value)
        if not math.isfinite(number) or number <= 0:
            raise RuntimeError(f"metric {name} has a non-positive or non-finite sample")
        parsed.append(number)
    return parsed


def extract_metrics(
    benchmark: dict[str, Any], version: str, architecture: str
) -> dict[str, Any]:
    """Validate ``results.json`` and return the normalized metric set."""
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
        matrix = metric_matrix(name, result)
        value = result.get("value")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise TypeError(f"metric {name} is not numeric")
        if not math.isfinite(float(value)) or value <= 0:
            raise RuntimeError(f"metric {name} must be finite and positive")
        unit = result.get("unit")
        if unit != GFLOP_UNIT:
            raise RuntimeError(f"metric {name} must be reported in {GFLOP_UNIT}, got {unit!r}")
        direction = result.get("direction")
        if direction != "higher_is_better":
            raise RuntimeError(f"metric {name} has an unexpected direction: {direction!r}")
        group = result.get("group")
        if not isinstance(group, str) or not group:
            raise RuntimeError(f"metric {name} has no group")
        source_field = result.get("source_field")
        if not isinstance(source_field, str) or not source_field:
            raise RuntimeError(f"metric {name} has no source_field")
        metric_samples(name, result)
        metrics[name] = {
            "matrix": {"m": matrix[0], "k": matrix[1], "n": matrix[2]},
            "value": value,
            "unit": unit,
            "direction": direction,
            "group": group,
        }
    if len(metrics) != MATRIX_POINTS:
        raise RuntimeError(
            f"results.json has {len(metrics)} matrix points, expected {MATRIX_POINTS}"
        )
    return metrics


def markdown_cell(value: Any) -> str:
    if value is None or value == "":
        return "N/A"
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def matrix_rows(raw_results: dict[str, Any]) -> list[tuple[int, int, int, float, int]]:
    """Return (m, k, n, gflops, samples) per matrix point in results order."""
    rows: list[tuple[int, int, int, float, int]] = []
    for name, result in raw_results.items():
        match = GFLOP_METRIC.match(name)
        if not match:
            continue
        if not isinstance(result, dict):
            raise TypeError(f"metric {name} must be an object")
        m, k, n = metric_matrix(name, result)
        gflops = float(result.get("value", 0.0))
        if not math.isfinite(gflops) or gflops <= 0:
            raise ValueError(f"metric {name} must be finite and positive")
        rows.append((m, k, n, gflops, len(metric_samples(name, result))))
    if len(rows) != MATRIX_POINTS:
        raise ValueError(
            f"results.json has {len(rows)} matrix points, expected {MATRIX_POINTS}"
        )
    return rows


def render_report(result: dict[str, Any]) -> str:
    """Render ``report.md``: one GFLOP/s value per pinned (m, k, n) matrix point."""
    benchmark = result["sources"]["benchmark_result"]
    raw_results = benchmark.get("results", {})
    parameters = benchmark.get("benchmark", {})
    if not isinstance(parameters, dict):
        parameters = {}
    toolchain = benchmark.get("toolchain", {})
    if not isinstance(toolchain, dict):
        toolchain = {}
    rows = matrix_rows(raw_results)
    build = result["build_info"]
    compiler = toolchain.get("compiler") or build.get("cxx_compiler") or "unknown"
    measure_reps = parameters.get("measure_reps", "N/A")
    tries = parameters.get("tries", "N/A")
    repeats = parameters.get("repeats_per_try", "N/A")
    lines = [
        f"# Eigen {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build.get('actual_version', 'unknown')}`",
        f"- C++ 编译器（容器内）：`{markdown_cell(compiler)}`",
        f"- 上游入口：`{markdown_cell(build.get('upstream_entry', UPSTREAM_ENTRY))}`",
        f"- 采样：每个矩阵点 1 次预热 + {measure_reps} 次独立测量，"
        f"每次测量按 `-t {tries} -p {repeats}` 调用上游驱动",
        "- 测量阶段网络：`offline`（本用例不需要网络）",
        "",
        "## 矩阵点与吞吐",
        "",
        f"表中每行是 Eigen 稠密 GEMM 的一个矩阵点（A 为 m×k，B 为 k×n，C 为 m×n），"
        f"GFLOP/s 取上游驱动 `eigen cpu` 输出行的 GFLOPS，"
        f"并把 {measure_reps} 次独立测量取中位数。",
        "",
        "| m | k | n | GFLOP/s |",
        "|---|---|---:|---:|",
    ]
    lines.extend(
        f"| {m} | {k} | {n} | {gflops:.3f} |" for m, k, n, gflops, _ in rows
    )
    lines.extend(
        [
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64（Kunpeng 950，384 vCPU，openEuler 24.03 LTS-SP3）运行，x86_64 只做本地链路自测，两者数值不可横向比较。",
            "- 单线程口径：上游驱动不带 OpenMP 编译开关，按上游默认单线程执行 dense float GEMM；不绑核、不改调度策略、不设置 CPU governor。",
            "- 唯一指标是 GFLOP/s：`eigen cpu` 行来自上游自身计时（`-t` 次尝试 × `-p` 次重复的最优值），墙钟与峰值 RSS 只作为 `runs/` 下的原始证据保留，不进入指标。",
            f"- 严格口径：{MATRIX_POINTS} 个矩阵点每个都必须有 1 次预热与全部正式测量；缺样本、非零退出、超时、NaN/非正值、上游 `Matrix sizes = ...` 行不符都判定失败，不补零、不估算。",
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
            "cxx_compiler": "",
            "upstream_entry": UPSTREAM_ENTRY,
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
            print(f"[eigen-standalone] ERROR: {exc}", flush=True)
            status["status"] = "failed"
            status["stage"] = "finalize"
            status["failed_stage"] = "finalize"
            atomic_write_json(output_dir / "status.json", status)
            return 60
        try:
            report = render_report(result)
        except (KeyError, TypeError, ValueError, RuntimeError) as exc:
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
    build.add_argument(
        "cmake",
        nargs="?",
        default=None,
        help="deprecated and ignored: the case no longer has a cmake step",
    )
    build.add_argument(
        "--native-flag",
        default=None,
        help="deprecated and ignored: the case no longer builds per-flag groups",
    )
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
        # The legacy ``cmake`` positional and ``--native-flag`` are accepted so an
        # older caller still runs, but neither is part of the build identity any
        # more; only the container compiler and the upstream entry are recorded.
        record_build_info(
            args.output,
            args.requested_version,
            args.actual_version_file,
            args.architecture,
            args.run_id,
            args.compiler,
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
