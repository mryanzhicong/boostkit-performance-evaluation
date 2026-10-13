#!/usr/bin/env bash
# Build the pinned upstream Sysbench client in this task's private directory.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  prepare_sysbench.sh WORK_DIRECTORY MYSQL_CONFIG

Builds the pinned upstream Sysbench source inside WORK_DIRECTORY.
USAGE
}

if [[ "$#" -ne 2 ]]; then
    usage >&2
    exit 10
fi

work_directory="${1%/}"
mysql_config="${2}"
sysbench_source_directory="${work_directory}/sysbench-1.0.20"
sysbench_repository="https://github.com/akopytov/sysbench.git"
sysbench_ref="1.0.20"
sysbench_commit="ebf1c90"
luajit_repository="https://github.com/LuaJIT/LuaJIT.git"
luajit_commit="c6ffc141a8762b41703f9287d63d93622a13dd8f"
luajit_source_directory="${work_directory}/luajit-${luajit_commit}"

for command_name in git make gcc autoreconf libtoolize pkg-config tar; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        printf '[mysql] ERROR: Sysbench prerequisite is missing: %s\n' \
            "${command_name}" >&2
        exit 30
    fi
done
if [[ ! -x "${mysql_config}" ]]; then
    printf '[mysql] ERROR: MySQL mysql_config is missing: %s\n' "${mysql_config}" >&2
    exit 30
fi
mkdir -p "${work_directory}"
rm -rf -- "${sysbench_source_directory}"
printf '[mysql] cloning official Sysbench %s from %s\n' \
    "${sysbench_ref}" "${sysbench_repository}"
git clone --quiet --depth 1 --branch "${sysbench_ref}" \
    "${sysbench_repository}" "${sysbench_source_directory}"

actual_commit="$(git -C "${sysbench_source_directory}" rev-parse --short=7 HEAD)"
if [[ "${actual_commit}" != "${sysbench_commit}" ]]; then
    printf '[mysql] ERROR: Sysbench %s resolved to %s, expected %s\n' \
        "${sysbench_ref}" "${actual_commit}" "${sysbench_commit}" >&2
    exit 30
fi

printf '[mysql] fetching LuaJIT v2.1 commit %s\n' "${luajit_commit}"
if [[ ! -d "${luajit_source_directory}/.git" ]]; then
    git init -q "${luajit_source_directory}"
    git -C "${luajit_source_directory}" remote add origin "${luajit_repository}"
fi
git -C "${luajit_source_directory}" fetch --quiet --depth 1 origin "${luajit_commit}"
git -C "${luajit_source_directory}" checkout --quiet --detach FETCH_HEAD
actual_commit="$(git -C "${luajit_source_directory}" rev-parse HEAD)"
if [[ "${actual_commit}" != "${luajit_commit}" ]]; then
    printf '[mysql] ERROR: LuaJIT resolved to %s, expected %s\n' \
        "${actual_commit}" "${luajit_commit}" >&2
    exit 30
fi

vendored_luajit="${sysbench_source_directory}/third_party/luajit/luajit"
if [[ ! -d "${vendored_luajit}" ]]; then
    printf '[mysql] ERROR: Sysbench bundled LuaJIT directory is missing: %s\n' \
        "${vendored_luajit}" >&2
    exit 30
fi
mv -- "${vendored_luajit}" "${vendored_luajit}-bak"
mkdir -p "${vendored_luajit}"
git -C "${luajit_source_directory}" archive --format=tar HEAD |
    tar -xf - -C "${vendored_luajit}"

sysbench_c="${sysbench_source_directory}/src/sysbench.c"
if [[ "$(grep -c '^#define THREAD_INIT_TIMEOUT 30$' "${sysbench_c}")" -ne 1 ]]; then
    printf '%s\n' '[mysql] ERROR: expected one upstream THREAD_INIT_TIMEOUT definition' >&2
    exit 30
fi
sed -i 's/^#define THREAD_INIT_TIMEOUT 30$/#define THREAD_INIT_TIMEOUT 300/' "${sysbench_c}"
printf '%s\n' '[mysql] using pinned LuaJIT v2.1 and a 300-second thread initialization timeout'

printf '[mysql] building upstream Sysbench %s with the private LuaJIT and timeout changes\n' \
    "${sysbench_ref}"
(
    cd "${sysbench_source_directory}"
    ./autogen.sh
    PATH="$(dirname "${mysql_config}"):${PATH}" ./configure --with-mysql
    make -j"$(getconf _NPROCESSORS_ONLN)"
)
if [[ ! -x "${sysbench_source_directory}/src/sysbench" ]]; then
    printf '%s\n' '[mysql] ERROR: Sysbench build did not create src/sysbench' >&2
    exit 40
fi

lua_directory="${sysbench_source_directory}/src/lua"
for workload in read_write read_only write_only; do
    script="${lua_directory}/oltp_${workload}.lua"
    if [[ ! -f "${script}" ]]; then
        printf '[mysql] ERROR: Sysbench workload script is missing: %s\n' "${script}" >&2
        exit 40
    fi
    if ! LUA_PATH="${lua_directory}/?.lua;;" \
        "${sysbench_source_directory}/src/sysbench" "${script}" help >/dev/null; then
        printf '[mysql] ERROR: Sysbench cannot load workload script: %s\n' "${script}" >&2
        exit 40
    fi
done

printf '[mysql] Sysbench %s is ready\n' "${sysbench_ref}"
