#!/usr/bin/env python3
"""Apply the x86_64 build fix required by Ultrascan v5.8.0.

Ultrascan v5.8.0 ships aarch64 (Kunpeng KHSEL) source files under
``src/kunpeng-enhanced/`` and adds ``fdr_enhanced.c``, ``runtime_lily.c`` and
``shufti.c`` to the *unconditional* ``hs_exec_SRCS`` list.  Those files use
NEON-only types and intrinsics, so the library does not compile on x86_64 even
though every KHSEL call site is already guarded by ``HAVE_NEON``.

The fix moves exactly those three translation units behind the existing
``HS_TARGET_AARCH64`` switch.  It is a build-portability fix only: on aarch64
(the production target and every official Ultrascan build) the generated build
graph is unchanged.

The script is idempotent, refuses to guess, and prints the patched file digest
so the build stage can record what it compiled.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

KUNPENG_SOURCES = """    src/kunpeng-enhanced/fdr_enhanced.c
    src/kunpeng-enhanced/runtime_lily.c
    src/kunpeng-enhanced/shufti.c
"""
GUARDED_BLOCK = """if (HS_TARGET_AARCH64)
    list(APPEND hs_exec_SRCS
        src/kunpeng-enhanced/fdr_enhanced.c
        src/kunpeng-enhanced/runtime_lily.c
        src/kunpeng-enhanced/shufti.c
    )
endif()

"""
ANCHOR = "set (hs_exec_avx2_SRCS"
MARKER = "if (HS_TARGET_AARCH64)\n    list(APPEND hs_exec_SRCS\n        src/kunpeng-enhanced/fdr_enhanced.c"


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", required=True, type=Path)
    args = parser.parse_args()

    cmake_lists = args.source_dir / "CMakeLists.txt"
    if not cmake_lists.is_file():
        raise SystemExit(f"source tree has no CMakeLists.txt: {args.source_dir}")
    original = cmake_lists.read_text(encoding="utf-8")

    if MARKER in original:
        print("[x86-fix] Kunpeng NEON sources are already arch-guarded; nothing to do")
        print(f"[x86-fix] CMakeLists.txt sha256={digest(original.encode())}")
        return 0

    count = original.count(KUNPENG_SOURCES)
    if count != 1:
        raise SystemExit(
            "unexpected Ultrascan CMakeLists.txt layout: found "
            f"{count} occurrences of the Kunpeng NEON source block"
        )
    if original.count(ANCHOR) != 1:
        raise SystemExit("unexpected Ultrascan CMakeLists.txt layout: anchor not unique")

    patched = original.replace(KUNPENG_SOURCES, "", 1)
    patched = patched.replace(ANCHOR, GUARDED_BLOCK + ANCHOR, 1)
    if patched.count("src/kunpeng-enhanced/shufti.c") != 1:
        raise SystemExit("build fix would duplicate or drop a Kunpeng source entry")

    cmake_lists.write_text(patched, encoding="utf-8")
    print("[x86-fix] moved fdr_enhanced.c/runtime_lily.c/shufti.c behind HS_TARGET_AARCH64")
    print(f"[x86-fix] CMakeLists.txt sha256={digest(patched.encode())}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
