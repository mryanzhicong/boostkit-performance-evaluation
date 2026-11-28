"""Contract tests for the fio case scaffolding (job file, VM definition, storage)."""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
WORKLOAD = CASE_DIR / "scripts" / "workload.env"

# A volume group name that cannot exist while the tests run: the XML then always
# uses the canonical /dev/<vg>/dataN path instead of a /dev/mapper/... fallback.
TEST_STORAGE_KEY = "fio-contract-test"


def workload() -> dict[str, str]:
    values: dict[str, str] = {}
    pattern = re.compile(r'^\s*:?\s*"\$\{(?P<key>FIO_[A-Z0-9_]+):=(?P<value>[^}]*)\}"')
    for line in WORKLOAD.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match:
            values[match.group("key")] = match.group("value")
    return values


def volume_count() -> int:
    return int(workload()["FIO_LV_COUNT"])


def guest_devices() -> list[str]:
    return [f"vd{chr(ord('b') + index)}" for index in range(volume_count())]


def run_bash(snippet: str, tmp_path: Path) -> str:
    env = {
        "PATH": "/usr/bin:/bin:/usr/sbin:/sbin",
        "RESULTS_DIR": str(tmp_path),
        "PERF_WORK_DIR": str(tmp_path),
        "PERF_RUN_ID": "test-run",
        "SOFTWARE_VERSION": "3.34",
        "EXPECTED_ARCH": "aarch64",
        "FIO_VM_ACCEL": "tcg",
        "FIO_VM_IMAGE": str(tmp_path / "golden.qcow2"),
        "FIO_VM_KEY": str(tmp_path / "id_ed25519"),
        "FIO_STORAGE_ROOT": str(tmp_path / "storage"),
        "FIO_STORAGE_KEY": TEST_STORAGE_KEY,
    }
    script = f'set -o pipefail\nsource "{COMMON}"\nconfigure_runtime_paths\n{snippet}\n'
    result = subprocess.run(
        ["bash", "-c", script],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return result.stdout


def test_workload_profile_is_consistent() -> None:
    values = workload()
    assert values["FIO_NUMJOBS"] == "1"
    assert values["FIO_IODEPTH"] == "1"
    assert values["FIO_RW"] == "randrw"
    assert values["FIO_BLOCK_SIZE"] == "4k"
    assert values["FIO_RWMIXWRITE"] == "30"
    assert values["FIO_RWMIXREAD"] == "70"
    assert values["FIO_RAMP_TIME"] == "300"
    assert values["FIO_RUNTIME"] == "600"
    # one logical volume per fio job: the host creates as many LUNs as there are jobs
    assert values["FIO_LV_COUNT"] == values["FIO_NUMJOBS"]


def test_block_device_list_matches_the_volume_count(tmp_path: Path) -> None:
    out = run_bash("fio_block_devices | tr '\\n' ' '", tmp_path)
    assert out.split() == guest_devices()


def test_job_filename_list_uses_the_requested_volumes(tmp_path: Path) -> None:
    out = run_bash("fio_job_filename_list", tmp_path)
    assert out.strip() == ":".join(f"/dev/{device}" for device in guest_devices())


def test_rendered_job_file_keeps_the_requested_global_block(tmp_path: Path) -> None:
    run_bash("render_fio_job_file >/dev/null", tmp_path)
    rendered = (tmp_path / "randrw_4k.fio").read_text(encoding="utf-8")
    values = workload()
    global_block = rendered.split("[randrw_4k]")[0]
    expected_lines = [
        "[global]",
        "ioengine=libaio",
        "direct=1",
        f"numjobs={values['FIO_NUMJOBS']}",
        "thread",
        f"bs={values['FIO_BLOCK_SIZE']}",
        f"rw={values['FIO_RW']}",
        f"rwmixwrite={values['FIO_RWMIXWRITE']}",
        f"rwmixread={values['FIO_RWMIXREAD']}",
        f"iodepth={values['FIO_IODEPTH']}",
        f"ramp_time={values['FIO_RAMP_TIME']}",
        f"runtime={values['FIO_RUNTIME']}",
        "time_based",
    ]
    assert [line for line in global_block.splitlines() if line.strip()] == expected_lines
    assert "[randrw_4k]" in rendered
    assert "filename=" + ":".join(f"/dev/{device}" for device in guest_devices()) in rendered
    assert "size=100%" in rendered
    assert "group_reporting" in rendered


def test_vm_definition_attaches_one_block_disk_per_volume(tmp_path: Path) -> None:
    out = run_bash(
        "FIO_VM_ACCEL_USED=tcg FIO_VM_VCPUS=4 FIO_VM_MEM_MIB=8192 emit_fio_vm_xml",
        tmp_path,
    )
    sources = re.findall(r"<source dev='/dev/([^']+)'/>", out)
    assert sources == [
        f"{TEST_STORAGE_KEY}-vg/data{index}" for index in range(1, volume_count() + 1)
    ]
    targets = re.findall(r"<target dev='(vd[a-z])' bus='virtio'/>", out)
    assert targets == ["vda", *guest_devices()]
    assert "hugepages" not in out
    assert "numatune" not in out
    assert "<vcpu placement='static'>4</vcpu>" in out
    assert "<memory unit='MiB'>8192</memory>" in out


def test_vm_definition_uses_an_aarch64_loader(tmp_path: Path) -> None:
    out = run_bash(
        "FIO_VM_ACCEL_USED=kvm FIO_VM_VCPUS=4 FIO_VM_MEM_MIB=8192 emit_fio_vm_xml",
        tmp_path,
    )
    assert "<type arch='aarch64' machine='virt'>hvm</type>" in out
    assert "/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw" in out
    assert "host-passthrough" in out


def test_fio_command_runs_inside_the_guest_on_vcpu_zero(tmp_path: Path) -> None:
    test_script = (CASE_DIR / "scripts" / "stages" / "test.sh").read_text(encoding="utf-8")
    assert "taskset -c 0 fio" in test_script
    # the host side must not pin the benchmark to a host CPU range
    common = COMMON.read_text(encoding="utf-8")
    assert not re.search(r"(?m)^\s*(?:sudo\s+)?taskset", common), "the host must not pin the benchmark"


def test_readme_documents_every_metric_and_the_runtime_substitution() -> None:
    readme = (CASE_DIR / "README.md").read_text(encoding="utf-8")
    metric_names = {
        "fio.read.iops",
        "fio.read.bw_mib",
        "fio.read.clat_avg_us",
        "fio.read.clat_p99_us",
        "fio.write.iops",
        "fio.write.bw_mib",
        "fio.write.clat_avg_us",
        "fio.write.clat_p99_us",
        "fio.numjobs",
        "fio.iodepth",
        "fio.block_size_kib",
        "fio.runtime_seconds",
    }
    for name in metric_names:
        assert name in readme, f"README does not document {name}"
    assert "虚拟机" in readme
    assert "容器" in readme


def test_no_container_runtime_is_used() -> None:
    for path in CASE_DIR.rglob("*"):
        if path.is_file() and path.suffix in {".sh", ".py", ".yaml"} and "tests" not in path.parts:
            text = path.read_text(encoding="utf-8", errors="replace")
            assert "docker run" not in text
            assert "podman run" not in text
