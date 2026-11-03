#!/usr/bin/env bash
# Base build.  The host only downloads and verifies the pinned jenkins.war; the
# JDK is installed with dnf, the war version probe and the one-time JENKINS_HOME
# template boot run inside this task's private openEuler 24.03 LTS SP4 container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host prerequisites are limited to Docker plus the download/verification tools.
require_host_transfer_commands() {
    local command_name
    for command_name in curl tar gzip sha256sum awk stat cksum timeout python3; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline asset"
        }
    done
    return 0
}

prepare_jenkins_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_jenkins_docker || return 30
    start_jenkins_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Java toolchain inside the private container"
    # Weak dependencies are disabled: the openEuler java-21-openjdk-devel package
    # pulls dbus-daemon through a weak dependency, and its scriptlet cannot run in
    # this container (the host /etc/passwd and /etc/group are mounted read-only).
    jenkins_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False \
        "${JDK_PACKAGES[@]}" tar gzip coreutils findutils which procps-ng || {
        log_message "ERROR: container package installation failed"
        return 30
    }
    jenkins_container_exec env "PATH=${JENKINS_CONTAINER_PATH_PREFIX}" \
        sh -c 'command -v java && command -v javac && command -v pgrep' || {
        log_message "ERROR: the container toolchain is not usable after installation"
        return 30
    }
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

# Download one pinned artifact with a hard per-attempt timeout, a transfer-stall
# detector and a shared budget.  Mirrors are tried in order; every source is
# re-verified against the same SHA-256 and a failure prints every URL attempted.
materialize_asset() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    local offline="${JENKINS_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        if verify_checksum "${destination}" "${expected}"; then
            return 0
        fi
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    rm -f -- "${destination}.part"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
        verify_checksum "${destination}" "${expected}" || {
            rm -f -- "${destination}"
            return 30
        }
        return 0
    fi
    if (( ${#urls[@]} == 0 )); then
        log_message "ERROR: no download source is configured for ${name}"
        return 30
    fi
    local url attempt=0 attempt_timeout remaining
    local -a tried=()
    for url in "${urls[@]}"; do
        remaining="$(remaining_seconds "${JENKINS_DOWNLOAD_DEADLINE}")"
        if [[ "${JENKINS_DOWNLOAD_DEADLINE}" -gt 0 && "${remaining}" -le 0 ]]; then
            log_message "ERROR: the ${JENKINS_DOWNLOAD_BUDGET_SECONDS}s download budget is exhausted"
            break
        fi
        attempt=$((attempt + 1))
        attempt_timeout="${JENKINS_DOWNLOAD_ATTEMPT_SECONDS}"
        if [[ "${JENKINS_DOWNLOAD_DEADLINE}" -gt 0 && "${remaining}" -lt "${attempt_timeout}" ]]; then
            attempt_timeout="${remaining}"
            if (( attempt_timeout < 15 )); then
                log_message "ERROR: only ${attempt_timeout}s of the download budget remain; giving up on ${name}"
                break
            fi
        fi
        if (( attempt_timeout < 1 )); then
            log_message "ERROR: invalid download attempt timeout for ${name}: ${attempt_timeout}s"
            break
        fi
        log_message "downloading ${name} from source ${attempt}/${#urls[@]}: ${url} (limit ${attempt_timeout}s)"
        tried+=("${url}")
        # curl's --connect-timeout alone does not stop a connection that is
        # accepted and then never answers; --max-time plus the external timeout
        # and the low-speed detector guarantee this attempt cannot hang the build.
        local max_time="${attempt_timeout}"
        (( max_time > 10 )) && max_time=$(( attempt_timeout - 5 ))
        if timeout --kill-after=10 "${attempt_timeout}" \
            curl -fL --silent --show-error \
                --connect-timeout 10 \
                --max-time "${max_time}" \
                --speed-limit "${JENKINS_STALL_BYTES_PER_SECOND}" \
                --speed-time "${JENKINS_STALL_SECONDS}" \
                --retry 0 \
                -o "${destination}.part" "${url}"; then
            mv -- "${destination}.part" "${destination}"
            if verify_checksum "${destination}" "${expected}"; then
                log_message "downloaded ${name} from ${url}"
                return 0
            fi
            log_message "ERROR: ${url} returned a file that does not match the pinned SHA-256; discarding"
            rm -f -- "${destination}"
        else
            log_message "WARNING: download attempt failed or timed out: ${url}"
        fi
        rm -f -- "${destination}.part"
    done
    log_message "ERROR: every download source failed for ${name}"
    local u
    for u in "${tried[@]}"; do
        log_message "  tried: ${u}"
    done
    return 30
}

# The JDK is a property of the pinned container image, not of the host: resolve
# where dnf installed it, persist that path for the later stages and verify the
# major version (the exact package build is runtime context only).
resolve_container_jdk() {
    local resolved java_version
    resolved="$(jenkins_container_exec bash -c 'readlink -f "$(command -v javac)"' 2>/dev/null)" || resolved=""
    if [[ -z "${resolved}" ]]; then
        log_message "ERROR: cannot resolve javac inside the private container"
        return 30
    fi
    JDK_HOME="$(dirname "$(dirname "${resolved}")")"
    record_container_jdk_home || return 30
    JENKINS_JAVA="${JDK_HOME}/bin/java"
    export JENKINS_JAVA
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: container JDK reports ${java_version}, expected major version ${JDK_MAJOR}"
        return 30
    fi
    local tool
    for tool in java javac jar; do
        jenkins_container_exec test -x "${JDK_HOME}/bin/${tool}" || {
            log_message "ERROR: the container JDK does not provide bin/${tool}"
            return 30
        }
    done
    JDK_SOURCE="container:${JDK_HOME}"
    log_message "container JDK ${java_version} resolved at ${JDK_HOME}"
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
    ensure_build_budget "the jenkins.war --version probe" || return $?
    local output version java_version
    if ! output="$(jenkins_container_env_exec timeout --kill-after=5 \
        "${JENKINS_VERSION_PROBE_TIMEOUT_SECONDS}" \
        "${JENKINS_JAVA}" -jar "${JENKINS_WAR}" --version 2>&1)"; then
        log_message "ERROR: the jenkins.war --version probe failed or exceeded ${JENKINS_VERSION_PROBE_TIMEOUT_SECONDS}s"
        printf '%s\n' "${output}" >&2
        return 30
    fi
    version="$(printf '%s\n' "${output}" | tr -d '[:space:]')"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Jenkins ${SOFTWARE_VERSION} but the war reports ${version}"
        return 30
    fi
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, got: ${java_version:-<unknown>}"
        return 30
    fi
    JENKINS_VERSION_STRING="${version}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Jenkins version: ${version} (container JDK ${java_version})"
    log_message "runtime: $(jenkins_container_env_exec java -version 2>&1 | tr '\n' ';' | sed 's/;;*/; /g')"
}

prepare_home_template() {
    export_java_env
    ensure_build_budget "the JENKINS_HOME template boot" || return $?
    local template_timeout remaining
    remaining="$(remaining_seconds "${JENKINS_BUILD_DEADLINE}")"
    template_timeout="${JENKINS_TEMPLATE_TIMEOUT_SECONDS}"
    if [[ "${JENKINS_BUILD_DEADLINE}" -gt 0 && "${remaining}" -lt "${template_timeout}" ]]; then
        template_timeout="${remaining}"
    fi
    if (( template_timeout < 60 )); then
        log_message "ERROR: only ${template_timeout}s of the build budget remain for the template boot"
        return 30
    fi
    rm -rf -- "${JENKINS_TEMPLATE_HOME}"
    mkdir -p "${RUNS_DIR}/template"
    log_message "creating the initialized JENKINS_HOME template inside the private container (one untimed boot, limit ${template_timeout}s)"
    local rc
    jenkins_container_env_exec_at "${PERF_WORK_DIR}" timeout --kill-after=15 \
        "$((template_timeout + 20))" python3 "${JENKINS_DRIVER}" --prepare-template \
        --prepare-home "${PERF_WORK_DIR}/homes/template-source" \
        --template-home "${JENKINS_TEMPLATE_HOME}" \
        --log "${RUNS_DIR}/template/prepare.log" \
        --java "${JENKINS_JAVA}" \
        --war "${JENKINS_WAR}" \
        --port "${JENKINS_PORT}" \
        --ready-timeout 180 \
        --timeout "${template_timeout}" \
        --expected-version "${SOFTWARE_VERSION}"
    rc=$?
    if [[ "${rc}" -ne 0 ]]; then
        if [[ "${rc}" -eq 124 ]]; then
            log_message "ERROR: the template controller did not finish within ${template_timeout}s"
        else
            log_message "ERROR: failed to create the JENKINS_HOME template (exit ${rc})"
        fi
        stop_stray_controllers "${JENKINS_PORT}"
        print_log_tail "${RUNS_DIR}/template/prepare.log" 40
        return 30
    fi
    [[ -f "${JENKINS_TEMPLATE_HOME}/config.xml" ]] || {
        log_message "ERROR: the JENKINS_HOME template has no config.xml"
        print_log_tail "${RUNS_DIR}/template/prepare.log" 40
        return 30
    }
    log_message "initialized JENKINS_HOME template is ready"
}

build_jenkins_base() {
    initialize_runtime || return $?
    prepare_jenkins_build_container || return $?
    resolve_container_jdk || return $?
    JENKINS_BUILD_DEADLINE=$(( $(date +%s) + JENKINS_BUILD_BUDGET_SECONDS ))
    JENKINS_DOWNLOAD_DEADLINE=$(( $(date +%s) + JENKINS_DOWNLOAD_BUDGET_SECONDS ))
    log_message "build budget: ${JENKINS_BUILD_BUDGET_SECONDS}s, download budget: ${JENKINS_DOWNLOAD_BUDGET_SECONDS}s"
    log_message "JDK source: ${JDK_SOURCE}"
    ensure_build_budget "the jenkins.war download" || return $?
    install_jenkins_war || return $?
    record_actual_version || return $?
    prepare_home_template || return $?
    log_message "base build completed: container JDK ${JDK_MAJOR}.x (${JDK_SOURCE}), Jenkins ${SOFTWARE_VERSION}, port ${JENKINS_PORT}"
}
