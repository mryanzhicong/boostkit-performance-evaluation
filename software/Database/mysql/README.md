# MySQL 性能测试说明

本目录测试 MySQL 8.0 的 Linux Generic 预编译二进制包，并使用
`database_blue` 的 Sysbench 1.0 MySQL 测试套件进行 x86_64 与 aarch64
开箱性能对比。软件入口为 `mysql_test.sh`，Framework 通过 `case.yaml`
调用其 `build`、`start`、`test`、`stop` 四个阶段；直接执行该脚本也使用
同一套阶段函数。

当前清单仅声明 MySQL `8.0.46`。新增版本或架构时，必须同时在
`mysql_test.sh` 中声明官方二进制包文件名及其 MD5，不能跳过校验。

## 构建与安装

这里的“构建”是部署官方二进制包，不从源码编译 MySQL，也不安装系统级
MySQL RPM。

1. 根据版本与架构选择官方 Linux Generic 包。当前包名为：

   | 架构 | 包名 |
   |---|---|
   | `x86_64` | `mysql-8.0.46-linux-glibc2.28-x86_64.tar.xz` |
   | `aarch64` | `mysql-8.0.46-linux-glibc2.28-aarch64.tar.xz` |

2. 依次在以下位置获取包：

   1. `/home/runner/software/mysql/<包名>` 的本地离线包；
   2. 当前任务工作目录中的同名缓存包；
   3. MySQL 官方下载地址 `https://dev.mysql.com/get/Downloads/MySQL-8.0/`。

3. 使用清单中声明的官方 MD5 校验包完整性，校验失败立即退出。
4. 解压到本次任务的 `PERF_WORK_DIR/mysql`，并验证 `mysqld`、`mysql`
   二进制及其实际版本。该目录仅供本次任务使用。
5. 运行时缺失的系统依赖由脚本自动通过 `dnf` 安装；非 root Runner 使用
   `sudo -n dnf`。其中包括 MySQL 运行所需的 `libaio-devel`、
   `openssl-devel`，以及构建 Sysbench 所需的编译和 autotools 工具。

脚本实际使用的下载和校验命令形态如下。`<包名>` 按上表选择：

```bash
curl -fSL --retry 3 --connect-timeout 30 -o "${PERF_WORK_DIR}/<包名>" \
  "https://dev.mysql.com/get/Downloads/MySQL-8.0/<包名>"
md5sum "${PERF_WORK_DIR}/<包名>"
tar -xJf "${PERF_WORK_DIR}/<包名>" -C "${PERF_WORK_DIR}"
```

在 Runner 预置离线包时，应使用与目标架构相符的文件名。例如 aarch64：

```bash
sudo install -d -o runner -g runner /home/runner/software/mysql
sudo install -o runner -g runner mysql-8.0.46-linux-glibc2.28-aarch64.tar.xz \
  /home/runner/software/mysql/
md5sum /home/runner/software/mysql/mysql-8.0.46-linux-glibc2.28-aarch64.tar.xz
```

MySQL 数据目录不放在 `/tmp`，而是位于：

```text
${PERF_WORK_DIR}/data/
```

这样数据写入会经过 Runner 的实际磁盘文件系统。任务结束后，脚本停止
MySQL 并删除该运行 ID 对应的数据目录。

## 服务启动

`start` 阶段在上述数据目录中执行 `mysqld --initialize-insecure`，随后以
独立实例启动 MySQL。服务只绑定 `127.0.0.1`，端口由运行 ID 稳定派生，
避免并发任务固定占用 `3306`。

启动时会设置：

- `--max-connections=2048`，覆盖 Sysbench 的最高 1024 线程档位；
- 本次任务专用 socket、PID、错误日志和临时目录；
- 本次任务专用 root 密码及 `sysbench` 数据库。

脚本在 socket 和 TCP 两条路径分别执行 `SELECT 1`，确认本次启动的实例和
测试账户可用后才进入测试阶段；不会连接或复用预先存在的 MySQL 服务。

核心启动与连通性检查命令如下，路径、端口和密码均由任务运行时生成：

```bash
"${MYSQLD_BIN}" --no-defaults --initialize-insecure \
  --basedir="${MYSQL_BASE_DIR}" --datadir="${DATADIR}" \
  --user="$(id -un)" --log-error="${ERR_LOG}"

"${MYSQLD_BIN}" --no-defaults --basedir="${MYSQL_BASE_DIR}" \
  --datadir="${DATADIR}" --tmpdir="${MYSQL_TMP_DIR}" \
  --socket="${SOCKET_PATH}" --pid-file="${PID_FILE}" \
  --port="${MYSQL_PORT}" --bind-address=127.0.0.1 \
  --max-connections=2048 --log-error="${ERR_LOG}"

"${MYSQL_BIN}" --socket="${SOCKET_PATH}" -u root -N -e 'SELECT 1'
MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
  -h127.0.0.1 -P"${MYSQL_PORT}" -uroot -N -e 'SELECT 1'
```

## 性能测试

测试采用固定版本的第三方套件及原始测试场景：

| 组件 | 固定来源 |
|---|---|
| database_blue | `https://gitcode.com/mwx5319395/database_blue.git`，提交 `af4759227538961f0b0bed5ffc25434d65e7456b` |
| Sysbench | `https://github.com/akopytov/sysbench.git`，版本 `1.0.17`，提交 `d634bce` |

脚本在任务私有目录构建 Sysbench，再以临时符号链接满足 database_blue 原有的
固定路径要求。测试结束后只清理本任务创建的链接，不删除其他任务或人工
准备的同名路径。

正式流程如下：

1. 执行原始 `prepare.sh`：创建 `sysbench` 数据库中的 100 张表，每张表
   1,000,000 行，使用 60 个准备线程。
2. 执行原始 `runall.sh`。为接入任务实例，仅注入本次任务的主机、端口和
   密码；测试场景及其负载参数保持 database_blue 原始脚本定义。
3. 每个场景按 128、256、512、1024 线程运行；原脚本默认每次运行 60 秒。
4. 保留完整控制台输出为 `database_blue_sysbench_raw.log`，并从本次运行
   新产生的 `normal_<场景>.log_<时间>` 汇总文件提取结构化结果。

对 database_blue 原脚本，适配层只写入任务实例的地址、端口和密码；随后
直接执行其原始入口。实际命令如下：

```bash
cd "${PERF_WORK_DIR}/database_blue/resources/database/client/script/sysbench_mysql_1.0"
sed -i "s/^host=.*/host='${MYSQL_HOST}'/" runall.sh
sed -i "s/^password=.*/password='${MYSQL_PASSWORD}'/" runall.sh
sed -i "s/-P 3306/-P ${MYSQL_PORT}/g" runall.sh
sed -i 's/--mysql-host=${HOST}/--mysql-host=${HOST} --mysql-port=${PORT}/' prepare.sh

bash prepare.sh -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" \
  -u "${MYSQL_DB_USER}" -p "${MYSQL_PASSWORD}"
bash runall.sh
```

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop 并
保存同样的产物。例如：

```bash
bash software/Database/mysql/mysql_test.sh \
  --version 8.0.46 \
  --results-dir /home/runner/boostkit-perf/mysql/results/8.0.46
```

覆盖的场景为：

```text
distinct、index、nonindex、order、point、simple、sum、delete、mix
```

## 指标

每个“场景 + 线程数”组合都保留原始 Sysbench 汇总行中的 3 个字段，不做
平均、加权、评分或跨场景聚合。因此总计为：

```text
9 个场景 × 4 个线程档位 × 3 个指标 = 108 个指标
```

| 原始字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `TPS` | `sysbench <场景> --threads=<线程数>: TPS` | transactions/s | 越大越好 | 每秒完成事务数 |
| `QPS` | `sysbench <场景> --threads=<线程数>: QPS` | queries/s | 越大越好 | 每秒执行查询数 |
| `transactions` | `sysbench <场景> --threads=<线程数>: transactions` | transactions | 越大越好 | 本次 60 秒运行期间完成的事务总数 |

报告按测试场景分组；每个场景中再按线程数展示 TPS、QPS 和 transactions，
便于在相同负载下比较 x86_64 与 aarch64。测试工具及其固定版本会同时列在
报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `database_blue_sysbench_raw.log`：原始控制台输出；
- `results.json`：108 个结构化指标及其来源文件名。

`stop` 阶段优先通过任务 socket 正常关闭 MySQL，必要时执行 SQL `SHUTDOWN`，
确认服务不可达后移除本次数据目录和 database_blue 临时工具链接。Framework
随后执行 Runner 级环境清理。
