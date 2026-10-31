#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Reuse the staging and smoke-build helpers from the start stage; the test
# stage runs the same workload definitions with the formal round count.
source "${SCRIPT_DIR}/scripts/stages/start.sh"

run_compile_scenario() {
    container_exec sh -c "$(cat <<EOS
for option in ${CLANG_COMPILE_OPTIONS[*]}; do
    for round in \$(seq 1 ${CLANG_ROUNDS}); do
        object_file="${BENCHMARK_DIR}/sqlite3-\${option#-}-r\${round}.o"
        rm -f "\$object_file"
        round_start=\$(date +%s.%N)
        "${CLANG_BIN}" "\$option" -c "${SQLITE3_C}" -o "\$object_file" || exit 50
        round_end=\$(date +%s.%N)
        round_seconds=\$(awk -v s="\$round_start" -v e="\$round_end" 'BEGIN { printf "%.3f", e - s }')
        printf 'result scenario=compile workload=%s round=%d wall_seconds=%s artifact_bytes=%s\n' \
            "\$option" "\$round" "\$round_seconds" "\$(stat -c %s "\$object_file")"
    done
    rm -f "${BENCHMARK_DIR}"/sqlite3-*-r*.o
done
EOS
)" || {
        log_message 'ERROR: compile scenario failed inside the container'
        return 50
    }
}

run_speedtest_scenario() {
    local binary_bytes
    build_speedtest1_binary "${SPEEDTEST1_BIN}" || return $?
    binary_bytes="$(container_exec stat -c %s "${SPEEDTEST1_BIN}")"
    container_exec sh -c "$(cat <<EOS
for size in ${CLANG_SPEEDTEST_SIZES[*]}; do
    for round in \$(seq 1 ${CLANG_ROUNDS}); do
        round_dir="${BENCHMARK_DIR}/speedtest1-size\${size}-r\${round}"
        rm -rf "\$round_dir"
        mkdir -p "\$round_dir"
        round_start=\$(date +%s.%N)
        cd "\$round_dir" && "${SPEEDTEST1_BIN}" --size "\$size" --memdb test.db || exit 50
        round_end=\$(date +%s.%N)
        round_seconds=\$(awk -v s="\$round_start" -v e="\$round_end" 'BEGIN { printf "%.3f", e - s }')
        printf 'result scenario=speedtest1 workload=%d round=%d wall_seconds=%s artifact_bytes=%s\n' \
            "\$size" "\$round" "\$round_seconds" "${binary_bytes}"
        cd "${BENCHMARK_DIR}" && rm -rf "\$round_dir"
    done
done
EOS
)" || {
        log_message 'ERROR: speedtest1 scenario failed inside the container'
        return 50
    }
}

run_clang_benchmarks() {
    local raw_output
    initialize_runtime || return $?
    check_clang_container || return $?
    container_exec test -x "${CLANG_BIN}" || {
        log_message 'ERROR: clang is not deployed; build stage did not complete'
        return 40
    }
    prepare_benchmark_sources || return $?
    raw_output="${RESULTS_DIR}/sqlite_clang_raw.log"
    log_message "running ${CLANG_ROUNDS} rounds per workload inside the container"
    if ! (
        run_compile_scenario || exit 50
        run_speedtest_scenario || exit 50
    ) 2>&1 | tee "${raw_output}"; then
        log_message 'ERROR: clang benchmark suite failed'
        return 50
    fi
    python3 "${CASE_DIR}/scripts/results/collect_clang_benchmark.py" \
        "${raw_output}" "${RESULTS_DIR}/benchmark_clang.json" \
        "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${CLANG_ROUNDS}" || {
        log_message 'ERROR: clang result collection failed'
        return 50
    }
    log_message 'clang benchmark suite completed'
}
