#!/usr/bin/env bash
set -euo pipefail

# The E2B case is host-mode (not containerized): the package under test is a
# full control plane (PostgreSQL + Redis + MinIO + Harbor + Nomad + Consul) plus
# a Firecracker compute node. It wants /dev/kvm, hugepages, host networking and
# passwordless sudo, which a private container cannot lend it, so the runner
# installs the vendor suite under /opt/e2b-infra and benchmarks it in place.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-2026.09}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

E2B_ARCHIVE_DIR="${E2B_ARCHIVE_DIR:-/home/runner/software/e2b}"
E2B_INSTALL_DIR="${E2B_INSTALL_DIR:-/opt/e2b-infra}"
E2B_RPM_VERSION="2026.09"
E2B_RPM_NAME="e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm"
E2B_RPM_SIZE=155357261
E2B_RPM_SHA256="19a5363465e7afeaaab7c9ab3387a6d56a04c69b7b0405eac503a9d9d9f1025c"
E2B_RPM_URL="https://eulermaker.openeuler.openatom.cn/api/ems5/repositories/2403sp3/openEuler%3A24.03-LTS-SP3/aarch64/history/5bce9a46-4aad-11f1-a4a9-fa163e474048/last/Packages/${E2B_RPM_NAME}"

E2B_DOCKER_TGZ="docker-25.0.5.tgz"
E2B_DOCKER_TGZ_SIZE=65952372
E2B_DOCKER_TGZ_SHA256="cf3529e0e4d46f83c4c57df4f986df86f011313359d86f33b5bfe6f333f12063"
E2B_DOCKER_TGZ_URL="https://mirrors.aliyun.com/docker-ce/linux/static/stable/aarch64/docker-25.0.5.tgz"

E2B_HARBOR_TGZ="harbor-offline-installer-aarch64-v2.13.0.tgz"
E2B_HARBOR_TGZ_SIZE=669795545
E2B_HARBOR_TGZ_SHA256="4c2c6b2055e79c364166529349187d5edc78055941ffec3d5b4e70269f778320"
E2B_HARBOR_TGZ_URL="https://gh-proxy.com/https://github.com/wise2c-devops/build-harbor-aarch64/releases/download/v2.13.0/harbor-offline-installer-aarch64-v2.13.0.tgz"

E2B_NOMAD_ZIP="nomad_1.10.4_linux_arm64.zip"
E2B_NOMAD_ZIP_SIZE=51166703
E2B_NOMAD_ZIP_SHA256="ebc53a0c232d251f8428d3af45400677c72ec530cc93042d95c60bf34e020169"
E2B_NOMAD_ZIP_URL="https://releases.hashicorp.com/nomad/1.10.4/nomad_1.10.4_linux_arm64.zip"

E2B_CONSUL_ZIP="consul_1.21.4_linux_arm64.zip"
E2B_CONSUL_ZIP_SIZE=65632148
E2B_CONSUL_ZIP_SHA256="50a1b6467a038166684fee25b70ebe9d710e154bd5a179f3e07c655c829646ea"
E2B_CONSUL_ZIP_URL="https://releases.hashicorp.com/consul/1.21.4/consul_1.21.4_linux_arm64.zip"

E2B_FIRECRACKER_TGZ="firecracker-v1.13.1-aarch64.tgz"
E2B_FIRECRACKER_TGZ_SIZE=7239827
E2B_FIRECRACKER_TGZ_SHA256="3ae4006ccb33a068f41d93a9c488cad17356bb9c22418e3c7efc7ca2256a6e84"
E2B_FIRECRACKER_TGZ_URL="https://github.com/firecracker-microvm/firecracker/releases/download/v1.13.1/firecracker-v1.13.1-aarch64.tgz"

E2B_GO_VERSION="${E2B_GO_VERSION:-1.24.5}"
E2B_GO_TGZ="go1.24.5.linux-arm64.tar.gz"
E2B_GO_TGZ_SIZE=74805101
E2B_GO_TGZ_SHA256="0df02e6aeb3d3c06c95ff201d575907c736d6c62cfa4b6934c11203f1d600ffa"
E2B_GO_TGZ_URL="https://mirrors.aliyun.com/golang/go1.24.5.linux-arm64.tar.gz"

# sandbox-bench lives in the BoostKit cloud-native tree; the case pulls the
# bench directory once, caches it as a tarball and rebuilds offline afterwards.
E2B_BENCH_REPO="boostkit/cloud-native"
E2B_BENCH_BRANCH="${E2B_BENCH_BRANCH:-br_26.3.0_devel}"
E2B_BENCH_PATH="pkg/sandbox-bench/bench"
E2B_BENCH_RAW_BASE="https://raw.gitcode.com/${E2B_BENCH_REPO}/raw"
E2B_BENCH_FILES="channel.go client.go config.go config_test.go go.mod http_client.go http_client_test.go log.go logging_test.go main.go observer.go observer_test.go report.go report_integration_test.go report_test.go round.go round_test.go scenario.go scenario_test.go stats.go stats_test.go"

E2B_API_URL="${E2B_API_URL:-http://127.0.0.1:3000}"
E2B_SERVER_IP="${E2B_SERVER_IP:-}"
E2B_API_KEY="${E2B_API_KEY:-}"
E2B_CONFIG_JSON="${E2B_CONFIG_JSON:-/root/.e2b/config.json}"
E2B_TEMPLATE_ALIAS="${E2B_TEMPLATE_ALIAS:-e2b-bench}"
E2B_TEMPLATE_ID="${E2B_TEMPLATE_ID:-}"
E2B_BASE_IMAGE="${E2B_BASE_IMAGE:-ubuntu:22.04-custom}"
E2B_HARBOR_PROJECT="${E2B_HARBOR_PROJECT:-e2b-orchestration}"
E2B_PLATFORM="${E2B_PLATFORM:-infra}"
E2B_SCENARIOS="${E2B_SCENARIOS:-create}"
# 30 is the orchestrator's per-node starting-instance ceiling
# (MAX_STARTING_INSTANCES_PER_NODE), so keep the measured levels below it.
E2B_LEVELS="${E2B_LEVELS:-1,10,20}"
E2B_TOTAL="${E2B_TOTAL:-60}"
E2B_WARMUP_TOTAL="${E2B_WARMUP_TOTAL:-10}"
E2B_WARMUPS="${E2B_WARMUPS:-1}"
E2B_SAMPLES="${E2B_SAMPLES:-6}"
E2B_SANDBOX_TIMEOUT="${E2B_SANDBOX_TIMEOUT:-600}"
E2B_TEARDOWN="${E2B_TEARDOWN:-0}"
E2B_BIN=""
E2B_BENCH_SRC=""
E2B_BENCH_BIN=""
E2B_DEP_DIR=""
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[e2b] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

initialize_runtime() {
    configure_runtime_paths || return $?
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export PERF_ACTUAL_VERSION_FILE
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${RESULTS_DIR}/runs" || return $?
    cd "${SCRIPT_DIR}" || return $?
    return 0
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: unsafe run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/e2b/${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${PERF_WORK_DIR}/results}"
    E2B_DEP_DIR="${E2B_INSTALL_DIR}/dep"
    E2B_BENCH_SRC="${PERF_WORK_DIR}/src/sandbox-bench"
    E2B_BENCH_BIN="${PERF_WORK_DIR}/bin/sandbox-bench"
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${PERF_WORK_DIR}/bin" "${PERF_WORK_DIR}/src"
    # The stage scripts call the host installers as child processes, so the paths
    # they share (run id, work/result directory, artifact list, bench binary) must
    # be exported; otherwise each child would derive its own run id.
    export PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR PERF_VARIANT SOFTWARE_VERSION EXPECTED_ARCH
    export E2B_ARCHIVE_DIR E2B_INSTALL_DIR E2B_DEP_DIR E2B_BENCH_SRC E2B_BENCH_BIN E2B_SERVER_IP
    log "run ${PERF_RUN_ID}: version ${SOFTWARE_VERSION}, variant ${PERF_VARIANT}, arch ${EXPECTED_ARCH}"
    log "work directory: ${PERF_WORK_DIR}"
    log "result directory: ${RESULTS_DIR}"
}

host_preflight() {
    local status=0
    [[ "${EXPECTED_ARCH}" == aarch64 ]] || {
        log 'ERROR: the E2B suite published by openEuler only ships aarch64 artifacts'
        status=30
    }
    [[ "$(normalize_arch "$(uname -m)")" == aarch64 ]] || {
        log 'ERROR: the runner is not aarch64; this case cannot run here'
        status=30
    }
    sudo -n true >/dev/null 2>&1 || { log 'ERROR: passwordless sudo is required'; status=30; }
    [[ -c /dev/kvm ]] || { log 'ERROR: /dev/kvm is missing; Firecracker needs KVM'; status=30; }
    sudo -n test -r /dev/kvm >/dev/null 2>&1 || { log 'ERROR: the runner cannot read /dev/kvm'; status=30; }
    command -v python3 >/dev/null 2>&1 || { log 'ERROR: python3 is required'; status=30; }
    command -v curl >/dev/null 2>&1 || { log 'ERROR: curl is required'; status=30; }
    command -v docker >/dev/null 2>&1 || { log 'ERROR: docker is required on the host'; status=30; }
    sudo -n docker version --format '{{.Server.Version}}' >/dev/null 2>&1 || {
        log 'ERROR: the docker daemon is not reachable through sudo'
        status=30
    }
    [[ "${status}" -eq 0 ]] || return "${status}"
    log "host preflight passed: aarch64, /dev/kvm, sudo, docker $(sudo -n docker version --format '{{.Server.Version}}' 2>/dev/null)"
}

e2b_installed() {
    [[ -f "${E2B_INSTALL_DIR}/build.sh" ]]
}

e2b_api_healthy() {
    local code
    code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 8 "${E2B_API_URL}/health" 2>/dev/null || true)"
    [[ "${code}" == 200 ]]
}

e2b_team_api_key() {
    if [[ -n "${E2B_API_KEY}" ]]; then
        printf '%s\n' "${E2B_API_KEY}"
        return 0
    fi
    sudo -n python3 - "${E2B_CONFIG_JSON}" <<'PY' 2>/dev/null
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
    print(data.get("teamApiKey", ""))
except Exception:
    print("")
PY
}

require_e2b_api_key() {
    local key
    key="$(e2b_team_api_key)"
    [[ -n "${key}" ]] || {
        log "ERROR: no team API key; ${E2B_CONFIG_JSON} is missing or the start stage did not run"
        return 40
    }
    E2B_API_KEY="${key}"
    export E2B_API_KEY
    return 0
}

e2b_sandboxes() {
    curl -sS --max-time 30 -H "X-API-Key: ${E2B_API_KEY}" "${E2B_API_URL}/sandboxes" 2>/dev/null
}

# --- Deployment ACL tokens --------------------------------------------------
# `build.sh --start` bootstraps one Consul ACL root token and one Nomad ACL token
# and stores them in /opt/e2b-infra/.env. Both are needed later:
# `run-nomad.sh` aborts with "The value for '--consul-token' cannot be empty", and
# `deploy.sh` submits jobs with `nomad job run --token $NOMAD_ACL_TOKEN` (an empty
# token makes nomad read the job file as the token value and fail with "This
# command takes one argument: <path>").
#
# Two vendor behaviours lose them: `build.sh --install` copies dep/.env over
# /opt/e2b-infra/.env, and both Consul and Nomad keep their ACL state across
# restarts, so their bootstrap steps refuse to run a second time. The case caches
# both tokens next to the artifacts, restores them before every install/start and
# falls back to a full vendor reset (`build.sh --stop`, which also drops
# /data/consul and /data/nomad) when neither the live env nor the cache has them.
E2B_ACL_CACHE_FILE=""

acl_env_var() {
    case "$1" in
        consul) printf 'CONSUL_ACL_TOKEN\n' ;;
        nomad) printf 'NOMAD_ACL_TOKEN\n' ;;
        *) return 1 ;;
    esac
}

acl_token() {
    local name="$1" var token=""
    var="$(acl_env_var "${name}")" || return 1
    if [[ -s "${E2B_INSTALL_DIR}/.env" ]]; then
        token="$(sudo -n grep -E "^export ${var}=.+" "${E2B_INSTALL_DIR}/.env" 2>/dev/null \
            | head -1 | sed -E "s/^export ${var}=//")"
    fi
    if [[ -z "${token}" && -s "${E2B_ACL_CACHE_FILE}" ]]; then
        token="$(grep -E "^${name}=" "${E2B_ACL_CACHE_FILE}" 2>/dev/null | head -1 | cut -d= -f2-)"
    fi
    printf '%s\n' "${token}"
}

set_env_token() {
    local name="$1" token="$2" file="$3" var
    var="$(acl_env_var "${name}")" || return 1
    sudo -n test -f "${file}" || return 0
    if sudo -n grep -qE "^export ${var}=" "${file}" 2>/dev/null; then
        sudo -n sed -i -E "s|^export ${var}=.*|export ${var}=${token}|" "${file}" || return $?
    else
        sudo -n sh -c "printf 'export %s=%s\n' '${var}' '${token}' >> '${file}'" || return $?
    fi
}

# Put the cached tokens back into both env files so the next install/start reuses
# the live ACLs instead of trying to bootstrap them again. Returns 0 only when
# both tokens are known.
restore_acl_tokens() {
    E2B_ACL_CACHE_FILE="${E2B_ACL_CACHE_FILE:-${E2B_ARCHIVE_DIR}/e2b-acl-tokens.env}"
    local name token missing=0
    for name in consul nomad; do
        token="$(acl_token "${name}")"
        if [[ -z "${token}" ]]; then
            missing=1
            continue
        fi
        set_env_token "${name}" "${token}" "${E2B_DEP_DIR}/.env" || return $?
        set_env_token "${name}" "${token}" "${E2B_INSTALL_DIR}/.env" || return $?
    done
    if [[ "${missing}" -eq 1 ]]; then
        log 'the ACL tokens are not both known yet; the vendor start has to bootstrap them'
        return 1
    fi
    log 'restored the cached Consul and Nomad ACL tokens into both env files'
    return 0
}

save_acl_tokens() {
    E2B_ACL_CACHE_FILE="${E2B_ACL_CACHE_FILE:-${E2B_ARCHIVE_DIR}/e2b-acl-tokens.env}"
    local name token tmp="${E2B_ACL_CACHE_FILE}.tmp" found=0
    mkdir -p "$(dirname "${E2B_ACL_CACHE_FILE}")" 2>/dev/null || true
    : >"${tmp}" 2>/dev/null || { log 'WARN: cannot write the ACL token cache'; return 1; }
    for name in consul nomad; do
        token="$(acl_token "${name}")"
        [[ -n "${token}" ]] || continue
        found=1
        printf '%s=%s\n' "${name}" "${token}" >>"${tmp}"
        set_env_token "${name}" "${token}" "${E2B_DEP_DIR}/.env" || true
    done
    if [[ "${found}" -eq 0 ]]; then
        rm -f "${tmp}"
        return 1
    fi
    mv -f "${tmp}" "${E2B_ACL_CACHE_FILE}" || return 1
    log 'cached the Consul/Nomad ACL tokens for later runs'
    return 0
}

# Host-side network leftovers (netns + veth + iptables) accumulate on every
# --start/--stop cycle and make every `ip` call print
# "Peer netns reference is invalid". The helper is the single implementation; it
# is also copied to /opt/e2b-infra so the patched vendor `iptable_clean` can use
# it.
E2B_NET_CLEANUP="${SCRIPT_DIR}/scripts/host/cleanup-e2b-network.sh"

cleanup_e2b_network() {
    local mode="${1:---stale}"
    [[ -f "${E2B_NET_CLEANUP}" ]] || return 0
    sudo -n bash "${E2B_NET_CLEANUP}" "${mode}" 2>/dev/null || true
    return 0
}

# `build.sh --stop` only kills processes whose command line starts with a handful of
# names (redis, /client-proxy, /api, template-manager), so the orchestrator processes
# survive and keep their ports (5007/5008/5010/5016). A restart then fails with
# "failed to listen on port 5008: bind: address already in use" and the Nomad job dies
# on its progress deadline. Reap whatever still holds an E2B-only port.
E2B_SERVICE_PORTS="5007 5008 5009 5010 5016 3000 3002"

reap_stale_e2b_processes() {
    local port pids pid cmd killed=0
    for port in ${E2B_SERVICE_PORTS}; do
        pids="$(sudo -n ss -lntp 2>/dev/null | awk -v p=":${port}\$" '$4 ~ p' \
            | grep -oE 'pid=[0-9]+' | cut -d= -f2 | sort -u)"
        [[ -n "${pids}" ]] || continue
        for pid in ${pids}; do
            cmd="$(sudo -n tr '\0' ' ' <"/proc/${pid}/cmdline" 2>/dev/null || true)"
            case "${cmd}" in
                *orchestrator*|*e2b*|*client-proxy*|*template-manager*|*'/usr/bin/api'*)
                    log "stopping stale E2B process ${pid} holding :${port} (${cmd% })"
                    sudo -n kill -9 "${pid}" 2>/dev/null || true
                    killed=1
                    ;;
            esac
        done
    done
    [[ "${killed}" -eq 1 ]] && sleep 2
    return 0
}

# Sandboxes are billed per second and consume hugepages, so every round is
# followed by a delete sweep; a leftover sandbox would also poison the next
# round's memory_delta observation.
cleanup_sandboxes() {
    local ids status=0
    require_e2b_api_key || return 50
    ids="$(e2b_sandboxes | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    data = []
print("\n".join(item.get("sandboxID", "") for item in data if item.get("sandboxID")))
' 2>/dev/null)" || return 50
    if [[ -n "${ids}" ]]; then
        local id
        while IFS= read -r id; do
            [[ -n "${id}" ]] || continue
            curl -sS -o /dev/null --max-time 60 -X DELETE \
                -H "X-API-Key: ${E2B_API_KEY}" "${E2B_API_URL}/sandboxes/${id}" 2>/dev/null || status=50
        done <<<"${ids}"
    fi
    local attempt remaining
    for attempt in $(seq 1 60); do
        remaining="$(e2b_sandboxes | python3 -c 'import json,sys
try:
    print(len(json.load(sys.stdin)))
except Exception:
    print(1)' 2>/dev/null)"
        if [[ "${remaining:-1}" == 0 ]]; then
            # Measured rounds must not be disturbed here: the leftover sweep
            # rewrites the nat table (one iptables-restore), which briefly drops
            # the Docker DNAT the API uses to reach PostgreSQL. It therefore runs
            # once, after the last round, from the test and stop stages.
            return 0
        fi
        sleep 2
    done
    log 'ERROR: sandboxes are still present after cleanup'
    return 50
}

# Host-side residue of the deleted sandboxes: the per-address egress SNAT rules
# (`-A POSTROUTING -s 10.11.x.y/32 -j MASQUERADE`), which carry no veth name and
# therefore survive the vendor delete path. Only safe while the API lists no
# sandbox, which is what cleanup_sandboxes() guarantees right before calling it.
# The `start-<uuid>` containers are *not* touched: those are the Nomad service
# allocations of the control plane (api/client-proxy/redis/template-manager).
reap_sandbox_leftovers() {
    cleanup_e2b_network --sandbox-leftovers || true
}

write_actual_version() {
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || return 0
    printf '%s\n' "${1:-${SOFTWARE_VERSION}}" >"${PERF_ACTUAL_VERSION_FILE}"
}

cached_artifact() { printf '%s/dl/%s\n' "${E2B_ARCHIVE_DIR}" "$1"; }

# fetch_artifact <name> <url> <sha256> <size>
# Sets FETCHED_ARTIFACT (never echoes it: progress lines go to stdout).
FETCHED_ARTIFACT=""

fetch_artifact() {
    local name="$1" url="$2" sha="$3" size="$4"
    local cached target
    FETCHED_ARTIFACT=""
    cached="$(cached_artifact "${name}")"
    target="${PERF_WORK_DIR}/${name}"
    mkdir -p "${E2B_ARCHIVE_DIR}/dl" "${PERF_WORK_DIR}" 2>/dev/null || return 30
    if [[ -s "${target}" ]]; then
        log "reusing ${target} from this run"
    elif [[ -s "${cached}" ]]; then
        log "reusing staged artifact ${cached}"
        cp -- "${cached}" "${target}" || { log "ERROR: cannot copy ${cached}"; return 30; }
    else
        log "downloading ${name} (kept under ${E2B_ARCHIVE_DIR}/dl afterwards)"
        with_network_proxy curl -fSL --retry 3 --max-time 3600 -o "${target}.part" "${url}" || {
            log "ERROR: failed to download ${url}"; return 30;
        }
        mv -- "${target}.part" "${target}" || return 30
        cp -- "${target}" "${cached}" 2>/dev/null || sudo -n cp -- "${target}" "${cached}" 2>/dev/null || true
    fi
    printf '%s  %s\n' "${sha}" "${target}" | sha256sum -c - >/dev/null 2>&1 || {
        log "ERROR: ${name} sha256 mismatch"; return 30
    }
    if [[ "$(stat -c %s "${target}")" != "${size}" ]]; then
        log "ERROR: ${name} size mismatch"; return 30
    fi
    FETCHED_ARTIFACT="${target}"
    return 0
}

ensure_go() {
    if command -v go >/dev/null 2>&1 && go version >/dev/null 2>&1; then
        local current
        current="$(go version | awk '{print $3}')"
        log "using the toolchain already on PATH: ${current}"
        return 0
    fi
    if [[ -x /usr/local/go/bin/go ]]; then
        export PATH="/usr/local/go/bin:${PATH}"
        log "using /usr/local/go: $(go version)"
        return 0
    fi
    fetch_artifact "${E2B_GO_TGZ}" "${E2B_GO_TGZ_URL}" "${E2B_GO_TGZ_SHA256}" "${E2B_GO_TGZ_SIZE}" || return $?
    sudo -n rm -rf /usr/local/go || return $?
    sudo -n tar -C /usr/local -xzf "${FETCHED_ARTIFACT}" || return $?
    export PATH="/usr/local/go/bin:${PATH}"
    go version >/dev/null 2>&1 || { log 'ERROR: the Go toolchain is unusable'; return 30; }
    log "installed $(go version) under /usr/local/go"
}

# The bench source is fetched once from gitcode and cached as a tarball, so a
# later offline build only needs the cache.
prepare_bench_source() {
    local cache="${E2B_ARCHIVE_DIR}/src/sandbox-bench-${E2B_BENCH_BRANCH}.tar.gz"
    if [[ -s "${E2B_BENCH_SRC}/go.mod" ]]; then
        log "reusing the bench source already unpacked in ${E2B_BENCH_SRC}"
        return 0
    fi
    mkdir -p "${E2B_BENCH_SRC}" || return $?
    if [[ -s "${cache}" ]]; then
        log "unpacking the cached bench source ${cache}"
        tar -xzf "${cache}" -C "${E2B_BENCH_SRC}" || return 30
        [[ -s "${E2B_BENCH_SRC}/go.mod" ]] && return 0
        log 'WARN: the cached bench tarball was incomplete; refetching'
        rm -rf "${E2B_BENCH_SRC}" && mkdir -p "${E2B_BENCH_SRC}" || return 30
    fi
    local file code
    for file in ${E2B_BENCH_FILES}; do
        code="$(with_network_proxy curl -sSL --retry 2 --max-time 120 \
            -o "${E2B_BENCH_SRC}/${file}" -w '%{http_code}' \
            "${E2B_BENCH_RAW_BASE}/${E2B_BENCH_BRANCH}/${E2B_BENCH_PATH}/${file}" 2>/dev/null || true)"
        if [[ "${code}" != 200 || ! -s "${E2B_BENCH_SRC}/${file}" ]]; then
            log "ERROR: cannot fetch ${file} from ${E2B_BENCH_RAW_BASE}/${E2B_BENCH_BRANCH}"
            return 30
        fi
    done
    mkdir -p "$(dirname "${cache}")" || return $?
    tar -czf "${cache}" -C "${E2B_BENCH_SRC}" . || return 30
    log "cached the bench source at ${cache}"
    return 0
}

build_bench_binary() {
    prepare_bench_source || return $?
    export PATH="/usr/local/go/bin:${PATH}"
    export GOFLAGS="${GOFLAGS:-}"
    export GOPROXY="${GOPROXY:-off}"
    ( cd "${E2B_BENCH_SRC}" && go build -trimpath -o "${E2B_BENCH_BIN}" . ) || {
        log 'ERROR: go build failed for sandbox-bench'
        return 30
    }
    [[ -x "${E2B_BENCH_BIN}" ]] || { log 'ERROR: sandbox-bench was not produced'; return 30; }
    log "built ${E2B_BENCH_BIN} from ${E2B_BENCH_REPO}/${E2B_BENCH_PATH}@${E2B_BENCH_BRANCH}"
}
