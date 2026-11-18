#!/usr/bin/env bash
# Prepare a performance Runner as a KVM host for the UnixBench reference VM.
# Run once per Runner as root: sudo bash software/Others/unixbench/scripts/host/prepare-vm-host.sh
set -euo pipefail

IMAGE_DIR="${UNIXBENCH_VM_IMAGE_DIR:-/home/libvirt-images}"
KEY_DIR="${UNIXBENCH_VM_KEY_DIR:-/home/runner/software/unixbench/vm}"
KEY="${KEY_DIR}/id_ed25519"
PUBKEY="${KEY_DIR}/id_ed25519.pub"
NBD_DEVICE="${UNIXBENCH_VM_NBD:-/dev/nbd0}"
MOUNT_DIR="${UNIXBENCH_VM_MOUNT:-/mnt/boostkit-unixbench-golden}"
SP4_BASE="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/virtual_machine_img"
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64) SP4_ARCH="x86_64" ;;
    aarch64) SP4_ARCH="aarch64" ;;
    *) echo "unsupported architecture: ${ARCH}" >&2; exit 1 ;;
esac
GOLDEN="${IMAGE_DIR}/boostkit-unixbench-golden-${ARCH}.qcow2"
MARKER="${IMAGE_DIR}/.boostkit-unixbench-golden-${ARCH}.prepared"

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
    qemu-img virt-install xorriso || true
if [[ ! -x /usr/libexec/qemu-kvm ]]; then
    dnf install -y --setopt=install_weak_deps=False qemu-kvm
fi
[[ -x /usr/libexec/qemu-kvm ]] || { echo 'qemu-kvm binary is missing' >&2; exit 1; }
[[ -c /dev/kvm ]] || { echo '/dev/kvm is missing (enable VT-x/AMD-V or KVM in BIOS)' >&2; exit 1; }

log 'starting libvirt'
systemctl enable libvirtd >/dev/null 2>&1 || systemctl enable virtqemud >/dev/null 2>&1 || true
systemctl start libvirtd >/dev/null 2>&1 || systemctl start virtqemud >/dev/null 2>&1 || true
virsh version >/dev/null 2>&1 || {
    echo 'libvirt is not reachable through virsh' >&2; exit 1
}
virsh net-info default >/dev/null 2>&1 || { echo 'libvirt default network is missing' >&2; exit 1; }
virsh net-list --name | grep -qx default || virsh net-start default
virsh net-autostart default >/dev/null

mkdir -p "${IMAGE_DIR}"
if [[ ! -f "${GOLDEN}" ]]; then
    archive="${IMAGE_DIR}/openEuler-24.03-LTS-SP4-${SP4_ARCH}.qcow2.xz"
    url="${SP4_BASE}/${SP4_ARCH}/openEuler-24.03-LTS-SP4-${SP4_ARCH}.qcow2.xz"
    log "downloading ${url}"
    curl -fL --retry 3 --connect-timeout 30 -o "${archive}" "${url}"
    curl -fsSL --retry 3 -o "${archive}.sha256sum" "${url}.sha256sum"
    (cd "${IMAGE_DIR}" && sha256sum -c "$(basename "${archive}.sha256sum")")
    log 'decompressing golden image'
    xz -dkf "${archive}"
    mv "${IMAGE_DIR}/openEuler-24.03-LTS-SP4-${SP4_ARCH}.qcow2" "${GOLDEN}"
else
    log "reusing golden image ${GOLDEN}"
fi

log 'creating Runner SSH key'
mkdir -p "${KEY_DIR}"
chown -R runner:runner "$(dirname "${KEY_DIR}")"
if [[ ! -f "${KEY}" ]]; then
    su - runner -c "ssh-keygen -q -t ed25519 -N '' -f '${KEY}'"
fi
chmod 600 "${KEY}"
chmod 644 "${PUBKEY}"

if [[ -f "${MARKER}" ]] && cmp -s "${MARKER}" "${PUBKEY}"; then
    log 'golden image already injected with the current key; nothing to do'
    exit 0
fi

log 'injecting SSH key and guest settings via qemu-nbd'
modprobe nbd max_part=8
qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null 2>&1 || true
qemu-nbd -c "${NBD_DEVICE}" -f qcow2 "${GOLDEN}"
sleep 2
root_part="$(lsblk -ln -o NAME,FSTYPE "${NBD_DEVICE}" | awk '$2 == "ext4" {print $1; exit}')"
[[ -n "${root_part}" ]] || { echo 'ext4 root partition not found in golden image' >&2; exit 1; }
mkdir -p "${MOUNT_DIR}"
mount "/dev/${root_part}" "${MOUNT_DIR}"
root="${MOUNT_DIR}"
install -d -m 700 "${root}/root/.ssh"
cp "${PUBKEY}" "${root}/root/.ssh/authorized_keys"
chmod 600 "${root}/root/.ssh/authorized_keys"
mkdir -p "${root}/etc/ssh/sshd_config.d"
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\nUseDNS no\n' \
    > "${root}/etc/ssh/sshd_config.d/99-boostkit.conf"
echo unixbench-vm > "${root}/etc/hostname"
rm -f "${root}/etc/NetworkManager/no-auto-default.state"
if [[ -f "${root}/etc/selinux/config" ]]; then
    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' "${root}/etc/selinux/config"
fi
sync
umount "${MOUNT_DIR}"
qemu-nbd --disconnect "${NBD_DEVICE}" >/dev/null
cp "${PUBKEY}" "${MARKER}"
log "golden image is ready: ${GOLDEN}"
