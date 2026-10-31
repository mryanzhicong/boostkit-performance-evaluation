#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_php_runtime() {
    initialize_runtime || return $?
    [[ -x "${PHP_BIN}" ]] || {
        log_message "ERROR: php executable is unavailable: ${PHP_BIN}"
        return 40
    }
    local version
    version="$("${PHP_BIN}" -v 2>&1 | sed -n 's/^PHP \([0-9][0-9.]*\).*/\1/p' | head -n 1)"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected PHP ${SOFTWARE_VERSION}, built CLI reports ${version:-unknown}"
        return 40
    fi
    [[ -f "${PHP_SRC_DIR}/Zend/bench.php" && -f "${PHP_SRC_DIR}/Zend/micro_bench.php" ]] || {
        log_message "ERROR: upstream Zend benchmarks are missing under ${PHP_SRC_DIR}"
        return 40
    }
    local modules
    modules="$(find "${PHP_GENERATED_DIR}" -maxdepth 1 -name 'module_*.php' | wc -l)"
    if [[ "${modules}" -ne "${PHP_GENERATED_MODULES}" ]]; then
        log_message "ERROR: expected ${PHP_GENERATED_MODULES} generated modules, found ${modules}"
        return 40
    fi
    [[ -f "${PHP_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${PHP_SCENARIOS_FILE}"
        return 40
    }
    local scenarios
    scenarios="$(scenario_count)" || scenarios=0
    if [[ "${scenarios}" -lt 1 ]]; then
        log_message "ERROR: workload matrix manifest has no scenarios"
        return 40
    fi
    export PHP_MODULES_DIR="${PHP_GENERATED_DIR}"
    log_message "PHP ${version} runtime is ready: ${scenarios} scenarios, ${modules} generated modules, upstream Zend benchmarks present"
}
