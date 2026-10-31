#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_lua_runtime() {
    initialize_runtime || return $?
    [[ -x "${LUA_BIN}" ]] || {
        log_message "ERROR: lua executable is unavailable: ${LUA_BIN}"
        return 40
    }
    [[ -x "${LUAC_BIN}" ]] || {
        log_message "ERROR: luac executable is unavailable: ${LUAC_BIN}"
        return 40
    }
    local version
    version="$("${LUA_BIN}" -v 2>&1 | awk '{print $2; exit}')"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected Lua ${SOFTWARE_VERSION}, built interpreter reports ${version:-unknown}"
        return 40
    fi
    [[ -f "${LUA_TESTS_DIR}/all.lua" ]] || {
        log_message "ERROR: upstream test suite is missing: ${LUA_TESTS_DIR}/all.lua"
        return 40
    }
    [[ -f "${LUA_GENERATED_DIR}/main.lua" ]] || {
        log_message "ERROR: generated luac workload is missing: ${LUA_GENERATED_DIR}/main.lua"
        return 40
    }
    local modules
    modules="$(find "${LUA_GENERATED_DIR}" -maxdepth 1 -name 'module_*.lua' | wc -l)"
    if [[ "${modules}" -ne "${LUA_GENERATED_MODULES}" ]]; then
        log_message "ERROR: expected ${LUA_GENERATED_MODULES} generated modules, found ${modules}"
        return 40
    fi
    [[ -f "${LUA_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${LUA_SCENARIOS_FILE}"
        return 40
    }
    local scenarios
    scenarios="$(scenario_count)" || scenarios=0
    if [[ "${scenarios}" -lt 1 ]]; then
        log_message "ERROR: workload matrix manifest has no scenarios"
        return 40
    fi
    log_message "Lua ${version} runtime is ready: ${scenarios} scenarios, ${modules} generated modules, upstream test suite extracted"
}
