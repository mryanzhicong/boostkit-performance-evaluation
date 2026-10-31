#!/usr/bin/env bash
# Deterministic workload generation for the GDB performance case.
#
# The workload is split in two parts:
#   * generated inputs (C fixtures, GDB command files, Python script) whose digests
#     are pinned in fixtures/fixtures.json and re-verified on every build;
#   * compiled fixtures and a core file produced here with the host compiler and the
#     freshly built GDB, recorded as evidence (architecture specific by nature).
# The fixed upstream testsuite subset is executed once without timing as a
# correctness gate; the measurement stage repeats exactly the same command.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

FIXTURE_BINARIES=(symbols_1000 symbols_10000 symbols_50000 steps_500 deep_2000)
WORKLOAD_FILE="${CASE_DIR}/fixtures/workload.json"
COMMITTED_FIXTURES="${CASE_DIR}/fixtures/fixtures.json"
baseline_tests_limit() { printf '%s/testsuite-baseline.json\n' "${PERF_WORK_DIR}"; }

generate_workload() {
    local generated="${PERF_WORK_DIR}/fixtures-generated.json"
    if [[ ! -f "${WORKLOAD_FILE}" ]]; then
        fail_message "the committed workload description is missing: ${WORKLOAD_FILE}"
        return 40
    fi
    log_message "generating the deterministic workload in ${FIXTURES_DIR}"
    if ! python3 "${SCRIPT_DIR}/scripts/fixtures/generate_fixtures.py" \
        --output "${FIXTURES_DIR}" --summary "${generated}"; then
        fail_message "failed to generate the deterministic fixture inputs"
        return 40
    fi
    if ! python3 - "${COMMITTED_FIXTURES}" "${generated}" <<'PY'; then
import json
import sys

committed_path, generated_path = sys.argv[1:3]
with open(committed_path, encoding="utf-8") as handle:
    committed = json.load(handle)
with open(generated_path, encoding="utf-8") as handle:
    generated = json.load(handle)
if committed.get("parameters") != generated.get("parameters"):
    raise SystemExit("the generated fixture parameters differ from the committed workload")
if committed.get("fixtures") != generated.get("fixtures"):
    raise SystemExit("the generated fixture digests differ from the committed fixtures")
print("[gdb] fixture digests match the committed fixtures.json")
PY
        fail_message "the generated fixtures do not match the committed digests"
        return 40
    fi
    local sources
    sources="$(count_fixture_sources "${FIXTURES_DIR}")"
    if [[ "${sources}" != "8" ]]; then
        fail_message "expected 8 fixture source files, found ${sources}"
        return 40
    fi
    log_message "workload inputs generated (${sources} sources, digests verified)"
    return 0
}

compile_fixture_binaries() {
    local name
    local cflags
    cflags="$(python3 - "${WORKLOAD_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    workload = json.load(handle)
print(workload["fixture_cflags"])
PY
)"
    if [[ -z "${cflags}" ]]; then
        fail_message "the committed workload does not define the fixture compiler flags"
        return 40
    fi
    for name in "${FIXTURE_BINARIES[@]}"; do
        if [[ ! -f "${FIXTURES_DIR}/${name}.c" ]]; then
            fail_message "the fixture source is missing: ${name}.c"
            return 40
        fi
        log_message "compiling fixture ${name} with: gcc ${cflags}"
        if ! (
            cd "${FIXTURES_DIR}" || exit 1
            gcc ${cflags} -o "${name}" "${name}.c"
        ); then
            fail_message "failed to compile the fixture ${name}"
            return 40
        fi
    done
    FIXTURE_CFLAGS="${cflags}"
    export FIXTURE_CFLAGS
    log_message "compiled ${#FIXTURE_BINARIES[@]} fixture binaries"
    return 0
}

generate_core_file() {
    local core="${FIXTURES_DIR}/$(python3 - "${WORKLOAD_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    workload = json.load(handle)
print(workload["core_file"])
PY
)"
    local frames
    frames="$(python3 - "${WORKLOAD_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    workload = json.load(handle)
print(workload["parameters"]["deep_frames"])
PY
)"
    rm -f "${core}"
    log_message "generating the core file for the deep backtrace scenario"
    if ! (
        cd "${FIXTURES_DIR}" || exit 1
        "${GDB_BIN}" -batch -ex 'break crash_here' -ex run -ex "generate-core-file $(basename "${core}")" deep_2000
    ) > "${PERF_WORK_DIR}/core-generation.log" 2>&1; then
        fail_message "failed to generate the core file (see core-generation.log)"
        return 40
    fi
    if [[ ! -s "${core}" ]]; then
        fail_message "the generated core file is missing or empty: ${core}"
        return 40
    fi
    local loaded_frames
    loaded_frames="$(
        cd "${FIXTURES_DIR}" || exit 1
        "${GDB_BIN}" -batch -ex bt deep_2000 "$(basename "${core}")" 2>/dev/null | wc -l
    )"
    if [[ "${loaded_frames}" -lt "${frames}" ]]; then
        fail_message "the generated core file only yields ${loaded_frames} backtrace lines, expected ${frames}"
        return 40
    fi
    log_message "core file generated (${loaded_frames} backtrace lines from $(basename "${core}"))"
    return 0
}

baseline_testsuite_flags() {
    python3 - "${WORKLOAD_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    workload = json.load(handle)
print(" ".join(workload["testsuite"]["tests"]))
PY
}

run_baseline_testsuite() {
    local tests flags
    tests="$(baseline_testsuite_flags)"
    if [[ -z "${tests}" ]]; then
        fail_message "the committed workload does not define the upstream testsuite subset"
        return 40
    fi
    log_message "running the fixed upstream testsuite subset once (correctness gate): ${tests}"
    rm -f "${GDB_TESTS_SUM}" "${GDB_BUILD_DIR}/gdb/testsuite/gdb.log"
    if ! (
        cd "${GDB_BUILD_DIR}" || exit 1
        make check-gdb MAKEINFO=true RUNTESTFLAGS="${tests}"
    ) > "${PERF_WORK_DIR}/testsuite-baseline.log" 2>&1; then
        fail_message "the upstream testsuite subset failed to run (see testsuite-baseline.log)"
        return 40
    fi
    if ! python3 - "${GDB_TESTS_SUM}" "${WORKLOAD_FILE}" "$(baseline_tests_limit)" <<'PY'; then
import json
import re
import sys

sum_path, workload_path, output_path = sys.argv[1:4]
with open(workload_path, encoding="utf-8") as handle:
    workload = json.load(handle)
minimum = int(workload["testsuite"]["min_expected_passes"])
try:
    text = open(sum_path, encoding="utf-8", errors="replace").read()
except OSError as error:
    raise SystemExit(f"the upstream testsuite summary is missing: {error}")
passes_match = re.search(r"^# of expected passes\s+(\d+)$", text, re.MULTILINE)
failures_match = re.search(r"^# of unexpected failures\s+(\d+)$", text, re.MULTILINE)
if not passes_match:
    raise SystemExit("the upstream testsuite summary has no expected-pass count")
passes = int(passes_match.group(1))
failures = int(failures_match.group(1)) if failures_match else 0
if failures:
    raise SystemExit(f"the upstream testsuite reported {failures} unexpected failures")
if passes < minimum:
    raise SystemExit(f"the upstream testsuite reported {passes} expected passes, expected >= {minimum}")
with open(output_path, "w", encoding="utf-8") as handle:
    json.dump({"expected_passes": passes, "unexpected_failures": failures,
               "tests": workload["testsuite"]["tests"]}, handle, indent=2)
    handle.write("\n")
print(f"[gdb] upstream testsuite baseline: {passes} expected passes, 0 unexpected failures")
PY
        fail_message "the upstream testsuite baseline is not acceptable"
        return 40
    fi
    return 0
}

write_fixture_metadata() {
    local build_seconds="$1"
    local sig_sha256=""
    if [[ -f "${GDB_SOURCE_SIGNATURE}" ]]; then
        sig_sha256="$(sha256sum "${GDB_SOURCE_SIGNATURE}" | awk '{print $1}')"
    fi
    if ! python3 - "${FIXTURE_METADATA}" \
        "${WORKLOAD_FILE}" \
        "${CASE_DIR}/fixtures/fixtures.json" \
        "${GDB_SRC_DIR}" \
        "${GDB_BUILD_DIR}" \
        "${GDB_INSTALL_DIR}" \
        "${GDB_BIN}" \
        "${GDB_PRIVATE_HOME}" \
        "${FIXTURES_DIR}" \
        "${GDB_TESTS_SUM}" \
        "$(baseline_tests_limit)" \
        "${SOFTWARE_VERSION}" \
        "${GDB_VERSION_STRING:-}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${build_seconds}" \
        "${GDB_CONFIGURE_SECONDS:-0}" \
        "${GDB_MAKE_SECONDS:-0}" \
        "${GDB_INSTALL_SECONDS:-0}" \
        "${GDB_BUILD_JOBS}" \
        "${GDB_SOURCE_ARCHIVE}" \
        "${GDB_SOURCE_SHA256}" \
        "${GDB_SOURCE_SIZE}" \
        "${sig_sha256}" \
        "${FIXTURE_CFLAGS:-}" \
        "${GDB_REPS}" \
        "${GDB_WARMUPS}" <<'PY'; then
import hashlib
import json
import os
import subprocess
import sys

(
    output_path,
    workload_path,
    committed_fixtures_path,
    src_dir,
    build_dir,
    install_dir,
    gdb_binary,
    private_home,
    fixtures_dir,
    tests_sum,
    baseline_path,
    version,
    version_string,
    architecture,
    run_id,
    build_seconds,
    configure_seconds,
    make_seconds,
    install_seconds,
    jobs,
    source_archive,
    source_sha256,
    source_size,
    signature_sha256,
    cflags,
    repetitions,
    warmups,
) = sys.argv[1:29]

with open(workload_path, encoding="utf-8") as handle:
    workload = json.load(handle)
with open(committed_fixtures_path, encoding="utf-8") as handle:
    generated = json.load(handle)
with open(baseline_path, encoding="utf-8") as handle:
    baseline = json.load(handle)


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


cc_version = subprocess.run(
    ["gcc", "--version"], capture_output=True, text=True, check=False
).stdout.splitlines()
cc_version_line = cc_version[0] if cc_version else "unknown"
python_version = subprocess.run(
    ["python3", "--version"], capture_output=True, text=True, check=False
).stdout.strip()

binaries = {}
for name in workload["binaries"]:
    path = os.path.join(fixtures_dir, name)
    binaries[name] = {"bytes": os.path.getsize(path), "sha256": sha256_file(path)}

core_name = workload["core_file"]
core_path = os.path.join(fixtures_dir, core_name)

metadata = {
    "software": "gdb",
    "version": version,
    "gdb_version": version.split("-")[0],
    "architecture": architecture,
    "run_id": run_id,
    "version_string": version_string,
    "source": {
        "archive": os.path.basename(source_archive),
        "sha256": source_sha256,
        "bytes": int(source_size),
        "urls": [
            "https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/",
            "https://mirrors.ustc.edu.cn/gnu/gdb/",
            "https://ftp.gnu.org/gnu/gdb/",
        ],
        "signature_sha256": signature_sha256,
    },
    "build": {
        "mode": "source build with an isolated prefix",
        "configure_options": workload["configure_options"],
        "makeinfo_skipped": True,
        "jobs": int(jobs),
        "build_seconds": int(build_seconds),
        "configure_seconds": int(configure_seconds),
        "make_seconds": int(make_seconds),
        "install_seconds": int(install_seconds),
        "source_dir": src_dir,
        "build_dir": build_dir,
        "install_dir": install_dir,
        "prefix": os.path.dirname(os.path.dirname(os.path.dirname(gdb_binary))),
        "gdb_binary": gdb_binary,
        "private_home": private_home,
        "build_dir_removed_after_build": False,
    },
    "toolchain": {
        "cc": cc_version_line,
        "python": python_version,
    },
    "fixtures": {
        "cflags": cflags,
        "binaries": binaries,
        "core_name": core_name,
        "core_bytes": os.path.getsize(core_path),
    },
    "fixtures_generated": generated["fixtures"],
    "fixtures_reference": committed_fixtures_path,
    "expected_fixture_sources": workload["expected_fixture_sources"],
    "expectations": {
        "symbols_small": workload["parameters"]["symbols_small"],
        "symbols_medium": workload["parameters"]["symbols_medium"],
        "symbols_large": workload["parameters"]["symbols_large"],
        "breakpoints": workload["parameters"]["breakpoints"],
        "steps": workload["parameters"]["steps"],
        "lookups": workload["parameters"]["lookups"],
        "deep_frames": workload["parameters"]["deep_frames"],
    },
    "testsuite": {
        "tests": workload["testsuite"]["tests"],
        "min_expected_passes": workload["testsuite"]["min_expected_passes"],
        "baseline_expected_passes": baseline["expected_passes"],
        "baseline_unexpected_failures": baseline["unexpected_failures"],
        "sum_path": tests_sum,
    },
    "measurement": {
        "repetitions": int(repetitions),
        "warmups": int(warmups),
        "statistic": "median of independent repetitions",
        "offline": True,
    },
    "scenarios": {
        scenario["name"]: {
            "kind": scenario["kind"],
            "fixture": scenario["fixture"],
            "command": scenario["command"],
            "expected_sources": workload["expected_fixture_sources"],
        }
        for scenario in workload["scenarios"]
    },
}
with open(output_path, "w", encoding="utf-8") as handle:
    json.dump(metadata, handle, indent=2)
    handle.write("\n")
print(f"[gdb] fixture metadata written with {len(metadata['scenarios'])} scenarios")
PY
        fail_message "failed to write the fixture metadata"
        return 60
    fi
    return 0
}
