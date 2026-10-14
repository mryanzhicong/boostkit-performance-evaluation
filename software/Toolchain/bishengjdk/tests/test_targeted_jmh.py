"""The JMH build must compile only the unchanged official target benchmark."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

import yaml


CASE_DIR = Path(__file__).resolve().parents[1]
BENCHMARK_PATH = Path("org/openjdk/bench/vm/compiler/FloatingScalarVectorAbsDiff.java")
METHODS = (
    "testVectorAbsDiffFloat",
    "testVectorAbsDiffDouble",
    "testScalarAbsDiffFloat",
    "testScalarAbsDiffDouble",
)


def test_official_jmh_array_is_declared_as_raw_text() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    raw_output = case["outputs"]["jmh_raw_result"]
    assert raw_output["path"] == "jmh-result.json"
    assert raw_output["format"] == "text"
    assert case["outputs"]["jmh_result"]["format"] == "json"


def test_private_microbenchmark_source_is_passed_to_make(tmp_path: Path) -> None:
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    fake_make = fake_bin / "make"
    fake_make.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$MAKE_CAPTURE"\nexit 42\n')
    fake_make.chmod(0o755)
    work = tmp_path / "work"
    source = work / "bishengjdk-source" / "test/micro" / BENCHMARK_PATH
    source.parent.mkdir(parents=True)
    source.write_text("// official benchmark source\n", encoding="utf-8")
    jdk = work / "jdk" / "bin"
    jdk.mkdir(parents=True)
    (jdk / "java").write_text("", encoding="utf-8")
    (jdk / "java").chmod(0o755)
    jmh = work / "bishengjdk-source" / "build/jmh/jars/jmh-core-1.37.jar"
    jmh.parent.mkdir(parents=True)
    jmh.write_text("jar", encoding="utf-8")
    capture = tmp_path / "make-arguments.txt"
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; run_bishengjdk_benchmarks', "bash", str(CASE_DIR / "bishengjdk_test.sh")],
        env={
            **os.environ,
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "MAKE_CAPTURE": str(capture),
            "PERF_WORK_DIR": str(work),
            "RESULTS_DIR": str(tmp_path / "results"),
            "PERF_RUN_ID": "test-jmh-source",
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 50, result.stdout + result.stderr
    copied = work / "jmh-source" / BENCHMARK_PATH
    assert copied.read_bytes() == source.read_bytes()
    assert list((work / "jmh-source").rglob("*.java")) == [copied]
    arguments = capture.read_text(encoding="utf-8").splitlines()
    assert "test" in arguments
    assert f"MICROBENCHMARK_SRC={work / 'jmh-source'}" in arguments
    assert "TEST=micro:org.openjdk.bench.vm.compiler.FloatingScalarVectorAbsDiff" in arguments


def test_normalized_parameters_align_across_architectures(tmp_path: Path) -> None:
    benchmark = "org.openjdk.bench.vm.compiler.FloatingScalarVectorAbsDiff"
    raw = tmp_path / "jmh-result.json"
    raw.write_text(json.dumps([
        {
            "benchmark": f"{benchmark}.{method}",
            "mode": "avgt",
            "threads": 1,
            "forks": 3,
            "warmupIterations": 4,
            "measurementIterations": 4,
            "params": {"count": "1024"},
            "primaryMetric": {"scoreUnit": "ns/op", "score": 10.0},
        }
        for method in METHODS
    ]), encoding="utf-8")
    parameters = []
    for architecture in ("x86_64", "aarch64"):
        output = tmp_path / f"benchmark-{architecture}.json"
        result = subprocess.run(
            ["python3", str(CASE_DIR / "scripts/parse_benchmark.py"), str(raw), str(output)],
            env={
                **os.environ,
                "JMH_BENCHMARK": benchmark,
                "JMH_COUNT": "1024",
                "JMH_VERSION": "1.37",
                "SOFTWARE_VERSION": "21.0.9",
                "EXPECTED_ARCH": architecture,
                "BUILD_CONF": f"linux-{architecture}-server-release",
            },
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        parameters.append(json.loads(output.read_text(encoding="utf-8"))["parameters"])
    assert parameters[0] == parameters[1]
