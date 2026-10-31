#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc|stat) printf 'coreutils\n' ;;
        unzip) printf 'unzip\n' ;;
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

    local offline_candidates=(
        "${GRADLE_OFFLINE_DIR}/${name}"
        "${PERF_GRADLE_JDK_FALLBACK_DIR:-/home/runner/software/maven}/${name}"
    )
    local candidate
    for candidate in "${offline_candidates[@]}"; do
        if [[ -f "${candidate}" ]]; then
            log_message "using pre-placed offline asset: ${candidate}"
            cp -- "${candidate}" "${destination}"
            verify_sha256 "${destination}" "${sha256}" && return 0
            rm -f -- "${destination}"
        fi
    done

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
    log_message "ERROR: could not obtain a verified ${name}; tried offline assets and every download source"
    return 30
}

install_jdk() {
    local expected_java="${JDK_HOME}/bin/java"
    if [[ -x "${expected_java}" ]]; then
        local installed
        installed="$("${expected_java}" -version 2>&1 | sed -n '1{s/^openjdk version "//;s/".*$//;p}')"
        if [[ "${installed}" == "${JDK_SEMVER}"* ]]; then
            log_message "reusing Temurin JDK ${installed} at ${JDK_HOME}"
            return 0
        fi
        log_message "removing unexpected JDK ${installed:-<unknown>} at ${JDK_HOME}"
        rm -rf -- "${JDK_HOME}"
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${JDK_TARBALL_NAME}"
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

install_gradle() {
    if [[ -x "${GRADLE_BIN}" ]] && [[ "$(gradle_version_string || true)" == "${SOFTWARE_VERSION}" ]]; then
        log_message "reusing Gradle ${SOFTWARE_VERSION} at ${GRADLE_HOME}"
        return 0
    fi
    rm -rf -- "${GRADLE_HOME}"
    local zip="${PERF_WORK_DIR}/downloads/${GRADLE_ZIP_NAME}"
    local urls=()
    if [[ -n "${PERF_GRADLE_MIRROR:-}" ]]; then
        urls+=("${PERF_GRADLE_MIRROR%/}/${GRADLE_ZIP_NAME}")
    fi
    urls+=("${GRADLE_ZIP_URL_PRIMARY}" "${GRADLE_ZIP_URL_SECONDARY}" "${GRADLE_ZIP_URL_OFFICIAL}")
    materialize_asset "${GRADLE_ZIP_NAME}" "${GRADLE_ZIP_SHA256}" "${zip}" \
        "${urls[@]}" || return $?
    mkdir -p "${GRADLE_HOME}"
    rm -rf -- "${GRADLE_HOME}.extract"
    log_message "extracting ${GRADLE_ZIP_NAME} to ${GRADLE_HOME}"
    unzip -q "${zip}" -d "${GRADLE_HOME}.extract" || {
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
    rm -rf -- "${GRADLE_HOME}.extract"
    # The delivery manual explicitly calls out preserving the executable bits of
    # the unpacked distribution.
    chmod +x "${GRADLE_HOME}/bin/gradle" || return 30
    chmod -R a+rX "${GRADLE_HOME}/lib" || return 30
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
    rm -rf -- "${GRADLE_SRC_DIR}"
    local tarball="${PERF_WORK_DIR}/downloads/${GRADLE_SRC_NAME}"
    materialize_asset "${GRADLE_SRC_NAME}" "${GRADLE_SRC_SHA256}" "${tarball}" \
        "${GRADLE_SRC_URL}" "${GRADLE_SRC_URL_FALLBACK}" || return $?
    mkdir -p "${GRADLE_SRC_DIR}"
    log_message "extracting ${GRADLE_SRC_NAME} to ${GRADLE_SRC_DIR}"
    tar -xzf "${tarball}" -C "${GRADLE_SRC_DIR}" --strip-components=1 || {
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
        log_message "generating deterministic Gradle project with ${scale} classes"
        python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${project}" --classes "${scale}" || return 30
    done
}

warm_gradle_user_home() {
    local marker="${PERF_WORK_DIR}/.gradle-home-warmed"
    if [[ -f "${marker}" ]]; then
        log_message "shared Gradle user home was already warmed in this work directory"
        return 0
    fi
    log_message "warming the shared Gradle user home with the 100-class project"
    local flags=()
    # shellcheck disable=SC2207
    flags=($(gradle_flags))
    (
        cd "${PROJECTS_DIR}/project-100" || exit 1
        "${GRADLE_BIN}" "${flags[@]}" clean build
    ) || {
        log_message "ERROR: failed to warm the Gradle user home"
        return 30
    }
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
    # Warm-up uses the exact batch runner that the measurement stage uses, only
    # with network access enabled so that every plugin/dependency is cached.
    local flags=()
    # shellcheck disable=SC2207
    flags=($(gradle_flags))
    log_message "warming upstream sample projects (online)"
    if ! UPSTREAM_WORK_DIR="${PERF_WORK_DIR}/upstream-samples" \
        GRADLE_BATCH_OFFLINE=0 GRADLE_FLAGS="${flags[*]}" \
        GRADLE_UPSTREAM_SAMPLE_LIST="${GRADLE_UPSTREAM_SAMPLE_LIST}" \
        bash "${SCRIPT_DIR}/scripts/run_upstream_batch.sh" \
        >"${RESULTS_DIR}/upstream-warmup.log" 2>&1; then
        log_message "ERROR: upstream sample warm-up failed; see ${RESULTS_DIR}/upstream-warmup.log"
        return 30
    fi
    touch "${marker}"
}

smoke_check_matrix() {
    local project="${PROJECTS_DIR}/project-100"
    local log="${RESULTS_DIR}/matrix-smoke.log"
    rm -rf -- "${project}/build"
    log_message "smoke check: clean build of the 100-class matrix project (offline)"
    if ! (
        cd "${project}" || exit 1
        "${GRADLE_BIN}" $(gradle_flags) --offline clean build
    ) >"${log}" 2>&1; then
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
    log_message "smoke check: offline build of every pinned upstream sample project"
    if ! UPSTREAM_WORK_DIR="${PERF_WORK_DIR}/upstream-samples" \
        GRADLE_BATCH_OFFLINE=1 GRADLE_FLAGS="$(gradle_flags | paste -sd' ')" \
        GRADLE_UPSTREAM_SAMPLE_LIST="${GRADLE_UPSTREAM_SAMPLE_LIST}" \
        bash "${SCRIPT_DIR}/scripts/run_upstream_batch.sh" >"${log}" 2>&1; then
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
    require_commands curl unzip tar sha256sum python3 awk || return $?
    install_jdk || return $?
    install_gradle || return $?
    install_gradle_source || return $?
    record_actual_version || return $?
    generate_projects || return $?
    warm_gradle_user_home || return $?
    warm_upstream_samples || return $?
    smoke_check_matrix || return $?
    smoke_check_upstream || return $?
    log_message "base build completed: Gradle ${SOFTWARE_VERSION}, Temurin JDK ${JDK_RELEASE}"
}
