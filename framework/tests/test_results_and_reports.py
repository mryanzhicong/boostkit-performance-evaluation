"""Verify normalization and cross-architecture direction semantics."""

import os
import subprocess
import sys
from pathlib import Path

import collect_environment
from build_info import (
    BuildInfoError,
    actual_version_path,
    load_build_info,
    record_build_info,
    reset_build_info,
)
from context import RunContext
from generate_comparison import compare_pair, generate
from json_helper import atomic_write_json
from mark_cleanup import mark
from normalize_results import ResultValidationError, normalize, validate_stage_outputs
from prepare_result_history import prepare
from process_scanner import matching_processes, references_root
from reporting import render_comparison, render_single


def normalized_result(architecture: str, higher: float, lower: float) -> dict:
    return {
        "category": "AI",
        "software": "sample",
        "version": "1.0",
        "architecture": architecture,
        "status": "passed",
        "cleanup_status": "passed",
        "build_info": {
            "requested_version": "1.0",
            "actual_version": "1.0",
            "recorded_at": "2026-08-17T00:00:00Z",
        },
        "system_info": {
            "architecture": architecture,
            "cpu_model": "Example CPU",
            "cpu_count": 64,
            "gcc_version": "13.2.1",
            "glibc_version": "glibc 2.38",
        },
        "runtime_before": {
            "memory": "before memory",
            "cpu_governor": "performance",
        },
        "runtime_after": {
            "memory": "after memory",
            "cpu_governor": "performance",
        },
        "parameters": {"benchmark.json": {"iterations": 3}},
        "parameter_signature": "same-parameters",
        "metrics": {
            "throughput": {"value": higher, "unit": "ops/s", "direction": "higher_is_better"},
            "latency": {"value": lower, "unit": "us", "direction": "lower_is_better"},
        },
    }


def record_requested_build(context: RunContext) -> dict:
    context.work_dir.mkdir(parents=True, exist_ok=True)
    actual_version_path(context).write_text(f"{context.version}\n", encoding="utf-8")
    record_build_info(context)
    return load_build_info(context)


def test_environment_collector_includes_gcc_and_glibc_versions(monkeypatch) -> None:
    responses = {
        ("gcc", "-dumpfullversion", "-dumpversion"): "13.2.1",
        ("getconf", "GNU_LIBC_VERSION"): "glibc 2.38",
    }
    monkeypatch.setattr(
        collect_environment,
        "_command",
        lambda args: responses.get(tuple(args), ""),
    )
    system_info = collect_environment.collect_system_info()
    runtime_state = collect_environment.collect_runtime_state()
    assert system_info["gcc_version"] == "13.2.1"
    assert system_info["glibc_version"] == "glibc 2.38"
    assert "cpu_count" in system_info
    assert "memory" not in system_info
    assert "gcc_version" not in runtime_state
    assert set(runtime_state) == {"collected_at", "memory", "cpu_governor"}


def test_normalizer_extracts_metric_from_declared_output_name(tmp_path: Path) -> None:
    output = tmp_path / "output"
    output.mkdir()
    atomic_write_json(
        output / "results.json",
        {"parameters": {"iterations": 3}, "summary": {"qps": 42.5}},
    )
    atomic_write_json(output / "system_info.json", {"cpu_count": 64})
    atomic_write_json(output / "runtime_before.json", {"cpu_governor": "performance"})
    atomic_write_json(output / "runtime_after.json", {"cpu_governor": "performance"})
    case = {
        "execution": {
            "environment": {"ITERATIONS": 1},
        },
        "outputs": {
            "result": {
                "path": "results.json",
                "stage": "test",
                "format": "json",
                "required": True,
            }
        },
        "metrics": {
            "source": "result",
            "definitions": {
                "qps": {
                    "path": "summary.qps",
                    "unit": "queries/s",
                    "direction": "higher_is_better",
                }
            }
        },
    }
    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case=case,
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        run_id="unit-run",
        output_dir=output,
        work_dir=tmp_path / "work",
    )
    build_info = record_requested_build(context)
    result = normalize(context, "passed")
    assert result["build_info"] == build_info
    assert result["system_info"] == {"cpu_count": 64}
    assert result["runtime_before"] == {"cpu_governor": "performance"}
    assert result["runtime_after"] == {"cpu_governor": "performance"}
    assert "environment_before" not in result
    assert "environment_after" not in result
    assert result["metrics"]["qps"]["value"] == 42.5
    assert result["metrics"]["qps"]["direction"] == "higher_is_better"
    assert result["parameters"] == {"result": {"iterations": 3}}
    assert result["sources"]["result"]["summary"]["qps"] == 42.5
    assert len(result["parameter_signature"]) == 64


def test_normalizer_rejects_missing_empty_and_non_numeric_metrics(tmp_path: Path) -> None:
    import pytest

    output = tmp_path / "output"
    output.mkdir()
    case = {
        "execution": {},
        "outputs": {
            "result": {
                "path": "results.json",
                "stage": "test",
                "format": "json",
                "required": True,
            }
        },
        "metrics": {
            "source": "result",
            "definitions": {
                "qps": {
                    "path": "summary.qps",
                    "unit": "queries/s",
                    "direction": "higher_is_better",
                }
            }
        },
    }
    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case=case,
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        run_id="unit-run",
        output_dir=output,
        work_dir=tmp_path / "work",
    )
    record_requested_build(context)

    (output / "results.json").write_text("", encoding="utf-8")
    with pytest.raises(ResultValidationError, match="empty"):
        normalize(context, "passed")
    atomic_write_json(output / "results.json", {"summary": {}})
    with pytest.raises(ResultValidationError, match="path does not exist"):
        normalize(context, "passed")
    atomic_write_json(output / "results.json", {"summary": {"qps": "fast"}})
    with pytest.raises(ResultValidationError, match="must be numeric"):
        normalize(context, "passed")
    (output / "results.json").write_text(
        '{"summary":{"qps":NaN}}\n', encoding="utf-8"
    )
    with pytest.raises(ResultValidationError, match="must be finite"):
        normalize(context, "passed")


def test_metric_can_override_the_default_logical_output_source(tmp_path: Path) -> None:
    output = tmp_path / "output"
    output.mkdir()
    atomic_write_json(output / "primary.json", {"summary": {"qps": 42}})
    atomic_write_json(output / "latency.json", {"summary": {"latency": 1.5}})
    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case={
            "execution": {},
            "outputs": {
                "primary": {
                    "path": "primary.json",
                    "stage": "test",
                    "format": "json",
                    "required": True,
                },
                "latency_result": {
                    "path": "latency.json",
                    "stage": "test",
                    "format": "json",
                    "required": True,
                },
            },
            "metrics": {
                "source": "primary",
                "definitions": {
                    "qps": {
                        "path": "summary.qps",
                        "unit": "ops/s",
                        "direction": "higher_is_better",
                    },
                    "latency": {
                        "source": "latency_result",
                        "path": "summary.latency",
                        "unit": "ms",
                        "direction": "lower_is_better",
                    },
                },
            },
        },
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        run_id="unit-run",
        output_dir=output,
        work_dir=tmp_path / "work",
    )
    record_requested_build(context)
    result = normalize(context, "passed")
    assert result["metrics"]["qps"]["value"] == 42
    assert result["metrics"]["latency"]["value"] == 1.5


def test_framework_owns_and_strictly_validates_build_info(tmp_path: Path) -> None:
    import pytest

    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case={},
        category="AI",
        software="sample",
        version="1.0",
        architecture="aarch64",
        run_id="unit-run",
        output_dir=tmp_path / "output",
        work_dir=tmp_path / "work",
    )
    context.output_dir.mkdir()
    context.work_dir.mkdir()

    with pytest.raises(BuildInfoError, match="did not report"):
        record_build_info(context)

    actual_version_path(context).write_text("2.0\n", encoding="utf-8")
    with pytest.raises(BuildInfoError, match="requested version 1.0, built version 2.0"):
        record_build_info(context)

    actual_version_path(context).write_text("1.0\n", encoding="utf-8")
    path = record_build_info(context)
    payload = load_build_info(context)
    assert path.name == "build_info.json"
    assert payload["software"] == "sample"
    assert payload["requested_version"] == "1.0"
    assert payload["actual_version"] == "1.0"
    assert payload["architecture"] == "aarch64"
    assert "cpu_model" not in payload

    payload["cpu_model"] = "software-owned-value"
    atomic_write_json(path, payload)
    with pytest.raises(BuildInfoError, match="fields must be exactly"):
        load_build_info(context)

    del payload["cpu_model"]
    payload["actual_version"] = "2.0"
    atomic_write_json(path, payload)
    with pytest.raises(BuildInfoError, match="field actual_version"):
        load_build_info(context)

    reset_build_info(context)
    assert not path.exists()
    assert not actual_version_path(context).exists()


def test_stage_output_validation_checks_only_the_completed_stage(tmp_path: Path) -> None:
    import pytest

    context = RunContext(
        root=tmp_path,
        case_path=tmp_path / "case.yaml",
        case={
            "execution": {},
            "outputs": {
                "version": {
                    "path": "version.json",
                    "stage": "build",
                    "format": "json",
                    "required": True,
                },
                "result": {
                    "path": "results.json",
                    "stage": "test",
                    "format": "json",
                    "required": True,
                },
            },
            "metrics": {},
        },
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        run_id="unit-run",
        output_dir=tmp_path / "output",
        work_dir=tmp_path / "work",
    )
    context.output_dir.mkdir()
    atomic_write_json(context.output_dir / "version.json", {"version": "1.0"})
    validate_stage_outputs(context, "build")
    with pytest.raises(ResultValidationError, match="required output result is missing"):
        validate_stage_outputs(context, "test")


def test_comparison_inverts_lower_is_better_and_explains_direction() -> None:
    comparison = compare_pair(
        normalized_result("x86_64", higher=100, lower=20),
        normalized_result("aarch64", higher=120, lower=10),
    )
    assert comparison["metrics"]["throughput"]["relative_performance"] == 1.2
    assert comparison["metrics"]["latency"]["relative_performance"] == 2.0
    markdown = render_comparison(comparison)
    assert "越大越好" in markdown
    assert "越小越好" in markdown
    assert "## 测试环境" in markdown
    environment = markdown.split("## 测试环境", 1)[1]
    assert "### aarch64" not in environment
    assert "### x86_64" not in environment
    assert "| 架构 | 类型 | 项目 | 固定值 | 测试前 | 测试后 |" in environment
    assert "| aarch64 |" in environment
    assert "| x86_64 |" in environment
    assert "Example CPU" in markdown
    assert "13.2.1" in markdown
    assert "glibc 2.38" in markdown


def test_single_report_includes_build_system_and_runtime_environment() -> None:
    markdown = render_single(normalized_result("aarch64", 120, 10))
    assert "## 测试环境" in markdown
    assert markdown.count("| 类型 | 项目 | 固定值 | 测试前 | 测试后 |") == 1
    assert "实际软件版本" in markdown
    assert "Example CPU" in markdown
    assert "GCC 版本" in markdown
    assert "13.2.1" in markdown
    assert "glibc 2.38" in markdown
    assert "测试前" in markdown and "测试后" in markdown
    assert "before memory" in markdown and "after memory" in markdown


def test_comparison_rejects_incompatible_metric_contracts() -> None:
    import pytest

    x86 = normalized_result("x86_64", higher=100, lower=20)
    arm = normalized_result("aarch64", higher=120, lower=10)
    arm["metrics"]["throughput"]["unit"] = "requests/s"
    with pytest.raises(ValueError, match="units differ"):
        compare_pair(x86, arm)

    arm = normalized_result("aarch64", higher=120, lower=10)
    del arm["metrics"]["latency"]
    with pytest.raises(ValueError, match="metric sets differ"):
        compare_pair(x86, arm)


def test_comparison_rejects_different_resolved_workload_parameters() -> None:
    import pytest

    x86 = normalized_result("x86_64", higher=100, lower=20)
    arm = normalized_result("aarch64", higher=120, lower=10)
    arm["parameters"]["benchmark.json"]["iterations"] = 5
    with pytest.raises(ValueError, match="resolved workload parameters differ"):
        compare_pair(x86, arm)


def test_report_generator_pairs_architectures(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    atomic_write_json(
        input_root / "x86" / "normalized_result.json",
        normalized_result("x86_64", 100, 20),
    )
    atomic_write_json(
        input_root / "arm" / "normalized_result.json",
        normalized_result("aarch64", 120, 10),
    )
    summary = generate(input_root, tmp_path / "report")
    assert summary["total"] == 2
    assert summary["comparisons"] == 1
    assert (tmp_path / "report" / "combined-report.md").is_file()
    assert (tmp_path / "report" / "junit.xml").is_file()
    combined = (tmp_path / "report" / "combined-report.md").read_text(encoding="utf-8")
    assert "越大越好" in combined
    assert "越小越好" in combined
    assert "## 测试环境" in combined
    environment = combined.split("## 测试环境", 1)[1].split("## 单架构指标", 1)[0]
    assert "###" not in environment
    assert (
        "| 软件 | 版本 | 架构 | 类型 | 项目 | 固定值 | 测试前 | 测试后 |"
        in environment
    )
    assert "| sample | 1.0 | aarch64 |" in environment
    assert "| sample | 1.0 | x86_64 |" in environment
    assert "Example CPU" in combined
    assert "13.2.1" in combined
    assert "glibc 2.38" in combined
    assert "before memory" in combined
    assert "after memory" in combined
    assert combined.index("### aarch64") < combined.index("### x86_64")
    arm_metrics = combined.split("### aarch64", 1)[1].split("### x86_64", 1)[0]
    x86_metrics = combined.split("### x86_64", 1)[1].split("## 跨架构指标", 1)[0]
    cross_architecture_metrics = combined.split("## 跨架构指标", 1)[1]
    for section in (arm_metrics, x86_metrics, cross_architecture_metrics):
        assert section.index("latency") < section.index("throughput")


def test_single_architecture_metrics_are_visible_in_combined_report(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    atomic_write_json(
        input_root / "arm" / "normalized_result.json",
        normalized_result("aarch64", 120, 10),
    )
    generate(input_root, tmp_path / "report")
    combined = (tmp_path / "report" / "combined-report.md").read_text(encoding="utf-8")
    assert "单架构指标" in combined
    assert "### aarch64" in combined
    assert "### x86_64" not in combined
    assert "120" in combined
    assert "越大越好" in combined


def test_permanent_history_keeps_compact_results_and_updates_dual_arch_baseline(
    tmp_path: Path,
) -> None:
    input_root = tmp_path / "artifacts"
    report_dir = tmp_path / "report"
    output_root = tmp_path / "permanent"
    run_id = "12345-1"
    for folder, architecture, throughput, latency in (
        ("x86", "x86_64", 100, 20),
        ("arm", "aarch64", 120, 10),
    ):
        result = normalized_result(architecture, throughput, latency)
        result.update({"run_id": run_id, "cleanup_status": "passed"})
        result_dir = input_root / folder
        atomic_write_json(result_dir / "normalized_result.json", result)
        atomic_write_json(result_dir / "benchmark.json", {"throughput": throughput})
        (result_dir / "report.md").write_text(f"# {architecture}\n", encoding="utf-8")
        (result_dir / "results.log").write_text("large log\n", encoding="utf-8")
        (result_dir / "results.txt").write_text("duplicate summary\n", encoding="utf-8")

    generate(input_root, report_dir)
    prepared = prepare(
        input_root,
        report_dir,
        output_root,
        run_id=run_id,
        repository="owner/repo",
        source_commit="abc123",
        workflow_url="https://github.example/actions/runs/12345",
        update_baseline=True,
    )
    run_root = output_root / "AI" / "sample" / "1.0" / run_id
    assert prepared == [run_root]
    assert (run_root / "x86_64" / "benchmark.json").is_file()
    assert (run_root / "aarch64" / "normalized_result.json").is_file()
    assert not (run_root / "aarch64" / "results.log").exists()
    assert not (run_root / "aarch64" / "results.txt").exists()
    assert (run_root / "comparison.json").is_file()
    assert (run_root / "combined-report.md").is_file()
    baseline = output_root / "AI" / "sample" / "1.0" / "baseline.json"
    assert baseline.is_file()
    assert '"run_id": "12345-1"' in baseline.read_text(encoding="utf-8")


def test_baseline_update_rejects_a_single_architecture(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    result = normalized_result("aarch64", 120, 10)
    result.update({"run_id": "12345-1", "cleanup_status": "passed"})
    atomic_write_json(input_root / "arm" / "normalized_result.json", result)
    generate(input_root, tmp_path / "report")
    import pytest

    with pytest.raises(ValueError, match="requires both architectures"):
        prepare(
            input_root,
            tmp_path / "report",
            tmp_path / "permanent",
            run_id="12345-1",
            repository="owner/repo",
            source_commit="abc123",
            workflow_url="https://github.example/actions/runs/12345",
            update_baseline=True,
        )


def test_permanent_history_rejects_failed_cleanup(tmp_path: Path) -> None:
    input_root = tmp_path / "artifacts"
    result = normalized_result("aarch64", 120, 10)
    result.update({"run_id": "12345-1", "cleanup_status": "failed"})
    atomic_write_json(input_root / "arm" / "normalized_result.json", result)

    import pytest

    with pytest.raises(ValueError, match="requires passed test and cleanup"):
        prepare(
            input_root,
            tmp_path / "report",
            tmp_path / "permanent",
            run_id="12345-1",
            repository="owner/repo",
            source_commit="abc123",
            workflow_url="https://github.example/actions/runs/12345",
        )


def test_result_history_publisher_creates_an_independent_branch(tmp_path: Path) -> None:
    repository = tmp_path / "repository"
    remote = tmp_path / "remote.git"
    source = tmp_path / "prepared"
    repository.mkdir()
    source.mkdir()

    subprocess.run(["git", "init", "--bare", str(remote)], check=True, capture_output=True)
    subprocess.run(["git", "init", "-b", "main"], cwd=repository, check=True, capture_output=True)
    subprocess.run(
        ["git", "config", "user.name", "Test User"], cwd=repository, check=True
    )
    subprocess.run(
        ["git", "config", "user.email", "test@example.com"], cwd=repository, check=True
    )
    (repository / "main-only.txt").write_text("main branch\n", encoding="utf-8")
    subprocess.run(["git", "add", "main-only.txt"], cwd=repository, check=True)
    subprocess.run(
        ["git", "commit", "-m", "Initial"],
        cwd=repository,
        check=True,
        capture_output=True,
    )
    subprocess.run(
        ["git", "remote", "add", "origin", str(remote)], cwd=repository, check=True
    )

    result_path = source / "Database" / "redis" / "8.0.0" / "12345-1"
    result_path.mkdir(parents=True)
    (source / "README.md").write_text("# Results\n", encoding="utf-8")
    (result_path / "manifest.json").write_text("{}\n", encoding="utf-8")
    publisher = Path(__file__).resolve().parents[1] / "publish_result_history.sh"
    environment = os.environ.copy()
    environment.update({
        "RUNNER_TEMP": str(tmp_path),
        "GITHUB_RUN_ID": "12345",
        "GITHUB_RUN_ATTEMPT": "1",
    })
    subprocess.run(
        ["bash", str(publisher), str(source), "performance-results"],
        cwd=repository,
        env=environment,
        check=True,
        capture_output=True,
        text=True,
    )

    tree = subprocess.run(
        ["git", f"--git-dir={remote}", "ls-tree", "-r", "--name-only", "performance-results"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    assert "Database/redis/8.0.0/12345-1/manifest.json" in tree
    assert "README.md" in tree
    assert "main-only.txt" not in tree
    duplicate = subprocess.run(
        ["bash", str(publisher), str(source), "performance-results"],
        cwd=repository,
        env=environment,
        capture_output=True,
        text=True,
    )
    assert duplicate.returncode == 3
    assert "immutable run already exists" in duplicate.stderr


def test_cleanup_failure_is_persisted(tmp_path: Path) -> None:
    atomic_write_json(tmp_path / "status.json", {"status": "passed", "cleanup_status": "pending"})
    atomic_write_json(tmp_path / "normalized_result.json", {"status": "passed"})
    mark(tmp_path, "failure")
    import json

    status = json.loads((tmp_path / "status.json").read_text(encoding="utf-8"))
    normalized = json.loads((tmp_path / "normalized_result.json").read_text(encoding="utf-8"))
    assert status["exit_code"] == 80
    assert status["cleanup_status"] == "failed"
    assert normalized["failed_stage"] == "cleanup"


def test_report_includes_status_when_execution_has_no_normalized_result(tmp_path: Path) -> None:
    atomic_write_json(tmp_path / "artifacts" / "failed" / "status.json", {
        "category": "AI",
        "software": "sample",
        "version": "1.0",
        "architecture": "x86_64",
        "status": "failed",
        "failed_stage": "architecture_check",
    })
    summary = generate(tmp_path / "artifacts", tmp_path / "report")
    assert summary["total"] == 1
    assert summary["failed"] == 1


def test_process_scanner_does_not_match_its_own_root_argument(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    scanner = Path(__file__).resolve().parents[1] / "process_scanner.py"
    completed = subprocess.run(
        [sys.executable, str(scanner), "--root", str(work_root)],
        check=True,
        capture_output=True,
        text=True,
    )
    assert completed.stdout == ""
    assert references_root(
        b"python3\0worker.py\0/tmp/boostkit-perf/case-work\0",
        Path("/tmp/boostkit-perf"),
    )


def test_process_scanner_finds_real_work_root_process(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    process = subprocess.Popen([
        sys.executable,
        "-c",
        "import time; time.sleep(30)",
        str(work_root / "case-work"),
    ])
    try:
        assert process.pid in matching_processes(work_root)
    finally:
        process.terminate()
        process.wait(timeout=5)


def test_process_scanner_finds_isolated_process_without_root_in_command(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    environment = os.environ.copy()
    environment["PERF_PROCESS_TOKEN"] = "boostkit-perf:old-run:AI:sample:1.0:x86_64"
    process = subprocess.Popen(
        [sys.executable, "-c", "import time; time.sleep(30)"],
        env=environment,
    )
    try:
        assert process.pid in matching_processes(work_root)
    finally:
        process.terminate()
        process.wait(timeout=5)


def test_process_scanner_finds_process_with_work_root_as_cwd(tmp_path: Path) -> None:
    work_root = tmp_path / "boostkit-perf"
    work_root.mkdir()
    process = subprocess.Popen(
        [sys.executable, "-c", "import time; time.sleep(30)"],
        cwd=work_root,
    )
    try:
        assert process.pid in matching_processes(work_root)
    finally:
        process.terminate()
        process.wait(timeout=5)
