#!/usr/bin/env bash
set -euo pipefail
# Stage every artifact the vendor suite needs into the shared cache, then expose
# the staged paths through ${PERF_WORK_DIR}/artifacts.list so the install script
# can copy them into /opt/e2b-infra/dep without touching the network again.
#
# The e2b-infra RPM ships an empty dep/ directory; build.sh expects the Docker,
# Harbor, Nomad, Consul and Firecracker archives next to it, so they are fetched
# here once and reused by every later run.

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stage_e2b_artifacts() {
    initialize_runtime || return $?
    local list="${PERF_WORK_DIR}/artifacts.list"
    : >"${list}"
    local spec name url sha size
    for spec in \
        "${E2B_RPM_NAME}|${E2B_RPM_URL}|${E2B_RPM_SHA256}|${E2B_RPM_SIZE}" \
        "${E2B_DOCKER_TGZ}|${E2B_DOCKER_TGZ_URL}|${E2B_DOCKER_TGZ_SHA256}|${E2B_DOCKER_TGZ_SIZE}" \
        "${E2B_HARBOR_TGZ}|${E2B_HARBOR_TGZ_URL}|${E2B_HARBOR_TGZ_SHA256}|${E2B_HARBOR_TGZ_SIZE}" \
        "${E2B_NOMAD_ZIP}|${E2B_NOMAD_ZIP_URL}|${E2B_NOMAD_ZIP_SHA256}|${E2B_NOMAD_ZIP_SIZE}" \
        "${E2B_CONSUL_ZIP}|${E2B_CONSUL_ZIP_URL}|${E2B_CONSUL_ZIP_SHA256}|${E2B_CONSUL_ZIP_SIZE}" \
        "${E2B_FIRECRACKER_TGZ}|${E2B_FIRECRACKER_TGZ_URL}|${E2B_FIRECRACKER_TGZ_SHA256}|${E2B_FIRECRACKER_TGZ_SIZE}"; do
        IFS='|' read -r name url sha size <<<"${spec}"
        fetch_artifact "${name}" "${url}" "${sha}" "${size}" || return $?
        printf '%s\n' "${FETCHED_ARTIFACT}" >>"${list}"
    done
    log "staged $(wc -l <"${list}") artifacts for the vendor suite"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    stage_e2b_artifacts
fi
