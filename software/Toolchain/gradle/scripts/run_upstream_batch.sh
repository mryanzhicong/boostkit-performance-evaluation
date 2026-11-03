#!/usr/bin/env bash
# Build every pinned upstream sample project once, in a fixed order.
# Invoked by the test stage through scripts/run_timed.py so that the whole batch
# is one measured unit (outer wall time and peak RSS of the process tree).
#
# Before every build the sample directory is reset deterministically: build
# outputs and the per-project Gradle caches are removed, so each repetition
# performs the same full multi-module build instead of an incremental one.
set -euo pipefail

: "${GRADLE_BIN:?GRADLE_BIN is required}"
: "${GRADLE_USER_HOME:?GRADLE_USER_HOME is required}"
: "${GRADLE_UPSTREAM_SAMPLE_LIST:?GRADLE_UPSTREAM_SAMPLE_LIST is required}"
: "${UPSTREAM_WORK_DIR:?UPSTREAM_WORK_DIR is required}"

# shellcheck disable=SC2206
GRADLE_FLAGS=(${GRADLE_FLAGS:-})
OFFLINE_FLAGS=()
if [[ "${GRADLE_BATCH_OFFLINE:-1}" == "1" ]]; then
    OFFLINE_FLAGS+=(--offline)
fi
SAMPLE_EXIT=0

while IFS= read -r sample; do
    [[ -n "${sample}" ]] || continue
    directory="${UPSTREAM_WORK_DIR}/$(printf '%s' "${sample}" | tr '/' '_')"
    printf '== upstream sample: %s ==\n' "${sample}"
    if [[ ! -d "${directory}" ]]; then
        printf '== sample done: %s rc=2 ==\n' "${sample}"
        SAMPLE_EXIT=2
        continue
    fi
    find "${directory}" -type d \( -name build -o -name .gradle \) -prune -exec rm -rf {} +
    rc=0
    (
        cd "${directory}" || exit 1
        "${GRADLE_BIN}" "${GRADLE_FLAGS[@]}" "${OFFLINE_FLAGS[@]}" build
    ) || rc=$?
    printf '== sample done: %s rc=%s ==\n' "${sample}" "${rc}"
    if [[ "${rc}" -ne 0 ]]; then
        SAMPLE_EXIT="${rc}"
    fi
done <<<"${GRADLE_UPSTREAM_SAMPLE_LIST}"

exit "${SAMPLE_EXIT}"
