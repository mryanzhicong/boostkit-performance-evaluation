#!/usr/bin/env bash
# Base build: fetch and verify the pinned PCRE 8.45 source archive on the host,
# then extract, configure, build and install it inside this task's private
# openEuler container.  The case's deterministic matching harness is compiled in
# the same container against the freshly installed static library.  The actual
# version is read back from the built ``pcre-config`` so the Framework can reject
# a wrong build.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host-side prerequisites are limited to Docker plus the download/verification
# tools; every compiler and build dependency is installed inside the container.
require_host_transfer_commands() {
    local packages=()
    local command_name package
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;;
            sha256sum) package=coreutils ;;
            tar) package=tar ;;
            python3) package=python3 ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    log_message "WARNING: host download tools are incomplete: ${packages[*]}; relying on the pre-placed offline archive"
    return 0
}

prepare_pcre_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_pcre_docker || return 30
    start_pcre_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing PCRE build and runtime dependencies inside the private container'
    pcre_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make tar gzip diffutils coreutils findutils sed gawk grep \
        util-linux file glibc-devel binutils python3 || {
        fail_message "container build dependencies failed"
        return 30
    }
}

build_pcre_base() {
    initialize_runtime || return $?
    prepare_pcre_build_container || return $?
    fetch_source_archive || return 30

    log_message "extracting ${PCRE_SOURCE_NAME} inside the private container"
    rm -rf -- "${PCRE_SRC_DIR}"
    mkdir -p "${PCRE_SRC_DIR}"
    pcre_container_exec tar -xzf "${PCRE_SOURCE_ARCHIVE}" -C "${PCRE_SRC_DIR}" --strip-components=1 || {
        fail_message "failed to extract ${PCRE_SOURCE_ARCHIVE}"
        return 30
    }
    pcre_container_exec test -f "${PCRE_SRC_DIR}/configure" || {
        fail_message "extracted source tree has no configure script"
        return 30
    }

    log_message "configuring PCRE ${SOFTWARE_VERSION}: ${PCRE_CONFIGURE_OPTIONS[*]}"
    pcre_container_exec_at "${PCRE_SRC_DIR}" \
        env "CFLAGS=${PCRE_CFLAGS}" "CXXFLAGS=${PCRE_CFLAGS}" \
        ./configure --prefix="${PCRE_INSTALL_DIR}" "${PCRE_CONFIGURE_OPTIONS[@]}" \
        > "${PCRE_STATE_DIR}/configure.log" 2>&1 || {
        fail_message "configure failed; tail of configure.log:"
        tail -n 40 -- "${PCRE_STATE_DIR}/configure.log" >&2 || true
        return 30
    }

    log_message "building PCRE with -j${PCRE_BUILD_JOBS} inside the private container"
    # Build and install as two sequential make invocations: requesting both
    # goals at once makes install race with the still-running compilations.
    {
        pcre_container_exec_at "${PCRE_SRC_DIR}" make -j "${PCRE_BUILD_JOBS}" all &&
            pcre_container_exec_at "${PCRE_SRC_DIR}" make install
    } > "${PCRE_STATE_DIR}/build.log" 2>&1 || {
        fail_message "build failed; tail of build.log:"
        tail -n 40 -- "${PCRE_STATE_DIR}/build.log" >&2 || true
        return 30
    }

    local tool
    for tool in pcretest pcregrep pcre-config; do
        pcre_container_exec test -x "$(pcre_tool "${tool}")" || {
            fail_message "installed PCRE is missing $(pcre_tool "${tool}")"
            return 30
        }
    done
    pcre_container_exec test -f "${PCRE_INSTALL_DIR}/lib/libpcre.a" || {
        fail_message "installed PCRE static library is missing"
        return 30
    }

    # The actual version is read from the built artefact, never echoed from the
    # requested value; a mismatch makes the build stage fail (exit 30).
    local actual_version
    actual_version="$(pcre_container_exec "$(pcre_tool pcre-config)" --version 2>/dev/null | head -n 1)" || actual_version=""
    if [[ -z "${actual_version}" ]]; then
        fail_message "pcre-config did not report a version"
        return 30
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "requested PCRE ${SOFTWARE_VERSION} but built ${actual_version}"
        return 30
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "actual PCRE version: ${actual_version}"

    log_message "compiling the deterministic matching harness inside the private container"
    pcre_container_exec cc -O2 -std=c99 -Wall -Wextra -Werror \
        -o "${PCRE_BENCH_BIN}" \
        "${SCRIPT_DIR}/benchmark/pcre_bench.c" \
        -I"${PCRE_INSTALL_DIR}/include" -L"${PCRE_INSTALL_DIR}/lib" -lpcre \
        > "${PCRE_STATE_DIR}/bench-build.log" 2>&1 || {
        fail_message "failed to compile benchmark/pcre_bench.c; log:"
        tail -n 40 -- "${PCRE_STATE_DIR}/bench-build.log" >&2 || true
        return 30
    }
    # The harness must report the same library version as pcre-config.
    local harness_version
    harness_version="$(pcre_container_exec "${PCRE_BENCH_BIN}" compile 10 2>/dev/null | head -n 1 | sed -E 's/.*pcre_version=//')" || harness_version=""
    case "${harness_version}" in
        "${SOFTWARE_VERSION}"*) ;;
        *)
            fail_message "harness reports unexpected PCRE version: ${harness_version}"
            return 30
            ;;
    esac

    {
        printf 'requested_version=%s\n' "${SOFTWARE_VERSION}"
        printf 'actual_version=%s\n' "${actual_version}"
        printf 'source_sha256=%s\n' "${PCRE_SOURCE_SHA256}"
        printf 'source_origin=%s\n' "$(cat "${PCRE_STATE_DIR}/source-origin.txt" 2>/dev/null || echo unknown)"
        printf 'configure_options=%s\n' "${PCRE_CONFIGURE_OPTIONS[*]}"
        printf 'cflags=%s\n' "${PCRE_CFLAGS}"
        printf 'compiler=%s\n' "$(compiler_identity)"
        printf 'build_jobs=%s\n' "${PCRE_BUILD_JOBS}"
        printf 'pcretest_features=%s\n' "$(pcre_container_exec "$(pcre_tool pcretest)" -C 2>/dev/null | tr '\n' ';' || true)"
        printf 'container_image=%s\n' "$(pcre_container_exec cat /etc/os-release 2>/dev/null | sed -n 's/^PRETTY_NAME=//p' | tr -d '\"' || true)"
    } > "${PCRE_STATE_DIR}/build-provenance.txt"
    log_message "base build finished"
    return 0
}
