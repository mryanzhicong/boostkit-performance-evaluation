# libwebp 1.2.1 开箱（open-box）性能用例

本用例在**私有 openEuler 24.03 LTS SP4 容器内原生运行**，把开源版 libwebp 1.2.1
的有损解码时延作为性能指标。测试素材与场景来自 boostkit 开箱测试材料
`Test/libwebp`（bench.py / build_install.sh / run_bench.sh），移植时**只去掉绑核与绑内存**，
其余（输入切片、质量参数、金标准校验、计时方式）逐项保持一致。

## 与参考材料的关系

| 项目 | 参考材料 | 本用例 |
| --- | --- | --- |
| 源码 | libwebp 1.2.1（sha256 `808b98d2…`） | 相同，构建阶段强校验 |
| 编译 | CMake `-O3 -DNDEBUG -ffp-contract=off`、SIMD/线程开启 | 相同 |
| 输入 | Film2012 首帧 → PNG → PPM | 相同，PNG/WebP/PAM 三个 sha256 全部锁定 |
| 编码 | `cwebp -q 85 -m 4` | 相同 |
| 解码 | `dwebp -mt -quiet -pam -o /dev/null` | 相同（原生 2 线程） |
| 计时 | 1 次预热 + 20 次迭代，取均值 | 1 次预热 + 20 次采样，**上报中位数**，均值另存 evidence.json |
| CPU/内存 | `numactl`/`sched_setaffinity` 绑 2 核 + 绑 NUMA 节点 | **完全不绑**，容器内进程可用全部 CPU 与 NUMA 节点 |
| 运行位置 | 宿主机 `/home/test/Test` | 私有容器（镜像 `openEuler-24.03-LTS-SP4`），素材只读挂载 `/media-input` |

因为不绑核，本用例的绝对值与参考材料里的 9.31 ms（鲲鹏 950）/ 9.98 ms（EPYC 9654）
不可直接对比；跨平台对比请看同架构下本用例自己的结果。

## 指标

| 指标 | 单位 | 方向 | 说明 |
| --- | --- | --- | --- |
| `Film2012_lossy_decode_pam_c2` | ms | lower_is_better | 单张 1920x1080 图像从 WebP 解码为 RGBA PAM 并写 `/dev/null` 的耗时（中位数） |

分组信息：`group=RGB解码`、`subgroup=Film2012`。

## 目录结构

```
libwebp_test.sh                    独立运行入口（四个阶段一次跑完）
case.yaml                          Framework 用例描述（阶段、超时、产物、指标）
fixtures/media.json                测试素材清单（文件名/字节数/sha256/场景参数）
scripts/common.sh                  公共配置 + 生成式容器运行时块
scripts/builders/{dispatch,base,optimized}.sh   构建阶段（base 为唯一实现）
scripts/stages/{start,test,stop}.sh             运行/测试/清理阶段
scripts/harness/bench_decode.py    解码场景计时器（容器内执行）
scripts/results/parse_benchmark.py 严格结果校验与 benchmark_libwebp.json 生成
tests/test_container_lifecycle.py  离线契约测试（无 Docker、无素材也能跑）
```

## 运行方式

CI（Framework 六阶段）：

```bash
python3 framework/run_case.py --case software/Media/libwebp/case.yaml --version 1.2.1 \
    --architecture x86_64 --run-id "$PERF_RUN_ID"
```

工作站复现：

```bash
LIBWEBP_SAMPLES=5 ./libwebp_test.sh --keep-workdir
```

## 素材

镜像里不含测试素材。运行机需在下列任一位置提供
`Film2012_1920x1080_25_8bit_8Mbps.yuv`（4,665,600,000 字节）：

1. `LIBWEBP_MEDIA_DIR` 环境变量指定的目录；
2. `/home/runner/software/media/video`（推荐，`SHA256SUMS` 一并归档）；
3. `/home/test/Test/video`（原始素材机路径）。

素材在测试阶段以只读方式挂载进容器 `/media-input`，仓库里只提交 `fixtures/media.json`
中的摘要，不提交任何 YUV 文件。

## 构建产物

源码包优先取运行机持久目录 `/home/runner/software/libwebp/downloads/`，
缺失时才联网下载（Google Storage 及镜像线路），下载后仍按 sha256 校验。
容器内构建产物为 `cwebp`、`dwebp`，`-version` 必须报告 1.2.1，否则测试阶段直接失败。

## 采样契约

- 至少 1 次预热、至少 5 次有效采样（默认 1 + 20，与参考材料一致）；
- 采样值必须有限且为正，解析器不接受补零、缺样本或与 CSV 不一致的样本；
- 上报统计量为中位数，全部原始样本保存在 `results/runs/<scenario>/rep<i>.json` 与 `evidence.json`；
- 解析器同时校验：CSV 只有一行且 `status=OK`、`iterations` 与请求样本数一致、
  `evidence.cpu_pinning=none`、`dwebp -mt` 实际线程数为 2、PNG/WebP/PAM 摘要与清单一致。

## 产物

| 文件 | 说明 |
| --- | --- |
| `build_variant.json` | 构建变体、源码包摘要、容器镜像 |
| `benchmark_decode.txt` | 容器内完整原始输出（含 `LIBWEBP_BENCH_COMPLETE` 完成标记） |
| `result_bench-libwebp.csv` | 参考格式 CSV（`scenario,iterations,ms_per_image,status`） |
| `evidence.json` | 全部样本、CPU 集合、线程数、输入摘要、无绑核声明 |
| `benchmark_libwebp.json` | Framework 归一化结果（`results` 对象，指标名 = 场景名） |
| `runs/<scenario>/rep<i>.json` | 每次采样一条记录（不覆盖、不丢弃） |

## 约束

- 单分支单提交，PR 不合并；
- 全流程禁止 `taskset`、`numactl`、`sched_setaffinity`、`membind` 等绑核绑内存手段；
- 只用开源版源码与默认构建参数，不做任何补丁或调优；
- `optimized` 变体未实现，显式失败，避免把 baseline 数据挂在优化版本名下。
