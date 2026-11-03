#!/usr/bin/env bash
# Base build for the Perl case.  The host keeps only the download and verification
# of the pinned release archive; extraction, package installation,
# Configure/make/install, version probing and the workload smoke check all happen
# inside this task's private openEuler container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base_common.sh"

prepare_perl_build_container() {
    local -a dnf_options=()
    require_perl_docker || return 30
    start_perl_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing the Perl build and runtime dependencies inside the private container'
    perl_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc make tar curl bzip2 xz python3 time diffutils coreutils findutils \
        sed gawk grep util-linux file || {
        log_message "ERROR: dnf install failed for the Perl build dependencies"
        return 30
    }
    perl_container_exec bash -c \
        'command -v gcc >/dev/null && command -v make >/dev/null && command -v python3 >/dev/null' || {
        log_message "ERROR: the container build dependencies remain incomplete"
        return 30
    }
    log_message 'Perl build dependencies are ready inside the private container'
}

ensure_source_extracted() {
    if perl_container_exec test -x "${BENCH_SRC_DIR}/Configure"; then
        return 0
    fi
    log_message "extracting ${BENCH_SOURCE_NAME} into ${BENCH_SRC_PARENT} inside the private container"
    rm -rf "${BENCH_SRC_PARENT}" "${BENCH_SRC_PARENT}.extract"
    mkdir -p "${BENCH_SRC_PARENT}.extract"
    perl_container_exec tar -xzf "${BENCH_DOWNLOADS_DIR}/${BENCH_SOURCE_NAME}" \
        -C "${BENCH_SRC_PARENT}.extract" --strip-components=1 || return 30
    mv "${BENCH_SRC_PARENT}.extract" "${BENCH_SRC_PARENT}"
    perl_container_exec test -x "${BENCH_SRC_DIR}/Configure" || {
        log_message "ERROR: extracted source is missing Configure: ${BENCH_SRC_DIR}"
        return 30
    }
    perl_container_exec test -f "${BENCH_SRC_DIR}/lib/Benchmark.pm" || {
        log_message "ERROR: extracted source is missing the core Benchmark module"
        return 30
    }
}

build_perl_impl() {
    prepare_perl_build_container || return 30
    mkdir -p "${BENCH_DOWNLOADS_DIR}"
    materialize_asset "${BENCH_DOWNLOADS_DIR}" "${BENCH_SOURCE_NAME}" "${BENCH_SOURCE_SHA256}" \
        "${BENCH_OFFLINE_DIR}" "${BENCH_SOURCE_URLS[@]}" || return $?
    ensure_source_extracted || return $?
    rm -rf "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"
    mkdir -p "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"
    log_message "configuring ${BENCH_SRC_DIR} inside the private container"
    perl_container_exec_at "${BENCH_SRC_DIR}" \
        ./Configure -des \
            -Dprefix="${BENCH_INSTALL_DIR}" \
            -Dman1dir=none -Dman3dir=none \
            -Dcc=gcc -Dcf_by=perf -Dcf_email=perf@example.com \
        > "${BENCH_BUILD_DIR}/configure.log" 2>&1 || {
        log_message "ERROR: Configure failed; see ${BENCH_BUILD_DIR}/configure.log"
        tail -40 "${BENCH_BUILD_DIR}/configure.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    log_message "compiling with make -j${BENCH_BUILD_JOBS} inside the private container"
    perl_container_exec_at "${BENCH_SRC_DIR}" make -j"${BENCH_BUILD_JOBS}" \
        > "${BENCH_BUILD_DIR}/make.log" 2>&1 || {
        log_message "ERROR: make failed; see ${BENCH_BUILD_DIR}/make.log"
        tail -40 "${BENCH_BUILD_DIR}/make.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    perl_container_exec_at "${BENCH_SRC_DIR}" make install \
        > "${BENCH_BUILD_DIR}/install.log" 2>&1 || {
        log_message "ERROR: make install failed; see ${BENCH_BUILD_DIR}/install.log"
        tail -40 "${BENCH_BUILD_DIR}/install.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    perl_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: installed perl binary is missing: ${BENCH_BIN}"
        return 30
    }
    local version_line actual
    version_line="$(perl_container_exec "${BENCH_BIN}" -v 2>&1 | grep -m1 'This is perl 5' || true)"
    actual="$(perl_container_exec "${BENCH_BIN}" -e 'print $^V' 2>/dev/null | sed 's/^v//')" || actual=""
    record_actual_version "${actual}" "${version_line}" || return 30
    perl_container_exec "${BENCH_BIN}" -MBenchmark -e 'print "Benchmark module loadable\n"' >/dev/null 2>&1 || {
        log_message "ERROR: the built perl cannot load the core Benchmark module"
        return 30
    }
    BENCH_BUILD_CONFIG="$(printf '{"configure":"Configure -des -Dprefix=<install> -Dman1dir=none -Dman3dir=none -Dcc=gcc","jobs":%s,"source_sha256":"%s"}' \
        "${BENCH_BUILD_JOBS}" "${BENCH_SOURCE_SHA256}")"
    log_message "perl build completed inside the container: ${version_line}"
}

build_config_json() {
    printf '%s\n' "${BENCH_BUILD_CONFIG}"
}

build_perl_base() {
    build_perl_impl || return $?
    workload_smoke || return $?
}

workload_smoke() {
    local smoke_dir="${BENCH_BUILD_DIR}/smoke"
    rm -rf "${smoke_dir}"
    mkdir -p "${smoke_dir}"
    perl_container_exec "${BENCH_BIN}" "${SCRIPT_DIR}/benchmarks/bench.pl" arith_int 1000 "${smoke_dir}" \
        > "${smoke_dir}/arith_int.log" 2>&1 || {
        log_message "ERROR: smoke workload failed; see ${smoke_dir}/arith_int.log"
        return 30
    }
    grep -q 'RESULT scenario=arith_int checksum=' "${smoke_dir}/arith_int.log" || {
        log_message "ERROR: smoke workload did not print a RESULT line"
        return 30
    }
    log_message "build smoke check passed inside the private container"
}
