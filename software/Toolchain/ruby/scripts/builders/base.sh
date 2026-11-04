#!/usr/bin/env bash
# Base build: verify the pinned Ruby 4.0.9 release archive on the host, then
# extract, configure, build and install it inside this task's private openEuler
# container.  The host keeps only Docker, the download/verification tooling and
# the framework; the compiler, the -devel packages and every build step run in
# the container.  The actual version is read back from the built interpreter.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base_common.sh"

prepare_ruby_build_container() {
    local -a dnf_options=()
    require_ruby_docker || return 30
    start_ruby_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing Ruby build and runtime dependencies inside the private container'
    ruby_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc make tar curl bzip2 xz findutils coreutils diffutils sed gawk grep \
        util-linux file time \
        openssl-devel libyaml-devel zlib-devel readline-devel libffi-devel \
        gdbm-devel ncurses-devel libxcrypt-devel python3 || {
        log_message 'ERROR: container build dependencies failed'
        return 30
    }
    local cmd
    for cmd in gcc make /usr/bin/time curl; do
        ruby_container_exec sh -c "command -v ${cmd} >/dev/null 2>&1" || {
            log_message "ERROR: required container command is still unavailable: ${cmd}"
            return 30
        }
    done
    log_message 'Ruby build dependencies are ready inside the private container'
}

ensure_source_extracted() {
    if ruby_container_exec test -x "${BENCH_SRC_DIR}/configure"; then
        return 0
    fi
    log_message "extracting ${BENCH_SOURCE_NAME} inside the private container"
    rm -rf "${BENCH_SRC_DIR}"
    mkdir -p "${BENCH_SRC_DIR}"
    ruby_container_exec tar -xzf "${BENCH_DOWNLOADS_DIR}/${BENCH_SOURCE_NAME}" \
        -C "${BENCH_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract ${BENCH_SOURCE_NAME} inside the container"
        return 30
    }
    ruby_container_exec test -x "${BENCH_SRC_DIR}/configure" || {
        log_message "ERROR: extracted source is missing configure: ${BENCH_SRC_DIR}"
        return 30
    }
}

build_ruby_impl() {
    prepare_ruby_build_container || return 30
    mkdir -p "${BENCH_DOWNLOADS_DIR}"
    materialize_asset "${BENCH_DOWNLOADS_DIR}" "${BENCH_SOURCE_NAME}" "${BENCH_SOURCE_SHA256}" \
        "${BENCH_OFFLINE_DIR}" "${BENCH_SOURCE_URLS[@]}" || return $?
    ensure_source_extracted || return $?
    rm -rf "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"
    mkdir -p "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"

    log_message "configuring ${BENCH_SRC_DIR} inside the private container"
    ruby_container_exec_at "${BENCH_SRC_DIR}" ./configure \
        --prefix="${BENCH_INSTALL_DIR}" --disable-install-doc --disable-yjit \
        > "${BENCH_BUILD_DIR}/configure.log" 2>&1 || {
        log_message "ERROR: configure failed; see ${BENCH_BUILD_DIR}/configure.log"
        tail -40 "${BENCH_BUILD_DIR}/configure.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    log_message "compiling inside the private container with make -j${BENCH_BUILD_JOBS}"
    {
        ruby_container_exec_at "${BENCH_SRC_DIR}" make -j"${BENCH_BUILD_JOBS}" &&
            ruby_container_exec_at "${BENCH_SRC_DIR}" make install
    } > "${BENCH_BUILD_DIR}/make.log" 2>&1 || {
        log_message "ERROR: make or make install failed; see ${BENCH_BUILD_DIR}/make.log"
        tail -40 "${BENCH_BUILD_DIR}/make.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    ruby_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: installed ruby binary is missing: ${BENCH_BIN}"
        return 30
    }
    local version_line actual
    version_line="$(ruby_container_exec "${BENCH_BIN}" --version 2>&1 | head -1)"
    actual="$(printf '%s' "${version_line}" | sed -n 's/^ruby \([0-9][0-9.]*\).*/\1/p')"
    record_actual_version "${actual}" "${version_line}" || return 30
    ruby_container_exec "${BENCH_BIN}" -rbenchmark -e 'print "Benchmark module loadable\n"' >/dev/null 2>&1 || {
        log_message "ERROR: the built ruby cannot load the stdlib Benchmark module inside the container"
        return 30
    }
    BENCH_BUILD_CONFIG="$(printf '{"container":"openEuler 24.03 LTS SP4","configure":"./configure --prefix=<install> --disable-install-doc --disable-yjit","jobs":%s,"source_sha256":"%s"}' \
        "${BENCH_BUILD_JOBS}" "${BENCH_SOURCE_SHA256}")"
    log_message "ruby build completed inside the private container: ${version_line}"
}

build_config_json() {
    printf '%s\n' "${BENCH_BUILD_CONFIG}"
}

workload_smoke() {
    local smoke_dir="${BENCH_BUILD_DIR}/smoke"
    rm -rf "${smoke_dir}"
    mkdir -p "${smoke_dir}"
    ruby_container_exec "${BENCH_BIN}" "${SCRIPT_DIR}/benchmarks/bench.rb" \
        arith_int 1000 "${smoke_dir}" > "${smoke_dir}/arith_int.log" 2>&1 || {
        log_message "ERROR: smoke workload failed; see ${smoke_dir}/arith_int.log"
        return 30
    }
    grep -q 'RESULT scenario=arith_int checksum=' "${smoke_dir}/arith_int.log" || {
        log_message "ERROR: smoke workload did not print a RESULT line"
        return 30
    }
    log_message "build smoke check passed inside the private container"
}

build_ruby_base() {
    initialize_runtime || return $?
    build_ruby_impl || return $?
    workload_smoke || return $?
}
