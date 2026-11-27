# llama.cpp 3ac67535c86 bge-m3 Q8_0 性能测试

本用例在 x86_64、aarch64 上使用同一个上游 llama.cpp 提交 `3ac67535c86`（纯上游原版，不合入任何调优补丁或基线修复补丁）。构建和测试都在本次任务的 openEuler 24.03 LTS SP4 私有容器内进行；不限制容器 CPU、内存，不绑核（无 `taskset`），也不添加架构专用编译特性或调优环境变量。测试使用随源码构建的上游 `llama-bench`，对官方 `bge-m3-q8_0.gguf` 执行 `pp512`（`-p 512 -b 512 -n 0 -t 1 -r 5`）性能基准测试。

软件入口为 `llama-cpp_test.sh`；Framework 按 `case.yaml` 调用 `scripts/builders/dispatch.sh` 和 `scripts/stages/{start,test,stop}.sh`。`base` 构建上游原版；`optimized` 尚未实现，选择后明确失败，不会回退到基础版，也不会写出 `build_variant.json`。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| llama.cpp 源码 | [上游源码](https://github.com/ggml-org/llama.cpp.git) 提交 `3ac67535c86`（纯原版，无补丁） | 优先克隆 `/home/runner/software/llama-cpp/llama.cpp.git`（或 `llama.cpp`），缺失时从 GitHub 克隆至 `${PERF_WORK_DIR}/llama.cpp-3ac67535c86` |
| `llama-bench` 测试工具 | 同一上游提交随源码构建（`ggml-cpu`、`llama-embedding`、`llama-bench`、`llama-server`） | `${PERF_WORK_DIR}/build/bin/llama-bench` |
| `bge-m3` Q8_0 模型 | [ggml-org/bge-m3-Q8_0-GGUF](https://huggingface.co/ggml-org/bge-m3-Q8_0-GGUF/resolve/main/bge-m3-q8_0.gguf) 的 `bge-m3-q8_0.gguf`（634,553,760 字节，SHA-256 `aa473d51f451a22f0fcf39ba3330c14bed38a385712b1113440f69df4047a173`） | 优先读取 `/home/runner/software/llama-cpp/bge-m3-q8_0.gguf`，缺失时下载到 `${PERF_WORK_DIR}/models/bge-m3-q8_0.gguf` |
| 容器镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}` |

## 构建与容器

脚本通过 `scripts/common.sh` 接收 Framework 传入的 `SOFTWARE_VERSION`（固定 `3ac67535c86`）、`PERF_VARIANT`（默认 `base`）、`EXPECTED_ARCH`（`x86_64` 或 `aarch64`）、`PERF_RUN_ID`、`PERF_WORK_DIR`、`RESULTS_DIR`、`PERF_ACTUAL_VERSION_FILE`（仅独立运行时补默认值），并计算 `LLAMA_CPP_CONTAINER_NAME="boostkit-llama-cpp-${EXPECTED_ARCH}-${PERF_RUN_ID}"`、私有目录 `${PERF_WORK_DIR}/{home,llama.cpp-3ac67535c86,build,models,tmp}`。

`build` 阶段先检查 `docker info` 并拒绝覆盖已存在的同名容器；再读取 `openEuler-docker.<架构>.tar.xz` 和对应 `.sha256sum`（默认目录 `LLAMA_CPP_IMAGE_ARCHIVE_DIR=/home/runner/software/openEuler-24.03-LTS-SP4`，缺失时从官方地址原子下载到 `${PERF_WORK_DIR}`），校验 SHA-256 后执行 `docker load --input "${ARCHIVE}"`，核对镜像架构（`x86_64 → amd64`、`aarch64 → arm64`）与容器内 `/etc/os-release` 为 openEuler 24.03 LTS SP4，并将实际加载出的镜像名写入 `${PERF_WORK_DIR}/container-image.txt`。容器使用当前 Runner 用户的 UID/GID、宿主机网络，设置 `--ulimit nofile=65535:65535`，将 `HOME`、`XDG_CACHE_HOME` 与 `TMPDIR` 指向本次任务私有目录，不限制 CPU 或内存，也不向宿主机安装编译依赖或模型。

```bash
archive="${LLAMA_CPP_IMAGE_ARCHIVE_DIR}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
printf '%s  %s\n' "$(awk 'NR==1 {print $1}' "${archive}.sha256sum")" "${archive}" | sha256sum -c -
docker load --input "${archive}"
docker image inspect --format '{{.Architecture}}' "${LLAMA_CPP_CONTAINER_IMAGE}"
docker run --rm --network=none "${LLAMA_CPP_CONTAINER_IMAGE}" cat /etc/os-release
```

条件挂载规则：

- Runner 存在 `/home/runner/.gitconfig` 时，脚本以只读方式挂载到容器内同一路径，并在 `docker exec` 中设置 `GIT_CONFIG_GLOBAL=/home/runner/.gitconfig`；文件不存在时跳过。
- Runner 存在 `${LLAMA_CPP_OFFLINE_DIR}`（默认 `/home/runner/software/llama-cpp`）时，以只读方式挂载到容器内同一路径供离线源码克隆；目录不存在时跳过。
- 正式工作流设置 `PERF_PROXY` 时，脚本校验 `${LLAMA_CPP_CA_ANCHORS_DIR}`（默认 `/home/runner/software/anchors`）存在并以只读方式挂载到 `/etc/pki/ca-trust/source/anchors`，执行 `update-ca-trust extract`，并在容器内 `dnf` 与联网命令中传入该代理；无代理时跳过证书挂载与更新，也不注入代理。

下面是同时满足上述条件时的容器启动与初始化命令形态；无对应条件时去掉相应的 `--mount` 和 `update-ca-trust` 命令：

```bash
docker run --detach --name "${LLAMA_CPP_CONTAINER_NAME}" \
  --label "boostkit.llama-cpp.run-id=${PERF_RUN_ID}" \
  --network=host \
  --ulimit nofile=65535:65535 \
  --user "$(id -u):$(id -g)" \
  -e "HOME=${PERF_WORK_DIR}/home" \
  -e "XDG_CACHE_HOME=${PERF_WORK_DIR}/home/.cache" \
  -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount "type=bind,source=${LLAMA_CPP_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly" \
  --mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly \
  --mount "type=bind,source=${LLAMA_CPP_OFFLINE_DIR},target=${LLAMA_CPP_OFFLINE_DIR},readonly" \
  "${LLAMA_CPP_CONTAINER_IMAGE}" sleep infinity

# 仅设置 PERF_PROXY 时执行：
docker exec --user 0 "${LLAMA_CPP_CONTAINER_NAME}" update-ca-trust extract

# 仅容器内存在 /etc/yum.repos.d/openEuler.repo 时执行：
docker exec --user 0 "${LLAMA_CPP_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
```

随后用 `docker exec --user 0` 在容器内安装编译依赖，再用 `docker exec`（以 Runner UID/GID 及私有 `HOME`/`XDG_CACHE_HOME`/`TMPDIR`）在容器内完成源码检出、编译与校验。基础版的关键命令形态如下，均在私有容器中执行：

```bash
# 容器内以 root 安装依赖（设置 PERF_PROXY 时为 dnf 追加 --setopt=proxy="${PERF_PROXY}"）
dnf install -y gcc gcc-c++ libgomp cmake ninja-build git curl ca-certificates tar gzip xz

# 以下均在容器内以 Runner UID/GID 执行：
gcc --version && g++ --version && cmake --version && ninja --version && git --version

# 优先从离线镜像克隆（存在且含提交 3ac67535c86 时），否则克隆 GitHub 上游
git clone --no-checkout https://github.com/ggml-org/llama.cpp.git "${PERF_WORK_DIR}/llama.cpp-3ac67535c86"
git -C "${PERF_WORK_DIR}/llama.cpp-3ac67535c86" checkout --detach 3ac67535c86
git -C "${PERF_WORK_DIR}/llama.cpp-3ac67535c86" diff --quiet
git -C "${PERF_WORK_DIR}/llama.cpp-3ac67535c86" rev-parse HEAD > "${RESULTS_DIR}/source-commit.txt"

env CFLAGS="-O3 -funroll-loops" CXXFLAGS="-O3 -funroll-loops" \
  cmake -S "${PERF_WORK_DIR}/llama.cpp-3ac67535c86" -B "${PERF_WORK_DIR}/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_CURL=OFF \
  -DGGML_CCACHE=OFF
cmake --build "${PERF_WORK_DIR}/build" \
  --target ggml-cpu llama-embedding llama-bench llama-server -j "$(nproc)"

ldd "${PERF_WORK_DIR}/build/bin/llama-bench"
ldd "${PERF_WORK_DIR}/build/bin/llama-server"
ldd "${PERF_WORK_DIR}/build/bin/llama-embedding"
"${PERF_WORK_DIR}/build/bin/llama-bench" --help >/dev/null
"${PERF_WORK_DIR}/build/bin/llama-server" --version > "${RESULTS_DIR}/binary-version.txt" 2>&1
```

脚本会记录编译器版本到 `${RESULTS_DIR}/toolchain-versions.txt`，核对 `git rev-parse HEAD` 前缀为 `3ac67535c86` 且无未提交修改；构建后检查三个可执行文件的 `ldd` 无 `not found`、`llama-bench --help` 可运行，并从 `llama-server --version` 的 `version: <build_number> (<short_commit>)` 中解析二进制内置提交号，确认其为 `3ac67535c86` 及 `source-commit.txt` 的前缀后，才将 `3ac67535c86` 写入 `${PERF_ACTUAL_VERSION_FILE}`；随后 `dispatch.sh` 写出 `${RESULTS_DIR}/build_variant.json`。

`start` 与 `test` 阶段仅复用该容器（通过 `docker inspect` 同时校验 `State.Running == true` 与 `boostkit.llama-cpp.run-id == ${PERF_RUN_ID}`），不会重新 `docker load`、`docker run` 或重编译。`stop` 阶段（含失败与中断路径）先核对 `boostkit.llama-cpp.run-id` 标签一致，在删除前将 `docker logs "${LLAMA_CPP_CONTAINER_NAME}"` 保存至 `${RESULTS_DIR}/container.log`，再执行 `docker stop --time 30` 与 `docker rm`；容器不存在时安全返回 0，标签不匹配时拒绝删除，不触碰 `${RESULTS_DIR}` 或共享离线目录。

## 数据准备与测试

模型文件优先从 `/home/runner/software/llama-cpp/bge-m3-q8_0.gguf` 读取，并校验 SHA-256（`aa473d51f451a22f0fcf39ba3330c14bed38a385712b1113440f69df4047a173`）与 4 字节 `GGUF` 文件头；通过后再经 `.part` 临时文件原子复制到 `${PERF_WORK_DIR}/models/bge-m3-q8_0.gguf`。本地模型缺失或校验失败时，才从 `${LLAMA_CPP_MODEL_URL}`（默认 `https://huggingface.co/ggml-org/bge-m3-Q8_0-GGUF/resolve/main/bge-m3-q8_0.gguf`）下载到 `.part` 并校验通过后落盘；校验失败或下载失败时立即删除 `.part`，不留半成品。

`start` 阶段（无常驻服务）在复用容器内检查 `llama-bench --help` 可执行，并完成上述模型准备与容器内可读检查（`test -r "${LLAMA_CPP_MODEL_PATH}"`）。

`test` 阶段在同一私有容器内执行正式测试，标准输出完整保存为 `${RESULTS_DIR}/benchmark_llama_bench.json`，标准错误（含 `--progress` 实时进度与告警）通过 `tee` 完整保存为 `${RESULTS_DIR}/benchmark_llama_bench.log`，并以 `PIPESTATUS[0]` 保留 `llama-bench` 原始退出码：

```bash
{
  docker exec \
    -e "HOME=${PERF_WORK_DIR}/home" \
    -e "XDG_CACHE_HOME=${PERF_WORK_DIR}/home/.cache" \
    -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
    "${LLAMA_CPP_CONTAINER_NAME}" \
    env OMP_NUM_THREADS=1 "${PERF_WORK_DIR}/build/bin/llama-bench" \
    -m "${PERF_WORK_DIR}/models/bge-m3-q8_0.gguf" \
    -p 512 -b 512 -n 0 -t 1 -r 5 \
    --progress -o json \
    > "${RESULTS_DIR}/benchmark_llama_bench.json"
} 2>&1 | tee "${RESULTS_DIR}/benchmark_llama_bench.log"

python3 software/AI/llama-cpp/scripts/results/parse_benchmark.py \
  "${RESULTS_DIR}/benchmark_llama_bench.json" \
  "${RESULTS_DIR}/benchmark_llama_cpp.json" \
  --model-sha256 "${MODEL_SHA256}" \
  --expected-commit 3ac67535c86
```

上游 `llama-bench` 在正式采样前自动执行 1 次 `pp512` 预热（不计入结果），随后执行 `-r 5` 轮正式计时并输出 5 次采样（`samples_ns`、`samples_ts`）及均值/标准差。

### 与参考指导的差异

本用例参考了 `boostkit/llama-CPP`（`opt` 分支 `docs/zh/user_guide.md` 与 `bench_bgem3_full.py`），差异如下：

| 差异 | 当前做法与原因 |
|---|---|
| 源码与补丁 | 原指导面向鲲鹏调优合入 `patch/0001..0011` 与 `compile.sh`，并在精度基线中应用 `baseline-bug-fixed.patch`；本基础版固定上游 `ggml-org/llama.cpp` 提交 `3ac67535c86`，不打任何补丁，严格评测纯上游原版行为。 |
| 编译参数 | 沿用原指导基线编译的 `CFLAGS/CXXFLAGS="-O3 -funroll-loops"`、`-DCMAKE_BUILD_TYPE=Release`、`-GNinja`、`-DLLAMA_CURL=OFF`、`-DGGML_CCACHE=OFF`，并在容器内按 `-j "$(nproc)"` 构建；不添加 ARM 专用 `-march` 或 `-DGGML_USE_FUSED_CPP_SDPA`。 |
| 测试模型 | `user_guide.md` 文本写 `bge-m3-FP16.gguf`，而同分支 `bench_bgem3_full.py` 实际配置 `bge-m3-q8_0.gguf`；按确认口径统一采用官方 `ggml-org/bge-m3-Q8_0-GGUF` 的 `bge-m3-q8_0.gguf` 并锁定 SHA-256。 |
| 单核测试参数 | 去掉原指导中的 `taskset -c 128`（硬编码核号不跨架构通用）以及调优专用变量 `GGML_FUSED_CPP_SDPA=1`、`GGML_TOTAL_THREADS=1`；将 `-r 1` 改为上游默认 `-r 5` 降低单轮抖动，并启用 `--progress -o json` 供严格解析。 |
| 整机压测与精度脚本 | `bench_bgem3_full.py` 硬编码 192 物理核偶数核、`LD_PRELOAD=/usr/local/lib/libjemalloc.so.2`、`pkill -9` 及多达 192 个 server 实例，无法跨架构配对；`eval_llamacpp_cmteb.py` 属于调优精度验证，均不纳入本基础版用例。 |
| 执行环境 | 全程在本次任务的私有 openEuler 24.03 LTS SP4 容器内构建与测试，隔离两台 Runner 宿主机环境。 |

## 结果与报告

| 结果 | 位置 | 用途 |
|---|---|---|
| 构建变体 | `${RESULTS_DIR}/build_variant.json` | 记录 `variant` 与 `parameters.variant`（`base`） |
| 版本与工具链记录 | `${RESULTS_DIR}/source-commit.txt`、`${RESULTS_DIR}/binary-version.txt`、`${RESULTS_DIR}/toolchain-versions.txt` | 留存完整提交号、二进制自报版本与容器编译器版本 |
| 上游原始 JSON | `${RESULTS_DIR}/benchmark_llama_bench.json` | 保留 `llama-bench -o json` 的完整标准输出 |
| 进度与 stderr 日志 | `${RESULTS_DIR}/benchmark_llama_bench.log` | 保留 `--progress` 实时进度及告警输出 |
| 归一化指标 | `${RESULTS_DIR}/benchmark_llama_cpp.json` | 4 条指标、`parameters` 与 `runtime_context`，供 Framework 单架构和跨架构报告读取 |
| 容器日志 | `${RESULTS_DIR}/container.log` | `stop` 阶段删除容器前保存的 `docker logs` |

原始输出字段盘点与指标映射（分组统一为 `pp512,b512,t1`）：

| 原始字段 | 处理方式 | 归一化指标 / 存储位置 | 单位 | 方向 | 依据 |
|---|---|---|---|---|---|
| `avg_ts` | 纳入指标 | `pp512,b512,t1/prompt_throughput` | `tokens/s` | `higher_is_better` | 直接提取 |
| `stddev_ts` | 纳入指标 | `pp512,b512,t1/prompt_throughput_stddev` | `tokens/s` | `neutral` | 直接提取，反映 5 轮波动 |
| `avg_ns` | 纳入指标 | `pp512,b512,t1/avg_latency_ms` | `ms` | `lower_is_better` | `avg_ns / 1e6`（纳秒转毫秒） |
| `stddev_ns` | 纳入指标 | `pp512,b512,t1/latency_stddev_ms` | `ms` | `neutral` | `stddev_ns / 1e6`（纳秒转毫秒） |
| `model_type`、`model_size`、`model_n_params`、`backends`、`n_prompt`、`n_gen`、`n_depth`、`n_batch`、`n_ubatch`、`n_threads`、`flash_attn`、`embeddings`、`use_mmap` | 跨架构固定参数 | `benchmark_llama_cpp.json` 的 `parameters` | — | — | 另记录 `model_name`、`model_sha256`、`omp_num_threads=1`、`repetitions=5`，两架构须完全一致 |
| `build_commit`、`build_number`、`cpu_info`、`gpu_info`、`model_filename`、`test_time`、`samples_ns`、`samples_ts` | 仅保留运行上下文 | `benchmark_llama_cpp.json` 的 `runtime_context` | — | — | 机器或运行实例相关字段，不进入 `parameters` |
| `cpu_mask`、`cpu_strict`、`poll`、`type_k`、`type_v`、`n_gpu_layers`、`split_mode`、`main_gpu`、`no_kv_offload`、`tensor_split`、`tensor_buft_overrides`、`defrag_thold`、`no_op_offload` | 仅保留原始数据 | `benchmark_llama_bench.json` | — | — | 默认配置或 GPU 字段，不作为 CPU 性能指标 |

解析器严格校验：输出数组恰好 1 条、`build_commit` 匹配 `3ac67535c86`、全部负载参数与预期一致、`samples_ns`/`samples_ts` 恰好 5 个正有限值且均值与采样均值偏差不超过 1%；任一校验不通过即返回非零，不会将不完整或异常数据标为成功。

## 独立执行

在仓库根目录运行；Runner 需具备 Docker 权限并保留足够磁盘空间（模型约 605 MiB，源码与构建约 1.5 GiB）：

```bash
bash software/AI/llama-cpp/llama-cpp_test.sh \
  --version 3ac67535c86 --variant base \
  --results-dir /home/runner/llama-cpp-results/3ac67535c86
```

独立入口依次执行构建、检查、测试、停止容器（失败或中断时同样通过 `EXIT` trap 调用 `stop` 收口），并在结果目录写出 `results.json`、`status.json` 和 `report.md`。数据与构建目录默认位于 `/home/runner/boostkit-perf/llama-cpp/local-<运行 ID>/`；正常结束后仅清理本次自行创建的私有目录，需要保留排障时添加 `--keep-workdir`。Framework 分阶段调用或调用者显式传入 `PERF_WORK_DIR` 时，脚本不会删除该目录。

> **当前验证状态**：本用例已完成第 1 层静态接线、解析器、容器契约单测与双架构对比预检；**真实 openEuler 24.03 LTS SP4 容器内构建、同一容器跨阶段复用、Runner 清理权限以及 x86_64 / aarch64 正式端到端测试尚未在目标 Runner 上执行**。
