# libavif 0.9.3 开箱（open-box）性能用例

本用例在**私有 openEuler 24.03 LTS SP4 容器内原生运行**，用开源版 libavif 0.9.3
（编码器 AOM 3.2.0）的 AV1 编码时延作为性能指标。测试素材与场景来自 boostkit 开箱测试材料
`Test/libavif`（bench.py / build_install.sh / run_bench.sh），移植时**只去掉绑核与绑内存**，
其余（输入切片、编码参数、金标准校验、计时方式）逐项保持一致。

## 与参考材料的关系

| 项目 | 参考材料 | 本用例 |
| --- | --- | --- |
| 源码 | libavif 0.9.3（sha256 `bcd9a1f5…`）+ AOM 3.2.0（sha256 `34132ae8…`），禁止打补丁 | 相同，构建阶段强校验并断言补丁标记不存在 |
| 编译 | AOM `-Ofast -ffp-contract=off -fPIC`，libavif `-O3 -ffp-contract=off`，共享库 | 相同 |
| 输入 | 3 段 1080p 视频首帧 → PNG（BQTerrace / Film2012 / messi） | 相同，3 个 PNG sha256 全部锁定 |
| 编码 | `avifenc --codec aom --yuv 420 --speed 8 --jobs 8 --min QP --max QP --tilerowslog2 0 --tilecolslog2 2`，QP 20/32 | 相同（原生 8 线程） |
| 正确性 | 每次编码结果一致 + 解码像素一致 | 相同（编码 sha256、解码 Y4M sha256 双校验） |
| 计时 | 1 次预热 + 20 次迭代，取均值 | 1 次预热 + 20 次采样，**上报中位数**，均值另存 evidence.json |
| CPU/内存 | `taskset` 绑 8 核 + `numactl --membind` 绑 NUMA 节点 | **完全不绑**，容器内进程可用全部 CPU 与 NUMA 节点 |
| 运行位置 | 宿主机 `/home/test/Test` | 私有容器，素材只读挂载 `/media-input` |

因为不绑核，本用例的绝对值与参考材料里绑核的 94.8–192.5 ms 不可直接对比；
跨平台对比请看同架构下本用例自己的结果。

## 指标

6 个场景，单位 ms，方向 lower_is_better：

| 场景 | 分组 | 说明 |
| --- | --- | --- |
| `BQTerrace_qp20_c8` / `BQTerrace_qp32_c8` | AV1编码 / BQTerrace | QP20 / QP32 |
| `Film2012_qp20_c8` / `Film2012_qp32_c8` | AV1编码 / Film2012 | QP20 / QP32 |
| `messi_qp20_c8` / `messi_qp32_c8` | AV1编码 / messi | QP20 / QP32 |

每个场景 1 次预热 + 20 次采样（`LIBAVIF_SAMPLES` 可覆盖，最少 5），上报中位数，
全部原始样本落盘 `runs/<scenario>/rep<i>.json`；参考材料的均值同时保留在 `evidence.json` 与结果 JSON 的 `mean_ms` 中。

## 目录结构

```
libavif_test.sh                    独立运行入口（四个阶段一次跑完）
case.yaml                          Framework 用例描述（阶段、超时、产物、指标）
fixtures/media.json                测试素材与 6 个场景清单（文件名/字节数/sha256/编码参数）
scripts/common.sh                  公共配置 + 生成式容器运行时块
scripts/builders/{dispatch,base,optimized}.sh   构建阶段（base 为唯一实现）
scripts/stages/{start,test,stop}.sh             运行/测试/清理阶段
scripts/harness/bench_encode.py    编码场景计时器（容器内执行）
scripts/results/parse_benchmark.py 严格结果校验与 benchmark_libavif.json 生成
tests/test_container_lifecycle.py  离线契约测试（无 Docker、无素材也能跑）
```

## 运行方式

CI（Framework 六阶段）：

```bash
python3 framework/run_case.py --case software/Media/libavif/case.yaml --version 0.9.3 \
    --architecture x86_64 --run-id "$PERF_RUN_ID"
```

工作站复现：

```bash
LIBAVIF_SAMPLES=5 ./libavif_test.sh --keep-workdir
```

## 素材

镜像里不含测试素材。运行机需在下列任一位置提供三段 YUV：

| 文件 | 字节 |
| --- | --- |
| `BQTerrace_1920x1080_60.yuv` | 1,866,240,000 |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | 4,665,600,000 |
| `messi_1920x1080_25_1000.yuv` | 3,110,400,000 |

查找顺序：`LIBAVIF_MEDIA_DIR` > `/home/runner/software/media/video` > `/home/test/Test/video`。
素材在测试阶段只读挂载进容器 `/media-input`，仓库里只提交 `fixtures/media.json` 中的摘要。

## 构建产物

两个源码包优先取运行机持久目录 `/home/runner/software/libavif/downloads/`，
缺失时才从 `https://gitcode.com/boostkit/libavif.git` 浅克隆取包（两包都在该仓库根目录），
取到后仍按 sha256 校验。容器内安装 `avifenc` / `avifdec`，`--version` 必须报告 0.9.3，
且 `ldd` 必须把 `libavif.so`、`libaom.so` 解析到私有前缀、不得链接 `libgomp`。

## 采样契约

- 每个场景至少 1 次预热、至少 5 次有效采样（默认 1 + 20，与参考材料一致）；
- 采样值必须有限且为正，解析器不接受补零、缺样本或与 CSV 不一致的样本；
- 6 个场景必须齐全且顺序/名称与清单一致，缺一个就整体失败；
- 解析器同时校验：CSV `status` 全为 `OK`、`iterations` 等于请求样本数、
  `evidence.cpu_pinning=none`、编码器实际线程数为 8、编码与解码摘要存在且稳定。

## 产物

| 文件 | 说明 |
| --- | --- |
| `build_variant.json` | 构建变体、两个源码包摘要、容器镜像 |
| `benchmark_encode.txt` | 容器内完整原始输出（含 `LIBAVIF_BENCH_COMPLETE` 完成标记） |
| `result_bench-libavif.csv` | 参考格式 CSV（6 行，`scenario,iterations,ms_per_image,status`） |
| `evidence.json` | 每个场景的全部样本、CPU 集合、线程数、编码/解码摘要、无绑核声明 |
| `benchmark_libavif.json` | Framework 归一化结果（6 个指标） |
| `runs/<scenario>/rep<i>.json` | 每次采样一条记录（不覆盖、不丢弃） |

## 约束

- 单分支单提交，PR 不合并；
- 全流程禁止 `taskset`、`numactl`、`sched_setaffinity`、`membind` 等绑核绑内存手段；
- 只用开源版源码与默认构建参数，不做任何补丁或调优；
- `optimized` 变体未实现，显式失败，避免把 baseline 数据挂在优化版本名下。
