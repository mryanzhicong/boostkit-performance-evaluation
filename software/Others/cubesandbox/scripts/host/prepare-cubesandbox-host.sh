#!/usr/bin/env bash
# Prepare an aarch64 host for the CubeSandbox case (run as an administrator).
#
# The case itself re-checks every prerequisite and idempotently fills the gaps it
# is allowed to fill (XFS reflink volume, docker compose plugin, cube-bench build,
# one-click deployment). This script exists for operators who prefer to pre-bake a
# dedicated node so the measured run never installs anything.
#
# Reference: docs/zh/cubesandbox_deployment_user_guide.md (boostkit/cloud-native).
set -euo pipefail

SOFTWARE_VERSION="${SOFTWARE_VERSION:-0.8.0}"
DATA_DIR="${CUBESANDBOX_DATA_DIR:-/data}"
DATA_IMG="${CUBESANDBOX_DATA_IMG:-/home/runner/cubesandbox-data.img}"
DATA_SIZE="${CUBESANDBOX_DATA_SIZE:-200G}"
MIRROR="${CUBESANDBOX_MIRROR:-cn}"

log() { printf '[prepare-host] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }
die() { log "ERROR: $*"; exit 1; }

[[ "$(uname -m)" == aarch64 ]] || die 'CubeSandbox requires an aarch64 host'
[[ -c /dev/kvm ]] || die '/dev/kvm is missing; enable virtualization in the BIOS and load kvm'
sudo -n true 2>/dev/null || die 'passwordless sudo is required'
command -v docker >/dev/null || die 'docker is required'
docker version --format '{{.Server.Version}}' >/dev/null 2>&1 || die 'the docker daemon is unreachable'

glibc="$(getconf GNU_LIBC_VERSION | awk '{print $2}')"
awk -v v="${glibc}" 'BEGIN { split(v, p, "."); exit (p[1] * 100 + p[2] < 231) }' \
    || die "glibc ${glibc} is older than 2.31"

if ! docker compose version >/dev/null 2>&1; then
    log 'installing the docker compose v2.30.3 plugin'
    sudo -n mkdir -p /usr/local/lib/docker/cli-plugins
    sudo -n curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose \
        https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-aarch64
    sudo -n chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

if [[ "$(findmnt -no FSTYPE "${DATA_DIR}" 2>/dev/null || true)" != xfs ]] \
   || ! xfs_info "${DATA_DIR}" 2>/dev/null | grep -q 'reflink=1'; then
    log "creating an XFS reflink volume at ${DATA_DIR}"
    sudo -n mkdir -p "${DATA_DIR}"
    sudo -n truncate -s "${DATA_SIZE}" "${DATA_IMG}"
    sudo -n mkfs.xfs -q -f "${DATA_IMG}"
    loop="$(sudo -n losetup -f --show "${DATA_IMG}")"
    sudo -n mount -o noatime "${loop}" "${DATA_DIR}"
    echo "${loop}" | sudo -n tee "${DATA_IMG}.loop" >/dev/null
fi

if ! curl -fsS --max-time 5 http://127.0.0.1:3000/health >/dev/null 2>&1; then
    pkg_dir="${HOME}/cubesandbox-install"
    mkdir -p "${pkg_dir}"
    asset="cube-sandbox-one-click-v${SOFTWARE_VERSION}-arm64.tar.gz"
    url="https://github.com/TencentCloud/CubeSandbox/releases/download/v${SOFTWARE_VERSION}/${asset}"
    [[ -s "${pkg_dir}/${asset}" ]] || curl -fsSL --retry 3 -o "${pkg_dir}/${asset}" "${url}"
    sha256sum "${pkg_dir}/${asset}"
    tar -xzf "${pkg_dir}/${asset}" -C "${pkg_dir}"
    installer="$(find "${pkg_dir}" -maxdepth 3 -name install.sh -printf '%h\n' 2>/dev/null | head -1 || true)"
    [[ -n "${installer}" ]] || die 'install.sh not found in the one-click archive'
    cp -n "${installer}/env.example" "${installer}/.env" || true
    grep -q '^MIRROR=' "${installer}/.env" || echo "MIRROR=${MIRROR}" >> "${installer}/.env"
    log 'running the one-click installer'
    ( cd "${installer}" && sudo -n env ONE_CLICK_ASSUME_YES=1 MIRROR="${MIRROR}" \
        bash ./install.sh --mode=install --yes )
    log 'restoring the host resolver taken over by cube-proxy'
    dns_down="$(sudo -n find /usr/local /opt -maxdepth 8 -name 'down-dns.sh' 2>/dev/null | head -1 || true)"
    [[ -n "${dns_down}" ]] && sudo -n bash "${dns_down}" || true
fi

log 'creating the reference template'
cubemastercli --address 127.0.0.1 --port 8089 tpl create-from-image \
    --image cube-sandbox-cn.tencentcloudcr.com/cube-sandbox/sandbox-code:latest \
    --writable-layer-size 1G --expose-port 49999 --probe 49999 --probe-path / \
    | tee "${HOME}/cubesandbox-template.log"

log 'host preparation finished; the case will reuse the installation and template'
