#!/usr/bin/env python3
"""Static contract tests for the Tongsuo containerised case.

These tests do not need Docker: they pin the container contract (name prefix,
run-id label, host network, runner user, mounts, no CPU/memory quota), the
README contract sections and the case.yaml wiring, so a silent regression in the
generated container block or the documentation is caught by `pytest tests`.
"""
from __future__ import annotations

import re
from pathlib import Path

import yaml

CASE = Path(__file__).resolve().parent.parent
COMMON = (CASE / "scripts" / "common.sh").read_text(encoding="utf-8")
README = (CASE / "README.md").read_text(encoding="utf-8")
CASE_YAML = yaml.safe_load((CASE / "case.yaml").read_text(encoding="utf-8"))


def test_container_block_is_generated_and_present():
    assert "# >>> container-runtime:begin" in COMMON
    assert "# >>> container-runtime:end" in COMMON
    block = COMMON.split("# >>> container-runtime:begin", 1)[1]
    assert "boostkit-tongsuo-" in block
    assert 'boostkit.tongsuo.run-id=${PERF_RUN_ID}' in block
    assert "--network=host" in block
    assert '--user "$(id -u):$(id -g)"' in block
    assert "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" in block
    assert "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" in block


def test_container_block_has_no_cpu_or_memory_quota():
    block = COMMON.split("# >>> container-runtime:begin", 1)[1]
    run_line = [line for line in block.splitlines() if "docker run --detach" in line]
    assert run_line, "docker run line missing"
    joined = " ".join(block.splitlines())
    for flag in ("--cpus ", "--cpuset-cpus", "--cpuset-mems", "--memory"):
        assert flag not in joined, f"unexpected quota flag {flag}"


def test_case_yaml_wiring():
    assert CASE_YAML["name"] == "tongsuo"
    assert CASE_YAML["category"] == "Toolchain"
    assert CASE_YAML["versions"] == ["8.5.0"]
    stages = CASE_YAML["execution"]["stages"]
    assert set(stages) == {"build", "start", "test", "stop"}
    for stage in stages.values():
        assert (CASE / stage["script"]).is_file(), stage
        function = stage["function"]
        sources = "\n".join(
            (CASE / path).read_text(encoding="utf-8")
            for path in ("scripts/builders/dispatch.sh", "scripts/stages/start.sh",
                         "scripts/stages/test.sh", "scripts/stages/stop.sh")
        )
        assert function in sources, f"{function} not defined"
    outputs = CASE_YAML["outputs"]
    assert outputs["benchmark_result"]["path"] == "results.json"
    assert outputs["run_samples"]["path"] == "runs"
    collection = CASE_YAML["metrics"]["collection"]
    assert collection["name_path"] == "source_name"
    assert collection["direction_path"] == "direction"


def test_readme_contract_sections():
    for heading in (
        "# Tongsuo 8.5.0 性能测试",
        "## 软件与测试工具",
        "## Tongsuo 获取、构建与容器启动",
        "## 数据与运行顺序",
        "## 指标与产物",
        "## 独立运行",
        "## 已知限制",
        "## 故障排查",
        "## 许可证",
    ):
        assert heading in README, heading
    assert "不限制 CPU、内存或 NUMA" in README
    assert "docker load" in README
    assert "/home/runner/software/openEuler-24.03-LTS-SP4/" in README
    assert "boostkit.tongsuo.run-id" in README
    assert "boostkit-tongsuo-" in README
    assert "不向宿主机安装任何软件包" in README
    assert "| 指标 | 来源（场景） | 单位 | 方向 |" in README


def test_readme_metric_table_matches_parser():
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "tongsuo_parse_benchmark", CASE / "scripts" / "results" / "parse_benchmark.py"
    )
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    expected = [column["metric"] for spec_item in module.SCENARIOS.values()
                for column in spec_item["columns"]]
    table_metrics = re.findall(r"^\| `([a-z0-9_]+)` \| `[a-z0-9_]+` \|", README, re.M)
    assert sorted(table_metrics) == sorted(expected), (table_metrics, expected)
    assert len(expected) == 19
