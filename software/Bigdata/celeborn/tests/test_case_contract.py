#!/usr/bin/env python3
"""Contract tests: the case declares what the scripts actually implement."""

from __future__ import annotations

import re
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = CASE_DIR.parents[2]

STAGES = ("build", "start", "test", "stop")


def load_case() -> dict:
    return yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))


def test_case_yaml_declares_the_four_stages() -> None:
    case = load_case()
    assert case["name"] == "celeborn"
    assert case["category"] == "Bigdata"
    assert case["versions"] == ["0.5.3"]
    assert case["execution"]["type"] == "shell-functions"
    assert set(case["execution"]["stages"]) == set(STAGES)


@pytest.mark.parametrize("stage", STAGES)
def test_declared_stage_function_exists(stage: str) -> None:
    definition = load_case()["execution"]["stages"][stage]
    script = CASE_DIR / definition["script"]
    assert script.is_file(), f"missing stage script: {definition['script']}"
    body = script.read_text(encoding="utf-8")
    pattern = re.compile(rf"^{re.escape(definition['function'])}\(\)\s*\{{", re.MULTILINE)
    assert pattern.search(body), (
        f"{definition['function']} must be declared as a Shell function in {definition['script']}"
    )


def test_declared_outputs_are_produced_by_the_scripts() -> None:
    case = load_case()
    produced = "\n".join(
        path.read_text(encoding="utf-8") for path in (CASE_DIR / "scripts").rglob("*.sh")
    )
    for name, definition in case["outputs"].items():
        assert definition["stage"] in STAGES
        assert definition["format"] in {"json", "text"}
        assert Path(definition["path"]).name in produced or name in produced, (
            f"output {name} ({definition['path']}) is not written by any stage script"
        )


def test_metrics_come_from_the_benchmark_result() -> None:
    case = load_case()
    assert case["metrics"]["source"] == "benchmark_result"
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_celeborn.json"
    collection = case["metrics"]["collection"]
    assert collection["path"] == "results"
    assert collection["value_path"] == "value"


def test_optimized_variant_is_declared_unimplemented() -> None:
    body = (CASE_DIR / "scripts" / "builders" / "optimized.sh").read_text(encoding="utf-8")
    assert re.search(r"build_celeborn_optimized\(\)", body)
    assert re.search(r"return 30", body)
    assert "not implemented" in body.lower() or "未实现" in body


def test_readme_sections_follow_the_contract() -> None:
    readme = (CASE_DIR / "README.md").read_text(encoding="utf-8")
    required = [
        "# Celeborn 0.5.3 性能测试",
        "## 软件与测试工具",
        "## Celeborn 获取、构建与容器启动",
        "## 数据与运行顺序",
        "## 指标与产物",
        "## 独立运行",
        "## 已知限制",
    ]
    for heading in required:
        assert heading in readme, f"README is missing the section {heading!r}"


def test_readme_documents_the_container_and_metrics() -> None:
    readme = (CASE_DIR / "README.md").read_text(encoding="utf-8")
    assert "容器不限制 CPU、内存或 NUMA" in readme
    assert "docker run" in readme and "--network=host" in readme
    assert "106 项" in readme
    for metric in (
        "celeborn.tpcds.suite.elapsed",
        "celeborn.tpcds.statement.median.mean",
        "celeborn.tpcds.statements.executed",
        "celeborn.shuffle.bytes.written",
    ):
        assert metric in readme


def test_case_is_registered_in_categories_and_dropdowns() -> None:
    categories = (REPO_ROOT / "config" / "categories.yaml").read_text(encoding="utf-8")
    assert re.search(r"^\s*-\s*celeborn\s*$", categories, re.MULTILINE)
    workflows = REPO_ROOT / ".github" / "workflows"
    for workflow in (
        "development-performance-test.yml",
        "performance-test-blue.yml",
        "performance-test.yml",
        "compare-existing-results.yml",
    ):
        body = (workflows / workflow).read_text(encoding="utf-8")
        assert re.search(r"^\s*-\s*celeborn\s*$", body, re.MULTILINE), f"{workflow} has no celeborn option"


def test_no_removed_scaffolding_is_referenced() -> None:
    for obsolete in (
        "scripts/adapter.sh",
        "scripts/normalize_x86_workload.py",
        "TESTING.md",
        "profile.json",
        "assets.json",
        "reference",
    ):
        assert not (CASE_DIR / obsolete).exists(), f"{obsolete} should not exist in this case"
    forbidden = ["software/Bigdata/spark", "../spark/scripts", "normalize_x86_workload"]
    self_path = Path(__file__).resolve()
    for path in CASE_DIR.rglob("*"):
        if not path.is_file() or path.suffix not in {".sh", ".py", ".md"}:
            continue
        if path.resolve() == self_path:
            continue
        body = path.read_text(encoding="utf-8", errors="ignore")
        for obsolete in forbidden:
            assert obsolete not in body, f"{path.relative_to(CASE_DIR)} still references {obsolete}"
