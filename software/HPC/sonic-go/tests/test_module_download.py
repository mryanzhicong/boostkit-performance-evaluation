"""Verify Go modules are prefetched sequentially through the existing proxy."""

import os
import subprocess
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "sonic_go_test.sh"


def run_download(tmp_path: Path, fail_module: str = "") -> subprocess.CompletedProcess[str]:
    fake_go = tmp_path / "go"
    fake_go.write_text(
        '#!/bin/sh\n'
        'printf "%s %s %s\\n" "$1" "$2" "${3:-}" >> "$CALLS_FILE"\n'
        'if [ -n "$FAIL_MODULE" ] && [ "${3:-}" = "$FAIL_MODULE" ]; then exit 1; fi\n',
        encoding="utf-8",
    )
    fake_go.chmod(0o755)
    source_dir = tmp_path / "source"
    (source_dir / "external_jsonlib_test").mkdir(parents=True)
    (source_dir / "go.sum").write_text(
        "example.com/b v2.0.0 h1:checksum\n"
        "example.com/a v1.0.0/go.mod h1:checksum\n"
        "example.com/a v1.0.0 h1:checksum\n",
        encoding="utf-8",
    )
    (source_dir / "external_jsonlib_test" / "go.sum").write_text(
        "example.com/b v2.0.0 h1:checksum\n",
        encoding="utf-8",
    )
    environment = os.environ | {
        "SONIC_SCRIPT": str(SCRIPT),
        "SOURCE_DIR_TEST": str(source_dir),
        "GO_BIN_TEST": str(fake_go),
        "CALLS_FILE": str(tmp_path / "calls"),
        "FAIL_MODULE": fail_module,
        "https_proxy": "http://proxy.example:8080",
    }
    return subprocess.run(
        [
            "bash", "-c",
            'source "$SONIC_SCRIPT"; SOURCE_DIR="$SOURCE_DIR_TEST"; '
            'GO_BIN="$GO_BIN_TEST"; download_sonic_modules',
        ],
        env=environment,
        capture_output=True,
        text=True,
    )


def test_modules_are_unique_and_downloaded_one_at_a_time(tmp_path: Path) -> None:
    result = run_download(tmp_path)
    assert result.returncode == 0, result.stderr
    assert (tmp_path / "calls").read_text(encoding="utf-8").splitlines() == [
        "mod download example.com/a@v1.0.0",
        "mod download example.com/b@v2.0.0",
        "mod download ",
    ]


def test_failed_module_stops_without_retry(tmp_path: Path) -> None:
    result = run_download(tmp_path, fail_module="example.com/a@v1.0.0")
    assert result.returncode == 40
    assert "failed to download Go module" in result.stdout
    assert (tmp_path / "calls").read_text(encoding="utf-8").splitlines() == [
        "mod download example.com/a@v1.0.0",
    ]
