# Redis 性能用例

本目录由 `/root/redis` 中已有的 Redis 测试代码人工接入，不包含历史 `results/`。Redis 脚本负责自身的构建、服务生命周期、性能测试和软件级结果聚合，公共 Framework 负责严格结果校验、指标提取和通用报告。

## 分阶段接口

`redis_test.sh` 接受一个阶段参数：

| 参数 | 对应函数 | 用途 |
|---|---|---|
| `build` | `phase_build` | 克隆精确版本，原样执行 `/root/redis/redis_test.sh` 的构建命令，随后校验架构、二进制和实际版本。 |
| `start` | `phase_start` | 从源码树的 `src/redis-server` 启动基准使用的 Redis 服务并等待就绪。 |
| `test` | `phase_test` | 复用已启动服务执行主基准和微基准，并聚合生成 `results.json` 与 `results.txt`。 |
| `stop` | `phase_stop` | 停止服务并确认端口释放；该阶段可重复执行，Workflow 无条件调用。 |

不传参数时按上述顺序执行完整本地流程；正式 Workflow 逐阶段调用。测试结束后由 Framework `finalize` 检查全部预期文件非空，并严格提取清单声明的数值指标。

## 测试内容

- 版本：7.4.10、8.0.0、8.0.6。
- 主基准：SET、GET、INCR、LPUSH、LRANGE_100、SADD、HSET、ZADD 的多客户端并发测试。
- 微基准：数据大小、客户端并发和 none/AOF/RDB 持久化模式。
- SET/GET QPS 和客户端并发扩展比越大越好；平均延迟和最大 P99 延迟越小越好。

## 裸机边界

Runner 必须预装 Git、Python 3、GCC 和 Make。构建阶段只把原脚本的临时源码目录换成 Workflow 任务专属目录，构建命令保持为 `make -j$(nproc) BUILD_TLS=no`。构建完成后直接使用源码树中的 `src/redis-server`、`src/redis-benchmark` 和 `src/redis-cli`，不执行 `make install`，也不增加、删除或重写其他 Make 参数。

公共框架只通过 `EXPECTED_ARCH` 告知用例预期架构，不再设置 `TARGET_ARCH`。GNU Make 的内置 C 编译规则会把 `TARGET_ARCH` 当成编译参数；此前设置为 `aarch64` 后，Lua 编译命令错误地把它当作输入文件。

源码、构建产物、安装前缀、服务数据和临时文件都位于 `/tmp/boostkit-perf`。国内网络环境可通过 Runner 服务环境中的 `REDIS_SOURCE_URL` 指向内部只读源码镜像。
