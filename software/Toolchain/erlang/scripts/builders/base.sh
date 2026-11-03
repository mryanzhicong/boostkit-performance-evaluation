#!/usr/bin/env bash
# Base build for the Erlang/OTP case.  The host keeps only the download and
# verification of the pinned release assets; extraction, package installation,
# configure/make/install, version probing and workload compilation all happen
# inside this task's private openEuler container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base_common.sh"

prepare_erlang_build_container() {
    local -a dnf_options=()
    require_erlang_docker || return 30
    start_erlang_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing the Erlang build and runtime dependencies inside the private container'
    erlang_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar curl bzip2 ncurses-devel openssl-devel perl \
        python3 time diffutils coreutils findutils sed gawk grep util-linux file || {
        log_message "ERROR: dnf install failed for the Erlang build dependencies"
        return 30
    }
    erlang_container_exec bash -c \
        'command -v gcc >/dev/null && command -v make >/dev/null && command -v perl >/dev/null \
         && { test -f /usr/include/ncurses.h || test -f /usr/include/term.h; }' || {
        log_message "ERROR: the container build dependencies remain incomplete (erts requires ncurses development files)"
        return 30
    }
    log_message 'Erlang build dependencies are ready inside the private container'
}

ensure_source_extracted() {
    if erlang_container_exec test -x "${BENCH_SRC_DIR}/configure"; then
        return 0
    fi
    log_message "extracting ${BENCH_SOURCE_NAME} into ${BENCH_SRC_PARENT} inside the private container"
    rm -rf "${BENCH_SRC_PARENT}" "${BENCH_SRC_PARENT}.extract"
    mkdir -p "${BENCH_SRC_PARENT}.extract"
    erlang_container_exec tar -xzf "${BENCH_DOWNLOADS_DIR}/${BENCH_SOURCE_NAME}" \
        -C "${BENCH_SRC_PARENT}.extract" --strip-components=1 || return 30
    mv "${BENCH_SRC_PARENT}.extract" "${BENCH_SRC_PARENT}"
    erlang_container_exec test -x "${BENCH_SRC_DIR}/configure" || {
        log_message "ERROR: extracted source is missing configure: ${BENCH_SRC_DIR}"
        return 30
    }
}

fetch_bencherl_modules() {
    mkdir -p "${BENCH_BENCHERL_SRC_DIR}" "${BENCH_BENCHERL_OFFLINE_DIR}"
    local module urls=()
    local module_name base
    for module in "${BENCH_BENCHERL_FILES[@]}"; do
        urls=()
        module_name="${module%.erl}"
        # bang.erl / big.erl / mbrot.erl live in bench/<name>/src/<name>.erl.
        for base in "${BENCH_BENCHERL_URL_BASES[@]}"; do
            urls+=("${base}/${module_name}/src/${module}")
        done
        materialize_asset "${BENCH_BENCHERL_SRC_DIR}" "${module}" "${BENCH_BENCHERL_SHA256[${module}]}" \
            "${BENCH_BENCHERL_OFFLINE_DIR}" "${urls[@]}" || return $?
    done
    # mbrot.erl carries "-compile(native)." which is unsupported since HiPE was
    # removed in OTP 24; drop only that line (documented in build_variant.json).
    if erlang_container_exec grep -q '^-compile(native)\.' "${BENCH_BENCHERL_SRC_DIR}/mbrot.erl"; then
        erlang_container_exec sed -i '/^-compile(native)\./d' "${BENCH_BENCHERL_SRC_DIR}/mbrot.erl"
        log_message "patched mbrot.erl: removed -compile(native). (HiPE removed in OTP 24+)"
    fi
    erlang_container_exec grep -q '^-compile(native)\.' "${BENCH_BENCHERL_SRC_DIR}/mbrot.erl" && {
        log_message "ERROR: mbrot.erl still requests native compilation"
        return 30
    } || true
    log_message "bencherl modules fetched and verified: ${BENCH_BENCHERL_FILES[*]}"
}

build_erlang_impl() {
    prepare_erlang_build_container || return 30
    mkdir -p "${BENCH_DOWNLOADS_DIR}"
    materialize_asset "${BENCH_DOWNLOADS_DIR}" "${BENCH_SOURCE_NAME}" "${BENCH_SOURCE_SHA256}" \
        "${BENCH_OFFLINE_DIR}" "${BENCH_SOURCE_URLS[@]}" || return $?
    ensure_source_extracted || return $?
    fetch_bencherl_modules || return $?
    rm -rf "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"
    mkdir -p "${BENCH_INSTALL_DIR}" "${BENCH_BUILD_DIR}"
    log_message "configuring ${BENCH_SRC_DIR} inside the private container"
    erlang_container_exec_at "${BENCH_SRC_DIR}" \
        ./configure --prefix="${BENCH_INSTALL_DIR}" --without-javac --without-odbc --without-wx \
        > "${BENCH_BUILD_DIR}/configure.log" 2>&1 || {
        log_message "ERROR: configure failed; see ${BENCH_BUILD_DIR}/configure.log"
        tail -40 "${BENCH_BUILD_DIR}/configure.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    log_message "compiling with make -j${BENCH_BUILD_JOBS} inside the private container"
    erlang_container_exec_at "${BENCH_SRC_DIR}" make -j"${BENCH_BUILD_JOBS}" \
        > "${BENCH_BUILD_DIR}/make.log" 2>&1 || {
        log_message "ERROR: make failed; see ${BENCH_BUILD_DIR}/make.log"
        tail -40 "${BENCH_BUILD_DIR}/make.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    erlang_container_exec_at "${BENCH_SRC_DIR}" make install \
        > "${BENCH_BUILD_DIR}/install.log" 2>&1 || {
        log_message "ERROR: make install failed; see ${BENCH_BUILD_DIR}/install.log"
        tail -40 "${BENCH_BUILD_DIR}/install.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    }
    erlang_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: installed erl binary is missing: ${BENCH_BIN}"
        return 30
    }
    local version_line actual
    actual="$(erlang_container_exec cat "${BENCH_INSTALL_DIR}"/lib/erlang/releases/*/OTP_VERSION 2>/dev/null | head -1)"
    version_line="$(erlang_container_exec "${BENCH_BIN}" -noshell -eval 'io:format("~s~n", [erlang:system_info(system_version)]), halt(0).' 2>/dev/null | head -1)"
    record_actual_version "${actual}" "${version_line}" || return 30
    log_message "erlang build completed: ${version_line}"
    compile_workloads || return $?
    BENCH_BUILD_CONFIG="$(printf '{"configure":"./configure --prefix=<install> --without-javac --without-odbc --without-wx","jobs":%s,"source_sha256":"%s","bencherl_commit":"%s"}' \
        "${BENCH_BUILD_JOBS}" "${BENCH_SOURCE_SHA256}" "${BENCH_BENCHERL_COMMIT}")"
}

compile_workloads() {
    rm -rf "${BENCH_EBIN_DIR}"
    mkdir -p "${BENCH_EBIN_DIR}"
    local source
    for source in "${BENCH_BENCHERL_SRC_DIR}"/*.erl "${SCRIPT_DIR}/benchmarks/perf_bench.erl"; do
        [[ -f "${source}" ]] || {
            log_message "ERROR: workload source is missing: ${source}"
            return 30
        }
        erlang_container_exec "${BENCH_INSTALL_DIR}/bin/erlc" -o "${BENCH_EBIN_DIR}" "${source}" \
            > "${BENCH_BUILD_DIR}/erlc-$(basename "${source}").log" 2>&1 || {
            log_message "ERROR: failed to compile ${source}"
            tail -20 "${BENCH_BUILD_DIR}/erlc-$(basename "${source}").log" | while IFS= read -r line; do log_message "  ${line}"; done
            return 30
        }
    done
    log_message "workload modules compiled into ${BENCH_EBIN_DIR} inside the private container"
}

build_config_json() {
    printf '%s\n' "${BENCH_BUILD_CONFIG}"
}

build_erlang_base() {
    build_erlang_impl || return $?
    workload_smoke || return $?
}

workload_smoke() {
    local smoke_dir="${BENCH_BUILD_DIR}/smoke"
    rm -rf "${smoke_dir}"
    mkdir -p "${smoke_dir}"
    erlang_container_exec "${BENCH_BIN}" -noshell -pa "${BENCH_EBIN_DIR}" -run perf_bench main arith_int 1000 "${smoke_dir}" \
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
