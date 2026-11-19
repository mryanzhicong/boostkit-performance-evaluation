# FFmpeg 7.1.1 1080p→640×360 RGB24 缩放性能测试

本用例在 x86_64、aarch64 上分别从 GNU 官方源码构建 FFmpeg 7.1.1，对三段
1920×1080、8-bit YUV420P 视频的前 30 帧执行 `scale=640:360:flags=bilinear+accurate_rnd+bitexact`
和 YUV420P→RGB24 转换。源码、构建和安装均在本次任务的私有目录内，不替换系统
FFmpeg，不绑核，编码/解码/滤镜线程均为 1。

软件入口为 `ffmpeg_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、测试
和停止函数；`scripts/builders/base.sh` 负责容器、依赖和源码构建，
`scripts/stages/` 负责运行检查与正式测试，`scripts/results/` 负责执行和解析。
`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| FFmpeg | [GNU FFmpeg 7.1.1 官方源码包](https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.gz)，SHA-256 `9a6e57a446b671012612aaeb9df5126794d5ac8f2015ca220934f99a6a4e0601` | `${PERF_WORK_DIR}/ffmpeg-src`、`ffmpeg-install` |
| 构建依赖 | GCC、Make、Python 3、pkg-config、curl、tar；x86_64 额外需要 NASM | 缺失时在容器内用 `dnf` 安装 |
| 容器基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 优先 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载 |
| 输入视频 | BQTerrace、Film2012、messi | `/home/runner/software/ffmpeg/video/`，缺失时回退 x264/Test 视频目录 |

源码归档优先读取 `/home/runner/software/ffmpeg/ffmpeg-7.1.1.tar.gz`；缺失时从
官方地址下载到 `${PERF_WORK_DIR}`。两种来源都校验上表 SHA-256。

## 容器

每次运行创建一个带任务标签的容器，名称为
`boostkit-ffmpeg-<架构>-<运行 ID>`。容器使用宿主网络，不绑核、不限制 CPU/内存/NUMA，
普通构建和测试使用 Runner UID/GID：

```bash
docker run --detach --name "${FFMPEG_CONTAINER_NAME}" \
  --label "boostkit.ffmpeg.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${FFMPEG_VIDEO_DIR},target=${FFMPEG_VIDEO_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${FFMPEG_CONTAINER_IMAGE}" sleep infinity
```

镜像归档优先取公共目录，缺失时下载；校验 SHA-256、`docker load` 后核对架构和
openEuler 24.03 LTS SP4 版本。设置 `PERF_PROXY` 时额外挂载 CA anchors 并执行
`update-ca-trust extract`，只在本次容器内切换 openEuler 仓库镜像。停止阶段只删除
带本次任务标签的容器。

## 构建

容器内安装缺失依赖后执行：

```bash
cd "${PERF_WORK_DIR}/ffmpeg-src"
./configure --prefix="${PERF_WORK_DIR}/ffmpeg-install" \
  --enable-shared --disable-debug --disable-doc \
  --disable-autodetect --disable-everything \
  --enable-ffmpeg --enable-ffprobe \
  --enable-protocol=file,pipe --enable-demuxer=rawvideo \
  --enable-decoder=rawvideo --enable-encoder=rawvideo \
  --enable-muxer=rawvideo,hash \
  --enable-filter=scale,format,null,psnr,setpts --enable-swscale \
  --extra-cflags="-O3 -ffp-contract=off" \
  --extra-ldflags="-Wl,-O3"
make -j8
make install
```

构建后检查 `${PERF_WORK_DIR}/ffmpeg-install/bin/ffmpeg` 可执行，并把实际
`ffmpeg -version` 首行写入日志。只构建本用例需要的组件，保留原生 SIMD，不修改源码。

## 数据与运行顺序

两台 Runner 在以下目录预置素材，至少包含 30 帧：

```text
/home/runner/software/ffmpeg/video/BQTerrace_1920x1080_60-dianbo.yuv
/home/runner/software/ffmpeg/video/Film2012_1920x1080_25_8bit_8Mbps.yuv
/home/runner/software/ffmpeg/video/messi_1920x1080_25_1000.yuv
```

| 文件 | SHA-256 |
|---|---|
| `BQTerrace_1920x1080_60-dianbo.yuv` | `5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7` |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | `27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc` |
| `messi_1920x1080_25_1000.yuv` | `1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b` |

测试阶段把每个视频前 30 帧复制到私有工作目录，然后对每个视频执行：

```bash
"${PERF_WORK_DIR}/ffmpeg-install/bin/ffmpeg" \
  -v error -nostdin -y -threads 1 -filter_threads 1 \
  -f rawvideo -pixel_format yuv420p -video_size 1920x1080 -framerate <fps> \
  -i "<视频前30帧>" \
  -vf "scale=640:360:flags=bilinear+accurate_rnd+bitexact" \
  -frames:v 30 -threads 1 -c:v rawvideo -pix_fmt rgb24 \
  -f rawvideo <输出>
```

- 先做 1 次预热，输出到私有文件，检查大小是否为 `640×360×30×3` 字节；该检查不计时。
- 再执行 20 次，输出到 `/dev/null`，用完整命令耗时除以 30 帧后取中位数。
- 包含进程启动、读文件、缩放和颜色转换，不包含输出尺寸检查。
- 不设置 CPU 亲和性；`OMP_NUM_THREADS=1`、`OMP_THREAD_LIMIT=1`。

## 指标与产物

每个视频一项，共 3 项，单位 `ms/frame`，方向 `lower_is_better`：

| 视频 | 场景 |
|---|---|
| BQTerrace | `BQTerrace_640x360_rgb24` |
| Film2012 | `Film2012_640x360_rgb24` |
| messi | `messi_640x360_rgb24` |

报告按 `ffmpeg` 分组、视频作为子组。每项必须 20 个样本，CSV 值为样本中位数；
缺场景、FAIL、样本数不足、非正/非有限值、CSV 与证据不符、输入/输出 SHA 异常、
输出尺寸不符都会让测试失败。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 正式测试完整控制台输出 |
| `result_bench-ffmpeg.csv` | 3 行参考格式 CSV（`scenario,frames,ms_per_frame,status`） |
| `benchmark_evidence/evidence.json` | 20 个样本、输入/输出 SHA、命令、输出尺寸 |
| `benchmark_ffmpeg.json` | Framework 归一化指标 |
| `container_runtime.log` | 停止阶段保存的容器日志 |

脱离 Workflow 执行完整流程：

```bash
bash software/Media/ffmpeg/ffmpeg_test.sh \
  --version 7.1.1 \
  --variant base \
  --results-dir /home/runner/ffmpeg-results/7.1.1
```

素材不在默认目录时可设置 `FFMPEG_VIDEO_DIR`；独立运行默认清理私有工作目录，
需要保留现场时加 `--keep-workdir`。
