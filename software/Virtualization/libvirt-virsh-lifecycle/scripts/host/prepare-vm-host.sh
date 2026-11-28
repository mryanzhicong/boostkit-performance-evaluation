#!/usr/bin/env bash
# Prepare a performance Runner as a KVM host for the libvirt lifecycle reference VM.
# Run once per Runner as root:
#   sudo bash software/Virtualization/libvirt-virsh-lifecycle/scripts/host/prepare-vm-host.sh
set -euo pipefail

IMAGE_DIR="${LIBVIRT_VM_IMAGE_DIR:-/home/libvirt-images}"
KEY_DIR="${LIBVIRT_VM_KEY_DIR:-/home/runner/software/libvirt/vm}"
KEY="${KEY_DIR}/id_ed25519"
PUBKEY="${KEY_DIR}/id_ed25519.pub"
NBD_DEVICE="${LIBVIRT_VM_NBD:-/dev/nbd0}"
MOUNT_DIR="${LIBVIRT_VM_MOUNT:-/mnt/boostkit-libvirt-2203-golden}"
OS_RELEASE="${LIBVIRT_GUEST_OS:-22.03-LTS-SP3}"
OS_BASE="https://repo.openeuler.org/openEuler-${OS_RELEASE}/virtual_machine_img"
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64|aarch64) ;;
    *) echo "unsupported architecture: ${ARCH}" >&2; exit 1 ;;
esac
GOLDEN="${IMAGE_DIR}/boostkit-libvirt-2203-golden-${ARCH}.qcow2"
MARKER="${IMAGE_DIR}/.boostkit-libvirt-2203-golden-${ARCH}.prepared"

log() { printf '[prepare-vm-host] %s\n' "$*"; }

cleanup_mount() {
    set +e
    mountpoint -q "${MOUNT_DIR}" && umount "${MOUNT_DIR}"
    qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1
    rmdir "${MOUNT_DIR}" >/dev/null 2>&1
}
trap cleanup_mount EXIT

[[ "$(id -u)" -eq 0 ]] || { echo 'must run as root' >&2; exit 1; }

log 'installing libvirt and QEMU packages'
dnf install -y --setopt=install_weak_deps=False \
    libvirt libvirt-client libvirt-daemon libvirt-daemon-driver-qemu \
    qemu-img qemu-kvm virt-install xorriso || true
for package in parted util-linux lvm2; do
    dnf install -y --setopt=install_weak_deps=False "${package}" >/dev/null 2>&1 || true
done
if [[ ! -x /usr/libexec/qemu-kvm ]]; then
    log 'WARNING: /usr/libexec/qemu-kvm is missing; the case will use /usr/bin/qemu-system-*'
fi

log 'starting libvirt'
systemctl enable libvirtd >/dev/null 2>&1 || systemctl enable virtqemud >/dev/null 2>&1 || true
systemctl start libvirtd >/dev/null 2>&1 || systemctl start virtqemud >/dev/null 2>&1 || true
if ! virsh version >/dev/null 2>&1; then
    log 'systemd is unavailable; starting libvirtd directly'
    /usr/sbin/libvirtd --daemon >/dev/null 2>&1 || /usr/sbin/virtqemud --daemon >/dev/null 2>&1 || true
    sleep 3
fi
virsh version >/dev/null 2>&1 || { echo 'libvirt is not reachable through virsh' >&2; exit 1; }
virsh net-info default >/dev/null 2>&1 || { echo 'libvirt default network is missing' >&2; exit 1; }
virsh net-list --name | grep -qx default || virsh net-start default
virsh net-autostart default >/dev/null

log 'enabling IPv4 forwarding for the libvirt NAT network'
if [[ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]]; then
    sysctl -w net.ipv4.ip_forward=1 >/dev/null
    printf 'net.ipv4.ip_forward = 1\n' > /etc/sysctl.d/99-boostkit-qemu-vm.conf
    log 'net.ipv4.ip_forward was 0; enabled it and persisted it to /etc/sysctl.d/99-boostkit-qemu-vm.conf'
fi

mkdir -p "${IMAGE_DIR}"
if [[ ! -f "${GOLDEN}" ]]; then
    archive="${IMAGE_DIR}/openEuler-${OS_RELEASE}-${ARCH}.qcow2.xz"
    url="${OS_BASE}/${ARCH}/openEuler-${OS_RELEASE}-${ARCH}.qcow2.xz"
    if [[ ! -f "${archive}" ]]; then
        log "downloading ${url}"
        curl -fL --retry 3 --connect-timeout 30 -o "${archive}.part" "${url}"
        mv "${archive}.part" "${archive}"
        curl -fsSL --retry 3 -o "${archive}.sha256sum" "${url}.sha256sum" || true
        if [[ -s "${archive}.sha256sum" ]]; then
            (cd "${IMAGE_DIR}" && sha256sum -c "$(basename "${archive}.sha256sum")")
        fi
    fi
    log 'decompressing the golden image'
    xz -dkf "${archive}"
    mv "${IMAGE_DIR}/openEuler-${OS_RELEASE}-${ARCH}.qcow2" "${GOLDEN}"
else
    log "reusing golden image ${GOLDEN}"
fi

log 'creating the Runner SSH key for the reference VMs'
mkdir -p "${KEY_DIR}"
if [[ ! -f "${KEY}" ]]; then
    ssh-keygen -q -t ed25519 -N '' -f "${KEY}"
fi
chmod 600 "${KEY}"
chmod 644 "${PUBKEY}"
if id runner >/dev/null 2>&1; then
    chown -R runner:runner "${KEY_DIR}"
fi

if [[ -f "${MARKER}" ]] && cmp -s "${MARKER}" "${PUBKEY}"; then
    log 'golden image already carries the current key; nothing to do'
    exit 0
fi

inject_with_nbd() {
    modprobe nbd max_part=8 2>/dev/null || true
    [[ -b "${NBD_DEVICE}" ]] || return 1
    qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1 || true
    qemu-nbd -c "${NBD_DEVICE}" -f qcow2 "${GOLDEN}" || return 1
    sleep 2
    root_part="$(lsblk -ln -o NAME,FSTYPE "${NBD_DEVICE}" | awk '$2 == "ext4" {print $1; exit}')"
    [[ -n "${root_part}" ]] || { qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1; return 1; }
    mkdir -p "${MOUNT_DIR}"
    mount "/dev/${root_part}" "${MOUNT_DIR}" || { qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1; return 1; }
    ROOT_MOUNT="${MOUNT_DIR}"
}

inject_with_loop() {
    local raw="${IMAGE_DIR}/.libvirt-golden-inject.raw" offset sector
    qemu-img convert -O raw "${GOLDEN}" "${raw}" || return 1
    sector="$(parted -s "${raw}" unit s print 2>/dev/null | awk '/ext4/ {gsub(/s/,"",$3); print $2}')"
    [[ -n "${sector}" ]] || { rm -f "${raw}"; return 1; }
    offset=$((sector * 512))
    mkdir -p "${MOUNT_DIR}"
    mount -o loop,offset="${offset}" "${raw}" "${MOUNT_DIR}" || { rm -f "${raw}"; return 1; }
    ROOT_MOUNT="${MOUNT_DIR}"
    CONVERT_BACK_RAW="${raw}"
}

log 'injecting the SSH key and guest settings into the golden image'
ROOT_MOUNT=""
CONVERT_BACK_RAW=""
if ! inject_with_nbd; then
    log 'nbd is unavailable; falling back to a loop mounted raw conversion'
    inject_with_loop || { echo 'could not mount the golden image for key injection' >&2; exit 1; }
fi

install -d -m 700 "${ROOT_MOUNT}/root/.ssh"
cp "${PUBKEY}" "${ROOT_MOUNT}/root/.ssh/authorized_keys"
chmod 600 "${ROOT_MOUNT}/root/.ssh/authorized_keys"
mkdir -p "${ROOT_MOUNT}/etc/ssh/sshd_config.d"
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\nUseDNS no\n' \
    > "${ROOT_MOUNT}/etc/ssh/sshd_config.d/99-boostkit.conf"
echo libvirt-2203-vm > "${ROOT_MOUNT}/etc/hostname"
rm -f "${ROOT_MOUNT}/etc/NetworkManager/no-auto-default.state"
if [[ -f "${ROOT_MOUNT}/etc/selinux/config" ]]; then
    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' "${ROOT_MOUNT}/etc/selinux/config"
fi
sync
umount "${ROOT_MOUNT}"
mountpoint -q "${MOUNT_DIR}" && umount "${MOUNT_DIR}"
qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1 || true
if [[ -n "${CONVERT_BACK_RAW}" ]]; then
    qemu-img convert -O qcow2 "${CONVERT_BACK_RAW}" "${GOLDEN}"
    rm -f "${CONVERT_BACK_RAW}"
fi
cp "${PUBKEY}" "${MARKER}"
log "golden image is ready: ${GOLDEN}"
