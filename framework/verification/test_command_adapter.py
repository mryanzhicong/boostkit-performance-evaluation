"""Check that the generic adapter invokes existing scripts through environment variables."""

from pathlib import Path

from command_adapter import build_environment, run_command
from context import RunContext


def context_for(tmp_path: Path) -> RunContext:
    case_dir = tmp_path / "software" / "AI" / "sample"
    case_dir.mkdir(parents=True)
    script = case_dir / "sample_test.sh"
    script.write_text(
        '#!/usr/bin/env bash\nset -euo pipefail\n'
        'printf \'{"summary":{"qps":42}}\\n\' > "${RESULTS_DIR}/results.json"\n'
        'command -v pip3 > "${RESULTS_DIR}/pip_path.txt"\n',
        encoding="utf-8",
    )
    case = {
        "name": "sample",
        "category": "AI",
        "execution": {
            "type": "command",
            "entrypoint": "sample_test.sh",
            "expected_outputs": ["results.json", "pip_path.txt"],
        },
        "modes": {"smoke": {"timeout_minutes": 1, "environment": {"ITERATIONS": 1}}},
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
        test_mode="smoke",
        run_id="unit-run",
        output_dir=tmp_path / "output",
        work_dir=tmp_path / "work",
    )


def test_environment_contains_architecture_and_mode_overrides(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    environment = build_environment(context)
    assert environment["EXPECTED_ARCH"] == "x86_64"
    assert environment["RESULTS_DIR"] == str(context.output_dir)
    assert environment["ITERATIONS"] == "1"
    assert environment["BUILD_METHOD"] == "pip"


def test_existing_command_writes_to_framework_output(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    result = run_command(context)
    assert result.returncode == 0
    assert result.missing_outputs == ()
    assert (context.output_dir / "results.json").is_file()
    pip_path = (context.output_dir / "pip_path.txt").read_text(encoding="utf-8").strip()
    assert pip_path.startswith(str(context.work_dir / "venv" / "bin"))
