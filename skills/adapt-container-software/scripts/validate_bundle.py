#!/usr/bin/env python3
"""Check this portable skill bundle's local structure and relative links.

This is a packaging check, not a Docker or benchmark validation.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
REQUIRED = (
    "SKILL.md",
    "assets/适配记录模板.md",
    "references/deployment.md",
    "references/container-lifecycle.md",
    "references/framework-and-results.md",
    "references/verification.md",
    "scripts/check_adapter.py",
    "scripts/validate_bundle.py",
)
LINK = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")


def main() -> int:
    errors: list[str] = []
    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            errors.append(f"missing: {relative}")

    for document in ROOT.rglob("*.md"):
        text = document.read_text(encoding="utf-8")
        if "/root/adapt-container-software" in text:
            errors.append(f"hard-coded skill location: {document.relative_to(ROOT)}")
        for target in LINK.findall(text):
            if "://" in target or target.startswith("#"):
                continue
            path = target.split("#", 1)[0]
            if not path or not (document.parent / path).is_file():
                errors.append(f"broken link in {document.relative_to(ROOT)}: {target}")

    if errors:
        for error in errors:
            print(f"[bundle] ERROR: {error}", file=sys.stderr)
        return 1
    print(f"[bundle] portable skill structure OK: {ROOT}")
    print("[bundle] Docker, Runner and benchmark behavior still require runtime checks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
