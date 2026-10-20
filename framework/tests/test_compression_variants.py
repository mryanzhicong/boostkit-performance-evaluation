"""Check compression cases keep a safe base/optimized build selection."""

import os
import subprocess

import pytest

from catalog import ROOT, validate_case


@pytest.mark.parametrize("software", ["lz4", "snappy", "zstd"])
def test_compression_variant_dispatch(software, tmp_path):
    case_dir = ROOT / "software" / "HPC" / software
    case, errors = validate_case(case_dir / "case.yaml", ROOT)
    assert errors == []
    assert case is not None
    assert case["execution"]["stages"]["build"]["script"] == "scripts/builders/dispatch.sh"
    assert case["outputs"]["build_variant"]["required"] is True

    work_dir = tmp_path / "work"
    result_dir = tmp_path / "results"
    completed = subprocess.run(
        [
            "bash", "-c", 'source "$1"; "build_$2"', "bash",
            str(case_dir / "scripts" / "builders" / "dispatch.sh"), software,
        ],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "PERF_WORK_DIR": str(work_dir),
            "RESULTS_DIR": str(result_dir),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert f"optimized {software} build is not implemented" in completed.stdout
    assert not work_dir.exists()
    assert not (result_dir / "build_variant.json").exists()


@pytest.mark.parametrize("software", ["lz4", "snappy", "zstd"])
def test_compression_standalone_rejects_unknown_variant(software):
    script = ROOT / "software" / "HPC" / software / f"{software}_test.sh"
    completed = subprocess.run(
        ["bash", str(script), "--variant", "unknown"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


@pytest.mark.parametrize("software,version", [
    ("lz4", "1.9.4"), ("snappy", "1.2.2"), ("zstd", "1.5.7"),
])
@pytest.mark.parametrize("variant", ["base", "optimized"])
def test_compression_default_results_are_separated(software, version, variant, tmp_path):
    common = ROOT / "software" / "HPC" / software / "scripts" / "common.sh"
    completed = subprocess.run(
        [
            "bash", "-c", 'source "$1"; configure_runtime_paths; printf "%s\\n" "$RESULTS_DIR"',
            "bash", str(common),
        ],
        env={
            **os.environ,
            "PERF_VARIANT": variant,
            "PERF_RUN_ID": "unit-test",
            "PERF_WORK_DIR": str(tmp_path),
            "RESULTS_DIR": "",
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    suffix = f"/{version}/optimized/unit-test" if variant == "optimized" else f"/{version}/unit-test"
    assert completed.stdout.strip().endswith(suffix)
