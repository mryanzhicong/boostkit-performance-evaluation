#!/usr/bin/env bash
# Base build: fetch the pinned APR and APR-util release tarballs on the host,
# then extract, configure, build and install both libraries (APR-util against
# the just-built APR), build the upstream portable test program (test/testall)
# and compile the case-owned base64 harness inside this task's private openEuler
# container.  The actual versions are read back from the built artefacts so the
# Framework can reject a wrong build.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

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
    log_message "WARNING: host download tools are incomplete: ${packages[*]}; relying on the pre-placed offline archives"
    return 0
}

prepare_apr_util_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_apr_util_docker || return 30
    start_apr_util_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing APR and APR-util build dependencies inside the private container'
    # APR-util 1.6.5 always compiles its XML support and needs expat headers;
    # the container image only ships the runtime library.
    apr_util_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar bzip2 diffutils coreutils findutils sed gawk grep \
        util-linux file glibc-devel expat-devel binutils python3 || {
        fail_message "container build dependencies failed"
        return 30
    }
}

extract_source_tree() {
    local archive="$1"
    local destination="$2"
    local extracted_name="$3"

    if [[ -d "${destination}" ]]; then
        rm -rf -- "${destination}"
    fi
    log_message "extracting ${archive##*/} inside the private container"
    apr_util_container_exec tar -xjf "${archive}" -C "${PERF_WORK_DIR}" || {
        fail_message "failed to extract ${archive}"
        return 30
    }
    if apr_util_container_exec test -d "${PERF_WORK_DIR}/${extracted_name}"; then
        apr_util_container_exec mv -- "${PERF_WORK_DIR}/${extracted_name}" "${destination}" || {
            fail_message "failed to place the extracted ${extracted_name} tree"
            return 30
        }
    fi
    if ! apr_util_container_exec test -d "${destination}"; then
        fail_message "source tree is missing after extraction: ${destination}"
        return 30
    fi
    return 0
}

build_apr() {
    log_message "configuring APR 1.7.5 (static, prefix ${APR_PREFIX})"
    apr_util_container_exec_at "${APR_SRC_DIR}" \
        env "CFLAGS=${APR_UTIL_OPTIMIZATION}" \
        ./configure --prefix="${APR_PREFIX}" --disable-shared --enable-static \
        > "${APR_UTIL_STATE_DIR}/apr-configure.log" 2>&1 || {
        fail_message "APR configure failed, see ${APR_UTIL_STATE_DIR}/apr-configure.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-configure.log" >&2 || true
        return 30
    }

    log_message "building APR 1.7.5 with -j${APR_UTIL_BUILD_JOBS} inside the private container"
    apr_util_container_exec_at "${APR_SRC_DIR}" make -j "${APR_UTIL_BUILD_JOBS}" \
        > "${APR_UTIL_STATE_DIR}/apr-build.log" 2>&1 || {
        fail_message "APR build failed, see ${APR_UTIL_STATE_DIR}/apr-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-build.log" >&2 || true
        return 30
    }
    apr_util_container_exec_at "${APR_SRC_DIR}" make install \
        > "${APR_UTIL_STATE_DIR}/apr-install.log" 2>&1 || {
        fail_message "APR install failed, see ${APR_UTIL_STATE_DIR}/apr-install.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-install.log" >&2 || true
        return 30
    }
    if ! apr_util_container_exec test -f "${APR_PREFIX}/lib/libapr-1.a" || \
        ! apr_util_container_exec test -x "${APR_PREFIX}/bin/apr-1-config"; then
        fail_message "APR static library or apr-1-config was not installed under ${APR_PREFIX}"
        return 30
    fi
    return 0
}

build_apr_util_library() {
    log_message "configuring APR-util 1.6.5 against ${APR_PREFIX}"
    apr_util_container_exec_at "${APR_UTIL_SRC_DIR}" \
        env "CFLAGS=${APR_UTIL_OPTIMIZATION}" \
        ./configure --prefix="${APR_PREFIX}" --with-apr="${APR_PREFIX}" \
        "${APR_UTIL_CONFIGURE_OPTIONS[@]}" \
        > "${APR_UTIL_STATE_DIR}/apr-util-configure.log" 2>&1 || {
        fail_message "APR-util configure failed, see ${APR_UTIL_STATE_DIR}/apr-util-configure.log"
        tail -50 "${APR_UTIL_STATE_DIR}/apr-util-configure.log" >&2 || true
        return 30
    }

    log_message "building APR-util 1.6.5 with -j${APR_UTIL_BUILD_JOBS} inside the private container"
    apr_util_container_exec_at "${APR_UTIL_SRC_DIR}" make -j "${APR_UTIL_BUILD_JOBS}" \
        > "${APR_UTIL_STATE_DIR}/apr-util-build.log" 2>&1 || {
        fail_message "APR-util build failed, see ${APR_UTIL_STATE_DIR}/apr-util-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-util-build.log" >&2 || true
        return 30
    }
    apr_util_container_exec_at "${APR_UTIL_SRC_DIR}" make install \
        > "${APR_UTIL_STATE_DIR}/apr-util-install.log" 2>&1 || {
        fail_message "APR-util install failed, see ${APR_UTIL_STATE_DIR}/apr-util-install.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-util-install.log" >&2 || true
        return 30
    }
    if ! apr_util_container_exec test -f "${APR_PREFIX}/lib/libaprutil-1.a" || \
        ! apr_util_container_exec test -f "${APR_PREFIX}/include/apr-1/apr_base64.h"; then
        fail_message "APR-util static library or headers were not installed under ${APR_PREFIX}"
        return 30
    fi
    return 0
}

build_upstream_testall() {
    log_message "building the upstream portable test program (test/testall)"
    apr_util_container_exec_at "${APR_UTIL_SRC_DIR}/test" make testall \
        > "${APR_UTIL_STATE_DIR}/testall-build.log" 2>&1 || {
        fail_message "test/testall build failed, see ${APR_UTIL_STATE_DIR}/testall-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/testall-build.log" >&2 || true
        return 30
    }
    if ! apr_util_container_exec test -x "${APR_UTIL_TESTALL_BIN}"; then
        fail_message "the upstream testall binary was not produced: ${APR_UTIL_TESTALL_BIN}"
        return 30
    fi
    return 0
}

build_base64_harness() {
    mkdir -p "${PERF_WORK_DIR}/apr-util-bench" || return 30
    log_message "compiling the base64 benchmark harness inside the private container"
    apr_util_container_exec_at "${CASE_DIR}" \
        cc ${APR_UTIL_HARNESS_CFLAGS} \
        -I "${APR_PREFIX}/include/apr-1" \
        bench/base64_bench.c \
        -L "${APR_PREFIX}/lib" -laprutil-1 -lapr-1 -lm -lpthread -ldl \
        -o "${APR_UTIL_BENCH_BIN}" \
        > "${APR_UTIL_STATE_DIR}/harness-base64.log" 2>&1 || {
        fail_message "failed to compile bench/base64_bench.c, see ${APR_UTIL_STATE_DIR}/harness-base64.log"
        tail -30 "${APR_UTIL_STATE_DIR}/harness-base64.log" >&2 || true
        return 30
    }

    log_message "compiling the offline network-namespace launcher inside the private container"
    apr_util_container_exec_at "${CASE_DIR}" \
        cc ${APR_UTIL_HARNESS_CFLAGS} \
        bench/netns_loopback_up.c \
        -o "${APR_UTIL_NETNS_PREP}" \
        > "${APR_UTIL_STATE_DIR}/harness-netns.log" 2>&1 || {
        fail_message "failed to compile bench/netns_loopback_up.c, see ${APR_UTIL_STATE_DIR}/harness-netns.log"
        tail -30 "${APR_UTIL_STATE_DIR}/harness-netns.log" >&2 || true
        return 30
    }
    if ! apr_util_container_exec test -x "${APR_UTIL_BENCH_BIN}" || \
        ! apr_util_container_exec test -x "${APR_UTIL_NETNS_PREP}"; then
        fail_message "benchmark harness binaries are missing after the build"
        return 30
    fi
    return 0
}

verify_versions() {
    local reported
    reported="$(apr_util_container_exec "${APR_UTIL_BENCH_BIN}" --version 2>/dev/null || true)"
    if [[ -z "${reported}" ]]; then
        fail_message "cannot determine the built APR-util/APR versions"
        return 30
    fi
    local apu_version apr_version
    apu_version="${reported#*apu=}"
    apu_version="${apu_version%% *}"
    apr_version="${reported#*apr=}"
    apr_version="${apr_version%% *}"
    if [[ "${apr_version}" != "1.7.5" ]]; then
        fail_message "expected the pinned APR 1.7.5, harness linked APR ${apr_version}"
        return 30
    fi
    printf '%s\n' "${apu_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ "${apu_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "requested APR-util ${SOFTWARE_VERSION}, built ${apu_version}"
        return 30
    fi
    return 0
}

write_build_provenance() {
    cat > "${APR_UTIL_STATE_DIR}/build-provenance.txt" <<EOF
software=apr-util
version=${SOFTWARE_VERSION}
apr_version=1.7.5
apr_source_archive=${APR_SOURCE_NAME}
apr_source_sha256=${APR_SOURCE_SHA256}
apr_source_bytes=${APR_SOURCE_SIZE}
apr_util_source_archive=${APR_UTIL_SOURCE_NAME}
apr_util_source_sha256=${APR_UTIL_SOURCE_SHA256}
apr_util_source_bytes=${APR_UTIL_SOURCE_SIZE}
configure_options=${APR_UTIL_CONFIGURE_OPTIONS[*]}
build_target=static
optimization=${APR_UTIL_OPTIMIZATION}
harness_cflags=${APR_UTIL_HARNESS_CFLAGS}
build_jobs=${APR_UTIL_BUILD_JOBS}
c_compiler=$(compiler_identity)
apr_prefix=${APR_PREFIX}
benchmark_binary=${APR_UTIL_BENCH_BIN}
netns_loopback_launcher=${APR_UTIL_NETNS_PREP}
upstream_test_binary=${APR_UTIL_TESTALL_BIN}
upstream_expected_test_modules=${APR_UTIL_EXPECT_TESTALL_MODULES}
bundled_expat=yes
container_name=${APR_UTIL_CONTAINER_NAME}
container_image=$(apr_util_container_exec cat /etc/os-release 2>/dev/null | sed -n 's/^PRETTY_NAME=//p' | tr -d '"' || true)
EOF
}

build_apr_util_base() {
    initialize_runtime || return $?
    prepare_apr_util_build_container || return $?

    log_message "fetching pinned APR ${APR_SOURCE_NAME##*/} and APR-util ${APR_UTIL_SOURCE_NAME##*/}"
    fetch_sources || return $?

    extract_source_tree "${APR_SOURCE_ARCHIVE}" "${APR_SRC_DIR}" "apr-1.7.5" || return $?
    extract_source_tree "${APR_UTIL_SOURCE_ARCHIVE}" "${APR_UTIL_SRC_DIR}" "apr-util-1.6.5" || return $?
    if ! apr_util_container_exec test -f "${APR_SRC_DIR}/configure" || \
        ! apr_util_container_exec test -f "${APR_UTIL_SRC_DIR}/configure"; then
        fail_message "source archives do not contain the expected APR / APR-util trees"
        return 30
    fi

    build_apr || return $?
    build_apr_util_library || return $?
    build_upstream_testall || return $?
    build_base64_harness || return $?
    verify_versions || return $?
    write_build_provenance || return $?

    log_message "APR-util ${SOFTWARE_VERSION} (APR 1.7.5) built; harnesses compiled"
    return 0
}
