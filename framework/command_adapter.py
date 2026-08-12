#!/usr/bin/env python3
"""Execute an existing software test entrypoint without generating test code."""

from __future__ import annotations

import os
import signal
import subprocess
import sys
import threading
from dataclasses import dataclass
from pathlib import Path
from typing import TextIO

from context import RunContext


@dataclass(frozen=True)
class CommandResult:
    returncode: int
    log_path: Path
    missing_outputs: tuple[str, ...]


class StageTerminated(RuntimeError):
    """Raised when the runner asks an active stage to terminate."""


def _stringify(value: object) -> str:
    if isinstance(value, bool):
        return "1" if value else "0"
    return str(value)


def _terminate_process_group(process: subprocess.Popen[str]) -> None:
    """Stop every process started by one stage, not only its shell parent."""
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=5)
        return
    except subprocess.TimeoutExpired:
        pass
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        return
    process.wait(timeout=5)


def _raise_stage_terminated(signum: int, _frame: object) -> None:
    raise StageTerminated(f"received signal {signum}")


def _stream_output(stream: TextIO, log: TextIO) -> None:
    """Mirror stage output to the Actions console and its durable stage log."""
    for line in stream:
        sys.stdout.write(line)
        sys.stdout.flush()
        log.write(line)
        log.flush()


def build_environment(context: RunContext, case_venv: Path | None = None) -> dict[str, str]:
    environment = dict(os.environ)
    environment.update({
        "SOFTWARE_VERSION": context.version,
        "EXPECTED_ARCH": context.architecture,
        "RESULTS_DIR": str(context.output_dir),
        "PERF_RUN_ID": context.run_id,
        "PERF_PROCESS_TOKEN": (
            f"boostkit-perf:{context.run_id}:{context.category}:"
            f"{context.software}:{context.version}:{context.architecture}"
        ),
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
    for key, value in context.execution.get("environment", {}).items():
        environment[str(key)] = _stringify(value)
    override = context.case.get("version_overrides", {}).get(context.version, {})
    for key, value in override.get("environment", {}).items():
        environment[str(key)] = _stringify(value)
    return environment


def run_command(
    context: RunContext,
    stage: str | None = None,
    *,
    check_outputs: bool = True,
) -> CommandResult:
    entrypoint = (context.case_dir / context.execution["entrypoint"]).resolve()
    timeout_minutes = float(context.execution.get("timeout_minutes", 180))
    log_path = context.output_dir / f"command-{stage or 'all'}.log"
    context.output_dir.mkdir(parents=True, exist_ok=True)
    context.work_dir.mkdir(parents=True, exist_ok=True)
    (context.work_dir / "tmp").mkdir(parents=True, exist_ok=True)
    case_venv = context.work_dir / "venv"
    if not (case_venv / "bin" / "python").is_file():
        subprocess.run(
            [sys.executable, "-m", "venv", str(case_venv)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    environment = build_environment(context, case_venv)
    command = ["bash", str(entrypoint)] if entrypoint.suffix == ".sh" else [str(entrypoint)]
    if stage is not None:
        command.append(stage)
    with log_path.open("w", encoding="utf-8") as log:
        process: subprocess.Popen[str] | None = None
        output_thread: threading.Thread | None = None
        previous_sigterm = signal.getsignal(signal.SIGTERM)
        signal.signal(signal.SIGTERM, _raise_stage_terminated)
        try:
            process = subprocess.Popen(
                command,
                cwd=context.case_dir,
                env=environment,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                bufsize=1,
                start_new_session=True,
            )
            assert process.stdout is not None
            output_thread = threading.Thread(
                target=_stream_output,
                args=(process.stdout, log),
                name=f"stage-output-{stage or 'all'}",
            )
            output_thread.start()
            returncode = process.wait(timeout=timeout_minutes * 60)
        except subprocess.TimeoutExpired:
            assert process is not None
            message = f"[TIMEOUT] stage {stage or 'all'} exceeded {timeout_minutes} minutes\n"
            sys.stderr.write(message)
            sys.stderr.flush()
            log.write(message)
            log.flush()
            _terminate_process_group(process)
            returncode = 124
        except BaseException:
            if process is not None:
                _terminate_process_group(process)
            raise
        finally:
            if output_thread is not None:
                output_thread.join()
            signal.signal(signal.SIGTERM, previous_sigterm)
    missing = ()
    if check_outputs:
        missing = tuple(
            output for output in context.execution.get("expected_outputs", [])
            if not (context.output_dir / output).is_file()
        )
    return CommandResult(returncode=returncode, log_path=log_path, missing_outputs=missing)
