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
obd demo -c oceanbase-ce,obproxy-ce -A \
  --oceanbase-ce.version=4.2.5.6 \
  --oceanbase-ce.root_password=<本次任务生成的随机密码> \
  --obproxy-ce.version=4.3.6.1 \
  --oceanbase-ce.mysql_port=<observer SQL 端口> \
  --oceanbase-ce.rpc_port=<observer RPC 端口> \
  --obproxy-ce.listen_port=<OBProxy SQL 端口> \
  --obproxy-ce.prometheus_listen_port=<OBProxy 监控端口> \
  --home_path=<本次任务的部署目录>
```

`-A` 创建使用可用资源的 MySQL 模式 `test` 租户。部署后，脚本通过 observer
直接连接检查 `SELECT version()`，并通过 OBProxy 使用 `root@test#demo`
检查租户和代理版本。正式测试只连接 OBProxy，不直连 observer。单机部署命令
依据 [OBD 官方 `demo` 说明](https://en.oceanbase.com/docs/community-obd-en-10000000001957770)。

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

## 独立执行

```bash
bash software/Database/oceanbase/oceanbase_test.sh \
  --version 4.2.5.6 \
  --results-dir /home/runner/boostkit-perf/oceanbase/results/4.2.5.6
```

独立运行和 Framework 均按 build、start、test、stop 执行。stop 阶段只销毁
本次任务私有 `OBD_HOME` 内的 `demo` 集群。独立运行默认清理自身创建的工作
目录；排查部署问题时可使用 `--keep-workdir`。
