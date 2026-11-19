#!/usr/bin/env bash
# Source this file to prepare component-local build and Python dependencies.
bench_runner=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ "${BENCH_ENV_READY:-}" == "$bench_runner" ]]; then return 0; fi
bench_component=$(basename -- "$(dirname -- "$bench_runner")")
bench_arch=$(uname -m)
bench_cache=${BENCH_CACHE_DIR:-$HOME/.cache/media-bench}
bench_prefix=$bench_runner/.sysroot
mkdir -p "$bench_cache/rpms/$bench_arch" "$bench_cache/wheels/$bench_arch" "$bench_runner/.deps"

bench_download() {
    local url=$1 target=$2
    if [[ -s "$target" ]]; then return 0; fi
    mkdir -p "$(dirname -- "$target")"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --retry 2 --connect-timeout 20 "$url" -o "$target.part.$$"
    else
        python3 - "$url" "$target.part.$$" <<'PY'
import shutil,sys,urllib.request
with urllib.request.urlopen(sys.argv[1],timeout=120) as response,open(sys.argv[2],'wb') as target:
    shutil.copyfileobj(response,target)
PY
    fi
    mv -- "$target.part.$$" "$target"
}

bench_local_rpms() {
    command -v dnf >/dev/null 2>&1 && command -v rpm2cpio >/dev/null 2>&1 && command -v cpio >/dev/null 2>&1 || {
        printf 'ERROR: without root/sudo, RPM deployment needs dnf, rpm2cpio and cpio.\n' >&2
        return 1
    }
    local urls url file
    urls=$(dnf -q repoquery --latest-limit 1 --location "$@")
    [[ -n "$urls" ]] || { printf 'ERROR: no packages found: %s\n' "$*" >&2; return 1; }
    mkdir -p "$bench_prefix"
    while IFS= read -r url; do
        case "$url" in
            https://*.rpm|http://*.rpm)
                file=$bench_cache/rpms/$bench_arch/${url##*/}
                bench_download "$url" "$file"
                rpm --checksig --nosignature "$file" >/dev/null
                (cd -- "$bench_prefix" && rpm2cpio "$file" | cpio -idmu --quiet --no-absolute-filenames) ;;
        esac
    done <<< "$urls"
}

bench_packages() {
    if (( EUID == 0 )); then
        if command -v dnf >/dev/null 2>&1; then dnf install -y "$@"; else yum install -y "$@"; fi
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        if command -v dnf >/dev/null 2>&1; then sudo -n dnf install -y "$@"; else sudo -n yum install -y "$@"; fi
    else
        bench_local_rpms "$@"
    fi
}

if ! command -v python3 >/dev/null 2>&1; then bench_packages python3 python3-pip; fi
export PATH="$bench_runner/.deps/bin:$bench_prefix/usr/bin:$PATH"
export PYTHONPATH="$bench_runner/.deps${PYTHONPATH:+:$PYTHONPATH}"
export CMAKE_PREFIX_PATH="$bench_prefix/usr${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
export PKG_CONFIG_PATH="$bench_prefix/usr/lib64/pkgconfig:$bench_prefix/usr/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export CPATH="$bench_prefix/usr/include${CPATH:+:$CPATH}"
export LIBRARY_PATH="$bench_prefix/usr/lib64:$bench_prefix/usr/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$bench_prefix/usr/lib64:$bench_prefix/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [[ -d "$bench_prefix/usr/libexec/git-core" ]]; then export GIT_EXEC_PATH="$bench_prefix/usr/libexec/git-core"; fi

bench_pip() {
    if ! python3 -m pip --version >/dev/null 2>&1; then
        bench_packages python3-pip
        if ! python3 -m pip --version >/dev/null 2>&1; then
            export PYTHONPATH="$bench_runner/.deps:$bench_prefix/usr/lib/python3.11/site-packages${PYTHONPATH:+:$PYTHONPATH}"
        fi
    fi
    if python3 -m pip install --upgrade --target "$bench_runner/.deps" --no-index \
            --find-links "$bench_cache/wheels/$bench_arch" "$@"; then return 0; fi
    python3 -m pip install --upgrade --target "$bench_runner/.deps" \
        --find-links "$bench_cache/wheels/$bench_arch" \
        --index-url "${BENCH_PYPI_INDEX:-https://mirrors.huaweicloud.com/repository/pypi/simple}" "$@" || \
    python3 -m pip install --upgrade --target "$bench_runner/.deps" --index-url https://pypi.org/simple "$@"
}

bench_torch_cpu() {
    local torch_file="torch-2.9.1+cpu-cp311-cp311-manylinux_2_28_$bench_arch.whl"
    if [[ ! -s "$bench_cache/wheels/$bench_arch/$torch_file" ]]; then
        bench_download "https://download.pytorch.org/whl/cpu/${torch_file/+/%2B}" \
            "$bench_cache/wheels/$bench_arch/$torch_file"
    fi
    bench_pip "torch==2.9.1+cpu" "torchvision==0.24.1" "numpy==2.4.6" "pillow==13.0.0"
}

bench_needed=()
if [[ "$bench_component" != torchvision && "$bench_component" != openvino ]]; then
    for pair in cc:gcc c++:gcc-c++ make:make git:git curl:curl tar:tar xz:xz pkg-config:pkgconf-pkg-config; do
        tool=${pair%%:*}; package=${pair#*:}
        if ! command -v "$tool" >/dev/null 2>&1; then bench_needed+=("$package"); fi
    done
    if [[ "$bench_arch" == x86_64 ]] && ! command -v nasm >/dev/null 2>&1; then bench_needed+=(nasm); fi
fi
if (( ${#bench_needed[@]} )); then bench_packages "${bench_needed[@]}"; fi
if [[ "$bench_component" != torchvision && "$bench_component" != openvino ]] && ! command -v cmake >/dev/null 2>&1; then
    bench_pip cmake==3.29.6
fi
case "$bench_component" in
    libavif|libwebp)
        bench_headers_missing=false
        for bench_header in png.h jpeglib.h zlib.h; do
            if [[ ! -f /usr/include/$bench_header && ! -f "$bench_prefix/usr/include/$bench_header" ]]; then bench_headers_missing=true; fi
        done
        if $bench_headers_missing; then
            bench_packages libpng-devel libjpeg-turbo-devel zlib-devel
        fi ;;
    opencv)
        bench_python_include=$(python3 -c 'import sysconfig; print(sysconfig.get_path("include"))')
        if [[ ! -f "$bench_python_include/Python.h" && ! -f "$bench_prefix/usr/include/python3.11/Python.h" ]]; then
            bench_packages python3-devel
        fi
        if ! python3 -c 'import numpy; assert int(numpy.__version__.split(".")[0]) < 2' >/dev/null 2>&1; then bench_pip numpy==1.24.3; fi ;;
esac
# Resolve developer-package links against the matching installed runtime libraries.
python3 - "$bench_prefix" <<'PY'
from pathlib import Path
import sys
root=Path(sys.argv[1]);lib=root/'usr/lib64'
if lib.is_dir():
    for item in lib.iterdir():
        if item.is_symlink() and not item.exists():
            name=Path(item.readlink()).name;runtime=Path('/usr/lib64')/name;target=lib/name
            if runtime.exists() and not target.exists():target.symlink_to(runtime)
include=root/'usr/include/python3.11'
config=include/'pyconfig-64.h';runtime=Path('/usr/include/python3.11/pyconfig-64.h')
if include.is_dir() and not config.exists() and runtime.exists():config.symlink_to(runtime)
PY
if [[ -f "$bench_prefix/usr/include/python3.11/Python.h" ]]; then
    export PYTHON3_INCLUDE_DIR="$bench_prefix/usr/include/python3.11"
fi
# Shared downloads are optional; every build script still verifies its pinned archive SHA256.
mkdir -p "$bench_runner/../software/downloads"
for bench_archive in "$bench_cache"/downloads/*.tar.gz "$bench_cache"/downloads/*.tar.xz; do
    [[ -f "$bench_archive" ]] || continue
    if [[ "$bench_component" == opus ]]; then
        [[ ${bench_archive##*/} == opus-1.6.1.tar.gz ]] || continue
        bench_destination="$bench_runner/../${bench_archive##*/}"
    else
        bench_destination="$bench_runner/../software/downloads/${bench_archive##*/}"
    fi
    if [[ ! -f "$bench_destination" ]]; then ln -- "$bench_archive" "$bench_destination" 2>/dev/null || cp -- "$bench_archive" "$bench_destination"; fi
done
if [[ "$bench_component" == opus && -f "$bench_cache/materials/speech_orig.wav" ]]; then
    mkdir -p "$bench_runner/.work/audio"
    if [[ ! -f "$bench_runner/.work/audio/speech_orig.wav" ]]; then
        ln "$bench_cache/materials/speech_orig.wav" "$bench_runner/.work/audio/speech_orig.wav" 2>/dev/null || \
            cp "$bench_cache/materials/speech_orig.wav" "$bench_runner/.work/audio/speech_orig.wav"
    fi
fi
export bench_runner bench_component bench_arch bench_cache bench_prefix
export BENCH_ENV_READY="$bench_runner"
export -f bench_pip bench_torch_cpu bench_download bench_packages bench_local_rpms
