#!/usr/bin/env python3
"""Statically check that a case has a real (not stubbed) optimized variant.

This is a structural check only: it cannot prove that the container build or
the benchmark run succeeds. Runtime validation stays on the Runner.

Usage:
    python3 check_optimized_case.py --case software/AI/numpy
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

OS_BIOS_PATTERNS = (
    r"\bsysctl\b",
    r"/proc/sys",
    r"/sys/",
    r"\bcpupower\b",
    r"\btuned-adm\b",
    r"\bgovernor\b",
    r"\birqbalance\b",
    r"transparent_hugepage",
    r"\bhugepages?\b",
    r"\bdmidecode\b",
    r"\bwrmsr\b",
    r"\bmsr\b",
    r"\bsetpci\b",
    r"--privileged\b",
    r"--cap-add\b",
    r"--sysctl\b",
)
STUB_MARKERS = (
    "not supported by this case",
    "is not implemented",
    "not implemented",
)
FUNCTION = re.compile(r"(?m)^([A-Za-z_][A-Za-z0-9_]*)\(\)\s*\{")


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)

    def ok(self, message: str) -> None:
        print(f"[check] OK: {message}")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.is_file() else ""


def executable_lines(text: str) -> list[tuple[int, str]]:
    rows = []
    for number, line in enumerate(text.splitlines(), 1):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        rows.append((number, line))
    return rows


def load_case(case_dir: Path) -> tuple[str, str]:
    """Return (name, case.yaml text); fall back to the directory name."""
    text = read(case_dir / "case.yaml")
    match = re.search(r"(?m)^name:\s*(\S+)\s*$", text)
    name = match.group(1).strip("\"'") if match else case_dir.name
    return name, text


def has_optimized_test_tool(case_text: str, name: str) -> bool:
    return re.search(rf"(?m)^\s*{re.escape(name)}_optimized\s*:", case_text) is not None


def check_case(case_dir: Path) -> Report:
    report = Report()
    name, case_text = load_case(case_dir)
    print(f"[check] case: {case_dir.as_posix()} (name={name})")
    if not case_text:
        report.error("case.yaml is missing or empty")

    optimized = case_dir / "scripts" / "builders" / "optimized.sh"
    if not optimized.is_file():
        report.error("scripts/builders/optimized.sh is missing")
        return report

    body = read(optimized)
    defined = set(FUNCTION.findall(body))
    entry = f"build_{name}_optimized"
    base_entry = f"build_{name}_base"

    if entry not in defined:
        report.error(f"optimized.sh does not define {entry}()")
    else:
        report.ok(f"optimized.sh defines {entry}()")

    if re.search(rf"(?m)(^|[^A-Za-z0-9_]){re.escape(base_entry)}([^A-Za-z0-9_]|$)", body):
        report.error(
            f"optimized.sh references {base_entry}; the optimized build must not "
            "call the base build or depend on its artifacts"
        )
    else:
        report.ok("optimized.sh does not call the base build")

    lowered = body.lower()
    for marker in STUB_MARKERS:
        if marker in lowered:
            report.error(f"optimized.sh still contains the stub marker {marker!r}")
    if re.search(r"(?m)^\s*return\s+10\s*$", body):
        report.warn(
            "optimized.sh contains `return 10`; confirm it is not the old "
            "unsupported-variant sentinel"
        )

    if "build_variant.json" not in body:
        report.error("optimized.sh never writes build_variant.json")
    else:
        report.ok("optimized.sh writes build_variant.json")

    if "write_actual_version" not in body:
        report.warn("optimized.sh does not call write_actual_version")

    sources = [
        optimized,
        case_dir / "scripts" / "stages" / "start.sh",
        case_dir / "scripts" / "stages" / "test.sh",
        case_dir / "scripts" / "builders" / "dispatch.sh",
    ]
    os_bios_hits = 0
    for path in sources:
        if not path.is_file():
            continue
        for number, line in executable_lines(read(path)):
            for pattern in OS_BIOS_PATTERNS:
                if re.search(pattern, line):
                    os_bios_hits += 1
                    report.error(
                        f"{path.relative_to(case_dir).as_posix()}:{number} touches "
                        f"OS/BIOS state via {pattern!r}: {line.strip()}"
                    )
    if not os_bios_hits:
        report.ok("no OS/BIOS tuning patterns in optimized build/stage scripts")

    test_script = read(case_dir / "scripts" / "stages" / "test.sh")
    if not test_script:
        report.warn("scripts/stages/test.sh is missing")
    elif "optimized" not in test_script:
        report.warn(
            "test.sh never mentions the optimized variant; confirm the measurement "
            "command is variant-aware"
        )
    else:
        report.ok("test.sh is variant-aware")

    if case_text:
        if has_optimized_test_tool(case_text, name):
            report.ok(f"case.yaml registers {name}_optimized in test_tools")
        else:
            report.warn(
                f"case.yaml has no {name}_optimized entry in test_tools; the report "
                "cannot name the optimized source revision"
            )

    readme = read(case_dir / "README.md")
    if readme:
        if "optimized" in readme:
            report.ok("README documents the optimized variant")
        else:
            report.warn("README does not mention the optimized variant")
        if "已知限制" not in readme and "限制" not in readme:
            report.warn("README has no limitations section")
    else:
        report.warn("README.md is missing")

    tests_dir = case_dir / "tests"
    if tests_dir.is_dir():
        hits = [
            path
            for path in tests_dir.rglob("test_*.py")
            if "optimized" in read(path) or "EXPECTED_COMMIT" in read(path)
        ]
        if hits:
            report.ok(f"{len(hits)} test file(s) cover the optimized variant")
        else:
            report.warn("no test file mentions the optimized variant or EXPECTED_COMMIT")
    else:
        report.warn("tests/ directory is missing")

    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", required=True, help="case directory, e.g. software/AI/numpy")
    args = parser.parse_args()

    case_dir = Path(args.case).resolve()
    if not case_dir.is_dir():
        print(f"[check] ERROR: {case_dir} is not a directory", file=sys.stderr)
        return 1

    report = check_case(case_dir)
    for warning in report.warnings:
        print(f"[check] WARN: {warning}")
    for error in report.errors:
        print(f"[check] ERROR: {error}", file=sys.stderr)

    print(
        f"[check] summary: {len(report.errors)} error(s), "
        f"{len(report.warnings)} warning(s)"
    )
    print(
        "[check] structural checks only; container build, benchmark run and "
        "formal matrix still require the Runner"
    )
    return 1 if report.errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
