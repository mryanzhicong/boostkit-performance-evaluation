# Redis 性能用例

本目录由 `/root/redis` 中已有的 Redis 测试代码人工接入，不包含历史 `results/`。Redis 脚本继续负责自身的构建、校验、服务、测试和报告逻辑，公共 Workflow 只按统一阶段调用。

## 分阶段接口

`redis_test.sh` 接受一个阶段参数：

| 参数 | 对应函数 | 用途 |
|---|---|---|
| `build` | `phase_build` | 克隆精确版本，按 Redis 官方 README 的 core 命令裸机编译并安装到任务专属前缀。 |
| `validate` | `phase_validate` | 校验架构、命令、安装文件和实际 Redis 版本，生成版本信息。 |
| `start-service` | `phase_start_service` | 从任务安装前缀启动基准使用的 Redis 服务并等待就绪。 |
| `test` | `phase_test` | 复用已启动服务执行主基准和微基准。 |
| `stop-service` | `phase_stop_service` | 停止服务；该阶段可重复执行，Workflow 无条件调用。 |
| `collect-report` | `phase_collect_report` | 聚合原始结果、生成 Redis 文本报告并检查输出完整性。 |

不传参数时按上述顺序执行完整本地流程；正式 Workflow 逐阶段调用，以便准确显示失败阶段并保证停止服务和清理必定执行。

## 测试内容

- 版本：7.4.10、8.0.0、8.0.6。
- 主基准：SET、GET、INCR、LPUSH、LRANGE_100、SADD、HSET、ZADD 的多客户端并发测试。
- 微基准：数据大小、客户端并发和 none/AOF/RDB 持久化模式。
- SET/GET QPS 和客户端并发扩展比越大越好；平均延迟和最大 P99 延迟越小越好。

## 裸机边界

Runner 必须预装 Bash、Git、Python 3、GCC、G++、GNU ar 和 Make。进入克隆后的源码目录后，脚本直接执行 Redis 官方 README 的 core 构建命令 `make -j "$(nproc)" all`，随后执行 `make install PREFIX=...` 安装到任务专属目录；不单独构建依赖，不指定 allocator、TLS 或其他编译参数，也不使用 sudo、apt、dnf 或系统级 pip。

公共框架在启动软件脚本前剔除 self-hosted Runner 服务继承的 Make 和编译参数，避免 `MAKEFLAGS`、`MYCFLAGS` 等宿主机变量改变官方构建命令；软件若确实需要编译变量，必须在自己的 `case.yaml` 中显式声明。

源码、构建产物、安装前缀、服务数据和临时文件都位于 `/tmp/boostkit-perf`。国内网络环境可通过 Runner 服务环境中的 `REDIS_SOURCE_URL` 指向内部只读源码镜像。
