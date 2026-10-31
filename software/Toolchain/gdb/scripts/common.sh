#!/usr/bin/env bash
# Shared configuration and helpers for the GDB performance case.
#
# Everything here is architecture neutral: the parameter signature of a run only
# depends on the values recorded by scripts/results/parse_benchmark.py, and those
# must be identical on x86_64 and aarch64.  The GDB source archive checksum, the
# compiler used to build the fixtures and the built binary sizes are evidence, not
# workload parameters.
set -uo pipefail

# SCRIPT_DIR is the case root (software/Toolchain/gdb); the shell libraries live in
# scripts/.  Every entry point therefore sources scripts/common.sh relatively.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASE_DIR="${SCRIPT_DIR}"

SOFTWARE_NAME="gdb"
CATEGORY_NAME="Toolchain"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-18.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-x86_64}"
PERF_VARIANT="${PERF_VARIANT:-base}"

# ---------------------------------------------------------------- source -------
# Official GNU release archive; SHA-256 computed from the mirror download (GNU
# publishes only a detached GPG signature) and pinned here.  The signature file is
# kept next to the archive so the origin can be re-audited.
GDB_SOURCE_SHA256="cd9fc3fe2b47743840e42c1592d3d87f8302eb18639c0b8b4ba0898002e2348f"
GDB_SOURCE_SIZE=22158720
# Pre-placed offline asset directory: when it contains the pinned archive it is
# used (and verified) before any mirror is tried.
GDB_OFFLINE_DIR="${GDB_OFFLINE_DIR:-/home/runner/software/gdb}"
GDB_SOURCE_URLS=(
    "${GDB_OFFLINE_DIR}/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://mirrors.ustc.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
    "https://ftp.gnu.org/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz"
)

# Build prerequisites.  The case builds GDB from source with its bundled readline
# and with the system GMP/MPFR (both are available from the distribution), and it
# disables the components that are not needed for the measured workload.
GDB_CONFIGURE_OPTIONS=(
    --disable-binutils
    --disable-gas
    --disable-ld
    --disable-gprof
    --disable-gold
    --disable-sim
    --disable-tui
    --without-guile
    --without-intel-pt
    --with-system-gmp
    --with-system-mpfr
    --disable-nls
)
GDB_BUILD_JOBS="${GDB_BUILD_JOBS:-$(nproc 2>/dev/null || echo 2)}"
GDB_MAKE_TARGETS=(all install)

# --------------------------------------------------------------- measurement ---
GDB_REPS="${PERF_REPS:-5}"
GDB_WARMUPS=1
# Fixture size of the deterministic workload.  The delivery load is a fixed small
# -g -O0 C program with a function breakpoint; the matrix adds larger symbol tables
# so the measurement is not an artefact of one tiny program.
GDB_SYMBOLS_SMALL=1000
GDB_SYMBOLS_MEDIUM=10000
GDB_SYMBOLS_LARGE=50000
GDB_BREAKPOINTS=200
GDB_STEPS=500
GDB_LOOKUPS=5000
GDB_DEEP_FRAMES=2000
# Fixed upstream testsuite subset (correctness + timing of the real GDB tests).
GDB_TESTSUITE_TESTS=(
    "gdb.python/py-symbol.exp"
    "gdb.python/py-value.exp"
    "gdb.base/break.exp"
)
# Minimum number of expected passes the fixed subset must report.  The exact count
# depends on the target triplet and on optional GDB features, so the parser
# requires a lower bound plus zero unexpected failures instead of an exact number.
GDB_TESTSUITE_MIN_PASSES=12

# Scenario execution order.  The authoritative description of every scenario
# (fixture, command, expected evidence) lives in the metadata file written by the
# build stage and is read by the parser; this list only drives execution.
GDB_SCENARIOS=(
    startup_version
    symbol_load_1000
    symbol_load_50000
    breakpoint_set_200
    step_500
    info_functions_10000
    python_eval_5000
    backtrace_deep_2000
    core_backtrace_2000
    upstream_testsuite_python
)

log_message() {
    printf '[gdb] [%s] %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*"
}

fail_message() {
    printf '[gdb] [%s] ERROR: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

normalize_architecture() {
    case "${EXPECTED_ARCH}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) return 1 ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) return 0 ;;
        *)
            fail_message "unsupported variant: ${PERF_VARIANT} (expected base or optimized)"
            return 10
            ;;
    esac
}

validate_reps() {
    if ! [[ "${GDB_REPS}" =~ ^[0-9]+$ ]] || [[ "${GDB_REPS}" -lt 1 ]]; then
        fail_message "PERF_REPS must be a positive integer, got: ${GDB_REPS}"
        return 10
    fi
    if [[ "${GDB_REPS}" -gt 50 ]]; then
        fail_message "PERF_REPS is unreasonably large: ${GDB_REPS}"
        return 10
    fi
    return 0
}


scenario_kind() {
    case "$1" in
        upstream_testsuite_python) printf 'testsuite\n' ;;
        *) printf 'fixture\n' ;;
    esac
}

scenario_project() {
    case "$1" in
        startup_version) printf 'gdb\n' ;;
        symbol_load_1000) printf 'symbols_1000\n' ;;
        symbol_load_50000) printf 'symbols_50000\n' ;;
        breakpoint_set_200) printf 'symbols_50000\n' ;;
        step_500) printf 'steps_500\n' ;;
        info_functions_10000) printf 'symbols_10000\n' ;;
        python_eval_5000) printf 'symbols_50000\n' ;;
        backtrace_deep_2000) printf 'deep_2000\n' ;;
        core_backtrace_2000) printf 'deep_2000\n' ;;
        upstream_testsuite_python) printf 'testsuite\n' ;;
        *) return 1 ;;
    esac
}

# The recorded command is a description of the workload (relative, reproducible on
# both architectures); the absolute work-directory paths only exist in the raw
# per-repetition logs.
scenario_command_text() {
    case "$1" in
        startup_version) printf 'gdb --version\n' ;;
        symbol_load_1000) printf "gdb -batch -ex 'info functions fn_00042' -ex quit symbols_1000\n" ;;
        symbol_load_50000) printf "gdb -batch -ex 'info functions fn_49975' -ex quit symbols_50000\n" ;;
        breakpoint_set_200) printf 'gdb -batch -x breakpoints.cmd symbols_50000\n' ;;
        step_500) printf 'gdb -batch -x steps.cmd steps_500\n' ;;
        info_functions_10000) printf "gdb -batch -ex 'info functions' symbols_10000 | wc -l\n" ;;
        python_eval_5000) printf 'gdb -batch -x python_eval.py symbols_50000\n' ;;
        backtrace_deep_2000) printf "gdb -batch -ex 'break crash_here' -ex run -ex bt deep_2000 | wc -l\n" ;;
        core_backtrace_2000) printf 'gdb -batch -ex bt deep_2000 deep_2000.core | wc -l\n' ;;
        upstream_testsuite_python) printf 'make check-gdb RUNTESTFLAGS="gdb.python/py-symbol.exp gdb.python/py-value.exp gdb.python/py-breakpoint.exp"\n' ;;
        *) return 1 ;;
    esac
}

# Interactive scenarios that need a command file rather than -ex options.
scenario_script() {
    case "$1" in
        breakpoint_set_200) printf 'breakpoints.cmd\n' ;;
        step_500) printf 'steps.cmd\n' ;;
        python_eval_5000) printf 'python_eval.py\n' ;;
        *) return 1 ;;
    esac
}

scenario_binary() {
    case "$1" in
        symbol_load_1000) printf 'symbols_1000\n' ;;
        symbol_load_50000) printf 'symbols_50000\n' ;;
        breakpoint_set_200) printf 'symbols_50000\n' ;;
        step_500) printf 'steps_500\n' ;;
        info_functions_10000) printf 'symbols_10000\n' ;;
        python_eval_5000) printf 'symbols_50000\n' ;;
        backtrace_deep_2000) printf 'deep_2000\n' ;;
        core_backtrace_2000) printf 'deep_2000\n' ;;
        *) return 1 ;;
    esac
}

configure_runtime_paths() {
    local arch
    arch="$(normalize_architecture)" || {
        fail_message "unsupported architecture: ${EXPECTED_ARCH}"
        return 10
    }
    EXPECTED_ARCH="${arch}"
    RESULTS_DIR="${RESULTS_DIR:-${CASE_DIR}/results}"
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    if [[ -z "${PERF_WORK_DIR:-}" ]]; then
        # Standalone entry point: keep the work directory clearly marked as local so
        # that a copy of the case outside the repository cleans up only its own
        # directory.  The framework always provides PERF_WORK_DIR.
        PERF_WORK_DIR="/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"

    RUNS_DIR="${RESULTS_DIR}/runs"
    GDB_SRC_DIR="${PERF_WORK_DIR}/gdb-src"
    GDB_BUILD_DIR="${PERF_WORK_DIR}/gdb-build"
    GDB_INSTALL_DIR="${PERF_WORK_DIR}/gdb-install"
    GDB_BIN="${GDB_INSTALL_DIR}/bin/gdb"
    GDB_PRIVATE_HOME="${PERF_WORK_DIR}/home"
    FIXTURES_DIR="${PERF_WORK_DIR}/fixtures"
    FIXTURE_METADATA="${PERF_WORK_DIR}/fixtures-metadata.json"
    GDB_SOURCE_ARCHIVE="${PERF_WORK_DIR}/assets/gdb-${SOFTWARE_VERSION}.tar.xz"
    GDB_SOURCE_SIGNATURE="${PERF_WORK_DIR}/assets/gdb-${SOFTWARE_VERSION}.tar.xz.sig"
    GDB_TESTS_SUM="${GDB_BUILD_DIR}/gdb/testsuite/gdb.sum"
    GDB_WORK_ASSETS="${PERF_WORK_DIR}/assets"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR RUNS_DIR
    export PERF_WORK_DIR PERF_ACTUAL_VERSION_FILE STANDALONE_OWNS_WORK_DIR
    export GDB_SRC_DIR GDB_BUILD_DIR GDB_INSTALL_DIR GDB_BIN GDB_PRIVATE_HOME
    export FIXTURES_DIR FIXTURE_METADATA GDB_SOURCE_ARCHIVE GDB_SOURCE_SIGNATURE
    export GDB_TESTS_SUM GDB_SOURCE_SHA256 GDB_SOURCE_SIZE GDB_OFFLINE_DIR
    GDB_FIXTURE_METADATA=${FIXTURE_METADATA}
    export GDB_FIXTURE_METADATA
    export GDB_REPS GDB_WARMUPS GDB_SYMBOLS_SMALL GDB_SYMBOLS_MEDIUM GDB_SYMBOLS_LARGE
    export GDB_BREAKPOINTS GDB_STEPS GDB_LOOKUPS GDB_DEEP_FRAMES
    export GDB_TESTSUITE_MIN_PASSES GDB_BUILD_JOBS
    return 0
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${RUNS_DIR}" "${PERF_WORK_DIR}" "${GDB_PRIVATE_HOME}" \
        "${GDB_WORK_ASSETS}" "${FIXTURES_DIR}" || {
        fail_message "failed to create the work directories under ${PERF_WORK_DIR}"
        return 20
    }
    return 0
}

# Count the committed fixture inputs (C sources, command files, Python script).  The
# measured runs must see exactly this many inputs, so a run against an incomplete
# fixture tree is rejected.
count_fixture_sources() {
    local directory="$1"
    find "${directory}" -maxdepth 1 -type f \
        \( -name '*.c' -o -name '*.h' -o -name '*.cmd' -o -name '*.py' \) \
        2>/dev/null | wc -l
}

fixture_deep_frames() {
    printf '%s\n' "${GDB_DEEP_FRAMES}"
}
