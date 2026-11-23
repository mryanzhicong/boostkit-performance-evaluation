#!/usr/bin/env python3
"""只读检查容器化软件用例的目录、清单、阶段接线与 Shell 语法。

此脚本不能证明 Docker 生命周期或正式性能测试成功；还需按 Skill 验证清单运行。
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError as exc:
    raise SystemExit("缺少 PyYAML；请安装仓库的 Framework 依赖") from exc


def inspect(case_file: Path) -> list[str]:
    errors: list[str] = []
    case_file = case_file.resolve()
    if not case_file.is_file():
        return [f"用例文件不存在：{case_file}"]
    case_dir = case_file.parent
    repo_root = case_dir.parents[2]
    expected_parent = repo_root / "software"
    if case_dir.parent.parent != expected_parent:
        errors.append(f"用例应位于 {expected_parent}/<分类>/<软件>/")

    try:
        case = yaml.safe_load(case_file.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as exc:
        return [f"无法读取 case YAML：{exc}"]
    if not isinstance(case, dict):
        return ["case YAML 顶层必须是对象"]
    if case.get("name") != case_dir.name:
        errors.append("case.name 与软件目录名不一致")
    if case.get("category") != case_dir.parent.name:
        errors.append("case.category 与分类目录名不一致")
    if not isinstance(case.get("versions"), list) or not case["versions"]:
        errors.append("versions 必须是非空列表")
    if not isinstance(case.get("test_tools"), dict) or not case["test_tools"]:
        errors.append("test_tools 必须声明实际测试工具")

    categories_path = repo_root / "config/categories.yaml"
    if categories_path.is_file():
        categories = yaml.safe_load(categories_path.read_text(encoding="utf-8")) or {}
        registered = (categories.get("categories") or {}).get(case.get("category")) or []
        if case.get("name") not in registered:
            errors.append("软件未注册到 config/categories.yaml")

    for relative in (
        "README.md", f"{case_dir.name}_test.sh", "scripts/common.sh",
        "scripts/builders/base.sh", "scripts/builders/dispatch.sh",
        "scripts/builders/optimized.sh", "scripts/stages/start.sh",
        "scripts/stages/test.sh", "scripts/stages/stop.sh",
    ):
        if not (case_dir / relative).is_file():
            errors.append(f"缺少必需文件：{relative}")

    execution = case.get("execution") or {}
    if not isinstance(execution, dict):
        errors.append("execution 必须是映射")
        execution = {}
    if execution.get("type") != "shell-functions":
        errors.append("execution.type 必须是 shell-functions")
    stages = execution.get("stages") or {}
    if not isinstance(stages, dict):
        errors.append("execution.stages 必须是映射")
        stages = {}
    for stage in ("build", "start", "test", "stop"):
        entry = stages.get(stage) or {}
        if not isinstance(entry, dict):
            errors.append(f"{stage} 阶段必须是映射")
            continue
        script_name, function = entry.get("script"), entry.get("function")
        if not isinstance(script_name, str) or not isinstance(function, str):
            errors.append(f"{stage} 必须声明 script 和 function")
            continue
        script = (case_dir / script_name).resolve()
        if not script.is_relative_to(case_dir) or not script.is_file():
            errors.append(f"{stage} 脚本不存在或越过用例目录：{script_name}")
            continue
        body = script.read_text(encoding="utf-8")
        if not re.search(rf"(?m)^\s*(?:function\s+)?{re.escape(function)}\s*\(\s*\)", body):
            errors.append(f"{stage} 函数 {function} 未在 {script_name} 中定义")
        if stage in {"start", "test"} and re.search(r"(?m)^\s*docker\s+(?:run|load)\b", body):
            errors.append(f"{stage} 直接创建或加载 Docker 状态；应复用 build 阶段容器")
    build_entry = stages.get("build")
    if not isinstance(build_entry, dict) or build_entry.get("script") != "scripts/builders/dispatch.sh":
        errors.append("build 必须指向 scripts/builders/dispatch.sh")

    outputs = case.get("outputs") or {}
    if not isinstance(outputs, dict) or not outputs:
        errors.append("outputs 必须是非空映射")
        outputs = {}
    for name, spec in outputs.items():
        if not isinstance(spec, dict):
            errors.append(f"输出 {name} 必须是映射")
            continue
        output_path = spec.get("path")
        if not isinstance(output_path, str) or not output_path or Path(output_path).is_absolute() or ".." in Path(output_path).parts:
            errors.append(f"输出 {name} 的路径必须安全地相对 RESULTS_DIR")
        if spec.get("stage") not in {"build", "start", "test", "stop"}:
            errors.append(f"输出 {name} 的 stage 无效")
    metrics = case.get("metrics") or {}
    if not isinstance(metrics, dict):
        errors.append("metrics 必须是映射")
        metrics = {}
    metric_source = metrics.get("source")
    metric_output = outputs.get(metric_source) if isinstance(metric_source, str) else None
    if not isinstance(metric_output, dict) or metric_output.get("format") != "json":
        errors.append("metrics.source 必须指向 JSON 输出")
    if not ("definitions" in metrics or "collection" in metrics):
        errors.append("metrics 必须声明 definitions 或 collection")

    for script in sorted(case_dir.rglob("*.sh")):
        checked = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True, check=False)
        if checked.returncode:
            errors.append(f"{script.relative_to(case_dir)} 存在 Shell 语法错误：{checked.stderr.strip()}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", type=Path, help="software/<分类>/<软件>/case.yaml")
    args = parser.parse_args()
    errors = inspect(args.case)
    if errors:
        for error in errors:
            print(f"[适配检查] 错误：{error}", file=sys.stderr)
        return 1
    print(f"[适配检查] 静态接线通过：{args.case}")
    print("[适配检查] 容器内构建、正式测试、清理和指标仍需运行时验证")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
