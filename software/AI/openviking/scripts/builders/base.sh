#!/usr/bin/env bash
# Build stage executed identically on x86_64 and aarch64:
#
#   1. create the private openEuler 24.03 LTS SP4 container;
#   2. materialize the OpenViking v0.5.0 benchmark kit: the upstream tag is
#      cloned on the host, its commit is verified and the architecture-specific
#      kit archive is SHA-256 verified before it is copied into the work
#      directory (the container only sees verified bytes);
#   3. inside the container install the runtime toolchain (python3 from the
#      openEuler repository), the kit's pinned dependency set, the v0.5.0 wheel
#      and the instrumented overlay;
#   4. verify the import contract and publish build_variant.json plus the
#      measured-version contract file.
#
# No compiler flags, NUMA binding, cpuset pinning or CPU-frequency tuning are
# applied anywhere: the case measures the out-of-the-box configuration.
set -euo pipefail

openviking_source_commit() {
    printf '%s\n' "${OPENVIKING_COMMIT}"
}

clone_openviking_source() {
    local target="${OPENVIKING_SRC_HOST_DIR}" attempt actual
    if [[ -d "${target}/.git" ]]; then
        actual="$(git -C "${target}" rev-parse HEAD 2>/dev/null || true)"
        if [[ "${actual}" == "${OPENVIKING_COMMIT}" ]]; then
            OPENVIKING_SOURCE_COMMIT="${actual}"
            log_message "reusing verified OpenViking source clone at ${target}"
            return 0
        fi
        log_message "discarding OpenViking source clone with unexpected commit: ${actual:-unknown}"
        rm -rf -- "${target}"
    fi
    mkdir -p "$(dirname "${target}")" || return 30
    command -v git >/dev/null 2>&1 || {
        log_message "ERROR: git is required on the host to materialize the OpenViking source"
        return 30
    }
    for attempt in 1 2 3; do
        rm -rf -- "${target}"
        log_message "cloning OpenViking ${OPENVIKING_TAG} from ${OPENVIKING_REPO_URL} (attempt ${attempt})"
        if git clone --depth 1 --branch "${OPENVIKING_TAG}" "${OPENVIKING_REPO_URL}" "${target}" 2>&1; then
            actual="$(git -C "${target}" rev-parse HEAD)"
            if [[ "${actual}" != "${OPENVIKING_COMMIT}" ]]; then
                log_message "ERROR: ${OPENVIKING_TAG} resolved to ${actual}, pinned commit is ${OPENVIKING_COMMIT}"
                return 30
            fi
            OPENVIKING_SOURCE_COMMIT="${actual}"
            return 0
        fi
        sleep 3
    done
    log_message "ERROR: cannot clone the OpenViking source tree from ${OPENVIKING_REPO_URL}"
    return 30
}

verify_kit_archive() {
    local archive="$1" expected="${OPENVIKING_KIT_SHA256}" actual
    [[ -s "${archive}" ]] || return 1
    actual="$(sha256sum "${archive}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: ${OPENVIKING_KIT_ARCHIVE_NAME} checksum mismatch: ${actual}, expected ${expected}"
        return 1
    fi
    return 0
}

materialize_openviking_kit() {
    local offline_dir="${OPENVIKING_OFFLINE_DIR:-/home/runner/software/openviking}"
    local offline="${offline_dir}/${OPENVIKING_KIT_ARCHIVE_NAME}"
    mkdir -p "$(dirname "${OPENVIKING_KIT_ARCHIVE}")" || return 30
    if [[ -s "${OPENVIKING_KIT_ARCHIVE}" ]] && verify_kit_archive "${OPENVIKING_KIT_ARCHIVE}"; then
        log_message "reusing verified benchmark-kit archive: ${OPENVIKING_KIT_ARCHIVE}"
        return 0
    fi
    rm -f -- "${OPENVIKING_KIT_ARCHIVE}"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline benchmark-kit archive: ${offline}"
        cp -- "${offline}" "${OPENVIKING_KIT_ARCHIVE}" || return 30
        verify_kit_archive "${OPENVIKING_KIT_ARCHIVE}" || return 30
        log_message "verified offline benchmark-kit archive $(basename "${OPENVIKING_KIT_ARCHIVE}")"
        return 0
    fi
    clone_openviking_source || return $?
    local source_archive="${OPENVIKING_SRC_HOST_DIR}/benchmark-kit/${OPENVIKING_KIT_ARCHIVE_NAME}"
    [[ -f "${source_archive}" ]] || {
        log_message "ERROR: the v0.5.0 source tree does not contain ${OPENVIKING_KIT_ARCHIVE_NAME}"
        return 30
    }
    cp -- "${source_archive}" "${OPENVIKING_KIT_ARCHIVE}" || return 30
    verify_kit_archive "${OPENVIKING_KIT_ARCHIVE}" || return 30
    log_message "verified benchmark-kit archive $(basename "${OPENVIKING_KIT_ARCHIVE}") from OpenViking ${OPENVIKING_TAG} (${OPENVIKING_SOURCE_COMMIT:0:12})"
}

install_openviking_toolchain() {
    local log_file="${PERF_WORK_DIR}/dnf-install.log"
    log_message "installing the in-container runtime toolchain from the openEuler repository"
    if ! openviking_container_exec_root bash -c \
        "dnf install -y --setopt=install_weak_deps=False \
            python3 python3-pip python3-devel python3-setuptools \
            gcc gcc-c++ make tar gzip xz findutils procps-ng util-linux" \
        >"${log_file}" 2>&1; then
        tail -30 "${log_file}"
        log_message "ERROR: the in-container runtime toolchain could not be installed"
        return 30
    fi
    log_message "runtime toolchain installed: $(openviking_run 'python3 -V')"
}

install_openviking_runtime() {
    local pip_log="${PERF_WORK_DIR}/pip-install.log"
    openviking_run "mkdir -p '${OPENVIKING_CONTEXT_DIR}' '${OPENVIKING_SITE_DIR}'" || return 30
    log_message "extracting the benchmark-kit archive inside the container"
    openviking_run "tar -xf '${OPENVIKING_KIT_ARCHIVE}' -C '${OPENVIKING_CONTEXT_DIR}'" || {
        log_message "ERROR: cannot extract the benchmark-kit archive"
        return 30
    }
    discover_openviking_kit_layout || return $?

    log_message "installing the kit's pinned dependency set (this is the longest build step)"
    if ! openviking_run "python3 -m pip install --no-cache-dir --disable-pip-version-check \
            --index-url '${OPENVIKING_PIP_INDEX_URL}' --trusted-host '${OPENVIKING_PIP_TRUSTED_HOST}' \
            --target '${OPENVIKING_SITE_DIR}' -r '${OPENVIKING_REQUIREMENTS_LOCK}'" >"${pip_log}" 2>&1; then
        tail -40 "${pip_log}"
        log_message "ERROR: the pinned kit dependency set could not be installed"
        return 30
    fi
    log_message "installing the OpenViking ${SOFTWARE_VERSION} wheel without dependencies"
    if ! openviking_run "python3 -m pip install --no-cache-dir --disable-pip-version-check \
            --no-deps --target '${OPENVIKING_SITE_DIR}' '${OPENVIKING_WHEEL_FILE}'" >>"${pip_log}" 2>&1; then
        tail -40 "${pip_log}"
        log_message "ERROR: the OpenViking wheel could not be installed"
        return 30
    fi
    log_message "applying the instrumented benchmark overlay"
    openviking_run "cp -a '${OPENVIKING_OVERLAY_DIR}/.' '${OPENVIKING_SITE_DIR}/openviking/'" || {
        log_message "ERROR: cannot apply the instrumented overlay"
        return 30
    }
}

verify_openviking_runtime() {
    local version_output
    # The instrumented overlay logs to stdout when OV_AGFS_TIMING is set, so the
    # version is printed with a marker and extracted instead of trimming the
    # whole output.
    version_output="$(openviking_run "OV_AGFS_TIMING=0 python3 -c '
import openviking
print(\"OPENVIKING_VERSION=\" + openviking.__version__)
import openviking.session.memory.streaming_memory_updater
import openviking.session.session
import openviking.session.memory.extract_loop
import openviking.storage.collection_schemas
import openviking.storage.viking_fs._semantic
import openviking.server
import fastapi, uvicorn, openai, json_repair, psutil
'")" || {
        log_message "ERROR: the installed OpenViking runtime failed its import contract"
        return 40
    }
    version_output="$(printf '%s\n' "${version_output}" | sed -n 's/^OPENVIKING_VERSION=//p' | tr -d '[:space:]')"
    if [[ "${version_output}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: installed OpenViking version is ${version_output:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    OPENVIKING_ACTUAL_VERSION="${version_output}"
    log_message "verified OpenViking ${OPENVIKING_ACTUAL_VERSION} runtime import contract"
}

publish_build_info() {
    local python_version kit_dirs kit_json
    python_version="$(openviking_run 'python3 -V 2>&1')"
    kit_dirs="$(cd "${OPENVIKING_KIT_DIR}" && find . -maxdepth 2 -type d | sort | head -n 20)"
    kit_json="$(printf '%s\n' "${kit_dirs}" | awk '{printf "%s\"%s\"", (NR > 1 ? "," : ""), $0}')"
    mkdir -p "${RESULTS_DIR}" || return 40
    cat > "${RESULTS_DIR}/build_variant.json" <<EOF
{
  "software": "openviking",
  "version": "${SOFTWARE_VERSION}",
  "variant": "${PERF_VARIANT}",
  "architecture": "${OPENVIKING_ARCH}",
  "run_id": "${PERF_RUN_ID}",
  "out_of_the_box": true,
  "numa_binding": false,
  "cpuset_pinning": false,
  "source": {
    "repository": "${OPENVIKING_REPO_URL}",
    "tag": "${OPENVIKING_TAG}",
    "commit": "$(openviking_source_commit)",
    "kit_archive": "${OPENVIKING_KIT_ARCHIVE_NAME}",
    "kit_sha256": "${OPENVIKING_KIT_SHA256}"
  },
  "runtime": {
    "container_image": "${OPENVIKING_CONTAINER_IMAGE:-openEuler 24.03 LTS SP4}",
    "python": "${python_version}",
    "kit_layout": [${kit_json}]
  },
  "providers": {
    "llm": "deterministic local OpenAI-compatible mock",
    "embedding": "deterministic local OpenAI-compatible mock",
    "external_network": false
  }
}
EOF
    python3 -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" \
        "${RESULTS_DIR}/build_variant.json" || {
        log_message "ERROR: build_variant.json is not valid JSON"
        return 40
    }
    printf '%s\n' "${OPENVIKING_ACTUAL_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    printf '%s\n' "$(openviking_source_commit)" > "${RESULTS_DIR}/source-commit.txt" || return 40
    printf '%s\n' "${OPENVIKING_KIT_SHA256}" > "${RESULTS_DIR}/kit-sha256.txt" || return 40
    log_message "published build information for OpenViking ${OPENVIKING_ACTUAL_VERSION} (${OPENVIKING_ARCH}, ${PERF_VARIANT})"
}

build_openviking_base() {
    initialize_runtime || return $?
    require_openviking_docker || return $?
    start_openviking_container || return $?
    check_openviking_container || return $?
    materialize_openviking_kit || return $?
    install_openviking_toolchain || return $?
    install_openviking_runtime || return $?
    verify_openviking_runtime || return $?
    publish_build_info || return $?
}
