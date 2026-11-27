# Celeborn 0.5.3 性能测试

本用例在**一台 openEuler 24.03 LTS SP4 机器上的单个私有容器**内运行 Apache Celeborn 0.5.3 远程 Shuffle 服务、
Apache Spark 3.5.2 与 TPC-DS 99 条查询，用「1 次预热 + 5 次有效采样」的完整查询轮次衡量 Celeborn 参与
Shuffle 时的 TPC-DS 套件耗时、单语句耗时分布与 Shuffle 数据量/吞吐。x86_64 与 aarch64 使用同一份脚本与
同一份参数矩阵（TPC-DS 数据由源码构建的 `dsdgen` 生成，两架构数据逐字节一致）。

- **在哪跑**：宿主机只保留 Docker、下载缓存、Framework 与严格解析器；Celeborn master/worker、Spark、TPC-DS
  生成与全部测量过程都在名为 `boostkit-celeborn-<arch>-<run-id>` 的私有容器内完成。
- **容器规格**：**容器不限制 CPU、内存或 NUMA**（不传 `--cpus`/`--cpuset-cpus`/`--memory`），
  Spark 驱动堆取容器可用内存的一半、上限 24 GiB；Celeborn master/worker 堆各 4 GiB，worker 8 GiB 堆外内存。
- **怎么进入**：Framework 六阶段依次调用 `build_celeborn`、`start_celeborn_runtime`、`run_celeborn_benchmark`、
  `stop_celeborn_runtime`（`execution.stages`），独立入口 `celeborn_test.sh` 调用同一批函数。
- **变体**：`base` 为唯一实现；调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，
  选择后会在构建阶段明确失败，不会退回基础版，也不产生任何数字。
- **怎么复现**：`bash software/Bigdata/celeborn/celeborn_test.sh --version 0.5.3 --variant base --results-dir <dir>`
  （见「独立运行」）。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | [Apache Celeborn 0.5.3 官方二进制发行版](https://archive.apache.org/dist/celeborn/celeborn-0.5.3/apache-celeborn-0.5.3-bin.tgz)，SHA-512 `cc294b85…fb18c9` | `${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin`（公共离线目录 `/home/runner/software/celeborn/` 优先） |
| Shuffle 客户端 | 发行版自带 `spark/celeborn-client-spark-3-shaded_2.12-0.5.3.jar`，`spark.shuffle.manager=org.apache.spark.shuffle.celeborn.SparkShuffleManager` | 同一发行版目录，`spark-submit --jars` 引入 |
| 计算引擎 | [Apache Spark 3.5.2 `bin-hadoop3`](https://archive.apache.org/dist/spark/spark-3.5.2/spark-3.5.2-bin-hadoop3.tgz)，SHA-512 `ae243483…d37539` | `${PERF_WORK_DIR}/spark-3.5.2-bin-hadoop3` |
| 测试工具（数据生成） | [databricks/tpcds-kit](https://github.com/databricks/tpcds-kit) 提交 `1b7fb7529edae091684201fab142d956d6afd881`，源码包 SHA-256 `d57b2885…318056`；在容器内编译 `dsdgen`/`dsqgen`，两架构生成的数据一致 | `${PERF_WORK_DIR}/tpcds-kit` |
| 测试工具（DDL 与语句） | hive-testbench-hdp3 归档（`gitcode` 发布件），SHA-256 `7248c0f9…9b81ee`；只取 `ddl-tpcds/text/alltables.sql` 的列定义与 `sample-queries-tpcds/query*.sql` 的 99 条语句 | `${PERF_WORK_DIR}/hive-testbench-hdp3` |
| 运行时 | openEuler 自带 `java-1.8.0-openjdk`（BiSheng 1.8.0）、`python3`、`gcc/make/bison/flex`（仅编译 TPC-DS 生成器） | 容器内 `dnf` 安装 |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |

解析器、Framework 与下载/校验都在宿主机执行；**宿主机不安装被测软件、不改系统配置/信任库/软件源**。

## Celeborn 获取、构建与容器启动

### 获取顺序

每个下载件按三段顺序解析：① 公共离线目录 `/home/runner/software/celeborn/`；② 本次任务缓存
`${PERF_WORK_DIR}`；③ 下载——**国内镜像优先、上游官网兜底**（Celeborn 与 Spark 先用
`mirrors.huaweicloud.com` 的 Apache 镜像，失败后再用 `archive.apache.org`），每个候选源都必须给出同一个
摘要，摘要不符换下一个源，全部失败即失败（不重试其它地址、不降级）。按架构的归档与校验值如下
（两架构使用同名归档，`dsdgen` 由源码编译，不下载预编译生成器）：

| 归档 | 架构 | 校验 |
|---|---|---|
| `apache-celeborn-0.5.3-bin.tgz` | x86_64 / aarch64 通用 | SHA-512 `cc294b8589bde1a5c5340dd18f7b20ab3dfd904d072228ee473e76d05cbaf4d5152a61c8502fe9505e3f25ce05241b43dda72a028caf044043810fee15fb18c9` |
| `spark-3.5.2-bin-hadoop3.tgz` | x86_64 / aarch64 通用 | SHA-512 `ae243483c2d07dc0feade02ac681956e9577e22935e32bb4ffca4fce02243682ca71dadeff9e6566153e132b0a71c518ded2dc58d08a124679843bffd3237539` |
| `tpcds-kit.tar.gz`（提交 `1b7fb75`） | 源码，两架构通用 | 解包后源树规范化摘要 `6bc2cdf0e91b07e4e3374d0f765051e2f8411a7d074fd4f88c411eaa6eabc5ee`（见下方说明） |
| `hive-testbench.zip` | 文本资产，两架构通用 | SHA-256 `7248c0f9d3d4dfe8435cd6e8137c2023ed8008dcf9bc2d55ff7f2427699b81ee` |

TPC-DS 源码按**内容**校验而非压缩字节：codeload 会重新打包归档，同一提交的 `.tar.gz` 字节并不稳定
（本次观测到同一提交出现过两种 SHA-256），因此 `scripts/builders/tree_digest.py` 对解包后的每个文件计算
`sha256(文件)`，按相对路径排序拼成清单再取 SHA-256，与 `TPCDS_KIT_TREE_SHA256` 比对，不符即失败——
提交内容变化会被发现，压缩方式变化不会误报。

### 实际命令形态

以下是构建阶段真实执行的命令行（`${PERF_WORK_DIR}` 由 Framework 按
`<work-root>/celeborn/<version>/<arch>/<run-id>` 派生，可用 `--keep-workdir` 观察）：

```bash
# 1) 下载、校验并缓存四个归档（已命中缓存时只做校验）
sha512sum -c <<< "${CELEBORN_ARCHIVE_SHA512}  ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin.tgz"
sha512sum -c <<< "${SPARK_ARCHIVE_SHA512}  ${PERF_WORK_DIR}/spark-3.5.2-bin-hadoop3.tgz"
sha256sum -c <<< "${TESTBENCH_SHA256}  ${PERF_WORK_DIR}/hive-testbench.zip"

# 1.1) TPC-DS 源码按内容校验：解包到临时目录后比对源树规范化摘要
python3 ${CASE_DIR}/scripts/builders/tree_digest.py \
    ${PERF_WORK_DIR}/tpcds-kit-verify/tpcds-kit-1b7fb75... \
    --expected ${TPCDS_KIT_TREE_SHA256}

# 2) 镜像校验与加载（校验 SHA-256 后再 docker load，不访问 Docker Hub）
sha256sum -c openEuler-docker.${ARCH}.tar.xz.sha256sum
docker load --input /home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.${ARCH}.tar.xz

# 3) 容器内解包（解包由容器内用户完成，目录属主即运行用户）
tar -xzf ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin.tgz -C ${PERF_WORK_DIR}
tar -xzf ${PERF_WORK_DIR}/spark-3.5.2-bin-hadoop3.tgz -C ${PERF_WORK_DIR}
tar -xzf ${PERF_WORK_DIR}/tpcds-kit.tar.gz -C ${PERF_WORK_DIR}/tpcds-kit --strip-components=1
unzip -q ${PERF_WORK_DIR}/hive-testbench.zip -d ${PERF_WORK_DIR}/testbench-extract
mv ${PERF_WORK_DIR}/testbench-extract/hive-testbench-* ${PERF_WORK_DIR}/hive-testbench-hdp3

# 4) 容器内安装运行库与生成器编译链（镜像源先切到华为镜像）
dnf -y --setopt=install_weak_deps=False install java-1.8.0-openjdk gcc make bison flex unzip tar gzip python3 procps-ng

# 5) 编译与架构无关的 TPC-DS 生成器（bison 以 yacc/lex 兼容名调用，串行 make 避免 y.tab.h 竞态）
ln -sf "$(command -v bison)" ${PERF_WORK_DIR}/bin/yacc && ln -sf "$(command -v flex)" ${PERF_WORK_DIR}/bin/lex
cd ${PERF_WORK_DIR}/tpcds-kit/tools && bison -y -d -v qgen.y && make OS=LINUX

# 6) 版本核对：Celeborn 0.5.3、Spark 3.5.2、客户端 jar 存在
grep -oE '[0-9]+\.[0-9]+\.[0-9]+' ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin/RELEASE | head -n 1
${PERF_WORK_DIR}/spark-3.5.2-bin-hadoop3/bin/spark-submit --version
test -s ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin/spark/celeborn-client-spark-3-shaded_2.12-0.5.3.jar
```

`versions.json` 记录实际到手的 Celeborn/Spark/JDK 版本与 TPC-DS 提交号，`actual-version.txt` 供 Framework 核对。

### 容器创建

```bash
docker run --detach --name "${CELEBORN_CONTAINER_NAME}" \
  --label "boostkit.celeborn.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --ulimit nofile=1048576:1048576 \
  --mount type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR} \
  --mount type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR} \
  --mount type=bind,source=${CASE_DIR},target=${CASE_DIR},readonly \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${CELEBORN_CONTAINER_IMAGE}" sleep infinity
```

- 容器名 `boostkit-celeborn-<arch>-<run-id>`，标签 `boostkit.celeborn.run-id=<run-id>`；`stop.sh` 按标签校验后才删除，
  同名残留容器会被拒绝复用，历史容器按标签清理。
- 用例目录只读挂载，工作目录与结果目录以宿主机原路径挂载；`PERF_PROXY` 启用时额外只读挂载 CA 锚点目录并以容器内
  root 执行 `update-ca-trust extract`。
- Celeborn 端口固定为 9097（RPC）/9098（master HTTP）/9099（worker HTTP），容器使用 `--network=host`，
  `/etc/hosts` 中把 `server1` 指向 `127.0.0.1`，与文档中的 `server1:9097` 端点一致。

### 容器内准备

镜像源只改本次容器：注释 `meta` 元数据地址、`repo.openeuler.org` → `repo.huaweicloud.com/openeuler`，再执行上面的
`dnf install`；不修改宿主机软件源或信任库。

- **脚本出处**：`scripts/builders/dispatch.sh`、`scripts/builders/base.sh`、`scripts/common.sh`（容器块由
  `adaptation/scripts/add-container-block.py` 生成）

## 数据与运行顺序

1. **启动 Celeborn 服务**：写 `celeborn-defaults.conf`/`celeborn-env.sh` 后启动 master 与 worker，等待日志出现
   `Master started` 与 `Register worker successfully`，并把 worker 注册、端口、存储目录及设备号写入
   `service-state.json`。

```bash
# 实际命令形态（容器内，JAVA_HOME 指向 openEuler 自带 JDK8）
cat > ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin/conf/celeborn-defaults.conf <<EOF
celeborn.master.host=server1
celeborn.master.port=9097
celeborn.master.endpoints=server1:9097
celeborn.master.http.port=9098
celeborn.worker.http.port=9099
celeborn.worker.storage.dirs=${PERF_WORK_DIR}/celeborn/storage-1,${PERF_WORK_DIR}/celeborn/storage-2
celeborn.worker.memory=8g
EOF
${CELEBORN_HOME}/sbin/start-master.sh
${CELEBORN_HOME}/sbin/start-worker.sh celeborn://server1:9097
grep -q 'Register worker successfully' ${CELEBORN_LOG_DIR}/*worker*
```

2. **固定工作负载清单**：解析 `ddl-tpcds/text/alltables.sql` 得到 24 张表的列定义，记录
   `sample-queries-tpcds/query*.sql` 99 条语句的 SHA-256，写入 `${PERF_WORK_DIR}/workload/manifest.json`；
   后续生成、装载与解析都以该清单为准，语句数量或摘要不符即失败。清单中的摘要覆盖**实际执行的语句文本**：
   上游 Hive/Tez 的两处区间写法（`+ 14 days`、`INTERVAL(5) DAY`）统一改写为 Spark 的 `interval N unit`，
   一个文件里若存在两条等价改写（Q14/Q23/Q24/Q39）只取第一条；改写规则固定、不含表名/列名/谓词改动，
   详见「已知限制」。

```bash
python3 scripts/workload/tpcds.py  # load_tables()/statement_files()/manifest()，见脚本出处
```

3. **生成 TPC-DS 数据**：`dsdgen` 并行子进程写管道分隔文本到 `${PERF_WORK_DIR}/data/tpcds-${SF}`，
   完成后写 `.complete` 标记（含 scale factor），重复执行时按标记复用。

```bash
cd ${PERF_WORK_DIR}/tpcds-kit/tools
for i in $(seq 1 ${PARALLEL}); do
  ./dsdgen -DIR ${PERF_WORK_DIR}/data/tpcds-${SF} -SCALE ${SF} -TERMINATE N -PARALLEL ${PARALLEL} -CHILD $i -QUIET Y &
done
wait
```

4. **装载为 ORC 表**：Spark 按清单中的列定义读取文本（`sep='|'`，末尾补一列吸收行尾分隔符），逐列 cast 后
   `saveAsTable` 写入 `${PERF_WORK_DIR}/warehouse/tpcds-${SF}`，元数据用嵌入式 Derby
   （`jdbc:derby:;databaseName=${PERF_WORK_DIR}/metastore/tpcds-${SF}/metastore_db;create=true`），装载结果写
   `warehouse-load.json`。

```bash
${SPARK_HOME}/bin/spark-submit --master 'local[*]' --driver-memory ${DRIVER_MEMORY} \
  --conf spark.sql.warehouse.dir=${PERF_WORK_DIR}/warehouse/tpcds-${SF} \
  --conf spark.sql.catalogImplementation=hive \
  --conf spark.hadoop.javax.jdo.option.ConnectionURL='jdbc:derby:;databaseName='"${PERF_WORK_DIR}"'/metastore/tpcds-${SF}/metastore_db;create=true' \
  ${CASE_DIR}/scripts/workload/load_tables.py --ddl ${DDL_FILE} \
  --data-dir ${PERF_WORK_DIR}/data/tpcds-${SF} --warehouse ${PERF_WORK_DIR}/warehouse/tpcds-${SF} \
  --metastore ${PERF_WORK_DIR}/metastore/tpcds-${SF} --scale-factor ${SF} --summary ${RESULTS_DIR}/warehouse-load.json
```

5. **预热 1 轮 + 正式 5 轮**：每轮是一个独立 Spark 应用（`spark.shuffle.manager` 指向 Celeborn），按清单顺序执行
   99 条语句并记录每条语句 `spark.sql(...).collect()` 的墙钟耗时；轮次结果写
   `runs/sample<i>/queries.jsonl`，Spark 日志写同目录 `spark.log`。**预热轮不进统计**。
   固定 `spark.sql.adaptive.enabled=false`：开启 AQE 时同一组查询在不同轮次的 Shuffle 量在 540 MB 与
   884 MB 之间跳变（运行时重规划所致），关闭后每轮稳定在 286 MB 量级，轮次间差异 < 0.01%。

```bash
${SPARK_HOME}/bin/spark-submit --master 'local[*]' --driver-memory ${DRIVER_MEMORY} \
  --jars ${CELEBORN_HOME}/spark/celeborn-client-spark-3-shaded_2.12-0.5.3.jar \
  --conf spark.shuffle.manager=org.apache.spark.shuffle.celeborn.SparkShuffleManager \
  --conf spark.celeborn.master.endpoints=server1:9097 \
  --conf spark.shuffle.service.enabled=false \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.shuffle.partitions=200 \
  --conf spark.sql.adaptive.enabled=false \
  ${CASE_DIR}/scripts/workload/run_queries.py --manifest ${PERF_WORK_DIR}/workload/manifest.json \
  --query-dir ${TESTBENCH_HOME}/sample-queries-tpcds --warehouse ${PERF_WORK_DIR}/warehouse/tpcds-${SF} \
  --metastore ${PERF_WORK_DIR}/metastore/tpcds-${SF} --sample ${i} \
  --out ${RESULTS_DIR}/runs/sample${i}/queries.jsonl \
  --shuffle-dirs ${CELEBORN_STORAGE_DIR_1},${CELEBORN_STORAGE_DIR_2}
```

6. **取 Shuffle 证据**：Celeborn 在应用结束后会异步清理它的 Shuffle 数据，事后 `du` 会读到被清理中的目录，
   因此**在应用停止之前**（`SparkSession.stop()` 之前）由 `run_queries.py` 统计 worker 两个存储目录下
   `celeborn-worker/shuffle_data/<appId>` 的字节数与文件数，写入 `queries.jsonl` 的 `shuffle_usage` 记录，
   再由 `test.sh` 落到 `runs/sample<i>/shuffle.json`（同时记录事后 `du` 值作交叉核对）；为 0 视为该轮无效。

```bash
# 应用内（容器内同一路径可见）统计：见 scripts/workload/run_queries.py 的 shuffle_usage()
python3 -c "..." ${CELEBORN_STORAGE_DIR_1},${CELEBORN_STORAGE_DIR_2}
# 事后交叉核对（不作为指标来源）
du -sb ${PERF_WORK_DIR}/celeborn/storage-1/celeborn-worker/shuffle_data/${APP_ID}
```

7. **解析与清理**：把服务状态、清单、数据集、装载结果、每轮 Shuffle 证据与 Spark 日志汇总成
   `benchmark_celeborn_raw.log`，再按严格规则解析成 `benchmark_celeborn.json`；`stop.sh` 停掉 Celeborn 进程，
   `CELEBORN_TEARDOWN=1` 时按标签删除容器，任何时候都写 `stop-report.json`。

```bash
python3 ${CASE_DIR}/scripts/results/parse_benchmark.py --results-dir ${RESULTS_DIR} \
  --manifest ${PERF_WORK_DIR}/workload/manifest.json --samples ${PERF_REPS} \
  --scale-factor ${SF} --shuffle-bytes ${MEAN_SHUFFLE_BYTES} --output ${RESULTS_DIR}/benchmark_celeborn.json
${CELEBORN_HOME}/sbin/stop-all.sh
```

### 参数矩阵

| 参数 | 取值 | 说明 |
|---|---|---|
| TPC-DS 规模 `CELEBORN_SCALE_FACTOR` | `3`（默认） | 单容器可承载的规模；仅接受 ≥1 的整数（`dsdgen` 2.13 在小于 1 的规模下会崩溃） |
| 语句数 | 99 | 固定清单，SHA-256 逐条记录 |
| 采样轮次 `PERF_REPS` | `6` | 1 预热 + 5 有效采样，预热轮不计入统计 |
| Spark 驱动内存 | 容器内存的一半，上限 24 GiB | `${PERF_WORK_DIR}` 与驱动内存都随机器读取，不写死 |
| `spark.sql.shuffle.partitions` | 200 | 与文档的 200 执行器规模对齐 |
| Celeborn master / worker 堆 | 4 GiB / 4 GiB | worker 另配 8 GiB 堆外内存（`celeborn.worker.memory=8g`） |
| 数据生成并发 | `min(16, 容器核数)`，且 ≥2 | 核数用 `nproc` 读取 |

两架构使用同一矩阵；差异只在镜像归档名与 JDK/生成器由各自架构编译。

## 指标与产物

| 报告分组 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| suite | `celeborn.tpcds.suite.elapsed` | 5 个有效轮次「99 条语句耗时之和」的中位数（`queries.jsonl` 的 `seconds` 求和） | s | 越小越好 |
| statements | `celeborn.tpcds.statement.median.mean` | 每条语句 5 轮耗时的中位数的算术平均 | s | 越小越好 |
| statements | `celeborn.tpcds.statement.median.p95` | 上述中位数序列的 95 分位（线性插值） | s | 越小越好 |
| workload | `celeborn.tpcds.statements.executed` | 清单中实际执行的语句数（99） | statements | 越大越好 |
| workload | `celeborn.tpcds.scale_factor` | 本次运行的 TPC-DS 规模 | factor | 越大越好 |
| shuffle | `celeborn.shuffle.bytes.written` | 有效轮次 `shuffle.json` 的**中位数字节数**（应用停止前实测的 Celeborn worker 存储占用；轮次间出现重试型离群值时用中位数，`shuffle-summary.json` 同时保留每轮值与最大/最小值） | bytes | 越小越好 |
| shuffle | `celeborn.shuffle.throughput` | 上述字节数 ÷ `celeborn.tpcds.suite.elapsed` | MB/s | 越大越好 |
| `query1` … `query99` | `celeborn.tpcds.query<nn>.median` | 单条语句 5 轮耗时的中位数 | s | 越小越好 |

- **指标总数**：7 项整体指标 + 99 项语句级指标 = **106 项**。
- **分组规则**：整体指标分 `suite`/`statements`/`workload`/`shuffle` 四组；语句级指标每条语句一组（`query1`…`query99`），
  便于逐条对照上游改动；语句级指标只做同规模对比，不与 SF100 文档值配对。
- 单位与方向与 `case.yaml` 的 `metrics.collection` 完全一致（`value`/`unit`/`direction`/`group`）。

| 产物 | 内容 |
|---|---|
| `build_variant.json` | 变体与关键参数（规模、Shuffle 管理器、Spark 版本） |
| `versions.json` | 实际 Celeborn/Spark/JDK 版本与 TPC-DS 提交号 |
| `service-state.json` | master/worker 端点、worker 注册证据、存储目录与设备号、驱动内存 |
| `dataset.json` | 生成的 TPC-DS 文本文件数/字节数 |
| `warehouse-load.json` | 每张 ORC 表的行数与来源文件数 |
| `benchmark_celeborn_raw.log` | 服务状态、清单、数据集、装载结果、每轮 Shuffle 证据、逐语句记录，以及每轮 Spark 日志的**错误行与末 120 行**摘录（完整日志留在 `runs/sample<i>/spark.log`，不进结果仓库，避免单文件超过 GitHub 100 MB 限制） |
| `benchmark_celeborn.json` | 解析后的 106 项指标与样本统计（Framework 与独立入口都生成） |
| `runs/sample<i>/queries.jsonl` | 第 i 轮逐语句耗时、返回行数、application id，以及停止前的 Celeborn 存储量（`shuffle_usage`） |
| `runs/sample<i>/spark.log` | 第 i 轮的 Spark 原始输出 |
| `runs/sample<i>/shuffle.json` | 第 i 轮 Celeborn 存储的 Shuffle 字节数（应用内实测）与事后 `du` 交叉核对值 |
| `shuffle-summary.json`、`disk-usage.jsonl` | 每轮字节数与磁盘占用采样 |
| `stop-report.json` | 停止阶段的清理结论（是否保留容器、退出码） |
| `command-<stage>.log`、`status.json` | Framework 逐阶段命令日志与阶段状态 |
| `results.json`、`report.md` | 独立入口生成的汇总（Framework 路径不生成） |

**解析严格性**：解析器要求样本目录恰好 `PERF_REPS` 个、每轮恰好包含清单里的全部 99 条语句且不重复、
每条耗时有限且 >0、有效轮次 ≥5、Shuffle 字节数 >0；任何一项不满足直接以非零码失败，**绝不补零、
绝不静默降级**。

- **脚本出处**：`scripts/stages/start.sh`、`scripts/stages/test.sh`、`scripts/stages/stop.sh`、
  `scripts/workload/{tpcds.py,load_tables.py,run_queries.py}`、`scripts/results/parse_benchmark.py`

## 独立运行

```bash
bash software/Bigdata/celeborn/celeborn_test.sh \
  --version 0.5.3 --variant base \
  --results-dir /home/runner/celeborn-results/0.5.3
```

入口内部实际执行的关键命令（与 Framework 六阶段一致）：

```bash
# 构建：下载校验、docker load、docker run、容器内 dnf、编译 dsdgen/dsqgen
sha512sum -c <<< "${CELEBORN_ARCHIVE_SHA512}  ${PERF_WORK_DIR}/apache-celeborn-0.5.3-bin.tgz"
docker load --input /home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.${ARCH}.tar.xz
docker run --detach --name ${CELEBORN_CONTAINER_NAME} --label boostkit.celeborn.run-id=${PERF_RUN_ID} \
  --network=host --user "$(id -u):$(id -g)" --mount type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR} \
  ${CELEBORN_CONTAINER_IMAGE} sleep infinity
dnf -y install java-1.8.0-openjdk gcc make bison flex unzip python3

# 启动与测量：Celeborn master/worker + 6 轮 Spark 应用（见「数据与运行顺序」）
${CELEBORN_HOME}/sbin/start-master.sh && ${CELEBORN_HOME}/sbin/start-worker.sh celeborn://server1:9097
${SPARK_HOME}/bin/spark-submit --jars ${CELEBORN_CLIENT_JAR} \
  --conf spark.shuffle.manager=org.apache.spark.shuffle.celeborn.SparkShuffleManager \
  ${CASE_DIR}/scripts/workload/run_queries.py --manifest ${WORKLOAD_MANIFEST} --sample 1 --out ${RESULTS_DIR}/runs/sample1/queries.jsonl

# 解析与清理
python3 ${CASE_DIR}/scripts/results/parse_benchmark.py --results-dir ${RESULTS_DIR} \
  --manifest ${WORKLOAD_MANIFEST} --samples 6 --scale-factor 3 \
  --shuffle-bytes ${MEAN_SHUFFLE_BYTES} --output ${RESULTS_DIR}/benchmark_celeborn.json
${CELEBORN_HOME}/sbin/stop-all.sh
```

- `--keep-workdir` 保留 `${PERF_WORK_DIR}`（默认删除，删除前校验路径必须是 `/home/runner/boostkit-perf/celeborn/local-*`）。
- `--variant optimized` 在构建阶段明确失败（退出码 30），不退回 base、不写 `benchmark_celeborn.json`、不更新基线。
- 独立入口默认把结果写到 `--results-dir`，并额外生成 `results.json` 与 `report.md`。

## 已知限制

- **单容器而非 YARN 集群**：文档环境是 HDFS + YARN + Hive + Tez + Spark（200 执行器 × 8 核 × 23 GiB）的多机
  集群，本用例在单容器内以 `local[*]` 承载 Spark，Shuffle 仍由 Celeborn worker 经网络提供（每轮均有正数
  Shuffle 字节作为证据）。因此绝对耗时不能与文档的集群数值直接比较，适合做**同环境前后对比**。
- **数据规模**：默认 SF3 而文档是 SF100；SF100（约 100 GB 文本）超出单容器磁盘/内存预算。规模记录在
  `benchmark_celeborn.json` 与 `build_variant.json`，跨规模不配对。
- **表结构**：文档用 Hive 分区 ORC 表（`ddl-tpcds/bin_partitioned/*.sql`）；本用例没有 Hive metastore，
  改为按同一份列定义建立的**平铺 ORC 表**（嵌入式 Derby 提供跨轮次元数据）。查询文本未改动。
- **Shuffle 管理器**：文档指定 Gluten 1.3.0 的 `org.apache.spark.shuffle.gluten.celeborn.CelebornShuffleManager`，
  本用例使用 Celeborn 原生的 `org.apache.spark.shuffle.celeborn.SparkShuffleManager`。原因是 Gluten 1.3.0
  发行包内含与架构绑定的原生库（x86_64 归档不能用于 aarch64），其 Celeborn 管理器只是把调用委托给原生管理器；
  两者的远程 Shuffle 路径相同。切换需在 aarch64 上另有可验证的 Gluten 组合，目前没有实测证据，故不声明。
- **Shuffle 量取轮次中位数**：某轮若发生 stage 重试，该轮会额外写入一份 Shuffle 数据（本次实测出现过
  286 MB 与 511 MB 并存），因此 `celeborn.shuffle.bytes.written` 与吞吐都按 5 个有效轮次的中位数计算，
  `shuffle-summary.json` 保留每轮值、最大值与最小值供复核；不剔除任何离群轮次，也不改写原始记录。
- **关闭 AQE**：`spark.sql.adaptive.enabled=false`。开启时同一组 99 条查询在不同轮次的 Shuffle 量在
  540 MB 与 884 MB 之间跳变（AQE 依据运行时统计重规划 join 与分区），指标不可比；关闭后每轮 Shuffle 量
  稳定在 286 MB 量级（轮次间差异 < 0.01%）。文档集群默认开启 AQE，因此绝对耗时与文档不可配对。
- **未实现 optimized 变体**：`scripts/builders/optimized.sh` 只返回失败，不产生任何数字。
- **SQL 兼容改写**：上游 `sample-queries-tpcds` 是 Hive/Tez 语法，其中 5 条语句无法被 Spark 3.5 解析
  （Q14/Q23/Q24/Q39 在同一文件里各含两条等价改写，Q72 用 `INTERVAL(5) DAY`）。用例只做两处确定性改写：
  区间写法改为 `interval N unit`、多改写文件取第一条；表名、列名、谓词、连接顺序与语句顺序均未改动，
  改写后的文本参与清单摘要，99 条语句在 Spark 3.5.2 上 `EXPLAIN` 全部通过。
- **网络约束**：下载只走 Apache 归档、华为云 Apache 镜像、GitHub 与 `gitcode` 公开发布件；离线 runner 依赖
  `/home/runner/software/celeborn/` 预置四个归档。容器内 `dnf` 依赖华为 openEuler 镜像可达。
- **无基准数字**：本 README 不写任何未经产物验证的数值。
