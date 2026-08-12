"""Validate software outputs and normalize their declared metrics."""

from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
from typing import Any

from context import RunContext
from json_helper import atomic_write_json, get_path, load_json


class ResultValidationError(ValueError):
    """Raised when a software result violates the common result contract."""


MISSING = object()


def parameter_signature(context: RunContext) -> str:
    payload = {
        "software": context.software,
        "version": context.version,
        "environment": context.execution.get("environment", {}),
    }
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def _load_sources(context: RunContext) -> dict[str, Any]:
    sources: dict[str, Any] = {}
    for filename in context.execution.get("expected_outputs", []):
        path = context.output_dir / filename
        if not path.is_file():
            raise ResultValidationError(f"required result file is missing: {filename}")
        if path.stat().st_size == 0:
            raise ResultValidationError(f"required result file is empty: {filename}")
        if path.suffix == ".json":
            try:
                value = load_json(path)
            except (OSError, json.JSONDecodeError) as exc:
                raise ResultValidationError(f"invalid JSON result file {filename}: {exc}") from exc
            if not isinstance(value, dict):
                raise ResultValidationError(f"JSON result root must be an object: {filename}")
            sources[filename] = value
        else:
            sources[filename] = {"path": str(path), "size": path.stat().st_size}
    return sources


def _extract_metrics(context: RunContext, sources: dict[str, Any]) -> dict[str, Any]:
    metrics: dict[str, Any] = {}
    for metric_name, definition in context.case.get("metrics", {}).items():
        source_name = definition["source"]
        if source_name not in sources:
            raise ResultValidationError(
                f"metric {metric_name} references unavailable source {source_name}"
            )
        value = get_path(sources[source_name], definition["path"], MISSING)
        if value is MISSING:
            raise ResultValidationError(
                f"metric {metric_name} path does not exist: "
                f"{source_name}:{definition['path']}"
            )
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ResultValidationError(
                f"metric {metric_name} must be numeric, got {type(value).__name__}"
            )
        numeric_value = float(value)
        if not math.isfinite(numeric_value):
            raise ResultValidationError(f"metric {metric_name} must be finite")
        metrics[metric_name] = {
            "value": value,
            "unit": definition["unit"],
            "direction": definition["direction"],
            "target": definition.get("target"),
        }
    if not metrics:
        raise ResultValidationError("no metrics were extracted")
    return metrics


def normalize(context: RunContext, command_status: str) -> dict[str, Any]:
    sources = _load_sources(context)
    primary = sources.get("results.json", {})
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
        "metrics": _extract_metrics(context, sources),
        "legacy_summary": primary.get("summary", {}) if isinstance(primary, dict) else {},
    }


def write_normalized(context: RunContext, command_status: str) -> Path:
    output = context.output_dir / "normalized_result.json"
    atomic_write_json(output, normalize(context, command_status))
    return output
