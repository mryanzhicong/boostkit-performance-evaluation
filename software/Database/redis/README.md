# Redis 性能测试说明

本目录从 Redis 官方仓库构建指定版本，启动一个任务私有 Redis 实例，并按
`database_blue` 的物理机 Redis 性能用例提供 Redis 自带 `redis-benchmark` 的负载
参数。当前测试不指定 `-t`，直接运行该工具的完整默认操作集。
Framework 通过 `case.yaml` 调用 `redis_test.sh` 的 `build`、`start`、`test`、
`stop` 四个阶段；直接执行入口脚本会使用同一套构建、测试、信息收集和清理流程。

当前清单支持 `7.4.10`、`8.0.0`、`8.0.6`，独立入口默认版本为 `8.0.6`。

## 构建与安装

Redis 从官方 GitHub 标签浅克隆，在任务隔离工作目录中编译，不安装系统级 Redis
软件包。脚本检查 `git`、`python3`、`gcc`、`make`、`sed`、`grep` 和 coreutils
工具；缺失时通过 `dnf` 自动安装，非 root Runner 使用 `sudo -n dnf`。

当前实际构建命令为：

```bash
git clone --branch 8.0.6 --depth 1 https://github.com/redis/redis.git redis-source
cd redis-source
make -j"$(nproc)" BUILD_TLS=no
```

构建完成后必须存在以下 Redis 官方二进制，并通过 `redis-server --version` 校验实际
版本与请求版本一致：

```text
src/redis-server
src/redis-benchmark
src/redis-cli
```

源码与编译产物位于 Framework 的任务工作目录。独立执行时的默认工作目录在 `/tmp`
下，仅用于构建；使用 `--keep-workdir` 才会在执行结束后保留它用于排障。

## 服务启动与数据目录

Redis 服务数据不放在 `/tmp`。每次运行使用唯一的持久化目录：

```text
/home/runner/redis-data/<版本>/<架构>/<运行 ID>/
```

该目录包含 Redis 的数据文件、RDB/AOF（如运行期间产生）、日志和 PID。可通过
`REDIS_DATA_ROOT` 修改根目录。端口默认由运行 ID 稳定派生，范围为
`20000`–`39999`，也可通过 `REDIS_SERVICE_PORT` 显式指定，从而不会固定占用 6379
或与并发任务冲突。

核心启动命令如下：

```bash
./src/redis-server \
  --bind 127.0.0.1 \
  --protected-mode yes \
  --port "${REDIS_SERVICE_PORT}" \
  --dir "${REDIS_DATA_ROOT}/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}" \
  --daemonize yes \
  --pidfile "${SERVICE_DIR}/redis.pid" \
  --logfile "${SERVICE_DIR}/redis.log"

./src/redis-cli -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING
```

脚本拒绝复用既有任务数据目录或既有端口服务。Redis 使用默认持久化行为，未通过
`--save ""` 或 `--appendonly no` 关闭 RDB/AOF。

## 性能测试

测试参考 `database_blue` 的物理机用例
`tests/kunpeng_virtual/performance_loss/25.0/redis/virtuall_redis_ori_0001.py` 的
请求数、客户端数、随机键空间和客户端线程数。当前 Workflow 每个架构只有一台专用
Runner，因此服务端和客户端均位于 `127.0.0.1`。在此负载参数基础上，不传 `-t`，
由 Redis 版本自身选择完整默认操作集。

正式执行的一条命令为：

```bash
./src/redis-benchmark -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" \
  -n 10000000 -c 1000 -r 10000000 --threads 20
```

参数含义如下：

| 参数 | 值 | 含义 |
|---|---:|---|
| `-n` | 10,000,000 | 每项操作的请求数 |
| `-c` | 1,000 | 并发客户端连接数 |
| `-r` | 10,000,000 | 随机键空间大小 |
| `--threads` | 20 | benchmark 客户端线程数 |

整套默认操作集最长允许 14,400 秒；任何默认操作缺少唯一吞吐摘要或吞吐为非正数时，
测试直接失败。完整原始输出（包含实际命令）保存为 `redis_benchmark_raw.log`。

## 指标

保留 `redis-benchmark` 本次默认操作集中的全部操作，不做自定义并发矩阵、微基准、
跨操作平均或综合评分。默认集由 Redis 版本本身决定，脚本不维护也不筛选操作清单。

| 报告分组 | 原始输出字段 | 报告指标名 | 单位 | 优化方向 |
|---|---|---|---:|---|
| 每个官方默认操作 | 该操作 `====== <操作> ======` 段中的 `throughput summary: <值> requests per second` | `<操作>: requests per second` | requests/s | 越大越好 |

`benchmark_redis.json` 保存全部结构化结果和固定测试参数。解析器按每个官方操作的
输出分段记录吞吐，因此操作名称和 `throughput summary` 一一对应。

## 独立执行、结果与清理

可脱离 Workflow 执行完整流程：

```bash
bash software/Database/redis/redis_test.sh \
  --version 8.0.6 \
  --results-dir /home/runner/redis-results/8.0.6
```

独立执行会依次完成环境采集、构建、启动、测试、停止、结果校验和单架构报告生成。
结果目录至少包含：

- `redis_benchmark_raw.log`：一条官方默认集压测命令的完整原始输出；
- `benchmark_redis.json`：全部默认操作的结构化吞吐及测试参数；
- `system_info.json`、`runtime_before.json`、`runtime_after.json`：测试环境信息；
- `build_info.json`、`results.json`、`status.json`、`report.md`：构建记录、校验结果和报告。

停止阶段先使用任务端口执行 `SHUTDOWN NOSAVE`，必要时再终止记录的进程；确认端口
不可达后，仅删除本次运行 ID 的 Redis 数据目录。独立运行还会删除自己创建的构建
工作目录，除非指定 `--keep-workdir`。
