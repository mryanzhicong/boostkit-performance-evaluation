# lz4 1.10.0 性能结果

- 分类：`HPC`
- Run ID：`32006206657-1`

## aarch64

# lz4 1.10.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32006206657-1`

| 指标 | 数值 | 单位 | 优化方向 |
|---|---:|---|---|
| compress_speed_64k | 479.1 | MB/s | 越大越好 |
| decompress_speed_64k | 2682.2 | MB/s | 越大越好 |
| compress_speed_4m | 528.6 | MB/s | 越大越好 |
| decompress_speed_4m | 3341.3 | MB/s | 越大越好 |

## x86_64

# lz4 1.10.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32006206657-1`

| 指标 | 数值 | 单位 | 优化方向 |
|---|---:|---|---|
| compress_speed_64k | 651.0 | MB/s | 越大越好 |
| decompress_speed_64k | 3480.8 | MB/s | 越大越好 |
| compress_speed_4m | 678.7 | MB/s | 越大越好 |
| decompress_speed_4m | 4365.3 | MB/s | 越大越好 |

## 跨架构对比

# lz4 1.10.0 跨架构对比

| 指标 | 优化方向 | x86_64 | aarch64 | ARM/x86 原始比值 | 相对性能 |
|---|---|---:|---:|---:|---:|
| compress_speed_4m | 越大越好 | 678.7 | 528.6 | 0.7788 | 0.7788 |
| compress_speed_64k | 越大越好 | 651.0 | 479.1 | 0.7359 | 0.7359 |
| decompress_speed_4m | 越大越好 | 4365.3 | 3341.3 | 0.7654 | 0.7654 |
| decompress_speed_64k | 越大越好 | 3480.8 | 2682.2 | 0.7706 | 0.7706 |

> 相对性能大于 1 表示 aarch64 更优，小于 1 表示 x86_64 更优。
