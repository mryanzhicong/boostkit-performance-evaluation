# celeborn 0.5.3：Spark 3.5.2 单机 TPC-DS 容器适配

本适配参考 `大数据单机环境部署+tpcds+celeborn.docx`，原文 SHA-256 见 profile.json，组件章节摘录见 reference/document-excerpt.txt。本次已开始 Action 适配验证；实际结果和失败修复记录见 TESTING.md，不把尚未验证的运行写成性能结论。

## 固定负载及版本

- openEuler 24.03 LTS-SP4；基础栈沿用 [Spark 手册](../spark/README.md)：OpenJDK 8u252-b09、ZooKeeper 3.4.6、Hadoop 3.2.0、Tez 0.10.0、Hive 3.1.0、MySQL JDBC 5.1.49；MariaDB 记录发行源实际版本。
- Spark 固定 3.5.2；本组件固定 0.5.3。依赖来源、固定校验值见 [assets.json](assets.json)，不会下载 latest 或替换旧 Spark。
- 默认 **SF100**。按本轮要求从原文生成示例 SF10000 缩小为 SF100；查询库名和迁移目标随规模同步变化。实际源库为 `tpcds_bin_partitioned_decimal_orc_100`，不能将 decimal schema 称为 varchar。
- 24 张 ORC 表；冻结基础附件全部 103 个 SQL 文件（99 模板及四组 a/b），沿用 Spark 的 queries.sha256.json；自然顺序串行执行，1 轮预热 + 3 轮测量，共 412 次 SQL 文件执行。
- driver 8 核/20G；申请 200 个 executor，每个 8 核/23g；YARN 64 vcore/371200MB。其他参数完整列于 [profile.json](profile.json)，不自动缩减。

## 准备与执行（当前不要启动）

独立入口支持 **Linux aarch64 和 x86_64**，按宿主架构自动选择 JDK 与原始数据生成包。实际指标以通过验收的 Action 产物为准。

1. 安装宿主 Docker、Python 3.9+、curl、GNU coreutils、Bash 4+；不得替换宿主 Java/Hadoop/Hive。
2. 按 assets.json 将离线文件放到 `/home/runner/software/celeborn/packages`，或通过 PERF_ASSET_DIR 指向同样布局的只读来源目录。具备公开地址的资产自动下载并核验；无公开地址的资产必须使用文档附件。
3. 原始附件来源为当前任务提供的 `大数据/` 目录；不要提交 JAR/so 或 SF100 数据到 Git。当前依赖都有公开下载地址，无必需的手工预置文件；离线时按 assets.json 放置两个原始发布归档。
4. CPU/内存预检仍要求 ≥64 可用 CPU、≥416GiB 可用内存。磁盘仅记录工作目录和结果目录所在文件系统的剩余空间，不设置最低容量、不因空间偏少拦截。实际写入出现磁盘不足时本阶段失败，停止后续测试并尽力保留已有日志和清理资源。

```bash
export PERF_ASSET_DIR=/home/runner/software/celeborn/packages
bash software/Bigdata/celeborn/celeborn_test.sh \
  --version 0.5.3 --variant base \
  --results-dir /home/runner/boostkit-results/celeborn/run-001
```

独立入口设置 24 小时总超时；单查询 30 分钟，超时、失败、样本不足即停止。只创建本任务私有容器与网络，服务数据在 `/home/runner/boostkit-perf/celeborn/` 内；结果必须在工作目录外。终止与正常退出均收集证据、停止并删除容器和网络；工作目录清理后保留结果目录。

## 文档差异与组件核验

保留文档指定 `org.apache.spark.shuffle.gluten.celeborn.CelebornShuffleManager`，使用 Apache 官方 Gluten 1.3.0 Spark 3.5 发布包生成 Java-only bridge JAR；不擅自换成原生 Celeborn 管理器，也不启用文档未指定的 GlutenPlugin。上游该类支持 row shuffle。发布包 SHA-512、内层 JAR SHA-256 与生成桥接 JAR SHA-256 均固定；剔除 ELF/平台原生库及失效签名，保留原始 Java 类、SPI 和许可证，两侧使用同一份 Java 字节码；不加载该发布包中的 x86 原生引擎。实际与 Celeborn 0.5.3 的兼容性不通过即失败。Master/Worker 位于同一私有容器，端点改为 server1:9097；堆 4g/4g、Worker 堆外 8g。两目录对应的实际设备号会归档，不能将同盘目录宣传为两块 SSD。记录 Worker 注册与采样到的正数 shuffle 文件字节，缺少证据则失败。

服务原来的宿主绝对路径映射至私有目录，不修改宿主防火墙、主机名、系统 Java 或服务。配置里的 `server1` 仅用于容器内部；不发布宿主端口，不设置额外 CPU、内存或 NUMA 限额。资源不足不会自动回退。请求资源和 YARN 实际分配数分别记录。

## 结果与指标

- `benchmark_celeborn.json`：103 项 SQL 耗时三轮中位数，单位秒，越低越好；不是官方 TPC-DS 分数。
- `timings.jsonl`：全部执行命令、轮次、退出码、SQL 原始耗时、墙钟时间、行数和分配采样。安装、数据生成与迁移耗时不混入指标。
- `versions.json`、`sources.json`、`extension-sources.json`、`extension-installed.json`：实际版本、来源、摘要、已安装 JAR 和原生库清单。
- `preflight.json`：启动时的剩余磁盘信息；`disk-usage.jsonl`：安装、启动/生成/迁移、查询和收集阶段每 10 秒采样，以及阶段结束采样。数据是文件系统整体占用，可能包含其他进程，不等同于本组件数据大小；不会按采样值强制停止。
- `dataset.json`、`ddl/`、`table-counts/`、`data-files.log`；湖表另含 migration/ 和 migration-validation/。
- `effective-config/`、`services/`、`spark-events/` 与逐查询日志；不会归档完整数据集。
- 独立入口另输出 results.json、status.json、report.md。框架入口沿用仓库通用报告合同。

## 故障排查与验证边界

校验失败：按清单重新取得**同一构建**，不要改摘要绕过。native architecture/ldd 失败：核对 ARM 原生依赖与容器 ABI，不换成旧包或静默关闭插件。Hive 客户端冲突：检查 Spark 显式 Hive 3.1.0 隔离依赖。迁移行数或格式不符：查看逐表 DDL/计数，不继续查询。缺原生计划或 Celeborn 证据：视为失败，不能把原生 Spark 结果记为组件成绩。

本地检查：Shell/Python 静态检查、框架目录与矩阵、资源配置、校验失败、迁移缺表/行数变化、结果缺计时/样本不足和容器所有权清理测试。macOS 不执行 Linux Docker 服务链路；完整 ARM 安装、ABI、数据生成与 412 次查询仍待 Action 完整验证。

## 上游参考

- [Spark 3.5.2 配置](https://spark.apache.org/docs/3.5.2/configuration.html)
- [OmniOperatorDebugAgent 发行包](https://gitcode.com/helloxteen_/OmniOperatorDebugAgent/releases)
- [Celeborn 0.5.3 发行归档](https://archive.apache.org/dist/celeborn/celeborn-0.5.3/)
- [Gluten 1.3.0 Celeborn 管理器源码](https://github.com/apache/incubator-gluten/blob/v1.3.0/gluten-celeborn/src-celeborn/main/java/org/apache/spark/shuffle/gluten/celeborn/CelebornShuffleManager.java)
- [Hudi 0.15.0 文档](https://hudi.apache.org/docs/0.15.0/overview/)、[Iceberg 1.5.0 Spark 配置](https://iceberg.apache.org/docs/1.5.0/spark-configuration/)

双架构 Action 选择 `architecture=all`；只重试单侧可选 `aarch64` 或 `x86_64`。修复后需要从新提交触发新运行，rerun 旧运行仍然使用旧代码。

下载策略：Apache/Maven 优先使用华为镜像，始终核验原始发行摘要，失败才尝试原地址；网络停滞设超时。已核验安装包缓存到 `/home/runner/software/boostkit-download-cache/<算法>/<摘要>/`，后续修复重跑可复用；缓存写入失败不阻止任务。缓存是安装包，不包含测试数据，不修改宿主软件或服务。

x86 附件的表结构和查询文件与 ARM 一致，但原生成脚本使用 `varchar` 库名并关闭约束加载；x86 启动时仅对齐这两处设置，生成脚本及 30 份模式/加载文件必须逐字节匹配已冻结 ARM 元数据。x86 原生生成器保留，原始脚本及校验报告写入 `workload-normalization/` 和 `workload-normalization.json`。ARM 启动路径保持原样。

固定公开的 AdoptOpenJDK/Apache Gluten GitHub Release 文件下载过慢时，下载器优先尝试公开文件加速镜像，最后保留原地址；只转发这两个已知公开仓库的无凭据 URL。版本及预期摘要不变，所有内容在安装和缓存前核验，实际下载地址记录于 sources.json/extension-sources.json。私有仓库 URL 与带查询凭据的 URL 不转发。

容器软件源：安装前从容器内部探测同一 openEuler 24.03 LTS-SP4 的华为镜像/官方源元数据，选择可达地址。仅改本任务容器的 repo 配置，保留发行版路径与 GPG 设置；`container-repository-network.json`、`openEuler.repo.original`、`openEuler.repo.selected` 保存选择及失败证据。若运行容器无法访问三处软件源，使用同一已校验基础镜像启动临时的下载专用容器，仅该容器使用 host 网络执行 `dnf --downloadonly`，不启动服务、不安装到宿主机。导出发行签名密钥、验证 RPM 签名并记录 SHA-256 清单后，在原私有容器中强制本地 GPG 检查完成离线安装。下载容器由退出处理和 stop 阶段重复清理；服务、HDFS、查询和数据始终留在独立网络。不修改宿主机防火墙、Docker 配置或系统软件。下载专用网络也不可达时明确失败。

离线下载与签名配置依据 [DNF 命令说明](https://dnf.readthedocs.io/en/latest/command_ref.html)及 [localpkg_gpgcheck 配置](https://dnf.readthedocs.io/en/latest/conf_ref.html)。`system-dependency-manifest.json` 保存 RPM/密钥摘要和传输方式，`dependency-fetch-network/` 保存下载容器的源探测证据。openEuler SP4 的压缩库包名为 `zstd`，采用发行版包名替代其他发行版的 `zstd-libs`。
