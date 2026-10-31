#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        curl) printf 'curl\n' ;;
        tar) printf 'tar\n' ;;
        xz) printf 'xz\n' ;;
        sha256sum) printf 'coreutils\n' ;;
        python3) printf 'python3\n' ;;
        cc) printf 'gcc\n' ;;
        java) printf '%s\n' "${REACT_JAVA_PACKAGE}" ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

require_commands() {
    local missing=() command_name
    for command_name in "$@"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            missing+=("${command_name}")
        fi
    done
    if (( ${#missing[@]} == 0 )); then
        return 0
    fi
    log_message "missing commands: ${missing[*]}"
    local packages=() package
    for command_name in "${missing[@]}"; do
        package="$(package_for_command "${command_name}")"
        packages+=("${package}")
    done
    local installer=()
    if command -v dnf >/dev/null 2>&1; then
        installer=(dnf install -y)
        if [[ "$(id -u)" -ne 0 ]]; then
            if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
                log_message "ERROR: missing commands ${missing[*]} and dnf needs root or passwordless sudo"
                return 30
            fi
            installer=(sudo -n dnf install -y)
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        installer=(apt-get install -y)
        if [[ "$(id -u)" -ne 0 ]]; then
            if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
                log_message "ERROR: missing commands ${missing[*]} and apt-get needs root or passwordless sudo"
                return 30
            fi
            installer=(sudo -n apt-get install -y)
        fi
    else
        log_message "ERROR: missing commands ${missing[*]} and no supported package manager"
        return 30
    fi
    if [[ -n "${PERF_PROXY:-}" ]]; then
        export http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}"
        export HTTP_PROXY="${PERF_PROXY}" HTTPS_PROXY="${PERF_PROXY}"
    fi
    log_message "installing missing system packages: ${packages[*]}"
    if ! "${installer[@]}" "${packages[@]}"; then
        log_message "ERROR: failed to install system packages: ${packages[*]}"
        return 30
    fi
}

verify_sha256() {
    local path="$1"
    local expected="$2"
    local label="${3:-$(basename "${path}")}"
    local actual
    if [[ ! -f "${path}" ]]; then
        log_message "ERROR: archive is missing: ${path}"
        return 30
    fi
    if ! actual="$(sha256sum "${path}" | awk '{print $1}')"; then
        log_message "ERROR: cannot compute SHA-256 for ${label}"
        return 30
    fi
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: SHA-256 mismatch for ${label}: expected ${expected}, got ${actual}"
        return 30
    fi
    log_message "verified sha256 ${label}"
}

download_to() {
    local url="$1" destination="$2" label="$3"
    log_message "downloading ${label}: ${url}"
    if curl --fail --silent --show-error --location \
        --retry 3 --retry-delay 5 --connect-timeout 20 --max-time 600 \
        --output "${destination}.partial" "${url}"; then
        mv -- "${destination}.partial" "${destination}"
        return 0
    fi
    rm -f -- "${destination}.partial"
    log_message "WARN: download failed for ${label}: ${url}"
    return 1
}

# Resolve one pinned archive. A pre-placed file in the offline directory wins and
# is verified; otherwise each configured source is tried in order and the result
# must still match the pinned SHA-256. There is no fallback to an unverified file.
materialize_asset() {
    local name="$1" sha256="$2" label="$3"
    shift 3
    local destination="${PERF_WORK_DIR}/assets/${name}"
    local offline="${REACT_OFFLINE_DIR}/${name}"
    mkdir -p "${PERF_WORK_DIR}/assets"
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -f -- "${offline}" "${destination}"
        if verify_sha256 "${destination}" "${sha256}" "${label}"; then
            return 0
        fi
        log_message "ERROR: pre-placed offline asset is corrupt: ${offline}"
        return 30
    fi
    if [[ -f "${destination}" ]] && verify_sha256 "${destination}" "${sha256}" "${label}" >/dev/null 2>&1; then
        return 0
    fi
    rm -f -- "${destination}"
    local url
    for url in "$@"; do
        if download_to "${url}" "${destination}" "${label}" && \
            verify_sha256 "${destination}" "${sha256}" "${label}"; then
            return 0
        fi
        rm -f -- "${destination}"
    done
    log_message "ERROR: could not obtain a verified ${label}; tried offline directory ${REACT_OFFLINE_DIR} and download sources"
    return 30
}

install_node_runtime() {
    rm -rf -- "${REACT_NODE_HOME}"
    mkdir -p "${REACT_NODE_HOME}"
    if ! tar -xJf "${PERF_WORK_DIR}/assets/${REACT_NODE_ARCHIVE_NAME}" \
        -C "${REACT_NODE_HOME}" --strip-components=1; then
        log_message "ERROR: failed to extract Node.js archive"
        return 30
    fi
    if [[ ! -x "${REACT_NODE_BIN}" ]]; then
        log_message "ERROR: Node.js launcher is missing after extraction: ${REACT_NODE_BIN}"
        return 30
    fi
    local version
    version="$(node_version_string)" || version=""
    if [[ "${version}" != "v${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js v${NODE_VERSION}, got: ${version:-<unknown>}"
        return 30
    fi
    log_message "Node.js runtime ready: ${version} (npm $( "${REACT_NPM_CLI}" --version 2>/dev/null || echo unknown ))"
}

install_yarn() {
    local extract_dir="${PERF_WORK_DIR}/yarn-extract"
    rm -rf -- "${extract_dir}" "${PERF_WORK_DIR}/yarn"
    mkdir -p "${extract_dir}"
    if ! tar -xzf "${PERF_WORK_DIR}/assets/${YARN_ARCHIVE_NAME}" \
        -C "${extract_dir}" --strip-components=1; then
        log_message "ERROR: failed to extract the pinned Yarn archive"
        return 30
    fi
    mv -- "${extract_dir}" "${PERF_WORK_DIR}/yarn"
    if [[ ! -f "${REACT_YARN_JS}" ]]; then
        log_message "ERROR: Yarn launcher is missing: ${REACT_YARN_JS}"
        return 30
    fi
    local version
    version="$(yarn_version_string)" || version=""
    if [[ "${version}" != "${YARN_VERSION}" ]]; then
        log_message "ERROR: expected Yarn ${YARN_VERSION}, got: ${version:-<unknown>}"
        return 30
    fi
    log_message "Yarn ready: ${version}"
}

install_react_runtime() {
    rm -rf -- "${REACT_APP_DIR}"
    mkdir -p "${REACT_APP_DIR}"
    cat > "${REACT_APP_DIR}/package.json" <<'JSON'
{
  "name": "boostkit-react-ssr-matrix",
  "private": true,
  "version": "0.0.0"
}
JSON
    local archives=()
    archives+=("${PERF_WORK_DIR}/assets/${REACT_ARCHIVE_NAME}")
    archives+=("${PERF_WORK_DIR}/assets/${REACT_DOM_ARCHIVE_NAME}")
    archives+=("${PERF_WORK_DIR}/assets/${SCHEDULER_ARCHIVE_NAME}")
    if ! ( cd "${REACT_APP_DIR}" && "${REACT_NPM_CLI}" install \
        --offline --no-audit --no-fund --no-save --loglevel=error \
        "${archives[@]}" ); then
        log_message "ERROR: offline npm install of the pinned React packages failed"
        return 30
    fi
    local version
    version="$(react_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react ${SOFTWARE_VERSION}, installed: ${version:-<unknown>}"
        return 30
    fi
    version="$(react_dom_version_string)" || version=""
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react-dom ${SOFTWARE_VERSION}, installed: ${version:-<unknown>}"
        return 30
    fi
    log_message "React runtime ready: react $(react_version_string), react-dom $(react_dom_version_string)"
    if ! cp -f -- "${REACT_BENCH_SCRIPT}" "${REACT_APP_BENCH_SCRIPT}"; then
        log_message "ERROR: failed to install the SSR harness into ${REACT_APP_DIR}"
        return 30
    fi
    log_message "SSR harness installed: ${REACT_APP_BENCH_SCRIPT}"
}

install_react_source() {
    rm -rf -- "${REACT_SOURCE_DIR}"
    mkdir -p "${REACT_SOURCE_DIR}"
    if ! tar -xzf "${PERF_WORK_DIR}/assets/${REACT_SOURCE_NAME}" \
        -C "${REACT_SOURCE_DIR}" --strip-components=1; then
        log_message "ERROR: failed to extract the React ${SOFTWARE_VERSION} source archive"
        return 30
    fi
    local source_version
    source_version="$(react_source_version_string)" || source_version=""
    if [[ "${source_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: React source tree reports ${source_version:-<unknown>}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    # The upstream lockfile pins registry.yarnpkg.com URLs. Point them at the
    # configured mirror so the build stage is not tied to one registry host; the
    # pinned integrity hashes in the lockfile still verify every package.
    local mirror_host="${REACT_REGISTRY%%/}"
    if grep -q 'https://registry.yarnpkg.com/' "${REACT_SOURCE_DIR}/yarn.lock"; then
        sed -i "s#https://registry.yarnpkg.com/#${mirror_host}/#g" "${REACT_SOURCE_DIR}/yarn.lock"
    fi
    cat > "${REACT_SOURCE_DIR}/.yarnrc" <<YARNRC
registry "${REACT_REGISTRY}"
network-timeout 600000
YARNRC
    cat > "${REACT_SOURCE_DIR}/.npmrc" <<NPMRC
registry=${REACT_REGISTRY}
NPMRC
    log_message "React ${SOFTWARE_VERSION} source tree ready: ${REACT_SOURCE_DIR}"
}

yarn_install_react_source() {
    if [[ -f "${REACT_SOURCE_DIR}/node_modules/.yarn-integrity" ]]; then
        log_message "reusing the installed React source dependencies"
        return 0
    fi
    log_message "installing upstream React source dependencies with Yarn ${YARN_VERSION}"
    # The repository's devDependencies contain binary-download postinstalls
    # (electron, optipng-bin, gifsicle, jpegtran-bin, ...) that are only used by
    # the documentation/screenshot tooling, not by the release build. They fetch
    # archives from hosts that are unrelated to the measured workload, so the
    # install runs with --ignore-scripts plus the documented skip switches: the
    # release build itself is pure rollup + babel + closure-compiler JavaScript.
    if ! ( cd "${REACT_SOURCE_DIR}" && \
        env -u NODE_ENV \
            ELECTRON_SKIP_BINARY_DOWNLOAD=1 \
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
            PUPPETEER_SKIP_DOWNLOAD=1 \
            PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 \
            "${REACT_NODE_BIN}" "${REACT_YARN_JS}" install \
            --frozen-lockfile --ignore-engines --ignore-scripts --non-interactive --no-progress \
            --network-timeout 600000 ); then
        log_message "ERROR: yarn install failed for the React source tree"
        return 30
    fi
    if [[ ! -d "${REACT_SOURCE_DIR}/node_modules/rollup" ]]; then
        log_message "ERROR: rollup is missing after yarn install"
        return 30
    fi
    log_message "upstream React source dependencies installed: $( du -sh "${REACT_SOURCE_DIR}/node_modules" | cut -f1 )"
}

smoke_check_react_runtime() {
    local output="${PERF_WORK_DIR}/bench-smoke.json"
    if ! ( cd "${REACT_APP_DIR}" && env NODE_ENV=production "${REACT_NODE_BIN}" \
        "${REACT_APP_BENCH_SCRIPT}" --task render_to_string --items 100 --renders 5 \
        --warmup 1 --output "${output}" >/dev/null ); then
        log_message "ERROR: smoke check failed: React SSR renderToString of 100 items"
        return 30
    fi
    if [[ ! -s "${output}" ]]; then
        log_message "ERROR: smoke check did not produce a benchmark result"
        return 30
    fi
    log_message "smoke check passed"
}

smoke_check_upstream_build() {
    local log="${RESULTS_DIR}/upstream-build-smoke.log"
    local output="${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_OUTPUT}"
    rm -rf -- "${output}"
    log_message "smoke check: upstream production bundle build"
    if ! ( cd "${REACT_SOURCE_DIR}" && env -u NODE_ENV "${REACT_NODE_BIN}" \
        "${REACT_UPSTREAM_BUILD_SCRIPT}" "${REACT_UPSTREAM_BUILD_ENTRIES}" \
        "--type=${REACT_UPSTREAM_BUILD_TYPES}" \
        "--release-channel=${REACT_UPSTREAM_RELEASE_CHANNEL}" ) >"${log}" 2>&1; then
        log_message "ERROR: upstream React production bundle build failed; see ${log}"
        return 30
    fi
    # `set -o pipefail` would turn the SIGPIPE of an early-closing `grep -q` into a
    # spurious failure, so test the first artefact through a command substitution.
    if [[ -z "$( find "${output}" -type f -print -quit 2>/dev/null )" ]]; then
        {
            printf '# diagnostic: no artefacts after upstream build\n'
            printf '# cwd: %s\n' "${REACT_SOURCE_DIR}"
            printf '# build directory listing:\n'
            ls -la "${output}" 2>&1 || true
            printf '# source tree top level:\n'
            ls -la "${REACT_SOURCE_DIR}" 2>&1 | head -30
        } >>"${log}"
        log_message "ERROR: upstream React build produced no artefacts; see ${log}"
        return 30
    fi
    log_message "upstream build smoke check passed"
}

build_react_base() {
    require_commands curl tar xz sha256sum python3 java || return $?
    materialize_asset "${REACT_NODE_ARCHIVE_NAME}" "${REACT_NODE_ARCHIVE_SHA256}" \
        "${REACT_NODE_ARCHIVE_NAME}" "${REACT_NODE_ARCHIVE_URL}" "${REACT_NODE_ARCHIVE_URL_FALLBACK}" || return $?
    materialize_asset "${YARN_ARCHIVE_NAME}" "${YARN_SHA256}" "${YARN_ARCHIVE_NAME}" \
        "${REACT_REGISTRY}/yarn/-/${YARN_ARCHIVE_NAME}" "${REGISTRY_OFFICIAL}/yarn/-/${YARN_ARCHIVE_NAME}" || return $?
    materialize_asset "${REACT_ARCHIVE_NAME}" "${REACT_SHA256}" "${REACT_ARCHIVE_NAME}" \
        "${REACT_REGISTRY}/react/-/${REACT_ARCHIVE_NAME}" "${REGISTRY_OFFICIAL}/react/-/${REACT_ARCHIVE_NAME}" || return $?
    materialize_asset "${REACT_DOM_ARCHIVE_NAME}" "${REACT_DOM_SHA256}" "${REACT_DOM_ARCHIVE_NAME}" \
        "${REACT_REGISTRY}/react-dom/-/${REACT_DOM_ARCHIVE_NAME}" "${REGISTRY_OFFICIAL}/react-dom/-/${REACT_DOM_ARCHIVE_NAME}" || return $?
    materialize_asset "${SCHEDULER_ARCHIVE_NAME}" "${SCHEDULER_SHA256}" "${SCHEDULER_ARCHIVE_NAME}" \
        "${REACT_REGISTRY}/scheduler/-/${SCHEDULER_ARCHIVE_NAME}" "${REGISTRY_OFFICIAL}/scheduler/-/${SCHEDULER_ARCHIVE_NAME}" || return $?
    materialize_asset "${REACT_SOURCE_NAME}" "${REACT_SOURCE_SHA256}" "${REACT_SOURCE_NAME}" \
        "https://codeload.github.com/facebook/react/tar.gz/refs/tags/${REACT_SOURCE_TAG}" \
        "https://gh-proxy.com/https://github.com/facebook/react/archive/refs/tags/${REACT_SOURCE_TAG}.tar.gz" || return $?

    install_node_runtime || return $?
    install_yarn || return $?
    install_react_runtime || return $?
    install_react_source || return $?
    yarn_install_react_source || return $?
    react_record_actual_version || return $?
    smoke_check_react_runtime || return $?
    smoke_check_upstream_build || return $?
    log_message "base build completed: React ${SOFTWARE_VERSION}, Node.js v${NODE_VERSION}, Yarn ${YARN_VERSION}, npm $( "${REACT_NPM_CLI}" --version 2>/dev/null || echo unknown )"
}
