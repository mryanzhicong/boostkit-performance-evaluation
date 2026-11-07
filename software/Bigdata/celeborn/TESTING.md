# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境，完整本地检查首次为 125 passed、5 deselected。
- 精确排除已有的两项 Bash 4 和三项 Linux /proc 测试；这五项不计为通过。
- 随后补充有效配置路径和架构/优化变体早期拒绝测试，相关子集 59 passed。
- Python compileall、Shell bash -n、目录注册、工作流矩阵及 git diff --check 通过。
- Apache 0.5.3 server 使用官方 SHA-512；本地固定 Gluten 1.3.0 bridge JAR 的 SHA-256，确认包含文档要求的管理器类。该类上游支持 row shuffle。
- 未运行服务器、Docker 部署或 Action；Gluten bridge 与 Celeborn 0.5.3 的实际二进制兼容性、Worker 注册及正数远程 shuffle 数据仍待验证。
- 无性能实测数据；Draft PR 不合并，不更新基线。

## SF100 与磁盘检查更新

- 默认规模改为 SF100；上轮 SF10000 是旧默认值，不再用于本轮配置。SQL 数量、测量轮次和 CPU/内存参数保持不变。
- 磁盘只记录，不设硬性容量拦截；运行时每 10 秒及阶段结束采样文件系统空间，采样日志写满不另行触发阈值停止。实际业务写入错误仍返回失败并执行清理。
- 本轮本地检查：64 项通过（组件、公共 Spark 与目录/矩阵子集）；新增低磁盘不拦截、CPU 检查保留和磁盘日志写满容错测试。
- 未启动 Action、未部署服务器或执行性能测试。

## 2026-11-07 双架构适配与 Action 修复

- #265 选择 all，x86 构建因旧 ARM-only 限制被拒绝；完整错误保存在任务证据目录。
- 开放 Celeborn aarch64/x86_64；其他尚未适配的组件保留自身架构限制，不把 ARM 原生库放到 x86。
- 使用 Apache 官方 Gluten 1.3.0 Spark35 发布归档，固定官方 SHA-512；其内部 JAR 与所附 x86 JAR SHA-256 相同。从中确定性生成 Java-only bridge，移除原生二进制和失效签名，保留原 Java 类、SPI、许可证，生成物另固定 SHA-256。
- 双架构均使用原生 Spark 的 row shuffle 与文档指定 Gluten CelebornShuffleManager，不额外启用 GlutenPlugin；JDK 和原始数据生成器按各自架构下载。
- 本地相关子集 67 项通过；完整回归 135 passed、5 项已有平台测试精确排除。架构选择、公共下载路径和 Java-only 构建确定性已测试。
- SF100、原资源参数、103 查询/412 次文件执行、磁盘只记录策略保持不变；真实兼容性与性能结论以重启后的 Action 产物为准。

- 补充实际 Celeborn 安装分支回归，修复 tarfile 局部导入遮蔽问题；相关子集 68 项通过。首次修复运行在部署前被停止并由新提交替代，避免执行已知有问题的版本。

- #265 ARM 端在下载 Spark 时 SSL 连接超时，尚未进入实际安装。新增 Apache/Maven 华为镜像优先、原摘要校验、传输停滞超时与内容寻址下载缓存，镜像错误内容不能通过摘要检查。相关子集 69 项通过。

- 独立读取两种架构的固定附件：103 个查询的 SHA-256 清单完全一致，30 份模式/加载文件逐字节相同，仅 tpcds-setup.sh 的库名及约束开关不同。x86 启动前对齐后，31 个文件 SHA-256 均精确匹配 ARM，保留 x86 原生生成器；已使用实际附件内容验证转换，并覆盖幂等及拒绝未知模式变更。
- 独立流式核验华为 Spark 镜像完整 400822099 字节，SHA-512 与已冻结官方摘要一致；未把这项本地校验写成服务器安装通过。

- x86 工作负载修复相关本地子集 72 项通过；ARM 启动不会调用该转换，x86 转换在服务启动前执行，失败立即停止。当前运行保留用于观察各侧真实终态，后续重启使用更新后的提交。

- #267 x86 在 JDK 下载阶段失败：原 GitHub 地址 30 分钟仅收到约 21MB/102MB 后超时；其他 Apache 组件经华为镜像成功下载。增加仅针对已知公开 Release 的备用下载地址，完整流式核验本地 JDK 镜像 102170196 字节，其 SHA-256 与原固定值完全一致，不更改 JDK 构建。新增私有 URL/查询凭据不转发回归，相关子集 73 项通过。

- 新双架构运行 #269 中，x86 的所有固定下载通过，失败转移到私有容器软件源连接超时（repo.huaweicloud.com）。新增容器内部的同版本软件源探测：依次测试 mirrors.huaweicloud.com、repo.huaweicloud.com 和 repo.openeuler.org 的 SP4 元数据，选择实际可达源，并保留地址解析、失败原因及原/新配置。保留 GPG 检查、发行版路径和独立网络，不改宿主机网络。相关组件与 Spark 测试 61 项通过。

- #269 ARM 在 Gluten 下载至约 94% 时出现 HTTP/2 PROTOCOL_ERROR，备用源随后出现 INTERNAL_ERROR/停滞，最终失败。新增 HTTP/1.1、每源最多两次断点续传；不支持 Range 时从零重试，摘要错误立即丢弃部分内容。增加中断续传与 Range 拒绝回归，组件和 Spark 子集 64 项通过。ARM JDK 镜像也完成本地全文件校验（102238546 字节，SHA-256 与固定源一致），不将本地结果冒充 runner 安装成功。

- #271 ARM 已能访问软件源，因发行包名 `zstd-libs` 不存在而失败；核验 SP4 目录后改用 `zstd`。x86 三个源均在私有桥接容器超时，DNS 正常；新增可清理的下载专用容器，仅下载 RPM、不启动服务，运行容器保留独立网络并离线安装，校验 SHA-256 和 GPG 签名。增加错误架构、摘要错误、路径越界、空清单、缺环境入口及下载容器清理检查；组件与 Spark 子集 72 项通过。实际网络及安装效果仍需后续 Action 验证。

- #272 双架构均通过安装和版本检查，x86 下载专用容器的 RPM 签名和离线安装成功。ARM 服务日志为 DataNode/NodeManager Too many open files；x86 服务正常注册，但 node -list 在 8032 刚就绪前触发 30 秒 CLI 超时。增加容器/bench 用户文件句柄额度与实际值验证、RPC 就绪等待及有期限的超时重试，保留原资源规格；相关子集 75 项通过。

## 2026-11-07 #273 服务启动失败定位与修复

- #273 双架构通过安装、离线 RPM 与版本检查；YARN 正常注册（x86 `node -list` 显示 1 个 RUNNING 节点，TimelineServer 启动完成），随后 x86 在 MariaDB 系统表初始化失败、aarch64 在 TimelineServer 启动失败。finalize 报 `dataset.json` 缺失只是 start 失败的下游结果。
- x86 根因：mariadbd 以 mysql 用户运行，但继承属 runner 用户的 TMPDIR；InnoDB 无法在该目录创建临时文件（EACCES），mariadb-install-db 57ms 内中止。原生 `mysql-init.log` 只有通用提示，真实错误写容器内 `/var/log/mariadb/mariadb.log`。已在同镜像、同 MariaDB 4:10.11.19-2.oe2403sp4 的容器内复现（`mariadbd: Can't create/write to file ... Errcode: 13`）。
- aarch64 根因：Hadoop 3.2.0 默认 LeveldbTimelineStore 无 aarch64 native 库，ApplicationHistoryServer 以 `UnsatisfiedLinkError` 退出；`start-timelineserver.log` 的 `Cannot set priority` 只是对已退出 PID 执行 renice 的副作用，不是独立故障。
- 修复：MariaDB 在 datadir 下使用 mysql 所有的 tmp 作为 `--tmpdir` 与 TMPDIR，初始化失败时把容器内 mariadb 日志复制到结果目录 `mysql-init-details.log`；yarn-site 固定 `MemoryTimelineStore`，两架构一致且不需要 native 库。未改动指标口径、资源参数与 SF100 规模。
- 复核：新增 3 项单测，Spark 与 Celeborn 测试 78 项通过；同版本 SP4 容器内修复后的 `mariadb-install-db` 返回 0，mariadbd 启动后 `select version()` 返回 10.11.19-MariaDB。真实服务链路与性能结果以新提交的 Action 双架构产物为准。

## 2026-11-07 #274 启动链路继续定位与修复

- #274 双架构通过安装、离线 RPM、版本检查与 YARN/TimelineServer 启动；上一轮两处修复已生效：x86 与 aarch64 的 `mysql-init.log` 均为 `Installing MariaDB/MySQL system tables ... OK`，aarch64 `start-timelineserver.log` 不再出现 `UnsatisfiedLinkError`。随后双架构都在 `schematool -dbType mysql -initSchema` 失败，`hive-schema.log` 为 `java.lang.ClassNotFoundException: org.apache.hive.beeline.HiveSchemaTool`。
- 根因：`configure()` 把 `HADOOP_CLASSPATH`（只含 Tez 路径）写进 hadoop-env.sh。Hive 3.1.0 的 `bin/ext/cli.sh` 默认 `USE_DEPRECATED_CLI=true`，schematool 实际执行 `hadoop jar hive-cli-*.jar org.apache.hive.beeline.HiveSchemaTool`；Hive 启动脚本先把 hive/lib 全部 jar 前置进 HADOOP_CLASSPATH，但 hadoop 启动时会重新 source hadoop-env.sh，把该变量覆盖成只剩 Tez 路径，因此含 `HiveSchemaTool` 的 hive-beeline jar 不在 classpath 上。
- 复现：本地用 apache-hive-3.1.0-bin + hadoop-3.2.0 + 同一组环境变量运行 `bin/schematool`，在 hadoop-env.sh 含该 export 时复现相同 CNFE；删除该 export 后 schematool 正常输出 usage（hive/lib 恢复进入 classpath）。
- 修复：hadoop-env.sh 只导出 `JAVA_HOME`、`TEZ_CONF_DIR`、`HADOOP_MAPRED_HOME`，不再导出 `HADOOP_CLASSPATH`；Tez classpath 仍通过进程环境变量传入并被 Hive 脚本继承。新增 1 项回归测试，断言 hadoop-env.sh 不含 HADOOP_CLASSPATH 且其余导出保留。
- 复核：Spark 与 Celeborn 测试 79 项通过，Spark/Celeborn/框架合计 167 项通过；未改指标口径、资源参数与 SF100 规模。真实服务链路与性能结果以新提交的 Action 双架构产物为准。

## 2026-11-07 #275 Hive 元数据服务与 Tez 依赖冲突修复

- #275 双架构通过安装、离线 RPM、版本检查、YARN/TimelineServer/MariaDB 启动与 `schematool -dbType mysql -initSchema`（上一轮修复生效：hadoop-env.sh 不再覆盖 HADOOP_CLASSPATH），随后双架构都在 `hive --service metastore` 启动时 `wait_port(9083)` 超时。
- 根因：`services/hive/hive.log` 记录 `java.lang.NoSuchMethodError: org.apache.hadoop.conf.Configuration.getTimeDuration(Ljava/lang/String;JLjava/util/concurrent/TimeUnit;Ljava/util/concurrent/TimeUnit;)J`，栈中加载的是 `hadoop-hdfs-client-3.1.3.jar`。Tez 0.10.0 发行包自带 4 个 Hadoop 3.1.3 客户端 jar（hadoop-hdfs-client、hadoop-mapreduce-client-common/core、hadoop-yarn-server-timeline-pluginstorage）；Hive 启动脚本把 tez/lib 加入 HADOOP_CLASSPATH，且 hadoop 以用户 classpath 优先，3.1.3 的 hdfs-client 覆盖 Hadoop 3.2.0 的 hadoop-common，metastore 初始化 Warehouse 时崩溃。
- 复现：本地 hadoop-3.2.0 + hive-3.1.0 + tez-0.10.0 按同一顺序构造 classpath（hive/lib → tez/conf、tez/*、tez/lib/* → hadoop 3.2.0），`DfsClientConf` 构造即抛同一 NoSuchMethodError；删除 tez/lib/hadoop-*.jar 后同一 classpath 输出 `DFS_CONF_OK`。
- 修复：安装时删除 tez/lib 下的 hadoop-*.jar，并把删除清单写入 versions.json 的 `tez_bundled_hadoop_jars_removed`；tez-site 增加 `tez.use.cluster.hadoop-libs=true`，让 Tez AM 与容器使用集群 Hadoop 3.2.0 库。tez.tar.gz 因此只含 Tez 自身 jar，仍通过 `$PWD/tezlib/*`、`tezlib/lib/*` 进入 AM classpath。
- 复核：新增 2 项单测（tez-site 配置、tez 旧 jar 清理），Spark 与 Celeborn 测试 81 项、合计 169 项通过；未改指标口径、资源参数与 SF100 规模。真实服务链路与性能结果以新提交的 Action 双架构产物为准。

## 2026-11-07 #276 Hive-on-Tez 冒烟测试 Guava 版本修复

- #276 双架构通过安装、离线 RPM、版本检查、YARN/TimelineServer/MariaDB、schema 初始化、Metastore（9083）与 HiveServer2（10000）启动，Tez 包上传与 `create table student` 也成功；随后 `insert into student values ...` 失败，beeline 与 `services/hive/hive.log` 均为 `java.lang.IncompatibleClassChangeError: Class com.google.common.collect.ImmutableSortedMap does not implement the requested interface java.util.NavigableMap`，栈位于 `org.apache.calcite.schema.Schemas.gatherLattices`。
- 根因：安装阶段把 Hive 自带的 Guava 19 换成了 Hadoop 3.2.0 随包的 Guava 11.0.2。`javap` 对比确认 Guava 11.0.2 的 `ImmutableSortedMap` 只实现 `SortedMap`，Guava 19/27 才实现 `NavigableMap`；Hive 3.1.0 的 Calcite 1.16 规划器按 Guava 19 编译，连接初始化时要求 `ImmutableSortedMap` 实现 `NavigableMap`，与 11.0.2 的类定义不符即抛 ICCE。DDL 不经过 Calcite，因此建表成功、插入失败。
- 修复：取消 Guava 替换，保留 Hive 3.1.0 自带 Guava 19，并校验 hive/lib 中恰好只有一个 `guava-*.jar`（实际文件名写入 versions.json 的 `hive_guava`）；同时说明 Hadoop 3.2 与 Guava 19 是 Hive-on-Hadoop 的常规组合。
- 复核：新增 1 项单测（Hive 保留自身 Guava、重复 Guava 报错），Spark 与 Celeborn 测试 82 项、合计 170 项通过；未改指标口径、资源参数与 SF100 规模。真实服务链路与性能结果以新提交的 Action 双架构产物为准。
