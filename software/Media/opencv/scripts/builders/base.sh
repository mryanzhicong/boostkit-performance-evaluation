#!/usr/bin/env bash
# Stock (unpatched) OpenCV build with python3 bindings, entirely inside the
# private openEuler container.  The reference material builds only the core,
# imgproc and python3 modules with every threading backend disabled, so the
# published metric is single-threaded by construction.

build_opencv_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    opencv_resolve_media || return $?
    opencv_require_host_tools || return $?

    log_message "fetching the pinned OpenCV ${SOFTWARE_VERSION} archive"
    opencv_fetch_archive || return $?

    opencv_media_mount_args
    start_opencv_container || return $?

    log_message "installing build dependencies inside the container"
    opencv_container_exec_root dnf -y --setopt=install_weak_deps=False \
        --setopt=tsflags=noscripts install "${OPENCV_CONTAINER_DEPS[@]}" || return 30

    log_message "extracting the source archive inside the container"
    opencv_container_exec mkdir -p "${OPENCV_SRC_DIR}" || return 40
    opencv_container_exec tar -xzf "${PERF_WORK_DIR}/downloads/${OPENCV_ARCHIVE_NAME}" \
        --strip-components=1 -C "${OPENCV_SRC_DIR}" || return 40

    # The reference build derives the python3 include/lib/numpy paths from the
    # interpreter it builds against; do the same inside the container.
    local python_layout
    python_layout="$(opencv_container_exec python3 -B -c "
import os, sysconfig, sys
from pathlib import Path
import numpy
include = Path(os.environ.get('PYTHON3_INCLUDE_DIR', sysconfig.get_path('include')))
if not (include / 'Python.h').is_file():
    sys.exit('ERROR: matching Python development headers are required.')
lib = Path(sysconfig.get_config_var('LIBDIR')) / sysconfig.get_config_var('LDLIBRARY')
if not lib.exists():
    lib = Path(str(lib) + '.1.0')
if not lib.exists():
    sys.exit('ERROR: matching Python shared library is required.')
print(Path(sys.executable).resolve())
print(include)
print(numpy.get_include())
print(lib)
print(numpy.__version__)
")" || return 40
    local python_executable python_include numpy_include python_library numpy_version
    {
        read -r python_executable
        read -r python_include
        read -r numpy_include
        read -r python_library
        read -r numpy_version
    } <<< "${python_layout}"
    log_message "container python3: ${python_executable} (numpy ${numpy_version})"

    local arch_flags=""
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == aarch64 ]]; then
        arch_flags="-march=armv8-a"
    fi

    log_message "configuring OpenCV (core, imgproc, python3; all threading backends off)"
    opencv_container_exec cmake -S "${OPENCV_SRC_DIR}" -B "${OPENCV_BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${OPENCV_INSTALL_DIR}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_C_FLAGS="-O3 -ffp-contract=off ${arch_flags}" \
        -DCMAKE_CXX_FLAGS="-O3 -ffp-contract=off ${arch_flags}" \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_LIST=core,imgproc,python3 \
        -DBUILD_opencv_python3=ON -DBUILD_opencv_python2=OFF \
        -DPYTHON3_EXECUTABLE="${python_executable}" \
        -DPYTHON3_INCLUDE_DIR="${python_include}" \
        -DPYTHON3_INCLUDE_PATH="${python_include}" \
        -DPYTHON3_NUMPY_INCLUDE_DIRS="${numpy_include}" \
        -DPYTHON3_LIBRARY="${python_library}" \
        -DPYTHON3_PACKAGES_PATH="${OPENCV_PYTHON_DIR}" \
        -DOPENCV_PYTHON3_INSTALL_PATH="${OPENCV_PYTHON_DIR}" \
        -DOPENCV_SKIP_PYTHON_LOADER=ON \
        -DWITH_IPP=OFF -DWITH_OPENCL=OFF -DWITH_OPENVX=OFF -DWITH_LAPACK=OFF -DWITH_EIGEN=OFF \
        -DWITH_HALIDE=OFF -DWITH_CAROTENE=OFF -DWITH_TBB=OFF -DWITH_PTHREADS_PF=OFF -DWITH_OPENMP=OFF \
        -DWITH_ITT=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF \
        -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF \
        -DBUILD_JAVA=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || return 40
    opencv_container_exec grep -q 'opencv_python3' "${OPENCV_BUILD_DIR}/CMakeCache.txt" || {
        log_message "ERROR: the python3 bindings were not configured"
        return 40
    }

    log_message "building OpenCV with ${OPENCV_BUILD_JOBS} jobs"
    opencv_container_exec cmake --build "${OPENCV_BUILD_DIR}" \
        --parallel "${OPENCV_BUILD_JOBS}" || return 40
    opencv_container_exec cmake --install "${OPENCV_BUILD_DIR}" || return 40

    opencv_verify_runtime_payload || return $?
    write_actual_version || return $?
    write_build_variant || return $?
    log_message "stock OpenCV ${SOFTWARE_VERSION} build completed"
}
