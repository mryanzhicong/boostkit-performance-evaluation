#!/usr/bin/env bash
# Prepare the client-side dependencies used by database_blue's Sysbench 1.0
# scripts.  The database_blue scripts themselves are not changed: they retain
# their original fixed paths under /home/automation and /tmp/dataCollection.

set -euo pipefail

LEGACY_SYSBENCH_PATH="/home/automation/client/soft/sysbench-1.0.17"
LEGACY_DATA_COLLECTION_PATH="/tmp/dataCollection/dataCollect.sh"
LEGACY_REPORT_DIRECTORY="/home/automation/client/report/sysbench"

usage() {
    cat <<'USAGE'
Usage:
  prepare_database_blue_tools.sh WORK_DIRECTORY MYSQL_CONFIG
  prepare_database_blue_tools.sh --cleanup WORK_DIRECTORY

Builds the pinned Sysbench source required by database_blue's MySQL 1.0 suite
and exposes it through that suite's original fixed paths.  --cleanup removes
only the symlinks created for the supplied work directory.
USAGE
}

remove_owned_symlink() {
    local legacy_path="$1"
    local expected_target="$2"
    local actual_target

    if [[ ! -L "${legacy_path}" ]]; then
        return 0
    fi
    actual_target="$(readlink -f "${legacy_path}")"
    if [[ "${actual_target}" == "${expected_target}" ]]; then
        sudo -n rm -f -- "${legacy_path}"
    fi
}

if [[ "${1:-}" == "--cleanup" ]]; then
    if [[ "$#" -ne 2 ]]; then
        usage >&2
        exit 10
    fi
    work_directory="${2%/}"
    remove_owned_symlink \
        "${LEGACY_SYSBENCH_PATH}" \
        "${work_directory}/sysbench-1.0.17"
    remove_owned_symlink \
        "${LEGACY_DATA_COLLECTION_PATH}" \
        "${work_directory}/data-collection/dataCollect.sh"
    exit 0
fi

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

for command_name in git make gcc autoreconf libtoolize pkg-config sudo; do
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
if ! sudo -n true; then
    printf '%s\n' \
        '[mysql] ERROR: passwordless sudo is required for database_blue legacy paths' >&2
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

for legacy_path in "${LEGACY_SYSBENCH_PATH}" "${LEGACY_DATA_COLLECTION_PATH}"; do
    if [[ -e "${legacy_path}" && ! -L "${legacy_path}" ]]; then
        printf '[mysql] ERROR: refusing to replace existing path: %s\n' \
            "${legacy_path}" >&2
        exit 30
    fi
done
if [[ -L "${LEGACY_SYSBENCH_PATH}" ]] && \
   [[ "$(readlink -f "${LEGACY_SYSBENCH_PATH}")" != "${sysbench_source_directory}" ]]; then
    printf '[mysql] ERROR: legacy Sysbench path belongs to another task: %s\n' \
        "${LEGACY_SYSBENCH_PATH}" >&2
    exit 30
fi
if [[ -L "${LEGACY_DATA_COLLECTION_PATH}" ]] && \
   [[ "$(readlink -f "${LEGACY_DATA_COLLECTION_PATH}")" != "${data_collection_script}" ]]; then
    printf '[mysql] ERROR: legacy data collection path belongs to another task: %s\n' \
        "${LEGACY_DATA_COLLECTION_PATH}" >&2
    exit 30
fi

sudo -n mkdir -p "$(dirname "${LEGACY_SYSBENCH_PATH}")" \
    "$(dirname "${LEGACY_DATA_COLLECTION_PATH}")"
if [[ ! -L "${LEGACY_SYSBENCH_PATH}" ]]; then
    sudo -n ln -s "${sysbench_source_directory}" "${LEGACY_SYSBENCH_PATH}"
fi
if [[ ! -L "${LEGACY_DATA_COLLECTION_PATH}" ]]; then
    sudo -n ln -s "${data_collection_script}" "${LEGACY_DATA_COLLECTION_PATH}"
fi
if [[ ! -d "${LEGACY_REPORT_DIRECTORY}" ]]; then
    sudo -n mkdir -p "${LEGACY_REPORT_DIRECTORY}"
    sudo -n chown "$(id -u):$(id -g)" "${LEGACY_REPORT_DIRECTORY}"
elif [[ ! -w "${LEGACY_REPORT_DIRECTORY}" ]]; then
    printf '[mysql] ERROR: database_blue report directory is not writable: %s\n' \
        "${LEGACY_REPORT_DIRECTORY}" >&2
    exit 30
fi
printf '[mysql] database_blue Sysbench tools are ready\n'
