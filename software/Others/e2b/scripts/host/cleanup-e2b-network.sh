#!/usr/bin/env bash
# Reclaim the host-side network state that the e2b sandbox orchestrator leaves
# behind.
#
# Every sandbox gets a network namespace (`/var/run/netns/ns-<n>`), a host veth
# (`veth-<n>`) and a handful of iptables redirects (80 -> 5016, 443 -> 5017,
# the rest -> 5018, plus the `192.0.2.1` NFS/HTTP shims).  The vendor's stop
# path only runs `umount /var/run/netns/* && rm -f /var/run/netns/*`: because of
# the `&&` a single busy namespace aborts the `rm`, and nothing ever removes the
# veths or the iptables rules.  Repeated --start/--stop cycles therefore
# accumulate >1k namespaces, hundreds of veths and thousands of rules, and every
# `ip` call then prints "Peer netns reference is invalid" for the orphans.
#
# Deleting rules one by one is unusably slow once the table holds thousands of
# entries (every `iptables -D` walks the table), so the rules are rewritten with
# one `iptables-save | filter | iptables-restore` pass per table.
#
# Modes (all idempotent):
#   --rules-only  drop only the rules whose `-i veth-<n>` device is gone
#   --netns       drop the namespace files that no live process uses
#   --veth        drop `veth-<n>` links whose namespace is gone
#   --containers  remove the exited `start-*` containers of the suite (the live
#                 Nomad service allocations of `api`/`client-proxy`/`redis`/
#                 `template-manager` are never touched, see
#                 is_suite_service_container)
#   --helpers     signal the orphan Nomad logmon/executor/docker_logger children
#   --sandbox-leftovers
#                 drop the per-sandbox egress SNAT rules; only call it right
#                 after GET /sandboxes returned `[]`
#   --stale       rules-only + netns + veth + exited containers (safe while the
#                 suite is still running)
#   --all         everything, including live namespaces/veths, the `postgres`
#                 container and the 127.0.0.1:80 -> 3002 redirect (use after
#                 `build.sh --stop`)
set -uo pipefail

NETNS_DIR="${E2B_NETNS_DIR:-/var/run/netns}"
VETH_RE='veth-[0-9]+'

log() { printf '[e2b-net] %s\n' "$*"; }

need_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log 'ERROR: this cleanup has to run as root'
        exit 1
    fi
}

# The inode of a namespace is what /proc/<pid>/ns/net points at, so the live set
# tells us which `ns-*` files still back a running sandbox.
live_netns_inodes() {
    local path
    for path in /proc/[0-9]*/ns/net; do
        [[ -e "${path}" ]] || continue
        stat -L -c '%i' "${path}" 2>/dev/null
    done | sort -u
}

live_veth_devices() {
    ip -o link show 2>/dev/null | grep -oE "\\b${VETH_RE}\\b" | sort -u
}

cleanup_netns() {
    local delete_all="$1" live entry name inode removed=0
    live="$(live_netns_inodes)"
    shopt -s nullglob
    for entry in "${NETNS_DIR}"/ns-*; do
        [[ -e "${entry}" ]] || continue
        if [[ "${delete_all}" != "1" ]]; then
            inode="$(stat -L -c '%i' "${entry}" 2>/dev/null)"
            if [[ -n "${inode}" ]] && grep -qx -- "${inode}" <<<"${live}"; then
                continue
            fi
        fi
        name="$(basename "${entry}")"
        umount "${entry}" >/dev/null 2>&1 || true
        rm -f "${entry}" 2>/dev/null && removed=$((removed + 1))
    done
    shopt -u nullglob
    [[ "${removed}" -gt 0 ]] && log "removed ${removed} network namespace(s)"
    return 0
}

cleanup_veths() {
    local delete_all="$1" dev removed=0
    for dev in $(live_veth_devices); do
        if [[ "${delete_all}" != "1" ]] && [[ -e "${NETNS_DIR}/ns-${dev#veth-}" ]]; then
            continue
        fi
        if ip link del "${dev}" >/dev/null 2>&1; then
            removed=$((removed + 1))
        fi
    done
    [[ "${removed}" -gt 0 ]] && log "removed ${removed} veth device(s)"
    return 0
}

# One pass per table: keep every rule except the ones bound to a veth that no
# longer exists (`delete_all=1` drops every veth rule).
cleanup_rules() {
    local delete_all="$1" table tmp live removed=0 kept
    live="$(mktemp)"; tmp="$(mktemp)"
    live_veth_devices >"${live}"
    for table in nat filter; do
        if ! iptables-save -t "${table}" >"${tmp}" 2>/dev/null; then
            continue
        fi
        local rules before after
        before="$(wc -l <"${tmp}")"
        awk -v all="${delete_all}" -v livefile="${live}" -v snat="${E2B_SANDBOX_SNAT_PREFIX:-10.11.}" '
            BEGIN { while ((getline d < livefile) > 0) live[d] = 1 }
            {
                if (match($0, /veth-[0-9]+/)) {
                    dev = substr($0, RSTART, RLENGTH)
                    if (all == "1" || !(dev in live)) { removed++; next }
                }
                if (all == "1" && index($0, "-A POSTROUTING") == 1 &&
                    index($0, "-s " snat) > 0 && index($0, "MASQUERADE") > 0) { removed++; next }
                print
            }
            END { printf("%d\n", removed + 0) > "/dev/stderr" }
        ' "${tmp}" >"${tmp}.new" 2>"${tmp}.cnt"
        removed="$(cat "${tmp}.cnt" 2>/dev/null)"
        after="$(wc -l <"${tmp}.new")"
        if [[ "${before}" != "${after}" ]]; then
            # `iptables-restore` flushes the table before loading it, so a bad
            # file would leave the host without NAT rules: validate first.
            if iptables-restore --test <"${tmp}.new" 2>/dev/null \
                && iptables-restore <"${tmp}.new" 2>/dev/null; then
                log "table ${table}: dropped $((before - after)) rule(s)"
            else
                log "WARN: table ${table}: iptables-restore rejected the filtered rules; left untouched"
            fi
        fi
        rm -f "${tmp}.new" "${tmp}.cnt"
    done
    rm -f "${live}" "${tmp}"
    return 0
}

# Each sandbox also gets a per-address egress rule
# `-A POSTROUTING -s 10.11.x.y/32 -o <uplink> -j MASQUERADE`. Those rules carry no
# veth name, so they survive both the vendor delete path and the veth sweep; they
# are only dropped when the caller has just confirmed that the API lists no
# sandboxes at all.
cleanup_sandbox_snat() {
    local snat="${E2B_SANDBOX_SNAT_PREFIX:-10.11.}" tmp removed before after
    tmp="$(mktemp)"
    iptables-save -t nat >"${tmp}" 2>/dev/null || { rm -f "${tmp}"; return 0; }
    before="$(wc -l <"${tmp}")"
    awk -v snat="${snat}" '
        index($0, "-A POSTROUTING") == 1 && index($0, "-s " snat) > 0 && index($0, "MASQUERADE") > 0 { next }
        { print }
    ' "${tmp}" >"${tmp}.new"
    after="$(wc -l <"${tmp}.new")"
    removed=$((before - after))
    if [[ "${removed}" -gt 0 ]] && iptables-restore --test <"${tmp}.new" 2>/dev/null \
        && iptables-restore <"${tmp}.new" 2>/dev/null; then
        log "dropped ${removed} sandbox egress rule(s)"
    fi
    rm -f "${tmp}" "${tmp}.new"
    return 0
}

# The control plane runs as Nomad *service* allocations, and Docker names those
# containers `start-<alloc-id>` just like everything else Nomad starts. They are
# the suite itself, not leftovers: deleting them takes `api`, `client-proxy` and
# `redis` down and every API call fails until Nomad restarts them.
is_suite_service_container() {
    local name="$1" job
    job="$(docker inspect "${name}" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
        | sed -n 's/^NOMAD_JOB_NAME=//p' | head -1)"
    case "${job}" in
        api|client-proxy|redis|template-manager|orchestrator) return 0 ;;
    esac
    return 1
}

cleanup_output_redirect() {
    local removed=0
    while iptables -t nat -C OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-port 3002 2>/dev/null; do
        iptables -t nat -D OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-port 3002 2>/dev/null || break
        removed=$((removed + 1))
    done
    [[ "${removed}" -gt 0 ]] && log 'removed the 127.0.0.1:80 -> 3002 redirect'
    return 0
}

cleanup_containers() {
    local delete_all="$1" name removed=0
    for name in $(docker ps -a --filter status=exited --filter status=created \
        --format '{{.Names}}' 2>/dev/null | grep -E '^start-[0-9a-f-]+$'); do
        is_suite_service_container "${name}" && continue
        docker rm "${name}" >/dev/null 2>&1 && removed=$((removed + 1))
    done
    if [[ "${delete_all}" == "1" ]] && [[ -f /opt/e2b-infra/.env ]] \
        && docker inspect postgres >/dev/null 2>&1; then
        # build.sh keeps the database in a plain `postgres` container; it is part
        # of the suite, so it goes with the suite.
        if docker inspect postgres --format '{{.Config.Image}}' 2>/dev/null | grep -q '^postgres'; then
            docker rm -f postgres >/dev/null 2>&1 && removed=$((removed + 1))
        fi
    fi
    [[ "${removed}" -gt 0 ]] && log "removed ${removed} suite container(s)"
    return 0
}

# `build.sh --stop` kills the agents but leaves their logmon/executor/docker_logger
# children behind; those hold `/data` (and therefore block the CubeSandbox image
# from being released).
cleanup_helpers() {
    local removed=0
    for name in logmon docker_logger executor; do
        if pkill -f "/opt/nomad/bin/nomad ${name}" 2>/dev/null; then
            removed=$((removed + 1))
        fi
    done
    [[ "${removed}" -gt 0 ]] && log "signalled orphan Nomad ${removed} helper process group(s)"
    return 0
}

main() {
    local mode="${1:---stale}"
    need_root
    case "${mode}" in
        --rules-only) cleanup_rules 0 ;;
        --netns) cleanup_netns 0 ;;
        --veth) cleanup_veths 0 ;;
        --containers) cleanup_containers 0 ;;
        --helpers) cleanup_helpers ;;
        --sandbox-leftovers)
            # The caller has already confirmed that GET /sandboxes is empty.
            cleanup_sandbox_snat
            ;;
        --stale)
            cleanup_netns 0
            cleanup_veths 0
            cleanup_rules 0
            cleanup_containers 0
            ;;
        --all)
            cleanup_helpers
            cleanup_netns 1
            cleanup_veths 1
            cleanup_rules 1
            cleanup_output_redirect
            cleanup_containers 1
            ;;
        *)
            log "usage: $0 [--rules-only|--netns|--veth|--containers|--helpers|--sandbox-leftovers|--stale|--all]"
            return 2
            ;;
    esac
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
