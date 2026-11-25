# HBase 2.4.14 性能测试

本用例在单容器内运行单实例 HBase 2.4.14（HDFS 单机 + ZooKeeper standalone +
HMaster + HRegionServer 同容器），用 HBase 自带 `PerformanceEvaluation` 测量随机写
吞吐与随机读吞吐/平均时延。HBase、Hadoop、ZooKeeper、BiSheng JDK 的获取和正式
测试都在本次任务的私有容器内完成；`start`、`test`、`stop` 复用 `build` 创建的
那一个容器。

容器规格固定为 32 个物理核（单 NUMA 节点）、128 GiB 内存、不限 memlock。
**不修改任何内核参数**：THP、swap、`sysctl`、`limits.conf`、`drop_caches` 与
BIOS/电源策略保持 Runner 原状，只在结果目录记录实际值。软件侧参数（RegionServer
堆 30G、Direct 48G、BucketCache 24576MB、`ActiveProcessorCount=8`、WAL 落本地盘、
`hbase-site.xml` 的 20 余项固定值）按 bdperf 文档 §7.2 固定，两侧一致。

入口为 `hbase_test.sh`。Framework 按 `case.yaml` 调用 build、start、test、stop，
独立入口调用同一组函数。`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| HBase | [2.4.14 bin](https://repo.huaweicloud.com/apache/hbase/2.4.14/hbase-2.4.14-bin.tar.gz) | 优先读取 `/home/runner/software/hbase/` |
| Hadoop | 3.3.6，x86_64 用 `hadoop-3.3.6.tar.gz`、aarch64 用 `hadoop-3.3.6-aarch64.tar.gz` | 优先读取 `/home/runner/software/hadoop/` |
| ZooKeeper | 3.6.2 bin | 优先读取 `/home/runner/software/zookeeper/`（与 ZooKeeper 用例共用） |
| JDK | BiSheng JDK `8u472-b11` | 优先读取 `/home/runner/software/bishengjdk/` |
| 容器镜像 | openEuler 24.03 LTS SP4 Docker 归档 | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/` |
| 测试工具 | HBase 自带 `org.apache.hadoop.hbase.PerformanceEvaluation` | 随 HBase 发行包提供，不单独安装 |

固定校验值（适配时从官方地址下载后计算）：

| 文件 | SHA-256 |
|---|---|
| `hbase-2.4.14-bin.tar.gz` | `04d5c2f46ce4d1e1b80dcf4740d7c8e6c6a371f4a44f5561dfc55c703df00b1e` |
| `hadoop-3.3.6.tar.gz` | `f5195059c0d4102adaa7fff17f7b2a85df906bcb6e19948716319f9978641a04` |
| `hadoop-3.3.6-aarch64.tar.gz` | `e4bbf6b80ef604912f6b9bf6ca77323dee6028d08d38f36ca077df56de8a5d0d` |
| `apache-zookeeper-3.6.2-bin.tar.gz` | `476f6fce10f9528e3a4ad00e6cd1714563f602dd4924db78e506c0df28fea1e5` |

BiSheng JDK 与 ZooKeeper/ClickHouse/Doris 用例使用同一组固定 SHA-256。离线目录可用
`HBASE_OFFLINE_DIR`、`HADOOP_OFFLINE_DIR`、`HBASE_ZK_OFFLINE_DIR`、
`HBASE_JDK_OFFLINE_DIR`、`HBASE_IMAGE_ARCHIVE_DIR`、`HBASE_CA_ANCHORS_DIR` 覆盖。

## 获取、构建与容器启动

构建阶段先检查 Docker daemon 并加载 openEuler 24.03 LTS SP4 镜像：

```bash
command -v docker >/dev/null && docker info >/dev/null
ARCHIVE="${HBASE_IMAGE_ARCHIVE_DIR}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
URL="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
[[ -s "${ARCHIVE}" ]] || curl -fSL --retry 3 -o "${ARCHIVE}" "${URL}"
[[ -s "${ARCHIVE}.sha256sum" ]] || curl -fSL --retry 3 -o "${ARCHIVE}.sha256sum" "${URL}.sha256sum"
expected="$(awk 'NR == 1 {print $1}' "${ARCHIVE}.sha256sum")"
actual="$(sha256sum "${ARCHIVE}")"
[[ "${actual%% *}" == "${expected,,}" ]] || { echo "image SHA-256 mismatch"; exit 1; }
output="$(docker load --input "${ARCHIVE}")"
CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
printf '%s\n' "${CONTAINER_IMAGE}" > "${PERF_WORK_DIR}/container-image.txt"
docker image inspect --format '{{.Architecture}}' "${CONTAINER_IMAGE}"   # x86_64→amd64、aarch64→arm64
docker run --rm --network=none "${CONTAINER_IMAGE}" cat /etc/os-release    # 必须是 openEuler 24.03 LTS SP4
```

随后依次解包 HBase、Hadoop、ZooKeeper、BiSheng JDK 到 `${PERF_WORK_DIR}`。Hadoop 的
`-aarch64` 包内顶层目录仍叫 `hadoop-3.3.6`，脚本按实际目录校验。随后在容器内执行
`hbase version`，从输出读取 `2.4.14` 写入 `PERF_ACTUAL_VERSION_FILE`；`build`
成功后写 `build_variant.json`。

容器名称为 `boostkit-hbase-<架构>-<run-id>`，创建命令如下：

```bash
docker run --detach --name "${CONTAINER_NAME}" \
  --label "boostkit.hbase.run-id=${PERF_RUN_ID}" \
  --network=host \
  --user "$(id -u):$(id -g)" \
  --cpuset-cpus="${HBASE_CPUSET}" \
  --cpuset-mems="${HBASE_MEMSET}" \
  --memory="${HBASE_MEMORY}" \
  --memory-swap="${HBASE_MEMORY_SWAP}" \
  --ulimit nofile=1048576:1048576 \
  --ulimit memlock=-1:-1 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${CONTAINER_IMAGE}" sleep infinity
```

| 变量 | 默认值 | 说明 |
|---|---|---|
| `HBASE_CPUSET` | `0-31` | 单 NUMA 节点上的 32 个物理核，两个架构必须相同 |
| `HBASE_MEMSET` | `0` | 与 cpuset 对应的 NUMA 节点 |
| `HBASE_MEMORY` / `HBASE_MEMORY_SWAP` | `128g` / `128g` | 容器内存与 swap 额度，相等即容器内禁用 swap |
| `CONTAINER_IMAGE` | 上一步 `docker load` 的输出 | 不写死 tag |

开发机冒烟可覆盖 `HBASE_CPUSET`、`HBASE_MEMSET`、`HBASE_MEMORY`、
`HBASE_MEMORY_SWAP` 以及 `HBASE_RS_HEAP`/`HBASE_MASTER_HEAP`/`HBASE_DIRECT_MEMORY`/
`HBASE_BUCKET_CACHE_MB`，并在结果里注明；正式 Runner 使用 bdperf 默认值。容器
不加 `--privileged`。

## 启动

`start` 写 `core-site.xml`、`hdfs-site.xml`、`hbase-env.sh`、`hbase-site.xml` 与
`zoo.cfg`。关键点：

- HDFS 单机、副本 1，NameNode/DataNode 端口由 run ID 派生（23000+offset）并绑定
  `127.0.0.1`，避免与同机其他任务冲突；
- `hbase.rootdir=hdfs://127.0.0.1:<nn>/HBase`，`hbase.wal.dir` 落本地盘
  `${HBASE_DATA}/wal`；
- `hbase.zookeeper.quorum=127.0.0.1`、`zookeeper.session.timeout=90000`、
  `znode.parent=/hbase`，ZooKeeper 由本用例启动，`HBASE_MANAGES_ZK=false`；
- `HBASE_OPTS` 显式 `UseG1GC`，Master 8G、RegionServer 30G、
  `MaxDirectMemorySize=48g`、BucketCache offheap 24576MB；
- handler/flusher/memstore/compaction/WAL 分组等 20 余项按 bdperf §7.2 固定。

启动顺序（全部直接在容器内启动守护进程，不依赖 ssh）：

```bash
hdfs namenode -format -force -nonInteractive          # 仅首次
zkServer.sh --config <conf> start
hdfs --daemon start namenode
hdfs --daemon start datanode
hbase-daemon.sh start master
hbase-daemon.sh start regionserver
```

就绪判断是有界轮询：`hdfs dfsadmin -report` 成功后才启动 HBase；随后每 2 秒执行
`echo status | hbase shell -n`，最多 180 秒，要求输出同时包含 `active master` 与
`servers, 0 dead`，并把状态保存到 `${HBASE_RESULT_DIR}/hbase_status.txt`。

## 测试负载

先灌数再读：

```bash
hbase org.apache.hadoop.hbase.PerformanceEvaluation \
  --size=2 --table=Test_2GB --presplit=16 randomWrite 4
echo "flush 'Test_2GB'" | hbase shell -n
echo "major_compact 'Test_2GB'" | hbase shell -n
hbase org.apache.hadoop.hbase.PerformanceEvaluation \
  --nomapred --rows=100000 --table=Test_2GB randomRead 8
```

- 随机写用 mapreduce 模式，`--size` 单位 GB（必须 > 1），`--presplit` 是 region 数；
- 随机读用客户端多线程模式，`--rows` 是每线程行数，读 3 轮，第 1 轮同样计入并取
  3 轮中位数（本用例没有单独的预热轮，读前已 flush+major_compact）；
- 写吞吐 = `Row count / (Elapsed time in milliseconds / 1000)`；读吞吐只取
  `[ Avg TPS/QPS]` 那一行，**不取** `duration` 行的 `Avg: xxxms`（那会得到 20 万级
  的假数，bdperf FAQ Q1 已记录）。

**规模说明**：bdperf 只在 ARM 上验证过 2GB/16 region 的 smoke，100G/400 region 的
正式口径**没有跑过**。本用例把 2GB/16 region 作为固定负载，不声称是 100G 正式规模；
启用 100G 需要另做容器内存、数据盘和时长的验证。

## 指标与产物

| 指标 | 原始字段 | 单位 | 方向 |
|---|---|---|---|
| `pe-randomWrite/throughput` | `Row count=` / `Elapsed time in milliseconds=` | rows/s | 越大越好 |
| `pe-randomRead/throughput` | `[ Avg TPS/QPS]` | ops/s | 越大越好 |
| `pe-randomRead/avg_latency` | `[ Avg latency (us)]` ÷ 1000 | ms | 越小越好 |

解析器要求：写段恰好一组 `Row count` 与 `Elapsed`；读段数等于 3，每段恰好一组
TPS 与 latency；全部为正有限值。缺段、重复段、零值都会失败。固定负载参数写入
`parameters`（数据量、region 数、读线程与行数、轮次、读写模式）。

| 产物 | 内容 |
|---|---|
| `hbase-official/pe_randomWrite.log`、`pe_randomRead_round*.log` | 原始 PE 输出 |
| `hbase-official/hbase_status.txt`、`hdfs_report.txt`、`hbase_version.txt` | 拓扑与健康状态 |
| `benchmark_hbase_raw.log` | 写段与 3 轮读段的完整输出 |
| `benchmark_hbase.json` | 3 项指标与固定参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `service-logs/` | 停止阶段保存的 HBase/HDFS/ZK 日志 |
| `results.json`、`report.md` | 独立入口生成的结果与报告 |

脱离 Workflow 执行：

```bash
bash software/Bigdata/hbase/hbase_test.sh \
  --version 2.4.14 --variant base \
  --results-dir /home/runner/hbase-results/2.4.14
```

独立运行可用 `--keep-workdir` 保留私有目录；默认只删除本次独立运行创建的
`/home/runner/boostkit-perf/hbase/local-*`。

## 与 bdperf 参考文档的差异

| 项目 | bdperf `02_HBase单容器性能测试.md` | 本用例 | 原因 |
|---|---|---|---|
| 内核 / 系统调优 | THP=always、swapoff、`sysctl`、`noatime`、BIOS 电源策略 | **全部不做**，只记录 | 本仓库禁止修改内核参数 |
| 容器规格 | 32U/128G 与 64U/256G 两档 | 只保留 32U/128G + cpuset/ulimit，去掉 privileged | 本用例固定一档，跨架构可比 |
| 软件参数 | 堆/Direct/BucketCache/hbase-site 全套 | **保持一致**（默认 32 档值） | 跨架构可比 |
| 部署 | 依赖 ssh 免密与 hostname shim | 直接 `hdfs --daemon`/`hbase-daemon.sh` 启动守护进程 | 容器内无 sshd，避免额外依赖 |
| 端口 | 9000/2181/16000/16020 固定 | 按 run ID 派生并绑定 127.0.0.1 | 同机并行隔离 |
| 数据规模 | 100G/400 region 正式、2G smoke | **只用 2G/16 region**；100G 未跑 | bdperf 只验证过 2G，100G 未验证 |
| YCSB | 可选 | 未实现 | 安装包下载不稳定，主用例已覆盖读写 |
| 结果对照 | `results_arm/hbase_*.csv` | 不引用（原始 CSV 里还有一条 duration 误记） | 口径不同且数据有瑕疵 |

## 未验证与限制

- 本机适配只验证构建与启动；正式 benchmark 未执行，2G 数字以流水线为准。
- 100G/400 region 未跑，也不在 `case.yaml` 的默认参数里；如要启用需先验证容器内存、
  数据盘容量与运行时长。
- 本地开发机内存较小时，需要用 `HBASE_RS_HEAP` 等覆盖项缩小堆，否则 RegionServer
  无法启动；这些覆盖只用于冒烟，正式 Runner 必须使用 bdperf 默认值。
- `optimized` 变体未实现，选择后构建阶段明确返回非零。
