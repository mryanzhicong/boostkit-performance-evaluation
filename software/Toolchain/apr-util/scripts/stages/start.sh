#!/usr/bin/env bash
# Start stage: generate and verify the deterministic base64 payloads, confirm
# the harnesses and the upstream test program run, and record whether the
# measurements can run offline.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

detect_network_mode() {
    if command -v unshare >/dev/null 2>&1 && unshare -n true >/dev/null 2>&1; then
        printf 'unshare\n'
        return 0
    fi
    printf 'unavailable\n'
}

verify_payloads() {
    local manifest="${APR_UTIL_FIXTURE_MANIFEST}"
    if [[ ! -s "${manifest}" ]]; then
        fail_message "payload manifest is missing: ${manifest}"
        return 20
    fi
    python3 - "${manifest}" "${APR_UTIL_FIXTURES_DIR}" \
        "${APR_UTIL_PAYLOAD_64B_BYTES}" "${APR_UTIL_PAYLOAD_64B_SHA256}" \
        "${APR_UTIL_PAYLOAD_1KIB_BYTES}" "${APR_UTIL_PAYLOAD_1KIB_SHA256}" \
        "${APR_UTIL_PAYLOAD_64KIB_BYTES}" "${APR_UTIL_PAYLOAD_64KIB_SHA256}" \
        "${APR_UTIL_PAYLOAD_1MIB_BYTES}" "${APR_UTIL_PAYLOAD_1MIB_SHA256}" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

(
    manifest_path,
    fixture_dir,
    bytes_64b, sha_64b,
    bytes_1kib, sha_1kib,
    bytes_64kib, sha_64kib,
    bytes_1mib, sha_1mib,
) = sys.argv[1:]
fixture_dir = Path(fixture_dir)
manifest = json.loads(Path(manifest_path).read_text(encoding="utf-8"))
pins = {
    "payload_64.bin": (int(bytes_64b), sha_64b),
    "payload_1024.bin": (int(bytes_1kib), sha_1kib),
    "payload_65536.bin": (int(bytes_64kib), sha_64kib),
    "payload_1048576.bin": (int(bytes_1mib), sha_1mib),
}


def fail(message: str) -> None:
    print(f"[apr-util-start] ERROR: {message}", file=sys.stderr)
    raise SystemExit(20)


payloads = manifest.get("payloads")
if not isinstance(payloads, dict):
    fail("payload manifest has no payload table")
for name, (expected_bytes, expected_sha) in pins.items():
    path = fixture_dir / name
    if not path.is_file():
        fail(f"payload is missing: {path}")
    actual_bytes = path.stat().st_size
    if actual_bytes != expected_bytes:
        fail(f"{name}: size {actual_bytes} != pinned {expected_bytes}")
    entry = payloads.get(name)
    if not isinstance(entry, dict):
        fail(f"{name}: missing from the payload manifest")
    if int(entry.get("bytes", -1)) != expected_bytes:
        fail(f"{name}: manifest byte count differs from the pinned value")
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    if digest.hexdigest() != expected_sha:
        fail(f"{name}: SHA-256 {digest.hexdigest()} != pinned {expected_sha}")
    if entry.get("sha256") != expected_sha:
        fail(f"{name}: manifest SHA-256 differs from the pinned value")
    # Every payload is deterministic pseudo-random bytes; a fully uniform
    # payload would hide encoder bugs, so require some byte diversity.
    sample = path.read_bytes()[:4096]
    minimum_distinct = min(48, len(sample))
    if len(set(sample)) < minimum_distinct:
        fail(f"{name}: payload does not look pseudorandom")

print("[apr-util-start] base64 payloads and manifest match the pinned values")
PY
    return $?
}

verify_harnesses() {
    if [[ ! -x "${APR_UTIL_BENCH_BIN}" || ! -x "${APR_UTIL_TESTALL_BIN}" || \
          ! -x "${APR_UTIL_NETNS_PREP}" ]]; then
        fail_message "benchmark harness, upstream testall or netns launcher are missing"
        return 20
    fi
    local reported
    reported="$("${APR_UTIL_BENCH_BIN}" --version 2>/dev/null || true)"
    if [[ -z "${reported}" ]]; then
        fail_message "the harness does not report its APR-util/APR versions"
        return 20
    fi
    local apu_version apr_version
    apu_version="${reported#*apu=}"
    apu_version="${apu_version%% *}"
    apr_version="${reported#*apr=}"
    apr_version="${apr_version%% *}"
    if [[ "${apu_version}" != "${SOFTWARE_VERSION}" || "${apr_version}" != "1.7.5" ]]; then
        fail_message "harness reports APR-util ${apu_version} / APR ${apr_version}, expected ${SOFTWARE_VERSION} / 1.7.5"
        return 20
    fi

    log_message "running the upstream testall self-check"
    (
        cd "${APR_UTIL_TESTALL_CWD}" || exit 1
        "${APR_UTIL_TESTALL_BIN}"
    ) > "${APR_UTIL_STATE_DIR}/testall-selftest.log" 2>&1 || {
        fail_message "the upstream testall self-check failed, see ${APR_UTIL_STATE_DIR}/testall-selftest.log"
        tail -40 "${APR_UTIL_STATE_DIR}/testall-selftest.log" >&2 || true
        return 20
    }
    if ! grep -q '^All tests passed\.$' "${APR_UTIL_STATE_DIR}/testall-selftest.log"; then
        fail_message "the upstream testall self-check did not report success"
        tail -40 "${APR_UTIL_STATE_DIR}/testall-selftest.log" >&2 || true
        return 20
    fi
    local modules
    modules="$(grep -c ':  SUCCESS$' "${APR_UTIL_STATE_DIR}/testall-selftest.log" || true)"
    if [[ "${modules}" != "${APR_UTIL_EXPECT_TESTALL_MODULES}" ]]; then
        fail_message "upstream testall passed ${modules} modules, expected ${APR_UTIL_EXPECT_TESTALL_MODULES}"
        return 20
    fi
    return 0
}

start_apr_util_runtime() {
    validate_variant || return $?
    validate_version || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    initialize_runtime || return $?

    verify_harnesses || return $?
    if ! command -v python3 >/dev/null 2>&1; then
        fail_message "python3 is required for payload generation and result parsing"
        return 20
    fi

    log_message "generating deterministic base64 payloads in ${APR_UTIL_FIXTURES_DIR}"
    python3 "${SCRIPTS_DIR}/fixtures/generate_payloads.py" "${APR_UTIL_FIXTURES_DIR}" > \
        "${APR_UTIL_STATE_DIR}/fixtures.log" 2>&1 || {
        fail_message "payload generation failed, see ${APR_UTIL_STATE_DIR}/fixtures.log"
        return 20
    }
    verify_payloads || return $?

    local network_mode
    network_mode="$(detect_network_mode)"
    printf '%s\n' "${network_mode}" > "${APR_UTIL_OFFLINE_DIR_MODE_FILE}"
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: network namespace isolation (unshare -n) is unavailable on this runner (unprivileged user namespaces disabled); continuing with network mode '${network_mode}'"
        log_message "WARNING: the measured workload uses no network and all fixtures are pinned by SHA-256, so results remain reproducible; recorded in the run context"
    fi

    log_message "start stage ready (network mode: ${network_mode})"
    return 0
}
