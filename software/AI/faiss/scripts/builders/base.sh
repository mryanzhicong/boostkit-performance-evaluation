#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_system_packages() {
    local dnf_options=()
    command -v dnf >/dev/null 2>&1 || {
        log_message "ERROR: dnf is required to install Faiss build dependencies"
        return 30
    }
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing system packages: $*"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "$@" || return 30
    else
        command -v sudo >/dev/null 2>&1 || return 30
        sudo -n dnf "${dnf_options[@]}" install -y "$@" || return 30
    fi
}


require_build_commands() {
    local required_command package
    local cmake_version cmake_major cmake_minor
    local packages=()
    for required_command in git python3 cmake make g++ find nproc tee curl h5dump; do
        command -v "${required_command}" >/dev/null 2>&1 && continue
        case "${required_command}" in
            g++) package="gcc-c++" ;;
            find) package="findutils" ;;
            nproc|tee) package="coreutils" ;;
            h5dump) package="hdf5" ;;
            *) package="${required_command}" ;;
        esac
        log_message "missing required command: ${required_command}"
        packages+=("${package}")
    done
    [[ -f /usr/include/H5Cpp.h || -f /usr/include/hdf5/serial/H5Cpp.h ]] || packages+=(hdf5-devel)
    if ((${#packages[@]})); then
        install_system_packages "${packages[@]}" || return 30
    fi
    for required_command in git python3 cmake make g++ find nproc tee curl h5dump; do
        command -v "${required_command}" >/dev/null 2>&1 || {
            log_message "ERROR: required command remains unavailable: ${required_command}"
            return 30
        }
    done
    [[ -f /usr/include/H5Cpp.h || -f /usr/include/hdf5/serial/H5Cpp.h ]] || {
        log_message "ERROR: HDF5 C++ headers remain unavailable"
        return 30
    }
    cmake_version="$(cmake --version | head -n 1)"
    if [[ ! "${cmake_version}" =~ ([0-9]+)\.([0-9]+) ]]; then
        log_message "ERROR: cannot determine CMake version: ${cmake_version}"
        return 30
    fi
    cmake_major="${BASH_REMATCH[1]}"
    cmake_minor="${BASH_REMATCH[2]}"
    if ((cmake_major < 3 || (cmake_major == 3 && cmake_minor < 24))); then
        log_message "ERROR: Faiss ${SOFTWARE_VERSION} needs CMake >= 3.24; found ${cmake_version}"
        return 30
    fi
    if ! printf '#include <span>\n#include <omp.h>\nint main() { int a[1]={0}; return std::span<int>(a).size() != 1 || omp_get_max_threads() < 1; }\n' |
         g++ -std=c++20 -fopenmp -x c++ - -o "${TMPDIR}/faiss-compiler-check"; then
        log_message "ERROR: g++ must support C++20 and OpenMP for Faiss ${SOFTWARE_VERSION}"
        return 30
    fi
    "${TMPDIR}/faiss-compiler-check" || return 30
}


locate_mkl() {
    local candidate library_dir
    for candidate in "${MKLROOT:-}" "${PERF_WORK_DIR}/oneapi/mkl/latest" \
        "${PERF_WORK_DIR}"/oneapi/mkl/* /opt/intel/oneapi/mkl/latest \
        /opt/intel/oneapi/mkl/*; do
        [[ -n "${candidate}" && -f "${candidate}/include/mkl.h" ]] || continue
        for library_dir in "${candidate}/lib/intel64" "${candidate}/lib"; do
            [[ -d "${library_dir}" ]] || continue
            [[ -e "${library_dir}/libmkl_intel_lp64.so" &&
               -e "${library_dir}/libmkl_gnu_thread.so" &&
               -e "${library_dir}/libmkl_core.so" ]] || continue
            MKLROOT="${candidate}"
            MKL_LIBRARY_DIR="${library_dir}"
            export MKLROOT
            return 0
        done
    done
    return 1
}


prepare_math_library() {
    local installer instance_id
    local openblas_flags=()
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "aarch64" ]]; then
        if ! command -v pkg-config >/dev/null 2>&1; then
            install_system_packages pkgconf-pkg-config || return 30
        fi
        if ! pkg-config --exists openblas; then
            install_system_packages openblas-devel || return 30
        fi
        if ! pkg-config --exists openblas; then
            log_message "ERROR: system OpenBLAS development files are unavailable"
            return 30
        fi
        OPENBLAS_CFLAGS="$(pkg-config --cflags openblas)"
        OPENBLAS_LIBS="$(pkg-config --libs openblas)"
        read -r -a openblas_flags <<< "${OPENBLAS_CFLAGS} ${OPENBLAS_LIBS}"
        if ! printf '#include <cblas.h>\nint main() { double x[1]={1}; return cblas_ddot(1,x,1,x,1) != 1; }\n' |
             g++ -std=c++17 -fopenmp -x c++ - "${openblas_flags[@]}" \
                 -o "${TMPDIR}/faiss-blas-check" ||
           ! "${TMPDIR}/faiss-blas-check"; then
            log_message "ERROR: system OpenBLAS headers or libraries cannot be linked and run"
            return 30
        fi
        log_message "using system OpenBLAS on aarch64"
        return 0
    fi

    if ! locate_mkl; then
        installer="${MKL_OFFLINE_DIRECTORY}/${MKL_INSTALLER_NAME}"
        if [[ ! -s "${installer}" ]]; then
            installer="${PERF_WORK_DIR}/${MKL_INSTALLER_NAME}"
            log_message "downloading official Intel oneMKL offline installer"
            if ! curl --fail --location --retry 3 --output "${installer}" "${MKL_INSTALLER_URL}"; then
                log_message "ERROR: cannot download Intel oneMKL; place ${MKL_INSTALLER_NAME} in ${MKL_OFFLINE_DIRECTORY}"
                return 30
            fi
        else
            log_message "using local Intel oneMKL offline installer ${installer}"
        fi
        instance_id="faiss-${PERF_RUN_ID//[^a-zA-Z0-9]/-}"
        log_message "installing Intel oneMKL into private work directory (instance ${instance_id})"
        if ! sh "${installer}" -a --silent --eula accept \
            --install-dir="${PERF_WORK_DIR}/oneapi" --instance="${instance_id}"; then
            log_message "ERROR: Intel oneMKL offline installation failed"
            return 30
        fi
        if ! locate_mkl; then
            log_message "ERROR: Intel oneMKL installation did not provide its headers and GNU OpenMP libraries"
            return 30
        fi
    fi
    if ! printf '#include <mkl.h>\nint main() { double x[1]={1}; return cblas_ddot(1,x,1,x,1) != 1; }\n' |
         g++ -std=c++17 -fopenmp -x c++ - -I"${MKLROOT}/include" \
             -L"${MKL_LIBRARY_DIR}" -Wl,-rpath,"${MKL_LIBRARY_DIR}" \
             -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core \
             -lgomp -lpthread -lm -ldl -o "${TMPDIR}/faiss-blas-check" ||
       ! "${TMPDIR}/faiss-blas-check"; then
        log_message "ERROR: Intel oneMKL headers or libraries cannot be linked and run"
        return 30
    fi
    log_message "using Intel oneMKL at ${MKLROOT}"
}


check_architecture() {
    local actual_architecture
    local expected_architecture
    actual_architecture="$(normalize_architecture "$(uname -m)")"
    expected_architecture="$(normalize_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual_architecture}" != "${expected_architecture}" ]]; then
        log_message "ERROR: expected ${expected_architecture}, runner is ${actual_architecture}"
        return 20
    fi
}


build_faiss_base() {
    local source_tag
    local actual_version
    local parallel_jobs
    local faiss_library
    local config_file
    local algorithm
    local faiss_mkl_mode
    local faiss_link_file
    local expected_blas

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if ! configure_benchmark_profile; then
        return 10
    fi
    if check_architecture; then
        :
    else
        return $?
    fi
    if require_build_commands; then
        :
    else
        return $?
    fi
    if prepare_math_library; then
        :
    else
        return $?
    fi
    if [[ -e "${SOURCE_DIR}" || -e "${BUILD_DIR}" || -e "${SRA_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    source_tag="${SOFTWARE_VERSION}"
    if [[ "${source_tag}" != v* ]]; then
        source_tag="v${source_tag}"
    fi
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning Faiss ${source_tag} from ${FAISS_SOURCE_URL}"
    if ! git clone --branch "${source_tag}" --depth 1 \
        "${FAISS_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone Faiss ${source_tag}"
        return 30
    fi

    actual_version="$(git -C "${SOURCE_DIR}" describe --tags --exact-match 2>/dev/null || true)"
    [[ "${actual_version}" == "${source_tag}" ]] || {
        log_message "ERROR: Faiss source tag is ${actual_version:-missing}, expected ${source_tag}"
        return 40
    }
    faiss_mkl_mode=OFF
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "x86_64" ]]; then
        faiss_mkl_mode=ON
    fi
    log_message "configuring CPU-only Faiss ${SOFTWARE_VERSION} shared library"
    if ! cmake -B "${BUILD_DIR}" -S "${SOURCE_DIR}" \
        -DFAISS_ENABLE_GPU=OFF \
        -DFAISS_ENABLE_PYTHON=OFF \
        -DFAISS_ENABLE_EXTRAS=OFF \
        -DFAISS_ENABLE_MKL="${faiss_mkl_mode}" \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release; then
        log_message "ERROR: Faiss CMake configuration failed"
        return 40
    fi
    faiss_link_file="${BUILD_DIR}/faiss/CMakeFiles/faiss.dir/link.txt"
    [[ -f "${faiss_link_file}" ]] || {
        log_message "ERROR: Faiss CMake link command is unavailable: ${faiss_link_file}"
        return 40
    }
    expected_blas=openblas
    [[ "${faiss_mkl_mode}" == OFF ]] || expected_blas=mkl
    if [[ "$(<"${faiss_link_file}")" != *"${expected_blas}"* ]]; then
        log_message "ERROR: Faiss is not linked with expected ${expected_blas} math library"
        return 40
    fi

    parallel_jobs="$(nproc)"
    log_message "building official Faiss C++ library"
    if ! make -C "${BUILD_DIR}" -j"${parallel_jobs}" faiss; then
        log_message "ERROR: Faiss C++ library build failed"
        return 40
    fi
    faiss_library="$(find "${BUILD_DIR}" -type f -name 'libfaiss.so' -print -quit)"
    if [[ -z "${faiss_library}" ]]; then
        log_message "ERROR: built libfaiss.so is unavailable"
        return 40
    fi
    log_message "fetching sra_test at ${SRA_REVISION}"
    if ! git init -q "${SRA_DIR}" || \
       ! git -C "${SRA_DIR}" remote add origin "${SRA_SOURCE_URL}" || \
       ! git -C "${SRA_DIR}" fetch --depth 1 --filter=blob:none origin "${SRA_REVISION}" || \
       ! git -C "${SRA_DIR}" sparse-checkout set scripts configs include src || \
       ! git -C "${SRA_DIR}" checkout --detach FETCH_HEAD; then
        log_message "ERROR: failed to fetch pinned sra_test source"
        return 30
    fi
    if [[ "$(git -C "${SRA_DIR}" rev-parse HEAD)" != "${SRA_REVISION}" ]]; then
        log_message "ERROR: sra_test revision mismatch"
        return 40
    fi
    mkdir -p "${SRA_DIR}/build"
    config_file="${SRA_DIR}/build/config_faiss_$(normalize_architecture "${EXPECTED_ARCH}").sh"
    {
        printf 'export FAISS_SO=%q\n' "${faiss_library}"
        printf 'export FAISS_LIB_DIR=%q\n' "$(dirname "${faiss_library}")"
        printf 'export FAISS_LIBNAME=faiss\n'
        printf 'export FAISS_INC=%q\n' "${SOURCE_DIR}"
        printf 'export EXTRA_DEFINES=""\n'
        if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "x86_64" ]]; then
            printf 'export MKLROOT=%q\n' "${MKLROOT}"
            printf 'export MKL_CFLAGS=%q\n' "-I${MKLROOT}/include"
            printf 'export MKL_LIBS=%q\n' "-L${MKL_LIBRARY_DIR} -Wl,-rpath,${MKL_LIBRARY_DIR} -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl"
        else
            printf 'export OPENBLAS_CFLAGS=%q\n' "${OPENBLAS_CFLAGS}"
            printf 'export OPENBLAS_LIBS=%q\n' "${OPENBLAS_LIBS}"
        fi
    } > "${config_file}"
    for algorithm in "${ACTIVE_ALGORITHMS[@]}"; do
        log_message "building original sra_test ${algorithm}_test"
        if ! (cd "${SRA_DIR}" && printf '\n' | make "${algorithm}_test"); then
            log_message "ERROR: sra_test ${algorithm}_test build failed"
            return 40
        fi
    done
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    if ! printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log_message "ERROR: failed to record built Faiss version"
        return 40
    fi
}
