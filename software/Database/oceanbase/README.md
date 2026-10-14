# OceanBase 4.2.5.6 开箱性能测试

本用例在同一台 Runner 上部署上游社区版 OceanBase 4.2.5.6 和 OBProxy
4.3.6.1，通过 OBProxy 运行 Sysbench 1.0.20。x86_64 与 aarch64 使用相同软件
版本、命令和测试矩阵。结果包含代理开销。

测试场景与参数参考用户提供的《OB applysrv线程优化insert性能提升5
_20260910》：`read_only`、`insert`、`read_write`、`write_only`，每个场景
从参考文档的并发档位中选取 1、64、256 线程，每档 300 秒。测试使用上游发布
包，不应用文档中的 `log_apply_thread_factor` 优化补丁，也不修改系统内核、
BIOS、swap、SELinux 或防火墙。

## 安装与部署

| 组件 | 来源 | 安装方式 |
|---|---|---|
| OceanBase 4.2.5.6 | OceanBase 官方社区仓库的 el8 RPM | 导入本次任务的私有 OBD 镜像，`demo` 单节点部署 |
| OBProxy 4.3.6.1 | OceanBase 官方社区仓库的 el8 RPM | 导入同一 OBD 镜像并部署 |
| Sysbench 1.0.20 | [上游 Sysbench](https://github.com/akopytov/sysbench) 标签 `1.0.20`、提交 `ebf1c90` | 在本次任务的私有目录编译，不安装到系统目录 |
| OBD 4.6.0 | OceanBase 官方社区仓库 | 缺失时使用临时 `dnf --repofrompath` 安装 `ob-deploy-4.6.0-16.el8` |

基础命令 `python3`、`mysql`、Sysbench 编译依赖缺失时由脚本使用 `dnf` 安装。安装
`ob-deploy` 时只在本次 `dnf` 命令中指定官方仓库，不写系统 repo 文件；配置了
`PERF_PROXY` 时，该命令通过 `--setopt=proxy=...` 使用代理。Sysbench 源码固定
为 `1.0.20`，编译前校验提交，编译后校验可执行程序的版本。

Framework 提供本次任务的 `PERF_WORK_DIR`、`RESULTS_DIR`、`PERF_RUN_ID` 等
变量。数据、OBD 元数据和临时文件都保存在 `/home/runner/boostkit-perf/oceanbase/`
下的本次任务私有目录，不写入 `/tmp`。脚本根据运行 ID 生成端口，并使用私有
`OBD_HOME`，避免连接或销毁已有的 OceanBase 集群。脚本在本次任务目录生成
权限为 `0600` 的随机 `root@sys` 密码文件；连接时读取该文件，不把密码写入
Sysbench 命令或结果文件。

OBD 的 `--home_path` 为 `${PERF_WORK_DIR}/ob`。脚本在部署前检查
`${PERF_WORK_DIR}/ob/oceanbase-ce/run/daemon.sock` 的字节长度，确保 obshell
的 Unix socket 路径不超过 107 字节。

两架构使用相同的资源额度：observer 上限 64 GiB、系统预留 8 GiB、
`sys` 租户 16 GiB、`test` 租户 32 GiB、OBProxy 上限 8 GiB。observer
可分配给租户 56 GiB；`sys` 与 `test` 合计 48 GiB，留有 8 GiB
未分配。这里明确的是运行所需容量，不是应用优化参数。部署后，脚本
执行 `ALTER RESOURCE UNIT sys_unit_config MEMORY_SIZE='16G'`，查询
`DBA_OB_UNIT_CONFIGS` 验证，再从 `GV$OB_SERVERS` 核对剩余内存至少
32 GiB。容量不足时直接失败，不让 OBD 自动申请超出容量的租户。

参考文档在 2.9T NVMe 上固定配置 `datafile_size: 2000G`、
`log_disk_size: 500G`。本用例沿用固定容量方式，但按两台 Runner 的磁盘空间
统一设为 512G 数据文件和 128G 日志盘；不启用测试期间的自动扩容。

openEuler 上 OBD 可能自动选择 el7 镜像。脚本明确从 OceanBase 官方 el8 仓库
用 `dnf download` 下载两个固定版本的 RPM，然后以 `obd mirror clone` 导入本次
任务的私有 `OBD_HOME`，并禁用该私有 OBD 镜像的远端源：

```bash
dnf --repofrompath=oceanbase-official,https://mirrors.oceanbase.com/community/stable/el/8/<架构>/ \
  --disablerepo='*' --enablerepo=oceanbase-official download \
  --destdir="${PERF_WORK_DIR}/packages" \
  oceanbase-ce-4.2.5.6-106000022025082510.el8 \
  obproxy-ce-4.3.6.1-2.el8
obd mirror clone "${PERF_WORK_DIR}/packages/oceanbase-ce-4.2.5.6-106000022025082510.el8.<架构>.rpm" -f
obd mirror clone "${PERF_WORK_DIR}/packages/obproxy-ce-4.3.6.1-2.el8.<架构>.rpm" -f
obd mirror disable remote
```

Sysbench 在部署 OceanBase 前构建，实际命令为：

```bash
git clone --depth 1 --branch 1.0.20 \
  https://github.com/akopytov/sysbench.git \
  "${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20"
cd "${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20"
./autogen.sh
./configure --with-mysql
make -j"$(getconf _NPROCESSORS_ONLN)"
```

构建阶段的命令形态如下；实际端口和路径由本次任务计算：

```bash
obd demo -c oceanbase-ce,obproxy-ce \
  --oceanbase-ce.version=4.2.5.6 \
  --oceanbase-ce.root_password=<本次任务生成的随机密码> \
  --oceanbase-ce.memory_limit=64G \
  --oceanbase-ce.system_memory=8G \
  --oceanbase-ce.datafile_size=512G \
  --oceanbase-ce.log_disk_size=128G \
  --obproxy-ce.version=4.3.6.1 \
  --obproxy-ce.proxy_mem_limited=8G \
  --oceanbase-ce.mysql_port=<observer SQL 端口> \
  --oceanbase-ce.rpc_port=<observer RPC 端口> \
  --obproxy-ce.listen_port=<OBProxy SQL 端口> \
  --obproxy-ce.prometheus_listen_port=<OBProxy 监控端口> \
  --home_path=<本次任务的部署目录>
```

部署后，脚本先通过 observer 直接连接检查 `SELECT version()`，再执行：

```bash
obd cluster tenant create demo -n test --memory-size=32G
```

日志盘固定为 128G：32G 测试租户默认需要 96G 日志盘配额，系统租户还占用一部分。
部署前脚本要求工作目录所在文件系统至少有 672G 可用空间（512G 数据文件、
128G 日志盘，以及 32G 其他文件余量）；部署后从 `GV$OB_SERVERS` 核实
数据盘容量至少 512G、日志盘剩余配额至少 96G。任何一项不足都立即停止，
不进入建租户和长时间性能测试。

该命令以固定内存额度创建 MySQL 模式 `test` 租户。脚本从系统租户查询
`DBA_OB_TENANTS` 确认租户已创建，再通过 OBProxy 使用 `root@test#demo`
检查租户和代理版本。正式测试只连接 OBProxy，不直连 observer。部署与建租户命令
分别依据 [OBD `demo` 说明](https://en.oceanbase.com/docs/community-obd-en-10000000002136401)
和 [OBD 租户创建说明](https://www.oceanbase.com/docs/common-obd-cn-1000000006717719)。

## 测试流程

脚本先在 `test` 租户创建 `obtest` 数据库。每个场景、每个并发档位依次运行
Sysbench 原版 Lua 脚本的 `cleanup`、`prepare`、`run`，再等待 60 秒，然后
进入下一档。每次 `prepare` 创建一张 500,000 行的表；不复用上一档的数据。
命令形态为：

```bash
"${SYSBENCH_BIN}" --db-driver=mysql --mysql-host=127.0.0.1 \
  --mysql-port=<OBProxy SQL 端口> --mysql-user='root@test#demo' \
  --mysql-db=obtest --db-ps-mode=disable \
  --threads=<并发档位> --table_size=500000 \
  "${SYSBENCH_LUA_DIR}/oltp_<场景>.lua" cleanup

"${SYSBENCH_BIN}" <相同连接和场景参数> \
  "${SYSBENCH_LUA_DIR}/oltp_<场景>.lua" prepare

"${SYSBENCH_BIN}" <相同连接和场景参数> --report-interval=1 \
  --mysql-ignore-errors=1062,6002,6001,4012,1213,1020,1205,4038,6004 \
  --time=300 --max-requests=0 --rand-type=uniform \
  "${SYSBENCH_LUA_DIR}/oltp_<场景>.lua" run
```

Lua 脚本取自同一份上游源码，并通过 `LUA_PATH` 加载其 `oltp_common.lua`。
任一阶段即使退出码为 0，只要输出含 `FATAL:`，测试也会立即失败并保留该阶段原始日志。
四个场景共 12 次正式运行，仅计时阶段约 60 分钟；场景间 11 次等待再增加
11 分钟，部署、数据准备和清理另计。当前用例超时上限为 600 分钟。

## 指标与产物

每次运行从 Sysbench 正式汇总中严格提取以下字段；任一档缺失、非有限或非
正值时测试失败，不生成不完整的跨架构对比。

| 指标 | Sysbench 来源 | 方向 |
|---|---|---|
| TPS | `transactions: ... (X per sec.)` | 越大越好 |
| QPS | `queries: ... (X per sec.)` | 越大越好 |
| 平均延迟 | `Latency (ms)` 下的 `avg` | 越小越好 |
| P95 延迟 | `Latency (ms)` 下的 `95th percentile` | 越小越好 |

共 12 × 4 = 48 个指标。报告按 `read_only`、`insert`、`read_write`、
`write_only` 场景分表，指标名包含线程数，不把不同并发度混合比较。
`sysbench_raw.log` 保存控制台输出，`sysbench-runs/` 保存每次
`cleanup`、`prepare`、`run` 的原始日志，`results.json` 保存结构化指标和
相同的工作负载参数。

部署失败时，脚本会在 stop 清理前把 `obd-trace.log` 和
`obshell-diagnostic.log` 保存到结果目录；OBProxy 租户连接失败时还会保存
`obproxy-connection-error.log`。每次 stop 都会在销毁部署前保存 observer 和
OBProxy 服务日志的末尾 300 行到 `oceanbase-ce-diagnostic.log`、
`obproxy-ce-diagnostic.log`。诊断日志中的密码会被遮盖。

## 独立执行

```bash
bash software/Database/oceanbase/oceanbase_test.sh \
  --version 4.2.5.6 \
  --results-dir /home/runner/boostkit-perf/oceanbase/results/4.2.5.6
```

独立运行和 Framework 均按 build、start、test、stop 执行。stop 阶段只销毁
本次任务私有 `OBD_HOME` 内的 `demo` 集群。独立运行默认清理自身创建的工作
目录；排查部署问题时可使用 `--keep-workdir`。
