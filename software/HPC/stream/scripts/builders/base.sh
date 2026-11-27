#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Fetch the pinned upstream archive: public offline directory, then this run's
# cache, then the two upstream endpoints (each candidate is checksum verified).
fetch_stream_archive() {
    local target="$1" candidate
    local -a local_candidates=("${STREAM_ARCHIVE_DIR}/${STREAM_ARCHIVE_NAME}")
    local -a url_candidates=("${STREAM_ARCHIVE_URL}" "${STREAM_ARCHIVE_MIRROR_URL}")
    if [[ -f "${target}" ]]; then
        log "reusing the pinned archive ${target}"
        printf '%s  %s\n' "${STREAM_ARCHIVE_SHA256}" "${target}" | sha256sum -c - >/dev/null || {
            log 'ERROR: cached STREAM archive checksum mismatch'
            return 30
        }
        return 0
    fi
    for candidate in "${local_candidates[@]}"; do
        [[ -f "${candidate}" ]] || continue
        log "copying the pinned archive from ${candidate}"
        cp -- "${candidate}" "${target}.part" || continue
        if printf '%s  %s\n' "${STREAM_ARCHIVE_SHA256}" "${target}.part" | sha256sum -c - >/dev/null; then
            mv -- "${target}.part" "${target}"
            return 0
        fi
        log "WARNING: checksum mismatch for ${candidate}; trying the next source"
        rm -f "${target}.part"
    done
    for candidate in "${url_candidates[@]}"; do
        log "downloading ${candidate}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 --max-time 600 \
            -o "${target}.part" "${candidate}" || continue
        if printf '%s  %s\n' "${STREAM_ARCHIVE_SHA256}" "${target}.part" | sha256sum -c - >/dev/null; then
            mv -- "${target}.part" "${target}"
            return 0
        fi
        log "WARNING: checksum mismatch for ${candidate}; trying the next source"
        rm -f "${target}.part"
    done
    log 'ERROR: no STREAM archive candidate passed the checksum check'
    return 30
}

build_stream_base() {
    local archive actual_version gcc_version
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == 5.10 ]] || { log 'ERROR: only STREAM 5.10 is supported'; return 10; }
    [[ "$(normalize_arch "$(uname -m)")" == "$(normalize_arch "${EXPECTED_ARCH}")" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    start_stream_vm || return $?
    verify_stream_guest_os || return $?
    capture_stream_vm_environment || return $?
    install_stream_guest_packages || return $?
    archive="${PERF_WORK_DIR}/${STREAM_ARCHIVE_NAME}"
    fetch_stream_archive "${archive}" || return $?
    log 'verifying the pinned source archive layout'
    tar -tzf "${archive}" | python3 "${SCRIPT_DIR}/scripts/results/verify_archive.py" || return 30
    vm_copy_in "${archive}" "/root/${STREAM_ARCHIVE_NAME}" || return 30
    vm_exec rm -rf "${GUEST_SOURCE_DIR}" || return 40
    vm_exec mkdir -p "${GUEST_SOURCE_DIR}" || return 40
    vm_exec tar -xzf "/root/${STREAM_ARCHIVE_NAME}" -C "${GUEST_SOURCE_DIR}" --strip-components=1 || return 40
    vm_exec test -f "${GUEST_SOURCE_DIR}/stream.c" || {
        log 'ERROR: stream.c is missing inside the reference VM'
        return 40
    }
    # The pinned source carries its revision in the leading "Revision: $Id: stream.c,v 5.10 ..." line.
    actual_version="$(vm_exec_shell "head -n 3 '${GUEST_SOURCE_DIR}/stream.c' | sed -n 's|.*,v \\([0-9][0-9.]*\\) .*|\\1|p' | head -n 1")"
    [[ -n "${actual_version}" ]] || {
        log 'ERROR: cannot determine the STREAM revision inside the reference VM'
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: requested ${SOFTWARE_VERSION}, source reports ${actual_version:-unknown}"
        return 40
    }
    log 'compiling the 200M-element STREAM binary inside the reference VM'
    compile_flags="-O3 -fopenmp -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${STREAM_NTIMES} -mcmodel=large"
    compile_extra=''
    if ! vm_exec_shell "cd '${GUEST_SOURCE_DIR}' && gcc ${compile_flags} stream.c -o '${GUEST_BINARY}'"; then
        # aarch64 + GCC 12 cannot place libgcc's outline-atomics helpers next to a
        # 4.8 GiB .bss (`relocation truncated to fit: R_AARCH64_ADR_PREL_PG_HI21`),
        # so the exact upstream command fails to link there.  Disabling the
        # outline-atomics helpers keeps the build flags and the workload identical.
        case "${EXPECTED_ARCH}" in
            aarch64|arm64) compile_extra='-mno-outline-atomics' ;;
            *)
                log 'ERROR: the STREAM binary did not compile inside the reference VM'
                return 40
                ;;
        esac
        log "WARNING: the upstream flags do not link on ${EXPECTED_ARCH} with GCC 12; retrying with ${compile_extra}"
        vm_exec_shell "cd '${GUEST_SOURCE_DIR}' && gcc ${compile_flags} ${compile_extra} stream.c -o '${GUEST_BINARY}'" || {
            log 'ERROR: the STREAM binary did not compile inside the reference VM'
            return 40
        }
    fi
    vm_exec test -x "${GUEST_BINARY}" || {
        log 'ERROR: the compiled STREAM binary is missing inside the reference VM'
        return 40
    }
    gcc_version="$(vm_exec gcc -dumpfullversion -dumpversion)"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf '# stream_version: %s\n' "${actual_version}"
        printf '# stream_revision: %s\n' "${STREAM_REVISION}"
        printf '# array_size: %s\n' "${STREAM_ARRAY_SIZE}"
        printf '# ntimes: %s\n' "${STREAM_NTIMES}"
        printf '# compile_flags: %s\n' "${compile_flags}${compile_extra:+ ${compile_extra}}"
        printf '# compile_flags_upstream: %s\n' "${compile_flags}"
        printf '# compile_extra_flags: %s\n' "${compile_extra:-none}"
        printf '# guest_gcc: %s\n' "${gcc_version}"
        printf '# guest_toolchain_install_attempt: %s\n' "${STREAM_GUEST_TOOLCHAIN_ATTEMPT:-1}"
        printf '# guest_toolchain_source: %s\n' "${STREAM_GUEST_TOOLCHAIN_SOURCE:-dnf}"
        printf '# guest_binary_sha256: %s\n' "$(vm_exec sha256sum "${GUEST_BINARY}" | awk '{print $1}')"
        printf '# guest_binary_size: %s\n' "$(vm_exec stat -c %s "${GUEST_BINARY}")"
    } > "${RESULTS_DIR}/build-info.txt"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "STREAM ${actual_version} built inside the reference VM (gcc ${gcc_version}, ${STREAM_ARRAY_SIZE} elements, NTIMES=${STREAM_NTIMES})"
}
