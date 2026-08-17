# lz4 1.10.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32012458198-1`

## 测试环境

### 构建信息

| 项目 | x86 | aarch64 |
|---|---|---|
| 请求软件版本 | N/A | 1.10.0 |
| 实际软件版本 | N/A | 1.10.0 |
| 构建信息记录时间 | N/A | 2026-08-17T08:53:44Z |
| 系统架构 | N/A | aarch64 |

### 系统信息

| 项目 | x86 | aarch64 |
|---|---|---|
| 采集时间 | N/A | 2026-08-17T08:53:26Z |
| 系统架构 | N/A | aarch64 |
| CPU 型号 | N/A | 0 |
| CPU 核数 | N/A | 256 |
| 操作系统 | N/A | Linux-6.6.0-159.4.3.154.oe2403sp4.aarch64-aarch64-with-glibc2.38 |
| 内核 | N/A | 6.6.0-159.4.3.154.oe2403sp4.aarch64 |
| Python 版本 | N/A | 3.11.6 |
| GCC 版本 | N/A | 12.3.1 |
| glibc 版本 | N/A | glibc 2.38 |
| NUMA | N/A | N/A |

## 性能指标

| 指标 | 数值 | 单位 | 优化方向 |
|---|---:|---|---|
| compress_speed_64k | 479.9 | MB/s | 越大越好 |
| decompress_speed_64k | 2681.5 | MB/s | 越大越好 |
| compress_speed_4m | 528.7 | MB/s | 越大越好 |
| decompress_speed_4m | 3339.3 | MB/s | 越大越好 |
