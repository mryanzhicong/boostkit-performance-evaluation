#!/usr/bin/env python3
"""Append a bounded report to the GitHub Actions step summary.

GitHub aborts step summary uploads larger than 1 MiB::

    $GITHUB_STEP_SUMMARY upload aborted, supports content up to a size of 1024k,
    got 1083k

When that happens the whole summary of the run silently disappears, so a large
case (numpy publishes 1256 metrics) must not be pasted in full.  This helper:

* appends the compact report produced by ``framework/generate_comparison.py``
  (``combined-report-summary.md``) when it exists, otherwise
* appends the full report truncated at a line boundary,
* always keeps the summary file below the limit, counting what earlier steps
  already wrote, and
* states where the complete report can be found.
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

LIMIT_BYTES = 1024 * 1024
DEFAULT_MARGIN_BYTES = 4096
POINTER = (
    "\n> 报告全文 {size} KiB。GitHub Step Summary 上限 1024 KiB，此处为概览；"
    "完整版本见本次运行的 report artifact 与 `performance-results` 分支上的 "
    "`combined-report.md` / `combined-report.json`。\n"
)


def truncate_at_line(text: str, budget: int) -> str:
    """Return the longest prefix of ``text`` that fits into ``budget`` bytes."""
    encoded = text.encode("utf-8")
    if len(encoded) <= budget:
        return text
    kept: list[str] = []
    used = 0
    for line in text.splitlines(keepends=True):
        size = len(line.encode("utf-8"))
        if used + size > budget:
            break
        kept.append(line)
        used += size
    return "".join(kept)


def build_payload(
    report: Path, compact: Path | None, limit: int, margin: int
) -> tuple[str, str]:
    full_text = report.read_text(encoding="utf-8")
    full_size = len(full_text.encode("utf-8"))
    note = POINTER.format(size=f"{full_size / 1024:.0f}")
    if compact is not None and compact.is_file():
        compact_text = compact.read_text(encoding="utf-8")
        if len(compact_text.encode("utf-8")) + len(note.encode("utf-8")) <= limit - margin:
            return compact_text, note
    budget = limit - margin - len(note.encode("utf-8"))
    return truncate_at_line(full_text, max(budget, 0)), note


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", required=True, type=Path,
                        help="full report (combined-report.md)")
    parser.add_argument("--compact", type=Path, default=None,
                        help="compact report for the run page (combined-report-summary.md)")
    parser.add_argument("--limit-bytes", type=int, default=LIMIT_BYTES,
                        help="GitHub step summary limit (default 1 MiB)")
    parser.add_argument("--margin-bytes", type=int, default=DEFAULT_MARGIN_BYTES,
                        help="safety margin kept free in the summary file")
    args = parser.parse_args(argv)

    if not args.report.is_file():
        print(f"write_step_summary: {args.report} is missing", file=sys.stderr)
        return 1

    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        target = Path(summary_path)
        used = target.stat().st_size if target.exists() else 0
    else:
        target = None
        used = 0

    remaining = args.limit_bytes - used
    if remaining <= args.margin_bytes:
        print(
            f"write_step_summary: summary already holds {used} B, no room left; "
            "skipping the report",
            file=sys.stderr,
        )
        return 0

    payload, note = build_payload(
        args.report, args.compact, remaining, args.margin_bytes
    )
    body = payload if payload.endswith("\n") else payload + "\n"
    body += note
    encoded = body.encode("utf-8")
    if len(encoded) > remaining:
        body = truncate_at_line(body, remaining - 1) + "\n"
        encoded = body.encode("utf-8")

    if target is None:
        sys.stdout.write(body)
        sys.stdout.flush()
        print(
            f"write_step_summary: GITHUB_STEP_SUMMARY is unset, wrote {len(encoded)} B to stdout",
            file=sys.stderr,
        )
        return 0

    with target.open("a", encoding="utf-8") as handle:
        handle.write(body)
    total = target.stat().st_size
    print(
        f"write_step_summary: appended {len(encoded)} B, summary now {total} B "
        f"({total / 1024:.1f} KiB of {args.limit_bytes / 1024:.0f} KiB)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
