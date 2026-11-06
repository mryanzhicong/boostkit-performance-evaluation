# bolt 1.0.0-SNAPSHOT：Spark 3.5.2 单机 TPC-DS 容器适配

本适配参考 `大数据单机环境部署+tpcds+bolt.docx`，原文 SHA-256 见 profile.json，组件章节摘录见 reference/document-excerpt.txt。当前交付仅代码和 PR：**未运行 Action、未在服务器执行，未获得性能指标**。

## 固定负载及版本

- openEuler 24.03 LTS-SP4；基础栈沿用 [Spark 手册](../spark/README.md)：OpenJDK 8u252-b09、ZooKeeper 3.4.6、Hadoop 3.2.0、Tez 0.10.0、Hive 3.1.0、MySQL JDBC 5.1.49；MariaDB 记录发行源实际版本。
- Spark 固定 3.5.2；本组件固定 1.0.0-SNAPSHOT。依赖来源、固定校验值见 [assets.json](assets.json)，不会下载 latest 或替换旧 Spark。
- 默认 **SF100**。按本轮要求从原文生成示例 SF10000 缩小为 SF100；查询库名和迁移目标随规模同步变化。实际源库为 `tpcds_bin_partitioned_decimal_orc_100`，不能将 decimal schema 称为 varchar。
- 24 张 ORC 表；冻结基础附件全部 103 个 SQL 文件（99 模板及四组 a/b），沿用 Spark 的 queries.sha256.json；自然顺序串行执行，1 轮预热 + 3 轮测量，共 412 次 SQL 文件执行。
- driver 8 核/20G；申请 200 个 executor，每个 8 核/23g；YARN 64 vcore/371200MB。其他参数完整列于 [profile.json](profile.json)，不自动缩减。

## 准备与执行（当前不要启动）

本次只执行本地静态和单元检查，以下命令留待另行授权后在 **Linux aarch64** 使用。本 PR 不提供已测结论；x86_64 明确拒绝执行，避免错误使用 ARM 包。

1. 安装宿主 Docker、Python 3.9+、curl、GNU coreutils、Bash 4+；不得替换宿主 Java/Hadoop/Hive。
2. 按 assets.json 将离线文件放到 `/home/runner/software/bolt/packages`，或通过 PERF_ASSET_DIR 指向同样布局的只读来源目录。具备公开地址的资产自动下载并核验；无公开地址的资产必须使用文档附件。
3. 原始附件来源为当前任务提供的 `大数据/` 目录；不要提交 JAR/so 或 SF100 数据到 Git。离线文件包括：无必需离线文件。
4. CPU/内存预检仍要求 ≥64 可用 CPU、≥416GiB 可用内存。磁盘仅记录工作目录和结果目录所在文件系统的剩余空间，不设置最低容量、不因空间偏少拦截。实际写入出现磁盘不足时本阶段失败，停止后续测试并尽力保留已有日志和清理资源。

```bash
export PERF_ASSET_DIR=/home/runner/software/bolt/packages
bash software/Bigdata/bolt/bolt_test.sh \
  --version 1.0.0-SNAPSHOT --variant base \
  --results-dir /home/runner/boostkit-results/bolt/run-001
```

独立入口设置 24 小时总超时；单查询 30 分钟，超时、失败、样本不足即停止。只创建本任务私有容器与网络，服务数据在 `/home/runner/boostkit-perf/bolt/` 内；结果必须在工作目录外。终止与正常退出均收集证据、停止并删除容器和网络；工作目录清理后保留结果目录。

## 文档差异与组件核验

Gluten 版本来自文档指定快照 JAR，并非声称 Bolt 内核有独立 1.0.0 正式版本。仅 Spark driver、AM、executor 使用随包 JDK 17.0.16，Hadoop/Hive/Tez 仍使用 JDK 8。IANA 2025b 只在容器安装。保留 `fs.defaultFS=file:///`，但仓库及 Metastore 已生成的数据位置使用完整 HDFS URI，避免读成本地路径。

服务原来的宿主绝对路径映射至私有目录，不修改宿主防火墙、主机名、系统 Java 或服务。配置里的 `server1` 仅用于容器内部；不发布宿主端口，不设置额外 CPU、内存或 NUMA 限额。资源不足不会自动回退。请求资源和 YARN 实际分配数分别记录。

## 结果与指标

- `benchmark_bolt.json`：103 项 SQL 耗时三轮中位数，单位秒，越低越好；不是官方 TPC-DS 分数。
- `timings.jsonl`：全部执行命令、轮次、退出码、SQL 原始耗时、墙钟时间、行数和分配采样。安装、数据生成与迁移耗时不混入指标。
- `versions.json`、`sources.json`、`extension-sources.json`、`extension-installed.json`：实际版本、来源、摘要、已安装 JAR 和原生库清单。
- `preflight.json`：启动时的剩余磁盘信息；`disk-usage.jsonl`：安装、启动/生成/迁移、查询和收集阶段每 10 秒采样，以及阶段结束采样。数据是文件系统整体占用，可能包含其他进程，不等同于本组件数据大小；不会按采样值强制停止。
- `dataset.json`、`ddl/`、`table-counts/`、`data-files.log`；湖表另含 migration/ 和 migration-validation/。
- `effective-config/`、`services/`、`spark-events/` 与逐查询日志；不会归档完整数据集。
- 独立入口另输出 results.json、status.json、report.md。框架入口沿用仓库通用报告合同。

## 故障排查与验证边界

校验失败：按清单重新取得**同一构建**，不要改摘要绕过。native architecture/ldd 失败：核对 ARM 原生依赖与容器 ABI，不换成旧包或静默关闭插件。Hive 客户端冲突：检查 Spark 显式 Hive 3.1.0 隔离依赖。迁移行数或格式不符：查看逐表 DDL/计数，不继续查询。缺原生计划或 Celeborn 证据：视为失败，不能把原生 Spark 结果记为组件成绩。

本地检查：Shell/Python 静态检查、框架目录与矩阵、资源配置、校验失败、迁移缺表/行数变化、结果缺计时/样本不足和容器所有权清理测试。macOS 不执行 Linux Docker 服务链路；完整 ARM 安装、ABI、数据生成与 412 次查询仍待以后授权验证。

## 上游参考

- [Spark 3.5.2 配置](https://spark.apache.org/docs/3.5.2/configuration.html)
- [OmniOperatorDebugAgent 发行包](https://gitcode.com/helloxteen_/OmniOperatorDebugAgent/releases)
- [Celeborn 0.5.3 发行归档](https://archive.apache.org/dist/celeborn/celeborn-0.5.3/)
- [Gluten 1.3.0 Celeborn 管理器源码](https://github.com/apache/incubator-gluten/blob/v1.3.0/gluten-celeborn/src-celeborn/main/java/org/apache/spark/shuffle/gluten/celeborn/CelebornShuffleManager.java)
- [Hudi 0.15.0 文档](https://hudi.apache.org/docs/0.15.0/overview/)、[Iceberg 1.5.0 Spark 配置](https://iceberg.apache.org/docs/1.5.0/spark-configuration/)
