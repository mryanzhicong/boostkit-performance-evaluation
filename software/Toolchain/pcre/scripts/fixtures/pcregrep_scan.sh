#!/usr/bin/env bash
# Run the fixed pcregrep scan workload: one pcregrep invocation per pinned
# pattern over the same deterministic corpus, then verify every per-pattern
# line count against the value generated with the corpus.  The wrapper exists so
# that a single measured child process covers the whole scan set and the
# aggregate "lines matched" and "bytes scanned" values are recorded in one log.
#
# Usage: pcregrep_scan.sh <fixtures-dir> <expected-total-matches>
set -euo pipefail

FIXTURES_DIR="${1:?fixtures directory is required}"
EXPECTED_TOTAL="${2:?expected total match count is required}"

CORPUS="${FIXTURES_DIR}/scan_corpus.txt"
PATTERNS="${FIXTURES_DIR}/scan_patterns.txt"
MANIFEST="${FIXTURES_DIR}/fixtures.json"

for path in "${CORPUS}" "${PATTERNS}" "${MANIFEST}"; do
    [[ -s "${path}" ]] || {
        printf '[pcre-scan] ERROR: missing fixture: %s\n' "${path}" >&2
        exit 1
    }
done

PYTHON_BIN="${PYTHON_BIN:-python3}"
corpus_bytes="$(stat -c %s "${CORPUS}")"
pattern_count="$("${PYTHON_BIN}" - "${PATTERNS}" <<'PY'
import sys
from pathlib import Path
lines = [line for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines() if line]
print(len(lines))
PY
)"

total=0
index=0
while IFS= read -r pattern; do
    [[ -n "${pattern}" ]] || continue
    index=$((index + 1))
    count="$("${PCREGREP_BIN}" -c "${pattern}" "${CORPUS}")" || {
        rc=$?
        # pcregrep exits 1 when a pattern matches no line; that is a fixture
        # error here because every pinned pattern must match.
        printf '[pcre-scan] ERROR: pcregrep failed or matched nothing for pattern %d (exit %d)\n' \
            "${index}" "${rc}" >&2
        exit 1
    }
    printf 'PATTERN %d matched_lines=%s pattern=%s\n' "${index}" "${count}" "${pattern}"
    total=$((total + count))
done < "${PATTERNS}"

printf 'SCAN corpus_bytes=%s patterns=%s matched_lines=%s\n' \
    "${corpus_bytes}" "${pattern_count}" "${total}"
printf 'PERF-CHECK name=scan_matched_lines expected=%s actual=%s status=%s\n' \
    "${EXPECTED_TOTAL}" "${total}" "$([[ "${EXPECTED_TOTAL}" == "${total}" ]] && echo ok || echo failed)"
printf 'PERF-CHECK name=scan_patterns expected=%s actual=%s status=%s\n' \
    8 "${pattern_count}" "$([[ "${pattern_count}" == 8 ]] && echo ok || echo failed)"

[[ "${total}" == "${EXPECTED_TOTAL}" ]] || {
    printf '[pcre-scan] ERROR: total match count %s differs from the pinned %s\n' \
        "${total}" "${EXPECTED_TOTAL}" >&2
    exit 1
}
printf 'PERF-RESULT status=ok\n'
