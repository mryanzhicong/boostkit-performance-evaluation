# ZooKeeper 3.6.2 性能测试

本用例在单容器内运行 Apache ZooKeeper 3.6.2 standalone，用仓库自带的 `ZkBench`
测量 `create / get / set / 9:1 mixed` 四类操作在 1、8、32、64 个并发线程下的吞吐与
分位时延。ZooKeeper、BiSheng JDK 与基准工具的获取、编译和正式测试都在本次任务的
私有容器内完成；`start`、`test`、`stop` 复用 `build` 创建的那一个容器。

容器规格固定为 32 个物理核（单 NUMA 节点）、128 GiB 内存、不限 memlock，对应
bdperf 协议 §0.4 的对比边界。**不修改任何内核参数**：THP、swap、`sysctl`、
`limits.conf`、`drop_caches`、挂载参数与 BIOS/电源策略都保持 Runner 原状，只在结果
目录记录实际值。软件侧参数（堆、GC、连接与会话上限、事务日志目录）按 bdperf
文档 §7.2 固定，两侧必须一致。

入口为 `zookeeper_test.sh`。Framework 按 `case.yaml` 调用 build、start、test、stop
四个函数，独立入口调用同一组函数。`scripts/builders/base.sh` 完成镜像、JDK、
ZooKeeper 与 ZkBench 的准备，`scripts/stages/` 负责启动、测试与清理，
`scripts/results/` 负责解析。`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| ZooKeeper | [Apache ZooKeeper 3.6.2](https://repo.huaweicloud.com/apache/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz)，SHA-512 `caff5111bb6876b7124760bc006e6fa2523efa54b99321a3c9cd8192ea0d5596abc7d70a054b1aac9b20a411407dae7611c7aba870c23bff28eb1643ba499199` | 优先读取 `/home/runner/software/zookeeper/`；缺失才下载到 `${PERF_WORK_DIR}` |
| JDK | BiSheng JDK `8u472-b11`（[华为镜像](https://repo.huaweicloud.com/kunpeng/archive/compiler/bisheng_jdk)），x86_64 / aarch64 各一份，校验值见下 | 优先读取 `/home/runner/software/bishengjdk/`；缺失才下载 |
| 容器镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 及同名 `.sha256sum` |
| 基准工具 | `scripts/tools/ZkBench.java`（随用例提供，单文件、仅依赖 `$ZK_HOME/lib/*`） | 构建阶段在容器内用 BiSheng `javac` 编译到 `${PERF_WORK_DIR}/tools/zkbench` |

BiSheng JDK 8u472 的固定校验值：

| 架构 | 文件 | SHA-256 |
|---|---|---|
| x86_64 | `bisheng-jdk-8u472-b11-linux-x64.tar.gz` | `45d5daf61a2670d20c7c2eed476577d7ef2d685a84f9f963464e8413b2b8c012` |
| aarch64 | `bisheng-jdk-8u472-b11-linux-aarch64.tar.gz` | `b5366023c742a29e0527c0c2d6bdd207a625084969e2693a248a0f328ad2c031` |

离线目录都可以用环境变量指向其他位置：`ZOOKEEPER_OFFLINE_DIR`、
`ZOOKEEPER_JDK_OFFLINE_DIR`、`ZOOKEEPER_IMAGE_ARCHIVE_DIR`、`ZOOKEEPER_CA_ANCHORS_DIR`。
生产 Runner 使用上表默认值。

## 获取、构建与容器启动

脚本先检查 Docker daemon，再用离线归档加载镜像：核对同名 `.sha256sum`、执行
`docker load`、检查镜像架构（`x86_64 → amd64`、`aarch64 → arm64`），并确认容器内
`/etc/os-release` 是 openEuler 24.03 LTS SP4。镜像引用写入
`${PERF_WORK_DIR}/container-image.txt`，`start/test/stop` 复用，不重复加载。

ZooKeeper 归档与 BiSheng JDK 先复制到 `${PERF_WORK_DIR}`，分别用 SHA-512 与
SHA-256 校验后解包；ZkBench 在容器内编译：

```bash
tar -xzf "${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin.tar.gz" -C "${PERF_WORK_DIR}"
tar -xzf "${PERF_WORK_DIR}/bisheng-jdk-8u472-b11-linux-<arch>.tar.gz" -C "${PERF_WORK_DIR}"
"${ZK_JDK_HOME}/bin/javac" -nowarn -cp "${ZK_HOME}/lib/*" \
  -d "${ZK_BENCH_DIR}" "${ZK_BENCH_DIR}/ZkBench.java"
```

实际版本从解包后的发行包读取，不沿用请求值：

```bash
docker exec <容器> "${ZK_HOME}/bin/zkServer.sh" version
```

输出写入 `PERF_ACTUAL_VERSION_FILE`；`build` 成功后写 `build_variant.json`。

每次运行创建一个带任务标签的容器，名称为
`boostkit-zookeeper-<架构>-<run-id>`。创建命令如下（`<...>` 由变量替换）：

```bash
docker run --detach --name "${ZK_CONTAINER_NAME}" \
  --label "boostkit.zookeeper.run-id=${PERF_RUN_ID}" \
  --network=host \
  --user "$(id -u):$(id -g)" \
  --cpuset-cpus="${ZK_CPUSET}" \
  --cpuset-mems="${ZK_MEMSET}" \
  --memory="${ZK_MEMORY}" \
  --memory-swap="${ZK_MEMORY_SWAP}" \
  --ulimit nofile=1048576:1048576 \
  --ulimit memlock=-1:-1 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${ZK_CONTAINER_IMAGE}" sleep infinity
```

`ZK_CPUSET=0-31`、`ZK_MEMSET=0`、`ZK_MEMORY=128g`、`ZK_MEMORY_SWAP=128g`
是正式口径的默认值。只有在核数或内存不足的开发机上做冒烟时，才通过
`ZOOKEEPER_CPUSET`、`ZOOKEEPER_MEMSET`、`ZOOKEEPER_MEMORY`、
`ZOOKEEPER_MEMORY_SWAP` 覆盖，并在结果里注明；正式 Runner 必须使用默认值。
容器不使用 `--privileged`。

正式工作流设置 `PERF_PROXY` 时，脚本把 `/home/runner/software/anchors/`
只读挂到 `/etc/pki/ca-trust/source/anchors/`，在容器内执行
`update-ca-trust extract`，并把 openEuler 仓库地址换成
`repo.huaweicloud.com/openeuler`。没有代理时不挂载证书目录。

## 启动

`start` 重新计算容器名，校验容器正在运行且 `boostkit.zookeeper.run-id` 标签等于
本次 run ID，然后写入 `${PERF_WORK_DIR}/conf/zoo.cfg`：

```properties
tickTime=2000
initLimit=10
syncLimit=5
dataDir=${PERF_WORK_DIR}/data/zk/data
dataLogDir=${PERF_WORK_DIR}/data/zk/log
clientPort=${ZK_CLIENT_PORT}
clientPortAddress=127.0.0.1
admin.enableServer=false
maxClientCnxns=0
minSessionTimeout=4000
maxSessionTimeout=60000
autopurge.snapRetainCount=10
autopurge.purgeInterval=6
4lw.commands.whitelist=mntr,ruok,stat,srvr,cons
```

`clientPort` 由 run ID 派生（`22000 + cksum(run-id) % 10000`），避免同机并行任务
争用 2181；AdminServer 关闭以免占用 8080。JVM 参数按 bdperf §7.2 固定，通过
`SERVER_JVMFLAGS` 传入，不影响其他任务：

```bash
SERVER_JVMFLAGS="-Xms4g -Xmx4g -XX:ActiveProcessorCount=8 -XX:+UseG1GC \
-XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 \
-XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch \
-XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:${PERF_WORK_DIR}/logs/zk_gc.log"
```

启动命令：

```bash
docker exec -e JAVA_HOME="${ZK_JDK_HOME}" -e ZOO_LOG_DIR="${PERF_WORK_DIR}/logs" \
  -e SERVER_JVMFLAGS="${ZK_JVM_FLAGS}" "${ZK_CONTAINER_NAME}" \
  "${ZK_HOME}/bin/zkServer.sh" --config "${ZK_CONF_DIR}" start
```

就绪判断不是固定 `sleep`：在容器内用 bash `/dev/tcp` 连接
`127.0.0.1:${ZK_CLIENT_PORT}` 发送 `mntr`，最多等 60 秒，要求
`zk_server_state` 为 `standalone`；成功快照保存到
`${RESULTS_DIR}/zookeeper-official/mntr_start.txt`。

## 测试负载

正式测试前先预置 keyspace（默认 100 万，`ZOOKEEPER_KEYSPACE` 可改）：

```bash
java -cp "${ZK_BENCH_DIR}:${ZK_HOME}/lib/*" ZkBench \
  --connect=127.0.0.1:${ZK_CLIENT_PORT} --root=/zkbench \
  --mode=preload --keyspace=1000000 --value-size=1024
```

预置后要求 `zk_znode_count >= keyspace`，否则失败。随后按 bdperf §9 的固定矩阵执行：

| 用例 | 模式 | 并发 | 每线程操作数 |
|---|---|---|---|
| `<mode>-t1` | create/read/update/mixed | 1 | 20000 |
| `<mode>-t8` | create/read/update/mixed | 8 | 5000 |
| `<mode>-t32` | create/read/update/mixed | 32 | 6250 |
| `<mode>-t64` | create/read/update/mixed | 64 | 6250 |

总操作数由并发档决定（20000 / 40000 / 200000 / 400000），每线程先做 2000 次预热，
预热不计入统计。每个组合跑 3 轮；`--run-seq` 全局递增，保证 create 路径
`/zkbench/c/r<seq>/t<tid>/...` 互不重叠。单次命令：

```bash
java -cp "${ZK_BENCH_DIR}:${ZK_HOME}/lib/*" ZkBench \
  --connect=127.0.0.1:${ZK_CLIENT_PORT} --root=/zkbench --mode=read --threads=32 \
  --ops=6250 --keyspace=1000000 --value-size=1024 --warmup=2000 \
  --label="${PERF_RUN_ID}" --run-seq=<递增序号>
```

每轮之间 `sleep 5`，不重启 ZooKeeper。测试结束自动执行
`--mode=clean` 删除 create 产生的树；设 `KEEP_CREATED=1` 可保留现场。

完整原始输出保存在 `${RESULTS_DIR}/benchmark_zookeeper_raw.log`，逐轮 CSV 保存在
`${RESULTS_DIR}/zookeeper-official/zk_<run-id>_<arch>.csv`，每轮的 `mntr` 快照和
stderr 也在该目录。

## 指标与产物

解析器只读取 ZkBench 原始 CSV，按 `(模式, 并发)` 把 3 轮取中位数：

| 指标 | 原始字段 | 单位 | 方向 |
|---|---|---|---|
| `throughput` | `throughput_ops` | ops/s | 越大越好 |
| `single_core_throughput` | `throughput_ops / 32` | ops/s | 越大越好 |
| `p50_ms` / `p95_ms` / `p99_ms` / `max_ms` | `p50_us` / `p95_us` / `p99_us` / `max_us` ÷ 1000 | ms | 越小越好 |

16 个组合 × 6 项 = 96 个指标，`group` 为 `<模式>-t<并发>`。解析器会拒绝：场景缺失
或重复、轮次不足、`ops_err != 0`、吞吐与 `ops_ok/elapsed_s` 不一致、分位数乱序、
非正或非有限数值。固定负载参数写入 JSON 的 `parameters`（keyspace、value size、
预热、轮次、模式、并发、每线程操作数、容器核数、JVM 参数）。

| 产物 | 内容 |
|---|---|
| `zookeeper-official/` | 逐轮 CSV、`mntr` 快照、预置/清理日志 |
| `benchmark_zookeeper_raw.log` | 完整原始 CSV、mntr 摘要与逐轮 stderr |
| `benchmark_zookeeper.json` | 96 项指标与固定负载参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `service-logs/`、`server-logs/` | 停止阶段保存的容器与 ZooKeeper 日志 |
| `results.json`、`report.md` | 独立入口生成的结果与报告 |

脱离 Workflow 执行完整流程：

```bash
bash software/Bigdata/zookeeper/zookeeper_test.sh \
  --version 3.6.2 \
  --variant base \
  --results-dir /home/runner/zookeeper-results/3.6.2
```

独立运行可用 `--keep-workdir` 保留私有工作目录；默认只删除由本次独立运行创建的
`/home/runner/boostkit-perf/zookeeper/local-*`，调用者自行指定的
`PERF_WORK_DIR` 与结果目录不会被删除。

## 与 bdperf 参考文档的差异

| 项目 | bdperf `01_ZooKeeper单容器性能测试.md` | 本用例 | 原因 |
|---|---|---|---|
| 内核 / 系统调优 | THP=always、swapoff、`sysctl`、`limits.conf`、`noatime`、IO 调度、BIOS 电源策略 | **全部不做**，只记录实际值 | 本仓库禁止修改内核参数 |
| 容器规格 | 32U/128G、`--cpuset-cpus=0-31`、`--cpuset-mems=0`、`--privileged` | 前四项保留；**去掉 `--privileged`** | 不再需要 perf/sysctl 权限 |
| JVM / ZooKeeper 参数 | 4G 堆、G1、`ActiveProcessorCount=8`、独立 `dataLogDir`、连接/会话上限、autopurge | **保持一致** | 软件侧固定参数，跨架构可比 |
| 端口 | 固定 2181 | 由 run ID 派生，`127.0.0.1` 绑定 | 同机并行任务隔离 |
| 系统用户 | 容器内 root | Runner UID/GID | 宿主可读可删，挂载目录不留 root 文件 |
| 结果对照 | `results_arm/zk_*.csv` | 不引用 | 对方未做本用例口径的容器/内核对齐 |

## 未验证与限制

- bdperf 只跑过 keyspace=200000 的 smoke（2 轮），100 万 keyspace 未在本仓库实测；
  默认堆 4G 下预置与快照行为需在正式流水线确认。
- 本机适配只验证了构建、启动与健康检查，未运行正式 benchmark；性能数字以流水线为准。
- `optimized` 变体未实现，选择后构建阶段明确返回非零。
