#!/usr/bin/env bash
# Shared helpers for the Toolchain interpreters (Perl/Ruby/R/Erlang) cases.

log_message() {
    printf '[%s] [%s] %s\n' "ruby" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
    log_message "ERROR: $*"
    return 1
}

require_commands() {
    local missing=()
    local command_name
    for command_name in "$@"; do
        command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
    done
    if [[ "${#missing[@]}" -eq 0 ]]; then
        return 0
    fi
    log_message "installing missing build prerequisites: ${missing[*]}"
    # Prefer apt on Debian/Ubuntu even when a dnf compatibility shim exists in
    # PATH (local WSL probes install `dnf` as an apt wrapper); the package names
    # of the two families are not interchangeable.
    if [[ -f /etc/debian_version ]] && [[ "${#BENCH_BUILD_DEPS_APT[@]}" -gt 0 ]] && command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${BENCH_BUILD_DEPS_APT[@]}" || {
            log_message "ERROR: apt-get install failed for ${BENCH_BUILD_DEPS_APT[*]}"
            return 30
        }
    else
        log_message "ERROR: mandatory build commands are missing and no supported package manager was found: ${missing[*]}"
        return 30
    fi
    for command_name in "$@"; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: build command is still missing after dependency installation: ${command_name}"
            return 30
        }
    done
}

require_build_tools() {
    require_commands gcc make tar curl sha256sum awk sed grep find sort wc stat /usr/bin/time ${BENCH_EXTRA_TOOLS[@]} || return $?
    /usr/bin/time -f '%M' true >/dev/null 2>&1 || {
        log_message "ERROR: /usr/bin/time does not support GNU -f %M"
        return 30
    }
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
    mkdir -p "${destination}"
    case "${archive}" in
        *.tar.gz|*.tgz) tar -xzf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.tar.bz2|*.tbz2) tar -xjf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.tar.xz) tar -xJf "${archive}" -C "${destination}" --strip-components="${strip_components}" ;;
        *.zip) unzip -q "${archive}" -d "${destination}" ;;
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
