# libavif 性能测试说明

本目录从 libavif 官方仓库（github.com/AOMediaCodec/libavif）克隆 `v1.4.2`
标签源码（当前 stable release），连同上游构建文件锁定的 AV1 编解码栈（aom
`v3.14.1`、libyuv `644251f`、nasm `2.16.03`）一起静态构建，并通过基准驱动
`src/avif_benchmark.c` 以官方公开 API 执行 AVIF 编码与解码延迟测试。软件入口
为 `libavif_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 libavif `1.4.2`。新增版本时，必须同步核对上游
`cmake/Modules/LocalAom.cmake` 与 `LocalLibyuv.cmake` 中锁定的 aom tag 与
libyuv commit 是否变化，不能沿用失效的锁定版本。

## 构建与安装

libavif 不安装任何系统级组件，全部构建在任务隔离工作目录中。构建步骤如下：

1. 克隆 libavif `v1.4.2` 标签（`git clone --branch v1.4.2 --depth 1`），以
   `git describe --tags --exact-match` 校验标签精确匹配，并读取上游
   `include/avif/avif.h` 的 `AVIF_VERSION_MAJOR/MINOR/PATCH`（组成 1.4.2，
   release tag 的 `AVIF_VERSION_DEVEL` 为 0）与请求版本交叉验证。
2. 按上游锁定版本克隆两个编解码依赖，放在官方构建脚本约定的源码树内位置：

   | 依赖 | 锁定来源 | 版本 | 位置 |
   |---|---|---|---|
   | aom | `aomedia.googlesource.com/aom` | tag `v3.14.1`（`ext/aom.cmd` 与 `LocalAom.cmake` 固定） | `ext/aom` |
   | libyuv | `chromium.googlesource.com/libyuv/libyuv` | commit `644251f252a84bf8ce91ff0aca86a9b16b069ab8`（`LocalLibyuv.cmake` 固定） | `ext/libyuv` |

3. 构建汇编器 nasm `2.16.03`（aom 的 SIMD 内核汇编需要）：官方
   `nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.xz` 发布包，
   SHA-256 `1412a1c7...6148` 校验后源码构建进本任务 prefix，不做系统安装。
4. 运行官方 CMake 构建并编译基准驱动：

```bash
PATH=<prefix>/bin:$PATH cmake -S libavif-source -B libavif-source/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DAVIF_CODEC_AOM=LOCAL \
  -DAVIF_LIBYUV=LOCAL \
  -DAVIF_BUILD_APPS=OFF \
  -DAVIF_BUILD_TESTS=OFF
cmake --build libavif-source/build --parallel 8

gcc -O2 -Wall -o avif_benchmark src/avif_benchmark.c \
  -I libavif-source/include \
  libavif-source/build/libavif.a -lpthread -lm
```

对官方构建口径的两处适配说明：

1. **`FETCHCONTENT_SOURCE_DIR_LIBAOM`**：上游 `LocalAom.cmake` 在检测到
   `ext/aom` 存在时设置了 `FETCHCONTENT_SOURCE_DIR_AOM` 变量，但其
   `FetchContent_Declare` 声明名是 `libaom`，变量名与声明名不匹配导致 cmake
   忽略本地源码转而从网络重新克隆。构建命令显式传入与声明名匹配的
   `FETCHCONTENT_SOURCE_DIR_LIBAOM=<ext/aom>`，使第 2 步克隆并校验过的源码
   生效；其余配置不变。
2. **`BUILD_SHARED_LIBS=OFF` + LOCAL 依赖**：这是上游 `ext/README.md` 给出的
   全静态发布构建形态（libavif 官方持续集成即用此方式），基准驱动直接链接
   产物 `build/libavif.a`（已并入 aom/libyuv），运行时不依赖任何
   `LD_LIBRARY_PATH`。apps/tests 关闭为构建裁剪（官方应用与功能测试和基准
   无关）。

## 基准驱动

libavif 官方仓库不带基准工具：`tests/aviftest.c` 是数据目录功能遍历，
`tests/avifyuv.c` 是颜色转换正确性检查，官方应用 `avifenc`/`avifdec` 不输出
任何耗时信息。因此本用例按仓库规则自写最小驱动 `src/avif_benchmark.c`，其
只调用官方公开 API，调用方式与官方应用一致（被测代码 100% 为官方库构建
产物）：

- 编码：`avifImageCreate` + `avifImageAllocatePlanes` 构图 →
  `avifEncoderCreate`（`maxThreads`、`speed=6`、`quality=60`，即 avifenc 默
  认值）→ `avifEncoderAddImage` + `avifEncoderFinish`；
- 解码：`avifDecoderCreate`（`maxThreads`）→ `avifDecoderSetIOMemory` +
  `avifDecoderParse` + `avifDecoderNextImage`（纯内存解码，不含文件 I/O）。

测试图像由固定 LCG 种子程序生成（内容确定性、跨架构逐字节一致），三档负载
覆盖主流照片规格与高质量档：

| 负载 | 规格 |
|---|---|
| `1920x1080_yuv420_8bpc` | 1080p，YUV420，8bpc（主流网页照片） |
| `3840x2160_yuv420_8bpc` | 4K，YUV420，8bpc（高负载） |
| `1920x1080_yuv444_10bpc` | 1080p，YUV444，10bpc（高质量档，aom 10bit 路径） |

计时使用 `clock_gettime(CLOCK_MONOTONIC)`，测量编码（AddImage+Finish）与解
码（NextImage）单次调用耗时；每场景预热 1 次后测量多次取中位数（1080p 编码
10 次、4K 编码 5 次，解码加倍），解码负载为同线程档编码产物。驱动输出一行
一场景的管道分隔结果：

```text
AVIFBENCH|encode|1920x1080_yuv420_8bpc|1|1021415023|1008278144|1043738137|10
AVIFBENCH|decode|1920x1080_yuv420_8bpc|1|145717848|144547594|156243596|20
```

各字段依次为：操作（encode/decode）、负载、线程数、中位数 ns、最小 ns、最
大 ns、样本数。多线程语义与官方应用 `-j/--jobs` 一致（编码影响 tile 划
分、解码影响解码器线程数）；部分小图解码档位下多线程不升反降为官方库真实
行为，不做干预。

## 性能测试

`start` 阶段以 `--smoke` 模式冒烟运行驱动（1080p、单线程、各测量 1 次），
校验版本行与 encode/decode 两行结果完整。

`test` 阶段运行完整 18 场景矩阵（2 操作 × 3 负载 × 线程 1/4/16），全程输出
保留为 `avif_benchmark_raw.log`，随后由 `collect_avif_benchmark.py` 解析并
生成结构化 `results.json`。任一场景缺失、中位数非正、或驱动报告版本与请求
版本不符时测试失败。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop 并
保存同样的产物。例如：

```bash
bash software/Media/libavif/libavif_test.sh \
  --version 1.4.2 \
  --results-dir /home/runner/boostkit-perf/libavif/results/1.4.2
```

## 指标

每个"操作 + 负载 + 线程数"组合一个指标，不做平均、加权或跨场景聚合。因此
总计为：

```text
2 个操作 × 3 个负载 × 3 个线程档位 = 18 个指标
```

| 驱动字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `median` | `avif <操作> <负载> --threads=<线程数>: median` | ms | 越小越好 | 单帧编码/解码耗时中位数 |

报告按"操作 + 负载"分组展示（如 `encode 1920x1080_yuv420_8bpc`），每组 3
个线程档位；同一测量轮的 `min`/`max`/`samples` 保留在原始日志中，不作为跨
架构指标。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `avif_benchmark_raw.log`：驱动完整原始输出；
- `results.json`：18 个结构化指标及其来源文件名。

没有后台服务需要停止（驱动跑完即退）；任务结束只删除本次运行的源码、构建
产物、nasm prefix 和基准二进制（限
`/home/runner/boostkit-perf/libavif/local-*`）。Framework 随后执行 Runner 级
环境清理。
