#!/usr/bin/env bash
# Stage the CubeSandbox artifacts once under the offline cache directory, so that
# later case runs (and the Bootstrap probe) never download them again.
#
#   bash scripts/host/stage-cubesandbox-artifacts.sh [cache_dir]
#
# Default cache_dir: /home/runner/software/cubesandbox
# The case reads CUBESANDBOX_ARCHIVE_DIR, so exporting
#   CUBESANDBOX_ARCHIVE_DIR=/home/runner/software/cubesandbox
# is enough for reuses; the default already points there.
set -uo pipefail

CACHE_DIR="${1:-${CUBESANDBOX_ARCHIVE_DIR:-/home/runner/software/cubesandbox}}"
VERSION="${SOFTWARE_VERSION:-0.8.0}"
TAG="v${VERSION}"
GO_VERSION="${CUBESANDBOX_GO_VERSION:-1.25.0}"

log() { printf '[stage] %s\n' "$*"; }
die() { printf '[stage] ERROR: %s\n' "$*" >&2; exit 1; }

declare -A URL SHA SIZE
URL["cube-sandbox-one-click-${TAG}-arm64.tar.gz"]="https://github.com/TencentCloud/CubeSandbox/releases/download/${TAG}/cube-sandbox-one-click-${TAG}-arm64.tar.gz"
SHA["cube-sandbox-one-click-${TAG}-arm64.tar.gz"]="a7dcf6faa80416aab323050aac275e3385a3f49778a46256715608a26a4cb4f4"
SIZE["cube-sandbox-one-click-${TAG}-arm64.tar.gz"]=223970625

URL["CubeSandbox-${VERSION}.tar.gz"]="https://github.com/TencentCloud/CubeSandbox/archive/refs/tags/${TAG}.tar.gz"
SHA["CubeSandbox-${VERSION}.tar.gz"]="c2de64cb316580492625a12065158264a5bfb3abd096a04ced0c8743fa0ffeae"
SIZE["CubeSandbox-${VERSION}.tar.gz"]=40894189

URL["go${GO_VERSION}.linux-arm64.tar.gz"]="https://dl.google.com/go/go${GO_VERSION}.linux-arm64.tar.gz"
SHA["go${GO_VERSION}.linux-arm64.tar.gz"]="05de75d6994a2783699815ee553bd5a9327d8b79991de36e38b66862782f54ae"
SIZE["go${GO_VERSION}.linux-arm64.tar.gz"]=57159737

mkdir -p "${CACHE_DIR}" || die "cannot create ${CACHE_DIR}"
log "cache directory: ${CACHE_DIR}"

status=0
for name in "cube-sandbox-one-click-${TAG}-arm64.tar.gz" "CubeSandbox-${VERSION}.tar.gz" "go${GO_VERSION}.linux-arm64.tar.gz"; do
    target="${CACHE_DIR}/${name}"
    if [[ -s "${target}" ]]; then
        if [[ "$(sha256sum "${target}" | awk '{print $1}')" == "${SHA[$name]}" ]] \
           && [[ "$(stat -c %s "${target}")" == "${SIZE[$name]}" ]]; then
            log "cached: ${name}"
            continue
        fi
        log "cached copy of ${name} is invalid; re-downloading"
        rm -f "${target}"
    fi
    log "downloading ${name} (${SIZE[$name]} B)"
    if ! curl -fsSL --retry 3 --max-time 3600 -o "${target}.part" "${URL[$name]}"; then
        log "download failed: ${URL[$name]}"
        rm -f "${target}.part"
        status=1
        continue
    fi
    mv -- "${target}.part" "${target}" || { status=1; continue; }
    if [[ "$(sha256sum "${target}" | awk '{print $1}')" != "${SHA[$name]}" ]]; then
        log "sha256 mismatch for ${name}"; rm -f "${target}"; status=1; continue
    fi
    if [[ "$(stat -c %s "${target}")" != "${SIZE[$name]}" ]]; then
        log "size mismatch for ${name}"; rm -f "${target}"; status=1; continue
    fi
    log "staged: ${name}"
done

log 'cache contents:'
ls -l "${CACHE_DIR}" || true
exit "${status}"
