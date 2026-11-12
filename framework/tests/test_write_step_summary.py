"""Keep short reports visible while respecting the step-summary size limit."""

from write_step_summary import main


def test_short_report_keeps_metric_tables(tmp_path, monkeypatch) -> None:
    report = tmp_path / "combined-report.md"
    compact = tmp_path / "combined-report-summary.md"
    summary = tmp_path / "step-summary.md"
    report.write_text("# 报告\n\n| 指标 | 数值 |\n|---|---|\n| QPS | 123 |\n", encoding="utf-8")
    compact.write_text("# 报告\n\n指标明细已省略\n", encoding="utf-8")
    monkeypatch.setenv("GITHUB_STEP_SUMMARY", str(summary))

    assert main(["--report", str(report), "--compact", str(compact),
                 "--limit-bytes", "1024", "--margin-bytes", "16"]) == 0
    assert summary.read_text(encoding="utf-8") == report.read_text(encoding="utf-8")


def test_oversized_report_uses_compact_with_pointer(tmp_path, monkeypatch) -> None:
    report = tmp_path / "combined-report.md"
    compact = tmp_path / "combined-report-summary.md"
    summary = tmp_path / "step-summary.md"
    report.write_text("# 完整报告\n" + "| 指标 | 123 |\n" * 100, encoding="utf-8")
    compact.write_text("# 概览\n", encoding="utf-8")
    monkeypatch.setenv("GITHUB_STEP_SUMMARY", str(summary))

    assert main(["--report", str(report), "--compact", str(compact),
                 "--limit-bytes", "512", "--margin-bytes", "16"]) == 0
    content = summary.read_text(encoding="utf-8")
    assert content.startswith("# 概览\n")
    assert "完整版本见本次运行的 report artifact" in content
    assert "| 指标 | 123 |" not in content
    assert summary.stat().st_size <= 512 - 16


def test_existing_summary_counts_toward_limit(tmp_path, monkeypatch) -> None:
    report = tmp_path / "combined-report.md"
    compact = tmp_path / "combined-report-summary.md"
    summary = tmp_path / "step-summary.md"
    report.write_text("# 完整报告\n" + "指标\n" * 50, encoding="utf-8")
    compact.write_text("# 概览\n", encoding="utf-8")
    summary.write_text("前置摘要\n" + "x" * 300, encoding="utf-8")
    previous = summary.read_text(encoding="utf-8")
    monkeypatch.setenv("GITHUB_STEP_SUMMARY", str(summary))

    assert main(["--report", str(report), "--compact", str(compact),
                 "--limit-bytes", "600", "--margin-bytes", "16"]) == 0
    content = summary.read_text(encoding="utf-8")
    assert content.startswith(previous)
    assert "# 概览" in content
    assert "# 完整报告" not in content
    assert summary.stat().st_size <= 600 - 16
