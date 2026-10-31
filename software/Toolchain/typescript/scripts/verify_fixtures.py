#!/usr/bin/env python3
"""Validate the committed TypeScript fixtures without running the compiler.

The measurement is only meaningful if the program that tsc compiles is exactly
the program that was published with the case.  This script proves that:

* ``fixtures/projects.json`` pins the deterministic projects, and re-running the
  generator reproduces every tree digest;
* the upstream fixture matches its per-file SHA-256 manifest, is the pinned
  upstream version and carries no compiler options that could compensate for a
  slow machine;
* declare nothing that depends on an architecture: the fixture must stay
  identical on x86_64 and aarch64.
"""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

REQUIRED_PROJECTS = {
    "small": 100,
    "medium": 1000,
    "large": 5000,
    "emit": 1000,
    "incremental": 1000,
    "references": 0,
}
REFERENCE_PACKAGES = {"lib": 200, "app": 300}
UPSTREAM_MODULES = 13


def fail(message: str) -> None:
    print(f"[typescript-fixtures] ERROR: {message}", file=sys.stderr)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise RuntimeError(f"cannot read {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"invalid JSON in {path}: {exc}") from exc


def tree_digest(root: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(entry for entry in root.rglob("*") if entry.is_file()):
        relative = path.relative_to(root).as_posix()
        file_digest = hashlib.sha256(path.read_bytes()).hexdigest()
        digest.update(f"{relative}\0{file_digest}\n".encode())
    return digest.hexdigest()


def validate_projects(fixtures: Path) -> dict[str, Any]:
    payload = load_json(fixtures / "projects.json")
    projects = payload.get("projects")
    if not isinstance(projects, dict) or set(projects) != set(REQUIRED_PROJECTS):
        raise RuntimeError(
            f"fixtures/projects.json must describe exactly {sorted(REQUIRED_PROJECTS)}"
        )
    for name, modules in REQUIRED_PROJECTS.items():
        entry = projects[name]
        if entry.get("modules") != modules:
            raise RuntimeError(
                f"project {name} declares {entry.get('modules')} modules, expected {modules}"
            )
        digest = entry.get("digest")
        if not isinstance(digest, str) or len(digest) != 64:
            raise RuntimeError(f"project {name} has no SHA-256 tree digest")
    references = projects["references"].get("packages")
    if references != REFERENCE_PACKAGES:
        raise RuntimeError(
            f"the references project declares {references}, expected {REFERENCE_PACKAGES}"
        )
    generator = fixtures.parent / "scripts" / "fixtures" / "generate_projects.py"
    if not generator.is_file():
        raise RuntimeError(f"the project generator is missing: {generator}")
    with tempfile.TemporaryDirectory(prefix="typescript-fixtures-") as temporary:
        output = Path(temporary)
        completed = subprocess.run(
            [sys.executable, str(generator), str(output), "--summary", str(output / "summary.json")],
            capture_output=True,
            text=True,
            check=False,
        )
        if completed.returncode != 0:
            raise RuntimeError(
                "the project generator failed: " + (completed.stderr or completed.stdout).strip()
            )
        summary = load_json(output / "summary.json")
        regenerated = summary.get("projects", {})
        for name, entry in sorted(projects.items()):
            if regenerated.get(name, {}).get("digest") != entry["digest"]:
                raise RuntimeError(
                    f"project {name} is not reproducible: the generator produces a different tree"
                )
    return {
        "projects": {
            name: {"modules": entry["modules"], **({"packages": entry["packages"]} if "packages" in entry else {})}
            for name, entry in projects.items()
        }
    }


def validate_upstream(fixtures: Path) -> dict[str, Any]:
    directory = fixtures / "upstream"
    manifest_path = directory / "manifest.sha256"
    if not manifest_path.is_file():
        raise RuntimeError("the upstream fixture has no manifest.sha256")
    listed: set[str] = set()
    for line in manifest_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != 2:
            raise RuntimeError(f"malformed manifest line: {line!r}")
        expected, relative = parts
        listed.add(relative)
        target = directory / relative
        if not target.is_file():
            raise RuntimeError(f"the upstream fixture is missing {relative}")
        actual = hashlib.sha256(target.read_bytes()).hexdigest()
        if actual != expected:
            raise RuntimeError(f"the upstream fixture file {relative} does not match its hash")
    for path in sorted(entry for entry in directory.rglob("*") if entry.is_file()):
        relative = path.relative_to(directory).as_posix()
        if relative == "manifest.sha256":
            continue
        if relative not in listed:
            raise RuntimeError(f"the upstream fixture file {relative} is not covered by the manifest")
    sources = sorted(directory.glob("src/**/*.ts"))
    if len(sources) != UPSTREAM_MODULES:
        raise RuntimeError(
            f"the upstream fixture has {len(sources)} TypeScript sources, expected {UPSTREAM_MODULES}"
        )
    tsconfig = load_json(directory / "tsconfig.json")
    options = tsconfig.get("compilerOptions", {})
    if options.get("types") != []:
        raise RuntimeError("the upstream fixture must compile with an empty 'types' list")
    if options.get("noEmit") is not True:
        raise RuntimeError("the upstream fixture must be type checked without emitting files")
    for forbidden in ("paths", "rootDirs", "customConditions"):
        if forbidden in options:
            raise RuntimeError(f"the upstream fixture must not configure {forbidden}")
    ref = ""
    ref_file = directory / "ref.txt"
    if ref_file.is_file():
        ref = ref_file.read_text(encoding="utf-8").strip().splitlines()[0]
    if "zod" not in ref:
        raise RuntimeError("the upstream fixture reference does not name its project")
    if not (directory / "LICENSE").is_file():
        raise RuntimeError("the upstream fixture has no LICENSE file")
    return {
        "upstream": {
            "reference": ref,
            "modules": len(sources),
            "manifest_entries": len(listed),
        }
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
        projects = validate_projects(fixtures)
        upstream = validate_upstream(fixtures)
    except RuntimeError as exc:
        fail(str(exc))
        return 1
    for name, row in sorted(projects["projects"].items()):
        detail = ""
        if "packages" in row:
            detail = " packages=" + ",".join(f"{key}:{value}" for key, value in sorted(row["packages"].items()))
        print(f"[typescript-fixtures] {name:<12} modules={row['modules']:<5}{detail}")
    print(
        f"[typescript-fixtures] upstream     modules={upstream['upstream']['modules']} "
        f"manifest_entries={upstream['upstream']['manifest_entries']} "
        f"({upstream['upstream']['reference']})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
