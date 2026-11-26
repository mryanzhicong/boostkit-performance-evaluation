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
    "assets/优化方案输入表.md",
    "references/optimized-build.md",
    "references/measurement-handoff.md",
    "references/os-bios-boundary.md",
    "references/verification.md",
    "scripts/check_optimized_case.py",
    "scripts/validate_bundle.py",
)
LINK = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)


def main() -> int:
    errors: list[str] = []

    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            errors.append(f"missing: {relative}")

    skill = ROOT / "SKILL.md"
    if skill.is_file():
        match = FRONTMATTER.match(skill.read_text(encoding="utf-8"))
        if not match:
            errors.append("SKILL.md: missing YAML frontmatter")
        else:
            block = match.group(1)
            name = re.search(r"(?m)^name:\s*(\S+)\s*$", block)
            if not name:
                errors.append("SKILL.md: frontmatter has no name")
            elif name.group(1) != ROOT.name:
                errors.append(
                    f"SKILL.md: name {name.group(1)!r} does not match directory {ROOT.name!r}"
                )
            if not re.search(r"(?m)^description:\s*\S", block):
                errors.append("SKILL.md: frontmatter has no description")

    for document in ROOT.rglob("*.md"):
        text = document.read_text(encoding="utf-8")
        if "/root/add-optimized-variant" in text:
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
