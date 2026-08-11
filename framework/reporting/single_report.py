#!/usr/bin/env python3
"""Render one normalized result as Markdown."""

from __future__ import annotations

import argparse
from pathlib import Path

import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from json_helper import load_json  # noqa: E402


DIRECTION_LABELS = {
    "higher_is_better": "越大越好",
    "lower_is_better": "越小越好",
    "target_is_better": "越接近目标越好",
    "neutral": "仅展示",
}


def render(data: dict) -> str:
    lines = [
        f"# {data.get('software')} {data.get('version')} 性能报告",
        "",
        f"- 架构：`{data.get('architecture')}`",
        f"- 状态：`{data.get('status')}`",
        f"- Run ID：`{data.get('run_id')}`",
        "",
        "| 指标 | 数值 | 单位 | 优化方向 |",
        "|---|---:|---|---|",
    ]
    for name, metric in data.get("metrics", {}).items():
        value = metric.get("value")
        lines.append(
            f"| {name} | {value if value is not None else 'N/A'} | {metric.get('unit', '')} | "
            f"{DIRECTION_LABELS.get(metric.get('direction'), metric.get('direction'))} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render(load_json(args.input, {})), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
