"""Keep every framework stage on the same task-owned container."""

from __future__ import annotations

import json
import re
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
SCRIPTS = CASE / "scripts"
FIXTURES = CASE / "fixtures/scenarios.json"


def read(path: str) -> str:
    return (SCRIPTS / path).read_text(encoding="utf-8")


def bash_array(text: str, name: str) -> list[str]:
    match = re.search(rf"^{name}=\((.*?)\)\s*$", text, re.MULTILINE | re.DOTALL)
    assert match, name
    return match.group(1).split()


def fixtures() -> dict:
    return json.loads(FIXTURES.read_text(encoding="utf-8"))


def test_only_build_loads_image_and_starts_container() -> None:
    build = read("builders/base.sh") + read("builders/optimized.sh")
    start = read("stages/start.sh")
    test = read("stages/test.sh")
    stop = read("stages/stop.sh")

    assert "require_rapidjson_docker" in build
    assert "start_rapidjson_container" in build
    assert "require_rapidjson_docker" not in start + test
    assert "start_rapidjson_container" not in start + test
    assert "check_rapidjson_container" in start
    assert "check_rapidjson_container" in test
    assert "remove_rapidjson_container" in stop


def test_build_runs_inside_the_container() -> None:
    build = read("builders/base.sh")
    for needle in (
        "rapidjson_container_exec_root dnf install",
        "rapidjson_container_exec tar xzf",
        "rapidjson_container_exec cmake -S",
        'bash -c \'cmake --build "$1" -j "$(nproc)" --target perftest unittest\'',
        '"${build}/bin/perftest"',
    ):
        assert needle in build, needle


def test_container_name_and_label_are_task_owned() -> None:
    common = read("common.sh")
    assert 'boostkit-rapidjson-${arch}-${PERF_RUN_ID}' in common
    assert 'boostkit.rapidjson.run-id=${PERF_RUN_ID}' in common
    assert 'boostkit.rapidjson.run-id' in read("stages/start.sh")
    assert 'docker rm --force' in common  # stale sweeps only touch labelled containers
    assert 'boostkit-rapidjson-' in common


def test_container_removal_is_idempotent_and_label_guarded() -> None:
    common = read("common.sh")
    stop = read("stages/stop.sh")
    match = re.search(r"^remove_rapidjson_container\(\) \{(.*?)^\}", common, re.MULTILINE | re.DOTALL)
    assert match
    body = match.group(1)
    assert "docker container inspect" in body
    assert "run-id" in body
    assert "return 60" in body
    assert "rm -rf" not in stop


def test_every_scenario_runs_through_docker_exec() -> None:
    test = read("stages/test.sh")
    common = read("common.sh")
    assert len(bash_array(common, "RAPIDJSON_SCENARIOS")) == len(fixtures()["scenarios"])
    assert 'for index in "${!RAPIDJSON_SCENARIOS[@]}"' in test
    assert 'rapidjson_benchmark_once "${scenario}" "${RAPIDJSON_SCENARIO_CASES[index]}" "${i}"' in test
    assert "rapidjson_container_exec_at" in test
    assert "--gtest_repeat=5" in test
    assert '--gtest_output=xml:"${out}.xml"' in test
    assert '2> "${out}.err"' in test
    assert "timeout 600" in test


def test_filters_enumerate_architecture_suffixes_explicitly() -> None:
    common = read("common.sh")
    suffixes = bash_array(common, "RAPIDJSON_ARCH_SUFFIXES")
    assert suffixes == fixtures()["architecture_suffixes"]
    assert 'out+="RapidJson.${case_name}_${suffix}"' in common
    # A wildcard would also match sibling cases such as Writer_StringBuffer_Booleans.
    assert "RapidJson.${case_name}_*" not in common
    assert ".${case_name}_*" not in common


def test_scenario_table_matches_fixtures() -> None:
    common = read("common.sh")
    data = fixtures()
    assert bash_array(common, "RAPIDJSON_SCENARIOS") == [item["name"] for item in data["scenarios"]]
    assert bash_array(common, "RAPIDJSON_SCENARIO_CASES") == [item["case"] for item in data["scenarios"]]
    assert len(data["scenarios"]) == 8


def test_optimized_patch_is_pinned_and_never_falls_back() -> None:
    common = read("common.sh")
    optimized = read("builders/optimized.sh")
    assert "748f35b0a78feaa2b80ae8dc6852796611d51528ca5082cf0d595cf2e347ddba" in common
    assert "RAPIDJSON_PATCH_BYTES=12053" in common
    assert "rapidjson_verify_patch" in optimized
    assert "refusing to fall back to base" in common
    assert (CASE / "fixtures/kunpeng_opti_v1.0.0.patch").is_file()


def test_optimized_variant_is_implemented() -> None:
    optimized = read("builders/optimized.sh")
    assert "build_rapidjson_optimized" in optimized
    assert "not implemented" not in optimized
    assert "rapidjson_apply_patch" in optimized
    common = read("common.sh")
    assert "rapidjson_apply_patch()" in read("builders/base.sh")
    # Only aarch64 adds the Kunpeng compilation flags.
    base = read("builders/base.sh")
    assert 'extra=" -march=armv8.2-a+simd -DRAPIDJSON_NEON"' in base
    assert '"${variant}" == "optimized" && "${arch}" == "aarch64"' in base


def test_build_variant_records_all_sources_and_effective_flags() -> None:
    common = read("common.sh")
    for needle in (
        "image_archive_sha256",
        "effective_cxx_flags",
        "architecture_macros",
        "test/perftest/CMakeFiles/perftest.dir/flags.make",
    ):
        assert needle in common, needle
    readme = (CASE / "README.md").read_text(encoding="utf-8")
    assert "四份来源" in readme


def test_no_hardcoded_cpu_pinning() -> None:
    for relative in ("builders/base.sh", "stages/start.sh", "stages/test.sh"):
        text = read(relative)
        assert "taskset" not in text
        assert "numactl" not in text
        assert "--cpuset" not in text


def test_sampling_contract_matches_readme() -> None:
    common = read("common.sh")
    test = read("stages/test.sh")
    assert 'PERF_REPS="${PERF_REPS:-5}"' in common
    assert 'RAPIDJSON_WARMUPS="${RAPIDJSON_WARMUPS:-1}"' in common
    assert "at least 5 measured rounds" in test
    assert "PERF_REPS=5" not in test
    readme = (CASE / "README.md").read_text(encoding="utf-8")
    assert "指标总数 **16 项**" in readme
    assert "1 次预热 + 5 次采样" in readme


def test_case_yaml_declares_the_readme_outputs() -> None:
    case = (CASE / "case.yaml").read_text(encoding="utf-8")
    for needle in (
        "path: build_variant.json",
        "path: raw-output.log",
        "path: perftest_result.json",
        "path: unittest.log",
        "path: runs",
        "path: results",
        "value_path: value",
        "unit_path: unit",
        "direction_path: direction",
        "group_path: group",
    ):
        assert needle in case, needle
    assert "source: benchmark_result" in case


def test_standalone_places_optimized_results_below_base() -> None:
    entry = (CASE / "rapidjson_test.sh").read_text(encoding="utf-8")
    assert 'RESULTS_DIR="${RESULTS_DIR}/optimized"' in entry
    assert "rapidjson_initialize_runtime" in entry
    assert "standalone_runtime.py" in entry


def test_standalone_rejects_unknown_variant(tmp_path) -> None:
    import subprocess

    result = subprocess.run(
        ["bash", str(CASE / "rapidjson_test.sh"), "--variant", "bogus",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "unsupported build variant" in result.stdout + result.stderr


def test_standalone_rejects_unsupported_version(tmp_path) -> None:
    import subprocess

    result = subprocess.run(
        ["bash", str(CASE / "rapidjson_test.sh"), "--version", "9.9.9",
         "--results-dir", str(tmp_path / "results")],
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == 10, result.stdout + result.stderr
    assert "only rapidjson 1.1.0 is supported" in result.stdout + result.stderr
