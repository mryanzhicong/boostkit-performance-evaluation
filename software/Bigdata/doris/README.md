# Doris 2.1.2 性能测试

本用例在单容器内运行 Apache Doris 2.1.2（FE×1 + BE×1 同容器），用 TPC-H 22 条
查询测量 SF1 数据量下的端到端查询耗时：主指标是 22 条查询的 wall time 合计，
辅助指标是每条查询的中位耗时。Doris 安装包、JDK、Python 依赖和正式测试都在本次
任务的私有容器内完成；`start`、`test`、`stop` 复用 `build` 创建的那一个容器。

容器规格固定为 32 个物理核（单 NUMA 节点）、128 GiB 内存、不限 memlock。
**不修改任何内核参数**：THP、swap、`sysctl`、`limits.conf`、`drop_caches` 与
BIOS/电源策略保持 Runner 原状，只在结果目录记录实际值。软件侧参数
（FE 8G 堆、BE `mem_limit=90%`、`parallel_pipeline_task_num=32`、
`exec_mem_limit=100G`、`query_timeout=7200`）按 bdperf 文档 §7.2 固定，两侧一致。

入口为 `doris_test.sh`。Framework 按 `case.yaml` 调用 build、start、test、stop，
独立入口调用同一组函数。`scripts/builders/base.sh` 负责镜像、Doris 包、BiSheng JDK
与 pymysql 的准备，`scripts/stages/` 负责配置、启动、造数、导入、查询与清理，
`scripts/results/` 负责解析。`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| Apache Doris | `apache-doris-2.1.2-bin-{x64,arm64}.tar.gz`，来自 `https://apache-doris-releases.oss-accelerate.aliyuncs.com` | 优先读取 `/home/runner/software/doris/`；缺失才下载到 `${PERF_WORK_DIR}` |
| JDK | BiSheng JDK `8u472-b11`（华为镜像，x86_64/aarch64 各一份，校验值固定） | 优先读取 `/home/runner/software/bishengjdk/` |
| 容器镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/` |
| pymysql | `py3-none-any` wheel | 优先读取 `/home/runner/software/python/pymysql-*.whl`；缺失时容器内联网安装 |
| 数据生成 | tpch-kit 的 `dbgen` | 优先读取 `/home/runner/software/tpch/tpch-kit-master.zip` |
| 查询 | 本用例 `scripts/queries/q1.sql` … `q22.sql` | 与 ClickHouse 用例同一批 TPC-H 改写版 |

Doris 官方发布页不提供 tar 包的独立校验文件；本用例在适配时从上述官方地址下载并
计算 SHA-256，固定写在 `scripts/common.sh` 的 `doris_package_sha256` 中，构建时
先校验再解包。BiSheng JDK 使用与 ZooKeeper/ClickHouse 用例相同的固定 SHA-256。

离线目录可用 `DORIS_OFFLINE_DIR`、`DORIS_JDK_OFFLINE_DIR`、
`DORIS_PYTHON_OFFLINE_DIR`、`DORIS_TPCH_OFFLINE_DIR`、
`DORIS_IMAGE_ARCHIVE_DIR`、`DORIS_CA_ANCHORS_DIR` 覆盖；生产 Runner 使用默认值。

## 获取、构建与容器启动

构建阶段先检查 Docker daemon 并加载 openEuler 24.03 LTS SP4 镜像：

```bash
command -v docker >/dev/null && docker info >/dev/null
ARCHIVE="${DORIS_IMAGE_ARCHIVE_DIR:-/home/runner/software/openEuler-24.03-LTS-SP4}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
URL="https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${EXPECTED_ARCH}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
[[ -s "${ARCHIVE}" ]] || curl -fSL --retry 3 -o "${ARCHIVE}" "${URL}"
[[ -s "${ARCHIVE}.sha256sum" ]] || curl -fSL --retry 3 -o "${ARCHIVE}.sha256sum" "${URL}.sha256sum"
expected="$(awk 'NR == 1 {print $1}' "${ARCHIVE}.sha256sum")"
actual="$(sha256sum "${ARCHIVE}")"
[[ "${actual%% *}" == "${expected,,}" ]] || { echo "image SHA-256 mismatch"; exit 1; }
output="$(docker load --input "${ARCHIVE}")"
DORIS_CONTAINER_IMAGE="$(printf '%s\n' "${output}" | sed -nE 's/^Loaded image( ID)?: (.+)$/\2/p' | tail -n 1)"
printf '%s\n' "${DORIS_CONTAINER_IMAGE}" > "${PERF_WORK_DIR}/container-image.txt"
docker image inspect --format '{{.Architecture}}' "${DORIS_CONTAINER_IMAGE}"   # x86_64→amd64、aarch64→arm64
docker run --rm --network=none "${DORIS_CONTAINER_IMAGE}" cat /etc/os-release   # 必须是 openEuler 24.03 LTS SP4
```

随后解包官方 tar 到 `${PERF_WORK_DIR}/apache-doris-2.1.2-bin-<x64|arm64>`，解包 BiSheng
JDK，把 `doris_client.py` 复制到 `${PERF_WORK_DIR}/tools`。镜像自带 python3，但
没有 pip，且 dnf 源在部分环境不可用，因此 pymysql 采用**纯 Python wheel 直接解包**
到 `${PERF_WORK_DIR}/python`，通过 `PYTHONPATH` 导入（适配时使用 1.2.4 的
`py3-none-any` wheel）；不再依赖容器内 pip 或 dnf 安装 Python 包。镜像自带 curl，
Stream Load 直接使用。

构建阶段还会在容器内安装并校验 `gcc`、`make`、`curl`，把 tpch-kit 解包到
`${PERF_WORK_DIR}/tpch-kit-extract` 并编译 `${PERF_WORK_DIR}/tpch-kit/dbgen/dbgen`；
`test` 阶段只生成数据、导入和跑查询，不再安装编译工具。

实际版本从 BE 二进制的 `--version` 输出读取（`doris_be --version` 打印
`doris-2.1.2-rc04(AVX2) ...`；FE 的 `doris-fe.jar` 清单里是过期的
`1.2-SNAPSHOT`，不能用）。Framework 要求实际版本与请求版本完全相等，因此去掉
`-rcNN` 后缀得到 `2.1.2` 写入 `PERF_ACTUAL_VERSION_FILE`，完整的
`2.1.2-rc04` build 字符串另存到 `${RESULTS_DIR}/doris_build_string.txt`；
`build` 成功后写 `build_variant.json`。

容器名称为 `boostkit-doris-<架构>-<run-id>`，创建命令如下：

```bash
docker run --detach --name "${DORIS_CONTAINER_NAME}" \
  --label "boostkit.doris.run-id=${PERF_RUN_ID}" \
  --network=host \
  --user "$(id -u):$(id -g)" \
  --cpuset-cpus="${DORIS_CPUSET}" \
  --cpuset-mems="${DORIS_MEMSET}" \
  --memory="${DORIS_MEMORY}" \
  --memory-swap="${DORIS_MEMORY_SWAP}" \
  --ulimit nofile=1048576:1048576 \
  --ulimit memlock=-1:-1 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${DORIS_CONTAINER_IMAGE}" sleep infinity
```

| 变量 | 默认值 | 说明 |
|---|---|---|
| `DORIS_CPUSET` | `0-31` | 单 NUMA 节点上的 32 个物理核，两个架构必须相同 |
| `DORIS_MEMSET` | `0` | 与 cpuset 对应的 NUMA 节点 |
| `DORIS_MEMORY` / `DORIS_MEMORY_SWAP` | `128g` / `128g` | 容器内存与 swap 额度，相等即容器内禁用 swap |
| `DORIS_CONTAINER_IMAGE` | 上一步 `docker load` 的输出 | 不写死 tag |

开发机冒烟可用 `DORIS_CPUSET`、`DORIS_MEMSET`、`DORIS_MEMORY`、
`DORIS_MEMORY_SWAP` 覆盖并注明；正式 Runner 必须用默认值。容器不加
`--privileged`。

容器创建后，脚本**总是**在本次容器内把 openEuler 软件源改为
`repo.huaweicloud.com/openeuler`，并注释 `metalink` 行：

```bash
docker exec --user 0 "${DORIS_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
```

设置 `PERF_PROXY` 时，额外把 `/home/runner/software/anchors/` 只读挂到
`/etc/pki/ca-trust/source/anchors/` 并执行 `update-ca-trust extract`；没有代理时
不挂载证书目录。换源只作用于本次任务的容器，不改宿主机。

## 启动

`start` 校验容器、端口空闲，写入 `fe.conf` 与 `be.conf`：

```properties
# fe/conf/fe.conf
priority_networks = 127.0.0.1/32
query_port = <19000+offset>
http_port = <19000+offset+1>
rpc_port = <19000+offset+2>
edit_log_port = <19000+offset+3>
meta_dir = ${PERF_WORK_DIR}/data/doris/meta
JAVA_OPTS = -Xmx8g -Xms8g
```

```properties
# be/conf/be.conf
priority_networks = 127.0.0.1/32
be_port = <19000+offset+4>
webserver_port = <19000+offset+5>
heartbeat_service_port = <19000+offset+6>
brpc_port = <19000+offset+7>
storage_root_path = ${PERF_WORK_DIR}/data/doris/storage
mem_limit = 90%
storage_flood_stage_left_capacity_bytes = 10737418240
```

随后启动 FE 与 BE：

```bash
docker exec --detach -e DORIS_HOME=<fe> -e PID_DIR=<fe>/bin -e LOG_DIR=<fe>/log \
  -e CLASSPATH=<fe>/lib/doris-fe.jar:<fe>/conf:<fe>/lib/*:<fe>/lib \
  <容器> ${JDK_HOME}/bin/java -Xmx8g -Xms8g -Dfile.encoding=UTF-8 \
  -XX:-OmitStackTraceInFastThrow org.apache.doris.DorisFE
docker exec --detach -e JAVA_HOME=<jdk> -e DORIS_HOME=<be> -e PID_DIR=<be>/bin \
  -e LOG_DIR=<be>/log <容器> <be>/lib/doris_be
docker exec <容器> python3 ${PERF_WORK_DIR}/tools/doris_client.py wait-fe --port <query_port> --timeout 180
docker exec <容器> python3 ${PERF_WORK_DIR}/tools/doris_client.py add-backend \
  --port <query_port> --host 127.0.0.1 --heartbeat-port <heartbeat_port>
docker exec <容器> python3 ${PERF_WORK_DIR}/tools/doris_client.py wait-backend --port <query_port> --timeout 180
```

**为什么不用发行包的 `start_fe.sh`/`start_be.sh`**：两个脚本都调用 `getopt`，而
openEuler 最小镜像没有 util-linux；`start_be.sh` 还会在 `vm.max_map_count < 2000000`
或存在 swap 时直接退出，这两项属于本仓库禁止修改的内核参数。因此本用例直接启动
`org.apache.doris.DorisFE` 与 `be/lib/doris_be`，并把容器内实际
`vm.max_map_count`、swap 状态记录到 `${DORIS_RESULT_DIR}/kernel_state.txt`，由报告
如实说明"未按 Doris 建议调大内核参数"。

就绪判断不是固定 `sleep`：`wait-fe` 反复建立 MySQL 连接直到成功，`wait-backend`
反复执行 `SHOW BACKENDS` 并要求所有行 `Alive=true`。成功后把
`SHOW FRONTENDS`、`SHOW BACKENDS` 的原始输出保存到
`${DORIS_RESULT_DIR}/show_{frontends,backends}.tsv`。

注意 `SELECT version()` 返回 `5.7.99` 是 MySQL 协议兼容行为；真实版本看
`SHOW FRONTENDS` 的 `Version` 列与构建阶段写入的实际版本文件。

## 测试负载

1. 使用构建阶段编译好的 `${PERF_WORK_DIR}/tpch-kit/dbgen/dbgen` 生成 SF1 数据到
   `${PERF_WORK_DIR}/tpch-data/sf1`，删除每行末尾的 `|`。
2. 建库 `tpch_sf1`（`DROP DATABASE IF EXISTS` 后重建），8 张表全部
   `DUPLICATE KEY`、`DISTRIBUTED BY HASH(<主键>) BUCKETS n`、
   `PROPERTIES("replication_num"="1")`；金额 `DECIMAL(15,2)`、日期 `DATE`、
   `l_comment VARCHAR(44)`、`o_comment VARCHAR(79)`；并建 q15 依赖的视图 `revenue0`。
3. 逐表 Stream Load：

   ```bash
   curl -sS -L --location-trusted -u root: \
     -H 'Expect: 100-continue' \
     -H 'format: csv' -H 'column_separator: |' -H 'columns: <列名列表>' \
     -T <table>.tbl \
     http://127.0.0.1:<http_port>/api/tpch_sf1/<table>/_stream_load
   ```

   必须同时带 `-L` 和 `--location-trusted`，并解析返回 JSON 的 `Status` 字段；
   失败时 HTTP 仍可能是 200。Doris 2.1.2 的 Stream Load 还要求请求带
   `Expect: 100-continue`，缺少时返回
   `{"status":"FAILED","msg":"There is no 100-continue header"}`。
4. 校验 SF1 行数（同 ClickHouse 用例的 8 个数字），不一致直接失败。
5. 用 pymysql 串行执行 22 条查询 × 3 轮，每轮开始前设置
   `parallel_pipeline_task_num=32`、`exec_mem_limit=107374182400`、
   `query_timeout=7200`；每条查询用 `time.perf_counter()` 包住
   `execute + fetchall()`，得到端到端 wall ms。

单容器只有 1 个 BE，并行度完全由 `parallel_pipeline_task_num` 决定，必须与容器
CPU 限额一致；这是本口径与手册“4 容器（1FE+3BE）”的差异，绝对值不可与手册比较。

## 指标与产物

| 指标 | 原始字段 | 单位 | 方向 |
|---|---|---|---|
| `tpch-22-total/total_time` | 22 条每轮 wall 求和后取中位数 ÷ 1000 | s | 越小越好 |
| `tpch-qNN/duration_ms` | 每条查询 3 轮 wall 的中位数 | ms | 越小越好 |

共 23 项，分组为 `tpch-22-total` 与 `tpch-qNN`。固定负载参数写入 `parameters`
（SF、轮次、`parallel_pipeline_task_num`、`exec_mem_limit`、`replication_num`、
计时口径）。解析器拒绝轮次/查询缺失、重复、非正或非有限耗时、查询编号越界。

Doris 用端到端 wall，ClickHouse 用服务端 `query_duration_ms`，**两者绝对值不可
横向比较**，各自只算本组件的跨架构比值。

| 产物 | 内容 |
|---|---|
| `doris-official/tpch_wall.csv` | 每轮每条查询的端到端耗时 |
| `doris-official/show_{frontends,backends}.tsv` | FE/BE 拓扑与存活状态 |
| `benchmark_doris_raw.log` | 拓扑、27×22 条耗时数据 |
| `benchmark_doris.json` | 23 项指标与固定参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `service-logs/`、`fe-logs/`、`be-logs/` | 停止阶段保存的日志 |
| `results.json`、`report.md` | 独立入口生成的结果与报告 |

脱离 Workflow 执行：

```bash
bash software/Bigdata/doris/doris_test.sh \
  --version 2.1.2 --variant base \
  --results-dir /home/runner/doris-results/2.1.2
```

独立运行可用 `--keep-workdir` 保留私有目录；默认只删除本次独立运行创建的
`/home/runner/boostkit-perf/doris/local-*`。

## 与 bdperf 参考文档的差异

| 项目 | bdperf `04_Doris单容器性能测试.md` | 本用例 | 原因 |
|---|---|---|---|
| 内核 / 系统调优 | THP=always、swapoff、`sysctl`、BIOS 电源策略 | **全部不做**，只记录 | 本仓库禁止修改内核参数 |
| 容器规格 | 32U/128G（单容器 FE+BE） | 相同；补 cpuset/mems/ulimit，去掉 privileged | 对齐性能对比边界 |
| 软件参数 | FE 8G、BE 90%、并行度 32、100G 查询内存 | **保持一致** | 跨架构可比 |
| 端口 | 9030/8030/9010/9020、9050/9060/8040/8060 固定 | 从 29000 起按 run ID 偏移 | 同机并行隔离 |
| 数据规模 | SF1 回归 / SF100 正式 | **只用 SF1**；SF100 未跑 | bdperf 只在 SF1 验证过 |
| 启动方式 | `start_fe.sh`/`start_be.sh` | 直接启动 FE 主类与 BE 二进制 | 镜像缺 getopt；BE 脚本强制要求改内核参数 |
| 系统用户 | 容器内 root | Runner UID/GID | 宿主可读可删 |
| 结果对照 | `results_arm/doris_tpch_sf1_aarch64.csv` | 不引用 | 容器/内核对齐口径不同 |

## 未验证与限制

- 本机适配只验证了构建、启动与健康检查，**未执行 TPC-H 查询**；SF1 的正式数字
  以流水线为准，SF100 未实现。
- BE 启动硬性要求 `ulimit -n > 60000`；容器以 `--ulimit nofile=1048576` 兜住，
  不再在脚本里执行 `ulimit`。
- Doris 建议 `vm.max_map_count >= 2000000`，本用例**不改内核参数**；实际值记录在
  `kernel_state.txt`，正式跑大数据量前需确认 Runner 现有值是否足够。
- 开发机冒烟时 FE 堆通过 `DORIS_FE_HEAP` 缩小到 4G（正式默认 8G），BE 的
  `mem_limit=90%` 仍按发行包默认；这些覆盖只用于本地验证，正式 Runner 用默认值。
- gcc/make/curl 与 tpch-kit 在 `build` 阶段准备；如果 Runner 的容器源不可用，
  构建会在 `dnf install` 处失败，不会拖到 `test` 阶段才暴露。离线环境需预置
  tpch-kit 压缩包，或允许构建阶段访问容器源。
- `optimized` 变体未实现，选择后构建阶段明确返回非零。
