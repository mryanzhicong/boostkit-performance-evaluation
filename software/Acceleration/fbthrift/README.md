# fbthrift 2022.11.14.00 性能测试

本用例在 aarch64（Kunpeng 950）与 x86_64 两种 openEuler 24.03 LTS SP4 环境的私有容器中，用
clang 16.0.6 构建上游 facebook/folly、facebookincubator/fizz、facebook/wangle、facebook/fbthrift
四个 `v2022.11.14.00` 标签的源码，再用 AccLibBenchmark 的 `press_server` / `press_client`
（Thrift RPC，rocket transport，close_loop 模式）测量 11 种数据类型 × 5 种连接形态 × 3 种队列深度的
RPC 吞吐、时延与 CPU 占用。

- **架构范围**：`aarch64` 与 `x86_64`，两个架构使用同一份源码、同一矩阵，便于跨架构配对。
- **容器规格**：容器**不限制 CPU、内存或 NUMA**（`docker run` 不传 `--cpus`/`--cpuset-*`/`--memory`），
  服务端与客户端都跑在同一个容器内，`--network=host`，NUMA 绑定由容器内的 `numactl -N 1` 完成
  （节点不存在时自动退回 0，见「已知限制」）。
- **入口脚本**：`fbthrift_test.sh`。Framework 六阶段（build / prepare / start / test / stop / report）
  与独立入口调用同一批阶段函数 `build_fbthrift`、`start_fbthrift_runtime`、`run_fbthrift_benchmarks`、
  `stop_fbthrift_runtime`。
- **变体**：只有 `base`（上游默认 Release 构建）。调优版入口位于 `scripts/builders/optimized.sh`，
  目前**尚未实现**，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 Folly | [facebook/folly](https://github.com/facebook/folly) `v2022.11.14.00`（commit 由 `git rev-parse v2022.11.14.00^{commit}` 固定） | `${PERF_WORK_DIR}/folly-source`，容器内构建，安装到 `${PERF_WORK_DIR}/install/folly` |
| 被测软件 Fizz | [facebookincubator/fizz](https://github.com/facebookincubator/fizz) `v2022.11.14.00` | `${PERF_WORK_DIR}/fizz-source` → `${PERF_WORK_DIR}/install/fizz` |
| 被测软件 Wangle | [facebook/wangle](https://github.com/facebook/wangle) `v2022.11.14.00` | `${PERF_WORK_DIR}/wangle-source` → `${PERF_WORK_DIR}/install/wangle` |
| 被测软件 fbthrift | [facebook/fbthrift](https://github.com/facebook/fbthrift) `v2022.11.14.00` | `${PERF_WORK_DIR}/fbthrift-source` → `${PERF_WORK_DIR}/install/fbthrift` |
| 编译依赖 fast_float | [fastfloat/fast_float](https://github.com/fastfloat/fast_float) `v8.2.10` | `${PERF_WORK_DIR}/fast_float`，仅头文件 |
| 编译器 clang 16 | [terralang/llvm-build llvm-16.0.6](https://github.com/terralang/llvm-build/releases/tag/llvm-16.0.6) 官方 Linux 归档，按架构选择（见下表） | 优先公共目录 `/home/runner/software/fbthrift/`，否则下载到 `${PERF_WORK_DIR}/downloads/`，解压到 `${PERF_WORK_DIR}/clang16` |
| 测试工具 AccLibBenchmark | 仓库外的私有 fixture `fb_folly_autobuild` / `fbthrift_folly_benchmark`（内部压测工具，版本 unknown） | 宿主机复制到 `${PERF_WORK_DIR}/acclib-source`，容器内构建为 `${PERF_WORK_DIR}/fbthrift_folly_benchmark/build/press_{server,client}` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |

clang 16.0.6 归档与校验值（两个架构各一份，`sha256sum -c` 通过后才解压）：

| 架构 | 归档名 | SHA-256 |
|---|---|---|
| aarch64 | `clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz` | `e624cd19010fce9d7ba89066ab36d633514be9ce0237416943c1c05c59d1bf3c` |
| x86_64 | `clang+llvm-16.0.6-x86_64-linux-gnu.tar.xz` | `2be9b9d5e2ca1f6411d9988496a820c556c65c4354c3949fe411646986922468` |

## fbthrift 获取、构建与容器启动

### 获取顺序

按 **公共离线目录 → 本任务缓存 → 官方下载** 三段取值，任何一段命中都不再联网：

1. `/home/runner/software/fbthrift/`（以及旧的 `/home/runner/software/folly/`）下的
   `clang+llvm-16.0.6-<arch>-linux-gnu.tar.xz` 与 AccLibBenchmark 目录；
2. `${PERF_WORK_DIR}/downloads/`、`${PERF_WORK_DIR}/clang16`、`${PERF_WORK_DIR}/acclib-source`（上一次运行留下的缓存）；
3. 官方地址：`https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/<归档名>`，
   镜像依次回退 `gh-proxy.com`、`ghfast.top`、`hub.gitmirror.com`；四个库源码用 `git clone --branch v2022.11.14.00 --depth 1`。

### 实际命令形态

```bash
# 1) 宿主机：准备 clang 16 归档（离线命中则跳过下载），校验后解压
install -d "${PERF_WORK_DIR}/downloads" "${PERF_WORK_DIR}/clang16"
curl -fL --retry 2 --connect-timeout 30 --max-time 1800 \
  -o "${PERF_WORK_DIR}/downloads/clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz" \
  https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz
echo "e624cd19010fce9d7ba89066ab36d633514be9ce0237416943c1c05c59d1bf3c  ${PERF_WORK_DIR}/downloads/clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz" | sha256sum -c -
tar -xf "${PERF_WORK_DIR}/downloads/clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz" -C "${PERF_WORK_DIR}/clang16" --strip-components=1
"${PERF_WORK_DIR}/clang16/bin/clang++" --version   # 必须输出 clang version 16.0.6

# 2) 宿主机：拉取四个库的固定标签（tag 与 HEAD 必须一致，否则构建失败）
git clone --branch v2022.11.14.00 --depth 1 --recurse-submodules https://github.com/facebook/folly.git "${PERF_WORK_DIR}/folly-source"
git clone --branch v2022.11.14.00 --depth 1 --recurse-submodules https://github.com/facebookincubator/fizz.git "${PERF_WORK_DIR}/fizz-source"
git clone --branch v2022.11.14.00 --depth 1 --recurse-submodules https://github.com/facebook/wangle.git "${PERF_WORK_DIR}/wangle-source"
git clone --branch v2022.11.14.00 --depth 1 --recurse-submodules https://github.com/facebook/fbthrift.git "${PERF_WORK_DIR}/fbthrift-source"
git clone --branch v8.2.10 --depth 1 https://github.com/fastfloat/fast_float.git "${PERF_WORK_DIR}/fast_float"
git -C "${PERF_WORK_DIR}/folly-source" rev-parse HEAD   # 与 v2022.11.14.00^{commit} 比对

# 3) 宿主机：把私有压测工具复制进任务目录（容器只挂载 PERF_WORK_DIR，读不到 /home/runner/software）
cp -a /home/runner/software/fbthrift/AccLibBenchmark/fbthrift_folly_benchmark "${PERF_WORK_DIR}/acclib-source/"
```

### 容器创建

```bash
docker run --detach --name "${FBTHRIFT_CONTAINER_NAME}" \
  --label "boostkit.fbthrift.run-id=${PERF_RUN_ID}" \
  --network=host \
  --user "$(id -u):$(id -g)" \
  --ulimit nofile=1048576:1048576 \
  --mount type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR} \
  --mount type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR} \
  --mount type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  sleep infinity
```

- 容器名固定为 `boostkit-fbthrift-<arch>-<runid>`；清理时只删除带本任务
  `boostkit.fbthrift.run-id` 标签的容器，不同运行互不干扰。
- 容器不设 `--cpus`/`--cpuset-cpus`/`--cpuset-mems`/`--memory`，即不限制 CPU、内存与 NUMA；
  CPU 编号不写死，NUMA 节点由容器内 `numactl --hardware` 读取后再绑定。
- 暴露的 RPC 端口由运行 ID 派生（`cksum "${PERF_RUN_ID}"` 映射到 20000–39990），
  服务端与客户端使用同一个端口，避免并发任务撞端口。
- `PERF_PROXY` 启用时，把宿主机 CA 锚点只读挂到 `/etc/pki/ca-trust/source/anchors/`，
  并在容器内以 root 执行 `update-ca-trust extract`。

### 容器内准备与构建

镜像来自 openEuler 官方归档：校验 SHA-256 后 `docker load`，不访问 Docker Hub；镜像源只改本次容器
（注释 `meta` 行、`repo.openeuler.org` → `repo.huaweicloud.com/openeuler`），在装包之前完成。
**不向宿主机安装**任何编译依赖，宿主只负责 docker、下载/克隆与结果收集。

```bash
# 容器内 root：安装编译依赖（只装进本次容器；不装 clang，clang 用上面校验过的 16.0.6 归档）
docker exec --user 0 "${FBTHRIFT_CONTAINER_NAME}" dnf -y --setopt=install_weak_deps=False install \
  git cmake make gcc gcc-c++ python3 tar gzip xz bzip2 which diffutils glibc-devel binutils time \
  boost-devel glog-devel gflags-devel libevent-devel openssl-devel zlib-devel double-conversion-devel \
  fmt-devel libunwind-devel lz4-devel zstd-devel libsodium-devel liburing-devel snappy-devel \
  gtest-devel gmock-devel libaio-devel libatomic numactl libicu-devel util-linux

# 容器内：按 Folly → Fizz → Wangle → fbthrift → AccLibBenchmark 的顺序用 clang 16 编译
CC="${PERF_WORK_DIR}/clang16/bin/clang" CXX="${PERF_WORK_DIR}/clang16/bin/clang++" \
cmake -S "${PERF_WORK_DIR}/folly-source" -B "${PERF_WORK_DIR}/folly-build" \
  -DCMAKE_C_COMPILER="${PERF_WORK_DIR}/clang16/bin/clang" \
  -DCMAKE_CXX_COMPILER="${PERF_WORK_DIR}/clang16/bin/clang++" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF \
  -DCMAKE_INSTALL_PREFIX="${PERF_WORK_DIR}/install/folly" \
  -DCMAKE_LIBRARY_ARCHITECTURE="$("${PERF_WORK_DIR}/clang16/bin/clang" -dumpmachine)" \
  -DFASTFLOAT_INCLUDE_DIR="${PERF_WORK_DIR}/fast_float/include"
cmake --build "${PERF_WORK_DIR}/folly-build" --parallel "$(nproc)"
cmake --install "${PERF_WORK_DIR}/folly-build"

# fizz / wangle / fbthrift 使用同一组 -DCMAKE_* 参数，并传入上一层的 *_DIR
# fbthrift 额外带 -DTHRIFT_ENABLE_ARM_SVE2=ON（见「已知限制」：上游忽略该变量）

# 生成 Thrift 代码并编译压测工具
cd "${PERF_WORK_DIR}/fbthrift_folly_benchmark"
"${PERF_WORK_DIR}/install/fbthrift/bin/thrift1" --gen mstch_cpp2 press.thrift
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PERF_WORK_DIR}/install/fbthrift:${PERF_WORK_DIR}/install/wangle:${PERF_WORK_DIR}/install/fizz:${PERF_WORK_DIR}/install/folly"
cmake --build build --parallel "$(nproc)" --target press_server press_client
```

容器内构建前会把 fixture 复制成私有副本，并移除其中只有华为 fork 才提供的
`folly::IOBuf` 内存池与 io_uring 调用（上游 v2022.11.14.00 没有这些接口），
兼容性改动逐处记录在 `${PERF_WORK_DIR}/acclib-compatibility.json`。

- **脚本出处**：`scripts/build_acclib_stack.sh`、`scripts/prepare_benchmark.py`、`scripts/builders/base.sh`

## 数据与运行顺序

以下步骤按顺序执行；两个架构使用同一矩阵，仅 `nproc` 与 NUMA 节点数随机器变化。

1. **构建**：按上一节完成四个库与压测工具的 clang 16 构建，产物
   `${PERF_WORK_DIR}/fbthrift_folly_benchmark/build/press_server`、`press_client`。
2. **启动服务端**（容器内，后台）：

   ```bash
   docker exec "${FBTHRIFT_CONTAINER_NAME}" bash -c \
     "nohup ${NUMA_PREFIX} '${SERVER_BINARY}' --num_io_threads=40 --num_cpu_threads=40 \
        --port=${PORT} --use_io_uring=false \
        > '${SERVICE_DIR}/press_server.log' 2>&1 < /dev/null &"
   # 就绪判定：容器内 bash 的 /dev/tcp 能连上 127.0.0.1:${PORT}
   # 容器镜像里没有 setsid，且 SERVER_BINARY 必须是绝对路径（工作目录在容器内可能不同）
   ```

3. **小矩阵验证（先跑）**：2 连接 × 2 队列 × 1 数据 = 4 个单元，用于验证 clang 16 构建、
   SVE2 开关与 io_uring 三个风险点，同时确认服务端/客户端能正常通信。

   ```bash
   docker exec "${FBTHRIFT_CONTAINER_NAME}" python3 "${SCRIPT_DIR}/scripts/results/run_matrix.py" \
     --client "${PERF_WORK_DIR}/fbthrift_folly_benchmark/build/press_client" \
     --port "${PORT}" --numa-node 1 --matrix small \
     --test-seconds 120 --rpc-timeout-ms 2000 --cpu-threads 40 --io-threads 40 \
     --version 2022.11.14.00 --arch "$(uname -m)" \
     --results-json "${RESULTS_DIR}/benchmark_fbthrift.json" --raw-dir "${RESULTS_DIR}/raw"
   ```

4. **全量矩阵**：11 数据类型 × 5 连接形态 × 3 队列深度 = 165 个单元：

   ```bash
   docker exec "${FBTHRIFT_CONTAINER_NAME}" python3 "${SCRIPT_DIR}/scripts/results/run_matrix.py" \
     --client "${PERF_WORK_DIR}/fbthrift_folly_benchmark/build/press_client" \
     --port "${PORT}" --numa-node 1 --matrix full \
     --test-seconds 120 --rpc-timeout-ms 2000 --cpu-threads 40 --io-threads 40 \
     --version 2022.11.14.00 --arch "$(uname -m)" \
     --results-json "${RESULTS_DIR}/benchmark_fbthrift.json" --raw-dir "${RESULTS_DIR}/raw"
   ```

5. **清理**：容器内 `pkill -f press_server`，随后按标签删除容器；失败时保留
   `${RESULTS_DIR}/raw/` 与 `press_server.log` 供排查，不删除。

参数矩阵（两个架构一致）：

| 维度 | 取值 | 说明 |
|---|---|---|
| 数据类型（11） | `binary` 256 B / 1024 B / 4096 B / 8192 B / 16384 B；`i32` 2048 B；`i64` 1024 B；`double` 512 B；`list<i32>` 4096 B；`list<i64>` 2048 B；`string` 8192 B | 由 `--fields=... --payload_size=...` 组合 |
| 连接形态（5） | `[cpu=1, io=1, conn=50]`、`[10,10,500]`、`[20,20,1000]`、`[40,40,1000]`、`[40,40,2000]` | 服务端固定 `--num_io_threads=40 --num_cpu_threads=40` |
| 队列深度（3） | 10、25、50 | 客户端 `--queue_depth=` |
| 单次时长 | 120 s | `--test_seconds=120`，`--mode=close_loop` |
| 传输 | rocket，无压缩 | `--transport=rocket --compression=none` |
| 超时 | 2000 ms | `--rpc_timeout_ms=2000` |

小矩阵（`--matrix small`）取 `[8,8,500]`、`[16,16,1000]` 两种连接、队列深度 10/50、`binary 256 B` 一种数据，
共 4 个单元，用于风险点验证；全量矩阵同时覆盖 `--use_io_uring=false` 的固定取值。

- **脚本出处**：`scripts/results/run_matrix.py`、`scripts/stages/start.sh`、`scripts/stages/test.sh`
- **采样规则**：受 wiki 口径与总时长约束（165 个单元），每个单元执行一次 120 s 稳态运行，客户端在窗口内
  连续压测并输出 avg/p99；不单独预热、不重复采样，原始输出逐单元保留。小矩阵用于风险点验证，
  已在 aarch64 Blue Runner 上通过（run 44261371268：4 个单元 / 32 项指标，构建日志无编译错误）。
  这与 Framework 对「单配置用例」要求的 1 次预热 + 5 次重复不同，属本用例的显式取舍（见「已知限制」）。

## 指标与产物

每个矩阵单元输出 8 项指标；全量矩阵 165 × 8 = **1320 项**，小矩阵 4 × 8 = **32 项**。
分组列取数据类型（`<payload>`），同一数据类型的 15 种连接/队列组合放在一组便于横向比较；
指标名形如 `<数据类型>-conn<连接数>-qd<队列深度>-cpu<线程数> :: <指标>`。

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `Throughput` | `press_client` 输出 `Throughput: <n>MB/s` | MB/s | 越大越好 |
| `QPS` | 同一输出 `QPS: <n>` | ops/s | 越大越好 |
| `Success Rate` | `Success:` 与 `Fail:` 计算的成功占比 | % | 越大越好 |
| `Failed Requests` | 同一输出 `Fail: <n>` | requests | 中性 |
| `latencyAvg` | 同一输出 `Latency (us): avg=` | us | 越小越好 |
| `latencyP99` | 同一输出 `Latency (us): ... p99=` | us | 越小越好 |
| `Client CPU (%)` | 同一输出 `Client CPU (%): ... avg=` | % | 中性 |
| `Server CPU (%)` | 同一输出 `Server CPU (%): ... avg=` | % | 中性 |

**分组规则**：按数据类型分组（`binary-256B`、`i32-2048B`、…）；跨架构只配对参数完全相同的单元，
核数不同导致的连接档位不强行配对，配对时按 `cpu_threads/io_threads/connections/queue_depth` 一一对应。

产物清单：

| 产物 | 内容 | 生成方 |
|---|---|---|
| `${RESULTS_DIR}/benchmark_fbthrift.json` | 1320 项指标 + 运行上下文（矩阵、端口、NUMA、io_uring=false） | 矩阵驱动 |
| `${RESULTS_DIR}/raw/<cell>.log` | 每个矩阵单元的 `press_client` 原始输出 | 矩阵驱动 |
| `${RESULTS_DIR}/runtime.json` | 端口、NUMA 节点、线程数、io_uring 开关 | 启动阶段 |
| `${RESULTS_DIR}/build_variant.json` | 构建变体（`base`） | 构建阶段 |
| `${RESULTS_DIR}/actual-version.txt` | 实际源码版本（`2022.11.14.00`） | 构建阶段 |
| `framework` 侧 `results.json`/报表 | 由 Framework 采样与展示，独立入口不生成 | Framework |

解析严格性：每个单元必须能在原始输出里找到 8 个字段，缺字段或数值非法（`NaN`、负值、`Success=0`）
立即失败并保留原始日志，**绝不补零、绝不降级**；io_uring 固定为 `false`，若服务端/客户端启动参数不一致
则矩阵驱动直接失败。

## 独立运行

```bash
bash software/Acceleration/fbthrift/fbthrift_test.sh \
  --version 2022.11.14.00 --variant base \
  --results-dir /home/runner/fbthrift-results/2022.11.14.00 \
  --work-dir /home/runner/boostkit-perf/fbthrift/2022.11.14.00-$(date +%s) \
  --keep-workdir
```

内部实际执行（独立入口与 Framework 六阶段调用的都是这四个函数）：

```bash
# 构建：创建容器 -> 容器内装依赖 -> 校验/解压 clang 16 -> 宿主机克隆四个库 -> 容器内编译
# 启动：容器内后台运行 press_server（有 NUMA 节点时用 numactl -N <node>，否则直接运行），
#       端口由运行 ID 派生
docker exec "${FBTHRIFT_CONTAINER_NAME}" bash -c \
  "nohup ${NUMA_PREFIX} '${SERVER_BINARY}' \
     --num_io_threads=40 --num_cpu_threads=40 --port=${PORT} --use_io_uring=false \
     > '${SERVICE_DIR}/press_server.log' 2>&1 < /dev/null &"
# 测量：python3 scripts/results/run_matrix.py --matrix full ...（见「数据与运行顺序」第 4 步）
# 停止：pkill -f press_server；按 boostkit.fbthrift.run-id 标签删除容器
```

- `--keep-workdir` 保留私有目录（含源码、clang、构建产物），便于复跑；不传则结束后清理。
- `optimized` 结果落 `results/<version>/optimized/`，不更新基线；当前未实现，选择后构建阶段失败。
- 数据目录与容器名均按运行 ID 隔离，可并发运行不同版本；同一个运行内不要重复启动服务端。

## 已知限制

- **SVE2 开关**：wiki 要求 `-DTHRIFT_ENABLE_ARM_SVE2=ON`，但该选项只存在于华为 fork；上游
  `v2022.11.14.00` 的 CMake 与源码都没有任何 SVE2 实现。用例仍显式传入 ON 以对齐 wiki 口径，
  实测该变量只停留在 `CMakeCache.txt` 的 `THRIFT_ENABLE_ARM_SVE2:UNINITIALIZED=ON`，构建走的是
  上游标量路径，因此本用例把它记为 **N/A**，不声称「已启用 SVE2」。
- **io_uring**：上游 v2022.11.14.00 没有 `IoUringBackend`/`AsyncIoUringSocket` 等 RPC 路径，
  fixture 中调用它们的代码在私有副本里被替换为 `LOG(FATAL)`，因此矩阵固定 `--use_io_uring=false`；
  若强行 `true`，服务端/客户端会立即退出，用例不会静默降级。
- **矩阵规模**：165 个单元 × 120 s ≈ 5.5 小时（不含构建）；`case.yaml` 声明 720 分钟超时，可覆盖
  构建 + 全量矩阵，仍建议先用 `FBTHRIFT_MATRIX=small` 验证风险点再跑全量。
- **采样**：每个单元单次 120 s，不满足「1 次预热 + 5 次重复」的通用采样要求（165 单元 × 6 次不现实），
  依赖全量矩阵的配置覆盖与 small 矩阵重复一次做稳定性核对；报告为单次窗口的 avg/p99，不提供置信区间。
- **libunwind 探测被关闭**：上游 folly 的 `FindLibUnwind` 存在包名不一致（`LIBUNWIND` vs
  `LibUnwind`），aarch64 openEuler 上 `libfolly.so` 会留下 `_ULaarch64_get_reg`/`unw_backtrace` 未定义
  引用，导致所有链接 libfolly.so 的可执行文件（含示例程序）链接失败。用例统一传
  `-DCMAKE_DISABLE_FIND_PACKAGE_LibUnwind=ON`，让 folly 走 glibc `backtrace()` 回退；符号化器不在本 RPC
  基准的测量范围内，x86_64/aarch64 因此行为一致，且不改上游源码。
- **clang 16 归档较大**：LLVM 16.0.6 官方归档约 780 MB，runner 到 GitHub 的链路会间歇性中断；下载
  按「可续传 + 停滞 60 s 即换源」重试镜像，成功后会缓存到 `/home/runner/software/fbthrift/`，
  后续运行（例如全量矩阵）直接复用，不再重复下载。
- **依赖网络**：构建阶段需要访问 GitHub（四个库、fast_float、clang 16 归档）；离线 runner 需把
  `/home/runner/software/fbthrift/` 下的归档与 AccLibBenchmark 预先放好，否则会失败退出。
- **容器内不装 git**：openEuler 的 `git` 依赖 `systemd`（连带 `dbus` 的安装脚本），在该 rootless
  容器里 dnf 事务会失败；因此四个源码仓库与 clang 16 归档都由宿主机准备，容器内只复用已标签校验的检出，
  构建脚本以 `FBTHRIFT_SKIP_GIT=1` 跳过容器内的 git 校验，编译产物本身不受影响。
- **权限**：需要可访问的 Docker daemon（缺失时 `require_fbthrift_docker` 返回 30），
  容器内装包需要 root（`docker exec --user 0`）；宿主机不安装任何软件包。
- **端口**：端口由运行 ID 派生，若宿主机已有进程占用会启动失败并保留日志；不写死 23456。
