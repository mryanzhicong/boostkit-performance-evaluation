#!/usr/bin/env bash
# Start stage: generate and verify the deterministic corpora, confirm the built
# applets are usable, and record whether measurements can run offline.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

detect_network_mode() {
    # Probe inside the private container: that is exactly where the measured
    # process tree will be created, so the recorded mode describes the measured
    # environment rather than the host.
    if busybox_container_exec unshare -n true >/dev/null 2>&1; then
        printf 'unshare\n'
        return 0
    fi
    printf 'unavailable\n'
}

verify_fixtures() {
    local manifest="${BUSYBOX_FIXTURE_MANIFEST}"
    if [[ ! -s "${manifest}" ]]; then
        fail_message "fixture manifest is missing: ${manifest}"
        return 20
    fi
    python3 - "${manifest}" \
        "${BUSYBOX_FIXTURES_DIR}" \
        "${BUSYBOX_FIXTURE_CORPUS_LINES}" "${BUSYBOX_FIXTURE_CORPUS_BYTES}" \
        "${BUSYBOX_FIXTURE_CORPUS_SHA256}" \
        "${BUSYBOX_FIXTURE_GZIP_LINES}" "${BUSYBOX_FIXTURE_GZIP_BYTES}" \
        "${BUSYBOX_FIXTURE_GZIP_SHA256}" \
        "${BUSYBOX_FIXTURE_SORT_LINES}" "${BUSYBOX_FIXTURE_SORT_BYTES}" \
        "${BUSYBOX_FIXTURE_SORT_SHA256}" "${BUSYBOX_FIXTURE_SORT_MAX_KEY}" \
        "${BUSYBOX_FIXTURE_TAR_FILES}" "${BUSYBOX_FIXTURE_TAR_BYTES}" \
        "${BUSYBOX_FIXTURE_TAR_CONTENT_SHA256}" \
        "${BUSYBOX_EXPECT_GREP_MATCHES}" "${BUSYBOX_EXPECT_SED_SHA256}" \
        "${BUSYBOX_EXPECT_CUT_SHA256}" "${BUSYBOX_EXPECT_AWK_SUM}" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

(
    manifest_path,
    fixture_dir,
    corpus_lines, corpus_bytes, corpus_sha,
    gzip_lines, gzip_bytes, gzip_sha,
    sort_lines, sort_bytes, sort_sha, sort_max_key,
    tar_files, tar_bytes, tar_content_sha,
    expect_grep, expect_sed, expect_cut, expect_awk,
) = sys.argv[1:]
fixture_dir = Path(fixture_dir)
manifest = json.loads(Path(manifest_path).read_text(encoding="utf-8"))


def fail(message: str) -> None:
    print(f"[busybox-start] ERROR: {message}", file=sys.stderr)
    raise SystemExit(20)


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def check_file(name: str, expected_lines: int, expected_bytes: int, expected_sha: str) -> None:
    path = fixture_dir / name
    if not path.is_file():
        fail(f"fixture is missing: {path}")
    actual_bytes = path.stat().st_size
    if actual_bytes != int(expected_bytes):
        fail(f"{name}: size {actual_bytes} != pinned {expected_bytes}")
    entry = manifest.get(name, {})
    if int(entry.get("lines", -1)) != int(expected_lines):
        fail(f"{name}: manifest line count differs from the pinned value")
    if int(entry.get("bytes", -1)) != int(expected_bytes):
        fail(f"{name}: manifest byte count differs from the pinned value")
    if entry.get("sha256") != expected_sha:
        fail(f"{name}: manifest SHA-256 differs from the pinned value")
    actual_sha = sha256_of(path)
    if actual_sha != expected_sha:
        fail(f"{name}: SHA-256 {actual_sha} != pinned {expected_sha}")


check_file("corpus_text.txt", corpus_lines, corpus_bytes, corpus_sha)
check_file("gzip_input.txt", gzip_lines, gzip_bytes, gzip_sha)
check_file("sort_input.txt", sort_lines, sort_bytes, sort_sha)

tree = fixture_dir / "tar_tree"
files = sorted(tree.glob("part*.txt")) if tree.is_dir() else []
if len(files) != int(tar_files):
    fail(f"tar_tree: {len(files)} files != pinned {tar_files}")
total = 0
digest = hashlib.sha256()
for path in files:
    content = path.read_bytes()
    total += len(content)
    digest.update(content)
if total != int(tar_bytes):
    fail(f"tar_tree: {total} bytes != pinned {tar_bytes}")
if digest.hexdigest() != tar_content_sha:
    fail("tar_tree content SHA-256 differs from the pinned value")

expected = manifest.get("expected", {})
if int(expected.get("grep_matches_tag_alpha", -1)) != int(expect_grep):
    fail("manifest grep expectation differs from the pinned value")
if expected.get("sed_output_sha256") != expect_sed:
    fail("manifest sed expectation differs from the pinned value")
if expected.get("cut_output_sha256") != expect_cut:
    fail("manifest cut expectation differs from the pinned value")
if int(expected.get("awk_line_bytes_sum", -1)) != int(expect_awk):
    fail("manifest awk expectation differs from the pinned value")
if int(manifest.get("sort_input.txt", {}).get("max_key", -1)) != int(sort_max_key):
    fail("manifest sort max key differs from the pinned value")

print("[busybox-start] fixture manifest and all corpora match the pinned values")
PY
    return $?
}

verify_applets() {
    if ! busybox_container_exec test -x "${BUSYBOX_BIN}"; then
        fail_message "built BusyBox binary is missing: ${BUSYBOX_BIN}"
        return 20
    fi
    local available
    available="$(busybox_container_exec "${BUSYBOX_BIN}" --list 2>/dev/null || true)"
    if [[ -z "${available}" ]]; then
        fail_message "cannot list the applets of ${BUSYBOX_BIN}"
        return 20
    fi
    local applet absent=()
    for applet in "${BUSYBOX_REQUIRED_APPLETS[@]}"; do
        if ! printf '%s\n' "${available}" | grep -qx "${applet}"; then
            absent+=("${applet}")
        fi
    done
    if (( ${#absent[@]} > 0 )); then
        fail_message "required applets are missing: ${absent[*]}"
        return 20
    fi
    printf '%s\n' "${available}" | grep -c . > "${BUSYBOX_STATE_DIR}/applet-count.txt" || true
    return 0
}

start_busybox_runtime() {
    validate_variant || return $?
    validate_version || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    initialize_runtime || return $?

    check_busybox_container || return $?

    verify_applets || return $?
    busybox_container_exec python3 -c 'import sys' || {
        fail_message "python3 is required for fixture generation inside the container"
        return 20
    }

    log_message "generating deterministic corpora in ${BUSYBOX_FIXTURES_DIR} inside the private container"
    busybox_container_exec python3 "${SCRIPTS_DIR}/fixtures/generate_fixtures.py" "${BUSYBOX_FIXTURES_DIR}" > \
        "${BUSYBOX_STATE_DIR}/fixtures.log" 2>&1 || {
        fail_message "fixture generation failed, see ${BUSYBOX_STATE_DIR}/fixtures.log"
        return 20
    }
    verify_fixtures || return $?

    local network_mode
    network_mode="$(detect_network_mode)"
    printf '%s\n' "${network_mode}" > "${BUSYBOX_OFFLINE_DIR_MODE_FILE}"
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: network namespace isolation (unshare -n) is unavailable on this runner (unprivileged user namespaces disabled); continuing with network mode '${network_mode}'"
        log_message "WARNING: the measured workload uses no network and all fixtures are pinned by SHA-256, so results remain reproducible; recorded in the run context"
    fi

    log_message "start stage ready (network mode: ${network_mode})"
    return 0
}
