#!/usr/bin/env bash
# Base build: verify the pinned CPython / scikit-learn archives and wheels on the
# host, then extract, compile CPython, create the private virtual environment,
# install the hash-locked wheels and prefetch every asv scenario inside this
# task's private openEuler container.  The host keeps only Docker, the
# download/verification tooling, the framework and the strict parser.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

BUILD_STARTED_EPOCH=0

# ---------------------------------------------------------------------------
# Container preparation: the compiler, the -devel headers, GNU time and python3
# are installed inside the private container; the host only needs curl/tar.
# ---------------------------------------------------------------------------
prepare_sklearn_build_container() {
    local -a dnf_options=()
    local cmd
    require_scikit_learn_docker || return 30
    start_scikit_learn_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing CPython and scikit-learn build dependencies inside the private container'
    scikit_learn_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar gzip xz curl coreutils findutils diffutils \
        pkgconf-pkg-config file time python3 \
        zlib-devel libffi-devel openssl-devel bzip2-devel xz-devel \
        sqlite-devel ncurses-devel readline-devel || {
        log_message 'ERROR: container build dependencies failed'
        return 30
    }
    for cmd in gcc g++ make /usr/bin/time python3; do
        scikit_learn_container_exec sh -c "command -v ${cmd} >/dev/null 2>&1" || {
            log_message "ERROR: required container command is still unavailable: ${cmd}"
            return 30
        }
    done
    log_message 'CPython build dependencies are ready inside the private container'
}

# Container-side header probe: every header that CPython links against must be
# usable by the in-container compiler.
missing_headers() {
    local header missing=()
    for header in zlib.h ffi.h openssl/ssl.h bzlib.h lzma.h; do
        if ! scikit_learn_container_exec sh -c \
            "printf '#include <${header}>\\n' | gcc -E -x c - >/dev/null 2>&1"; then
            missing+=("${header}")
        fi
    done
    printf '%s\n' "${missing[*]}"
}

require_build_dependencies() {
    prepare_sklearn_build_container || return $?
    local headers
    headers="$(missing_headers)"
    if [[ -n "${headers}" ]]; then
        log_message "ERROR: CPython build headers are still unavailable inside the container: ${headers}"
        return 30
    fi
    log_message 'all CPython build headers are present inside the private container'
}

# ---------------------------------------------------------------------------
# Host-side asset acquisition (download + SHA-256 verification only).
# ---------------------------------------------------------------------------
verify_sha256() {
    local path="$1" expected="$2" actual
    actual="$(sha256sum "${path}" | cut -d' ' -f1)"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: SHA-256 mismatch for ${path}: got ${actual}, expected ${expected}"
        return 30
    fi
}

copy_from_offline_dir() {
    local name="$1" target="$2" candidate
    candidate="${SKLEARN_OFFLINE_DIR}/${name}"
    if [[ ! -s "${candidate}" ]]; then
        return 1
    fi
    log_message "using offline artifact from the runner: ${candidate}"
    cp -f "${candidate}" "${target}" || return 30
}

acquire_python_source() {
    local tarball="${PERF_WORK_DIR}/${PYTHON_TARBALL}"
    local url attempt=0
    if copy_from_offline_dir "${PYTHON_TARBALL}" "${tarball}"; then
        :
    else
        for url in "${PYTHON_URLS[@]}"; do
            attempt=$((attempt + 1))
            log_message "downloading CPython ${PYTHON_VERSION} (attempt ${attempt}): ${url}"
            if curl -fSL --retry 3 --retry-delay 5 --connect-timeout 30 \
                --max-time 900 -o "${tarball}.part" "${url}"; then
                mv -f "${tarball}.part" "${tarball}"
                break
            fi
            rm -f "${tarball}.part"
            log_message "download failed: ${url}"
        done
        if [[ ! -s "${tarball}" ]]; then
            log_message "ERROR: failed to download CPython ${PYTHON_VERSION}; attempted sources:"
            for url in "${PYTHON_URLS[@]}"; do
                log_message "  ${url}"
            done
            return 30
        fi
    fi
    verify_sha256 "${tarball}" "${PYTHON_SHA256}" || return $?
    local bytes
    bytes="$(stat -c '%s' "${tarball}")"
    if [[ "${bytes}" != "${PYTHON_BYTES}" ]]; then
        log_message "ERROR: unexpected CPython source size ${bytes}, expected ${PYTHON_BYTES}"
        return 30
    fi
    log_message "CPython source verified (sha256 ${PYTHON_SHA256}, ${bytes} bytes)"
}

# ---------------------------------------------------------------------------
# Container-side CPython build, virtual environment and wheel installation.
# ---------------------------------------------------------------------------
build_python_runtime() {
    local configure_seconds=0 make_seconds=0 install_seconds=0
    mkdir -p "${SOURCE_DIR}" "${PY_BUILD_DIR}" "${RESULTS_DIR}/build"
    log_message "extracting CPython ${PYTHON_VERSION} source inside the private container"
    scikit_learn_container_exec tar -xzf "${PERF_WORK_DIR}/${PYTHON_TARBALL}" -C "${SOURCE_DIR}" || {
        log_message "ERROR: failed to extract ${PYTHON_TARBALL}"
        return 30
    }
    scikit_learn_container_exec test -x "${PY_SRC_DIR}/configure" || {
        log_message "ERROR: CPython source tree is incomplete: ${PY_SRC_DIR}"
        return 30
    }

    log_message "configuring CPython ${PYTHON_VERSION} with ${PYTHON_CONFIGURE_OPTIONS[*]} (jobs=${BUILD_JOBS}) inside the private container"
    local started started_seconds
    started="$(date +%s)"
    scikit_learn_container_exec_at "${PY_BUILD_DIR}" \
        "${PY_SRC_DIR}/configure" --prefix="${PY_INSTALL_DIR}" "${PYTHON_CONFIGURE_OPTIONS[@]}" \
        > "${RESULTS_DIR}/build/cpython-configure.log" 2>&1 || {
        log_message "ERROR: CPython configure failed, see build/cpython-configure.log"
        tail -40 "${RESULTS_DIR}/build/cpython-configure.log" || true
        return 30
    }
    started_seconds="$(date +%s)"
    configure_seconds=$((started_seconds - started))

    log_message "building CPython ${PYTHON_VERSION} with make -j${BUILD_JOBS} inside the private container"
    scikit_learn_container_exec_at "${PY_BUILD_DIR}" make -j"${BUILD_JOBS}" \
        > "${RESULTS_DIR}/build/cpython-make.log" 2>&1 || {
        log_message "ERROR: CPython make failed, see build/cpython-make.log"
        tail -40 "${RESULTS_DIR}/build/cpython-make.log" || true
        return 30
    }
    make_seconds=$(( $(date +%s) - started_seconds ))

    started_seconds="$(date +%s)"
    scikit_learn_container_exec_at "${PY_BUILD_DIR}" make install \
        > "${RESULTS_DIR}/build/cpython-install.log" 2>&1 || {
        log_message "ERROR: CPython make install failed, see build/cpython-install.log"
        tail -40 "${RESULTS_DIR}/build/cpython-install.log" || true
        return 30
    }
    install_seconds=$(( $(date +%s) - started_seconds ))

    scikit_learn_container_exec test -x "${PYTHON_BIN}" || {
        log_message "ERROR: built CPython interpreter is missing: ${PYTHON_BIN}"
        return 30
    }
    local reported
    reported="$(scikit_learn_container_exec "${PYTHON_BIN}" -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])')" || {
        log_message "ERROR: built CPython cannot report its version"
        return 30
    }
    if [[ "${reported}" != "${PYTHON_VERSION}" ]]; then
        log_message "ERROR: built CPython reports ${reported}, expected ${PYTHON_VERSION}"
        return 30
    fi
    scikit_learn_container_exec "${PYTHON_BIN}" -c \
        'import zlib, ssl, ctypes, bz2, lzma, sqlite3, venv, ensurepip' || {
        log_message "ERROR: built CPython is missing required standard library modules"
        return 30
    }
    scikit_learn_container_exec "${PYTHON_BIN}" -m pip --version >/dev/null 2>&1 || {
        log_message "ERROR: built CPython has no usable pip"
        return 30
    }
    CPYTHON_CONFIGURE_SECONDS="${configure_seconds}"
    CPYTHON_MAKE_SECONDS="${make_seconds}"
    CPYTHON_INSTALL_SECONDS="${install_seconds}"
    log_message "CPython ${PYTHON_VERSION} built inside the container (configure ${configure_seconds}s, make ${make_seconds}s, install ${install_seconds}s)"
}

create_venv() {
    local started
    started="$(date +%s)"
    log_message "creating the private virtual environment inside the container"
    scikit_learn_container_exec "${PYTHON_BIN}" -m venv "${VENV_DIR}" || {
        log_message "ERROR: failed to create the virtual environment"
        return 30
    }
    if ! scikit_learn_container_exec "${VENV_PY}" -m pip --version >/dev/null 2>&1; then
        log_message "virtual environment has no pip yet, bootstrapping with ensurepip"
        scikit_learn_container_exec "${VENV_PY}" -m ensurepip --upgrade --default-pip || {
            log_message "ERROR: ensurepip failed inside the virtual environment"
            return 30
        }
    fi
    scikit_learn_container_exec "${VENV_PY}" -m pip --version || {
        log_message "ERROR: the virtual environment has no usable pip"
        return 30
    }
    VENV_SECONDS=$(( $(date +%s) - started ))
    log_message "private virtual environment ready (${VENV_SECONDS}s)"
}

wheelhouse_has_platform_wheels() {
    local wheel name normalized base found arch
    arch="$(normalize_architecture "$(uname -m)")"
    for name in "${SKLEARN_WHEELS[@]}"; do
        normalized="${name%%==*}"
        normalized="${normalized//-/_}"
        found=0
        for wheel in "${WHEELHOUSE}"/*.whl; do
            [[ -e "${wheel}" ]] || continue
            base="$(basename "${wheel}")"
            if [[ "${base}" != "${normalized}"-* ]]; then
                continue
            fi
            # Pure Python wheels serve every architecture; binary wheels must
            # match the runner architecture.
            if [[ "${base}" == *"-none-any.whl" ]] || [[ "${base}" == *"${arch}"* ]]; then
                found=1
                break
            fi
        done
        if [[ "${found}" -eq 0 ]]; then
            log_message "the wheelhouse has no usable wheel for ${name} on ${arch}"
            return 1
        fi
    done
}

copy_offline_wheels() {
    local offline_wheels="${SKLEARN_OFFLINE_DIR}/${SKLEARN_OFFLINE_WHEELS_SUBDIR}"
    local wheel copied=0
    if [[ ! -d "${offline_wheels}" ]]; then
        return 1
    fi
    for wheel in "${offline_wheels}"/*.whl; do
        [[ -e "${wheel}" ]] || continue
        cp -f "${wheel}" "${WHEELHOUSE}/" || return 30
        copied=$((copied + 1))
    done
    if [[ "${copied}" -gt 0 ]]; then
        log_message "copied ${copied} wheels from the runner offline directory ${offline_wheels}"
    fi
    wheelhouse_has_platform_wheels
}

download_wheels() {
    local index host url attempt=0
    for index in "${SKLEARN_PIP_INDEXES[@]}"; do
        attempt=$((attempt + 1))
        host="${index#https://}"
        host="${host%%/*}"
        log_message "downloading pinned wheels (attempt ${attempt}): ${index}"
        if scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
            timeout 300 "${VENV_PY}" -m pip download \
            --dest "${WHEELHOUSE}" \
            --only-binary=:all: \
            --no-deps \
            --disable-pip-version-check \
            --index-url "${index}" \
            --trusted-host "${host}" \
            --retries 3 --timeout 60 \
            "${SKLEARN_WHEELS[@]}" >> "${RESULTS_DIR}/build/pip-download.log" 2>&1; then
            if wheelhouse_has_platform_wheels; then
                return 0
            fi
            log_message "mirror ${index} did not provide every pinned wheel"
        else
            log_message "pip download failed for ${index}"
        fi
    done
    log_message "ERROR: failed to obtain every pinned wheel; attempted indexes:"
    for url in "${SKLEARN_PIP_INDEXES[@]}"; do
        log_message "  ${url}"
    done
    return 30
}

install_runtime() {
    local started
    mkdir -p "${WHEELHOUSE}"
    if copy_offline_wheels 2>/dev/null; then
        log_message "offline wheelhouse is complete for $(normalize_architecture "$(uname -m)")"
    else
        log_message "offline wheelhouse is incomplete, falling back to the pip mirrors"
        download_wheels || return $?
    fi
    started="$(date +%s)"
    log_message "installing the hash-locked runtime into the private virtual environment inside the container"
    scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
        "${VENV_PY}" -m pip install \
        --no-index \
        --find-links "${WHEELHOUSE}" \
        --require-hashes \
        --disable-pip-version-check \
        --no-warn-script-location \
        -r "${SKLEARN_REQUIREMENTS_LOCK}" > "${RESULTS_DIR}/build/pip-install.log" 2>&1 || {
        log_message "ERROR: hash-locked wheel install failed, see build/pip-install.log"
        tail -40 "${RESULTS_DIR}/build/pip-install.log" || true
        return 30
    }
    RUNTIME_INSTALL_SECONDS=$(( $(date +%s) - started ))
    local actual
    actual="$(scikit_learn_container_exec "${VENV_PY}" -c 'import sklearn; print(sklearn.__version__)')" || {
        log_message "ERROR: cannot import scikit-learn from the private virtual environment"
        return 30
    }
    if [[ "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: private virtual environment reports scikit-learn ${actual}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}" || return $?
    log_message "scikit-learn ${actual} installed inside the container (${RUNTIME_INSTALL_SECONDS}s)"
}

acquire_source_distribution() {
    local target="${PERF_WORK_DIR}/${SKLEARN_SDIST}"
    local url
    if copy_from_offline_dir "${SKLEARN_SDIST}" "${target}"; then
        :
    else
        for url in "${SKLEARN_SDIST_URLS[@]}"; do
            log_message "downloading scikit-learn ${SOFTWARE_VERSION} source archive: ${url}"
            if curl -fSL --retry 3 --retry-delay 5 --connect-timeout 30 \
                --max-time 600 -o "${target}.part" "${url}"; then
                mv -f "${target}.part" "${target}"
                break
            fi
            rm -f "${target}.part"
            log_message "download failed: ${url}"
        done
        if [[ ! -s "${target}" ]]; then
            log_message "source archive download failed, retrying through the pip mirror inside the container"
            scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
                "${VENV_PY}" -m pip download \
                --dest "${PERF_WORK_DIR}" \
                --no-binary=:all: \
                --no-deps \
                --disable-pip-version-check \
                --index-url "${SKLEARN_PIP_INDEXES[0]}" \
                "scikit-learn==${SOFTWARE_VERSION}" \
                > "${RESULTS_DIR}/build/pip-sdist.log" 2>&1 || {
                log_message "ERROR: failed to obtain the scikit-learn ${SOFTWARE_VERSION} source archive"
                return 30
            }
        fi
    fi
    [[ -s "${target}" ]] || {
        log_message "ERROR: source archive is missing: ${target}"
        return 30
    }
    verify_sha256 "${target}" "${SKLEARN_SDIST_SHA256}" || return $?
    local bytes
    bytes="$(stat -c '%s' "${target}")"
    if [[ "${bytes}" != "${SKLEARN_SDIST_BYTES}" ]]; then
        log_message "ERROR: unexpected source archive size ${bytes}, expected ${SKLEARN_SDIST_BYTES}"
        return 30
    fi
    log_message "scikit-learn ${SOFTWARE_VERSION} source archive verified (${bytes} bytes)"
}

prepare_asv_suite() {
    log_message "verifying the vendored upstream asv benchmark snapshot inside the container"
    scikit_learn_container_exec_at "${SCRIPT_DIR}/asv_benchmarks" \
        sha256sum --quiet -c manifest.sha256 || {
        log_message "ERROR: vendored asv benchmark files do not match manifest.sha256"
        return 30
    }
    rm -rf "${ASV_DIR}"
    mkdir -p "${ASV_DIR}"
    scikit_learn_container_exec sh -c \
        "cp -a '${SCRIPT_DIR}/asv_benchmarks/.' '${ASV_DIR}/'" || {
        log_message "ERROR: failed to stage the vendored asv benchmark suite"
        return 30
    }
    log_message "upstream asv benchmark snapshot staged at ${ASV_DIR}"
}

prefetch_scenarios() {
    local scenario log_file started_seconds
    local total_started
    total_started="$(date +%s)"
    mkdir -p "${RESULTS_DIR}/build"
    # The prefetch imports numpy/scipy, so it must run under the same
    # pinned BLAS/OpenMP thread pools as the timed runs: on many-core
    # runners the default OpenBLAS thread count exceeds the prebuilt
    # NUM_THREADS limit and aborts the process.
    sklearn_measurement_env
    for scenario in "${SKLEARN_SCENARIOS[@]}"; do
        log_file="${RESULTS_DIR}/build/prefetch-${scenario}.log"
        log_message "prefetching scenario ${scenario} (cold-cache correctness gate) inside the container"
        started_seconds="$(date +%s)"
        if ! sklearn_container_exec_measured "${PERF_WORK_DIR}" \
            "${VENV_PY}" "${SCRIPT_DIR}/scripts/fixtures/asv_runner.py" \
            --mode prefetch \
            --scenario "${scenario}" \
            --scenarios "${SCENARIOS_FILE}" \
            --benchmarks-dir "${ASV_DIR}" > "${log_file}" 2>&1; then
            log_message "ERROR: prefetch failed for scenario ${scenario}, last log lines:"
            tail -40 "${log_file}" || true
            return 30
        fi
        log_message "scenario ${scenario} prefetched in $(( $(date +%s) - started_seconds ))s"
    done
    PREFETCH_SECONDS=$(( $(date +%s) - total_started ))
    log_message "all ${#SKLEARN_SCENARIOS[@]} scenarios prefetched (${PREFETCH_SECONDS}s)"
}

record_runtime_versions() {
    local script_path="${PERF_WORK_DIR}/build/record_runtime_versions.py"
    mkdir -p "$(dirname "${script_path}")"
    cat > "${script_path}" <<'PY'
import hashlib
import json
import platform
import sys
from importlib import metadata
from pathlib import Path

output_path = Path(sys.argv[1])
packages = ["numpy", "scipy", "scikit-learn", "joblib", "narwhals", "threadpoolctl"]
payload = {
    "python": platform.python_version(),
    "python_implementation": platform.python_implementation(),
    "machine": platform.machine(),
    "runtime": {name: metadata.version(name) for name in packages},
    "pip": metadata.version("pip"),
}
output_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print(json.dumps(payload, sort_keys=True))
PY
    scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
        "${VENV_PY}" "${script_path}" "${RUNTIME_VERSIONS_JSON}" || return 30
    [[ -s "${RUNTIME_VERSIONS_JSON}" ]] || {
        log_message "ERROR: failed to record the runtime versions"
        return 30
    }
}

record_build_variant() {
    local script_path="${PERF_WORK_DIR}/build/record_build_variant.py"
    mkdir -p "$(dirname "${script_path}")"
    cat > "${script_path}" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

(
    output_path,
    version,
    variant,
    python_version,
    python_sha256,
    build_jobs,
    configure_seconds,
    make_seconds,
    install_seconds,
    venv_seconds,
    runtime_install_seconds,
    prefetch_seconds,
    sdist_name,
    sdist_sha256,
    sdist_bytes,
    asv_tag,
    asv_commit,
    asv_repository,
    asv_suite,
    asv_profile,
    manifest_path,
    wheelhouse,
    runtime_versions_path,
    scenarios_csv,
) = sys.argv[1:]

manifest_sha = hashlib.sha256(Path(manifest_path).read_bytes()).hexdigest()
wheel_hashes = {
    wheel.name: hashlib.sha256(wheel.read_bytes()).hexdigest()
    for wheel in sorted(Path(wheelhouse).glob("*.whl"))
}
runtime = json.loads(Path(runtime_versions_path).read_text(encoding="utf-8"))
comments = (
    "# Hash-locked runtime for the scikit-learn benchmark case.",
    "# Every wheel is verified with --require-hashes against requirements.lock.",
)
payload = {
    "software": "scikit-learn",
    "requested_version": version,
    "actual_version": runtime["runtime"]["scikit-learn"],
    "variant": variant,
    "python": {
        "implementation": "CPython",
        "version": python_version,
        "source": "python.org official source archive",
        "source_sha256": python_sha256,
        "configure_options": ["--with-ensurepip=install"],
        "build_jobs": int(build_jobs),
        "build_seconds": {
            "configure": int(configure_seconds),
            "make": int(make_seconds),
            "install": int(install_seconds),
        },
    },
    "private_venv": {
        "created": True,
        "venv_seconds": int(venv_seconds),
        "wheel_install_seconds": int(runtime_install_seconds),
    },
    "runtime": runtime["runtime"],
    "runtime_wheels_sha256": wheel_hashes,
    "source_distribution": {
        "file": sdist_name,
        "sha256": sdist_sha256,
        "bytes": int(sdist_bytes),
        "notes": "provenance only: measurement uses the published wheel",
    },
    "asv_suite": {
        "repository": asv_repository,
        "tag": asv_tag,
        "tag_commit": asv_commit,
        "suite": asv_suite,
        "profile": asv_profile,
        "n_jobs": 1,
        "vendored_manifest": "asv_benchmarks/manifest.sha256",
        "vendored_manifest_sha256": manifest_sha,
    },
    "scenarios": [item for item in scenarios_csv.split(",") if item],
    "measurement_protocol": {
        "statistic": "median",
        "processes_per_sample": 1,
        "offline": True,
        "threads": {
            "OMP_NUM_THREADS": "1",
            "OPENBLAS_NUM_THREADS": "1",
            "MKL_NUM_THREADS": "1",
            "NUMEXPR_NUM_THREADS": "1",
        },
    },
    "prefetch_seconds": int(prefetch_seconds),
    "comments": list(comments),
}
Path(output_path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
    scikit_learn_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${script_path}" \
        "${RESULTS_DIR}/build_variant.json" \
        "${SOFTWARE_VERSION}" "${PERF_VARIANT}" "${PYTHON_VERSION}" \
        "${PYTHON_SHA256}" "${BUILD_JOBS}" "${CPYTHON_CONFIGURE_SECONDS:-0}" \
        "${CPYTHON_MAKE_SECONDS:-0}" "${CPYTHON_INSTALL_SECONDS:-0}" \
        "${VENV_SECONDS:-0}" "${RUNTIME_INSTALL_SECONDS:-0}" "${PREFETCH_SECONDS:-0}" \
        "${SKLEARN_SDIST}" "${SKLEARN_SDIST_SHA256}" "${SKLEARN_SDIST_BYTES}" \
        "${ASV_TAG}" "${ASV_TAG_COMMIT}" "${ASV_REPOSITORY}" "${ASV_SUITE}" \
        "${ASV_PROFILE}" "${MANIFEST_FILE}" "${WHEELHOUSE}" \
        "${RUNTIME_VERSIONS_JSON}" \
        "$(known_scenarios_csv)" || {
        log_message "ERROR: failed to write build_variant.json inside the container"
        return 30
    }
    [[ -s "${RESULTS_DIR}/build_variant.json" ]] || {
        log_message "ERROR: failed to write build_variant.json"
        return 30
    }

    # build_info.json is Framework-owned: it is written after this stage from
    # PERF_ACTUAL_VERSION_FILE, which install_runtime already populated.
}

build_scikit_learn_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    validate_reps || return $?
    BUILD_STARTED_EPOCH="$(date +%s)"
    if [[ -e "${SOURCE_DIR}" || -e "${VENV_DIR}" || -e "${ASV_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    require_build_dependencies || return $?
    GCC_VERSION_STRING="$(scikit_learn_container_exec gcc --version | head -n 1)"
    acquire_python_source || return $?
    build_python_runtime || return $?
    create_venv || return $?
    install_runtime || return $?
    acquire_source_distribution || return $?
    prepare_asv_suite || return $?
    prefetch_scenarios || return $?
    record_runtime_versions || return $?
    record_build_variant || return $?
    log_message "build finished in $(( $(date +%s) - BUILD_STARTED_EPOCH ))s inside the private container"
}
