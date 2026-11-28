#!/usr/bin/env python3
"""Unit tests for the libvirt virsh lifecycle parser."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER_PATH = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"


def load_parser():
    spec = importlib.util.spec_from_file_location("libvirt_lifecycle_parser", PARSER_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def write_rep(
    results_dir: Path,
    rep: int,
    *,
    status: str = "passed",
    start_ms: int = 9000,
    console_ms: int = 1500,
    boot_seconds: float = 12.0,
    flags: tuple[bool, bool, bool] = (True, True, True),
) -> None:
    directory = results_dir / "reps"
    directory.mkdir(parents=True, exist_ok=True)
    payload = {
        "repetition": rep,
        "virsh_start_ms": start_ms,
        "virsh_console_probe_ms": console_ms,
        "guest_boot_observed_seconds": boot_seconds,
        "status": status,
        "virsh_start_ok": flags[0],
        "virsh_list_running_ok": flags[1],
        "virsh_console_ok": flags[2],
    }
    (directory / f"rep{rep}.json").write_text(json.dumps(payload), encoding="utf-8")


def prepare(tmp_path: Path, monkeypatch, *, reps: int = 6, warmup: int = 1) -> tuple[Path, Path]:
    monkeypatch.setenv("LIBVIRT_REPS", str(reps))
    monkeypatch.setenv("LIBVIRT_WARMUP_REPS", str(warmup))
    monkeypatch.setenv("LIBVIRT_VM_CORES", "4")
    monkeypatch.setenv("LIBVIRT_VM_MEM_MIB", "8192")
    monkeypatch.setenv("LIBVIRT_VM_COUNT", "1")
    monkeypatch.setenv("SOFTWARE_VERSION", "22.03-LTS-SP3")
    monkeypatch.setenv("EXPECTED_ARCH", "aarch64")
    output = tmp_path / "benchmark_virsh_lifecycle.json"
    monkeypatch.setattr(
        "sys.argv",
        ["parse_benchmark.py", str(tmp_path), str(output)],
    )
    return tmp_path, output


def test_aggregates_the_measured_repetitions(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    results, output = prepare(tmp_path, monkeypatch)
    for rep in range(1, 7):
        write_rep(results, rep, start_ms=9000 + rep * 100, console_ms=1500 + rep, boot_seconds=10.0 + rep)
    assert parser.main() == 0
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert len(payload["results"]) == 9
    assert payload["results"]["libvirt.virsh_start_ok"]["value"] == 1.0
    # measured repetitions 2..6 -> medians of 9200..9600 is 9400
    assert payload["results"]["libvirt.virsh_start_ms"]["value"] == pytest.approx(9400.0)
    assert payload["results"]["libvirt.measured_reps"]["value"] == 5
    assert payload["results"]["libvirt.vcpus_per_vm"]["value"] == 4
    assert payload["parameters"]["measured_repetitions"] == 5


def test_fails_when_the_console_test_point_fails(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    results, _ = prepare(tmp_path, monkeypatch)
    for rep in range(1, 7):
        write_rep(results, rep, flags=(True, True, rep != 4))
    with pytest.raises(SystemExit, match="virsh_console_ok"):
        parser.main()


def test_fails_when_a_repetition_did_not_pass(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    results, _ = prepare(tmp_path, monkeypatch)
    for rep in range(1, 7):
        status = "failed" if rep == 3 else "passed"
        write_rep(results, rep, status=status)
    with pytest.raises(SystemExit, match="did not pass"):
        parser.main()


def test_fails_when_a_repetition_is_missing(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    results, _ = prepare(tmp_path, monkeypatch)
    for rep in range(1, 6):
        write_rep(results, rep)
    with pytest.raises(SystemExit, match="missing lifecycle repetition report"):
        parser.main()


def test_rejects_non_positive_durations(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    results, _ = prepare(tmp_path, monkeypatch)
    for rep in range(1, 7):
        write_rep(results, rep, start_ms=0 if rep == 2 else 9000)
    with pytest.raises(SystemExit, match="must be positive"):
        parser.main()


def test_rejects_a_reduced_sampling_contract(tmp_path: Path, monkeypatch) -> None:
    parser = load_parser()
    prepare(tmp_path, monkeypatch, reps=5, warmup=1)
    with pytest.raises(SystemExit, match="at least five measured repetitions"):
        parser.main()


def test_workload_contract_defaults() -> None:
    common = (CASE_DIR / "scripts" / "common.sh").read_text(encoding="utf-8")
    assert 'LIBVIRT_VM_CORES="${LIBVIRT_VM_CORES:-4}"' in common
    assert 'LIBVIRT_VM_MEM_MIB="${LIBVIRT_VM_MEM_MIB:-8192}"' in common
    assert "LIBVIRT_REPS - LIBVIRT_WARMUP_REPS >= 5" in common
    assert "numatune" in common and "mode='strict'" in common
    assert '"${version_id}" == "22.03"' in common
    test_stage = (CASE_DIR / "scripts" / "stages" / "test.sh").read_text(encoding="utf-8")
    assert "virsh start" in (CASE_DIR / "README.md").read_text(encoding="utf-8")
    assert "console_libvirt_vm_probe" in test_stage
    env = (CASE_DIR / "scripts" / "host" / "prepare-vm-host.sh").read_text(encoding="utf-8")
    assert "22.03-LTS-SP3" in env
    assert (CASE_DIR / "case.yaml").is_file()
