#!/usr/bin/env bash
# Base build.  The host only downloads and verifies the pinned Maven
# distribution/source archives and the framework assets; the JDK is installed with
# dnf, both archives are unpacked, the deterministic projects are generated and
# the private Maven repository / upstream self-build are warmed inside this task's
# private openEuler 24.03 LTS SP4 container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host prerequisites are limited to Docker plus the download/verification tools.
require_host_transfer_commands() {
    local command_name
    for command_name in curl tar gzip sha256sum sha512sum awk python3; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "WARNING: host command is missing: ${command_name}; relying on the pre-placed offline assets"
        }
    done
    return 0
}

prepare_maven_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_maven_docker || return 30
    start_maven_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Java toolchain inside the private container"
    # Weak dependencies are disabled: the openEuler java-21-openjdk-devel package
    # pulls dbus-daemon through a weak dependency, and its scriptlet cannot run in
    # this container (the host /etc/passwd and /etc/group are mounted read-only).
    maven_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False \
        "${JDK_PACKAGES[@]}" tar gzip coreutils findutils which || {
        log_message "ERROR: container package installation failed"
        return 30
    }
    maven_container_exec env "PATH=${MAVEN_CONTAINER_PATH_PREFIX}" \
        sh -c 'command -v java && command -v javac' || {
        log_message "ERROR: the container toolchain is not usable after installation"
        return 30
    }
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

# Host-side asset transfer: the offline directory is tried first and every
# candidate is verified against the same pinned digest.
materialize_asset() {
    local name="$1" algorithm="$2" expected="$3" destination="$4"
    shift 4
    local -a urls=("$@")
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
            if verify_checksum "${destination}.part" "${algorithm}" "${expected}"; then
                mv -- "${destination}.part" "${destination}"
                downloaded=1
                break
            fi
            log_message "WARNING: checksum mismatch from ${url}, trying the next source"
            rm -f -- "${destination}.part"
        done
        if (( downloaded == 0 )); then
            log_message "ERROR: every download source failed for ${name}"
            return 30
        fi
    fi
    verify_checksum "${destination}" "${algorithm}" "${expected}"
}

# The JDK is a property of the pinned container image, not of the host: resolve
# where dnf installed it, persist that path for the later stages and verify the
# major version (the exact package build is runtime context only).
resolve_container_jdk() {
    local resolved java_version
    resolved="$(maven_container_exec bash -c 'readlink -f "$(command -v javac)"' 2>/dev/null)" || resolved=""
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
        maven_container_exec test -x "${JDK_HOME}/bin/${tool}" || {
            log_message "ERROR: the container JDK does not provide bin/${tool}"
            return 30
        }
    done
    log_message "container JDK ${java_version} resolved at ${JDK_HOME}"
}

install_maven() {
    local version
    version="$(maven_version_string || true)"
    if maven_container_exec test -x "${MAVEN_BIN}" && [[ "${version}" == "${SOFTWARE_VERSION}" ]]; then
        log_message "reusing Maven ${SOFTWARE_VERSION} at ${MAVEN_HOME}"
        return 0
    fi
    maven_container_exec rm -rf -- "${MAVEN_HOME}" || return 30
    local tarball="${PERF_WORK_DIR}/downloads/${MAVEN_BIN_NAME}"
    materialize_asset "${MAVEN_BIN_NAME}" sha512 \
        "${MAVEN_BIN_SHA512}" "${tarball}" "${MAVEN_BIN_URLS[@]}" || return $?
    maven_container_exec mkdir -p "${MAVEN_HOME}" || return 30
    log_message "extracting ${MAVEN_BIN_NAME} to ${MAVEN_HOME} inside the private container"
    maven_container_exec tar -xzf "${tarball}" -C "${MAVEN_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Maven distribution"
        return 30
    }
    maven_container_exec chmod +x "${MAVEN_BIN}" || return 30
    maven_container_exec test -x "${MAVEN_BIN}" || {
        log_message "ERROR: Maven launcher is not executable: ${MAVEN_BIN}"
        return 30
    }
    version="$(maven_version_string || true)"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: installed Maven reports '${version:-<unknown>}', expected ${SOFTWARE_VERSION}"
        return 30
    fi
}

install_maven_sources() {
    if maven_container_exec test -f "${MAVEN_SRC_DIR}/pom.xml"; then
        log_message "reusing extracted Maven sources at ${MAVEN_SRC_DIR}"
        return 0
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${MAVEN_SRC_NAME}"
    materialize_asset "${MAVEN_SRC_NAME}" sha512 \
        "${MAVEN_SRC_SHA512}" "${tarball}" "${MAVEN_SRC_URLS[@]}" || return $?
    maven_container_exec rm -rf -- "${MAVEN_SRC_DIR}" || return 30
    maven_container_exec mkdir -p "${MAVEN_SRC_DIR}" || return 30
    log_message "extracting ${MAVEN_SRC_NAME} to ${MAVEN_SRC_DIR} inside the private container"
    maven_container_exec tar -xzf "${tarball}" -C "${MAVEN_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Maven source archive"
        return 30
    }
    maven_container_exec test -f "${MAVEN_SRC_DIR}/pom.xml" || {
        log_message "ERROR: extracted Maven sources have no pom.xml"
        return 30
    }
}

record_actual_version() {
    export_java_env
    local version_line maven_version
    version_line="$(maven_version_output)" || {
        log_message "ERROR: failed to execute ${MAVEN_BIN} -v inside the private container"
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
    local java_version
    java_version="$(java_version_string)" || java_version=""
    if [[ "${java_version}" != "${JDK_MAJOR}."* ]]; then
        log_message "ERROR: expected container JDK ${JDK_MAJOR}.x, got: ${java_version:-<unknown>}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${maven_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    # The result parser runs on the host and only needs the runtime context, so the
    # container JDK release line is copied out next to the other evidence.
    local java_banner java_release
    java_banner="$(maven_container_env_exec java -version 2>&1)" || java_banner=""
    java_release="$(printf '%s\n' "${java_banner}" | sed -n '1s/.*"\([^"]*\)".*/\1/p')"
    printf 'JAVA_VERSION="%s"\n' "${java_release:-unknown}" > "${PERF_WORK_DIR}/container-jdk-release.txt"
    log_message "recorded actual Maven version: ${maven_version} (container JDK ${java_version})"
    log_message "runtime: $(printf '%s\n' "${version_line}" | tr '\n' ';' | sed 's/;;*/; /g')"
}

generate_projects() {
    local scale project
    for scale in "${MAVEN_SCALES[@]}"; do
        project="${PROJECTS_DIR}/project-${scale}"
        log_message "generating deterministic project with ${scale} classes inside the private container"
        maven_container_env_exec python3 "${SCRIPT_DIR}/scripts/generate_project.py" \
            --output "${project}" --classes "${scale}" || return 40
    done
}

# Fallback settings.xml used only for the untimed warm-up when the runner cannot
# reach the repositories declared by the projects themselves.  The measured
# scenarios always run with -o (offline), so this cannot alter the measured
# dependency set; it only lets the warm-up complete on restricted networks.
write_fallback_maven_settings() {
    local settings="${PERF_WORK_DIR}/maven-fallback-settings.xml"
    mkdir -p "$(dirname "${settings}")"
    cat >"${settings}" <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <mirrors>
    <mirror>
      <id>perf-fallback-central</id>
      <name>Public Central mirror used for the untimed warm-up</name>
      <url>${MAVEN_FALLBACK_MIRROR_URL}</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
EOF
    log_message "wrote fallback Maven settings: ${settings}"
}

maven_prefetch_run() {
    local directory="$1"
    shift
    local argv=("${MAVEN_SETTINGS_ARGV[@]}")
    if [[ -n "${MAVEN_FALLBACK_SETTINGS:-}" ]]; then
        argv+=(-s "${MAVEN_FALLBACK_SETTINGS}")
    fi
    maven_container_env_exec_at "${directory}" \
        "${MAVEN_BIN}" -B -ntp "${argv[@]}" "-Dmaven.repo.local=${M2_REPO}" -Dstyle.color=never "$@"
}

prefetch_build_dependencies() {
    export_java_env
    local marker="${PERF_WORK_DIR}/.prefetch-project-repo.done"
    if [[ -f "${marker}" ]]; then
        log_message "private Maven repository was already warmed in this work directory"
        return 0
    fi
    local project="${PROJECTS_DIR}/project-100"
    log_message "warming the private Maven repository with the 100-class project (network allowed) inside the private container"
    if ! maven_prefetch_run "${project}" -DskipTests clean package; then
        if [[ -z "${MAVEN_SETTINGS_ARGV[*]:-}" && -n "${MAVEN_FALLBACK_MIRROR_URL}" ]]; then
            log_message "WARNING: warm-up failed with the default repositories; retrying through ${MAVEN_FALLBACK_MIRROR_URL}"
            write_fallback_maven_settings || return 30
            MAVEN_FALLBACK_SETTINGS="${PERF_WORK_DIR}/maven-fallback-settings.xml"
            export MAVEN_FALLBACK_SETTINGS
            maven_prefetch_run "${project}" -DskipTests clean package || {
                log_message "ERROR: failed to warm the private Maven repository"
                return 40
            }
        else
            log_message "ERROR: failed to warm the private Maven repository"
            return 40
        fi
    fi
    touch "${marker}"
}

prefetch_self_build_dependencies() {
    export_java_env
    local marker="${PERF_WORK_DIR}/.prefetch-self-build.done"
    if [[ -f "${marker}" ]]; then
        log_message "upstream Maven self-build was already validated in this work directory"
        return 0
    fi
    log_message "prefetching and validating the upstream Maven self-build (network allowed) inside the private container"
    if ! maven_prefetch_run "${MAVEN_SRC_DIR}" -DskipTests -Drat.skip=true -Dmaven.javadoc.skip=true \
        -Dmaven.source.skip=true -Dcheckstyle.skip=true clean package; then
        if [[ -z "${MAVEN_SETTINGS_ARGV[*]:-}" && -n "${MAVEN_FALLBACK_MIRROR_URL}" ]]; then
            log_message "WARNING: upstream self-build warm-up failed; retrying through ${MAVEN_FALLBACK_MIRROR_URL}"
            write_fallback_maven_settings || return 30
            MAVEN_FALLBACK_SETTINGS="${PERF_WORK_DIR}/maven-fallback-settings.xml"
            export MAVEN_FALLBACK_SETTINGS
            maven_prefetch_run "${MAVEN_SRC_DIR}" -DskipTests -Drat.skip=true -Dmaven.javadoc.skip=true \
                -Dmaven.source.skip=true -Dcheckstyle.skip=true clean package || {
                log_message "ERROR: upstream Maven self-build prefetch failed"
                return 40
            }
        else
            log_message "ERROR: upstream Maven self-build prefetch failed"
            return 40
        fi
    fi
    touch "${marker}"
}

build_maven_base() {
    initialize_runtime || return $?
    prepare_maven_build_container || return $?
    resolve_container_jdk || return $?
    install_maven || return $?
    install_maven_sources || return $?
    record_actual_version || return $?
    generate_projects || return $?
    prefetch_build_dependencies || return $?
    prefetch_self_build_dependencies || return $?
    log_message "base build completed: container JDK ${JDK_MAJOR}.x, Maven ${SOFTWARE_VERSION}"
}
