#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The build stage is the install stage for this case: the measured artifact is a
# vendor RPM plus a container-image bundle, and build.sh --install is what turns
# them into /opt/e2b-infra. The benchmark client is compiled here as well.
build_e2b() {
    configure_runtime_paths || return $?
    case "${PERF_VARIANT}" in
        base) source "${SCRIPT_DIR}/scripts/builders/base.sh"; build_e2b_base || return $? ;;
        optimized) source "${SCRIPT_DIR}/scripts/builders/optimized.sh"; build_e2b_optimized || return $? ;;
        *) log "ERROR: unsupported variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    printf '{"variant":"%s","parameters":{"variant":"%s","rpm":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" "${E2B_RPM_VERSION}" \
        >"${RESULTS_DIR}/build_variant.json"
}
