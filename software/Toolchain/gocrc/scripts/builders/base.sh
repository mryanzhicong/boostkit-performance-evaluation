#!/usr/bin/env bash
# Build stage executed identically on AMD EPYC 9654 (x86_64) and Kunpeng 950
# (aarch64):
#
#   1. install the official bootstrap Go release at /usr/local/go inside the
#      private container (host only transfers and SHA-256 verifies the archive);
#      this toolchain only compiles the measured one and is never benchmarked;
#   2. clone the pinned openEuler golang tree on the host (git cannot be
#      installed in the container: its dnf transaction pulls dbus-daemon whose
#      rpm scriptlet needs a writable /etc/passwd) and build go1.24.6 in the
#      container with GOOS=linux GOARCH=<amd64|arm64>
#      GOROOT_BOOTSTRAP=/usr/local/go ./make.bash; the source tree is visible at
#      /home/local/golang through a bind mount;
#   3. install golang.org/x/perf/cmd/benchstat with the freshly built go1.24.6.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

GOCRC_CONTAINER_PACKAGES=(tar gzip coreutils findutils which ca-certificates gcc)

prepare_gocrc_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_gocrc_docker || return 30
    start_gocrc_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Go toolchain dependencies inside the private container"
    # Weak dependencies are disabled because the host /etc/passwd and /etc/group
    # are mounted read-only in the container and some rpm scriptlets (useradd,
    # groupadd) cannot run there.
    if ! gocrc_container_exec_root dnf "${dnf_options[@]}" install -y \
        --setopt=install_weak_deps=False "${GOCRC_CONTAINER_PACKAGES[@]}"; then
        log_message "ERROR: container package installation failed"
        return 30
    fi
    gocrc_container_exec sh -c 'command -v tar && command -v gzip && command -v gcc' || {
        log_message "ERROR: the container toolchain is not usable after installation"
        return 30
    }
    log_message "Go container dependencies are ready"
}

# The openEuler golang source is cloned on the host into the directory that the
# container sees as /home/local/golang; only the clone needs git and network.
clone_optimized_source() {
    local commit
    if [[ -d "${GO_SRC_HOST_DIR}/.git" ]]; then
        log_message "reusing the existing openEuler golang source tree: ${GO_SRC_HOST_DIR}"
    else
        if [[ -e "${GO_SRC_HOST_DIR}" && -n "$(ls -A "${GO_SRC_HOST_DIR}" 2>/dev/null)" ]]; then
            log_message "ERROR: ${GO_SRC_HOST_DIR} exists but is not a git checkout"
            return 20
        fi
        if ! command -v git >/dev/null 2>&1; then
            log_message "ERROR: the host needs git to clone the openEuler golang source"
            return 30
        fi
        log_message "cloning openEuler golang ${GO_OPTIMIZED_BRANCH} on the host into ${GO_SRC_HOST_DIR}"
        if ! git clone --depth 1 --branch "${GO_OPTIMIZED_BRANCH}" \
            "${GO_OPTIMIZED_REPO}" "${GO_SRC_HOST_DIR}"; then
            log_message "ERROR: cannot clone the openEuler golang source: ${GO_OPTIMIZED_REPO}"
            return 30
        fi
    fi
    if [[ ! -f "${GO_SRC_HOST_DIR}/src/make.bash" ]]; then
        log_message "ERROR: the openEuler golang tree has no src/make.bash: ${GO_SRC_HOST_DIR}"
        return 30
    fi
    commit="$(git -C "${GO_SRC_HOST_DIR}" rev-parse HEAD)" || {
        log_message "ERROR: cannot read the openEuler golang commit"
        return 30
    }
    GO_SRC_COMMIT="$(printf '%s\n' "${commit}" | tr -d '[:space:]')"
    printf '%s\n' "${GO_SRC_COMMIT}" > "${RESULTS_DIR}/source-commit.txt"
    log_message "openEuler golang source commit: ${GO_SRC_COMMIT}"
}

build_optimized_go() {
    log_message "building openEuler golang ${GO_OPTIMIZED_VERSION} for ${GO_ARCH} with make.bash (GOROOT_BOOTSTRAP=${GO_BOOTSTRAP_DIR})"
    if ! gocrc_container_exec_at "${GO_SRC_DIR}/src" env \
        "GOOS=linux" "GOARCH=${GO_ARCH}" "GOROOT_BOOTSTRAP=${GO_BOOTSTRAP_DIR}" \
        ./make.bash --no-banner; then
        log_message "ERROR: make.bash failed for the openEuler golang source"
        return 40
    fi
    verify_optimized_go || return $?
    log_message "built openEuler golang ${GO_OPTIMIZED_ACTUAL_VERSION} at ${GO_OPTIMIZED_GOROOT}"
}

install_benchstat() {
    local version_output
    log_message "installing golang.org/x/perf/cmd/benchstat with the openEuler golang toolchain"
    if ! optimized_go_at "${GO_SRC_DIR}/src" install "golang.org/x/perf/cmd/benchstat@latest"; then
        log_message "ERROR: go install golang.org/x/perf/cmd/benchstat@latest failed"
        return 40
    fi
    if ! gocrc_container_exec test -x "${GO_BENCHSTAT}"; then
        log_message "ERROR: benchstat was not installed at ${GO_BENCHSTAT}"
        return 40
    fi
    version_output="$(optimized_go_at "${GO_SRC_DIR}/src" version -m "${GO_BENCHSTAT}" 2>/dev/null | head -n 3)" || version_output=""
    if [[ -n "${version_output}" ]]; then
        printf '%s\n' "${version_output}" > "${RESULTS_DIR}/benchstat-version.txt"
    fi
    log_message "benchstat is ready: ${GO_BENCHSTAT}"
}

# The complete procedure of the case: bootstrap compiler + measured go1.24.6
# toolchain + benchstat.  Both variants run the same procedure; the dropdown only
# labels the run so the existing workflows keep working.
build_gocrc_environment() {
    initialize_runtime || return $?
    prepare_gocrc_container || return $?
    install_bootstrap_go || return $?
    clone_optimized_source || return $?
    build_optimized_go || return $?
    install_benchstat || return $?
    record_gcc_identity
}

build_gocrc_base() { build_gocrc_environment; }
