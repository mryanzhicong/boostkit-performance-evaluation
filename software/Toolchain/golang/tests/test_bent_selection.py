"""Keep the selected Bent workload and its raw-result contract stable."""

from __future__ import annotations

import importlib.util
import os
import subprocess
import tomllib
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location("golang_bent_parser", SCRIPT_DIR / "parse_benchmark.py")
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)


def test_selected_benchmarks_resolve_to_pinned_suites() -> None:
    benchmarks = tomllib.loads((SCRIPT_DIR / "benchmarks.toml").read_text())["Benchmarks"]
    suites = tomllib.loads((SCRIPT_DIR / "suites.toml").read_text())["Suites"]
    names = [benchmark["Name"] for benchmark in benchmarks]
    assert len(names) == len(set(names)) == 20
    assert len(suites) == 15
    assert {benchmark["Suite"] for benchmark in benchmarks} == {suite["Name"] for suite in suites}
    assert all(suite["Version"].startswith("@") for suite in suites)


def sample_output(*, omit: str | None = None) -> list[str]:
    lines = []
    for shortname in parser.expected_shortnames():
        lines.extend((f"shortname: {shortname}", "toolchain: Baseline", "pkg: example.org/bench"))
        for sample in range(parser.REPEATS - (shortname == omit)):
            lines.append(f"BenchmarkExample-12  100  {sample + 1} ns/op  4 B/op  2 allocs/op")
    return lines


def test_parse_all_twenty_original_ns_per_op_metrics() -> None:
    results, context = parser.parse_output(sample_output())
    assert len(results) == 20
    assert context["bent_measurements"] == 300
    assert context["source_gomaxprocs"] == ["12"]
    for name, metric in results.items():
        assert name.endswith("BenchmarkExample-12 :: ns/op")
        assert metric["value"] == 8
        assert metric["samples"] == 15
        assert metric["direction"] == "lower_is_better"


def test_missing_repeat_fails_instead_of_silently_dropping_metric() -> None:
    with pytest.raises(RuntimeError, match="15 ns/op samples"):
        parser.parse_output(sample_output(omit=parser.expected_shortnames()[0]))


def test_bent_runner_preserves_original_stdout_before_cleanup(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    gopath = tmp_path / "gopath"
    results = tmp_path / "results"
    go_root = tmp_path / "go-install"
    bent = gopath / "bin/bent"
    bent.parent.mkdir(parents=True)
    bent.write_text(
        "#!/bin/sh\n"
        "if [ \"$1\" = -I ]; then exit 0; fi\n"
        "mkdir -p bench\n"
        "printf 'shortname: uuid-New\\ntoolchain: Baseline\\npkg: github.com/google/uuid\\nBenchmarkNew-12  100  8 ns/op\\n' > bench/20261014.Baseline.stdout\n",
        encoding="utf-8",
    )
    bent.chmod(0o755)
    go = go_root / "bin/go"
    go.parent.mkdir(parents=True)
    go.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    go.chmod(0o755)
    results.mkdir()
    command = (
        'source "$1"; GO_RUNTIME_DIR="$2"; GOPATH="$3"; GO_BIN="$4"; '
        'RESULTS_DIR="$5"; GO_INSTALL_DIR="$6"; run_official_bent_benchmarks'
    )
    completed = subprocess.run(
        ["bash", "-c", command, "bash", str(CASE_DIR / "golang_test.sh"),
         str(runtime), str(gopath), str(go), str(results), str(go_root)],
        env=os.environ.copy(),
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (results / "benchmark_go_bench.txt").read_text().startswith("shortname: uuid-New")
    assert "GOMAXPROCS=" in (results / "configurations.toml").read_text()
