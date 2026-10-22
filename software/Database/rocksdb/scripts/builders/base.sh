#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

install_rocksdb_dependencies() {
    local command_name package
    local packages=()

    for command_name in git gcc g++ make nproc python3 sed mvn flex; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            git) package="git" ;;
            gcc) package="gcc" ;;
            g++) package="gcc-c++" ;;
            make) package="make" ;;
            nproc) package="coreutils" ;;
            python3) package="python3" ;;
            sed) package="sed" ;;
            mvn) package="maven" ;;
            flex) package="flex" ;;
        esac
        packages+=("${package}")
    done
    if ! command -v javac >/dev/null 2>&1 || [[ "$(javac -version 2>&1)" != javac\ 11.* ]]; then
        packages+=("java-11-openjdk-devel")
    fi
    for package in cmake gflags-devel snappy-devel zlib-devel bzip2-devel lz4-devel zstd-devel libatomic; do
        if ! rpm -q "${package}" >/dev/null 2>&1; then
            packages+=("${package}")
        fi
    done
    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing RocksDB dependencies: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1 && sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        :
    else
        log_message "ERROR: cannot install required RocksDB dependencies"
        return 30
    fi
}

build_rocksdb_base() {
    local source_tag actual_version major minor patch java_binary java_home
    local jar_path distribution_archive

    initialize_runtime || return $?
    install_rocksdb_dependencies || return $?
    java_binary="$(command -v javac || true)"
    if [[ -n "${java_binary}" ]]; then
        java_binary="$(readlink -f "${java_binary}")"
        java_home="$(dirname "$(dirname "${java_binary}")")"
    else
        java_home=""
    fi
    if [[ ! -x "${java_home}/bin/java" || "$("${java_home}/bin/javac" -version 2>&1)" != javac\ 11.* ]]; then
        java_binary="$(rpm -ql java-11-openjdk-devel 2>/dev/null | sed -n '/\/bin\/javac$/p' | head -1 || true)"
        if [[ -z "${java_binary}" ]]; then
            log_message "ERROR: a complete JDK 11 is required for upstream RocksDB/YCSB"
            return 30
        fi
        java_home="$(dirname "$(dirname "${java_binary}")")"
    fi
    if [[ ! -x "${java_home}/bin/java" || "$("${java_home}/bin/javac" -version 2>&1)" != javac\ 11.* ]]; then
        log_message "ERROR: selected JDK is not Java 11: ${java_home}"
        return 30
    fi
    printf '%s\n' "${java_home}" > "${PERF_WORK_DIR}/java-home.txt"
    export JAVA_HOME="${java_home}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    export MAVEN_OPTS="${MAVEN_OPTS:-} -Dmaven.repo.local=${MAVEN_REPO_DIR} -Drocksdb.version=${SOFTWARE_VERSION}"
    python3 "${SCRIPT_DIR}/scripts/write_maven_settings.py" "${MAVEN_SETTINGS_FILE}" || return 30
    source_tag="v${SOFTWARE_VERSION#v}"
    rm -rf -- "${SOURCE_DIR}" "${YCSB_SOURCE_DIR}" "${YCSB_DIST_DIR}"
    log_message "cloning RocksDB ${source_tag} from ${ROCKSDB_REPOSITORY}"
    if ! with_network_proxy git clone --branch "${source_tag}" --depth 1 "${ROCKSDB_REPOSITORY}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone RocksDB ${source_tag}"
        return 40
    fi
    log_message "building unmodified RocksDB JNI with the documented rocksdbjava target"
    if ! (cd "${SOURCE_DIR}" && export PORTABLE=1 DEBUG_LEVEL=0 && \
        with_network_proxy make rocksdbjava -j"$(nproc)" DISABLE_WARNING_AS_ERROR=1 DISABLE_JEMALLOC=1); then
        log_message "ERROR: rocksdbjava build failed"
        return 40
    fi
    major="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MAJOR[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    minor="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_MINOR[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    patch="$(sed -nE 's/^#define[[:space:]]+ROCKSDB_PATCH[[:space:]]+([0-9]+).*/\1/p' "${SOURCE_DIR}/include/rocksdb/version.h")"
    actual_version="${major}.${minor}.${patch}"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION#v}" ]]; then
        log_message "ERROR: built RocksDB is ${actual_version}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    jar_path="${SOURCE_DIR}/java/target/rocksdbjni-${actual_version}-linux64.jar"
    if [[ ! -s "${jar_path}" ]]; then
        log_message "ERROR: architecture-specific RocksDB JNI JAR is missing: ${jar_path}"
        return 40
    fi
    log_message "installing the locally built JNI JAR into this task's private Maven repository"
    if ! mvn -B -s "${MAVEN_SETTINGS_FILE}" install:install-file \
        -Dfile="${jar_path}" -DgroupId=org.rocksdb -DartifactId=rocksdbjni \
        -Dversion="${actual_version}" -Dpackaging=jar -DgeneratePom=true; then
        log_message "ERROR: failed to install locally built RocksDB JNI JAR"
        return 40
    fi
    log_message "cloning unmodified YCSB revision ${YCSB_REVISION}"
    if ! with_network_proxy git clone --filter=blob:none "${YCSB_REPOSITORY}" "${YCSB_SOURCE_DIR}" || \
       ! with_network_proxy git -C "${YCSB_SOURCE_DIR}" checkout --detach "${YCSB_REVISION}"; then
        log_message "ERROR: failed to check out the documented YCSB revision"
        return 40
    fi
    if [[ "$(git -C "${YCSB_SOURCE_DIR}" rev-parse HEAD)" != "${YCSB_REVISION}" ]]; then
        log_message "ERROR: YCSB revision verification failed"
        return 40
    fi
    log_message "building the original YCSB RocksDB binding against the locally built JNI JAR"
    if ! (cd "${YCSB_SOURCE_DIR}" && mvn -B -s "${MAVEN_SETTINGS_FILE}" \
        -pl site.ycsb:rocksdb-binding -am clean package -DskipTests \
        -Drocksdb.version="${actual_version}"); then
        log_message "ERROR: YCSB RocksDB binding build failed"
        return 40
    fi
    distribution_archive="${YCSB_SOURCE_DIR}/rocksdb/target/ycsb-rocksdb-binding-0.18.0-SNAPSHOT.tar.gz"
    if [[ ! -s "${distribution_archive}" ]]; then
        log_message "ERROR: YCSB RocksDB binding distribution is missing"
        return 40
    fi
    mkdir -p "${YCSB_DIST_DIR}"
    if ! tar -xzf "${distribution_archive}" -C "${YCSB_DIST_DIR}" --strip-components=1; then
        log_message "ERROR: failed to extract YCSB RocksDB binding distribution"
        return 40
    fi
    if [[ ! -s "${YCSB_DIST_DIR}/bin/ycsb" || ! -s "${YCSB_DIST_DIR}/lib/rocksdbjni-${actual_version}.jar" ]]; then
        log_message "ERROR: YCSB distribution does not contain the expected original launcher and JNI JAR"
        return 40
    fi
    if ! cmp -s "${jar_path}" "${YCSB_DIST_DIR}/lib/rocksdbjni-${actual_version}.jar"; then
        log_message "ERROR: YCSB distribution JNI JAR differs from the locally built RocksDB JAR"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}
