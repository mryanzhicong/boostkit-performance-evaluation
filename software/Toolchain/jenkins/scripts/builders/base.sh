#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc|stat|cksum) printf 'coreutils\n' ;;
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
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    fi
    for cmd in "${missing[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still unavailable: ${cmd}"
            return 30
        fi
    done
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
    local offline="${JENKINS_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
    else
        local url ok=0
        for url in "${urls[@]}"; do
            log_message "downloading ${url}"
            if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
                -o "${destination}.part" "${url}"; then
                mv -- "${destination}.part" "${destination}"
                ok=1
                break
            fi
            rm -f -- "${destination}.part"
        done
        if [[ "${ok}" != 1 ]]; then
            log_message "ERROR: every download source failed for ${name}"
            return 30
        fi
    fi
    verify_checksum "${destination}" "${expected}"
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
    mkdir -p "${PERF_WORK_DIR}/downloads"
    materialize_asset "${JDK_TARBALL_NAME}" "${JDK_TARBALL_SHA256}" "${tarball}" \
        "${JDK_TARBALL_URL}" || return $?
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
}

install_jenkins_war() {
    mkdir -p "${PERF_WORK_DIR}/downloads"
    materialize_asset "${JENKINS_WAR_NAME}" "${JENKINS_WAR_SHA256}" "${JENKINS_WAR}" \
        "${JENKINS_WAR_URLS[@]}" || return $?
    local size
    size="$(stat -c '%s' "${JENKINS_WAR}")"
    if [[ "${size}" != "${JENKINS_WAR_SIZE}" ]]; then
        log_message "ERROR: ${JENKINS_WAR_NAME} has size ${size}, expected ${JENKINS_WAR_SIZE}"
        return 30
    fi
    log_message "jenkins.war ${SOFTWARE_VERSION} verified (${size} bytes)"
}

record_actual_version() {
    export_java_env
    local version
    version="$("${JENKINS_JAVA}" -jar "${JENKINS_WAR}" --version 2>&1)" || {
        log_message "ERROR: failed to execute the Jenkins war --version"
        return 40
    }
    version="$(printf '%s\n' "${version}" | tr -d '[:space:]')"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Jenkins ${SOFTWARE_VERSION} but the war reports ${version}"
        return 40
    fi
    JENKINS_VERSION_STRING="${version}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Jenkins version: ${version}"
    log_message "runtime: $(printf '%s\n' "$("${JENKINS_JAVA}" -version 2>&1 | tr '\n' ';' | sed 's/;;*/; /g')")"
}

prepare_home_template() {
    export_java_env
    rm -rf -- "${JENKINS_TEMPLATE_HOME}"
    log_message "creating the initialized JENKINS_HOME template (one untimed boot/shutdown cycle)"
    mkdir -p "${RUNS_DIR}/template"
    python3 "${JENKINS_DRIVER}" --prepare-template \
        --prepare-home "${PERF_WORK_DIR}/homes/template-source" \
        --template-home "${JENKINS_TEMPLATE_HOME}" \
        --log "${RUNS_DIR}/template/prepare.log" \
        --java "${JENKINS_JAVA}" \
        --war "${JENKINS_WAR}" \
        --port "${JENKINS_PORT}" \
        --ready-timeout 180 \
        --expected-version "${SOFTWARE_VERSION}" || {
        log_message "ERROR: failed to create the JENKINS_HOME template"
        return 40
    }
    [[ -f "${JENKINS_TEMPLATE_HOME}/config.xml" ]] || {
        log_message "ERROR: the JENKINS_HOME template has no config.xml"
        return 40
    }
    log_message "initialized JENKINS_HOME template is ready"
}

build_jenkins_base() {
    initialize_runtime || return $?
    require_commands curl tar gzip sha256sum awk stat cksum || return $?
    install_jdk || return $?
    install_jenkins_war || return $?
    record_actual_version || return $?
    prepare_home_template || return $?
    log_message "base build completed: Temurin ${JDK_RELEASE}, Jenkins ${SOFTWARE_VERSION}, port ${JENKINS_PORT}"
}
