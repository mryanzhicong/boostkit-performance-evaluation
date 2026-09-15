# DPDK 性能测试说明

本目录测试 DPDK 官方源码 tarball（`26.07`，dpdk.org 官方发布），在隔离
工作目录内以官方 meson 默认配置从源码构建，以三大核心数据面库的经典
负载为基准，进行 x86_64 与 aarch64 开箱性能对比。软件入口为
`dpdk_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 DPDK `26.07`。新增版本时，必须同时在 `dpdk_test.sh`
的 `dpdk_tarball_sha256` 中声明官方 tarball 的 SHA-256，不能跳过校验。

## 构建与安装

DPDK 是以 dpdk.org（`https://fast.dpdk.org/rel/`）为官方分发渠道的
C 语言框架，这里的“构建”是在隔离工作目录内从官方源码构建库并编译
基准应用（与 x264/x265、jemalloc 用例的源码构建哲学一致），不在系统
范围内安装任何 DPDK 软件包：

1. 依次在以下位置获取官方源码 tarball：

   | 制品 | 官方地址 |
   |---|---|
   | `dpdk-26.07.tar.xz` | `https://fast.dpdk.org/rel/dpdk-26.07.tar.xz` |

   获取顺序：`/home/runner/software/dpdk/` 本地离线包 → 任务工作
   目录已缓存副本 → 官方 dpdk.org 下载。

2. 以 `dpdk_tarball_sha256` 中声明的 SHA-256 校验（校验值取自官方
   发布制品，经官方 URL 下载实测），失败立即退出。

3. 源码构建全部隔离在工作目录内（out-of-tree），使用官方 meson
   默认配置，仅设置 `--prefix` 与 `-Dmax_numa_nodes=1`：

   ```bash
   cd "${PERF_WORK_DIR}/dpdk-26.07"
   meson setup "${PERF_WORK_DIR}/build" \
     --prefix="${PERF_WORK_DIR}/install" -Dmax_numa_nodes=1
   ninja -C "${PERF_WORK_DIR}/build" -j$(nproc)
   meson install -C "${PERF_WORK_DIR}/build"
   ```

   `max_numa_nodes=1` 是官方文档声明的单 NUMA 节点构建选项：消除对
   可选 libnuma 开发包的依赖，并使构建在每台主机上完全一致。其余
   全部保持 meson 默认（`platform=native`、默认驱动集、默认优化）。

   构建依赖 `meson`、`ninja`、`pkg-config` 与 Python 的 `elftools`
   模块（`python3-pyelftools`）；缺失时脚本经 `dnf` 安装（与 gcc 等
   先例一致）。

4. 基准应用源码位于 `src/dpdk_benchmark.c`，经官方 pkg-config 元数据
   （`libdpdk.pc`）链接工作目录内构建的 DPDK 库，不引入任何额外
   依赖：

   ```bash
   export PKG_CONFIG_PATH="$(find "${PERF_WORK_DIR}/install" \
     -name libdpdk.pc -exec dirname {} \; | head -n1)"
   gcc -O2 -Wall -Wextra $(pkg-config --cflags libdpdk) \
     -o "${PERF_WORK_DIR}/dpdk_benchmark" \
     src/dpdk_benchmark.c $(pkg-config --libs libdpdk) \
     -Wl,-rpath,$(pkg-config --variable=libdir libdpdk) -lpthread
   ```

5. 通过官方运行时 API（`rte_version()`，返回 `DPDK <主>.<次>.<修订>`，
   主.次版本必须精确匹配）验证版本：

   ```bash
   ${PERF_WORK_DIR}/dpdk_benchmark --version
   # 输出必须形如 dpdk-version=DPDK 26.07.0
   ```

注意：DPDK EAL 出于安全检查拒绝加载位于 world-writable 目录（如
`/tmp`）下的插件路径，脚本会在构建前拒绝这类工作目录；默认工作目录
`/home/runner/boostkit-perf/dpdk/local-*` 不受影响。

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/dpdk
sudo install -o runner -g runner dpdk-26.07.tar.xz \
  /home/runner/software/dpdk/
sha256sum /home/runner/software/dpdk/*.tar.xz
```

## 基准就绪（start）

DPDK 基准没有常驻服务。`start` 阶段对三种负载各以最小配置
（2 线程、预热 1 秒 + 测量 2 秒）完整冒烟运行一次基准链路（EAL 初始化、
对象预填充、分配/查找循环、延迟采样、JSON 报告），校验报告字段全部为
正后丢弃冒烟产物；`test` 阶段只对已验证的组合计时。

## 性能测试

基准负载为 DPDK 三大核心数据面库的经典工作负载（每个 DPDK 分组处理
应用都建立在它们之上）：

- **ring**：`rte_ring` SP/SC 模式环形队列，burst 32 入队+出队，每个
  工作线程独占一个环对——真实 DPDK 部署的流水线阶段形态（环形队列按
  阶段对分配，工作线程跑在专用核上，绝不超订阅）；1 op = 1 个元素
  完成入队+出队（按 burst 摊销计时）；
- **hash**：`rte_hash` 流表查找，预填充 256k 条目、16 字节键，
  7/8 命中——OVS/vSwitch 类应用的流表查找形态；
- **lpm**：`rte_lpm` IPv4 路由查找，预填充 64k 条 /24 路由，
  7/8 命中——DPDK 路由查找基准的标准形态。

EAL 以 `--no-huge --in-memory -l 0 -m 1024` 初始化：不依赖主机
hugepage 配置、不产生运行时文件、不受 lcore 发现影响；工作线程为
普通 pthread（三类库从任意线程调用均安全，全部写操作发生在预填充
阶段）。EAL 会把主线程钉在 lcore 0 对应的 CPU 上，基准在 EAL 初始化
前保存、初始化后恢复线程亲和性，确保工作线程继承完整 CPU 掩码。

每个操作以 `clock_gettime(CLOCK_MONOTONIC)` 计时（unit=ns，跨架构
一致）；固定线程池（线程阶梯档位即并发线程数）全速循环，测量窗口内
计数并按 1/1024 全局节拍采样单次操作延迟。

场景矩阵以 mysql 用例的阶梯方式组织：**负载（ring / hash / lpm）×
线程数（1 / 4 / 16 / 64）**，共 12 组，每组独立进程（预热 5 秒 +
测量 30 秒，`DPDK_WARMUP_SECONDS` / `DPDK_DURATION_SECONDS` 可覆盖）：

```bash
${PERF_WORK_DIR}/dpdk_benchmark \
  --workload ring --threads 16 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "ring" --output benchmark/runs/ring-t16.json
```

任何分配失败或零操作即判失败。每组运行输出一个 JSON 报告，完整控制
台输出保留为 `dpdk_dataplane_raw.log`，全部报告由
`scripts/collect_dpdk_benchmark.py` 校验（负载、线程数与文件名一致，
所有数值为正）并汇总为 `results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/dpdk/dpdk_test.sh \
  --version 26.07 \
  --results-dir /home/runner/boostkit-perf/dpdk/results/26.07
```

## 指标

每个“负载 + 线程档位”组合保留 3 个字段，不做平均、加权或跨场景
聚合。总计为：

```text
3 个负载场景 × 4 个线程档位 × 3 个指标 = 36 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `operations_per_second` | `dpdk <负载> --threads=<线程数>: ops/s` | ops/s | 越大越好 | 每秒完成的操作数 |
| `avg_op_ns` | `dpdk <负载> --threads=<线程数>: avg op` | ns | 越小越好 | 采样操作的平均耗时 |
| `p99_op_ns` | `dpdk <负载> --threads=<线程数>: p99 op` | ns | 越小越好 | 采样操作耗时的 99 分位 |

报告按负载场景（ring / hash / lpm）分组；每个场景中再按线程数展示
吞吐与两项延迟，便于在相同负载下比较 x86_64 与 aarch64。基准参数
（官方源码 meson 默认构建、EAL 参数、CLOCK_MONOTONIC 计时、预热与
测量时长）记录在 `results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `dpdk_dataplane_raw.log`：12 组运行的原始控制台输出；
- `results.json`：36 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（基准生命周期在各测量进程内），仅
移除本次任务的基准数据目录（运行报告与冒烟产物）。Standalone 模式
结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/dpdk/local-*` 工作目录（含官方源码、
构建产物、安装树、编译基准与运行数据）；Framework 随后执行 Runner 级
环境清理。
