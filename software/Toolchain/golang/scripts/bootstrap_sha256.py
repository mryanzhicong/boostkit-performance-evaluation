#!/usr/bin/env python3
"""Look up the official SHA-256 checksum of a Go binary release tarball.

Reads the public go.dev/dl release metadata (JSON) from stdin and prints the
checksum recorded for the requested tarball filename.
"""

from __future__ import annotations

import json
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: bootstrap_sha256.py GO_TARBALL_FILENAME", file=sys.stderr)
        return 1
    filename = sys.argv[1]
    try:
        releases = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        print(
            f"[golang-bootstrap] ERROR: cannot parse go.dev/dl metadata: {exc}",
            file=sys.stderr,
        )
        return 1
    if not isinstance(releases, list):
        print("[golang-bootstrap] ERROR: go.dev/dl metadata is not a list", file=sys.stderr)
        return 1
    for release in releases:
        if not isinstance(release, dict):
            continue
        files = release.get("files")
        if not isinstance(files, list):
            continue
        for file_entry in files:
            if not isinstance(file_entry, dict):
                continue
            if file_entry.get("filename") != filename:
                continue
            sha256 = file_entry.get("sha256")
            if isinstance(sha256, str) and len(sha256) == 64:
                print(sha256)
                return 0
            print(
                f"[golang-bootstrap] ERROR: checksum entry for {filename} is invalid",
                file=sys.stderr,
            )
            return 1
    print(f"[golang-bootstrap] ERROR: {filename} is not listed on go.dev/dl", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
