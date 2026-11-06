#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
build_spark_base() {
    initialize_runtime || return $?
    [[ "$(uname -m)" == "$EXPECTED_ARCH" ]] || return 20
    command -v docker >/dev/null && docker info >/dev/null || return 30
    python3 "$SCRIPT_DIR/scripts/assets.py" preflight || return 30
    python3 "$SCRIPT_DIR/scripts/assets.py" download || return 30
    local image_archive image_digest loaded image actual_arch release
    image_archive="/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.$EXPECTED_ARCH.tar.xz"
    image_digest="$image_archive.sha256sum"
    if [[ ! -s "$image_archive" || ! -s "$image_digest" ]]; then
        image_archive="$PERF_WORK_DIR/openEuler-docker.$EXPECTED_ARCH.tar.xz"
        image_digest="$image_archive.sha256sum"
        local url="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/$EXPECTED_ARCH/openEuler-docker.$EXPECTED_ARCH.tar.xz"
        curl -fSL --retry 3 --connect-timeout 20 --max-time 900 -o "$image_archive" "$url" || return 30
        curl -fSL --retry 3 --connect-timeout 20 --max-time 120 -o "$image_digest" "$url.sha256sum" || return 30
    fi
    local expected actual
    expected="$(awk 'NR==1 {print $1}' "$image_digest")"
    [[ "$expected" =~ ^[[:xdigit:]]{64}$ ]] || return 30
    actual="$(sha256sum "$image_archive")"
    [[ "${actual%% *}" == "${expected,,}" ]] || { echo 'Image checksum mismatch'; return 30; }
    loaded="$(docker load --input "$image_archive")" || return 30
    image="$(sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' <<< "$loaded" | tail -1)"
    [[ -n "$image" ]] || return 30
    actual_arch="$(docker image inspect --format '{{.Architecture}}' "$image")"
    validate_image_architecture "$actual_arch" || return 30
    release="$(docker run --rm --network=none "$image" cat /etc/os-release)" || return 30
    grep -Eq '^ID="?openEuler"?$' <<< "$release" &&
        grep -Eq '^VERSION=.*24\.03.*LTS-SP4' <<< "$release" || return 30
    docker container inspect "$SPARK_CONTAINER" >/dev/null 2>&1 && { echo 'Container already exists'; return 30; }
    local network=bridge
    if [[ -n "${PERF_ADAPTER_DIR:-}" ]]; then
        network="$SPARK_CONTAINER-net"
        docker network create --label "boostkit.spark.run-id=$PERF_RUN_ID" "$network" >/dev/null || return 30
    fi
    local -a proxy=() mounts=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy=(-e "http_proxy=$PERF_PROXY" -e "https_proxy=$PERF_PROXY")
        mounts=(--mount type=bind,source=/home/runner/software/anchors,target=/etc/pki/ca-trust/source/anchors,readonly)
    fi
    docker run --detach --name "$SPARK_CONTAINER" --hostname server1 --network "$network" \
        --label "boostkit.spark.run-id=$PERF_RUN_ID" \
        --mount "type=bind,source=$PERF_WORK_DIR,target=$PERF_WORK_DIR" \
        --mount "type=bind,source=$RESULTS_DIR,target=$RESULTS_DIR" \
        --mount "type=bind,source=$(dirname "$SCRIPT_DIR"),target=$(dirname "$SCRIPT_DIR"),readonly" \
        "${mounts[@]}" "${proxy[@]}" "$image" sleep infinity >/dev/null || return 30
    if [[ -n "${PERF_PROXY:-}" ]]; then
        docker exec "$SPARK_CONTAINER" update-ca-trust extract || return 30
    fi
    docker exec "$SPARK_CONTAINER" sed -i \
        -e '/^meta/ s/^/#/' -e 's,repo.openeuler.org,repo.huaweicloud.com/openeuler,g' \
        /etc/yum.repos.d/openEuler.repo || return 30
    docker exec "$SPARK_CONTAINER" dnf install -y python3 mariadb-server mariadb \
        procps-ng util-linux coreutils findutils tar gzip unzip hostname shadow \
        libaio openssl-libs zlib snappy which make gcc gcc-c++ binutils lz4 zstd-libs numactl-libs libatomic libstdc++ libicu double-conversion libsodium libevent xz-libs bzip2 || return 30
    docker image inspect --format '{{json .}}' "$image" > "$RESULTS_DIR/container-image.json"
    container_exec install || return 30
}
