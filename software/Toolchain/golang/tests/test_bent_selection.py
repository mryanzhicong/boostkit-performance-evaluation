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


def test_bent_version_matches_case_and_installer() -> None:
    version = parser.BENT_MODULE_VERSION
    assert version == "v0.0.0-20261009192853-4a545adeb0d5"
    assert f'"golang.org/x/benchmarks/cmd/bent@${{BENT_MODULE_VERSION}}"' in (
        CASE_DIR / "golang_test.sh"
    ).read_text(encoding="utf-8")
    assert f'version: "{version}"' in (CASE_DIR / "case.yaml").read_text(encoding="utf-8")


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
    assert context["bent_measurements"] == 20
    assert context["source_gomaxprocs"] == ["12"]
    for name, metric in results.items():
        assert name.endswith("BenchmarkExample-12 :: ns/op")
        assert metric["value"] == 1
        assert metric["samples"] == 1
        assert metric["direction"] == "lower_is_better"


def test_missing_repeat_fails_instead_of_silently_dropping_metric() -> None:
    with pytest.raises(RuntimeError, match="1 ns/op samples"):
        parser.parse_output(sample_output(omit=parser.expected_shortnames()[0]))


@pytest.mark.parametrize(
    ("direct_network", "expected_proxy"),
    [
        ("false", "https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn"),
        ("true", "direct"),
    ],
)
def test_go_module_proxy_selection(direct_network: str, expected_proxy: str) -> None:
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; configure_go_environment; printf "%s" "$GOPROXY"',
         "bash", str(CASE_DIR / "golang_test.sh")],
        env=os.environ | {"PERF_DIRECT_NETWORK": direct_network},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr
    assert completed.stdout == expected_proxy


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
    module_source = tmp_path / "module-source"
    module_source.mkdir()
    offline_cache = tmp_path / "offline-cache" / "cache" / "download"
    offline_cache.mkdir(parents=True)
    (offline_cache / "cached.info").write_text("cached", encoding="utf-8")
    go.write_text(
        '#!/bin/sh\nprintf \'{"Dir":"%s"}\\n\' "$FAKE_GO_SOURCE_DIR"\n',
        encoding="utf-8",
    )
    go.chmod(0o755)
    results.mkdir()
    command = (
        'source "$1"; GO_RUNTIME_DIR="$2"; GOPATH="$3"; GO_BIN="$4"; '
        'RESULTS_DIR="$5"; GO_INSTALL_DIR="$6"; run_official_bent_benchmarks'
    )
    completed = subprocess.run(
        ["bash", "-c", command, "bash", str(CASE_DIR / "golang_test.sh"),
         str(runtime), str(gopath), str(go), str(results), str(go_root)],
        env=os.environ | {
            "FAKE_GO_SOURCE_DIR": str(module_source),
            "BENT_MODULE_CACHE_DIR": str(offline_cache.parent.parent),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (results / "benchmark_go_bench.txt").read_text().startswith("shortname: uuid-New")
    assert "GOMAXPROCS=" in (results / "configurations.toml").read_text()
    assert (runtime / "go-mod-cache/cache/download/cached.info").read_text() == "cached"
    assert "copied local Bent module cache" in completed.stdout


def test_missing_local_bent_cache_uses_network_fallback(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    missing_cache = tmp_path / "missing-cache"
    completed = subprocess.run(
        ["bash", "-c", 'source "$1"; GO_RUNTIME_DIR="$2"; copy_bent_module_cache',
         "bash", str(CASE_DIR / "golang_test.sh"), str(runtime)],
        env=os.environ | {"BENT_MODULE_CACHE_DIR": str(missing_cache)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "missing modules will use GOPROXY" in completed.stdout
    assert not (runtime / "go-mod-cache").exists()


def test_bent_modules_are_prefetched_one_at_a_time(tmp_path: Path) -> None:
    source = tmp_path / "module-source"
    source.mkdir()
    (source / "go.sum").write_text(
        "example.org/dep v1.0.0 h1:abc\n"
        "example.org/dep v1.0.0/go.mod h1:def\n"
        "example.org/metadata-only v2.0.0/go.mod h1:ghi\n",
        encoding="utf-8",
    )
    suites = tmp_path / "suites.toml"
    suites.write_text(
        '[[Suites]]\nName = "uuid"\nRepo = "github.com/google/uuid/"\nVersion = "@v1.2.0"\n'
        '[[Suites]]\nName = "dustin_humanize"\nRepo = "github.com/dustin/go-humanize"\nVersion = "@v1.0.1"\n',
        encoding="utf-8",
    )
    calls = tmp_path / "calls"
    fake_go = tmp_path / "go"
    fake_go.write_text(
        '#!/bin/sh\nprintf "%s\\n" "$4" >> "$FAKE_GO_CALLS"\n'
        'printf \'{"Dir":"%s"}\\n\' "$FAKE_GO_SOURCE_DIR"\n',
        encoding="utf-8",
    )
    fake_go.chmod(0o755)
    completed = subprocess.run(
        ["python3", str(SCRIPT_DIR / "prefetch_bent_modules.py"),
         "--go", str(fake_go), "--suites", str(suites), "--work-dir", str(tmp_path)],
        env=os.environ | {"FAKE_GO_SOURCE_DIR": str(source), "FAKE_GO_CALLS": str(calls)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert calls.read_text(encoding="utf-8").splitlines() == [
        "github.com/google/uuid@v1.2.0",
        "example.org/dep@v1.0.0",
        "example.org/metadata-only@v2.0.0",
        "github.com/dustin/go-humanize@v1.0.1",
    ]
