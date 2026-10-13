#!/usr/bin/env bash
# Build matching, unmodified upstream Facebook libraries and a private copy
# of the AccLibBenchmark RPC tool.  No package is installed into /usr/local.
set -euo pipefail

[[ "$#" -eq 5 ]] || { echo 'usage: build_acclib_stack.sh WORK FOLLY_SOURCE FAST_FLOAT VERSION ACCLIB_SOURCE' >&2; exit 2; }
work_dir="$1"
folly_source="$2"
fast_float_dir="$3"
version="$4"
acclib_source="$5"
install_root="${work_dir}/install"
benchmark_dir="${work_dir}/fbthrift_folly_benchmark"
tag="v${version}"
if [[ -n "${PERF_PROXY:-}" ]]; then
    export http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}"
fi

install_dependencies() {
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
        command -v dnf >/dev/null || { echo '[folly] ERROR: dnf is required' >&2; return 30; }
        local dnf_options=()
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        echo "[folly] installing missing build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}"
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"
        fi
    fi
}

clone_tag() {
    local repository="$1" destination="$2"
    if [[ ! -e "${destination}" ]]; then
        echo "[folly] cloning ${repository} ${tag}"
        GIT_TERMINAL_PROMPT=0 git clone --branch "${tag}" --depth 1 --recurse-submodules \
            "${repository}" "${destination}"
    fi
    [[ "$(git -C "${destination}" rev-parse HEAD)" == \
       "$(git -C "${destination}" rev-parse "refs/tags/${tag}^{commit}")" ]] || {
        echo "[folly] ERROR: ${destination} does not match ${tag}" >&2
        return 40
    }
}

cmake_package_dir() {
    local prefix="$1" package="$2" location
    for location in "${prefix}/lib/cmake/${package}" "${prefix}/lib64/cmake/${package}"; do
        [[ ! -d "${location}" ]] || { printf '%s\n' "${location}"; return 0; }
    done
    echo "[folly] ERROR: ${package} CMake package not installed under ${prefix}" >&2
    return 40
}

build_install() {
    local name="$1" source="$2" shift_count=2
    shift "${shift_count}"
    local prefix="${install_root}/${name}"
    local build="${work_dir}/${name}-build"
    echo "[folly] configuring upstream ${name}"
    cmake -S "${source}" -B "${build}" \
        -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF \
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
        -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
        "$@"
    echo "[folly] building and installing upstream ${name}"
    cmake --build "${build}" --parallel "${build_jobs}"
    cmake --install "${build}"
}

install_dependencies
[[ -f "${acclib_source}/fb_folly_autobuild/run.py" ]] || {
    echo "[folly] ERROR: AccLibBenchmark run.py is missing in ${acclib_source}" >&2
    exit 30
}
build_jobs="$(nproc)"
((build_jobs <= 32)) || build_jobs=32
mkdir -p "${install_root}"
export CMAKE_PREFIX_PATH="${install_root}/fbthrift:${install_root}/wangle:${install_root}/fizz:${install_root}/folly"
export LD_LIBRARY_PATH="${install_root}/fbthrift/lib:${install_root}/fbthrift/lib64:${install_root}/wangle/lib:${install_root}/wangle/lib64:${install_root}/fizz/lib:${install_root}/fizz/lib64:${install_root}/folly/lib:${install_root}/folly/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fast_float_args=()
[[ ! -d "${fast_float_dir}/include" ]] || fast_float_args=(-DFASTFLOAT_INCLUDE_DIR="${fast_float_dir}/include")
build_install folly "${folly_source}" "${fast_float_args[@]}"
folly_cmake_dir="$(cmake_package_dir "${install_root}/folly" folly)"

clone_tag https://github.com/facebookincubator/fizz.git "${work_dir}/fizz-source"
build_install fizz "${work_dir}/fizz-source/fizz" -Dfolly_DIR="${folly_cmake_dir}"
fizz_cmake_dir="$(cmake_package_dir "${install_root}/fizz" fizz)"

clone_tag https://github.com/facebook/wangle.git "${work_dir}/wangle-source"
build_install wangle "${work_dir}/wangle-source/wangle" \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}"
wangle_cmake_dir="$(cmake_package_dir "${install_root}/wangle" wangle)"

clone_tag https://github.com/facebook/fbthrift.git "${work_dir}/fbthrift-source"
build_install fbthrift "${work_dir}/fbthrift-source" \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}" \
    -Dwangle_DIR="${wangle_cmake_dir}" -DTHRIFT_ENABLE_ARM_SVE2=OFF

python3 "$(dirname "$0")/prepare_acclib.py" "${acclib_source}" "${benchmark_dir}" \
    "${work_dir}/acclib-compatibility.json"
(cd "${benchmark_dir}" && "${install_root}/fbthrift/bin/thrift1" --gen mstch_cpp2 press.thrift)
echo '[folly] configuring AccLibBenchmark press_server and press_client'
cmake -S "${benchmark_dir}" -B "${benchmark_dir}/build" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
    -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
    -Dfolly_DIR="${folly_cmake_dir}" -Dfizz_DIR="${fizz_cmake_dir}" \
    -Dwangle_DIR="${wangle_cmake_dir}"
cmake --build "${benchmark_dir}/build" --parallel "${build_jobs}" \
    --target press_server press_client
[[ -x "${benchmark_dir}/build/press_server" && -x "${benchmark_dir}/build/press_client" ]] || {
    echo '[folly] ERROR: AccLibBenchmark binaries are missing' >&2
    exit 40
}
echo '[folly] upstream library stack and AccLibBenchmark binaries are ready'
