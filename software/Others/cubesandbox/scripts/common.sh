#!/usr/bin/env bash
set -euo pipefail

# The CubeSandbox case is host-mode (not containerized): the measured stack is a
# full KVM control plane + compute node, so the runner lends the host its KVM,
# XFS reflink storage and sudo instead of a private container.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.8.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

CUBESANDBOX_ARCHIVE_DIR="${CUBESANDBOX_ARCHIVE_DIR:-/home/runner/software/cubesandbox}"
CUBESANDBOX_RELEASE_TAG="v0.8.0"
CUBESANDBOX_COMMIT="41748bb78d6384962b4e417ff9215720ea7472fd"
CUBESANDBOX_SOURCE_URL="https://github.com/TencentCloud/CubeSandbox/archive/refs/tags/v0.8.0.tar.gz"
CUBESANDBOX_SOURCE_SHA256="c2de64cb316580492625a12065158264a5bfb3abd096a04ced0c8743fa0ffeae"
CUBESANDBOX_SOURCE_SIZE=40894189
CUBESANDBOX_ONE_CLICK_ARM64_SHA256="a7dcf6faa80416aab323050aac275e3385a3f49778a46256715608a26a4cb4f4"
CUBESANDBOX_ONE_CLICK_ARM64_SIZE=223970625
CUBESANDBOX_ONE_CLICK_AMD64_SHA256="06e0cce7b43cbff831504a3cb21687c69841d6be743125bc32a138929b796ad3"
CUBESANDBOX_ONE_CLICK_AMD64_SIZE=305860175
CUBESANDBOX_RELEASE_BASE_URL="https://github.com/TencentCloud/CubeSandbox/releases/download/${CUBESANDBOX_RELEASE_TAG}"

CUBESANDBOX_API_URL="${CUBESANDBOX_API_URL:-http://127.0.0.1:3000}"
CUBESANDBOX_API_KEY="${CUBESANDBOX_API_KEY:-e2b_000000}"
CUBESANDBOX_MASTER_ADDR="${CUBESANDBOX_MASTER_ADDR:-127.0.0.1}"
CUBESANDBOX_MASTER_PORT="${CUBESANDBOX_MASTER_PORT:-8089}"
CUBESANDBOX_TEMPLATE_IMAGE="${CUBESANDBOX_TEMPLATE_IMAGE:-cube-sandbox-cn.tencentcloudcr.com/cube-sandbox/sandbox-code:latest}"
CUBESANDBOX_TEMPLATE_ID="${CUBESANDBOX_TEMPLATE_ID:-}"
CUBESANDBOX_ALLOW_PROVISION="${CUBESANDBOX_ALLOW_PROVISION:-1}"
CUBESANDBOX_MIRROR="${CUBESANDBOX_MIRROR:-cn}"
# The upstream default sandbox network 192.168.0.0/18 overlaps most office LANs
# and docker0, so let the caller pin one and otherwise auto-pick a free /16.
CUBESANDBOX_NETWORK_CIDR="${CUBESANDBOX_NETWORK_CIDR:-}"
CUBESANDBOX_DNSMASQ_MODE="${CUBESANDBOX_DNSMASQ_MODE:-}"
CUBESANDBOX_TOOLBOX_DIR="${CUBESANDBOX_TOOLBOX_DIR:-/usr/local/services/cubetoolbox}"
CUBESANDBOX_PROXY_WORKERS="${CUBESANDBOX_PROXY_WORKERS:-16}"
CUBESANDBOX_LEVELS="${CUBESANDBOX_LEVELS:-1,20,50}"
# One node fits roughly 400 concurrent sandboxes (CubeMaster answers
# ret_code 130597 "no more resource" past that on this 384-vCPU/1.5TiB host), so
# every sample must stay clearly below the ceiling.
CUBESANDBOX_TOTAL="${CUBESANDBOX_TOTAL:-300}"
CUBESANDBOX_WARMUP_TOTAL="${CUBESANDBOX_WARMUP_TOTAL:-50}"
CUBESANDBOX_INNER_WARMUP="${CUBESANDBOX_INNER_WARMUP:-3}"
CUBESANDBOX_WARMUPS="${CUBESANDBOX_WARMUPS:-1}"
CUBESANDBOX_SAMPLES="${CUBESANDBOX_SAMPLES:-6}"
CUBESANDBOX_DATA_DIR="${CUBESANDBOX_DATA_DIR:-/data}"
CUBESANDBOX_DATA_IMG="${CUBESANDBOX_DATA_IMG:-${HOME}/cubesandbox-data.img}"
CUBESANDBOX_DATA_SIZE="${CUBESANDBOX_DATA_SIZE:-200G}"
CUBESANDBOX_GO_VERSION="${CUBESANDBOX_GO_VERSION:-1.25.0}"
CUBESANDBOX_GO_SIZE=57159737
CUBESANDBOX_GO_SHA256="05de75d6994a2783699815ee553bd5a9327d8b79991de36e38b66862782f54ae"
# examples/cube-bench declares `go 1.25.0` in its go.mod, so an older toolchain
# would try to download a newer one at build time and fail on an offline runner.
CUBESANDBOX_GOPROXY="${CUBESANDBOX_GOPROXY:-https://goproxy.cn,direct https://mirrors.aliyun.com/goproxy/,direct}"
CUBESANDBOX_GO_MIRRORS=(
    "https://mirrors.aliyun.com/golang/go${CUBESANDBOX_GO_VERSION}.linux-arm64.tar.gz"
    "https://golang.google.cn/dl/go${CUBESANDBOX_GO_VERSION}.linux-arm64.tar.gz"
    "https://dl.google.com/go/go${CUBESANDBOX_GO_VERSION}.linux-arm64.tar.gz"
    "https://mirrors.huaweicloud.com/golang/go${CUBESANDBOX_GO_VERSION}.linux-arm64.tar.gz"
)

CUBESANDBOX_INSTALL_DIR=""
CUBESANDBOX_PACKAGE_DIR=""
CUBESANDBOX_CUBE_BENCH=""
CUBESANDBOX_SOURCE_DIR=""
CUBESANDBOX_DATA_LOOP=""
CUBESANDBOX_DATA_CREATED=0
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[cubesandbox] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

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

# Every artifact is staged once under CUBESANDBOX_ARCHIVE_DIR (default
# /home/runner/software/cubesandbox). Later runs reuse the staged copy instead of
# downloading again, which matters on links where the 224 MB bundle takes ~15 min.
cached_artifact() {
    printf '%s/%s\n' "${CUBESANDBOX_ARCHIVE_DIR}" "$1"
}

stage_into_cache() {
    local source="$1" name="$2" cached
    cached="$(cached_artifact "${name}")"
    mkdir -p "${CUBESANDBOX_ARCHIVE_DIR}" 2>/dev/null || return 0
    if [[ -s "${cached}" ]]; then
        return 0
    fi
    cp -- "${source}" "${cached}" 2>/dev/null || sudo -n cp -- "${source}" "${cached}" 2>/dev/null || true
    [[ -s "${cached}" ]] && log "staged ${name} into ${CUBESANDBOX_ARCHIVE_DIR} for later runs"
    return 0
}

# fetch_artifact <name> <url> <sha256> <size>
# On success sets FETCHED_ARTIFACT to the verified local path (never echoes it,
# because the progress messages go to stdout and would corrupt a $(...)).
FETCHED_ARTIFACT=""

fetch_artifact() {
    local name="$1" url="$2" sha="$3" size="$4"
    local cached target
    FETCHED_ARTIFACT=""
    cached="$(cached_artifact "${name}")"
    target="${PERF_WORK_DIR}/${name}"
    mkdir -p "${PERF_WORK_DIR}" 2>/dev/null || return 30
    if [[ -s "${target}" ]]; then
        log "reusing ${target} from this run"
    elif [[ -s "${cached}" ]]; then
        log "reusing staged artifact ${cached}"
        cp -- "${cached}" "${target}" || { log "ERROR: cannot copy ${cached}"; return 30; }
    else
        log "downloading ${name} once (staged into ${cached} afterwards)"
        with_network_proxy curl -fsSL --retry 3 --max-time 3600 -o "${target}.part" "${url}" || {
            log "ERROR: failed to download ${url}"; return 30;
        }
        mv -- "${target}.part" "${target}" || return 30
        stage_into_cache "${target}" "${name}"
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

prepare_source() {
    local archive
    fetch_artifact "CubeSandbox-${SOFTWARE_VERSION}.tar.gz" \
        "${CUBESANDBOX_SOURCE_URL}" "${CUBESANDBOX_SOURCE_SHA256}" "${CUBESANDBOX_SOURCE_SIZE}" || return 30
    archive="${FETCHED_ARTIFACT}"
    rm -rf -- "${PERF_WORK_DIR}/src" || return 30
    mkdir -p "${PERF_WORK_DIR}/src" || return 30
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}/src" || return 30
    CUBESANDBOX_SOURCE_DIR="$(find "${PERF_WORK_DIR}/src" -maxdepth 1 -type d -name 'CubeSandbox-*' 2>/dev/null | head -1 || true)"
    [[ -d "${CUBESANDBOX_SOURCE_DIR}/examples/cube-bench" ]] || {
        log 'ERROR: examples/cube-bench is missing from the source archive'; return 30
    }
    log "source tree: ${CUBESANDBOX_SOURCE_DIR}"
}

go_supports_cube_bench() {
    local version major minor
    version="$("$1" env GOVERSION 2>/dev/null || "$1" version 2>/dev/null | awk '{print $3}' || true)"
    version="${version#go}"
    major="${version%%.*}"
    minor="${version#*.}"; minor="${minor%%.*}"
    [[ "${major}" =~ ^[0-9]+$ && "${minor}" =~ ^[0-9]+$ ]] || return 1
    (( major > 1 || (major == 1 && minor >= 25) ))
}

ensure_go() {
    if command -v go >/dev/null 2>&1 && go_supports_cube_bench "$(command -v go)"; then
        log "using the host Go toolchain: $(go version 2>&1 | awk '{print $3}')"
        return 0
    fi
    local root="${PERF_WORK_DIR}/goroot"
    if [[ ! -x "${root}/go/bin/go" ]] || ! go_supports_cube_bench "${root}/go/bin/go"; then
        local name tarball url tried=0
        name="go${CUBESANDBOX_GO_VERSION}.linux-arm64.tar.gz"
        mkdir -p "${root}" || return 30
        if [[ -s "$(cached_artifact "${name}")" ]]; then
            fetch_artifact "${name}" "https://dl.google.com/go/${name}" \
                "${CUBESANDBOX_GO_SHA256}" "${CUBESANDBOX_GO_SIZE}" || return 30
            tarball="${FETCHED_ARTIFACT}"
        else
            for url in "${CUBESANDBOX_GO_MIRRORS[@]}"; do
                tried=1
                if with_network_proxy curl -fsSL --retry 2 --max-time 1800 \
                    -o "${PERF_WORK_DIR}/${name}.part" "${url}"; then
                    log "downloaded the pinned Go toolchain from ${url}"
                    mv -- "${PERF_WORK_DIR}/${name}.part" "${PERF_WORK_DIR}/${name}" || return 30
                    break
                fi
            done
            [[ "${tried}" -eq 1 && -s "${PERF_WORK_DIR}/${name}" ]] || {
                log 'ERROR: no Go mirror responded'; return 30
            }
            tarball="${PERF_WORK_DIR}/${name}"
            printf '%s  %s\n' "${CUBESANDBOX_GO_SHA256}" "${tarball}" | sha256sum -c - >/dev/null 2>&1 || {
                log 'ERROR: Go toolchain checksum mismatch'; return 30
            }
            if [[ "$(stat -c %s "${tarball}")" != "${CUBESANDBOX_GO_SIZE}" ]]; then
                log 'ERROR: Go toolchain size mismatch'; return 30
            fi
            stage_into_cache "${tarball}" "${name}"
        fi
        tar -C "${root}" -xzf "${tarball}" || return 30
    fi
    export PATH="${root}/go/bin:${PATH}"
    go_supports_cube_bench "${root}/go/bin/go" || {
        log 'ERROR: the pinned Go toolchain does not support go 1.25 modules'; return 30
    }
    log "using the pinned Go toolchain: $("${root}/go/bin/go" version | awk '{print $3}')"
}

build_cube_bench() {
    local proxy built=0
    mkdir -p "$(dirname "${CUBESANDBOX_CUBE_BENCH}")" || return 40
    log 'building examples/cube-bench with the upstream sources'
    for proxy in ${CUBESANDBOX_GOPROXY}; do
        log "go build with GOPROXY=${proxy}"
        if ( cd "${CUBESANDBOX_SOURCE_DIR}/examples/cube-bench" && \
             CGO_ENABLED=0 GOOS=linux GOARCH=arm64 GOTOOLCHAIN=local GOPROXY="${proxy}" \
               go build -trimpath -buildvcs=false -o "${CUBESANDBOX_CUBE_BENCH}" . ); then
            built=1
            break
        fi
    done
    [[ "${built}" -eq 1 ]] || { log 'ERROR: cube-bench build failed'; return 40; }
    [[ -x "${CUBESANDBOX_CUBE_BENCH}" ]] || { log 'ERROR: cube-bench binary is missing'; return 40; }
    "${CUBESANDBOX_CUBE_BENCH}" --help >/dev/null 2>&1 || {
        log 'ERROR: the built cube-bench binary does not run'; return 40
    }
    log "cube-bench built: $(stat -c %s "${CUBESANDBOX_CUBE_BENCH}") bytes"
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
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/cubesandbox/${PERF_RUN_ID}}"
    RESULTS_DIR="${RESULTS_DIR:-${PERF_WORK_DIR}/results}"
    CUBESANDBOX_INSTALL_DIR="${PERF_WORK_DIR}/one-click"
    CUBESANDBOX_PACKAGE_DIR="${CUBESANDBOX_INSTALL_DIR}/package"
    CUBESANDBOX_SOURCE_DIR="${PERF_WORK_DIR}/src/CubeSandbox-${SOFTWARE_VERSION}"
    CUBESANDBOX_CUBE_BENCH="${PERF_WORK_DIR}/bin/cube-bench"
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${PERF_WORK_DIR}/bin"
    log "run ${PERF_RUN_ID}: version ${SOFTWARE_VERSION}, variant ${PERF_VARIANT}, arch ${EXPECTED_ARCH}"
    log "work directory: ${PERF_WORK_DIR}"
    log "result directory: ${RESULTS_DIR}"
}

host_preflight() {
    local status=0
    [[ "${EXPECTED_ARCH}" == aarch64 ]] || { log 'ERROR: this case targets aarch64 hosts only'; status=30; }
    [[ -c /dev/kvm ]] || { log 'ERROR: /dev/kvm is missing; KVM is required'; status=30; }
    sudo -n test -r /dev/kvm >/dev/null 2>&1 || {
        log 'ERROR: the runner cannot read /dev/kvm (add the user to the kvm group or grant passwordless sudo)'
        status=30
    }
    sudo -n true >/dev/null 2>&1 || { log 'ERROR: passwordless sudo is required'; status=30; }
    command -v docker >/dev/null 2>&1 || { log 'ERROR: docker is required on the host'; status=30; }
    docker version --format '{{.Server.Version}}' >/dev/null 2>&1 || {
        log 'ERROR: the docker daemon is not reachable'; status=30
    }
    command -v python3 >/dev/null 2>&1 || { log 'ERROR: python3 is required'; status=30; }
    local glibc
    glibc="$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')"
    if [[ -n "${glibc}" ]] && ! awk -v v="${glibc}" 'BEGIN { split(v, p, "."); exit (p[1] * 100 + p[2] < 231) }'; then
        log "ERROR: glibc ${glibc} is older than 2.31"; status=30
    fi
    [[ "${status}" -eq 0 ]] || return "${status}"
    log "host preflight passed: aarch64, /dev/kvm, sudo, docker, python3, glibc ${glibc}"
}

ensure_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        log "docker compose plugin: $(docker compose version | head -1)"
        return 0
    fi
    local target=/usr/local/lib/docker/cli-plugins/docker-compose
    local name=docker-compose-linux-aarch64
    local cached="${CUBESANDBOX_ARCHIVE_DIR}/${name}"
    local rel="https://github.com/docker/compose/releases/download/v2.30.3/${name}"
    log 'installing the docker compose v2.30.3 plugin (missing on this host)'
    sudo -n mkdir -p "$(dirname "${target}")" || return 30
    if [[ -s "${cached}" ]]; then
        log "using the staged compose binary ${cached}"
        sudo -n cp -f -- "${cached}" "${target}" || return 30
    else
        local url
        for url in "https://gh-proxy.com/${rel}" "https://ghfast.top/${rel}" "${rel}"; do
            log "downloading the compose plugin from ${url}"
            if sudo -n curl -fL --retry 2 --max-time 1800 -o "${target}" "${url}"; then
                break
            fi
        done
        [[ -s "${target}" ]] || { log 'ERROR: failed to download the docker compose plugin'; return 30; }
        stage_into_cache "${target}" "${name}"
    fi
    sudo -n chmod +x "${target}" || return 30
    docker compose version >/dev/null 2>&1 || { log 'ERROR: docker compose plugin still unusable'; return 30; }
    log "docker compose plugin installed: $(docker compose version | head -1)"
}

ensure_data_volume() {
    local fs
    fs="$(findmnt -no FSTYPE "${CUBESANDBOX_DATA_DIR}" 2>/dev/null || true)"
    if [[ "${fs}" == xfs ]] && xfs_info "${CUBESANDBOX_DATA_DIR}" 2>/dev/null | grep -q 'reflink=1'; then
        log "${CUBESANDBOX_DATA_DIR} is already an XFS reflink volume"
        return 0
    fi
    log "preparing ${CUBESANDBOX_DATA_DIR} as an XFS reflink volume backed by ${CUBESANDBOX_DATA_IMG}"
    sudo -n mkdir -p "${CUBESANDBOX_DATA_DIR}" || return 30
    sudo -n rm -f "${CUBESANDBOX_DATA_IMG}" || return 30
    sudo -n truncate -s "${CUBESANDBOX_DATA_SIZE}" "${CUBESANDBOX_DATA_IMG}" || return 30
    sudo -n mkfs.xfs -q -f "${CUBESANDBOX_DATA_IMG}" || { log 'ERROR: mkfs.xfs failed'; return 30; }
    CUBESANDBOX_DATA_LOOP="$(sudo -n losetup -f --show "${CUBESANDBOX_DATA_IMG}")" || {
        log 'ERROR: losetup failed'; return 30
    }
    sudo -n mount -o noatime "${CUBESANDBOX_DATA_LOOP}" "${CUBESANDBOX_DATA_DIR}" || {
        log 'ERROR: mounting the reflink volume failed'; return 30
    }
    CUBESANDBOX_DATA_CREATED=1
    xfs_info "${CUBESANDBOX_DATA_DIR}" | grep -q 'reflink=1' || {
        log 'ERROR: the prepared volume does not report reflink=1'; return 30
    }
    # Remember that this run created the volume, so stop only releases volumes it
    # owns and never unmounts a pre-installed /data belonging to the host.
    printf 'loop=%s\nimg=%s\n' "${CUBESANDBOX_DATA_LOOP}" "${CUBESANDBOX_DATA_IMG}" \
        >"${RESULTS_DIR}/data_volume" 2>/dev/null || true
    log "reflink volume ready: ${CUBESANDBOX_DATA_DIR} on ${CUBESANDBOX_DATA_LOOP}"
}

cubesandbox_api_healthy() {
    curl -fsS --max-time 5 "${CUBESANDBOX_API_URL}/health" >/dev/null 2>&1
}

cubesandbox_master_cli() {
    cubesandbox_cli --address "${CUBESANDBOX_MASTER_ADDR}" --port "${CUBESANDBOX_MASTER_PORT}" "$@"
}

# The one-click package installs its CLIs under a configurable install prefix and
# normally symlinks them into /usr/local/bin; resolve the directory defensively
# instead of assuming the runner's PATH already contains them.
CUBESANDBOX_CLI_DIR="${CUBESANDBOX_CLI_DIR:-}"

cubesandbox_resolve_cli_dir() {
    [[ -n "${CUBESANDBOX_CLI_DIR}" ]] && { export PATH="${CUBESANDBOX_CLI_DIR}:${PATH}"; return 0; }
    local candidate on_path=""
    on_path="$(command -v cubemastercli 2>/dev/null || true)"
    for candidate in \
        "${on_path:+$(dirname "${on_path}")}" \
        /usr/local/bin \
        /usr/local/sbin \
        /usr/local/services/cubetoolbox/bin \
        /usr/local/services/cubesandbox/bin \
        /opt/cubesandbox/bin; do
        [[ -n "${candidate}" ]] || continue
        if [[ -x "${candidate}/cubemastercli" ]]; then
            CUBESANDBOX_CLI_DIR="${candidate}"
            break
        fi
    done
    if [[ -z "${CUBESANDBOX_CLI_DIR}" ]]; then
        candidate="$(sudo -n find /usr/local /opt "${HOME}" -maxdepth 6 -type f -name 'cubemastercli' 2>/dev/null | head -1 || true)"
        [[ -n "${candidate}" ]] && CUBESANDBOX_CLI_DIR="$(dirname "${candidate}")"
    fi
    [[ -n "${CUBESANDBOX_CLI_DIR}" ]] || return 40
    export PATH="${CUBESANDBOX_CLI_DIR}:${PATH}"
    log "CubeSandbox CLIs resolved in ${CUBESANDBOX_CLI_DIR}"
    return 0
}

cubesandbox_cli() {
    cubesandbox_resolve_cli_dir || {
        log 'ERROR: cubemastercli was not found after installation'
        log "hint: looked on PATH, /usr/local/bin, /usr/local/services and /opt"
        return 40
    }
    "${CUBESANDBOX_CLI_DIR}/cubemastercli" "$@"
}

download_release_archive() {
    local asset sha size target
    case "${EXPECTED_ARCH}" in
        aarch64) asset="cube-sandbox-one-click-${CUBESANDBOX_RELEASE_TAG}-arm64.tar.gz"
                 sha="${CUBESANDBOX_ONE_CLICK_ARM64_SHA256}"
                 size="${CUBESANDBOX_ONE_CLICK_ARM64_SIZE}" ;;
        *)       asset="cube-sandbox-one-click-${CUBESANDBOX_RELEASE_TAG}-amd64.tar.gz"
                 sha="${CUBESANDBOX_ONE_CLICK_AMD64_SHA256}"
                 size="${CUBESANDBOX_ONE_CLICK_AMD64_SIZE}" ;;
    esac
    mkdir -p "${CUBESANDBOX_INSTALL_DIR}" || return 40
    fetch_artifact "${asset}" "${CUBESANDBOX_RELEASE_BASE_URL}/${asset}" "${sha}" "${size}" || return 40
    target="${FETCHED_ARTIFACT}"
    cp -f -- "${target}" "${CUBESANDBOX_INSTALL_DIR}/${asset}" || return 40
    tar -xzf "${CUBESANDBOX_INSTALL_DIR}/${asset}" -C "${CUBESANDBOX_INSTALL_DIR}" || return 40
    local found
    found="$(find "${CUBESANDBOX_INSTALL_DIR}" -maxdepth 4 -name install.sh -printf '%h\n' 2>/dev/null | head -1 || true)"
    [[ -n "${found}" ]] || { log 'ERROR: install.sh not found in the archive'; return 40; }
    CUBESANDBOX_PACKAGE_DIR="${found}"
    log "one-click package: ${CUBESANDBOX_PACKAGE_DIR}"
}

provision_cubesandbox() {
    [[ "${CUBESANDBOX_ALLOW_PROVISION}" == 1 ]] || {
        log 'ERROR: CubeSandbox is not installed and CUBESANDBOX_ALLOW_PROVISION=0'
        return 30
    }
    log 'CubeSandbox is not installed; running the one-click installer (first run only)'
    download_release_archive || return $?
    pick_sandbox_network_cidr || return 40
    local env_file="${CUBESANDBOX_PACKAGE_DIR}/.env"
    [[ -f "${env_file}" ]] || cp "${CUBESANDBOX_PACKAGE_DIR}/env.example" "${env_file}" || return 40
    grep -q '^MIRROR=' "${env_file}" || printf 'MIRROR=%s\n' "${CUBESANDBOX_MIRROR}" >> "${env_file}"
    local log_file="${PERF_WORK_DIR}/one-click-install.log"
    local install_status=0
    # The bundled quickcheck demands every unit (including cube-proxy) to be
    # active within 120 s; on this host cube-proxy cannot start until its worker
    # count is capped (see repair_cube_proxy_workers), so the installer's own
    # check is skipped and replaced by the explicit readiness gate below.
    ( cd "${CUBESANDBOX_PACKAGE_DIR}" && \
      sudo -n env ONE_CLICK_ASSUME_YES=1 ONE_CLICK_MODE=install MIRROR="${CUBESANDBOX_MIRROR}" \
        ONE_CLICK_RUN_QUICKCHECK=0 \
        CUBE_SANDBOX_NETWORK_CIDR="${CUBESANDBOX_NETWORK_CIDR}" \
        ${CUBESANDBOX_DNSMASQ_MODE:+CUBE_PROXY_DNSMASQ_MODE=${CUBESANDBOX_DNSMASQ_MODE}} \
        bash ./install.sh --mode=install --yes ) >"${log_file}" 2>&1 || install_status=$?
    printf '%s\n' "${CUBESANDBOX_NETWORK_CIDR}" >"${RESULTS_DIR}/sandbox_network_cidr"
    restore_host_dns
    if [[ "${install_status}" -ne 0 ]]; then
        log "ERROR: the one-click installer failed (exit ${install_status}), see ${log_file}"
        tail -40 "${log_file}" || true
        return 40
    fi
    log 'one-click installer finished'
    repair_cube_proxy_workers || true
    wait_cubesandbox_ready || return 40
}

# wait_cubesandbox_ready polls the units and the CubeAPI health endpoint, which
# keeps a slow cubelet/MySQL/Redis cold start from looking like a failure.
wait_cubesandbox_ready() {
    local attempt
    for attempt in $(seq 1 36); do
        if cubesandbox_units_ready >/dev/null 2>&1 && cubesandbox_api_healthy >/dev/null 2>&1; then
            log "CubeSandbox is ready after $((attempt * 5))s"
            return 0
        fi
        sleep 5
    done
    cubesandbox_units_ready || true
    cubesandbox_api_healthy || log 'ERROR: CubeAPI is not healthy after installation'
    return 40
}

# cube-proxy runs OpenResty with `worker_processes auto` and
# `worker_rlimit_nofile 100000`. Containers on this host get RLIMIT_NOFILE=1024
# (dockerd builtin default, no /etc/docker/daemon.json), so nginx cannot raise
# the limit (`setrlimit ... Operation not permitted`) and then runs out of file
# descriptors while creating one reuseport listener per worker on a 384-vCPU
# node: `socket() 0.0.0.0:9090 failed (24: No file descriptors available)`.
# The unit never leaves start-post, and the installer's quickcheck dies with
# "expected systemd unit not active: cube-sandbox-cube-proxy.service".
# Capping the worker count keeps the listener set inside the descriptor budget
# without touching the host-wide docker configuration.
repair_cube_proxy_workers() {
    local toolbox="${CUBESANDBOX_TOOLBOX_DIR}"
    [[ -d "${toolbox}/cubeproxy" ]] || return 1
    local hard
    hard="$(sudo -n docker inspect -f \
        '{{range .HostConfig.Ulimits}}{{if eq .Name "nofile"}}{{.Hard}}{{end}}{{end}}' \
        cube-proxy 2>/dev/null)"
    [[ "${hard}" =~ ^[0-9]+$ ]] || return 1
    if (( hard >= 4096 )); then
        log "cube-proxy container nofile limit is ${hard}; no worker cap is needed"
        return 1
    fi
    log "cube-proxy container nofile limit is ${hard}, too small for $(nproc) nginx workers; capping worker_processes to ${CUBESANDBOX_PROXY_WORKERS}"
    local file changed=0
    for file in "${toolbox}/cubeproxy/nginx.conf.template" "${toolbox}/cubeproxy/nginx.conf"; do
        [[ -f "${file}" ]] || continue
        if grep -q '^worker_processes auto;' "${file}"; then
            sudo -n sed -i "s/^worker_processes auto;/worker_processes ${CUBESANDBOX_PROXY_WORKERS};/" "${file}" || return 1
            changed=1
        fi
    done
    [[ "${changed}" -eq 1 ]] || return 1
    sudo -n systemctl restart cube-sandbox-cube-proxy || return 1
    local attempt
    for attempt in $(seq 1 24); do
        if ss -lnt 2>/dev/null | grep -q ':80 '; then
            break
        fi
        sleep 5
    done
    systemctl is-active --quiet cube-sandbox-cube-proxy || return 1
    printf 'workers=%s\nnofile=%s\n' "${CUBESANDBOX_PROXY_WORKERS}" "${hard}" \
        >"${RESULTS_DIR}/cube_proxy_workers"
    log "cube-proxy is active again with ${CUBESANDBOX_PROXY_WORKERS} nginx workers"
    return 0
}

cubesandbox_units_ready() {
    local unit missing=0
    for unit in cube-sandbox-cubelet cube-sandbox-cubemaster cube-sandbox-cube-api \
                cube-sandbox-cube-proxy cube-sandbox-cube-lifecycle-manager; do
        if ! systemctl is-active --quiet "${unit}"; then
            log "ERROR: ${unit} is not active"
            missing=1
        fi
    done
    [[ "${missing}" -eq 0 ]] || return 40
    log 'CubeSandbox control-plane units are active'
    return 0
}

# pick_sandbox_network_cidr sets CUBESANDBOX_NETWORK_CIDR to a /16 that does not
# overlap any host address or route (upstream only validates the format).
pick_sandbox_network_cidr() {
    if [[ -n "${CUBESANDBOX_NETWORK_CIDR}" ]]; then
        log "using the caller-provided sandbox network ${CUBESANDBOX_NETWORK_CIDR}"
        return 0
    fi
    local picked
    picked="$(python3 - <<'PY' 2>/dev/null
import ipaddress
import subprocess

def run(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=10).stdout
    except Exception:
        return ""

networks = []
for line in run("ip", "-o", "-4", "addr", "show").splitlines():
    fields = line.split()
    for i, token in enumerate(fields):
        if token == "inet" and i + 1 < len(fields):
            try:
                networks.append(ipaddress.ip_network(fields[i + 1], strict=False))
            except ValueError:
                pass
for line in run("ip", "-4", "route", "show").splitlines():
    token = line.split()[0] if line.split() else ""
    if not token or token == "default":
        continue
    try:
        networks.append(ipaddress.ip_network(token, strict=False))
    except ValueError:
        pass
for candidate in ("10.240.0.0/16", "10.241.0.0/16", "10.242.0.0/16",
                  "172.28.0.0/16", "172.29.0.0/16", "192.168.128.0/17"):
    network = ipaddress.ip_network(candidate)
    if not any(network.overlaps(other) for other in networks):
        print(candidate)
        break
PY
)"
    [[ -n "${picked}" ]] || {
        log 'ERROR: no free /16 sandbox network found; set CUBESANDBOX_NETWORK_CIDR'
        return 40
    }
    CUBESANDBOX_NETWORK_CIDR="${picked}"
    log "sandbox network ${CUBESANDBOX_NETWORK_CIDR} does not overlap host networks"
    return 0
}

# The one-click installer rewrites /etc/resolv.conf to point at its own CoreDNS
# and keeps the pre-install copy in <toolbox>/coredns/resolv.conf.upstream.
# restore_host_dns() puts the host resolver back, but the restore target must be
# a file that was really captured *before* the installer ran: a resolver that was
# already rewritten (e.g. the CoreDNS variant, or one carrying an unreachable
# link-local nameserver) must never be treated as the "original", because every
# later DNS lookup would pay a full timeout.  Hence the `.pre-install` stamp and
# the fallback to the installer's own upstream copy.
restore_host_dns() {
    local backup="${PERF_WORK_DIR}/resolv.conf.before-cubesandbox"
    local upstream="${CUBESANDBOX_TOOLBOX_DIR}/coredns/resolv.conf.upstream"
    local dns_down=""
    dns_down="$(sudo -n find /usr/local /opt -maxdepth 8 -name 'down-dns.sh' 2>/dev/null | head -1 || true)"
    if [[ -n "${dns_down}" ]]; then
        sudo -n bash "${dns_down}" >/dev/null 2>&1 || true
    fi
    local target=""
    if [[ -s "${backup}" && -f "${backup}.pre-install" ]] && grep -q '^nameserver ' "${backup}" 2>/dev/null; then
        target="${backup}"
    elif [[ -s "${upstream}" ]] && grep -q '^nameserver ' "${upstream}" 2>/dev/null \
        && ! grep -q '^nameserver 127\.' "${upstream}" 2>/dev/null; then
        target="${upstream}"
    fi
    if [[ -n "${target}" ]] && ! sudo -n cmp -s "${target}" /etc/resolv.conf 2>/dev/null; then
        sudo -n cp "${target}" /etc/resolv.conf || true
        sudo -n chmod 644 /etc/resolv.conf 2>/dev/null || true
        log "restored the host /etc/resolv.conf from ${target} after the installer DNS handover"
    fi
    return 0
}

ensure_cubesandbox_runtime() {
    if cubesandbox_api_healthy; then
        log "CubeSandbox control plane is already healthy at ${CUBESANDBOX_API_URL}"
        return 0
    fi
    sudo -n cp /etc/resolv.conf "${PERF_WORK_DIR}/resolv.conf.before-cubesandbox" 2>/dev/null || true
    : >"${PERF_WORK_DIR}/resolv.conf.before-cubesandbox.pre-install"
    ensure_data_volume || return $?
    ensure_docker_compose || return $?
    provision_cubesandbox || return $?
}

ensure_template() {
    if [[ -n "${CUBESANDBOX_TEMPLATE_ID}" ]]; then
        log "using the caller-provided template ${CUBESANDBOX_TEMPLATE_ID}"
    else
        log "creating a template from ${CUBESANDBOX_TEMPLATE_IMAGE}"
        cubesandbox_master_cli tpl create-from-image \
            --image "${CUBESANDBOX_TEMPLATE_IMAGE}" \
            --writable-layer-size 1G \
            --expose-port 49999 --probe 49999 --probe-path / \
            >"${PERF_WORK_DIR}/template-create.log" 2>&1 || {
            log 'ERROR: template creation failed'
            tail -30 "${PERF_WORK_DIR}/template-create.log" || true
            return 40
        }
        CUBESANDBOX_TEMPLATE_ID="$(grep -oE 'tpl-[0-9a-zA-Z]+' "${PERF_WORK_DIR}/template-create.log" 2>/dev/null | head -1 || true)"
        [[ -n "${CUBESANDBOX_TEMPLATE_ID}" ]] || {
            log 'ERROR: template creation did not report a tpl- identifier'; return 40
        }
        printf '%s\n' "${CUBESANDBOX_TEMPLATE_ID}" >"${RESULTS_DIR}/template_id"
    fi
    local state
    for _ in $(seq 1 60); do
        state="$(cubesandbox_master_cli tpl list 2>/dev/null | grep -F "${CUBESANDBOX_TEMPLATE_ID}" | head -1 || true)"
        [[ "${state}" == *READY* ]] && { log "template ${CUBESANDBOX_TEMPLATE_ID} is READY"; return 0; }
        sleep 15
    done
    log "ERROR: template ${CUBESANDBOX_TEMPLATE_ID} did not reach READY"
    return 40
}

# Sandboxes created by the benchmark are removed through cubemastercli
# (`cubebox list --all --quiet` prints only the ids). Note that `cubemaster` is
# the server binary, not the CLI, so it has no `list`/`destroy` subcommands.
cleanup_sandboxes() {
    local ids
    ids="$(cubesandbox_master_cli cubebox list --all --size 1000 --quiet 2>/dev/null)" || return 50
    if [[ -n "${ids}" ]]; then
        # shellcheck disable=SC2086  # the ids are a whitespace separated list
        cubesandbox_master_cli cubebox destroy ${ids} >/dev/null 2>&1 || true
    fi
    for _ in $(seq 1 60); do
        [[ -z "$(cubesandbox_master_cli cubebox list --all --size 1000 --quiet 2>/dev/null)" ]] && return 0
        sleep 2
    done
    log 'ERROR: sandboxes are still present after cleanup'
    return 50
}

write_actual_version() {
    [[ -n "${PERF_ACTUAL_VERSION_FILE}" ]] || return 0
    printf '%s\n' "${1:-${SOFTWARE_VERSION}}" >"${PERF_ACTUAL_VERSION_FILE}"
}
