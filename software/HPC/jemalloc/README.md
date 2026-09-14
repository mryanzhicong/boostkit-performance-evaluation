# jemalloc 性能测试说明

本目录测试 jemalloc 官方源码 tarball（`5.3.1`，GitHub Releases 官方发布），
在隔离工作目录内以默认配置从源码构建，以业界经典的两类分配器负载为
基准，进行 x86_64 与 aarch64 开箱性能对比。软件入口为
`jemalloc_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 jemalloc `5.3.1`。新增版本时，必须同时在
`jemalloc_test.sh` 的 `jemalloc_tarball_sha256` 中声明官方 tarball 的
SHA-256，不能跳过校验。

## 构建与安装

jemalloc 是以 GitHub Releases 为官方分发渠道的 C 库，这里的“构建”是
在隔离工作目录内从官方源码构建库并编译基准应用（与 x264/x265 用例的
源码构建哲学一致），不在系统范围内安装任何 jemalloc 软件包：

1. 依次在以下位置获取官方源码 tarball：

   | 制品 | 官方地址 |
   |---|---|
   | `jemalloc-5.3.1.tar.bz2` | `https://github.com/jemalloc/jemalloc/releases/download/5.3.1/` |

   获取顺序：`/home/runner/software/jemalloc/` 本地离线包 → 任务工作
   目录已缓存副本 → 官方 GitHub Releases 下载。

2. 以 `jemalloc_tarball_sha256` 中声明的 SHA-256 校验（校验值取自
   官方发布制品，经官方 URL 下载实测），失败立即退出。

3. 源码构建全部隔离在工作目录内（out-of-tree）：

   ```bash
   mkdir -p "${PERF_WORK_DIR}/build"
   cd "${PERF_WORK_DIR}/build"
   "${SOURCE_DIR}/configure" --prefix="${PERF_WORK_DIR}/install" \
     --srcdir="${SOURCE_DIR}"
   make -j$(nproc)
   make install_bin install_lib install_include
   ```

   configure 不加任何调优选项（默认 arena 数、tcache、decay 等全部
   保持开箱默认）；`--prefix` 指向工作目录，`install_bin/lib/include`
   只安装运行必需的库与头文件，不触碰系统路径。

4. 基准应用源码位于 `src/jemalloc_benchmark.c`，以系统 gcc（缺失时
   通过 `dnf` 安装 `gcc`/`make`）静态链接工作目录内构建的
   `libjemalloc.a` 编译，不引入任何额外依赖：

   ```bash
   gcc -O2 -Wall -Wextra \
     -I "${PERF_WORK_DIR}/install/include" \
     -o "${PERF_WORK_DIR}/jemalloc_benchmark" \
     src/jemalloc_benchmark.c \
     "${PERF_WORK_DIR}/install/lib/libjemalloc.a" \
     -lpthread -lm
   ```

5. 通过官方运行时 API（`mallctl("version")`，返回
   `<版本>-<rev>-<hash>`，版本前缀必须精确匹配）验证版本：

   ```bash
   ${PERF_WORK_DIR}/jemalloc_benchmark --version
   # 输出必须以 jemalloc-version=5.3.1- 开头
   ```

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/jemalloc
sudo install -o runner -g runner jemalloc-5.3.1.tar.bz2 \
  /home/runner/software/jemalloc/
sha256sum /home/runner/software/jemalloc/*.tar.bz2
```

## 基准就绪（start）

jemalloc 基准没有常驻服务。`start` 阶段对两种负载各以最小配置
（2 线程、预热 1 秒 + 测量 2 秒）完整冒烟运行一次基准链路（线程池、
分配/释放循环、延迟采样、JSON 报告），校验报告字段全部为正后丢弃
冒烟产物；`test` 阶段只对已验证的组合计时。

## 性能测试

基准负载采用业界分配器评测的两类经典负载族（与学术文献
Larson & Krishnan 1998 及后续各类分配器对比评测所用的负载族一致）：

- **small**：短生命周期小对象（16-512 B），经每线程槽位环回收利用
  ——考验线程缓存（tcache）快速路径，对应通用应用的主导分配流量；
- **mixed**：大对象池（16 B - 256 KiB 对数均匀分布）随机替换
  ——考验 arena 扩展/收缩、size class 覆盖与碎片管理。

每个操作 = 释放受害槽位 + 分配新对象 + 触碰首部字节，以
`clock_gettime(CLOCK_MONOTONIC)` 计时（unit=ns，跨架构一致）；固定
线程池（线程阶梯档位即并发线程数）全速循环，测量窗口内计数并按
1/1024 全局节拍采样单次操作延迟。

场景矩阵以 mysql 用例的阶梯方式组织：**负载（small / mixed）× 线程数
（1 / 4 / 16 / 64）**，共 8 组，每组独立进程（预热 5 秒 + 测量 30 秒，
`JEMALLOC_WARMUP_SECONDS` / `JEMALLOC_DURATION_SECONDS` 可覆盖）：

```bash
${PERF_WORK_DIR}/jemalloc_benchmark \
  --workload small --threads 16 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "small" --output benchmark/runs/small-t16.json
```

任何分配失败或零操作即判失败。每组运行输出一个 JSON 报告，完整控制
台输出保留为 `jemalloc_alloc_raw.log`，全部报告由
`scripts/collect_jemalloc_benchmark.py` 校验（负载、线程数与文件名一致，
所有数值为正）并汇总为 `results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/HPC/jemalloc/jemalloc_test.sh \
  --version 5.3.1 \
  --results-dir /home/runner/boostkit-perf/jemalloc/results/5.3.1
```

## 指标

每个“负载 + 线程档位”组合保留 3 个字段，不做平均、加权或跨场景
聚合。总计为：

```text
2 个负载场景 × 4 个线程档位 × 3 个指标 = 24 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `operations_per_second` | `jemalloc <负载> --threads=<线程数>: ops/s` | ops/s | 越大越好 | 每秒完成的分配+释放操作数 |
| `avg_op_ns` | `jemalloc <负载> --threads=<线程数>: avg op` | ns | 越小越好 | 采样操作的平均耗时 |
| `p99_op_ns` | `jemalloc <负载> --threads=<线程数>: p99 op` | ns | 越小越好 | 采样操作耗时的 99 分位 |

报告按负载场景（small / mixed）分组；每个场景中再按线程数展示吞吐
与两项延迟，便于在相同负载下比较 x86_64 与 aarch64。基准参数
（官方源码默认 configure、CLOCK_MONOTONIC 计时、预热与测量时长）
记录在 `results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `jemalloc_alloc_raw.log`：8 组运行的原始控制台输出；
- `results.json`：24 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（基准生命周期在各测量进程内），仅
移除本次任务的基准数据目录（运行报告与冒烟产物）。Standalone 模式
结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/jemalloc/local-*` 工作目录（含官方源码、
构建产物、安装树、编译基准与运行数据）；Framework 随后执行 Runner 级
环境清理。
