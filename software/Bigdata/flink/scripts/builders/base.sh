#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_build_dependencies() {
    local -a packages=(java-11-openjdk-devel maven curl git tar gzip unzip)
    local -a missing=()
    local -a dnf_options=()
    local package
    for package in "${packages[@]}"; do
        rpm -q "${package}" >/dev/null 2>&1 || missing+=("${package}")
    done
    (( ${#missing[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing build packages: ${missing[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    else
        log_message 'ERROR: dnf requires root or passwordless sudo'
        return 30
    fi
}

select_jdk() {
    local javac_bin java_home
    javac_bin="$(rpm -ql java-11-openjdk-devel | sed -n '/\/bin\/javac$/p' | head -1)"
    [[ -n "${javac_bin}" ]] || { log_message 'ERROR: installed JDK 11 has no javac'; return 30; }
    java_home="$(dirname "$(dirname "${javac_bin}")")"
    [[ "$(${java_home}/bin/javac -version 2>&1)" == javac\ 11.* ]] || { log_message 'ERROR: selected JDK is not 11'; return 30; }
    printf '%s\n' "${java_home}" > "${PERF_WORK_DIR}/java-home.txt"
    load_java
}

prepare_flink_release() {
    local archive="${FLINK_ARCHIVE_DIR}/${FLINK_RELEASE}"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${FLINK_RELEASE}"
        log_message "downloading Apache Flink ${SOFTWARE_VERSION} release"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive}" \
            "https://archive.apache.org/dist/flink/flink-${SOFTWARE_VERSION}/${FLINK_RELEASE}" || return 30
    else
        log_message "using local Apache Flink archive: ${archive}"
    fi
    printf '%s  %s\n' "${FLINK_SHA512}" "${archive}" | sha512sum -c - || return 30
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -x "${FLINK_HOME}/bin/flink" ]] || { log_message 'ERROR: Flink release is incomplete'; return 30; }
    local version_output actual_version
    version_output="$("${FLINK_HOME}/bin/flink" --version 2>&1)" || return 30
    actual_version="$(sed -nE 's/.*Version: ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' <<< "${version_output}" | head -1)"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: installed Flink reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

prepare_nexmark() {
    local jar
    log_message "fetching upstream Nexmark ${NEXMARK_REVISION}"
    git init -q "${NEXMARK_SOURCE}" || return 30
    git -C "${NEXMARK_SOURCE}" remote add origin "${NEXMARK_REPOSITORY}" || return 30
    with_network_proxy git -C "${NEXMARK_SOURCE}" fetch --depth 1 origin "${NEXMARK_REVISION}" || return 30
    git -C "${NEXMARK_SOURCE}" checkout --detach FETCH_HEAD || return 30
    [[ "$(git -C "${NEXMARK_SOURCE}" rev-parse HEAD)" == "${NEXMARK_REVISION}" ]] || return 30
    log_message 'building the unmodified upstream nexmark-flink module'
    python3 "${CASE_DIR}/scripts/configure_maven.py" "${PERF_WORK_DIR}/maven-settings.xml" || return 30
    ( cd "${NEXMARK_SOURCE}" && \
      mvn -B -s "${PERF_WORK_DIR}/maven-settings.xml" \
        "-Dmaven.repo.local=${PERF_WORK_DIR}/maven-repository" \
        -Dflink.version=1.16.3 -Dmaven.test.skip=true -pl nexmark-flink clean package ) || return 40
    jar="${NEXMARK_SOURCE}/nexmark-flink/target/nexmark-flink-0.3-SNAPSHOT.jar"
    [[ -s "${jar}" ]] || { log_message 'ERROR: shaded Nexmark JAR is missing'; return 40; }
    unzip -l "${jar}" | grep 'com/github/nexmark/flink/Benchmark.class' >/dev/null || return 40
    mkdir -p "${NEXMARK_HOME}/lib" "${NEXMARK_HOME}/log"
    cp -a "${NEXMARK_SOURCE}/nexmark-flink/src/main/resources/"{bin,conf,queries,queries-cep} "${NEXMARK_HOME}/" || return 40
    cp -f "${jar}" "${NEXMARK_HOME}/lib/" || return 40
    cp -f "${jar}" "${FLINK_HOME}/lib/" || return 40
}

configure_flink() {
    mkdir -p "${FLINK_HOME}/data" "${FLINK_PID_DIR}" "${PERF_WORK_DIR}/pids/tm2"
    printf 'localhost\n' > "${FLINK_HOME}/conf/workers"
    cat > "${FLINK_HOME}/conf/flink-conf.yaml" <<EOF
jobmanager.rpc.address: localhost
jobmanager.rpc.port: ${FLINK_RPC_PORT}
jobmanager.memory.process.size: 4g
taskmanager.memory.process.size: 8g
taskmanager.memory.managed.fraction: 0.4
taskmanager.numberOfTaskSlots: 8
parallelism.default: 8
rest.address: localhost
rest.port: ${FLINK_REST_PORT}
io.tmp.dirs: ${FLINK_DATA}/tmp
state.backend: rocksdb
state.backend.incremental: true
state.backend.local-recovery: true
state.backend.rocksdb.localdir: ${FLINK_DATA}/rocksdb
state.checkpoints.dir: file://${FLINK_DATA}/checkpoint
execution.checkpointing.interval: 0
execution.checkpointing.mode: EXACTLY_ONCE
execution.checkpointing.checkpoints-after-tasks-finish.enabled: false
table.exec.mini-batch.enabled: true
table.exec.mini-batch.allow-latency: 2s
table.exec.mini-batch.size: 50000
table.optimizer.distinct-agg.split.enabled: true
pipeline.operator-chaining.enabled: true
EOF
    sed -i \
        -e "s/^nexmark.metric.reporter.port:.*/nexmark.metric.reporter.port: ${NEXMARK_METRIC_PORT}/" \
        -e "s/^flink.rest.port:.*/flink.rest.port: ${FLINK_REST_PORT}/" \
        "${NEXMARK_HOME}/conf/nexmark.yaml"
    printf 'nexmark.metric.monitor.delay: 3s\nnexmark.metric.monitor.interval: 2s\n' \
        >> "${NEXMARK_HOME}/conf/nexmark.yaml"
    log_message "configured 1 JM, 2 TM x 8 slots, REST ${FLINK_REST_PORT} in ${PERF_WORK_DIR}"
}

build_flink_base() {
    initialize_runtime || return $?
    install_build_dependencies || return $?
    select_jdk || return $?
    prepare_flink_release || return $?
    prepare_nexmark || return $?
    configure_flink || return $?
}
