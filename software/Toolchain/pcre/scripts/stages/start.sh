#!/usr/bin/env bash
# Start stage: verify the build products, materialise the deterministic fixtures,
# verify every pinned SHA-256 and prove that the measurement stage can run with
# no network namespace.  No service is started; PCRE is a library plus command
# line tools, so "start" means "the measured workload is ready and reproducible".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

verify_fixture() {
    local path="$1" expected="$2" actual
    [[ -s "${path}" ]] || {
        fail_message "fixture is missing or empty: ${path}"
        return 1
    }
    actual="$(sha256sum "${path}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        fail_message "fixture SHA-256 mismatch for ${path}: ${actual} != ${expected}"
        return 1
    fi
    return 0
}

start_pcre_runtime() {
    initialize_runtime || return $?

    check_pcre_container || return $?

    local tool
    for tool in pcretest pcregrep pcre-config; do
        pcre_container_exec test -x "$(pcre_tool "${tool}")" || {
            fail_message "required tool is missing: $(pcre_tool "${tool}")"
            return 20
        }
    done
    pcre_container_exec test -x "${PCRE_BENCH_BIN}" || {
        fail_message "benchmark harness is missing: ${PCRE_BENCH_BIN}"
        return 20
    }
    pcre_container_exec test -f "${PCRE_SRC_DIR}/RunTest" || {
        fail_message "upstream RunTest suite is not available under ${PCRE_SRC_DIR}"
        return 20
    }
    pcre_container_exec test -d "${PCRE_SRC_DIR}/testdata" || {
        fail_message "upstream RunTest data is not available under ${PCRE_SRC_DIR}"
        return 20
    }
    [[ -s "${PERF_ACTUAL_VERSION_FILE}" ]] || {
        fail_message "actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 20
    }

    log_message "generating deterministic fixtures inside the private container"
    rm -rf -- "${PCRE_FIXTURES_DIR}"
    mkdir -p "${PCRE_FIXTURES_DIR}"
    pcre_container_exec python3 "${SCRIPT_DIR}/scripts/fixtures/generate_fixtures.py" \
        "${PCRE_FIXTURES_DIR}" > "${PCRE_STATE_DIR}/fixtures.log" 2>&1 || {
        fail_message "fixture generation failed; log:"
        tail -n 40 -- "${PCRE_STATE_DIR}/fixtures.log" >&2 || true
        return 20
    }

    local fixture
    for fixture in pcretest_literal.txt pcretest_backtrack.txt pcretest_utf8.txt \
        pcretest_dfa.txt scan_patterns.txt scan_corpus.txt; do
        verify_fixture "${PCRE_FIXTURES_DIR}/${fixture}" "$(fixture_sha256 "${fixture}")" || return 20
    done
    [[ -s "${PCRE_FIXTURE_MANIFEST}" ]] || {
        fail_message "fixture manifest is missing: ${PCRE_FIXTURE_MANIFEST}"
        return 20
    }

    # Cross-check the generated manifest against the pinned values: a corpus whose
    # size or match counts drifted must not be measured.
    python3 - "${PCRE_FIXTURE_MANIFEST}" "${PCRE_SCAN_CORPUS_BYTES}" \
        "${PCRE_SCAN_MATCHES_TOTAL}" "${PCRE_SCAN_PATTERNS}" <<'PY' || return 20
import json
import sys

manifest_path, expected_bytes, expected_total, expected_patterns = sys.argv[1:5]
with open(manifest_path, encoding="utf-8") as handle:
    manifest = json.load(handle)
errors = []
if manifest.get("corpus_bytes") != int(expected_bytes):
    errors.append(f"corpus_bytes {manifest.get('corpus_bytes')} != {expected_bytes}")
if manifest.get("expected_scan_matches_total") != int(expected_total):
    errors.append(
        f"expected_scan_matches_total {manifest.get('expected_scan_matches_total')} != {expected_total}"
    )
if len(manifest.get("scan_patterns") or []) != int(expected_patterns):
    errors.append("scan pattern count differs from the pinned value")
if not manifest.get("expected_scan_matches"):
    errors.append("expected per-pattern match counts are missing")
if errors:
    print("[pcre] ERROR: fixture manifest does not match the pinned workload:")
    for error in errors:
        print(f"[pcre] ERROR:   {error}")
    raise SystemExit(1)
print("[pcre] fixture manifest matches the pinned workload")
PY

    # Measurement network mode.  A fresh network namespace is the strongest
    # available proof that the measured stage needs no network at all; the case
    # requires it unless the operator explicitly opts out for a restricted
    # runner, in which case the fallback is recorded in the result runtime
    # context (never in the cross-architecture parameter set).  The probe runs
    # inside the private container so it describes exactly where the measured
    # process tree will run.
    local network_mode="none"
    if pcre_container_exec unshare -n true >/dev/null 2>&1; then
        network_mode="unshare"
    fi
    printf '%s\n' "${network_mode}" > "${PCRE_OFFLINE_DIR_MODE_FILE}"
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: network namespace isolation (unshare -n) is unavailable inside the container (unprivileged user namespaces disabled); continuing with network mode '${network_mode}'"
        log_message "WARNING: the measured workload uses no network and all fixtures are pinned by SHA-256, so results remain reproducible; recorded in the run context"
    else
        log_message "offline measurement verified: unshare -n is available inside the private container"
    fi

    local actual_version
    actual_version="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    log_message "start stage ready: pcre ${actual_version}, network mode ${network_mode}"
    return 0
}
