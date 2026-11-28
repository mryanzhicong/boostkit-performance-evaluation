#!/usr/bin/env bash
# Shared runtime for the libvirt unixbench case.
#
# The benchmark never runs in a container: every measurement runs inside its own
# KVM virtual machine.  Each VM gets 4 vCPU / 8 GiB, the vCPU of every VM are
# pinned to consecutive host cores of one NUMA node, and the VM memory is bound
# to that same node, matching the reference environment.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-6.0.1}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# Upstream UnixBench "master" snapshot (the version string inside Run is 6.0.1).
UNIXBENCH_REVISION="${UNIXBENCH_REVISION:-master}"
UNIXBENCH_ARCHIVE_NAME="byte-unixbench-master.tar.gz"
UNIXBENCH_ARCHIVE_URL="https://codeload.github.com/kdlucas/byte-unixbench/tar.gz/refs/heads/master"
UNIXBENCH_ARCHIVE_SHA256="f57ab9d1d61e920bce58ee05c82c70dca8490d30662d21d7bef1579a1a797125"
UNIXBENCH_ARCHIVE_DIR="${UNIXBENCH_ARCHIVE_DIR:-/home/runner/software/libvirt}"
UNIXBENCH_GUEST_ARCHIVE="/root/UnixBench.tgz"
UNIXBENCH_GUEST_HOME="/home/byte-unixbench-master"
UNIXBENCH_GUEST_DIR="${UNIXBENCH_GUEST_HOME}/UnixBench"

# Reference virtual machine fleet: one 4 vCPU / 8 GiB VM per four host cores.
LIBVIRT_VM_IMAGE_DIR="${LIBVIRT_VM_IMAGE_DIR:-/home/libvirt-images}"
LIBVIRT_VM_KEY="${LIBVIRT_VM_KEY:-/home/runner/software/libvirt/vm/id_ed25519}"
LIBVIRT_VM_NETWORK="${LIBVIRT_VM_NETWORK:-default}"
LIBVIRT_VM_CORES="${LIBVIRT_VM_CORES:-4}"
LIBVIRT_VM_MEM_MIB="${LIBVIRT_VM_MEM_MIB:-8192}"
LIBVIRT_COPIES="${LIBVIRT_COPIES:-${LIBVIRT_VM_CORES}}"
LIBVIRT_VM_COUNT="${LIBVIRT_VM_COUNT:-auto}"
LIBVIRT_VM_ACCEL="${LIBVIRT_VM_ACCEL:-auto}"
LIBVIRT_REPS="${LIBVIRT_REPS:-6}"
LIBVIRT_WARMUP_REPS="${LIBVIRT_WARMUP_REPS:-1}"
LIBVIRT_REP_TIMEOUT="${LIBVIRT_REP_TIMEOUT:-3600}"
LIBVIRT_SYSFS_CPU_ROOT="${LIBVIRT_SYSFS_CPU_ROOT:-/sys/devices/system/cpu}"
LIBVIRT_SYSFS_NODE_ROOT="${LIBVIRT_SYSFS_NODE_ROOT:-/sys/devices/system/node}"
LIBVIRT_GOLDEN_IMAGE="${LIBVIRT_GOLDEN_IMAGE:-}"

LIBVIRT_VM_ACCEL_USED=""
LIBVIRT_TOTAL_CORES=0
LIBVIRT_VM_PLAN_FILE=""
LIBVIRT_ENV_FILE=""

STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

# Progress goes to stderr so stdout stays usable as data.
log() { printf '[libvirt-unixbench] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

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
        PERF_WORK_DIR="/home/runner/boostkit-perf/libvirt-unixbench/local-${PERF_RUN_ID}"
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
    LIBVIRT_VM_RUN_DIR="${PERF_WORK_DIR}/vm"
    LIBVIRT_VM_PLAN_FILE="${PERF_WORK_DIR}/vms.tsv"
    LIBVIRT_ENV_FILE="${PERF_WORK_DIR}/vm-environment.json"
    LIBVIRT_GOLDEN_IMAGE="${LIBVIRT_GOLDEN_IMAGE:-${LIBVIRT_VM_IMAGE_DIR}/boostkit-libvirt-golden-${EXPECTED_ARCH}.qcow2}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    [[ "${LIBVIRT_REPS}" =~ ^[0-9]+$ ]] && ((LIBVIRT_REPS >= 2)) || {
        log 'ERROR: LIBVIRT_REPS must be an integer >= 2 (warm-up + measured repetitions)'
        return 10
    }
    [[ "${LIBVIRT_WARMUP_REPS}" =~ ^[0-9]+$ ]] && ((LIBVIRT_WARMUP_REPS >= 1)) || {
        log 'ERROR: LIBVIRT_WARMUP_REPS must be an integer >= 1'
        return 10
    }
    ((LIBVIRT_REPS - LIBVIRT_WARMUP_REPS >= 5)) || {
        log 'ERROR: the sampling contract requires at least one warm-up plus five measured repetitions'
        return 10
    }
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR LIBVIRT_VM_RUN_DIR LIBVIRT_VM_PLAN_FILE LIBVIRT_ENV_FILE
    export LIBVIRT_GOLDEN_IMAGE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${LIBVIRT_VM_RUN_DIR}"
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

require_libvirt_host() {
    local name
    for name in virsh qemu-img ssh scp tar python3 awk sed grep; do
        command -v "${name}" >/dev/null 2>&1 || {
            log "ERROR: required host command is missing: ${name}"
            return 30
        }
    done
    [[ -f "${LIBVIRT_GOLDEN_IMAGE}" ]] || {
        log "ERROR: golden VM image is missing: ${LIBVIRT_GOLDEN_IMAGE}"
        log 'ERROR: run scripts/host/prepare-vm-host.sh on this runner first'
        return 30
    }
    [[ -r "${LIBVIRT_VM_KEY}" ]] || {
        log "ERROR: VM SSH key is missing: ${LIBVIRT_VM_KEY}"; return 30
    }
    sudo -n virsh version >/dev/null 2>&1 || {
        log 'ERROR: passwordless sudo for virsh is required on this runner'; return 30
    }
    return 0
}

resolve_libvirt_accel() {
    case "${LIBVIRT_VM_ACCEL}" in
        kvm) LIBVIRT_VM_ACCEL_USED=kvm ;;
        qemu|tcg) LIBVIRT_VM_ACCEL_USED=qemu ;;
        auto)
            if [[ -r /dev/kvm && -w /dev/kvm ]] || sudo -n test -r /dev/kvm 2>/dev/null; then
                LIBVIRT_VM_ACCEL_USED=kvm
            else
                LIBVIRT_VM_ACCEL_USED=qemu
            fi
            ;;
        *)
            log "ERROR: invalid accelerator: ${LIBVIRT_VM_ACCEL}"; return 10 ;;
    esac
    export LIBVIRT_VM_ACCEL_USED
    log "virtualization accelerator: ${LIBVIRT_VM_ACCEL_USED}"
}

libvirt_emulator_path() {
    local candidate
    for candidate in /usr/libexec/qemu-kvm "/usr/bin/qemu-system-${EXPECTED_ARCH}" /usr/bin/qemu-kvm; do
        [[ -x "${candidate}" ]] && { printf '%s\n' "${candidate}"; return 0; }
    done
    printf '%s\n' ''
}

libvirt_emulator_element() {
    local path
    path="$(libvirt_emulator_path)"
    [[ -n "${path}" ]] && printf '    <emulator>%s</emulator>\n' "${path}"
    return 0
}

# One vCPU is pinned to a dedicated physical core (the first online thread of
# that core) so every VM owns consecutive cores inside a single NUMA node, which
# is what the reference "consecutive core binding" describes.
plan_libvirt_vms() {
    local per_vm="${LIBVIRT_VM_CORES}"
    local -a rows=() nodes=()
    local entry cpu core socket node online key
    local total_cores=0 index node_index assigned i j cpu_of_core cpuset
    local best_node
    mapfile -t rows < <(LC_ALL=C lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE 2>/dev/null | grep -v '^#')
    if ((${#rows[@]} == 0)); then
        mapfile -t rows < <(LC_ALL=C lscpu -p=CPU,CORE,SOCKET,NODE 2>/dev/null | grep -v '^#' | sed 's/$/,Y/')
    fi
    ((${#rows[@]} > 0)) || { log 'ERROR: cannot read the host CPU topology'; return 30; }
    declare -A first_thread=() core_node=() node_cores=() node_core_list=() assigned_per_node=()
    for entry in "${rows[@]}"; do
        IFS=',' read -r cpu core socket node online <<< "${entry}"
        case "${online,,}" in
            y|yes|1|true|'') ;;
            *) continue ;;
        esac
        [[ -n "${node}" && -n "${core}" && -n "${cpu}" ]] || continue
        key="${socket}:${core}"
        [[ -n "${first_thread[${key}]:-}" ]] && continue
        first_thread["${key}"]="${cpu}"
        core_node["${key}"]="${node}"
        node_cores[${node}]=$(( ${node_cores[${node}]:-0} + 1 ))
        node_core_list[${node}]+="${node_core_list[${node}]:+ }${core}"
    done
    ((${#node_cores[@]} > 0)) || { log 'ERROR: the host CPU topology produced no online core'; return 30; }
    mapfile -t nodes < <(printf '%s\n' "${!node_cores[@]}" | sort -n)
    for node in "${nodes[@]}"; do
        # shellcheck disable=SC2086
        node_core_list[${node}]="$(printf '%s\n' ${node_core_list[${node}]} | sort -n | tr '\n' ' ')"
        total_cores=$((total_cores + node_cores[${node}]))
    done
    LIBVIRT_TOTAL_CORES="${total_cores}"
    if [[ "${LIBVIRT_VM_COUNT}" == auto ]]; then
        LIBVIRT_VM_COUNT=$((total_cores / per_vm))
        ((LIBVIRT_VM_COUNT >= 1)) || LIBVIRT_VM_COUNT=1
    fi
    [[ "${LIBVIRT_VM_COUNT}" =~ ^[0-9]+$ ]] && ((LIBVIRT_VM_COUNT >= 1)) || {
        log "ERROR: invalid VM count: ${LIBVIRT_VM_COUNT}"; return 10
    }
    # Spread the VMs over the NUMA nodes so every VM keeps its memory inside the
    # node that owns its cores and no node is over-committed.
    for node in "${nodes[@]}"; do
        assigned_per_node[${node}]=0
    done
    declare -A next_core_index=()
    for node in "${nodes[@]}"; do
        next_core_index[${node}]=0
    done
    : > "${LIBVIRT_VM_PLAN_FILE}"
    for ((i = 0; i < LIBVIRT_VM_COUNT; i++)); do
        best_node=""
        for node in "${nodes[@]}"; do
            (( node_cores[${node}] - next_core_index[${node}] >= per_vm )) || continue
            if [[ -z "${best_node}" ]] || (( assigned_per_node[${node}] < assigned_per_node[${best_node}] )); then
                best_node="${node}"
            fi
        done
        [[ -n "${best_node}" ]] || {
            log "ERROR: ${LIBVIRT_VM_COUNT} VMs with ${per_vm} cores do not fit on this host (${total_cores} cores)"
            return 30
        }
        node="${best_node}"
        cpuset=""
        for ((j = 0; j < per_vm; j++)); do
            index=$(( next_core_index[${node}] + j ))
            # shellcheck disable=SC2086
            core="$(printf '%s\n' ${node_core_list[${node}]} | sed -n "$((index + 1))p")"
            [[ -n "${core}" ]] || { log "ERROR: cannot resolve NUMA node ${node} core index ${index}"; return 30; }
            cpu_of_core="$(printf '%s\n' "${rows[@]}" | awk -F, -v node="${node}" -v core="${core}"                 '($4==node) && ($2==core) && ($5=="Y"||$5=="y"||$5=="yes"||$5=="1"||$5=="") {print $1; exit}')"
            [[ -n "${cpu_of_core}" ]] || { log "ERROR: cannot resolve the first thread of NUMA node ${node} core ${core}"; return 30; }
            cpuset+="${cpuset:+,}${cpu_of_core}"
        done
        next_core_index[${node}]=$(( next_core_index[${node}] + per_vm ))
        assigned_per_node[${node}]=$(( assigned_per_node[${node}] + 1 ))
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
            "${i}" "boostkit-libvirt-${EXPECTED_ARCH}-${PERF_RUN_ID}-${i}" "${cpuset}" "${node}" \
            "${per_vm}" "${LIBVIRT_VM_MEM_MIB}" >> "${LIBVIRT_VM_PLAN_FILE}"
    done
    mkdir -p "${LIBVIRT_VM_RUN_DIR}"
    log "planned ${LIBVIRT_VM_COUNT} VMs (${per_vm} vCPU / ${LIBVIRT_VM_MEM_MIB} MiB each) on ${LIBVIRT_TOTAL_CORES} host cores across ${#nodes[@]} NUMA nodes"
}

load_libvirt_vms() {
    [[ -s "${LIBVIRT_VM_PLAN_FILE}" ]] || { log 'ERROR: the VM plan is missing'; return 30; }
    LIBVIRT_VM_NAMES=()
    LIBVIRT_VM_CPUSETS=()
    LIBVIRT_VM_NODES=()
    LIBVIRT_VM_IPS=()
    local idx name cpuset node cores mem
    while IFS=$'\t' read -r idx name cpuset node cores mem; do
        LIBVIRT_VM_NAMES[idx]="${name}"
        LIBVIRT_VM_CPUSETS[idx]="${cpuset}"
        LIBVIRT_VM_NODES[idx]="${node}"
        LIBVIRT_VM_IPS[idx]="${LIBVIRT_VM_IPS[idx]:-}"
    done < "${LIBVIRT_VM_PLAN_FILE}"
    LIBVIRT_VM_COUNT="$(wc -l < "${LIBVIRT_VM_PLAN_FILE}" | tr -d ' ')"
    export LIBVIRT_VM_COUNT
}

libvirt_vm_dir() {
    printf '%s/vm%s\n' "${LIBVIRT_VM_RUN_DIR}" "$1"
}

libvirt_vm_ip_file() {
    printf '%s/ip\n' "$(libvirt_vm_dir "$1")"
}

read_libvirt_vm_ip() {
    local index="$1" file
    file="$(libvirt_vm_ip_file "${index}")"
    [[ -s "${file}" ]] && cat "${file}"
    return 0
}

save_libvirt_vm_ip() {
    printf '%s\n' "$2" > "$(libvirt_vm_ip_file "$1")"
}

vm_pin_lines() {
    local index="$1" vcpu=0 host_cpu
    local -a cpus=()
    IFS=',' read -r -a cpus <<< "${LIBVIRT_VM_CPUSETS[${index}]}"
    for host_cpu in "${cpus[@]}"; do
        printf "    <vcpupin vcpu='%d' cpuset='%d'/>\n" "${vcpu}" "${host_cpu}"
        vcpu=$((vcpu + 1))
    done
}

emit_libvirt_vm_xml() {
    local index="$1"
    local name="${LIBVIRT_VM_NAMES[${index}]}"
    local cpuset="${LIBVIRT_VM_CPUSETS[${index}]}"
    local node="${LIBVIRT_VM_NODES[${index}]}"
    local dir arch_machine arch_type features cpu_block emulator
    dir="$(libvirt_vm_dir "${index}")"
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        arch_type="x86_64"
        arch_machine="q35"
        features="    <acpi/>\n    <apic/>"
    else
        arch_type="aarch64"
        arch_machine="virt"
        features="    <acpi/>"
    fi
    if [[ "${LIBVIRT_VM_ACCEL_USED}" == kvm ]]; then
        cpu_block="  <cpu mode='host-passthrough' check='none' migratable='off'>
    <topology sockets='1' dies='1' cores='${LIBVIRT_VM_CORES}' threads='1'/>
  </cpu>"
    else
        cpu_block="  <cpu mode='custom' check='none'>
    <model fallback='allow'>${LIBVIRT_TCG_CPU_MODEL:-Haswell}</model>
    <topology sockets='1' dies='1' cores='${LIBVIRT_VM_CORES}' threads='1'/>
  </cpu>"
    fi
    if [[ "${EXPECTED_ARCH}" == aarch64 ]]; then
        cpu_block="${cpu_block}"
    fi
    emulator="$(libvirt_emulator_element)"
    cat <<XML
<domain type='${LIBVIRT_VM_ACCEL_USED}'>
  <name>${name}</name>
  <description>boostkit libvirt reference VM: ${LIBVIRT_VM_CORES} vCPU (${LIBVIRT_VM_CORES} cores x 1 thread) pinned to consecutive host cores of NUMA node ${node}, ${LIBVIRT_VM_MEM_MIB} MiB bound to the same node, openEuler 24.03 LTS SP4</description>
  <memory unit='MiB'>${LIBVIRT_VM_MEM_MIB}</memory>
  <currentMemory unit='MiB'>${LIBVIRT_VM_MEM_MIB}</currentMemory>
  <vcpu placement='static'>${LIBVIRT_VM_CORES}</vcpu>
  <cputune>
$(vm_pin_lines "${index}")
    <emulatorpin cpuset='${cpuset}'/>
  </cputune>
  <numatune>
    <memory mode='strict' nodeset='${node}'/>
  </numatune>
  <os>
    <type arch='${arch_type}' machine='${arch_machine}'>hvm</type>
XML
    if [[ "${EXPECTED_ARCH}" == aarch64 ]]; then
        cat <<XML
    <loader readonly='yes' type='pflash'>/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw</loader>
    <nvram>${dir}/nvram.fd</nvram>
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
${emulator}
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='${dir}/system.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='${LIBVIRT_VM_NETWORK}'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <log file='${dir}/console.log' append='off'/>
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

sweep_libvirt_stale_vms() {
    local name
    while IFS= read -r name; do
        [[ -n "${name}" ]] || continue
        log "removing stale reference VM: ${name}"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 || sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    done < <(sudo -n virsh list --all --name 2>/dev/null | grep -E '^boostkit-libvirt-' || true)
    if [[ -d "${LIBVIRT_VM_RUN_DIR}" ]]; then
        find "${LIBVIRT_VM_RUN_DIR}" -mindepth 1 -maxdepth 1 -type d ! -name 'vm*' -exec sudo -n rm -rf {} + 2>/dev/null || true
    fi
}

vm_ssh_opts() {
    printf '%s\n' \
        -p 22 \
        -i "${LIBVIRT_VM_KEY}" \
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
        -i "${LIBVIRT_VM_KEY}" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=10
}

libvirt_guest_ip() {
    local index="$1" ip
    ip="$(read_libvirt_vm_ip "${index}")"
    [[ -n "${ip}" ]] || { log "ERROR: the address of VM ${index} is unknown"; return 40; }
    printf '%s\n' "${ip}"
}

vm_exec() {
    local index="$1" ip
    shift
    ip="$(libvirt_guest_ip "${index}")" || return 40
    local -a options=()
    mapfile -t options < <(vm_ssh_opts)
    ssh "${options[@]}" "root@${ip}" "$(printf '%q ' "$@")"
}

vm_exec_shell() {
    local index="$1" command="$2" ip
    ip="$(libvirt_guest_ip "${index}")" || return 40
    local -a options=()
    mapfile -t options < <(vm_ssh_opts)
    ssh "${options[@]}" "root@${ip}" "${command}"
}

vm_copy_in() {
    local index="$1" source="$2" target="$3" ip
    ip="$(libvirt_guest_ip "${index}")" || return 40
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "${source}" "root@${ip}:${target}"
}

vm_copy_out() {
    local index="$1" source="$2" target="$3" ip
    ip="$(libvirt_guest_ip "${index}")" || return 40
    local -a options=()
    mapfile -t options < <(vm_scp_opts)
    scp "${options[@]}" "root@${ip}:${source}" "${target}"
}

wait_libvirt_vm_address() {
    local index="$1" name="${LIBVIRT_VM_NAMES[$1]}" attempt address
    for attempt in $(seq 1 150); do
        address="$(sudo -n virsh domifaddr "${name}" --source lease 2>/dev/null |
            awk '/ipv4/ {print $4}' | cut -d/ -f1 | head -n 1)"
        if [[ -n "${address}" ]]; then
            save_libvirt_vm_ip "${index}" "${address}"
            return 0
        fi
        sleep 2
    done
    return 1
}

wait_libvirt_vm_ssh() {
    local index="$1" attempt cpus
    for attempt in $(seq 1 150); do
        cpus="$(vm_exec "${index}" nproc 2>/dev/null || true)"
        if [[ "${cpus}" == "${LIBVIRT_VM_CORES}" ]]; then
            return 0
        fi
        sleep 2
    done
    return 1
}

create_libvirt_vms() {
    local index dir xml
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        dir="$(libvirt_vm_dir "${index}")"
        sudo -n mkdir -p "${dir}" || return 30
        sudo -n chmod 755 "${dir}" || return 30
        sudo -n qemu-img create -q -f qcow2 -F qcow2 -b "${LIBVIRT_GOLDEN_IMAGE}" "${dir}/system.qcow2" || {
            log "ERROR: failed to create the overlay disk of VM ${index}"; return 40
        }
        xml="${dir}/vm.xml"
        emit_libvirt_vm_xml "${index}" | sudo -n tee "${xml}" >/dev/null || {
            log "ERROR: failed to render the definition of VM ${index}"; return 40
        }
        sudo -n virsh define "${xml}" >/dev/null || {
            log "ERROR: libvirt rejected the definition of VM ${index}"; return 40
        }
    done
    log "defined ${LIBVIRT_VM_COUNT} reference VMs"
}

start_libvirt_vms() {
    local index
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        sudo -n virsh start "${LIBVIRT_VM_NAMES[${index}]}" >/dev/null || {
            log "ERROR: VM ${index} failed to start"; return 40
        }
    done
    log "started ${LIBVIRT_VM_COUNT} reference VMs, waiting for their addresses"
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        wait_libvirt_vm_address "${index}" || {
            log "ERROR: VM ${index} did not obtain a DHCP address"; return 40
        }
    done
    log "waiting for every VM to answer over SSH with ${LIBVIRT_VM_CORES} vCPU"
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        wait_libvirt_vm_ssh "${index}" || {
            log "ERROR: VM ${index} did not become reachable over SSH"; return 40
        }
    done
    log "${LIBVIRT_VM_COUNT} reference VMs are ready"
}

check_libvirt_vms() {
    local index ip state
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        ip="$(read_libvirt_vm_ip "${index}")"
        [[ -n "${ip}" ]] || { log "ERROR: the address of VM ${index} is unknown"; return 40; }
        state="$(sudo -n virsh domstate "${LIBVIRT_VM_NAMES[${index}]}" 2>/dev/null || true)"
        [[ "${state}" == running ]] || {
            log "ERROR: VM ${index} is not running: ${state:-unknown}"; return 40
        }
        [[ "$(vm_exec "${index}" nproc)" == "${LIBVIRT_VM_CORES}" ]] || {
            log "ERROR: VM ${index} does not expose the expected vCPU count"; return 40
        }
    done
    log "all ${LIBVIRT_VM_COUNT} reference VMs are running and reachable"
}

verify_libvirt_guest_os() {
    local index=0 release version_id version
    release="$(vm_exec "${index}" cat /etc/os-release)" || {
        log 'ERROR: cannot read /etc/os-release inside the reference VM'; return 30
    }
    version_id="$(printf '%s\n' "${release}" | sed -n 's/^VERSION_ID="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    version="$(printf '%s\n' "${release}" | sed -n 's/^VERSION="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    [[ "${version_id}" == "24.03" ]] || {
        log "ERROR: reference VM is not openEuler 24.03 (VERSION_ID=${version_id:-unknown})"; return 30
    }
    log "reference VM operating system: ${version:-openEuler ${version_id}}"
}

enable_libvirt_guest_forwarding() {
    local current
    current="$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 0)"
    if [[ "${current}" != "1" ]]; then
        sudo -n sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || {
            log 'WARNING: could not enable net.ipv4.ip_forward on the host'
            return 0
        }
        log 'enabled net.ipv4.ip_forward so the reference VMs can reach package mirrors'
    fi
    return 0
}

guest_has_network() {
    local index="$1"
    vm_exec_shell "${index}" 'timeout 8 bash -c "cat < /dev/null > /dev/tcp/192.168.122.1/53"' >/dev/null 2>&1 || return 1
    vm_exec_shell "${index}" 'for host in mirrors.openeuler.org repo.openeuler.org; do timeout 8 bash -c "cat < /dev/null > /dev/tcp/${host}/443" && exit 0; done; exit 1' >/dev/null 2>&1
}

install_libvirt_guest_packages() {
    local index="$1" attempt
    local -a proxy_env=()
    local -a extra=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy_env=(env "http_proxy=$(vm_guest_proxy_value)" "https_proxy=$(vm_guest_proxy_value)")
    fi
    if guest_has_network "${index}"; then
        for attempt in 1 2 3; do
            case "${attempt}" in
                1) extra=() ;;
                2) extra=(--refresh) ;;
                3) extra=(--disablerepo='*update*' --setopt=strict=0) ;;
            esac
            if "${proxy_env[@]}" vm_exec "${index}" timeout 420 dnf install -y \
                --setopt=install_weak_deps=False "${extra[@]}" \
                gcc make perl perl-Time-HiRes tar gzip coreutils findutils procps-ng \
                sed gawk grep util-linux; then
                return 0
            fi
            log "WARNING: guest dnf installation failed on VM ${index} (attempt ${attempt} of 3)"
            sleep 5
        done
        log "WARNING: VM ${index} cannot install its toolchain through dnf; falling back to offline RPMs"
    else
        log "VM ${index} has no outbound network; installing the toolchain from host-provided RPMs"
    fi
    install_libvirt_guest_packages_offline "${index}" || return 30
}

install_libvirt_guest_packages_offline() {
    local index="$1" bundle_dir tarball package attempt
    local -a packages=(gcc make perl perl-Time-HiRes tar gzip coreutils findutils procps-ng sed gawk grep util-linux)
    command -v dnf >/dev/null 2>&1 || {
        log 'ERROR: the host has no dnf, so the offline toolchain bundle cannot be built'; return 30
    }
    bundle_dir="${UNIXBENCH_ARCHIVE_DIR}/rpms/${EXPECTED_ARCH}"
    sudo -n mkdir -p "${bundle_dir}" 2>/dev/null || mkdir -p "${bundle_dir}" 2>/dev/null || true
    [[ -d "${bundle_dir}" ]] || { bundle_dir="${PERF_WORK_DIR}/rpms"; mkdir -p "${bundle_dir}"; }
    if ! compgen -G "${bundle_dir}/*.rpm" >/dev/null; then
        log "downloading the guest toolchain RPMs on the host into ${bundle_dir}"
        for package in "${packages[@]}"; do
            for attempt in 1 2; do
                if with_network_proxy dnf download --resolve --alldeps --destdir "${bundle_dir}" "${package}" >/dev/null 2>&1; then
                    break
                fi
                log "WARNING: could not download ${package} (attempt ${attempt} of 2)"
                sleep 3
            done
        done
    fi
    compgen -G "${bundle_dir}/*.rpm" >/dev/null || {
        log 'ERROR: no guest toolchain RPM was downloaded on the host'; return 30
    }
    tarball="${PERF_WORK_DIR}/libvirt-guest-rpms-${EXPECTED_ARCH}.tar.gz"
    tar -czf "${tarball}" -C "${bundle_dir}" . || return 30
    vm_exec "${index}" rm -rf /root/libvirt-rpms || return 30
    vm_exec "${index}" mkdir -p /root/libvirt-rpms || return 30
    vm_copy_in "${index}" "${tarball}" /root/libvirt-rpms.tar.gz || return 30
    vm_exec "${index}" tar -xzf /root/libvirt-rpms.tar.gz -C /root/libvirt-rpms || return 30
    vm_exec_shell "${index}" 'dnf install -y --disablerepo="*" --nogpgcheck /root/libvirt-rpms/*.rpm' || {
        log "ERROR: the offline guest toolchain installation failed on VM ${index}"; return 30
    }
}

fetch_unixbench_archive() {
    local archive="${PERF_WORK_DIR}/${UNIXBENCH_ARCHIVE_NAME}"
    local cached="${UNIXBENCH_ARCHIVE_DIR}/${UNIXBENCH_ARCHIVE_NAME}"
    if [[ -f "${archive}" ]]; then
        printf '%s\n' "${archive}"
        return 0
    fi
    if [[ -f "${cached}" ]]; then
        log "using the cached UnixBench master archive ${cached}"
        cp -- "${cached}" "${archive}" || return 30
    else
        log "downloading the UnixBench master snapshot from ${UNIXBENCH_ARCHIVE_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 -o "${archive}.part" "${UNIXBENCH_ARCHIVE_URL}" || {
            log 'ERROR: cannot download the UnixBench master snapshot'; return 30
        }
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${UNIXBENCH_ARCHIVE_SHA256}" "${archive}" | sha256sum -c - >/dev/null || {
        log 'ERROR: the UnixBench master archive checksum does not match'; return 30
    }
    printf '%s\n' "${archive}"
}

# Replace the tested maximum of parallel copies with the vCPU count of the guest,
# exactly as the reference procedure does, and report which spelling was found so
# the evidence shows whether upstream already ships an unlimited value.
patch_guest_unixbench_max_copies() {
    local index="$1" output
    output="$(vm_exec_shell "${index}" "cd '${UNIXBENCH_GUEST_DIR}' && sed -i \"s/\\('system.*'maxCopies'\\) => 16/\\1 => \`nproc --all\`/\" Run && grep -nE \"'system'.*maxCopies\" Run | head -n 1")" || {
        log "ERROR: cannot patch the maxCopies setting on VM ${index}"; return 40
    }
    printf '%s\n' "${output}"
}

prepare_libvirt_guest() {
    local index="$1" archive
    archive="$(fetch_unixbench_archive)" || return $?
    log "preparing VM ${index}"
    install_libvirt_guest_packages "${index}" || return $?
    vm_copy_in "${index}" "${archive}" "${UNIXBENCH_GUEST_ARCHIVE}" || return $?
    vm_exec_shell "${index}" "rm -rf '${UNIXBENCH_GUEST_HOME}' /home/STREAM-master" || return 40
    log "VM ${index}: tar -zxvf ${UNIXBENCH_GUEST_ARCHIVE} -C /home"
    vm_exec "${index}" tar -zxvf "${UNIXBENCH_GUEST_ARCHIVE}" -C /home >/dev/null || {
        log "ERROR: cannot unpack UnixBench inside VM ${index}"; return 40
    }
    vm_exec "${index}" test -f "${UNIXBENCH_GUEST_DIR}/Run" || {
        log "ERROR: UnixBench/Run is missing inside VM ${index}"; return 40
    }
    patch_guest_unixbench_max_copies "${index}" | sed "s/^/VM ${index}: /" >&2
    log "VM ${index}: make all"
    vm_exec_shell "${index}" "cd '${UNIXBENCH_GUEST_DIR}' && make all" >/dev/null || {
        log "ERROR: UnixBench build failed inside VM ${index}"; return 40
    }
    vm_exec "${index}" test -x "${UNIXBENCH_GUEST_DIR}/pgms/dhry2reg" || {
        log "ERROR: the UnixBench build is incomplete inside VM ${index}"; return 40
    }
    vm_exec_shell "${index}" "cd '${UNIXBENCH_GUEST_DIR}' && ./Run --version 2>/dev/null | head -n 0; grep -m1 -E '^my \\\$version' Run" || true
}

guest_optimize() {
    local index="$1"
    vm_exec_shell "${index}" '
        set -u
        for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "${governor}" ] && echo performance > "${governor}" 2>/dev/null || true
        done
        [ -w /sys/kernel/mm/transparent_hugepage/enabled ] && echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
        systemctl disable --now firewalld >/dev/null 2>&1 || true
        systemctl disable --now irqbalance >/dev/null 2>&1 || true
        sysctl -w vm.swappiness=10 >/dev/null 2>&1 || true
        true
    ' >/dev/null 2>&1 || log "WARNING: guest optimisation on VM ${index} was partial"
}

prepare_all_libvirt_guests() {
    local index pids=() status=0
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        guest_optimize "${index}" &
        pids+=("$!")
    done
    for index in "${pids[@]}"; do wait "${index}" || status=1; done
    ((status == 0)) || { log 'ERROR: guest optimisation failed'; return 40; }
    pids=()
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        prepare_libvirt_guest "${index}" > "${LIBVIRT_VM_RUN_DIR}/prepare-vm${index}.log" 2>&1 &
        pids+=("$!")
    done
    for index in "${pids[@]}"; do wait "${index}" || status=1; done
    ((status == 0)) || {
        log 'ERROR: at least one reference VM could not be prepared; see prepare-vm*.log'
        return 40
    }
    log "prepared UnixBench inside ${LIBVIRT_VM_COUNT} reference VMs"
}

capture_libvirt_vm_environment() {
    local output="${RESULTS_DIR}/vm-environment.txt" index
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf '# host: %s (%s)\n' "$(uname -n)" "$(uname -m)"
        printf '# host_cores: %s\n' "${LIBVIRT_TOTAL_CORES}"
        printf '# host_accel: %s\n' "${LIBVIRT_VM_ACCEL_USED}"
        printf '# host_virsh: %s\n' "$(sudo -n virsh --version 2>/dev/null || echo unknown)"
        printf '# vm_count: %s\n' "${LIBVIRT_VM_COUNT}"
        printf '# vm_spec: %s vCPU / %s MiB / copies=%s\n' "${LIBVIRT_VM_CORES}" "${LIBVIRT_VM_MEM_MIB}" "${LIBVIRT_COPIES}"
        printf '# host_numa_cpus:\n'
        for index in $(seq 0 9); do
            [[ -r "${LIBVIRT_SYSFS_NODE_ROOT}/node${index}/cpulist" ]] || break
            printf '#   node%s: %s\n' "${index}" "$(cat "${LIBVIRT_SYSFS_NODE_ROOT}/node${index}/cpulist")"
        done
    } > "${output}"
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        {
            printf '\n# ===== VM %s =====\n' "${index}"
            printf '# name: %s\n' "${LIBVIRT_VM_NAMES[${index}]}"
            printf '# cpuset: %s\n' "${LIBVIRT_VM_CPUSETS[${index}]}"
            printf '# numa_node: %s\n' "${LIBVIRT_VM_NODES[${index}]}"
            printf '# ip: %s\n' "$(read_libvirt_vm_ip "${index}")"
            printf '# --- guest os-release ---\n'
            vm_exec "${index}" cat /etc/os-release
            printf '# --- guest lscpu ---\n'
            vm_exec "${index}" lscpu
            printf '# --- guest meminfo ---\n'
            vm_exec "${index}" sh -c 'grep -E "MemTotal|HugePages" /proc/meminfo'
        } >> "${output}" 2>&1
    done
    {
        printf '\n# ===== virsh dumpxml of VM 0 =====\n'
        sudo -n virsh dumpxml "${LIBVIRT_VM_NAMES[0]}"
    } >> "${output}" 2>&1
    log "captured the reference VM environment evidence: ${output}"
}

stop_libvirt_vms() {
    local index
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        [[ -n "${LIBVIRT_VM_NAMES[${index}]:-}" ]] || continue
        sudo -n virsh destroy "${LIBVIRT_VM_NAMES[${index}]}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${LIBVIRT_VM_NAMES[${index}]}" --nvram >/dev/null 2>&1 || \
            sudo -n virsh undefine "${LIBVIRT_VM_NAMES[${index}]}" >/dev/null 2>&1 || true
    done
    if [[ -n "${LIBVIRT_VM_RUN_DIR:-}" && "${LIBVIRT_VM_RUN_DIR}" == */vm ]]; then
        sudo -n rm -rf "${LIBVIRT_VM_RUN_DIR}" 2>/dev/null || true
    fi
    log "stopped and removed ${LIBVIRT_VM_COUNT:-0} reference VMs"
}
