#!/usr/bin/env bash
# Build the pinned upstream folly/fizz/wangle/fbthrift stack and the
# AccLibBenchmark RPC binaries with clang 16.  Executed inside the private
# openEuler container; only the task work dir is written.
set -euo pipefail

[[ "$#" -eq 6 ]] || { echo 'usage: build_acclib_stack.sh WORK FOLLY_SOURCE FAST_FLOAT VERSION ACCLIB_SOURCE CLANG_ROOT' >&2; exit 2; }
work_dir="$1"
folly_source="$2"
fast_float_dir="$3"
version="$4"
acclib_source="$5"
clang_root="$6"
install_root="${work_dir}/install"
benchmark_dir="${work_dir}/fbthrift_folly_benchmark"
tag="v${version}"
cc="${clang_root}/bin/clang"
cxx="${clang_root}/bin/clang++"
[[ -x "${cc}" && -x "${cxx}" ]] || { echo "[fbthrift] ERROR: clang ${version} is missing under ${clang_root}" >&2; exit 30; }
export CC="${cc}" CXX="${cxx}"
if [[ -n "${PERF_PROXY:-}" ]]; then
    export http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}"
fi

install_dependencies() {
    [[ "${FBTHRIFT_SKIP_DNF:-0}" == 1 ]] && return 0
    local package
    local packages=()
    for package in git cmake make gcc gcc-c++ python3 gflags-devel glog-devel \
        fmt-devel libevent-devel double-conversion-devel boost-devel \
        libunwind-devel lz4-devel zstd-devel libsodium-devel liburing-devel \
        openssl-devel zlib-devel snappy-devel gtest-devel gmock-devel \
        libaio-devel libatomic; do
        rpm -q "${package}" >/dev/null 2>&1 || packages+=("${package}")
    done
    if ((${#packages[@]})); then
        command -v dnf >/dev/null || { echo '[fbthrift] ERROR: dnf is required' >&2; return 30; }
        local dnf_options=()
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        echo "[fbthrift] installing missing build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y "${packages[@]}"
        else
            sudo -n dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y "${packages[@]}"
        fi
    fi
}

clone_tag() {
    local repository="$1" destination="$2"
    # Sources are cloned and tag-verified on the host; the container has no git
    # (the openEuler git package drags in systemd, whose scriptlets cannot run in
    # this rootless container), so it only reuses the prepared checkouts.
    if [[ "${FBTHRIFT_SKIP_GIT:-0}" == 1 && -d "${destination}/.git" ]]; then
        return 0
    fi
    if [[ ! -e "${destination}" ]]; then
        echo "[fbthrift] cloning ${repository} ${tag}"
        GIT_TERMINAL_PROMPT=0 git clone --branch "${tag}" --depth 1 --recurse-submodules \
            "${repository}" "${destination}"
    fi
    [[ "$(git -C "${destination}" rev-parse HEAD)" == \
       "$(git -C "${destination}" rev-parse "refs/tags/${tag}^{commit}")" ]] || {
        echo "[fbthrift] ERROR: ${destination} does not match ${tag}" >&2
        return 40
    }
}

cmake_package_dir() {
    local prefix="$1" package="$2" location
    for location in "${prefix}/lib/cmake/${package}" "${prefix}/lib64/cmake/${package}"; do
        [[ ! -d "${location}" ]] || { printf '%s\n' "${location}"; return 0; }
    done
    echo "[fbthrift] ERROR: ${package} CMake package not installed under ${prefix}" >&2
    return 40
}

build_install() {
    local name="$1" source="$2"
    shift 2
    local prefix="${install_root}/${name}"
    local build="${work_dir}/${name}-build"
    echo "[fbthrift] configuring upstream ${name} with clang 16"
    cmake -S "${source}" -B "${build}" \
        -DCMAKE_C_COMPILER="${cc}" -DCMAKE_CXX_COMPILER="${cxx}" \
        -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF \
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
        -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
        "${toolchain_flags[@]}" \
        "$@"
    echo "[fbthrift] building and installing upstream ${name}"
    cmake --build "${build}" --parallel "${build_jobs}"
    cmake --install "${build}"
}

install_dependencies
[[ -f "${acclib_source}/fbthrift_folly_benchmark/CMakeLists.txt" ]] || {
    echo "[fbthrift] ERROR: AccLibBenchmark fbthrift_folly_benchmark is missing in ${acclib_source}" >&2
    exit 30
}
build_jobs="$(nproc)"
# clang16 needs the openEuler GCC installation for crtbeginS.o / libstdc++.
# The official LLVM tarball bundles the compiler but not the target GCC, and a
# distro clang has host paths compiled in; naming the directory explicitly keeps
# both variants working inside the container.
gcc_install_dir=""
gcc_machine="$(gcc -dumpmachine 2>/dev/null || true)"
gcc_version="$(gcc -dumpversion 2>/dev/null || true)"
if [[ -n "${gcc_machine}" && -n "${gcc_version}" && -d "/usr/lib/gcc/${gcc_machine}/${gcc_version}" ]]; then
    gcc_install_dir="/usr/lib/gcc/${gcc_machine}/${gcc_version}"
fi
toolchain_flags=()
if [[ -n "${gcc_install_dir}" ]]; then
    toolchain_flags=(-DCMAKE_C_FLAGS="--gcc-install-dir=${gcc_install_dir}"
                     -DCMAKE_CXX_FLAGS="--gcc-install-dir=${gcc_install_dir}")
    echo "[fbthrift] using GCC installation ${gcc_install_dir} for clang16"
fi
# folly's FindLibUnwind reports a package-name mismatch (LIBUNWIND vs LibUnwind) and
# on aarch64 openEuler the resulting libfolly.so keeps unresolved libunwind symbols
# (unw_backtrace/_ULaarch64_*), so every executable that links libfolly.so fails.
# Disabling the optional libunwind detection makes folly use its glibc backtrace
# fallback: the symbolizer is not part of this RPC benchmark, and the link is then
# identical on both architectures.
toolchain_flags+=(-DCMAKE_DISABLE_FIND_PACKAGE_LibUnwind=ON)
((build_jobs <= 32)) || build_jobs=32
mkdir -p "${install_root}"
export CMAKE_PREFIX_PATH="${install_root}/fbthrift:${install_root}/wangle:${install_root}/fizz:${install_root}/folly"
export LD_LIBRARY_PATH="${clang_root}/lib:${install_root}/fbthrift/lib:${install_root}/fbthrift/lib64:${install_root}/wangle/lib:${install_root}/wangle/lib64:${install_root}/fizz/lib:${install_root}/fizz/lib64:${install_root}/folly/lib:${install_root}/folly/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fast_float_args=()
[[ ! -d "${fast_float_dir}/include" ]] || fast_float_args=(-DFASTFLOAT_INCLUDE_DIR="${fast_float_dir}/include")
folly_target_arch="$("${cc}" -dumpmachine)"
[[ -n "${folly_target_arch}" ]] || { echo '[fbthrift] ERROR: compiler target architecture is empty' >&2; exit 40; }
build_install folly "${folly_source}" \
    -DCMAKE_LIBRARY_ARCHITECTURE="${folly_target_arch}" "${fast_float_args[@]}"
folly_cmake_dir="$(cmake_package_dir "${install_root}/folly" folly)"

clone_tag https://github.com/facebookincubator/fizz.git "${work_dir}/fizz-source"
build_install fizz "${work_dir}/fizz-source/fizz" -Dfolly_DIR="${folly_cmake_dir}"
fizz_cmake_dir="$(cmake_package_dir "${install_root}/fizz" fizz)"

clone_tag https://github.com/facebook/wangle.git "${work_dir}/wangle-source"
build_install wangle "${work_dir}/wangle-source/wangle" \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}"
wangle_cmake_dir="$(cmake_package_dir "${install_root}/wangle" wangle)"

clone_tag https://github.com/facebook/fbthrift.git "${work_dir}/fbthrift-source"
# The wiki requests THRIFT_ENABLE_ARM_SVE2=ON; upstream v2022.11.14.00 does not
# define that option (it is a Huawei-fork feature), so CMake records it as an
# unused variable and the build stays on the upstream scalar path.
build_install fbthrift "${work_dir}/fbthrift-source" \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}" \
    -Dwangle_DIR="${wangle_cmake_dir}" -DTHRIFT_ENABLE_ARM_SVE2=ON

python3 "$(dirname "$0")/prepare_benchmark.py" "${acclib_source}" "${benchmark_dir}" \
    "${work_dir}/acclib-compatibility.json"
(cd "${benchmark_dir}" && "${install_root}/fbthrift/bin/thrift1" --gen mstch_cpp2 press.thrift)
echo '[fbthrift] configuring AccLibBenchmark press_server and press_client'
cmake -S "${benchmark_dir}" -B "${benchmark_dir}/build" \
    -DCMAKE_C_COMPILER="${cc}" -DCMAKE_CXX_COMPILER="${cxx}" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
    -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
    "${toolchain_flags[@]}" \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}" \
    -Dwangle_DIR="${wangle_cmake_dir}"
cmake --build "${benchmark_dir}/build" --parallel "${build_jobs}" \
    --target press_server press_client
[[ -x "${benchmark_dir}/build/press_server" && -x "${benchmark_dir}/build/press_client" ]] || {
    echo '[fbthrift] ERROR: AccLibBenchmark binaries are missing' >&2
    exit 40
}
echo '[fbthrift] upstream stack and AccLibBenchmark binaries are ready'
