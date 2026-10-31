#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|wc|basename|dirname|nproc|stat) printf 'coreutils\n' ;;
        find) printf 'findutils\n' ;;
        /usr/bin/time) printf 'time\n' ;;
        gcc) printf 'gcc\n' ;;
        make) printf 'make\n' ;;
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
        hash -r
    elif command -v apt-get >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do
            packages+=("$(package_for_command "${cmd}")")
        done
        if [[ "$(id -u)" -eq 0 ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" || return 30
        else
            sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" || return 30
        fi
        hash -r
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
    local offline="${PHP_OFFLINE_DIR}/${name}"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}.part"
        if verify_sha256 "${destination}.part" "${expected}"; then
            mv -- "${destination}.part" "${destination}"
            mkdir -p "${PHP_OFFLINE_DIR}"
            cp -- "${destination}" "${offline}"
            return 0
        fi
        log_message "ERROR: pre-placed offline asset has a wrong checksum: ${offline}"
        rm -f -- "${destination}.part"
    fi
    local url
    for url in "$@"; do
        log_message "downloading ${url}"
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -C - -o "${destination}.part" "${url}"; then
            if verify_sha256 "${destination}.part" "${expected}"; then
                mv -- "${destination}.part" "${destination}"
                mkdir -p "${PHP_OFFLINE_DIR}"
                cp -- "${destination}" "${offline}"
                return 0
            fi
            log_message "ERROR: checksum mismatch for ${url}"
        else
            log_message "WARNING: download failed: ${url}"
        fi
        rm -f -- "${destination}.part"
    done
    log_message "ERROR: could not obtain a verified copy of ${name}"
    log_message "  tried offline directory: ${PHP_OFFLINE_DIR}"
    log_message "  tried URLs: $*"
    return 30
}

fetch_source() {
    local archive="${PHP_DOWNLOADS_DIR}/${PHP_SOURCE_NAME}"
    [[ -f "${archive}" ]] || {
        log_message "ERROR: verified source archive is missing: ${archive}"
        return 30
    }
    local size
    size="$(stat -c '%s' "${archive}")"
    if [[ "${size}" != "${PHP_SOURCE_SIZE}" ]]; then
        log_message "ERROR: source archive size ${size} does not match ${PHP_SOURCE_SIZE}"
        return 30
    fi
    rm -rf -- "$(dirname "${PHP_SRC_DIR}")"
    mkdir -p "$(dirname "${PHP_SRC_DIR}")"
    log_message "extracting ${PHP_SOURCE_NAME} to $(dirname "${PHP_SRC_DIR}")"
    tar -xzf "${archive}" -C "$(dirname "${PHP_SRC_DIR}")" || {
        log_message "ERROR: failed to extract the PHP source archive"
        return 30
    }
    [[ -x "${PHP_SRC_DIR}/configure" && -f "${PHP_SRC_DIR}/Zend/bench.php" ]] || {
        log_message "ERROR: extracted PHP sources are incomplete: ${PHP_SRC_DIR}"
        return 30
    }
}

build_php() {
    local build_log="${PHP_BUILD_DIR}/make.log" configure_log="${PHP_BUILD_DIR}/configure.log"
    mkdir -p "${PHP_BUILD_DIR}"
    log_message "configuring PHP ${SOFTWARE_VERSION}: ./configure --prefix=${PHP_INSTALL_DIR} ${PHP_CONFIGURE_FLAGS[*]} (CC=gcc, default -O2)"
    (
        cd "${PHP_SRC_DIR}" || exit 1
        unset MAKEFLAGS MFLAGS
        ./configure --prefix="${PHP_INSTALL_DIR}" "${PHP_CONFIGURE_FLAGS[@]}"
    ) 2>&1 | tee "${configure_log}" || {
        log_message "ERROR: configure failed; see ${configure_log}"
        tail -n 30 "${configure_log}" >&2 || true
        return 30
    }
    log_message "building PHP ${SOFTWARE_VERSION} with make -j${PHP_BUILD_JOBS}"
    (
        cd "${PHP_SRC_DIR}" || exit 1
        unset MAKEFLAGS MFLAGS
        make -j"${PHP_BUILD_JOBS}"
    ) 2>&1 | tee "${build_log}" || {
        log_message "ERROR: PHP build failed; see ${build_log}"
        tail -n 30 "${build_log}" >&2 || true
        return 30
    }
    log_message "installing PHP ${SOFTWARE_VERSION} into ${PHP_INSTALL_DIR}"
    (
        cd "${PHP_SRC_DIR}" || exit 1
        make install
    ) >> "${build_log}" 2>&1 || {
        log_message "ERROR: PHP install failed; see ${build_log}"
        tail -n 30 "${build_log}" >&2 || true
        return 30
    }
    [[ -x "${PHP_BIN}" ]] || {
        log_message "ERROR: the build did not produce ${PHP_BIN}"
        return 30
    }
}

record_actual_version() {
    local version_line version
    version_line="$("${PHP_BIN}" -v 2>&1)" || {
        log_message "ERROR: failed to execute ${PHP_BIN} -v"
        return 40
    }
    version="$(printf '%s\n' "${version_line}" | sed -n 's/^PHP \([0-9][0-9.]*\).*/\1/p' | head -n 1)"
    if [[ -z "${version}" ]]; then
        log_message "ERROR: could not parse the version from php -v"
        printf '%s\n' "${version_line}" | sed -n '1,3p'
        return 40
    fi
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested PHP ${SOFTWARE_VERSION} but built ${version}"
        return 40
    fi
    PHP_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual PHP version: ${version}"
    log_message "runtime: $(printf '%s' "${version_line}" | head -n 1)"
    if ! "${PHP_BIN}" -n -m | grep -qx 'Zend OPcache'; then
        log_message "ERROR: the built CLI does not embed Zend OPcache as expected for PHP 8.5"
        return 40
    fi
    PHP_CONFIGURE_SUMMARY="--disable-all --enable-cli --disable-opcache-jit"
}

generate_modules() {
    local generator_log="${PHP_BUILD_DIR}/generate-modules.log"
    rm -rf -- "${PHP_GENERATED_DIR}"
    log_message "generating ${PHP_GENERATED_MODULES} deterministic include modules for the compile scenario"
    python3 "${SCRIPT_DIR}/scripts/generate_modules.py" \
        --output "${PHP_GENERATED_DIR}" \
        --count "${PHP_GENERATED_MODULES}" 2>&1 | tee "${generator_log}" || {
        log_message "ERROR: failed to generate the include workload sources"
        return 30
    }
    local count
    count="$(find "${PHP_GENERATED_DIR}" -maxdepth 1 -name 'module_*.php' | wc -l)"
    if [[ "${count}" -ne "${PHP_GENERATED_MODULES}" ]]; then
        log_message "ERROR: expected ${PHP_GENERATED_MODULES} generated modules, found ${count}"
        return 30
    fi
    log_message "generated ${count} include modules under ${PHP_GENERATED_DIR}"
}

workload_smoke() {
    local output checksum scenario
    output="$(PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}" "${PHP_BIN}" -n -d memory_limit=512M \
        "${SCRIPT_DIR}/benchmarks/cli_startup.php" cli_startup 0)" || {
        log_message "ERROR: CLI start-up smoke run failed"
        return 30
    }
    checksum="$(printf '%s\n' "${output}" | sed -n 's/.*checksum=\(-*[0-9][0-9]*\).*/\1/p')"
    if [[ "${checksum}" != "1" ]]; then
        log_message "ERROR: CLI start-up smoke checksum ${checksum:-<missing>} is not 1"
        return 30
    fi
    for scenario in nbody spectral_norm fannkuch string_churn array_hash; do
        if ! "${PHP_BIN}" -n -l "${SCRIPT_DIR}/benchmarks/${scenario}.php" >/dev/null 2>&1; then
            log_message "ERROR: benchmark script does not lint: ${scenario}.php"
            return 30
        fi
    done
    output="$(PHP_MODULES_DIR="${PHP_GENERATED_DIR}" "${PHP_BIN}" -n -d memory_limit=512M \
        "${SCRIPT_DIR}/benchmarks/include_all.php" include_modules_1000 "${PHP_GENERATED_MODULES}")" || {
        log_message "ERROR: include smoke run failed"
        return 30
    }
    checksum="$(printf '%s\n' "${output}" | sed -n 's/.*checksum=\(-*[0-9][0-9]*\).*/\1/p')"
    if [[ -z "${checksum}" || "${checksum}" -eq 0 ]]; then
        log_message "ERROR: include smoke run produced no non-zero checksum"
        return 30
    fi
    log_message "workload smoke validation passed"
}

build_php_base() {
    initialize_runtime || return $?
    require_commands curl tar gzip sha256sum awk make gcc python3 find sed wc stat /usr/bin/time || return $?
    materialize_asset "${PHP_SOURCE_NAME}" "${PHP_DOWNLOADS_DIR}/${PHP_SOURCE_NAME}" \
        "${PHP_SOURCE_SHA256}" "${PHP_SOURCE_URLS[@]}" || return $?
    fetch_source || return $?
    build_php || return $?
    record_actual_version || return $?
    generate_modules || return $?
    workload_smoke || return $?
    log_message "base build completed: PHP ${SOFTWARE_VERSION} (minimal CLI, ${PHP_CONFIGURE_FLAGS[*]}) ready"
}
