#!/usr/bin/env bash
# Shared runtime for the libvirt virsh lifecycle case.
#
# The case measures the libvirt control plane itself: one reference VM is defined
# on the host (4 vCPU / 8 GiB, vCPU pinned to consecutive host cores of one NUMA
# node, memory bound to that node) and every measured repetition starts it with
# `virsh start`, checks `virsh list`, enters the guest through `virsh console` and
# shuts the domain down again.  No container is used.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-22.03-LTS-SP3}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

LIBVIRT_GUEST_RELEASE="22.03-LTS-SP3"
LIBVIRT_VM_IMAGE_DIR="${LIBVIRT_VM_IMAGE_DIR:-/home/libvirt-images}"
LIBVIRT_VM_KEY="${LIBVIRT_VM_KEY:-/home/runner/software/libvirt/vm/id_ed25519}"
LIBVIRT_VM_NETWORK="${LIBVIRT_VM_NETWORK:-default}"
LIBVIRT_VM_CORES="${LIBVIRT_VM_CORES:-4}"
LIBVIRT_VM_MEM_MIB="${LIBVIRT_VM_MEM_MIB:-8192}"
LIBVIRT_VM_COUNT="${LIBVIRT_VM_COUNT:-1}"
LIBVIRT_VM_ACCEL="${LIBVIRT_VM_ACCEL:-auto}"
LIBVIRT_REPS="${LIBVIRT_REPS:-6}"
LIBVIRT_WARMUP_REPS="${LIBVIRT_WARMUP_REPS:-1}"
LIBVIRT_START_TIMEOUT="${LIBVIRT_START_TIMEOUT:-180}"
LIBVIRT_CONSOLE_TIMEOUT="${LIBVIRT_CONSOLE_TIMEOUT:-120}"
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

log() { printf '[libvirt-virsh-lifecycle] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*" >&2; }

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
        PERF_WORK_DIR="/home/runner/boostkit-perf/libvirt-virsh-lifecycle/local-${PERF_RUN_ID}"
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
    LIBVIRT_VM_DISK_ROOT="${LIBVIRT_VM_DISK_ROOT:-${LIBVIRT_VM_IMAGE_DIR}/boostkit-libvirt-vm-runs/${PERF_RUN_ID}}"
    LIBVIRT_VM_PLAN_FILE="${PERF_WORK_DIR}/vms.tsv"
    LIBVIRT_ENV_FILE="${PERF_WORK_DIR}/vm-environment.json"
    LIBVIRT_GOLDEN_IMAGE="${LIBVIRT_GOLDEN_IMAGE:-${LIBVIRT_VM_IMAGE_DIR}/boostkit-libvirt-2203-golden-${EXPECTED_ARCH}.qcow2}"
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
    # The stage scripts, the parsers and the evidence writers are separate
    # processes, so every workload knob has to be exported here.
    export LIBVIRT_VM_CORES LIBVIRT_VM_MEM_MIB LIBVIRT_REPS LIBVIRT_WARMUP_REPS LIBVIRT_VM_COUNT
    export LIBVIRT_VM_DISK_ROOT
    export LIBVIRT_GOLDEN_IMAGE
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}" "${LIBVIRT_VM_RUN_DIR}"
    cd "${SCRIPT_DIR}"
    return 0
}

require_libvirt_host() {
    local name
    for name in virsh qemu-img ssh scp python3 awk sed grep timeout; do
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

libvirt_emulator_element() {
    local candidate
    for candidate in /usr/libexec/qemu-kvm "/usr/bin/qemu-system-${EXPECTED_ARCH}" /usr/bin/qemu-kvm; do
        if [[ -x "${candidate}" ]]; then
            printf '    <emulator>%s</emulator>\n' "${candidate}"
            return 0
        fi
    done
    return 0
}

libvirt_vm_dir() { printf '%s/vm%s\n' "${LIBVIRT_VM_RUN_DIR}" "$1"; }

# QEMU runs as the qemu user, so the disks stay outside /home/runner (mode 700)
# and inside the world traversable image root.
libvirt_vm_disk_dir() { printf '%s/vm%s\n' "${LIBVIRT_VM_DISK_ROOT}" "$1"; }
libvirt_vm_ip_file() { printf '%s/ip\n' "$(libvirt_vm_dir "$1")"; }
read_libvirt_vm_ip() {
    local file
    file="$(libvirt_vm_ip_file "$1")"
    [[ -s "${file}" ]] && cat "${file}"
    return 0
}
save_libvirt_vm_ip() { printf '%s\n' "$2" > "$(libvirt_vm_ip_file "$1")"; }

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
    local dir arch_machine arch_type features cpu_block
    dir="$(libvirt_vm_disk_dir "${index}")"
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        arch_type="x86_64"; arch_machine="q35"
        features="    <acpi/>\n    <apic/>"
    else
        arch_type="aarch64"; arch_machine="virt"
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
    cat <<XML
<domain type='${LIBVIRT_VM_ACCEL_USED}'>
  <name>${name}</name>
  <description>boostkit libvirt lifecycle VM: ${LIBVIRT_VM_CORES} vCPU pinned to consecutive host cores of NUMA node ${node}, ${LIBVIRT_VM_MEM_MIB} MiB bound to the same node, openEuler ${LIBVIRT_GUEST_RELEASE}</description>
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
$(libvirt_emulator_element)
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
        log "removing stale lifecycle VM: ${name}"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 || sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    done < <(sudo -n virsh list --all --name 2>/dev/null | grep -E '^boostkit-libvirt-lifecycle-${EXPECTED_ARCH}-' || true)
}

vm_ssh_opts() {
    printf '%s\n' -p 22 -i "${LIBVIRT_VM_KEY}" -o BatchMode=yes -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10 -o ServerAliveInterval=30
}

libvirt_guest_ip() {
    local ip
    ip="$(read_libvirt_vm_ip "$1")"
    [[ -n "${ip}" ]] || { log "ERROR: the address of VM $1 is unknown"; return 40; }
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

wait_libvirt_vm_address() {
    local index="$1" name="${LIBVIRT_VM_NAMES[$1]}" attempt address
    for attempt in $(seq 1 120); do
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

virsh_domain_state() {
    sudo -n virsh domstate "$1" 2>/dev/null | head -n 1 | tr -d '\r'
}

virsh_wait_state() {
    local name="$1" expected="$2" deadline=$(( SECONDS + LIBVIRT_START_TIMEOUT )) state
    while (( SECONDS < deadline )); do
        state="$(virsh_domain_state "${name}")"
        [[ "${state}" == "${expected}" ]] && return 0
        sleep 1
    done
    return 1
}

# One vCPU per physical core: consecutive cores of a single NUMA node, and the
# guest memory stays inside that node.
plan_libvirt_vms() {
    local per_vm="${LIBVIRT_VM_CORES}"
    local -a rows=() nodes=()
    local entry cpu core socket node online key
    local total_cores=0 index assigned i j cpu_of_core cpuset best_node
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
    [[ "${LIBVIRT_VM_COUNT}" =~ ^[0-9]+$ ]] && ((LIBVIRT_VM_COUNT >= 1)) || {
        log "ERROR: invalid VM count: ${LIBVIRT_VM_COUNT}"; return 10
    }
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
            cpu_of_core="$(printf '%s\n' "${rows[@]}" | awk -F, -v node="${node}" -v core="${core}" \
                '($4==node) && ($2==core) && ($5=="Y"||$5=="y"||$5=="yes"||$5=="1"||$5=="") {print $1; exit}')"
            [[ -n "${cpu_of_core}" ]] || { log "ERROR: cannot resolve the first thread of NUMA node ${node} core ${core}"; return 30; }
            cpuset+="${cpuset:+,}${cpu_of_core}"
        done
        next_core_index[${node}]=$(( next_core_index[${node}] + per_vm ))
        assigned_per_node[${node}]=$(( assigned_per_node[${node}] + 1 ))
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
            "${i}" "boostkit-libvirt-lifecycle-${EXPECTED_ARCH}-${PERF_RUN_ID}-${i}" "${cpuset}" "${node}" \
            "${per_vm}" "${LIBVIRT_VM_MEM_MIB}" >> "${LIBVIRT_VM_PLAN_FILE}"
    done
    mkdir -p "${LIBVIRT_VM_RUN_DIR}"
    log "planned ${LIBVIRT_VM_COUNT} lifecycle VM(s) (${per_vm} vCPU / ${LIBVIRT_VM_MEM_MIB} MiB each) on ${LIBVIRT_TOTAL_CORES} host cores across ${#nodes[@]} NUMA nodes"
}

load_libvirt_vms() {
    [[ -s "${LIBVIRT_VM_PLAN_FILE}" ]] || { log 'ERROR: the VM plan is missing'; return 30; }
    LIBVIRT_VM_NAMES=()
    LIBVIRT_VM_CPUSETS=()
    LIBVIRT_VM_NODES=()
    local idx name cpuset node cores mem
    while IFS=$'\t' read -r idx name cpuset node cores mem; do
        LIBVIRT_VM_NAMES[idx]="${name}"
        LIBVIRT_VM_CPUSETS[idx]="${cpuset}"
        LIBVIRT_VM_NODES[idx]="${node}"
    done < "${LIBVIRT_VM_PLAN_FILE}"
    LIBVIRT_VM_COUNT="$(wc -l < "${LIBVIRT_VM_PLAN_FILE}" | tr -d ' ')"
    export LIBVIRT_VM_COUNT
}

create_libvirt_vms() {
    local index dir xml
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        # QEMU runs as the qemu user and cannot traverse /home/runner (mode 700),
        # so the disk, the NVRAM and the serial log live under the image root.
        dir="$(libvirt_vm_disk_dir "${index}")"
        sudo -n mkdir -p "${dir}" || return 30
        sudo -n chmod 755 "${dir}" || return 30
        sudo -n qemu-img create -q -f qcow2 -F qcow2 -b "${LIBVIRT_GOLDEN_IMAGE}" "${dir}/system.qcow2" || {
            log "ERROR: failed to create the overlay disk of VM ${index}"; return 40
        }
        sudo -n chmod 644 "${dir}/system.qcow2" || return 30
        mkdir -p "$(libvirt_vm_dir "${index}")" || return 30
        xml="$(libvirt_vm_dir "${index}")/vm.xml"
        emit_libvirt_vm_xml "${index}" | sudo -n tee "${xml}" >/dev/null || {
            log "ERROR: failed to render the definition of VM ${index}"; return 40
        }
        sudo -n virsh define "${xml}" >/dev/null || {
            log "ERROR: libvirt rejected the definition of VM ${index}"; return 40
        }
    done
    log "defined ${LIBVIRT_VM_COUNT} lifecycle VM(s) without starting them"
}

check_libvirt_vms_defined() {
    local index state
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        sudo -n virsh dominfo "${LIBVIRT_VM_NAMES[${index}]}" >/dev/null 2>&1 || {
            log "ERROR: VM ${index} is not defined in libvirt"; return 40
        }
        state="$(virsh_domain_state "${LIBVIRT_VM_NAMES[${index}]}")"
        [[ "${state}" == "shut off" ]] || {
            log "ERROR: VM ${index} must start from the shut off state, found: ${state:-unknown}"
            return 40
        }
    done
}

# Timed `virsh start` plus the running-state check of `virsh list`.
start_libvirt_vm_timed() {
    local index="$1" name="${LIBVIRT_VM_NAMES[$1]}" begin end list_output
    begin="$(date +%s%N)"
    sudo -n virsh start "${name}" >/dev/null 2>&1 || {
        log "ERROR: virsh start ${name} failed"; return 50
    }
    virsh_wait_state "${name}" "running" || {
        log "ERROR: ${name} never reached the running state"; return 50
    }
    end="$(date +%s%N)"
    list_output="$(sudo -n virsh list 2>/dev/null)"
    printf '%s\n' "${list_output}" | grep -qE "[[:space:]]${name}[[:space:]]" || {
        log "ERROR: ${name} is missing from virsh list"; return 50
    }
    printf '%s\n' "${list_output}" | grep -E "[[:space:]]${name}[[:space:]]" | grep -q 'running' || {
        log "ERROR: virsh list does not report ${name} as running"; return 50
    }
    printf '%s\n' "$(( (end - begin) / 1000000 ))"
}

# `virsh console` needs a controlling terminal, so the probe runs it under a
# pseudo terminal via `script`, sends one newline and stops as soon as the guest
# prints its login prompt.  The measured value is the wall clock until the prompt.
console_libvirt_vm_probe() {
    local index="$1" log_file="$2" name="${LIBVIRT_VM_NAMES[$1]}"
    local begin end waited=0 limit=$(( LIBVIRT_CONSOLE_TIMEOUT * 2 )) status=50 console_pid
    : > "${log_file}"
    begin="$(date +%s%N)"
    ( printf '\n'; sleep "${LIBVIRT_CONSOLE_TIMEOUT}" ) | \
        script -qec "sudo -n virsh console ${name} --force" /dev/null > "${log_file}" 2>&1 &
    console_pid=$!
    while (( waited < limit )); do
        if grep -qiE 'login:|Password:' "${log_file}" 2>/dev/null; then
            status=0
            break
        fi
        sleep 0.5
        waited=$(( waited + 1 ))
    done
    end="$(date +%s%N)"
    kill "${console_pid}" 2>/dev/null || true
    pkill -f "virsh console ${name}" 2>/dev/null || true
    wait "${console_pid}" 2>/dev/null || true
    if (( status != 0 )); then
        log "ERROR: virsh console of ${name} never reached a login prompt (see ${log_file})"
        return 50
    fi
    printf '%s\n' "$(( (end - begin) / 1000000 ))"
}

# The guest answers over SSH once it has really booted.  A stale DHCP lease from a
# previous run can hand out a dead address, so a failed probe drops the address and
# resolves it again instead of waiting on the wrong guest.
wait_libvirt_vm_ssh() {
    local index="$1" attempt cpus ip
    for attempt in $(seq 1 120); do
        if [[ -z "$(read_libvirt_vm_ip "${index}")" ]]; then
            wait_libvirt_vm_address "${index}" || true
        fi
        ip="$(read_libvirt_vm_ip "${index}")"
        if [[ -n "${ip}" ]]; then
            cpus="$(vm_exec "${index}" nproc 2>/dev/null || true)"
            if [[ "${cpus}" == "${LIBVIRT_VM_CORES}" ]]; then
                return 0
            fi
            save_libvirt_vm_ip "${index}" ""
        fi
        sleep 2
    done
    return 1
}

verify_libvirt_guest_os() {
    local release version_id version
    release="$(vm_exec 0 cat /etc/os-release)" || {
        log 'ERROR: cannot read /etc/os-release inside the reference VM'; return 30
    }
    version_id="$(printf '%s\n' "${release}" | sed -n 's/^VERSION_ID="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    version="$(printf '%s\n' "${release}" | sed -n 's/^VERSION="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p')"
    [[ "${version_id}" == "22.03" ]] || {
        log "ERROR: the reference VM is not openEuler 22.03 (VERSION_ID=${version_id:-unknown})"
        return 30
    }
    printf '%s\n' "${version:-openEuler ${version_id}}"
}

# Graceful `virsh shutdown` with a destroy fallback; the domain stays defined.
graceful_shutdown_lifecycle_vm() {
    local index="$1" name="${LIBVIRT_VM_NAMES[$1]}" state
    state="$(virsh_domain_state "${name}")"
    [[ "${state}" == "running" ]] || return 0
    sudo -n virsh shutdown "${name}" >/dev/null 2>&1 || {
        log "ERROR: virsh shutdown ${name} failed"; return 50
    }
    virsh_wait_state "${name}" "shut off" || {
        log "WARNING: ${name} ignored the graceful shutdown and is destroyed"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        virsh_wait_state "${name}" "shut off" || return 50
    }
    return 0
}

stop_libvirt_vm() {
    local index="$1" name="${LIBVIRT_VM_NAMES[$1]}" state
    graceful_shutdown_lifecycle_vm "${index}" || true
    sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
    sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 || \
        sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    index=$((index))
    return 0
}

stop_all_libvirt_vms() {
    local index
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        [[ -n "${LIBVIRT_VM_NAMES[${index}]:-}" ]] || continue
        stop_libvirt_vm "${index}"
    done
    if [[ -n "${LIBVIRT_VM_RUN_DIR:-}" && "${LIBVIRT_VM_RUN_DIR}" == */vm ]]; then
        sudo -n rm -rf "${LIBVIRT_VM_RUN_DIR}" 2>/dev/null || true
    fi
    if [[ -n "${LIBVIRT_VM_DISK_ROOT:-}" && "${LIBVIRT_VM_DISK_ROOT}" == */boostkit-libvirt-vm-runs/* ]]; then
        sudo -n rm -rf "${LIBVIRT_VM_DISK_ROOT}" 2>/dev/null || true
    fi
    log "stopped and removed ${LIBVIRT_VM_COUNT:-0} lifecycle VM(s)"
}

