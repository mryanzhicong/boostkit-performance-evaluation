# Redis 7.0.15 性能测试

本用例在 x86_64、aarch64 的 openEuler 24.03 LTS SP4 宿主机上构建上游 Redis，
在单个 2 CPU、8 GiB 的同版本 openEuler 容器中运行服务，宿主机运行
`redis-benchmark`。两架构使用相同的 SET/GET 参数，比较 40、60、80 并发下的
吞吐量。软件入口为 `redis_test.sh`；Framework 通过 `case.yaml` 分别调用构建、
启动、测试和停止脚本，独立入口也调用相同的阶段函数。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 构建上游源码；调优版入口位于
`scripts/builders/optimized.sh`，目前尚未实现，选择后会在构建阶段明确失败。
启动、测试和停止阶段共用 `scripts/stages/` 下的脚本；私有路径、实例编号和端口
由 `scripts/common.sh` 管理，结果解析位于 `scripts/results/`。

## 软件与测试工具

| 项目 | 来源与版本 | 安装位置 |
|---|---|---|
| Redis | [上游 Redis](https://github.com/redis/redis) 标签 `7.0.15` | `${PERF_WORK_DIR}/redis-source`，宿主机编译，不执行 `make install` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/redis/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |
| `redis-benchmark`、`redis-cli` | 与被测 Redis 同一源码和版本 | `${PERF_WORK_DIR}/redis-source/src/`，在宿主机运行 |

Runner 需要可访问的 Docker daemon。缺失的宿主机构建命令由脚本通过 `dnf`
安装；普通 Runner 用户使用 `sudo -n dnf`，配置了 `PERF_PROXY` 时将代理传给
`dnf`。源码、二进制和数据都保存在本次任务目录，不写入系统 Redis 目录。

## Redis 构建、部署与启动

`build_redis` 在宿主机浅克隆指定标签并编译，不进入容器构建。实际命令形态为：

```bash
git clone --branch 7.0.15 --depth 1 \
  https://github.com/redis/redis.git "${PERF_WORK_DIR}/redis-source"
cd "${PERF_WORK_DIR}/redis-source"
make -j"$(nproc)" BUILD_TLS=no
```

构建后核对 `src/redis-server`、`src/redis-benchmark`、`src/redis-cli` 均可执行，
并从 `redis-server --version` 校验实际版本为 `7.0.15`。`BUILD_TLS=no` 是两架构
一致的构建参数。

容器镜像按架构选取 `openEuler-docker.x86_64.tar.xz` 或
`openEuler-docker.aarch64.tar.xz`。脚本先查找
`/home/runner/software/redis/openEuler-24.03-LTS-SP4/` 中的归档和同名
`.sha256sum`；缺失时从上表的官方目录下载。SHA-256 校验通过后执行
`docker load --input <归档>`，再核对镜像架构及容器内的 openEuler 版本。
`REDIS_IMAGE_ARCHIVE_DIR` 可指定其他离线归档目录。

`start_redis_service` 默认启动一个容器。容器可在 NUMA node 3 的可用 CPU 上
调度，但总用量限制为 2 CPU，内存限制为 8 GiB；启动前要求该节点至少有
2 个可用 CPU。CPU 编号按当前机器拓扑读取，不写死架构专用编号。
`REDIS_NUMA_NODE` 可选择其他节点。容器以 Runner 的 UID/GID 运行，只挂载本次
任务的 `${PERF_WORK_DIR}`，并使用宿主网络连接 `127.0.0.1`。启动命令形态为：

```bash
docker run --detach --name "${REDIS_CONTAINER_NAME}" \
  --label "boostkit.redis.run-id=${PERF_RUN_ID}" \
  --cpus=2 --cpuset-cpus="${CPU_SET}" --cpuset-mems="${REDIS_NUMA_NODE}" \
  --memory=8g --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  "${REDIS_CONTAINER_IMAGE}" sleep infinity

docker exec "${REDIS_CONTAINER_NAME}" "${REDIS_SERVER_BIN}" \
  --bind 127.0.0.1 --protected-mode yes \
  --port "${REDIS_SERVICE_PORT}" --dir "${SERVICE_DIR}" \
  --daemonize yes --pidfile "${PID_FILE}" --logfile "${LOG_FILE}"

"${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" PING
```

脚本要求 `PING` 返回 `PONG`。容器内如缺少 `libatomic`，只在本任务容器中通过
`dnf` 安装并重新校验二进制；不修改宿主机系统 Redis。Redis 使用默认持久化行为，
数据、日志和 PID 文件位于 `${PERF_WORK_DIR}/instances/1/`。测试前拒绝复用已存在的
任务数据目录、容器名或已运行 Redis 的端口。

容器名为 `boostkit-redis-<架构>-<run-id>-<实例编号>`。端口基数由运行 ID 派生，
默认在 `20000`–`39999`，也可用 `REDIS_SERVICE_PORT` 指定；实例 `i` 的端口为
基数加 `i-1`。设置 `REDIS_INSTANCE_COUNT` 可让启动和停止阶段按编号管理多个容器，
每个实例都有独立的名称、端口和 `${PERF_WORK_DIR}/instances/<编号>/`。默认值为
`1`；当前测试与报告只支持一个实例，多实例启动后运行测试阶段会明确失败。
停止阶段从本次任务记录读取已启动的实例数量，因此可以逐一清理。

## 数据与运行顺序

服务端在容器内运行，客户端在宿主机运行；两者通过本机任务端口通信。
不预先导入数据。每档并发测试前，脚本只对本任务 Redis 执行 `FLUSHALL`，
然后依次执行一轮 40、60、80 并发的 SET/GET 测试：

```bash
for clients in 40 60 80; do
  "${REDIS_CLI_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" FLUSHALL
  "${REDIS_BENCHMARK_BIN}" -h 127.0.0.1 -p "${REDIS_SERVICE_PORT}" \
    -c "${clients}" -d 3 -n 10000000 -r 10000000 \
    -t set,get --threads 20 -q
done
```

| 参数 | 值 | 含义 |
|---|---:|---|
| `-c` | 40、60、80 | 客户端并发连接数，每档各运行一次 |
| `-d` | 3 | SET/GET 值的字节数 |
| `-n` | 10,000,000 | 每种操作、每档并发的请求数 |
| `-r` | 10,000,000 | 随机键空间大小 |
| `-t` | `set,get` | 只执行 SET 和 GET |
| `--threads` | 20 | 宿主机 benchmark 客户端线程数 |
| `-q` | — | 输出吞吐量摘要 |

合计运行 3 档、6 个操作测试；整套测试最长允许 14,400 秒。每档保存实际命令
和完整控制台输出。任何一档执行失败、缺少 SET/GET 摘要或数值无效，测试失败，
不会生成部分成功的比较结果。数据文件保存在 Runner 本次任务目录，不放到 `/tmp`。

## 指标与产物

每档只取 `redis-benchmark` 原始输出中的 `requests per second`，不统计延迟，
也不跨操作或并发档位求平均：

| 报告分组 | 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|---|
| 40 并发 | SET、GET 吞吐量 | `<操作>: <值> requests per second` | requests/s | 越大越好 |
| 60 并发 | SET、GET 吞吐量 | `<操作>: <值> requests per second` | requests/s | 越大越好 |
| 80 并发 | SET、GET 吞吐量 | `<操作>: <值> requests per second` | requests/s | 越大越好 |

总计 6 项指标，报告按并发档位分组，同一档只对比相同操作的两架构数值。
`redis_benchmark_raw.log` 保存原始命令和输出；`benchmark_redis.json` 保存
六项结构化结果及测试参数；`results.json`、`status.json`、`report.md` 是
校验结果和单架构报告，`system_info.json`、`runtime_before.json`、
`runtime_after.json` 保存环境信息。构建阶段还生成 `build_info.json` 和
`build_variant.json`。

脱离 Workflow 执行完整流程：

```bash
bash software/Database/redis/redis_test.sh \
  --version 7.0.15 \
  --variant base \
  --results-dir /home/runner/redis-results/7.0.15
```

独立运行默认在结束后停止 Redis、移除本任务容器并清理私有实例目录和构建工作目录；
需要保留构建目录排障时可加 `--keep-workdir`。停止阶段只处理带有本次运行 ID
标签的容器。正式工作流中，调优版结果归档到
`Database/redis/7.0.15/optimized/<时间戳_Run ID>/`，不更新基础版的
`baseline.json`。
