# lz4 1.10.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32010701863-1`

## 测试环境

| 类型 | 项目 | 固定值 | 测试前 | 测试后 |
|---|---|---|---|---|
| 构建信息 | 请求软件版本 | 1.10.0 | N/A | N/A |
| 构建信息 | 实际软件版本 | 1.10.0 | N/A | N/A |
| 构建信息 | 构建信息记录时间 | 2026-08-17T08:32:23Z | N/A | N/A |
| 系统信息 | 采集时间 | 2026-08-17T08:31:56Z | N/A | N/A |
| 系统信息 | 系统架构 | aarch64 | N/A | N/A |
| 系统信息 | CPU 型号 | 0 | N/A | N/A |
| 系统信息 | CPU 核数 | 256 | N/A | N/A |
| 系统信息 | 操作系统 | Linux-6.6.0-159.4.3.154.oe2403sp4.aarch64-aarch64-with-glibc2.38 | N/A | N/A |
| 系统信息 | 内核 | 6.6.0-159.4.3.154.oe2403sp4.aarch64 | N/A | N/A |
| 系统信息 | Python 版本 | 3.11.6 | N/A | N/A |
| 系统信息 | GCC 版本 | 12.3.1 | N/A | N/A |
| 系统信息 | glibc 版本 | glibc 2.38 | N/A | N/A |
| 系统信息 | NUMA | N/A | N/A | N/A |
| 运行状态 | 采集时间 | N/A | 2026-08-17T08:31:56Z | 2026-08-17T08:41:02Z |
| 运行状态 | 内存状态 | N/A | total        used        free      shared  buff/cache   available<br>Mem:     539263840256  5308624896 534394523648    72445952  2109116416 533955215360<br>Swap:     4294963200           0  4294963200 | total        used        free      shared  buff/cache   available<br>Mem:     539263840256  5678624768 534023430144   447295488  2485334016 533585215488<br>Swap:     4294963200           0  4294963200 |
| 运行状态 | CPU governor | N/A | performance | performance |

## 性能指标

| 指标 | 数值 | 单位 | 优化方向 |
|---|---:|---|---|
| compress_speed_64k | 480.1 | MB/s | 越大越好 |
| decompress_speed_64k | 2682.4 | MB/s | 越大越好 |
| compress_speed_4m | 529.2 | MB/s | 越大越好 |
| decompress_speed_4m | 3340.4 | MB/s | 越大越好 |
