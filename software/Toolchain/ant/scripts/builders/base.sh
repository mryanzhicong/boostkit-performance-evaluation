#!/usr/bin/env bash
# Base build.  Only the pinned Ant binary distribution is fetched and verified on
# the host; the JDK is installed with dnf, the distribution is unpacked, the
# deterministic Java projects are generated and every version probe runs inside
# this task's private openEuler 24.03 LTS SP4 container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host prerequisites are limited to Docker plus the download/verification tools.
# A missing host tool is only a warning: the pre-placed offline archive is the
# documented fallback for restricted runners.
require_host_transfer_commands() {
    local command_name
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline asset"
        }
    done
    return 0
}

prepare_ant_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_ant_docker || return 30
    start_ant_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Java toolchain and the unpacking utilities inside the private container"
    # Weak dependencies are disabled: the openEuler java-21-openjdk-devel package
    # pulls dbus-daemon through a weak dependency, and its scriptlet cannot run in
    # this container (the host /etc/passwd and /etc/group are mounted read-only).
    ant_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False \
        "${JDK_PACKAGES[@]}" tar gzip coreutils findutils which || {
        log_message "ERROR: container package installation failed"
        return 30
    }
    # A zero exit code from dnf is not evidence that the commands are usable.
    ant_container_exec env "PATH=${ANT_CONTAINER_PATH_PREFIX}" \
        sh -c 'command -v java && command -v javac' || {
        log_message "ERROR: the container JDK is not usable after installation"
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

# Host-side asset transfer: the offline directory is tried first, every
# candidate is verified against the same pinned digest, and the fully attempted
# list is reported when nothing succeeds.
materialize_ant_archive() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    local offline="${ANT_OFFLINE_DIR}/${name}"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}" || return 30
        verify_checksum "${destination}" "${expected}" && return 0
        rm -f -- "${destination}"
    fi
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
        log_message "ERROR:   attempted offline asset: ${offline}"
        for url in "${urls[@]}"; do
            log_message "ERROR:   attempted: ${url}"
        done
        return 30
    fi
    log_message "materialized ${name} ($(stat -c %s "${destination}") bytes)"
}

install_ant_distribution() {
    local archive="${PERF_WORK_DIR}/downloads/${ANT_ARCHIVE_NAME}"
    materialize_ant_archive "${ANT_ARCHIVE_NAME}" "${ANT_ARCHIVE_SHA256}" "${archive}" \
        "${ANT_ARCHIVE_URLS[@]}" || return $?
    log_message "extracting ${ANT_ARCHIVE_NAME} inside the private container"
    ant_container_exec rm -rf -- "${ANT_HOME}" || return 30
    ant_container_exec mkdir -p "${ANT_HOME}" || return 30
    ant_container_exec tar -xzf "${archive}" -C "${ANT_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Ant distribution archive"
        return 30
    }
    ant_container_exec test -x "${ANT_BIN}" || {
        log_message "ERROR: extracted Ant distribution has no bin/ant launcher"
        return 30
    }
}

# The JDK is a property of the pinned container image, not of the host: resolve
# where dnf installed it, persist that path for the later stages and verify the
# major version (the exact package build is recorded as runtime context only).
resolve_container_jdk() {
    local resolved java_version
    resolved="$(ant_container_exec bash -c 'readlink -f "$(command -v javac)"' 2>/dev/null)" || resolved=""
    if [[ -z "${resolved}" ]]; then
        log_message "ERROR: cannot resolve javac inside the private container"
        return 30
    fi
    JDK_HOME="$(dirname "$(dirname "${resolved}")")"
    record_container_jdk_home || return 30
    local java_banner
    java_banner="$(ant_container_java_exec java -version 2>&1)" || java_banner=""
    java_version="$(printf '%s\n' "${java_banner}" | awk -F'"' '/version/ {print $2; exit}')"
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: container JDK reports ${java_version}, expected major version ${JDK_MAJOR}"
        return 30
    fi
    local tool
    for tool in java javac jar; do
        ant_container_java_exec test -x "${JDK_HOME}/bin/${tool}" || {
            log_message "ERROR: the container JDK does not provide bin/${tool}"
            return 30
        }
    done
    log_message "container JDK ${java_version} resolved at ${JDK_HOME}"
}

record_actual_version() {
    load_container_jdk
    local version_line ant_version
    version_line="$(ant_container_java_exec "${ANT_BIN}" -version 2>&1)" || {
        log_message "ERROR: failed to execute ant -version inside the private container"
        return 40
    }
    ant_version="$(printf '%s\n' "${version_line}" | sed -n 's/^Apache Ant(TM) version \([^ ]*\).*/\1/p')"
    ant_version="${ant_version%%$'\n'*}"
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
        log_message "generating the deterministic ${scale}-class Java project inside the private container"
        ant_container_exec python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
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
    prepare_ant_build_container || return $?
    install_ant_distribution || return $?
    resolve_container_jdk || return $?
    record_actual_version || return $?
    generate_corpora || return $?
    local java_version
    local java_banner
    java_banner="$(ant_container_java_exec java -version 2>&1)" || java_banner=""
    java_version="$(printf '%s\n' "${java_banner}" | awk -F'"' '/version/ {print $2; exit}')"
    log_message "base build completed: Apache Ant ${SOFTWARE_VERSION} on container JDK ${java_version}"
}
