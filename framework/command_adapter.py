#!/usr/bin/env python3
"""Execute an existing software test entrypoint without generating test code."""

from __future__ import annotations

import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from context import RunContext


@dataclass(frozen=True)
class CommandResult:
    returncode: int
    log_path: Path
    missing_outputs: tuple[str, ...]


def _stringify(value: object) -> str:
    if isinstance(value, bool):
        return "1" if value else "0"
    return str(value)


def build_environment(context: RunContext, case_venv: Path | None = None) -> dict[str, str]:
    environment = dict(os.environ)
    environment.update({
        "SOFTWARE_VERSION": context.version,
        "EXPECTED_ARCH": context.architecture,
        "TARGET_ARCH": context.architecture,
        "TEST_MODE": context.test_mode,
        "RESULTS_DIR": str(context.output_dir),
        "PERF_RUN_ID": context.run_id,
        "PERF_WORK_DIR": str(context.work_dir),
        "PIP_CACHE_DIR": str(context.work_dir / "pip-cache"),
        "XDG_CACHE_HOME": str(context.work_dir / "cache"),
        "CARGO_HOME": str(context.work_dir / "cargo"),
        "CCACHE_DIR": str(context.work_dir / "ccache"),
        "TMPDIR": str(context.work_dir / "tmp"),
        "PYTHONUNBUFFERED": "1",
    })
    if case_venv is not None:
        environment["VIRTUAL_ENV"] = str(case_venv)
        environment["PATH"] = f"{case_venv / 'bin'}:{environment.get('PATH', '')}"
    for key, value in context.mode_config.get("environment", {}).items():
        environment[str(key)] = _stringify(value)
    override = context.case.get("version_overrides", {}).get(context.version, {})
    for key, value in override.get("environment", {}).items():
        environment[str(key)] = _stringify(value)
    return environment


def run_command(context: RunContext) -> CommandResult:
    entrypoint = (context.case_dir / context.execution["entrypoint"]).resolve()
    timeout_minutes = int(context.mode_config.get("timeout_minutes", 180))
    log_path = context.output_dir / "command.log"
    context.output_dir.mkdir(parents=True, exist_ok=True)
    context.work_dir.mkdir(parents=True, exist_ok=True)
    (context.work_dir / "tmp").mkdir(parents=True, exist_ok=True)
    case_venv = context.work_dir / "venv"
    subprocess.run(
        [sys.executable, "-m", "venv", str(case_venv)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    environment = build_environment(context, case_venv)
    command = ["bash", str(entrypoint)] if entrypoint.suffix == ".sh" else [str(entrypoint)]
    with log_path.open("w", encoding="utf-8") as log:
        try:
            completed = subprocess.run(
                command,
                cwd=context.case_dir,
                env=environment,
                stdout=log,
                stderr=subprocess.STDOUT,
                timeout=timeout_minutes * 60,
                check=False,
                text=True,
            )
            returncode = completed.returncode
        except subprocess.TimeoutExpired:
            log.write(f"\n[TIMEOUT] exceeded {timeout_minutes} minutes\n")
            returncode = 124
    missing = tuple(
        output for output in context.execution.get("expected_outputs", [])
        if not (context.output_dir / output).is_file()
    )
    return CommandResult(returncode=returncode, log_path=log_path, missing_outputs=missing)
