#!/usr/bin/env bash
# Prepare the client-side dependencies used by database_blue's Sysbench 1.0
# scripts. The caller updates its per-task script copy to use these paths.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  prepare_database_blue_tools.sh WORK_DIRECTORY MYSQL_CONFIG

Builds the pinned Sysbench source required by database_blue's MySQL 1.0 suite
inside WORK_DIRECTORY.
USAGE
}

if [[ "$#" -ne 2 ]]; then
    usage >&2
    exit 10
fi

work_directory="${1%/}"
mysql_config="${2}"
sysbench_source_directory="${work_directory}/sysbench-1.0.17"
data_collection_directory="${work_directory}/data-collection"
data_collection_script="${data_collection_directory}/dataCollect.sh"
sysbench_repository="${DATABASE_BLUE_SYSBENCH_REPOSITORY:-https://github.com/akopytov/sysbench.git}"
sysbench_ref="${DATABASE_BLUE_SYSBENCH_REF:-1.0.17}"
sysbench_commit="${DATABASE_BLUE_SYSBENCH_COMMIT:-d634bce}"

for command_name in git make gcc autoreconf libtoolize pkg-config; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        printf '[mysql] ERROR: database_blue Sysbench prerequisite is missing: %s\n' \
            "${command_name}" >&2
        printf '%s\n' \
            '[mysql] ERROR: the workflow must install the MySQL Sysbench build dependencies first' >&2
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

printf '[mysql] building official Sysbench %s\n' "${sysbench_ref}"
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

mkdir -p "${data_collection_directory}"
cat > "${data_collection_script}" <<'EOF'
#!/usr/bin/env bash
# database_blue calls data_record only after a Sysbench scenario completes.
# The public database_blue tree does not contain its original data-collection
# implementation.  Results are retained by the framework instead, so this
# compatibility definition intentionally has no side effects.
data_record() {
    return 0
}
EOF
chmod 0644 "${data_collection_script}"

printf '[mysql] database_blue Sysbench tools are ready\n'
