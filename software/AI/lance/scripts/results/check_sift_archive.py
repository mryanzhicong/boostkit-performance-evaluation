#!/usr/bin/env python3
"""Validate the TexMex SIFT archive before extracting it to this run's directory."""

import sys
import tarfile
from pathlib import PurePosixPath


def check(path: str) -> None:
    found = set()
    with tarfile.open(path, "r:gz") as archive:
        for member in archive:
            parts = PurePosixPath(member.name).parts
            if not parts or parts[0] != "sift" or ".." in parts:
                raise ValueError(f"unsafe path: {member.name}")
            if not (member.isfile() or member.isdir()):
                raise ValueError(f"unsupported member: {member.name}")
            found.add("/".join(parts))
    if not {"sift/sift_base.fvecs", "sift/sift_query.fvecs"}.issubset(found):
        raise ValueError("SIFT base or query vectors are missing")


if __name__ == "__main__":
    try:
        check(sys.argv[1])
    except (IndexError, OSError, ValueError, tarfile.TarError) as exc:
        print(f"[lance] ERROR: invalid SIFT archive: {exc}", file=sys.stderr)
        raise SystemExit(50) from exc
