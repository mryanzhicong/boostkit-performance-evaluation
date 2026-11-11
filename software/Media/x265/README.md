# x265 4.2 性能测试

本用例在 x86_64、aarch64 上构建未经修改的上游 x265 4.2 和 FFmpeg 7.0.1，
使用 [Test/x265](https://gitcode.com/weixin_51237760/tasks/tree/main/Test/x265)
提供的脚本编码同一段 YUV 视频，对比单路编码帧率。核对的参考仓库提交为
`21154155f56328b708e2c78f4ce6bac08101fe68`。

软件入口为 `x265_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、
测试和停止脚本。基础版构建入口是 `scripts/builders/base.sh`；
`scripts/reference/bench_scene.py` 是原仓库的构建与测试脚本，逐字节保留；
`scripts/reference/run.py` 仅增加 `X265_VIDEO_DIR` 入口，以便在 Runner 上指定视频目录。
构建阶段将两者复制到本次私有工作目录，随后直接执行原脚本。
`scripts/results/parse_reference.py` 只校验、转换原始结果，不执行编码。

工作流可选择 `base` 或 `optimized`，默认 `base`。`optimized` 构建入口目前尚未实现，
选中后会明确失败，不会退回基础版；其余阶段共用 `scripts/stages/` 下的脚本。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| x265 | [上游 x265 4.2 源码归档](https://bitbucket.org/multicoreware/x265_git/downloads) | `${PERF_WORK_DIR}/x265_4.2`；构建后位于私有 `install` 目录 |
| FFmpeg | [上游 FFmpeg 7.0.1 源码归档](https://ffmpeg.org/releases/) | `${PERF_WORK_DIR}/ffmpeg-7.0.1`；构建后位于私有 `install` 目录 |
| 测试脚本 | 参考仓库提交 `21154155f56328b708e2c78f4ce6bac08101fe68` 的 `bench_scene.py`、`run.py` | `${PERF_WORK_DIR}/reference/scripts/` |
| 测试视频 | `BQTerrace_1920x1080_60-dianbo.yuv` | `/home/runner/software/x265/video/` |

此用例在宿主机上构建和测试，不启动容器。源码、编译产物和编码过程文件
保存在本次任务的私有目录；不会向系统目录安装 x265 或 FFmpeg。

## x265 与 FFmpeg 获取、构建

两台 Runner 都要提供同一份视频文件：

```text
/home/runner/software/x265/video/BQTerrace_1920x1080_60-dianbo.yuv
```

视频为 1920×1080、8-bit YUV420P、60 fps，至少包含 600 个完整帧。
脚本不会生成或下载视频。结果会记录视频的 SHA-256；跨架构比较会核对文件内容和测试参数。

源码包优先从 Runner 的 `/home/runner/software/x265/` 读取：

```text
/home/runner/software/x265/x265_4.2.tar.gz
/home/runner/software/x265/ffmpeg-7.0.1.tar.gz
```

任一源码包缺失时，脚本下载对应的上游归档到本次私有目录。
无论从哪里取得，均校验脚本中固定的 SHA-256；校验失败即停止。
缺少构建工具时，通过 `dnf` 安装。x86_64 还要求 NASM 2.13 或更新版本。

构建阶段直接调用复制到私有目录的原 `bench_scene.py build`：

```bash
jobs="$(getconf _NPROCESSORS_ONLN)"
(( jobs <= 16 )) || jobs=16
python3 "${PERF_WORK_DIR}/reference/scripts/bench_scene.py" build \
  --x265-source "${PERF_WORK_DIR}/x265_4.2" \
  --ffmpeg-source "${PERF_WORK_DIR}/ffmpeg-7.0.1" \
  --jobs "${jobs}"
```

原脚本以 Release、静态 8-bit、汇编启用、libnuma 关闭的方式构建 x265，
再以 `--enable-gpl --enable-libx265 --disable-autodetect` 构建 FFmpeg。
实际并行数为 `min(在线 CPU 数, 16)`。构建结束后，适配层将原脚本安装目录
链接为 `${PERF_WORK_DIR}/install`，并校验 x265 版本、FFmpeg 版本和 `libx265` 编码器。

## 数据与运行顺序

1. `build`：取得并校验两份源码归档，调用原脚本构建 x265 和 FFmpeg。
2. `start`：验证私有二进制文件可运行，并检查视频至少有 600 个完整帧。
3. `test`：调用原 `run.py`；先预读输入，再依次编码 CRF 24、CRF 28，每项运行一次。
4. `stop`：无需停止后台服务；独立运行时按选项清理本次私有工作目录。

`test` 阶段执行的入口为：

```bash
X265_VIDEO_DIR=/home/runner/software/x265/video \
  python3 -B "${PERF_WORK_DIR}/reference/scripts/run.py"
```

每项编码取 BQTerrace 的前 600 帧，使用 `medium` 预设，
`-maxrate 6000k -bufsize 12000k`，以及
`pools=16:frame-threads=15:ctu=16:aq-mode=4:bframes=7`。
两架构参数相同，均不绑 CPU 或 NUMA。CRF 24 的编码命令形态如下；第二项只将
`-crf 24` 改为 `-crf 28`：

```bash
ffmpeg -hide_banner -nostdin -loglevel info -n \
  -f rawvideo -pixel_format yuv420p -video_size 1920x1080 -framerate 60 \
  -skip_initial_bytes 0 \
  -i /home/runner/software/x265/video/BQTerrace_1920x1080_60-dianbo.yuv \
  -map 0:v:0 -an -frames:v 600 -c:v libx265 \
  -preset medium -crf 24 -maxrate 6000k -bufsize 12000k \
  -threads:v 0 \
  -x265-params pools=16:frame-threads=15:ctu=16:aq-mode=4:bframes=7 \
  -progress pipe:1 -nostats -f mp4 -movflags +faststart output.mp4
```

原脚本核对 FFmpeg 的完成状态和 600 帧进度，再用 `ffprobe` 检查输出 MP4 的
HEVC 编码、分辨率和帧数。完整编码命令的计时包括进程启动、视频读取、编码和封装；
预读、`ffprobe` 检查与结果转换不计时。

## 指标与产物

| 场景 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| BQTerrace，CRF 24 | 单路编码帧率 | 原脚本 CSV 中的 `fps`，由 `600 ÷ 编码命令耗时（秒）` 得出 | fps | 越大越好 |
| BQTerrace，CRF 28 | 单路编码帧率 | 同上 | fps | 越大越好 |

共两个指标。报告按“单路 → BQTerrace”分组，分别显示 CRF 24 和 28；
本用例不测整机多路，也不按码率拆表。此前的“四码率、单路＋整机”结果
与本用例口径不同，不能直接比较。

| 文件 | 内容 |
|---|---|
| `result_bench-x265.csv` | 原 `run.py` 的 `scenario,frames,fps,status` 两行结果 |
| `benchmark_encode.txt` | 原脚本控制台输出和编码日志 |
| `scenarios/<场景>/` | 编码命令、进度、日志、`ffprobe` 与单场景结果证据 |
| `benchmark_x265.json` | 经原始 CSV 和证据校验后供 Framework 读取的两个指标及测试参数 |
| `x265-build-manifest.json` | 原构建脚本生成的构建信息 |

原始 MP4 留在本次私有工作目录，不复制到报告目录。转换脚本要求两个场景
都成功、每项恰好编码 600 帧，且 CSV 帧率与原始记录一致；缺失或不一致则测试失败。

脱离 Workflow 执行完整流程：

```bash
bash software/Media/x265/x265_test.sh \
  --version 4.2 \
  --variant base \
  --results-dir /home/runner/x265-results
```

独立运行默认清理自身创建的私有工作目录；需要保留编码现场时加 `--keep-workdir`。
Framework 分阶段运行时，输出写入传入的 `RESULTS_DIR`，构建和编码现场写入
传入的 `PERF_WORK_DIR`。
