"""Check the numpy case without a live Docker daemon and without a numpy build.

The case runs every stage inside a private openEuler 24.03 LTS SP4 container and
trusts the strict parser as the only success authority.  These tests pin the
parts of that contract that a silent regression would break:

* the generated container block: container name and run-id label, the verified
  local image archive, host-network / directory mounts, the ``docker exec``
  environment, the refusal to remove a container of another run and an
  idempotent stop with no container;
* ``scripts/benchmarks/select_benchmarks.py``: CRLF/escaped list handling,
  anchored ``asv run -b`` regexes, the expected-metric document, and the hard
  failures for duplicated, unresolved or colliding ids;
* ``scripts/results/parse_benchmark.py``: the median-after-warm-up metric, the
  sample mirror, and the refusal to publish on any protocol violation.

The asv fixtures under ``tests/fixtures`` are a reduced synthetic copy of the
real asv 0.6.4 artefacts (flat ``result``/``samples`` rows over
``itertools.product(*params)`` with ``NaN``/``null`` for combinations that were
not selected).  Nothing here needs network access or an installed numpy.
"""

from __future__ import annotations

import hashlib
import itertools
import json
import os
import re
import statistics
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
COMMON = CASE_DIR / "scripts" / "common.sh"
STOP = CASE_DIR / "scripts" / "stages" / "stop.sh"
SELECT = CASE_DIR / "scripts" / "benchmarks" / "select_benchmarks.py"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
RESULTS_FIXTURE = FIXTURES / "synthetic_asv_results.json"
BENCHMARKS_FIXTURE = FIXTURES / "synthetic_asv_benchmarks.json"
IDS_FIXTURE = FIXTURES / "synthetic_ids.txt"

REPS = 5
WARMUPS = 1
ESCAPE_SEQUENCE = re.compile(r"\\(.)")


def fixture_document() -> dict:
    return json.loads(RESULTS_FIXTURE.read_text(encoding="utf-8"))


FIXTURE = fixture_document()
COLUMNS = {name: index for index, name in enumerate(FIXTURE["result_columns"])}
COMMIT = FIXTURE["commit_hash"]


# ---------------------------------------------------------------------------
# shared helpers
# ---------------------------------------------------------------------------


def run_tool(
    script: Path, tmp_path: Path, *arguments: str, **extra: str
) -> subprocess.CompletedProcess[str]:
    """Run one case script with the calling interpreter and a clean env."""
    environment = os.environ | extra
    return subprocess.run(
        [sys.executable, str(script), *arguments],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
        cwd=tmp_path,
    )


def unescaped_ids() -> list[str]:
    text = IDS_FIXTURE.read_bytes().decode("utf-8")
    return [
        ESCAPE_SEQUENCE.sub(r"\1", line)
        for line in text.splitlines()
        if line.strip()
    ]


def write_ids(path: Path, identifiers: list[str], *, escape: bool = True) -> Path:
    lines = [
        re.escape(identifier) if escape else identifier for identifier in identifiers
    ]
    path.write_bytes("\r\n".join(lines).encode("utf-8"))
    return path


def copy_results(tmp_path: Path, mutate) -> Path:
    document = json.loads(RESULTS_FIXTURE.read_text(encoding="utf-8"))
    mutate(document)
    path = tmp_path / "asv-results.json"
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    return path


def parser_environment(**overrides: str) -> dict[str, str]:
    environment = {
        "NUMPY_REPS": str(REPS),
        "NUMPY_WARMUPS": str(WARMUPS),
        "NUMPY_BASELINE_COMMIT": COMMIT,
        "NUMPY_PYTHON_SHORT": FIXTURE["python"],
        "SOFTWARE_VERSION": "2.4.3",
        "PERF_VARIANT": "standalone",
        "EXPECTED_ARCH": FIXTURE["params"]["arch"],
        "ASV_SUITE_COMMIT": "95422b21eb5b43a2453e45b8531a3dd09c9b61ab",
        "ASV_VERSION": "0.6.4",
    }
    environment.update(overrides)
    return environment


def fixture_samples(name: str, flat: int) -> list[float]:
    return list(FIXTURE["results"][name][COLUMNS["samples"]][flat])


def expected_metric(samples: list[float]) -> dict[str, float]:
    measured = samples[WARMUPS:]
    return {
        "value": statistics.median(measured),
        "min": min(measured),
        "max": max(measured),
        "mean": statistics.fmean(measured),
    }


# ---------------------------------------------------------------------------
# container lifecycle (skipped until scripts/common.sh exists)
# ---------------------------------------------------------------------------


def normalised_arch(machine: str) -> str:
    lowered = machine.lower()
    if lowered in ("x86_64", "amd64"):
        return "x86_64"
    if lowered in ("aarch64", "arm64"):
        return "aarch64"
    return lowered


def host_arch() -> str:
    return normalised_arch(os.uname().machine)


def image_architecture() -> str:
    return "amd64" if host_arch() == "x86_64" else "arm64"


def require_common(*functions: str) -> None:
    if not COMMON.is_file():
        pytest.skip("scripts/common.sh is not written yet; the case builder owns it")
    text = COMMON.read_text(encoding="utf-8")
    missing = [
        function
        for function in functions
        if not re.search(rf"(?m)^\s*{re.escape(function)}\s*\(\)\s*\{{", text)
    ]
    assert not missing, (
        f"scripts/common.sh does not define {missing}; run "
        "adaptation/scripts/add-container-block.py to install the generated "
        "container block"
    )


def require_stop(*functions: str) -> None:
    if not STOP.is_file():
        pytest.skip("scripts/stages/stop.sh is not written yet; the case builder owns it")
    sources = [path.read_text(encoding="utf-8") for path in (COMMON, STOP) if path.is_file()]
    text = "\n".join(sources)
    missing = [
        function
        for function in functions
        if not re.search(rf"(?m)^\s*{re.escape(function)}\s*\(\)\s*\{{", text)
    ]
    if missing:
        pytest.skip(f"scripts/stages/stop.sh does not define {missing} yet")


def run_shell(
    script: str, tmp_path: Path, **extra: str
) -> subprocess.CompletedProcess[str]:
    environment = os.environ | {
        "PATH": f"{tmp_path}{os.pathsep}{os.environ['PATH']}",
        "PERF_RUN_ID": "unit-test",
        "EXPECTED_ARCH": os.uname().machine,
        "DOCKER_CALLS": str(tmp_path / "docker-calls.log"),
        "PERF_PROXY": "",
        "TMPDIR": str(tmp_path / "tmp"),
        "LABEL": "unit-test",
        "IMAGE_ARCH": image_architecture(),
    } | extra
    return subprocess.run(
        ["bash", "-c", script],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )


def write_fake_docker(tmp_path: Path, *, container_exists: bool = False) -> Path:
    fake_docker = tmp_path / "docker"
    fake_docker.write_text(
        "#!/bin/sh\n"
        'printf "%s\\n" "$*" >> "$DOCKER_CALLS"\n'
        'case "$1" in\n'
        "  info) exit 0 ;;\n"
        '  load) printf "Loaded image: openeuler-24.03-lts-sp4:latest\\n"; exit 0 ;;\n'
        '  ps) exit 0 ;;\n'
        '  stop|rm) exit 0 ;;\n'
        "esac\n"
        'if [ "$1" = container ] && [ "$2" = inspect ]; then\n'
        f'  exit {0 if container_exists else 1}\n'
        "fi\n"
        'if [ "$1 $2 $3" = "image inspect --format" ]; then printf "%s\\n" "$IMAGE_ARCH"; exit 0; fi\n'
        'case "$1" in\n'
        "  inspect)\n"
        '    case "$3" in\n'
        '      *State.Running*) printf "true\\n" ;;\n'
        '      *) printf "%s\\n" "$LABEL" ;;\n'
        "    esac\n"
        "    exit 0 ;;\n"
        "esac\n"
        'if [ "$1" = run ]; then\n'
        '  case " $* " in\n'
        '    *" --network=none "*) printf \'NAME="openEuler Linux"\\nVERSION="24.03 (LTS-SP4)"\\n\' ;;\n'
        "  esac\n"
        "  exit 0\n"
        "fi\n"
        'if [ "$1" = exec ]; then\n'
        '  case " $* " in\n'
        '    *" test -f /etc/yum.repos.d/openEuler.repo "*) exit 1 ;;\n'
        "  esac\n"
        '  printf "exec-ok\\n"\n'
        "  exit 0\n"
        "fi\n"
        "exit 0\n",
        encoding="utf-8",
    )
    fake_docker.chmod(0o755)
    return fake_docker


def write_image_archive(tmp_path: Path, architecture: str) -> Path:
    archive_name = f"openEuler-docker.{architecture}.tar.xz"
    archive = tmp_path / archive_name
    archive.write_bytes(b"openEuler 24.03 SP4 fixture")
    checksum = tmp_path / f"{archive_name}.sha256sum"
    checksum.write_text(
        f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive_name}\n",
        encoding="utf-8",
    )
    return archive


def test_container_name_carries_arch_and_run_id(tmp_path: Path) -> None:
    require_common("numpy_configure_container")
    work = tmp_path / "work"
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; '
        "numpy_configure_container; "
        'printf "%s\\n" "${NUMPY_CONTAINER_NAME}"; printf "%s\\n" "${NUMPY_CONTAINER_HOME}"'
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    name, home = completed.stdout.splitlines()[:2]
    assert name == f"boostkit-numpy-{host_arch()}-unit-test"
    assert home == f"{work}/home"


def test_image_uses_local_verified_sp4_archive(tmp_path: Path) -> None:
    require_common("prepare_numpy_container_image")
    write_fake_docker(tmp_path)
    archive = write_image_archive(tmp_path, host_arch())
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; '
        "prepare_numpy_container_image"
    )
    completed = run_shell(
        script, tmp_path, NUMPY_IMAGE_ARCHIVE_DIR=str(tmp_path)
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert f"load --input {archive}" in calls
    assert "is ready" in completed.stdout

    checksum = archive.with_name(archive.name + ".sha256sum")
    checksum.write_text("0" * 64 + f"  {archive.name}\n", encoding="utf-8")
    failed = run_shell(script, tmp_path, NUMPY_IMAGE_ARCHIVE_DIR=str(tmp_path))
    assert failed.returncode == 30
    assert "checksum mismatch" in failed.stdout + failed.stderr


def test_image_rejects_wrong_architecture(tmp_path: Path) -> None:
    require_common("prepare_numpy_container_image")
    write_fake_docker(tmp_path)
    wrong = "arm64" if host_arch() == "x86_64" else "amd64"
    write_image_archive(tmp_path, normalised_arch(wrong))
    work = tmp_path / "work"
    work.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; '
        "prepare_numpy_container_image"
    )
    completed = run_shell(
        script,
        tmp_path,
        NUMPY_IMAGE_ARCHIVE_DIR=str(tmp_path),
        EXPECTED_ARCH=wrong,
    )
    assert completed.returncode == 30, completed.stdout + completed.stderr
    assert "architecture" in completed.stdout + completed.stderr


def test_start_uses_host_network_and_mounts_task_directories(tmp_path: Path) -> None:
    require_common("start_numpy_container")
    write_fake_docker(tmp_path)
    write_image_archive(tmp_path, host_arch())
    work = tmp_path / "work"
    results = tmp_path / "results"
    work.mkdir()
    results.mkdir()
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; RESULTS_DIR="{results}"; SCRIPT_DIR="{CASE_DIR}"; '
        "start_numpy_container"
    )
    completed = run_shell(
        script, tmp_path, NUMPY_IMAGE_ARCHIVE_DIR=str(tmp_path)
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    run_line = next(
        line for line in calls.splitlines() if line.startswith("run --detach")
    )
    assert "--network=host" in run_line
    assert "--label boostkit.numpy.run-id=unit-test" in run_line
    assert f"source={work},target={work}" in run_line
    assert f"source={results},target={results}" in run_line
    assert f"source={CASE_DIR},target={CASE_DIR},readonly" in run_line
    assert "--user " in run_line
    assert "sleep infinity" in run_line


def test_exec_forwards_workdir_home_and_container(tmp_path: Path) -> None:
    require_common("numpy_container_exec_at")
    write_fake_docker(tmp_path)
    work = tmp_path / "work"
    script = (
        f'source "{COMMON}"; '
        f'PERF_WORK_DIR="{work}"; '
        "numpy_container_exec_at /tmp/scenario echo hello"
    )
    completed = run_shell(script, tmp_path)
    assert completed.returncode == 0, completed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert (
        "exec -e HOME=" + str(work) + "/home -e TMPDIR=" + str(tmp_path / "tmp")
        + " -e PERF_RUN_ID=unit-test --workdir /tmp/scenario boostkit-numpy-"
    ) in calls
    assert "echo hello" in calls


def test_stop_refuses_foreign_label_then_removes_own_container(tmp_path: Path) -> None:
    require_common("remove_numpy_container")
    write_fake_docker(tmp_path, container_exists=True)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{COMMON}"; PERF_WORK_DIR="{work}"; remove_numpy_container'
    refused = run_shell(script, tmp_path, LABEL="another-run")
    assert refused.returncode == 60
    assert "refusing to remove" in refused.stdout
    assert "stop --time 30" not in (tmp_path / "docker-calls.log").read_text(
        encoding="utf-8"
    )

    (tmp_path / "docker-calls.log").unlink()
    removed = run_shell(script, tmp_path, LABEL="unit-test")
    assert removed.returncode == 0, removed.stdout + removed.stderr
    calls = (tmp_path / "docker-calls.log").read_text(encoding="utf-8")
    assert "stop --time 30 boostkit-numpy-" in calls
    assert "rm boostkit-numpy-" in calls


def test_stop_is_idempotent_without_a_container(tmp_path: Path) -> None:
    require_stop("stop_numpy_runtime")
    write_fake_docker(tmp_path, container_exists=False)
    work = tmp_path / "work"
    work.mkdir()
    script = f'source "{STOP}"; initialize_runtime() {{ :; }}; stop_numpy_runtime'
    completed = run_shell(
        script,
        tmp_path,
        PERF_WORK_DIR=str(work),
        NUMPY_STATE_DIR=f"{work}/state",
        # The leftover scan greps for this path; keep it unique so the scan does
        # not match unrelated processes (or this test's own shell).
        NUMPY_ASV_BIN=f"{work}/numpy-asv/asv",
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    log = tmp_path / "docker-calls.log"
    assert log.exists(), (
        f"docker was never invoked: stdout={completed.stdout!r} "
        f"stderr={completed.stderr!r} entries={sorted(p.name for p in tmp_path.iterdir())}"
    )
    assert "rm boostkit-numpy-" not in log.read_text(encoding="utf-8")


def test_measurement_environment_is_explicit(tmp_path: Path) -> None:
    """Every in-container measurement inherits the pinned BLAS/offline settings."""
    require_common("numpy_container_exec")
    script = (
        f'source "{COMMON}"; '
        "declare -p NUMPY_MEASUREMENT_ENV >/dev/null 2>&1 || exit 3; "
        'printf "%s\\n" "${NUMPY_MEASUREMENT_ENV[@]}"'
    )
    completed = run_shell(script, tmp_path)
    if completed.returncode == 3:
        pytest.skip("scripts/common.sh does not define NUMPY_MEASUREMENT_ENV yet")
    assert completed.returncode == 0, completed.stderr
    values = dict(item.split("=", 1) for item in completed.stdout.split())
    assert values["OMP_NUM_THREADS"] == "1"
    assert values["OPENBLAS_NUM_THREADS"] == "1"
    assert values["MKL_NUM_THREADS"] == "1"
    assert values["PYTHONHASHSEED"] == "0"
    assert values["TZ"] == "UTC"
    assert values["LC_ALL"] == "C"


# ---------------------------------------------------------------------------
# select_benchmarks.py
# ---------------------------------------------------------------------------


def test_select_emits_one_anchored_regex_per_id(tmp_path: Path) -> None:
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(IDS_FIXTURE),
        "--benchmarks",
        str(BENCHMARKS_FIXTURE),
        "--emit-bench-args",
    )
    assert completed.returncode == 0, completed.stderr
    identifiers = unescaped_ids()
    expected = ["^" + re.escape(identifier) + "$" for identifier in identifiers]
    assert completed.stdout.splitlines() == expected
    # Nothing else may be printed on stdout: the run stage maps it to -b args.
    assert completed.stdout.count("\n") == len(expected)


def test_select_writes_expected_document(tmp_path: Path) -> None:
    expected_path = tmp_path / "expected.json"
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(IDS_FIXTURE),
        "--benchmarks",
        str(BENCHMARKS_FIXTURE),
        "--emit-expected",
        str(expected_path),
    )
    assert completed.returncode == 0, completed.stderr
    document = json.loads(expected_path.read_text(encoding="utf-8"))
    entries = document["entries"]
    assert [entry["id"] for entry in entries] == unescaped_ids()
    assert [entry["benchmark"] for entry in entries] == [
        "bench_reduce.AddReduce.time_axis_0",
        "bench_clip.ClipInteger.time_clip",
        "bench_clip.ClipInteger.time_clip",
        "bench_ufunc.Binary.time_binary",
        "bench_ufunc.Binary.time_binary",
    ]
    assert [entry["index"] for entry in entries] == [[], [0, 0], [0, 1], [0], [2]]
    for entry in entries:
        assert entry["regex"] == "^" + re.escape(entry["id"]) + "$"


def test_select_rejects_duplicate_ids(tmp_path: Path) -> None:
    identifiers = unescaped_ids()
    path = write_ids(tmp_path / "ids.txt", identifiers + [identifiers[1]])
    completed = run_tool(
        SELECT, tmp_path, "--list", str(path), "--emit-bench-args"
    )
    assert completed.returncode == 2
    assert identifiers[1] in completed.stderr
    assert completed.stdout == ""


def test_select_rejects_unresolved_ids(tmp_path: Path) -> None:
    ghost = "bench_ghost.GhostClass.time_ghost(1)"
    path = write_ids(tmp_path / "ids.txt", unescaped_ids() + [ghost])
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(path),
        "--benchmarks",
        str(BENCHMARKS_FIXTURE),
        "--emit-bench-args",
    )
    assert completed.returncode == 3
    assert ghost in completed.stderr
    assert completed.stdout == ""


def test_select_rejects_combination_collision(tmp_path: Path) -> None:
    discovery = {
        "version": 2,
        "bench_x.C.time_y": {
            "name": "bench_x.C.time_y",
            "params": [["1"]],
            "param_names": ["n"],
        },
        "bench_x.C.time_y(1)": {
            "name": "bench_x.C.time_y(1)",
            "params": [],
            "param_names": [],
        },
    }
    discovery_path = tmp_path / "benchmarks.json"
    discovery_path.write_text(json.dumps(discovery), encoding="utf-8")
    path = write_ids(tmp_path / "ids.txt", ["bench_x.C.time_y(1)"])
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(path),
        "--benchmarks",
        str(discovery_path),
        "--emit-bench-args",
    )
    assert completed.returncode == 4
    assert "same combination" in completed.stderr


def test_select_results_mode_uses_the_measured_combinations(tmp_path: Path) -> None:
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(IDS_FIXTURE),
        "--results",
        str(RESULTS_FIXTURE),
        "--json",
    )
    assert completed.returncode == 0, completed.stderr
    summary = json.loads(completed.stdout)
    assert summary["source"] == "results"
    assert summary["resolved"] == len(unescaped_ids())
    assert summary["unresolved"] == 0
    assert summary["measured_combos"] == len(unescaped_ids())

    unmeasured = "bench_clip.ClipInteger.time_clip(<class 'numpy.int64'>, 100)"
    path = write_ids(tmp_path / "ids.txt", unescaped_ids() + [unmeasured])
    lenient = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(path),
        "--results",
        str(RESULTS_FIXTURE),
        "--json",
    )
    assert lenient.returncode == 0, lenient.stderr
    strict = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(path),
        "--results",
        str(RESULTS_FIXTURE),
        "--require-measured",
        "--json",
    )
    assert strict.returncode == 3
    assert unmeasured in strict.stderr


def test_select_json_summary_reports_the_discovered_grid(tmp_path: Path) -> None:
    completed = run_tool(
        SELECT,
        tmp_path,
        "--list",
        str(IDS_FIXTURE),
        "--benchmarks",
        str(BENCHMARKS_FIXTURE),
        "--json",
    )
    assert completed.returncode == 0, completed.stderr
    summary = json.loads(completed.stdout)
    assert summary["source"] == "benchmarks"
    assert summary["ids"] == len(unescaped_ids())
    assert summary["blank_lines"] == 0
    assert summary["discovered_benchmarks"] == 4
    assert summary["discovered_combos"] == 9
    assert summary["resolved"] == len(unescaped_ids())


# ---------------------------------------------------------------------------
# parse_benchmark.py
# ---------------------------------------------------------------------------


def run_parser(
    tmp_path: Path,
    results: Path,
    ids: Path,
    *,
    log_summary: bool = False,
    env_overrides: dict[str, str] | None = None,
) -> tuple[subprocess.CompletedProcess[str], Path, Path]:
    out = tmp_path / "benchmark_result.json"
    samples = tmp_path / "runs" / "samples.json"
    arguments = [
        "--results",
        str(results),
        "--list",
        str(ids),
        "--out",
        str(out),
        "--samples",
        str(samples),
    ]
    if log_summary:
        arguments.append("--log-summary")
    completed = run_tool(
        PARSER, tmp_path, *arguments, **parser_environment(**(env_overrides or {}))
    )
    return completed, out, samples


def test_parser_publishes_median_after_warmup_and_mirrors_samples(
    tmp_path: Path,
) -> None:
    completed, out, samples = run_parser(
        tmp_path, RESULTS_FIXTURE, IDS_FIXTURE, log_summary=True
    )
    assert completed.returncode == 0, completed.stderr
    assert "[numpy]" in completed.stdout

    document = json.loads(out.read_text(encoding="utf-8"))
    assert document["software"] == "numpy"
    assert document["version"] == "2.4.3"
    assert document["variant"] == "standalone"
    assert document["architecture"] == FIXTURE["params"]["arch"]
    assert document["commit"] == COMMIT
    assert document["suite_commit"] == "95422b21eb5b43a2453e45b8531a3dd09c9b61ab"
    assert document["python"] == FIXTURE["python"]
    assert document["asv"] == "0.6.4"
    assert document["machine"] == FIXTURE["params"]["machine"]
    assert document["reps"] == REPS
    assert document["warmups"] == WARMUPS
    assert document["statistic"] == "median"
    assert document["measured"] == len(unescaped_ids())

    identifiers = unescaped_ids()
    # The Framework metric collector requires a non-empty JSON object.
    assert isinstance(document["results"], dict)
    assert list(document["results"]) == identifiers
    by_id = document["results"]
    assert len(by_id) == len(identifiers)

    # A plain benchmark: the first sample is the warm-up and must be dropped.
    plain = by_id["bench_reduce.AddReduce.time_axis_0"]
    plain_samples = fixture_samples("bench_reduce.AddReduce.time_axis_0", 0)
    plain_expected = expected_metric(plain_samples)
    assert plain["samples"] == plain_samples
    assert plain["warmup"] == plain_samples[0]
    assert plain["value"] == pytest.approx(plain_expected["value"])
    assert plain["median"] == pytest.approx(plain_expected["value"])
    assert plain["min"] == pytest.approx(plain_expected["min"])
    assert plain["max"] == pytest.approx(plain_expected["max"])
    assert plain["mean"] == pytest.approx(plain_expected["mean"])
    assert plain["unit"] == "s"
    assert plain["direction"] == "lower_is_better"
    assert plain["group"] == "bench_reduce.AddReduce"

    # Parameterized benchmarks: the flat row-major row index must be decoded
    # with itertools.product(*params) order.
    for name, flat in (
        ("bench_clip.ClipInteger.time_clip", 0),
        ("bench_clip.ClipInteger.time_clip", 1),
        ("bench_ufunc.Binary.time_binary", 0),
        ("bench_ufunc.Binary.time_binary", 2),
    ):
        combo = list(itertools.product(*FIXTURE["results"][name][COLUMNS["params"]]))[flat]
        identifier = f"{name}({', '.join(combo)})"
        entry = by_id[identifier]
        samples_for_combo = fixture_samples(name, flat)
        assert entry["samples"] == samples_for_combo
        assert entry["warmup"] == samples_for_combo[0]
        assert entry["value"] == pytest.approx(
            expected_metric(samples_for_combo)["value"]
        )
        assert entry["group"] == name.rsplit(".", 1)[0]

    mirror = json.loads(samples.read_text(encoding="utf-8"))
    assert mirror["commit"] == COMMIT
    assert mirror["reps"] == REPS
    assert mirror["warmups"] == WARMUPS
    assert [case["id"] for case in mirror["cases"]] == identifiers
    assert [case["samples"] for case in mirror["cases"]] == [
        by_id[identifier]["samples"] for identifier in identifiers
    ]


def test_parser_accepts_the_optional_benchmarks_flag(tmp_path: Path) -> None:
    out = tmp_path / "benchmark_result.json"
    samples = tmp_path / "samples.json"
    completed = run_tool(
        PARSER,
        tmp_path,
        "--results",
        str(RESULTS_FIXTURE),
        "--list",
        str(IDS_FIXTURE),
        "--out",
        str(out),
        "--samples",
        str(samples),
        "--benchmarks",
        str(tmp_path / "does-not-exist.json"),
        **parser_environment(),
    )
    assert completed.returncode == 0, completed.stderr
    assert out.is_file()


def test_parser_rejects_wrong_commit(tmp_path: Path) -> None:
    completed, out, _ = run_parser(
        tmp_path,
        RESULTS_FIXTURE,
        IDS_FIXTURE,
        env_overrides={"NUMPY_BASELINE_COMMIT": "0" * 40},
    )
    assert completed.returncode == 50
    assert "NUMPY_BASELINE_COMMIT" in completed.stderr
    assert not out.exists()


def test_parser_rejects_python_drift(tmp_path: Path) -> None:
    completed, _, _ = run_parser(
        tmp_path,
        RESULTS_FIXTURE,
        IDS_FIXTURE,
        env_overrides={"NUMPY_PYTHON_SHORT": "3.13"},
    )
    assert completed.returncode == 50
    assert "NUMPY_PYTHON_SHORT" in completed.stderr


def test_parser_rejects_short_sample_list(tmp_path: Path) -> None:
    def mutate(document: dict) -> None:
        row = document["results"]["bench_reduce.AddReduce.time_axis_0"]
        row[COLUMNS["samples"]][0] = row[COLUMNS["samples"]][0][:-1]

    results = copy_results(tmp_path, mutate)
    completed, _, _ = run_parser(tmp_path, results, IDS_FIXTURE)
    assert completed.returncode == 50
    assert "sample(s), expected" in completed.stderr


def test_parser_rejects_nonfinite_result(tmp_path: Path) -> None:
    path = write_ids(
        tmp_path / "ids.txt",
        ["bench_reduce.AddReduce.time_axis_0", "bench_reduce.AddReduce.time_axis_1"],
    )
    completed, _, _ = run_parser(tmp_path, RESULTS_FIXTURE, path)
    assert completed.returncode == 50
    assert "no finite result" in completed.stderr


def test_parser_rejects_unresolved_id(tmp_path: Path) -> None:
    ghost = "bench_ghost.GhostClass.time_ghost(1)"
    path = write_ids(tmp_path / "ids.txt", unescaped_ids() + [ghost])
    completed, _, _ = run_parser(tmp_path, RESULTS_FIXTURE, path)
    assert completed.returncode == 50
    assert "not covered" in completed.stderr
    assert ghost in completed.stderr


def test_parser_rejects_duplicate_ids(tmp_path: Path) -> None:
    identifiers = unescaped_ids()
    path = write_ids(tmp_path / "ids.txt", identifiers + [identifiers[0]])
    completed, _, _ = run_parser(tmp_path, RESULTS_FIXTURE, path)
    assert completed.returncode == 50
    assert "repeats benchmark id" in completed.stderr


def test_parser_rejects_rep_count_drift(tmp_path: Path) -> None:
    completed, _, _ = run_parser(
        tmp_path,
        RESULTS_FIXTURE,
        IDS_FIXTURE,
        env_overrides={"NUMPY_REPS": "4"},
    )
    assert completed.returncode == 50
    assert "sample(s), expected" in completed.stderr
