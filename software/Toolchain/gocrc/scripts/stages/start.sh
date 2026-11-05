#!/usr/bin/env bash
# Start stage: prove that the measured openEuler golang go1.24.6 toolchain at
# /home/local/golang and benchstat are usable inside the private container before
# any measurement runs.  The bootstrap Go at /usr/local/go is only checked for
# existence: it is never measured.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

bootstrap_go_version() {
    gocrc_container_exec "${GO_BOOTSTRAP_BIN}" version | awk '{print $3}' | sed 's/^go//'
}

optimized_go_version() {
    gocrc_container_exec "${GO_OPTIMIZED_BIN}" version | awk '{print $3}' | sed 's/^go//'
}

smoke_go_toolchain() {
    local go_bin="$1" goroot="$2" smoke_dir="$3"
    mkdir -p "${smoke_dir}" || return 40
    printf 'package main\n\nimport "fmt"\n\nfunc main() { fmt.Println("go-smoke") }\n' \
        > "${smoke_dir}/main.go"
    if ! container_gocrc_exec_at "${smoke_dir}" "${go_bin}" "${goroot}" build -o smoke main.go; then
        log_message "ERROR: the Go toolchain ${go_bin} failed its smoke build"
        return 40
    fi
    if ! gocrc_container_exec_at "${smoke_dir}" ./smoke | grep -qx 'go-smoke'; then
        log_message "ERROR: the Go smoke binary from ${go_bin} did not produce the expected output"
        return 40
    fi
    log_message "Go toolchain smoke test passed: ${go_bin}"
}

start_gocrc_runtime() {
    local bootstrap_version optimized_version
    initialize_runtime || return $?
    check_gocrc_container || return $?
    configure_go_environment
    bootstrap_version="$(bootstrap_go_version)" || {
        log_message "ERROR: cannot read the bootstrap Go version"
        return 40
    }
    if [[ "${bootstrap_version}" != "${GO_BOOTSTRAP_VERSION}" ]]; then
        log_message "ERROR: bootstrap Go is ${bootstrap_version}, expected ${GO_BOOTSTRAP_VERSION} at ${GO_BOOTSTRAP_GOROOT}"
        return 40
    fi
    optimized_version="$(optimized_go_version)" || {
        log_message "ERROR: cannot read the openEuler golang version"
        return 40
    }
    if [[ "${optimized_version}" != "${GO_OPTIMIZED_VERSION}" ]]; then
        log_message "ERROR: openEuler golang is ${optimized_version}, expected ${GO_OPTIMIZED_VERSION} at ${GO_OPTIMIZED_GOROOT}"
        return 40
    fi
    if ! gocrc_container_exec test -x "${GO_BENCHSTAT}"; then
        log_message "ERROR: benchstat is not installed at ${GO_BENCHSTAT}"
        return 40
    fi
    smoke_go_toolchain "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${PERF_WORK_DIR}/smoke-go${SOFTWARE_VERSION}" || return $?
    log_message "measured Go toolchain ${optimized_version} (${GO_OPTIMIZED_GOROOT}) is ready; bootstrap Go ${bootstrap_version} at ${GO_BOOTSTRAP_GOROOT}"
}
