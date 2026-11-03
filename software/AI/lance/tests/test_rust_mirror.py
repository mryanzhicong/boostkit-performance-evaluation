"""Keep Rust mirrors task-private and available to container commands."""

import os
import subprocess
import tomllib
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"


def test_private_cargo_mirror(tmp_path: Path) -> None:
    environment = os.environ.copy()
    environment["PERF_WORK_DIR"] = str(tmp_path)
    subprocess.run(
        ["bash", "-c", 'source "$1"; prepare_cargo_mirror', "bash", str(SCRIPTS / "builders/base.sh")],
        check=True,
        env=environment,
    )
    config = tomllib.loads((tmp_path / "cargo/config.toml").read_text(encoding="utf-8"))
    assert config["source"]["crates-io"]["replace-with"] == "rsproxy-sparse"
    assert config["source"]["rsproxy-sparse"]["registry"] == "sparse+https://rsproxy.cn/index/"


def test_container_exec_passes_rustup_mirrors(tmp_path: Path) -> None:
    command = """
source "$1"
docker() { printf '%s\\n' "$@"; }
PERF_WORK_DIR="$2"
TMPDIR="$2/tmp"
LANCE_CONTAINER_NAME=test-container
container_exec true
"""
    output = subprocess.check_output(
        ["bash", "-c", command, "bash", str(SCRIPTS / "common.sh"), str(tmp_path)],
        text=True,
    )
    assert "RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup" in output
    assert "RUSTUP_DIST_SERVER=https://rsproxy.cn" in output
    assert f"CARGO_HOME={tmp_path}/cargo" in output


def test_installs_upstream_pinned_toolchain_before_build(tmp_path: Path) -> None:
    source = tmp_path / "source"
    source.mkdir()
    (source / "rust-toolchain.toml").write_text(
        '[toolchain]\nchannel = "1.98.1"\n', encoding="utf-8"
    )
    command = """
source "$1"
LANCE_SOURCE_DIR="$2"
PERF_WORK_DIR="$3"
container_exec() { printf '%s\\n' "$*"; }
install_pinned_rust_toolchain
"""
    output = subprocess.check_output(
        ["bash", "-c", command, "bash", str(SCRIPTS / "builders/base.sh"),
         str(source), str(tmp_path)],
        text=True,
    )
    assert "rustup toolchain install 1.98.1 --profile minimal" in output
    assert "rustc" in output
