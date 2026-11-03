# Kafka 2.5.0 性能测试

本用例按《鲲鹏服务器大数据性能测试一本通》第 7.5.1 节的单机生产者/消费者
场景测试 Apache Kafka 2.5.0。x86_64 与 aarch64 各在一台 Runner 上启动一个
私有 openEuler 24.03 LTS SP4 容器，使用 Kafka 发行包自带的两个性能测试程序，
分别报告生产和消费吞吐量（MB/s，越高越好）。容器不限制 CPU/内存、不绑核，
数据保存在本次任务的 `/home/runner/boostkit-perf/kafka/` 子目录，不使用系统 Kafka。

Framework 只调用 `case.yaml` 指定的构建、启动、测试、停止四个函数；
`kafka_test.sh` 独立入口调用同一组函数。`base` 使用官方发行包；
`optimized` 构建尚未实现，选择后会明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务的位置 |
|---|---|---|
| Kafka 与两个压测程序 | [Apache 归档](https://archive.apache.org/dist/kafka/2.5.0/)的 `kafka_2.12-2.5.0.tgz` | `${PERF_WORK_DIR}/kafka_2.12-2.5.0` |
| ZooKeeper | [Apache 归档](https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/)的 `apache-zookeeper-3.6.2-bin.tar.gz` | `${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin` |
| Java | openEuler `java-11-openjdk-headless` | 仅安装在本次私有容器 |
| 容器镜像 | [openEuler 24.03 LTS SP4 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | Docker daemon；按架构加载 |

## 工作目录与前置条件

Runner 必须能使用 Docker daemon，且运行数据的文件系统至少有 **25 GB 空余**。
容器不下载 Docker Hub 镜像；下载软件包、容器内安装 Java 才需要访问仓库。
宿主机若缺少 `curl`、`tar`、`coreutils`、`gawk`、`sed`，构建阶段使用
`sudo -n dnf install -y ...` 补齐；Docker 本身须由 Runner 预先安装。

| 变量或目录 | Framework 分阶段运行 | 直接运行 `kafka_test.sh` |
|---|---|---|
| `PERF_WORK_DIR` | `/home/runner/boostkit-perf/kafka/2.5.0/<架构>/<run-id>` | `/home/runner/boostkit-perf/kafka/local-<run-id>` |
| `RESULTS_DIR` | 仓库 `.perf-output/Bigdata/kafka/2.5.0/<架构>/<run-id>` | 默认 `software/Bigdata/kafka/results/2.5.0/<run-id>`；可用 `--results-dir` 指定 |
| `PERF_ACTUAL_VERSION_FILE` | `${PERF_WORK_DIR}/actual-version.txt` | 同左 |
| Kafka 离线包目录 | `/home/runner/software/kafka/` | 同左；可由 `KAFKA_OFFLINE_DIR` 修改 |
| openEuler 镜像目录 | `/home/runner/software/openEuler-24.03-LTS-SP4/` | 同左；可由 `KAFKA_IMAGE_ARCHIVE_DIR` 修改 |
| 代理证书目录 | `/home/runner/software/anchors/` | 同左；可由 `KAFKA_CA_ANCHORS_DIR` 修改 |

`build`、`start`、`test`、`stop` 各自在新 Shell 中执行，靠上述私有目录和运行 ID
恢复状态。`${PERF_WORK_DIR}` 挂载到容器内的**同一路径**，因此容器内程序写入
`data/kafka/`，实际占用的是宿主机 `/home/runner` 所在的持久磁盘。

## 获取、校验与安装

构建脚本先查找两个本地离线包；缺少时下载对应的 Apache 官方归档：

```bash
# 在宿主机执行；只有离线包不存在时才下载。
curl -fSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/kafka_2.12-2.5.0.tgz" \
  https://archive.apache.org/dist/kafka/2.5.0/kafka_2.12-2.5.0.tgz
curl -fSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin.tar.gz" \
  https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz
```

脚本使用以下固定 SHA-512 校验值，无论本地读取还是网络下载都必须匹配：

| 文件 | SHA-512 |
|---|---|
| `kafka_2.12-2.5.0.tgz` | `447a7057bcd9faca98b6f4807bd6019ef73eee90efdc1e7b10005f669e2537a8a190cb8b9c9f4c20db1d95b13d0f0487e9cc560d0759532058439ce7f722c7cd` |
| `apache-zookeeper-3.6.2-bin.tar.gz` | `caff5111bb6876b7124760bc006e6fa2523efa54b99321a3c9cd8192ea0d5596abc7d70a054b1aac9b20a411407dae7611c7aba870c23bff28eb1643ba499199` |

脚本用 `sha512sum -c -` 对选中的归档逐一校验。需要手动核对时，可执行
`sha512sum <实际归档路径>` 并与上表比较；不匹配则停止，不继续解压。
校验后在宿主机解压，两个发行包及其可执行脚本只放在本次工作目录：

```bash
tar -xzf "${PERF_WORK_DIR}/kafka_2.12-2.5.0.tgz" -C "${PERF_WORK_DIR}"
tar -xzf "${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin.tar.gz" -C "${PERF_WORK_DIR}"
```

## 加载镜像并创建私有容器

镜像包名为 `openEuler-docker.x86_64.tar.xz` 或
`openEuler-docker.aarch64.tar.xz`。构建脚本先取公共离线目录的归档和同名
`.sha256sum`；缺哪个就从
`https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<架构>/`
下载哪个。核对 SHA-256 后运行：

```bash
# 在宿主机执行；IMAGE_ARCHIVE 是实际选中的归档路径。
docker load --input "${IMAGE_ARCHIVE}"
docker image inspect "${KAFKA_CONTAINER_IMAGE}"  # 核对 amd64/arm64 架构
docker run --rm --network=none "${KAFKA_CONTAINER_IMAGE}" cat /etc/os-release
```

`${KAFKA_CONTAINER_IMAGE}` 是 `docker load` 返回的镜像引用，脚本不会猜测固定镜像名。
核对容器系统为 openEuler 24.03 LTS SP4 后，创建私有容器。以下命令展示
启用和不启用 `PERF_PROXY` 时的完整挂载逻辑：

```bash
# 在宿主机执行；PERF_PROXY 非空时挂载本地代理根证书。
cert_mount=()
if [[ -n "${PERF_PROXY:-}" ]]; then
  cert_mount=(--mount "type=bind,source=${KAFKA_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
fi
docker run --detach --name "${KAFKA_CONTAINER_NAME}" \
  --label "boostkit.kafka.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${cert_mount[@]}" "${KAFKA_CONTAINER_IMAGE}" sleep infinity
```

随后用 `docker exec` 在容器内执行以下准备操作；不配置 `PERF_PROXY` 时跳过
证书更新，并将 `dnf --setopt="proxy=..."` 改为普通 `dnf`。下载归档时也仅在
`PERF_PROXY` 非空的情况下临时把它传给 `curl` 的 `http_proxy`、`https_proxy`。

```bash
docker exec --user 0 "${KAFKA_CONTAINER_NAME}" update-ca-trust extract
docker exec --user 0 "${KAFKA_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
docker exec --user 0 "${KAFKA_CONTAINER_NAME}" \
  dnf --setopt="proxy=${PERF_PROXY}" install -y java-11-openjdk-headless
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-topics.sh" --version
```

版本命令必须报告 `2.5.0`；脚本还确认 ZooKeeper 3.6.2 的 JAR 文件存在，
然后写入 `${PERF_ACTUAL_VERSION_FILE}`。容器内的 `dnf` 和仓库地址修改
只影响本次容器，不修改宿主机软件源或系统 Java。

## 启动与数据目录

`start` 阶段按运行 ID 计算端口：`KAFKA_PORT = 20000 +
(cksum(run-id) mod 20000)`，`ZOOKEEPER_PORT = KAFKA_PORT + 1`。容器名为
`boostkit-kafka-<架构>-<run-id>`。脚本在启动前检查这两个端口是否已被占用，
不会覆盖现有服务。容器采用宿主网络，但两项服务都只监听 `127.0.0.1`。

脚本在 `${PERF_WORK_DIR}` 下创建以下目录和文件；配置文件的实际内容如下，
只有路径和端口随本次运行变化：

| 路径 | 用途 |
|---|---|
| `${PERF_WORK_DIR}/conf/zookeeper.properties` | ZooKeeper 监听地址、端口和数据目录 |
| `${PERF_WORK_DIR}/conf/server.properties` | 单 Broker、72 分区、单副本、Kafka 日志目录 |
| `${PERF_WORK_DIR}/conf/producer.properties` | 生产端配置 |
| `${PERF_WORK_DIR}/data/zookeeper` | ZooKeeper 状态 |
| `${PERF_WORK_DIR}/data/kafka` | Kafka 消息及索引，位于持久磁盘 |
| `${PERF_WORK_DIR}/logs` | 服务原始日志 |

`conf/zookeeper.properties`：

```properties
tickTime=2000
initLimit=10
syncLimit=5
dataDir=<PERF_WORK_DIR>/data/zookeeper
clientPort=<ZOOKEEPER_PORT>
clientPortAddress=127.0.0.1
admin.enableServer=false
```

`conf/server.properties`：

```properties
broker.id=0
listeners=PLAINTEXT://127.0.0.1:<KAFKA_PORT>
advertised.listeners=PLAINTEXT://127.0.0.1:<KAFKA_PORT>
log.dirs=<PERF_WORK_DIR>/data/kafka
zookeeper.connect=127.0.0.1:<ZOOKEEPER_PORT>
num.partitions=72
default.replication.factor=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
group.initial.rebalance.delay.ms=0
auto.create.topics.enable=false
delete.topic.enable=true
```

`conf/producer.properties`：

```properties
compression.type=lz4
acks=1
linger.ms=500
batch.size=65536
max.request.size=1073741824
buffer.memory=134217728
```

配置中的 `<PERF_WORK_DIR>`、`<KAFKA_PORT>`、`<ZOOKEEPER_PORT>` 是本次运行
生成的实际值，不是需要手动保留的占位文本。脚本先启动 ZooKeeper，最多等待
60 秒；再启动 Broker，最多等待 180 秒；最后创建 72 分区、单副本的 Topic：

```bash
docker exec -e "ZOO_LOG_DIR=${PERF_WORK_DIR}/logs" "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin/bin/zkServer.sh" \
  start "${PERF_WORK_DIR}/conf/zookeeper.properties"
docker exec -e "LOG_DIR=${PERF_WORK_DIR}/logs" "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-server-start.sh" \
  -daemon "${PERF_WORK_DIR}/conf/server.properties"
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-topics.sh" --create \
  --bootstrap-server "127.0.0.1:${KAFKA_PORT}" \
  --replication-factor 1 --partitions 72 --topic test_topic_kafka
```

每一步均校验返回码或就绪状态；不会连接 Runner 上已有的 Kafka 服务。

## 测试与指标

附件给出的性能工具及主要负载参数保持不变：单机、72 分区、单副本、1 KiB
消息、生产端不限速、消费端 `--fetch-size 1024`。为了让自动化测试能够结束，
生产与消费都固定为 **10,000,000 条消息**，数据净载荷约 9.54 GiB；
运行前要求私有数据盘至少有 25 GB 空余。两架构使用完全相同的数量和参数。
正式测试耗时取决于实际吞吐，约为 `9765.63 / 生产 MB/s + 9765.63 / 消费 MB/s`
秒，再加启动及 Topic 创建时间；每个 Framework 阶段的超时上限为 180 分钟。

测试阶段先确认 Topic 可访问，再生产、消费同一 Topic 中的消息。下列为脚本
在宿主机调用容器内官方工具的命令形式；实际脚本还通过 `docker exec -e` 设置
容器内的私有 `HOME`、`TMPDIR`：

```bash
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-producer-perf-test.sh" \
  --topic test_topic_kafka \
  --num-records 10000000 --record-size 1024 --throughput -1 \
  --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
  --producer.config "${PERF_WORK_DIR}/conf/producer.properties" \
  2>&1 | tee "${RESULTS_DIR}/producer.log"

docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-consumer-perf-test.sh" \
  --broker-list "127.0.0.1:${KAFKA_PORT}" \
  --topic test_topic_kafka --fetch-size 1024 --messages 10000000 \
  2>&1 | tee "${RESULTS_DIR}/consumer.log"
```

`scripts/results/parse_benchmark.py` 从生产工具最终摘要的 `MB/sec` 和消费工具
CSV 的 `MB.sec` 字段各提取一项。它要求两项吞吐量均为正数、结果各只有一条、
生产和消费记录数均为 10,000,000；任一条件不满足则测试失败，不会填入估计值。
单架构与跨架构报告分别按“生产者”“消费者”分组；最终各有一项
`producer/throughput`、`consumer/throughput`，单位均为 MB/s，越大越好。
例如两个官方工具分别输出 120.5 和 118.2 MB/s 时，
`benchmark_kafka.json` 的指标部分为：

```json
{
  "results": {
    "producer/throughput": {"value": 120.5, "unit": "MB/s", "direction": "higher_is_better", "group": "生产者"},
    "consumer/throughput": {"value": 118.2, "unit": "MB/s", "direction": "higher_is_better", "group": "消费者"}
  }
}
```

此处数值仅演示报告结构，不是实测结果；实际 JSON 还包含固定的 `parameters`。

| 结果文件 | 内容 |
|---|---|
| `${RESULTS_DIR}/producer.log`、`consumer.log` | 两个官方工具的完整输出 |
| `${RESULTS_DIR}/benchmark_kafka_raw.log` | 按先生产、后消费顺序合并的原始输出 |
| `${RESULTS_DIR}/benchmark_kafka.json` | 两项 MB/s 指标及跨架构一致的负载参数 |
| `${RESULTS_DIR}/service-logs/` | 停止阶段复制的 Kafka/ZooKeeper 服务日志 |

`stop` 先核对容器上的 `boostkit.kafka.run-id` 标签等于当前运行 ID，再尝试
停止 Kafka 和 ZooKeeper，将 `${PERF_WORK_DIR}/logs/` 复制到结果目录，最后
执行 `docker stop --time 30`、`docker rm`。标签不匹配时拒绝删除容器。
Framework 在 `${RESULTS_DIR}` 生成 `normalized_result.json`、`report.md` 等
通用产物；工作流随后负责清理本次任务的工作目录。

运行中排查可在对应 Runner 上查看以下位置，`<架构>` 和 `<run-id>` 应替换为
流水线实际值：

```bash
docker ps --filter 'name=boostkit-kafka-'
find /home/runner/boostkit-perf/kafka/2.5.0/<架构>/<run-id>/logs -type f -print
tail -n 50 .perf-output/Bigdata/kafka/2.5.0/<架构>/<run-id>/producer.log
tail -n 50 .perf-output/Bigdata/kafka/2.5.0/<架构>/<run-id>/consumer.log
```

## 独立运行

在 Runner 上从仓库根目录执行：

```bash
bash software/Bigdata/kafka/kafka_test.sh \
  --version 2.5.0 --variant base \
  --results-dir /home/runner/kafka-results/2.5.0
```

独立入口产生 `results.json` 和 `report.md`，成功或失败都会尝试停止私有容器。
排障时加 `--keep-workdir`，保留本次安装包、数据和服务日志；不指定该选项时，
独立入口只清理自己创建的 `local-<run-id>` 工作目录。
