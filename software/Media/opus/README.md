# Opus 1.6.1 定点编码性能测试

本用例从 Xiph 官方源码构建 **非默认的 fixed-point Opus 1.6.1**，对官方真实语音
`speech_orig.wav` 的前 10.8 秒执行 20ms 音频帧编码。源码、构建和测试均在本次任务
的私有目录内，不替换系统 Opus，不绑核，单线程，不使用 OpenMP。

参考脚本 `run_bench.sh`、`build_install.sh`、`bench.py`、`bootstrap_env.sh`
**逐字复制**在 `scripts/reference/`。构建阶段直接调用原 `build_install.sh`；
测试阶段直接调用原 `run_bench.sh`，由它调用原 `build_install.sh` 和原 `bench.py`。
`scripts/stages/` 只负责容器、路径、结果搬运和校验；`optimized` 未实现，选择后失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| Opus | [Xiph Opus 1.6.1 源码](https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz)，SHA-256 `6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1` | `${PERF_WORK_DIR}/opus-1.6.1.tar.gz`、`opus-1.6.1` |
| 语音 | [`speech_orig.wav`](https://media.xiph.org/opus/samples/examples/speech_orig.wav)，48kHz 单声道 16-bit，10.8 秒，SHA-256 `625ae47a791214ca5cef9927ac51ea085158a5ca1e3cc77db019b15579d63aa5` | 优先 `/home/runner/software/opus/audio/speech_orig.wav`；缺失时原 `bench.py` 从 Xiph 下载 |
| 构建依赖 | GCC/G++、Make、CMake、Python 3、curl、tar | 缺失时在容器内用 `dnf` 安装 |
| 容器基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 优先 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载 |

源码优先读取 `/home/runner/software/opus/opus-1.6.1.tar.gz`；缺失时由原
`build_install.sh` 从官方地址下载。原脚本继续校验上表 SHA-256。

## 容器

每次运行创建一个带任务标签的容器，名称为
`boostkit-opus-<架构>-<运行 ID>`。容器使用宿主网络，不绑核、不限制 CPU/内存/NUMA，
普通构建和测试使用 Runner UID/GID：

```bash
docker run --detach --name "${OPUS_CONTAINER_NAME}" \
  --label "boostkit.opus.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${OPUS_CONTAINER_IMAGE}" sleep infinity
```

镜像归档优先取公共目录，缺失时下载；校验 SHA-256、`docker load` 后核对架构和
openEuler 24.03 LTS SP4 版本。设置 `PERF_PROXY` 时额外挂载 CA anchors 并执行
`update-ca-trust extract`，只在本次容器内切换 openEuler 仓库镜像。停止阶段只删除
带本次任务标签的容器。

## 构建

原脚本复制到私有工作目录，保持原布局：

```text
${PERF_WORK_DIR}/scripts/{run_bench.sh,build_install.sh,bench.py,bootstrap_env.sh}
${PERF_WORK_DIR}/opus-1.6.1.tar.gz
${PERF_WORK_DIR}/opus-1.6.1/build-fixed-auto/
```

构建阶段直接调用原 `build_install.sh`：

```bash
export BENCH_ENV_READY="${PERF_WORK_DIR}/scripts"
bash "${PERF_WORK_DIR}/scripts/build_install.sh"
```

`BENCH_ENV_READY` 让原 `bootstrap_env.sh` 跳过依赖自安装；GCC、Make、CMake 等已由
容器内 `dnf` 安装。原脚本仍执行自己的 configure、`make -j8`、`make -j8 check`、
`.bench-ready` 缓存和 `FIXED_POINT` 检查。configure 参数：

```text
--enable-fixed-point --enable-shared --enable-extra-programs --disable-doc
CFLAGS="-O3 -ffp-contract=off"
```

构建后检查 `${PERF_WORK_DIR}/opus-1.6.1/build-fixed-auto/.libs/opus_demo` 可执行。

## 数据与运行顺序

官方语音文件优先放在：

```text
/home/runner/software/opus/audio/speech_orig.wav
```

下载并校验：

```bash
mkdir -p /home/runner/software/opus/audio
curl -fL --retry 3 \
  https://media.xiph.org/opus/samples/examples/speech_orig.wav \
  -o /home/runner/software/opus/audio/speech_orig.wav

printf '%s  %s\n' \
  625ae47a791214ca5cef9927ac51ea085158a5ca1e3cc77db019b15579d63aa5 \
  /home/runner/software/opus/audio/speech_orig.wav | sha256sum -c -
```

文件大小 `1,036,844` 字节，48kHz、单声道、16-bit PCM、518400 帧（10.8 秒）。

构建阶段会复制到 `${PERF_WORK_DIR}/scripts/.work/audio/speech_orig.wav`，原
`bench.py` 就不再联网下载。文件必须为 48kHz、单声道、16-bit PCM，至少 10.8 秒。

测试阶段直接调用原 `run_bench.sh`：

```bash
export BENCH_ENV_READY="${PERF_WORK_DIR}/scripts"
bash "${PERF_WORK_DIR}/scripts/run_bench.sh"
```

原 `run_bench.sh` 先调用原 `build_install.sh`（`.bench-ready` 命中时跳过构建），再
调用原 `bench.py`。`bench.py` 对以下 3 个场景各做 1 次预热 + 20 次完整编码：

| 场景 | 码率 | complexity |
|---|---:|---:|
| `speech_orig_16000_complexity5` | 16 kbps | 5 |
| `speech_orig_16000_complexity10` | 16 kbps | 10 |
| `speech_orig_24000_complexity10` | 24 kbps | 10 |

固定 `voip`、48kHz、单声道、20ms 帧；完整编码命令耗时除以 10.8 秒音频，取 20 次
**算术平均**。编码后的解码检查和时长检查不计时；不设置 CPU 亲和性，
`OMP_NUM_THREADS=1`，单线程。

## 指标与产物

3 项指标，单位 `ms/audio second`，方向 `lower_is_better`，分组 `opus`，子组：

| 场景 | 子组 |
|---|---|
| `speech_orig_16000_complexity5` | `16kbps_c5` |
| `speech_orig_16000_complexity10` | `16kbps_c10` |
| `speech_orig_24000_complexity10` | `24kbps_c10` |

每项必须 20 个样本，CSV 值为样本算术平均；缺场景、FAIL、样本数不足、非正/
非有限值、CSV 与证据不符、输入/编码/解码 SHA 异常、解码帧数不符都会让测试失败。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 原 `run_bench.sh` 完整输出 |
| `result_bench-opus.csv` | 原脚本 CSV（3 行，`scenario,iterations,ms_per_audio_second,status`） |
| `benchmark_evidence/evidence.json` | 原 `bench.py` 的样本、输入/编码/解码 SHA、命令 |
| `benchmark_opus.json` | Framework 归一化指标 |
| `container_runtime.log` | 停止阶段保存的容器日志 |

脱离 Workflow 执行完整流程：

```bash
bash software/Media/opus/opus_test.sh \
  --version 1.6.1 \
  --variant base \
  --results-dir /home/runner/opus-results/1.6.1
```

音频不在默认目录时可设置 `OPUS_AUDIO_FILE`；独立运行默认清理私有工作目录，需要
保留现场时加 `--keep-workdir`。
