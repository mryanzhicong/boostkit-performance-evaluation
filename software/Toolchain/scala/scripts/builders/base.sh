#!/usr/bin/env bash
# Base build.  The host only downloads and verifies the pinned Scala 3 compiler
# distribution; the JDK is installed with dnf, the compiler distribution is
# unpacked, the deterministic sources are generated and the run workloads are
# precompiled inside this task's private openEuler 24.03 LTS SP4 container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host prerequisites are limited to Docker plus the download/verification tools.
require_host_transfer_commands() {
    local command_name
    for command_name in curl tar unzip python3 sha256sum awk; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline assets"
        }
    done
    return 0
}

prepare_scala_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_scala_docker || return 30
    start_scala_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Java toolchain and the unpacking utilities inside the private container"
    # Weak dependencies are disabled: the openEuler java-21-openjdk-devel package
    # pulls dbus-daemon through a weak dependency, and its scriptlet cannot run in
    # this container (the host /etc/passwd and /etc/group are mounted read-only).
    scala_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False \
        "${JDK_PACKAGES[@]}" unzip tar gzip coreutils findutils which || {
        log_message "ERROR: container package installation failed"
        return 30
    }
    scala_container_exec env "PATH=${SCALA_CONTAINER_PATH_PREFIX}" \
        sh -c 'command -v java && command -v javac && command -v unzip' || {
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

# Host-side asset transfer: the offline directory is tried first and every
# candidate is verified against the same pinned digest.
materialize_asset() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    local candidate="${SCALA_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${candidate}" ]]; then
        log_message "using pre-placed offline asset: ${candidate}"
        cp -- "${candidate}" "${destination}" || return 30
        verify_checksum "${destination}" "${expected}"
        return $?
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
        local attempted
        for attempted in "${candidate}" "${urls[@]}"; do
            log_message "ERROR:   attempted: ${attempted}"
        done
        return 30
    fi
    log_message "materialized ${name} ($(stat -c %s "${destination}") bytes)"
}

# The JDK is a property of the pinned container image, not of the host: resolve
# where dnf installed it, persist that path for the later stages and verify the
# major version (the exact package build is runtime context only).
resolve_container_jdk() {
    local resolved java_version
    resolved="$(scala_container_exec bash -c 'readlink -f "$(command -v javac)"' 2>/dev/null)" || resolved=""
    if [[ -z "${resolved}" ]]; then
        log_message "ERROR: cannot resolve javac inside the private container"
        return 30
    fi
    JDK_HOME="$(dirname "$(dirname "${resolved}")")"
    record_container_jdk_home || return 30
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: container JDK reports ${java_version}, expected major version ${JDK_MAJOR}"
        return 30
    fi
    local tool
    for tool in java javac jar; do
        scala_container_exec test -x "${JDK_HOME}/bin/${tool}" || {
            log_message "ERROR: the container JDK does not provide bin/${tool}"
            return 30
        }
    done
    log_message "container JDK ${java_version} resolved at ${JDK_HOME}"
}

install_scala() {
    local banner
    banner="$(scalac_version_output || true)"
    if scala_container_exec test -x "${SCALAC_BIN}" && [[ "${banner}" == *"${SOFTWARE_VERSION}"* ]]; then
        log_message "reusing Scala ${SOFTWARE_VERSION} distribution at ${SCALA_HOME}"
        return 0
    fi
    scala_container_exec rm -rf -- "${SCALA_HOME}" "${SCALA_HOME}.extract" || return 30
    local archive="${PERF_WORK_DIR}/downloads/${SCALA_ARCHIVE_NAME}"
    materialize_asset "${SCALA_ARCHIVE_NAME}" "${SCALA_ARCHIVE_SHA256}" "${archive}" \
        "${SCALA_ARCHIVE_URLS[@]}" || return $?
    scala_container_exec mkdir -p "${SCALA_HOME}" || return 30
    log_message "extracting ${SCALA_ARCHIVE_NAME} to ${SCALA_HOME} inside the private container"
    scala_container_exec unzip -q "${archive}" -d "${SCALA_HOME}.extract" || {
        log_message "ERROR: failed to extract the Scala distribution archive"
        return 30
    }
    local top
    top="$(find "${SCALA_HOME}.extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [[ -z "${top}" ]] || ! scala_container_exec test -x "${top}/bin/scalac"; then
        log_message "ERROR: extracted Scala distribution has no bin/scalac"
        return 30
    fi
    cp -a "${top}/." "${SCALA_HOME}/" || return 30
    scala_container_exec rm -rf -- "${SCALA_HOME}.extract" || return 30
    scala_container_exec test -x "${SCALAC_BIN}" || {
        log_message "ERROR: Scala launcher is not executable: ${SCALAC_BIN}"
        return 30
    }
    log_message "extracted Scala distribution to ${SCALA_HOME}"
}

record_actual_version() {
    export_java_env
    local version_line scala_version
    version_line="$(scalac_version_output)" || {
        log_message "ERROR: failed to execute ${SCALAC_BIN} -version inside the private container"
        return 40
    }
    scala_version="$(printf '%s\n' "${version_line}" | sed -n 's/^Scala compiler version \([^ ]*\).*/\1/p')"
    scala_version="${scala_version%%$'\n'*}"
    if [[ -z "${scala_version}" ]]; then
        log_message "ERROR: could not parse the Scala version from scalac -version"
        printf '%s\n' "${version_line}" | sed -n '1,6p'
        return 40
    fi
    SCALA_VERSION_STRING="${version_line//$'\n'/; }"
    if [[ "${scala_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Scala ${SOFTWARE_VERSION} but installed ${scala_version}"
        return 40
    fi
    local java_version
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, got: ${java_version:-<unknown>}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${scala_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Scala version: ${scala_version} (container JDK ${java_version})"
    log_message "compiler: ${SCALA_VERSION_STRING}"
}

generate_corpus() {
    local scale
    for scale in "${SCALA_COMPILE_SCALES[@]}"; do
        log_message "generating the deterministic ${scale}-class Scala 3 project inside the private container"
        scala_container_env_exec python3 "${SCRIPT_DIR}/scripts/generate_sources.py" compile \
            --output "${PROJECTS_DIR}/project-${scale}" --classes "${scale}" || return 40
    done
    local workload
    for workload in "${SCALA_RUN_WORKLOADS[@]}"; do
        log_message "generating the ${workload} run workload inside the private container"
        scala_container_env_exec python3 "${SCRIPT_DIR}/scripts/generate_sources.py" workload \
            --output "${PROJECTS_DIR}/workload-${workload}" --workload "${workload}" || return 40
    done
}

precompile_workloads() {
    export_java_env
    resolve_scala_classpath || return $?
    scala_container_exec rm -rf -- "${SCALA_PROGRAMS_OUT}" || return 30
    scala_container_exec mkdir -p "${SCALA_PROGRAMS_OUT}" || return 30
    local workload source out
    local -a sources=()
    for workload in "${SCALA_RUN_WORKLOADS[@]}"; do
        out="${SCALA_PROGRAMS_OUT}/${workload}"
        mkdir -p "${out}"
        sources=("${PROJECTS_DIR}/workload-${workload}/src/bench/"*.scala)
        log_message "precompiling the ${workload} workload (untimed build step) inside the private container"
        if ! scala_container_env_exec "${SCALAC_BIN}" -classpath "${SCALA_CLASSPATH}" \
            -d "${out}" "${sources[@]}" \
            >"${PERF_WORK_DIR}/precompile-${workload}.log" 2>&1; then
            log_message "ERROR: failed to precompile the ${workload} workload"
            tail -n 30 "${PERF_WORK_DIR}/precompile-${workload}.log" | sed 's/^/  /'
            return 40
        fi
        [[ -f "${out}/bench/Main.class" ]] || {
            log_message "ERROR: ${workload} workload did not produce bench/Main.class"
            return 40
        }
    done
}

verify_scala_distribution() {
    scala_container_exec test -x "${SCALA_HOME}/bin/scalac" || {
        log_message "ERROR: Scala compiler launcher is missing: ${SCALAC_BIN}"
        return 40
    }
    scala_container_exec test -d "${SCALA_LIB_DIR}" || {
        log_message "ERROR: Scala distribution has no jar directory: ${SCALA_LIB_DIR}"
        return 40
    }
    local jar
    jar="$(find "${SCALA_LIB_DIR}" -name 'scala3-library_3-*.jar' | head -n 1)"
    if [[ -z "${jar}" ]]; then
        log_message "ERROR: Scala distribution has no scala3-library jar"
        return 40
    fi
    if [[ -z "$(find "${SCALA_LIB_DIR}" -name 'scala-library-*.jar' | head -n 1)" ]]; then
        log_message "ERROR: Scala distribution has no scala-library jar"
        return 40
    fi
    log_message "Scala distribution verified: $(basename "${jar}")"
}

build_scala_base() {
    initialize_runtime || return $?
    prepare_scala_build_container || return $?
    resolve_container_jdk || return $?
    install_scala || return $?
    record_actual_version || return $?
    generate_corpus || return $?
    precompile_workloads || return $?
    verify_scala_distribution || return $?
    log_message "base build completed: Scala ${SOFTWARE_VERSION} on container OpenJDK ${JDK_MAJOR}.x"
}
