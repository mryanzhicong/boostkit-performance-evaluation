#!/usr/bin/env bash
# Build the pinned upstream Sysbench client on the host against private MariaDB headers/libs.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  prepare_sysbench.sh WORK_DIRECTORY MARIADB_CONFIG

Builds the pinned upstream Sysbench 1.0.20 client inside WORK_DIRECTORY linked
against the private MariaDB installation.
USAGE
}

if [[ "$#" -ne 2 ]]; then
    usage >&2
    exit 10
fi

work_directory="${1%/}"
mariadb_config="${2}"
mariadb_prefix="$(cd "$(dirname "${mariadb_config}")/.." && pwd)"
sysbench_source_directory="${work_directory}/sysbench-1.0.20"
sysbench_repository="https://github.com/akopytov/sysbench.git"
sysbench_ref="1.0.20"
sysbench_commit="ebf1c90"
luajit_repository="https://github.com/LuaJIT/LuaJIT.git"
luajit_commit="c6ffc141a8762b41703f9287d63d93622a13dd8f"
luajit_source_directory="${work_directory}/luajit-${luajit_commit}"

with_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

for command_name in git make gcc autoreconf libtoolize pkg-config tar; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        printf '[mariadb] ERROR: Sysbench prerequisite is missing: %s\n' "${command_name}" >&2
        exit 30
    fi
done
if [[ ! -x "${mariadb_config}" ]]; then
    printf '[mariadb] ERROR: MariaDB mariadb_config is missing: %s\n' "${mariadb_config}" >&2
    exit 30
fi

# Resolve include and library directories from the private MariaDB prefix.
mariadb_inc_dir=""
if [[ -f "${mariadb_prefix}/include/mysql/mysql.h" ]]; then
    mariadb_inc_dir="${mariadb_prefix}/include/mysql"
elif [[ -f "${mariadb_prefix}/include/mariadb/mysql.h" ]]; then
    mariadb_inc_dir="${mariadb_prefix}/include/mariadb"
else
    mariadb_inc_dir="$("${mariadb_config}" --include 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^-I/) {sub(/^-I/,"",$i); print $i; exit}}')"
fi
mariadb_lib_dir="${mariadb_prefix}/lib"
if [[ ! -d "${mariadb_lib_dir}" && -d "${mariadb_prefix}/lib64" ]]; then
    mariadb_lib_dir="${mariadb_prefix}/lib64"
fi
if [[ -z "${mariadb_inc_dir}" || ! -f "${mariadb_inc_dir}/mysql.h" ]]; then
    printf '[mariadb] ERROR: mysql.h not found under private MariaDB prefix: %s\n' "${mariadb_prefix}" >&2
    exit 30
fi

mkdir -p "${work_directory}"
rm -rf -- "${sysbench_source_directory}"
printf '[mariadb] cloning official Sysbench %s from %s\n' "${sysbench_ref}" "${sysbench_repository}"
with_proxy git clone --quiet --depth 1 --branch "${sysbench_ref}" \
    "${sysbench_repository}" "${sysbench_source_directory}"

actual_commit="$(git -C "${sysbench_source_directory}" rev-parse --short=7 HEAD)"
if [[ "${actual_commit}" != "${sysbench_commit}" ]]; then
    printf '[mariadb] ERROR: Sysbench %s resolved to %s, expected %s\n' \
        "${sysbench_ref}" "${actual_commit}" "${sysbench_commit}" >&2
    exit 30
fi

printf '[mariadb] fetching LuaJIT v2.1 commit %s\n' "${luajit_commit}"
if [[ ! -d "${luajit_source_directory}/.git" ]]; then
    git init -q "${luajit_source_directory}"
    git -C "${luajit_source_directory}" remote add origin "${luajit_repository}"
fi
with_proxy git -C "${luajit_source_directory}" fetch --quiet --depth 1 origin "${luajit_commit}"
git -C "${luajit_source_directory}" checkout --quiet --detach FETCH_HEAD
actual_commit="$(git -C "${luajit_source_directory}" rev-parse HEAD)"
if [[ "${actual_commit}" != "${luajit_commit}" ]]; then
    printf '[mariadb] ERROR: LuaJIT resolved to %s, expected %s\n' "${actual_commit}" "${luajit_commit}" >&2
    exit 30
fi

vendored_luajit="${sysbench_source_directory}/third_party/luajit/luajit"
if [[ ! -d "${vendored_luajit}" ]]; then
    printf '[mariadb] ERROR: Sysbench bundled LuaJIT directory is missing: %s\n' "${vendored_luajit}" >&2
    exit 30
fi
mv -- "${vendored_luajit}" "${vendored_luajit}-bak"
mkdir -p "${vendored_luajit}"
git -C "${luajit_source_directory}" archive --format=tar HEAD | tar -xf - -C "${vendored_luajit}"

sysbench_c="${sysbench_source_directory}/src/sysbench.c"
if [[ "$(grep -c '^#define THREAD_INIT_TIMEOUT 30$' "${sysbench_c}")" -ne 1 ]]; then
    printf '%s\n' '[mariadb] ERROR: expected one upstream THREAD_INIT_TIMEOUT definition' >&2
    exit 30
fi
sed -i 's/^#define THREAD_INIT_TIMEOUT 30$/#define THREAD_INIT_TIMEOUT 300/' "${sysbench_c}"
printf '%s\n' '[mariadb] using pinned LuaJIT v2.1 and a 300-second thread initialization timeout'

# Ensure mysql_config resolves to the private mariadb_config for Sysbench configure discovery.
if [[ ! -x "${mariadb_prefix}/bin/mysql_config" ]]; then
    ln -sf "$(basename "${mariadb_config}")" "${mariadb_prefix}/bin/mysql_config"
fi

printf '[mariadb] building upstream Sysbench %s linked against %s\n' "${sysbench_ref}" "${mariadb_lib_dir}"
(
    cd "${sysbench_source_directory}"
    ./autogen.sh
    PATH="${mariadb_prefix}/bin:${PATH}" \
    LDFLAGS="-Wl,-rpath,${mariadb_lib_dir} ${LDFLAGS:-}" \
        ./configure --with-mysql
    make -j"$(getconf _NPROCESSORS_ONLN)"
)
if [[ ! -x "${sysbench_source_directory}/src/sysbench" ]]; then
    printf '%s\n' '[mariadb] ERROR: Sysbench build did not create src/sysbench' >&2
    exit 40
fi
if LD_LIBRARY_PATH="${mariadb_lib_dir}:${LD_LIBRARY_PATH:-}" \
    ldd "${sysbench_source_directory}/src/sysbench" 2>&1 | grep -q 'not found'; then
    printf '%s\n' '[mariadb] ERROR: host Sysbench binary has unresolved shared libraries' >&2
    exit 40
fi

lua_directory="${sysbench_source_directory}/src/lua"
for workload in read_write read_only write_only; do
    script="${lua_directory}/oltp_${workload}.lua"
    if [[ ! -f "${script}" ]]; then
        printf '[mariadb] ERROR: Sysbench workload script is missing: %s\n' "${script}" >&2
        exit 40
    fi
    if ! LUA_PATH="${lua_directory}/?.lua;;" \
        LD_LIBRARY_PATH="${mariadb_lib_dir}:${LD_LIBRARY_PATH:-}" \
        "${sysbench_source_directory}/src/sysbench" "${script}" help >/dev/null; then
        printf '[mariadb] ERROR: Sysbench cannot load workload script: %s\n' "${script}" >&2
        exit 40
    fi
done

printf '[mariadb] Sysbench %s is ready\n' "${sysbench_ref}"
