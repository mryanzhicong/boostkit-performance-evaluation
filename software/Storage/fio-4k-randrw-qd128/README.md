# fio 3.34 性能测试（4k 随机读写，numjobs=4 / iodepth=128，KVM 参考虚拟机）

本用例在 x86_64、aarch64 上分别测量 fio 3.34 的 **4k 随机读写**能力：`rw=randrw`、
`rwmixwrite=30`、`rwmixread=70`、`direct=1`、`ioengine=libaio`、`thread`、`bs=4k`、
`numjobs=4`、`iodepth=128`、`ramp_time=300`、`runtime=600`、`time_based`。
**测试不在容器内执行，而是在本次任务专属的 KVM 参考虚拟机内执行**：虚拟机 4 vCPU、8192 MiB，
按作业数挂载 **4 个 virtio-blk 逻辑卷**（每个作业独占一个 LUN），逻辑卷由宿主 LVM 提供并已
预埋随机数据；测试阶段在虚拟机内以 `taskset -c 0` 把 fio 全部作业钉在 vCPU 0 上运行
`fio randrw_4k.fio`，与预置条件给出的执行方式一致。

被测软件与压测工具是同一个程序（fio），因此用例只做「获取 + 虚拟机内安装 + 逻辑卷准备 + 执行 + 解析」，
没有编译步骤。软件入口为 `fio-4k-randrw-qd128_test.sh`，Framework 按 `case.yaml` 依次调用
构建、启动、测试、停止函数，独立入口调用同一组函数。`scripts/builders/base.sh` 负责创建参考
虚拟机和数据池并在虚拟机内安装 fio，`scripts/stages/` 负责运行时校验、六轮测试与清理，
`scripts/results/parse_benchmark.py` 严格解析 fio 控制台输出。`optimized` 构建入口位于
`scripts/builders/optimized.sh`，**尚未实现**：选择后会在构建阶段明确失败（返回码 10 / 退出码 40），
不会退回基础版，也不产生任何数字。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 / 压测工具 | [fio](https://github.com/axboe/fio) 3.34（openEuler 24.03 LTS SP4 仓库包 `fio-3.34-6.oe2403sp4`，两个架构同名同版本） | 公共离线目录 `/home/runner/software/fio/rpms/<arch>/` → 本任务缓存 `${PERF_WORK_DIR}/fio-rpms/` → 宿主机 `dnf download --resolve --alldeps`；安装进虚拟机 `/usr/bin/fio` |
| 参考虚拟机镜像 | [openEuler 24.03 LTS SP4 官方虚拟化镜像](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/virtual_machine_img/)（按架构 `qcow2.xz` + `.sha256sum` 校验） | 优先读取 `/home/libvirt-images/boostkit-fio-golden-<arch>.qcow2`；每次运行只创建 qcow2 overlay，不重装系统 |
| 虚拟化栈 | 宿主 `libvirt` + `qemu-kvm`（`/usr/libexec/qemu-kvm`）、`qemu-img`、`virsh`、`ssh` | 宿主 `/usr/bin`；由 `scripts/host/prepare-vm-host.sh` 一次性安装并校验 `/dev/kvm` |
| 宿主存储池 | 宿主 `lvm2`（`pvcreate`/`vgcreate`/`lvcreate`）建在稀疏镜像文件上的 loop 设备 | `/home/libvirt-images/fio-storage/fio-qd128/`；卷组 `fio-qd128-vg`，每作业一个逻辑卷 `data1..data4`，各 16 GiB |
| 采样与解析 | 本仓库 `scripts/results/parse_benchmark.py`（无第三方依赖） | 宿主 `${SCRIPT_DIR}/scripts/results/` |

本用例**不使用容器**：预置条件要求「host 创建逻辑卷并预埋数据、虚拟机挂载逻辑卷、虚拟机内
`taskset -c 0 fio`」，逻辑卷到虚拟机的块设备直通由 libvirt 域表达，容器共享宿主内核、无法提供
独立的块设备视图与 vCPU 绑定语义。宿主机只承担 libvirt/QEMU、golden 镜像、LVM 数据池与结果解析，
**不向宿主机安装被测软件**，也不修改宿主机的软件源、信任库、内核参数或调度配置；fio 与运行库
全部装在虚拟机内。

## 参考环境与预置条件的对应关系

| 预置条件 | 本用例的实现 |
|---|---|
| 4k 随机读写 | `bs=4k`、`rw=randrw`、`rwmixwrite=30`、`rwmixread=70`，写入占比 30% |
| 4 作业 / 队列深度 128 | `numjobs=4`、`iodepth=128`、`thread`、`direct=1`、`ioengine=libaio` |
| 预热 300 s + 计时 600 s | `ramp_time=300`、`runtime=600`、`time_based`，每轮实际运行 ≈900 s |
| host 创建相应数目的逻辑卷 | 每个 fio 作业一个逻辑卷：4 作业 → 4 个 LUN（`data1..data4`，卷组 `fio-qd128-vg`） |
| 将数据预埋 | 宿主对每个逻辑卷执行 `dd if=/dev/urandom of=/dev/fio-qd128-vg/dataN bs=4M`，预埋标记 `.seeded` 记录作业数与容量，已预埋则跳过 |
| 在虚拟机中执行 | fio 与作业文件都在虚拟机内，逻辑卷以 `<disk type='block'>` 直通为 `/dev/vdb.../dev/vde` |
| `taskset -c 0 fio randrw_4k.fio` | 测试阶段在虚拟机内执行该命令原样；fio 的 4 个线程继承 vCPU 0 的亲和性掩码 |
| test 结束后查看结果并记录 | 每轮完整控制台输出落 `runs/rep<i>.log`，5 轮有效样本取中位数写入 `benchmark_fio.json` |
| 操作系统 | openEuler 24.03 LTS SP4 cloud 镜像；构建阶段读取虚拟机 `/etc/os-release` 并强制校验 `VERSION_ID="24.03"` |
| 作业文件 | 预置条件给出的 `[global]` 段逐行保留；另加一个作业段命名目标逻辑卷（原因见「已知限制」） |

## 宿主准备（Runner 一次性）

```bash
sudo bash software/Storage/fio-4k-randrw-qd128/scripts/host/prepare-vm-host.sh
```

以下是脚本执行的实际命令形态与顺序：

1. `dnf install -y --setopt=install_weak_deps=False libvirt libvirt-client libvirt-daemon libvirt-daemon-driver-qemu qemu-img virt-install xorriso`，
   并补装 `qemu-kvm`、`parted`、`util-linux`、`lvm2`，校验 `/usr/libexec/qemu-kvm` 与 `/dev/kvm` 存在。
2. `systemctl enable --now libvirtd`（无 systemd 的宿主退化为 `/usr/sbin/libvirtd --daemon`），
   `virsh version` 可用，`virsh net-start default` + `virsh net-autostart default`，`virbr0` 为 `192.168.122.1/24`。
3. 打开 `net.ipv4.ip_forward`：虚拟机要通过 `virbr0` 的 NAT 访问软件源安装 fio，脚本发现该值
   不为 `1` 时执行 `sysctl -w net.ipv4.ip_forward=1` 并写入 `/etc/sysctl.d/99-boostkit-qemu-vm.conf`
   持久化（Blue 机器实测默认是 `0`，此时虚拟机能拿到 DHCP 地址、DNS 可用，但出网全部超时）。
4. `virsh define` 前无需额外动作；若宿主没有 udev（WSL），建卷阶段会自动补 `/dev/block/<主>:<次>`
   链接，供 libvirt 解析 `type='block'` 直通盘的底层设备。
5. 下载并按官方 `.sha256sum` 校验镜像，`xz -dkf` 解压后命名为
   `/home/libvirt-images/boostkit-fio-golden-<arch>.qcow2`；生成
   `/home/runner/software/fio/vm/id_ed25519{,.pub}`，用 `qemu-nbd`（无 nbd 模块时退化为
   `qemu-img convert` + `mount -o loop,offset=`）挂载根分区，注入 `root` 的 `authorized_keys`、
   `/etc/ssh/sshd_config.d/99-boostkit.conf`（`PermitRootLogin prohibit-password`、`PasswordAuthentication no`）、
   主机名 `fio-vm`，SELinux 置 `permissive`，随后卸载并把镜像写回 qcow2。
6. 创建数据池：为每个逻辑卷准备一个稀疏镜像文件并挂成 loop 设备，建成卷组与逻辑卷，然后预埋数据：

```bash
# 实际命令形态（宿主，每个作业一份，这里以第 1 个逻辑卷为例）
truncate -s 16G /home/libvirt-images/fio-storage/fio-qd128/disk1.img
losetup --find --show /home/libvirt-images/fio-storage/fio-qd128/disk1.img
pvcreate -q -y /dev/loop0
vgcreate -q -y fio-qd128-vg /dev/loop0 /dev/loop1 /dev/loop2 /dev/loop3
lvcreate -q -y -W n --zero n -L 16G -n data1 fio-qd128-vg
dd if=/dev/urandom of=/dev/fio-qd128-vg/data1 bs=4M status=none
```

脚本幂等：镜像已存在且已注入当前公钥时跳过镜像重做，逻辑卷已存在时跳过创建、预埋标记
`.seeded` 与当前「作业数×容量」一致时跳过重复预埋。`FIO_VM_IMAGE_DIR`、`FIO_VM_KEY_DIR`、
`FIO_STORAGE_ROOT` 可覆盖默认路径。

- **脚本出处**：`scripts/host/prepare-vm-host.sh`

## 虚拟机生命周期（每次运行）

构建阶段执行以下步骤，全部命令对宿主只读或只操作本次命名的资源：

1. 校验宿主具备 `virsh`、`qemu-img`、`ssh`、`scp`、`sha256sum`、免密 `sudo` 与 `sudo -n virsh version`，
   golden 镜像、SSH 私钥与逻辑卷存在；`FIO_VM_ACCEL=kvm` 时强制要求 `/dev/kvm`。
2. 清理上一次异常中断遗留的 `boostkit-fio-*` 域与本次运行之外的 overlay 目录；逻辑卷**不删除**，
   它们是宿主持久数据池的一部分。
3. 校验或创建数据池（见上节），并把逻辑卷设备节点交给 libvirt 的 `qemu` 用户（存在时）。
4. `qemu-img create -f qcow2 -F qcow2 -b <golden> <overlay>` 创建本次专属 overlay，渲染并 `virsh define` 如下规格：

```bash
virsh define "${FIO_VM_RUN_DIR}/vm.xml"     # 域名 boostkit-fio-<架构>-<运行 ID>
virsh start  "boostkit-fio-<架构>-<运行 ID>"
```

```xml
<domain type='kvm'>
  <name>boostkit-fio-aarch64-&lt;run-id&gt;</name>
  <memory unit='MiB'>8192</memory>
  <vcpu placement='static'>4</vcpu>
  <cpu mode='host-passthrough' check='none' migratable='off'/>
  <devices>
    <disk type='file' device='disk'>      <!-- 系统盘：golden 镜像的 qcow2 overlay -->
      <source file='/home/libvirt-images/runs/&lt;run-id&gt;/system.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <disk type='block' device='disk'>      <!-- 数据盘 1：宿主逻辑卷直通，共 4 个 -->
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/fio-qd128-vg/data1'/>
      <target dev='vdb' bus='virtio'/>
    </disk>
  </devices>
</domain>
```

5. 虚拟机使用 libvirt `default` NAT 网络；脚本用 `virsh domifaddr --source lease` 发现 IPv4，
   等 SSH 就绪且 `nproc` 等于 4 后把 `vm_ip` 写入 `${PERF_WORK_DIR}/vm-state.env`；
   控制台日志写 `/home/libvirt-images/runs/<运行 ID>/console.log`。
6. 虚拟机内安装 fio，两条路径按虚拟机实际网络情况自动选择，尝试结果写入 `build-info.txt` 的
   `toolchain_source`/`toolchain_install_attempt`：
   - 虚拟机可出网：`dnf install -y --setopt=install_weak_deps=False fio procps-ng util-linux`，
     镜像元数据不一致时依次重试（原样 → `--refresh` → `--disablerepo='*update*' --setopt=strict=0`）；
   - 虚拟机无出网：宿主用同发行版同架构的 `dnf download --resolve --alldeps` 把上述包及其依赖下载到
     `/home/libvirt-images/fio-rpms/<arch>/`，打包 `scp` 进虚拟机后
     `dnf install -y --disablerepo="*" --nogpgcheck /root/fio-rpms/*.rpm` 离线安装。
   - 安装后执行 `fio --version`，与 `case.yaml` 的 3.34 不一致时直接失败（退出码 40）。
7. 校验虚拟机内 `/dev/vdb..vde` 的扇区数等于 16 GiB，把 `vm-environment.txt` 写入结果目录：
   宿主加速器、域规格、`virsh dumpxml` 全文、逻辑卷布局，以及虚拟机内 `os-release`、块设备
   队列参数、`fio --version`。

启动阶段重新校验域在运行、SSH 可达、fio 与 `taskset` 可用、作业文件存在，并写 `service-state.json`。
停止阶段 `virsh destroy` + `virsh undefine --nvram`、删除 overlay 与状态文件，**保留逻辑卷**，
因此 `stop` 幂等且可安全重跑。

- **脚本出处**：`scripts/common.sh`、`scripts/stages/{start,test,stop}.sh`

## fio 获取、构建与虚拟机启动

fio 不编译，获取顺序固定为三级，安装动作发生在虚拟机内：

1. 公共离线目录 `/home/runner/software/fio/rpms/<arch>/*.rpm`（离线 runner 的预置件）；
2. 本任务缓存 `${PERF_WORK_DIR}/fio-rpms/`；
3. 宿主 `dnf download --resolve --alldeps`（默认走 openEuler 24.03 LTS SP4 官方仓库，`sp4` 元数据缺失时
   依次重试两次）。

```bash
# 实际命令形态（宿主，离线兜底时）
dnf download --resolve --alldeps --destdir "${PERF_WORK_DIR}/fio-rpms" fio procps-ng util-linux
tar -czf "${PERF_WORK_DIR}/fio-rpms-$(uname -m).tar.gz" -C "${PERF_WORK_DIR}/fio-rpms" .
scp -i /home/runner/software/fio/vm/id_ed25519 "${PERF_WORK_DIR}/fio-rpms-$(uname -m).tar.gz" root@${FIO_VM_IP}:/root/fio-rpms.tar.gz
```

```bash
# 实际命令形态（虚拟机内，由 vm_exec 执行）
dnf install -y --setopt=install_weak_deps=False fio procps-ng util-linux
fio --version
```

安装完成后把实际版本、安装来源与尝试次数、作业文件 SHA-256、LUN 列表写入 `build-info.txt`；
`fio --version` 输出形如 `fio-3.34`，与 `case.yaml` 声明的版本逐字符校验。

- **脚本出处**：`scripts/builders/base.sh`

## 数据与运行顺序

1. 宿主侧校验数据池：4 个逻辑卷各 16 GiB，预埋标记与「作业数×容量」一致；缺卷或未预埋时
   先补建/补埋再继续。

   ```bash
   # 实际命令形态（宿主）
   lvs --noheadings -o lv_name,lv_size,devices fio-qd128-vg
   dd if=/dev/urandom of=/dev/fio-qd128-vg/data1 bs=4M status=none
   ```

2. 虚拟机侧确认块设备与容量：`/dev/vdb`…`/dev/vde` 依次对应 `data1`…`data4`，扇区数等于
   16 GiB ÷ 512。

   ```bash
   # 实际命令形态（虚拟机内）
   cat /sys/block/vdb/size   # 33554432 = 16 GiB / 512 B
   cat /sys/block/vdb/queue/scheduler
   ```

3. 渲染作业文件：预置条件的 `[global]` 段逐行保留，另加作业段把 4 个逻辑卷分配给 4 个作业，
   并把作业文件 `scp` 进虚拟机 `/root/fio/randrw_4k.fio`。

   ```bash
   # 实际命令形态（宿主渲染，随后 scp 进虚拟机）
   fio_job_filename_list      # 输出 /dev/vdb:/dev/vdc:/dev/vdd:/dev/vde
   scp -i /home/runner/software/fio/vm/id_ed25519 "${RESULTS_DIR}/randrw_4k.fio" root@${FIO_VM_IP}:/root/fio/randrw_4k.fio
   ```

   渲染后的作业文件（实际内容）：

   ```ini
   [global]
   ioengine=libaio
   direct=1
   numjobs=4
   thread
   bs=4k
   rw=randrw
   rwmixwrite=30
   rwmixread=70
   iodepth=128
   ramp_time=300
   runtime=600
   time_based

   [randrw_4k]
   filename=/dev/vdb:/dev/vdc:/dev/vdd:/dev/vde
   size=100%
   group_reporting
   ```

4. 测试阶段在虚拟机内连续执行 **6 轮**（1 轮预热 + 5 轮有效），每轮 300 s 预热 + 600 s 计时：

   ```bash
   # 实际命令形态：vm_exec_shell 把该命令串交给虚拟机登录 shell 执行
   bash -c 'cd /root/fio && taskset -c 0 fio randrw_4k.fio'
   ```

5. 每轮完整控制台输出写 `runs/rep<i>.log`，并按轮次追加到 `benchmark_fio_raw.log`；预热轮不进入统计。
6. 任一轮退出码非 0 或输出出现 `err= <非零>` 即判该轮失败，整次测试失败，不补零、不降级。

| 参数 | 取值 | 来源 |
|---|---|---|
| 块大小 | 4k | 预置条件 |
| 读写模式 | `randrw`（写 30% / 读 70%） | 预置条件 |
| 并发作业 | 4 | 预置条件 |
| 队列深度 | 128 | 预置条件 |
| I/O 引擎 | `libaio`，`direct=1`，`thread` | 预置条件 |
| 预热 / 计时 | 300 s / 600 s，`time_based` | 预置条件 |
| 逻辑卷 | 4 × 16 GiB（每作业一个） | 本用例按「相应数目」推导，见上表 |
| 虚拟机规格 | 4 vCPU、8192 MiB | 负载只使用 1 个 vCPU（`taskset -c 0`），故取最小可复现规格 |
| 轮次 | 6（1 预热 + 5 有效） | 仓库采样契约 |
| 每次运行耗时 | ≈ 6 × 900 s + 环境准备 | 预置条件 × 轮次 |

x86_64 与 aarch64 使用同一矩阵、同一逻辑卷数量与容量。

## 指标与产物

每个有效轮次产生 8 项性能数值，跨 5 个有效轮次取**中位数**，另加 4 项负载事实（共 12 项）：

| 报告分组 | 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|---|
| 读 | `fio.read.iops` | `read: IOPS=…` 行（支持 `k`/`M` 后缀） | IOPS | 越大越好 |
| 读 | `fio.read.bw_mib` | `read: … BW=…MiB/s` | MiB/s | 越大越好 |
| 读 | `fio.read.clat_avg_us` | `read` 块内 `clat (usec): … avg=…` | us | 越小越好 |
| 读 | `fio.read.clat_p99_us` | `read` 块内 `clat percentiles (usec)` 的 `99.00th` | us | 越小越好 |
| 写 | `fio.write.iops` | `write: IOPS=…` 行 | IOPS | 越大越好 |
| 写 | `fio.write.bw_mib` | `write: … BW=…MiB/s` | MiB/s | 越大越好 |
| 写 | `fio.write.clat_avg_us` | `write` 块内 `clat (usec): … avg=…` | us | 越小越好 |
| 写 | `fio.write.clat_p99_us` | `write` 块内 `clat percentiles (usec)` 的 `99.00th` | us | 越小越好 |
| 负载 | `fio.numjobs` | 作业文件 `numjobs=` | jobs | 中性 |
| 负载 | `fio.iodepth` | 作业文件 `iodepth=` | queue_depth | 中性 |
| 负载 | `fio.block_size_kib` | 作业文件 `bs=4k` | KiB | 中性 |
| 负载 | `fio.runtime_seconds` | 作业文件 `runtime=` | s | 中性 |

指标总数为 **12 项**：读 4 项、写 4 项、负载事实 4 项；分组列只有 `读`/`写`/`负载` 三种取值，
对应 `benchmark_fio.json` 中 `results.*.group`。方向与 `case.yaml` 的 `metrics` 一致
（`higher_is_better`/`lower_is_better`/`neutral`）。

| 产物 | 内容 |
|---|---|
| `benchmark_fio_raw.log` | 6 轮完整控制台输出（含轮次头与命令），单文件约 30 KB |
| `runs/rep<i>.log` | 第 i 轮原始输出，供复核 |
| `benchmark_fio.json` | 12 项指标 + 每轮读/写原始值 + 参数与轮次元数据 + raw log 的 SHA-256 |
| `randrw_4k.fio` | 实际下发给虚拟机的作业文件 |
| `format-info.txt` | 作业文件全文、`taskset -c 0 fio randrw_4k.fio` 命令、虚拟机内各 LUN 扇区数与调度器 |
| `vm-environment.txt` | 宿主加速器、`virsh dumpxml` 全文、逻辑卷布局、虚拟机 `os-release`/块设备队列参数 |
| `build-info.txt` | 实际版本、安装来源与尝试次数、作业文件 SHA-256、LUN 列表 |
| `build_variant.json`、`service-state.json`、`stop-state.json` | 变体与虚拟机运行时快照 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

解析严格性：轮次数不足 6、缺任一 `rep<i>.log`、`fio-<版本>` 横幅缺失或版本不符、`Starting N threads`
的 N 不等于 `numjobs`、作业描述行的 `rw`/`bs`/`iodepth`/`ioengine` 与声明不符、聚合结果行
`err=` 非 0、缺读或缺写报告、任一侧 IOPS 或带宽非正、单侧计时偏差超出 ±2% 下限、任一数值非有限，
都会以非零码失败并打印具体文件与原因，**绝不补零、绝不降级为部分指标**。

- **脚本出处**：`scripts/results/parse_benchmark.py`、`scripts/stages/test.sh`

## 独立运行

在具备 KVM 与 lvm2 的 Runner 上以 `runner` 用户执行同一批函数（默认工作目录 `/home/runner/boostkit-perf/fio/<run-id>`）：

```bash
bash software/Storage/fio-4k-randrw-qd128/fio-4k-randrw-qd128_test.sh \
  --version 3.34 \
  --variant base \
  --results-dir /home/runner/fio-results/3.34-qd128
```

入口内部实际执行的关键命令：

```bash
# 1) 数据池（幂等；已预埋则跳过）
losetup --find --show /home/libvirt-images/fio-storage/fio-qd128/disk1.img
vgcreate -q -y fio-qd128-vg /dev/loop0 /dev/loop1 /dev/loop2 /dev/loop3
lvcreate -q -y -W n --zero n -L 16G -n data1 fio-qd128-vg

# 2) 参考虚拟机
qemu-img create -q -f qcow2 -F qcow2 -b /home/libvirt-images/boostkit-fio-golden-x86_64.qcow2 \
  /home/libvirt-images/runs/<run-id>/system.qcow2
virsh start "boostkit-fio-x86_64-<run-id>"

# 3) 虚拟机内安装与执行
dnf install -y --setopt=install_weak_deps=False fio procps-ng util-linux
bash -c 'cd /root/fio && taskset -c 0 fio randrw_4k.fio'

# 4) 解析
python3 scripts/results/parse_benchmark.py --runs-dir "${RESULTS_DIR}/runs" --reps 6 \
  --output "${RESULTS_DIR}/benchmark_fio.json" --raw-log "${RESULTS_DIR}/benchmark_fio_raw.log"
```

- `--variant optimized`：构建阶段立即失败（`ERROR: the optimized fio build is not implemented`），不产生数字。
- `--results-dir`：指定结果落盘目录；`--keep-workdir` 保留本次私有目录便于排查，默认清理。
- 结果目录内可直接查看 `benchmark_fio.json`、`report.md`、`results.json`、`vm-environment.txt`。
- 基线：本用例不写死任何基准数值，`update_baseline` 由调用方控制，正式结果由流水线写入
  `performance-results` 分支。

## 已知限制

- **虚拟机而非容器**：为使「宿主逻辑卷 + 虚拟机块设备直通 + vCPU 绑定」成立，本用例在 KVM
  虚拟机内运行，不使用仓库通用的 openEuler 容器；因此镜像加载、容器创建等步骤在本用例中不适用。
- **作业文件补了一个作业段**：预置条件给出的作业文件只有 `[global]`。fio 对「只有 `[global]`」的
  文件直接以 `fio: need a job section` 退出（可用 `fio randrw_4k.fio` 复现），因此用例在 `[global]`
  逐行保留的前提下追加 `[randrw_4k]` 作业段，只写目标逻辑卷列表（`filename=`）、`size=100%` 与
  `group_reporting`；`bs`、`rw`、`rwmix*`、`numjobs`、`iodepth`、`ramp_time`、`runtime`、
  `time_based`、`direct`、`thread`、`ioengine` 全部保持预置条件原值，未做调优。
- **`taskset -c 0` 是预置条件的一部分**：4 个作业的线程都继承 vCPU 0 的亲和性，等于用单核驱动
  4 × 128 的队列深度。用例不额外绑核、不改写为多核，以保证与预置条件的执行方式一致。
- **逻辑卷是宿主持久数据池**：预埋会覆盖这 4 个逻辑卷（16 GiB × 4），
  `stop` 阶段不删除卷组与逻辑卷；如需回收，在宿主执行 `lvremove fio-qd128-vg` 后
  `vgremove fio-qd128-vg`、`pvremove`，再删除 `/home/libvirt-images/fio-storage/fio-qd128/`。
- **与整机直跑的差异**：fio 在虚拟机内运行，I/O 经过 virtio-blk 与 QEMU 块层，延迟高于同硬件
  整机直跑属正常现象；本用例只用于同机型、同规格虚拟机之间的横向比较。
- **本地链路验证降级为 TCG**：WSL 等无 `/dev/kvm` 的机器上，用例自动退化为 QEMU TCG
  （`<domain type='qemu'>`）、改用小型逻辑卷并缩短预热/计时，只用于验证虚拟机创建、块设备直通、
  SSH、fio 执行与解析链路，**这些数字不能作为性能证据**；正式证据取 aarch64 KVM 全规格运行。
- **无 udev 的宿主需补 `/dev/block` 链接**：libvirt 打开 `type='block'` 直通盘时会把设备映射解析到底层
  loop 设备，并访问 `/dev/block/<主设备号>:<次设备号>`。有 udev 的发行版由 udev 提供该链接；WSL 这类
  无 udev 的环境缺失，用例在建卷后自动补建（`ln -sfn /dev/loopN /dev/block/7:N`），不影响 Blue 的
  KVM 机器。
- **完成时延表的单位随延迟分布变化**：fio 在延迟较小时输出 `clat percentiles (usec)`，延迟较大时改用
  `(msec)`，个别环境用 `(nsec)`。解析器按表头单位统一换算为微秒后再取中位数；表头缺失、99 百分位
  缺失或任一方向缺失都直接失败，不补零。
- **单作业时 fio 的启动行是单数**：`numjobs=1` 时 fio 打印 `Starting 1 thread`。解析器同时接受
  `thread` 与 `threads`，并把该数字与作业声明逐一比对。
- **虚拟机规格取最小可复现值**：4 vCPU / 8192 MiB 只是承载一个被钉在 vCPU 0 的 fio 进程；
  预置条件未规定虚拟机规格，故不写死更大规格。
- **未实现 optimized 变体**：`scripts/builders/optimized.sh` 只返回失败，不产生任何数字。
- **网络**：宿主下载只走 openEuler 官方仓库；离线 runner 依赖 `/home/runner/software/fio/rpms/`
  预置 RPM 与 `/home/libvirt-images/` 的 golden 镜像。
- **虚拟机出网依赖宿主转发**：Blue 机器默认 `net.ipv4.ip_forward=0`，此时虚拟机可拿到 DHCP 地址、
  DNS 可用但所有出网连接超时；宿主准备脚本会打开并持久化该开关，未打开且宿主有 `dnf` 时构建阶段
  自动退回「宿主下载 RPM + 虚拟机离线安装」，两者都不可用时明确失败，不跳过安装。
- **无基准数字**：本 README 不写任何未经产物验证的数值。

## 与参考材料的关系

- fio 作业参数（`bs=4k`、`rw=randrw`、`rwmixwrite=30`、`rwmixread=70`、`numjobs=4`、`iodepth=128`、
  `direct=1`、`thread`、`ioengine=libaio`、`ramp_time=300`、`runtime=600`、`time_based`）、执行命令
  `taskset -c 0 fio randrw_4k.fio` 与「host 建逻辑卷并预埋数据、虚拟机内执行」的流程来自预置条件原文，
  未做改动。
- 虚拟机形态、libvirt 域结构与「宿主一次性准备 + 每次运行 overlay」的组织方式沿用 main 分支
  `software/Others/unixbench` 与同批交付的 `software/HPC/stream` 参考虚拟机实现，以保证同一 Runner
  上虚拟机用例的行为一致。
- 与容器方案不可横向比较：容器共享宿主内核、无独立块设备直通与 vCPU 亲和性语义；历史容器结果继续
  保留在 `performance-results` 中，不做清理。
