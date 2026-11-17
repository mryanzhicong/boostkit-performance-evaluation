"""Generic per-item cross-architecture comparison and aggregation.

A case may publish ``items.jsonl`` next to its ``normalized_result.json``.
Each line is one raw measurement with a stable ``key``, ``value``, ``unit``,
``direction`` and optional ``group``/``implementation`` fields.  The full item
table stays in the artifact; only a compact summary and a bounded sample are
embedded in the consolidated comparison report.
"""

from __future__ import annotations

import json
import math
import statistics
from collections import defaultdict
from pathlib import Path
from typing import Any

VALID_DIRECTIONS = {"lower_is_better", "higher_is_better", "neutral"}
SAMPLE_LIMIT = 10


def load_items(path: Path) -> list[dict[str, Any]] | None:
    """Load a JSONL item table; return None when the file does not exist."""
    if not path.is_file():
        return None
    items: list[dict[str, Any]] = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            item = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"{path}:{line_number}: invalid JSON: {exc}") from exc
        if not isinstance(item, dict):
            raise ValueError(f"{path}:{line_number}: item must be an object")
        items.append(item)
    return items


def write_items(path: Path, items: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "".join(json.dumps(item, ensure_ascii=False, separators=(",", ":")) + "\n" for item in items),
        encoding="utf-8",
    )


def _number(value: Any) -> float | None:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    number = float(value)
    return number if math.isfinite(number) else None


def _validate_item(item: dict[str, Any], architecture: str) -> tuple[str, float, str, str, str]:
    key = item.get("key")
    value = _number(item.get("value"))
    unit = item.get("unit")
    direction = item.get("direction")
    group = item.get("group", "all")
    if not isinstance(key, str) or not key:
        raise ValueError(f"{architecture} item has an invalid key")
    if value is None:
        raise ValueError(f"{architecture} item {key} has an invalid value")
    if not isinstance(unit, str) or not unit:
        raise ValueError(f"{architecture} item {key} has an invalid unit")
    if direction not in VALID_DIRECTIONS:
        raise ValueError(f"{architecture} item {key} has an invalid direction")
    if not isinstance(group, str) or not group:
        raise ValueError(f"{architecture} item {key} has an invalid group")
    return key, value, unit, direction, group


def _index(items: list[dict[str, Any]], architecture: str) -> dict[str, dict[str, Any]]:
    indexed: dict[str, dict[str, Any]] = {}
    for item in items:
        key, _value, _unit, _direction, _group = _validate_item(item, architecture)
        if key in indexed:
            raise ValueError(f"{architecture} item table contains duplicate key: {key}")
        indexed[key] = item
    return indexed


def _relative(x86_value: float, arm_value: float, direction: str) -> float | None:
    if direction == "lower_is_better":
        return x86_value / arm_value
    if direction == "higher_is_better":
        return arm_value / x86_value
    return None


def _stats(ratios: list[float]) -> dict[str, Any]:
    if not ratios:
        return {
            "n": 0,
            "arithmetic_mean": None,
            "geometric_mean": None,
            "median": None,
            "min": None,
            "max": None,
            "arm_faster": 0,
            "x86_faster": 0,
        }
    return {
        "n": len(ratios),
        "arithmetic_mean": statistics.mean(ratios),
        "geometric_mean": math.exp(sum(math.log(value) for value in ratios) / len(ratios)),
        "median": statistics.median(ratios),
        "min": min(ratios),
        "max": max(ratios),
        "arm_faster": sum(1 for value in ratios if value > 1),
        "x86_faster": sum(1 for value in ratios if value < 1),
    }


def compare_items(
    x86_items: list[dict[str, Any]], arm_items: list[dict[str, Any]]
) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    """Compare two item tables by stable key.

    Returns ``(summary, records)``.  ``summary`` is small enough for the
    comparison JSON/report; ``records`` is the full per-item table that should
    be written to a separate JSONL artifact.
    """
    x86_index = _index(x86_items, "x86_64")
    arm_index = _index(arm_items, "aarch64")
    keys = set(x86_index) | set(arm_index)
    records: list[dict[str, Any]] = []
    group_values: dict[str, list[float]] = defaultdict(list)
    missing_x86 = 0
    missing_aarch64 = 0
    invalid = 0
    metadata_mismatch = 0
    neutral = 0
    paired = 0
    units: set[str] = set()
    directions: set[str] = set()

    for key in sorted(keys):
        x86_item = x86_index.get(key)
        arm_item = arm_index.get(key)
        if x86_item is None:
            missing_x86 += 1
            continue
        if arm_item is None:
            missing_aarch64 += 1
            continue
        paired += 1
        x86_key, x86_value, x86_unit, x86_direction, x86_group = _validate_item(x86_item, "x86_64")
        arm_key, arm_value, arm_unit, arm_direction, arm_group = _validate_item(arm_item, "aarch64")
        assert x86_key == arm_key == key
        if (x86_unit, x86_direction, x86_group) != (arm_unit, arm_direction, arm_group):
            metadata_mismatch += 1
            continue
        if x86_direction == "neutral":
            neutral += 1
            continue
        if x86_value <= 0 or arm_value <= 0:
            invalid += 1
            continue
        relative = _relative(x86_value, arm_value, x86_direction)
        if relative is None or not math.isfinite(relative):
            invalid += 1
            continue
        record = {
            "key": key,
            "group": x86_group,
            "unit": x86_unit,
            "direction": x86_direction,
            "x86_64": x86_value,
            "aarch64": arm_value,
            "relative_performance": relative,
            "x86_implementation": x86_item.get("implementation"),
            "aarch64_implementation": arm_item.get("implementation"),
        }
        records.append(record)
        group_values[x86_group].append(relative)
        units.add(x86_unit)
        directions.add(x86_direction)

    overall = _stats([record["relative_performance"] for record in records])
    summary = {
        "unit": next(iter(units)) if len(units) == 1 else None,
        "direction": next(iter(directions)) if len(directions) == 1 else None,
        "aggregation": "geometric_mean",
        "paired": paired,
        "compared": len(records),
        "missing_x86": missing_x86,
        "missing_aarch64": missing_aarch64,
        "invalid": invalid,
        "metadata_mismatch": metadata_mismatch,
        "neutral": neutral,
        **overall,
        "groups": {
            group: _stats(values)
            for group, values in sorted(group_values.items())
        },
        "samples": records[:SAMPLE_LIMIT],
    }
    return summary, records
