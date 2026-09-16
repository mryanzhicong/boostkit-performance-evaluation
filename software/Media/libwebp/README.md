# libwebp 性能测试说明

本目录从 libwebp 官方仓库（chromium.googlesource.com/webm/libwebp）克隆
`v1.6.0` 标签源码（当前 stable release），构建官方命令行工具 `cwebp` 与
`dwebp`，并以二者自带的官方计时插桩（`-v` 模式的 `Time to encode/decode
picture` 输出）执行 WebP 编码与解码延迟测试。软件入口为
`libwebp_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 libwebp `1.6.0`。新增版本时，必须同步确认官方仓库存在对应
`v<版本>` 标签，不能凭空声明。

## 构建与安装

libwebp 不安装任何系统级组件，全部构建在任务隔离工作目录中：

1. 从官方仓库浅克隆 `v1.6.0` 标签（`git clone --branch v1.6.0 --depth 1`），
   以 `git describe --tags --exact-match` 校验标签精确匹配，并读取上游
   `configure.ac` 的 `AC_INIT([libwebp], [1.6.0], ...)` 版本声明与请求版本
   交叉验证。
2. 运行官方 CMake 构建并生成基准所需工具：

```bash
cmake -S libwebp-source -B libwebp-source/build -DCMAKE_BUILD_TYPE=Release
cmake --build libwebp-source/build --target cwebp dwebp --parallel 8
```

   SIMD 优化（x86 SSE2/AVX2、aarch64 NEON）由官方 CMake 按构建架构自动
   启用，无需任何架构相关开关。构建完成后以 `cwebp -version` 的输出与
   请求版本做运行时交叉验证（首行为 libwebp 版本号）。
3. 以 `scripts/gen_ppm.py` 生成两档固定负载图像（PPM P6 格式，cwebp 原生
   支持且无需 libpng 等外部图像库）：`1920x1080` 与 `3840x2160`，内容为
   固定 32 位 LCG 伪随机像素（纯整数运算，跨架构逐字节一致，编码器每次
   看到的输入完全相同）。

## 基准工具

libwebp 官方仓库不带独立基准工具（`examples/` 下均为功能工具，`tests/`
只有 fuzzer），但官方 CLI 自带维护者自己的计时插桩：`-v` 模式下
`examples/cwebp.c` 在纯 `WebPEncode` 调用结束后打印
`Time to encode picture: X.XXXs`，`examples/dwebp.c` 在纯 `DecodeWebP`
调用结束后打印 `Time to decode picture: X.XXXs`——两者均不含文件读写
I/O，正是编解码核心路径的官方耗时口径。本用例直接使用该官方输出。

`start` 阶段以 1080p 有损模式冒烟运行一次编码 + 解码，校验两条官方计时
行完整出现。

`test` 阶段运行完整 8 场景矩阵（官方 CLI 参数，每场景预热 1 次后测量
5 次取中位数）：

| 操作 | 官方命令 | 模式参数 |
|---|---|---|
| 编码 | `cwebp -v [-z 6] <load>.ppm -o <load>_<mode>.webp` | 有损：默认设置（质量 75）；无损：官方文档的 `-z 6` 预设 |
| 解码 | `dwebp -v -ppm <load>_<mode>.webp -o <load>_<mode>_decode.ppm` | 解码输入为同模式编码产物 |

负载 × 模式组合为：

| 负载 | 有损（cwebp 默认 q75） | 无损（cwebp -z 6） |
|---|---|---|
| `1920x1080` | 编码 + 解码 | 编码 + 解码 |
| `3840x2160` | 编码 + 解码 | 编码 + 解码 |

官方 `-mt` 多线程开关不纳入矩阵：实测 libwebp 有损管线基本单线程
（1080p 0.302s → 0.293s、4K 1.193s → 1.186s，差距 < 3%），线程阶梯只会
测量到调度噪声。解码输出写入工作目录临时文件（写盘时间不计入官方
decode 计时，计时仅覆盖 `DecodeWebP` 调用）。

任一场景 CLI 退出非零、计时行缺失、或 `cwebp -version` 与请求版本不符时
测试失败。完整原始输出保留为 `webp_benchmark_raw.log`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop 并
保存同样的产物。例如：

```bash
bash software/Media/libwebp/libwebp_test.sh \
  --version 1.6.0 \
  --results-dir /home/runner/boostkit-perf/libwebp/results/1.6.0
```

## 指标

每个"操作 + 负载 + 模式"组合一个指标，不做平均、加权或跨场景聚合。因此
总计为：

```text
2 个操作 × 2 个负载 × 2 个压缩模式 = 8 个指标
```

| 官方输出字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `Time to encode/decode picture` | `cwebp <负载> <模式>: median` / `dwebp <负载> <模式>: median` | ms | 越小越好 | 单次编码/解码耗时中位数（5 次测量） |

报告按"操作 + 负载"分组展示（如 `encode 1920x1080`），每组有损/无损两个
模式；同一场景的逐次样本保留在基准 JSON 的 `samples` 字段中，不作为跨架构
指标。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `webp_benchmark_raw.log`：官方 CLI 完整原始输出；
- `results.json`：8 个结构化指标及其来源文件名。

没有后台服务需要停止（CLI 跑完即退）；任务结束只删除本次运行的源码、构建
产物、负载图像和临时文件（限
`/home/runner/boostkit-perf/libwebp/local-*`）。Framework 随后执行 Runner 级
环境清理。
