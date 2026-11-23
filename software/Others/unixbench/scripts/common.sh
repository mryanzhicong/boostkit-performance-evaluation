#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.0.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
UNIXBENCH_ARCHIVE_DIR="${UNIXBENCH_ARCHIVE_DIR:-/home/runner/software/unixbench}"
UNIXBENCH_ARCHIVE_URL="https://github.com/kdlucas/byte-unixbench/archive/refs/tags/v6.0.1.tar.gz"
UNIXBENCH_ARCHIVE_SHA256="e52257ae9ba6294a0c5804d802745294cf536e8c8d9383aabff7a8b039e31faa"
# The benchmark runs inside a dedicated KVM virtual machine, never in a container.
UNIXBENCH_VM_IMAGE_DIR="${UNIXBENCH_VM_IMAGE_DIR:-/home/libvirt-images}"
UNIXBENCH_VM_KEY="${UNIXBENCH_VM_KEY:-/home/runner/software/unixbench/vm/id_ed25519}"
UNIXBENCH_VM_NETWORK="${UNIXBENCH_VM_NETWORK:-default}"
UNIXBENCH_VM_VCPUS=32
UNIXBENCH_VM_MEM_KIB=67108864
UNIXBENCH_VM_HUGE_NODE=1
UNIXBENCH_VM_HUGE_PAGES=32768
UNIXBENCH_VM_NAME=""
UNIXBENCH_VM_IMAGE=""
UNIXBENCH_VM_RUN_DIR=""
UNIXBENCH_VM_OVERLAY=""
UNIXBENCH_VM_NVRAM=""
UNIXBENCH_VM_STATE_FILE=""
UNIXBENCH_VM_CPUSET=""
UNIXBENCH_VM_IP=""
GUEST_SOURCE_DIR="/root/byte-unixbench-6.0.1"
GUEST_RUN_DIR="${GUEST_SOURCE_DIR}/UnixBench"
GUEST_RESULTDIR="/root/unixbench-results/unixbench-official"
GUEST_TMPDIR="/root/unixbench-results/tmp"
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log() { printf '[unixbench] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"; }

normalize_arch() {
    case "${1,,}" in
        x86_64|amd64) printf 'x86_64\n' ;;
        aarch64|arm64) printf 'aarch64\n' ;;
        *) printf '%s\n' "${1,,}" ;;
    esac
}

configure_runtime_paths() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || { log 'ERROR: unsafe run ID'; return 10; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    case "${EXPECTED_ARCH}" in
        x86_64|aarch64) ;;
        *) log "ERROR: unsupported architecture: ${EXPECTED_ARCH}"; return 10 ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    elif [[ "${RESULTS_DIR}" != /* ]]; then
        RESULTS_DIR="$(pwd -P)/${RESULTS_DIR}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/unixbench/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    elif [[ "${PERF_WORK_DIR}" != /* ]]; then
        log 'ERROR: PERF_WORK_DIR must be an absolute path'
        return 10
    fi
    [[ "${PERF_WORK_DIR}" != / && "${PERF_WORK_DIR}" != /home/runner && "${PERF_WORK_DIR}" != /home/runner/boostkit-perf ]] || {
        log 'ERROR: PERF_WORK_DIR is too broad for a private run'
        return 10
    }
    TMPDIR="${PERF_WORK_DIR}/tmp"
    UB_RESULTDIR="${RESULTS_DIR}/unixbench-official"
    UB_TMPDIR="${PERF_WORK_DIR}/unixbench-tmp"
    UB_OUTPUT_FILE_NAME="unixbench-index"
    UNIXBENCH_VM_NAME="boostkit-unixbench-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    UNIXBENCH_VM_IMAGE="${UNIXBENCH_VM_IMAGE_DIR}/boostkit-unixbench-golden-${EXPECTED_ARCH}.qcow2"
    UNIXBENCH_VM_RUN_DIR="${UNIXBENCH_VM_IMAGE_DIR}/runs/${PERF_RUN_ID}"
    UNIXBENCH_VM_OVERLAY="${UNIXBENCH_VM_RUN_DIR}/system.qcow2"
    UNIXBENCH_VM_NVRAM="${UNIXBENCH_VM_RUN_DIR}/nvram.fd"
    UNIXBENCH_VM_STATE_FILE="${PERF_WORK_DIR}/vm-state.env"
    case "${EXPECTED_ARCH}" in
        x86_64) UNIXBENCH_VM_CPUSET="24-39,216-231" ;;
        aarch64) UNIXBENCH_VM_CPUSET="96-127" ;;
    esac
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR UB_RESULTDIR UB_TMPDIR UB_OUTPUT_FILE_NAME
    export UNIXBENCH_VM_NAME UNIXBENCH_VM_IMAGE UNIXBENCH_VM_RUN_DIR UNIXBENCH_VM_OVERLAY
    export UNIXBENCH_VM_NVRAM UNIXBENCH_VM_STATE_FILE UNIXBENCH_VM_CPUSET
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${UB_RESULTDIR}" "${UB_TMPDIR}"
    cd "${SCRIPT_DIR}"
    return 0
}

with_network_proxy() {
    if [[ -n "${PERF_PROXY:-}" ]]; then
        http_proxy="${PERF_PROXY}" https_proxy="${PERF_PROXY}" "$@"
    else
        "$@"
    fi
}

vm_guest_proxy_value() {
    # A proxy bound to the host loopback is reached from the guest through virbr0.
    printf '%s\n' "${PERF_PROXY//127.0.0.1/192.168.122.1}"
}

require_unixbench_vm_host() {
    local name
    for name in virsh qemu-img ssh scp sha256sum tar python3 awk sed grep; do
        command -v "${name}" >/dev/null 2>&1 || {
            log "ERROR: required host command is missing: ${name}"
            return 30
        }
    done
    [[ -c /dev/kvm ]] || { log 'ERROR: /dev/kvm is missing; KVM is required'; return 30; }
    [[ -f "${UNIXBENCH_VM_IMAGE}" ]] || {
        log "ERROR: golden VM image is missing: ${UNIXBENCH_VM_IMAGE}"
        log 'ERROR: run scripts/host/prepare-vm-host.sh on this runner first'
        return 30
    }
    [[ -r "${UNIXBENCH_VM_KEY}" ]] || {
        log "ERROR: VM SSH key is missing: ${UNIXBENCH_VM_KEY}"; return 30
    }
    sudo -n virsh version >/dev/null 2>&1 || {
        log 'ERROR: passwordless sudo for virsh is required on this runner'; return 30
    }
    return 0
}

load_unixbench_vm_state() {
    [[ -f "${UNIXBENCH_VM_STATE_FILE}" ]] || return 0
    # shellcheck disable=SC1090
    source "${UNIXBENCH_VM_STATE_FILE}"
    return 0
}

save_unixbench_vm_state() {
    {
        printf 'UNIXBENCH_VM_NAME=%q\n' "${UNIXBENCH_VM_NAME}"
        printf 'UNIXBENCH_VM_IP=%q\n' "${UNIXBENCH_VM_IP:-}"
        printf 'UNIXBENCH_VM_RUN_DIR=%q\n' "${UNIXBENCH_VM_RUN_DIR}"
        printf 'UNIXBENCH_VM_OVERLAY=%q\n' "${UNIXBENCH_VM_OVERLAY}"
        printf 'UNIXBENCH_VM_CPUSET=%q\n' "${UNIXBENCH_VM_CPUSET}"
    } > "${UNIXBENCH_VM_STATE_FILE}"
}

vm_ssh_opts() {
    printf '%s\n' \
        -p 22 \
        -i "${UNIXBENCH_VM_KEY}" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=10 \
        -o ServerAliveInterval=30
}

vm_scp_opts() {
    printf '%s\n' \
        -P 22 \
        -i "${UNIXBENCH_VM_KEY}" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=10
}

vm_exec() {
    local -a options=()
    local remote_command
    mapfile -t options < <(vm_ssh_opts)
    remote_command="$(printf '%q ' "$@")"
    ssh "${options[@]}" "root@${UNIXBENCH_VM_IP}" "${remote_command}"
}

vm_exec_shell() {
    local -a options=()
    mapfile -t options < <(vm_ssh_opts)
    ssh "${options[@]}" "root@${UNIXBENCH_VM_IP}" "$1"
}

vm_copy_in() {
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "$1" "root@${UNIXBENCH_VM_IP}:$2"
}

vm_copy_out() {
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "root@${UNIXBENCH_VM_IP}:$1" "$2"
}

vm_pin_lines() {
    local index host_cpu
    for ((index = 0; index < UNIXBENCH_VM_VCPUS; index++)); do
        if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
            if ((index % 2 == 0)); then
                host_cpu=$((24 + index / 2))
            else
                host_cpu=$((216 + index / 2))
            fi
        else
            host_cpu=$((96 + index))
        fi
        printf "    <vcpupin vcpu='%d' cpuset='%d'/>\n" "${index}" "${host_cpu}"
    done
}

emit_unixbench_vm_xml() {
    local arch_machine arch_type features
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        arch_type="x86_64"
        arch_machine="pc-q35-8.2"
        features="    <acpi/>\n    <apic/>"
    else
        arch_type="aarch64"
        arch_machine="virt"
        features="    <acpi/>"
    fi
    cat <<XML
<domain type='kvm'>
  <name>${UNIXBENCH_VM_NAME}</name>
  <description>boostkit unixbench reference VM: 32 vCPU pinned 1:1 inside one host NUMA node, 64 GiB 2M hugepages, openEuler 24.03 LTS SP4</description>
  <memory unit='KiB'>${UNIXBENCH_VM_MEM_KIB}</memory>
  <currentMemory unit='KiB'>${UNIXBENCH_VM_MEM_KIB}</currentMemory>
  <memoryBacking>
    <hugepages>
      <page size='2048' unit='KiB'/>
    </hugepages>
    <source type='memfd'/>
    <access mode='shared'/>
    <allocation mode='immediate' threads='4'/>
  </memoryBacking>
  <vcpu placement='static'>${UNIXBENCH_VM_VCPUS}</vcpu>
  <cputune>
$(vm_pin_lines)
    <emulatorpin cpuset='${UNIXBENCH_VM_CPUSET}'/>
  </cputune>
  <numatune>
    <memory mode='strict' nodeset='${UNIXBENCH_VM_HUGE_NODE}'/>
  </numatune>
  <os>
    <type arch='${arch_type}' machine='${arch_machine}'>hvm</type>
XML
    if [[ "${EXPECTED_ARCH}" == aarch64 ]]; then
        cat <<XML
    <loader readonly='yes' type='pflash'>/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw</loader>
    <nvram>${UNIXBENCH_VM_NVRAM}</nvram>
XML
    fi
    cat <<XML
    <boot dev='hd'/>
  </os>
  <features>
$(printf "%b" "${features}")
  </features>
  <cpu mode='host-passthrough' check='none' migratable='off'>
    <topology sockets='1' dies='1' clusters='1' cores='16' threads='2'/>
  </cpu>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>preserve</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='${UNIXBENCH_VM_OVERLAY}'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='${UNIXBENCH_VM_NETWORK}'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <log file='${UNIXBENCH_VM_RUN_DIR}/console.log' append='off'/>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <memballoon model='none'/>
  </devices>
</domain>
XML
}

allocate_unixbench_hugepages() {
    local huge_dir="/sys/devices/system/node/node${UNIXBENCH_VM_HUGE_NODE}/hugepages/hugepages-2048kB"
    local current free_pages attempt
    sudo -n test -d "${huge_dir}" || {
        log "ERROR: NUMA node ${UNIXBENCH_VM_HUGE_NODE} does not expose 2M hugepages"
        return 30
    }
    current="$(cat "${huge_dir}/nr_hugepages")"
    if ((current < UNIXBENCH_VM_HUGE_PAGES)); then
        log "allocating ${UNIXBENCH_VM_HUGE_PAGES} 2M hugepages on NUMA node ${UNIXBENCH_VM_HUGE_NODE}"
        sudo -n sh -c "echo ${UNIXBENCH_VM_HUGE_PAGES} > ${huge_dir}/nr_hugepages" || {
            log 'ERROR: failed to allocate hugepages for the reference VM'
            return 30
        }
    fi
    for attempt in $(seq 1 30); do
        free_pages="$(cat "${huge_dir}/free_hugepages")"
        if ((free_pages >= UNIXBENCH_VM_HUGE_PAGES)); then
            log "hugepages ready: node=${UNIXBENCH_VM_HUGE_NODE} free=${free_pages}"
            return 0
        fi
        sleep 1
    done
    log "ERROR: only ${free_pages} free 2M hugepages on node ${UNIXBENCH_VM_HUGE_NODE}"
    return 30
}

release_unixbench_hugepages() {
    local huge_dir="/sys/devices/system/node/node${UNIXBENCH_VM_HUGE_NODE}/hugepages/hugepages-2048kB"
    sudo -n sh -c "echo 0 > ${huge_dir}/nr_hugepages" 2>/dev/null || {
        log 'WARN: hugepages are still in use or could not be released'
        return 0
    }
    log "released 2M hugepages on NUMA node ${UNIXBENCH_VM_HUGE_NODE}"
}

sweep_unixbench_stale_vms() {
    local name
    while IFS= read -r name; do
        [[ -n "${name}" ]] || continue
        [[ "${name}" == "${UNIXBENCH_VM_NAME}" ]] && continue
        log "removing stale reference VM: ${name}"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 || sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    done < <(sudo -n virsh list --all --name 2>/dev/null | grep -E '^boostkit-unixbench-' || true)
    if [[ -d "${UNIXBENCH_VM_IMAGE_DIR}/runs" ]]; then
        find "${UNIXBENCH_VM_IMAGE_DIR}/runs" -mindepth 1 -maxdepth 1 -type d ! -name "${PERF_RUN_ID}" -exec sudo -n rm -rf {} + 2>/dev/null || true
    fi
}

wait_for_unixbench_vm_address() {
    local attempt address
    for attempt in $(seq 1 120); do
        address="$(sudo -n virsh domifaddr "${UNIXBENCH_VM_NAME}" --source lease 2>/dev/null |
            awk '/ipv4/ {print $4}' | cut -d/ -f1 | head -n 1)"
        if [[ -n "${address}" ]]; then
            UNIXBENCH_VM_IP="${address}"
            return 0
        fi
        sleep 2
    done
    return 1
}

wait_for_unixbench_vm_ssh() {
    local attempt cpus
    for attempt in $(seq 1 90); do
        cpus="$(vm_exec nproc 2>/dev/null || true)"
        if [[ "${cpus}" == "${UNIXBENCH_VM_VCPUS}" ]]; then
            return 0
        fi
        sleep 2
    done
    return 1
}

start_unixbench_vm() {
    local xml="${UNIXBENCH_VM_RUN_DIR}/vm.xml"
    require_unixbench_vm_host || return $?
    sweep_unixbench_stale_vms
    allocate_unixbench_hugepages || return $?
    sudo -n mkdir -p "${UNIXBENCH_VM_RUN_DIR}" || return 30
    sudo -n chmod 755 "${UNIXBENCH_VM_RUN_DIR}" || return 30
    sudo -n qemu-img create -q -f qcow2 -F qcow2 -b "${UNIXBENCH_VM_IMAGE}" "${UNIXBENCH_VM_OVERLAY}" || {
        log 'ERROR: failed to create the reference VM overlay disk'; return 40
    }
    emit_unixbench_vm_xml | sudo -n tee "${xml}" >/dev/null || {
        log 'ERROR: failed to render the reference VM definition'; return 40
    }
    sudo -n virsh define "${xml}" >/dev/null || {
        log 'ERROR: libvirt rejected the reference VM definition'; return 40
    }
    log "starting reference VM ${UNIXBENCH_VM_NAME} (${UNIXBENCH_VM_VCPUS} vCPU, 64 GiB, 2M hugepages, pinned ${UNIXBENCH_VM_CPUSET})"
    sudo -n virsh start "${UNIXBENCH_VM_NAME}" >/dev/null || {
        log 'ERROR: reference VM failed to start'; return 40
    }
    if ! wait_for_unixbench_vm_address; then
        log 'ERROR: reference VM did not obtain a DHCP address'
        sudo -n virsh destroy "${UNIXBENCH_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    save_unixbench_vm_state
    if ! wait_for_unixbench_vm_ssh; then
        log 'ERROR: reference VM did not become reachable over SSH'
        sudo -n virsh destroy "${UNIXBENCH_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    save_unixbench_vm_state
    log "reference VM is ready: ${UNIXBENCH_VM_NAME} at ${UNIXBENCH_VM_IP}"
}

check_unixbench_vm() {
    load_unixbench_vm_state
    [[ -n "${UNIXBENCH_VM_IP:-}" ]] || { log 'ERROR: reference VM address is unknown'; return 40; }
    [[ "$(sudo -n virsh domstate "${UNIXBENCH_VM_NAME}" 2>/dev/null)" == running ]] || {
        log "ERROR: reference VM is not running: ${UNIXBENCH_VM_NAME}"; return 40
    }
    vm_exec true >/dev/null 2>&1 || {
        log "ERROR: reference VM is not reachable over SSH: ${UNIXBENCH_VM_IP}"; return 40
    }
    [[ "$(vm_exec nproc)" == "${UNIXBENCH_VM_VCPUS}" ]] || {
        log 'ERROR: reference VM does not expose the expected vCPU count'; return 40
    }
}

verify_unixbench_guest_os() {
    local release version_id version
    release="$(vm_exec cat /etc/os-release)" || {
        log 'ERROR: cannot read /etc/os-release inside the reference VM'; return 30
    }
    version_id="$(printf '%s\n' "${release}" | sed -n 's/^VERSION_ID="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    version="$(printf '%s\n' "${release}" | sed -n 's/^VERSION="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    [[ "${version_id}" == "24.03" ]] || {
        log "ERROR: reference VM is not openEuler 24.03 (VERSION_ID=${version_id:-unknown})"; return 30
    }
    log "reference VM operating system: ${version:-openEuler ${version_id}}"
}

install_unixbench_guest_packages() {
    local -a proxy_env=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy_env=(env "http_proxy=$(vm_guest_proxy_value)" "https_proxy=$(vm_guest_proxy_value)")
    fi
    log 'installing UnixBench build and runtime packages inside the reference VM'
    "${proxy_env[@]}" vm_exec dnf install -y --setopt=install_weak_deps=False \
        gcc make perl perl-Time-HiRes tar gzip coreutils findutils procps-ng \
        sed gawk grep util-linux || {
        log 'ERROR: guest build dependencies failed'; return 30
    }
}

capture_unixbench_vm_environment() {
    local output="${RESULTS_DIR}/vm-environment.txt"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf '# host: %s\n' "$(uname -n)"
        printf '# host_arch: %s\n' "$(uname -m)"
        printf '# host_hugepages: %s\n' "$(grep -E 'HugePages_(Total|Free)' /proc/meminfo | tr '\n' ' ')"
        printf '# vm_name: %s\n' "${UNIXBENCH_VM_NAME}"
        printf '# vm_ip: %s\n' "${UNIXBENCH_VM_IP}"
        printf '# --- virsh dumpxml ---\n'
        sudo -n virsh dumpxml "${UNIXBENCH_VM_NAME}"
        printf '# --- guest os-release ---\n'
        vm_exec cat /etc/os-release
        printf '# --- guest lscpu ---\n'
        vm_exec lscpu
        printf '# --- guest meminfo ---\n'
        vm_exec sh -c 'grep -E "MemTotal|HugePages" /proc/meminfo'
        printf '# --- guest cmdline ---\n'
        vm_exec cat /proc/cmdline
    } > "${output}"
    log "captured reference VM environment evidence: ${output}"
}

stop_unixbench_vm() {
    load_unixbench_vm_state
    if [[ -n "${UNIXBENCH_VM_NAME:-}" ]]; then
        sudo -n virsh destroy "${UNIXBENCH_VM_NAME}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${UNIXBENCH_VM_NAME}" --nvram >/dev/null 2>&1 || \
            sudo -n virsh undefine "${UNIXBENCH_VM_NAME}" >/dev/null 2>&1 || true
    fi
    if [[ -n "${UNIXBENCH_VM_RUN_DIR:-}" ]]; then
        sudo -n rm -rf "${UNIXBENCH_VM_RUN_DIR}" 2>/dev/null || true
    fi
    rm -f "${UNIXBENCH_VM_STATE_FILE}"
    release_unixbench_hugepages
    log "reference VM ${UNIXBENCH_VM_NAME} stopped and removed"
}
