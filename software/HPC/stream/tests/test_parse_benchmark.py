"""STREAM parser regression tests: completeness, identity and strictness."""

import json
import os
import subprocess
import sys
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts/results/parse_benchmark.py"
SPEC = spec_from_file_location("stream_parser", PARSER)
assert SPEC and SPEC.loader
MODULE = module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

ARRAY = 200000000
NTIMES = 10


def kernel_lines(scale: float = 1.0) -> str:
    rows = {
        "Copy": (85000.0, 0.037900, 0.037647, 0.039000),
        "Scale": (84000.0, 0.038000, 0.038095, 0.039000),
        "Add": (90000.0, 0.053500, 0.053333, 0.055000),
        "Triad": (91000.0, 0.052900, 0.052747, 0.054000),
    }
    return "\n".join(
        f"{label}:{value[0] * scale:20.1f} {value[1]:11.6f} {value[2]:12.6f} {value[3]:12.6f}"
        for label, value in rows.items()
    )


def report(
    threads: int = 32,
    array: int = ARRAY,
    ntimes: int = NTIMES,
    scale: float = 1.0,
    missing: str = "",
    failed: bool = False,
    header: bool = True,
    validated: bool = True,
) -> str:
    lines = [
        "-------------------------------------------------------------",
        "STREAM version $Revision: 5.10 $",
        "-------------------------------------------------------------",
        "This system uses 8 bytes per array element.",
        "-------------------------------------------------------------",
        f"Array size = {array} (elements), Offset = 0 (elements)",
        "Memory per array = 1525.9 MiB (= 1.5 GiB).",
        "Total memory required = 4577.6 MiB (= 4.5 GiB).",
        f"Each kernel will be executed {ntimes} times.",
        " The *best* time for each kernel (excluding the first iteration)",
        " will be used to compute the reported bandwidth.",
        "-------------------------------------------------------------",
        f"Number of Threads requested = {threads}",
        f"Number of Threads counted = {threads}",
        "-------------------------------------------------------------",
        "Your clock granularity/precision appears to be 1 microseconds.",
        "-------------------------------------------------------------",
    ]
    if header:
        lines.append("Function    Best Rate MB/s  Avg time     Min time     Max time")
    for line in kernel_lines(scale).splitlines():
        if missing and line.startswith(f"{missing}:"):
            continue
        lines.append(line)
    lines.append("-------------------------------------------------------------")
    if failed:
        lines.append("Failed Validation on array a[], AvgRelAbsErr > epsilon (1.000000e-13)")
    elif validated:
        lines.append("Solution Validates: avg error less than 1.000000e-13 on all three arrays")
    lines.append("-------------------------------------------------------------")
    return "\n".join(lines) + "\n"


def write_reps(root: Path, reps: int, **kwargs) -> Path:
    runs = root / "runs"
    runs.mkdir(parents=True, exist_ok=True)
    for rep in range(1, reps + 1):
        scale = kwargs.pop("scale", None) if rep == 1 else 1.0
        text = report(scale=scale if scale is not None else 1.0, **kwargs)
        (runs / f"rep{rep}.log").write_text(text, encoding="utf-8")
    return runs


def parse(runs: Path, reps: int, env: dict | None = None) -> dict:
    output = runs.parent / "benchmark_stream.json"
    environ = dict(os.environ)
    environ.update({"SOFTWARE_VERSION": "5.10", "EXPECTED_ARCH": "aarch64", "STREAM_VM_VCPUS": "32"})
    if env:
        environ.update(env)
    result = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--runs-dir",
            str(runs),
            "--reps",
            str(reps),
            "--output",
            str(output),
        ],
        text=True,
        capture_output=True,
        env=environ,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return json.loads(output.read_text(encoding="utf-8"))


def test_six_repetitions_produce_eleven_metrics(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6)
    payload = parse(runs, 6)
    results = payload["results"]
    assert len(results) == 11
    assert payload["samples"]["total"] == 6
    assert payload["samples"]["warmup"] == 1
    assert payload["samples"]["measured"] == 5
    assert payload["samples"]["vcpus"] == 32
    assert payload["samples"]["validation_tolerance"] == pytest.approx(1e-13)
    assert set(payload["samples"]["measured_reps"]) == {f"rep{index}" for index in range(2, 7)}
    assert results["stream.triad.best_rate"]["value"] == pytest.approx(91000.0, rel=1e-9)
    assert results["stream.triad.best_rate"]["unit"] == "MB/s"
    assert results["stream.triad.best_rate"]["direction"] == "higher_is_better"
    assert results["stream.copy.avg_time"]["direction"] == "lower_is_better"
    assert results["stream.array.size"]["value"] == ARRAY
    assert results["stream.kernel.iterations"]["value"] == NTIMES
    assert results["stream.threads"]["value"] == 32
    assert sum(1 for name in results if name.endswith(".best_rate")) == 4
    assert sum(1 for name in results if name.endswith(".avg_time")) == 4


def test_warmup_rep_is_excluded_from_the_median(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6, scale=0.5)
    payload = parse(runs, 6)
    # The warm-up run reports half the rate; it must not move the median.
    assert payload["results"]["stream.copy.best_rate"]["value"] == pytest.approx(85000.0, rel=1e-9)


def test_measured_median_uses_the_measured_repetitions(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6)
    (runs / "rep4.log").write_text(report(scale=2.0), encoding="utf-8")
    payload = parse(runs, 6)
    # 5 measured values: 85000, 85000, 170000, 85000, 85000 -> median 85000.
    assert payload["results"]["stream.copy.best_rate"]["value"] == pytest.approx(85000.0, rel=1e-9)


@pytest.mark.parametrize("kwargs", [{"missing": "Triad"}, {"failed": True}, {"header": False}])
def test_incomplete_or_failed_output_is_rejected(tmp_path: Path, kwargs: dict) -> None:
    runs = write_reps(tmp_path, 6, **kwargs)
    with pytest.raises(AssertionError):
        parse(runs, 6)


@pytest.mark.parametrize(
    "kwargs",
    [{"array": 100000000}, {"ntimes": 7}, {"threads": 16}],
)
def test_pinned_configuration_is_enforced(tmp_path: Path, kwargs: dict) -> None:
    runs = write_reps(tmp_path, 6, **kwargs)
    with pytest.raises(AssertionError):
        parse(runs, 6, env={"STREAM_VM_VCPUS": "32"})


def test_missing_repetition_is_rejected(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6)
    (runs / "rep6.log").unlink()
    with pytest.raises(AssertionError):
        parse(runs, 6)


def test_five_repetitions_are_not_enough(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 5)
    with pytest.raises(AssertionError):
        parse(runs, 5)


def test_measured_thread_count_must_match_the_vm(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6)
    with pytest.raises(AssertionError):
        parse(runs, 6, env={"STREAM_VM_VCPUS": "16"})


def test_execution_environment_follows_the_accelerator(tmp_path: Path) -> None:
    runs = write_reps(tmp_path, 6)
    kvm = parse(runs, 6, env={"STREAM_VM_ACCEL_USED": "kvm"})
    assert kvm["parameters"]["execution_environment"] == "kvm-vm"
    assert kvm["parameters"]["accelerator"] == "kvm"
    tcg = parse(runs, 6, env={"STREAM_VM_ACCEL_USED": "qemu", "STREAM_VM_MEM_MIB": "16384"})
    assert tcg["parameters"]["execution_environment"] == "qemu-vm"
    assert tcg["parameters"]["memory_mib"] == "16384"
