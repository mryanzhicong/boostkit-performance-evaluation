"""Guards for the host network reclamation helper.

The script runs as root against the live host, so the parts that can be checked
without touching iptables are: it parses, it advertises the same modes it
dispatches, and the modes the case calls exist.
"""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
SCRIPT = CASE / "scripts" / "host" / "cleanup-e2b-network.sh"


def test_script_parses() -> None:
    assert SCRIPT.is_file(), SCRIPT
    result = subprocess.run(["bash", "-n", str(SCRIPT)], capture_output=True, text=True)
    assert result.returncode == 0, result.stderr


def test_documented_modes_match_dispatch() -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    usage = re.search(r"usage: \$0 \[([^\]]+)\]", text)
    assert usage, "the usage line is missing"
    documented = [mode.strip() for mode in usage.group(1).split("|")]
    dispatch = re.findall(r"^\s+(--[a-z-]+)\)", text, flags=re.MULTILINE)
    assert sorted(documented) == sorted(dispatch), (documented, dispatch)


def test_case_calls_existing_modes() -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    dispatch = set(re.findall(r"^\s+(--[a-z-]+)\)", text, flags=re.MULTILINE))
    callers = [
        CASE / "scripts" / "stages" / "start.sh",
        CASE / "scripts" / "stages" / "stop.sh",
        CASE / "scripts" / "common.sh",
    ]
    used: set[str] = set()
    for caller in callers:
        used.update(re.findall(r"cleanup_e2b_network\s+(--[a-z-]+)", caller.read_text(encoding="utf-8")))
    assert used, "no stage calls cleanup_e2b_network"
    assert used <= dispatch | {"--stale"}, used - dispatch


def test_helper_is_installed_next_to_the_vendor_script() -> None:
    installer = CASE / "scripts" / "host" / "install-e2b-suite.sh"
    text = installer.read_text(encoding="utf-8")
    assert "cleanup-e2b-network.sh" in text
    assert "E2B_NET_CLEANUP" in text, "the installer must reuse the common.sh path"
