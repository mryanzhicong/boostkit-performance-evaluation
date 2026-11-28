# libvirt-unixbench 6.0.1 性能测试

本用例在 openEuler 24.03 LTS SP4 宿主机上用 libvirt/QEMU 部署一批参考虚拟机（每 4 个宿主机核创建 1 台，
规格 4 vCPU / 8 GiB），把每台虚拟机的 vCPU 连续绑核、内存绑定到同一 NUMA 节点，在每台虚拟机内编译并运行
上游 UnixBench master 快照的完整系统基准（`./Run -c 4`），用 UnixBench 的系统基准 index score 作为
libvirt 虚拟化环境的性能指标。**本用例不使用容器**：被测对象是 KVM 虚拟机内的整机系统性能，容器无法提供
独立的 CPU 绑核、NUMA 内存绑定与 guest 内核，因此整条链路直接在宿主机与虚拟机内执行（宿主直跑）。

支持 `aarch64` 与 `x86_64`；两架构使用同一参数矩阵。Framework 六阶段（build/start/test/stop）与独立入口
`libvirt_unixbench_test.sh` 调用同一批阶段函数。用例提供 `base` 与 `optimized` 两个变体入口：`optimized`
位于 `scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测环境 | libvirt 9.10.0 + QEMU（宿主机发行版自带，`virsh --version` 记录实际值） | 宿主机 `/usr/bin/virsh`、`/usr/libexec/qemu-kvm` |
| 参考虚拟机镜像 | openEuler 24.03 LTS SP4 虚拟机镜像（`repo.openeuler.org/openEuler-24.03-LTS-SP4/virtual_machine_img/`），SHA-256 校验后解压 | 公共目录 `/home/libvirt-images/openEuler-24.03-LTS-SP4-<arch>.qcow2.xz`；golden 镜像 `boostkit-libvirt-golden-<arch>.qcow2` |
| 测试工具 | UnixBench（byte-unixbench）master 快照，`Run` 内 `my $version = "6.0.1"`，sha256 `f57ab9d1d61e920bce58ee05c82c70dca8490d30662d21d7bef1579a1a797125` | 宿主机缓存 `/home/runner/software/libvirt/byte-unixbench-master.tar.gz`，跑测时拷入 guest 的 `/home/byte-unixbench-master` |
| guest 编译依赖 | guest 自带 `gcc`、`make`、`perl(Time::HiRes)`，缺失时 guest 内 `dnf` 安装 | 只装在 guest 内，宿主机不装编译器 |

## libvirt 获取、部署与虚拟机启动

宿主机准备只需执行一次。以下给出实际命令形态，占位符 `${ARCH}` 取 `uname -m` 的结果（`aarch64` / `x86_64`），
`${PERF_WORK_DIR}` 由 Framework 注入（独立运行时默认 `/home/runner/boostkit-perf/libvirt-unixbench/local-<run-id>`）。

1. 安装并启动 libvirt（宿主机只装虚拟化最小依赖，不装编译器）：

```bash
sudo dnf install -y libvirt libvirt-client libvirt-daemon libvirt-daemon-driver-qemu qemu-img qemu-kvm xorriso
sudo systemctl enable --now libvirtd
sudo virsh net-start default && sudo virsh net-autostart default
sudo sysctl -w net.ipv4.ip_forward=1
```

2. 下载 openEuler 24.03 LTS SP4 虚拟机镜像，按 SHA-256 校验后解压为 golden 镜像：

```bash
curl -fL -o /home/libvirt-images/openEuler-24.03-LTS-SP4-${ARCH}.qcow2.xz \
  https://repo.openeuler.org/openEuler-24.03-LTS-SP4/virtual_machine_img/${ARCH}/openEuler-24.03-LTS-SP4-${ARCH}.qcow2.xz
(cd /home/libvirt-images && sha256sum -c openEuler-24.03-LTS-SP4-${ARCH}.qcow2.xz.sha256sum)
xz -dkf /home/libvirt-images/openEuler-24.03-LTS-SP4-${ARCH}.qcow2.xz
mv /home/libvirt-images/openEuler-24.03-LTS-SP4-${ARCH}.qcow2 /home/libvirt-images/boostkit-libvirt-golden-${ARCH}.qcow2
```

3. 生成虚拟机 SSH 密钥（`/home/runner/software/libvirt/vm/id_ed25519`），用 `qemu-nbd` 把公钥注入 golden 镜像的
`/root/.ssh/authorized_keys`，并写入 `PermitRootLogin prohibit-password`、关闭 SELinux enforcing：

```bash
ssh-keygen -q -t ed25519 -N '' -f /home/runner/software/libvirt/vm/id_ed25519
sudo modprobe nbd max_part=8
sudo qemu-nbd -c /dev/nbd0 -f qcow2 /home/libvirt-images/boostkit-libvirt-golden-${ARCH}.qcow2
sudo mount /dev/nbd0p2 /mnt/boostkit-libvirt-golden
sudo install -d -m 700 /mnt/boostkit-libvirt-golden/root/.ssh
sudo cp /home/runner/software/libvirt/vm/id_ed25519.pub /mnt/boostkit-libvirt-golden/root/.ssh/authorized_keys
sudo umount /mnt/boostkit-libvirt-golden && sudo qemu-nbd --disconnect /dev/nbd0
```

4. 缓存 UnixBench master 快照并校验（离线 runner 直接复用该缓存）：

```bash
mkdir -p /home/runner/software/libvirt
curl -fL -o /home/runner/software/libvirt/byte-unixbench-master.tar.gz \
  https://codeload.github.com/kdlucas/byte-unixbench/tar.gz/refs/heads/master
printf '%s  %s\n' f57ab9d1d61e920bce58ee05c82c70dca8490d30662d21d7bef1579a1a797125 \
  /home/runner/software/libvirt/byte-unixbench-master.tar.gz | sha256sum -c -
```

5. 创建虚拟机：每 4 个宿主机核 1 台虚拟机，规格 4 vCPU / 8192 MiB；从 `lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE`
读取拓扑，把每台虚拟机的 4 个 vCPU 依次绑到**同一 NUMA 节点内连续的 4 个物理核**（每核取第一个在线线程），
用 `numatune` 把内存严格绑定到该节点，磁盘用 golden 镜像的 qcow2 叠加盘（`cache=none`、`io=native`）：

```bash
sudo qemu-img create -q -f qcow2 -F qcow2 -b /home/libvirt-images/boostkit-libvirt-golden-${ARCH}.qcow2 \
  ${PERF_WORK_DIR}/vm/vm0/system.qcow2
sudo virsh define ${PERF_WORK_DIR}/vm/vm0/vm.xml   # <vcpupin/> + <emulatorpin/> + <numatune mode='strict'/>
sudo virsh start boostkit-libvirt-${ARCH}-${PERF_RUN_ID}-0
sudo virsh domifaddr boostkit-libvirt-${ARCH}-${PERF_RUN_ID}-0 --source lease
```

6. 在每台 guest 内准备 UnixBench（严格按用例规定的 4 条命令，外加一次 `make all`）：

```bash
scp -i /home/runner/software/libvirt/vm/id_ed25519 byte-unixbench-master.tar.gz root@<guest-ip>:/home/
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> 'tar -zxvf /home/byte-unixbench-master.tar.gz -C /home'
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> \
  'cd /home/byte-unixbench-master && sed -i "s/\('system.*'maxCopies'\) => 16/\1 => \`nproc --all\`/" Run'
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> 'cd /home/byte-unixbench-master && make all'
```

> 说明：master 快照的 `Run` 里 `'system' => { 'maxCopies' => 0 }`（0 表示不限制），因此该 `sed` 在 master 上是
> 不生效的空操作；脚本会记录实际匹配到的行原文，不会静默「修正」。`-c 4` 已经显式指定 4 个并发副本。

- **脚本出处**：`scripts/host/prepare-vm-host.sh`、`scripts/common.sh`

## 数据与运行顺序

两架构使用同一矩阵；虚拟机数量随宿主机核数变化，由 `lscpu` 读取后计算（`核数 / 4`，最少 1 台）。

| 参数 | 取值 | 说明 |
|---|---|---|
| 虚拟机数量 | `总核数 / 4`（192 核 aarch64 → 48 台） | 可用 `LIBVIRT_VM_COUNT` 覆盖，仅用于小规模复现 |
| 单机规格 | 4 vCPU / 8192 MiB | vCPU 连续绑核，内存同 NUMA 节点严格绑定 |
| 每机副本数 | 4（`./Run -c 4`） | 与 vCPU 数一致，guest 内 `nproc` 必须为 4 |
| 轮次 | 6 轮（1 轮预热 + 5 轮有效采样） | 轮次内所有虚拟机**同时**跑测 |
| 预计耗时 | 约 90 ~ 120 分钟（含建机与 guest 编译） | job 超时 = `timeout_minutes` 480 + 30 |

1. build 阶段：检查宿主前置条件（`virsh`、`qemu-img`、golden 镜像、私钥、`sudo -n virsh`），清理同前缀残留域，
   规划并创建全部虚拟机，启动后校验 guest 为 openEuler 24.03、`nproc == 4`，逐台编译 UnixBench，落
   `vm-environment.txt` 证据：

```bash
lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE | grep -v '^#'            # 读取拓扑并连续分组
sudo virsh list --all --name | grep '^boostkit-libvirt-'        # 清理同前缀残留
for i in $(seq 0 $((LIBVIRT_VM_COUNT - 1))); do vm_exec "${i}" nproc; done
```

2. start 阶段：复查每台 guest 的 `pgms/dhry2reg` 与 `perl -MTime::HiRes`（UnixBench 能跑起来的最小条件）：

```bash
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> \
  'test -x /home/byte-unixbench-master/pgms/dhry2reg && perl -MTime::HiRes -e "print qq(ok\n)"'
```

3. test 阶段：所有虚拟机并行执行 6 轮 `./Run -c 4`，原始输出按 `runs/rep<轮>/vm<序号>.log` 落盘，
   同时把每台 guest 官方的 `results/<host>/<date>-<arch>-<os>/` 目录整体拷回：

```bash
ssh -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip> \
  'cd /home/byte-unixbench-master && timeout 3600 ./Run -c 4 2>&1 | tee /home/rep1.log'
scp -r -i /home/runner/software/libvirt/vm/id_ed25519 root@<guest-ip>:/home/byte-unixbench-master/results \
  ${RESULTS_DIR}/unixbench-official/vm0
python3 scripts/results/parse_benchmark.py ${RESULTS_DIR}/runs ${RESULTS_DIR}/benchmark_unixbench.json \
  ${RESULTS_DIR}/per-vm-scores.json
```

4. 采样与聚合规则：预热轮不计入；每个有效轮次内先取所有虚拟机的中位数，再对 5 个有效轮次取中位数；
   `index_score_min/max` 给出所有（轮次 × 虚拟机）样本的最小/最大值，用于观察抖动。

5. stop 阶段：`virsh shutdown`（超时后 `destroy`）→ `undefine` 全部域，删除本次私有工作目录：

```bash
sudo virsh shutdown boostkit-libvirt-${ARCH}-${PERF_RUN_ID}-0
sudo virsh undefine boostkit-libvirt-${ARCH}-${PERF_RUN_ID}-0 --nvram
sudo rm -rf ${PERF_WORK_DIR}/vm
```

失败时保留 `runs/` 原始日志与 `benchmark_unixbench_raw.log` 以便定位；虚拟机一律按域名前缀清理，不残留。

- **脚本出处**：`scripts/builders/base.sh`、`scripts/stages/start.sh`、`scripts/stages/test.sh`、`scripts/stages/stop.sh`

## 指标与产物

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `unixbench.index_score` | `./Run -c 4` 输出的 `System Benchmarks Index Score`，跨虚拟机/轮次取中位数 | index | 越大越好 |
| `unixbench.index_score_min` | 所有（轮次 × 虚拟机）样本中的最小值 | index | 越大越好 |
| `unixbench.index_score_max` | 所有（轮次 × 虚拟机）样本中的最大值 | index | 越大越好 |
| `unixbench.dhrystone2.index` 等 12 项 | 系统基准索引表中 12 个测试的 `INDEX` 列 | index | 越大越好 |
| `libvirt.vm_count` | 本次实测的虚拟机数量 | vm | 中性 |
| `libvirt.vcpus_per_vm` | 单机 vCPU 数（= `./Run -c` 副本数） | vcpu | 中性 |
| `libvirt.measured_reps` | 计入统计的有效轮次 | repetition | 中性 |
| `libvirt.total_benchmark_runs` | 有效轮次 × 虚拟机数，即参与聚合的官方跑测次数 | run | 中性 |

12 个索引测试为：`dhrystone2`、`whetstone_double`、`execl`、`file_copy_1024`、`file_copy_256`、`file_copy_4096`、
`pipe_throughput`、`pipe_context_switch`、`process_creation`、`syscall_overhead`、`shell_scripts_1`、`shell_scripts_8`。

指标总数：3 项汇总（index/最小/最大）+ 12 项单测索引 + 4 项拓扑与采样 = **19 项**。分组规则：12 项单测索引
与 3 项汇总归入 `4 copies` 分组，拓扑与采样指标归入 `topology` 分组。单位与方向与 `case.yaml` 的
`metrics.collection` 一一对应（`value/unit/direction/group`）。

产物清单：

| 产物 | 内容 |
|---|---|
| `benchmark_unixbench.json` | 解析后的指标（19 项），由 `metrics.source` 消费 |
| `per-vm-scores.json` | 每一轮 × 每一台虚拟机的 index score 与 12 项索引（全部样本，不裁剪） |
| `benchmark_unixbench_raw.log` | test 阶段的完整日志（每轮每机的 `./Run` 输出与耗时） |
| `unixbench-official/` | 每台 guest 官方 `results/` 目录的原样拷贝 |
| `vm-environment.txt` | 每台 guest 的 OS、内核、`nproc`、`lscpu`、绑核校验、UnixBench `Run` 关键行等证据 |
| `build_variant.json` | 变体、版本、架构、虚拟机规格、副本数、golden 镜像校验值 |
| `actual-version.txt` | 实测 UnixBench 版本（`6.0.1`） |

解析严格性：任一轮次/任一虚拟机的报告缺失、副本数不是 4、`System Benchmarks Index Values` 表不完整、
出现 `Partial Index`、原始值与索引值不一致、或 index score 非正，都会让整例失败，**绝不补零、绝不降级**。

## 独立运行

```bash
sudo bash software/Virtualization/libvirt-unixbench/scripts/host/prepare-vm-host.sh   # 每台 runner 只跑一次
bash software/Virtualization/libvirt-unixbench/libvirt_unixbench_test.sh \
  --version 6.0.1 --variant base \
  --results-dir /home/runner/libvirt-unixbench-results/6.0.1
```

内部实际执行：

```bash
LIBVIRT_VM_COUNT=48 LIBVIRT_COPIES=4 LIBVIRT_REPS=6 bash -c '
  source software/Virtualization/libvirt-unixbench/scripts/builders/dispatch.sh
  build_libvirt_unixbench'
python3 software/Virtualization/libvirt-unixbench/scripts/results/parse_benchmark.py \
  ${RESULTS_DIR}/runs ${RESULTS_DIR}/benchmark_unixbench.json ${RESULTS_DIR}/per-vm-scores.json
python3 software/Virtualization/libvirt-unixbench/scripts/results/standalone_runtime.py finalize \
  ${RESULTS_DIR} 6.0.1 aarch64 ${PERF_RUN_ID} passed passed ''
```

小规模本地复现可覆盖 `LIBVIRT_VM_COUNT=1 LIBVIRT_VM_CORES=4 LIBVIRT_COPIES=4`（轮次不能少于 6，
`LIBVIRT_WARMUP_REPS` 至少为 1）。`--keep-workdir` 保留 `${PERF_WORK_DIR}`；`optimized` 结果落
`results/<version>/optimized/` 且 `update_baseline=false`。

## 已知限制

- `optimized` 变体**尚未实现**，选择后构建阶段**明确失败**，不会退回基础版。
- 本用例不使用容器；宿主机只安装 libvirt/QEMU 与镜像、密钥、UnixBench 缓存，**不向宿主机**安装编译器或
  被测工具，**不修改宿主机**软件源、信任库与系统调优参数（仅按需打开 `net.ipv4.ip_forward` 以支撑 NAT）。
- 宿主机需要 `sudo -n virsh`（runner 用户免密）；缺失时 `require_libvirt_host` 以 30 退出。
- 虚拟机数量随宿主机核数变化，不同核数机器的 `libvirt.vm_count` 不同，跨架构只比较**同名同参**的指标。
- 宿主机没有 `/dev/kvm` 时（如 WSL 本地验证）自动退化为 TCG 并改用自定义 CPU 模型，此时数值仅用于打通流程，
  不作为性能结论。
- master 快照的 `maxCopies` 为 0（不限制），用例规定的 `sed` 因此是空操作；副本数由 `./Run -c 4` 决定。

## 故障排查

- `virsh` 报 `Authorization not available`：宿主机缺 polkit 或未使用 `sudo -n virsh`，按上文的 `require_*` 退出码定位。
- guest 拿不到 IP：确认 `default` 网络已 `net-start`、`net.ipv4.ip_forward=1`、guest 内 `NetworkManager` 未禁用 DHCP。
- guest 内 `dnf` 不可用：脚本会退化为离线 RPM 包集合安装；两者都失败时 test 阶段直接失败，不跳过。
