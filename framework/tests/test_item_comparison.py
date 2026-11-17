"""Tests for the generic per-item comparison and aggregation layer."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from generate_comparison import generate
from item_comparison import compare_items, load_items, write_items
from reporting import render_comparison


def item(key: str, value: float, *, direction="lower_is_better", group="memcpy", implementation="memcpy"):
    return {
        "key": key,
        "value": value,
        "unit": "ns",
        "direction": direction,
        "group": group,
        "implementation": implementation,
    }


def test_lower_is_better_ratios_and_geometric_mean() -> None:
    summary, records = compare_items(
        [item("a", 10), item("b", 20)],
        [item("a", 5), item("b", 10)],
    )
    assert summary["paired"] == 2
    assert summary["compared"] == 2
    assert summary["arithmetic_mean"] == pytest.approx(2.0)
    assert summary["geometric_mean"] == pytest.approx(2.0)
    assert summary["arm_faster"] == 2
    assert summary["x86_faster"] == 0
    assert [record["relative_performance"] for record in records] == pytest.approx([2.0, 2.0])
    assert summary["groups"]["memcpy"]["n"] == 2


def test_higher_is_better_uses_arm_over_x86() -> None:
    summary, _records = compare_items(
        [item("a", 10, direction="higher_is_better")],
        [item("a", 20, direction="higher_is_better")],
    )
    assert summary["compared"] == 1
    assert summary["geometric_mean"] == pytest.approx(2.0)
    assert summary["arm_faster"] == 1


def test_missing_invalid_and_metadata_mismatch_are_counted() -> None:
    summary, _records = compare_items(
        [item("a", 10), item("b", 0), item("x", 10, group="memcpy"), item("z", 10)],
        [item("a", 5), item("b", 5), item("y", 5), item("x", 5, group="memcmp")],
    )
    assert summary["paired"] == 3
    assert summary["compared"] == 1
    assert summary["missing_x86"] == 1
    assert summary["missing_aarch64"] == 1
    assert summary["invalid"] == 1
    assert summary["metadata_mismatch"] == 1


def test_load_and_write_items_roundtrip(tmp_path: Path) -> None:
    path = tmp_path / "items.jsonl"
    write_items(path, [item("a", 10), item("b", 20)])
    loaded = load_items(path)
    assert loaded == [item("a", 10), item("b", 20)]
    assert load_items(tmp_path / "missing.jsonl") is None


def test_render_comparison_includes_item_summary() -> None:
    summary, _records = compare_items([item("a", 10)], [item("a", 5)])
    comparison = {
        "software": "glibc",
        "version": "2.44",
        "metrics": {},
        "item_comparison": summary,
        "environments": {},
    }
    report = render_comparison(comparison)
    assert "逐项对比汇总" in report
    assert "几何平均" in report
    assert "memcpy" in report


def test_generate_attaches_item_summary_and_artifact(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    for architecture, value in (("x86_64", 10.0), ("aarch64", 5.0)):
        directory = input_root / architecture
        directory.mkdir(parents=True)
        normalized = {
            "category": "Toolchain",
            "software": "glibc",
            "version": "2.44",
            "architecture": architecture,
            "status": "passed",
            "cleanup_status": "passed",
            "parameters": {},
            "parameter_signature": "signature",
            "test_tools": {},
            "metrics": {
                "memcpy.length=2048": {
                    "value": value,
                    "unit": "ns",
                    "direction": "lower_is_better",
                }
            },
        }
        (directory / "normalized_result.json").write_text(json.dumps(normalized), encoding="utf-8")
        write_items(directory / "items.jsonl", [item("a", value)])
    output = tmp_path / "report"
    generate(input_root, output)
    comparison = json.loads((output / "Toolchain-glibc-2.44.json").read_text())
    assert comparison["item_comparison"]["compared"] == 1
    artifact = output / comparison["item_comparison"]["artifact"]
    assert artifact.is_file()
    record = json.loads(artifact.read_text().strip())
    assert record["relative_performance"] == pytest.approx(2.0)
    assert "逐项对比汇总" in (output / "combined-report.md").read_text()
