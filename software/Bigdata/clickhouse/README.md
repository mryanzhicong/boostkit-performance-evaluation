# ClickHouse 24.5.1.1763 性能测试

本用例在单容器内运行单节点 ClickHouse 24.5.1.1763，用 TPC-H 22 条查询测量
SF1 数据量下的查询耗时：主指标是 22 条查询的服务端耗时合计，辅助指标是每条查询
的中位耗时。ClickHouse 的安装包、容器和正式测试都在本次任务的私有容器内完成；
`start`、`test`、`stop` 复用 `build` 创建的那一个容器。

容器规格固定为 32 个物理核（单 NUMA 节点）、128 GiB 内存、不限 memlock。
**不修改任何内核参数**：THP、swap、`sysctl`、`limits.conf`、`drop_caches` 与
BIOS/电源策略保持 Runner 原状，只在结果目录记录实际值。软件侧参数
（`max_threads=32`、内存上限、`mark_cache_size`、三条 TPC-H 查询设置）按 bdperf
文档 §7.2 固定，两侧必须一致。

入口为 `clickhouse_test.sh`。Framework 按 `case.yaml` 调用 build、start、test、
stop 四个函数，独立入口调用同一组函数。`scripts/builders/base.sh` 负责镜像与三个
官方 tgz 的准备，`scripts/stages/` 负责配置、启动、造数、跑查询和清理，
`scripts/results/` 负责解析。`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| ClickHouse | 官方 tgz：`clickhouse-{common-static,server,client}-24.5.1.1763-{amd64,arm64}.tgz`，来自 `https://packages.clickhouse.com/tgz/stable/` | 优先读取 `/home/runner/software/clickhouse/`；缺失才下载到 `${PERF_WORK_DIR}/ch-pkgs` |
| 容器镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 及同名 `.sha256sum` |
| 数据生成 | [tpch-kit](https://codeload.github.com/gregrahn/tpch-kit/zip/refs/heads/master) 的 `dbgen` | 优先读取 `/home/runner/software/tpch/tpch-kit-master.zip`；缺失才下载到 `${PERF_WORK_DIR}` |
| 查询 | 本用例 `scripts/queries/q1.sql` … `q22.sql` | 其中 q2/q4/q17/q19/q20/q21/q22 为 ClickHouse 适配版，结果已与 TPC-H 官方答案对齐 |

ClickHouse 官方只为源码发布 `sha256`，tgz 没有独立的校验文件。本用例在适配时从
`packages.clickhouse.com` 下载三个官方包并计算 SHA-256，固定写在
`scripts/common.sh` 的 `ch_package_sha256` 中；每次构建都先校验再解包。文件名
与校验值随请求版本、架构固定，不允许用其他来源的同名包替代。

离线目录可用环境变量指向其他位置：`CLICKHOUSE_OFFLINE_DIR`、
`CLICKHOUSE_TPCH_OFFLINE_DIR`、`CLICKHOUSE_IMAGE_ARCHIVE_DIR`、
`CLICKHOUSE_CA_ANCHORS_DIR`。生产 Runner 使用上表默认值。

## 获取、构建与容器启动

脚本先检查 Docker daemon，再按与 ZooKeeper 用例相同的方式加载 openEuler 镜像：
核对 `.sha256sum`、`docker load`、检查镜像架构和容器内 `/etc/os-release`。

三个官方 tgz 解包到 `${PERF_WORK_DIR}/ch-pkgs`；`clickhouse` 是 multiplexer 二进制，
三个包里的同名文件只取 `common-static` 那一份，`server`/`client` 包仅用于满足
发行版布局。实际使用的命令是：

```bash
tar -xzf "${CH_PKG_DIR}/clickhouse-common-static-24.5.1.1763-${CH_PACKAGE_ARCH}.tgz" -C "${CH_PKG_DIR}"
tar -xzf "${CH_PKG_DIR}/clickhouse-server-24.5.1.1763-${CH_PACKAGE_ARCH}.tgz" -C "${CH_PKG_DIR}"
tar -xzf "${CH_PKG_DIR}/clickhouse-client-24.5.1.1763-${CH_PACKAGE_ARCH}.tgz" -C "${CH_PKG_DIR}"
ln -sfn "${CH_PKG_DIR}/clickhouse-common-static-24.5.1.1763/usr/bin/clickhouse" "${CH_BIN}"
"${CH_BIN}" --version
```

版本从解包后的二进制读取，写入 `PERF_ACTUAL_VERSION_FILE`；`build` 成功后写
`build_variant.json`。

容器名称为 `boostkit-clickhouse-<架构>-<run-id>`，创建命令与 ZooKeeper 用例一致：
`--network=host`、Runner UID/GID、`--cpuset-cpus=0-31`、`--cpuset-mems=0`、
`--memory=128g --memory-swap=128g`、`--ulimit nofile=1048576:1048576`、
`--ulimit memlock=-1:-1`、工作目录与结果目录同路径挂载，不加 `--privileged`。
开发机做冒烟时可用 `CLICKHOUSE_CPUSET`、`CLICKHOUSE_MEMSET`、
`CLICKHOUSE_MEMORY`、`CLICKHOUSE_MEMORY_SWAP` 覆盖，并在结果里注明；
正式 Runner 必须使用默认值。

代理存在时，CA 证书目录只读挂载并在容器内 `update-ca-trust extract`；没有代理
时不挂载证书目录。

## 启动

`start` 校验容器正在运行且标签属于本任务，写入 `config.xml` 与 `users.xml`：

```xml
<tcp_port>19000+offset</tcp_port>
<http_port>19500+offset</http_port>
<listen_host>127.0.0.1</listen_host>
<path>${CH_DATA}/data/</path>
<tmp_path>${CH_DATA}/tmp/</tmp_path>
<user_files_path>${CH_DATA}/user_files/</user_files_path>
<max_server_memory_usage>120000000000</max_server_memory_usage>
<mark_cache_size>5368709120</mark_cache_size>
<query_log><database>system</database><table>query_log</table></query_log>
<metric_log><database>system</database><table>metric_log</table></metric_log>
```

`users.xml` 的 `default` profile 固定：

```xml
<max_threads>32</max_threads>
<max_memory_usage>110000000000</max_memory_usage>
<max_bytes_before_external_group_by>40000000000</max_bytes_before_external_group_by>
<max_bytes_before_external_sort>40000000000</max_bytes_before_external_sort>
<join_algorithm>parallel_hash</join_algorithm>
<preferred_block_size_bytes>2000000</preferred_block_size_bytes>
<allow_asynchronous_read_from_io_pool_for_merge_tree>true</allow_asynchronous_read_from_io_pool_for_merge_tree>
```

端口不使用 9000/8123：9000 在多组件同机时可能被 HDFS NameNode 占用，且同机
并行任务需要隔离；`tcp_port` 由 run ID 派生到 19000–19399，`http_port` 到
19500–19899，均绑定 `127.0.0.1`。启动命令：

```bash
docker exec --detach -e HOME="${PERF_WORK_DIR}" \
  "${CH_CONTAINER_NAME}" sh -c \
  "exec '${CH_BIN}' server --config-file='${CH_CONF}' >>'${CH_LOG_DIR}/stdout.log' 2>&1"
```

就绪判断是有界轮询，不是固定 `sleep`：最多 120 秒内反复执行
`clickhouse client --host 127.0.0.1 --port <tcp_port> --query 'SELECT 1'`，返回 1
才算就绪；随后把 `version()/timezone()/uptime()` 与三项固定设置的查询结果写入
`${CH_RESULT_DIR}/server_settings.txt`。

## 测试负载

1. 在容器内编译 `dbgen`（缺 gcc/make 时先 `dnf install`），生成 SF1 数据到
   `${PERF_WORK_DIR}/tpch-data/sf1`，并删除每行末尾的 `|`。
2. 建库 `${CH_DATABASE}`（`tpch_sf1`）与 8 张 MergeTree 表，全部 `ORDER BY` 主键，
   不设分区键；金额列 `Decimal(15,2)`、日期列 `Date`、`l_orderkey/o_orderkey` 为
   `Int64`，其余整数 `Int32`。同时创建 q15 依赖的视图 `revenue0`。
3. 逐表 `INSERT INTO ... FORMAT CSV` 导入，`--format_csv_delimiter='|'`。
4. 校验 SF1 行数：lineitem 6,001,215、orders 1,500,000、partsupp 800,000、
   part 200,000、customer 150,000、supplier 10,000、nation 25、region 5。
5. 22 条查询串行执行 3 轮，每条查询带唯一 `query_id=ck-<run-id>-r<轮>-q<编号>`；
   每轮结束后 `SYSTEM FLUSH LOGS`，从 `system.query_log` 按 `QueryFinish` 和
   `query_id` 前缀取 `query_duration_ms`，写入 `${CH_RESULT_DIR}/query_log.tsv`。

计时口径是**服务端** `query_duration_ms`，不是 `curl` 端到端；因此与 Doris 用例的
端到端 wall 不可横向比较，只各自算跨架构比值。单条查询失败、查询日志缺项或行数
不符都会让测试失败。

## 指标与产物

| 指标 | 原始字段 | 单位 | 方向 |
|---|---|---|---|
| `tpch-22-total/total_time` | 22 条 `query_duration_ms` 每轮求和后取中位数 ÷ 1000 | s | 越小越好 |
| `tpch-qNN/duration_ms` | 每条查询 3 轮 `query_duration_ms` 的中位数 | ms | 越小越好 |

共 23 项指标，分组为 `tpch-22-total` 与 `tpch-qNN`。固定负载参数写入 JSON 的
`parameters`：SF、轮次、查询数、`max_threads`、内存上限、三条查询设置和计时口径。
解析器会拒绝：轮次或查询缺失、重复记录、非正/非有限耗时、查询编号越界。

| 产物 | 内容 |
|---|---|
| `clickhouse-official/query_log.tsv` | 每轮 22 条的 `query_id`、耗时、扫描行数、内存 |
| `clickhouse-official/server_settings.txt` | 版本、时区、uptime 与固定设置 |
| `benchmark_clickhouse_raw.log` | 设置、查询日志与失败查询的完整输出 |
| `benchmark_clickhouse.json` | 23 项指标与固定负载参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `service-logs/` | 停止阶段保存的 ClickHouse 日志 |
| `results.json`、`report.md` | 独立入口生成的结果与报告 |

脱离 Workflow 执行完整流程：

```bash
bash software/Bigdata/clickhouse/clickhouse_test.sh \
  --version 24.5.1.1763 \
  --variant base \
  --results-dir /home/runner/clickhouse-results/24.5.1.1763
```

独立运行可用 `--keep-workdir` 保留私有工作目录；默认只删除本次独立运行创建的
`/home/runner/boostkit-perf/clickhouse/local-*`，调用者指定的目录不会被删除。

## 与 bdperf 参考文档的差异

| 项目 | bdperf `03_ClickHouse单容器性能测试.md` | 本用例 | 原因 |
|---|---|---|---|
| 内核 / 系统调优 | THP=always、swapoff、`sysctl`、`limits.conf`、BIOS 电源策略 | **全部不做**，只记录 | 本仓库禁止修改内核参数 |
| 容器规格 | 32U/128G（未写 cpuset 细节），`--privileged` | 32U/128G + cpuset 保留；**去掉 privileged** | 不再需要特权操作 |
| 软件参数 | `max_threads=32`、110G/120G 内存、5G mark cache、三条查询设置 | **保持一致** | 跨架构可比 |
| 端口 | 19000/18123 | 19000–19399 / 19500–19899，按 run ID 派生 | 同机并行隔离 |
| 数据规模 | SF1 回归 / SF100 正式 | **只用 SF1**；SF100 未实现也未跑 | bdperf 只在 SF1 验证过；SF100 需要 110GB 数据与数小时 |
| 系统用户 | 容器内 root | Runner UID/GID | 宿主可读可删 |
| 结果对照 | `results_arm/ck_tpch_sf1_aarch64.csv` | 不引用 | 对方未做本用例口径的容器/内核对齐 |

## 未验证与限制

- 本机适配只验证了构建、启动与健康检查，**未执行 TPC-H 查询**；SF1 的正式数字
  以流水线为准，SF100 未实现。
- 数据生成依赖 tpch-kit 的 `dbgen` 与容器内 gcc/make；离线环境下需要预置
  `tpch-kit-master.zip`，否则首次运行会联网下载。
- `optimized` 变体未实现，选择后构建阶段明确返回非零。
