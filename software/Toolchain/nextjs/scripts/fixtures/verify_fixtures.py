#!/usr/bin/env python3
"""Prove that the committed Next.js case fixtures are exactly what the case expects.

Checks:
* fixtures/projects.json describes exactly the four generated projects, with the
  documented source file counts, expected HTML page counts and 64 character tree
  digests;
* regenerating the matrix into a temporary directory reproduces those digests
  byte for byte (the generator is deterministic);
* fixtures/upstream/manifest.sha256 lists every committed upstream file with its
  SHA-256, and no unlisted file exists;
* the upstream example is the official vercel/next.js example for the pinned tag
  and its dependency versions match the case;
* fixtures/dependencies/package.json pins exactly the dependency set the case
  records, and the lockfile is a v3 lockfile that contains the platform specific
  Next.js native packages for both target architectures.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

EXPECTED_PROJECTS = {
    "static_1000": {"source_files": 5, "expected_html_pages": 1005},
    "static_3000": {"source_files": 5, "expected_html_pages": 3005},
    "dynamic_500": {"source_files": 6, "expected_html_pages": 5},
    "routes_500": {"source_files": 504, "expected_html_pages": 505},
}
EXPECTED_DEPENDENCIES = {
    "next": "16.4.3",
    "react": "19.3.1",
    "react-dom": "19.3.1",
}
EXPECTED_DEV_DEPENDENCIES = {
    "@types/node": "22.20.5",
    "@types/react": "19.3.0",
    "@types/react-dom": "19.3.0",
    "typescript": "5.9.3",
}
EXPECTED_SWC_PACKAGES = {
    "@next/swc-linux-x64-gnu",
    "@next/swc-linux-arm64-gnu",
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fail(message: str) -> int:
    print(f"[nextjs-fixtures] ERROR: {message}", flush=True)
    return 1


def check_projects(case_dir: Path) -> int:
    path = case_dir / "fixtures" / "projects.json"
    if not path.is_file():
        return fail(f"missing {path}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    projects = payload.get("projects", {})
    if set(projects) != set(EXPECTED_PROJECTS):
        return fail(
            f"projects.json describes {sorted(projects)}, expected {sorted(EXPECTED_PROJECTS)}"
        )
    for name, expected in EXPECTED_PROJECTS.items():
        entry = projects[name]
        digest = entry.get("digest", "")
        if not isinstance(digest, str) or len(digest) != 64:
            return fail(f"project {name} has an invalid tree digest")
        if int(entry.get("source_files", -1)) != expected["source_files"]:
            return fail(f"project {name} source_files mismatch")
        if int(entry.get("expected_html_pages", -1)) != expected["expected_html_pages"]:
            return fail(f"project {name} expected_html_pages mismatch")
    with tempfile.TemporaryDirectory() as temporary:
        summary_path = Path(temporary) / "summary.json"
        result = subprocess.run(
            [
                sys.executable,
                str(case_dir / "scripts" / "fixtures" / "generate_projects.py"),
                "--output",
                str(Path(temporary) / "projects"),
                "--summary",
                str(summary_path),
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            return fail(f"the generator failed: {result.stderr.strip()}")
        regenerated = json.loads(summary_path.read_text(encoding="utf-8"))["projects"]
        for name, entry in projects.items():
            if regenerated[name]["digest"] != entry["digest"]:
                return fail(f"regenerated project {name} differs from fixtures/projects.json")
    print(f"[nextjs-fixtures] 4 generated projects reproduce their digests", flush=True)
    return 0


def check_upstream(case_dir: Path) -> int:
    directory = case_dir / "fixtures" / "upstream"
    manifest_path = directory / "manifest.sha256"
    if not manifest_path.is_file():
        return fail(f"missing {manifest_path}")
    listed: set[str] = set()
    for line in manifest_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        digest, _, relative = line.partition("  ")
        target = directory / relative
        if not target.is_file():
            return fail(f"manifest lists a missing file: {relative}")
        if sha256_file(target) != digest:
            return fail(f"checksum mismatch for upstream file: {relative}")
        listed.add(relative)
    committed = {
        path.relative_to(directory).as_posix()
        for path in directory.rglob("*")
        if path.is_file() and path.name != "manifest.sha256"
    }
    extra = committed - listed
    if extra:
        return fail(f"upstream files missing from the manifest: {sorted(extra)}")
    reference = directory / "ref.txt"
    if not reference.is_file():
        return fail("the upstream fixture does not document its origin")
    text = reference.read_text(encoding="utf-8")
    if "vercel/next.js" not in text or "v16.4.3" not in text or "MIT" not in text:
        return fail("ref.txt does not document the upstream project, tag and license")
    requirements = directory / "requirements.txt"
    if requirements.is_file():
        return fail("the upstream fixture must not depend on runtime downloads")
    print(f"[nextjs-fixtures] {len(listed)} upstream files match manifest.sha256", flush=True)
    return 0


def check_dependencies(case_dir: Path) -> int:
    directory = case_dir / "fixtures" / "dependencies"
    manifest_path = directory / "package.json"
    lockfile_path = directory / "package-lock.json"
    if not manifest_path.is_file() or not lockfile_path.is_file():
        return fail("the committed dependency manifest or lockfile is missing")
    package = json.loads(manifest_path.read_text(encoding="utf-8"))
    if package.get("dependencies") != EXPECTED_DEPENDENCIES:
        return fail(f"dependency manifest pins {package.get('dependencies')}")
    if package.get("devDependencies") != EXPECTED_DEV_DEPENDENCIES:
        return fail(f"dependency manifest dev dependencies are {package.get('devDependencies')}")
    lockfile = json.loads(lockfile_path.read_text(encoding="utf-8"))
    if int(lockfile.get("lockfileVersion", 0)) != 3:
        return fail("the lockfile is not a v3 lockfile")
    packages = lockfile.get("packages", {})
    missing = [
        name
        for name in EXPECTED_SWC_PACKAGES
        if f"node_modules/{name}" not in packages
    ]
    if missing:
        return fail(f"the lockfile has no entry for the native packages: {missing}")
    for name in EXPECTED_DEPENDENCIES:
        entry = packages.get(f"node_modules/{name}", {})
        if entry.get("version") != EXPECTED_DEPENDENCIES[name]:
            return fail(f"the lockfile pins {name} to {entry.get('version')}")
    print(
        f"[nextjs-fixtures] lockfile v3 pins {len(packages)} packages including both "
        f"native Next.js backends",
        flush=True,
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case-dir", type=Path, required=True)
    arguments = parser.parse_args()
    failures = 0
    for check in (check_projects, check_upstream, check_dependencies):
        try:
            failures += check(arguments.case_dir)
        except (OSError, KeyError, ValueError, TypeError) as error:
            failures += fail(f"{check.__name__} raised {error!r}")
    if failures:
        print(f"[nextjs-fixtures] {failures} fixture problem(s)", flush=True)
        return 1
    print("[nextjs-fixtures] all fixtures verified", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
