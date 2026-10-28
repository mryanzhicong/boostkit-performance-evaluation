"""Tests for one-off x265 historical report alignment."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest


SCRIPT = Path(__file__).with_name("recover_x265_subgroups.py")
SPEC = importlib.util.spec_from_file_location("recover_x265_subgroups", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def result(architecture: str, subgroup: str | None) -> dict:
    metric = {
        "group": "单路",
        "value": 23.42 if architecture == "x86_64" else 18.2,
        "unit": "fps",
        "direction": "higher_is_better",
    }
    if subgroup is not None:
        metric["subgroup"] = subgroup
    return {
        "category": "Media",
        "software": "x265",
        "version": "4.2",
        "architecture": architecture,
        "metrics": {"single/Film2012/2000k/total_fps": metric},
    }


def test_fills_only_missing_historical_subgroup():
    x86 = result("x86_64", "Film2012")
    arm = result("aarch64", None)
    assert MODULE.align_subgroups(x86, arm) == 1
    assert arm["metrics"]["single/Film2012/2000k/total_fps"]["subgroup"] == "Film2012"
    assert arm["metrics"]["single/Film2012/2000k/total_fps"]["value"] == 18.2
    assert MODULE.align_subgroups(x86, arm) == 0


def test_rejects_unrelated_or_conflicting_metric():
    x86 = result("x86_64", "Film2012")
    arm = result("aarch64", "other")
    with pytest.raises(ValueError, match="subgroup differs"):
        MODULE.align_subgroups(x86, arm)
    arm = result("aarch64", None)
    arm["metrics"]["single/Film2012/2000k/total_fps"]["value"] = 0
    arm["metrics"]["single/Film2012/2000k/total_fps"]["group"] = "整机"
    with pytest.raises(ValueError, match="group differs"):
        MODULE.align_subgroups(x86, arm)
