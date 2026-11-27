#!/usr/bin/env bash
# Shared runtime for the STREAM 5.10 reference-VM case.
#
# The benchmark never runs in a container: every build and measurement step runs
# inside a dedicated KVM virtual machine whose vCPU, memory and 2M huge pages are
# pinned to one host NUMA node, matching the reference environment.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-5.10}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

STREAM_REVISION="6703f7504a38a8da96b353cadafa64d3c2d7a2d3"
STREAM_REVISION_SHORT="${STREAM_REVISION:0:8}"
STREAM_ARCHIVE_NAME="STREAM-${STREAM_REVISION}.tar.gz"
STREAM_ARCHIVE_URL="https://codeload.github.com/jeffhammond/STREAM/tar.gz/${STREAM_REVISION}"
STREAM_ARCHIVE_MIRROR_URL="https://github.com/jeffhammond/STREAM/archive/${STREAM_REVISION}.tar.gz"
STREAM_ARCHIVE_SHA256="977651ffb22de4f5a2fc8a0d8d647b84f3f007c0a77bbdc36ce583872b203f67"
STREAM_ARCHIVE_DIR="${STREAM_ARCHIVE_DIR:-/home/runner/software/stream}"
STREAM_ARRAY_SIZE=200000000
STREAM_NTIMES=10

# Reference virtual machine: 16 cores / 32 threads, 128 GiB, 2M huge pages, one NUMA node.
STREAM_VM_IMAGE_DIR="${STREAM_VM_IMAGE_DIR:-/home/libvirt-images}"
STREAM_VM_KEY="${STREAM_VM_KEY:-/home/runner/software/stream/vm/id_ed25519}"
STREAM_VM_NETWORK="${STREAM_VM_NETWORK:-default}"
STREAM_VM_NUMA_NODE="${STREAM_VM_NUMA_NODE:-0}"
STREAM_VM_TARGET_CORES="${STREAM_VM_TARGET_CORES:-16}"
STREAM_VM_MEM_MIB="${STREAM_VM_MEM_MIB:-131072}"
STREAM_VM_ACCEL="${STREAM_VM_ACCEL:-auto}"
STREAM_VM_HUGEPAGES="${STREAM_VM_HUGEPAGES:-auto}"
STREAM_VM_HUGE_PAGE_KIB=2048
STREAM_SYSFS_CPU_ROOT="${STREAM_SYSFS_CPU_ROOT:-/sys/devices/system/cpu}"
STREAM_SYSFS_NODE_ROOT="${STREAM_SYSFS_NODE_ROOT:-/sys/devices/system/node}"

STREAM_VM_NAME=""
STREAM_VM_IMAGE=""
STREAM_VM_RUN_DIR=""
STREAM_VM_OVERLAY=""
STREAM_VM_NVRAM=""
STREAM_VM_STATE_FILE=""
STREAM_VM_CPUSET=""
STREAM_VM_CORES_USED=""
STREAM_VM_THREADS_PER_CORE=""
STREAM_VM_VCPUS=""
STREAM_VM_IP=""
STREAM_VM_HUGE_NODE_DIR=""
STREAM_VM_HUGE_PAGES=0
STREAM_VM_HUGE_PAGES_ORIGINAL=""
STREAM_VM_HUGEPAGES_ENABLED=0
STREAM_VM_ACCEL_USED=""

GUEST_SOURCE_DIR="/root/stream-${STREAM_REVISION_SHORT}"
GUEST_BINARY="${GUEST_SOURCE_DIR}/stream_200M"

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Progress goes to stderr so stdout stays usable as data (topology, XML).
log() { printf '[stream] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

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
        PERF_WORK_DIR="/home/runner/boostkit-perf/stream/local-${PERF_RUN_ID}"
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
    STREAM_VM_NAME="boostkit-stream-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    STREAM_VM_IMAGE="${STREAM_VM_IMAGE_DIR}/boostkit-stream-golden-${EXPECTED_ARCH}.qcow2"
    STREAM_VM_RUN_DIR="${STREAM_VM_IMAGE_DIR}/runs/${PERF_RUN_ID}"
    STREAM_VM_OVERLAY="${STREAM_VM_RUN_DIR}/system.qcow2"
    STREAM_VM_NVRAM="${STREAM_VM_RUN_DIR}/nvram.fd"
    STREAM_VM_STATE_FILE="${PERF_WORK_DIR}/vm-state.env"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR TMPDIR
    export PERF_ACTUAL_VERSION_FILE STREAM_VM_NAME STREAM_VM_IMAGE STREAM_VM_RUN_DIR STREAM_VM_OVERLAY
    export STREAM_VM_NVRAM STREAM_VM_STATE_FILE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
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

# ---------------------------------------------------------------- host topology

# Expand a kernel CPU list ("0-3,8,10-11") into one CPU per line.
stream_expand_cpu_list() {
    local list="$1" part start end cpu
    local -a parts
    IFS=',' read -r -a parts <<< "${list}"
    for part in "${parts[@]}"; do
        [[ -n "${part}" ]] || continue
        if [[ "${part}" == *-* ]]; then
            start="${part%%-*}"
            end="${part##*-}"
            for ((cpu = start; cpu <= end; cpu++)); do
                printf '%s\n' "${cpu}"
            done
        else
            printf '%s\n' "${part}"
        fi
    done
}

# Compress a sorted CPU list into the kernel range notation.
stream_compress_cpu_list() {
    local -a values=("$@")
    local index=0 total=${#values[@]} start current
    local -a output=()
    while ((index < total)); do
        start="${values[index]}"
        current="${values[index]}"
        while ((index + 1 < total)) && ((values[index + 1] == current + 1)); do
            index=$((index + 1))
            current="${values[index]}"
        done
        if [[ "${start}" == "${current}" ]]; then
            output+=("${start}")
        else
            output+=("${start}-${current}")
        fi
        index=$((index + 1))
    done
    local IFS=','
    printf '%s\n' "${output[*]}"
}

# Pick the physical cores of one NUMA node and return "cpuset cores threads vcpus".
#
# The selection is topology driven: the node CPU list comes from sysfs, every CPU is
# grouped with its SMT siblings, and the first STREAM_VM_TARGET_CORES complete cores
# of that node are pinned.  Nothing is hard coded, so a 2-socket/4-NUMA host and a
# single-NUMA workstation both produce a valid, fully pinned vCPU set.
stream_select_cpu_topology() {
    local node_list node_cpu sibling_list core_cpus count=0 cpu
    local -a node_cpus=() cores=() chosen=() sorted=()
    local -A seen_cpu=() seen_core=()
    node_list="$(cat "${STREAM_SYSFS_NODE_ROOT}/node${STREAM_VM_NUMA_NODE}/cpulist" 2>/dev/null || true)"
    if [[ -z "${node_list}" ]]; then
        log "ERROR: cannot read the CPU list of NUMA node ${STREAM_VM_NUMA_NODE}"
        return 30
    fi
    mapfile -t node_cpus < <(stream_expand_cpu_list "${node_list}")
    for node_cpu in "${node_cpus[@]}"; do
        seen_cpu["${node_cpu}"]=1
    done
    for node_cpu in "${node_cpus[@]}"; do
        [[ -n "${seen_core[${node_cpu}]:-}" ]] && continue
        sibling_list="$(cat "${STREAM_SYSFS_CPU_ROOT}/cpu${node_cpu}/topology/thread_siblings_list" 2>/dev/null || echo "${node_cpu}")"
        core_cpus=()
        while IFS= read -r cpu; do
            # Only CPUs that belong to the requested NUMA node may be pinned.
            [[ -n "${seen_cpu[${cpu}]:-}" ]] || continue
            seen_core["${cpu}"]=1
            core_cpus+=("${cpu}")
        done < <(stream_expand_cpu_list "${sibling_list}")
        ((${#core_cpus[@]} > 0)) || continue
        cores+=("${core_cpus[*]}")
        count=$((count + 1))
        ((count < STREAM_VM_TARGET_CORES)) || break
    done
    if ((${#cores[@]} == 0)); then
        log "ERROR: no usable core was found on NUMA node ${STREAM_VM_NUMA_NODE}"
        return 30
    fi
    if ((${#cores[@]} < STREAM_VM_TARGET_CORES)); then
        log "WARNING: NUMA node ${STREAM_VM_NUMA_NODE} exposes ${#cores[@]} cores, the reference VM asks for ${STREAM_VM_TARGET_CORES}"
    fi
    for cpu in "${cores[@]}"; do
        read -r -a chosen <<< "${cpu}"
        sorted+=("${chosen[@]}")
    done
    mapfile -t sorted < <(printf '%s\n' "${sorted[@]}" | sort -n | uniq)
    local cpuset threads
    cpuset="$(stream_compress_cpu_list "${sorted[@]}")"
    threads=$((${#sorted[@]} / ${#cores[@]}))
    printf '%s %s %s %s\n' "${cpuset}" "${#cores[@]}" "${threads}" "${#sorted[@]}"
}

stream_apply_cpu_topology() {
    local topology
    topology="$(stream_select_cpu_topology)" || return $?
    read -r STREAM_VM_CPUSET STREAM_VM_CORES_USED STREAM_VM_THREADS_PER_CORE STREAM_VM_VCPUS <<< "${topology}"
    [[ -n "${STREAM_VM_CPUSET}" && -n "${STREAM_VM_VCPUS}" ]] || {
        log 'ERROR: CPU topology selection produced an empty pinning set'
        return 30
    }
    if ((STREAM_VM_THREADS_PER_CORE > 2)); then
        log "WARNING: ${STREAM_VM_THREADS_PER_CORE} threads per core detected; the reference VM uses 2"
    fi
    export STREAM_VM_CPUSET STREAM_VM_CORES_USED STREAM_VM_THREADS_PER_CORE STREAM_VM_VCPUS
}

stream_resolve_accel() {
    case "${STREAM_VM_ACCEL,,}" in
        kvm) STREAM_VM_ACCEL_USED=kvm ;;
        tcg) STREAM_VM_ACCEL_USED=qemu ;;
        auto)
            if [[ -c /dev/kvm ]]; then
                STREAM_VM_ACCEL_USED=kvm
            else
                STREAM_VM_ACCEL_USED=qemu
                log 'WARNING: /dev/kvm is absent; the reference VM falls back to QEMU TCG (functional validation only)'
            fi
            ;;
        *) log "ERROR: invalid STREAM_VM_ACCEL: ${STREAM_VM_ACCEL}"; return 10 ;;
    esac
    export STREAM_VM_ACCEL_USED
}

stream_resolve_hugepages() {
    case "${STREAM_VM_HUGEPAGES,,}" in
        on) STREAM_VM_HUGEPAGES_ENABLED=1 ;;
        off) STREAM_VM_HUGEPAGES_ENABLED=0 ;;
        auto)
            if [[ "${STREAM_VM_ACCEL_USED}" == kvm ]]; then
                STREAM_VM_HUGEPAGES_ENABLED=1
            else
                # TCG keeps the pages anonymous: a huge page pool is a KVM-side feature here.
                STREAM_VM_HUGEPAGES_ENABLED=0
            fi
            ;;
        *) log "ERROR: invalid STREAM_VM_HUGEPAGES: ${STREAM_VM_HUGEPAGES}"; return 10 ;;
    esac
    STREAM_VM_HUGE_PAGES=$((STREAM_VM_MEM_MIB / (STREAM_VM_HUGE_PAGE_KIB / 1024)))
    STREAM_VM_HUGE_NODE_DIR="${STREAM_SYSFS_NODE_ROOT}/node${STREAM_VM_NUMA_NODE}/hugepages/hugepages-${STREAM_VM_HUGE_PAGE_KIB}kB"
    export STREAM_VM_HUGEPAGES_ENABLED STREAM_VM_HUGE_PAGES STREAM_VM_HUGE_NODE_DIR
}

# ------------------------------------------------------------------ host checks

require_stream_vm_host() {
    local name
    for name in virsh qemu-img ssh scp sha256sum tar python3 awk sed grep sort uniq; do
        command -v "${name}" >/dev/null 2>&1 || {
            log "ERROR: required host command is missing: ${name}"
            return 30
        }
    done
    sudo -n true >/dev/null 2>&1 || { log 'ERROR: passwordless sudo is required on this runner'; return 30; }
    sudo -n virsh version >/dev/null 2>&1 || {
        log 'ERROR: libvirt is not reachable through virsh on this runner'
        return 30
    }
    if [[ "${STREAM_VM_ACCEL_USED}" == kvm && ! -c /dev/kvm ]]; then
        log 'ERROR: /dev/kvm is missing but KVM acceleration was requested'
        return 30
    fi
    [[ -f "${STREAM_VM_IMAGE}" ]] || {
        log "ERROR: golden VM image is missing: ${STREAM_VM_IMAGE}"
        log 'ERROR: run scripts/host/prepare-vm-host.sh on this runner first'
        return 30
    }
    [[ -r "${STREAM_VM_KEY}" ]] || { log "ERROR: VM SSH key is missing: ${STREAM_VM_KEY}"; return 30; }
    return 0
}

# ------------------------------------------------------------- virtual machine

load_stream_vm_state() {
    [[ -f "${STREAM_VM_STATE_FILE}" ]] || return 0
    # shellcheck disable=SC1090
    source "${STREAM_VM_STATE_FILE}"
    # The recorded state is consumed by later stages in separate processes.
    export STREAM_VM_NAME STREAM_VM_IP STREAM_VM_RUN_DIR STREAM_VM_OVERLAY STREAM_VM_CPUSET
    export STREAM_VM_VCPUS STREAM_VM_HUGE_PAGES STREAM_VM_HUGE_PAGES_ORIGINAL
    export STREAM_VM_HUGE_NODE_DIR STREAM_VM_HUGEPAGES_ENABLED STREAM_VM_ACCEL_USED
    return 0
}

save_stream_vm_state() {
    {
        printf 'STREAM_VM_NAME=%q\n' "${STREAM_VM_NAME}"
        printf 'STREAM_VM_IP=%q\n' "${STREAM_VM_IP:-}"
        printf 'STREAM_VM_RUN_DIR=%q\n' "${STREAM_VM_RUN_DIR}"
        printf 'STREAM_VM_OVERLAY=%q\n' "${STREAM_VM_OVERLAY}"
        printf 'STREAM_VM_CPUSET=%q\n' "${STREAM_VM_CPUSET}"
        printf 'STREAM_VM_VCPUS=%q\n' "${STREAM_VM_VCPUS}"
        printf 'STREAM_VM_HUGE_PAGES=%q\n' "${STREAM_VM_HUGE_PAGES}"
        printf 'STREAM_VM_HUGE_PAGES_ORIGINAL=%q\n' "${STREAM_VM_HUGE_PAGES_ORIGINAL:-}"
        printf 'STREAM_VM_HUGE_NODE_DIR=%q\n' "${STREAM_VM_HUGE_NODE_DIR:-}"
        printf 'STREAM_VM_HUGEPAGES_ENABLED=%q\n' "${STREAM_VM_HUGEPAGES_ENABLED}"
        printf 'STREAM_VM_ACCEL_USED=%q\n' "${STREAM_VM_ACCEL_USED}"
    } > "${STREAM_VM_STATE_FILE}"
}

vm_ssh_opts() {
    printf '%s\n' \
        -p 22 \
        -i "${STREAM_VM_KEY}" \
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
        -i "${STREAM_VM_KEY}" \
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
    ssh "${options[@]}" "root@${STREAM_VM_IP}" "${remote_command}"
}

vm_exec_shell() {
    local -a options=()
    mapfile -t options < <(vm_ssh_opts)
    ssh "${options[@]}" "root@${STREAM_VM_IP}" "$1"
}

vm_copy_in() {
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "$1" "root@${STREAM_VM_IP}:$2"
}

vm_copy_out() {
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "root@${STREAM_VM_IP}:$1" "$2"
}

vm_pin_lines() {
    local -a cpus=()
    local index=0 cpu
    mapfile -t cpus < <(stream_expand_cpu_list "${STREAM_VM_CPUSET}")
    for cpu in "${cpus[@]}"; do
        printf "    <vcpupin vcpu='%d' cpuset='%d'/>\n" "${index}" "${cpu}"
        index=$((index + 1))
    done
}

stream_emulator_path() {
    if [[ "${STREAM_VM_ACCEL_USED}" == kvm && -x /usr/libexec/qemu-kvm ]]; then
        printf '%s\n' /usr/libexec/qemu-kvm
        return 0
    fi
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        printf '%s\n' /usr/bin/qemu-system-x86_64
    else
        printf '%s\n' /usr/bin/qemu-system-aarch64
    fi
}

emit_stream_vm_xml() {
    local arch_machine arch_type features cpu_block memory_backing description_memory topology
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        arch_type="x86_64"
        arch_machine="q35"
        features="    <acpi/>\n    <apic/>"
        topology="sockets='1' dies='1' cores='${STREAM_VM_CORES_USED}' threads='${STREAM_VM_THREADS_PER_CORE}'"
    else
        arch_type="aarch64"
        arch_machine="virt"
        features="    <acpi/>"
        # libvirt only accepts the "clusters" topology level on aarch64.
        topology="sockets='1' dies='1' clusters='1' cores='${STREAM_VM_CORES_USED}' threads='${STREAM_VM_THREADS_PER_CORE}'"
    fi
    if [[ "${STREAM_VM_ACCEL_USED}" == kvm ]]; then
        # Keep the guest CPU model (and therefore the vector width STREAM uses) equal
        # to the host, and describe the SMT topology so the guest sees 16C/32T.
        cpu_block="  <cpu mode='host-passthrough' check='none' migratable='off'>
    <topology ${topology}/>
  </cpu>"
    else
        # TCG cannot pass the host CPU model through; a fixed model with SSE4.2/AVX2 is
        # required because the openEuler kernel is built for x86-64-v3.
        cpu_block="  <cpu mode='custom' check='none'>
    <model fallback='allow'>${STREAM_VM_TCG_CPU_MODEL:-Haswell}</model>
  </cpu>"
    fi
    if ((STREAM_VM_HUGEPAGES_ENABLED == 1)); then
        memory_backing="  <memoryBacking>
    <hugepages>
      <page size='${STREAM_VM_HUGE_PAGE_KIB}' unit='KiB'/>
    </hugepages>
    <source type='memfd'/>
    <access mode='shared'/>
    <allocation mode='immediate' threads='4'/>
  </memoryBacking>"
        description_memory="2M huge pages (${STREAM_VM_HUGE_PAGES} pages)"
    else
        memory_backing=""
        description_memory="anonymous memory"
    fi
    cat <<XML
<domain type='${STREAM_VM_ACCEL_USED}'>
  <name>${STREAM_VM_NAME}</name>
  <description>boostkit STREAM reference VM: ${STREAM_VM_VCPUS} vCPU (${STREAM_VM_CORES_USED} cores x ${STREAM_VM_THREADS_PER_CORE} threads) pinned inside host NUMA node ${STREAM_VM_NUMA_NODE}, ${STREAM_VM_MEM_MIB} MiB ${description_memory}, openEuler 24.03 LTS SP4</description>
  <memory unit='MiB'>${STREAM_VM_MEM_MIB}</memory>
  <currentMemory unit='MiB'>${STREAM_VM_MEM_MIB}</currentMemory>
${memory_backing}
  <vcpu placement='static'>${STREAM_VM_VCPUS}</vcpu>
  <cputune>
$(vm_pin_lines)
    <emulatorpin cpuset='${STREAM_VM_CPUSET}'/>
  </cputune>
  <numatune>
    <memory mode='strict' nodeset='${STREAM_VM_NUMA_NODE}'/>
  </numatune>
  <os>
    <type arch='${arch_type}' machine='${arch_machine}'>hvm</type>
XML
    if [[ "${EXPECTED_ARCH}" == aarch64 ]]; then
        cat <<XML
    <loader readonly='yes' type='pflash'>/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw</loader>
    <nvram>${STREAM_VM_NVRAM}</nvram>
XML
    fi
    cat <<XML
    <boot dev='hd'/>
  </os>
  <features>
$(printf "%b" "${features}")
  </features>
${cpu_block}
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>preserve</on_crash>
  <devices>
    <emulator>$(stream_emulator_path)</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='${STREAM_VM_OVERLAY}'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='${STREAM_VM_NETWORK}'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <log file='${STREAM_VM_RUN_DIR}/console.log' append='off'/>
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

allocate_stream_hugepages() {
    local current free_pages attempt
    if ((STREAM_VM_HUGEPAGES_ENABLED != 1)); then
        log '2M huge pages are disabled for this run'
        save_stream_vm_state
        return 0
    fi
    sudo -n test -d "${STREAM_VM_HUGE_NODE_DIR}" || {
        log "ERROR: NUMA node ${STREAM_VM_NUMA_NODE} does not expose ${STREAM_VM_HUGE_PAGE_KIB} KiB huge pages"
        return 30
    }
    current="$(cat "${STREAM_VM_HUGE_NODE_DIR}/nr_hugepages")"
    STREAM_VM_HUGE_PAGES_ORIGINAL="${current}"
    if ((current < STREAM_VM_HUGE_PAGES)); then
        log "allocating ${STREAM_VM_HUGE_PAGES} x ${STREAM_VM_HUGE_PAGE_KIB} KiB huge pages on NUMA node ${STREAM_VM_NUMA_NODE}"
        sudo -n sh -c "echo ${STREAM_VM_HUGE_PAGES} > ${STREAM_VM_HUGE_NODE_DIR}/nr_hugepages" || {
            log 'ERROR: failed to allocate huge pages for the reference VM'
            return 30
        }
    fi
    for attempt in $(seq 1 30); do
        free_pages="$(cat "${STREAM_VM_HUGE_NODE_DIR}/free_hugepages")"
        if ((free_pages >= STREAM_VM_HUGE_PAGES)); then
            log "huge pages ready: node=${STREAM_VM_NUMA_NODE} free=${free_pages} pages"
            save_stream_vm_state
            return 0
        fi
        sleep 1
    done
    log "ERROR: only ${free_pages} free huge pages on node ${STREAM_VM_NUMA_NODE}"
    return 30
}

release_stream_hugepages() {
    local target
    [[ -n "${STREAM_VM_HUGE_NODE_DIR:-}" && -d "${STREAM_VM_HUGE_NODE_DIR}" ]] || return 0
    ((STREAM_VM_HUGEPAGES_ENABLED == 1)) || return 0
    # Restore the pool that existed before this run instead of zeroing the host pool.
    target="${STREAM_VM_HUGE_PAGES_ORIGINAL:-0}"
    sudo -n sh -c "echo ${target} > ${STREAM_VM_HUGE_NODE_DIR}/nr_hugepages" 2>/dev/null || {
        log 'WARN: the huge page pool could not be restored to its previous size'
        return 0
    }
    log "restored NUMA node ${STREAM_VM_NUMA_NODE} huge page pool to ${target} pages"
}

sweep_stream_stale_vms() {
    local name
    while IFS= read -r name; do
        [[ -n "${name}" ]] || continue
        [[ "${name}" == "${STREAM_VM_NAME}" ]] && continue
        log "removing stale reference VM: ${name}"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 || sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    done < <(sudo -n virsh list --all --name 2>/dev/null | grep -E '^boostkit-stream-' || true)
    if [[ -d "${STREAM_VM_IMAGE_DIR}/runs" ]]; then
        find "${STREAM_VM_IMAGE_DIR}/runs" -mindepth 1 -maxdepth 1 -type d ! -name "${PERF_RUN_ID}" \
            -exec sudo -n rm -rf {} + 2>/dev/null || true
    fi
}

wait_for_stream_vm_address() {
    local attempt address
    for attempt in $(seq 1 150); do
        address="$(sudo -n virsh domifaddr "${STREAM_VM_NAME}" --source lease 2>/dev/null |
            awk '/ipv4/ {print $4}' | cut -d/ -f1 | head -n 1)"
        if [[ -n "${address}" ]]; then
            STREAM_VM_IP="${address}"
            return 0
        fi
        sleep 2
    done
    return 1
}

wait_for_stream_vm_ssh() {
    local attempt cpus
    for attempt in $(seq 1 150); do
        cpus="$(vm_exec nproc 2>/dev/null || true)"
        if [[ "${cpus}" == "${STREAM_VM_VCPUS}" ]]; then
            return 0
        fi
        sleep 2
    done
    return 1
}

start_stream_vm() {
    local xml="${STREAM_VM_RUN_DIR}/vm.xml"
    stream_apply_cpu_topology || return $?
    stream_resolve_accel || return $?
    stream_resolve_hugepages || return $?
    require_stream_vm_host || return $?
    sweep_stream_stale_vms
    allocate_stream_hugepages || return $?
    sudo -n mkdir -p "${STREAM_VM_RUN_DIR}" || return 30
    sudo -n chmod 755 "${STREAM_VM_RUN_DIR}" || return 30
    sudo -n qemu-img create -q -f qcow2 -F qcow2 -b "${STREAM_VM_IMAGE}" "${STREAM_VM_OVERLAY}" || {
        log 'ERROR: failed to create the reference VM overlay disk'; return 40
    }
    emit_stream_vm_xml | sudo -n tee "${xml}" >/dev/null || {
        log 'ERROR: failed to render the reference VM definition'; return 40
    }
    sudo -n virsh define "${xml}" >/dev/null || {
        log 'ERROR: libvirt rejected the reference VM definition'; return 40
    }
    log "starting reference VM ${STREAM_VM_NAME}: ${STREAM_VM_CORES_USED}C/${STREAM_VM_VCPUS}T, ${STREAM_VM_MEM_MIB} MiB, accelerator=${STREAM_VM_ACCEL_USED}, cpuset=${STREAM_VM_CPUSET}, memory node=${STREAM_VM_NUMA_NODE}"
    sudo -n virsh start "${STREAM_VM_NAME}" >/dev/null || {
        log 'ERROR: reference VM failed to start'; return 40
    }
    save_stream_vm_state
    if ! wait_for_stream_vm_address; then
        log 'ERROR: reference VM did not obtain a DHCP address'
        sudo -n virsh destroy "${STREAM_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    save_stream_vm_state
    if ! wait_for_stream_vm_ssh; then
        log 'ERROR: reference VM did not become reachable over SSH with the expected vCPU count'
        sudo -n virsh destroy "${STREAM_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    log "reference VM is ready: ${STREAM_VM_NAME} at ${STREAM_VM_IP} (${STREAM_VM_VCPUS} vCPU)"
}

check_stream_vm() {
    load_stream_vm_state
    [[ -n "${STREAM_VM_IP:-}" ]] || { log 'ERROR: reference VM address is unknown'; return 40; }
    [[ "$(sudo -n virsh domstate "${STREAM_VM_NAME}" 2>/dev/null)" == running ]] || {
        log "ERROR: reference VM is not running: ${STREAM_VM_NAME}"; return 40
    }
    vm_exec true >/dev/null 2>&1 || {
        log "ERROR: reference VM is not reachable over SSH: ${STREAM_VM_IP}"; return 40
    }
    [[ "$(vm_exec nproc)" == "${STREAM_VM_VCPUS}" ]] || {
        log 'ERROR: reference VM does not expose the expected vCPU count'; return 40
    }
    return 0
}

verify_stream_guest_os() {
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

enable_stream_guest_forwarding() {
    # The reference VM has no host bridge of its own: guest package installation
    # needs IPv4 forwarding on the Runner (libvirt already installs the masquerade
    # rules for 192.168.122.0/24).  Runners have been observed with forwarding off.
    local current
    current="$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 0)"
    if [[ "${current}" != "1" ]]; then
        sudo -n sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || {
            log 'WARNING: could not enable net.ipv4.ip_forward on the host'
            return 0
        }
        log 'enabled net.ipv4.ip_forward so the reference VM can reach package mirrors'
    fi
    return 0
}

guest_has_network() {
    # Cheap reachability probe from inside the guest; avoids a full dnf timeout.
    vm_exec_shell 'timeout 8 bash -c "cat < /dev/null > /dev/tcp/192.168.122.1/53"' >/dev/null 2>&1 || return 1
    vm_exec_shell 'for host in mirrors.openeuler.org repo.openeuler.org; do timeout 8 bash -c "cat < /dev/null > /dev/tcp/${host}/443" && exit 0; done; exit 1' >/dev/null 2>&1
}

install_stream_guest_packages() {
    local -a proxy_env=()
    local -a extra=()
    local attempt
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy_env=(env "http_proxy=$(vm_guest_proxy_value)" "https_proxy=$(vm_guest_proxy_value)")
    fi
    enable_stream_guest_forwarding
    if guest_has_network; then
        log 'installing the STREAM build toolchain inside the reference VM (guest has network access)'
        # A mirror that serves inconsistent metadata must not abort the whole build:
        # retry once as-is, then without the volatile "update" repository.
        for attempt in 1 2 3; do
            case "${attempt}" in
                1) extra=() ;;
                2) extra=(--refresh) ;;
                3) extra=(--disablerepo='*update*' --setopt=strict=0) ;;
            esac
            if "${proxy_env[@]}" vm_exec timeout 420 dnf install -y \
                --setopt=install_weak_deps=False "${extra[@]}" \
                gcc make tar gzip numactl procps-ng util-linux; then
                STREAM_GUEST_TOOLCHAIN_ATTEMPT="dnf:${attempt}"
                STREAM_GUEST_TOOLCHAIN_SOURCE=dnf
                export STREAM_GUEST_TOOLCHAIN_ATTEMPT STREAM_GUEST_TOOLCHAIN_SOURCE
                return 0
            fi
            log "WARNING: guest dnf installation failed (attempt ${attempt} of 3)"
            sleep 5
        done
        log 'WARNING: the guest cannot install its toolchain through dnf; falling back to offline RPMs'
    else
        log 'the reference VM has no outbound network; installing the toolchain from host-provided RPMs'
    fi
    install_stream_guest_packages_offline || return 30
    STREAM_GUEST_TOOLCHAIN_ATTEMPT=offline
    STREAM_GUEST_TOOLCHAIN_SOURCE=host-rpms
    export STREAM_GUEST_TOOLCHAIN_ATTEMPT STREAM_GUEST_TOOLCHAIN_SOURCE
}

# Download the guest toolchain on the host (same distribution and architecture) and
# install it inside the VM without any guest-side network access.
install_stream_guest_packages_offline() {
    local bundle_dir tarball package attempt
    local -a packages=(gcc make tar gzip numactl procps-ng util-linux)
    if ! command -v dnf >/dev/null 2>&1; then
        log 'ERROR: the host has no dnf, so the offline toolchain bundle cannot be built'
        return 30
    fi
    bundle_dir="${STREAM_ARCHIVE_DIR}/rpms/${EXPECTED_ARCH}"
    sudo -n mkdir -p "${bundle_dir}" 2>/dev/null || mkdir -p "${bundle_dir}" 2>/dev/null || true
    if [[ ! -d "${bundle_dir}" ]]; then
        bundle_dir="${PERF_WORK_DIR}/rpms"
        mkdir -p "${bundle_dir}"
    fi
    if ! compgen -G "${bundle_dir}/*.rpm" >/dev/null; then
        log "downloading the guest toolchain RPMs on the host into ${bundle_dir}"
        for package in "${packages[@]}"; do
            for attempt in 1 2; do
                if with_network_proxy dnf download --resolve --alldeps \
                    --destdir "${bundle_dir}" "${package}" >/dev/null 2>&1; then
                    break
                fi
                log "WARNING: could not download ${package} (attempt ${attempt} of 2)"
                sleep 3
            done
        done
    fi
    compgen -G "${bundle_dir}/*.rpm" >/dev/null || {
        log 'ERROR: no guest toolchain RPM was downloaded on the host'
        return 30
    }
    tarball="${PERF_WORK_DIR}/stream-guest-rpms-${EXPECTED_ARCH}.tar.gz"
    tar -czf "${tarball}" -C "${bundle_dir}" . || return 30
    vm_exec rm -rf /root/stream-rpms || return 30
    vm_exec mkdir -p /root/stream-rpms || return 30
    vm_copy_in "${tarball}" /root/stream-rpms.tar.gz || return 30
    vm_exec tar -xzf /root/stream-rpms.tar.gz -C /root/stream-rpms || return 30
    log 'installing the offline guest toolchain inside the reference VM'
    vm_exec_shell 'dnf install -y --disablerepo="*" --nogpgcheck /root/stream-rpms/*.rpm' || {
        log 'ERROR: the offline guest toolchain installation failed'
        return 30
    }
    log "offline toolchain installed from $(find "${bundle_dir}" -name '*.rpm' | wc -l) RPMs"
}

capture_stream_vm_environment() {
    local output="${RESULTS_DIR}/vm-environment.txt"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf '# host: %s (%s)\n' "$(uname -n)" "$(uname -m)"
        printf '# host_accel: %s\n' "${STREAM_VM_ACCEL_USED}"
        printf '# host_cpuset: %s (cores=%s threads_per_core=%s vcpus=%s numa_node=%s)\n' \
            "${STREAM_VM_CPUSET}" "${STREAM_VM_CORES_USED}" "${STREAM_VM_THREADS_PER_CORE}" \
            "${STREAM_VM_VCPUS}" "${STREAM_VM_NUMA_NODE}"
        printf '# host_hugepages: %s\n' "$(grep -E 'HugePages_(Total|Free)' /proc/meminfo | tr '\n' ' ')"
        printf '# host_numa_cpus: %s\n' "$(cat "${STREAM_SYSFS_NODE_ROOT}/node${STREAM_VM_NUMA_NODE}/cpulist" 2>/dev/null || echo unknown)"
        printf '# vm_name: %s\n' "${STREAM_VM_NAME}"
        printf '# vm_ip: %s\n' "${STREAM_VM_IP}"
        printf '# vm_memory_mib: %s\n' "${STREAM_VM_MEM_MIB}"
        printf '# vm_hugepages: %s\n' "${STREAM_VM_HUGEPAGES_ENABLED}"
        printf '# --- virsh dumpxml ---\n'
        sudo -n virsh dumpxml "${STREAM_VM_NAME}"
        printf '# --- guest os-release ---\n'
        vm_exec cat /etc/os-release
        printf '# --- guest lscpu ---\n'
        vm_exec lscpu
        printf '# --- guest meminfo ---\n'
        vm_exec sh -c 'grep -E "MemTotal|HugePages_" /proc/meminfo'
        printf '# --- guest cmdline ---\n'
        vm_exec cat /proc/cmdline
    } > "${output}"
    log "captured reference VM environment evidence: ${output}"
}

stop_stream_vm() {
    load_stream_vm_state
    if [[ -n "${STREAM_VM_NAME:-}" ]]; then
        sudo -n virsh destroy "${STREAM_VM_NAME}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${STREAM_VM_NAME}" --nvram >/dev/null 2>&1 || \
            sudo -n virsh undefine "${STREAM_VM_NAME}" >/dev/null 2>&1 || true
    fi
    if [[ -n "${STREAM_VM_RUN_DIR:-}" && "${STREAM_VM_RUN_DIR}" == */runs/* ]]; then
        sudo -n rm -rf "${STREAM_VM_RUN_DIR}" 2>/dev/null || true
    fi
    rm -f "${STREAM_VM_STATE_FILE}"
    release_stream_hugepages
    log "reference VM ${STREAM_VM_NAME:-unknown} stopped and removed"
}
