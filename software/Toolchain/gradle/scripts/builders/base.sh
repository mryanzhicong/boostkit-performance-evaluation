#!/usr/bin/env bash
# Base build.  The host only downloads and verifies the pinned Gradle
# distribution/source archives; the JDK is installed with dnf, the archives are
# unpacked, the deterministic projects are generated, the shared Gradle user home
# is warmed and the upstream samples are smoke-built inside this task's private
# openEuler 24.03 LTS SP4 container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host prerequisites are limited to Docker plus the download/verification tools.
# A missing host tool is only a warning: the pre-placed offline archives are the
# documented fallback for restricted runners.
require_host_transfer_commands() {
    local command_name
    for command_name in curl sha256sum tar python3 unzip; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline assets"
        }
    done
    return 0
}

prepare_gradle_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_gradle_docker || return 30
    start_gradle_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Java toolchain and the unpacking utilities inside the private container"
    # Weak dependencies are disabled: the openEuler java-21-openjdk-devel package
    # pulls dbus-daemon through a weak dependency, and its scriptlet cannot run in
    # this container (the host /etc/passwd and /etc/group are mounted read-only).
    gradle_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False \
        "${JDK_PACKAGES[@]}" unzip tar gzip coreutils findutils which || {
        log_message "ERROR: container package installation failed"
        return 30
    }
    gradle_container_exec env "PATH=${GRADLE_CONTAINER_PATH_PREFIX}" \
        sh -c 'command -v java && command -v javac && command -v unzip' || {
        log_message "ERROR: the container toolchain is not usable after installation"
        return 30
    }
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

# Host-side asset transfer: the offline directory is tried first and every
# candidate is verified against the same pinned digest.
materialize_asset() {
    local name="$1" sha256="$2" destination="$3"
    shift 3
    local urls=("$@")
    mkdir -p "$(dirname "${destination}")"

    if [[ -f "${destination}" ]]; then
        verify_sha256 "${destination}" "${sha256}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi

    local candidate="${GRADLE_OFFLINE_DIR}/${name}"
    if [[ -f "${candidate}" ]]; then
        log_message "using pre-placed offline asset: ${candidate}"
        cp -- "${candidate}" "${destination}"
        verify_sha256 "${destination}" "${sha256}" && return 0
        rm -f -- "${destination}"
    fi

    local url
    for url in "${urls[@]}"; do
        [[ -n "${url}" ]] || continue
        log_message "downloading ${url}"
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -o "${destination}.part" "${url}"; then
            mv -- "${destination}.part" "${destination}"
            if verify_sha256 "${destination}" "${sha256}"; then
                return 0
            fi
            rm -f -- "${destination}"
            log_message "WARN: downloaded asset did not match the pinned digest: ${url}"
        else
            rm -f -- "${destination}.part"
            log_message "WARN: download failed: ${url}"
        fi
    done
    log_message "ERROR: could not obtain a verified ${name}; tried the offline asset and every download source"
    return 30
}

# The JDK is a property of the pinned container image, not of the host: resolve
# where dnf installed it, persist that path for the later stages and verify the
# major version (the exact package build is runtime context only).
resolve_container_jdk() {
    local resolved java_version
    resolved="$(gradle_container_exec bash -c 'readlink -f "$(command -v javac)"' 2>/dev/null)" || resolved=""
    if [[ -z "${resolved}" ]]; then
        log_message "ERROR: cannot resolve javac inside the private container"
        return 30
    fi
    JDK_HOME="$(dirname "$(dirname "${resolved}")")"
    record_container_jdk_home || return 30
    java_version="$(gradle_container_env_exec java -version 2>&1 | sed -n '1{s/^openjdk version "//;s/".*$//;p}')"
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: container JDK reports ${java_version}, expected major version ${JDK_MAJOR}"
        return 30
    fi
    local tool
    for tool in java javac jar; do
        gradle_container_exec test -x "${JDK_HOME}/bin/${tool}" || {
            log_message "ERROR: the container JDK does not provide bin/${tool}"
            return 30
        }
    done
    log_message "container JDK ${java_version} resolved at ${JDK_HOME}"
}

install_gradle() {
    if [[ -x "${GRADLE_BIN}" ]] && [[ "$(gradle_version_string || true)" == "${SOFTWARE_VERSION}" ]]; then
        log_message "reusing Gradle ${SOFTWARE_VERSION} at ${GRADLE_HOME}"
        return 0
    fi
    gradle_container_exec rm -rf -- "${GRADLE_HOME}" || return 30
    local zip="${PERF_WORK_DIR}/downloads/${GRADLE_ZIP_NAME}"
    local urls=()
    if [[ -n "${PERF_GRADLE_MIRROR:-}" ]]; then
        urls+=("${PERF_GRADLE_MIRROR%/}/${GRADLE_ZIP_NAME}")
    fi
    urls+=("${GRADLE_ZIP_URL_PRIMARY}" "${GRADLE_ZIP_URL_SECONDARY}" "${GRADLE_ZIP_URL_OFFICIAL}")
    materialize_asset "${GRADLE_ZIP_NAME}" "${GRADLE_ZIP_SHA256}" "${zip}" \
        "${urls[@]}" || return $?
    gradle_container_exec mkdir -p "${GRADLE_HOME}" || return 30
    gradle_container_exec rm -rf -- "${GRADLE_HOME}.extract" || return 30
    log_message "extracting ${GRADLE_ZIP_NAME} to ${GRADLE_HOME} inside the private container"
    gradle_container_exec unzip -q "${zip}" -d "${GRADLE_HOME}.extract" || {
        log_message "ERROR: failed to extract the Gradle distribution"
        return 30
    }
    local root
    root="$(find "${GRADLE_HOME}.extract" -maxdepth 1 -mindepth 1 -type d -name 'gradle-*' | head -1)"
    if [[ -z "${root}" ]]; then
        log_message "ERROR: unexpected Gradle distribution layout"
        return 30
    fi
    shopt -s dotglob
    mv "${root}"/* "${GRADLE_HOME}/"
    shopt -u dotglob
    gradle_container_exec rm -rf -- "${GRADLE_HOME}.extract" || return 30
    # The delivery manual explicitly calls out preserving the executable bits of
    # the unpacked distribution.
    gradle_container_exec chmod +x "${GRADLE_HOME}/bin/gradle" || return 30
    gradle_container_exec chmod -R a+rX "${GRADLE_HOME}/lib" || return 30
    local version
    version="$(gradle_version_string || true)"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: installed Gradle reports '${version:-<unknown>}', expected ${SOFTWARE_VERSION}"
        return 30
    fi
}

install_gradle_source() {
    if [[ -d "${GRADLE_SRC_DIR}" ]] && [[ -f "${GRADLE_SRC_DIR}/settings.gradle.kts" ]]; then
        log_message "reusing extracted Gradle source release at ${GRADLE_SRC_DIR}"
        return 0
    fi
    gradle_container_exec rm -rf -- "${GRADLE_SRC_DIR}" || return 30
    local tarball="${PERF_WORK_DIR}/downloads/${GRADLE_SRC_NAME}"
    materialize_asset "${GRADLE_SRC_NAME}" "${GRADLE_SRC_SHA256}" "${tarball}" \
        "${GRADLE_SRC_URL}" "${GRADLE_SRC_URL_FALLBACK}" || return $?
    gradle_container_exec mkdir -p "${GRADLE_SRC_DIR}" || return 30
    log_message "extracting ${GRADLE_SRC_NAME} to ${GRADLE_SRC_DIR} inside the private container"
    gradle_container_exec tar -xzf "${tarball}" -C "${GRADLE_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Gradle source archive"
        return 30
    }
    [[ -f "${GRADLE_SRC_DIR}/settings.gradle.kts" ]] || {
        log_message "ERROR: extracted Gradle source release has no settings.gradle.kts"
        return 30
    }
    local sample
    for sample in "${GRADLE_UPSTREAM_SAMPLES[@]}"; do
        if [[ ! -d "${GRADLE_SRC_DIR}/${sample}" ]]; then
            log_message "ERROR: upstream sample is missing from the source release: ${sample}"
            return 30
        fi
    done
}

generate_projects() {
    local scale project
    for scale in "${GRADLE_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        log_message "generating deterministic Gradle project with ${scale} classes inside the private container"
        gradle_container_env_exec python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${project}" --classes "${scale}" || return 30
    done
}

warm_gradle_user_home() {
    local marker="${PERF_WORK_DIR}/.gradle-home-warmed"
    if [[ -f "${marker}" ]]; then
        log_message "shared Gradle user home was already warmed in this work directory"
        return 0
    fi
    log_message "warming the shared Gradle user home with the 100-class project inside the private container"
    local flags=()
    # shellcheck disable=SC2207
    flags=($(gradle_flags))
    if ! gradle_container_env_exec_at "${PROJECTS_DIR}/project-100" \
        "${GRADLE_BIN}" "${flags[@]}" clean build; then
        log_message "ERROR: failed to warm the Gradle user home"
        return 30
    fi
    touch "${marker}"
}

warm_upstream_samples() {
    local marker="${PERF_WORK_DIR}/.upstream-samples-warmed"
    if [[ -f "${marker}" ]]; then
        log_message "upstream sample projects were already validated in this work directory"
        return 0
    fi
    local sample destination
    for sample in "${GRADLE_UPSTREAM_SAMPLES[@]}"; do
        destination="${PERF_WORK_DIR}/upstream-samples/$(printf '%s' "${sample}" | tr '/' '_')"
        rm -rf -- "${destination}"
        mkdir -p "$(dirname "${destination}")"
        cp -a "${GRADLE_SRC_DIR}/${sample}" "${destination}" || return 30
    done
    local flags=()
    # shellcheck disable=SC2207
    flags=($(gradle_flags))
    export GRADLE_FLAGS="${flags[*]}"
    log_message "warming upstream sample projects (online) inside the private container"
    if ! gradle_container_batch_exec "${PERF_WORK_DIR}/upstream-samples" 0 \
        >"${RESULTS_DIR}/upstream-warmup.log" 2>&1; then
        log_message "ERROR: upstream sample warm-up failed; see ${RESULTS_DIR}/upstream-warmup.log"
        return 30
    fi
    touch "${marker}"
}

smoke_check_matrix() {
    local project="${PROJECTS_DIR}/project-100"
    local log="${RESULTS_DIR}/matrix-smoke.log"
    gradle_container_exec rm -rf -- "${project}/build" || return 30
    log_message "smoke check: clean build of the 100-class matrix project (offline) inside the private container"
    local flags=()
    # shellcheck disable=SC2207
    flags=($(gradle_flags))
    if ! gradle_container_env_exec_at "${project}" \
        "${GRADLE_BIN}" "${flags[@]}" --offline clean build >"${log}" 2>&1; then
        log_message "ERROR: offline matrix smoke build failed; see ${log}"
        return 30
    fi
    if ! grep -q '^BUILD SUCCESSFUL' "${log}"; then
        log_message "ERROR: smoke build did not report BUILD SUCCESSFUL; see ${log}"
        return 30
    fi
    if [[ -z "$( find "${project}/build/libs" -type f -name '*.jar' -print -quit 2>/dev/null )" ]]; then
        log_message "ERROR: smoke build produced no jar; see ${log}"
        return 30
    fi
    log_message "matrix smoke check passed"
}

smoke_check_upstream() {
    local log="${RESULTS_DIR}/upstream-smoke.log"
    local flags
    flags="$(gradle_flags | paste -sd' ')"
    export GRADLE_FLAGS="${flags}"
    log_message "smoke check: offline build of every pinned upstream sample project inside the private container"
    if ! gradle_container_batch_exec "${PERF_WORK_DIR}/upstream-samples" 1 >"${log}" 2>&1; then
        log_message "ERROR: offline upstream sample smoke build failed; see ${log}"
        return 30
    fi
    local sample
    for sample in "${GRADLE_UPSTREAM_SAMPLES[@]}"; do
        if ! grep -q "== sample done: ${sample} rc=0 ==" "${log}"; then
            log_message "ERROR: upstream smoke build did not succeed for ${sample}; see ${log}"
            return 30
        fi
    done
    log_message "upstream smoke check passed"
}

build_gradle_base() {
    initialize_runtime || return $?
    prepare_gradle_build_container || return $?
    resolve_container_jdk || return $?
    install_gradle || return $?
    install_gradle_source || return $?
    record_actual_version || return $?
    generate_projects || return $?
    warm_gradle_user_home || return $?
    warm_upstream_samples || return $?
    smoke_check_matrix || return $?
    smoke_check_upstream || return $?
    log_message "base build completed: Gradle ${SOFTWARE_VERSION}, container JDK ${JDK_MAJOR}.x"
}
