# RocksDB 6.26.1 性能测试

本用例在 x86_64、aarch64 的 openEuler 24.03 LTS SP4 宿主机上编译上游原版
RocksDB JNI 和 YCSB 绑定，在单个 2 CPU、8 GiB 的同版本 openEuler 容器内运行
YCSB。RocksDB 是嵌入式库，不启动独立服务；YCSB 与 RocksDB 在同一容器内执行。
两架构使用相同的数据准备流程和 workload A–F 参数，分别比较六项吞吐量。
软件入口为 `rocksdb_test.sh`；Framework 通过 `case.yaml` 分别调用构建、启动、
测试和停止脚本，独立入口也使用这些阶段函数。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 构建上游原版；调优版入口位于
`scripts/builders/optimized.sh`，目前尚未实现，选择后会在构建阶段明确失败。
启动、测试和停止阶段共用 `scripts/stages/` 下的脚本。私有路径和容器管理位于
`scripts/common.sh`，Maven 私有配置由 `scripts/write_maven_settings.py` 生成，
YCSB 执行与结果解析位于 `scripts/results/`。

## 软件与测试工具

| 项目 | 来源与版本 | 安装位置 |
|---|---|---|
| RocksDB | [上游 RocksDB](https://github.com/facebook/rocksdb) 标签 `v6.26.1` | `${PERF_WORK_DIR}/rocksdb-source`，宿主机编译 JNI JAR |
| YCSB | [上游 YCSB](https://github.com/brianfrankcooper/YCSB) 提交 `19e885f7cb780fdded0547853f7810a150554caf`，构建版本 `0.18.0-SNAPSHOT` | `${PERF_WORK_DIR}/ycsb-source` 和 `ycsb-dist` |
| JDK | openEuler 软件源的 JDK 11 | 宿主机用于构建；容器内安装 Java 11 运行环境 |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}`，校验 SHA-256 后 `docker load` |

Runner 需要可访问的 Docker daemon。缺失的宿主机依赖由脚本通过 `dnf` 安装；
普通 Runner 用户使用 `sudo -n dnf`。RocksDB、YCSB、JNI JAR、Maven 仓库和
数据库文件均位于 `/home/runner/boostkit-perf/rocksdb/<本次任务>/` 下，不覆盖
用户的 `~/.m2`，也不向系统目录安装 RocksDB。

## RocksDB 构建、容器部署与启动

`build_rocksdb` 在宿主机克隆并编译原版 RocksDB JNI，再把生成的
`rocksdbjni-6.26.1-linux64.jar` 安装到本次任务的私有 Maven 仓库。
随后从固定提交构建原版 YCSB RocksDB 绑定，并核对发行包中使用的 JNI JAR
与刚编译的文件完全一致。关键命令形态为：

```bash
git clone --branch v6.26.1 --depth 1 \
  https://github.com/facebook/rocksdb.git "$WORK/rocksdb-source"
cd "$WORK/rocksdb-source"
PORTABLE=1 DEBUG_LEVEL=0 make rocksdbjava -j"$(nproc)" \
  DISABLE_WARNING_AS_ERROR=1 DISABLE_JEMALLOC=1

mvn -B -s "$WORK/maven-settings.xml" install:install-file \
  -Dfile="$WORK/rocksdb-source/java/target/rocksdbjni-6.26.1-linux64.jar" \
  -DgroupId=org.rocksdb -DartifactId=rocksdbjni \
  -Dversion=6.26.1 -Dpackaging=jar -DgeneratePom=true

git clone --filter=blob:none https://github.com/brianfrankcooper/YCSB.git \
  "$WORK/ycsb-source"
git -C "$WORK/ycsb-source" checkout --detach \
  19e885f7cb780fdded0547853f7810a150554caf
cd "$WORK/ycsb-source"
mvn -B -s "$WORK/maven-settings.xml" \
  -pl site.ycsb:rocksdb-binding -am clean package -DskipTests \
  -Drocksdb.version=6.26.1
```

`MAVEN_OPTS` 指向 `$WORK/maven-repository`，所以 YCSB 使用本次构建的
RocksDB 6.26.1 JNI JAR。`$WORK` 为 `${PERF_WORK_DIR}`。构建产物不在容器内
重新编译，而是通过本次任务目录挂载供容器使用。

容器镜像按架构选取 `openEuler-docker.x86_64.tar.xz` 或
`openEuler-docker.aarch64.tar.xz`。脚本优先读取上表离线目录中的归档及同名
`.sha256sum`，缺失时从官方目录下载；校验 SHA-256、镜像架构和容器内的
openEuler 版本后使用。`ROCKSDB_IMAGE_ARCHIVE_DIR` 可指定其他离线归档目录。

`start` 阶段创建单个容器，CPU 总用量限制为 2，内存限制为 8 GiB。
容器可在 NUMA node 3 的所有可用 CPU 上调度，并从该节点分配内存；脚本要求
该节点至少有 2 个可用 CPU。CPU 编号由运行机器实时读取，不写死架构专用编号；
`ROCKSDB_NUMA_NODE` 可选择其他节点。容器名按架构和运行 ID 生成，
只挂载本次任务目录及结果目录，不使用 `--privileged`。启动命令形态为：

```bash
docker run --detach --name "${ROCKSDB_CONTAINER_NAME}" \
  --label "boostkit.rocksdb.run-id=${PERF_RUN_ID}" \
  --cpus=2 --cpuset-cpus="${CPU_SET}" --cpuset-mems="${ROCKSDB_NUMA_NODE}" \
  --memory=8g --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  "${ROCKSDB_CONTAINER_IMAGE}" sleep infinity
```

若结果目录已在工作目录内，脚本不重复挂载它。启动后，脚本只在本任务容器内
通过 `dnf` 安装 Java 11、Python 3 和 RocksDB/JNI 运行库，并校验运行环境。
构建和依赖安装可使用 `PERF_PROXY` 指定的代理；不修改系统代理配置。

## 数据与运行顺序

数据库和快照分别位于 `$WORK/data/workload_data` 和
`$WORK/data/warmup_workload_data`。全部数据留在 Runner 的持久磁盘，不使用
`/tmp` 存放数据库。`test` 阶段在容器内调用原版 YCSB，按以下顺序执行：

| 阶段 | YCSB 用例 | 线程数 | 用途 |
|---|---|---:|---|
| 加载 | `load rocksdb -P workloads/workloada` | 5 | 建立 1,000 万条记录 |
| 预热 1 | `run rocksdb -P workloads/workloadc` | 3 | 只读预热 500 万次，随后复制数据库快照 |
| 恢复与预热 2 | 恢复快照，再运行 `workloadc` | 3 | 只读预热 500 万次，准备正式测试 |
| 正式 A | `run rocksdb -P workloads/workloada` | 5 | 读写混合 |
| 正式 B | `run rocksdb -P workloads/workloadb` | 5 | 以读取为主的读写混合 |
| 正式 C | `run rocksdb -P workloads/workloadc` | 5 | 只读 |
| 正式 D | `run rocksdb -P workloads/workloadd` | 5 | 读最新记录与插入 |
| 正式 E | `run rocksdb -P workloads/workloade` | 5 | 范围扫描与插入 |
| 正式 F | `run rocksdb -P workloads/workloadf` | 5 | 读—改—写 |

各次 YCSB 调用都传入相同的数据量和字段参数：

```bash
-s -p rocksdb.dir="$WORK/data/workload_data" \
  -p recordcount=10000000 -p operationcount=5000000 \
  -p fieldlength=256 -p fieldcount=1
```

不设置 `target`，即不限制请求速率。YCSB 使用原版 RocksDB binding 的默认
初始化逻辑，不传入 `rocksdb.optionsfile`，不打优化补丁、不改 YCSB 源码，
也不执行 `drop_caches` 或系统参数调优。两架构使用相同的容器资源限制和用例参数。
六项正式测试各执行 500 万次操作，按 A–F 顺序运行，不在场景之间恢复快照。
测试作业上限为 24 小时；实际耗时需在两台 Runner 上验证。

## 指标与产物

正式 workload A–F 各取一次 YCSB 的 `[OVERALL], Throughput(ops/sec)`：

| 场景 | 指标来源 | 单位 | 方向 |
|---|---|---|---|
| workload A | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |
| workload B | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |
| workload C | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |
| workload D | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |
| workload E | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |
| workload F | `[OVERALL], Throughput(ops/sec)` | ops/sec | 越大越好 |

加载和预热吞吐量仅保留在 `ycsb_raw.log`，不计入成绩。`results.json` 保存
六项正式指标、负载参数、容器规格及运行环境信息。任一阶段失败、YCSB 报告失败
操作，或缺少唯一且为正数的吞吐量，测试即失败。

脱离 Workflow 执行完整流程：

```bash
bash software/Database/rocksdb/rocksdb_test.sh \
  --version 6.26.1 \
  --variant base \
  --results-dir /home/runner/rocksdb-results/6.26.1
```

`stop` 阶段停止并删除带有本次运行 ID 标签的容器，再清理本次任务的数据目录；
独立运行默认还清理构建工作目录，需要排障时可加 `--keep-workdir`。
正式工作流中，调优版结果归档到
`Database/rocksdb/6.26.1/optimized/<时间戳_Run ID>/`，不更新基础版的
`baseline.json`。
