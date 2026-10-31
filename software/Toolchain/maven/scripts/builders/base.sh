#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|sha512sum|basename|dirname|nproc|stat) printf 'coreutils\n' ;;
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
    local file="$1" algorithm="$2" expected="$3" actual
    case "${algorithm}" in
        sha256) actual="$(sha256sum "${file}" | awk '{print $1}')" ;;
        sha512) actual="$(sha512sum "${file}" | awk '{print $1}')" ;;
        *)
            log_message "ERROR: unsupported checksum algorithm: ${algorithm}"
            return 30
            ;;
    esac
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: ${algorithm} mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified ${algorithm} $(basename "${file}")"
}

materialize_asset() {
    local name="$1" url="$2" algorithm="$3" expected="$4" destination="$5"
    local offline="${MAVEN_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${algorithm}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
    else
        log_message "downloading ${url}"
        if ! curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -o "${destination}.part" "${url}"; then
            log_message "ERROR: download failed: ${url}"
            rm -f -- "${destination}.part"
            return 30
        fi
        mv -- "${destination}.part" "${destination}"
    fi
    verify_checksum "${destination}" "${algorithm}" "${expected}"
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
    materialize_asset "${JDK_TARBALL_NAME}" "${JDK_TARBALL_URL}" sha256 \
        "${JDK_TARBALL_SHA256}" "${tarball}" || return $?
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

install_maven() {
    if [[ -x "${MAVEN_BIN}" ]]; then
        log_message "reusing Maven distribution at ${MAVEN_HOME}"
        return 0
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${MAVEN_BIN_NAME}"
    materialize_asset "${MAVEN_BIN_NAME}" "${MAVEN_BIN_URL}" sha512 \
        "${MAVEN_BIN_SHA512}" "${tarball}" || return $?
    mkdir -p "${MAVEN_HOME}"
    log_message "extracting ${MAVEN_BIN_NAME} to ${MAVEN_HOME}"
    tar -xzf "${tarball}" -C "${MAVEN_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Maven distribution"
        return 30
    }
    chmod +x "${MAVEN_BIN}" || return 30
    [[ -x "${MAVEN_BIN}" ]] || {
        log_message "ERROR: Maven launcher is not executable: ${MAVEN_BIN}"
        return 30
    }
}

install_maven_sources() {
    if [[ -f "${MAVEN_SRC_DIR}/pom.xml" ]]; then
        log_message "reusing extracted Maven sources at ${MAVEN_SRC_DIR}"
        return 0
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${MAVEN_SRC_NAME}"
    materialize_asset "${MAVEN_SRC_NAME}" "${MAVEN_SRC_URL}" sha512 \
        "${MAVEN_SRC_SHA512}" "${tarball}" || return $?
    rm -rf -- "${MAVEN_SRC_DIR}"
    mkdir -p "${MAVEN_SRC_DIR}"
    log_message "extracting ${MAVEN_SRC_NAME} to ${MAVEN_SRC_DIR}"
    tar -xzf "${tarball}" -C "${MAVEN_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Maven source archive"
        return 30
    }
    [[ -f "${MAVEN_SRC_DIR}/pom.xml" ]] || {
        log_message "ERROR: extracted Maven sources have no pom.xml"
        return 30
    }
}

record_actual_version() {
    export_java_env
    local version_line maven_version
    version_line="$("${MAVEN_BIN}" -v 2>&1)" || {
        log_message "ERROR: failed to execute ${MAVEN_BIN} -v"
        return 40
    }
    maven_version="$(printf '%s\n' "${version_line}" | awk '/^Apache Maven/ {print $3; exit}')"
    if [[ -z "${maven_version}" ]]; then
        log_message "ERROR: could not parse the Maven version from mvn -v"
        printf '%s\n' "${version_line}" | sed -n '1,6p'
        return 40
    fi
    MAVEN_VERSION_STRING="$(printf '%s\n' "${version_line}" | sed -n '1p')"
    if [[ "${maven_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Maven ${SOFTWARE_VERSION} but installed ${maven_version}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${maven_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Maven version: ${maven_version}"
    log_message "runtime: $(printf '%s\n' "${version_line}" | tr '\n' ';' | sed 's/;;*/; /g')"
}

generate_projects() {
    local scale project
    for scale in "${MAVEN_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        log_message "generating deterministic project with ${scale} classes"
        python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${project}" --classes "${scale}" || return 40
    done
}

prefetch_build_dependencies() {
    export_java_env
    local marker="${PERF_WORK_DIR}/.prefetch-project-repo.done"
    if [[ -f "${marker}" ]]; then
        log_message "private Maven repository was already warmed in this work directory"
        return 0
    fi
    local project="${PROJECTS_DIR}/project-100"
    log_message "warming the private Maven repository with the 100-class project (network allowed)"
    (
        cd "${project}" || exit 1
        "${MAVEN_BIN}" -B -ntp "${MAVEN_SETTINGS_ARGV[@]}" "-Dmaven.repo.local=${M2_REPO}" -Dstyle.color=never \
            -DskipTests clean package
    ) || {
        log_message "ERROR: failed to warm the private Maven repository"
        return 40
    }
    touch "${marker}"
}

prefetch_self_build_dependencies() {
    export_java_env
    local marker="${PERF_WORK_DIR}/.prefetch-self-build.done"
    if [[ -f "${marker}" ]]; then
        log_message "upstream Maven self-build was already validated in this work directory"
        return 0
    fi
    log_message "prefetching and validating the upstream Maven self-build (network allowed)"
    (
        cd "${MAVEN_SRC_DIR}" || exit 1
        "${MAVEN_BIN}" -B -ntp "${MAVEN_SETTINGS_ARGV[@]}" "-Dmaven.repo.local=${M2_REPO}" -Dstyle.color=never \
            -DskipTests -Drat.skip=true -Dmaven.javadoc.skip=true \
            -Dmaven.source.skip=true -Dcheckstyle.skip=true clean package
    ) || {
        log_message "ERROR: upstream Maven self-build prefetch failed"
        return 40
    }
    touch "${marker}"
}

build_maven_base() {
    initialize_runtime || return $?
    require_commands curl tar gzip sha256sum sha512sum awk || return $?
    install_jdk || return $?
    install_maven || return $?
    install_maven_sources || return $?
    record_actual_version || return $?
    generate_projects || return $?
    prefetch_build_dependencies || return $?
    prefetch_self_build_dependencies || return $?
    log_message "base build completed: Temurin ${JDK_RELEASE}, Maven ${SOFTWARE_VERSION}"
}
