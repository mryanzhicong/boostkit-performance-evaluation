#!/usr/bin/env bash
# Start stage: generate and verify the deterministic RESP fixtures inside the
# private container, confirm the harnesses run there, and record whether
# measurements can run offline from inside that container.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

detect_network_mode() {
    # The probe runs inside the private container so it describes exactly where
    # the measured process tree will run.
    if hiredis_container_exec sh -c 'command -v unshare >/dev/null 2>&1 && unshare -n true' >/dev/null 2>&1; then
        printf 'unshare\n'
        return 0
    fi
    printf 'unavailable\n'
}

verify_fixtures() {
    local manifest="${HIREDIS_FIXTURE_MANIFEST}"
    if [[ ! -s "${manifest}" ]]; then
        fail_message "fixture manifest is missing: ${manifest}"
        return 20
    fi
    python3 - "${manifest}" "${HIREDIS_FIXTURES_DIR}" \
        "${HIREDIS_FIXTURE_PIPELINE_BYTES}" "${HIREDIS_FIXTURE_PIPELINE_REPLIES}" "${HIREDIS_FIXTURE_PIPELINE_SHA256}" \
        "${HIREDIS_FIXTURE_BULK_BYTES}" "${HIREDIS_FIXTURE_BULK_REPLIES}" "${HIREDIS_FIXTURE_BULK_SHA256}" \
        "${HIREDIS_FIXTURE_NESTED_BYTES}" "${HIREDIS_FIXTURE_NESTED_REPLIES}" "${HIREDIS_FIXTURE_NESTED_SHA256}" \
        "${HIREDIS_FIXTURE_MIXED_BYTES}" "${HIREDIS_FIXTURE_MIXED_REPLIES}" "${HIREDIS_FIXTURE_MIXED_SHA256}" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

(
    manifest_path,
    fixture_dir,
    pipeline_bytes, pipeline_replies, pipeline_sha,
    bulk_bytes, bulk_replies, bulk_sha,
    nested_bytes, nested_replies, nested_sha,
    mixed_bytes, mixed_replies, mixed_sha,
) = sys.argv[1:]
fixture_dir = Path(fixture_dir)
manifest = json.loads(Path(manifest_path).read_text(encoding="utf-8"))
pins = {
    "pipeline_get.resp": (int(pipeline_bytes), int(pipeline_replies), pipeline_sha),
    "bulk_256k.resp": (int(bulk_bytes), int(bulk_replies), bulk_sha),
    "nested_arrays.resp": (int(nested_bytes), int(nested_replies), nested_sha),
    "mixed_types.resp": (int(mixed_bytes), int(mixed_replies), mixed_sha),
}


def fail(message: str) -> None:
    print(f"[hiredis-start] ERROR: {message}", file=sys.stderr)
    raise SystemExit(20)


streams = manifest.get("streams")
if not isinstance(streams, dict):
    fail("fixture manifest has no stream table")
for name, (expected_bytes, expected_replies, expected_sha) in pins.items():
    path = fixture_dir / name
    if not path.is_file():
        fail(f"fixture is missing: {path}")
    actual_bytes = path.stat().st_size
    if actual_bytes != expected_bytes:
        fail(f"{name}: size {actual_bytes} != pinned {expected_bytes}")
    entry = streams.get(name)
    if not isinstance(entry, dict):
        fail(f"{name}: missing from the fixture manifest")
    if int(entry.get("bytes", -1)) != expected_bytes:
        fail(f"{name}: manifest byte count differs from the pinned value")
    if int(entry.get("replies", -1)) != expected_replies:
        fail(f"{name}: manifest reply count differs from the pinned value")
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    if digest.hexdigest() != expected_sha:
        fail(f"{name}: SHA-256 {digest.hexdigest()} != pinned {expected_sha}")
    if entry.get("sha256") != expected_sha:
        fail(f"{name}: manifest SHA-256 differs from the pinned value")
    # Structural sanity: a RESP stream of replies must end with a CRLF and start
    # with a reply type byte.
    with path.open("rb") as handle:
        first = handle.read(1)
        handle.seek(-2, 2)
        tail = handle.read(2)
    if first not in b"+-:$*%>~#,":
        fail(f"{name}: does not start with a RESP type byte")
    if tail != b"\r\n":
        fail(f"{name}: does not end with CRLF")

print("[hiredis-start] RESP fixtures and manifest match the pinned values")
PY
    return $?
}

verify_harnesses() {
    local binary
    for binary in "${HIREDIS_BENCH_BIN}" "${HIREDIS_UPSTREAM_BIN}" "${HIREDIS_NETNS_PREP}"; do
        if ! hiredis_container_exec test -x "${binary}"; then
            fail_message "benchmark harness binary or the netns launcher is missing: ${binary}"
            return 20
        fi
    done
    local version
    version="$(hiredis_container_exec "${HIREDIS_BENCH_BIN}" --version 2>/dev/null || true)"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "harness reports hiredis ${version}, expected ${SOFTWARE_VERSION}"
        return 20
    fi
    if ! hiredis_container_exec "${HIREDIS_UPSTREAM_BIN}" > "${HIREDIS_STATE_DIR}/upstream-selftest.log" 2>&1; then
        fail_message "upstream local-test runner fails its self-check, see ${HIREDIS_STATE_DIR}/upstream-selftest.log"
        return 20
    fi
    return 0
}

start_hiredis_runtime() {
    validate_variant || return $?
    validate_version || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    initialize_runtime || return $?

    check_hiredis_container || return $?

    verify_harnesses || return $?

    log_message "generating deterministic RESP fixtures inside the private container"
    hiredis_container_exec python3 "${SCRIPTS_DIR}/fixtures/generate_resp_fixtures.py" "${HIREDIS_FIXTURES_DIR}" > \
        "${HIREDIS_STATE_DIR}/fixtures.log" 2>&1 || {
        fail_message "fixture generation failed, see ${HIREDIS_STATE_DIR}/fixtures.log"
        return 20
    }
    verify_fixtures || return $?

    local network_mode
    network_mode="$(detect_network_mode)"
    mkdir -p "$(dirname "${HIREDIS_OFFLINE_DIR_MODE_FILE}")"
    printf '%s\n' "${network_mode}" > "${HIREDIS_OFFLINE_DIR_MODE_FILE}"
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: network namespace isolation (unshare -n) is unavailable inside the container (unprivileged user namespaces disabled); continuing with network mode '${network_mode}'"
        log_message "WARNING: the measured workload uses no network and all fixtures are pinned by SHA-256, so results remain reproducible; recorded in the run context"
    else
        log_message "offline measurement verified: unshare -n is available inside the private container"
    fi

    log_message "start stage ready (network mode: ${network_mode}, container: ${HIREDIS_CONTAINER_NAME})"
    return 0
}
