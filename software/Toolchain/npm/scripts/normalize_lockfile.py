#!/usr/bin/env python3
"""Point every resolved URL of a lockfile at the configured registry origin.

npm 12 satisfies an offline install from the cache only when the URL it requests
is byte-identical to the URL that warmed the cache.  The fixtures keep the
registry URLs they were generated from, so the materialisation step rewrites the
origin (scheme + host + optional path prefix) to the registry configured for the
current run.  Only the origin changes: package paths, versions and every
integrity hash stay untouched, so the downloaded artifacts are still verified
against the hashes the lockfile declares.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

HTTP_SCHEMES = ("http", "https")


def fail(message: str) -> None:
    print(f"[npm-lockfile] ERROR: {message}", file=sys.stderr)


def tarball_suffix(parts) -> str:
    """Return the registry-relative path of a tarball URL.

    Registry URLs come in several shapes: ``/vary/-/vary-1.1.2.tgz``,
    ``/@babel/core/-/core-7.28.4.tgz`` and mirror-specific prefixes such as
    ``/repository/npm/vary/-/vary-1.1.2.tgz``.  The package name is the last one
    (or, for a scoped package, the last two) segment before ``/-/``, so the
    suffix can be derived without knowing the mirror prefix.
    """
    segments = parts.path.split("/")
    try:
        marker = segments.index("-")
    except ValueError:
        return parts.path
    if marker < 1:
        return parts.path
    start = marker - 1
    if start >= 2 and segments[start - 1].startswith("@"):
        start -= 1
    suffix = "/" + "/".join(segments[start:])
    if parts.query:
        suffix = f"{suffix}?{parts.query}"
    return suffix


def walk(node: Any, registry: str, counters: dict[str, int]) -> None:
    if not isinstance(node, dict):
        return
    resolved = node.get("resolved")
    if isinstance(resolved, str) and resolved.startswith(HTTP_SCHEMES):
        parts = urlsplit(resolved)
        if resolved.startswith(registry + "/") or resolved == registry:
            counters["unchanged"] += 1
        else:
            rewritten = registry + tarball_suffix(parts)
            if rewritten != resolved:
                node["resolved"] = rewritten
                counters["rewritten"] += 1
            else:
                counters["unchanged"] += 1
    for key in ("dependencies", "packages"):
        children = node.get(key)
        if isinstance(children, dict):
            for child in children.values():
                walk(child, registry, counters)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: normalize_lockfile.py LOCKFILE REGISTRY", file=sys.stderr)
        return 1
    path = Path(sys.argv[1])
    registry = sys.argv[2].rstrip("/")
    parts = urlsplit(registry)
    if parts.scheme not in HTTP_SCHEMES or not parts.netloc:
        fail(f"invalid registry URL: {registry}")
        return 1
    if not path.is_file():
        fail(f"lockfile does not exist: {path}")
        return 1
    try:
        lock = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read lockfile {path}: {exc}")
        return 1
    if not isinstance(lock, dict):
        fail(f"lockfile root must be a JSON object: {path}")
        return 1
    counters = {"rewritten": 0, "unchanged": 0}
    walk(lock, registry, counters)
    if counters["rewritten"]:
        path.write_text(json.dumps(lock, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"[npm-lockfile] {path.name}: {counters['rewritten']} rewritten, "
        f"{counters['unchanged']} already on {registry}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
