#!/usr/bin/env bash
set -euo pipefail

# Global cleanup for dedicated performance runners. This intentionally removes
# resources left by any previous job, not only resources tagged by this run.

MODE="${1:-}"
WORK_ROOT="${PERF_WORK_ROOT:-/tmp/boostkit-perf}"
readonly TMP_PATTERNS=(
    "/tmp/faiss_build_*"
    "/tmp/hnswlib_build_*"
    "/tmp/openviking_build_*"
    "/tmp/protobuf_build_*"
    "/tmp/snappy_build_*"
    "/tmp/shunit2_*"
)

log() { printf '[cleanup] %s\n' "$*"; }
fail() { printf '[cleanup] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "${PERF_DEDICATED_RUNNER:-}" != "true" ]]; then
    fail "PERF_DEDICATED_RUNNER=true is required; refusing global cleanup"
fi
if [[ "${WORK_ROOT}" != "/tmp/boostkit-perf" ]]; then
    fail "PERF_WORK_ROOT must be exactly /tmp/boostkit-perf"
fi
if [[ "${MODE}" != "--before" && "${MODE}" != "--after" && "${MODE}" != "--verify" ]]; then
    fail "usage: $0 --before|--after|--verify"
fi
command -v docker >/dev/null 2>&1 || fail "docker is required to certify a clean runner"

matching_processes() {
    ps -eo pid=,args= | awk -v root="${WORK_ROOT}/" '
        index($0, root) { print $1 }
    ' | awk -v self="$$" -v parent="${PPID}" '$1 != self && $1 != parent'
}

matching_mounts() {
    command -v findmnt >/dev/null 2>&1 || return 0
    findmnt -rn -o TARGET | awk -v root="${WORK_ROOT}/" 'index($0, root) == 1'
}

verify_clean() {
    local dirty=0
    if [[ -n "$(matching_processes)" ]]; then
        log "residual processes still reference ${WORK_ROOT}"
        matching_processes >&2
        dirty=1
    fi
    if [[ -d "${WORK_ROOT}" ]] && find "${WORK_ROOT}" -mindepth 1 -print -quit | grep -q .; then
        log "${WORK_ROOT} is not empty"
        dirty=1
    fi
    if matching_mounts | grep -q .; then
        log "mounts remain below ${WORK_ROOT}"
        dirty=1
    fi
    if [[ -n "$(docker ps -aq)" ]]; then
        log "Docker containers remain"
        dirty=1
    fi
    if [[ -n "$(docker image ls -aq)" ]]; then
        log "Docker images remain"
        dirty=1
    fi
    if [[ -n "$(docker volume ls -q)" ]]; then
        log "Docker volumes remain"
        dirty=1
    fi
    if [[ -n "$(docker network ls --filter type=custom -q)" ]]; then
        log "custom Docker networks remain"
        dirty=1
    fi
    local pattern
    for pattern in "${TMP_PATTERNS[@]}"; do
        if find /tmp -maxdepth 1 -mindepth 1 -name "${pattern##*/}" -print -quit | grep -q .; then
            log "known test temporary paths remain for ${pattern##*/}"
            dirty=1
        fi
    done
    [[ "${dirty}" -eq 0 ]] || fail "runner cleanliness verification failed; quarantine this runner"
    log "runner cleanliness verification passed"
}

if [[ "${MODE}" == "--verify" ]]; then
    verify_clean
    exit 0
fi

log "starting ${MODE#--} global cleanup on dedicated runner"

mapfile -t pids < <(matching_processes)
if ((${#pids[@]})); then
    kill -TERM "${pids[@]}" 2>/dev/null || true
    mapfile -t pids < <(matching_processes)
    if ((${#pids[@]})); then
        kill -KILL "${pids[@]}" 2>/dev/null || true
    fi
fi

mapfile -t containers < <(docker ps -aq)
if ((${#containers[@]})); then
    docker rm -f "${containers[@]}"
fi
docker network prune --force
docker volume prune --all --force
docker image prune --all --force
docker builder prune --all --force

mkdir -p "${WORK_ROOT}"
if command -v findmnt >/dev/null 2>&1; then
    mapfile -t mounts < <(matching_mounts | sort -r)
    for mountpoint in "${mounts[@]}"; do
        [[ "${mountpoint}" == "${WORK_ROOT}" ]] && continue
        umount --lazy --force "${mountpoint}"
    done
fi
find "${WORK_ROOT}" -mindepth 1 -delete
for pattern in "${TMP_PATTERNS[@]}"; do
    # Patterns are fixed above and deliberately restricted to known case prefixes.
    find /tmp -maxdepth 1 -mindepth 1 -name "${pattern##*/}" -exec rm -rf -- {} +
done

verify_clean
