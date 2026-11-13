# Kafka 2.5.0 性能测试

本用例按《鲲鹏服务器大数据性能测试一本通》第 7.5.1 节的单机生产者/消费者
场景测试 Apache Kafka 2.5.0。x86_64 与 aarch64 各在一台 Runner 上启动一个
私有 openEuler 24.03 LTS SP4 容器，使用 Kafka 发行包自带的两个性能测试程序，
分别报告生产和消费吞吐量（MB/s，越高越好）。默认负载为 **8 Topic × 9 分区**
的并行生产/消费（8 个生产者进程、8 个消费者进程 × 5 线程），单机单进程的
小规模场景可通过 `KAFKA_TOPICS=1` 复现。容器不限制 CPU/内存、不绑核，
数据保存在本次任务的 `/home/runner/boostkit-perf/kafka/` 子目录，不使用系统 Kafka。
生产与消费数据目录应落在 **NVMe** 上（例如 `/data/data1/...`），否则冷读消费会
被机械盘/RAID 逻辑卷限制；多 Topic + 多进程 + 冷读的可复现实验方法见下文。

Framework 只调用 `case.yaml` 指定的构建、启动、测试、停止四个函数；
`kafka_test.sh` 独立入口调用同一组函数。`base` 使用官方发行包；
`optimized` 构建尚未实现，选择后会明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务的位置 |
|---|---|---|
| Kafka 与两个压测程序 | [Apache 归档](https://archive.apache.org/dist/kafka/2.5.0/)的 `kafka_2.12-2.5.0.tgz` | `${PERF_WORK_DIR}/kafka_2.12-2.5.0` |
| ZooKeeper | [Apache 归档](https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/)的 `apache-zookeeper-3.6.2-bin.tar.gz` | `${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin` |
| Java | openEuler `java-11-openjdk-headless` | 默认安装在本次私有容器；无外网时可复用宿主机 Java（见下文） |
| 容器镜像 | [openEuler 24.03 LTS SP4 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | Docker daemon；按架构加载 |

## 本次测试环境

| 架构 | Runner IP | Kafka / ZooKeeper 离线包 | 数据盘 |
|---|---|---|---|
| x86_64 | 90.91.181.112 | `/usr/local/kafka_2.12-2.5.0.tgz`、`/usr/local/apache-zookeeper-3.6.2-bin.tar.gz` | `/data/data1`（NVMe，符号链接自 `/home/runner/boostkit-perf`） |
| aarch64 | 90.91.179.186 | 同上 | `nvme0n1`（NVMe，`/` 所在盘） |

两平台均已配置 root 免密登录；容器镜像均为 `openeuler-24.03-lts-sp4:latest`，
Docker 分别使用 host 网络与私有工作目录。

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

### 使用 NVMe 作为数据盘

`/home/runner` 可能是 RAID 逻辑卷（冷读随机性能可能仅约 500 MB/s）。建议把
Kafka 数据放到 NVMe，用一个符号链接保持脚本默认路径不变：

```bash
# 在 Runner 上执行；假设 /data/data1 是 NVMe 挂载点
docker rm -f boostkit-kafka-x86_64-kafka-run1 2>/dev/null || true
mkdir -p /data/data1/boostkit-perf
rm -rf /home/runner/boostkit-perf
ln -s /data/data1/boostkit-perf /home/runner/boostkit-perf

# 校验：数据目录应显示 nvme 设备
df -h /home/runner/boostkit-perf/kafka/local-kafka-run1/data
```

迁移后需重新执行 `build`、`start`（旧容器与工作目录先删除），否则容器仍可能
挂载旧的数据目录。

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
若 Runner 上执行 `docker images` 已能看到 `openeuler-24.03-lts-sp4:latest`，可跳过
镜像下载与 `docker load`，直接把镜像引用写入
`${PERF_WORK_DIR}/container-image.txt` 即可（构建脚本会先检查该文件）。
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
  --mount type=bind,source=/usr/lib/jvm,target=/usr/lib/jvm,readonly \
  --mount type=bind,source=/etc/java,target=/etc/java,readonly \
  "${cert_mount[@]}" "${KAFKA_CONTAINER_IMAGE}" sleep infinity
```

`/usr/lib/jvm` 与 `/etc/java` 两个挂载用于“复用宿主机 Java 11”的离线场景；
若容器内通过 `dnf` 安装 Java，可省略这两个挂载。

随后用 `docker exec` 在容器内执行以下准备操作；不配置 `PERF_PROXY` 时跳过
证书更新，并将 `dnf --setopt="proxy=..."` 改为普通 `dnf`。下载归档时也仅在
`PERF_PROXY` 非空的情况下临时把它传给 `curl` 的 `http_proxy`、`https_proxy`。

**方式一：联网安装 Java（脚本默认）**

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

**方式二：无外网时复用宿主机 Java 11**

宿主机已安装 `java-11-openjdk-headless` 时，直接设置 `KAFKA_JAVA_MODE=host`
即可。`base.sh` 会自动挂载 `/usr/lib/jvm` 与 `/etc/java`，并在容器内建立
`/usr/bin/java` 链接，跳过 `dnf`：

```bash
export KAFKA_JAVA_MODE=host
# 重新执行 build 阶段；容器内 Java 版本可用以下命令确认
docker exec "${KAFKA_CONTAINER_NAME}" /usr/bin/java -version
```

Java 的 `conf` 目录通常是指向 `/etc/java/...` 的符号链接，因此 `/etc/java`
必须一起挂载，否则会出现 `Error loading java.security file`。

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
num.io.threads=32
num.network.threads=32
```

`conf/producer.properties`（本次调优后的最终值，已移除 `compression.type=lz4`）：

```properties
acks=all
linger.ms=500
batch.size=65536
max.request.size=1073741824
buffer.memory=134217728
retries=0
key.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
socket.send.buffer.bytes=524288
socket.receive.buffer.bytes=524288
```

与旧配置相比：`acks` 从 `1` 改为 `all`、`retries=0`、显式指定 ByteArray
序列化器、增加收发 socket 缓冲；删除 LZ4 压缩后，生产端写入的是原始 1 KiB
记录，吞吐会低于压缩配置，但更接近真实写入压力。

配置中的 `<PERF_WORK_DIR>`、`<KAFKA_PORT>`、`<ZOOKEEPER_PORT>` 是本次运行
生成的实际值，不是需要手动保留的占位文本。脚本先启动 ZooKeeper，最多等待
60 秒；再启动 Broker，最多等待 180 秒；最后创建 72 分区、单副本的 Topic：

```bash
docker exec -e "ZOO_LOG_DIR=${PERF_WORK_DIR}/logs" "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/apache-zookeeper-3.6.2-bin/bin/zkServer.sh" \
  start "${PERF_WORK_DIR}/conf/zookeeper.properties"
docker exec -e "LOG_DIR=${PERF_WORK_DIR}/logs" \
  -e "KAFKA_HEAP_OPTS=${KAFKA_BROKER_HEAP_OPTS:--Xmx128G -Xms128G}" \
  "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-server-start.sh" \
  -daemon "${PERF_WORK_DIR}/conf/server.properties"
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-topics.sh" --create \
  --bootstrap-server "127.0.0.1:${KAFKA_PORT}" \
  --replication-factor 1 --partitions 72 --topic test_topic_kafka
```

每一步均校验返回码或就绪状态；不会连接 Runner 上已有的 Kafka 服务。

## 测试与指标

附件给出的性能工具与主要负载参数保持不变，本次调优后的默认值如下：

| 参数 | 默认值 | 说明 |
|---|---|---|
| 消息条数 | 10,000,000 | 数据净载荷约 9.54 GiB；每 Topic 1,250,000 条 |
| 单条记录大小 | 1024 B | 未压缩原始大小 |
| Topic 数 | 8 | `KAFKA_TOPICS`，每个 Topic 一个生产者/消费者进程 |
| 分区数 | 72（8 × 9） | 单副本，每 Topic 9 分区 |
| 消费 fetch | 1 MiB (`1048576`) | 原值 1024 B，已提升 |
| 消费线程 | 5/进程（总 40） | `KAFKA_CONSUMER_THREADS` |
| 生产者进程 | 8 | 每 Topic 一个进程，吞吐求和 |
| Broker 堆 | `-Xmx128G -Xms128G` | 原默认 1G |
| 压测工具堆 | `-Xmx4096M` | 原默认 256M |

相关环境变量均可覆盖：

```bash
export KAFKA_RECORDS=10000000          # 总消息数（需被 KAFKA_TOPICS 整除）
export KAFKA_RECORD_SIZE=1024          # 单条字节数
export KAFKA_TOPICS=8                  # Topic 数（设为 1 回到单 Topic 场景）
export KAFKA_PARTITIONS=72             # 总分区（需被 KAFKA_TOPICS 整除）
export KAFKA_CONSUMER_FETCH_SIZE=1048576
export KAFKA_CONSUMER_THREADS=5        # 每个消费者进程的线程数
export KAFKA_PRODUCER_PROCS=8          # 多 Topic 时必须等于 KAFKA_TOPICS
export KAFKA_BROKER_HEAP_OPTS="-Xmx128G -Xms128G"
export KAFKA_TOOLS_HEAP_OPTS="-Xmx4096M"
export KAFKA_JAVA_MODE=host            # package（默认，容器内 dnf 安装）或 host（复用宿主 Java）
export KAFKA_NUM_IO_THREADS=32         # Broker num.io.threads
export KAFKA_NUM_NETWORK_THREADS=32    # Broker num.network.threads
```

**冷读测试要求**：生产完成后、消费开始前必须清理页缓存，否则消费会命中
page cache，测出的不是磁盘能力。需 root 执行：

```bash
sync
echo 3 > /proc/sys/vm/drop_caches
```

用例默认不自动清理页缓存（容器内非 root 无法写 `/proc/sys/vm/drop_caches`），
因此消费吞吐包含 page cache 影响；严格冷读需在 Runner 上以 root 执行上面的
命令，或另行在测试阶段前增加这一步。运行前要求私有数据盘至少有 **25 GB**
空余（1 亿条时约 95 GiB）。两架构使用完全相同的数量和参数。每个 Framework
阶段的超时上限为 180 分钟。

测试阶段先确认 8 个 Topic 均可访问，然后并行生产、并行消费；下列为脚本在
宿主机调用容器内官方工具的命令形式（Topic 名称 `test_topic_kafka_1..8`，
每 Topic 1,250,000 条、9 分区）。实际脚本还通过 `docker exec -e` 设置容器内
的私有 `HOME`、`TMPDIR` 和工具堆：

```bash
# 8 个生产者进程并行，每进程一个 Topic
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-producer-perf-test.sh" \
  --topic test_topic_kafka_<1..8> \
  --num-records 1250000 --record-size 1024 --throughput -1 \
  --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
  --producer.config "${PERF_WORK_DIR}/conf/producer.properties" \
  > "${PERF_WORK_DIR}/producer_parts/part_<1..8>.log" 2>&1 &

# 8 个消费者进程并行，每进程一个 Topic、5 线程
docker exec "${KAFKA_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/kafka_2.12-2.5.0/bin/kafka-consumer-perf-test.sh" \
  --broker-list "127.0.0.1:${KAFKA_PORT}" \
  --topic test_topic_kafka_<1..8> --fetch-size 1048576 --threads 5 \
  --messages 1250000 > "${PERF_WORK_DIR}/consumer_parts/part_<1..8>.log" 2>&1 &
```

`scripts/results/parse_benchmark.py` 从生产工具最终摘要的 `MB/sec` 和消费工具
CSV 的 `MB.sec` 字段各提取一项。生产工具可能先输出多条中途进度；脚本对每个
进程只取**最后一条**摘要，再把 8 个进程合并为一条总摘要（记录数求和、MB/s
求和、延迟按记录数加权），消费者同样把 8 个进程的 `MB.sec` 与记录数求和，
然后交给解析器。解析器还要求消费记录数为 `KAFKA_RECORDS`、两项吞吐量均为
正数；任一条件不满足则测试失败，不会填入估计值。
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

## 默认 8 × 9 多 Topic 并行配置

单 Topic 下把消费者从 10 增加到 40，吞吐基本不变；将消费者拆成多个独立
消费组（每个 Topic 一组、独立 JVM 进程）可以绕过单组协调/单 JVM 瓶颈。
用例默认即使用 **8 Topic × 9 分区** 配置（总分区 72、总数据 1000 万条），
下表为该配置在 x86 与 ARM 上的复现结果，可用来核对量级。

| 项目 | 值 |
|---|---|
| Topic 数 | 8 |
| 每 Topic 分区 | 9（总 72） |
| 生产 | 8 个进程，每个 1,250,000 条 |
| 消费 | 8 个进程 × 每进程 5 线程（总 40） |
| fetch-size | 1048576 |
| Broker 堆 / 工具堆 | `-Xmx128G -Xms128G` / `-Xmx4096M` |
| 缓存 | 生产后 `sync + drop_caches`，消费为冷读 |
| 吞吐口径 | 每个生产者/消费者的 MB/s 或 MB.sec 相加 |

复现脚本（在 Runner 上以 root 执行）：

```bash
#!/bin/bash
set -u
ARCH=$(uname -m)
C="boostkit-kafka-${ARCH}-kafka-run1"
W="/home/runner/boostkit-perf/kafka/local-kafka-run1"
P=39209
K="$W/kafka_2.12-2.5.0/bin"
RUN="docker exec -e HOME=$W -e TMPDIR=$W/tmp -e KAFKA_HEAP_OPTS=-Xmx4096M $C"
T=8; PART=9; REC=1250000; TH=5

for t in $(seq 1 $T); do
  $RUN "$K/kafka-topics.sh" --delete --bootstrap-server 127.0.0.1:$P --topic "kafka_multi_$t" >/dev/null 2>&1
done
sleep 8
for t in $(seq 1 $T); do
  $RUN "$K/kafka-topics.sh" --create --bootstrap-server 127.0.0.1:$P \
    --replication-factor 1 --partitions $PART --topic "kafka_multi_$t" >/dev/null 2>&1
done

sync; echo 3 > /proc/sys/vm/drop_caches
for t in $(seq 1 $T); do
  $RUN "$K/kafka-producer-perf-test.sh" --topic "kafka_multi_$t" --num-records $REC \
    --record-size 1024 --throughput -1 \
    --producer-props "bootstrap.servers=127.0.0.1:$P" \
    --producer.config "$W/conf/producer.properties" > /tmp/prod_$t.log 2>&1 &
done
wait

sync; echo 3 > /proc/sys/vm/drop_caches
for t in $(seq 1 $T); do
  $RUN "$K/kafka-consumer-perf-test.sh" --broker-list "127.0.0.1:$P" --topic "kafka_multi_$t" \
    --fetch-size 1048576 --threads $TH --messages $REC > /tmp/cons_$t.log 2>&1 &
done
wait

PSUM=0; CSUM=0
for t in $(seq 1 $T); do
  p=$(sed -n 's/.*(\([0-9.]*\) MB\/sec).*/\1/p' /tmp/prod_$t.log | tail -1)
  c=$(sed '/egrep: warning/d' /tmp/cons_$t.log | tail -1 | awk -F', ' '{print $4}')
  echo "topic$t producer=$p consumer=$c MB/s"
  PSUM=$(python3 -c "print($PSUM+${p:-0})")
  CSUM=$(python3 -c "print($CSUM+${c:-0})")
done
echo "PRODUCER_SUM=$PSUM MB/s CONSUMER_SUM=$CSUM MB/s"
```

说明：

- 每个消费者进程使用独立的默认消费组，避免 40 个消费者挤在同一组导致
  rebalance 和分区分配不均。实测同一 Topic + 4 进程同组仅约 542 MB/s，
  远低于独立组方案。
- 各进程 `MB/s` 是各自运行窗口的平均值，求和口径通常高于“总数据量 / 墙钟”；
  对比时必须固定口径，报告建议同时给出墙钟整体吞吐。
- 生产者没有 `--threads` 参数，并行生产必须启动多个进程。

### 6/8/10 Topic 对比（各进程吞吐总和）

| Topic 数 | 每 Topic 分区 | 每 Topic 消费线程 | x86 生产 | ARM 生产 | x86 消费 | ARM 消费 |
|---|---|---|---|---|---|---|
| 6 | 12 | 7 | 3814.48 | 3603.22 | 3931.85 | 4241.13 |
| 8 | 9 | 5 | 4840.77 | 4265.57 | 4431.96 | 4501.54 |
| 10 | 7 | 4 | 5597.09 | 5208.60 | 4059.38 | 4739.36 |

单位 MB/s。8 Topic 时两平台消费相差约 1.5%，推荐作为跨架构对比配置。

### 8 Topic 三轮平均值

| 平台 | 生产平均 | 消费平均 |
|---|---|---|
| x86（90.91.181.112） | 4757.45 MB/s | 4070.30 MB/s |
| ARM（90.91.179.186） | 4459.03 MB/s | 4448.57 MB/s |

消费三轮波动约 7%~10%，建议增加轮次以降低噪声。

## Broker 线程与缓存观测

`start.sh` 生成 `conf/server.properties` 时已写入以下两项，可用
`KAFKA_NUM_IO_THREADS`、`KAFKA_NUM_NETWORK_THREADS` 覆盖（默认 32；
修改后需重启 Broker 生效）：

```properties
num.io.threads=32
num.network.threads=32
```

消费期间建议同时采集：

```bash
iostat -x 5          # r/s、rkB/s、r_await、%util
mpstat 5             # CPU idle、softirq
docker stats --no-stream --format \
  '{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.BlockIO}}'
```

判读要点：

- `%util` 接近 100% 且 `r_await` 高：存储瓶颈；
- CPU idle 高、磁盘 util 低但吞吐不涨：每请求/单线程处理或延迟瓶颈，
  此时继续增加消费者通常无效；
- 冷读与热读必须分别标注。x86 数据盘为 RAID 逻辑卷时曾出现热读
  1817 MB/s、冷读仅 460 MB/s；迁移到 NVMe 后冷读提升到约 1589 MB/s
  （1000 万条）和 1908 MB/s（1 亿条）。

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

## 本次代码变更摘要

| 文件 | 变更 |
|---|---|
| `scripts/common.sh` | `KAFKA_RECORDS`/`KAFKA_RECORD_SIZE`/`KAFKA_PARTITIONS`/`KAFKA_TOPICS`/`KAFKA_CONSUMER_THREADS` 支持环境变量覆盖，并校验 Topic 数整除关系；`kafka_exec` 注入 `KAFKA_HEAP_OPTS=${KAFKA_TOOLS_HEAP_OPTS:--Xmx4096M}` |
| `scripts/builders/base.sh` | 新增 `KAFKA_JAVA_MODE=host`：条件挂载 `/usr/lib/jvm`、`/etc/java`，并用 `ln -sf` 复用宿主 Java 11；默认仍为容器内 `dnf` 安装 |
| `scripts/stages/start.sh` | `producer.properties` 改为 `acks=all`、`retries=0`、ByteArray 序列化器、socket 缓冲，删除 `compression.type=lz4`；启动 Broker 注入 `KAFKA_HEAP_OPTS=${KAFKA_BROKER_HEAP_OPTS:--Xmx128G -Xms128G}`；`server.properties` 增加可配置的 `num.io.threads`/`num.network.threads`（默认 32）；按 `KAFKA_TOPICS` 创建 8 × 9 分区 Topic |
| `scripts/stages/test.sh` | 默认 8 Topic 并行：每 Topic 一个生产者进程（1,250,000 条）与一个消费者进程（5 线程、fetch 1 MiB），逐进程取最终摘要后求和，再交给解析器 |
| `scripts/results/parse_benchmark.py` | `parameters` 记录本次实际使用的 `topics`/`partitions_per_topic`/`records_per_topic`/`record_size_bytes`/`producer_processes`/`consumer_processes` 与 `consumer.fetch_size_bytes`/`threads`，并新增同名 CLI 参数；解析仍保持严格（缺摘要、摘要重复、记录数不符或吞吐非正数都失败） |

复现时请使用上述五个文件的最新版本。仍属于**环境步骤**而非代码的部分：
NVMe 数据盘迁移（`/home/runner/boostkit-perf` 软链接到 `/data/data1`）、
离线包放置、缓存清理（`drop_caches`）与多 Topic 手工实验脚本，按本文对应
章节执行即可。