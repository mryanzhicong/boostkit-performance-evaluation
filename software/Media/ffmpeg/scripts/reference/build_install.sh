#!/usr/bin/env bash
set -euo pipefail
runner=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$runner/bootstrap_env.sh"
root=$(dirname -- "$runner")
case "$(uname -s):$(uname -m)" in Linux:aarch64|Linux:x86_64) ;; *) printf 'ERROR: Linux AArch64/x86_64 required.\n' >&2; exit 1 ;; esac
for tool in cc make python3 pkg-config curl tar; do command -v "$tool" >/dev/null; done
if [[ $(uname -m) == x86_64 ]]; then command -v nasm >/dev/null; fi
software="$root/software"
archive="$software/downloads/ffmpeg-7.1.1.tar.gz"
src="$software/ffmpeg-7.1.1"
install="$src/ffmpeg_install"
export LD_LIBRARY_PATH="$install/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
key=$( { uname -m; cc -dumpmachine; cc -dumpversion; sha256sum "$runner/build_install.sh"; } | sha256sum | cut -d' ' -f1)
if [[ -f "$install/.stock-ready" && $(cat "$install/.stock-ready") == "$key" && -x "$install/bin/ffmpeg" ]]; then
    "$install/bin/ffmpeg" -version
    exit 0
fi
mkdir -p "$(dirname -- "$archive")"
if [[ ! -f "$archive" ]]; then
    curl --fail --location --retry 2 https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.gz -o "$archive.tmp"
    mv -- "$archive.tmp" "$archive"
fi
printf '9a6e57a446b671012612aaeb9df5126794d5ac8f2015ca220934f99a6a4e0601  %s\n' "$archive" | sha256sum -c -
if [[ ! -f "$src/configure" ]]; then
    mkdir -p "$src"
    tar -xzf "$archive" --strip-components=1 -C "$src"
fi
cd -- "$src"
./configure --prefix="$install" --enable-shared --disable-debug --disable-doc \
    --disable-autodetect --disable-everything --enable-ffmpeg --enable-ffprobe \
    --enable-protocol=file,pipe --enable-demuxer=rawvideo --enable-decoder=rawvideo \
    --enable-encoder=rawvideo --enable-muxer=rawvideo,hash \
    --enable-filter=scale,format,null,psnr,setpts --enable-swscale \
    --extra-cflags="-O3 -ffp-contract=off" --extra-ldflags="-Wl,-O3"
make -j8
make install
"$install/bin/ffmpeg" -version
printf '%s\n' "$key" > "$install/.stock-ready"
