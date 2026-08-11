#!/usr/bin/env python3
"""Normalize existing case outputs without replacing their benchmark logic."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from context import RunContext
from json_helper import atomic_write_json, get_path, load_json


def parameter_signature(context: RunContext) -> str:
    payload = {
        "software": context.software,
        "version": context.version,
        "environment": context.execution.get("environment", {}),
    }
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def normalize(context: RunContext, command_status: str) -> dict[str, Any]:
    sources: dict[str, Any] = {}
    for filename in context.execution.get("expected_outputs", []):
        path = context.output_dir / filename
        sources[filename] = load_json(path, {}) if path.suffix == ".json" else {"path": str(path)}

    primary = sources.get("results.json", {})
    metrics: dict[str, Any] = {}
    for metric_name, definition in context.case.get("metrics", {}).items():
        source_name = definition.get("source", "results.json")
        source = sources.get(source_name, {})
        value = get_path(source, definition.get("path", "")) if definition.get("path") else None
        metrics[metric_name] = {
            "value": value,
            "unit": definition.get("unit", ""),
            "direction": definition.get("direction", "neutral"),
            "target": definition.get("target"),
        }

    return {
        "software": context.software,
        "category": context.category,
        "version": context.version,
        "architecture": context.architecture,
        "run_id": context.run_id,
        "status": command_status,
        "cleanup_status": "pending",
        "parameter_signature": parameter_signature(context),
        "environment_before": load_json(context.output_dir / "environment_before.json", {}),
        "environment_after": load_json(context.output_dir / "environment_after.json", {}),
        "sources": sources,
        "metrics": metrics,
        "legacy_summary": primary.get("summary", {}) if isinstance(primary, dict) else {},
    }


def write_normalized(context: RunContext, command_status: str) -> Path:
    output = context.output_dir / "normalized_result.json"
    atomic_write_json(output, normalize(context, command_status))
    return output


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    data = load_json(args.input)
    atomic_write_json(args.output, data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
