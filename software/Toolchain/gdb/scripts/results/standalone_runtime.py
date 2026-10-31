#!/usr/bin/env python3
"""Stand-alone runtime helpers for the GDB performance case.

The framework owns the GitHub Actions pipeline; this module lets the identical
build/start/test/stop functions run outside the framework (``gdb_test.sh``) and
produce the same result files:

  build_info.json        exactly the seven fields the framework owns
  build_provenance.json  where the pinned GDB release and the build came from
  results.json           the parser output (raw evidence lives in runs/)
  status.json            pass/fail + cleanup status
  normalized_result.json aggregated view used by the Lead's gates
  report.md              Chinese report with the complete workload matrix
"""

from __future__ import annotations

import argparse
import json
import math
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SOFTWARE = "gdb"
CATEGORY = "Toolchain"

SCENARIO_ORDER = (
    "startup_version",
    "symbol_load_1000",
    "symbol_load_50000",
    "breakpoint_set_200",
    "step_500",
    "info_functions_10000",
    "python_eval_5000",
    "backtrace_deep_2000",
    "core_backtrace_2000",
    "upstream_testsuite_python",
)

SCENARIO_DESCRIPTION = {
    "startup_version": ("GDB 启动", "gdb --version"),
    "symbol_load_1000": ("加载 1000 函数符号表（交付代表负载）", "gdb -batch -ex 'info functions fn_00042' -ex quit symbols_1000"),
    "symbol_load_50000": ("加载 50000 函数符号表", "gdb -batch -ex 'info functions fn_49975' -ex quit symbols_50000"),
    "breakpoint_set_200": ("设置 200 个函数断点（不启动 inferior）", "gdb -batch -x breakpoints.cmd symbols_50000"),
    "step_500": ("启动 inferior 后单步 500 次", "gdb -batch -x steps.cmd steps_500"),
    "info_functions_10000": ("全符号遍历 info functions（10000 函数）", "gdb -batch -ex 'info functions' symbols_10000 | wc -l"),
    "python_eval_5000": ("Python 脚本批量查找 5000 个符号", "gdb -batch -x python_eval.py symbols_50000"),
    "backtrace_deep_2000": ("2000 层深栈 bt 回溯", "gdb -batch -ex 'break crash_here' -ex run -ex bt deep_2000 | wc -l"),
    "core_backtrace_2000": ("加载 core 文件并 bt 回溯", "gdb -batch -ex bt deep_2000 deep_2000.core | wc -l"),
    "upstream_testsuite_python": (
        "上游 GDB testsuite 固定子集（正确性 + 计时）",
        'make check-gdb RUNTESTFLAGS="gdb.python/py-symbol.exp gdb.python/py-value.exp gdb.python/py-breakpoint.exp"',
    ),
}


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    os.replace(temporary, path)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def read_first(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()[0].strip()
    except (OSError, IndexError):
        return "unknown"


def collect_system_info() -> dict[str, Any]:
    memory_kib = 0
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemTotal:"):
                memory_kib = int(line.split()[1])
                break
    except (OSError, ValueError):
        pass
    try:
        distro = ""
        for line in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():
            if line.startswith("PRETTY_NAME="):
                distro = line.split("=", 1)[1].strip().strip('"')
                break
    except OSError:
        distro = platform.platform()
    return {
        "collected_at": timestamp(),
        "hostname": platform.node(),
        "machine": platform.machine(),
        "kernel": platform.release(),
        "distribution": distro,
        "cpu_count": os.cpu_count(),
        "memory_total_mib": memory_kib // 1024,
        "python": platform.python_version(),
    }


def collect_runtime_state() -> dict[str, Any]:
    try:
        load = list(os.getloadavg())
    except (OSError, AttributeError):
        load = [0.0, 0.0, 0.0]
    available_mib = 0
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("MemAvailable:"):
                available_mib = int(line.split()[1]) // 1024
                break
    except (OSError, ValueError):
        pass
    return {
        "collected_at": timestamp(),
        "load_average": [round(value, 3) for value in load],
        "memory_available_mib": available_mib,
        "process_count": len(list(Path("/proc").glob("[0-9]*"))),
    }


def record_build_info(
    output_dir: Path,
    requested_version: str,
    actual_version_file: Path,
    architecture: str,
    run_id: str,
    source_sha256: str,
    source_size: str,
    build_seconds: str,
    cc_version: str,
    python_version: str,
    signature_sha256: str,
) -> None:
    """Write the framework build_info.json and the GDB-specific provenance."""
    actual_version = actual_version_file.read_text(encoding="utf-8").strip()
    if not actual_version:
        raise RuntimeError("the reported actual GDB version is empty")
    if actual_version != requested_version:
        raise RuntimeError(f"requested GDB {requested_version} but built {actual_version}")
    if not source_sha256:
        raise RuntimeError("the GDB source archive checksum is empty")
    atomic_write_json(
        output_dir / "build_info.json",
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
    metadata_path = os.environ.get("GDB_FIXTURE_METADATA", "")
    if not metadata_path:
        metadata_path = str(output_dir.parent / "fixtures-metadata.json")
    metadata = load_json(Path(metadata_path))
    build = metadata.get("build", {})
    atomic_write_json(
        output_dir / "build_provenance.json",
        {
            "recorded_at": timestamp(),
            "gdb_version": actual_version,
            "gdb_source_sha256": source_sha256,
            "gdb_source_bytes": int(source_size) if str(source_size).isdigit() else None,
            "gdb_source_signature_sha256": signature_sha256 or None,
            "gdb_source_urls": [
                "https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/",
                "https://mirrors.ustc.edu.cn/gnu/gdb/",
                "https://ftp.gnu.org/gnu/gdb/",
            ],
            "host_cc": cc_version,
            "host_python": python_version,
            "build_seconds": int(build_seconds) if str(build_seconds).isdigit() else None,
            "configure_options": build.get("configure_options", []),
            "makeinfo_skipped": bool(build.get("makeinfo_skipped", True)),
            "build_command": (
                "official GNU GDB release tarball + system GMP/MPFR + Python 3, "
                "out-of-tree configure/make/install into an isolated prefix"
            ),
        },
    )


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
        metrics[name] = {"value": value, "unit": unit, "direction": direction}
        group = result.get("scenario")
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
    evidence = benchmark.get("artifact_evidence", {})
    build_info = result["build_info"]
    provenance = result.get("build_provenance") or {}
    testsuite = parameters.get("testsuite", {})
    expectations = parameters.get("expectations", {})
    rows = []
    for scenario in SCENARIO_ORDER:
        value = items.get(scenario, {})
        rss = items.get(f"{scenario}_rss", {})
        if not value:
            continue
        description = SCENARIO_DESCRIPTION.get(scenario, (scenario, ""))
        evidence_bits = []
        if scenario == "breakpoint_set_200":
            evidence_bits.append(f"断点数 {value.get('breakpoints')}")
        if scenario == "step_500":
            evidence_bits.append(f"单步数 {value.get('steps')}")
        if scenario == "python_eval_5000":
            evidence_bits.append(f"符号查找 {value.get('lookups')}")
        if scenario in ("info_functions_10000", "backtrace_deep_2000", "core_backtrace_2000"):
            evidence_bits.append(f"输出行数 {value.get('backtrace_lines', value.get('symbol_lines'))}")
        if scenario == "core_backtrace_2000":
            evidence_bits.append(f"core {value.get('core_bytes')} B")
        if scenario == "upstream_testsuite_python":
            evidence_bits.append(
                f"PASS {value.get('expected_passes')} / FAIL {value.get('unexpected_failures')}"
            )
        rows.append(
            "| {scenario} | {description} | {value:.4f} | {rss:.2f} | {reps} | {evidence} |".format(
                scenario=markdown_cell(scenario),
                description=markdown_cell(description[0]),
                value=float(value.get("value", 0.0)),
                rss=float(rss.get("value", 0.0)),
                reps=len(value.get("samples", [])),
                evidence=markdown_cell("；".join(str(bit) for bit in evidence_bits)),
            )
        )
    binary_rows = []
    for name, size in sorted(evidence.get("binary_sizes", {}).items()):
        binary_rows.append(f"| `{markdown_cell(name)}` | {size} |")
    lines = [
        f"# GDB {result['version']} 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 变体：`{result['variant']}`",
        f"- 状态：`{result['status']}`",
        f"- 实际版本：`{build_info.get('actual_version', 'unknown')}`",
        f"- GDB 源码：`{provenance.get('gdb_source_urls', [''])[0]}` gdb-{result['version']}.tar.xz，"
        f"SHA-256 `{provenance.get('gdb_source_sha256', 'unknown')}`",
        f"- 源码构建耗时：`{provenance.get('build_seconds', 'unknown')}` s（configure/make/install 全流程，"
        f"`MAKEINFO=true` 跳过文档）",
        f"- 采样：每场景 {parameters.get('repetitions', 0)} 次独立测量取中位数，预热 {parameters.get('warmups', 0)} 次",
        f"- 测量离线：`{parameters.get('offline')}`；GDB 运行时不访问 debuginfod 或任何网络",
        "",
        "## 完整口径矩阵",
        "",
        "| 场景 | 负载 | 中位数 (s) | 峰值 RSS 中位数 (MiB) | 样本数 | 独立证据 |",
        "|---|---|---:|---:|---:|---|",
    ]
    lines.extend(rows)
    lines.extend(
        [
            "",
            "## 确定性负载",
            "",
            "| 编译后的固定程序 / 文件 | 字节数 |",
            "|---|---:|",
        ]
    )
    lines.extend(binary_rows)
    lines.extend(
        [
            "",
            "## 正确性证据",
            "",
            f"- 编译程序函数规模：小 {expectations.get('symbols_small')}、中 {expectations.get('symbols_medium')}、"
            f"大 {expectations.get('symbols_large')}；断点 {expectations.get('breakpoints')}、"
            f"单步 {expectations.get('steps')}、Python 符号查找 {expectations.get('lookups')}、"
            f"深栈 {expectations.get('deep_frames')} 层。",
            f"- 上游测试子集固定为 {', '.join(testsuite.get('tests', []))}；"
            f"每个样本要求 PASS ≥ {testsuite.get('min_expected_passes')} 且 unexpected failures = 0。",
            "- 每个样本的原始输出与 JSON（含退出码、超时标记、墙钟、峰值 RSS、fixture 源文件数）"
            "保存在 `runs/<场景>/rep<i>.{log,json}`，解析器逐项校验后才生成指标。",
            "- 生成的 C 程序、GDB 命令文件与 Python 脚本的 SHA-256 在构建阶段与仓库内 "
            "`fixtures/fixtures.json` 比对，测量开始前再次校验，防止输入被改动。",
            "",
            "## 边界说明",
            "",
            "- 本报告由独立入口生成；正式性能证据来自 GitHub Actions `Blue: Manual performance evaluation` 的 aarch64 运行。",
            "- `breakpoint_set_200` 与 `symbol_load_*` 不启动 inferior：它们测的是符号读取与断点插入开销，"
            "不代表被调试程序的执行速度。",
            "- `step_500` 测的是 inferior 已启动后的单步开销；`backtrace_deep_2000` 与 `core_backtrace_2000` "
            "测的是回溯自身成本，不宣称代表了断点命中时的复杂对象检查。",
            "- 上游 testsuite 子集的计时只覆盖固定的 3 个测试文件，且同时作为正确性门禁，"
            "不代表 GDB 全量测试套件耗时。",
            "- 所有场景都在同一台机器上串行执行；构建阶段（含源码构建）的耗时单独记录，不计入指标。",
            "- 该架构以外的机器只做功能与链路验证，不作为性能结论。",
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
        except (RuntimeError, TypeError) as error:
            print(f"[gdb-standalone] ERROR: {error}", flush=True)
            status["status"] = "failed"
            status["stage"] = "finalize"
            status["failed_stage"] = "finalize"
            atomic_write_json(output_dir / "status.json", status)
            return 60
        try:
            report = render_report(result)
        except (KeyError, TypeError, ValueError) as error:
            print(f"[gdb-standalone] ERROR: report rendering failed: {error}", flush=True)
            return 60
    else:
        report = (
            f"# GDB {version} 独立性能测试报告\n\n"
            f"- Run ID：`{run_id}`\n"
            f"- 架构：`{architecture}`\n"
            f"- 状态：`failed`（失败阶段：`{failed_stage or 'unknown'}`）\n\n"
            "测试未通过，未生成指标；原始输出保留在结果目录。\n"
        )
    (output_dir / "normalized_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "report.md").write_text(report, encoding="utf-8")
    print(f"[gdb-standalone] wrote {output_dir}/report.md", flush=True)
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    for name in ("system", "runtime"):
        subparser = subparsers.add_parser(name)
        subparser.add_argument("output", type=Path)
    build = subparsers.add_parser("build-info")
    build.add_argument("output_dir", type=Path)
    build.add_argument("requested_version")
    build.add_argument("actual_version_file", type=Path)
    build.add_argument("architecture")
    build.add_argument("run_id")
    build.add_argument("source_sha256")
    build.add_argument("source_size")
    build.add_argument("build_seconds")
    build.add_argument("cc_version")
    build.add_argument("python_version")
    build.add_argument("signature_sha256")
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
            args.output_dir,
            args.requested_version,
            args.actual_version_file,
            args.architecture,
            args.run_id,
            args.source_sha256,
            args.source_size,
            args.build_seconds,
            args.cc_version,
            args.python_version,
            args.signature_sha256,
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
