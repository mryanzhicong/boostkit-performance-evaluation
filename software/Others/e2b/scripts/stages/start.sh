#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

e2b_wait_healthy() {
    local attempt code
    for attempt in $(seq 1 90); do
        code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "${E2B_API_URL}/health" 2>/dev/null || true)"
        if [[ "${code}" == 200 ]]; then
            log "the control plane answers ${E2B_API_URL}/health with 200 (attempt ${attempt})"
            return 0
        fi
        sleep 5
    done
    return 40
}

# /health only proves the HTTP layer is up. build.sh --install recreates the
# PostgreSQL container, so after a re-install the database is empty while the API
# still answers /health: every authenticated call then fails with
# `relation "public.team_api_keys" does not exist`. Probe /templates with the team
# key instead, and re-run the vendor's deploy step when it does not answer 200.
e2b_team_api_ok() {
    local key code
    key="$(e2b_team_api_key 2>/dev/null || true)"
    [[ -n "${key}" ]] || return 1
    code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 \
        -H "X-API-Key: ${key}" "${E2B_API_URL}/templates" 2>/dev/null || true)"
    [[ "${code}" == 200 ]]
}

# `build.sh --start` ends with `deploy.sh`, whose seed-db step prints an
# interactive prompt before reading stdin. The prompt is printed even when the
# patch feeds the answers, so it cannot be used as a failure signal on its own:
# only a prompt followed by a log that stops growing is a real block (that
# happens when the vendor copies an unpatched dep/deploy.sh over the patched
# one).
run_vendor_start() {
    local log_file="${PERF_WORK_DIR}/build-start.log"
    log 'starting the suite: build.sh --start under a pseudo terminal'
    sudo -n env PATH="/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        bash -c "cd '${E2B_INSTALL_DIR}' && timeout 1800 script -qec 'bash build.sh --start' /dev/null" \
        >"${log_file}" 2>&1 &
    local start_pid=$! baseline=0 stalled=0 current
    while kill -0 "${start_pid}" 2>/dev/null; do
        sleep 10
        sudo -n grep -q 'Please enter the following values' "${log_file}" 2>/dev/null || continue
        current="$(sudo -n awk 'END {print NR}' "${log_file}" 2>/dev/null)"
        if [[ "${current}" == "${baseline}" ]]; then
            stalled=$((stalled + 1))
        else
            baseline="${current}"
            stalled=0
        fi
        # ~60 s without a single new line after the prompt: the vendor start is
        # waiting for a terminal that will never answer.
        if [[ "${stalled}" -ge 6 ]]; then
            log 'ERROR: build.sh --start is blocked on the deploy.sh seed-db prompt'
            log 'ERROR: the shared-runner patch of dep/deploy.sh did not take effect'
            sudo -n pkill -f 'bin/seed-db' >/dev/null 2>&1 || true
            sudo -n pkill -f 'build.sh --start' >/dev/null 2>&1 || true
            kill -9 "${start_pid}" >/dev/null 2>&1 || true
            wait "${start_pid}" 2>/dev/null || true
            return 40
        fi
    done
    wait "${start_pid}"
}

# Last resort: the vendor cannot reuse the ACL state any more (both tokens are
# gone, or start keeps rejecting them). `build.sh --stop` is the vendor's own reset
# -- it stops Consul/Nomad and removes /data/consul, /data/nomad and the Harbor
# volumes -- after which --install + --start bootstrap a fresh deployment.
reset_e2b_deployment() {
    log 'WARN: resetting the deployment: build.sh --stop, then --install and --start again'
    sudo -n env PATH="/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        bash -c "cd '${E2B_INSTALL_DIR}' && timeout 1200 bash build.sh --stop" \
        >"${PERF_WORK_DIR}/build-stop.log" 2>&1 || {
        log 'WARN: build.sh --stop reported errors; continuing with the reset'
        tail -10 "${PERF_WORK_DIR}/build-stop.log" || true
    }
    rm -f "${E2B_ACL_CACHE_FILE}" 2>/dev/null || true
    sudo -n rm -f "${E2B_ACL_CACHE_FILE}" 2>/dev/null || true
    reap_stale_e2b_processes || true
    # The vendor stop never removes the netns/veth/iptables state, so a restarted
    # orchestrator inherits >1k dead namespaces and every `ip` call fails.
    cleanup_e2b_network --all
    bash "${SCRIPT_DIR}/scripts/host/install-e2b-suite.sh" || return $?
    return 0
}

ensure_e2b_runtime() {
    if e2b_api_healthy && e2b_team_api_ok; then
        log "the E2B control plane is already serving ${E2B_API_URL} and the team key works"
        save_acl_tokens || true
        return 0
    fi
    # deploy.sh calls `docker exec -it psql`, which needs a terminal; build.sh
    # --start is therefore wrapped in `script` so the install completes when the
    # stage runs without a TTY. The vendor's start is idempotent and re-seeds the
    # database, which is exactly what an empty schema needs.
    if restore_acl_tokens; then
        if run_vendor_start && e2b_wait_healthy && e2b_team_api_ok; then
            save_acl_tokens || true
            return 0
        fi
        log 'WARN: the vendor start could not reuse the cached ACL tokens'
        tail -20 "${PERF_WORK_DIR}/build-start.log" || true
    fi
    reset_e2b_deployment || return $?
    restore_acl_tokens || true
    run_vendor_start || {
        log 'ERROR: build.sh --start failed'
        tail -40 "${PERF_WORK_DIR}/build-start.log" || true
        return 40
    }
    e2b_wait_healthy || {
        log 'ERROR: the control plane did not become healthy'
        tail -20 "${PERF_WORK_DIR}/build-start.log" || true
        return 40
    }
    e2b_team_api_ok || {
        log 'ERROR: the team API key still does not authorize GET /templates after build.sh --start'
        tail -20 "${PERF_WORK_DIR}/build-start.log" || true
        return 40
    }
    save_acl_tokens || true
    return 0
}
ensure_e2b_template() {
    if [[ -n "${E2B_TEMPLATE_ID}" ]]; then
        log "using the caller-provided template ${E2B_TEMPLATE_ID}"
        return 0
    fi
    local output="${PERF_WORK_DIR}/template-create.log"
    local access_token
    access_token="$(sudo -n python3 -c "
import json
try:
    print(json.load(open('${E2B_CONFIG_JSON}', encoding='utf-8')).get('accessToken', ''))
except Exception:
    print('')
" 2>/dev/null || true)"
    sudo -n env E2B_API_URL="${E2B_API_URL}" E2B_API_KEY="${E2B_API_KEY}" E2B_ACCESS_TOKEN="${access_token}" \
        PATH="/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        python3 "${SCRIPT_DIR}/scripts/template/create_bench_template.py" \
        --alias "${E2B_TEMPLATE_ALIAS}" --base-image "${E2B_BASE_IMAGE}" \
        >"${output}" 2>&1 || {
        log 'ERROR: template creation failed'
        tail -30 "${output}" || true
        return 40
    }
    E2B_TEMPLATE_ID="$(grep -oE 'TEMPLATE_ID=[0-9a-z]+' "${output}" | head -1 | cut -d= -f2 || true)"
    [[ -n "${E2B_TEMPLATE_ID}" ]] || {
        log 'ERROR: template creation did not report a template ID'
        tail -20 "${output}" || true
        return 40
    }
    printf '%s\n' "${E2B_TEMPLATE_ID}" >"${RESULTS_DIR}/template_id"
    log "template ${E2B_TEMPLATE_ID} (alias ${E2B_TEMPLATE_ALIAS}) is ready"
    return 0
}

start_e2b_runtime() {
    initialize_runtime || return $?
    host_preflight || return $?
    e2b_installed || {
        log "ERROR: ${E2B_INSTALL_DIR} is missing; run the build stage first"; return 30
    }
    ensure_e2b_runtime || return $?
    require_e2b_api_key || return $?
    ensure_e2b_template || return $?
    [[ -x "${E2B_BENCH_BIN}" ]] || {
        log 'ERROR: sandbox-bench is missing; run the build stage first'; return 40
    }
    log "validating one real sandbox creation against ${E2B_API_URL} (template ${E2B_TEMPLATE_ID})"
    E2B_API_URL="${E2B_API_URL}" E2B_API_KEY="${E2B_API_KEY}" E2B_TEMPLATE_ID="${E2B_TEMPLATE_ID}" \
        "${E2B_BENCH_BIN}" --platform "${E2B_PLATFORM}" --scenario create \
        --requests 1 --concurrency 1 --rounds 1 --warmup 0 \
        --output "${PERF_WORK_DIR}/e2b-smoke.json" \
        >"${PERF_WORK_DIR}/e2b-smoke.log" 2>&1 || {
        log 'ERROR: the E2B smoke run failed'
        tail -20 "${PERF_WORK_DIR}/e2b-smoke.log" || true
        cleanup_sandboxes || true
        return 40
    }
    python3 - "${PERF_WORK_DIR}/e2b-smoke.json" <<'PY' || { cleanup_sandboxes || true; return 40; }
import json, sys
report = json.load(open(sys.argv[1], encoding="utf-8"))
summary = report.get("summary") or {}
if summary.get("success") != 1 or summary.get("success_rate") != 1:
    print(f"smoke run did not create a sandbox: {summary}")
    raise SystemExit(1)
print("smoke run created one sandbox successfully")
PY
    cleanup_sandboxes || return $?
    write_actual_version "${E2B_RPM_VERSION}"
    log "runtime ready: concurrency levels ${E2B_LEVELS}, ${E2B_TOTAL} sandboxes per sample, scenarios ${E2B_SCENARIOS}"
}
