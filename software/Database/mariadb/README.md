# MariaDB 11.8.10 性能测试

本用例在 x86_64、aarch64 上使用同一份官方 MariaDB `11.8.10` LTS 源码包，在本次任务的 8 CPU、32 GiB（NUMA node 3）openEuler 24.03 LTS SP4 私有容器内编译并运行单节点 MariaDB，宿主机运行 Sysbench `1.0.20` 通过 `127.0.0.1:<任务端口>` 执行单机 OLTP 开箱对比（复刻仓库内 `software/Database/mysql` 的宿主机客户端拓扑例外，两架构采用完全相同的隔离拓扑与计时口径）。

软件入口为 `mariadb_test.sh`；Framework 按 `case.yaml` 调用 `scripts/builders/dispatch.sh` 和 `scripts/stages/{start,test,stop}.sh`。`base` 构建上游原版；`optimized` 尚未实现，选择后明确失败，不会回退到基础版，也不会写出 `build_variant.json`。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| MariaDB 源码与安装 | [官方 MariaDB 11.8.10 LTS 源码包](https://archive.mariadb.org/mariadb-11.8.10/source/mariadb-11.8.10.tar.gz)（官方 SHA-256 `77d62a86477d5b836da960f5228eb4e13458692ab775f2ad95d55fd4a4d3b117`） | 优先读取 `/home/runner/software/mariadb/mariadb-11.8.10.tar.gz`，缺失时下载至 `${PERF_WORK_DIR}`；容器内编译安装到 `${PERF_WORK_DIR}/mariadb` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}` |
| Sysbench | [上游 Sysbench](https://github.com/akopytov/sysbench) 1.0.20，提交 `ebf1c90` | 宿主机私有目录 `${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20` |
| LuaJIT | [上游 LuaJIT](https://github.com/LuaJIT/LuaJIT) v2.1，固定提交 `c6ffc141a8762b41703f9287d63d93622a13dd8f` | `${PERF_WORK_DIR}/sysbench-tools/luajit-<提交>`；编译前替换 Sysbench 内置 LuaJIT |

> **容器外拓扑例外说明（经明确确认）**：本用例按 MySQL 参考架构部署——MariaDB 服务端在 8U32G（NUMA node 3）私有容器内编译与运行，Sysbench 客户端在宿主机私有目录编译并执行（缺失宿主机编译包时通过 `sudo -n dnf` 安装 `autoconf`/`automake`/`libtool`/`openssl-devel`/`zlib-devel` 等），经 `--network=host` 共享的 `127.0.0.1:<任务端口>` 访问容器内 `mariadbd`。计时完全由宿主机 Sysbench 在正式 `run` 阶段统计，两架构拓扑和计时边界一致；清理阶段由 `stop` 关闭 `mariadbd`、停止并删除带本任务标签的容器并清理 `${PERF_WORK_DIR}/instances`。

## 构建与容器

脚本通过 `scripts/common.sh` 接收 Framework 传入的 `SOFTWARE_VERSION`（固定 `11.8.10`）、`PERF_VARIANT`（默认 `base`）、`EXPECTED_ARCH`（`x86_64` 或 `aarch64`）、`PERF_RUN_ID`、`PERF_WORK_DIR`、`RESULTS_DIR`、`PERF_ACTUAL_VERSION_FILE`（仅独立运行时补默认值），并派生唯一容器名 `boostkit-mariadb-${EXPECTED_ARCH}-${PERF_RUN_ID}-1`（归属标签 `boostkit.mariadb.run-id=${PERF_RUN_ID}`）、任务独占端口 `20000 + cksum(PERF_RUN_ID) % 20000` 及私有目录 `${PERF_WORK_DIR}/{home,mariadb-11.8.10,build,mariadb,instances/1,sysbench-tools}`。

`build` 阶段先检查 `docker info` 并拒绝覆盖同名容器；校验并加载 openEuler 24.03 LTS SP4 官方离线镜像（`x86_64 → amd64`、`aarch64 → arm64`），动态读取本机 NUMA node 3 上全部可用 CPU（核对至少 8 个可用 CPU），启动 8U32G 容器（`--cpus=8 --cpuset-cpus="${CPU_SET}" --cpuset-mems=3 --memory=32g --ulimit nofile=65535:65535 --network=host --user "$(id -u):$(id -g)"`），并将 `HOME`、`XDG_CACHE_HOME`、`TMPDIR` 指向本次任务私有目录。

条件挂载规则：

- 设置 `PERF_PROXY` 时，只读挂载 `${MARIADB_CA_ANCHORS_DIR}`（默认 `/home/runner/software/anchors`）到 `/etc/pki/ca-trust/source/anchors` 并执行 `update-ca-trust extract`；无代理时跳过。
- 存在 `/home/runner/.gitconfig` 或 `${MARIADB_OFFLINE_DIR}`（默认 `/home/runner/software/mariadb`）时只读挂载；不存在时跳过。

包含全部可选挂载时的容器创建与初始化命令如下：

```bash
docker run --detach --name "${MARIADB_CONTAINER_NAME}" \
  --label "boostkit.mariadb.run-id=${PERF_RUN_ID}" \
  --cpus=8 --cpuset-cpus="${CPU_SET}" --cpuset-mems=3 \
  --memory=32g --ulimit nofile=65535:65535 \
  --network=host --user "$(id -u):$(id -g)" \
  -e "HOME=${PERF_WORK_DIR}/home" \
  -e "XDG_CACHE_HOME=${PERF_WORK_DIR}/home/.cache" \
  -e "TMPDIR=${PERF_WORK_DIR}/instances/1/tmp" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount "type=bind,source=${MARIADB_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly" \
  --mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly \
  --mount "type=bind,source=${MARIADB_OFFLINE_DIR},target=${MARIADB_OFFLINE_DIR},readonly" \
  "${MARIADB_CONTAINER_IMAGE}" sleep infinity

# 仅设置 PERF_PROXY 时执行：
docker exec --user 0 "${MARIADB_CONTAINER_NAME}" update-ca-trust extract

# 仅容器内存在 /etc/yum.repos.d/openEuler.repo 时执行：
docker exec --user 0 "${MARIADB_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
```

随后在同一容器内安装编译依赖、获取并校验官方源码包、执行 CMake + Ninja Release 编译安装与版本校验：

```bash
# 容器内以 root 安装编译与运行依赖（设置 PERF_PROXY 时追加 --setopt=proxy="${PERF_PROXY}"）
dnf install -y gcc gcc-c++ make cmake ninja-build bison \
  ncurses-devel openssl-devel zlib-devel libaio libaio-devel \
  pcre2-devel fmt-devel libxml2-devel numactl-libs numactl-devel \
  hostname findutils perl perl-Getopt-Long curl tar gzip xz

# 以下均在容器内以 Runner UID/GID 执行：
# 校验 mariadb-11.8.10.tar.gz SHA-256 并解压
tar -xzf "${PERF_WORK_DIR}/mariadb-11.8.10.tar.gz" -C "${PERF_WORK_DIR}"

cmake -S "${PERF_WORK_DIR}/mariadb-11.8.10" -B "${PERF_WORK_DIR}/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PERF_WORK_DIR}/mariadb" \
  -DINSTALL_LIBDIR=lib \
  -DINSTALL_SBINDIR=bin \
  -DINSTALL_SCRIPTDIR=bin \
  -DWITH_SSL=system \
  -DWITH_ZLIB=system \
  -DWITH_PCRE=system \
  -DWITH_MYSQLCOMPAT=ON \
  -DWITH_UNIT_TESTS=OFF \
  -DINSTALL_MYSQLTESTDIR= \
  -DPLUGIN_TOKUDB=NO \
  -DPLUGIN_MROONGA=NO \
  -DPLUGIN_ROCKSDB=NO \
  -DPLUGIN_SPIDER=NO \
  -DPLUGIN_CONNECT=NO \
  -DPLUGIN_OQGRAPH=NO \
  -DPLUGIN_SPHINX=NO \
  -DPLUGIN_COLUMNSTORE=NO \
  -DPLUGIN_S3=NO

ninja -C "${PERF_WORK_DIR}/build" -j 8
ninja -C "${PERF_WORK_DIR}/build" install

ldd "${PERF_WORK_DIR}/mariadb/bin/mariadbd"
"${PERF_WORK_DIR}/mariadb/bin/mariadbd" --version
```

脚本检查 `mariadbd`、`mariadb`、`mariadb-admin`、`mariadb-install-db`、`mariadb_config` 均存在、`ldd` 无缺失库，并从 `mariadbd --version` 提取实际版本 `11.8.10` 写入 `${PERF_ACTUAL_VERSION_FILE}`；随后 `dispatch.sh` 写出 `${RESULTS_DIR}/build_variant.json`。

## 服务初始化、Sysbench 构建与测试

`start` 阶段复用 `build` 创建的同一容器（校验 `State.Running == true` 与 `boostkit.mariadb.run-id == ${PERF_RUN_ID}`），先检查任务端口未被占用，再在容器内执行初始化、以 `prepare` 模式启动 `mariadbd`（`--innodb-flush-log-at-trx-commit=0 --innodb-use-native-aio=OFF --skip-log-bin`），轮询 `mariadb-admin ping` 并核验 `max_prepared_stmt_count=1048576` 与 `max_connections>=2048`，最后配置 `root` 密码并建库 `sbtest`：

```bash
docker exec "${MARIADB_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/mariadb/bin/mariadb-install-db" --no-defaults \
  --basedir="${PERF_WORK_DIR}/mariadb" \
  --datadir="${PERF_WORK_DIR}/instances/1/data" \
  --auth-root-authentication-method=normal \
  --skip-test-db

docker exec -d "${MARIADB_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/mariadb/bin/mariadbd" --no-defaults \
  --basedir="${PERF_WORK_DIR}/mariadb" \
  --datadir="${PERF_WORK_DIR}/instances/1/data" \
  --tmpdir="${PERF_WORK_DIR}/instances/1/tmp" \
  --socket="${PERF_WORK_DIR}/instances/1/mariadb.sock" \
  --pid-file="${PERF_WORK_DIR}/instances/1/mariadb.pid" \
  --port="${MARIADB_PORT}" --bind-address=127.0.0.1 \
  --max-connections=2048 --max-prepared-stmt-count=1048576 \
  --log-error="${PERF_WORK_DIR}/instances/1/mariadb.err" \
  --innodb-flush-log-at-trx-commit=0 --innodb-use-native-aio=OFF --skip-log-bin
```

`test` 阶段复用同一容器，首先在宿主机由 `scripts/prepare_sysbench.sh` 构建固定提交的 Sysbench `1.0.20`（`ebf1c90` + LuaJIT `c6ffc141a8762b41703f9287d63d93622a13dd8f` + `THREAD_INIT_TIMEOUT=300`），链接私有 `${PERF_WORK_DIR}/mariadb` 头文件与 `libmariadb`（带 `-Wl,-rpath,${PERF_WORK_DIR}/mariadb/lib`），并校验三个 `oltp_*.lua` 脚本可加载：

```bash
./autogen.sh
PATH="${PERF_WORK_DIR}/mariadb/bin:${PATH}" \
LDFLAGS="-Wl,-rpath,${PERF_WORK_DIR}/mariadb/lib" \
  ./configure --with-mysql
make -j"$(getconf _NPROCESSORS_ONLN)"
```

随后按以下顺序执行数据准备、快照与正式压测：

1. 运行 `oltp_read_write prepare`：16 张表，每张 1,000,000 行，16 线程；检查无 `FATAL:` 且 `information_schema.tables` 中 `sbtest1`～`sbtest16` 全部齐全。
2. 通过 `mariadb-admin shutdown` 正常停库，检查磁盘余量并将数据目录复制到 `${PERF_WORK_DIR}/instances/1/snapshot`。
3. 以 `benchmark` 模式重启 `mariadbd`（`--innodb-flush-log-at-trx-commit=1 --innodb-use-native-aio=ON --log-bin=${DATADIR}/mariadb-bin`），查询并保存 5 项生效配置至 `mariadb-benchmark-config.log`。
4. 按 `read_only`、`read_write`（重启后）、`write_only`（从快照恢复并重启后）顺序测试：每个场景静置 10 秒后先以 `oltp_read_only`、64 线程预热 **60 秒**（不计入指标），再按 **256、128、32、1** 线程顺序各运行 **60 秒**正式测试：

```bash
LUA_PATH="${SYSBENCH_LUA_DIR}/?.lua;;" LD_LIBRARY_PATH="${PERF_WORK_DIR}/mariadb/lib" \
  "${SYSBENCH_BIN}" --db-driver=mysql \
  --mysql-host=127.0.0.1 --mysql-port="${MARIADB_PORT}" \
  --mysql-user=root --mysql-password="${MARIADB_PASSWORD}" \
  --mysql-db=sbtest --table_size=1000000 --tables=16 --threads=16 \
  --percentile=95 --report-interval=1 \
  "${SYSBENCH_LUA_DIR}/oltp_read_write.lua" prepare

LUA_PATH="${SYSBENCH_LUA_DIR}/?.lua;;" LD_LIBRARY_PATH="${PERF_WORK_DIR}/mariadb/lib" \
  "${SYSBENCH_BIN}" --db-driver=mysql \
  --mysql-host=127.0.0.1 --mysql-port="${MARIADB_PORT}" \
  --mysql-user=root --mysql-password="${MARIADB_PASSWORD}" \
  --mysql-db=sbtest --table_size=1000000 --tables=16 --threads=64 --time=60 \
  --percentile=95 --report-interval=1 \
  "${SYSBENCH_LUA_DIR}/oltp_read_only.lua" run

LUA_PATH="${SYSBENCH_LUA_DIR}/?.lua;;" LD_LIBRARY_PATH="${PERF_WORK_DIR}/mariadb/lib" \
  "${SYSBENCH_BIN}" --db-driver=mysql \
  --mysql-host=127.0.0.1 --mysql-port="${MARIADB_PORT}" \
  --mysql-user=root --mysql-password="${MARIADB_PASSWORD}" \
  --mysql-db=sbtest --table_size=1000000 --tables=16 --threads=<线程数> --time=60 \
  --percentile=95 --report-interval=1 \
  "${SYSBENCH_LUA_DIR}/oltp_<场景>.lua" run
```

`stop` 阶段先保存 `mariadb.err` 与 `docker logs` 至 `${RESULTS_DIR}/service-logs/`，正常关闭 `mariadbd`，核对 `boostkit.mariadb.run-id` 标签后停止并删除本任务容器，最后清理 `${PERF_WORK_DIR}/instances` 私有数据目录（不触碰 `${RESULTS_DIR}` 与共享离线目录）。

### 与 MySQL 参考用例的差异

| 差异 | 当前做法与原因 |
|---|---|
| 软件包来源与构建 | MySQL 官方同时提供 x86_64/aarch64 二进制包；MariaDB 官方 `bintar` 仅提供 x86_64，无 aarch64。本用例在两架构均使用官方 `mariadb-11.8.10.tar.gz` 源码包，在 8U32G 私有容器内用相同 CMake + Ninja 参数编译安装。 |
| 容器生命周期起点 | MySQL 在 `start` 阶段才创建容器；本用例按 `SKILL.md` 在 `build` 阶段创建容器并在 `start`/`test`/`stop` 全程复用同一容器。 |
| 数据库初始化与启停 | 使用 `mariadb-install-db --auth-root-authentication-method=normal` 替代 MySQL 的 `--initialize-insecure`；使用 `docker exec -d mariadbd` 替代 `--daemonize`。 |
| OLTP 负载规模 | 按确认口径缩小为 **16 表 × 1,000,000 行、预热 60 秒、正式 60 秒**（保持相同的 3 场景 × 4 线程 36 项矩阵），整套执行预计约 20–30 分钟（含源码编译与数据准备）。 |

## 结果与报告

| 结果 | 位置 | 用途 |
|---|---|---|
| 构建变体与版本 | `${RESULTS_DIR}/build_variant.json`、`${RESULTS_DIR}/source-checksum.txt`、`${RESULTS_DIR}/binary-version.txt`、`${RESULTS_DIR}/toolchain-versions.txt` | 记录 `base` 变体、源码 SHA-256 与实际编译出的 MariaDB 版本 |
| 完整原始输出 | `${RESULTS_DIR}/sysbench_raw.log`、`${RESULTS_DIR}/sysbench-runs/` | 保留全部预热与 12 次正式运行原始日志 |
| 生效配置与诊断日志 | `${RESULTS_DIR}/mariadb-benchmark-config.log`、`${RESULTS_DIR}/service-logs/` | 留存正式模式 SQL 参数核验、错误日志与 `docker logs` |
| 归一化指标 | `${RESULTS_DIR}/results.json` | 36 项二维矩阵指标（3 场景 × 4 线程 × 3 指标），供 Framework 单架构和跨架构报告读取 |

指标提取口径（不将预热结果纳入报告）：

| 指标 | Sysbench 原始字段 | 单位 | 方向 |
|---|---|---|---|
| `TPS` | `transactions: ... (X per sec.)` | `transactions/s` | `higher_is_better` |
| `QPS` | `queries: ... (X per sec.)` | `queries/s` | `higher_is_better` |
| `P95 latency` | `Latency (ms)` 下的 `95th percentile` | `ms` | `lower_is_better` |

## 独立执行

在仓库根目录运行（Runner 需具备 Docker 权限与至少 4 个 NUMA 节点且 node 3 至少 8 核可用）：

```bash
bash software/Database/mariadb/mariadb_test.sh \
  --version 11.8.10 --variant base \
  --results-dir /home/runner/mariadb-results/11.8.10
```

独立入口依次执行构建、启动、压测与停止（失败或中断时通过 `EXIT` trap 调用 `stop` 收口），并在结果目录写出 `results.json`、`status.json` 和 `report.md`；默认仅清理本次自行创建的 `/home/runner/boostkit-perf/mariadb/local-*` 目录（添加 `--keep-workdir` 可保留排障）。

> **当前验证状态**：本用例已完成第 1 层静态接线、解析器、容器契约单测与双架构矩阵对比预检；**真实 openEuler 24.03 LTS SP4 8U32G 容器内源码编译、`mariadb-install-db`/`mariadbd` 启停、宿主机 Sysbench 1.0.20 链接压测、Runner 清理权限以及 x86_64 / aarch64 正式端到端测试尚未在目标 Runner 上执行**。
