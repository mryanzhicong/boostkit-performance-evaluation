"""Contract tests for the native and CinderX-optimized pyperformance variants."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path


PARSER = Path(__file__).resolve().parents[1] / "scripts" / "results" / "parse_benchmark.py"
CASE_DIR = Path(__file__).resolve().parents[1]
CINDERX_HEAD = "1" * 40
CINDERX_TREE = "2" * 40
CINDERX_PARENT = "3" * 40
CINDERX_PARENT_TREE = "4" * 40
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


def run_bash(script: str, environment: dict[str, str]) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bash", "-c", script],
        env={**os.environ, **environment},
        capture_output=True,
        text=True,
        check=False,
    )


def write_source_record(path: Path, *, branch: str = "master", ref: str = "master") -> None:
    path.write_text(
        "\n".join(
            (
                f"ref={ref}",
                f"branch={branch}",
                f"head={CINDERX_HEAD}",
                f"head_tree={CINDERX_TREE}",
                f"parent={CINDERX_PARENT}",
                f"parent_tree={CINDERX_PARENT_TREE}",
                f"range={CINDERX_PARENT}..{CINDERX_HEAD}",
                "",
            )
        ),
        encoding="utf-8",
    )


def write_official_benchmark(path: Path) -> None:
    path.write_text(
        json.dumps(
            {
                "version": "1.0",
                "benchmarks": [
                    {
                        "metadata": {"name": "json_dumps", "unit": "second"},
                        "runs": [{"values": [0.1, 0.2, 0.3]}],
                    }
                ],
            }
        ),
        encoding="utf-8",
    )


def optimized_environment(**overrides: str) -> dict[str, str]:
    environment = {
        "SOFTWARE_VERSION": "3.14.3",
        "PERF_VARIANT": "optimized",
        "EXPECTED_ARCH": "x86_64",
        "PYPERFORMANCE_VERSION": "1.13.0",
        "PYPERFORMANCE_WARMUP": "3",
        "CONFIGURE_OPTIONS": "--enable-optimizations --with-lto",
        "PYTHON_EXPECTED_COMMIT": CINDERX_HEAD,
        "PYTHON_EXPECTED_BRANCH": "master",
        "PYTHON_EXPECTED_TREE": CINDERX_TREE,
        "PYTHON_EXPECTED_PARENT": CINDERX_PARENT,
        "PYTHON_EXPECTED_PARENT_TREE": CINDERX_PARENT_TREE,
        "PYTHON_EXPECTED_RANGE": f"{CINDERX_PARENT}..{CINDERX_HEAD}",
        "CINDERX_REPOSITORY": "https://gitcode.com/openeuler/cinderx.git",
        "CINDERX_REF": "master",
        "CINDERX_BUILD_TYPE": "Release",
        "CINDERX_ENABLE_PGO": "0",
        "CINDERX_ENABLE_LTO": "0",
        "CINDERX_PLUGIN_ENABLE": "1",
        "PYTHONJITAUTO": "auto:2",
    }
    environment.update(overrides)
    return environment


def test_normalizes_all_official_benchmarks_without_a_fixed_name_list(tmp_path):
    official = tmp_path / "benchmark.json"
    normalized = tmp_path / "benchmark_python.json"
    official.write_text(
        json.dumps(
            {
                "version": "1.0",
                "benchmarks": [
                    {
                        "metadata": {"name": name, "unit": "second"},
                        "runs": [{"values": values}],
                    }
                    for name, values in (
                        ("2to3", [1.0, 2.0, 3.0]),
                        ("json_dumps", [0.1, 0.2, 0.3]),
                    )
                ],
            }
        ),
        encoding="utf-8",
    )
    environment = {
        **os.environ,
        "SOFTWARE_VERSION": "3.14.3",
        "PERF_VARIANT": "base",
        "EXPECTED_ARCH": "x86_64",
        "PYPERFORMANCE_VERSION": "1.13.0",
        "PYPERFORMANCE_WARMUP": "3",
        "CONFIGURE_OPTIONS": "--enable-optimizations --with-lto",
    }
    completed = subprocess.run(
        [sys.executable, str(PARSER), str(official), str(normalized)],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    result = json.loads(normalized.read_text(encoding="utf-8"))
    assert list(result["results"]) == ["2to3", "json_dumps"]
    assert result["results"]["json_dumps"]["value"] == 0.2
    assert result["parameters"]["benchmark_group"] == "default"
    assert result["parameters"]["variant"] == "base"
    assert "-b" not in result["parameters"]["command"]


def test_optimized_source_record_round_trip(tmp_path):
    record = tmp_path / "cinderx-source.txt"
    write_source_record(record)
    completed = run_bash(
        f'source "{CASE_DIR}/scripts/common.sh"\n'
        'python_load_expected_source\n'
        'printf "%s\\n" "$PYTHON_EXPECTED_COMMIT" "$PYTHON_EXPECTED_BRANCH" '
        '"$PYTHON_EXPECTED_PARENT" "$PYTHON_EXPECTED_RANGE"',
        {
            "PERF_VARIANT": "optimized",
            "CINDERX_REF": "master",
            "CINDERX_SOURCE_RECORD": str(record),
        },
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert completed.stdout.split() == [
        CINDERX_HEAD,
        "master",
        CINDERX_PARENT,
        f"{CINDERX_PARENT}..{CINDERX_HEAD}",
    ]


def test_optimized_source_record_missing_fails(tmp_path):
    completed = run_bash(
        f'source "{CASE_DIR}/scripts/common.sh"\npython_load_expected_source',
        {
            "PERF_VARIANT": "optimized",
            "CINDERX_REF": "master",
            "CINDERX_SOURCE_RECORD": str(tmp_path / "missing.txt"),
        },
    )
    assert completed.returncode == 30
    assert "source record is missing" in completed.stdout


def test_optimized_source_record_rejects_branch_mismatch(tmp_path):
    record = tmp_path / "cinderx-source.txt"
    write_source_record(record, branch="dev")
    completed = run_bash(
        f'source "{CASE_DIR}/scripts/common.sh"\npython_load_expected_source',
        {
            "PERF_VARIANT": "optimized",
            "CINDERX_REF": "master",
            "CINDERX_SOURCE_RECORD": str(record),
        },
    )
    assert completed.returncode == 30
    assert "branch dev does not match requested master" in completed.stdout


def test_optimized_parser_records_pinned_source(tmp_path):
    official = tmp_path / "benchmark.json"
    normalized = tmp_path / "benchmark_python.json"
    write_official_benchmark(official)
    completed = subprocess.run(
        [sys.executable, str(PARSER), str(official), str(normalized)],
        env={**os.environ, **optimized_environment()},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    result = json.loads(normalized.read_text(encoding="utf-8"))
    cinderx = result["parameters"]["cinderx"]
    assert result["variant"] == "optimized"
    assert cinderx["commit"] == CINDERX_HEAD
    assert cinderx["commit_tree"] == CINDERX_TREE
    assert cinderx["parent_commit"] == CINDERX_PARENT
    assert cinderx["parent_tree"] == CINDERX_PARENT_TREE
    assert cinderx["commit_range"] == f"{CINDERX_PARENT}..{CINDERX_HEAD}"
    assert result["parameters"]["cinderx_build"]["build_type"] == "Release"
    command = result["parameters"]["command"]
    inherit = command[command.index("--inherit-environ") + 1]
    assert "CINDERX_PLUGIN_ENABLE" in inherit
    assert "PYTHONJITAUTO" in inherit


def test_optimized_parser_requires_pinned_commit(tmp_path):
    official = tmp_path / "benchmark.json"
    normalized = tmp_path / "benchmark_python.json"
    write_official_benchmark(official)
    completed = subprocess.run(
        [sys.executable, str(PARSER), str(official), str(normalized)],
        env={**os.environ, **optimized_environment(PYTHON_EXPECTED_COMMIT="")},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 1
    assert "requires PYTHON_EXPECTED_COMMIT" in completed.stderr


def test_optimized_scripts_avoid_base_build_and_os_tuning():
    optimized = (CASE_DIR / "scripts/builders/optimized.sh").read_text(encoding="utf-8")
    assert "build_python_base" not in optimized
    assert "not implemented" not in optimized.lower()
    assert "build_variant.json" in optimized

    sources = (
        CASE_DIR / "scripts/builders/optimized.sh",
        CASE_DIR / "scripts/builders/dispatch.sh",
        CASE_DIR / "scripts/stages/start.sh",
        CASE_DIR / "scripts/stages/test.sh",
    )
    for path in sources:
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            for pattern in OS_BIOS_PATTERNS:
                assert re.search(pattern, line) is None, (
                    f"{path.relative_to(CASE_DIR)}:{number} matches {pattern}: {line}"
                )


def test_optimized_test_stage_uses_system_site_packages_venv():
    test_script = (CASE_DIR / "scripts/stages/test.sh").read_text(encoding="utf-8")
    start_script = (CASE_DIR / "scripts/stages/start.sh").read_text(encoding="utf-8")
    assert "run_python_benchmarks_optimized" in test_script
    assert "pyperformance venv create" in test_script
    assert "include-system-site-packages = true" in test_script
    assert "CINDERX_PLUGIN_ENABLE" in test_script
    assert "python_load_expected_source" in start_script
    assert "import cinderx.jit as jit" in start_script
    assert "jit.is_enabled()" in start_script


def test_dispatch_preserves_an_existing_build_variant():
    dispatch = (CASE_DIR / "scripts/builders/dispatch.sh").read_text(encoding="utf-8")
    assert 'if [[ ! -f "${RESULTS_DIR}/build_variant.json" ]]' in dispatch


def test_standalone_variant_option_rejects_unknown_values():
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "python_test.sh"), "--variant", "invalid"],
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


def test_base_build_dispatch_preserves_private_install_contract(tmp_path):
    fake_bin = tmp_path / "fake-bin"
    fake_bin.mkdir()
    for command, body in {
        "git": (
            '#!/bin/bash\n'
            'destination="${@: -1}"\n'
            'mkdir -p "$destination"\n'
            'printf \'%s\\n\' \'#!/bin/sh\' '
            '\'printf "%s\\n" "$*" > "$FAKE_CONFIGURE_ARGS"\' '
            '> "$destination/configure"\n'
            'chmod +x "$destination/configure"\n'
        ),
        "rpm": "#!/bin/sh\nexit 0\n",
        "sudo": "#!/bin/sh\nexit 0\n",
        "make": (
            '#!/bin/sh\n'
            'if [ "$1" = install ]; then\n'
            '  mkdir -p "$FAKE_INSTALL_DIR/bin"\n'
            '  printf "#!/bin/sh\\nif [ \\"\\$1\\" = --version ]; then '
            'printf \'Python 3.14.3\\\\n\'; fi\\n"'
            ' > "$FAKE_INSTALL_DIR/bin/python3"\n'
            '  chmod +x "$FAKE_INSTALL_DIR/bin/python3"\n'
            'fi\n'
        ),
    }.items():
        executable = fake_bin / command
        executable.write_text(body, encoding="utf-8")
        executable.chmod(0o755)

    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    version_file = work_dir / "actual-version.txt"
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; build_python', "bash",
         str(CASE_DIR / "scripts" / "builders" / "dispatch.sh")],
        env={
            **os.environ,
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "PERF_VARIANT": "base",
            "SOFTWARE_VERSION": "3.14.3",
            "EXPECTED_ARCH": os.uname().machine,
            "PERF_RUN_ID": "test-1",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(results_dir),
            "PERF_ACTUAL_VERSION_FILE": str(version_file),
            "FAKE_INSTALL_DIR": str(work_dir / "cpython-install"),
            "FAKE_CONFIGURE_ARGS": str(tmp_path / "configure-args"),
        },
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert version_file.read_text(encoding="utf-8") == "3.14.3\n"
    assert json.loads((results_dir / "build_variant.json").read_text())["variant"] == "base"
    assert "--enable-optimizations --with-lto" in (tmp_path / "configure-args").read_text()
