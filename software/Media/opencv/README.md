# opencv 4.10.0 开箱（open-box）性能用例

本用例在**私有 openEuler 24.03 LTS SP4 容器内原生运行**，用开源版 OpenCV 4.10.0 的
Python 绑定做 1920x1080 灰度帧 L1 范数（`cv2.norm(gray, cv2.NORM_L1)`）的单次调用时延作为性能指标。
测试素材与场景来自 boostkit 开箱测试材料 `Test/opencv`（bench.py / build_install.sh / run_bench.sh），
移植时**只去掉绑核与绑内存**，其余（输入切片、构建参数、工作负载、金标准校验、计时方式）逐项保持一致。

## 与参考材料的关系

| 项目 | 参考材料 | 本用例 |
| --- | --- | --- |
| 源码 | opencv 4.10.0（sha256 `b2171af5…`），禁止打补丁 | 相同，构建阶段强校验 |
| 编译 | `-O3 -ffp-contract=off`，aarch64 追加 `-march=armv8-a`，共享库，只编 `core,imgproc,python3` | 相同 |
| 后端 | IPP/OpenCL/OpenVX/LAPACK/Eigen/Halide/Carotene/TBB/OpenMP 全关，`OPENCV_SKIP_PYTHON_LOADER=ON` | 相同 |
| 输入 | 3 段 1080p 视频首帧 → 灰度平面（BQTerrace / Film2012 / messi） | 相同，帧 0 与 RGB 转换摘要全部锁定 |
| 工作负载 | `cv2.norm(gray, cv2.NORM_L1)`，每次采样 500 次调用 | 相同 |
| 正确性 | 结果与 `gray.sum(dtype=np.uint64)` 相等，前后复核 | 相同，并校验输入/转换摘要 |
| 计时 | 5 次预热 + 20 次采样，每次采样 median | 相同（5 + 20 × 500），上报中位数，均值另存 evidence.json |
| 线程 | `cv2.setNumThreads(1)`、`OMP_NUM_THREADS=1`、OpenCL 关闭 | 相同（库级设置，不是 CPU 亲和性） |
| CPU/内存 | `os.sched_setaffinity(0, {88})` + `numactl --membind` 绑 NUMA 节点 | **完全不绑**，容器内进程可用全部 CPU 与 NUMA 节点 |
| 运行位置 | 宿主机 `/home/test/Test` | 私有容器，素材只读挂载 `/media-input` |

因为不绑核，本用例的绝对值与参考材料里绑核的 0.412–0.968 ms/call 不可直接对比；
跨平台对比请看同架构下本用例自己的结果。

## 指标

3 个场景，单位 ms（每次 `cv2.norm` 调用），方向 lower_is_better：

| 场景 | 分组 | 说明 |
| --- | --- | --- |
| `BQTerrace_norm_l1_gray8` | 图像处理 / BQTerrace | 1920x1080 灰度帧 L1 范数 |
| `Film2012_norm_l1_gray8` | 图像处理 / Film2012 | 同上 |
| `messi_norm_l1_gray8` | 图像处理 / messi | 同上 |

每个场景 5 次预热调用 + 20 次采样（每次 500 次调用，`OPENCV_SAMPLES`/`OPENCV_CALLS_PER_SAMPLE` 可覆盖，
样本数最少 5），上报中位数，全部原始样本落盘 `runs/<scenario>/rep<i>.json`；
参考材料的 `iterations` 列（`500 × 20 = 10000`）保持原样。

## 目录结构

```
opencv_test.sh                     独立运行入口（四个阶段一次跑完）
case.yaml                          Framework 用例描述（阶段、超时、产物、指标）
fixtures/media.json                测试素材与 3 个场景清单（文件名/字节数/sha256/API）
scripts/common.sh                  公共配置 + 生成式容器运行时块
scripts/builders/{dispatch,base,optimized}.sh   构建阶段（base 为唯一实现）
scripts/stages/{start,test,stop}.sh             运行/测试/清理阶段
scripts/harness/bench_norm.py      范数场景计时器（容器内执行，需要 numpy）
scripts/results/parse_benchmark.py 严格结果校验与 benchmark_opencv.json 生成
tests/test_container_lifecycle.py  离线契约测试（无 Docker、无素材也能跑）
```

## 运行方式

CI（Framework 六阶段）：

```bash
python3 framework/run_case.py --case software/Media/opencv/case.yaml --version 4.10.0 \
    --architecture x86_64 --run-id "$PERF_RUN_ID"
```

工作站复现：

```bash
OPENCV_SAMPLES=5 ./opencv_test.sh --keep-workdir
```

## 素材

镜像里不含测试素材。运行机需在下列任一位置提供三段 YUV：

| 文件 | 字节 |
| --- | --- |
| `BQTerrace_1920x1080_60.yuv` | 1,866,240,000 |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | 4,665,600,000 |
| `messi_1920x1080_25_1000.yuv` | 3,110,400,000 |

查找顺序：`OPENCV_MEDIA_DIR` > `/home/runner/software/media/video` > `/home/test/Test/video`。
素材在测试阶段只读挂载进容器 `/media-input`，仓库里只提交 `fixtures/media.json` 中的摘要。

## 构建产物

源码包优先取运行机持久目录 `/home/runner/software/opencv/downloads/opencv-4.10.0.tar.gz`，
缺失时才用 codeload 兜底下载，拿到后按 sha256 校验。
容器内安装 `libopencv_core.so`、`libopencv_imgproc.so` 与 `python3` 绑定，
`import cv2` 必须来自私有前缀并报告 4.10.0；构建信息必须满足：无 `-fopenmp`、
`Parallel framework: none`、IPP 关闭。

## 采样契约

- 每个场景 5 次预热调用、至少 5 次采样（默认 20 次 × 500 次调用）；
- 采样值必须有限且为正，解析器不接受补零、缺样本或与 CSV 不一致的样本；
- 3 个场景必须齐全且顺序/名称与清单一致，缺一个就整体失败；
- 解析器同时校验：CSV `status` 全为 `OK`、`iterations == 500 × 20`、
  `evidence.cpu_pinning=none`、`source_mode=unpatched`、输入与 RGB 摘要与清单一致、
  构建信息里的并行框架为 `none`。

## 产物

| 文件 | 说明 |
| --- | --- |
| `build_variant.json` | 构建变体、源码包摘要、容器镜像 |
| `benchmark_norm.txt` | 容器内完整原始输出（含 `OPENCV_BENCH_COMPLETE` 完成标记） |
| `result_bench-opencv.csv` | 参考格式 CSV（3 行，`scenario,iterations,ms_per_call,status`） |
| `evidence.json` | 每个场景的全部样本、CPU 集合、构建信息、输入摘要、无绑核声明 |
| `benchmark_opencv.json` | Framework 归一化结果（3 个指标） |
| `runs/<scenario>/rep<i>.json` | 每次采样一条记录（不覆盖、不丢弃） |

## 约束

- 单分支单提交，PR 不合并；
- 全流程禁止 `taskset`、`numactl`、`sched_setaffinity`、`membind` 等绑核绑内存手段；
- 只用开源版源码与默认构建参数，不做任何补丁或调优；
- `optimized` 变体未实现，显式失败，避免把 baseline 数据挂在优化版本名下。
