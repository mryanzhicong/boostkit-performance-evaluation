# libwebp 1.2.1 开箱（open-box）性能用例

本用例在**私有 openEuler 24.03 LTS SP4 容器内原生运行**，测量开源版 libwebp 1.2.1
的**无损编码（lossless encode）时延**。测试方法与场景来自 boostkit 开箱测试材料
`Test/libwebp` @ `21154155`（2026-11-07，"Restore near-parity WebP and x265
benchmark cases"）中的 `bench.py` / `generate_inputs.py` / `build_install.sh`，
移植时**只调整运行位置（容器/路径）**，命令、输入生成、预热与计时方式逐项保持一致。

## 与参考材料的关系

| 项目 | 参考材料 `Test/libwebp` @ 21154155 | 本用例 |
| --- | --- | --- |
| 源码 | libwebp 1.2.1，sha256 `808b98d2…` | 相同，构建阶段强校验 |
| 编译 | CMake：`-O3 -DNDEBUG -ffp-contract=off`、`-DBUILD_SHARED_LIBS=ON`、SIMD/线程开启，仅构建 `cwebp`/`dwebp` | 相同（`scripts/builders/base.sh`） |
| 输入 | `generate_inputs.py` 确定性生成 RGBA dashboard PNG：1920x1080 `dashboard.png`，再最近邻下采样为 1280x720 `dashboard_720p.png`；不使用外部视频/图片 | 相同（`scripts/harness/generate_inputs.py`，生成字节逐字节一致） |
| 编码命令 | `cwebp -quiet -lossless -z 0 -exact -mt <png> -o <webp>` | 相同 |
| 解码校验 | 预热后 `dwebp <webp> -quiet -pam -o <pam>`，解出像素字节数必须等于 `width*height*4` | 相同（尺寸不符即失败） |
| 计时范围 | 单次计时包含进程启动、PNG 读取、无损压缩与 WebP 写文件；素材生成与解码校验不计时 | 相同 |
| 预热/迭代 | 1 次预热 + 20 次计时，取**均值**（`statistic=mean`） | 相同，默认值一致 |
| 摘要 | 记录每场景 `input_sha256` / `output_sha256`，不做相等断言 | 相同（只记录进 `evidence.json`） |
| CPU/内存 | 不绑核、不绑 NUMA（`cwebp -mt` 在 `-z 0` 下实际 1 线程，只记录不断言） | 相同，evidence 记录 `affinity=unbound`、`cpu_pinning=none`、`memory_pinning=none` |
| 运行位置 | 宿主机 `/home/test/Test`，root 直装依赖 | **仅存差异**：私有 openEuler 24.03 LTS SP4 容器，路径由 CLI 传入 |

因为不绑核，本用例的绝对值不能与参考材料任意机器上的数字直接对比；跨平台/跨版本
对比请看同架构下本用例自己的结果。

## 指标

共 2 项，均为无损编码时延（毫秒/张，越小越好，`statistic=mean`）：

| 指标（场景名） | 分组 | 分辨率 | 说明 |
| --- | --- | --- | --- |
| `dashboard_lossless_z0` | `无损编码` / `dashboard` | 1920x1080 | 1920x1080 RGBA dashboard PNG 无损编码的单次进程耗时均值 |
| `dashboard_720p_lossless_z0` | `无损编码` / `dashboard` | 1280x720 | 1280x720（1080p 最近邻下采样）RGBA dashboard PNG 无损编码的单次进程耗时均值 |

## 目录结构

```
libwebp_test.sh                    独立运行入口（四个阶段一次跑完）
case.yaml                          Framework 用例描述（阶段、超时、产物、指标）
fixtures/media.json                场景清单（名称/分组/分辨率/编码参数；无外部素材、无固定摘要）
scripts/common.sh                  公共配置 + 生成式容器运行时块
scripts/builders/{dispatch,base,optimized}.sh   构建阶段（base 为唯一实现）
scripts/stages/{start,test,stop}.sh             运行/测试/清理阶段
scripts/harness/generate_inputs.py 确定性生成 dashboard PNG（容器内执行）
scripts/harness/bench_encode.py    无损编码计时器（容器内执行）
scripts/results/parse_benchmark.py 严格结果校验与 benchmark_libwebp.json 生成
tests/test_container_lifecycle.py  离线契约测试（无 Docker、无素材也能跑）
```

## 依赖

容器内依赖（构建阶段由 dnf 自动安装）：

```
gcc gcc-c++ make cmake tar curl python3 libpng-devel libjpeg-turbo-devel zlib-devel
```

`cwebp` 读 PNG 需要 `libpng-devel`/`zlib-devel`（`libjpeg-turbo-devel` 与参考材料
依赖清单保持一致）。x86_64 额外安装 `nasm`。宿主机只需 Docker、curl、tar、sha256sum。

## 运行方式

CI（Framework 六阶段，`prepare` → `build` → `start` → `test` → `stop` → `finalize`）：

```bash
python3 framework/run_case.py --case software/Media/libwebp/case.yaml --version 1.2.1 \
    --architecture x86_64 --run-id "$PERF_RUN_ID"
```

工作站复现：

```bash
LIBWEBP_SAMPLES=5 ./libwebp_test.sh --keep-workdir
```

## 产物

结果目录位于 `.perf-output/Media/libwebp/1.2.1/<arch>/<run_id>/`：

| 文件 | 说明 |
| --- | --- |
| `build_variant.json` | 构建变体、源码包摘要、容器镜像 |
| `benchmark_encode.txt` | 容器内完整原始输出（含 `LIBWEBP_BENCH_COMPLETE` 完成标记） |
| `result_bench-libwebp.csv` | 参考格式 CSV（`scenario,iterations,ms_per_image,status`，每场景一行） |
| `evidence.json` | 每场景全部样本、均值、输入/输出 sha256、命令、`cpus_allowed`、无绑核声明（`statistic=mean`） |
| `benchmark_libwebp.json` | Framework 归一化结果（`results` 对象，指标名 = 场景名，2 个指标） |
| `runs/<scenario>/rep<i>.json` | 每次采样一条记录（不覆盖、不丢弃） |

## 采样契约

- 至少 1 次预热、至少 5 次有效采样（默认 1 + 20，与参考材料一致）；
- 上报统计量为**均值**（`mean`），原始样本全部写入 `runs/` 与 `evidence.json`；
- 采样值必须有限且为正，解析器不接受补零、缺样本、CSV 与样本均值不一致
  （容差 `1e-6`）或与 manifest 场景顺序不一致的结果；
- 解析器同时校验：CSV 恰好两行且 `status=OK`、`iterations` 与请求样本数一致、
  evidence 声明 `statistic=mean`、`cpu_pinning=none`、`memory_pinning=none` 且记录
  `cpus_allowed`、每场景 `input_sha256`/`output_sha256` 格式合法；
- 不对 PNG/WebP/PAM 摘要、实际线程数做相等断言。

## 约束

- 全流程禁止任何 CPU 绑定 / NUMA 内存绑定手段（CPU affinity、NUMA memory binding），
  evidence 中如实记录 `affinity=unbound`、`cpu_pinning=none`、`memory_pinning=none`；
- 只用开源版源码与默认构建参数，不做任何补丁或调优；
- 单分支单提交，PR 不合并，不更新 baseline；
- `optimized` 变体未实现，显式失败，避免把 baseline 数据挂在优化版本名下。
