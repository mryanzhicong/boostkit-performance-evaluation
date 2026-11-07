# Spark 3.5.2 单机 TPC-DS 容器测试

本适配参考用户提供的《大数据单机环境部署+tpcds.docx》，部署完整单机基础栈，
在 Spark 原生引擎、YARN client 模式下执行 TPC-DS SF100。
不加载 Gluten、Velox、Bolt、OmniOperator、Celeborn 或数据湖插件。
本次验证只选择 aarch64；x86_64 包下载映射已提供，但不宣称实测通过。

## 版本与完整性

| 组件 | 固定版本及来源 |
|---|---|
| Spark | 3.5.2，[Apache 二进制归档](https://archive.apache.org/dist/spark/spark-3.5.2/)，hadoop3 发行包 |
| Java | AdoptOpenJDK 8u252-b09，Linux hotspot，对应架构官方包 |
| Hadoop | 3.2.0，[Apache 归档](https://archive.apache.org/dist/hadoop/common/hadoop-3.2.0/) |
| Hive | 3.1.0，[Apache 归档](https://archive.apache.org/dist/hive/hive-3.1.0/) |
| Tez | 0.10.0，[Apache 官方 binary 归档](https://archive.apache.org/dist/tez/0.10.0/) |
| ZooKeeper | 3.4.6，[Apache 归档](https://archive.apache.org/dist/zookeeper/zookeeper-3.4.6/) |
| JDBC | MySQL Connector/J 5.1.49，Maven Central |
| MariaDB | openEuler 发行源版本，实际版本和完整 RPM 列表归档 |
| 镜像 | openEuler 24.03 LTS-SP4，官方 Docker 归档及 SHA-256 |
| TPC-DS 工具 | [OmniOperatorDebugAgent tpcds release](https://gitcode.com/helloxteen_/OmniOperatorDebugAgent/releases/tag/tpcds)，2026-10-15，提交 5bd9edd86452ca27d9d2a34812f34d626168c449 |

安装包 URL、可信发布校验值在 scripts/assets.py 中固定。下载后先验证发布校验值，
再记录各包 SHA-256 到 sources.json。旧版本 ZooKeeper、JDBC 的上游发布校验为 SHA-1，
明确保留该事实。Hadoop SHA-256来自官方 .mds，其他 Apache 校验来自相邻发布校验文件。
优先复用 /home/runner/software/spark/packages/ 中校验相符的同名包；否则下载到本任务工作目录。

TPC-DS ARM 包为 hive-testbench-hdp3-arm.zip，SHA-256：

    11f5ea3a6a7d68fba7bca1543e1454109ced69bc134192da1d8d659e456c60de

实际读取包内 tpcds-gen/target/、settings/、ddl-tpcds/、tpcds-setup.sh 和
spark-queries-tpcds/。跳过附带的旧 Spark JAR、旧 metastore、Git 历史和旧运行结果。
103 份 SQL 的 SHA-256 已冻结在 scripts/reference/queries.sha256.json；
安装和测量前均验证文件集合与内容，查询不打补丁。

## 容器与阶段

容器命名为 boostkit-spark-<架构>-<运行ID>，使用 bridge 网络、server1 主机名，
不发布端口、不挂载 Docker socket、不使用 privileged，也不设置 CPU、内存或 NUMA 限制。
本次工作目录、结果目录挂载到相同绝对路径；本软件适配目录只读挂载。
服务、安装包、HDFS、MariaDB 数据及临时文件均位于本次工作目录。
宿主机仅需已有的 Docker、Git、Python3、curl 和校验命令，不部署大数据服务。

1. build 检查架构、Docker、资源，校验并下载软件；加载镜像，在容器内安装依赖；
   建立与 runner UID/GID 对应的容器用户，安装并核对 Java/Hadoop/Hive/Spark 版本。
2. start 启动 ZooKeeper、HDFS、YARN/TimelineServer、MariaDB、Hive Metastore 和
   HiveServer2。通过端口、YARN 节点注册和 Hive-on-Tez 的 student 插入/查询验证服务。
3. start 从原包目录执行 bash tpcds-setup.sh 100，在私有 HDFS 生成并转换数据；
   验证24张表、ORC格式、各表非零行数，归档 DDL、文件清单和行数。
4. test 串行执行4轮全部查询，第0轮预热，第1–3轮测量。
5. stop 收集服务日志、配置和 Spark 事件日志，恢复挂载目录为 runner 所有，
   停止并删除当前运行标签对应的容器。框架随后清理工作目录；
   独立入口同样清理，不保留完整数据集。

镜像优先读取 /home/runner/software/openEuler-24.03-LTS-SP4/；
缺失则下载到本次目录。配置 PERF_PROXY 时沿用仓库证书目录的只读挂载，
仅在容器中更新信任和使用华为 openEuler 软件源。测量不通过外部代理访问内部服务。

### 容器内服务注意事项

- MariaDB 数据目录位于工作目录、属 runner 用户，而 mariadbd 以 mysql 用户运行。
  datadir 下单独创建 mysql 所有的 tmp 子目录，并同时作为 mariadb-install-db 与
  mariadbd 的 --tmpdir 传入，避免 InnoDB 建系统表时因 EACCES 中止。MariaDB 自己的
  错误只写容器的 /var/log/mariadb/mariadb.log，初始化失败时该日志复制到结果目录的
  mysql-init-details.log。
- Hadoop 3.2.0 默认的 LeveldbTimelineStore 依赖只随 x86 提供的 native 库，aarch64 上
  启动 TimelineServer 会报 UnsatisfiedLinkError；yarn-site 固定使用
  MemoryTimelineStore，两架构一致。本用例不查询 Application History，不影响指标。
- 写入 hadoop-env.sh 的变量不能包含 HADOOP_CLASSPATH。Hive 启动脚本会把自己的 jar
  前置到 HADOOP_CLASSPATH 再调用 hadoop，而 hadoop 又会 source hadoop-env.sh；若在该
  文件里固定 HADOOP_CLASSPATH，Hive 计算出的 classpath 会被整段替换掉，schematool、
  metastore 和 hive CLI 会因缺少 hive-beeline/hive-* jar 报 ClassNotFoundException。
  Tez classpath 直接放在进程环境变量里即可被 Hive 脚本继承。

## 资源及文档差异

| 项目 | 保留的文档值 |
|---|---|
| YARN CPU / 内存 | 64 vcore / 371200 MB |
| driver | 8核、20G |
| executor 请求 | 200个，每个8核、23g |
| 并行度 / shuffle partitions | 960 / 960 |
| JVM | executor 使用 G1GC、ActiveProcessorCount=8 |
| SQL | native ORC、100M广播阈值、AQE及文档其余配置 |

200是申请数量，64-vcore单机不可能同时运行200个8核executor。
保留原参数，不自动降低申请数；从 YARN REST 轮询记录实际容器、内存和 vcore 分配，
并在 runtime-context.json 记录观测到的 executor 最大数量。
YARN 的 AM 计入运行容器数，因此 executor 估计值为 runningContainers−1。
记录是轮询采样，不表示全程恒定分配。Spark 等待资源的时间可能显著增加总用时。

预检要求至少64个可用逻辑CPU、416GiB可用内存、500GB剩余磁盘，给文档的
YARN、driver、服务和 SF100 临时数据留空间。资源不足直接失败，不降低 SF 或资源值。
数据生成最多12小时，单查询30分钟，整个用例24小时。

以下差异用于将手工文档转换为隔离、可重复的执行流程：

- /usr/local、/data 等路径替换为本次私有目录；不修改宿主机 /etc/profile。
- Tez 使用同版本 Apache 官方 binary 包，避免依赖未固定的定制归档及旧 JNI 替换包；
  实际 Hadoop native 库可用性另行记录，不冒充原文定制包。
- 容器内直接启动 Hadoop 守护进程，不依赖宿主机 SSH 免密或修改防火墙。
- 修正 Spark 解压目录、JAVA_HOME 空格、--databases 参数为 --database，以及 Hadoop 3 的 HTTP 配置名。
- 对 Hive3.1.0/Hadoop3.2.0 的 Guava 不兼容，采用 Hadoop 随包 Guava 替换 Hive 的旧 Guava，
  实际文件名记录在 versions.json；不改变 SQL 或 Spark 代码。
- Spark 显式使用 Hive3.1.0 Metastore 及其本地依赖路径，避免默认内置 Hive2.3.9 客户端混用。
- 原包实际生成 tpcds_bin_partitioned_decimal_orc_100，使用该真实 schema/数据库，
  不伪称文档示例中的 varchar schema。生成规模统一为已确认的 SF100。
- 原包的全查询为99个模板、103个文件，四组 a/b 是独立指标，全部执行。
- MariaDB 使用仅限本容器数据库的测试账户；配置归档隐藏本地测试口令。

## 命令、指标与结果

独立入口：

~~~bash
bash software/Bigdata/spark/spark_test.sh \
  --version 3.5.2 --variant base --results-dir /home/runner/spark-results/3.5.2
~~~

optimized 尚未实现，指定该变体会在创建容器前失败，不回退基础版。
独立入口与框架共享相同阶段和解析器，可复制整个软件目录独立使用。

每份 SQL 使用如下形式运行，其余配置由归档的 spark-defaults.conf 提供：

~~~bash
spark-sql --master yarn --deploy-mode client \
  --driver-cores 8 --driver-memory 20G \
  --num-executors 200 --executor-cores 8 --executor-memory 23g \
  --database tpcds_bin_partitioned_decimal_orc_100 -f q1.sql
~~~

每轮按自然顺序执行 q1、q2、…、q14a、q14b、…、q99，不并行查询，不清理 OS 页缓存。
103×4=412次执行均需成功，且每个查询必须有完整的预热记录与3个测量样本。
失败或超时停止后续查询，保留故障输出；缺失样本、重复记录、非有限数值和退出码为0的
SQL错误均判失败。

正式指标为 q1/query_time 等103项：Spark SQL 的 Time taken 秒数在3轮测量中的中位数，
单位 s、lower_is_better。计时包含该查询的规划、执行和结果获取，不包含单独的 JVM/YARN
初始化、安装或数据生成。进程总墙钟时间和结果行数另存，不混成查询指标。
空结果查询按 Spark CLI 规则记录0行。结果输出供复核，不宣称已通过独立答案集校验。
不输出官方 TPC-DS 分数或跨架构比较结论。

| 产物 | 内容 |
|---|---|
| benchmark_spark.json | 103项指标、原始3个样本、预热值、参数和资源采样 |
| timings.jsonl | 412次执行的命令、状态、计时、行数、分配采样 |
| benchmark_spark_raw.log、queries/ | 完整逐查询输出，包含失败输出 |
| versions.json、sources.json、rpm-packages.txt | 安装版本、来源、校验值和系统依赖 |
| preflight.json、runtime-context.json | 资源预检、文档参数、实际获配资源 |
| dataset.json、ddl/、table-counts/、data-files.log | 24张表及数据验证 |
| services/、effective-config/、spark-events/ | 服务日志、生效配置及事件日志 |
| results.json、report.md | 独立入口报告；Action运行由Framework生成正式报告 |

本地检查：

~~~bash
python3 framework/catalog.py validate
python3 framework/catalog.py matrix --software spark --version 3.5.2 --architecture aarch64 --pretty
python3 -m pytest -q software/Bigdata/spark/tests framework/tests
~~~

本次计划仅提交一次 performance-test-blue.yml，选择 spark / 3.5.2 / aarch64 / base，
update_baseline=false。不直接SSH机器，不提交x86任务，不自动重跑失败的Action。
