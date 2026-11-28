#!/usr/bin/env bash
# Shared runtime for the fio 4k random read/write cases.
#
# Layout of one run:
#   host      : libvirt/QEMU + a golden openEuler 24.03 LTS SP4 image + a thin
#               storage pool (loop files -> LVM volume group -> one logical
#               volume per fio job, pre-seeded with random data)
#   reference VM : the target operating system; fio is installed there and every
#               measurement runs inside it as
#                   cd /root/fio && taskset -c 0 fio randrw_4k.fio
#
# Nothing in this file touches the host software configuration except the
# storage pool and the transient libvirt domain owned by this run.

FIO_CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIO_SCRIPTS_DIR="${FIO_CASE_DIR}/scripts"
# shellcheck disable=SC1091
source "${FIO_SCRIPTS_DIR}/workload.env"

FIO_VERSION_DEFAULT="3.34"
FIO_GUEST_DIR="${FIO_GUEST_DIR:-/root/fio}"
FIO_GUEST_JOB="randrw_4k.fio"
FIO_GUEST_BIN="/usr/bin/fio"

FIO_VM_IMAGE_DIR="${FIO_VM_IMAGE_DIR:-/home/libvirt-images}"
FIO_VM_KEY_DIR="${FIO_VM_KEY_DIR:-/home/runner/software/fio/vm}"
FIO_VM_KEY="${FIO_VM_KEY_DIR}/id_ed25519"
FIO_VM_NETWORK="${FIO_VM_NETWORK:-default}"
FIO_VM_ACCEL="${FIO_VM_ACCEL:-auto}"
# The default TCG CPU model has to exist in the guest architecture: Haswell is an
# x86 model and makes libvirt reject an aarch64 domain.
if [[ "${EXPECTED_ARCH:-$(uname -m)}" == x86_64 ]]; then
    FIO_VM_TCG_CPU_MODEL="${FIO_VM_TCG_CPU_MODEL:-Haswell}"
else
    FIO_VM_TCG_CPU_MODEL="${FIO_VM_TCG_CPU_MODEL:-cortex-a57}"
fi

FIO_STORAGE_ROOT="${FIO_STORAGE_ROOT:-${FIO_VM_IMAGE_DIR}/fio-storage}"

log() {
    printf '[fio] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

configure_runtime_paths() {
    : "${PERF_RUN_ID:=$(date -u '+%Y%m%dT%H%M%SZ')}"
    : "${EXPECTED_ARCH:=$(uname -m)}"
    : "${SOFTWARE_VERSION:=${FIO_VERSION_DEFAULT}}"
    : "${PERF_WORK_DIR:=${TMPDIR:-/tmp}/perf-${PERF_RUN_ID}}"
    : "${RESULTS_DIR:=${PERF_WORK_DIR}/results}"
    : "${PERF_VARIANT:=base}"
    : "${PERF_REPS:=6}"
    : "${PERF_ACTUAL_VERSION_FILE:=${RESULTS_DIR}/actual-version.txt}"
    export PERF_RUN_ID EXPECTED_ARCH SOFTWARE_VERSION PERF_WORK_DIR RESULTS_DIR PERF_VARIANT
    export PERF_ACTUAL_VERSION_FILE

    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}"

    FIO_VM_IMAGE="${FIO_VM_IMAGE_DIR}/boostkit-fio-golden-${EXPECTED_ARCH}.qcow2"
    FIO_VM_RUN_DIR="${FIO_VM_IMAGE_DIR}/runs/${PERF_RUN_ID}"
    FIO_VM_OVERLAY="${FIO_VM_RUN_DIR}/system.qcow2"
    FIO_VM_NVRAM="${FIO_VM_RUN_DIR}/nvram.fd"
    FIO_VM_NAME="boostkit-fio-${EXPECTED_ARCH}-${PERF_RUN_ID}"
    FIO_VM_STATE_FILE="${PERF_WORK_DIR}/vm-state.env"
    FIO_STORAGE_DIR="${FIO_STORAGE_ROOT}/${FIO_STORAGE_KEY}"
    FIO_VG_NAME="${FIO_STORAGE_KEY}-vg"
    FIO_SEED_MARKER="${FIO_STORAGE_DIR}/.seeded"
    export FIO_VM_IMAGE FIO_VM_RUN_DIR FIO_VM_OVERLAY FIO_VM_NVRAM FIO_VM_NAME
    export FIO_VM_STATE_FILE FIO_STORAGE_DIR FIO_VG_NAME
}

fio_block_devices() {
    # Guest block device names for this case, one per fio job.
    local index
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        printf 'vdb\n' >/dev/null
    done
    local letters=(b c d e f g h i)
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        printf 'vd%s\n' "${letters[$((index - 1))]}"
    done
}

fio_lv_names() {
    local index
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        printf '%s/data%d\n' "${FIO_VG_NAME}" "${index}"
    done
}

fio_job_filename_list() {
    local device first=1
    for device in $(fio_block_devices); do
        if ((first)); then
            printf '/dev/%s' "${device}"
            first=0
        else
            printf ':/dev/%s' "${device}"
        fi
    done
}

resolve_accel() {
    local requested="${FIO_VM_ACCEL}"
    case "${requested}" in
        kvm)
            [[ -e /dev/kvm ]] || { log 'ERROR: FIO_VM_ACCEL=kvm but /dev/kvm is missing'; return 30; }
            FIO_VM_ACCEL_USED=kvm
            ;;
        tcg)
            FIO_VM_ACCEL_USED=tcg
            ;;
        auto)
            # The case runs as an unprivileged runner user while libvirt itself
            # starts QEMU as root/qemu, so probing /dev/kvm directly can report a
            # false negative; ask through sudo as well before degrading to TCG.
            if [[ -r /dev/kvm && -w /dev/kvm ]] || sudo -n test -r /dev/kvm 2>/dev/null; then
                FIO_VM_ACCEL_USED=kvm
            else
                FIO_VM_ACCEL_USED=tcg
                log 'no /dev/kvm on this host: falling back to QEMU TCG (functional validation only)'
            fi
            ;;
        *)
            log "ERROR: unsupported FIO_VM_ACCEL=${requested}"
            return 30
            ;;
    esac
    export FIO_VM_ACCEL_USED
}

require_fio_vm_host() {
    local tool
    for tool in virsh qemu-img ssh scp sha256sum sudo; do
        command -v "${tool}" >/dev/null 2>&1 || {
            log "ERROR: the host is missing ${tool}"
            return 30
        }
    done
    sudo -n virsh version >/dev/null 2>&1 || {
        log 'ERROR: the runner cannot reach libvirt through passwordless sudo'
        return 30
    }
    [[ -f "${FIO_VM_IMAGE}" ]] || {
        log "ERROR: the golden image ${FIO_VM_IMAGE} is missing; run scripts/host/prepare-vm-host.sh"
        return 30
    }
    [[ -f "${FIO_VM_KEY}" ]] || {
        log "ERROR: the SSH key ${FIO_VM_KEY} is missing; run scripts/host/prepare-vm-host.sh"
        return 30
    }
    return 0
}

# --- host storage pool ------------------------------------------------------

fio_loop_device_for() {
    local image="$1"
    losetup -j "${image}" 2>/dev/null | awk -F: 'NR==1 {print $1}'
}

fio_lv_device_path() {
    # Hosts without udev (for example a WSL workspace) do not create the
    # /dev/<vg>/<lv> symlinks, but device-mapper always provides /dev/mapper/<dm>.
    local index="$1"
    local direct="/dev/${FIO_VG_NAME}/data${index}"
    local mapper="/dev/mapper/${FIO_VG_NAME//-/--}-data${index}"
    if [[ -e "${direct}" ]]; then
        printf '%s' "${direct}"
        return 0
    fi
    if [[ -e "${mapper}" ]]; then
        printf '%s' "${mapper}"
        return 0
    fi
    printf '%s' "${direct}"
    return 1
}

fio_libvirt_qemu_user() {
    local candidate
    for candidate in qemu libvirt-qemu; do
        if id "${candidate}" >/dev/null 2>&1; then
            printf '%s' "${candidate}"
            return 0
        fi
    done
    return 1
}

ensure_fio_block_nodes() {
    # libvirt resolves the device-mapper targets of a block disk to its backing
    # device and then stats /dev/block/<major>:<minor>. udev normally provides that
    # symlink; on a host without udev (a WSL workspace, for example) create it.
    local index loop majmin
    sudo -n mkdir -p /dev/block 2>/dev/null || true
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        loop="$(fio_loop_device_for "${FIO_STORAGE_DIR}/disk${index}.img")"
        [[ -n "${loop}" ]] || continue
        majmin="$(sudo -n lsblk -dno MAJ:MIN "${loop}" 2>/dev/null | tr -d ' ')"
        [[ -n "${majmin}" ]] || continue
        if [[ ! -e "/dev/block/${majmin}" ]]; then
            sudo -n ln -sfn "${loop}" "/dev/block/${majmin}" 2>/dev/null || true
        fi
    done
}

fio_seed_marker_value() {
    printf '%sx%sG' "${FIO_LV_COUNT}" "${FIO_LV_SIZE_GIB}"
}

ensure_fio_storage() {
    # Create (once) one logical volume per fio job and pre-seed it with random data
    # so every read hits written extents instead of never-written blocks.
    local index image loop lv size_bytes marker_value
    marker_value="$(fio_seed_marker_value)"
    sudo -n mkdir -p "${FIO_STORAGE_DIR}" || return 30
    sudo -n chmod 755 "${FIO_STORAGE_DIR}" || return 30

    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        image="${FIO_STORAGE_DIR}/disk${index}.img"
        if [[ ! -f "${image}" ]]; then
            # The backing file is one GiB larger than the logical volume: the PV
            # metadata lives inside the file, so an exact-size file cannot host an
            # exact-size volume.
            log "creating sparse backing file ${image} ($((FIO_LV_SIZE_GIB + 1)) GiB, hosts one ${FIO_LV_SIZE_GIB} GiB volume)"
            sudo -n truncate -s "$((FIO_LV_SIZE_GIB + 1))G" "${image}" || return 30
        fi
        loop="$(fio_loop_device_for "${image}")"
        if [[ -z "${loop}" ]]; then
            loop="$(sudo -n losetup --find --show "${image}")" || {
                log "ERROR: cannot attach ${image} to a loop device"
                return 30
            }
            log "attached ${image} to ${loop}"
        fi
        if ! sudo -n pvs --noheadings -o pv_name 2>/dev/null | awk '{print $1}' | grep -qx "${loop}"; then
            sudo -n pvcreate -q -y "${loop}" || return 30
        fi
    done

    if ! sudo -n vgs --noheadings -o vg_name 2>/dev/null | awk '{print $1}' | grep -qx "${FIO_VG_NAME}"; then
        if [[ -d "/dev/${FIO_VG_NAME}" ]]; then
            # A previous run may have left the udev-style /dev/<vg> directory with
            # dangling links; it makes vgcreate fail with "already exists".
            log "removing the stale /dev/${FIO_VG_NAME} device directory"
            sudo -n rm -rf "/dev/${FIO_VG_NAME}"
        fi
        local loop_args=()
        for index in $(seq 1 "${FIO_LV_COUNT}"); do
            loop_args+=("$(fio_loop_device_for "${FIO_STORAGE_DIR}/disk${index}.img")")
        done
        log "creating volume group ${FIO_VG_NAME} on ${#loop_args[@]} physical volume(s)"
        sudo -n vgcreate -q -y "${FIO_VG_NAME}" "${loop_args[@]}" || return 30
    fi

    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        if ! sudo -n lvs --noheadings -o lv_name "${FIO_VG_NAME}" 2>/dev/null | tr -d ' ' | grep -qx "data${index}"; then
            log "creating logical volume ${FIO_VG_NAME}/data${index}"
            sudo -n lvcreate -q -y -W n --zero n -L "${FIO_LV_SIZE_GIB}G" -n "data${index}" "${FIO_VG_NAME}" || {
                log "ERROR: cannot create logical volume data${index}"
                return 30
            }
        fi
    done

    sudo -n dmsetup mknodes >/dev/null 2>&1 || true
    ensure_fio_block_nodes
    local qemu_user=""
    qemu_user="$(fio_libvirt_qemu_user || true)"
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        lv="$(fio_lv_device_path "${index}")" || {
            log "ERROR: ${FIO_VG_NAME}/data${index} has no block device node"
            return 30
        }
        sudo -n chmod 660 "${lv}" 2>/dev/null || true
        if [[ -n "${qemu_user}" ]]; then
            # libvirt's qemu user opens the block devices directly.
            sudo -n chown "${qemu_user}:" "${lv}" 2>/dev/null || true
        fi
    done

    if [[ "$(cat "${FIO_SEED_MARKER}" 2>/dev/null || true)" == "${marker_value}" ]]; then
        log "logical volumes already pre-seeded (${marker_value})"
        return 0
    fi
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        lv="$(fio_lv_device_path "${index}")" || return 30
        size_bytes="$(sudo -n blockdev --getsize64 "${lv}")" || return 30
        log "pre-seeding ${lv} with random data ($((size_bytes / 1024 / 1024)) MiB)"
        # Writing the exact number of MiB avoids the trailing ENOSPC that a
        # count-less dd reports when it runs into the end of a block device.
        sudo -n dd if=/dev/urandom of="${lv}" bs=1M count="$((size_bytes / 1024 / 1024))" \
            conv=notrunc status=none || {
            log "ERROR: failed to pre-seed ${lv}"
            return 30
        }
    done
    sudo -n sh -c "printf '%s\n' '${marker_value}' > '${FIO_SEED_MARKER}'" || true
    log "storage pool ready: ${FIO_LV_COUNT} x ${FIO_LV_SIZE_GIB} GiB in ${FIO_VG_NAME}"
}

describe_fio_storage() {
    local index lv size_bytes
    {
        printf 'volume_group: %s\n' "${FIO_VG_NAME}"
        printf 'storage_root: %s\n' "${FIO_STORAGE_DIR}"
        printf 'logical_volumes: %s\n' "${FIO_LV_COUNT}"
        printf 'logical_volume_size_gib: %s\n' "${FIO_LV_SIZE_GIB}"
        printf 'pre_seeded: %s\n' "$(cat "${FIO_SEED_MARKER}" 2>/dev/null || echo unknown)"
        for index in $(seq 1 "${FIO_LV_COUNT}"); do
            lv="$(fio_lv_device_path "${index}" || true)"
            size_bytes="$(sudo -n blockdev --getsize64 "${lv}" 2>/dev/null || echo 0)"
            printf 'lv%d: %s (%s bytes)\n' "${index}" "${lv}" "${size_bytes}"
        done
        sudo -n vgs --noheadings -o vg_name,vg_size,vg_free "${FIO_VG_NAME}" 2>/dev/null |
            sed 's/^/vg: /'
        sudo -n lvs --noheadings -o lv_name,lv_size,devices "${FIO_VG_NAME}" 2>/dev/null |
            sed 's/^/lv: /'
    }
}

# --- guest access -----------------------------------------------------------

load_fio_vm_state() {
    [[ -f "${FIO_VM_STATE_FILE}" ]] || return 0
    # shellcheck disable=SC1090
    source "${FIO_VM_STATE_FILE}"
    export FIO_VM_NAME FIO_VM_IP FIO_VM_RUN_DIR FIO_VM_OVERLAY FIO_VM_ACCEL_USED
    export FIO_VM_VCPUS FIO_VM_MEM_MIB FIO_STORAGE_DIR FIO_VG_NAME
    return 0
}

save_fio_vm_state() {
    {
        printf 'FIO_VM_NAME=%q\n' "${FIO_VM_NAME}"
        printf 'FIO_VM_IP=%q\n' "${FIO_VM_IP:-}"
        printf 'FIO_VM_RUN_DIR=%q\n' "${FIO_VM_RUN_DIR}"
        printf 'FIO_VM_OVERLAY=%q\n' "${FIO_VM_OVERLAY}"
        printf 'FIO_VM_ACCEL_USED=%q\n' "${FIO_VM_ACCEL_USED:-}"
        printf 'FIO_VM_VCPUS=%q\n' "${FIO_VM_VCPUS}"
        printf 'FIO_VM_MEM_MIB=%q\n' "${FIO_VM_MEM_MIB}"
        printf 'FIO_STORAGE_DIR=%q\n' "${FIO_STORAGE_DIR}"
        printf 'FIO_VG_NAME=%q\n' "${FIO_VG_NAME}"
    } > "${FIO_VM_STATE_FILE}"
}

vm_exec() {
    ssh -i "${FIO_VM_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR -o ConnectTimeout=15 -o BatchMode=yes \
        "root@${FIO_VM_IP}" "$@"
}

vm_exec_shell() {
    ssh -i "${FIO_VM_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR -o ConnectTimeout=15 -o BatchMode=yes \
        "root@${FIO_VM_IP}" "$1"
}

vm_copy_in() {
    scp -q -i "${FIO_VM_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR -o BatchMode=yes "$1" "root@${FIO_VM_IP}:$2"
}

vm_copy_out() {
    scp -q -i "${FIO_VM_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR -o BatchMode=yes "root@${FIO_VM_IP}:$1" "$2"
}

fio_emulator_element() {
    local path
    path="$(fio_emulator_path)"
    if [[ -n "${path}" ]]; then
        printf '<emulator>%s</emulator>' "${path}"
    fi
}

fio_emulator_path() {
    # libvirt picks its own default when the element is absent, so only emit a
    # path that exists: some hosts ship /usr/libexec/qemu-kvm, others
    # /usr/bin/qemu-system-<arch>, and a wrong path makes virsh define fail.
    local candidate
    for candidate in /usr/libexec/qemu-kvm "/usr/bin/qemu-system-${EXPECTED_ARCH}" /usr/bin/qemu-kvm; do
        if [[ -x "${candidate}" ]]; then
            printf '%s' "${candidate}"
            return 0
        fi
    done
    return 0
}

emit_fio_vm_xml() {
    local arch_type arch_machine features cpu_block device disk_block index lv_device
    local domain_type
    if [[ "${EXPECTED_ARCH}" == x86_64 ]]; then
        arch_type="x86_64"
        arch_machine="q35"
        features="    <acpi/>\n    <apic/>"
    else
        arch_type="aarch64"
        arch_machine="virt"
        features="    <acpi/>"
    fi
    if [[ "${FIO_VM_ACCEL_USED}" == kvm ]]; then
        domain_type="kvm"
        cpu_block="  <cpu mode='host-passthrough' check='none' migratable='off'/>"
    else
        # libvirt spells software emulation as domain type 'qemu'; 'tcg' is not a
        # domain type, it is the accelerator qemu picks when KVM is unavailable.
        domain_type="qemu"
        cpu_block="  <cpu mode='custom' check='none'>
    <model fallback='allow'>${FIO_VM_TCG_CPU_MODEL}</model>
  </cpu>"
    fi
    disk_block=""
    for index in $(seq 1 "${FIO_LV_COUNT}"); do
        device="$(fio_block_devices | sed -n "${index}p")"
        lv_device="$(fio_lv_device_path "${index}")"
        disk_block+="    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='${lv_device}'/>
      <target dev='${device}' bus='virtio'/>
    </disk>
"
    done
    cat <<XML
<domain type='${domain_type}'>
  <name>${FIO_VM_NAME}</name>
  <description>boostkit fio reference VM: ${FIO_VM_VCPUS} vCPU, ${FIO_VM_MEM_MIB} MiB, ${FIO_LV_COUNT} logical volume(s) from ${FIO_VG_NAME}, openEuler 24.03 LTS SP4</description>
  <memory unit='MiB'>${FIO_VM_MEM_MIB}</memory>
  <currentMemory unit='MiB'>${FIO_VM_MEM_MIB}</currentMemory>
  <vcpu placement='static'>${FIO_VM_VCPUS}</vcpu>
  <os>
    <type arch='${arch_type}' machine='${arch_machine}'>hvm</type>
XML
    if [[ "${EXPECTED_ARCH}" == aarch64 ]]; then
        cat <<XML
    <loader readonly='yes' type='pflash'>/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw</loader>
    <nvram>${FIO_VM_NVRAM}</nvram>
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
$(fio_emulator_element)
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='${FIO_VM_OVERLAY}'/>
      <target dev='vda' bus='virtio'/>
    </disk>
${disk_block}    <interface type='network'>
      <source network='${FIO_VM_NETWORK}'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <log file='${FIO_VM_RUN_DIR}/console.log' append='off'/>
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

sweep_stale_fio_vms() {
    local name
    while IFS= read -r name; do
        [[ -n "${name}" ]] || continue
        [[ "${name}" == "${FIO_VM_NAME}" ]] && continue
        log "removing stale reference VM: ${name}"
        sudo -n virsh destroy "${name}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${name}" --nvram >/dev/null 2>&1 ||
            sudo -n virsh undefine "${name}" >/dev/null 2>&1 || true
    done < <(sudo -n virsh list --all --name 2>/dev/null | grep -E '^boostkit-fio-' || true)
    if [[ -d "${FIO_VM_IMAGE_DIR}/runs" ]]; then
        find "${FIO_VM_IMAGE_DIR}/runs" -mindepth 1 -maxdepth 1 -type d ! -name "${PERF_RUN_ID}" \
            -exec sudo -n rm -rf {} + 2>/dev/null || true
    fi
}

wait_for_fio_vm_address() {
    local attempt address
    for attempt in $(seq 1 150); do
        address="$(sudo -n virsh domifaddr "${FIO_VM_NAME}" --source lease 2>/dev/null |
            awk '/ipv4/ {print $4}' | cut -d/ -f1 | head -n 1)"
        if [[ -n "${address}" ]]; then
            FIO_VM_IP="${address}"
            return 0
        fi
        sleep 2
    done
    return 1
}

wait_for_fio_vm_ssh() {
    local attempt cpus
    for attempt in $(seq 1 150); do
        cpus="$(vm_exec nproc 2>/dev/null || true)"
        if [[ "${cpus}" == "${FIO_VM_VCPUS}" ]]; then
            return 0
        fi
        sleep 2
    done
    return 1
}

start_fio_vm() {
    local xml="${FIO_VM_RUN_DIR}/vm.xml"
    FIO_VM_VCPUS="${FIO_VM_VCPUS:-4}"
    FIO_VM_MEM_MIB="${FIO_VM_MEM_MIB:-8192}"
    resolve_accel || return $?
    require_fio_vm_host || return $?
    enable_host_forwarding
    ensure_fio_storage || return $?
    sweep_stale_fio_vms
    sudo -n mkdir -p "${FIO_VM_RUN_DIR}" || return 30
    sudo -n chmod 755 "${FIO_VM_RUN_DIR}" || return 30
    sudo -n qemu-img create -q -f qcow2 -F qcow2 -b "${FIO_VM_IMAGE}" "${FIO_VM_OVERLAY}" || {
        log 'ERROR: failed to create the reference VM overlay disk'
        return 40
    }
    emit_fio_vm_xml | sudo -n tee "${xml}" >/dev/null || {
        log 'ERROR: failed to render the reference VM definition'
        return 40
    }
    sudo -n virsh define "${xml}" >/dev/null || {
        log 'ERROR: libvirt rejected the reference VM definition'
        return 40
    }
    log "starting reference VM ${FIO_VM_NAME}: ${FIO_VM_VCPUS} vCPU, ${FIO_VM_MEM_MIB} MiB, accelerator=${FIO_VM_ACCEL_USED}, ${FIO_LV_COUNT} logical volume(s)"
    sudo -n virsh start "${FIO_VM_NAME}" >/dev/null || {
        log 'ERROR: reference VM failed to start'
        return 40
    }
    save_fio_vm_state
    if ! wait_for_fio_vm_address; then
        log 'ERROR: reference VM did not obtain a DHCP address'
        sudo -n virsh destroy "${FIO_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    save_fio_vm_state
    if ! wait_for_fio_vm_ssh; then
        log 'ERROR: reference VM did not become reachable over SSH'
        sudo -n virsh destroy "${FIO_VM_NAME}" >/dev/null 2>&1 || true
        return 40
    fi
    log "reference VM is ready: ${FIO_VM_NAME} at ${FIO_VM_IP} (${FIO_VM_VCPUS} vCPU)"
    verify_fio_guest_os || return $?
    save_fio_vm_state
}

verify_fio_guest_os() {
    local version
    version="$(vm_exec_shell '. /etc/os-release && printf "%s" "${VERSION_ID}"' 2>/dev/null | tr -d '\r')"
    [[ "${version}" == "24.03" ]] || {
        log "ERROR: the reference VM runs openEuler '${version:-unknown}', expected 24.03"
        return 40
    }
    log 'reference VM operating system: openEuler 24.03 LTS SP4'
}

check_fio_vm() {
    load_fio_vm_state
    [[ -n "${FIO_VM_IP:-}" ]] || {
        log 'ERROR: no reference VM state for this run'
        return 40
    }
    [[ "$(sudo -n virsh domstate "${FIO_VM_NAME}" 2>/dev/null)" == "running" ]] || {
        log "ERROR: reference VM ${FIO_VM_NAME} is not running"
        return 40
    }
    return 0
}

record_fio_vm_environment() {
    local target="${RESULTS_DIR}/vm-environment.txt"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'host_arch: %s\n' "$(uname -m)"
        printf 'accelerator: %s\n' "${FIO_VM_ACCEL_USED}"
        printf 'vm_name: %s\n' "${FIO_VM_NAME}"
        printf 'vm_ip: %s\n' "${FIO_VM_IP}"
        printf 'vm_vcpus: %s\n' "${FIO_VM_VCPUS}"
        printf 'vm_memory_mib: %s\n' "${FIO_VM_MEM_MIB}"
        printf 'workload: %s x bs=%s iodepth=%s numjobs=%s ramp=%ss runtime=%ss\n' \
            "${FIO_RW}" "${FIO_BLOCK_SIZE}" "${FIO_IODEPTH}" "${FIO_NUMJOBS}" \
            "${FIO_RAMP_TIME}" "${FIO_RUNTIME}"
        printf '\n# host storage pool\n'
        describe_fio_storage
        printf '\n# domain definition\n'
        sudo -n virsh dumpxml "${FIO_VM_NAME}" 2>/dev/null | sed 's/^/  /'
        printf '\n# guest os-release\n'
        vm_exec_shell 'cat /etc/os-release' 2>/dev/null | sed 's/^/  /'
        printf '\n# guest block devices\n'
        vm_exec_shell 'for d in /sys/block/vd*; do printf "%s size_sectors=%s rotational=%s scheduler=%s\n" "${d##*/}" "$(cat "$d/size")" "$(cat "$d/queue/rotational" 2>/dev/null)" "$(cat "$d/queue/scheduler" 2>/dev/null)"; done' 2>/dev/null | sed 's/^/  /'
        printf '\n# guest fio version\n'
        vm_exec_shell "${FIO_GUEST_BIN} --version" 2>/dev/null | sed 's/^/  /'
    } > "${target}" || {
        log 'ERROR: failed to collect the reference VM environment'
        return 40
    }
    log "captured reference VM environment evidence: ${target}"
}

install_fio_guest_packages() {
    local -a extra=()
    local attempt
    log 'installing fio inside the reference VM'
    if guest_has_network; then
        for attempt in 1 2 3; do
            case "${attempt}" in
                1) extra=() ;;
                2) extra=(--refresh) ;;
                3) extra=(--disablerepo='*update*' --setopt=strict=0) ;;
            esac
            if vm_exec timeout 420 dnf install -y --setopt=install_weak_deps=False \
                "${extra[@]}" fio procps-ng util-linux; then
                FIO_TOOLCHAIN_ATTEMPT="dnf:${attempt}"
                FIO_TOOLCHAIN_SOURCE=dnf
                export FIO_TOOLCHAIN_ATTEMPT FIO_TOOLCHAIN_SOURCE
                return 0
            fi
            log "WARNING: guest dnf installation failed (attempt ${attempt} of 3)"
            sleep 5
        done
        log 'WARNING: the guest cannot install fio through dnf; falling back to offline RPMs'
    else
        log 'the reference VM has no outbound network; installing fio from host-provided RPMs'
    fi
    install_fio_guest_offline || return 30
    FIO_TOOLCHAIN_ATTEMPT=offline
    FIO_TOOLCHAIN_SOURCE=host-rpms
    export FIO_TOOLCHAIN_ATTEMPT FIO_TOOLCHAIN_SOURCE
}

guest_has_network() {
    vm_exec_shell 'timeout 8 bash -c "cat < /dev/null > /dev/tcp/192.168.122.1/53"' >/dev/null 2>&1 || return 1
    vm_exec_shell 'for host in mirrors.openeuler.org repo.openeuler.org; do timeout 8 bash -c "cat < /dev/null > /dev/tcp/${host}/443" && exit 0; done; exit 1' >/dev/null 2>&1
}

enable_host_forwarding() {
    local current
    current="$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 0)"
    if [[ "${current}" != "1" ]]; then
        sudo -n sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 ||
            log 'WARNING: could not enable net.ipv4.ip_forward on the host'
    fi
    return 0
}

install_fio_guest_offline() {
    local bundle_dir tarball package attempt
    if ! command -v dnf >/dev/null 2>&1; then
        log 'ERROR: the host has no dnf, so the offline fio bundle cannot be built'
        return 30
    fi
    bundle_dir="${FIO_VM_IMAGE_DIR}/fio-rpms/${EXPECTED_ARCH}"
    sudo -n mkdir -p "${bundle_dir}" 2>/dev/null || mkdir -p "${bundle_dir}" 2>/dev/null || true
    if [[ ! -d "${bundle_dir}" ]]; then
        bundle_dir="${PERF_WORK_DIR}/rpms"
        mkdir -p "${bundle_dir}"
    fi
    if ! compgen -G "${bundle_dir}/*.rpm" >/dev/null; then
        log "downloading the fio RPMs on the host into ${bundle_dir}"
        for package in fio procps-ng util-linux; do
            for attempt in 1 2; do
                if sudo -n dnf download --resolve --alldeps --destdir "${bundle_dir}" "${package}" >/dev/null 2>&1; then
                    break
                fi
                log "WARNING: could not download ${package} (attempt ${attempt} of 2)"
                sleep 3
            done
        done
    fi
    compgen -G "${bundle_dir}/*.rpm" >/dev/null || {
        log 'ERROR: no fio RPM was downloaded on the host'
        return 30
    }
    tarball="${PERF_WORK_DIR}/fio-rpms-${EXPECTED_ARCH}.tar.gz"
    tar -czf "${tarball}" -C "${bundle_dir}" . || return 30
    vm_exec rm -rf /root/fio-rpms || return 30
    vm_exec mkdir -p /root/fio-rpms || return 30
    vm_copy_in "${tarball}" /root/fio-rpms.tar.gz || return 30
    vm_exec tar -xzf /root/fio-rpms.tar.gz -C /root/fio-rpms || return 30
    vm_exec_shell 'dnf install -y --disablerepo="*" --nogpgcheck /root/fio-rpms/*.rpm' || {
        log 'ERROR: the offline fio installation failed'
        return 30
    }
}

verify_guest_block_devices() {
    local device expected_sectors actual_sectors
    for device in $(fio_block_devices); do
        expected_sectors=$((FIO_LV_SIZE_GIB * 1024 * 1024 * 1024 / 512))
        actual_sectors="$(vm_exec_shell "cat /sys/block/${device}/size" 2>/dev/null | tr -d '\r')"
        [[ "${actual_sectors}" == "${expected_sectors}" ]] || {
            log "ERROR: guest device /dev/${device} reports ${actual_sectors:-missing} sectors, expected ${expected_sectors}"
            return 40
        }
    done
    return 0
}

verify_fio_version() {
    local actual
    actual="$(vm_exec_shell "${FIO_GUEST_BIN} --version" 2>/dev/null | tr -d '\r' | head -n 1)"
    FIO_ACTUAL_VERSION="${actual#fio-}"
    export FIO_ACTUAL_VERSION
    [[ "${FIO_ACTUAL_VERSION}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: requested fio ${SOFTWARE_VERSION}, the reference VM provides '${actual:-unknown}'"
        return 40
    }
}

render_fio_job_file() {
    # The [global] block below is the requested workload verbatim.  fio refuses to
    # run a job file that only has [global] ("need a job section"), so the case adds
    # the job stanza that names the target logical volumes.
    local target="${RESULTS_DIR}/${FIO_GUEST_JOB}"
    cat > "${target}" <<EOF
[global]
ioengine=libaio
direct=1
numjobs=${FIO_NUMJOBS}
thread
bs=${FIO_BLOCK_SIZE}
rw=${FIO_RW}
rwmixwrite=${FIO_RWMIXWRITE}
rwmixread=${FIO_RWMIXREAD}
iodepth=${FIO_IODEPTH}
ramp_time=${FIO_RAMP_TIME}
runtime=${FIO_RUNTIME}
time_based

[randrw_4k]
filename=$(fio_job_filename_list)
size=100%
group_reporting
EOF
    printf '%s\n' "${target}"
}

push_fio_job_to_guest() {
    local job="${RESULTS_DIR}/${FIO_GUEST_JOB}"
    [[ -f "${job}" ]] || {
        log "ERROR: the fio job file ${job} was not rendered"
        return 40
    }
    vm_exec "mkdir -p '${FIO_GUEST_DIR}'" || return 40
    vm_copy_in "${job}" "${FIO_GUEST_DIR}/${FIO_GUEST_JOB}" || return 40
    vm_exec "test -s '${FIO_GUEST_DIR}/${FIO_GUEST_JOB}'" || {
        log 'ERROR: the fio job file is missing inside the reference VM'
        return 40
    }
}

capture_fio_format_info() {
    local target="${RESULTS_DIR}/format-info.txt"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'job_file: %s\n' "${FIO_GUEST_DIR}/${FIO_GUEST_JOB}"
        printf 'command: taskset -c 0 fio %s\n' "${FIO_GUEST_JOB}"
        printf 'fio_version: %s\n' "${FIO_ACTUAL_VERSION:-unknown}"
        printf 'numjobs: %s\niodepth: %s\nblock_size: %s\nrw: %s\n' \
            "${FIO_NUMJOBS}" "${FIO_IODEPTH}" "${FIO_BLOCK_SIZE}" "${FIO_RW}"
        printf 'ramp_time_seconds: %s\nruntime_seconds: %s\n' "${FIO_RAMP_TIME}" "${FIO_RUNTIME}"
        printf '\n# guest job file\n'
        vm_exec_shell "cat '${FIO_GUEST_DIR}/${FIO_GUEST_JOB}'" 2>/dev/null | sed 's/^/  /'
        printf '\n# guest block devices used by this run\n'
        local device
        for device in $(fio_block_devices); do
            printf '  /dev/%s sectors=%s scheduler=%s\n' "${device}" \
                "$(vm_exec_shell "cat /sys/block/${device}/size" 2>/dev/null | tr -d '\r')" \
                "$(vm_exec_shell "cat /sys/block/${device}/queue/scheduler" 2>/dev/null | tr -d '\r')"
        done
    } > "${target}" || {
        log 'ERROR: failed to record the fio workload layout'
        return 40
    }
}

stop_fio_vm() {
    load_fio_vm_state
    if [[ -n "${FIO_VM_NAME:-}" ]] &&
        sudo -n virsh domstate "${FIO_VM_NAME}" >/dev/null 2>&1; then
        sudo -n virsh destroy "${FIO_VM_NAME}" >/dev/null 2>&1 || true
        sudo -n virsh undefine "${FIO_VM_NAME}" --nvram >/dev/null 2>&1 ||
            sudo -n virsh undefine "${FIO_VM_NAME}" >/dev/null 2>&1 || true
        log "reference VM ${FIO_VM_NAME} stopped and removed"
    fi
    if [[ -n "${FIO_VM_RUN_DIR:-}" && -d "${FIO_VM_RUN_DIR}" ]]; then
        sudo -n rm -rf "${FIO_VM_RUN_DIR}" 2>/dev/null || true
    fi
    # The logical volumes are the host-provided data pool: they are kept for the
    # next run (that is what "pre-seeded once on the host" means), only the
    # transient domain and its overlay are removed here.
    log 'managed fio reference VM stopped'
}

# --- standalone runner helpers ----------------------------------------------

initialize_runtime() {
    configure_runtime_paths
}

normalize_arch() {
    case "${1:-}" in
        amd64 | x86_64) printf 'x86_64' ;;
        arm64 | aarch64) printf 'aarch64' ;;
        *) printf '%s' "${1:-}" ;;
    esac
}
