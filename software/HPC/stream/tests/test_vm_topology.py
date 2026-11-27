"""Reference-VM topology and libvirt definition tests (no KVM required)."""
import os

import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts/common.sh"


def build_sysfs(
    root: Path,
    node_cpus: dict[str, str],
    siblings: dict[int, str],
) -> tuple[Path, Path]:
    node_root = root / "node"
    cpu_root = root / "cpu"
    for node, cpulist in node_cpus.items():
        target = node_root / f"node{node}"
        (target / "hugepages/hugepages-2048kB").mkdir(parents=True, exist_ok=True)
        (target / "cpulist").write_text(cpulist + "\n", encoding="utf-8")
        (target / "hugepages/hugepages-2048kB/nr_hugepages").write_text("0\n", encoding="utf-8")
        (target / "hugepages/hugepages-2048kB/free_hugepages").write_text("0\n", encoding="utf-8")
    for cpu, sibling_list in siblings.items():
        target = cpu_root / f"cpu{cpu}/topology"
        target.mkdir(parents=True, exist_ok=True)
        (target / "thread_siblings_list").write_text(sibling_list + "\n", encoding="utf-8")
    return node_root, cpu_root


def run_bash(script: str, node_root: Path, cpu_root: Path, env: dict | None = None) -> str:
    assignments = {
        "STREAM_SYSFS_NODE_ROOT": str(node_root),
        "STREAM_SYSFS_CPU_ROOT": str(cpu_root),
    }
    if env:
        assignments.update(env)
    result = subprocess.run(
        ["bash", "-c", f'source "{COMMON}" && {script}'],
        text=True,
        capture_output=True,
        env={**os.environ, **assignments},
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return result.stdout.strip()


# Kunpeng 950 shape: 2 sockets x 96 cores x 2 threads, 4 NUMA nodes of 96 CPUs.
def kunpeng_siblings() -> dict[int, str]:
    siblings = {}
    for cpu in range(384):
        base = cpu - (cpu % 2)
        siblings[cpu] = f"{base}-{base + 1}"
    return siblings


KUNAPENG_NODES = {"0": "0-95", "1": "96-191", "2": "192-287", "3": "288-383"}


def test_numa0_selection_pins_sixteen_cores_and_their_siblings(tmp_path: Path) -> None:
    node_root, cpu_root = build_sysfs(tmp_path, KUNAPENG_NODES, kunpeng_siblings())
    topology = run_bash("stream_select_cpu_topology", node_root, cpu_root)
    cpuset, cores, threads, vcpus = topology.split()
    assert cpuset == "0-31"
    assert (cores, threads, vcpus) == ("16", "2", "32")


def test_selection_follows_the_requested_core_count(tmp_path: Path) -> None:
    node_root, cpu_root = build_sysfs(tmp_path, KUNAPENG_NODES, kunpeng_siblings())
    topology = run_bash("stream_select_cpu_topology", node_root, cpu_root, {"STREAM_VM_TARGET_CORES": "8"})
    assert topology == "0-15 8 2 16"


def test_selection_is_reduced_when_the_node_is_smaller(tmp_path: Path) -> None:
    node_root, cpu_root = build_sysfs(
        tmp_path, {"0": "0-7"}, {cpu: f"{cpu - cpu % 2}-{cpu - cpu % 2 + 1}" for cpu in range(8)}
    )
    topology = run_bash("stream_select_cpu_topology", node_root, cpu_root)
    assert topology == "0-7 4 2 8"


def test_non_smt_hosts_use_one_thread_per_core(tmp_path: Path) -> None:
    node_root, cpu_root = build_sysfs(tmp_path, {"0": "0-19"}, {cpu: str(cpu) for cpu in range(20)})
    topology = run_bash("stream_select_cpu_topology", node_root, cpu_root)
    assert topology == "0-15 16 1 16"


def test_selection_stays_inside_the_requested_numa_node(tmp_path: Path) -> None:
    # Node 1 repeats the CPU numbering of a second socket; nothing from it may leak in.
    node_root, cpu_root = build_sysfs(tmp_path, {"0": "0-3", "1": "4-7"}, {cpu: f"{cpu}" for cpu in range(8)})
    topology = run_bash("stream_select_cpu_topology", node_root, cpu_root, {"STREAM_VM_NUMA_NODE": "1"})
    assert topology == "4-7 4 1 4"


def render_xml(tmp_path: Path, env: dict | None = None) -> ET.Element:
    node_root, cpu_root = build_sysfs(tmp_path, KUNAPENG_NODES, kunpeng_siblings())
    script = (
        "stream_apply_cpu_topology && stream_resolve_accel && stream_resolve_hugepages && "
        "STREAM_VM_NAME=boostkit-stream-aarch64-test STREAM_VM_IP=192.168.122.10 "
        "STREAM_VM_RUN_DIR=/tmp/runs/test STREAM_VM_OVERLAY=/tmp/runs/test/system.qcow2 "
        "STREAM_VM_NVRAM=/tmp/runs/test/nvram.fd emit_stream_vm_xml"
    )
    overrides = {"STREAM_VM_ACCEL": "kvm", "STREAM_VM_HUGEPAGES": "on"}
    overrides.update(env or {})
    return ET.fromstring(run_bash(script, node_root, cpu_root, overrides))


def test_vm_definition_pins_all_vcpus_into_one_numa_node(tmp_path: Path) -> None:
    domain = render_xml(tmp_path)
    assert domain.get("type") == "kvm"
    assert domain.findtext("vcpu") == "32"
    assert domain.findtext("memory") == "131072"
    pins = domain.findall("./cputune/vcpupin")
    assert len(pins) == 32
    assert [pin.get("cpuset") for pin in pins] == [str(cpu) for cpu in range(32)]
    assert domain.find("./cputune/emulatorpin").get("cpuset") == "0-31"
    assert domain.find("./numatune/memory").get("mode") == "strict"
    assert domain.find("./numatune/memory").get("nodeset") == "0"


def test_vm_definition_uses_2m_huge_pages_for_128_gib(tmp_path: Path) -> None:
    domain = render_xml(tmp_path)
    page = domain.find("./memoryBacking/hugepages/page")
    assert page.get("size") == "2048"
    assert page.get("unit") == "KiB"
    assert domain.find("./memoryBacking/source").get("type") == "memfd"
    topology = domain.find("./cpu/topology")
    assert (topology.get("cores"), topology.get("threads")) == ("16", "2")


def test_tcg_profile_drops_the_huge_page_backing(tmp_path: Path) -> None:
    domain = render_xml(tmp_path, {"STREAM_VM_ACCEL": "tcg", "STREAM_VM_HUGEPAGES": "auto"})
    assert domain.get("type") == "qemu"
    assert domain.find("./memoryBacking") is None


def test_huge_page_count_follows_the_memory_size(tmp_path: Path) -> None:
    node_root, cpu_root = build_sysfs(tmp_path, KUNAPENG_NODES, kunpeng_siblings())
    pages = run_bash(
        "stream_apply_cpu_topology && stream_resolve_accel && stream_resolve_hugepages && "
        "printf '%s' \"${STREAM_VM_HUGE_PAGES}\"",
        node_root,
        cpu_root,
        {"STREAM_VM_ACCEL": "kvm", "STREAM_VM_MEM_MIB": "131072"},
    )
    assert pages == "65536"


def test_scripts_do_not_hard_code_cpu_ranges() -> None:
    common = COMMON.read_text(encoding="utf-8")
    assert "cpuset='24-39" not in common
    assert "cpuset='96-127" not in common
    import re

    assert not re.search(r'STREAM_VM_CPUSET="\d', common)
    for path in (CASE_DIR / "scripts").rglob("*.sh"):
        text = path.read_text(encoding="utf-8")
        assert "--cpuset-cpus=0-" not in text, path
        assert "taskset -c 0-" not in text, path


def test_case_runs_in_a_virtual_machine_not_a_container() -> None:
    common = COMMON.read_text(encoding="utf-8")
    build = (CASE_DIR / "scripts/builders/base.sh").read_text(encoding="utf-8")
    test = (CASE_DIR / "scripts/stages/test.sh").read_text(encoding="utf-8")
    stop = (CASE_DIR / "scripts/stages/stop.sh").read_text(encoding="utf-8")
    assert "docker" not in common
    assert "virsh" in common and "hugepages" in common
    assert "start_stream_vm" in build and "verify_stream_guest_os" in build
    assert '-O3 -fopenmp -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE}' in build
    assert "gcc ${compile_flags}" in build
    assert "-mcmodel=large" in build
    assert "./stream_200M" in test
    assert "stop_stream_vm" in stop


def test_guest_toolchain_survives_a_vm_without_network_access() -> None:
    common = COMMON.read_text(encoding="utf-8")
    host_prep = (CASE_DIR / "scripts/host/prepare-vm-host.sh").read_text(encoding="utf-8")
    # The Runner has been observed with forwarding off: the reference VM then gets a
    # DHCP lease and DNS but every outbound connection times out.
    assert "net.ipv4.ip_forward=1" in host_prep
    assert "guest_has_network" in common
    # Without guest egress the toolchain must come from host-downloaded RPMs, never be skipped.
    assert "install_stream_guest_packages_offline" in common
    assert "dnf download --resolve --alldeps" in common
    assert "--disablerepo=\"*\"" in common
    assert "ERROR: the host has no dnf" in common


def test_aarch64_link_fallback_keeps_the_upstream_flags() -> None:
    build = (CASE_DIR / "scripts/builders/base.sh").read_text(encoding="utf-8")
    parser = (CASE_DIR / "scripts/results/parse_benchmark.py").read_text(encoding="utf-8")
    # The upstream command must be tried first, unmodified.
    assert "compile_flags=\"-O3 -fopenmp -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${STREAM_NTIMES} -mcmodel=large\"" in build
    # aarch64 needs the outline-atomics opt-out because of the 4.8 GiB .bss.
    assert "-mno-outline-atomics" in build
    assert "aarch64|arm64)" in build
    assert "compile_extra_flags" in build
    # The actually used flags are surfaced in the result, never hard-coded.
    assert "read_build_info" in parser
    assert "compile_flags_upstream" in parser
