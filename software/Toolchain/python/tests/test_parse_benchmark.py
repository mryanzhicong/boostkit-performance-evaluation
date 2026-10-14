"""Contract tests for normalizing the complete pyperformance default suite."""

import json
import os
import subprocess
import sys
from pathlib import Path


PARSER = Path(__file__).resolve().parents[1] / "scripts" / "results" / "parse_benchmark.py"
CASE_DIR = Path(__file__).resolve().parents[1]


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


def test_optimized_build_fails_without_running_base_build(tmp_path):
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; build_python', "bash",
         str(CASE_DIR / "scripts" / "builders" / "dispatch.sh")],
        env={**os.environ, "PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 30
    assert "optimized CPython build is not implemented" in completed.stdout
    assert not (tmp_path / "cpython-source").exists()


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
