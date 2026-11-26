#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Optimized variant: CPython is built with the same PGO+LTO configure options
# as the base variant, then the CinderX JIT extension is built from source and
# installed into that private interpreter. Only container-user-space tooling and
# the tested source tree are touched; the two variants use identical runtime
# launch parameters. The CinderX branch tip is resolved to an explicit commit
# and recorded so start/test/parse use the exact revision that was built.

require_python_tools() {
    local command_name package
    local packages=()

    for command_name in git gcc make python3 nproc sudo; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            gcc) package="gcc" ;;
            make) package="make" ;;
            python3) package="python3" ;;
            nproc) package="coreutils" ;;
            sudo) package="sudo" ;;
        esac
        log_message "missing required Python test command: ${command_name}"
        packages+=("${package}")
    done

    for package in bzip2-devel gdbm-devel libffi-devel openssl-devel readline-devel sqlite-devel uuid-devel xz-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "missing required Python test package: ${package}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install Python test prerequisites"
        return 30
    fi

    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing Python test packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install Python test prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install Python test prerequisites"
        return 30
    fi

    for command_name in git gcc make python3 nproc sudo; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required Python test command remains unavailable: ${command_name}"
            return 30
        fi
    done
    for package in bzip2-devel gdbm-devel libffi-devel openssl-devel readline-devel sqlite-devel uuid-devel xz-devel zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "ERROR: required Python test package remains unavailable: ${package}"
            return 30
        fi
    done
}

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

prepare_cpython_source() {
    [[ ! -e "${SOURCE_DIR}" ]] || {
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning CPython v${SOFTWARE_VERSION} from ${CPYTHON_SOURCE_URL}"
    git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${CPYTHON_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone CPython v${SOFTWARE_VERSION}"
        return 30
    }
}

verify_cpython_build() {
    local version_output actual_version
    [[ -x "${PYTHON_BIN}" ]] || {
        log_message "ERROR: CPython interpreter was not installed: ${PYTHON_BIN}"
        return 40
    }
    version_output="$("${PYTHON_BIN}" --version 2>&1)" || {
        log_message "ERROR: built CPython cannot report its version"
        return 40
    }
    actual_version="${version_output#Python }"
    actual_version="${actual_version%%[[:space:]]*}"
    [[ -n "${actual_version}" && "${actual_version}" != "${version_output}" ]] || {
        log_message "ERROR: unexpected CPython version output: ${version_output}"
        return 40
    }
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built CPython reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    "${PYTHON_BIN}" -c "import ssl, zlib, ctypes" || {
        log_message "ERROR: built CPython is missing ssl/zlib/ctypes modules"
        log_message "the Runner is missing zlib-devel or libffi-devel"
        return 40
    }
    "${PYTHON_BIN}" -m pip --version >/dev/null 2>&1 || {
        log_message "ERROR: built CPython has no usable pip"
        return 40
    }
}

cinderx_dnf_install() {
    local -a packages=("$@")
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install CinderX build prerequisites"
        return 30
    fi
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}"
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"
    else
        log_message "ERROR: sudo is required to install CinderX build prerequisites"
        return 30
    fi
}

cinderx_compiler_major() {
    local compiler="$1"
    [[ -n "${compiler}" && -x "${compiler}" ]] || return 1
    "${compiler}" -dumpversion 2>/dev/null | cut -d. -f1
}

cinderx_toolchain_usable() {
    local cc="$1" cxx="$2" cc_major cxx_major
    cc_major="$(cinderx_compiler_major "${cc}")" || return 1
    cxx_major="$(cinderx_compiler_major "${cxx}")" || return 1
    [[ "${cc_major}" =~ ^[0-9]+$ && "${cxx_major}" =~ ^[0-9]+$ ]] || return 1
    (( cc_major >= 13 && cxx_major >= 13 ))
}

cinderx_try_toolchain() {
    local cc="$1" cxx="$2" gcov="$3" libdir="$4"
    cinderx_toolchain_usable "${cc}" "${cxx}" || return 1
    CINDERX_CC="${cc}"
    CINDERX_CXX="${cxx}"
    CINDERX_GCOV=""
    if [[ -n "${gcov}" && -x "${gcov}" ]]; then
        CINDERX_GCOV="${gcov}"
    fi
    CINDERX_GCC_LIBDIR="${libdir}"
    return 0
}

cinderx_select_compiler() {
    local override_cc="${CINDERX_CC:-}"
    local override_cxx="${CINDERX_CXX:-}"
    local toolset_root="/opt/openEuler/gcc-toolset-14/root"

    CINDERX_CC=""
    CINDERX_CXX=""
    CINDERX_GCOV=""
    CINDERX_GCC_LIBDIR=""

    if [[ -n "${override_cc}" && -n "${override_cxx}" ]]; then
        override_cc="$(command -v "${override_cc}" 2>/dev/null || true)"
        override_cxx="$(command -v "${override_cxx}" 2>/dev/null || true)"
        if cinderx_try_toolchain "${override_cc}" "${override_cxx}" "" ""; then
            return 0
        fi
    fi
    if cinderx_try_toolchain \
        "${toolset_root}/usr/bin/gcc" \
        "${toolset_root}/usr/bin/g++" \
        "${toolset_root}/usr/bin/gcov" \
        "${toolset_root}/usr/lib64"; then
        return 0
    fi
    if cinderx_try_toolchain \
        "$(command -v gcc 2>/dev/null || true)" \
        "$(command -v g++ 2>/dev/null || true)" \
        "$(command -v gcov 2>/dev/null || true)" \
        ""; then
        return 0
    fi
    return 1
}

require_cinderx_tools() {
    local package
    local -a missing=()

    for package in git gcc-c++ make cmake ninja-build zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            missing+=("${package}")
        fi
    done
    if [[ "${#missing[@]}" -gt 0 ]]; then
        log_message "installing missing CinderX build packages: ${missing[*]}"
        cinderx_dnf_install "${missing[@]}" || return 30
    fi
    for package in gcc-c++ cmake ninja-build zlib-devel; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            log_message "ERROR: required CinderX build package remains unavailable: ${package}"
            return 30
        fi
    done

    if ! cinderx_select_compiler; then
        log_message "installing GCC toolset required by the CinderX build"
        cinderx_dnf_install \
            gcc-toolset-14-gcc \
            gcc-toolset-14-gcc-c++ \
            gcc-toolset-14-libgcc \
            gcc-toolset-14-libstdc++-devel || return 30
        cinderx_select_compiler || {
            log_message "ERROR: CinderX requires GCC 13 or newer with a matching g++; set CINDERX_CC/CINDERX_CXX"
            return 30
        }
    fi
    log_message "CinderX toolchain: CC=${CINDERX_CC} CXX=${CINDERX_CXX}"
}

install_python_build_tools() {
    log_message "installing the CinderX build backend into the private CPython"
    CINDERX_PLUGIN_ENABLE=0 "${PYTHON_BIN}" -m pip install --no-cache-dir \
        --index-url "${PYPI_INDEX_URL}" \
        --trusted-host "${PYPI_TRUSTED_HOST}" \
        "setuptools>=77.0.3" wheel || {
        log_message "ERROR: failed to install setuptools/wheel for the CinderX build"
        return 40
    }
}

prepare_cinderx_source() {
    [[ ! -e "${CINDERX_SOURCE_DIR}" ]] || {
        log_message "ERROR: CinderX source directory already exists: ${CINDERX_SOURCE_DIR}"
        return 30
    }
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning CinderX ${CINDERX_REF} from ${CINDERX_REPOSITORY}"
    if ! git clone --branch "${CINDERX_REF}" \
        "${CINDERX_REPOSITORY}" "${CINDERX_SOURCE_DIR}"; then
        log_message "branch/tag checkout failed; retrying as an explicit revision"
        rm -rf -- "${CINDERX_SOURCE_DIR}"
        git clone "${CINDERX_REPOSITORY}" "${CINDERX_SOURCE_DIR}" || {
            log_message "ERROR: failed to clone CinderX ${CINDERX_REF}"
            return 30
        }
        git -C "${CINDERX_SOURCE_DIR}" checkout --detach "${CINDERX_REF}" || {
            log_message "ERROR: CinderX revision does not exist: ${CINDERX_REF}"
            return 30
        }
    fi

    local head tree branch parent parent_tree range
    head="$(git -C "${CINDERX_SOURCE_DIR}" rev-parse HEAD)" || return 30
    tree="$(git -C "${CINDERX_SOURCE_DIR}" rev-parse "HEAD^{tree}")" || return 30
    if git -C "${CINDERX_SOURCE_DIR}" symbolic-ref -q HEAD >/dev/null 2>&1; then
        branch="$(git -C "${CINDERX_SOURCE_DIR}" rev-parse --abbrev-ref HEAD)" || return 30
    else
        branch="detached"
    fi
    parent="$(git -C "${CINDERX_SOURCE_DIR}" rev-parse "HEAD~1")" || {
        log_message "ERROR: CinderX ${CINDERX_REF} has no parent commit to compare against"
        return 30
    }
    parent_tree="$(git -C "${CINDERX_SOURCE_DIR}" rev-parse "HEAD~1^{tree}")" || return 30
    range="${parent}..${head}"

    [[ "${branch}" == detached || "${branch}" == "${CINDERX_REF}" ]] || {
        log_message "ERROR: CinderX clone is on ${branch}, expected ${CINDERX_REF}"
        return 30
    }

    {
        printf 'ref=%s\n' "${CINDERX_REF}"
        printf 'branch=%s\n' "${branch}"
        printf 'head=%s\n' "${head}"
        printf 'head_tree=%s\n' "${tree}"
        printf 'parent=%s\n' "${parent}"
        printf 'parent_tree=%s\n' "${parent_tree}"
        printf 'range=%s\n' "${range}"
    } > "${CINDERX_SOURCE_RECORD}" || return 30
    log_message "CinderX source pinned at ${head} (${branch}), parent ${parent}"
}

build_cpython_pgo_lto() {
    local -a configure_options

    read -r -a configure_options <<< "${CONFIGURE_OPTIONS}"
    [[ "${#configure_options[@]}" -gt 0 ]] || {
        log_message "ERROR: CPython configure options are empty"
        return 40
    }

    log_message "configuring CPython v${SOFTWARE_VERSION} with ${CONFIGURE_OPTIONS} into a private prefix"
    (
        cd "${SOURCE_DIR}"
        ./configure --prefix="${INSTALL_DIR}" "${configure_options[@]}"
    ) || {
        log_message "ERROR: CPython configure failed"
        return 40
    }
    log_message "building CPython v${SOFTWARE_VERSION} with make -j$(nproc)"
    (
        cd "${SOURCE_DIR}"
        make -j"$(nproc)"
    ) || {
        log_message "ERROR: CPython make failed"
        return 40
    }
    (
        cd "${SOURCE_DIR}"
        make install
    ) || {
        log_message "ERROR: CPython make install failed"
        return 40
    }
}

build_cinderx() {
    local jobs="${CINDERX_BUILD_JOBS:-$(nproc)}"
    [[ "${jobs}" =~ ^[1-9][0-9]*$ ]] || {
        log_message "ERROR: CINDERX_BUILD_JOBS must be a positive integer: ${jobs}"
        return 40
    }

    log_message "building CinderX with ${CINDERX_CC} (build type ${CINDERX_BUILD_TYPE}, PGO=${CINDERX_ENABLE_PGO}, LTO=${CINDERX_ENABLE_LTO})"
    (
        cd "${CINDERX_SOURCE_DIR}" || exit 40
        export CC="${CINDERX_CC}"
        export CXX="${CINDERX_CXX}"
        if [[ -n "${CINDERX_GCOV}" ]]; then
            export GCOV="${CINDERX_GCOV}"
        fi
        if [[ -n "${CINDERX_GCC_LIBDIR}" ]]; then
            export LD_LIBRARY_PATH="${CINDERX_GCC_LIBDIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
            export LDFLAGS="-Wl,-rpath,${CINDERX_GCC_LIBDIR}${LDFLAGS:+ ${LDFLAGS}}"
        fi
        export CMAKE_BUILD_TYPE="${CINDERX_BUILD_TYPE}"
        export CMAKE_BUILD_PARALLEL_LEVEL="${jobs}"
        export CINDERX_PLUGIN_ENABLE=0
        export CINDERX_ENABLE_PGO="${CINDERX_ENABLE_PGO}"
        export CINDERX_ENABLE_LTO="${CINDERX_ENABLE_LTO}"
        if [[ -n "${CINDERX_LOCAL_DEPS}" ]]; then
            export CINDERX_LOCAL_DEPS
        fi
        "${PYTHON_BIN}" -m pip install --no-cache-dir \
            --no-build-isolation --no-deps --force-reinstall . || exit 40
    ) || {
        log_message "ERROR: CinderX build failed; inspect the CMake output above"
        return 40
    }
}

verify_cinderx_build() {
    local version
    version="$("${PYTHON_BIN}" -c 'import importlib.metadata as metadata; print(metadata.version("cinderx"))' 2>/dev/null)" || {
        log_message "ERROR: CinderX distribution is not installed in the private CPython"
        return 40
    }
    [[ -n "${version}" ]] || {
        log_message "ERROR: CinderX reports an empty version"
        return 40
    }
    CINDERX_VERSION="${version}"
    "${PYTHON_BIN}" -c 'import cinderx' >/dev/null 2>&1 || {
        log_message "ERROR: CinderX extension cannot be imported by the private CPython"
        return 40
    }
    log_message "CinderX ${CINDERX_VERSION} installed into ${PYTHON_BIN}"
}

write_cinderx_build_variant() {
    "${PYTHON_BIN}" - "${RESULTS_DIR}/build_variant.json" \
        "${SOFTWARE_VERSION}" \
        "${PYTHON_EXPECTED_COMMIT}" \
        "${PYTHON_EXPECTED_TREE}" \
        "${PYTHON_EXPECTED_BRANCH}" \
        "${CINDERX_REF}" \
        "${PYTHON_EXPECTED_PARENT}" \
        "${PYTHON_EXPECTED_PARENT_TREE}" \
        "${PYTHON_EXPECTED_RANGE}" \
        "${CINDERX_BUILD_TYPE}" \
        "${CINDERX_ENABLE_PGO}" \
        "${CINDERX_ENABLE_LTO}" \
        "${CINDERX_VERSION}" \
        "$("${CINDERX_CC}" --version | head -n 1)" \
        "${GCC_VERSION_STRING}" \
        "${CINDERX_PLUGIN_ENV}" \
        "${CINDERX_PYTHONJITAUTO}" <<'PY'
import json
import os
import sys

argv = sys.argv[1:]
if len(argv) != 17:
    print(f"expected 17 arguments, got {len(argv)}", file=sys.stderr)
    raise SystemExit(2)
(
    path,
    version,
    commit,
    tree,
    branch,
    ref,
    parent,
    parent_tree,
    commit_range,
    build_type,
    pgo,
    lto,
    cinderx_version,
    cinderx_gcc,
    python_gcc,
    plugin_enabled,
    jit_auto,
) = argv

payload = {
    "variant": "optimized",
    "software": "python",
    "version": version,
    "commit": commit,
    "commit_tree": tree,
    "branch": branch,
    "ref": ref,
    "parent_commit": parent,
    "parent_tree": parent_tree,
    "commit_range": commit_range,
    "source": {
        "repository": os.environ.get("CINDERX_REPOSITORY", ""),
        "record": os.environ.get("CINDERX_SOURCE_RECORD", ""),
    },
    "cinderx": {
        "version": cinderx_version,
        "build_type": build_type,
        "pgo": pgo,
        "lto": lto,
        "plugin_enable": plugin_enabled,
        "python_jit_auto": jit_auto,
    },
    "toolchain": {"python_gcc": python_gcc, "cinderx_gcc": cinderx_gcc},
    "configure_options": os.environ.get("CONFIGURE_OPTIONS", ""),
    "parameters": {"variant": "optimized"},
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")
PY
}

build_python_optimized() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_python_tools || return $?
    require_cinderx_tools || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${INSTALL_DIR}" && ! -e "${BENCH_WORK_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    prepare_cpython_source || return $?
    GCC_VERSION_STRING="$(gcc --version | head -n 1)"
    build_cpython_pgo_lto || return 40
    verify_cpython_build || return $?

    install_python_build_tools || return 40
    prepare_cinderx_source || return 30
    python_load_expected_source || return $?
    build_cinderx || return 40
    verify_cinderx_build || return 40
    write_cinderx_build_variant || return 40

    log_message "optimized runtime ready: CPython ${SOFTWARE_VERSION} + CinderX ${CINDERX_VERSION} (${PYTHON_EXPECTED_COMMIT:0:8})"
}
