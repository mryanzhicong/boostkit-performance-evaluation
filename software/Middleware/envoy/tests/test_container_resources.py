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


def test_start_script_passes_quota_and_verifies_it() -> None:
    text = (ENVOY_DIR / "scripts/stages/start.sh").read_text(encoding="utf-8")
    assert '"--cpus=${ENVOY_CONTAINER_CPUS}"' in text
    assert '"--cpuset-cpus=${cpu_set}"' in text
    assert '"--cpuset-mems=${numa_node}"' in text
    assert '"--memory=${ENVOY_CONTAINER_MEMORY}"' in text
    assert '"--memory-swap=${ENVOY_CONTAINER_MEMORY}"' in text
    assert "swap_limit=\"$(docker info --format '{{.SwapLimit}}'" in text
    assert 'verify_envoy_container_resources "${cpu_set}" "${numa_node}" "${expect_swap}"' in text
