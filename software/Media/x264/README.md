# x264 开箱编码性能测试

测试版本为 `0.165.3223`。入口是 `x264_test.sh`，四阶段函数由 `case.yaml` 声明。测试场景参考[开箱测试方案](https://atomgit.com/weixin_51237760/tasks/tree/main/2026/0924-x264%E3%80%81x265%E5%BC%80%E7%AE%B1)。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 从固定提交的源码压缩包编译；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，
不会退回基础版。启动、测试和停止阶段共用 `scripts/stages/` 下的脚本；
`scripts/common.sh` 提供阶段间一致的私有路径与运行时初始化，独立运行环境收集
位于 `scripts/results/`。未修改的参考脚本 `fps-encode-x264.sh`、`score-x264.sh`
保留在 `scripts/` 原位，由 Media 级测试锁定逐字节原版。

## 构建与安装

源码固定为 VideoLAN x264 的 `0480cb05` 提交（版本 `0.165.3223`）。
脚本参考 openEuler x264 Dockerfile，从
[GitHub 镜像](https://github.com/mirror/x264/archive/0480cb05.tar.gz)获取源码压缩包，
不访问需要人机验证的 VideoLAN Git 仓库。下载后校验 SHA-256：
`d0967a1348c85dfde363bb52610403be898171493100561efa0dd05d5fd1ae50`。

Runner 已有 `/home/runner/software/x264/x264-0480cb05.tar.gz` 时优先使用该离线包，
同样必须通过校验；不存在时联网下载。缺少构建命令时用 `dnf` 安装，
x86_64 还需要 NASM；`PERF_PROXY` 非空时作为 dnf 代理。

关键命令（在本次私有工作目录 `PERF_WORK_DIR` 下执行）：

```bash
cd "$PERF_WORK_DIR"
INSTALL_DIR="$PERF_WORK_DIR/x264/x264_install"
curl -fSL --connect-timeout 30 --retry 3 \
  -o x264-0480cb05.tar.gz https://github.com/mirror/x264/archive/0480cb05.tar.gz
echo 'd0967a1348c85dfde363bb52610403be898171493100561efa0dd05d5fd1ae50  x264-0480cb05.tar.gz' | sha256sum -c -
mkdir x264
tar -xzf x264-0480cb05.tar.gz -C x264 --strip-components=1
cd x264
mkdir x264_build x264_install
cd x264_build
../configure --enable-shared --enable-pic --prefix="$INSTALL_DIR"
make -j"$(nproc)" && make install
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:${LD_LIBRARY_PATH:-}"
export PATH="$INSTALL_DIR/bin:$PATH"
x264 --version
```

源码与安装目录均在本次 `PERF_WORK_DIR` 内，不覆盖系统编码器。
源码压缩包没有 `.git` 历史，x264 自带的 `version.sh` 因此可能使二进制的
`--version` 显示 `0.165.x`。构建阶段只在归档 SHA-256 已匹配上述固定源码、
且二进制显示 `0.165.x` 时接受这一形式；结果仍记录已校验的源码版本
`0.165.3223`。其他版本不匹配仍会失败。

## 视频素材

将下列视频中需要测试的非空子集放在 Runner 持久目录
`/home/runner/software/x264/video/`，文件名以 `.yuv` 结尾。视频必须是未经压缩的
1920×1080、8 位 I420，且不能包含不完整帧。当前若只提供 3 个视频，就运行
3 个视频 × 4 个码率，共 12 个场景；不要求凑齐 13 个。

x86_64 和 aarch64 必须提供**相同文件名、相同内容**的视频。结果会记录各文件的
SHA-256、长度和使用帧数；跨架构汇总会校验这些参数一致。x265 仍要求完整的
13 个视频，使用自己的 `/home/runner/software/x265/video/` 目录。

```text
Dota2_1920x1080_60.yuv
xihuanni_1920x1080_30_1000.yuv
showSingText_1920x1080_40.yuv
1_Yuanshen_1920x1080_60_8bit_12M.yuv
BQTerrace_1920x1080_60.yuv
Film2012_1920x1080_25_8bit_8Mbps.yuv
BQTerrace_1920x1080_60-dianbo.yuv
messi_1920x1080_25_1000.yuv
BasketballDrive_1920x1080_50.yuv
BQTerrace_1920x1080_60-biaozhun.yuv
Cactus_1920x1080_50.yuv
Kimono_1920x1080_24.yuv
ParkScene_1920x1080_24.yuv
```

## 测试与指标

测试阶段直接执行未修改的参考脚本 [fps-encode-x264.sh](scripts/fps-encode-x264.sh) 和 [score-x264.sh](scripts/score-x264.sh)。脚本需要的 `TEST_HOME/video` 是指向上述 Runner 持久目录的符号链接，`TEST_HOME` 为本次私有工作目录。

调用方式与原文一致：aarch64 使用 `bash fps-encode-x264.sh 8core 920 1`，x86_64 使用 `bash fps-encode-x264.sh 8core x86 1`，随后执行 `bash score-x264.sh`。原脚本会对目录中每个视频以 `2000`、`4000`、`6000`、`8000` kb/s 编码，固定传入 `--frames 9999`。CPU 绑定、线程选择及编码参数均由原脚本决定；x86 的 CPU 偏移量也保留原脚本的 `192`。

参考命令形态（实际值随视频变化）：

```bash
taskset -c <本路 CPU 列表> "$INSTALL_DIR/bin/x264" \
  --preset faster --input-res 1920x1080 --fps 60 --frames 9999 \
  --keyint 120 --min-keyint 60 --bframes 0 \
  --bitrate 2000 --vbv-maxrate 2000 --vbv-bufsize 2000 \
  --rc-lookahead 1 --lookahead-threads 3 \
  -o <本次任务的私有码流路径> /home/runner/software/x264/video/Dota2_1920x1080_60.yuv
```

报告指标取原脚本生成的 `video_fps_summary_x264.csv` 中的 `Total FPS`，单位 `fps`，越高越好；按码率分组。结果转换程序只校验原始日志与 CSV，并生成 `benchmark_x264.json` 供框架读取，不执行编码。原始日志合并到 `benchmark_encode.txt`；码流文件留在本次私有工作目录，独立运行结束时由现有清理流程处理。

独立运行：

```bash
bash software/Media/x264/x264_test.sh --version 0.165.3223 \
  --variant base \
  --results-dir /home/runner/x264-results
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；不指定时调优版
结果位于该版本下的 `optimized/` 子目录。目前调优版只验证入口与明确失败行为，
不执行性能测试；正式工作流中调优版归档到
`Media/x264/0.165.3223/optimized/<时间戳_Run ID>/`，且不会更新基础版的
`baseline.json`。构建阶段保存 `build_variant.json` 以标识实际选择。

`stop` 阶段无后台服务需要停止；独立运行默认清理自身创建的私有工作目录，
排查问题时可使用 `--keep-workdir`。
