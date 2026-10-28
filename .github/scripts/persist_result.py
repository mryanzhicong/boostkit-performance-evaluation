#!/usr/bin/env python3
"""Atomically preserve one architecture's complete result outside runner cleanup."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import tempfile
from pathlib import Path


RESULT_ROOT = Path("/home/runner/boostkit-perf-result")


def component(value: str) -> str:
    if not value or value in {".", ".."} or "/" in value or "\\" in value:
        raise ValueError(f"invalid result path component: {value!r}")
    return value


def destination(
    category: str, software: str, version: str, result_directory: str,
    architecture: str, variant: str, root: Path = RESULT_ROOT,
) -> Path:
    parts = [component(value) for value in (category, software, version)]
    if variant not in {"base", "optimized"}:
        raise ValueError(f"invalid variant: {variant}")
    if variant == "optimized":
        parts.append("optimized")
    parts.extend((component(result_directory), component(architecture)))
    return root.joinpath(*parts)


def persist(source: Path, target: Path) -> None:
    if not source.is_dir() or not (source / "status.json").is_file():
        raise ValueError(f"result directory is missing status.json: {source}")
    if target.exists():
        raise ValueError(f"refusing to overwrite preserved result: {target}")
    target.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{target.name}.pending-", dir=target.parent))
    try:
        shutil.copytree(source, staging, dirs_exist_ok=True, symlinks=True)
        source_status = json.loads((source / "status.json").read_text(encoding="utf-8"))
        copied_status = json.loads((staging / "status.json").read_text(encoding="utf-8"))
        if source_status != copied_status:
            raise ValueError("preserved status.json differs from the source")
        if target.exists():
            raise ValueError(f"refusing to overwrite preserved result: {target}")
        os.rename(staging, target)
    finally:
        if staging.exists():
            shutil.rmtree(staging)
    print(f"[result] preserved {source} at {target}", flush=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--category", required=True)
    parser.add_argument("--software", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--result-directory", required=True)
    parser.add_argument("--architecture", choices=("x86_64", "aarch64"), required=True)
    parser.add_argument("--variant", choices=("base", "optimized"), required=True)
    args = parser.parse_args()
    target = destination(
        args.category, args.software, args.version, args.result_directory,
        args.architecture, args.variant,
    )
    persist(args.source, target)


if __name__ == "__main__":
    main()
