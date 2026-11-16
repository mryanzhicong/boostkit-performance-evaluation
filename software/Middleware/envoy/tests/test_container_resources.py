"""Exercise the Envoy 4U8G CPU/NUMA selection without starting a container."""

import os
import subprocess
from pathlib import Path

ENVOY_DIR = Path(__file__).resolve().parents[1]
COMMON = ENVOY_DIR / "scripts" / "common.sh"


def _run(script: str, **overrides: str) -> subprocess.CompletedProcess[str]:
    env = os.environ | {
        "ENVOY_CONTAINER_CPUS": "4",
        "ENVOY_CONTAINER_MEMORY": "8g",
        "ENVOY_CONTAINER_NUMA_NODE": "",
        "ENVOY_CONTAINER_CPU_RESERVED": "4",
    }
    env.update(overrides)
    return subprocess.run(
        ["bash", "-c", f'source "{COMMON}"; {script}'],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )


def test_selects_four_cpus_from_one_numa_node() -> None:
    completed = _run("select_envoy_cpu_set")
    assert completed.returncode == 0, completed.stderr
    fields = completed.stdout.split()
    assert len(fields) in (1, 2), completed.stdout
    cpus = [int(value) for value in fields[0].split(",")]
    assert len(cpus) == 4
    # 0-3 are reserved for host/system work, so the container must not use them.
    assert cpus == [4, 5, 6, 7], cpus
    if len(fields) == 2:
        node = fields[1]
        assert node.isdigit()
        for cpu in cpus:
            assert Path(f"/sys/devices/system/cpu/cpu{cpu}/node{node}").exists()


def test_rejects_non_positive_cpu_count() -> None:
    completed = _run("validate_envoy_container_resources", ENVOY_CONTAINER_CPUS="0")
    assert completed.returncode == 10
    assert "ENVOY_CONTAINER_CPUS" in completed.stdout


def test_rejects_non_gi_b_memory_value() -> None:
    completed = _run("validate_envoy_container_resources", ENVOY_CONTAINER_MEMORY="8192m")
    assert completed.returncode == 10
    assert "ENVOY_CONTAINER_MEMORY" in completed.stdout


def test_rejects_negative_reserved_cpu_count() -> None:
    completed = _run("validate_envoy_container_resources", ENVOY_CONTAINER_CPU_RESERVED="-1")
    assert completed.returncode == 10
    assert "ENVOY_CONTAINER_CPU_RESERVED" in completed.stdout


def test_derives_a_distinct_port_block_from_the_run_id() -> None:
    completed = _run(
        "set_envoy_runtime_ports; "
        'printf "%s %s %s %s %s %s\\n" "$ENVOY_BACKEND_PORT" '
        '"$ENVOY_BACKEND_ADMIN_PORT" "$ENVOY_DIRECT_PORT" '
        '"$ENVOY_DIRECT_ADMIN_PORT" "$ENVOY_PROXY_PORT" '
        '"$ENVOY_PROXY_ADMIN_PORT"',
        PERF_RUN_ID="43789417289-1",
    )
    assert completed.returncode == 0, completed.stderr
    ports = [int(value) for value in completed.stdout.split()]
    assert len(ports) == 6
    assert len(set(ports)) == 6
    assert all(20000 <= port <= 49999 for port in ports)


def test_runtime_uses_the_derived_ports() -> None:
    start = (ENVOY_DIR / "scripts/stages/start.sh").read_text(encoding="utf-8")
    test = (ENVOY_DIR / "scripts/stages/test.sh").read_text(encoding="utf-8")
    assert "set_envoy_runtime_ports" in start
    assert "ports.env" in start
    assert "${ENVOY_DIRECT_PORT}" in start
    assert "${ENVOY_PROXY_PORT}" in start
    assert "ports.env" in test
    assert "${ENVOY_DIRECT_PORT}" in test
    assert "${ENVOY_PROXY_PORT}" in test
    assert "19000" not in start
    assert "19001" not in test


def test_start_script_passes_quota_and_verifies_it() -> None:
    text = (ENVOY_DIR / "scripts/stages/start.sh").read_text(encoding="utf-8")
    assert '"--cpus=${ENVOY_CONTAINER_CPUS}"' in text
    assert '"--cpuset-cpus=${cpu_set}"' in text
    assert '"--cpuset-mems=${numa_node}"' in text
    assert '"--memory=${ENVOY_CONTAINER_MEMORY}"' in text
    assert '"--memory-swap=${ENVOY_CONTAINER_MEMORY}"' in text
    assert "swap_limit=\"$(docker info --format '{{.SwapLimit}}'" in text
    assert 'verify_envoy_container_resources "${cpu_set}" "${numa_node}" "${expect_swap}"' in text
