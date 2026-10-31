#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|wc|basename|dirname|nproc|stat) printf 'coreutils\n' ;;
        find) printf 'findutils\n' ;;
        /usr/bin/time) printf 'time\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

require_commands() {
    local missing=() packages=() cmd
    for cmd in "$@"; do
        if [[ "${cmd}" == /* ]]; then
            [[ -x "${cmd}" ]] || missing+=("${cmd}")
        else
            command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
        fi
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
        if [[ "${cmd}" == /* ]]; then
            if [[ ! -x "${cmd}" ]]; then
                log_message "ERROR: required command is still unavailable: ${cmd}"
                return 30
            fi
        elif ! command -v "${cmd}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still unavailable: ${cmd}"
            return 30
        fi
    done
}

verify_sha256() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "checksum mismatch for ${file}"
        log_message "  expected sha256: ${expected}"
        log_message "  actual sha256:   ${actual}"
        return 30
    fi
    log_message "verified sha256 $(basename "${file}")"
}

materialize_asset() {
    local name="$1" destination="$2" expected="$3"
    shift 3
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        if verify_sha256 "${destination}" "${expected}"; then
            return 0
        fi
        log_message "discarding cached asset with an unexpected checksum: ${destination}"
        rm -f -- "${destination}"
    fi
    local offline="${LUA_OFFLINE_DIR}/${name}"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}.part"
        if verify_sha256 "${destination}.part" "${expected}"; then
            mv -- "${destination}.part" "${destination}"
            return 0
        fi
        log_message "ERROR: pre-placed offline asset has a wrong checksum: ${offline}"
        rm -f -- "${destination}.part"
    fi
    local url
    for url in "$@"; do
        log_message "downloading ${url}"
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -o "${destination}.part" "${url}"; then
            if verify_sha256 "${destination}.part" "${expected}"; then
                mv -- "${destination}.part" "${destination}"
                return 0
            fi
            log_message "ERROR: checksum mismatch for ${url}"
        else
            log_message "WARNING: download failed: ${url}"
        fi
        rm -f -- "${destination}.part"
    done
    log_message "ERROR: could not obtain a verified copy of ${name}"
    log_message "  tried offline directory: ${LUA_OFFLINE_DIR}"
    log_message "  tried URLs: $*"
    return 30
}

fetch_source() {
    local archive="${LUA_DOWNLOADS_DIR}/${LUA_SOURCE_NAME}"
    [[ -f "${archive}" ]] || {
        log_message "ERROR: verified source archive is missing: ${archive}"
        return 30
    }
    rm -rf -- "${LUA_SRC_DIR}"
    mkdir -p "${LUA_SRC_DIR}"
    log_message "extracting ${LUA_SOURCE_NAME} to ${LUA_SRC_DIR}"
    tar -xzf "${archive}" -C "${LUA_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Lua source archive"
        return 30
    }
    [[ -f "${LUA_SRC_DIR}/src/lua.c" && -f "${LUA_SRC_DIR}/Makefile" ]] || {
        log_message "ERROR: extracted Lua sources are incomplete"
        return 30
    }
}

fetch_testsuite() {
    local archive="${LUA_DOWNLOADS_DIR}/${LUA_TESTSUITE_NAME}"
    [[ -f "${archive}" ]] || {
        log_message "ERROR: verified test-suite archive is missing: ${archive}"
        return 30
    }
    rm -rf -- "${LUA_TESTS_DIR}"
    mkdir -p "${LUA_TESTS_DIR}"
    log_message "extracting ${LUA_TESTSUITE_NAME} to ${LUA_TESTS_DIR}"
    tar -xzf "${archive}" -C "${LUA_TESTS_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Lua test suite"
        return 30
    }
    [[ -f "${LUA_TESTS_DIR}/all.lua" ]] || {
        log_message "ERROR: extracted test suite is missing all.lua"
        return 30
    }
}

build_lua() {
    local build_log="${PERF_WORK_DIR}/lua-build.log"
    log_message "building Lua ${SOFTWARE_VERSION} with: make ${LUA_BUILD_TARGET} (CC=gcc -std=gnu99, CFLAGS=-O2 -Wall -Wextra)"
    (
        cd "${LUA_SRC_DIR}" || exit 1
        unset MAKEFLAGS MFLAGS
        make "${LUA_BUILD_TARGET}"
    ) 2>&1 | tee "${build_log}" || {
        log_message "ERROR: Lua build failed; see ${build_log}"
        tail -n 20 "${build_log}" >&2 || true
        return 30
    }
    if [[ ! -x "${LUA_BIN}" || ! -x "${LUAC_BIN}" ]]; then
        log_message "ERROR: the build did not produce the lua and luac executables"
        return 30
    fi
}

record_actual_version() {
    local version_line version luac_version
    version_line="$("${LUA_BIN}" -v 2>&1)" || {
        log_message "ERROR: failed to execute ${LUA_BIN} -v"
        return 40
    }
    version="$(printf '%s\n' "${version_line}" | awk '{print $2; exit}')"
    if [[ -z "${version}" ]]; then
        log_message "ERROR: could not parse the version from lua -v"
        printf '%s\n' "${version_line}" | sed -n '1,3p'
        return 40
    fi
    luac_version="$("${LUAC_BIN}" -v 2>&1 | awk '{print $2; exit}')" || {
        log_message "ERROR: failed to execute ${LUAC_BIN} -v"
        return 40
    }
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Lua ${SOFTWARE_VERSION} but built ${version}"
        return 40
    fi
    if [[ "${luac_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: luac reports ${luac_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    LUA_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Lua version: ${version}"
    log_message "runtime: ${version_line}"
}

generate_sources() {
    local generator_log="${PERF_WORK_DIR}/generate-sources.log"
    rm -rf -- "${LUA_GENERATED_DIR}"
    log_message "generating ${LUA_GENERATED_MODULES} deterministic Lua modules for the luac scenario"
    python3 "${SCRIPT_DIR}/scripts/generate_sources.py" \
        --output "${LUA_GENERATED_DIR}" \
        --modules "${LUA_GENERATED_MODULES}" 2>&1 | tee "${generator_log}" || {
        log_message "ERROR: failed to generate the luac workload sources"
        return 30
    }
    local generated expected count
    generated="$(grep -oE 'expected checksum: [0-9]+' "${generator_log}" | awk '{print $3}')"
    if ! expected="$(scenario_expected_checksum luac_compile)"; then
        log_message "ERROR: benchmarks/scenarios.tsv has no luac_compile row"
        return 30
    fi
    if [[ -z "${generated}" || "${generated}" != "${expected}" ]]; then
        log_message "ERROR: generated source checksum ${generated:-<missing>} differs from the committed expectation ${expected}"
        return 30
    fi
    count="$(find "${LUA_GENERATED_DIR}" -maxdepth 1 -name 'module_*.lua' | wc -l)"
    if [[ "${count}" -ne "${LUA_GENERATED_MODULES}" ]]; then
        log_message "ERROR: expected ${LUA_GENERATED_MODULES} generated modules, found ${count}"
        return 30
    fi
    log_message "generated ${count} modules with checksum ${generated}"
}

smoke_validate() {
    local script
    for script in "${SCRIPT_DIR}"/benchmarks/*.lua; do
        if ! LUA_SMOKE_SCRIPT="${script}" "${LUA_BIN}" \
            -e 'local f, e = loadfile(os.getenv("LUA_SMOKE_SCRIPT")); assert(f, e)'; then
            log_message "ERROR: benchmark script does not load: ${script}"
            return 30
        fi
    done
    local output checksum expected
    output="$("${LUA_BIN}" "${SCRIPT_DIR}/benchmarks/arithmetic_loop.lua" 1000)" || {
        log_message "ERROR: arithmetic smoke run failed"
        return 30
    }
    checksum="$(printf '%s\n' "${output}" | sed -n 's/.*checksum=\(-*[0-9]*\).*/\1/p')"
    expected="$("${LUA_BIN}" -e 'local M, X = 1000000007, 2654435761; local s = 0; for i = 1, 1000 do s = (s + (i * X) % M) % M end; print(s)')"
    if [[ -z "${checksum}" || "${checksum}" != "${expected}" ]]; then
        log_message "ERROR: arithmetic smoke checksum ${checksum:-<missing>} differs from ${expected}"
        return 30
    fi
    log_message "workload smoke validation passed"
}

build_lua_base() {
    initialize_runtime || return $?
    require_commands curl tar gzip sha256sum awk make gcc python3 find sed wc /usr/bin/time || return $?
    materialize_asset "${LUA_SOURCE_NAME}" "${LUA_DOWNLOADS_DIR}/${LUA_SOURCE_NAME}" \
        "${LUA_SOURCE_SHA256}" "${LUA_SOURCE_URLS[@]}" || return $?
    materialize_asset "${LUA_TESTSUITE_NAME}" "${LUA_DOWNLOADS_DIR}/${LUA_TESTSUITE_NAME}" \
        "${LUA_TESTSUITE_SHA256}" "${LUA_TESTSUITE_URLS[@]}" || return $?
    fetch_source || return $?
    fetch_testsuite || return $?
    build_lua || return $?
    record_actual_version || return $?
    generate_sources || return $?
    smoke_validate || return $?
    log_message "base build completed: Lua ${SOFTWARE_VERSION} (${LUA_BUILD_TARGET} target), official test suite and workload sources ready"
}
