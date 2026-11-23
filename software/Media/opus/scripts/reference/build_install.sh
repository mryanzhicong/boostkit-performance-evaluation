#!/usr/bin/env bash
set -euo pipefail
runner=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$runner/bootstrap_env.sh"
root=$(dirname -- "$runner")
source="$root/opus-1.6.1"
archive="$root/opus-1.6.1.tar.gz"
if [[ ! -f "$archive" ]]; then
    curl -fL --retry 3 https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz -o "$archive.part"
    mv -- "$archive.part" "$archive"
fi
printf '%s  %s\n' '6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1' "$archive" | sha256sum -c -
if [[ ! -f "$source/configure" ]]; then
    tar -xzf "$archive" -C "$root"
fi
build="$source/build-fixed-auto"
mkdir -p "$build"
cd -- "$build"
if [[ ! -f .bench-ready ]]; then
    ../configure --enable-fixed-point --enable-shared --enable-extra-programs --disable-doc \
        CFLAGS="-O3 -ffp-contract=off"
    make -j8
    make -j8 check
    touch .bench-ready
fi
grep -q '^#define FIXED_POINT 1' config.h
test -x .libs/opus_demo
