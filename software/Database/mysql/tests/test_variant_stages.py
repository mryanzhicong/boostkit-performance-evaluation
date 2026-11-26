"""Contract tests for the mysql variant-aware stage split."""

from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path

import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
RESULTS_DIR = SCRIPT_DIR / "results"


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_mysql",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_mysql_service",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_mysql_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_mysql_service",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


def test_stage_scripts_do_not_depend_on_builder_only_functions() -> None:
    """Framework stages run standalone; they must not call builder-only helpers."""
    builder_functions: set[str] = set()
    for builder in sorted((SCRIPT_DIR / "builders").glob("*.sh")):
        builder_functions.update(
            re.findall(r"^([a-z_]+)\(\)", builder.read_text(encoding="utf-8"), re.MULTILINE)
        )
    assert builder_functions
    for stage in sorted((SCRIPT_DIR / "stages").glob("*.sh")):
        content = stage.read_text(encoding="utf-8")
        referenced = {
            name for name in builder_functions if re.search(rf"\b{name}\b", content)
        }
        assert not referenced, f"{stage.name} references builder-only functions: {referenced}"


def test_optimized_build_refuses_architectures_without_a_vendor_package(
    tmp_path: Path,
) -> None:
    """BoostKit publishes the optimized package for aarch64 only."""
    result = subprocess.run(
        [
            "bash",
            "-c",
            'uname() { printf "x86_64\\n"; }\n'
            'source "$1"\n'
            "build_mysql",
            "bash",
            str(SCRIPT_DIR / "builders" / "dispatch.sh"),
        ],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "PERF_WORK_DIR": str(tmp_path),
            "RESULTS_DIR": str(tmp_path / "results"),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 30
    assert "is published for aarch64 only" in result.stdout
    assert not (tmp_path / "mysql").exists()
    assert not (tmp_path / "mysql-source.txt").exists()


def test_optimized_start_rejects_a_tampered_artifact_record(
    tmp_path: Path,
) -> None:
    """A swapped package must fail before the benchmark server starts."""
    (tmp_path / "mysql-source.txt").write_text(
        "variant=optimized\n"
        "artifact=BoostDB-Percona-8.0.43-34.aarch64.rpm\n"
        f"artifact_sha256={'0' * 64}\n"
        "artifact_version=8.0.43\n"
        "artifact_release=34\n"
        "release=26.2\n"
        "architecture=aarch64\n"
        f"mysqld_sha256={'0' * 64}\n",
        encoding="utf-8",
    )
    result = subprocess.run(
        [
            "bash",
            "-c",
            'uname() { printf "aarch64\\n"; }\n'
            'source "$1"\n'
            "configure_runtime_paths\n"
            "mysql_load_expected_artifact",
            "bash",
            str(SCRIPT_DIR / "builders" / "dispatch.sh"),
        ],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "EXPECTED_ARCH": "aarch64",
            "PERF_WORK_DIR": str(tmp_path),
            "RESULTS_DIR": str(tmp_path / "results"),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 30
    assert "does not describe" in result.stdout


def test_start_and_test_stages_verify_the_deployed_artifact() -> None:
    for stage in ("start.sh", "test.sh"):
        content = (SCRIPT_DIR / "stages" / stage).read_text(encoding="utf-8")
        assert "mysql_verify_installed_artifact" in content, stage
    common = (SCRIPT_DIR / "common.sh").read_text(encoding="utf-8")
    assert "mysql_load_expected_artifact" in common
    assert "MYSQL_SOURCE_RECORD" in common


def test_optimized_scripts_do_not_touch_os_or_bios_state() -> None:
    """The optimized variant changes user space only, never the host."""
    forbidden = re.compile(
        r"\b(?:sysctl|cpupower|tuned-adm|governor|irqbalance|dmidecode|wrmsr|msr|setpci)\b"
        r"|/proc/sys|/sys/|transparent_hugepage|--privileged\b|--cap-add\b|--sysctl\b"
    )
    for name in ("optimized.sh", "dispatch.sh"):
        path = SCRIPT_DIR / "builders" / name
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            assert not forbidden.search(line), f"{path.name}:{number}: {line}"


def test_case_declares_both_mysql_sources() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    tools = case["test_tools"]
    assert tools["mysql_base"]["version"] == "8.0.43"
    assert tools["mysql_optimized"]["version"] == "8.0.43-34"
    assert tools["mysql_optimized"]["revision"] == "BoostDB-Percona-8.0.43-34.aarch64"
    for name, entry in tools.items():
        assert set(entry) == {"version", "revision"}, name


def test_collect_sysbench_reports_the_artifact_only_for_optimized(
    tmp_path: Path,
) -> None:
    runs_dir = tmp_path / "sysbench-runs"
    runs_dir.mkdir()
    for scenario in ("read_only", "read_write", "write_only"):
        for threads in (1, 32, 128, 256):
            (runs_dir / f"run-{scenario}-threads{threads}.log").write_text(
                "transactions: 120 (12.00 per sec.)\n"
                "queries: 240 (24.00 per sec.)\n"
                "Latency (ms):\n"
                "    95th percentile: 3.14\n",
                encoding="utf-8",
            )
    artifact = {
        "MYSQL_ARTIFACT_NAME": "BoostDB-Percona-8.0.43-34.aarch64.rpm",
        "MYSQL_ARTIFACT_SHA256": "ab" * 32,
        "MYSQL_ARTIFACT_RELEASE": "26.2",
        "MYSQL_ARTIFACT_SOURCE": "https://gitcode.com/boostkit/boostdb",
    }
    documents = {}
    for variant in ("base", "optimized"):
        output = tmp_path / f"results-{variant}.json"
        result = subprocess.run(
            [
                "python3",
                str(RESULTS_DIR / "collect_sysbench.py"),
                str(runs_dir),
                str(output),
            ],
            env={
                **os.environ,
                "SOFTWARE_VERSION": "8.0.43",
                "EXPECTED_ARCH": "aarch64",
                "PERF_VARIANT": variant,
                **({} if variant == "base" else artifact),
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        documents[variant] = json.loads(output.read_text(encoding="utf-8"))
    assert "artifact" not in documents["base"]
    assert documents["optimized"]["artifact"] == {
        "name": artifact["MYSQL_ARTIFACT_NAME"],
        "sha256": artifact["MYSQL_ARTIFACT_SHA256"],
        "release": artifact["MYSQL_ARTIFACT_RELEASE"],
        "source_url": artifact["MYSQL_ARTIFACT_SOURCE"],
    }
    assert documents["base"]["results"] == documents["optimized"]["results"]


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "mysql_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        runs_dir = tmp_path / f"sysbench-runs-{architecture}"
        runs_dir.mkdir()
        for scenario in ("read_only", "read_write", "write_only"):
            for threads in (1, 32, 128, 256):
                (runs_dir / f"run-{scenario}-threads{threads}.log").write_text(
                    "transactions: 120 (12.00 per sec.)\n"
                    "queries: 240 (24.00 per sec.)\n"
                    "Latency (ms):\n    95th percentile: 3.14\n",
                    encoding="utf-8",
                )
        output = tmp_path / f"results-{architecture}.json"
        result = subprocess.run(
            [
                "python3",
                str(RESULTS_DIR / "collect_sysbench.py"),
                str(runs_dir),
                str(output),
            ],
            env={
                **os.environ,
                "SOFTWARE_VERSION": "8.0.43",
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        normalized = json.loads(output.read_text(encoding="utf-8"))
        assert normalized["variant"] == "base"
        assert len(normalized["results"]) == 36
        parameters.append(normalized["parameters"])
    assert parameters[0] == parameters[1]
    assert not any(
        "boostkit-perf" in json.dumps(parameter) for parameter in parameters
    )
