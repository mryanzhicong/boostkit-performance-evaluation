# OpenCV 性能测试案例

## 软件说明

OpenCV（Open Source Computer Vision Library）是开源的计算机视觉库，
提供矩阵/数组运算（core）、图像处理（imgproc：滤波、形态学、色彩
转换、缩放、阈值、直方图）等核心能力，是视觉领域事实标准的基础库。

- 官方仓库：<https://github.com/opencv/opencv>
- 测试版本：`5.0.0`（官方 stable tag，`git describe --exact-match` 校验）
- 测试数据仓库：<https://github.com/opencv/opencv_extra>（同 `5.0.0` tag，
  提供 `OPENCV_TEST_DATA_PATH` 固定测试数据树）

## 基准工具

使用 OpenCV 源码树自带的官方 perf 基准框架（`modules/ts`，GTest 驱动）：
每个模块编译出独立的 `opencv_perf_<module>` 二进制，按官方计时循环
（默认 simple 策略：每 fixture 1 秒时间预算、样本上限 100）测量并输出：

```
[ RUN      ] Size_MatType_abs.abs/8, where GetParam() = (1920x1080, 8SC1)
[ PERFSTAT ]    (samples=100   mean=0.56   median=0.55   min=0.53   stddev=0.02 (4.0%))
[       OK ] Size_MatType_abs.abs/8 (61 ms)
```

全部 PERFSTAT 统计量的单位均为毫秒（`modules/ts/src/ts_perf.cpp` 中
`ticks * 1000.0f / tickFrequency` 换算）。采集指标为官方 median
（`median_ms`，越小越好），mean/min/stddev 一并保留供参考。

## 测试矩阵

全量 perf 矩阵（5.0.0 下 core 4024 + imgproc 5256 个 fixture）远超
可交付基准规模，因此按以下规则从官方 `--gtest_list_tests` 元数据在
每次运行时确定性选取切片（不依赖任何硬编码序号）：

- 模块：`core`、`imgproc`（两大核心计算模块）
- 排除 `OCL_` 前缀（纯 CPU 构建）与 `DISABLED` fixture
- 每 fixture 家族优先取最大官方尺寸 `1920x1080`（回退 `1280x720` →
  `640x480` → 家族首个），每家族至多 8 个参数组合

实测切片规模约 core ~340 + imgproc ~540，共 ~880 个代表性 fixture，
运行约 15 分钟。

## 构建方式

官方 CMake，仅构建 perf 目标的依赖闭包（`BUILD_LIST=core,imgproc,ts`
按官方依赖关系展开为 core、flann、geometry、imgproc、imgcodecs、
videoio、highgui、ts），关闭全部非基准目标与跨架构不一致的加速器：

| 选项 | 值 | 说明 |
|---|---|---|
| `CMAKE_BUILD_TYPE` | `Release` | 官方发布配置 |
| `BUILD_LIST` | `core,imgproc,ts` | perf 目标闭包 |
| `BUILD_PERF_TESTS` | `ON` | 生成 `opencv_perf_*` |
| `BUILD_TESTS` / `BUILD_opencv_apps` / `BUILD_opencv_world` | `OFF` | 非基准目标 |
| `BUILD_JAVA` / `BUILD_opencv_python3` | `OFF` | 非基准绑定 |
| `WITH_IPP` | `OFF` | Intel 闭源二进制，x86 独有，跨架构不一致 |
| `WITH_ITT` / `WITH_OPENCL` / `WITH_CUDA` | `OFF` | 非纯 CPU 路径 |

`CPU_BASELINE`/`CPU_DISPATCH` 保持官方默认（各架构各自的基线 + 运行
时分发 SIMD 内核，即官方发布二进制的配置），不跨架构强推任何 ISA。

## 执行

```bash
# 独立全流程（clone → build → smoke → test → 汇总 → 清理）
./opencv_test.sh

# 常用覆盖
./opencv_test.sh --version 5.0.0 --results-dir <dir> --keep-workdir
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`RESULTS_DIR`、
`PERF_WORK_DIR`、`OPENCV_SOURCE_URL`、`OPENCV_EXTRA_SOURCE_URL`、
`OPENCV_BUILD_JOBS`（默认 8）。

四阶段（供框架调度）：`build_opencv` / `start_opencv_runtime` /
`run_opencv_benchmarks` / `stop_opencv_runtime`（perf 二进制跑完即退，
无后台服务）。

## 输出

- `benchmark_opencv_perf.json`：全部 fixture 的 samples/mean/median/
  min/stddev（ms）与选择规则说明
- `results.json` / `status.json` / `report.md`：独立运行时汇总
  （指标按模块分组，`median_ms`，越小越好）

## 环境要求

- cmake >= 3.10、g++ >= 5、git、python3
- 磁盘 ~3 GB（源码 + 构建产物，全部位于隔离工作目录，结束后清理）
- 网络：可访问 GitHub（克隆两个官方仓库）
