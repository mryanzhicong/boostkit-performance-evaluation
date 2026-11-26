#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_e2b_runtime() {
    local status=0 attempt
    initialize_runtime >/dev/null 2>&1 || true
    # The end-of-run leftover sweep rewrites the nat table, which can make the
    # control plane miss a beat; give it a moment instead of skipping the
    # sandbox cleanup.
    for attempt in $(seq 1 12); do
        e2b_api_healthy && break
        sleep 5
    done
    if e2b_api_healthy; then
        cleanup_sandboxes || { log 'ERROR: sandbox cleanup failed'; status=50; }
    else
        log 'the control plane is not answering; no sandbox can be listed'
    fi
    if [[ "${E2B_TEARDOWN}" == 1 ]]; then
        if [[ -f "${E2B_INSTALL_DIR}/build.sh" ]]; then
            log 'stopping the suite (E2B_TEARDOWN=1): build.sh --stop'
            sudo -n env PATH="/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
                bash -c "cd '${E2B_INSTALL_DIR}' && timeout 900 build.sh --stop" \
                >"${PERF_WORK_DIR}/build-stop.log" 2>&1 || status=50
        else
            log 'the suite is not installed; nothing to stop'
        fi
        # The vendor stop only tries `umount ... && rm -f ...`, which leaves the
        # namespaces, the veths, the iptables redirects and the exited containers
        # behind. Reclaim them here so the next case starts from a clean host.
        log 'reclaiming the host network state left by the sandbox orchestrator'
        cleanup_e2b_network --all
    else
        # Even when the suite stays up, the orphans of earlier interrupted runs
        # are dead weight (they are what makes `ip` print
        # "Peer netns reference is invalid").
        cleanup_e2b_network --stale
        reap_sandbox_leftovers
        log 'leaving the suite running (set E2B_TEARDOWN=1 to stop it)'
    fi
    return "${status}"
}
