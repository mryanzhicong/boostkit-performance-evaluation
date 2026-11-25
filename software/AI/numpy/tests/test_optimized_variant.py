"""Checks for the optimized (Kunpeng) variant of the numpy case.

The optimized variant measures the ``master`` tip instead of a pinned commit:

* ``scripts/builders/optimized.sh`` is a full copy of the base builder and adds
  the master clone, the ``HEAD`` / ``HEAD~1`` resolution and the source record;
* ``scripts/common.sh`` turns that record into the expected commit/tree and
  lifts the offline black hole for the ASV invocation that builds the commits;
* ``scripts/stages/test.sh`` runs ``asv run HEAD~1..HEAD`` for the optimized
  variant (asv 0.6.4 refuses a range in an existing environment); the range
  resolves to the measured tip, so ASV builds that commit alone;
* ``scripts/results/parse_benchmark.py`` validates the measured commit against
  ``NUMPY_EXPECTED_COMMIT`` when the build stage exported it.

Nothing here needs Docker, network or a NumPy build: the shell checks exercise
the pure shell helpers and the parser checks reuse the synthetic ASV fixtures.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
BASE = CASE_DIR / "scripts" / "builders" / "base.sh"
OPTIMIZED = CASE_DIR / "scripts" / "builders" / "optimized.sh"
START = CASE_DIR / "scripts" / "stages" / "start.sh"
TEST = CASE_DIR / "scripts" / "stages" / "test.sh"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
README = CASE_DIR / "README.md"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
RESULTS_FIXTURE = FIXTURES / "synthetic_asv_results.json"
IDS_FIXTURE = FIXTURES / "synthetic_ids.txt"

PINNED_COMMIT = "289c872fc2cc3a82a63a66b4c1a32e8ef6e80fb6"
PINNED_TREE = "4011714d5de68c10c60cf6f083c3a49c1de0dfc4"
SUITE_COMMIT = "95422b21eb5b43a2453e45b8531a3dd09c9b61ab"


def defined_functions(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    return set(re.findall(r"(?m)^([A-Za-z_][A-Za-z0-9_]*)\(\)\s*\{", text))


def run_shell(
    script: str, tmp_path: Path, **extra: str
) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "PERF_PROXY": "",
        "TMPDIR": str(tmp_path / "tmp"),
    } | extra
    return subprocess.run(
        ["bash", "-c", script],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )


# ---------------------------------------------------------------------------
# builders and stages
# ---------------------------------------------------------------------------


def test_optimized_builder_keeps_the_base_machinery() -> None:
    """optimized.sh is a copy of base.sh, so every shared step must survive."""
    base = defined_functions(BASE)
    optimized = defined_functions(OPTIMIZED)
    assert {
        "numpy_clone_optimized",
        "numpy_write_source_record",
        "numpy_configure_asv_git",
        "numpy_expose_build_tools",
        "build_numpy_optimized",
    } <= optimized
    # Only the clone step and the entry point changed names.
    renamed = {"numpy_clone_baseline", "build_numpy_base"}
    assert base - renamed <= optimized


def test_optimized_builder_measures_the_master_tip() -> None:
    text = OPTIMIZED.read_text(encoding="utf-8")
    assert "not supported by this case" not in text
    assert 'git clone --branch "${NUMPY_OPTIMIZED_BRANCH}"' in text
    assert "HEAD~1^{commit}" in text and "HEAD~1^{tree}" in text
    assert "numpy_write_source_record || return $?" in text
    assert "protocol.file.allow always" in text
    assert "for tool in patchelf ninja; do" in text
    assert '"/usr/local/bin/${tool}"' in text
    assert "build_numpy_optimized" in text


def test_test_stage_runs_the_range_for_optimized() -> None:
    text = TEST.read_text(encoding="utf-8")
    assert '"${NUMPY_OPTIMIZED_RANGE}"' in text
    # The base variant keeps the existing-environment invocation.
    assert '--set-commit-hash "${NUMPY_EXPECTED_COMMIT}"' in text
    assert 'cp -f "${parent_file}" "${RUNS_DIR}/asv-results-parent.json"' in text


def test_start_stage_verifies_the_recorded_source() -> None:
    text = START.read_text(encoding="utf-8")
    assert "numpy_load_expected_source || return $?" in text
    assert '--set-commit-hash "${NUMPY_EXPECTED_COMMIT}"' in text


# ---------------------------------------------------------------------------
# common.sh: expected source and ASV environment
# ---------------------------------------------------------------------------


def write_record(path: Path, **values: str) -> None:
    order = ("branch", "head", "head_tree", "parent", "parent_tree", "range")
    path.write_text(
        "".join(f"{key}={values[key]}\n" for key in order if key in values),
        encoding="utf-8",
    )


def test_common_resolves_the_recorded_master_tip(tmp_path: Path) -> None:
    record = tmp_path / "numpy-source.txt"
    write_record(
        record,
        branch="master",
        head="a" * 40,
        head_tree="b" * 40,
        parent="c" * 40,
        parent_tree="d" * 40,
        range="HEAD~1..HEAD",
    )
    script = (
        f'source "{COMMON}"; '
        "PERF_VARIANT=optimized; "
        'NUMPY_EXPECTED_COMMIT=""; '
        f'NUMPY_SOURCE_RECORD="{record}"; '
        "numpy_load_expected_source || exit $?; "
        'printf "%s|%s|%s|%s\\n" "${NUMPY_EXPECTED_COMMIT}" '
        '"${NUMPY_EXPECTED_TREE}" "${NUMPY_EXPECTED_BRANCH}" "${NUMPY_EXPECTED_PARENT}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    commit, tree, branch, parent = completed.stdout.strip().split("|")
    assert commit == "a" * 40
    assert tree == "b" * 40
    assert branch == "master"
    assert parent == "c" * 40


def test_common_fails_without_a_source_record(tmp_path: Path) -> None:
    missing = tmp_path / "missing.txt"
    script = (
        f'source "{COMMON}"; '
        "PERF_VARIANT=optimized; "
        'NUMPY_EXPECTED_COMMIT=""; '
        f'NUMPY_SOURCE_RECORD="{missing}"; '
        "numpy_load_expected_source"
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 30
    output = completed.stdout + completed.stderr
    assert "build stage must run first" in output


def test_common_rejects_a_record_from_another_branch(tmp_path: Path) -> None:
    record = tmp_path / "numpy-source.txt"
    write_record(
        record,
        branch="dev",
        head="a" * 40,
        head_tree="b" * 40,
        parent="c" * 40,
        parent_tree="d" * 40,
        range="HEAD~1..HEAD",
    )
    script = (
        f'source "{COMMON}"; '
        "PERF_VARIANT=optimized; "
        'NUMPY_EXPECTED_COMMIT=""; '
        f'NUMPY_SOURCE_RECORD="{record}"; '
        "numpy_load_expected_source"
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 30
    assert "expected master" in completed.stdout + completed.stderr


def test_base_variant_still_uses_the_pinned_commit(tmp_path: Path) -> None:
    script = (
        f'source "{COMMON}"; '
        'PERF_VARIANT=base; '
        'NUMPY_EXPECTED_COMMIT=""; '
        "numpy_load_expected_source; "
        'printf "%s|%s|%s\\n" "${NUMPY_EXPECTED_COMMIT}" '
        '"${NUMPY_EXPECTED_TREE}" "${NUMPY_EXPECTED_BRANCH}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    commit, tree, branch = completed.stdout.strip().split("|")
    assert commit == PINNED_COMMIT
    assert tree == PINNED_TREE
    assert branch == ""


def asv_environment(tmp_path: Path, variant: str) -> dict[str, str]:
    script = (
        f'source "{COMMON}"; '
        f"PERF_VARIANT={variant}; "
        f'numpy_asv_env "{tmp_path}/home"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    return dict(
        line.split("=", 1) for line in completed.stdout.splitlines() if "=" in line
    )


def test_optimized_asv_environment_reaches_the_mirrors(tmp_path: Path) -> None:
    values = asv_environment(tmp_path, "optimized")
    assert "PIP_INDEX_URL" in values
    assert "PIP_TRUSTED_HOST" in values
    assert not [key for key in values if key.lower() == "http_proxy"]
    assert not [key for key in values if key.lower() == "no_proxy"]
    # The BLAS/threading pins are still handed to ASV.
    assert values["OPENBLAS_NUM_THREADS"] == "1"
    assert values["PYTHONHASHSEED"] == "0"
    assert values["HOME"] == f"{tmp_path}/home"


def test_base_asv_environment_keeps_the_black_hole(tmp_path: Path) -> None:
    values = asv_environment(tmp_path, "base")
    assert values["http_proxy"] == "http://127.0.0.1:9"
    assert values["https_proxy"] == "http://127.0.0.1:9"
    assert "PIP_INDEX_URL" not in values


# ---------------------------------------------------------------------------
# parse_benchmark.py: expected commit override
# ---------------------------------------------------------------------------


def fixture_document() -> dict:
    return json.loads(RESULTS_FIXTURE.read_text(encoding="utf-8"))


def parser_environment(**overrides: str) -> dict[str, str]:
    document = fixture_document()
    environment = {
        "NUMPY_REPS": "5",
        "NUMPY_WARMUPS": "1",
        "NUMPY_BASELINE_COMMIT": document["commit_hash"],
        "NUMPY_PYTHON_SHORT": document["python"],
        "SOFTWARE_VERSION": "2.4.3",
        "PERF_VARIANT": "base",
        "EXPECTED_ARCH": document["params"]["arch"],
        "ASV_SUITE_COMMIT": SUITE_COMMIT,
        "ASV_VERSION": "0.6.4",
    }
    environment.update(overrides)
    return environment


def run_parser(
    tmp_path: Path, **overrides: str
) -> tuple[subprocess.CompletedProcess[str], Path]:
    out = tmp_path / "results.json"
    completed = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--results",
            str(RESULTS_FIXTURE),
            "--list",
            str(IDS_FIXTURE),
            "--out",
            str(out),
            "--samples",
            str(tmp_path / "runs" / "samples.json"),
        ],
        env=os.environ | parser_environment(**overrides),
        capture_output=True,
        text=True,
        check=False,
    )
    return completed, out


def test_parser_honours_the_expected_commit_override(tmp_path: Path) -> None:
    commit = fixture_document()["commit_hash"]
    completed, out = run_parser(
        tmp_path, PERF_VARIANT="optimized", NUMPY_EXPECTED_COMMIT=commit
    )
    assert completed.returncode == 0, completed.stderr
    document = json.loads(out.read_text(encoding="utf-8"))
    assert document["variant"] == "optimized"
    assert document["commit"] == commit


def test_parser_rejects_a_commit_outside_the_expected_override(tmp_path: Path) -> None:
    completed, out = run_parser(
        tmp_path, PERF_VARIANT="optimized", NUMPY_EXPECTED_COMMIT="0" * 40
    )
    assert completed.returncode == 50
    assert "NUMPY_EXPECTED_COMMIT" in completed.stderr
    assert not out.exists()


def test_parser_records_the_optimized_source_metadata(tmp_path: Path) -> None:
    commit = fixture_document()["commit_hash"]
    completed, out = run_parser(
        tmp_path,
        PERF_VARIANT="optimized",
        NUMPY_EXPECTED_COMMIT=commit,
        NUMPY_EXPECTED_BRANCH="master",
        NUMPY_EXPECTED_PARENT="f" * 40,
        NUMPY_COMMIT_RANGE="HEAD~1..HEAD",
    )
    assert completed.returncode == 0, completed.stderr
    document = json.loads(out.read_text(encoding="utf-8"))
    assert document["branch"] == "master"
    assert document["parent_commit"] == "f" * 40
    assert document["commit_range"] == "HEAD~1..HEAD"


def test_parser_keeps_the_base_document_unchanged(tmp_path: Path) -> None:
    completed, out = run_parser(tmp_path)
    assert completed.returncode == 0, completed.stderr
    document = json.loads(out.read_text(encoding="utf-8"))
    assert "branch" not in document
    assert "parent_commit" not in document
    assert "commit_range" not in document


# ---------------------------------------------------------------------------
# documentation
# ---------------------------------------------------------------------------


def test_readme_documents_both_variants() -> None:
    text = README.read_text(encoding="utf-8")
    assert "variant=optimized" in text
    assert "HEAD~1..HEAD" in text
    assert "未实现" not in text


# ---------------------------------------------------------------------------
# optimization boundary: user space only, never OS/BIOS tuning
# ---------------------------------------------------------------------------

OS_BIOS_PATTERNS = (
    r"\bsysctl\b",
    r"/proc/sys",
    r"/sys/",
    r"\bcpupower\b",
    r"\btuned-adm\b",
    r"\bgovernor\b",
    r"transparent_hugepage",
    r"\bhugepages?\b",
    r"\bdmidecode\b",
    r"\bwrmsr\b",
    r"\bmsr\b",
    r"\bsetpci\b",
    r"--privileged\b",
    r"--cap-add\b",
    r"--sysctl\b",
)


def test_optimized_logic_never_touches_os_or_bios() -> None:
    """The optimized variant may change NumPy, not the operating system.

    Comparing ``variant=optimized`` against ``variant=base`` is only meaningful
    when both measure the same machine with the same out-of-the-box OS/BIOS
    settings, so the optimized builder and the stages it drives must not write
    sysctl knobs, CPU governors, THP/hugepage settings, tuned profiles, MSRs or
    privileged container flags.  Comments may name those knobs (this is how the
    rule is documented), so only executable lines are scanned.
    """
    for path in (OPTIMIZED, START, TEST):
        code = "\n".join(
            line
            for line in path.read_text(encoding="utf-8").splitlines()
            if not line.lstrip().startswith("#")
        )
        for pattern in OS_BIOS_PATTERNS:
            match = re.search(pattern, code)
            assert match is None, (
                f"{path.name} tunes OS/BIOS state via {match.group(0)!r}; the "
                "optimized variant must stay in container user space"
            )
