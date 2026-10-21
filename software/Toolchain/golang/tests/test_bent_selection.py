"""Keep the selected Bent workload and its raw-result contract stable."""

from __future__ import annotations

import importlib.util
import json
import os
import re
import subprocess
import sys
import zipfile
from pathlib import Path

import pytest
import tomllib

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location(
    "golang_bent_parser", SCRIPT_DIR / "results" / "parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)
PREFETCH_SPEC = importlib.util.spec_from_file_location(
    "golang_bent_prefetch", SCRIPT_DIR / "prefetch_bent_modules.py"
)
assert PREFETCH_SPEC is not None and PREFETCH_SPEC.loader is not None
prefetch = importlib.util.module_from_spec(PREFETCH_SPEC)
PREFETCH_SPEC.loader.exec_module(prefetch)


def test_case_yaml_stages_use_split_scripts() -> None:
    import yaml

    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_golang",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_golang_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_golang_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_golang_runtime",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


def test_selected_benchmarks_resolve_to_pinned_suites() -> None:
    benchmarks = tomllib.loads((SCRIPT_DIR / "benchmarks.toml").read_text())[
        "Benchmarks"
    ]
    suites = tomllib.loads((SCRIPT_DIR / "suites.toml").read_text())["Suites"]
    names = [benchmark["Name"] for benchmark in benchmarks]
    assert len(names) == len(set(names)) == 20
    assert len(suites) == 15
    assert {benchmark["Suite"] for benchmark in benchmarks} == {
        suite["Name"] for suite in suites
    }
    assert all(suite["Version"].startswith("@") for suite in suites)
    assert next(suite for suite in suites if suite["Name"] == "minio")["Version"] == (
        "@v0.0.0-20251015172955-9e49d5e7a648"
    )


def test_bent_version_matches_case_and_installer() -> None:
    version = parser.BENT_MODULE_VERSION
    assert version == "v0.0.0-20261009192853-4a545adeb0d5"
    assert '"golang.org/x/benchmarks/cmd/bent@${BENT_MODULE_VERSION}"' in (
        SCRIPT_DIR / "stages" / "test.sh"
    ).read_text(encoding="utf-8")
    assert f'version: "{version}"' in (CASE_DIR / "case.yaml").read_text(
        encoding="utf-8"
    )


def sample_output(*, omit: str | None = None) -> list[str]:
    lines = []
    for shortname in parser.expected_shortnames():
        lines.extend(
            (f"shortname: {shortname}", "toolchain: Baseline", "pkg: example.org/bench")
        )
        for sample in range(parser.REPEATS - (shortname == omit)):
            lines.append(
                f"BenchmarkExample-12  100  {sample + 1} ns/op  4 B/op  2 allocs/op"
            )
    return lines


def test_parse_all_twenty_original_ns_per_op_metrics() -> None:
    results, context = parser.parse_output(sample_output())
    assert len(results) == 20
    assert context["bent_measurements"] == 20 * parser.REPEATS
    assert context["source_gomaxprocs"] == ["12"]
    for name, metric in results.items():
        assert name.endswith("BenchmarkExample-12 :: ns/op")
        assert metric["value"] == 8
        assert metric["samples"] == 15
        assert metric["direction"] == "lower_is_better"


def test_missing_repeat_fails_instead_of_silently_dropping_metric() -> None:
    with pytest.raises(RuntimeError, match="15 ns/op samples"):
        parser.parse_output(sample_output(omit=parser.expected_shortnames()[0]))


def test_extra_repeat_fails_instead_of_changing_the_median() -> None:
    lines = sample_output()
    lines.append("BenchmarkExample-12  100  999 ns/op")
    with pytest.raises(RuntimeError, match="15 ns/op samples"):
        parser.parse_output(lines)


@pytest.mark.parametrize(
    ("direct_network", "expected_proxy"),
    [
        (
            "false",
            "https://repo.huaweicloud.com/repository/goproxy/|https://goproxy.cn",
        ),
        ("true", "direct"),
    ],
)
def test_go_module_proxy_selection(direct_network: str, expected_proxy: str) -> None:
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; configure_go_environment; printf "%s" "$GOPROXY"',
            "bash",
            str(SCRIPT_DIR / "common.sh"),
        ],
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
        'if [ "$1" = -I ]; then exit 0; fi\n'
        'printf "%s\\n" "$@" > "$FAKE_BENT_ARGS"\n'
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
        [
            "bash",
            "-c",
            command,
            "bash",
            str(SCRIPT_DIR / "stages" / "test.sh"),
            str(runtime),
            str(gopath),
            str(go),
            str(results),
            str(go_root),
        ],
        env=os.environ
        | {
            "FAKE_GO_SOURCE_DIR": str(module_source),
            "FAKE_BENT_ARGS": str(tmp_path / "bent-args"),
            "BENT_MODULE_CACHE_DIR": str(offline_cache.parent.parent),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert (
        (results / "benchmark_go_bench.txt")
        .read_text()
        .startswith("shortname: uuid-New")
    )
    assert "GOMAXPROCS=" in (results / "configurations.toml").read_text()
    assert (runtime / "go-mod-cache/cache/download/cached.info").read_text() == "cached"
    assert "copied local Bent module cache" in completed.stdout
    assert (tmp_path / "bent-args").read_text(encoding="utf-8").splitlines() == [
        "-B",
        "benchmarks.toml",
        "-C",
        "configurations.toml",
        "-N",
        "15",
        "-L",
        ".bent-stamps.log",
    ]


def test_missing_local_bent_cache_uses_network_fallback(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    missing_cache = tmp_path / "missing-cache"
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; GO_RUNTIME_DIR="$2"; copy_bent_module_cache',
            "bash",
            str(SCRIPT_DIR / "stages" / "test.sh"),
            str(runtime),
        ],
        env=os.environ | {"BENT_MODULE_CACHE_DIR": str(missing_cache)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert "missing modules will use GOPROXY" in completed.stdout
    assert not (runtime / "go-mod-cache").exists()


def test_missing_bent_modules_are_downloaded_one_at_a_time(tmp_path: Path) -> None:
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
        [
            "python3",
            str(SCRIPT_DIR / "prefetch_bent_modules.py"),
            "--go",
            str(fake_go),
            "--suites",
            str(suites),
            "--work-dir",
            str(tmp_path),
        ],
        env=os.environ
        | {"FAKE_GO_SOURCE_DIR": str(source), "FAKE_GO_CALLS": str(calls)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert calls.read_text(encoding="utf-8").splitlines() == [
        "github.com/google/uuid@v1.2.0",
        "github.com/dustin/go-humanize@v1.0.1",
        "example.org/dep@v1.0.0",
        "example.org/metadata-only@v2.0.0",
    ]


def test_offline_resolved_suites_skip_go_module_downloads(tmp_path: Path) -> None:
    suites = tmp_path / "suites.toml"
    suites.write_text(
        '[[Suites]]\nName = "uuid"\nRepo = "github.com/google/uuid/"\nVersion = "@v1.2.0"\n',
        encoding="utf-8",
    )
    module_cache = tmp_path / "module-cache"
    cache_root = module_cache / "cache/download"
    for module, version in (
        ("github.com/google/uuid", "v1.2.0"),
        ("example.org/cached", "v1.0.0"),
    ):
        base = cache_root / module / "@v" / version
        base.parent.mkdir(parents=True)
        with zipfile.ZipFile(f"{base}.zip", "w") as archive:
            contents = (
                "example.org/cached v1.0.0 h1:abc\nexample.org/missing v2.0.0 h1:def\n"
            )
            archive.writestr(f"{module}@{version}/go.sum", contents)
        for suffix in (".ziphash", ".mod", ".info"):
            Path(f"{base}{suffix}").write_text("cached", encoding="utf-8")

    source = tmp_path / "module-source"
    source.mkdir()
    calls = tmp_path / "calls"
    fake_go = tmp_path / "go"
    fake_go.write_text(
        '#!/bin/sh\nprintf "%s\\n" "$4" >> "$FAKE_GO_CALLS"\n'
        'printf \'{"Dir":"%s"}\\n\' "$FAKE_GO_SOURCE_DIR"\n',
        encoding="utf-8",
    )
    fake_go.chmod(0o755)
    completed = subprocess.run(
        [
            "python3",
            str(SCRIPT_DIR / "prefetch_bent_modules.py"),
            "--go",
            str(fake_go),
            "--suites",
            str(suites),
            "--work-dir",
            str(tmp_path),
            "--module-cache",
            str(module_cache),
        ],
        env=os.environ
        | {"FAKE_GO_SOURCE_DIR": str(source), "FAKE_GO_CALLS": str(calls)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    assert calls.read_text(encoding="utf-8").splitlines() == [
        "github.com/google/uuid/@v1.2.0"
    ]
    assert (
        "Bent and all 1 suites resolve from local cache; no downloads needed"
        in completed.stdout
    )


def test_cached_module_path_uses_go_uppercase_escaping(tmp_path: Path) -> None:
    base = tmp_path / "cache/download/github.com/!i!b!m/sarama/@v/v1.60.0"
    base.parent.mkdir(parents=True)
    for suffix in (".zip", ".ziphash", ".mod", ".info"):
        Path(f"{base}{suffix}").write_text("cached", encoding="utf-8")
    assert prefetch.cached_zip(tmp_path, "github.com/IBM/sarama@v1.60.0") == Path(
        f"{base}.zip"
    )


def test_stage_scripts_do_not_depend_on_builder_only_functions() -> None:
    """Framework stages run standalone; they must not call builder-only helpers."""
    builder_functions: set[str] = set()
    for builder in sorted((SCRIPT_DIR / "builders").glob("*.sh")):
        builder_functions.update(
            re.findall(
                r"^([a-z_]+)\(\)", builder.read_text(encoding="utf-8"), re.MULTILINE
            )
        )
    assert builder_functions
    for stage in sorted((SCRIPT_DIR / "stages").glob("*.sh")):
        content = stage.read_text(encoding="utf-8")
        referenced = {
            name for name in builder_functions if re.search(rf"\b{name}\b", content)
        }
        assert not referenced, (
            f"{stage.name} references builder-only functions: {referenced}"
        )


def test_optimized_build_fails_without_running_base_build(tmp_path: Path) -> None:
    completed = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_golang',
            "bash",
            str(SCRIPT_DIR / "builders" / "dispatch.sh"),
        ],
        env=os.environ | {"PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 30
    assert "optimized golang build is not implemented" in completed.stdout
    assert not (tmp_path / "go-install").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    completed = subprocess.run(
        ["bash", str(CASE_DIR / "golang_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 10
    assert "invalid build variant" in completed.stdout


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        raw = tmp_path / f"bent-{architecture}.txt"
        raw.write_text("\n".join(sample_output()) + "\n", encoding="utf-8")
        output = tmp_path / f"benchmark_golang-{architecture}.json"
        completed = subprocess.run(
            [
                sys.executable,
                str(SCRIPT_DIR / "results" / "parse_benchmark.py"),
                str(raw),
                str(output),
            ],
            env=os.environ
            | {
                "SOFTWARE_VERSION": "1.26.9",
                "EXPECTED_ARCH": architecture,
                "PERF_VARIANT": "base",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert completed.returncode == 0, completed.stderr
        normalized = json.loads(output.read_text(encoding="utf-8"))
        assert normalized["variant"] == "base"
        assert len(normalized["results"]) == 20
        parameters.append(normalized["parameters"])
    assert parameters[0] == parameters[1]
    assert not any("boostkit-perf" in json.dumps(parameter) for parameter in parameters)
