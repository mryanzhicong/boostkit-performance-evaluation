#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="gmp"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.3.0}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

GMP_VERSION="${SOFTWARE_VERSION}"
GMP_ARCHIVE_NAME="gmp-${GMP_VERSION}.tar.xz"
# Official GNU GMP 6.3.0 release archive digest.  The same digest is checked for
# every source (offline directory, mirrors and the official GNU servers).
GMP_ARCHIVE_SHA256="a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"

# Download order: pre-placed offline directory (the dedicated runner may not
# reach the internet), then mirrors reachable from the restricted network, then
# the official GNU servers.
GMP_OFFLINE_DIR="${PERF_GMP_OFFLINE_DIR:-/home/runner/software/gmp}"
GMP_MIRROR_URLS=(
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://mirrors.huaweicloud.com/gnu/gmp/${GMP_ARCHIVE_NAME}"
)
GMP_OFFICIAL_URLS=(
    "https://ftp.gnu.org/gnu/gmp/${GMP_ARCHIVE_NAME}"
    "https://ftpmirror.gnu.org/gmp/${GMP_ARCHIVE_NAME}"
)

GMP_BUILD_JOBS="${PERF_GMP_JOBS:-4}"
GMP_REPS="${PERF_REPS:-5}"
GMP_WARMUP_REPS="${PERF_WARMUP_REPS:-1}"
GMP_CONFIGURE_OPTIONS=(--disable-shared --enable-static)

# One upstream tune/speed routine at one operand size per scenario.  Sizes are
# limbs for the mpn_* routines and bits for the mpz_* routines, which is exactly
# how tune/speed defines its -s option.
GMP_SCENARIOS=(
    mpn_mul_n_512
    mpn_mul_n_2048
    mpn_mul_n_8192
    mpn_sqr_4096
    mpn_add_n_8192
    mpn_div_qr_2n_2048
    mpn_div_qr_2n_8192
    mpz_add_2048
    mpz_add_8192
)
# tune/speed aborts a measurement when it cannot get four timings within 1%
# (it then prints "n/a" instead of a value).  Under a busy CI host this can
# happen for an otherwise healthy build, so one repetition is retried up to this
# many times; the retry only happens when upstream itself produced no value.
GMP_MAX_ATTEMPTS="${PERF_GMP_ATTEMPTS:-6}"

GMP_ARCHIVE=""
GMP_SOURCE_DIR=""
GMP_PREFIX=""
GMP_SPEED_BIN=""
GMP_VERSION_STRING=""
RUNS_DIR=""
LOG_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[gmp] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

normalize_architecture() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || {
        log_message "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    }
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/gmp/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    GMP_ARCHIVE="${PERF_WORK_DIR}/src/${GMP_ARCHIVE_NAME}"
    GMP_SOURCE_DIR="${PERF_WORK_DIR}/src/gmp-${GMP_VERSION}"
    GMP_PREFIX="${PERF_WORK_DIR}/prefix"
    GMP_SPEED_BIN="${GMP_SOURCE_DIR}/tune/speed"
    RUNS_DIR="${RESULTS_DIR}/runs"
    LOG_DIR="${RESULTS_DIR}/logs"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR GMP_REPS
}

initialize_runtime() {
    configure_runtime_paths
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${RUNS_DIR}" "${LOG_DIR}" \
        "${PERF_WORK_DIR}/src" "${GMP_PREFIX}" "${TMPDIR}"
}

scenario_routine() {
    case "${1}" in
        mpn_mul_n_512|mpn_mul_n_2048|mpn_mul_n_8192) printf 'mpn_mul_n\n' ;;
        mpn_sqr_4096) printf 'mpn_sqr\n' ;;
        mpn_add_n_8192) printf 'mpn_add_n\n' ;;
        mpn_div_qr_2n_2048|mpn_div_qr_2n_8192) printf 'mpn_div_qr_2n\n' ;;
        mpz_add_2048|mpz_add_8192) printf 'mpz_add\n' ;;
        *) return 1 ;;
    esac
}

scenario_size() {
    case "${1}" in
        mpn_mul_n_512) printf '512\n' ;;
        mpn_mul_n_2048) printf '2048\n' ;;
        mpn_mul_n_8192) printf '8192\n' ;;
        mpn_sqr_4096) printf '4096\n' ;;
        mpn_add_n_8192) printf '8192\n' ;;
        mpn_div_qr_2n_2048) printf '2048\n' ;;
        mpn_div_qr_2n_8192) printf '8192\n' ;;
        mpz_add_2048) printf '2048\n' ;;
        mpz_add_8192) printf '8192\n' ;;
        *) return 1 ;;
    esac
}

scenario_unit() {
    case "${1}" in
        mpn_*) printf 'limbs\n' ;;
        mpz_*) printf 'bits\n' ;;
        *) return 1 ;;
    esac
}

verify_sha256() {
    local file="$1" expected="$2" actual
    [[ -f "${file}" ]] || {
        log_message "ERROR: archive is missing: ${file}"
        return 1
    }
    actual="$(sha256sum -- "${file}" | awk '{print $1}')" || {
        log_message "ERROR: cannot hash ${file}"
        return 1
    }
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: SHA-256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 1
    fi
    return 0
}

download_gmp_archive() {
    local destination="$1"
    local temporary="${destination}.part"
    local attempts=() entry url
    local ok=0

    if [[ -d "${GMP_OFFLINE_DIR}" ]]; then
        entry="${GMP_OFFLINE_DIR}/${GMP_ARCHIVE_NAME}"
        if [[ -f "${entry}" ]]; then
            log_message "using pre-placed offline archive: ${entry}"
            if cp -f -- "${entry}" "${temporary}" && verify_sha256 "${temporary}" "${GMP_ARCHIVE_SHA256}"; then
                ok=1
            else
                attempts+=("${entry} (digest mismatch)")
            fi
        else
            attempts+=("${entry} (missing)")
        fi
    else
        attempts+=("${GMP_OFFLINE_DIR} (missing directory)")
    fi

    if [[ "${ok}" -ne 1 ]]; then
        for url in "${GMP_MIRROR_URLS[@]}" "${GMP_OFFICIAL_URLS[@]}"; do
            log_message "downloading ${url}"
            rm -f -- "${temporary}"
            if curl -fsSL --retry 2 --retry-delay 2 --connect-timeout 20 \
                --max-time 900 -o "${temporary}" "${url}"; then
                if verify_sha256 "${temporary}" "${GMP_ARCHIVE_SHA256}"; then
                    ok=1
                    break
                fi
                attempts+=("${url} (digest mismatch)")
            else
                attempts+=("${url} (download failed)")
            fi
        done
    fi

    if [[ "${ok}" -ne 1 ]]; then
        log_message "ERROR: cannot obtain ${GMP_ARCHIVE_NAME} with the pinned SHA-256"
        log_message "  expected SHA-256: ${GMP_ARCHIVE_SHA256}"
        for entry in "${attempts[@]}"; do
            log_message "  attempted: ${entry}"
        done
        rm -f -- "${temporary}"
        return 30
    fi
    mv -f -- "${temporary}" "${destination}"
    log_message "verified ${GMP_ARCHIVE_NAME} (SHA-256 ${GMP_ARCHIVE_SHA256})"
}

require_build_commands() {
    local command_name package
    local missing=()
    for command_name in gcc make tar xz curl sha256sum awk sed; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            gcc) package="gcc" ;;
            make) package="make" ;;
            tar) package="tar" ;;
            xz) package="xz" ;;
            curl) package="curl" ;;
            sha256sum|awk|sed) package="coreutils" ;;
        esac
        log_message "missing required build command: ${command_name} (package ${package})"
        missing+=("${package}")
    done
    if [[ "${#missing[@]}" -eq 0 ]]; then
        return 0
    fi

    if command -v dnf >/dev/null 2>&1; then
        log_message "installing build prerequisites with dnf: ${missing[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf install -y "${missing[@]}" || log_message "WARNING: dnf install failed"
        elif command -v sudo >/dev/null 2>&1; then
            sudo -n dnf install -y "${missing[@]}" || log_message "WARNING: dnf install failed"
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        log_message "installing build prerequisites with apt: ${missing[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            apt-get install -y "${missing[@]}" || log_message "WARNING: apt-get install failed"
        elif command -v sudo >/dev/null 2>&1; then
            sudo -n apt-get install -y "${missing[@]}" || log_message "WARNING: apt-get install failed"
        fi
    fi

    for command_name in gcc make tar xz curl sha256sum awk sed; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required build command is unavailable: ${command_name}"
            return 30
        fi
    done
}
