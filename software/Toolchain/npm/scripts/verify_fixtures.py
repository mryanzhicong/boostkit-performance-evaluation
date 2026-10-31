#!/usr/bin/env python3
"""Validate the committed npm fixtures before the cache is warmed.

The measurement is only meaningful if the tree that npm installs is byte-for-byte
the tree that was committed: the lockfile checksums are verified by the caller,
and this script additionally proves that the fixtures are deterministic inputs
(exact pinned direct dependencies, complete resolved/integrity entries) so that
``npm ci --offline`` can never fall back to a registry lookup.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

PINNED_VERSION = re.compile(r"^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$")
TIER_FIXTURES = ("small", "medium", "large")
UPSTREAM_FIXTURE = "upstream"


def fail(message: str) -> None:
    print(f"[npm-fixtures] ERROR: {message}", file=sys.stderr)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"invalid JSON in {path}: {exc}") from exc


def validate_tier(fixtures: Path, name: str) -> dict[str, Any]:
    directory = fixtures / name
    package = load_json(directory / "package.json")
    lock = load_json(directory / "package-lock.json")
    dependencies = {
        **package.get("dependencies", {}),
        **package.get("devDependencies", {}),
    }
    if not dependencies:
        raise RuntimeError(f"fixture {name} declares no dependencies")
    for dependency, version in dependencies.items():
        if not isinstance(version, str) or not PINNED_VERSION.match(version):
            raise RuntimeError(
                f"fixture {name} dependency {dependency} is not exact-pinned: {version!r}"
            )
    if lock.get("lockfileVersion") != 3:
        raise RuntimeError(
            f"fixture {name} lockfileVersion is {lock.get('lockfileVersion')}, expected 3"
        )
    packages = lock.get("packages")
    if not isinstance(packages, dict) or len(packages) < 2:
        raise RuntimeError(f"fixture {name} lockfile has no installed packages")
    for key, entry in packages.items():
        if key == "":
            continue
        if not entry.get("resolved") or not entry.get("integrity"):
            raise RuntimeError(
                f"fixture {name} lockfile entry {key} lacks resolved/integrity"
            )
        if entry.get("link"):
            raise RuntimeError(f"fixture {name} lockfile entry {key} is a linked dependency")
    return {
        "direct_dependencies": len(dependencies),
        "installed_packages": len(packages) - 1,
        "lockfile_version": lock.get("lockfileVersion"),
    }


def validate_upstream(fixtures: Path) -> dict[str, Any]:
    directory = fixtures / UPSTREAM_FIXTURE
    package = load_json(directory / "package.json")
    lock = load_json(directory / "package-lock.json")
    if package.get("workspaces"):
        raise RuntimeError("the upstream fixture must not declare npm workspaces")
    if lock.get("lockfileVersion") not in (2, 3):
        raise RuntimeError(
            f"upstream lockfileVersion is {lock.get('lockfileVersion')}, expected 2 or 3"
        )
    packages = lock.get("packages")
    if not isinstance(packages, dict) or len(packages) < 2:
        raise RuntimeError("upstream lockfile has no installed packages")
    link_count = 0
    local_dir_count = 0
    for key, entry in packages.items():
        if key == "":
            continue
        if entry.get("link"):
            # Real projects may link a directory of their own repository into
            # node_modules.  That is only accepted when the target directory is
            # committed with the fixture, because npm would otherwise resolve
            # outside of the checked-in tree.
            target = entry.get("resolved")
            if not isinstance(target, str) or target.startswith(("http://", "https://")):
                raise RuntimeError(
                    f"upstream lockfile entry {key} has an unsupported link target: {target!r}"
                )
            fixture_root = directory.resolve()
            target_dir = (directory / target).resolve()
            if fixture_root not in target_dir.parents:
                raise RuntimeError(
                    f"upstream lockfile entry {key} links outside the fixture: {target}"
                )
            if not (target_dir / "package.json").is_file():
                raise RuntimeError(
                    f"upstream lockfile entry {key} links to a directory without package.json: {target}"
                )
            link_count += 1
            continue
        if not key.startswith("node_modules/"):
            # Link targets and other local directory packages have no registry
            # identity; they must exist in the committed tree instead.
            fixture_root = directory.resolve()
            local_dir = (directory / key).resolve()
            if fixture_root not in local_dir.parents:
                raise RuntimeError(
                    f"upstream lockfile entry {key} points outside the fixture directory"
                )
            if not (local_dir / "package.json").is_file():
                raise RuntimeError(
                    f"upstream lockfile entry {key} has no directory with a package.json in the fixture"
                )
            local_dir_count += 1
            continue
        resolved = entry.get("resolved") or ""
        if not resolved.startswith(("https://", "http://")):
            raise RuntimeError(f"upstream lockfile entry {key} has a non-HTTP resolved URL")
        if not entry.get("integrity"):
            raise RuntimeError(f"upstream lockfile entry {key} has no integrity hash")
    ref = ""
    ref_file = directory / "ref.txt"
    if ref_file.is_file():
        ref = ref_file.read_text(encoding="utf-8").strip().splitlines()[0]
    return {
        "installed_packages": len(packages) - 1,
        "lockfile_version": lock.get("lockfileVersion"),
        "project": f"{package.get('name')}@{package.get('version')}",
        "upstream_reference": ref,
        "committed_links": link_count,
        "committed_local_dirs": local_dir_count,
    }


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: verify_fixtures.py FIXTURES_DIRECTORY", file=sys.stderr)
        return 1
    fixtures = Path(sys.argv[1])
    if not fixtures.is_dir():
        fail(f"fixtures directory does not exist: {fixtures}")
        return 1
    try:
        rows = {name: validate_tier(fixtures, name) for name in TIER_FIXTURES}
        rows[UPSTREAM_FIXTURE] = validate_upstream(fixtures)
    except RuntimeError as exc:
        fail(str(exc))
        return 1
    for name in (*TIER_FIXTURES, UPSTREAM_FIXTURE):
        row = rows[name]
        print(
            f"[npm-fixtures] {name:<8} installed={row['installed_packages']:<5} "
            f"lockfile=v{row['lockfile_version']} {row.get('project', '')}".rstrip()
        )
        if row.get("committed_links"):
            print(
                f"[npm-fixtures] {name:<8} committed links={row['committed_links']} "
                f"(targets are part of the fixture tree)"
            )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
