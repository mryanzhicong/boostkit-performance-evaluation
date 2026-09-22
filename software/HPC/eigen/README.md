# Eigen 性能测试说明

本目录从 Eigen 官方仓库（gitlab.com/libeigen/eigen）克隆 `5.0.1` 标签源码，使用源码树自带的
官方 `bench/perf_monitoring` 性能监控套件构建基准二进制，并按官方 `runall.sh` 的负载矩阵
（8 负载 × 3 标量 = 24 组合）执行测试。Framework 通过 `case.yaml` 调用 `eigen_test.sh` 的
四阶段接口；直接执行入口脚本会走同一流程。

Eigen 5.0.0 起采用语义化版本（见源码 `Eigen/Version` 注释），当前清单支持 `5.0.1`，默认版本
`5.0.1`。

## 构建与安装

Eigen 是 header-only 模板库，无需安装任何系统级组件。脚本从官方 gitlab 标签浅克隆
（`git clone --branch 5.0.1 --depth 1`），以 `git describe --tags --exact-match` 校验标签
精确匹配，并读取 `Eigen/Version` 头中的 `EIGEN_VERSION_STRING` 与请求版本交叉验证。脚本检查
`git`、`python3`、`g++`（需支持 C++14）和 `tee`，缺失时报错退出，不做系统安装。

基准二进制按官方 `run.sh` 的编译配方构建（源码零修改）：

```bash
g++ -O3 -DNDEBUG -march=native -I <eigen-source> \
    bench/perf_monitoring/<workload>.cpp -DSCALAR=<scalar> -o <binary>
```

`bench/perf_monitoring` 的源码以 `#include "eigen_src/Eigen/Core"` 相对路径引用被测源码，
官方 `run.sh` 通过在该目录下克隆源码满足这一布局；本用例以指向已校验检出目录的
`eigen_src` 符号链接提供完全相同的布局，不重复下载。唯一的官方脚本偏离是引用修正：
官方 `run.sh` 未加引号地传递 `-DSCALAR=std::complex<double>`，会被 shell 在 `<` 处拆断，
本用例以正确引用传递同一编译参数，使官方 complex 标量基准可以实际构建。

共构建 8 负载 × 3 标量 = 24 个官方二进制，并行度由 `EIGEN_BUILD_JOBS` 控制（默认 4）。

官方 `runall.sh` 负载集中的 `lazy_gemm` 被裁剪：其源码以 `#include "../../BenchTimer.h"`
引用计时头，该路径解析到仓库根目录（`BenchTimer.h` 实际位于 `bench/` 下），官方 `run.sh`
配方在 5.0.1 树内无法编译该负载；其余 8 个负载均以 `../BenchTimer.h` 引用、编译正常。本用例
不修改官方源码，直接从负载集中剔除该成员。

## 测试数据与性能测试

`start` 阶段以官方 `gemm_settings.txt` 首行（`8 8 8`）构造单点阶梯冒烟运行 `d_gemm`，校验
输出为正的 GFLOPS 值。

`test` 阶段按官方 `runall.sh` 的负载顺序与 `run.sh` 的标量顺序执行全部 24 个组合，每个组合
使用官方对应 settings 文件驱动完整阶梯：

| 负载 | 内核 | 官方 settings | 阶梯点数 |
|---|---|---|---:|
| `gemm` | `C.noalias() += A * B` | `gemm_settings.txt` | 15 |
| `gemv` | `C.noalias() += A * B` | `gemv_settings.txt` | 11 |
| `gemvt` | `B.noalias() += A.transpose() * C` | `gemv_settings.txt` | 11 |
| `trmv_up` | `C.noalias() += A.triangularView<Upper>() * B` | `gemv_square_settings.txt` | 13 |
| `trmv_lo` | `C.noalias() += A.triangularView<Lower>() * B` | `gemv_square_settings.txt` | 13 |
| `trmv_upt` | `B.noalias() += A.transpose().triangularView<Upper>() * C` | `gemv_square_settings.txt` | 13 |
| `trmv_lot` | `B.noalias() += A.transpose().triangularView<Lower>() * C` | `gemv_square_settings.txt` | 13 |
| `llt` | `Eigen::internal::llt_inplace<Scalar, Lower>::blocked(C)` | `gemm_square_settings.txt` | 11 |

标量类型为 `float`、`double`、`std::complex<double>`。每个二进制输出一行空格分隔的 GFLOPS
值（每点一个），由官方 `BenchTimer`（多次尝试取最优）测量。每组合的完整原始输出保存在
`benchmark_perf_monitoring.json` 相应结果的 `raw_output` 字段，逐点 `size`/`gflops` 阶梯
保存在 `ladder` 字段。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/eigen/eigen_test.sh \
  --version 5.0.1 \
  --results-dir /home/runner/boostkit-perf/eigen/results/5.0.1
```

## 指标

报告按 9 个负载分组，每组 3 个标量指标（`<workload>/<scalar>`）。每个指标取该组合官方阶梯
全部阶梯点 GFLOPS 的中位数（`gflops_median`），单位 GFLOPS，越大越好；同一组合的峰值
（`gflops_peak`）作为上下文保留在基准 JSON 中，不作为跨架构指标。任一组合输出的值数量与
settings 行数不符、或存在非正值时测试失败。

## 结果与清理

必需产物为 `benchmark_perf_monitoring.json`，包含 24 组结构化结果、逐点阶梯、每组原始输出
以及编译参数信息。没有后台服务需要停止；任务结束只删除本次运行的源码、基准二进制和临时
目录（限 `/home/runner/boostkit-perf/eigen/local-*`）。
