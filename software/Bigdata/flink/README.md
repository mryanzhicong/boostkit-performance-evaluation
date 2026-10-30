# Flink 1.16.3 性能测试

本用例在 x86_64 和 aarch64 的单台 Runner 上分别部署 Apache Flink 1.16.3
standalone session，使用原版 Nexmark V1 OA 查询做开箱对比。两架构使用相同的 Flink
发行包、Nexmark 源码提交、集群规模和负载参数，不安装 native/Omni 插件。

测试方法取自随用例提供的《Nexmark 在原生（Vanilla）Flink 上的编译、部署与运行手册》。默认
正式负载选用 **10M 事件 × 23 条查询**：附件的 50M 全量方案中 q7 在 54 分钟后仍未完成，
而 10M 方案覆盖全部 23 条。warmup 仍使用附件的 500K 事件，不计入性能报告。

## 软件与测试工具

| 项目 | 来源与版本 | 安装位置 |
|---|---|---|
| Flink | [Apache 历史归档](https://archive.apache.org/dist/flink/flink-1.16.3/)的 `flink-1.16.3-bin-scala_2.12.tgz` | `${PERF_WORK_DIR}/flink-1.16.3` |
| Nexmark | [上游仓库](https://github.com/nexmark/nexmark)，固定提交 `6b3646c3baec701f1fa74baf938d235f742e5d3c` | `${PERF_WORK_DIR}/nexmark-source`，部署副本在 `${PERF_WORK_DIR}/nexmark` |
| JDK | openEuler `java-11-openjdk-devel` | 系统 RPM 提供的 JDK 11；实际路径记录在 `${PERF_WORK_DIR}/java-home.txt` |
| Maven | openEuler `maven` | 系统 RPM；依赖下载到 `${PERF_WORK_DIR}/maven-repository` |

构建阶段通过 `dnf` 确保 JDK 11、Maven、curl、git、tar、gzip、unzip 已安装。
只有 Flink 二进制包可离线提供：优先读取
`/home/runner/software/flink/flink-1.16.3-bin-scala_2.12.tgz`；不存在时下载到本次
任务目录。无论从哪里取包，均按 Apache 发布的 SHA-512 校验。`FLINK_ARCHIVE_DIR`
可更改离线包目录。Nexmark 使用固定提交从上游 Git 仓库获取，构建过程中 Maven
从仓库下载依赖；若工作流设置了 `PERF_PROXY`，脚本只在本次任务目录生成 Maven
代理配置，不修改用户或系统的 Maven 配置。

## 构建与部署

Framework 的 `build` 阶段只调用 `scripts/builders/dispatch.sh` 中的
`build_flink`。当 `PERF_VARIANT=base` 时，分发到 `scripts/builders/base.sh` 的
`build_flink_base`；选择 `optimized` 会明确失败，不会偷偷构建基础版。
构建成功后写入 `build_variant.json`，供报告核对。基础版执行：

```bash
sha512sum flink-1.16.3-bin-scala_2.12.tgz
tar -xzf flink-1.16.3-bin-scala_2.12.tgz -C "${PERF_WORK_DIR}"

git init "${PERF_WORK_DIR}/nexmark-source"
git -C "${PERF_WORK_DIR}/nexmark-source" fetch --depth 1 origin \
  6b3646c3baec701f1fa74baf938d235f742e5d3c
git -C "${PERF_WORK_DIR}/nexmark-source" checkout --detach FETCH_HEAD

cd "${PERF_WORK_DIR}/nexmark-source"
mvn -B -Dflink.version=1.16.3 -Dmaven.test.skip=true \
  -pl nexmark-flink clean package
```

实际命令还指定私有 Maven 设置与依赖缓存路径。编出的
`nexmark-flink-0.3-SNAPSHOT.jar` 同时复制到 `${PERF_WORK_DIR}/nexmark/lib/`
和 `${PERF_WORK_DIR}/flink-1.16.3/lib/`；前者供 V1 runner 使用，后者供 Flink
SQL Client 和 TaskManager 加载 `nexmark` connector。Nexmark 的 `bin/`、`conf/`、
`queries/`、`queries-cep/` 直接来自固定提交的资源目录，不修改其 Java 源码。
脚本通过安装目录的 `bin/flink --version` 读取并核对实际版本，写入
`PERF_ACTUAL_VERSION_FILE`，不以请求版本代替产物版本。

## 集群与测试

`start` 阶段在本次任务目录写入私有 `flink-conf.yaml`，启动 **1 个
JobManager + 2 个 TaskManager**，每个 TaskManager 8 槽，默认并行度 8。
端口由运行 ID 派生，不占用固定的 8081/9098。RocksDB、checkpoint 和 Flink
临时数据均放在 `${PERF_WORK_DIR}/data/`，不写 `/tmp`。配置保留附件实测的
RocksDB 后端、mini-batch `2s/50000`、关闭 checkpoint；不加载优化插件。

脚本启动 Nexmark 自带的 `CpuMetricSender`，并调用其原始
`SideInputGenerator --num 10000` 生成 q13 的输入。随后 `test` 阶段按附件的
两阶段次序运行原始命令：

```bash
cd "${PERF_WORK_DIR}/nexmark"
bash bin/run_query.sh q0
bash bin/run_query.sh q1
# 依次至 q23，跳过 Nexmark 官方 OA 列表中没有的 q6
```

两阶段的 `nexmark.yaml` 参数为：

| 阶段 | `events.num` | `tps` | 结果用途 |
|---|---:|---:|---|
| warmup | 500,000 | 5,000 | 预热与作业完成检查，不作为指标 |
| bench | 10,000,000 | 1,000,000 | 23 条查询的正式指标 |

每条查询独占集群；下一条提交前，脚本等待无运行中作业且 16 个槽全部可用。
对附件指出的 V1 runner 卡在“等待 RUNNING”问题，测试编排会在作业已经
`FINISHED` 后结束仍未退出的 runner；正式阶段仍必须取得该查询的 Nexmark
结果行，否则该架构测试失败。每条正式查询的上限为 1800 秒，避免无期限等待。
原始查询输出由 `scripts/run_nexmark.py` 保存；随后
`scripts/results/parse_benchmark.py` 逐条校验 23 条正式结果行并生成指标 JSON。

## 指标与结果目录

报告只收录 Nexmark 官方结果表中每条查询的 `Throughput`（events/s，越高越好）
和 `Time(s)`（秒，越低越好），共 **23 × 2 = 46 项**；按 `q0` 至 `q23`
分组。官方表的 `Cores`、`Throughput/Cores` 和完整原始行保存在 JSON 与原始日志中，
但不作为跨架构主指标，因为附件指出 CPU 采样可能有噪声。必须产生 23 条有效的
正式查询结果，不能用缺失项或失败项的估计值填表。

| 文件 | 内容 |
|---|---|
| `${RESULTS_DIR}/warmup-qN.log` | 原始 warmup 输出 |
| `${RESULTS_DIR}/bench-qN.log` | 每条正式查询的原始输出 |
| `${RESULTS_DIR}/benchmark_flink_raw.log` | 顺序合并的两阶段原始日志 |
| `${RESULTS_DIR}/benchmark_flink.json` | 46 项指标、原始行及跨架构对齐用的固定负载参数 |
| `${RESULTS_DIR}/flink-logs/`、`${RESULTS_DIR}/nexmark-logs/` | 停止阶段复制的进程日志 |

`stop` 阶段只停止本任务私有 PID 目录管理的 Flink 进程和本任务的
`CpuMetricSender`，不按全机类名执行 `pkill`，也不操作别人的 Flink 集群。
Framework 分配的 `${PERF_WORK_DIR}` 由 Framework 清理；结果由 Framework
保存在 `${RESULTS_DIR}` 并生成单架构和跨架构报告。

## 独立运行

在 Runner 上可直接调用同一套构建、启动、测试和停止函数：

```bash
bash software/Bigdata/flink/flink_test.sh \
  --version 1.16.3 --variant base \
  --results-dir /home/runner/flink-results/1.16.3
```

独立入口还接受 `--keep-workdir`，用于保留本次私有构建目录排查问题。
不指定结果目录时，基础版结果放在
`software/Bigdata/flink/results/1.16.3/<run-id>/`。入口在成功或失败时
都执行 `stop`，生成 `results.json`、`status.json` 和 `report.md`，并只清理
由本次入口创建的工作目录。若只想验证分流，可指定 `--variant optimized`；
目前该变体未实现，预期返回非零且不产生 `build_variant.json`。
