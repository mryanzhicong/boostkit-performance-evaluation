# uavs3d 1.2 解码性能测试

本用例在 x86_64、aarch64 上分别构建未经修改的上游 uavs3d 1.2 和输入编码器
uavs3e 1.3，使用 [Test/uavs3d](https://gitcode.com/weixin_51237760/tasks/tree/main/Test/uavs3d)
规定的 Film2012、8-bit、QP32 数据，测量 16/24 帧级线程下解码 120 帧的
毫秒/帧。构建、输入生成和正式测试都在本次任务的 openEuler 24.03 LTS SP4
私有容器内执行。核对的参考仓库提交为
`21154155f56328b708e2c78f4ce6bac08101fe68`。

软件入口为 `uavs3d_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、
测试和停止函数；独立入口调用同一组函数。`scripts/builders/base.sh` 完成基础版
构建，`scripts/stages/` 负责容器校验、输入准备、正式测试和清理，
`scripts/results/` 负责原始证据与指标转换。`optimized` 构建入口尚未实现，
选中后在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 预置归档（Runner 上的文件） | 解包/构建位置 |
|---|---|---|---|
| uavs3d | [上游 1.2 源码归档](https://github.com/uavs3/uavs3d/tree/1.2)，SHA-256 `faa1f1f8…5b157` | `/home/runner/software/uavs3d/uavs3d-1.2.tar.gz` | `${PERF_WORK_DIR}/sources/uavs3d-1.2` |
| uavs3e | [上游 v1.3 源码归档](https://github.com/uavs3/uavs3e/tree/v1.3)，SHA-256 `4c69ba57…10fc8` | `/home/runner/software/uavs3d/uavs3e-1.3.tar.gz` | `${PERF_WORK_DIR}/sources/uavs3e-1.3` |
| 基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz` 及同名 `.sha256sum` | `docker load` 后的镜像 |
| 测试输入 | `Film2012_1920x1080_25_8bit_8Mbps.yuv` | `/home/runner/software/uavs3d/video/Film2012_1920x1080_25_8bit_8Mbps.yuv` | 容器内同绝对路径 |
| 输入编码器 | 随 uavs3e 构建 | — | `${PERF_WORK_DIR}/sources/uavs3e-1.3/build/uavs3enc` |

两个源码归档优先从 `/home/runner/software/uavs3d/` 读取
`uavs3d-1.2.tar.gz`、`uavs3e-1.3.tar.gz`；缺失时从对应的 codeload 地址下载
到 `${PERF_WORK_DIR}`。无论来源都校验上表固定的 SHA-256，校验失败立即停止。
归档是 Runner 上的输入文件，不在 Git 仓库中；上表最后一列是解包后的源码/构建
位置，不是归档文件本身。可用 `UAVS3D_ARCHIVE_DIR` 指定其他预置目录。

## 容器与构建

脚本先检查 Docker daemon。镜像归档和同名 `.sha256sum` 优先取
`/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时才下载；随后校验
SHA-256、`docker load`，并核对镜像架构和容器内 `/etc/os-release`。开发环境可用
`UAVS3D_CONTAINER_IMAGE=<已有镜像>` 指定一个已加载镜像，脚本仍会核对架构和
openEuler 24.03 LTS SP4 版本。

每次运行创建一个带任务标签的容器，名称为
`boostkit-uavs3d-<架构>-<运行 ID>`，标签为
`boostkit.uavs3d.run-id=<运行 ID>`。容器使用宿主网络，不绑核、不限制
CPU/内存/NUMA；工作目录、结果目录、只读的用例脚本目录以及视频目录（存在时）
挂载到容器内相同绝对路径：

```bash
docker run --detach --name "${UAVS3D_CONTAINER_NAME}" \
  --label "boostkit.uavs3d.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${UAVS3D_VIDEO_DIR},target=${UAVS3D_VIDEO_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${UAVS3D_CONTAINER_IMAGE}" sleep infinity
```

正式工作流设置 `PERF_PROXY` 时，脚本把 `/home/runner/software/anchors/`
只读挂到容器 CA 目录并执行 `update-ca-trust extract`，只在本次容器内把
openEuler 仓库地址换成 `repo.huaweicloud.com/openeuler`，再用 `dnf` 安装
`gcc gcc-c++ make cmake python3 gawk tar gzip xz`。没有代理时不挂载证书目录，
也不执行证书更新；容器内仓库地址仍按上述镜像策略替换。

两个软件在容器内使用与参考脚本相同的配置构建：

```bash
cmake -S <源码目录> -B <源码目录>/build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -ffp-contract=off"
cmake --build <源码目录>/build --parallel 8
```

不修改源码、不打算法补丁、不使用 OpenMP，保留上游 x86 SSE4/AVX2 与
aarch64 NEON SIMD。构建完成后在容器内运行 `uavs3dec -v 1`，把实际报告的
`1.2.x` 归一到 `1.2` 并写入 `PERF_ACTUAL_VERSION_FILE`；声明版本、实际版本
和 Framework 请求版本必须一致。

## 数据与运行顺序

两台 Runner 必须预置同一份 1920×1080、8-bit YUV420P、25 fps 的素材，至少
包含 120 个完整帧（≥ 373,248,000 字节）：

```text
/home/runner/software/uavs3d/video/Film2012_1920x1080_25_8bit_8Mbps.yuv
```

脚本不生成或下载该素材。源文件 SHA-256 会写入结果 `parameters`，跨架构比较
要求内容一致。开发时可把测试文件放在其他目录并用 `--video-dir` 或
`UAVS3D_VIDEO_DIR` 指定；正式流水线使用上述默认路径。

1. `build`：准备镜像、创建唯一容器、安装依赖、在容器内构建 uavs3d 和 uavs3e。
2. `start`：校验两个可执行文件、素材长度；在容器内用 uavs3e 把前 120 帧编码为
   `Film2012_1080p_q32.avs3`，并记录源文件和码流的 SHA-256。编码不计时，
   首次可能较久；同一任务内已存在且校验通过的码流直接复用。
3. `test`：重新校验输入后，对 16、24 两个线程档各做 1 次预热解码，确认输出
   恰好为 120 帧（373,248,000 字节）并记录输出 SHA-256；随后各计时 20 次。
4. `stop`：保存容器日志，只停止并删除带本次任务标签的容器。

输入编码固定使用 8 线程（`--wpp_threads 4 --frm_threads 2`），完整命令为：

```bash
uavs3enc -i <Film2012.yuv> -o <output.avs3> -w 1920 -h 1080 -d 8 \
  --fps_num 25 --fps_den 1 -f 120 -q 32 -g 7 -p 0 \
  --speed_level 4 --wpp_threads 4 --frm_threads 2 -s 1 -v 0
```

预热的解码命令为 `uavs3dec -i <stream> -o <output.yuv> -t <16|24> -l 2 -s 1`；
正式计时把输出改为 `/dev/null`，日志级别改为 `1`、关闭 MD5 检查：

```bash
uavs3dec -i <stream> -o /dev/null -t <16|24> -l 1 -s 0
```

计时口径与参考脚本一致：从启动解码进程到进程退出（含读取、解码和输出），
用完整命令耗时除以 120 帧得到 `ms/frame`，每个线程档取 20 次样本的算术平均。
不设置 CPU 亲和性或 NUMA 绑定，由操作系统调度；两架构使用相同的线程数、
码流参数和轮次。

## 指标与产物

| 场景 | 指标 | 来源 | 单位 | 方向 | 分组 |
|---|---|---|---|---|---|
| Film2012，16 帧级线程 | 每帧解码耗时 | 20 次计时的平均值 | ms/frame | 越小越好 | 16 threads |
| Film2012，24 帧级线程 | 每帧解码耗时 | 20 次计时的平均值 | ms/frame | 越小越好 | 24 threads |

共两个指标。24 线程档允许超过宿主机核数，这是参考脚本的固定负载，不是
机器相关参数；实际核数只记录在结果 `runtime_context`，不参与跨架构配对。
每个线程档恰好需要 1 次预热和 20 次正式计时；缺失场景、样本数不足、
非有限或非正数值、码流/输出校验不一致、CSV 与原始证据不符都会让测试失败。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 正式测试的完整控制台输出 |
| `result_bench-uavs3d.csv` | 与参考脚本相同的 `scenario,frames,ms_per_frame,status` 两行结果 |
| `decode_evidence/c16/`、`c24/` | 每个场景的预热/计时日志、命令、输出 SHA-256 和样本 |
| `decode_evidence/evidence.json` | 输入清单、参数、两次场景证据和运行环境 |
| `input_prepare.log` | uavs3e 生成输入码流的日志（仅首次生成时） |
| `benchmark_uavs3d.json` | 经 CSV 与证据校验后供 Framework 读取的两个指标及负载参数 |
| `container_runtime.log` | 停止阶段保存的容器日志 |

指标盘点：每个场景纳入报告的是 20 次样本的算术平均 `ms_per_frame`；
20 个原始样本、中位数、最小值、最大值、样本标准差、预热耗时、命令和
输入/输出 SHA-256 仅保留在 `decode_evidence/`，不另列为对比指标；
输入编码耗时和预热耗时不计入正式指标；实际核数、CPU 型号和生成码流的
SHA-256 只写入 `runtime_context`，不参与跨架构负载配对。

预热产生的解码 YUV 只写入本次任务私有目录，校验后删除；正式计时的解码输出
直接写入 `/dev/null`。结果目录只保留文本、JSON 和日志。

脱离 Workflow 执行完整流程：

```bash
bash software/Media/uavs3d/uavs3d_test.sh \
  --version 1.2 \
  --variant base \
  --results-dir /home/runner/uavs3d-results/1.2
```

素材不在默认目录时可加：

```bash
bash software/Media/uavs3d/uavs3d_test.sh --version 1.2 \
  --video-dir /path/to/uavs3d-video \
  --results-dir /home/runner/uavs3d-results/1.2
```

独立运行默认清理自身创建的私有工作目录；需要保留现场时加 `--keep-workdir`。
Framework 分阶段运行时，输出写入传入的 `RESULTS_DIR`，源码、构建产物、码流和
预热输出写入传入的 `PERF_WORK_DIR`。

## 与参考脚本的差异

- 参考脚本在宿主机直接安装依赖并构建；本用例把依赖、两个软件的构建、输入
  编码和全部解码计时放进同一个私有容器，宿主机只执行 Docker、下载和解析。
- 参考脚本使用 `/home/test/Test/video`；本用例按 Runner 约定读取
  `/home/runner/software/uavs3d/video`，并允许开发时用环境变量或
  `--video-dir` 覆盖。
- 参考脚本把源码和码流放在脚本目录并跨次复用；本用例使用每次任务独立的
  私有目录，避免不同任务或架构互相污染。输入编码参数和计时口径不变。
- 参考脚本以 root 运行；本用例的普通构建和测试使用 Runner 的 UID/GID，
  只有安装容器内 RPM 时使用容器 root，避免在挂载目录留下无法清理的 root 文件。
- 参考脚本直接打印 CSV；本用例除保留同一 CSV 外，还保存每个场景的命令、
  日志和输出校验值，并由独立解析器核对后生成 Framework 指标。
