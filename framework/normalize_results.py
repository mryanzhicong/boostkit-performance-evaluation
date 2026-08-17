"""Validate software outputs and normalize their declared metrics."""

from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
from typing import Any

from build_info import load_build_info
from context import RunContext
from json_helper import atomic_write_json, get_path, load_json


class ResultValidationError(ValueError):
    """Raised when a software result violates the common result contract."""


MISSING = object()


def resolved_parameters(sources: dict[str, Any]) -> dict[str, Any]:
    """Collect the workload parameters recorded by declared JSON outputs."""
    return {
        source_name: source["parameters"]
        for source_name, source in sources.items()
        if isinstance(source, dict) and isinstance(source.get("parameters"), dict)
    }


def parameter_signature(context: RunContext, parameters: dict[str, Any]) -> str:
    payload = {
        "software": context.software,
        "version": context.version,
        "parameters": parameters,
    }
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def _load_output(
    context: RunContext,
    output_name: str,
    definition: dict[str, Any],
) -> Any | None:
    filename = definition["path"]
    path = context.output_dir / filename
    if not path.is_file():
        if definition["required"]:
            raise ResultValidationError(
                f"required output {output_name} is missing: {filename}"
            )
        return None
    if path.stat().st_size == 0:
        raise ResultValidationError(f"output {output_name} is empty: {filename}")
    if definition["format"] == "json":
        try:
            value = load_json(path)
        except (OSError, json.JSONDecodeError) as exc:
            raise ResultValidationError(
                f"output {output_name} contains invalid JSON ({filename}): {exc}"
            ) from exc
        if not isinstance(value, dict):
            raise ResultValidationError(
                f"output {output_name} JSON root must be an object: {filename}"
            )
        return value
    return {"path": str(path), "size": path.stat().st_size}


def validate_stage_outputs(context: RunContext, stage: str) -> None:
    """Validate every output assigned to a completed software stage."""
    for output_name, definition in context.case.get("outputs", {}).items():
        if definition["stage"] == stage:
            _load_output(context, output_name, definition)


def _load_sources(context: RunContext) -> dict[str, Any]:
    sources: dict[str, Any] = {}
    for output_name, definition in context.case.get("outputs", {}).items():
        loaded = _load_output(context, output_name, definition)
        if loaded is None:
            continue
        sources[output_name] = loaded
    return sources


def _extract_metrics(context: RunContext, sources: dict[str, Any]) -> dict[str, Any]:
    metrics: dict[str, Any] = {}
    metric_config = context.case.get("metrics", {})
    default_source = metric_config.get("source")
    for metric_name, definition in metric_config.get("definitions", {}).items():
        source_name = definition.get("source", default_source)
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
        }
    if not metrics:
        raise ResultValidationError("no metrics were extracted")
    return metrics


def normalize(context: RunContext, command_status: str) -> dict[str, Any]:
    sources = _load_sources(context)
    parameters = resolved_parameters(sources)
    return {
        "software": context.software,
        "category": context.category,
        "version": context.version,
        "architecture": context.architecture,
        "run_id": context.run_id,
        "status": command_status,
        "cleanup_status": "pending",
        "build_info": load_build_info(context),
        "parameters": parameters,
        "parameter_signature": parameter_signature(context, parameters),
        "system_info": load_json(context.output_dir / "system_info.json", {}),
        "runtime_before": load_json(context.output_dir / "runtime_before.json", {}),
        "runtime_after": load_json(context.output_dir / "runtime_after.json", {}),
        "sources": sources,
        "metrics": _extract_metrics(context, sources),
    }


def write_normalized(context: RunContext, command_status: str) -> Path:
    output = context.output_dir / "normalized_result.json"
    atomic_write_json(output, normalize(context, command_status))
    return output
