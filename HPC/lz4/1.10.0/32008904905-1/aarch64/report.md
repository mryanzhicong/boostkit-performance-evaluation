# lz4 1.10.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32008904905-1`

## 测试环境

### 构建信息

| 项目 | 值 |
|---|---|
| 请求软件版本 | 1.10.0 |
| 实际软件版本 | 1.10.0 |
| 构建信息记录时间 | 2026-08-17T08:08:26Z |

### 系统信息

| 项目 | 值 |
|---|---|
| 采集时间 | 2026-08-17T08:08:07Z |
| 系统架构 | aarch64 |
| CPU 型号 | 0 |
| CPU 核数 | 256 |
| 操作系统 | Linux-6.6.0-159.4.3.154.oe2403sp4.aarch64-aarch64-with-glibc2.38 |
| 内核 | 6.6.0-159.4.3.154.oe2403sp4.aarch64 |
| Python 版本 | 3.11.6 |
| GCC 版本 | 12.3.1 |
| glibc 版本 | glibc 2.38 |
| NUMA | N/A |

### 运行状态

| 项目 | 测试前 | 测试后 |
|---|---|---|
| 采集时间 | 2026-08-17T08:08:07Z | 2026-08-17T08:09:00Z |
| 内存状态 | total        used        free      shared  buff/cache   available<br>Mem:     539263840256  5335080960 534368694272    72077312  2108129280 533928759296<br>Swap:     4294963200           0  4294963200 | total        used        free      shared  buff/cache   available<br>Mem:     539263840256  5755817984 533947351040   446566400  2483458048 533508022272<br>Swap:     4294963200           0  4294963200 |
| CPU governor | performance | performance |

## 性能指标

| 指标 | 数值 | 单位 | 优化方向 |
|---|---:|---|---|
| compress_speed_64k | 480.1 | MB/s | 越大越好 |
| decompress_speed_64k | 2682.0 | MB/s | 越大越好 |
| compress_speed_4m | 527.6 | MB/s | 越大越好 |
| decompress_speed_4m | 3342.3 | MB/s | 越大越好 |
