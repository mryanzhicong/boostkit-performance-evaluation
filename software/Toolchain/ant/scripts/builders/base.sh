#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc) printf 'coreutils\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

package_for_command_apt() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

install_missing_commands() {
    local -a missing=() packages=() apt_packages=()
    local cmd rc=0
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    (( ${#missing[@]} == 0 )) && return 0
    log_message "missing commands: ${missing[*]}"
    if command -v dnf >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do packages+=("$(package_for_command "${cmd}")"); done
        local -a dnf_options=()
        [[ -n "${PERF_PROXY:-}" ]] && dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        local -a runner=()
        if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then runner=(sudo -n); fi
        "${runner[@]}" dnf "${dnf_options[@]}" install -y "${packages[@]}" || rc=$?
    elif command -v apt-get >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do apt_packages+=("$(package_for_command_apt "${cmd}")"); done
        local -a runner=()
        if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then runner=(sudo -n); fi
        DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get update || rc=$?
        if (( rc == 0 )); then
            DEBIAN_FRONTEND=noninteractive "${runner[@]}" apt-get install -y \
                --no-install-recommends "${apt_packages[@]}" || rc=$?
        fi
    else
        log_message "ERROR: neither dnf nor apt-get is available to install ${missing[*]}"
        return 30
    fi
    if (( rc != 0 )); then
        log_message "ERROR: package installation failed with exit code ${rc}"
        return 30
    fi
    # Post-install self-check: a package manager exit code is not evidence that
    # the command is usable (same lesson as the fbthrift ICU and spdk cases).
    local -a still_missing=()
    for cmd in "${missing[@]}"; do
        command -v "${cmd}" >/dev/null 2>&1 || still_missing+=("${cmd}")
    done
    if (( ${#still_missing[@]} > 0 )); then
        log_message "ERROR: required commands are still missing after installation: ${still_missing[*]}"
        return 30
    fi
    log_message "installed commands: ${missing[*]}"
}

verify_checksum() {
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

materialize_asset() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    local -a offline_candidates=()
    if [[ "${name}" == "${ANT_ARCHIVE_NAME}" ]]; then
        offline_candidates+=("${ANT_OFFLINE_DIR}/${name}")
    else
        local directory
        for directory in "${JDK_OFFLINE_DIRS[@]}"; do
            offline_candidates+=("${directory}/${name}")
        done
    fi
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    local candidate
    for candidate in "${offline_candidates[@]}"; do
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline asset: ${candidate}"
            cp -- "${candidate}" "${destination}" || return 30
            verify_checksum "${destination}" "${expected}"
            return $?
        fi
    done
    local url
    local downloaded=0
    for url in "${urls[@]}"; do
        log_message "downloading ${url}"
        if ! curl -fL --retry 2 --retry-delay 2 --connect-timeout 20 --max-time 1800 \
            -o "${destination}.part" "${url}"; then
            log_message "WARNING: download failed, trying the next source: ${url}"
            rm -f -- "${destination}.part"
            continue
        fi
        if verify_checksum "${destination}.part" "${expected}"; then
            mv -- "${destination}.part" "${destination}"
            downloaded=1
            break
        fi
        log_message "WARNING: checksum mismatch from ${url}, trying the next source"
        rm -f -- "${destination}.part"
    done
    if (( downloaded == 0 )); then
        log_message "ERROR: every download source failed for ${name}"
        local attempted
        for attempted in "${offline_candidates[@]}" "${urls[@]}"; do
            log_message "ERROR:   attempted: ${attempted}"
        done
        return 30
    fi
    log_message "materialized ${name} ($(stat -c %s "${destination}") bytes)"
}

install_jdk() {
    local expected_java="${JDK_HOME}/bin/java"
    if [[ -x "${expected_java}" ]]; then
        local installed
        installed="$("${expected_java}" -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
        if [[ "${installed}" == "${JDK_SEMVER}"* ]]; then
            log_message "reusing Temurin JDK ${installed} at ${JDK_HOME}"
            return 0
        fi
        log_message "removing unexpected JDK ${installed} at ${JDK_HOME}"
        rm -rf -- "${JDK_HOME}"
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${JDK_TARBALL_NAME}"
    materialize_asset "${JDK_TARBALL_NAME}" "${JDK_TARBALL_SHA256}" "${tarball}" \
        "${JDK_TARBALL_URLS[@]}" || return $?
    mkdir -p "${JDK_HOME}"
    log_message "extracting Temurin ${JDK_RELEASE} to ${JDK_HOME}"
    tar -xzf "${tarball}" -C "${JDK_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the JDK archive"
        return 30
    }
    [[ -x "${JDK_HOME}/bin/java" ]] || {
        log_message "ERROR: extracted JDK does not contain bin/java"
        return 30
    }
    local installed
    installed="$("${JDK_HOME}/bin/java" -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${installed}" != "${JDK_SEMVER}"* ]]; then
        log_message "ERROR: expected Temurin ${JDK_SEMVER}, extracted ${installed}"
        return 30
    fi
}

install_ant() {
    if [[ -x "${ANT_BIN}" ]]; then
        log_message "reusing Apache Ant ${SOFTWARE_VERSION} distribution at ${ANT_HOME}"
        return 0
    fi
    local archive="${PERF_WORK_DIR}/downloads/${ANT_ARCHIVE_NAME}"
    materialize_asset "${ANT_ARCHIVE_NAME}" "${ANT_ARCHIVE_SHA256}" "${archive}" \
        "${ANT_ARCHIVE_URLS[@]}" || return $?
    rm -rf -- "${ANT_HOME}"
    mkdir -p "${ANT_HOME}"
    log_message "extracting ${ANT_ARCHIVE_NAME} to ${ANT_HOME}"
    tar -xzf "${archive}" -C "${ANT_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Ant distribution archive"
        return 30
    }
    [[ -x "${ANT_BIN}" ]] || {
        log_message "ERROR: extracted Ant distribution has no bin/ant launcher"
        return 30
    }
}

install_jdk_formula_deps() {
    # javac/jar only need a JDK; Ant itself is a pure Java application.
    export_java_env
    local tool
    for tool in javac jar; do
        [[ -x "${JDK_HOME}/bin/${tool}" ]] || {
            log_message "ERROR: pinned JDK does not provide bin/${tool}"
            return 30
        }
    done
}

record_actual_version() {
    export_java_env
    local version_line ant_version
    version_line="$("${ANT_BIN}" -version 2>&1)" || {
        log_message "ERROR: failed to execute ${ANT_BIN} -version"
        return 40
    }
    ant_version="$(printf '%s\n' "${version_line}" | sed -n 's/^Apache Ant(TM) version \([^ ]*\).*/\1/p' | head -n 1)"
    if [[ -z "${ant_version}" ]]; then
        log_message "ERROR: could not parse the Ant version from ant -version"
        printf '%s\n' "${version_line}" | sed -n '1,6p'
        return 40
    fi
    ANT_VERSION_STRING="${version_line//$'\n'/; }"
    if [[ "${ant_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Ant ${SOFTWARE_VERSION} but installed ${ant_version}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${ant_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Ant version: ${ant_version}"
    log_message "launcher: ${ANT_VERSION_STRING}"
}

generate_corpora() {
    local scale
    for scale in "${ANT_JAR_SCALES[@]}"; do
        log_message "generating the deterministic ${scale}-class Java project"
        python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${PROJECTS_DIR}/project-${scale}" --classes "${scale}" || return 40
    done
    mkdir -p "${PROJECTS_DIR}/project-100"
    [[ -f "${PROJECTS_DIR}/project-100/src/bench/Class0001.java" ]] || {
        log_message "ERROR: incremental project sources are missing"
        return 40
    }
}

build_ant_base() {
    initialize_runtime || return $?
    install_missing_commands curl tar python3 sha256sum awk || return $?
    install_jdk || return $?
    install_ant || return $?
    record_actual_version || return $?
    install_jdk_formula_deps || return $?
    generate_corpora || return $?
    log_message "base build completed: Apache Ant ${SOFTWARE_VERSION} on Temurin ${JDK_RELEASE}"
}
