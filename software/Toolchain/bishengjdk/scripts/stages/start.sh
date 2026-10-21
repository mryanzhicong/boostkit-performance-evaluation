#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_bishengjdk_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${JDK_HOME}/bin/java" || \
          ! -s "${SRC_DIR}/build/jmh/jars/jmh-core-${JMH_VERSION}.jar" ]]; then
        log_message "ERROR: source-built BiSheng JDK or JMH bundle is missing"
        return 40
    fi
    if [[ ! -f "${SRC_DIR}/test/micro/org/openjdk/bench/vm/compiler/FloatingScalarVectorAbsDiff.java" ]]; then
        log_message "ERROR: JMH benchmark source is missing: ${JMH_BENCHMARK}"
        return 40
    fi
    log_message "BiSheng JDK JMH runtime is ready"
}
