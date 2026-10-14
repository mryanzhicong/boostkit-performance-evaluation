#!/usr/bin/env python3
"""Prefetch the pinned Bent suites and their go.sum modules sequentially."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tomllib
from pathlib import Path


MODULE_PATHS = {
    "uuid": "github.com/google/uuid",
    "ericlagergren_decimal": "github.com/ericlagergren/decimal_benchmarks",
    "gonum_lapack_native": "gonum.org/v1/gonum",
    "gonum_mat": "gonum.org/v1/gonum",
    "gproto_json": "google.golang.org/protobuf",
    "gproto_reflect": "google.golang.org/protobuf",
    "gproto_micro": "google.golang.org/protobuf",
    "gproto_proto": "google.golang.org/protobuf",
    "minio": "github.com/minio/minio",
    "bloom_bits": "github.com/bits-and-blooms/bitset",
    "shopify_sarama": "github.com/IBM/sarama",
    "ethereum_trie": "github.com/ethereum/go-ethereum",
    "semver": "github.com/Masterminds/semver/v3",
    "commonmark_markdown": "gitlab.com/golang-commonmark/markdown",
    "dustin_humanize": "github.com/dustin/go-humanize",
}


def download(go: str, work_dir: Path, module: str) -> Path:
    print(f"[golang] prefetching {module}", flush=True)
    completed = subprocess.run(
        [go, "mod", "download", "-json", module],
        cwd=work_dir,
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError(f"Go module download failed for {module}: {completed.stderr.strip()}")
    try:
        metadata = json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"Go module download returned invalid JSON for {module}") from error
    if metadata.get("Error"):
        raise RuntimeError(f"Go module download failed for {module}: {metadata['Error']}")
    source = metadata.get("Dir")
    directory = Path(source) if source else None
    if directory is None or not directory.is_dir():
        raise RuntimeError(f"Go module download returned no source directory for {module}")
    return directory


def prefetch(go: str, suites_file: Path, work_dir: Path) -> None:
    suites = tomllib.loads(suites_file.read_text(encoding="utf-8"))["Suites"]
    seen: set[str] = set()
    for suite in suites:
        name = suite["Name"]
        if name not in MODULE_PATHS:
            raise RuntimeError(f"Bent suite has no declared module path: {name}")
        if not suite["Repo"].rstrip("/").startswith(MODULE_PATHS[name]):
            raise RuntimeError(f"Bent suite module path does not match its repository: {name}")
        module = f"{MODULE_PATHS[name]}{suite['Version']}"
        if module in seen:
            continue
        seen.add(module)
        source_dir = download(go, work_dir, module)
        sums_file = source_dir / "go.sum"
        if not sums_file.is_file():
            continue
        for line in sums_file.read_text(encoding="utf-8").splitlines():
            fields = line.split()
            if len(fields) != 3 or fields[1].endswith("/go.mod"):
                continue
            dependency = f"{fields[0]}@{fields[1]}"
            if dependency not in seen:
                seen.add(dependency)
                download(go, work_dir, dependency)
    print(f"[golang] prefetched {len(seen)} Bent module versions one at a time", flush=True)


def main() -> int:
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("--go", required=True)
    arguments.add_argument("--suites", type=Path, required=True)
    arguments.add_argument("--work-dir", type=Path, required=True)
    args = arguments.parse_args()
    try:
        prefetch(args.go, args.suites, args.work_dir)
    except (OSError, KeyError, RuntimeError, tomllib.TOMLDecodeError) as error:
        print(f"[golang] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
