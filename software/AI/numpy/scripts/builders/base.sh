#!/usr/bin/env bash
# ==============================================================================
# numpy 2.4.3 base (open-box) builder -- runs entirely inside the container.
# ==============================================================================
# Steps, in order:
#   1. install the toolchain and library packages from the openEuler mirror
#   2. download and sha256-verify the CPython 3.14.10 source archive
#   3. build (PGO) and install that CPython into the work directory
#   4. create the pinned measurement virtual environment
#   5. clone the pinned NumPy baseline commit, verify commit + tree, init the
#      submodules the meson build needs
#   6. build the NumPy wheel from that checkout and install it
#   7. stage the vendored aggregate ASV suite and verify its manifest
#   8. register the machine with ASV
# Every log lands in ${RESULTS_DIR}/build so a failed run is diagnosable without
# re-running the container.
set -euo pipefail

NUMPY_CONTAINER_PACKAGES=(
    # compiler and build tooling
    gcc gcc-c++ make binutils patch diffutils findutils which file
    # CPython 3.14 build dependencies
    zlib-devel libffi-devel openssl-devel bzip2-devel xz-devel sqlite-devel
    ncurses-devel readline-devel gdbm-devel libuuid-devel
    # NumPy build dependencies (BLAS/LAPACK through the system openblas)
    openblas-devel pkgconf-pkg-config
    # downloads, archives, TLS trust for pip
    git-core curl tar gzip ca-certificates coreutils
)

numpy_build_log_dir() {
    mkdir -p "${RESULTS_DIR}/build"
    printf '%s\n' "${RESULTS_DIR}/build"
}

numpy_install_container_packages() {
    local log
    log="$(numpy_build_log_dir)/dnf-install.log"
    log_message "installing container build packages (${#NUMPY_CONTAINER_PACKAGES[@]} packages)"
    # --setopt=tsflags=noscripts: the private container mounts /etc/passwd and
    # /etc/group read-only, so any transaction that pulls a package whose
    # scriptlet creates a service user fails (openEuler's `git` Requires:
    # systemd, and systemd's dbus-daemon %prein cannot run useradd here).  The
    # scriptlets only manage daemons and users we never use; the two things that
    # actually matter afterwards are done explicitly below: `ldconfig` for the
    # new shared libraries and a real compile/link check.
    numpy_container_exec_root dnf install -y --setopt=install_weak_deps=False \
        --setopt=keepcache=True --setopt=tsflags=noscripts \
        "${NUMPY_CONTAINER_PACKAGES[@]}" > "${log}" 2>&1 || {
        log_message "ERROR: dnf install failed, see build/dnf-install.log"
        tail -30 "${log}" || true
        return 30
    }
    numpy_container_exec_root ldconfig || {
        log_message "ERROR: ldconfig failed after the package install"
        return 30
    }
    numpy_container_exec bash -c \
        'command -v gcc >/dev/null && command -v g++ >/dev/null && command -v make >/dev/null && command -v git >/dev/null' || {
        log_message "ERROR: the container toolchain is incomplete after dnf install"
        return 30
    }
    numpy_container_exec gcc --version | head -n 1 || return 30
    numpy_container_exec git --version || return 30
    numpy_container_exec pkg-config --modversion openblas || {
        log_message "ERROR: openblas development files are not visible to pkg-config"
        return 30
    }
    # Compile *and link* against the freshly installed headers/libraries so a
    # skipped scriptlet cannot hide a broken toolchain.
    numpy_container_exec bash -c \
        'set -e; d=$(mktemp -d); printf "%s\n" "#include <cblas.h>" "int main(void) { return CblasRowMajor; }" > "$d/t.c"; cflags=$(pkg-config --cflags openblas); libs=$(pkg-config --libs openblas); gcc "$d/t.c" -o "$d/t" $cflags $libs; "$d/t" || true; rm -rf "$d"' || {
        log_message "ERROR: the container toolchain cannot compile and link against openblas"
        return 30
    }
    log_message "container toolchain is ready"
}

numpy_acquire_cpython_source() {
    local log url
    log="$(numpy_build_log_dir)/cpython-download.log"
    mkdir -p "${PY_SRC_DIR%/*}"
    if [ -s "${PERF_WORK_DIR}/cpython-source/${PYTHON_TARBALL}" ]; then
        log_message "reusing the already downloaded CPython archive"
    else
        : > "${log}"
        for url in "${PYTHON_URLS[@]}"; do
            log_message "downloading ${url}"
            if numpy_container_exec_at "${PERF_WORK_DIR}/cpython-source" \
                curl -fSL --retry 3 --connect-timeout 30 --max-time 900 \
                -o "${PYTHON_TARBALL}.part" "${url}" >> "${log}" 2>&1; then
                numpy_container_exec_at "${PERF_WORK_DIR}/cpython-source" \
                    mv -f "${PYTHON_TARBALL}.part" "${PYTHON_TARBALL}" || return 30
                break
            fi
            numpy_container_exec_at "${PERF_WORK_DIR}/cpython-source" \
                rm -f "${PYTHON_TARBALL}.part" || true
        done
    fi
    numpy_container_exec test -s "${PERF_WORK_DIR}/cpython-source/${PYTHON_TARBALL}" || {
        log_message "ERROR: could not download the CPython ${PYTHON_VERSION} source archive"
        return 30
    }
    local actual size
    actual="$(numpy_container_exec sha256sum "${PERF_WORK_DIR}/cpython-source/${PYTHON_TARBALL}" | cut -d' ' -f1)"
    size="$(numpy_container_exec stat -c '%s' "${PERF_WORK_DIR}/cpython-source/${PYTHON_TARBALL}")"
    if [ "${actual}" != "${PYTHON_SHA256}" ] || [ "${size}" != "${PYTHON_BYTES}" ]; then
        log_message "ERROR: CPython archive mismatch (sha256 ${actual}, ${size} bytes)"
        return 30
    fi
    log_message "CPython ${PYTHON_VERSION} archive verified (sha256 ${PYTHON_SHA256})"
    numpy_container_exec mkdir -p "${PY_SRC_DIR}" || return 30
    numpy_container_exec tar -xzf "${PERF_WORK_DIR}/cpython-source/${PYTHON_TARBALL}" \
        -C "${PY_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: cannot extract the CPython source archive"
        return 30
    }
}

numpy_build_cpython_runtime() {
    local log_dir configure_log make_log install_log started
    log_dir="$(numpy_build_log_dir)"
    configure_log="${log_dir}/cpython-configure.log"
    make_log="${log_dir}/cpython-make.log"
    install_log="${log_dir}/cpython-install.log"

    if numpy_container_exec test -x "${PYTHON_BIN}"; then
        local existing
        existing="$(numpy_container_python_version)"
        if [ "${existing}" = "${PYTHON_VERSION}" ]; then
            log_message "reusing the installed CPython ${PYTHON_VERSION}"
            return 0
        fi
        log_message "ERROR: installed CPython is ${existing}, expected ${PYTHON_VERSION}"
        return 30
    fi

    numpy_container_exec mkdir -p "${PY_BUILD_DIR}" || return 30
    log_message "configuring CPython ${PYTHON_VERSION} (${PYTHON_CONFIGURE_OPTIONS[*]})"
    started="$(date +%s)"
    numpy_container_exec_at "${PY_BUILD_DIR}" "${PY_SRC_DIR}/configure" \
        --prefix="${PY_INSTALL_DIR}" "${PYTHON_CONFIGURE_OPTIONS[@]}" > "${configure_log}" 2>&1 || {
        log_message "ERROR: CPython configure failed, see build/cpython-configure.log"
        tail -40 "${configure_log}" || true
        return 30
    }
    log_message "building CPython ${PYTHON_VERSION} with make -j${BUILD_JOBS} ($(( $(date +%s) - started ))s in configure)"
    numpy_container_exec_at "${PY_BUILD_DIR}" make -j"${BUILD_JOBS}" > "${make_log}" 2>&1 || {
        log_message "ERROR: CPython make failed, see build/cpython-make.log"
        tail -40 "${make_log}" || true
        return 30
    }
    numpy_container_exec_at "${PY_BUILD_DIR}" make install > "${install_log}" 2>&1 || {
        log_message "ERROR: CPython make install failed, see build/cpython-install.log"
        tail -40 "${install_log}" || true
        return 30
    }
    local reported
    reported="$(numpy_container_python_version)" || return 30
    if [ "${reported}" != "${PYTHON_VERSION}" ]; then
        log_message "ERROR: built CPython reports ${reported}, expected ${PYTHON_VERSION}"
        return 30
    fi
    numpy_container_exec "${PYTHON_BIN}" -c \
        'import zlib, ssl, ctypes, bz2, lzma, sqlite3, venv, ensurepip' || {
        log_message "ERROR: built CPython is missing required standard library modules"
        return 30
    }
    log_message "CPython ${PYTHON_VERSION} built and installed ($(( $(date +%s) - started ))s total)"
}

numpy_create_measurement_venv() {
    local log index host installed
    log="$(numpy_build_log_dir)/pip-install.log"
    if ! numpy_container_exec test -x "${VENV_PY}"; then
        log_message "creating the measurement virtual environment"
        numpy_container_exec "${PYTHON_BIN}" -m venv "${VENV_DIR}" || {
            log_message "ERROR: cannot create the measurement virtual environment"
            return 30
        }
    fi
    if numpy_container_exec "${VENV_PY}" -m pip --version >/dev/null 2>&1; then
        :
    else
        numpy_container_exec "${VENV_PY}" -m ensurepip --upgrade --default-pip || {
            log_message "ERROR: ensurepip failed inside the measurement virtual environment"
            return 30
        }
    fi
    : > "${log}"
    installed=0
    for index in "${NUMPY_PIP_INDEXES[@]}"; do
        host="$(printf '%s\n' "${index}" | sed -E 's#^https?://([^/]+)/.*#\1#')"
        log_message "installing the pinned measurement wheels from ${host}"
        if numpy_container_exec "${VENV_PY}" -m pip install --no-cache-dir \
            --retries 3 --timeout 60 --index-url "${index}" --trusted-host "${host}" \
            -r "${NUMPY_REQUIREMENTS_LOCK}" >> "${log}" 2>&1; then
            installed=1
            break
        fi
    done
    if [ "${installed}" -ne 1 ]; then
        log_message "ERROR: could not install the pinned measurement wheels, see build/pip-install.log"
        tail -30 "${log}" || true
        return 30
    fi
    local asv_version
    asv_version="$(numpy_container_exec "${ASV_BIN}" --version 2>&1 | tail -n 1 | awk '{print $NF}')"
    if [ "${asv_version}" != "${ASV_VERSION}" ]; then
        log_message "ERROR: asv reports '${asv_version}', expected ${ASV_VERSION}"
        return 30
    fi
    log_message "measurement virtual environment is ready (asv ${asv_version})"
}

numpy_clone_baseline() {
    local log
    log="$(numpy_build_log_dir)/git-clone.log"
    if numpy_container_exec test -d "${NUMPY_REPO_DIR}/.git"; then
        log_message "reusing the existing NumPy checkout"
    else
        log_message "cloning the NumPy baseline repository (commit ${NUMPY_BASELINE_COMMIT:0:12})"
        numpy_container_exec mkdir -p "${SOURCE_DIR}" || return 30
        numpy_container_exec git clone --no-checkout \
            "${NUMPY_REPOSITORY}" "${NUMPY_REPO_DIR}" > "${log}" 2>&1 || {
            log_message "ERROR: cannot clone ${NUMPY_REPOSITORY}, see build/git-clone.log"
            tail -20 "${log}" || true
            return 30
        }
    fi
    numpy_container_exec git -C "${NUMPY_REPO_DIR}" checkout --detach -f \
        "${NUMPY_BASELINE_COMMIT}" >> "${log}" 2>&1 || {
        log_message "ERROR: cannot check out the pinned NumPy baseline commit"
        tail -20 "${log}" || true
        return 30
    }
    local commit tree
    commit="$(numpy_repo_commit)" || return 30
    tree="$(numpy_repo_tree)" || return 30
    if [ "${commit}" != "${NUMPY_BASELINE_COMMIT}" ]; then
        log_message "ERROR: NumPy checkout is at ${commit}, expected ${NUMPY_BASELINE_COMMIT}"
        return 30
    fi
    if [ "${tree}" != "${NUMPY_BASELINE_TREE}" ]; then
        log_message "ERROR: NumPy checkout tree is ${tree}, expected ${NUMPY_BASELINE_TREE}"
        return 30
    fi
    log_message "NumPy baseline verified: commit ${commit} tree ${tree}"
}

# Whether the direct github.com route is usable: one cheap ls-remote with a short
# timeout, so an unreachable runner does not burn two ~135 s connect timeouts per
# submodule before the mirror pass gets its turn.
numpy_github_reachable() {
    numpy_container_exec timeout "${NUMPY_SUBMODULE_PROBE_SECONDS}" \
        git ls-remote --heads "${NUMPY_SUBMODULE_PROBE_URL}" \
        > "$(numpy_build_log_dir)/git-probe.log" 2>&1
}

numpy_init_submodules() {
    local log mirror submodule installed
    local -a needed=()
    local -a failed=()
    log="$(numpy_build_log_dir)/git-submodules.log"
    needed=("${NUMPY_SUBMODULES[@]}")
    local already=1
    for submodule in "${needed[@]}"; do
        if ! numpy_container_exec test -f "${NUMPY_REPO_DIR}/${submodule}/.git"; then
            already=0
            break
        fi
    done
    if [ "${already}" -eq 1 ]; then
        log_message "all required NumPy submodules are already present"
        return 0
    fi
    : > "${log}"
    local direct_ok=0
    if numpy_github_reachable; then
        direct_ok=1
    else
        log_message "github.com is not reachable directly; going straight to the mirrors"
    fi
    for mirror in "${NUMPY_SUBMODULE_MIRRORS[@]}"; do
        if [ -z "${mirror}" ] && [ "${direct_ok}" -ne 1 ]; then
            continue
        fi
        log_message "initialising NumPy submodules (github mirror: ${mirror:-direct})"
        failed=()
        for submodule in "${needed[@]}"; do
            if [ -n "${mirror}" ]; then
                if numpy_container_exec git -C "${NUMPY_REPO_DIR}" \
                    -c "url.${mirror}.insteadOf=https://github.com/" \
                    submodule update --init --depth 1 -- "${submodule}" >> "${log}" 2>&1; then
                    continue
                fi
            elif numpy_container_exec git -C "${NUMPY_REPO_DIR}" submodule update \
                --init --depth 1 -- "${submodule}" >> "${log}" 2>&1; then
                continue
            fi
            failed+=("${submodule}")
        done
        if [ "${#failed[@]}" -eq 0 ]; then
            log_message "NumPy submodules are ready (${#needed[@]} paths)"
            return 0
        fi
        log_message "mirror ${mirror:-direct} could not fetch: ${failed[*]}"
    done
    log_message "ERROR: cannot initialise NumPy submodules: ${failed[*]}"
    tail -20 "${log}" || true
    return 30
}

numpy_build_wheel() {
    local log out_dir wheel
    log="$(numpy_build_log_dir)/numpy-build.log"
    out_dir="${WHEELHOUSE}/numpy"
    numpy_container_exec mkdir -p "${out_dir}" || return 30
    log_message "building the NumPy wheel with meson-python (no build isolation)"
    numpy_container_exec_at "${NUMPY_REPO_DIR}" env "PATH=${VENV_DIR}/bin:/usr/local/bin:/usr/bin:/bin" \
        "${VENV_PY}" -m build --wheel --no-isolation --outdir "${out_dir}" . > "${log}" 2>&1 || {
        log_message "ERROR: NumPy wheel build failed, see build/numpy-build.log"
        tail -40 "${log}" || true
        return 30
    }
    wheel="$(numpy_container_exec find "${out_dir}" -maxdepth 1 -name 'numpy-*.whl' -type f | head -n 1)"
    if [ -z "${wheel}" ]; then
        log_message "ERROR: the NumPy wheel build produced no wheel"
        return 30
    fi
    NUMPY_WHEEL="${wheel}"
    NUMPY_WHEEL_SHA256="$(numpy_container_exec sha256sum "${wheel}" | cut -d' ' -f1)"
    NUMPY_WHEEL_BYTES="$(numpy_container_exec stat -c '%s' "${wheel}")"
    log_message "NumPy wheel built: $(basename "${wheel}") (${NUMPY_WHEEL_BYTES} bytes, sha256 ${NUMPY_WHEEL_SHA256})"
}

numpy_install_wheel() {
    local log
    log="$(numpy_build_log_dir)/numpy-install.log"
    log_message "installing the NumPy wheel into the measurement virtual environment"
    numpy_container_exec "${VENV_PY}" -m pip install --no-cache-dir --no-deps \
        --force-reinstall "${NUMPY_WHEEL}" > "${log}" 2>&1 || {
        log_message "ERROR: cannot install the NumPy wheel, see build/numpy-install.log"
        tail -30 "${log}" || true
        return 30
    }
    local installed
    installed="$(numpy_container_exec_at "${PERF_WORK_DIR}" "${VENV_PY}" \
        -c 'import numpy; print(numpy.__version__)')" || {
        log_message "ERROR: installed NumPy cannot be imported"
        return 30
    }
    if [ "${installed}" != "${SOFTWARE_VERSION}" ]; then
        log_message "ERROR: installed NumPy reports ${installed}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    log_message "NumPy ${installed} installed in the measurement virtual environment"
}

numpy_stage_asv_suite() {
    local log count
    log="$(numpy_build_log_dir)/asv-stage.log"
    # Both ${SCRIPT_DIR} (read-only mount) and ${PERF_WORK_DIR} are visible on
    # the host and inside the container, so the suite is staged from the host
    # and then verified from inside the container.
    rm -rf "${ASV_DIR}" || return 30
    mkdir -p "${ASV_DIR}" || return 30
    log_message "staging the vendored aggregate ASV suite"
    if ! cp -a "${SCRIPT_DIR}/asv_bench/." "${ASV_DIR}/" > "${log}" 2>&1; then
        log_message "ERROR: cannot stage the vendored ASV suite into ${ASV_DIR}"
        tail -20 "${log}" || true
        return 30
    fi
    numpy_container_exec test -f "${ASV_CONF}" || {
        log_message "ERROR: the staged ASV suite has no asv.conf.json"
        return 30
    }
    numpy_verify_asv_suite "${ASV_DIR}" || return $?
    count="$(find "${ASV_DIR}/benchmarks" -name '*.py' -type f | wc -l)"
    log_message "ASV suite staged and verified: ${count} benchmark modules"
}

numpy_configure_asv_machine() {
    local log machine
    log="$(numpy_build_log_dir)/asv-machine.log"
    numpy_container_exec mkdir -p "${PERF_WORK_DIR}/home" || return 30
    log_message "registering the machine with ASV"
    numpy_container_exec_at "${ASV_DIR}" env "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${PERF_WORK_DIR}/home" "${ASV_BIN}" machine --yes > "${log}" 2>&1 || {
        log_message "ERROR: asv machine --yes failed, see build/asv-machine.log"
        tail -20 "${log}" || true
        return 30
    }
    machine="${PERF_WORK_DIR}/home/.asv-machine.json"
    numpy_container_exec test -s "${machine}" || {
        log_message "ERROR: asv did not write the machine file"
        return 30
    }
    log_message "ASV machine registered"
}

numpy_record_runtime_versions() {
    local script="${PERF_WORK_DIR}/tmp/record-runtime-versions.py"
    numpy_container_exec mkdir -p "${PERF_WORK_DIR}/tmp" || return 30
    cat > "${script}" <<'PY'
import json
import platform
import subprocess
import sys
from importlib import metadata
from pathlib import Path

output = Path(sys.argv[1])
packages = {}
for name in ("numpy", "asv", "asv-runner", "build", "Cython", "meson", "meson-python", "ninja", "packaging", "virtualenv"):
    try:
        packages[name.lower()] = metadata.version(name)
    except metadata.PackageNotFoundError:
        packages[name.lower()] = None


def command_output(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, check=False).stdout.strip()
    except OSError:
        return ""


payload = {
    "python": platform.python_version(),
    "python_implementation": platform.python_implementation(),
    "machine": platform.machine(),
    "platform": platform.platform(),
    "libc": " ".join(platform.libc_ver()),
    "packages": packages,
    "gcc": command_output("gcc", "--version").splitlines()[0] if command_output("gcc", "--version") else "",
    "openblas": command_output("pkg-config", "--modversion", "openblas"),
}
output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
PY
    numpy_container_exec_at "${PERF_WORK_DIR}/tmp" "${VENV_PY}" "${script}" \
        "${RUNTIME_VERSIONS_JSON}" || {
        log_message "ERROR: cannot record the runtime versions"
        return 30
    }
    log_message "recorded runtime versions: ${RUNTIME_VERSIONS_JSON}"
}

numpy_write_build_variant() {
    local script="${PERF_WORK_DIR}/tmp/write-build-variant.py"
    numpy_container_exec mkdir -p "${PERF_WORK_DIR}/tmp" || return 30
    cat > "${script}" <<'PY'
import json
import sys
from pathlib import Path

(
    output,
    variant,
    architecture,
    run_id,
    commit,
    tree,
    suite_commit,
    suite_tree,
    python_version,
    python_sha256,
    asv_version,
    wheel,
    wheel_sha256,
    wheel_bytes,
    runtime_versions,
    reps,
    warmups,
    container_image,
    software_version,
) = sys.argv[1:21]

runtime = json.loads(Path(runtime_versions).read_text())
payload = {
    "software": "numpy",
    "version": software_version,
    "variant": variant,
    "architecture": architecture,
    "run_id": run_id,
    "commit": commit,
    "tree": tree,
    "suite_commit": suite_commit,
    "suite_tree": suite_tree,
    "container_image": container_image,
    "python": python_version,
    "python_sha256": python_sha256,
    "asv": asv_version,
    "wheel": Path(wheel).name,
    "wheel_sha256": wheel_sha256,
    "wheel_bytes": int(wheel_bytes),
    "toolchain": runtime,
    "parameters": {
        "variant": variant,
        "commit": commit,
        "suite_commit": suite_commit,
        "python": python_version,
        "asv": asv_version,
        "reps": int(reps),
        "warmups": int(warmups),
    },
}
Path(output).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
PY
    numpy_container_exec_at "${PERF_WORK_DIR}/tmp" "${VENV_PY}" "${script}" \
        "${RESULTS_DIR}/build_variant.json" \
        "${PERF_VARIANT}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${NUMPY_BASELINE_COMMIT}" \
        "${NUMPY_BASELINE_TREE}" \
        "${ASV_SUITE_COMMIT}" \
        "${ASV_SUITE_BENCH_TREE}" \
        "${PYTHON_VERSION}" \
        "${PYTHON_SHA256}" \
        "${ASV_VERSION}" \
        "${NUMPY_WHEEL:-unknown}" \
        "${NUMPY_WHEEL_SHA256:-unknown}" \
        "${NUMPY_WHEEL_BYTES:-0}" \
        "${RUNTIME_VERSIONS_JSON}" \
        "${NUMPY_REPS}" \
        "${NUMPY_WARMUPS}" \
        "${NUMPY_CONTAINER_IMAGE}" \
        "${SOFTWARE_VERSION}" || {
        log_message "ERROR: cannot write build_variant.json"
        return 30
    }
    log_message "wrote ${RESULTS_DIR}/build_variant.json"
}

build_numpy_base() {
    numpy_require_host_tools || return $?
    numpy_configure_container || return $?
    require_numpy_docker || return $?
    check_architecture || return $?
    validate_reps || return $?
    start_numpy_container || return $?

    numpy_install_container_packages || return $?
    numpy_acquire_cpython_source || return $?
    numpy_build_cpython_runtime || return $?
    numpy_create_measurement_venv || return $?
    numpy_clone_baseline || return $?
    numpy_init_submodules || return $?
    numpy_build_wheel || return $?
    numpy_install_wheel || return $?
    numpy_stage_asv_suite || return $?
    numpy_configure_asv_machine || return $?
    numpy_record_runtime_versions || return $?
    numpy_write_build_variant || return $?
    write_actual_version "${SOFTWARE_VERSION}" || return $?
    log_message "base build finished"
}
