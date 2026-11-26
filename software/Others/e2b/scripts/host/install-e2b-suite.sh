#!/usr/bin/env bash
set -euo pipefail
# Install (or refresh) the E2B suite on the runner host.
#
# Steps, in the vendor's own order:
#   1. rpm -ivh the e2b-infra package (idempotent: skipped when already present)
#   2. copy the staged archives into /opt/e2b-infra/dep
#   3. patch the shipped build.sh/deploy.sh for a shared, offline runner
#   4. build.sh --install (nginx, dnsmasq, python wheels, Harbor, images)
#
# build.sh --start is handled by the start stage, because it must run under a
# pseudo terminal (deploy.sh uses `docker exec -it`).

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

E2B_PATCHER="${SCRIPT_DIR}/scripts/host/patch-e2b-shared-runner.py"

# The vendor env file ships `export SERVER_IP=""` and every address in the suite
# (PostgreSQL, MinIO, Harbor, the Consul-advertised services) is derived from it.
# The vendor's one-click flow expects the operator to fill it in, so resolve the
# host LAN address once and keep it (idempotent: an already-set value wins).
detect_server_ip() {
    local ip
    ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") {print $(i + 1); exit}}' || true)"
    [[ -n "${ip}" ]] || ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
    printf '%s\n' "${ip}"
}

ensure_server_ip() {
    local env_file="${E2B_DEP_DIR}/.env"
    [[ -s "${env_file}" ]] || { log "ERROR: ${env_file} is missing; the RPM layout changed"; return 30; }
    local current ip
    current="$(sudo -n grep -E '^export SERVER_IP=' "${env_file}" | head -1 | sed -E 's/^export SERVER_IP="?([^"]*)"?$/\1/' || true)"
    if [[ -n "${current}" ]]; then
        log "SERVER_IP is already set to ${current} in ${env_file}"
        E2B_SERVER_IP="${current}"
        return 0
    fi
    ip="$(detect_server_ip)"
    [[ -n "${ip}" ]] || { log 'ERROR: cannot determine the host LAN address for SERVER_IP'; return 30; }
    sudo -n sed -i -E "s|^export SERVER_IP=.*|export SERVER_IP=${ip}|" "${env_file}" || return 30
    E2B_SERVER_IP="${ip}"
    log "set SERVER_IP=${ip} in ${env_file}"
    return 0
}

install_e2b_suite() {
    initialize_runtime || return $?
    host_preflight || return $?
    local list="${PERF_WORK_DIR}/artifacts.list"
    [[ -s "${list}" ]] || { log 'ERROR: artifacts are not staged; run stage-e2b-artifacts.sh first'; return 30; }

    local rpm_path=""
    local path
    while IFS= read -r path; do
        [[ "$(basename "${path}")" == "${E2B_RPM_NAME}" ]] && rpm_path="${path}"
    done <"${list}"
    [[ -n "${rpm_path}" ]] || { log 'ERROR: the e2b-infra RPM is not staged'; return 30; }

    if sudo -n rpm -q e2b-infra >/dev/null 2>&1; then
        log "e2b-infra is already installed ($(sudo -n rpm -q e2b-infra 2>/dev/null)); reusing ${E2B_INSTALL_DIR}"
    else
        log "installing $(basename "${rpm_path}")"
        sudo -n rpm -ivh "${rpm_path}" >"${PERF_WORK_DIR}/rpm-install.log" 2>&1 || {
            log 'ERROR: rpm -ivh failed'
            tail -20 "${PERF_WORK_DIR}/rpm-install.log" || true
            return 30
        }
    fi
    [[ -f "${E2B_INSTALL_DIR}/build.sh" ]] || {
        log "ERROR: ${E2B_INSTALL_DIR}/build.sh is missing after the RPM install"
        return 30
    }

    log "staging the archives into ${E2B_DEP_DIR}"
    sudo -n mkdir -p "${E2B_DEP_DIR}" || return $?
    while IFS= read -r path; do
        sudo -n cp -f -- "${path}" "${E2B_DEP_DIR}/" || return $?
    done <"${list}"

    ensure_server_ip || return $?

    # The patched vendor `iptable_clean` calls this helper instead of flushing the
    # host ruleset, so it has to exist before the vendor script runs.
    if [[ -f "${E2B_NET_CLEANUP}" ]]; then
        sudo -n install -m 0755 "${E2B_NET_CLEANUP}" \
            "${E2B_INSTALL_DIR}/cleanup-e2b-network.sh" || {
            log 'ERROR: could not install the network cleanup helper'
            return 30
        }
    fi

    # build.sh --install copies dep/.env over /opt/e2b-infra/.env, so push the
    # cached Consul/Nomad ACL tokens into dep/.env first (see common.sh).
    restore_acl_tokens || true

    patch_suite() {
        local deploy_sh="$1"
        sudo -n python3 "${E2B_PATCHER}" \
            --build-sh "${E2B_INSTALL_DIR}/build.sh" \
            --deploy-sh "${deploy_sh}"
    }

    # build.sh --install (and --start) copy dep/*.sh over /opt/e2b-infra/*.sh, so
    # the fixes have to land in dep/ as well; otherwise the seed-db prompt blocks
    # `build.sh --start` for good.
    log 'patching build.sh/deploy.sh for a shared runner without Docker Hub access'
    patch_suite "${E2B_INSTALL_DIR}/deploy.sh" || {
        log 'ERROR: the shared-runner patch failed'
        return 30
    }
    patch_suite "${E2B_DEP_DIR}/deploy.sh" || {
        log 'ERROR: the shared-runner patch failed for dep/deploy.sh'
        return 30
    }

    log 'running build.sh --install (nginx, dnsmasq, python wheels, Harbor, images)'
    sudo -n env PATH="/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        bash -c "cd '${E2B_INSTALL_DIR}' && bash build.sh --install" \
        >"${PERF_WORK_DIR}/build-install.log" 2>&1 || {
        log 'ERROR: build.sh --install failed'
        tail -40 "${PERF_WORK_DIR}/build-install.log" || true
        return 30
    }
    # --install has just restored the vendor copies, so re-apply the deploy.sh fix
    # to the file that --start will actually execute.
    patch_suite "${E2B_INSTALL_DIR}/deploy.sh" >/dev/null 2>&1 || {
        log 'ERROR: the post-install patch failed'
        return 30
    }
    log 'build.sh --install completed'
    write_actual_version "${E2B_RPM_VERSION}"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_e2b_suite
fi
