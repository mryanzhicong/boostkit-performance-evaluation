"""Check that the generic adapter invokes existing scripts through environment variables."""

import os
import time
from pathlib import Path

from command_adapter import build_environment, run_command
from context import RunContext


def context_for(tmp_path: Path) -> RunContext:
    case_dir = tmp_path / "software" / "AI" / "sample"
    case_dir.mkdir(parents=True)
    script = case_dir / "sample_test.sh"
    script.write_text(
        '#!/usr/bin/env bash\nset -euo pipefail\n'
        'printf \'entrypoint stage=%s\\n\' "${1:-all}"\n'
        'printf \'{"summary":{"qps":42}}\\n\' > "${RESULTS_DIR}/results.json"\n'
        'command -v pip3 > "${RESULTS_DIR}/pip_path.txt"\n'
        'printf \'%s\\n\' "${1:-all}" > "${RESULTS_DIR}/stage.txt"\n',
        encoding="utf-8",
    )
    case = {
        "name": "sample",
        "category": "AI",
        "execution": {
            "type": "command",
            "entrypoint": "sample_test.sh",
            "expected_outputs": ["results.json", "pip_path.txt"],
            "timeout_minutes": 1,
            "environment": {"ITERATIONS": 1},
        },
        "version_overrides": {"1.0": {"environment": {"BUILD_METHOD": "pip"}}},
    }
    return RunContext(
        root=tmp_path,
        case_path=case_dir / "case.yaml",
        case=case,
        category="AI",
        software="sample",
        version="1.0",
        architecture="x86_64",
        run_id="unit-run",
        output_dir=tmp_path / "output",
        work_dir=tmp_path / "work",
    )


def test_environment_contains_architecture_and_case_overrides(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    environment = build_environment(context)
    assert environment["EXPECTED_ARCH"] == "x86_64"
    assert "TARGET_ARCH" not in environment
    assert environment["RESULTS_DIR"] == str(context.output_dir)
    assert environment["PERF_PROCESS_TOKEN"] == "boostkit-perf:unit-run:AI:sample:1.0:x86_64"
    assert environment["ITERATIONS"] == "1"
    assert environment["BUILD_METHOD"] == "pip"


def test_existing_command_streams_and_writes_to_framework_output(tmp_path: Path, capsys) -> None:
    context = context_for(tmp_path)
    result = run_command(context)
    assert result.returncode == 0
    assert result.missing_outputs == ()
    assert "entrypoint stage=all" in capsys.readouterr().out
    assert "entrypoint stage=all" in result.log_path.read_text(encoding="utf-8")
    assert (context.output_dir / "results.json").is_file()
    pip_path = (context.output_dir / "pip_path.txt").read_text(encoding="utf-8").strip()
    assert pip_path.startswith(str(context.work_dir / "venv" / "bin"))


def test_stage_is_forwarded_to_existing_entrypoint(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    result = run_command(context, "build", check_outputs=False)
    assert result.returncode == 0
    assert result.log_path.name == "command-build.log"
    assert (context.output_dir / "stage.txt").read_text(encoding="utf-8").strip() == "build"


def test_timeout_terminates_the_entire_stage_process_group(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    context.case["execution"]["timeout_minutes"] = 0.01
    entrypoint = context.case_dir / "sample_test.sh"
    entrypoint.write_text(
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        "sleep 30 &\n"
        "printf '%s\\n' \"$!\" > \"${RESULTS_DIR}/child.pid\"\n"
        "wait\n",
        encoding="utf-8",
    )
    result = run_command(context, "test", check_outputs=False)
    assert result.returncode == 124
    assert "[TIMEOUT]" in result.log_path.read_text(encoding="utf-8")

    child_pid = int((context.output_dir / "child.pid").read_text(encoding="utf-8"))
    for _ in range(20):
        try:
            os.kill(child_pid, 0)
        except ProcessLookupError:
            break
        time.sleep(0.05)
    else:
        raise AssertionError(f"stage child process {child_pid} survived timeout")
