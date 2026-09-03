# RocksDB 性能测试说明

本目录从 RocksDB 官方仓库构建指定版本，并使用构建产物 `db_bench` 执行单机
KV 性能测试。RocksDB 是嵌入式数据库，不启动网络服务；Framework 的四阶段分别是
构建、准备任务私有数据目录、执行 `db_bench`、删除该数据目录。直接执行
`rocksdb_test.sh` 也复用相同阶段，并生成单架构报告。

报告“测试工具”栏展示 `db_bench`，它与当前构建的 RocksDB 版本相同。

## 构建

脚本克隆官方 `facebook/rocksdb` 的 `v<版本>` 标签，并使用 Release 配置构建
官方 `db_bench` target：

```bash
git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
  https://github.com/facebook/rocksdb.git rocksdb-source
cmake -S rocksdb-source -B rocksdb-build \
  -DCMAKE_BUILD_TYPE=Release \
  -DFAIL_ON_WARNINGS=OFF
cmake --build rocksdb-build --target db_bench --parallel "$(nproc)"
```

脚本从 `include/rocksdb/version.h` 读取实际版本，必须与请求版本完全一致。
`FAIL_ON_WARNINGS=OFF` 保留编译器诊断，但不会将已知的 GCC 12 `restrict` 诊断升级
为构建错误。
缺失的构建依赖由脚本通过 `dnf` 或 `sudo -n dnf` 自动安装：编译工具链、CMake、
gflags、Snappy、zlib、bzip2、LZ4 和 Zstandard 开发包。

源码和构建产物位于任务工作目录；它们可以使用 `/tmp`。实际数据库与 WAL 数据
**不**使用 `/tmp`，而是位于：

```text
${PERF_WORK_DIR}/data/
```

该目录只属于当前运行 ID，`stop` 阶段只删除这个精确目录，不会格式化磁盘、卸载
文件系统或影响其他 RocksDB 数据。

## 性能测试

测试方案按照 `database_blue` 的 RocksDB **开源基线**参数矩阵实现。每组 KV 规格
依次执行 `pre_fillseq`、`pre_overwrite`，再执行 1 和 16 线程的 `overwrite`、
`readrandom`、`readrandomwriterandom`：

| KV 规格 | 场景数 | 正式负载 |
|---|---:|---|
| 64B Key / 128B Value | 8 | `overwrite`、`readrandom`、`readrandomwriterandom`，各 1/16 线程 |
| 64B Key / 512B Value | 8 | 同上 |
| 128B Key / 1024B Value | 8 | 同上 |

因此每个架构会执行 24 条 `db_bench` 命令：每组规格两条预埋命令与六条 60 秒正式
负载。每一组规格均从空目录开始，完成后才进入下一组；数据和 WAL 均在当前运行的
任务私有目录中，不会使用 `/tmp`。

入口脚本保留 `database_blue` 的场景和主要 LSM/DIO 参数，并将工作流负载缩放为
`num=10000000`、正式负载时长 60 秒、1 GiB 缓存，以便在两种架构上完成整套矩阵。
混合读写比仍为 70:30，不绑定 CPU，由 runner 按其正常调度策略执行。单条命令的
形态如下：

```bash
db_bench \
  --db="${ROCKSDB_BENCH_DATA_DIR}/key-64B-value-128B" \
  --wal_dir="${ROCKSDB_BENCH_DATA_DIR}/key-64B-value-128B" \
  --benchmarks=readrandomwriterandom,stats \
  --num=10000000 --key_size=64 --value_size=128 \
  --threads=16 --duration=60 --readwritepercent=70 \
  --compression_type=none --use_direct_reads=true \
  --use_direct_io_for_flush_and_compaction=true
```

原始方案会格式化、挂载专用 NVMe，并使用 KSAL 版本与鲲鹏专属资源采集。这里保留
可跨架构复现的开源 `db_bench` 命令与参数，明确不执行格式化磁盘、卸载文件系统、
KSAL 切换和专属采集。`use_direct_writes` 属于其旧版/定制 `db_bench` 参数，当前
官方 11.8.1 `db_bench` 不支持，故不传入。任何命令失败、结果行不唯一、或指标为空/
非正，都会使测试失败。

## 指标

每一个 `database_blue` 场景保留以下两个原始结果字段，共 48 项指标；不做评分、
比例或跨场景聚合。报告按 KV 规格分表展示。

| 原始字段 | 报告指标名 | 单位 | 优化方向 |
|---|---|---|---|
| `micros/op` | `<场景> micros/op` | micros/op | 越小越好 |
| `ops/sec` | `<场景> ops/sec` | ops/sec | 越大越好 |

`db_bench_raw.log` 保存每条实际执行命令及其完整原始输出；`results.json` 保存
严格校验后的结构化指标、KV 规格和完整负载参数。

## 独立执行

```bash
bash software/Database/rocksdb/rocksdb_test.sh \
  --version 11.8.1 \
  --results-dir /home/runner/boostkit-perf/rocksdb/results/11.8.1
```

独立执行依次完成环境采集、构建、数据准备、测试、数据清理、结果校验和报告生成。
默认会同时清理其自行创建的 `/home/runner/boostkit-perf/rocksdb/local-*` 构建目录；需要保留该目录
排查构建问题时，追加 `--keep-workdir`。
