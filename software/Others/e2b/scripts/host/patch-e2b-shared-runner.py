#!/usr/bin/env python3
"""Make the official E2B ``build.sh`` / ``deploy.sh`` safe on a shared runner.

The one-click installer in ``e2b-infra`` assumes it owns the machine: it replaces
the Docker binaries with its own tarball, restarts ``dockerd`` twice and flushes
the host ``iptables`` ruleset.  On the performance runner that would kill every
container other work left behind (a two-week-old debug container survives there)
and drop the host firewall rules.  Five rewrites of ``build.sh`` and one of
``deploy.sh`` make the flow runnable without those side effects:

``build.sh``
1. ``install_docker``  -> keep the Docker that is already installed (only the
   compose binary is refreshed); replacing ``/usr/bin/dockerd`` under a live
   daemon is pointless and destructive.
2. ``setenforce 0``    -> only touch SELinux when it is actually enforcing.
3. ``systemctl restart docker`` -> ``systemctl reload docker`` (``dockerd``
   live-reloads ``insecure-registries`` on SIGHUP, so the Harbor push works
   without restarting any container).
4. ``iptables -F``     -> only the rules of veth devices that no longer exist are
   deleted (a full flush would drop every other workload's rules, but doing
   nothing let >8k per-sandbox redirects pile up across restarts).
5. before "创建项目" -> wait for Harbor's health endpoint.  Harbor needs ~50 s
   on first boot and the unguarded POST races it, which surfaces later as
   ``unauthorized: project e2b-orchestration not found`` on ``docker push``.

``deploy.sh``
6. ``seed-db`` asks for the admin e-mail on stdin; feed it so the flow works
   without a TTY.  Without this patch the run blocks on ``Email:`` forever and
   ``/root/.e2b/config.json`` keeps a placeholder team key, which makes every
   later ``/templates`` and ``/sandboxes`` call answer 401.

The shipped RPM also contains a Docker Hub helper-image pull loop; when that
anchor is present it is skipped (the tags are pre-staged from the mirror), and a
missing anchor is only a warning because the packaged deploy.sh already ships
the redis image locally.

Every rewrite is asserted and idempotent: a second run is a no-op instead of
corrupting the file.
"""
from __future__ import annotations

import argparse
import sys

SKIP_DOCKER_OLD = '''function install_docker() {
    info "开始安装 Docker..."
'''

SKIP_DOCKER_NEW = '''function install_docker() {
    # patched-for-shared-runner: 保留宿主既有 Docker，只刷新 compose
    if docker --version >/dev/null 2>&1; then
        local compose_file="docker-compose-linux-aarch64"
        [ "$ARCH" = "x86_64" ] && compose_file="docker-compose-linux-x86_64"
        if [ -f "$DEP_DIR/$compose_file" ]; then
            cp -f "$DEP_DIR/$compose_file" /usr/local/bin/docker-compose || true
            chmod +x /usr/local/bin/docker-compose || true
        fi
        info "docker 已就绪：共享 runner 不替换宿主 docker 二进制"
        pull_docker_images
        return 0
    fi
    info "开始安装 Docker..."
'''

SELINUX_OLD = "    setenforce 0\n"
SELINUX_NEW = (
    "    # patched-for-shared-runner: 仅在 enforcing 时临时关闭\n"
    '    if command -v setenforce >/dev/null 2>&1 && [ "$(getenforce 2>/dev/null)" != "Disabled" ]; then setenforce 0; fi\n'
)

IPTABLES_OLD = "    iptables -F\n"
# A full flush would drop the rules of every other workload on the runner, but
# doing nothing lets >8k per-veth redirects pile up across restarts. Delete only
# the rules whose `veth-<n>` device is already gone; that is a no-op right after
# a healthy start and reclaims everything after a stop.
IPTABLES_NEW = (
    "    # patched-for-shared-runner: 不清空宿主 iptables，只清理已消失 veth 的规则\n"
    '    if [ -x "${E2B_DIR:-/opt/e2b-infra}/cleanup-e2b-network.sh" ]; then\n'
    '        bash "${E2B_DIR:-/opt/e2b-infra}/cleanup-e2b-network.sh" --rules-only || true\n'
    "    fi\n"
)
# Installs created before the targeted cleanup existed carry this no-op line.
LEGACY_IPTABLES_NEW = "    # patched-for-shared-runner: 不清空宿主 iptables，规则由安装流程逐条添加\n"

PROJECT_OLD = '    info "创建项目"\n'

PROJECT_NEW = '''    info "等待 Harbor 就绪..."
    # patched-for-shared-runner: Harbor 首次启动约 50 秒，先等健康检查再建项目，
    # 否则 docker push 会报 "project e2b-orchestration not found"。
    for _harbor_try in $(seq 1 60); do
        if [ "$(curl -sS -m 5 -o /dev/null -w '%{http_code}' -k "http://localhost:$HARBOR_PORT/api/v2.0/health" 2>/dev/null)" = "200" ]; then
            info "Harbor 已就绪（第 ${_harbor_try} 次探测）"
            break
        fi
        sleep 3
    done
    info "创建项目"
'''

DEPLOY_SEED_OLD = "  POSTGRES_CONNECTION_STRING=$POSTGRES_CONNECTION_STRING ./bin/seed-db | tee user.txt\n"

DEPLOY_SEED_NEW = (
    "  # patched-for-shared-runner: seed-db 交互式读取邮箱，非交互环境下用 stdin 喂入\n"
    "  printf 'admin@e2b.dev\\nE2B\\n' | POSTGRES_CONNECTION_STRING=$POSTGRES_CONNECTION_STRING ./bin/seed-db | tee user.txt\n"
)

DEPLOY_PULL_OLD = '''  echo "======  $src  ->  $tag  ======"
  docker pull "$src"
'''

DEPLOY_PULL_NEW = '''  echo "======  $src  ->  $tag  ======"
  # patched-for-shared-runner: 镜像已从国内镜像站预置，跳过 Docker Hub 拉取
  if docker image inspect "$src" >/dev/null 2>&1; then
    echo "[skip pull] $src 已在本地"
  else
    docker pull "$src"
  fi
'''


def _read(path: str) -> str:
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def _write(path: str, text: str) -> None:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)


def _sub(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        print("[skip] %s: already patched" % label)
        return text
    if old not in text:
        raise SystemExit("[FAIL] %s: anchor not found" % label)
    print("[ok  ] %s" % label)
    return text.replace(old, new, 1)


def patch_build(path: str) -> int:
    text = _read(path)
    try:
        text = _sub(text, SKIP_DOCKER_OLD, SKIP_DOCKER_NEW, "install_docker: keep the host Docker")
        text = _sub(text, SELINUX_OLD, SELINUX_NEW, "setenforce: guarded")
        if "systemctl reload docker || true" not in text:
            count = text.count("systemctl restart docker")
            text = text.replace("systemctl restart docker", "systemctl reload docker || true")
            print("[ok  ] docker restart -> reload (%d site(s))" % count)
        else:
            print("[skip] docker restart -> reload: already patched")
        if LEGACY_IPTABLES_NEW in text and IPTABLES_NEW not in text:
            text = text.replace(LEGACY_IPTABLES_NEW, IPTABLES_NEW, 1)
            print("[ok  ] iptables -F: upgraded to the targeted veth cleanup")
        else:
            text = _sub(text, IPTABLES_OLD, IPTABLES_NEW, "iptables -F: targeted cleanup")
        text = _sub(text, PROJECT_OLD, PROJECT_NEW, "harbor project: wait for health first")
    except SystemExit as exc:
        print(exc)
        return 3
    _write(path, text)
    print("[done] patched %s" % path)
    return 0


def patch_deploy(path: str) -> int:
    text = _read(path)
    try:
        text = _sub(text, DEPLOY_SEED_OLD, DEPLOY_SEED_NEW, "seed-db: feed the admin e-mail on stdin")
    except SystemExit as exc:
        print(exc)
        return 3
    try:
        text = _sub(text, DEPLOY_PULL_OLD, DEPLOY_PULL_NEW, "helper images: skip the Docker Hub pull")
    except SystemExit as exc:
        print(exc)
        print("[warn] helper-image pull anchor absent; the shipped deploy.sh only uses the local redis image")
    _write(path, text)
    print("[done] patched %s" % path)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-sh", default="/opt/e2b-infra/build.sh")
    parser.add_argument("--deploy-sh", default="/opt/e2b-infra/deploy.sh")
    args = parser.parse_args()
    rc = patch_build(args.build_sh)
    if rc != 0:
        return rc
    if args.deploy_sh:
        return patch_deploy(args.deploy_sh)
    return 0


if __name__ == "__main__":
    sys.exit(main())
