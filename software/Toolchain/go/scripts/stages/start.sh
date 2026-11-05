#!/usr/bin/env bash
# Start stage: prove that both toolchains (official Go at /usr/local/go and the
# openEuler golang build at /home/local/golang) and benchstat are usable inside
# the private container before any measurement runs.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

official_go_version() {
    go_container_exec "${GO_BIN}" version | awk '{print $3}' | sed 's/^go//'
}

optimized_go_version() {
    go_container_exec "${GO_OPTIMIZED_BIN}" version | awk '{print $3}' | sed 's/^go//'
}

smoke_go_toolchain() {
    local go_bin="$1" goroot="$2" smoke_dir="$3"
    mkdir -p "${smoke_dir}" || return 40
    printf 'package main\n\nimport "fmt"\n\nfunc main() { fmt.Println("go-smoke") }\n' \
        > "${smoke_dir}/main.go"
    if ! container_go_exec_at "${smoke_dir}" "${go_bin}" "${goroot}" build -o smoke main.go; then
        log_message "ERROR: the Go toolchain ${go_bin} failed its smoke build"
        return 40
    fi
    if ! go_container_exec_at "${smoke_dir}" ./smoke | grep -qx 'go-smoke'; then
        log_message "ERROR: the Go smoke binary from ${go_bin} did not produce the expected output"
        return 40
    fi
    log_message "Go toolchain smoke test passed: ${go_bin}"
}

start_go_runtime() {
    local official_version optimized_version
    initialize_runtime || return $?
    check_go_container || return $?
    configure_go_environment
    official_version="$(official_go_version)" || {
        log_message "ERROR: cannot read the official Go version"
        return 40
    }
    if [[ "${official_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: official Go is ${official_version}, expected ${SOFTWARE_VERSION} at ${GO_OFFICIAL_GOROOT}"
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
    if ! go_container_exec test -x "${GO_BENCHSTAT}"; then
        log_message "ERROR: benchstat is not installed at ${GO_BENCHSTAT}"
        return 40
    fi
    smoke_go_toolchain "${GO_BIN}" "${GO_OFFICIAL_GOROOT}" "${PERF_WORK_DIR}/smoke-official" || return $?
    smoke_go_toolchain "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${PERF_WORK_DIR}/smoke-optimized" || return $?
    log_message "Go toolchains ${official_version} (${GO_OFFICIAL_GOROOT}) and ${optimized_version} (${GO_OPTIMIZED_GOROOT}) are ready for measurement"
}
