#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc|stat) printf 'coreutils\n' ;;
        cc) printf 'gcc\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

require_commands() {
    local missing=() packages=() cmd
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    (( ${#missing[@]} == 0 )) && return 0
    log_message "missing commands: ${missing[*]}"
    if command -v dnf >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do
            packages+=("$(package_for_command "${cmd}")")
        done
        local dnf_options=()
        [[ -n "${PERF_PROXY:-}" ]] && dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for cmd in "${missing[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still unavailable: ${cmd}"
            return 30
        fi
    done
}

verify_sha256() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified sha256 $(basename "${file}")"
}

download_asset() {
    local url="$1" destination="$2"
    local candidates=("${url}")
    if [[ -n "${PERF_CMAKE_MIRROR}" ]]; then
        candidates+=("${PERF_CMAKE_MIRROR%/}/${url}")
    fi
    local candidate
    for candidate in "${candidates[@]}"; do
        log_message "downloading ${candidate}"
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -o "${destination}.part" "${candidate}"; then
            mv -- "${destination}.part" "${destination}"
            return 0
        fi
        rm -f -- "${destination}.part"
        log_message "download failed: ${candidate}"
    done
    return 30
}

# Resolve one pinned archive: re-use a verified copy, prefer the pre-placed
# offline asset, then fall back to the official URL (and the optional mirror).
materialize_asset() {
    local name="$1" url="$2" expected="$3" destination="$4"
    local offline="${CMAKE_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        if verify_sha256 "${destination}" "${expected}"; then
            return 0
        fi
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
        if verify_sha256 "${destination}" "${expected}"; then
            return 0
        fi
        log_message "ERROR: pre-placed offline asset is not the official archive: ${offline}"
        rm -f -- "${destination}"
        return 30
    fi
    download_asset "${url}" "${destination}" || {
        log_message "ERROR: could not obtain ${name} from ${url}"
        return 30
    }
    verify_sha256 "${destination}" "${expected}"
}

install_cmake() {
    if [[ -x "${CMAKE_BIN}" ]]; then
        local installed
        installed="$(cmake_version_string 2>/dev/null | awk '{print $3; exit}')" || installed=""
        if [[ "${installed}" == "${SOFTWARE_VERSION}" ]]; then
            log_message "reusing CMake ${installed} at ${CMAKE_HOME}"
            return 0
        fi
        log_message "removing unexpected CMake ${installed:-unknown} at ${CMAKE_HOME}"
        rm -rf -- "${CMAKE_HOME}"
    fi
    local archive="${PERF_WORK_DIR}/downloads/${CMAKE_ARCHIVE_NAME}"
    materialize_asset "${CMAKE_ARCHIVE_NAME}" "${CMAKE_ARCHIVE_URL}" \
        "${CMAKE_ARCHIVE_SHA256}" "${archive}" || return $?
    mkdir -p "${CMAKE_HOME}"
    log_message "extracting ${CMAKE_ARCHIVE_NAME} to ${CMAKE_HOME}"
    tar -xzf "${archive}" -C "${CMAKE_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the CMake distribution"
        return 30
    }
    chmod +x "${CMAKE_BIN}" "${CMAKE_HOME}/bin/ctest" "${CMAKE_HOME}/bin/cpack" 2>/dev/null || true
    [[ -x "${CMAKE_BIN}" ]] || {
        log_message "ERROR: extracted CMake distribution has no executable bin/cmake"
        return 30
    }
}

install_cmake_source() {
    local marker="${CMAKE_SOURCE_DIR}/.cmake-source-version"
    if [[ -f "${marker}" && -d "${CMAKE_SOURCE_DIR}/Source" ]]; then
        if [[ "$(<"${marker}")" == "${SOFTWARE_VERSION}" ]]; then
            log_message "reusing extracted CMake ${SOFTWARE_VERSION} sources at ${CMAKE_SOURCE_DIR}"
            return 0
        fi
    fi
    materialize_asset "${CMAKE_SOURCE_NAME}" "${CMAKE_SOURCE_URL}" \
        "${CMAKE_SOURCE_SHA256}" "${CMAKE_SOURCE_ARCHIVE}" || return $?
    rm -rf -- "${CMAKE_SOURCE_DIR}"
    mkdir -p "${CMAKE_SOURCE_DIR}"
    log_message "extracting ${CMAKE_SOURCE_NAME} to ${CMAKE_SOURCE_DIR}"
    tar -xzf "${CMAKE_SOURCE_ARCHIVE}" -C "${CMAKE_SOURCE_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the CMake source archive"
        return 30
    }
    if [[ ! -f "${CMAKE_SOURCE_DIR}/CMakeLists.txt" || \
          ! -d "${CMAKE_SOURCE_DIR}/Source" ]]; then
        log_message "ERROR: extracted CMake sources have an unexpected layout"
        return 30
    fi
    printf '%s\n' "${SOFTWARE_VERSION}" > "${marker}"
    # Keep a pristine copy of the leaf source used by the upstream incremental
    # scenario so every repetition (and every repeated run) rewrites exactly the
    # same base content plus one deterministic marker line.
    cp -- "${CMAKE_SOURCE_DIR}/${CMAKE_UPSTREAM_INCREMENTAL_SOURCE}" \
        "${CMAKE_INCREMENTAL_SOURCE_ORIG}" || {
        log_message "ERROR: upstream incremental source is missing: ${CMAKE_UPSTREAM_INCREMENTAL_SOURCE}"
        return 40
    }
}

record_actual_version() {
    local version_line version_value
    if ! version_line="$(cmake_version_string)"; then
        log_message "ERROR: failed to execute ${CMAKE_BIN} --version"
        return 40
    fi
    version_value="$(printf '%s\n' "${version_line}" | awk '{print $3; exit}')"
    if [[ ! "${version_value}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "ERROR: could not parse the CMake version from: ${version_line}"
        return 40
    fi
    if [[ "${version_value}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested CMake ${SOFTWARE_VERSION} but installed ${version_value}"
        return 40
    fi
    CMAKE_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version_value}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual CMake version: ${version_value}"
    log_message "runtime: ${version_line}"
    log_message "C compiler: $(compiler_identity)"
}

generate_projects() {
    local scale project
    for scale in "${CMAKE_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        log_message "generating deterministic C project with ${scale} sources"
        mkdir -p "${PROJECTS_DIR}"
        python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${project}" --sources "${scale}" || return 40
        local source_count
        source_count="$(find "${project}/src" -maxdepth 1 -type f -name 'unit_*.c' | wc -l)"
        if [[ "${source_count}" -ne "${scale}" ]]; then
            log_message "ERROR: project ${scale} has ${source_count} sources, expected ${scale}"
            return 40
        fi
    done
}

smoke_check_generated_project() {
    local project="${PROJECTS_DIR}/project-100"
    local build="${BENCH_DIR}/smoke"
    rm -rf -- "${build}"
    log_message "smoke check: configure and build the 100-source project"
    "${CMAKE_BIN}" -S "${project}" -B "${build}" "${PROJECT_CONFIGURE_ARGV[@]}" \
        >"${PERF_WORK_DIR}/smoke-configure.log" 2>&1 || {
        log_message "ERROR: smoke configure failed; see ${PERF_WORK_DIR}/smoke-configure.log"
        return 40
    }
    "${CMAKE_BIN}" --build "${build}" -j "${CMAKE_JOBS}" \
        >"${PERF_WORK_DIR}/smoke-build.log" 2>&1 || {
        log_message "ERROR: smoke build failed; see ${PERF_WORK_DIR}/smoke-build.log"
        return 40
    }
    if [[ ! -x "${build}/bench" ]]; then
        log_message "ERROR: smoke build did not produce the bench executable"
        return 40
    fi
    rm -rf -- "${build}"
    log_message "smoke check passed"
}

build_cmake_base() {
    initialize_runtime || return $?
    require_commands curl tar gzip sha256sum awk make cc python3 || return $?
    install_cmake || return $?
    install_cmake_source || return $?
    record_actual_version || return $?
    generate_projects || return $?
    smoke_check_generated_project || return $?
    log_message "base build completed: CMake ${SOFTWARE_VERSION}, $(compiler_identity), builds with -j${CMAKE_JOBS}"
}
