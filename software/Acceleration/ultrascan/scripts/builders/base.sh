#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The host only stages and verifies the pinned archive; unpacking happens inside
# the private container so the extracted tree is produced by the same image that
# later builds and runs hsbench.
extract_source_archive() {
    rm -rf "${SOURCE_DIR}"
    log "extracting $(basename "${SOURCE_ARCHIVE_LOCAL}") inside the private container"
    ultrascan_container_exec tar -C "${PERF_WORK_DIR}" -xzf "${SOURCE_ARCHIVE_LOCAL}" || {
        log "ERROR: failed to extract ${SOURCE_ARCHIVE_LOCAL} inside the container"
        return 30
    }
    local extracted="${PERF_WORK_DIR}/Ultrascan-${SOFTWARE_VERSION}"
    ultrascan_container_exec test -d "${extracted}" || {
        log "ERROR: source archive did not contain Ultrascan-${SOFTWARE_VERSION}"
        return 30
    }
    mv "${extracted}" "${SOURCE_DIR}" || return 30
}

fetch_source_from_archive() {
    local archive="$1"
    check_sha256 "${ULTRASCAN_SOURCE_ARCHIVE_SHA256}" "${archive}" \
        "Ultrascan ${SOFTWARE_VERSION} source archive" || return 30
    mkdir -p "$(dirname "${SOURCE_ARCHIVE_LOCAL}")" || return 30
    cp -f "${archive}" "${SOURCE_ARCHIVE_LOCAL}" || {
        log "ERROR: failed to stage ${archive} under ${PERF_WORK_DIR}"
        return 30
    }
    log "staged verified offline source archive ${archive}"
    extract_source_archive || return $?
}

fetch_source_from_git() {
    local attempted=()
    local url
    require_host_git || return 30
    for url in "${ULTRASCAN_GIT_URL}" ${ULTRASCAN_GIT_MIRRORS}; do
        attempted+=("${url}")
        [[ -n "${url}" ]] || continue
        log "cloning Ultrascan ${ULTRASCAN_GIT_TAG} from ${url}"
        rm -rf "${SOURCE_DIR}"
        if GIT_TERMINAL_PROMPT=0 git clone --depth 1 --branch "${ULTRASCAN_GIT_TAG}" \
            "${url}" "${SOURCE_DIR}" 2>&1; then
            local head
            head="$(git -C "${SOURCE_DIR}" rev-parse HEAD 2>/dev/null || true)"
            if [[ "${head}" == "${ULTRASCAN_GIT_COMMIT}" ]]; then
                ULTRASCAN_SOURCE_KIND="git_clone"
                ULTRASCAN_SOURCE_ORIGIN="${url}"
                return 0
            fi
            log "ERROR: ${url} produced commit ${head}, expected ${ULTRASCAN_GIT_COMMIT}"
        else
            log "WARNING: clone failed for ${url}"
        fi
        rm -rf "${SOURCE_DIR}"
    done
    log "ERROR: could not fetch Ultrascan ${ULTRASCAN_GIT_TAG}; attempted:"
    local attempted_url
    for attempted_url in "${attempted[@]}"; do
        log "  - ${attempted_url}"
    done
    return 30
}

require_host_git() {
    command -v git >/dev/null 2>&1 && return 0
    log "ERROR: git is required on the host only for the clone fallback when the offline archive is absent"
    return 30
}

verify_source_version() {
    local version major minor
    version="$(ultrascan_container_exec sed -n \
        's/^set *( *HS_PATCH_VERSION *\([0-9][0-9]*\)).*$/\1/p' \
        "${SOURCE_DIR}/CMakeLists.txt" | head -n 1)"
    major="$(ultrascan_container_exec sed -n 's/^set *( *HS_MAJOR_VERSION *\([0-9][0-9]*\)).*$/\1/p' \
        "${SOURCE_DIR}/CMakeLists.txt" | head -n 1)"
    minor="$(ultrascan_container_exec sed -n 's/^set *( *HS_MINOR_VERSION *\([0-9][0-9]*\)).*$/\1/p' \
        "${SOURCE_DIR}/CMakeLists.txt" | head -n 1)"
    [[ "${major}.${minor}.${version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: source tree declares version ${major}.${minor}.${version}, requested ${SOFTWARE_VERSION}"
        return 30
    }
    log "source tree declares Ultrascan ${major}.${minor}.${version} (${ULTRASCAN_SOURCE_KIND})"
}

fetch_source() {
    ULTRASCAN_SOURCE_KIND=""
    ULTRASCAN_SOURCE_ORIGIN=""
    if [[ -f "${ULTRASCAN_OFFLINE_DIR}/${ULTRASCAN_SOURCE_ARCHIVE}" ]]; then
        log "using offline source directory ${ULTRASCAN_OFFLINE_DIR}"
        fetch_source_from_archive "${ULTRASCAN_OFFLINE_DIR}/${ULTRASCAN_SOURCE_ARCHIVE}" || return $?
        ULTRASCAN_SOURCE_KIND="offline_archive"
        ULTRASCAN_SOURCE_ORIGIN="${ULTRASCAN_OFFLINE_DIR}/${ULTRASCAN_SOURCE_ARCHIVE}"
    else
        log "offline source archive is absent: ${ULTRASCAN_OFFLINE_DIR}/${ULTRASCAN_SOURCE_ARCHIVE}"
        fetch_source_from_git || return $?
    fi
    verify_source_version || return $?
}

apply_x86_build_fix() {
    ULTRASCAN_X86_FIX_APPLIED="false"
    ULTRASCAN_CMAKE_LISTS_SHA256=""
    if [[ "$(normalize_arch "$(uname -m)")" != "x86_64" ]]; then
        return 0
    fi
    log "applying the x86_64 Kunpeng-NEON build fix to the private source copy"
    python3 "${SCRIPT_DIR}/scripts/x86_build_fix.py" --source-dir "${SOURCE_DIR}" || {
        log "ERROR: failed to apply the x86_64 build fix"
        return 30
    }
    ULTRASCAN_X86_FIX_APPLIED="true"
    ULTRASCAN_CMAKE_LISTS_SHA256="$(sha256_of "${SOURCE_DIR}/CMakeLists.txt")"
}

# The measured binary is the documented Release hsbench build: one translation
# unit per source file, no DUMP_SUPPORT, no extra -march group.
build_hsbench() {
    local jobs
    jobs="$(resolve_build_jobs)" || return 30
    log "configuring Ultrascan ${SOFTWARE_VERSION} (Release, hsbench target, -j${jobs}) inside the private container"
    mkdir -p "${BUILD_DIR}"
    ultrascan_container_exec_at "${BUILD_DIR}" \
        cmake "${SOURCE_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CHIMERA=OFF || {
        log "ERROR: Ultrascan CMake configuration failed"
        return 30
    }
    ultrascan_container_exec_at "${BUILD_DIR}" \
        cmake --build . --target hsbench -j "${jobs}" || {
        log "ERROR: hsbench build failed"
        return 30
    }
    ultrascan_container_exec test -x "${HSBENCH_BIN}" || {
        log "ERROR: hsbench executable was not produced at ${HSBENCH_BIN}"
        return 30
    }
}

# The universal bytecode database comes from hsdump, which CMake only builds
# when DUMP_SUPPORT is enabled; that is the documented "build-debug" step, so it
# is a separate Debug configuration and never touches the measured Release tree.
build_hsdump() {
    local jobs
    jobs="$(resolve_build_jobs)" || return 30
    log "configuring Ultrascan ${SOFTWARE_VERSION} (Debug, hsdump target, dump support, -j${jobs}) inside the private container"
    mkdir -p "${DUMP_BUILD_DIR}"
    ultrascan_container_exec_at "${DUMP_BUILD_DIR}" \
        cmake "${SOURCE_DIR}" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CHIMERA=OFF || {
        log "ERROR: Ultrascan dump-tool CMake configuration failed"
        return 30
    }
    ultrascan_container_exec_at "${DUMP_BUILD_DIR}" \
        cmake --build . --target hsdump -j "${jobs}" || {
        log "ERROR: hsdump build failed"
        return 30
    }
    ultrascan_container_exec test -x "${HSDUMP_BIN}" || {
        log "ERROR: hsdump executable was not produced at ${HSDUMP_BIN}"
        return 30
    }
}

# hsdump writes the block-mode fat database that hsbench -U loads; the
# documentation names the file <output>/dump/db.raw.
generate_universal_db() {
    log "generating the universal bytecode database with hsdump inside the private container"
    rm -rf "${DUMP_OUTPUT_ROOT}"
    ultrascan_container_exec_at "${PERF_WORK_DIR}" \
        "${HSDUMP_BIN}" \
        -e "${SAMPLES_RULES}" \
        -N \
        -U \
        -o "${DUMP_OUTPUT_ROOT}" || {
        log "ERROR: hsdump failed to generate the universal bytecode database"
        return 30
    }
    ultrascan_container_exec test -f "${DUMP_DB}" || {
        log "ERROR: hsdump did not write ${DUMP_DB}"
        return 30
    }
    ULTRASCAN_DUMP_SHA256="$(ultrascan_container_exec sha256sum "${DUMP_DB}" | awk '{print $1}')"
    [[ -n "${ULTRASCAN_DUMP_SHA256}" ]] || {
        log "ERROR: cannot read the generated universal bytecode database"
        return 30
    }
    log "universal bytecode database ready: ${DUMP_DB} (sha256 ${ULTRASCAN_DUMP_SHA256:0:16}…)"
}

probe_runtime_version() {
    local output universal_output
    log "probing the built hsbench to read its runtime version inside the private container"
    # Pin the C locale so the smoke output is byte-identical on every runner;
    # some aarch64 runners otherwise print grouped digits ("3,116").
    output="$(ultrascan_container_exec env LC_ALL=C LANG=C TZ=UTC "${HSBENCH_BIN}" \
        -e "${SAMPLES_RULES}" -c "${SAMPLES_CORPUS}" -N -n 1 2>&1)" || {
        log "ERROR: the built hsbench failed its smoke scan"
        printf '%s\n' "${output}" >&2
        return 30
    }
    HSBENCH_ACTUAL_VERSION="$(printf '%s\n' "${output}" | sed -n \
        's/^Hyperscan info:.*Version: *\([0-9][0-9.]*\).*$/\1/p' | head -n 1)"
    [[ -n "${HSBENCH_ACTUAL_VERSION}" ]] || {
        log "ERROR: cannot read the runtime version from the built hsbench"
        printf '%s\n' "${output}" >&2
        return 30
    }
    [[ "${HSBENCH_ACTUAL_VERSION}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: built hsbench reports version ${HSBENCH_ACTUAL_VERSION}, requested ${SOFTWARE_VERSION}"
        return 30
    }
    universal_output="$(ultrascan_container_exec env LC_ALL=C LANG=C TZ=UTC "${HSBENCH_BIN}" \
        -U "${DUMP_DB}" -c "${SAMPLES_CORPUS}" -N -n 1 2>&1)" || {
        log "ERROR: the built hsbench could not load the generated universal bytecode database"
        printf '%s\n' "${universal_output}" >&2
        return 30
    }
    printf '%s\n' "${universal_output}" | grep -q '^Loading FAT database from:' || {
        log "ERROR: hsbench -U did not report loading the universal bytecode database"
        printf '%s\n' "${universal_output}" >&2
        return 30
    }
    printf '%s\n' "${universal_output}" | grep -Eq '^Mean throughput \(overall\): [0-9.]+ Mbit/sec$' || {
        log "ERROR: the universal bytecode smoke run did not report Mean throughput"
        printf '%s\n' "${universal_output}" >&2
        return 30
    }
}

record_build_state() {
    local jobs compiler_version
    jobs="$(resolve_build_jobs)" || return 30
    compiler_version="$(ultrascan_container_exec c++ --version 2>/dev/null | head -n 1)"
    python3 - \
        "${BUILD_STATE_FILE}" \
        "${SOFTWARE_VERSION}" \
        "${HSBENCH_ACTUAL_VERSION}" \
        "$(normalize_arch "$(uname -m)")" \
        "${ULTRASCAN_SOURCE_KIND}" \
        "${ULTRASCAN_SOURCE_ORIGIN}" \
        "${ULTRASCAN_GIT_COMMIT}" \
        "${ULTRASCAN_X86_FIX_APPLIED}" \
        "${ULTRASCAN_CMAKE_LISTS_SHA256}" \
        "${jobs}" \
        "${compiler_version}" \
        "${HSBENCH_BIN}" \
        "${HSDUMP_BIN}" \
        "${DUMP_DB}" \
        "${ULTRASCAN_DUMP_SHA256}" \
        "${SAMPLES_ZIP_LOCAL}" \
        "${SAMPLES_ROOT}" \
        "${ULTRASCAN_SAMPLE_LITERALS_SHA256}" \
        "${ULTRASCAN_SAMPLE_GUTENBERG_SHA256}" <<'PY'
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

(
    path, requested, actual, arch, source_kind, source_origin, commit, x86_fix,
    cmake_sha, jobs, compiler, hsbench_bin, hsdump_bin, dump_db, dump_sha,
    samples_zip, samples_root, literals_sha, gutenberg_sha,
) = sys.argv[1:]


def sha256_file(target: Path) -> str:
    digest = hashlib.sha256()
    with target.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


payload = {
    "recorded_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "software": "ultrascan",
    "requested_version": requested,
    "actual_version": actual,
    "architecture": arch,
    "source": {
        "kind": source_kind,
        "origin": source_origin,
        "tag": "Ultrascan-v5.8.0",
        "commit": commit,
        "archive_sha256": (
            "b0ad7d0126585581e93f621d1295066e7becf6d59c2179916c74e84e67f29b9b"
        ),
    },
    "samples": {
        "package": "[Hyperscan] hsbench-samples",
        "zip": samples_zip,
        "zip_sha256": sha256_file(Path(samples_zip)),
        "root": samples_root,
        "rules": {
            "path": "pcre/snort_literals",
            "file": f"{samples_root}/pcre/snort_literals",
            "sha256": literals_sha,
        },
        "corpus": {
            "path": "corpora/gutenberg.db",
            "file": f"{samples_root}/corpora/gutenberg.db",
            "sha256": gutenberg_sha,
        },
    },
    "build": {
        "system": "cmake",
        "release": {
            "build_type": "Release",
            "target": "hsbench",
            "binary": hsbench_bin,
            "binary_sha256": sha256_file(Path(hsbench_bin)),
            "jobs": int(jobs),
            "examples": False,
            "chimera": False,
        },
        "dump": {
            "build_type": "Debug",
            "target": "hsdump",
            "binary": hsdump_bin,
            "binary_sha256": sha256_file(Path(hsdump_bin)),
            "dump_support": True,
            "jobs": int(jobs),
        },
    },
    "universal_bytecode": {
        "dump_db": dump_db,
        "sha256": dump_sha,
    },
    "x86_64_build_fix": {
        "applied": x86_fix == "true",
        "cmake_lists_sha256": cmake_sha or None,
    },
    "compiler": {"cxx": compiler},
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    [[ -f "${BUILD_STATE_FILE}" ]] || {
        log "ERROR: failed to write the build state file"
        return 30
    }
}

build_ultrascan_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "5.8.0" ]] || {
        log "ERROR: this case supports only Ultrascan 5.8.0, requested ${SOFTWARE_VERSION}"
        return 10
    }
    check_architecture || return $?
    require_commands || return $?
    verify_directory_is_clean "${SOURCE_DIR}" "${BUILD_DIR}" "${DUMP_BUILD_DIR}" \
        "${DUMP_OUTPUT_ROOT}" "${SAMPLES_ROOT}"

    fetch_source || return 30
    apply_x86_build_fix || return 30
    build_hsbench || return 30
    build_hsdump || return 30
    prepare_samples_inputs || return 30
    generate_universal_db || return 30
    probe_runtime_version || return 30
    record_build_state || return 30

    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${HSBENCH_ACTUAL_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log "built Ultrascan ${HSBENCH_ACTUAL_VERSION}; hsbench is ready at ${HSBENCH_BIN}"
    log "universal bytecode database: ${DUMP_DB} (sha256 ${ULTRASCAN_DUMP_SHA256:0:16}…)"
    log "container image: $(ultrascan_container_exec sed -n 's/^PRETTY_NAME=//p' /etc/os-release | tr -d '\"')"
}
