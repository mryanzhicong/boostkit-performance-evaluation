# libavif 0.9.3 开箱（open-box）性能用例

本用例在**私有 openEuler 24.03 LTS SP4 容器内原生运行**，用开源版 libavif 0.9.3
（编码器 AOM 3.2.0）的 AV1 编码时延作为性能指标。测试素材与场景来自 boostkit 开箱测试材料
`Test/libavif`（`bench.py` / `build_install.sh` / `run_bench.sh`），对齐上游
`6c69c13d`（"Simplify benchmark deployment and runtime checks"）的最新口径：
**不绑核、不绑 NUMA、1 次预热 + N 次计时后上报均值**，预热摘要仅记录不逐轮比对，
也不观测/断言编码线程数。

## 与参考材料的关系

| 项目 | 参考材料（上游当前版本） | 本用例 |
| --- | --- | --- |
| 源码 | libavif 0.9.3（sha256 `bcd9a1f5…`）+ AOM 3.2.0（sha256 `34132ae8…`），禁止打补丁 | 相同，构建阶段强校验并断言补丁标记不存在 |
| 编译 | AOM `-Ofast -ffp-contract=off -fPIC`（aom / aom_static / aom_pc 三个 target），libavif `-O3 -ffp-contract=off`，共享库，仅 AOM 后端 | 相同 |
| 输入 | 3 段 1080p 视频首帧 → PNG；只校验文件大小 ≥ 1920×1080×3/2 | 相同，尺寸校验；**不再校验素材与 PNG 的 sha256** |
| 编码 | `avifenc --codec aom --yuv 420 --speed 8 --jobs 8 --min QP --max QP --tilerowslog2 0 --tilecolslog2 2`，QP 20/32 | 相同（原生 8 线程，仅声明不观测） |
| 正确性 | 预热编码/解码各一次并记录摘要；之后不再逐轮比对摘要 | 相同（`encoded_sha256` / `decoded_yuv_sha256` 仅作 evidence） |
| CPU/内存 | 不设置 CPU 亲和性、不绑 NUMA（`NODE=None`） | 相同，**完全不绑**，容器内可用全部 CPU 与 NUMA 节点 |
| 统计量 | 1 次预热 + 20 次计时，上报**均值** | 相同：1 + 20，CSV 与结果 JSON 的 `value` 均为均值 |
| 运行位置 | 宿主机 `/home/test/Test`（脚本自动装依赖、下载源码） | **私有容器**（差异 1），依赖 dnf 容器内安装、源码包本地缓存 |
| 素材路径 | `/home/test/Test/video` | 运行机目录只读挂载到 `/media-input`（差异 2） |
| 素材文件名 | `BQTerrace_1920x1080_60-dianbo.yuv` | 主名相同，另接受 `BQTerrace_1920x1080_60.yuv`（runner 存档旧名，差异 3） |

因此本用例与上游参考材料只保留 **容器内运行、路径映射、素材文件名别名** 三项差异；
其余采样、计时、统计与输入校验口径完全一致。参考材料的绝对值可作参考，但跨平台对比
请使用同架构下本用例自己的结果。

## 指标

6 个场景，单位 ms，方向 lower_is_better，`value` 为 20 次计时的均值：

| 场景 | 分组 | 说明 |
| --- | --- | --- |
| `BQTerrace_qp20_c8` / `BQTerrace_qp32_c8` | AV1编码 / BQTerrace | QP20 / QP32 |
| `Film2012_qp20_c8` / `Film2012_qp32_c8` | AV1编码 / Film2012 | QP20 / QP32 |
| `messi_qp20_c8` / `messi_qp32_c8` | AV1编码 / messi | QP20 / QP32 |

每个场景 1 次预热 + 20 次采样（`LIBAVIF_SAMPLES` 可覆盖，最少 5），上报均值，
全部原始样本落盘 `runs/<scenario>/rep<i>.json`；`mean_ms` 与 `value` 一致。

## 目录结构

```
libavif_test.sh                    独立运行入口（四个阶段一次跑完）
case.yaml                          Framework 用例描述（阶段、超时、产物、指标）
fixtures/media.json                测试素材与 6 个场景清单（文件名/别名/字节数/编码参数）
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

| 文件（主名） | 可接受别名 | 字节 |
| --- | --- | --- |
| `BQTerrace_1920x1080_60-dianbo.yuv` | `BQTerrace_1920x1080_60.yuv` | 1,866,240,000 |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | — | 4,665,600,000 |
| `messi_1920x1080_25_1000.yuv` | — | 3,110,400,000 |

查找顺序：`LIBAVIF_MEDIA_DIR` > `/home/runner/software/media/video` > `/home/test/Test/video`。
harness 按 `filename` → `alternate_filenames` 顺序解析，全部缺失时报错并列出所有候选文件名。
素材在测试阶段只读挂载进容器 `/media-input`，仓库里只提交 `fixtures/media.json` 中的清单
（文件名、别名、字节数、帧数），**不再提交或校验摘要**。

## 构建产物

两个源码包优先取运行机持久目录 `/home/runner/software/libavif/downloads/`，
缺失时才从 `https://gitcode.com/boostkit/libavif.git` 浅克隆取包（两包都在该仓库根目录），
取到后仍按 sha256 校验。容器内安装 `avifenc` / `avifdec`，只校验两个二进制存在且
`--version` 报告 0.9.3（与上游当前 `build_install.sh` 一致）；上游已移除的动态链接检查
不再保留。

## 采样契约

- 每个场景至少 1 次预热、至少 5 次有效采样（默认 1 + 20，与参考材料一致）；
- 预热：编码一次并记录编码结果 sha256，解码一次并记录 Y4M sha256，写入 evidence，
  之后**不再与任何一轮结果比较**；
- 计时：纯 `avifenc` 调用，包含命令启动、PNG 读取与文件写入；每次采样写一条
  `runs/<scenario>/rep<i>.json`；
- 统计量固定为**均值**（CSV `ms_per_image`、结果 JSON `value`、`mean_ms` 三处一致）；
- 采样值必须有限且为正，解析器不接受补零、缺样本或与 CSV 不一致的样本；
- 6 个场景必须齐全且顺序/名称与清单一致，缺一个就整体失败；
- 解析器同时校验：CSV `status` 全为 `OK`、`iterations` 等于请求样本数、
  `evidence.statistic="mean"`、`cpu_pinning=none`、`memory_pinning=none`、
  `affinity="unbound"`、两个摘要字段为合法 sha256 格式（仅格式，不比内容）；
  不再断言编码线程数，也不再逐轮比较固定摘要。

## 产物

| 文件 | 说明 |
| --- | --- |
| `build_variant.json` | 构建变体、两个源码包摘要、容器镜像 |
| `benchmark_encode.txt` | 容器内完整原始输出（含 `LIBAVIF_BENCH_COMPLETE` 完成标记） |
| `result_bench-libavif.csv` | 参考格式 CSV（6 行，`scenario,iterations,ms_per_image,status`，值为均值） |
| `evidence.json` | `cpus_allowed`（可用 CPU 数）、`cpu_pinning="none"`、`memory_pinning="none"`、`affinity="unbound"`、声明的 `native_threads`、`warmups`、`samples`、`statistic="mean"`、`source_mode="unpatched"`；每个场景的 `group/subgroup/qp`、`samples_ms`、`mean_ms`、预热 `encoded_sha256` / `decoded_yuv_sha256` |
| `benchmark_libavif.json` | Framework 归一化结果（6 个指标，`value` 为均值） |
| `runs/<scenario>/rep<i>.json` | 每次采样一条记录（不覆盖、不丢弃） |

## 约束

- 单分支单提交，PR 不合并；
- 全流程禁止 `taskset`、`numactl`、`sched_setaffinity`、`membind` 等绑核绑内存手段；
- 只用开源版源码与默认构建参数，不做任何补丁或调优；
- `optimized` 变体未实现，显式失败，避免把 baseline 数据挂在优化版本名下。
