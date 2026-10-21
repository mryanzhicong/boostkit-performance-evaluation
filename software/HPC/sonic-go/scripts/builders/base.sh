#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

run_as_root() {
    if [[ "$1" == dnf && -n "${PERF_PROXY:-}" ]]; then
        set -- "$1" "--setopt=proxy=${PERF_PROXY}" "${@:2}"
    fi
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n "$@"
    else
        log_message "ERROR: root privileges are required to install missing dependencies"
        return 30
    fi
}

install_dependencies() {
    local required package
    local packages=()

    for required in git curl gcc tar gzip sha256sum awk python3 taskset; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            curl) package="curl" ;;
            gcc) package="gcc" ;;
            tar) package="tar" ;;
            gzip) package="gzip" ;;
            sha256sum|taskset) package="util-linux" ;;
            awk) package="gawk" ;;
            tee) package="coreutils" ;;
            python3) package="python3" ;;
        esac
        packages+=("${package}")
    done
    if [[ "${#packages[@]}" -gt 0 ]]; then
        log_message "installing missing Sonic Go dependencies: ${packages[*]}"
        if ! command -v dnf >/dev/null 2>&1; then
            log_message "ERROR: dnf is required to install Sonic Go dependencies"
            return 30
        fi
        run_as_root dnf install -y "${packages[@]}" || return 30
    fi
    for required in git curl gcc tar gzip sha256sum awk python3 taskset; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command remains unavailable: ${required}"
            return 30
        fi
    done
}

copy_or_download_bootstrap_archive() {
    local archive="$1" filename expected actual offline_archive

    filename="$(basename "${archive}")"
    offline_archive="${GO_OFFLINE_DIR}/${filename}"
    case "${GO_BOOTSTRAP_VERSION}:${GO_ARCH}" in
        1.26.7:amd64)
            expected="ffb5f8de10c62550dfddab66b36b57030721e0a44a3218e9e1181d7b59f121ca"
            ;;
        1.26.7:arm64)
            expected="5a4ec883379d51ee9ce1040d5e87f8d35e20387574dd8c947feb01eabc3c1b37"
            ;;
        1.27.0:amd64)
            expected="675c26c449cbb18fc24b74650de1eabbae6e16f64326fd85a283fb3b58280685"
            ;;
        1.27.0:arm64)
            expected="51798d2c42d0e1c6ed7fd9f48728b4193abac9e8aad6dbac2fe96a81f5909bda"
            ;;
        *)
            log_message "ERROR: no verified Go binary release is declared for bootstrap ${GO_BOOTSTRAP_VERSION} on ${GO_ARCH}"
            return 10
            ;;
    esac
    if [[ -f "${offline_archive}" ]]; then
        log_message "using offline Go bootstrap archive ${offline_archive}"
        cp "${offline_archive}" "${archive}"
    else
        log_message "downloading official Go bootstrap archive ${filename}"
        if ! curl -fsSL --retry 3 --connect-timeout 30 -o "${archive}" \
            "${GO_RELEASE_URL}/${filename}"; then
            log_message "ERROR: failed to download ${filename}"
            return 30
        fi
    fi
    actual="$(sha256sum "${archive}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: Go bootstrap archive checksum mismatch: ${filename}"
        return 30
    fi
}

# 编译 Go 源码需要 PATH 上有 bootstrap Go（make.bash 自举）。优先使用 Runner
# 已有的 PATH Go；缺失时退回安装任务私有的官方二进制（离线目录优先，校验
# SHA-256 后解压），避免依赖系统包。
resolve_bootstrap_go() {
    if command -v go >/dev/null 2>&1; then
        log_message "using bootstrap Go from PATH: $(go version 2>/dev/null || echo unknown)"
        return 0
    fi
    local install_dir="${PERF_WORK_DIR}/bootstrap-go"
    local archive
    if [[ -e "${install_dir}" ]]; then
        log_message "ERROR: bootstrap Go directory already exists: ${install_dir}"
        return 20
    fi
    archive="${PERF_WORK_DIR}/go${GO_BOOTSTRAP_VERSION}.linux-${GO_ARCH}.tar.gz"
    copy_or_download_bootstrap_archive "${archive}" || return $?
    if ! mkdir -p "${install_dir}" || \
       ! tar -xzf "${archive}" -C "${install_dir}" --strip-components=1; then
        log_message "ERROR: failed to install bootstrap Go ${GO_BOOTSTRAP_VERSION}"
        return 30
    fi
    rm -f "${archive}"
    if [[ ! -x "${install_dir}/bin/go" ]]; then
        log_message "ERROR: bootstrap Go binary is unavailable: ${install_dir}/bin/go"
        return 30
    fi
    export PATH="${install_dir}/bin:${PATH}"
    log_message "installed private bootstrap Go ${GO_BOOTSTRAP_VERSION} for ${GO_ARCH}"
}

download_sonic_modules() {
    local module
    local -a modules=()

    mapfile -t modules < <(python3 - "${SOURCE_DIR}" <<'PYEOF'
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
modules = set()
for sums_file in source_dir.rglob("go.sum"):
    for line in sums_file.read_text(encoding="utf-8").splitlines():
        name, version, _checksum = line.split()
        if not version.endswith("/go.mod"):
            modules.add(f"{name}@{version}")
for module in sorted(modules):
    print(module)
PYEOF
    )
    if [[ "${#modules[@]}" -eq 0 ]]; then
        log_message "ERROR: Sonic source contains no go.sum module checksums"
        return 40
    fi
    log_message "downloading ${#modules[@]} checked Go module versions one at a time"
    for module in "${modules[@]}"; do
        log_message "downloading ${module}"
        if ! (cd "${SOURCE_DIR}" && "${GO_BIN}" mod download "${module}"); then
            log_message "ERROR: failed to download Go module ${module} through the configured proxy"
            return 40
        fi
    done
    log_message "verifying complete Sonic Go workspace dependency graph"
    if ! (cd "${SOURCE_DIR}" && "${GO_BIN}" mod download); then
        log_message "ERROR: failed to download the complete Sonic Go dependency graph"
        return 40
    fi
}

build_sonic_go_base() {
    local actual_version go_src_commit

    initialize_runtime || return $?
    check_architecture || return $?
    install_dependencies || return $?
    resolve_bootstrap_go || return $?
    if [[ -e "${OBJECTS_DIR}/go/src/go${GO_SRC_VERSION}" || -e "${TOOLCHAIN_DIR}" || -e "${SOURCE_DIR}" ]]; then
        log_message "ERROR: source or toolchain directory already exists under ${PERF_WORK_DIR}"
        return 20
    fi
    mkdir -p "${OBJECTS_DIR}/go/src" "${OBJECTS_DIR}/go/bin"

    export GIT_TERMINAL_PROMPT=0
    log_message "cloning Go ${GO_SRC_VERSION} source from ${GO_SOURCE_URL} (branch ${GO_SRC_BRANCH})"
    if ! git clone -b "${GO_SRC_BRANCH}" --depth 1 \
        "${GO_SOURCE_URL}" "${OBJECTS_DIR}/go/src/go${GO_SRC_VERSION}"; then
        log_message "ERROR: failed to clone Go source branch ${GO_SRC_BRANCH}"
        return 30
    fi
    go_src_commit="$(git -C "${OBJECTS_DIR}/go/src/go${GO_SRC_VERSION}" rev-parse HEAD 2>/dev/null || true)"
    log_message "Go source commit: ${go_src_commit:-unknown}"

    # 一份源码树 = 一个工具链：make.bash 就地生成 bin/go，GOROOT 指向工作副本。
    log_message "building Go ${GO_SRC_VERSION} toolchain (target: ${TOOLCHAIN_TARGET})"
    if ! cp -a "${OBJECTS_DIR}/go/src/go${GO_SRC_VERSION}" "${TOOLCHAIN_DIR}"; then
        log_message "ERROR: failed to create toolchain working copy: ${TOOLCHAIN_DIR}"
        return 30
    fi
    # bootstrap 阶段的构建缓存隔离在 runtime/ 下（stop 阶段清理）；测试阶段的
    # GOCACHE 由 sonic_bench.sh 的 setup_gocache 指到工具链目录内，两不混用。
    export GOCACHE="${PERF_WORK_DIR}/runtime/bootstrap-go-build"
    mkdir -p "${GOCACHE}"
    if ! (cd "${TOOLCHAIN_DIR}" && bash "${SCRIPT_DIR}/scripts/go/build_go.sh" default); then
        log_message "ERROR: failed to build Go ${GO_SRC_VERSION} toolchain"
        return 30
    fi
    unset GOCACHE
    verify_go_toolchain || return $?
    if [[ ! -f "${TOOLCHAIN_DIR}/toolchain_meta.json" ]]; then
        log_message "ERROR: toolchain metadata is missing: ${TOOLCHAIN_DIR}/toolchain_meta.json"
        return 40
    fi
    log_message "built private Go ${GO_SRC_VERSION} toolchain at ${TOOLCHAIN_DIR}"

    log_message "cloning Sonic ${SOFTWARE_VERSION} from ${SONIC_GO_SOURCE_URL}"
    if ! git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${SONIC_GO_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone Sonic v${SOFTWARE_VERSION}"
        return 30
    fi
    actual_version="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    if [[ "${actual_version}" != "v${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: checked-out Sonic tag ${actual_version:-unknown} does not match v${SOFTWARE_VERSION}"
        return 40
    fi
    if ! download_sonic_modules; then
        log_message "ERROR: failed to prepare the Sonic benchmark packages"
        return 40
    fi
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "Sonic ${SOFTWARE_VERSION} benchmark packages are ready"
}
