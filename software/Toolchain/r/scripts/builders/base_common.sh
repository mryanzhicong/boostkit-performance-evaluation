#!/usr/bin/env bash
# Shared helpers for the Toolchain interpreters (Perl/Ruby/R/Erlang) cases.

log_message() {
    printf '[%s] [%s] %s\n' "r" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
    log_message "ERROR: $*"
    return 1
}

# Host-side prerequisites are limited to Docker plus the download/verification
# tools.  Compilers, Fortran, headless build dependencies and GNU time are
# installed into the private container instead of the runner.
require_host_transfer_commands() {
    local required=(curl sha256sum awk sed grep tail head) missing=() command_name
    for command_name in "${required[@]}"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            missing+=("${command_name}")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        log_message "ERROR: missing host download/verification commands: ${missing[*]}"
        return 30
    fi
    return 0
}

# Create the private container and install every build dependency there.  The
# container is created before the download so the build proves the private
# runtime is available even when all network fetches fail.
prepare_r_build_container() {
    local -a dnf_options=()
    # Weak dependencies can pull in scriptlets that call groupadd/useradd; the
    # container mounts /etc/passwd and /etc/group read-only, so those scriptlets
    # would fail and make dnf exit non-zero.  Install only hard dependencies.
    dnf_options+=("--setopt=install_weak_deps=False")
    local -a dnf_packages=(
        "${BENCH_BUILD_DEPS_DNF[@]}"
        time make tar gzip unzip which findutils sed gawk grep diffutils
        ca-certificates python3 perl texinfo
    )
    require_host_transfer_commands || return $?
    require_r_docker || return 30
    start_r_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the R build dependencies inside the private container"
    r_container_exec_root dnf "${dnf_options[@]}" install -y "${dnf_packages[@]}" || {
        log_message "ERROR: container build dependency installation failed"
        return 30
    }
    local required=(gcc g++ make gfortran tar python3 /usr/bin/time)
    local missing=() tool
    for tool in "${required[@]}"; do
        if [[ "${tool}" == /* ]]; then
            r_container_exec test -x "${tool}" || missing+=("${tool}")
        else
            r_container_exec sh -c "command -v ${tool} >/dev/null 2>&1" || missing+=("${tool}")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        log_message "ERROR: the private container is missing build tools: ${missing[*]}"
        return 30
    fi
    if ! r_container_exec /usr/bin/time -f '%M' true >/dev/null 2>&1; then
        log_message "ERROR: /usr/bin/time inside the container does not support GNU -f %M"
        return 30
    fi
    if ! r_container_exec test -f /usr/include/curl/curl.h && \
        ! r_container_exec test -f /usr/include/aarch64-linux-gnu/curl/curl.h && \
        ! r_container_exec test -f /usr/include/x86_64-linux-gnu/curl/curl.h; then
        log_message "ERROR: libcurl development files are missing inside the private container"
        return 30
    fi
    log_message "R build toolchain is ready inside the private container (gcc $( r_container_exec gcc -dumpversion 2>/dev/null || true ), $( r_container_exec gfortran --version 2>/dev/null | head -1 || true ))"
    return 0
}

verify_sha256() {
    local file="$1" expected="$2" label="$3"
    [[ -f "${file}" ]] || {
        log_message "ERROR: ${label} is missing: ${file}"
        return 30
    }
    local actual
    actual="$(sha256sum "${file}" | awk '{print $1}')" || return 30
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: ${label} SHA-256 mismatch: expected ${expected}, got ${actual}"
        return 30
    fi
    log_message "${label} SHA-256 verified: ${actual}"
}

materialize_asset() {
    local destination="$1" filename="$2" expected_sha256="$3"
    shift 3
    local offline_dir="$1"
    shift
    local urls=("$@")
    local candidate
    if [[ -f "${offline_dir}/${filename}" ]]; then
        if verify_sha256 "${offline_dir}/${filename}" "${expected_sha256}" "offline ${filename}"; then
            cp -f "${offline_dir}/${filename}" "${destination}/${filename}"
            log_message "using pre-placed offline asset: ${offline_dir}/${filename}"
            return 0
        fi
    fi
    mkdir -p "${offline_dir}" "${destination}"
    local url attempt
    for url in "${urls[@]}"; do
        log_message "downloading ${filename} from ${url}"
        attempt=1
        while [[ "${attempt}" -le 4 ]]; do
            if curl -fL --max-time 1800 --retry 2 --retry-delay 3 \
                --connect-timeout 30 -C - -o "${destination}/${filename}.part" "${url}"; then
                if verify_sha256 "${destination}/${filename}.part" "${expected_sha256}" "downloaded ${filename}"; then
                    move_partial_asset "${destination}" "${filename}"
                    cp -f "${destination}/${filename}" "${offline_dir}/${filename}" || true
                    return 0
                fi
            fi
            attempt=$((attempt + 1))
            sleep 3
        done
        rm -f "${destination}/${filename}.part"
    done
    log_message "ERROR: unable to obtain ${filename}; tried offline ${offline_dir} and URLs: ${urls[*]}"
    return 30
}

move_partial_asset() {
    local destination="$1" filename="$2"
    mv -f "${destination}/${filename}.part" "${destination}/${filename}"
}

extract_asset() {
    local archive="$1" destination="$2" strip_components="${3:-1}"
    r_container_exec mkdir -p "${destination}" || return 30
    case "${archive}" in
        *.tar.gz|*.tgz) r_container_exec tar -xzf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.tar.bz2|*.tbz2) r_container_exec tar -xjf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.tar.xz) r_container_exec tar -xJf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.zip) r_container_exec unzip -q "${archive}" -d "${destination}" ;;
        *)
            log_message "ERROR: unsupported source archive format: ${archive}"
            return 30
            ;;
    esac
}

record_actual_version() {
    local actual="$1" version_line="$2"
    actual="$(printf '%s' "${actual}" | head -1)"
    if [[ -z "${actual}" ]]; then
        log_message "ERROR: actual version output is empty"
        return 30
    fi
    if [[ "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested ${SOFTWARE_VERSION} but built ${actual}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    BENCH_VERSION_LINE="${version_line}"
    log_message "actual version verified: ${actual} (${version_line})"
}

build_variant_marker() {
    local variant="$1" config_json="$2"
    python3 - "${RESULTS_DIR}/build_variant.json" "${variant}" "${config_json}" <<'PY'
import json, sys
output, variant, config_json = sys.argv[1], sys.argv[2], sys.argv[3]
payload = {"variant": variant, "config": json.loads(config_json)}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
}
