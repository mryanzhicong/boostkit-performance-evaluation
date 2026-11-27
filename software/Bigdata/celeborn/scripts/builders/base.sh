#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_host_dependencies() {
    local command package
    local -a packages=() dnf_options=()
    for command in docker curl tar sha512sum sha256sum awk sed python3; do
        command -v "${command}" >/dev/null 2>&1 && continue
        case "${command}" in
            docker) log_message 'ERROR: Docker must be installed on the Runner'; return 30 ;;
            sha512sum|sha256sum) package=coreutils ;;
            awk) package=gawk ;;
            python3) package=python3 ;;
            *) package="${command}" ;;
        esac
        packages+=("${package}")
    done
    (( ${#packages[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing host packages: ${packages[*]}"
    if (( EUID == 0 )); then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    fi
}

download_tpcds_kit() {
    local target="${PERF_WORK_DIR}/tpcds-kit.tar.gz"
    local cache="${CELEBORN_OFFLINE_DIR}/tpcds-kit.tar.gz"
    local scratch="${PERF_WORK_DIR}/tpcds-kit-verify" url tree
    mkdir -p "$(dirname "${target}")" "${CELEBORN_OFFLINE_DIR}" || return 30
    if [[ ! -s "${target}" ]]; then
        if [[ -s "${cache}" ]]; then
            log_message "using cached download: ${cache}"
            cp -- "${cache}" "${target}" || return 30
        else
            for url in "${TPCDS_KIT_URL}" "${TPCDS_KIT_MIRROR_URL}"; do
                [[ "${url}" == "${TPCDS_KIT_URL}" ]] && log_message "downloading ${url}"
                if with_network_proxy curl -fSL --retry 3 --retry-delay 5 --connect-timeout 30 \
                    -o "${target}.part" "${url}"; then
                    mv -f "${target}.part" "${target}"
                    break
                fi
                rm -f "${target}.part"
            done
            [[ -s "${target}" ]] || { log_message "ERROR: all download sources failed for tpcds-kit.tar.gz"; return 30; }
        fi
    fi
    rm -rf "${scratch}"; mkdir -p "${scratch}"
    if ! tar -xzf "${target}" -C "${scratch}"; then
        log_message "ERROR: cannot extract tpcds-kit.tar.gz"
        rm -rf "${scratch}"
        return 30
    fi
    tree="$(find "${scratch}" -maxdepth 1 -mindepth 1 -type d | head -1)"
    if ! python3 "${CASE_DIR}/scripts/builders/tree_digest.py" "${tree}" \
        --expected "${TPCDS_KIT_TREE_SHA256}" >/dev/null; then
        log_message "ERROR: the tpcds-kit source tree does not match the pinned commit ${TPCDS_KIT_COMMIT}"
        rm -rf "${scratch}"
        return 30
    fi
    rm -rf "${scratch}"
    if [[ ! -s "${cache}" ]]; then
        cp -- "${target}" "${cache}.part" && mv -f "${cache}.part" "${cache}" \
            || log_message "WARNING: cannot cache tpcds-kit.tar.gz"
    fi
    log_message "verified the tpcds-kit source tree (${TPCDS_KIT_COMMIT:0:7})"
}

download_workload_assets() {
    fetch_verified "${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin.tgz" \
        sha512 "${CELEBORN_ARCHIVE_SHA512}" \
        "${CELEBORN_ARCHIVE_MIRROR_URL}" "${CELEBORN_ARCHIVE_URL}" || return $?
    fetch_verified "${PERF_WORK_DIR}/spark-3.5.2-bin-hadoop3.tgz" \
        sha512 "${SPARK_ARCHIVE_SHA512}" \
        "${SPARK_ARCHIVE_MIRROR_URL}" "${SPARK_ARCHIVE_URL}" || return $?
    download_tpcds_kit || return $?
    fetch_verified "${PERF_WORK_DIR}/hive-testbench.zip" \
        sha256 "${TESTBENCH_SHA256}" \
        "${TESTBENCH_URL}" || return $?
}

prepare_container_toolchain() {
    local -a packages=(java-1.8.0-openjdk gcc make bison flex unzip tar gzip python3 procps-ng)
    log_message "installing the in-container toolchain: ${packages[*]}"
    if ! celeborn_container_exec_root dnf -y --setopt=install_weak_deps=False install "${packages[@]}" \
        >"${PERF_WORK_DIR}/dnf-toolchain.log" 2>&1; then
        log_message 'WARNING: first dnf transaction failed, retrying without the update-source repository'
        celeborn_container_exec_root dnf -y --disablerepo=update-source \
            --setopt=install_weak_deps=False install "${packages[@]}" \
            >>"${PERF_WORK_DIR}/dnf-toolchain.log" 2>&1 || {
            log_message 'ERROR: cannot install the in-container toolchain; see dnf-toolchain.log'
            return 30
        }
    fi
    local java_release
    java_release="$(celeborn_container_exec bash -lc 'java -version' 2>&1 | head -n 2 | tr '\n' ' ' || true)"
    log_message "in-container JDK: ${java_release}"
}

extract_workload_assets() {
    celeborn_container_exec tar -xzf "${PERF_WORK_DIR}/$(basename "${CELEBORN_ARCHIVE_URL}")" \
        -C "${PERF_WORK_DIR}" || return 30
    celeborn_container_exec tar -xzf "${PERF_WORK_DIR}/$(basename "${SPARK_ARCHIVE_URL}")" \
        -C "${PERF_WORK_DIR}" || return 30
    if [[ ! -d "${TPCDS_KIT_HOME}" ]]; then
        celeborn_container_exec mkdir -p "${TPCDS_KIT_HOME}" || return 30
        celeborn_container_exec tar -xzf "${PERF_WORK_DIR}/tpcds-kit.tar.gz" \
            -C "${TPCDS_KIT_HOME}" --strip-components=1 || return 30
    fi
    if [[ ! -d "${TESTBENCH_HOME}" ]]; then
        celeborn_container_exec bash -lc \
            "unzip -q '${PERF_WORK_DIR}/hive-testbench.zip' -d '${PERF_WORK_DIR}/testbench-extract'" || return 30
        celeborn_container_exec bash -lc \
            "mv '${PERF_WORK_DIR}/testbench-extract'/hive-testbench-* '${TESTBENCH_HOME}'" || return 30
        celeborn_container_exec rm -rf "${PERF_WORK_DIR}/testbench-extract" || return 30
    fi
    [[ -d "${CELEBORN_HOME}" ]] || { log_message "ERROR: Celeborn distribution directory is missing: ${CELEBORN_HOME}"; return 30; }
    [[ -d "${SPARK_HOME}" ]] || { log_message "ERROR: Spark distribution directory is missing: ${SPARK_HOME}"; return 30; }
    [[ -d "${TPCDS_KIT_HOME}/tools" ]] || { log_message "ERROR: tpcds-kit sources are missing"; return 30; }
    [[ -s "${TESTBENCH_HOME}/ddl-tpcds/text/alltables.sql" ]] || {
        log_message 'ERROR: the pinned TPC-DS DDL is missing from hive-testbench'; return 30;
    }
    [[ -d "${TESTBENCH_HOME}/sample-queries-tpcds" ]] || {
        log_message 'ERROR: the pinned TPC-DS statements are missing from hive-testbench'; return 30;
    }
}

build_tpcds_generator() {
    if [[ -x "${TPCDS_KIT_HOME}/tools/dsdgen" && -x "${TPCDS_KIT_HOME}/tools/dsqgen" ]]; then
        log_message 'tpcds-kit generator is already built'
        return 0
    fi
    log_message 'building the arch-neutral tpcds-kit generator (dsdgen + dsqgen)'
    celeborn_container_exec bash -lc "
        set -euo pipefail
        cd '${TPCDS_KIT_HOME}/tools'
        # bison provides yacc/lex compatible front ends; the makefile calls yacc.
        mkdir -p '${PERF_WORK_DIR}/bin'
        ln -sf \"\$(command -v bison)\" '${PERF_WORK_DIR}/bin/yacc'
        ln -sf \"\$(command -v flex)\" '${PERF_WORK_DIR}/bin/lex'
        export PATH='${PERF_WORK_DIR}/bin:'\"\${PATH}\"
        bison -y -d -v qgen.y >/dev/null 2>&1
        make OS=LINUX >'${PERF_WORK_DIR}/tpcds-kit-build.log' 2>&1
        test -x dsdgen && test -x dsqgen
    " || { log_message 'ERROR: tpcds-kit generator build failed; see tpcds-kit-build.log'; return 30; }
    log_message 'tpcds-kit generator is ready'
}

record_versions() {
    local celeborn_release spark_release java_release dsdgen_release
    celeborn_release="$(celeborn_container_exec bash -lc \
        "grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' '${CELEBORN_HOME}/RELEASE' 2>/dev/null | head -n 1" || true)"
    [[ -n "${celeborn_release}" ]] || celeborn_release="$(celeborn_container_exec bash -lc \
        "ls '${CELEBORN_HOME}/jars' | grep -oE 'celeborn-common_2\\.12-[0-9.]+' | sed 's/.*-//' | head -n 1" || true)"
    spark_release="$(celeborn_container_exec bash -lc \
        "'${SPARK_HOME}/bin/spark-submit' --version 2>&1 | grep -oE 'version 3\.[0-9]+\.[0-9]+' | head -n 1 | sed 's/version //'" || true)"
    java_release="$(celeborn_container_exec bash -lc 'java -version 2>&1 | head -n 1' || true)"
    dsdgen_release="$(celeborn_container_exec bash -lc \
        "cd '${TPCDS_KIT_HOME}/tools' && ./dsdgen -help 2>&1 | head -n 1" || true)"
    [[ "${celeborn_release}" == *"${SOFTWARE_VERSION}"* ]] || {
        log_message "ERROR: unexpected Celeborn release: ${celeborn_release}"; return 30;
    }
    [[ "${spark_release}" == "${SPARK_VERSION}" ]] || {
        log_message "ERROR: unexpected Spark release: ${spark_release}"; return 30;
    }
    [[ -s "${CELEBORN_CLIENT_JAR}" ]] || {
        log_message "ERROR: Celeborn Spark 3 client jar is missing: ${CELEBORN_CLIENT_JAR}"; return 30;
    }
    printf '%s\n' "${celeborn_release%%[[:space:]]*}" > "${PERF_ACTUAL_VERSION_FILE}"
    python3 - "${RESULTS_DIR}/versions.json" <<PY
import json
import sys

path = sys.argv[1]
payload = {
    "celeborn": "${celeborn_release%%[[:space:]]*}",
    "spark": "${spark_release}",
    "java": ${java_release@Q},
    "tpcds_kit_commit": "${TPCDS_KIT_COMMIT}",
    "tpcds_generator": ${dsdgen_release@Q},
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
    log_message "versions: Celeborn ${celeborn_release%%[[:space:]]*}, Spark ${spark_release}, ${java_release}"
}

build_celeborn_base() {
    initialize_runtime || return $?
    install_host_dependencies || return $?
    require_celeborn_docker || return $?
    prepare_celeborn_container_image || return $?
    download_workload_assets || return $?
    start_celeborn_container || return $?
    prepare_container_toolchain || return $?
    extract_workload_assets || return $?
    build_tpcds_generator || return $?
    record_versions || return $?
    log_message 'Celeborn 0.5.3, Spark 3.5.2 and the TPC-DS generator are ready'
}
