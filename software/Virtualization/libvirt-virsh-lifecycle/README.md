# libvirt-virsh-lifecycle 22.03-LTS-SP3 性能测试

本用例验证并度量 libvirt 的虚拟机生命周期控制面：在 openEuler 24.03 LTS SP4 宿主机上使用 libvirt/QEMU
创建一台 openEuler 22.03 LTS SP3 参考虚拟机（规格 4 vCPU / 8 GiB，vCPU 连续绑核、内存绑定到同一 NUMA 节点），
然后重复执行 `virsh start` → `virsh list` → `virsh console` → `virsh shutdown` 流程，用「虚机 running」和
「能正常进入虚机」两个测试点是否成立，以及 `virsh start`/`virsh console` 的耗时作为 libvirt 的性能指标。
**本用例不使用容器**：被测对象是宿主机的 libvirt 控制面与 KVM 虚机启动链路，容器内无法验证 `virsh` 与 guest
串口登录，因此整条链路直接在宿主机与虚拟机内执行（宿主直跑）。

支持 `aarch64` 与 `x86_64`，两架构使用同一参数矩阵。与整机直跑相比，本用例的被测命令（`virsh`）仍在宿主机
运行，只是多了 guest 启动这一段；不设 CPU/内存配额，绑核与内存绑定由虚机 XML 显式指定。
Framework 六阶段（build/start/test/stop）与独立入口
`libvirt_virsh_lifecycle_test.sh` 调用同一批阶段函数。用例提供 `base` 与 `optimized` 两个变体入口：
`optimized` 位于 `scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测环境 | libvirt 9.10.0 + QEMU（宿主机发行版自带，`virsh --version` 记录实际值） | 宿主机 `/usr/bin/virsh`、`/usr/libexec/qemu-kvm` |
| guest 操作系统 | openEuler 22.03 LTS SP3 虚拟机镜像（`repo.openeuler.org/openEuler-22.03-LTS-SP3/virtual_machine_img/`，392925408 字节），SHA-256 校验后解压 | 公共目录 `/home/libvirt-images/openEuler-22.03-LTS-SP3-<arch>.qcow2.xz`；golden 镜像 `boostkit-libvirt-2203-golden-<arch>.qcow2` |
| 测试工具 | `virsh`（libvirt-client，随宿主机 libvirt 版本） | 宿主机 `/usr/bin/virsh` |
| 校验手段 | guest 内 `cat /etc/os-release`（必须为 `VERSION_ID="22.03"`）、`nproc`（必须为 4） | guest 内执行，宿主机侧只读 |

## libvirt 获取、部署与虚拟机启动

宿主机准备只需执行一次。以下为实际命令形态，`${ARCH}` 取 `uname -m`（`aarch64` / `x86_64`），
`${PERF_WORK_DIR}` 由 Framework 注入（独立运行时默认
`/home/runner/boostkit-perf/libvirt-virsh-lifecycle/local-<run-id>`）。

1. 安装并启动 libvirt，打开 NAT 网络的 IPv4 转发（宿主机只装虚拟化最小依赖）：

```bash
sudo dnf install -y libvirt libvirt-client libvirt-daemon libvirt-daemon-driver-qemu qemu-img qemu-kvm xorriso
sudo systemctl enable --now libvirtd
sudo virsh net-start default && sudo virsh net-autostart default
sudo sysctl -w net.ipv4.ip_forward=1
```

2. 下载 openEuler 22.03 LTS SP3 虚拟机镜像，按 SHA-256 校验后解压为 golden 镜像：

```bash
curl -fL -o /home/libvirt-images/openEuler-22.03-LTS-SP3-${ARCH}.qcow2.xz \
  https://repo.openeuler.org/openEuler-22.03-LTS-SP3/virtual_machine_img/${ARCH}/openEuler-22.03-LTS-SP3-${ARCH}.qcow2.xz
(cd /home/libvirt-images && sha256sum -c openEuler-22.03-LTS-SP3-${ARCH}.qcow2.xz.sha256sum)
xz -dkf /home/libvirt-images/openEuler-22.03-LTS-SP3-${ARCH}.qcow2.xz
mv /home/libvirt-images/openEuler-22.03-LTS-SP3-${ARCH}.qcow2 \
   /home/libvirt-images/boostkit-libvirt-2203-golden-${ARCH}.qcow2
```

3. 生成 guest 登录密钥并注入 golden 镜像（`/root/.ssh/authorized_keys`），同时写入
`PermitRootLogin prohibit-password`、关闭 SELinux enforcing：

```bash
ssh-keygen -q -t ed25519 -N '' -f /home/runner/software/libvirt/vm/id_ed25519
sudo modprobe nbd max_part=8
sudo qemu-nbd -c /dev/nbd0 -f qcow2 /home/libvirt-images/boostkit-libvirt-2203-golden-${ARCH}.qcow2
sudo mount /dev/nbd0p2 /mnt/boostkit-libvirt-2203-golden
sudo install -d -m 700 /mnt/boostkit-libvirt-2203-golden/root/.ssh
sudo cp /home/runner/software/libvirt/vm/id_ed25519.pub \
    /mnt/boostkit-libvirt-2203-golden/root/.ssh/authorized_keys
sudo umount /mnt/boostkit-libvirt-2203-golden && sudo qemu-nbd --disconnect /dev/nbd0
```

4. 定义参考虚拟机（只 define，不 start）：4 vCPU 绑到同一 NUMA 节点内连续的 4 个物理核、内存 `numatune`
严格绑定该节点，磁盘为 golden 镜像的 qcow2 叠加盘（`cache=none`、`io=native`）。QEMU 以 `qemu`
用户运行，而 `/home/runner` 为 `700`，叠加盘、NVRAM 与串口日志因此落在镜像根目录下的一级目录
（`/home/libvirt-images/boostkit-libvirt-vm-runs/${PERF_RUN_ID}/vm0/`），域 XML 与地址文件仍写在
`${PERF_WORK_DIR}/vm/vm0/`：

```bash
sudo mkdir -p /home/libvirt-images/boostkit-libvirt-vm-runs/${PERF_RUN_ID}/vm0
sudo qemu-img create -q -f qcow2 -F qcow2 -b /home/libvirt-images/boostkit-libvirt-2203-golden-${ARCH}.qcow2 \
  /home/libvirt-images/boostkit-libvirt-vm-runs/${PERF_RUN_ID}/vm0/system.qcow2
sudo chmod 644 /home/libvirt-images/boostkit-libvirt-vm-runs/${PERF_RUN_ID}/vm0/system.qcow2
sudo virsh define ${PERF_WORK_DIR}/vm/vm0/vm.xml
sudo virsh dominfo boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0   # State: shut off
```

5. 首次启动校验 guest 系统版本与 vCPU 数，然后关机并把虚机留在 `shut off` 状态供测量轮次使用。
`virsh console` 需要控制终端，因此测量时用 `script -qec` 包一层伪终端，并按下回车等 guest 打印
`login:` 提示（`util-linux` 提供 `script`）：

```bash
sudo virsh start boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> 'cat /etc/os-release; nproc'   # 22.03 / 4
printf '\n' | script -qec "sudo virsh console boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0 --force" /dev/null
sudo virsh shutdown boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0
```

- **脚本出处**：`scripts/host/prepare-vm-host.sh`、`scripts/common.sh`

## 数据与运行顺序

两架构使用同一矩阵，虚拟机数量固定为 1 台（即「核数/4」在最小可用规模下的取值，本用例不随核数扩展）。

| 参数 | 取值 | 说明 |
|---|---|---|
| 虚拟机数量 | 1 | 每轮次重新定义并从未启动状态开始 |
| 单机规格 | 4 vCPU / 8192 MiB | vCPU 连续绑核，内存同 NUMA 节点严格绑定 |
| 轮次 | 6 轮（1 轮预热 + 5 轮有效采样） | 每轮都完整走一遍生命周期 |
| 单轮超时 | `virsh start` 等待 180 s，`console` 探测 30 s | 超时即该轮失败 |
| 预计耗时 | 约 15 ~ 25 分钟 | job 超时 = `timeout_minutes` 60 + 30 |

1. build 阶段：检查宿主前置条件（`virsh`、`qemu-img`、golden 镜像、私钥、`sudo -n virsh`），清理同前缀残留域，
   按拓扑规划并 define 虚机；启动一次校验 guest 为 openEuler 22.03 且 `nproc == 4`，随后关机保持 `shut off`
   并落 `build_variant.json` 与 `actual-version.txt`：

```bash
lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE | grep -v '^#'                     # 连续绑核分组
sudo virsh list --all --name | grep '^boostkit-libvirt-lifecycle-'       # 清理同前缀残留
sudo virsh dominfo boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0   # 必须为 shut off
```

2. start 阶段：复查 libvirt 可达、虚机已定义且处于 `shut off`，记录 libvirt 版本：

```bash
sudo virsh version
sudo virsh dominfo boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0
```

3. test 阶段：对每一轮依次执行下列命令（`start`/`console` 用 `date +%s%N` 前后取差计时），
   单轮结果写 `reps/rep<轮>.json`，`console` 捕获写 `reps/rep<轮>-console.log`：

```bash
sudo virsh start boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0
sudo virsh list | grep boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0    # 测试点 A：running
( printf '\n'; sleep 30 ) | sudo virsh console boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0 --force \
  > ${RESULTS_DIR}/reps/rep1-console.log                                       # 测试点 B：出现 login: 提示
sudo virsh shutdown boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0        # 回到 shut off 后 undefine
python3 scripts/results/parse_benchmark.py ${RESULTS_DIR} ${RESULTS_DIR}/benchmark_virsh_lifecycle.json
```

4. 采样与聚合规则：预热轮不计入；有效轮次各指标取中位数；任一有效轮次的测试点失败都会让整例失败。

5. stop 阶段：销毁并 undefine 全部域，删除私有工作目录，确保不残留：

```bash
sudo virsh destroy boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0    # 仍在 running 时先关机
sudo virsh undefine boostkit-libvirt-lifecycle-${ARCH}-${PERF_RUN_ID}-0 --nvram
sudo rm -rf ${PERF_WORK_DIR}/vm
```

失败时保留 `${RESULTS_DIR}/reps/` 全部轮次证据与 `console` 日志用于定位，虚机按域名前缀清理。

- **脚本出处**：`scripts/builders/base.sh`、`scripts/stages/start.sh`、`scripts/stages/test.sh`、`scripts/stages/stop.sh`

## 指标与产物

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `libvirt.virsh_start_ok` | 测试点 A1：每轮 `virsh start` 是否让域进入 running（全轮次通过才为 1） | bool | 越大越好 |
| `libvirt.virsh_list_running_ok` | 测试点 A2：每轮 `virsh list` 是否把域列为 running | bool | 越大越好 |
| `libvirt.virsh_console_ok` | 测试点 B：每轮 `virsh console` 是否出现 guest 登录提示 | bool | 越大越好 |
| `libvirt.virsh_start_ms` | `virsh start` 起至 `virsh domstate` 报告 running 的墙钟耗时（有效轮次中位数） | ms | 越小越好 |
| `libvirt.virsh_console_probe_ms` | `virsh console` 起至捕获到登录提示的墙钟耗时（中位数） | ms | 越小越好 |
| `libvirt.guest_boot_observed_seconds` | `virsh start` 起至 `virsh domifaddr --source lease` 拿到地址的耗时（中位数） | s | 越小越好 |
| `libvirt.measured_reps` | 计入统计的有效轮次 | repetition | 中性 |
| `libvirt.vcpus_per_vm` | 单机 vCPU 数 | vcpu | 中性 |
| `libvirt.memory_gib_per_vm` | 单机内存 | GiB | 中性 |

指标总数：**9 项**（3 项测试点 + 3 项耗时 + 3 项采样与拓扑）。分组规则：测试点与耗时归入 `virsh lifecycle`，
采样轮次归入 `sampling`，规格归入 `topology`；单位与方向与 `case.yaml` 的 `metrics.collection` 一一对应。

产物清单：

| 产物 | 内容 |
|---|---|
| `benchmark_virsh_lifecycle.json` | 解析后的 9 项指标，由 `metrics.source` 消费 |
| `reps/rep<轮>.json` | 单轮证据：三项测试点布尔值、`virsh start`/`console` 耗时、观测到的启动秒数、状态 |
| `reps/rep<轮>-console.log` | `virsh console` 原始捕获（含 guest 登录提示） |
| `build_variant.json` | 变体、版本、架构、虚拟机规格、绑核与内存绑定方式、加速器、轮次 |
| `actual-version.txt` | 实测 guest 版本（`22.03 LTS SP3`） |

解析严格性：任一轮次文件缺失、状态不是 `passed`、测试点布尔值缺失或为 false、耗时非正，都会让整例失败，
**绝不补零、绝不把失败轮次算作有效样本**。

## 独立运行

```bash
sudo bash software/Virtualization/libvirt-virsh-lifecycle/scripts/host/prepare-vm-host.sh   # 每台 runner 只跑一次
bash software/Virtualization/libvirt-virsh-lifecycle/libvirt_virsh_lifecycle_test.sh \
  --version 22.03-LTS-SP3 --variant base \
  --results-dir /home/runner/libvirt-lifecycle-results/22.03-LTS-SP3
```

内部实际执行：

```bash
source software/Virtualization/libvirt-virsh-lifecycle/scripts/builders/dispatch.sh
build_libvirt_virsh_lifecycle
python3 software/Virtualization/libvirt-virsh-lifecycle/scripts/results/parse_benchmark.py \
  ${RESULTS_DIR} ${RESULTS_DIR}/benchmark_virsh_lifecycle.json
python3 software/Virtualization/libvirt-virsh-lifecycle/scripts/results/standalone_runtime.py finalize \
  ${RESULTS_DIR} 22.03-LTS-SP3 aarch64 ${PERF_RUN_ID} passed passed ''
```

`--keep-workdir` 保留 `${PERF_WORK_DIR}`；`optimized` 结果落 `results/<version>/optimized/` 并保持
`update_baseline=false`。

## 已知限制

- `optimized` 变体**尚未实现**，选择后构建阶段**明确失败**，不会退回基础版。
- 本用例不使用容器；宿主机只安装 libvirt/QEMU 与镜像、密钥，**不向宿主机**安装被测工具，**不修改宿主机**
  软件源、信任库与系统调优（仅按需打开 `net.ipv4.ip_forward` 以支撑 NAT）。
- 宿主机需要 `sudo -n virsh`（runner 用户免密）；缺失时 `require_libvirt_host` 以 30 退出。
- guest 首次启动需要 openEuler 22.03 LTS SP3 镜像可下载并缓存到 `/home/libvirt-images`；离线 runner 需预先放置。
- 生命周期耗时包含 guest 固件与内核启动，受宿主机负载影响；因此同时给出测试点布尔值，避免只看耗时误判。
- 宿主机无 `/dev/kvm` 时（如 WSL 本地验证）自动退化为 TCG，耗时数值仅用于打通流程，不作为性能结论。

## 故障排查

- `virsh` 报 `Authorization not available`：宿主机缺 polkit 或未用 `sudo -n virsh`，按 `require_*` 退出码定位。
- `virsh console` 无输出：确认域定义里保留了 `<serial type='pty'>` 与 `<console>`，且 guest 未关闭串口 getty。
- guest 拿不到地址：确认 `default` 网络已启动、`net.ipv4.ip_forward=1`。
