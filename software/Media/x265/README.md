# x265 开箱编码性能测试

测试版本为 `4.2`。入口是 `x265_test.sh`，四阶段函数由 `case.yaml` 声明。测试场景参考[开箱测试方案](https://atomgit.com/weixin_51237760/tasks/tree/main/2026/0924-x264%E3%80%81x265%E5%BC%80%E7%AE%B1)。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 从官方源码包编译；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，
不会退回基础版。启动、测试和停止阶段共用 `scripts/stages/` 下的脚本；
`scripts/common.sh` 提供阶段间一致的私有路径与运行时初始化，独立运行环境收集
位于 `scripts/results/`。未修改的参考脚本 `fps-encode-x265.sh`、`score-x265.sh`
保留在 `scripts/` 原位，由 Media 级测试锁定逐字节原版。

## 构建与安装

脚本按参考资料从 [x265 官方下载目录](https://bitbucket.org/multicoreware/x265_git/downloads)获取 `x265_4.2.tar.gz` 并解压。缺少构建命令时用 `dnf` 安装，x86_64 还需要 NASM；`PERF_PROXY` 非空时作为 dnf 代理。

关键命令（在本次私有工作目录 `PERF_WORK_DIR` 下执行）：

```bash
cd "$PERF_WORK_DIR"
INSTALL_DIR="$PERF_WORK_DIR/x265_4.2/x265_install"
wget https://bitbucket.org/multicoreware/x265_git/downloads/x265_4.2.tar.gz
tar -zxvf x265_4.2.tar.gz
cd x265_4.2
mkdir x265_build x265_install
cd x265_build
cmake -S ../source/ \
  -DCMAKE_BUILD_TYPE=Release -DENABLE_PIC=ON -DENABLE_ASSEMBLY=ON \
  -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_C_FLAGS=-O3 -DCMAKE_CXX_FLAGS=-O3 \
  -DHIGH_BIT_DEPTH=off -DENABLE_TESTS=on \
  -DENABLE_SHARED=on -DENABLE_LIBNUMA=off \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"
make -j"$(nproc)" && make install
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:${LD_LIBRARY_PATH:-}"
export PATH="$INSTALL_DIR/bin:$PATH"
x265 --version
```

脚本验证实际编码器版本以 `4.2` 开头，不进行系统级安装。

## 视频素材

在 Runner 持久目录 `/home/runner/software/x265/video/` 放入
[x264 视频清单](../x264/README.md#视频素材)中的非空子集即可。例如只提供 3 个视频时，
运行 3 个视频 × 4 个码率，共 12 个场景，不要求凑齐 13 个。素材必须是
1920×1080、8 位 I420 的完整帧；x86_64 与 aarch64 必须提供相同文件名、
相同内容的文件。脚本记录 SHA-256、文件长度及使用帧数，跨架构汇总会校验负载一致。

## 测试与指标

测试阶段直接执行未修改的参考脚本 [fps-encode-x265.sh](scripts/fps-encode-x265.sh) 和 [score-x265.sh](scripts/score-x265.sh)。脚本需要的 `TEST_HOME/video` 是指向上述 Runner 持久目录的符号链接，`TEST_HOME` 为本次私有工作目录。

每个架构依次执行单路与整机两组测试，整机路数按原文使用 `nproc / 8`：

```bash
# aarch64
bash fps-encode-x265.sh 8core 920 1
bash fps-encode-x265.sh 8core 920 $(($(nproc) / 8))

# x86_64
bash fps-encode-x265.sh 8core x86 1
bash fps-encode-x265.sh 8core x86 $(($(nproc) / 8))

bash score-x265.sh
```

原脚本将两组码流和日志分别写入 `outputfiles-x265-8core-<路数>/`，汇总为对应的 `video_fps_summary_x265-8core-<路数>.csv`。每个视频测试 `2000`、`4000`、`6000`、`8000` kb/s，固定传入 `--frames 9999`。CPU 绑定、线程池及编码参数均由原脚本决定；x86 的 CPU 偏移量保留原脚本的 `192`。

参考命令形态（实际值随视频变化）：

```bash
taskset -c <本路 CPU 列表> "$INSTALL_DIR/bin/x265" \
  --preset faster --input /home/runner/software/x265/video/Dota2_1920x1080_60.yuv \
  --input-res 1920x1080 --fps 60 --frames 9999 \
  --keyint 120 --min-keyint 60 --bframes 0 \
  --bitrate 2000 --vbv-maxrate 2000 --vbv-bufsize 2000 \
  --rc-lookahead 1 --frame-threads 4 --pools 16 --lookahead-threads 3 \
  -o <本次任务的私有码流路径>
```

报告指标分别取单路和整机 CSV 中的 `Total FPS`，单位 `fps`，越高越好。报告先分“单路”和“整机”，再以视频名为下级标题，每个视频下面展示四个码率的 FPS；原始指标名保留在结果 JSON 中。整机 `Total FPS` 是各路 FPS 之和，实际路数记录在原始结果 JSON 中。结果转换程序校验每一路日志、码流文件与 CSV，再生成 `benchmark_x265.json` 供框架读取，不执行编码。原始日志合并到 `benchmark_encode.txt`；码流文件留在本次私有工作目录，独立运行结束时由现有清理流程处理。

独立运行：

```bash
bash software/Media/x265/x265_test.sh --version 4.2 \
  --variant base \
  --results-dir /home/runner/x265-results
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；不指定时调优版
结果位于该版本下的 `optimized/` 子目录。目前调优版只验证入口与明确失败行为，
不执行性能测试；正式工作流中调优版归档到
`Media/x265/4.2/optimized/<时间戳_Run ID>/`，且不会更新基础版的
`baseline.json`。构建阶段保存 `build_variant.json` 以标识实际选择。

`stop` 阶段无后台服务需要停止；独立运行默认清理自身创建的私有工作目录，
排查问题时可使用 `--keep-workdir`。
