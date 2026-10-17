# OpenCV 性能测试说明

本目录从 OpenCV 官方仓库（github.com/opencv/opencv）克隆 `5.0.0` 标签源码（当前 stable
release），使用源码树自带的官方 `modules/<m>/perf` 性能测试框架（`modules/ts`，GTest 驱动，
每模块构建出独立的 `opencv_perf_<module>` 二进制）构建并执行 core 与 imgproc 两大核心计算
模块的基准；固定测试数据树来自官方测试数据仓库 opencv_extra（github.com/opencv/opencv_extra）
的同 `5.0.0` 标签克隆。Framework 通过 `case.yaml` 调用 `opencv_test.sh` 的四阶段接口；
直接执行入口脚本会走同一流程。

当前清单支持 `5.0.0`，默认版本 `5.0.0`。

## 构建与安装

OpenCV 无需安装任何系统级组件。脚本从官方 GitHub 标签浅克隆两个仓库
（`git clone --branch 5.0.0 --depth 1`，opencv 与 opencv_extra 同 tag），各以
`git describe --tags --exact-match` 校验标签精确匹配，并读取上游
`modules/core/include/opencv2/core/version.hpp` 的 `CV_VERSION_MAJOR/MINOR/REVISION`
（组成 5.0.0，`CV_VERSION_STATUS` 为空即 stable）与请求版本交叉验证。脚本检查 `git`、
`python3`、`cmake`（≥ 3.10）、`make`、`g++`（≥ 5）和 `tee`，缺失时报错退出，不做系统安装。

构建命令（官方 CMake，仅构建两个 perf 目标及其依赖闭包）：

```bash
cmake -S opencv-source -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_LIST=core,imgproc,ts \
  -DBUILD_PERF_TESTS=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_opencv_apps=OFF \
  -DBUILD_opencv_world=OFF \
  -DBUILD_JAVA=OFF \
  -DBUILD_opencv_python3=OFF \
  -DWITH_IPP=OFF \
  -DWITH_ITT=OFF \
  -DWITH_OPENCL=OFF \
  -DWITH_CUDA=OFF \
  -DOPENCV_TEST_DATA_PATH=<opencv-extra>/testdata
cmake --build build --target opencv_perf_core opencv_perf_imgproc
```

对官方构建口径的说明：

1. **`BUILD_LIST=core,imgproc,ts`**：官方模块白名单机制按上游依赖关系闭包展开为 8 个模块
   （core、flann、geometry、imgproc、imgcodecs、videoio、highgui、ts），即 `opencv_perf_core`
   与 `opencv_perf_imgproc` 两个目标的完整链接闭包，白名单裁剪由官方 CMake 自身完成。
2. **加速器全关**：`WITH_IPP`（Intel 闭源二进制，x86 独有，跨架构不一致）、`WITH_ITT`、
   `WITH_OPENCL`、`WITH_CUDA` 一律关闭，基准为纯 CPU 路径；apps/world/java/python 为非基准
   目标，一并关闭。
3. **`CPU_BASELINE`/`CPU_DISPATCH` 保持官方默认**：各架构编译各自的基线加运行时分发 SIMD
   内核（官方发布二进制的配置），不跨架构强推任何 ISA。
4. **`OPENCV_TEST_DATA_PATH`**：perf fixture 读取参考图像的官方数据目录，指向同 tag 的
   opencv_extra `testdata` 树（运行时同样通过该环境变量导出）。

## 测试数据与性能测试

`start` 阶段以缩短的时间预算（`--perf_time_limit=0.05`）冒烟运行官方 core 家族
`Size_MatType_abs`（不依赖测试数据、跨架构名称稳定），校验输出含 `[ PERFSTAT ]` 结果行。

`test` 阶段运行官方 perf 二进制。全量 perf 矩阵（5.0.0 下 core 4024 + imgproc 5256 个
fixture）远超可交付基准规模，因此每次运行时从官方 `--gtest_list_tests` 列表元数据确定性
选取切片（不依赖任何硬编码序号）：每个 fixture 家族优先取最大官方尺寸 `1920x1080`
（回退 `1280x720` → `640x480` → 家族首个 fixture），每家族至多 8 个参数组合，排除 `OCL_`
前缀（纯 CPU 构建下无意义）与 `DISABLED` fixture。实测切片规模：

| 模块 | 家族数 | 切片 fixture 数 | 内容 |
|---|---:|---:|---|
| `core` | 74 | 343 | 矩阵算术、DFT/DCT、归约、split/merge、排序、范数 |
| `imgproc` | 99 | 541 | 滤波、形态学、色彩转换、缩放、阈值、直方图、Canny |

每 fixture 按官方默认 simple 策略测量（1 秒时间预算、样本上限 100），输出官方统计行
（全部单位为毫秒，`modules/ts/src/ts_perf.cpp` 以 `ticks * 1000 / tickFrequency` 换算）：

```
[ RUN      ] Size_MatType_abs.abs/8, where GetParam() = (1920x1080, 8SC1)
[ PERFSTAT ]    (samples=100   mean=0.56   median=0.55   min=0.53   stddev=0.02 (4.0%))
[       OK ] Size_MatType_abs.abs/8 (61 ms)
```

采集指标为官方 `median`。任一模块 GTest 汇总行缺失、运行数与选取数不符、或 PERFSTAT 结果
低于选取数的 80% 时测试失败。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/opencv/opencv_test.sh \
  --version 5.0.0 \
  --results-dir /home/runner/boostkit-perf/opencv/results/5.0.0
```

## 指标

报告按 2 个模块分组，共 884 个指标（`<module>/<fixture 家族>.<名称>/<序号>`，core 343 +
imgproc 541）。每个指标取官方 PERFSTAT `median`（`median_ms`），单位 ms，越小越好；同一次
测量的 `samples`/`mean`/`min`/`stddev` 作为上下文保留在基准 JSON 中，不作为跨架构指标。

## 结果与清理

必需产物为 `benchmark_opencv_perf.json`，包含全部 884 组结构化结果（官方统计五元组）、
两模块运行汇总以及切片规则与构建参数信息。没有后台服务需要停止（perf 二进制跑完即退）；
任务结束只删除本次运行的双仓库源码、构建产物和临时目录（限
`/home/runner/boostkit-perf/opencv/local-*`）。
