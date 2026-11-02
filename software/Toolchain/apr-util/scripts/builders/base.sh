#!/usr/bin/env bash
# Base build: fetch the pinned APR and APR-util release tarballs, build both as
# static libraries (APR-util against the just-built APR), build the upstream
# portable test program (test/testall), then compile the case-owned base64
# harness against the same libraries.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

extract_source_tree() {
    local archive="$1"
    local destination="$2"
    local extracted_name="$3"

    if [[ -d "${destination}" ]]; then
        rm -rf -- "${destination}"
    fi
    log_message "extracting ${archive}"
    tar -xjf "${archive}" -C "${PERF_WORK_DIR}" || {
        fail_message "failed to extract ${archive}"
        return 30
    }
    if [[ -d "${PERF_WORK_DIR}/${extracted_name}" ]]; then
        mv -- "${PERF_WORK_DIR}/${extracted_name}" "${destination}" || {
            fail_message "failed to place the extracted ${extracted_name} tree"
            return 30
        }
    fi
    if [[ ! -d "${destination}" ]]; then
        fail_message "source tree is missing after extraction: ${destination}"
        return 30
    fi
    return 0
}

build_apr() {
    log_message "configuring APR 1.7.5 (static, prefix ${APR_PREFIX})"
    (
        cd "${APR_SRC_DIR}" || exit 1
        CFLAGS="${APR_UTIL_OPTIMIZATION}" \
            ./configure --prefix="${APR_PREFIX}" --disable-shared --enable-static
    ) > "${APR_UTIL_STATE_DIR}/apr-configure.log" 2>&1 || {
        fail_message "APR configure failed, see ${APR_UTIL_STATE_DIR}/apr-configure.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-configure.log" >&2 || true
        return 30
    }

    log_message "building APR 1.7.5 with -j${APR_UTIL_BUILD_JOBS}"
    (
        cd "${APR_SRC_DIR}" || exit 1
        make -j "${APR_UTIL_BUILD_JOBS}"
    ) > "${APR_UTIL_STATE_DIR}/apr-build.log" 2>&1 || {
        fail_message "APR build failed, see ${APR_UTIL_STATE_DIR}/apr-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-build.log" >&2 || true
        return 30
    }
    (
        cd "${APR_SRC_DIR}" || exit 1
        make install
    ) > "${APR_UTIL_STATE_DIR}/apr-install.log" 2>&1 || {
        fail_message "APR install failed, see ${APR_UTIL_STATE_DIR}/apr-install.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-install.log" >&2 || true
        return 30
    }
    if [[ ! -f "${APR_PREFIX}/lib/libapr-1.a" || ! -x "${APR_PREFIX}/bin/apr-1-config" ]]; then
        fail_message "APR static library or apr-1-config was not installed under ${APR_PREFIX}"
        return 30
    fi
    return 0
}

build_apr_util_library() {
    log_message "configuring APR-util 1.6.5 against ${APR_PREFIX}"
    (
        cd "${APR_UTIL_SRC_DIR}" || exit 1
        CFLAGS="${APR_UTIL_OPTIMIZATION}" \
            ./configure --prefix="${APR_PREFIX}" --with-apr="${APR_PREFIX}" \
            "${APR_UTIL_CONFIGURE_OPTIONS[@]}"
    ) > "${APR_UTIL_STATE_DIR}/apr-util-configure.log" 2>&1 || {
        fail_message "APR-util configure failed, see ${APR_UTIL_STATE_DIR}/apr-util-configure.log"
        tail -50 "${APR_UTIL_STATE_DIR}/apr-util-configure.log" >&2 || true
        return 30
    }

    log_message "building APR-util 1.6.5 with -j${APR_UTIL_BUILD_JOBS}"
    (
        cd "${APR_UTIL_SRC_DIR}" || exit 1
        make -j "${APR_UTIL_BUILD_JOBS}"
    ) > "${APR_UTIL_STATE_DIR}/apr-util-build.log" 2>&1 || {
        fail_message "APR-util build failed, see ${APR_UTIL_STATE_DIR}/apr-util-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-util-build.log" >&2 || true
        return 30
    }
    (
        cd "${APR_UTIL_SRC_DIR}" || exit 1
        make install
    ) > "${APR_UTIL_STATE_DIR}/apr-util-install.log" 2>&1 || {
        fail_message "APR-util install failed, see ${APR_UTIL_STATE_DIR}/apr-util-install.log"
        tail -40 "${APR_UTIL_STATE_DIR}/apr-util-install.log" >&2 || true
        return 30
    }
    if [[ ! -f "${APR_PREFIX}/lib/libaprutil-1.a" || ! -f "${APR_PREFIX}/include/apr-1/apr_base64.h" ]]; then
        fail_message "APR-util static library or headers were not installed under ${APR_PREFIX}"
        return 30
    fi
    return 0
}

build_upstream_testall() {
    log_message "building the upstream portable test program (test/testall)"
    (
        cd "${APR_UTIL_SRC_DIR}/test" || exit 1
        make testall
    ) > "${APR_UTIL_STATE_DIR}/testall-build.log" 2>&1 || {
        fail_message "test/testall build failed, see ${APR_UTIL_STATE_DIR}/testall-build.log"
        tail -40 "${APR_UTIL_STATE_DIR}/testall-build.log" >&2 || true
        return 30
    }
    if [[ ! -x "${APR_UTIL_TESTALL_BIN}" ]]; then
        fail_message "the upstream testall binary was not produced: ${APR_UTIL_TESTALL_BIN}"
        return 30
    fi
    return 0
}

build_base64_harness() {
    mkdir -p "${PERF_WORK_DIR}/apr-util-bench" || return 30
    log_message "compiling the base64 benchmark harness"
    (
        cd "${CASE_DIR}" || exit 1
        cc ${APR_UTIL_HARNESS_CFLAGS} \
            -I "${APR_PREFIX}/include/apr-1" \
            bench/base64_bench.c \
            -L "${APR_PREFIX}/lib" -laprutil-1 -lapr-1 -lm -lpthread -ldl \
            -o "${APR_UTIL_BENCH_BIN}"
    ) > "${APR_UTIL_STATE_DIR}/harness-base64.log" 2>&1 || {
        fail_message "failed to compile bench/base64_bench.c, see ${APR_UTIL_STATE_DIR}/harness-base64.log"
        tail -30 "${APR_UTIL_STATE_DIR}/harness-base64.log" >&2 || true
        return 30
    }

    log_message "compiling the offline network-namespace launcher"
    (
        cd "${CASE_DIR}" || exit 1
        cc ${APR_UTIL_HARNESS_CFLAGS} \
            bench/netns_loopback_up.c \
            -o "${APR_UTIL_NETNS_PREP}"
    ) > "${APR_UTIL_STATE_DIR}/harness-netns.log" 2>&1 || {
        fail_message "failed to compile bench/netns_loopback_up.c, see ${APR_UTIL_STATE_DIR}/harness-netns.log"
        return 30
    }
    if [[ ! -x "${APR_UTIL_BENCH_BIN}" || ! -x "${APR_UTIL_NETNS_PREP}" ]]; then
        fail_message "benchmark harness binaries are missing after the build"
        return 30
    fi
    return 0
}

verify_versions() {
    local reported
    reported="$("${APR_UTIL_BENCH_BIN}" --version 2>/dev/null || true)"
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
EOF
}

build_apr_util_base() {
    require_commands || return $?

    log_message "fetching pinned APR ${APR_SOURCE_NAME##*/} and APR-util ${APR_UTIL_SOURCE_NAME##*/}"
    fetch_sources || return $?

    extract_source_tree "${APR_SOURCE_ARCHIVE}" "${APR_SRC_DIR}" "apr-1.7.5" || return $?
    extract_source_tree "${APR_UTIL_SOURCE_ARCHIVE}" "${APR_UTIL_SRC_DIR}" "apr-util-1.6.5" || return $?
    if [[ ! -f "${APR_SRC_DIR}/configure" || ! -f "${APR_UTIL_SRC_DIR}/configure" ]]; then
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
