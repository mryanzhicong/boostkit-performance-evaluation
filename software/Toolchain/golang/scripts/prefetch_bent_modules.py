#!/usr/bin/env python3
"""Validate the local Bent cache; download missing modules only when needed."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
import tomllib
import zipfile
from concurrent.futures import ThreadPoolExecutor
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
    print(f"[golang] downloading missing module {module}", flush=True)
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


def cached_zip(module_cache: Path | None, module: str) -> Path | None:
    if module_cache is None:
        return None
    path, version = module.rsplit("@", 1)
    escaped = "".join(f"!{character.lower()}" if character.isupper() else character for character in path)
    base = module_cache / "cache" / "download" / escaped / "@v" / version
    if all(
        Path(f"{base}{extension}").is_file() and Path(f"{base}{extension}").stat().st_size > 0
        for extension in (".zip", ".ziphash", ".mod", ".info")
    ):
        return Path(f"{base}.zip")
    return None


def suite_dependencies(module: str, archive: Path) -> list[str]:
    with zipfile.ZipFile(archive) as bundle:
        try:
            contents = bundle.read(f"{module}/go.sum").decode("utf-8")
        except KeyError:
            return []
    return dependencies_from_sums(contents)


def dependencies_from_sums(contents: str) -> list[str]:
    dependencies: list[str] = []
    for line in contents.splitlines():
        fields = line.split()
        if len(fields) == 3:
            dependencies.append(f"{fields[0]}@{fields[1].removesuffix('/go.mod')}")
    return dependencies


def offline_suites_resolve(
    go: str, suites: list[dict], work_dir: Path, module_cache: Path, bent_version: str | None
) -> bool:
    """Exercise Bent's go-get requests without allowing a network connection."""
    proxy = (module_cache / "cache" / "download").resolve().as_uri()
    environment = os.environ | {"GOPROXY": proxy, "GOSUMDB": "off"}
    with tempfile.TemporaryDirectory(prefix="bent-cache-check-", dir=work_dir) as temporary:
        if bent_version:
            environment["GOBIN"] = str(Path(temporary) / "bin")
            completed = subprocess.run(
                [go, "install", f"golang.org/x/benchmarks/cmd/bent@{bent_version}"],
                cwd=temporary,
                env=environment,
                capture_output=True,
                text=True,
                check=False,
            )
            if completed.returncode:
                print(f"[golang] local Bent installation is unavailable: {completed.stderr.strip()}", flush=True)
                return False
        def resolve_suite(suite: dict) -> tuple[str, str | None]:
            directory = Path(temporary) / suite["Name"]
            directory.mkdir()
            (directory / "go.mod").write_text("module build\n\ngo 1.25\n", encoding="utf-8")
            completed = subprocess.run(
                [go, "get", "-t", "-v", suite["Repo"] + suite["Version"]],
                cwd=directory,
                env=environment,
                capture_output=True,
                text=True,
                check=False,
            )
            if completed.returncode:
                errors = completed.stderr.strip().splitlines()
                return suite["Name"], errors[-1] if errors else f"go get exited {completed.returncode}"
            return suite["Name"], None

        with ThreadPoolExecutor(max_workers=min(8, max(1, len(suites)))) as workers:
            results = list(workers.map(resolve_suite, suites))
        for name, error in results:
            if error is not None:
                print(f"[golang] local cache is incomplete for {name}: {error}", flush=True)
                return False
    return True


def prefetch(
    go: str, suites_file: Path, work_dir: Path, module_cache: Path | None = None,
    bent_version: str | None = None,
) -> None:
    suites = tomllib.loads(suites_file.read_text(encoding="utf-8"))["Suites"]
    if module_cache is not None and offline_suites_resolve(
        go, suites, work_dir, module_cache, bent_version
    ):
        print(
            f"[golang] Bent and all {len(suites)} suites resolve from local cache; no downloads needed",
            flush=True,
        )
        return
    seen: set[str] = set()
    dependencies: list[str] = []
    cached_count = 0
    downloaded_count = 0
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
        archive = cached_zip(module_cache, module)
        if archive is not None:
            dependencies.extend(suite_dependencies(module, archive))
            cached_count += 1
        else:
            source_dir = download(go, work_dir, module)
            sums_file = source_dir / "go.sum"
            if sums_file.is_file():
                dependencies.extend(dependencies_from_sums(sums_file.read_text(encoding="utf-8")))
            downloaded_count += 1

    if bent_version:
        module = f"golang.org/x/benchmarks@{bent_version}"
        archive = cached_zip(module_cache, module)
        if archive is not None:
            dependencies.extend(suite_dependencies(module, archive))
            cached_count += 1
        else:
            source_dir = download(go, work_dir, module)
            sums_file = source_dir / "go.sum"
            if sums_file.is_file():
                dependencies.extend(dependencies_from_sums(sums_file.read_text(encoding="utf-8")))
            downloaded_count += 1
        seen.add(module)

    dependencies = [module for module in dict.fromkeys(dependencies) if module not in seen]
    with ThreadPoolExecutor(max_workers=min(16, max(1, len(dependencies)))) as workers:
        archives = list(workers.map(lambda module: cached_zip(module_cache, module), dependencies))
    for module, archive in zip(dependencies, archives):
        seen.add(module)
        if archive is not None:
            cached_count += 1
        else:
            download(go, work_dir, module)
            downloaded_count += 1
    print(
        f"[golang] prepared {len(seen)} Bent module versions: "
        f"{cached_count} from local cache, {downloaded_count} downloaded sequentially",
        flush=True,
    )
    if module_cache is not None and not offline_suites_resolve(
        go, suites, work_dir, module_cache, bent_version
    ):
        raise RuntimeError("Bent modules remain unavailable in the local cache after downloading")


def main() -> int:
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("--go", required=True)
    arguments.add_argument("--suites", type=Path, required=True)
    arguments.add_argument("--work-dir", type=Path, required=True)
    arguments.add_argument("--module-cache", type=Path)
    arguments.add_argument("--bent-version")
    args = arguments.parse_args()
    try:
        prefetch(args.go, args.suites, args.work_dir, args.module_cache, args.bent_version)
    except (OSError, KeyError, RuntimeError, tomllib.TOMLDecodeError, zipfile.BadZipFile) as error:
        print(f"[golang] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
