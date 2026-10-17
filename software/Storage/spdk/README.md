# SPDK 性能测试说明

本目录测试 SPDK 官方 git 仓库（`26.05`，github.com/spdk/spdk 官方
tag），在隔离工作目录内以官方 configure 默认配置从源码构建，以
blobstore（SPDK 本地存储对象层）的三大经典负载为基准，进行 x86_64
与 aarch64 开箱性能对比。软件入口为 `spdk_test.sh`，Framework 通过
`case.yaml` 调用其 `build`、`start`、`test`、`stop` 四个阶段；直接
执行该脚本也使用同一套阶段函数。

当前清单仅声明 SPDK `26.05`。新增版本时，必须确认官方仓库存在对应
`v<版本>` tag 并更新本说明与 `case.yaml` 的版本清单。

## 构建与安装

SPDK 是以 github.com/spdk/spdk（官方 git 仓库 + dpdk/isa-l 子模块）
为官方分发渠道的 C 语言框架，这里的“构建”是在隔离工作目录内从官方
tag 源码构建库并编译基准应用（与 dpdk、jemalloc 用例的源码构建哲学
一致），不在系统范围内安装任何 SPDK 软件包：

1. 依次在以下位置获取官方源码：

   | 制品 | 官方地址 |
   |---|---|
   | `spdk` v26.05 源码树 | `https://github.com/spdk/spdk`（tag `v26.05`） |

   获取顺序：`/home/runner/software/spdk/` 本地离线树 → 任务工作
   目录已缓存副本 → 官方 GitHub 浅克隆（`git clone --depth 1
   --branch v26.05`）。克隆后以 `git describe --tags
   --exact-match` 校验 tag 精确匹配（git tag 语义校验，等价于其它
   用例的 tarball SHA-256），再初始化构建必需的 `dpdk` 子模块
   （同样浅克隆官方上游；isa-l 等可选子模块不需要——只构建库层）。

2. 以官方 configure 默认配置构建，仅关闭本基准不涉及的 optional
   外部依赖与测试/示例/应用目标（vhost、virtio、vfio-user、
   crypto、uring、rdma、iscsi、ocf、xnvme、rbd、daos、ublk、
   nvme-cuse、usdt、sma、avahi、golang、aio-fsdev、idxd、fio、
   vtune、dpdk-compressdev、dpdk-uadk、raid5f；tests、unit-tests、
   examples、apps）。只构建库层（`make -C dpdkbuild` 构建 dpdk 子
   模块、`make -C lib` 构建 SPDK 库层）：基准链接 `build/lib/` 内
   blob 闭包静态库，bdev/event 模块层（及其额外外部依赖如
   libaio）完全不需要：

   ```bash
   cd "${PERF_WORK_DIR}/spdk-26.05"
   ./configure --disable-tests --disable-unit-tests \
     --disable-examples --disable-apps --without-vhost \
     --without-virtio --without-vfio-user --without-fsdev \
     --without-crypto --without-uring --without-rdma \
     --without-iscsi-initiator --without-ocf --without-xnvme \
     --without-rbd --without-daos --without-ublk \
     --without-nvme-cuse --without-usdt --without-sma \
     --without-avahi --without-golang --without-aio-fsdev \
     --without-idxd --without-fio --without-vtune \
     --without-dpdk-compressdev --without-dpdk-uadk \
     --without-raid5f
   make -C dpdkbuild DPDKBUILD_FLAGS="-Dmax_numa_nodes=1" -j$(nproc)
   make -C lib -j$(nproc)
   ```

   `DPDKBUILD_FLAGS` 是 SPDK 官方构建体系预留的 dpdk meson 附加
   选项变量；`-Dmax_numa_nodes=1` 是 dpdk 官方文档声明的单 NUMA
   节点构建选项：消除对可选 libnuma 开发包的依赖，并使构建在每台
   主机上完全一致。构建不执行 `make install`，库产物保留在源码树
   `build/lib/` 内，基准直接对该构建产物链接。

   构建依赖 `git`、`gcc`、`make`、`meson`、`ninja`、`pkg-config`、
   Python 的 `elftools`/`jinja2`/`tabulate` 模块与 openssl、libuuid
   开发头（SPDK 的 uuid/md5 辅助库使用）；缺失时脚本经 `dnf` 安装
   （与 dpdk 用例先例一致）。libnuma、CUnit、libaio、nasm 均不需要
   （模块层与 isa-l 不构建）。

3. 基准应用源码位于 `src/spdk_benchmark.c`，直接链接工作目录内
   构建的 SPDK 静态库（blob 及其依赖闭包）与 dpdk 官方
   `libdpdk.pc` 元数据描述的静态库集，不引入任何额外依赖：

   ```bash
   gcc -O2 -Wall -Wextra -I"${SOURCE_DIR}/include" $(pkg-config \
     --cflags libdpdk) -o "${PERF_WORK_DIR}/spdk_benchmark" \
     src/spdk_benchmark.c -L"${SOURCE_DIR}/build/lib" \
     -Wl,--whole-archive -Wl,--no-as-needed \
     -lspdk_blob -lspdk_thread -lspdk_trace -lspdk_rpc \
     -lspdk_jsonrpc -lspdk_json -lspdk_dma -lspdk_util \
     -lspdk_log -lspdk_env_dpdk \
     -Wl,--no-whole-archive $(pkg-config --libs --static libdpdk) \
     -lssl -lcrypto -luuid -lpthread -ldl -lrt -lm
   ```

4. 通过官方运行时版本宏（`SPDK_VERSION_STRING`，返回
   `SPDK <主>.<次>.<修订>`，主.次版本必须精确匹配）验证版本：

   ```bash
   ${PERF_WORK_DIR}/spdk_benchmark --version
   # 输出必须形如 spdk-version=SPDK v26.05.0
   ```

在 Runner 预置离线源码树时：

```bash
sudo install -d -o runner -g runner /home/runner/software/spdk
sudo cp -a spdk-26.05 /home/runner/software/spdk/
# 源码树需含已初始化的 dpdk 子模块内容
```

## 基准就绪（start）

SPDK 基准没有常驻服务。`start` 阶段对三种负载各以最小配置
（2 线程、预热 1 秒 + 测量 2 秒）完整冒烟运行一次基准链路（env
初始化、blobstore 创建、blob 生命周期/读写循环、延迟采样、JSON
报告），校验报告字段全部为正后丢弃冒烟产物；`test` 阶段只对已
验证的组合计时。

## 性能测试

基准负载为 SPDK blobstore 的三大经典工作负载（每个 SPDK blob
应用都建立在它们之上）：

- **create**：`spdk_bs_create_blob` + `spdk_bs_delete_blob` 完整
  生命周期——每次 blob 供给（provision）都走过的元数据路径；
  1 op = 1 个 blob 创建+删除（元数据页循环复用而不是耗尽）；
- **write**：4KiB `spdk_blob_io_write`，队列深度 8，对预分配的
  4MiB blob 顺序写入——blob 数据写路径；
- **read**：4KiB `spdk_blob_io_read`，队列深度 8，同一 blob——
  blob 读路径。

每个工作线程独占一个 blobstore 实例（在自身的 `spdk_thread` 上
创建并驱动）：blobstore 元数据操作固定在初始化线程上执行，每实例
一线程正是真实应用跨核扩展 blob I/O 的部署形态（与 dpdk 用例
per-worker SP/SC 环的哲学一致）。后端 `spdk_bs_dev` 为匿名内存
块设备（512B 块、256MiB、按需物理分配），不触碰主机存储；环境层
经 `spdk_env_dpdk` 以 no-huge / no-pci / 1GiB / 单 lcore 初始化，
不依赖主机 hugepage 配置，也不探测 PCI 设备。EAL 会把主线程钉在
lcore 0 对应的 CPU 上，基准在 env 初始化前保存、初始化后恢复线程
亲和性，确保工作线程继承完整 CPU 掩码。

两项线程模型细节保证 64 线程档位在 16 核超订阅下的稳定性（与
dpdk 用例在 64 线程超订阅下改用每线程独占 SP/SC 环的经验对应）：

- 每个工作线程启动时以 `rte_thread_register()` 注册为 DPDK 非
  EAL 线程，获得独立 lcore 身份：SPDK 线程库的消息对象取自共享
  DPDK mempool，无 lcore 身份的线程会全部落到 mempool 公共池的
  MP/SC 路径，在超订阅下 CAS 争用坍塌（每线程独立 per-lcore
  cache 即消除该争用；注册只做 lcore 记账，不改线程亲和性）；
- 每工作线程一次性的 blobstore 创建/卸载持有互斥锁串行执行
  （SPDK 全局对象簿记内部为自旋锁，数十线程同时触碰会在超订阅
  下活锁），测量期运行循环完全并行、不触碰该锁。

每个操作以 `clock_gettime(CLOCK_MONOTONIC)` 计时（unit=ns，跨架构
一致）；固定线程池（线程阶梯档位即并发线程数）异步流水线全速循环，
测量窗口内计数并按 1/1024 全局节拍采样单次操作延迟。

场景矩阵以 mysql 用例的阶梯方式组织：**负载（create / write /
read）× 线程数（1 / 4 / 16 / 64）**，共 12 组，每组独立进程（预热
5 秒 + 测量 30 秒，`SPDK_WARMUP_SECONDS` / `SPDK_DURATION_SECONDS`
可覆盖）：

```bash
${PERF_WORK_DIR}/spdk_benchmark \
  --workload write --threads 16 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "write" --output benchmark/runs/write-t16.json
```

任何分配失败或零操作即判失败。每组运行输出一个 JSON 报告，完整控制
台输出保留为 `spdk_blobstore_raw.log`，全部报告由
`scripts/collect_spdk_benchmark.py` 校验（负载、线程数与文件名一致，
所有数值为正）并汇总为 `results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Storage/spdk/spdk_test.sh \
  --version 26.05 \
  --results-dir /home/runner/boostkit-perf/spdk/results/26.05
```

## 指标

每个“负载 + 线程档位”组合保留 3 个字段，不做平均、加权或跨场景
聚合。总计为：

```text
3 个负载场景 × 4 个线程档位 × 3 个指标 = 36 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `operations_per_second` | `spdk <负载> --threads=<线程数>: ops/s` | ops/s | 越大越好 | 每秒完成的操作数 |
| `avg_op_ns` | `spdk <负载> --threads=<线程数>: avg op` | ns | 越小越好 | 采样操作的平均耗时 |
| `p99_op_ns` | `spdk <负载> --threads=<线程数>: p99 op` | ns | 越小越好 | 采样操作耗时的 99 分位 |

报告按负载场景（create / write / read）分组；每个场景中再按线程数
展示吞吐与两项延迟，便于在相同负载下比较 x86_64 与 aarch64。基准
参数（官方 tag 源码 configure 默认构建、每线程独立 blobstore、
no-huge 环境、CLOCK_MONOTONIC 计时、预热与测量时长）记录在
`results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `spdk_blobstore_raw.log`：12 组运行的原始控制台输出；
- `results.json`：36 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（基准生命周期在各测量进程内），仅
移除本次任务的基准数据目录（运行报告与冒烟产物）。Standalone 模式
结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/spdk/local-*` 工作目录（含官方源码、
子模块、构建产物、编译基准与运行数据）；Framework 随后执行 Runner
级环境清理。
