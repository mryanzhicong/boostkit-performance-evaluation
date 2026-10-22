"""Verify Folly tags by commit, even when two releases share one commit."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "builders" / "base.sh"


def git(*args: str, cwd: Path) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def test_release_tag_is_accepted_when_an_older_tag_shares_its_commit(tmp_path: Path) -> None:
    source = tmp_path / "upstream"
    source.mkdir()
    git("init", "-q", cwd=source)
    (source / "README").write_text("upstream fixture\n", encoding="utf-8")
    git("add", "README", cwd=source)
    git("-c", "user.name=Test", "-c", "user.email=test@example.com",
        "commit", "-qm", "release", cwd=source)
    git("tag", "v2022.11.07.00", cwd=source)
    git("tag", "v2022.11.14.00", cwd=source)

    work_dir = tmp_path / "work"
    results_dir = tmp_path / "results"
    results_dir.mkdir()
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; configure_runtime_paths; prepare_folly_source',
         "bash", str(SCRIPT)],
        env={**os.environ, "SOFTWARE_VERSION": "2022.11.14.00", "PERF_RUN_ID": "test",
             "PERF_WORK_DIR": str(work_dir), "RESULTS_DIR": str(results_dir),
             "FOLLY_SOURCE_URL": str(source)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (results_dir / "actual-version.txt").read_text(encoding="utf-8") == "2022.11.14.00\n"
