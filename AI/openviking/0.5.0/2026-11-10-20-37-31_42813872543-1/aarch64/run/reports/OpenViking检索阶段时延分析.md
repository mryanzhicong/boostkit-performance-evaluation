# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.056050s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000494 | 0.882% |
| Query Embedding | 生成查询向量 | 0.048140 | 85.887% |
| 向量召回 | 召回语义相似记忆 | 0.002706 | 4.828% |
| 结果处理 | 整理候选并转换返回结构 | 0.000016 | 0.028% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.004694 | 8.375% |
|  |  | 0.056050 | 100.000% |

**结论：检索耗时主要由Query Embedding决定。**

### 1.1 效果指标

| 指标 | 数据 |
|---|---|
| 记忆上下文Prompt Token | 3635.35/question |
| 完整上下文Prompt Token | 17449.62/question |
| Prompt Token节省 | 79.167% |
| 回答正确率 | 0/152（0.00%） |

## 2. 实际执行流程

```text
请求准备 -> 集合检查 -> Query Embedding -> 向量召回
                                      |
                                      v
                         候选处理 -> 结构转换 -> 接口返回
                                      |
                                      v
客户端初始化 -> 记忆检索 -> 上下文筛选 -> 记忆读取 -> Prompt准备 -> 回答LLM -> 响应解析
```

## 3. 各阶段拆解

### 3.1 检索HTTP请求

父阶段平均耗时：**0.056050s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000494 | 0.882% |
| Query Embedding | 生成查询向量 | 0.048140 | 85.887% |
| 向量召回 | 召回语义相似记忆 | 0.002706 | 4.828% |
| 结果处理 | 整理候选并转换返回结构 | 0.000016 | 0.028% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.004694 | 8.375% |
| 合计 |  | 0.056050 | 100.000% |

**结论：Query Embedding占85.887%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.000494s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000017 | 3.433% |
| 集合检查 | 检查目标集合与检索器 | 0.000477 | 96.567% |
| 合计 |  | 0.000494 | 100.000% |

**结论：集合检查占96.567%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000016s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000007 | 41.855% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 12.531% |
| 结果处理内部 | 结果处理调度 | 0.000007 | 45.614% |
| 合计 |  | 0.000016 | 100.000% |

**结论：结果处理内部占45.614%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.429181s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.009340 | 2.176% |
| 记忆检索 | 查询相关记忆 | 0.058692 | 13.675% |
| 上下文筛选 | 选择候选记忆 | 0.000035 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.248290 | 57.853% |
| 重排 | 调整候选顺序 | 0.003448 | 0.803% |
| Prompt准备 | 构造回答输入 | 0.086551 | 20.167% |
| 回答LLM | 生成最终回答 | 0.022797 | 5.312% |
| 响应解析 | 解析回答结果 | 0.000028 | 0.006% |
| 合计 |  | 0.429181 | 100.000% |

**结论：记忆读取占57.852%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-10T20:17:52+08:00 |
| 数据集SHA-256 | 79fa87e90f04081343b8c8debecb80a9a6842b76a7aa537dc9fdf651ea698ff4 |
| 会话 / 输入消息 | 19 / 419 |
| 写入提交 | 61 |
| 检索问题 | 152 |
| 问答结果 | 152 |
| 执行轮次 | 写入、检索、问答、Token对照、质量评分各1轮 |
| 最终失败 | 0 |

### B. 测量环境

| 项目 | 环境 |
|---|---|
| 执行位置 | 远程原生Linux服务器 |
| 操作系统 | Linux-6.6.0-132.0.0.111.oe2403sp3.aarch64-aarch64-with-glibc2.38 |
| 架构 | aarch64 |
| CPU | 384 vCPU / Kunpeng 950 |
| 内存 | 1505.35 GiB |
| Python | 3.11.6 |
| OpenViking | OpenViking v0.5.0 (official benchmark kit 48T96G, aarch64, container, out-of-the-box) |
| OV版本 | OpenViking v0.5.0 (official benchmark kit 48T96G, aarch64, container, out-of-the-box) |
| 源码提交 | b2b3df1fb5d845552a87f1efde8d5ddf5018c66b |
| 服务 | 独立进程、独立存储、服务器本地HTTP服务 |

### C. 配置

| 项目 | 配置 |
|---|---|
| LLM | mock-chat |
| Embedding | mock-embedding，1024维 |
| 模型服务 | OpenAI-compatible API |
| 写入方式 | 会话按时间顺序写入 |
| 检索并发 | 4 |
| 问答并发 | 8 |
| 检索上下文 | 最多50条、30,000字符 |
| 重排 | 关闭 |

### D. 口径与限制

- 写入采用任务内部耗时；检索采用HTTP耗时；问答采用客户端总耗时。
- 平均值按全部提交或请求计算，占比采用平均耗时之比。
- 并行阶段取较慢分支；余项为父阶段减去已计时子项。
- 跨会话合并LLM：未触发。
- Provider耗时包含网络、远端处理与排队时间。
- 本地交付保留脱敏遥测与测量数据，服务器保留运行日志。

### E. 检索统计

| 指标 | 平均 | P50 | P95 |
|---|---:|---:|---:|
| 检索耗时(s) | 0.056050 | 0.055894 | 0.062571 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_27815df820124e0da174c1f3eca2b631 | 39 | 0.080483 | 0.000016 | 0.001317 | 0.053454 | 0.001564 | 0.000007 | 0.000003 |
| 1 | sample_0_qa1 | tm_2aa65c455ee841fb9a9f4da8081b244b | 39 | 0.046606 | 0.000020 | 0.002328 | 0.012246 | 0.009176 | 0.000007 | 0.000003 |
| 2 | sample_0_qa2 | tm_bf4b7ed3426348cd8989bd487f96950d | 39 | 0.037133 | 0.000050 | 0.008290 | 0.011931 | 0.007004 | 0.000007 | 0.000004 |
| 3 | sample_0_qa3 | tm_21b0ee42660c42d3b042b07741128e59 | 39 | 0.048255 | 0.000014 | 0.000752 | 0.016634 | 0.007326 | 0.000006 | 0.000002 |
| 4 | sample_0_qa4 | tm_5508ec2271914b1282d6a4d4aebd48cf | 39 | 0.053847 | 0.000017 | 0.000455 | 0.046221 | 0.001159 | 0.000006 | 0.000002 |
| 5 | sample_0_qa5 | tm_5a99da43d29f45c8a9501fb910c17b33 | 39 | 0.062394 | 0.000019 | 0.001081 | 0.053354 | 0.002378 | 0.000007 | 0.000002 |
| 6 | sample_0_qa6 | tm_9af2fe015d7c499b8ec32a6fa08e78b2 | 39 | 0.012935 | 0.000014 | 0.000274 | 0.005514 | 0.001171 | 0.000006 | 0.000002 |
| 7 | sample_0_qa7 | tm_a17f39f7c61c46cc90bf093739ad37d9 | 39 | 0.057756 | 0.000018 | 0.000282 | 0.051948 | 0.001418 | 0.000006 | 0.000002 |
| 8 | sample_0_qa8 | tm_cf3d038432114155aca5fa4058586c69 | 39 | 0.055486 | 0.000018 | 0.000245 | 0.049930 | 0.001247 | 0.000007 | 0.000002 |
| 9 | sample_0_qa9 | tm_1aecb5b6c5c649f9bd7f42150f8c50a9 | 39 | 0.055820 | 0.000017 | 0.000259 | 0.050592 | 0.001192 | 0.000006 | 0.000002 |
| 10 | sample_0_qa10 | tm_156f8be95c084da8a27803cf092f9e6b | 39 | 0.054381 | 0.000019 | 0.000241 | 0.048914 | 0.001241 | 0.000006 | 0.000002 |
| 11 | sample_0_qa11 | tm_95b03c858ac847ca9fdd0b0c2aa10709 | 39 | 0.052809 | 0.000017 | 0.000271 | 0.046292 | 0.002463 | 0.000007 | 0.000002 |
| 12 | sample_0_qa12 | tm_74038de6d4394573aa9cd3116cd28984 | 39 | 0.051435 | 0.000017 | 0.000290 | 0.046310 | 0.001056 | 0.000007 | 0.000002 |
| 13 | sample_0_qa13 | tm_a339191915b742e983bcd88e8e8b4b9f | 39 | 0.052949 | 0.000017 | 0.000231 | 0.046966 | 0.001908 | 0.000007 | 0.000002 |
| 14 | sample_0_qa14 | tm_0e59a09d7d274406971b7df24f43ceb7 | 39 | 0.055918 | 0.000017 | 0.000266 | 0.048104 | 0.001289 | 0.000007 | 0.000002 |
| 15 | sample_0_qa15 | tm_83c7b11641c940a8947e85fabba9528f | 39 | 0.054739 | 0.000016 | 0.000154 | 0.047299 | 0.003757 | 0.000006 | 0.000002 |
| 16 | sample_0_qa16 | tm_0f251e4c290549cda056af56a31934a4 | 39 | 0.051995 | 0.000015 | 0.000225 | 0.046654 | 0.001443 | 0.000006 | 0.000002 |
| 17 | sample_0_qa17 | tm_d362d85d059a4068aaaa0477cf424313 | 39 | 0.054583 | 0.000018 | 0.000282 | 0.049498 | 0.001058 | 0.000006 | 0.000002 |
| 18 | sample_0_qa18 | tm_d3e40fe140e842249b22881f19621a1e | 39 | 0.055656 | 0.000017 | 0.000318 | 0.048461 | 0.001227 | 0.000007 | 0.000002 |
| 19 | sample_0_qa19 | tm_353b506988b8418281093d061241d15e | 39 | 0.056129 | 0.000016 | 0.000158 | 0.048247 | 0.004053 | 0.000006 | 0.000002 |
| 20 | sample_0_qa20 | tm_83d2d7b34e1b43d48bd672a07ef25578 | 39 | 0.055449 | 0.000018 | 0.000269 | 0.050250 | 0.001352 | 0.000006 | 0.000002 |
| 21 | sample_0_qa21 | tm_53e0a9b61cda4fd4b9f0e4fba4b0be32 | 39 | 0.051922 | 0.000017 | 0.000267 | 0.046666 | 0.001546 | 0.000006 | 0.000002 |
| 22 | sample_0_qa22 | tm_2a796ac06294437c931894465f9f100e | 39 | 0.055668 | 0.000017 | 0.000478 | 0.048308 | 0.001141 | 0.000007 | 0.000002 |
| 23 | sample_0_qa23 | tm_37ca677a1d1b40a79838a4a9e0426524 | 39 | 0.055919 | 0.000017 | 0.000202 | 0.047886 | 0.003921 | 0.000007 | 0.000002 |
| 24 | sample_0_qa24 | tm_5121805ccdc341e99dc9c569de23fd13 | 39 | 0.054669 | 0.000015 | 0.000253 | 0.047202 | 0.003622 | 0.000006 | 0.000002 |
| 25 | sample_0_qa25 | tm_05f52558c475433aaad5e7a16f0264e3 | 39 | 0.052213 | 0.000019 | 0.000409 | 0.046489 | 0.001444 | 0.000006 | 0.000002 |
| 26 | sample_0_qa26 | tm_6c832a96da83463998321fc77cb22079 | 39 | 0.055937 | 0.000016 | 0.000372 | 0.048601 | 0.001159 | 0.000007 | 0.000002 |
| 27 | sample_0_qa27 | tm_cd2104af7565456584de5de30a6cf59a | 39 | 0.058992 | 0.000017 | 0.002645 | 0.051060 | 0.001071 | 0.000006 | 0.000002 |
| 28 | sample_0_qa28 | tm_52e32a563ffe40aa859178ef6a278973 | 39 | 0.057374 | 0.000017 | 0.000136 | 0.049734 | 0.003805 | 0.000007 | 0.000002 |
| 29 | sample_0_qa29 | tm_372d56fabb5d42d48ceab4e5a3768e7f | 39 | 0.057417 | 0.000017 | 0.000192 | 0.050627 | 0.002890 | 0.000006 | 0.000002 |
| 30 | sample_0_qa30 | tm_efed92a6cc0d489182d3fd0b970dc54c | 39 | 0.051363 | 0.000018 | 0.000287 | 0.046406 | 0.001034 | 0.000006 | 0.000002 |
| 31 | sample_0_qa31 | tm_1ab97667090c4dbf85e488ea1ec78f01 | 39 | 0.056207 | 0.000017 | 0.000385 | 0.048790 | 0.001152 | 0.000007 | 0.000002 |
| 32 | sample_0_qa32 | tm_022b9e00544b45879a2a32026f4f0342 | 39 | 0.061325 | 0.000017 | 0.000174 | 0.050560 | 0.006858 | 0.000007 | 0.000002 |
| 33 | sample_0_qa33 | tm_8d585ebc50fe4c19ae0520b9a5a92333 | 39 | 0.053152 | 0.000016 | 0.000254 | 0.044864 | 0.004585 | 0.000006 | 0.000002 |
| 34 | sample_0_qa34 | tm_1fe01c5097374863a93200ab4f82b753 | 39 | 0.052279 | 0.000016 | 0.000261 | 0.047075 | 0.001200 | 0.000006 | 0.000002 |
| 35 | sample_0_qa35 | tm_a4b9e21f11fc4f3a9b30bd45e26fff90 | 39 | 0.060298 | 0.000017 | 0.000290 | 0.051874 | 0.001976 | 0.000006 | 0.000002 |
| 36 | sample_0_qa36 | tm_f5c462d23cf84422913fd4d2b66d99ae | 39 | 0.059877 | 0.000017 | 0.001039 | 0.047334 | 0.006454 | 0.000006 | 0.000002 |
| 37 | sample_0_qa37 | tm_16e114e611f0492c84ffabaaed4f05b0 | 39 | 0.060233 | 0.000014 | 0.000264 | 0.052225 | 0.003940 | 0.000006 | 0.000001 |
| 38 | sample_0_qa38 | tm_765115bd09144cd4a9593e5560855c6a | 39 | 0.055538 | 0.000020 | 0.000330 | 0.050143 | 0.001077 | 0.000006 | 0.000002 |
| 39 | sample_0_qa39 | tm_b165d159d5e242418322f7a62c8c3ea1 | 39 | 0.059158 | 0.000017 | 0.002671 | 0.051276 | 0.001151 | 0.000007 | 0.000002 |
| 40 | sample_0_qa40 | tm_5d3aeac554a24c50bea54a86a27c2ce6 | 39 | 0.059191 | 0.000017 | 0.001008 | 0.047327 | 0.005625 | 0.000007 | 0.000002 |
| 41 | sample_0_qa41 | tm_f9d71ef48e484f7f8cec1096bc16fb9d | 39 | 0.059576 | 0.000013 | 0.000265 | 0.050912 | 0.004495 | 0.000007 | 0.000002 |
| 42 | sample_0_qa42 | tm_299ce379fb0e490e9ffd2dd2f4190028 | 39 | 0.055628 | 0.000017 | 0.000278 | 0.050702 | 0.001088 | 0.000007 | 0.000002 |
| 43 | sample_0_qa43 | tm_e2c57ca361d4449788ed6d2a86afa129 | 39 | 0.055890 | 0.000016 | 0.000249 | 0.050649 | 0.001213 | 0.000007 | 0.000002 |
| 44 | sample_0_qa44 | tm_e72fa9f90053463bbd8c4d6304ed3464 | 39 | 0.059389 | 0.000017 | 0.001034 | 0.049182 | 0.003907 | 0.000006 | 0.000002 |
| 45 | sample_0_qa45 | tm_c40fd8bd86704029a79e8edb60fc2b78 | 39 | 0.055266 | 0.000014 | 0.000297 | 0.046786 | 0.003884 | 0.000006 | 0.000002 |
| 46 | sample_0_qa46 | tm_3f2f4bd4e85640ba857f368015ec489c | 39 | 0.056119 | 0.000015 | 0.000252 | 0.050917 | 0.001268 | 0.000007 | 0.000002 |
| 47 | sample_0_qa47 | tm_17caef1951104acaa14f1625016f20fa | 39 | 0.052011 | 0.000017 | 0.000292 | 0.046613 | 0.001285 | 0.000007 | 0.000002 |
| 48 | sample_0_qa48 | tm_611d1702f3954912bee2809df6d6982e | 39 | 0.053526 | 0.000017 | 0.001031 | 0.045880 | 0.001601 | 0.000007 | 0.000002 |
| 49 | sample_0_qa49 | tm_6f2b087267a64cb3841ad999212a5ad1 | 39 | 0.062699 | 0.000014 | 0.000305 | 0.050314 | 0.006829 | 0.000006 | 0.000002 |
| 50 | sample_0_qa50 | tm_56e3ecf6e7a5496dabe4167f1d397878 | 39 | 0.058062 | 0.000017 | 0.000229 | 0.047299 | 0.006715 | 0.000006 | 0.000002 |
| 51 | sample_0_qa51 | tm_0fba1a7fe9b044bba8bac466b9bba144 | 39 | 0.051613 | 0.000017 | 0.000259 | 0.046479 | 0.001134 | 0.000007 | 0.000002 |
| 52 | sample_0_qa52 | tm_2e1c4cd842fd44d092912551e197346f | 39 | 0.059279 | 0.000016 | 0.000174 | 0.052259 | 0.001156 | 0.000007 | 0.000002 |
| 53 | sample_0_qa53 | tm_1369740e64b44e749c94db58f3dd8266 | 39 | 0.056372 | 0.000017 | 0.000209 | 0.048558 | 0.003736 | 0.000007 | 0.000002 |
| 54 | sample_0_qa54 | tm_6eda6c7d81684f17a827ac44fac3f370 | 39 | 0.058503 | 0.000017 | 0.000188 | 0.050144 | 0.004338 | 0.000007 | 0.000002 |
| 55 | sample_0_qa55 | tm_a9b25db7c7604d459a2e40b82879fdd1 | 39 | 0.055795 | 0.000019 | 0.000295 | 0.050412 | 0.001191 | 0.000007 | 0.000002 |
| 56 | sample_0_qa56 | tm_3221b44d93aa4fd89d65c032a6d05778 | 39 | 0.059655 | 0.000015 | 0.000158 | 0.052643 | 0.001092 | 0.000007 | 0.000002 |
| 57 | sample_0_qa57 | tm_50ceed2e61fa4b31a68679e93fe3a560 | 39 | 0.064808 | 0.000017 | 0.000393 | 0.049530 | 0.009247 | 0.000005 | 0.000001 |
| 58 | sample_0_qa58 | tm_92bb8cbaf89e41fb9fec0f2bd1d88d53 | 39 | 0.054131 | 0.000017 | 0.000157 | 0.045901 | 0.004362 | 0.000006 | 0.000002 |
| 59 | sample_0_qa59 | tm_78a643f2600c4bc5a6f8a423d4e0a040 | 39 | 0.052579 | 0.000017 | 0.000267 | 0.046721 | 0.001934 | 0.000007 | 0.000002 |
| 60 | sample_0_qa60 | tm_90b2017e4bba4703944818b231e95eaa | 39 | 0.059778 | 0.000016 | 0.000236 | 0.050303 | 0.001088 | 0.000007 | 0.000002 |
| 61 | sample_0_qa61 | tm_411297fb0cb84e1d827f71a9a3f14cfc | 39 | 0.065436 | 0.000016 | 0.001049 | 0.052070 | 0.007548 | 0.000006 | 0.000001 |
| 62 | sample_0_qa62 | tm_e4f4bc21debf44a388393bb6a6d4cf1a | 39 | 0.059522 | 0.000013 | 0.000270 | 0.049501 | 0.005854 | 0.000006 | 0.000002 |
| 63 | sample_0_qa63 | tm_ee451a2435954a69994c3066712b0793 | 39 | 0.060790 | 0.000018 | 0.000284 | 0.047828 | 0.008946 | 0.000006 | 0.000002 |
| 64 | sample_0_qa64 | tm_9031c66c50714a9794f33357b7ccdc50 | 39 | 0.056061 | 0.000017 | 0.000277 | 0.050886 | 0.001154 | 0.000007 | 0.000002 |
| 65 | sample_0_qa65 | tm_2a6befcf296c4a3b8e0caf7b9c4efca4 | 39 | 0.059135 | 0.000015 | 0.001476 | 0.049150 | 0.001195 | 0.000007 | 0.000002 |
| 66 | sample_0_qa66 | tm_28923eeb18024cd89aab55e003ab2804 | 39 | 0.069014 | 0.000014 | 0.000309 | 0.054631 | 0.010009 | 0.000006 | 0.000001 |
| 67 | sample_0_qa67 | tm_f0c468c93085441ca65d2d55f18a0641 | 39 | 0.058576 | 0.000017 | 0.000155 | 0.049049 | 0.005571 | 0.000007 | 0.000002 |
| 68 | sample_0_qa68 | tm_f85d3ca3eec04e248fef0b2649ccb60a | 39 | 0.055497 | 0.000018 | 0.000292 | 0.050524 | 0.001083 | 0.000006 | 0.000002 |
| 69 | sample_0_qa69 | tm_ec155bf884a7463c92f96aa7317f8d2e | 39 | 0.059811 | 0.000016 | 0.000396 | 0.050073 | 0.001155 | 0.000007 | 0.000002 |
| 70 | sample_0_qa70 | tm_c183b9fb565d459d9988ca71442c2bd1 | 39 | 0.059913 | 0.000016 | 0.001064 | 0.048527 | 0.005535 | 0.000006 | 0.000002 |
| 71 | sample_0_qa71 | tm_6cc4e6c54b9748c4b11eebb50fd8004d | 39 | 0.060338 | 0.000013 | 0.000286 | 0.052472 | 0.003851 | 0.000006 | 0.000001 |
| 72 | sample_0_qa72 | tm_4eadf404d9f24a7693be77481d94cd8c | 39 | 0.051964 | 0.000018 | 0.000251 | 0.046895 | 0.001031 | 0.000006 | 0.000002 |
| 73 | sample_0_qa73 | tm_048f4c51164a4569902e7bac91d18ec1 | 39 | 0.055391 | 0.000017 | 0.000311 | 0.050341 | 0.001057 | 0.000006 | 0.000002 |
| 74 | sample_0_qa74 | tm_55af2d454abc4221aed3ba23580e8592 | 39 | 0.062676 | 0.000016 | 0.001075 | 0.052781 | 0.003935 | 0.000007 | 0.000002 |
| 75 | sample_0_qa75 | tm_190d21fe680a439c83c7e23b49fdf348 | 39 | 0.052586 | 0.000013 | 0.000311 | 0.046405 | 0.001028 | 0.000006 | 0.000002 |
| 76 | sample_0_qa76 | tm_533975989a5c42539dd15e3e1b848657 | 39 | 0.053253 | 0.000019 | 0.000262 | 0.047475 | 0.001802 | 0.000006 | 0.000002 |
| 77 | sample_0_qa77 | tm_3bf64b5242fc470da9ea5eb624324cc7 | 39 | 0.052336 | 0.000018 | 0.000246 | 0.047075 | 0.001416 | 0.000006 | 0.000002 |
| 78 | sample_0_qa78 | tm_3afc1a5300634f47bfbd955144b60968 | 39 | 0.056349 | 0.000015 | 0.000373 | 0.049411 | 0.001114 | 0.000007 | 0.000002 |
| 79 | sample_0_qa79 | tm_c1e98d17333d44a78c2d23506b9c6cdb | 39 | 0.060502 | 0.000017 | 0.000160 | 0.055121 | 0.001735 | 0.000006 | 0.000002 |
| 80 | sample_0_qa80 | tm_f6c1d42662a34f5ebe67db785b321733 | 39 | 0.058284 | 0.000017 | 0.000235 | 0.050648 | 0.003684 | 0.000006 | 0.000001 |
| 81 | sample_0_qa81 | tm_751cda1b1e5344f49156ce834e03502a | 39 | 0.055946 | 0.000016 | 0.000146 | 0.050742 | 0.001450 | 0.000007 | 0.000002 |
| 82 | sample_0_qa82 | tm_4cdb76dbfce44af7b6a35f9b864af66e | 39 | 0.051920 | 0.000017 | 0.000267 | 0.046820 | 0.001116 | 0.000006 | 0.000002 |
| 83 | sample_0_qa83 | tm_eeb2563cb4844b3088881e83e809cab0 | 39 | 0.055584 | 0.000015 | 0.000370 | 0.048935 | 0.001128 | 0.000007 | 0.000002 |
| 84 | sample_0_qa84 | tm_b93de17ad4bb48ecae175baf8fb0be63 | 39 | 0.055986 | 0.000018 | 0.000175 | 0.048341 | 0.003820 | 0.000006 | 0.000001 |
| 85 | sample_0_qa85 | tm_07a7adb13e5c4ae7816784db543d99b4 | 39 | 0.051573 | 0.000019 | 0.000299 | 0.046371 | 0.001181 | 0.000007 | 0.000002 |
| 86 | sample_0_qa86 | tm_60c6561914054bac9a92287725c3ed37 | 39 | 0.056151 | 0.000018 | 0.000320 | 0.050550 | 0.001566 | 0.000006 | 0.000002 |
| 87 | sample_0_qa87 | tm_bd9f4693504f42b7a4b4075f264bac2b | 39 | 0.055611 | 0.000017 | 0.000296 | 0.048740 | 0.001100 | 0.000016 | 0.000002 |
| 88 | sample_0_qa88 | tm_8a141c41ad064494a155974c76354cb4 | 39 | 0.058267 | 0.000015 | 0.000155 | 0.052096 | 0.002146 | 0.000007 | 0.000004 |
| 89 | sample_0_qa89 | tm_349734f58d0e42fb9eee545760a15817 | 39 | 0.056094 | 0.000017 | 0.000261 | 0.050649 | 0.001564 | 0.000006 | 0.000002 |
| 90 | sample_0_qa90 | tm_c2775506d4104ce6ad22c1e681bd8b4f | 39 | 0.051210 | 0.000018 | 0.000314 | 0.045898 | 0.001114 | 0.000006 | 0.000002 |
| 91 | sample_0_qa91 | tm_d40b7bd158844c18a4401268ae79da99 | 39 | 0.056062 | 0.000018 | 0.000282 | 0.050954 | 0.001250 | 0.000006 | 0.000002 |
| 92 | sample_0_qa92 | tm_32bedf5257cb4070b173dca178d9815b | 39 | 0.055585 | 0.000019 | 0.000171 | 0.048436 | 0.003057 | 0.000007 | 0.000002 |
| 93 | sample_0_qa93 | tm_3cff8ff8dc404616ad2a155dd109f05e | 39 | 0.055202 | 0.000019 | 0.000266 | 0.050124 | 0.001076 | 0.000006 | 0.000002 |
| 94 | sample_0_qa94 | tm_cc793cb462374120a53deabc4407e46f | 39 | 0.053778 | 0.000017 | 0.000285 | 0.047294 | 0.002665 | 0.000006 | 0.000002 |
| 95 | sample_0_qa95 | tm_056550a38678431c8142164e83fd7980 | 39 | 0.055777 | 0.000018 | 0.000280 | 0.050715 | 0.001083 | 0.000007 | 0.000002 |
| 96 | sample_0_qa96 | tm_1b12bf41a2fd4868991da78b95bc7197 | 39 | 0.054861 | 0.000018 | 0.000260 | 0.048819 | 0.002093 | 0.000007 | 0.000002 |
| 97 | sample_0_qa97 | tm_403feb374dbb40259bc67e1d58796b4b | 39 | 0.056441 | 0.000019 | 0.000262 | 0.050787 | 0.001478 | 0.000007 | 0.000002 |
| 98 | sample_0_qa98 | tm_400b96c92a4146788031ac94ce69f64e | 39 | 0.055527 | 0.000018 | 0.000296 | 0.049100 | 0.002372 | 0.000007 | 0.000002 |
| 99 | sample_0_qa99 | tm_55732c25c8444837865270f9158f7b50 | 39 | 0.055897 | 0.000019 | 0.000297 | 0.050629 | 0.001154 | 0.000007 | 0.000002 |
| 100 | sample_0_qa100 | tm_df7aa962e5364721b81d567e106ca4ed | 39 | 0.054813 | 0.000016 | 0.000147 | 0.047160 | 0.003846 | 0.000007 | 0.000002 |
| 101 | sample_0_qa101 | tm_a68f78eb48cf43578fe5e31d05440fd8 | 39 | 0.055436 | 0.000018 | 0.000294 | 0.047788 | 0.001041 | 0.000007 | 0.000002 |
| 102 | sample_0_qa102 | tm_cac71cc710ab4189b19e4248518f0fdc | 39 | 0.054991 | 0.000016 | 0.000192 | 0.046786 | 0.004324 | 0.000007 | 0.000002 |
| 103 | sample_0_qa103 | tm_fddacb1cba764b77918c44cd37b3acfa | 39 | 0.055425 | 0.000016 | 0.000174 | 0.048591 | 0.001021 | 0.000006 | 0.000002 |
| 104 | sample_0_qa104 | tm_b87bc9294b8048f6aea918fb336a46ca | 39 | 0.054801 | 0.000017 | 0.000163 | 0.047615 | 0.003496 | 0.000006 | 0.000002 |
| 105 | sample_0_qa105 | tm_e25bdfe879d94033827ac861a4e32620 | 39 | 0.052019 | 0.000015 | 0.000162 | 0.044663 | 0.001608 | 0.000006 | 0.000002 |
| 106 | sample_0_qa106 | tm_4155873b28eb42c2855a5baf5623f96c | 39 | 0.054879 | 0.000016 | 0.000232 | 0.049858 | 0.001068 | 0.000007 | 0.000002 |
| 107 | sample_0_qa107 | tm_a13bc0328b2e418286c1a6c4d4b8db4c | 39 | 0.052301 | 0.000017 | 0.000347 | 0.045219 | 0.001145 | 0.000007 | 0.000002 |
| 108 | sample_0_qa108 | tm_3166e27c7a7f497596648151759154a8 | 39 | 0.053704 | 0.000015 | 0.000161 | 0.047630 | 0.002295 | 0.000007 | 0.000002 |
| 109 | sample_0_qa109 | tm_e7e9e487387c4ab6a348f4b32a0be184 | 39 | 0.051580 | 0.000017 | 0.000182 | 0.046578 | 0.001090 | 0.000007 | 0.000002 |
| 110 | sample_0_qa110 | tm_98a2016ac3cb4efcb7249b1ce826b4af | 39 | 0.052452 | 0.000016 | 0.000187 | 0.046849 | 0.001676 | 0.000007 | 0.000002 |
| 111 | sample_0_qa111 | tm_17ec264401b645c99cdfe7725f783221 | 39 | 0.055738 | 0.000018 | 0.000285 | 0.048055 | 0.001161 | 0.000007 | 0.000002 |
| 112 | sample_0_qa112 | tm_8e6c2f75bd6e4b578ab78262ada64835 | 39 | 0.056142 | 0.000017 | 0.000176 | 0.050069 | 0.002157 | 0.000007 | 0.000002 |
| 113 | sample_0_qa113 | tm_fc00b702271d46bf93ba1c27a72311ef | 39 | 0.055081 | 0.000018 | 0.000272 | 0.047951 | 0.003200 | 0.000007 | 0.000002 |
| 114 | sample_0_qa114 | tm_e6ee3595153049baa7de31f1fb60dde3 | 39 | 0.055449 | 0.000018 | 0.000293 | 0.050388 | 0.001075 | 0.000007 | 0.000002 |
| 115 | sample_0_qa115 | tm_47cbf2fa5077414ea403709c8e5593f7 | 39 | 0.055852 | 0.000018 | 0.000291 | 0.050685 | 0.001158 | 0.000007 | 0.000002 |
| 116 | sample_0_qa116 | tm_cce3d59363954ab3acd8beac35d34446 | 39 | 0.055722 | 0.000019 | 0.002967 | 0.046162 | 0.002393 | 0.000006 | 0.000002 |
| 117 | sample_0_qa117 | tm_16af09cb081c487b9d5dc1807f88a601 | 39 | 0.056465 | 0.000016 | 0.000169 | 0.051411 | 0.001113 | 0.000007 | 0.000002 |
| 118 | sample_0_qa118 | tm_56eb04fd37d8481ca4510b5b52c2a23b | 39 | 0.054206 | 0.000017 | 0.000291 | 0.047026 | 0.003228 | 0.000006 | 0.000002 |
| 119 | sample_0_qa119 | tm_0462b20621b24fbb8f556707bf2b7498 | 39 | 0.065206 | 0.000019 | 0.000277 | 0.056878 | 0.004257 | 0.000006 | 0.000002 |
| 120 | sample_0_qa120 | tm_c643928c42d54f01b3091d0eee8e6178 | 39 | 0.054287 | 0.000016 | 0.000186 | 0.045651 | 0.004712 | 0.000007 | 0.000002 |
| 121 | sample_0_qa121 | tm_772af0f64d7f44e39d2da40f80054536 | 39 | 0.057524 | 0.000018 | 0.000287 | 0.051475 | 0.002042 | 0.000006 | 0.000002 |
| 122 | sample_0_qa122 | tm_9565e24fb1de49c3beb03f9f45c10b72 | 39 | 0.056111 | 0.000018 | 0.000257 | 0.048302 | 0.003652 | 0.000007 | 0.000002 |
| 123 | sample_0_qa123 | tm_69b2d237da384398a32e35e43a30f0b9 | 39 | 0.056093 | 0.000016 | 0.001039 | 0.048994 | 0.001203 | 0.000007 | 0.000002 |
| 124 | sample_0_qa124 | tm_6a552c7615564142abc7d6aaaf86eea7 | 39 | 0.062485 | 0.000013 | 0.000286 | 0.054523 | 0.003706 | 0.000007 | 0.000002 |
| 125 | sample_0_qa125 | tm_6bbfe0dbb4b147e2a23a2e45c96837ca | 39 | 0.061395 | 0.000017 | 0.000245 | 0.048655 | 0.006375 | 0.000006 | 0.000002 |
| 126 | sample_0_qa126 | tm_83c95bd711b94d91878731568700c0b3 | 39 | 0.058485 | 0.000019 | 0.000170 | 0.048319 | 0.006290 | 0.000006 | 0.000002 |
| 127 | sample_0_qa127 | tm_ffd079cfc90b4ba89386983bb0b69ca0 | 39 | 0.059748 | 0.000017 | 0.000348 | 0.052644 | 0.001122 | 0.000007 | 0.000002 |
| 128 | sample_0_qa128 | tm_be1b0a116666498ea273580a776ac176 | 39 | 0.063140 | 0.000017 | 0.000344 | 0.049860 | 0.007146 | 0.000006 | 0.000002 |
| 129 | sample_0_qa129 | tm_08433c630c1f49b7bb8e66002eeba228 | 39 | 0.060897 | 0.000019 | 0.000207 | 0.047811 | 0.008704 | 0.000006 | 0.000001 |
| 130 | sample_0_qa130 | tm_0e52b4108cba403b84e956eb93c31654 | 39 | 0.056510 | 0.000018 | 0.000171 | 0.046409 | 0.006419 | 0.000006 | 0.000002 |
| 131 | sample_0_qa131 | tm_68cca918045c4d73abfab8ae0f3ec0d2 | 39 | 0.055801 | 0.000017 | 0.000387 | 0.048531 | 0.001095 | 0.000006 | 0.000002 |
| 132 | sample_0_qa132 | tm_4863f2ca57f4492cb543adf491409f72 | 39 | 0.056007 | 0.000017 | 0.000292 | 0.048906 | 0.001137 | 0.000006 | 0.000002 |
| 133 | sample_0_qa133 | tm_088fba07464344f2a9cf6642c4535d69 | 39 | 0.061699 | 0.000016 | 0.001092 | 0.051577 | 0.004266 | 0.000006 | 0.000001 |
| 134 | sample_0_qa134 | tm_cd817e90783f4372ba9075156432578b | 39 | 0.057950 | 0.000013 | 0.000279 | 0.049281 | 0.004303 | 0.000006 | 0.000002 |
| 135 | sample_0_qa135 | tm_ad6fa678d4794ea2bc7fb479c3f1d30a | 39 | 0.055962 | 0.000016 | 0.000135 | 0.051078 | 0.001140 | 0.000007 | 0.000002 |
| 136 | sample_0_qa136 | tm_9c65095afcfa41a4a33fc02cfc22d27e | 39 | 0.056080 | 0.000018 | 0.000362 | 0.050751 | 0.001169 | 0.000007 | 0.000002 |
| 137 | sample_0_qa137 | tm_785c98e4a3b742ea8b793dc65b998014 | 39 | 0.060439 | 0.000016 | 0.001018 | 0.048226 | 0.006110 | 0.000006 | 0.000002 |
| 138 | sample_0_qa138 | tm_fa1712c4e9074766910f2d16887ea3ce | 39 | 0.056849 | 0.000014 | 0.000290 | 0.050376 | 0.002050 | 0.000007 | 0.000002 |
| 139 | sample_0_qa139 | tm_bf22d17cd7514c43ac5629bbfa0f6d1b | 39 | 0.051566 | 0.000017 | 0.000235 | 0.046511 | 0.001068 | 0.000007 | 0.000002 |
| 140 | sample_0_qa140 | tm_d8a43cd0ee4c458784e544b706e22604 | 39 | 0.051644 | 0.000016 | 0.000261 | 0.046697 | 0.001125 | 0.000007 | 0.000002 |
| 141 | sample_0_qa141 | tm_233febbad2cf42bc9575702a4424733f | 39 | 0.061821 | 0.000017 | 0.001047 | 0.049845 | 0.006211 | 0.000006 | 0.000001 |
| 142 | sample_0_qa142 | tm_0967d38bd8f74c03a7340a5f42cac9c6 | 39 | 0.058423 | 0.000014 | 0.000277 | 0.052002 | 0.001590 | 0.000007 | 0.000002 |
| 143 | sample_0_qa143 | tm_63600e92a52140e3ae78d1e8c92c6f21 | 39 | 0.051712 | 0.000017 | 0.000243 | 0.046592 | 0.001128 | 0.000007 | 0.000002 |
| 144 | sample_0_qa144 | tm_f44b435276bd4210bc4a5b2050e9c023 | 39 | 0.056066 | 0.000019 | 0.000254 | 0.050882 | 0.001126 | 0.000007 | 0.000002 |
| 145 | sample_0_qa145 | tm_8e8f330c76da4094a0ac61e0a279e2e6 | 39 | 0.052552 | 0.000016 | 0.000974 | 0.045634 | 0.001105 | 0.000007 | 0.000002 |
| 146 | sample_0_qa146 | tm_36a4ebc7b82848f199da01f8a9819f71 | 39 | 0.060221 | 0.000014 | 0.000299 | 0.053632 | 0.002197 | 0.000007 | 0.000002 |
| 147 | sample_0_qa147 | tm_96d8a11df4d74694aab1116e8ad26a2c | 39 | 0.054409 | 0.000017 | 0.000280 | 0.047674 | 0.002891 | 0.000006 | 0.000002 |
| 148 | sample_0_qa148 | tm_4d78d38ff28544288c715a8011a813ee | 39 | 0.052400 | 0.000015 | 0.000250 | 0.046943 | 0.001594 | 0.000007 | 0.000002 |
| 149 | sample_0_qa149 | tm_870ec876951245d9ae2f486eb028e477 | 39 | 0.056016 | 0.000019 | 0.000258 | 0.050702 | 0.001184 | 0.000007 | 0.000002 |
| 150 | sample_0_qa150 | tm_5ce53b345cf84403bd8c907fdf812abf | 39 | 0.054359 | 0.000017 | 0.002783 | 0.046488 | 0.001163 | 0.000007 | 0.000002 |
| 151 | sample_0_qa151 | tm_c21c4c93bed9497e81c5889ac3f3e34a | 39 | 0.057612 | 0.000017 | 0.000202 | 0.052564 | 0.001140 | 0.000007 | 0.000002 |

问答端到端平均耗时：0.429211s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.32 | 0.019354 | 0.260850 | 1.639114 | 0.286545 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.32 | 0.017966 | 0.249605 | 1.638386 | 0.287531 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.32 | 0.079041 | 0.224909 | 1.640493 | 0.285429 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.32 | 0.039182 | 0.215616 | 1.639395 | 0.286697 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.32 | 0.073653 | 0.228692 | 1.640132 | 0.285572 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.31 | 0.035235 | 0.233873 | 1.639744 | 0.285606 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.31 | 0.090394 | 0.224057 | 1.640754 | 0.285280 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.31 | 0.029678 | 0.214136 | 1.638789 | 0.287768 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.5 | 0.011216 | 0.471899 | 0.000206 | 0.007968 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.59 | 0.321453 | 0.224842 | 0.000173 | 0.007080 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.52 | 0.260175 | 0.216330 | 0.000173 | 0.009950 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.61 | 0.326932 | 0.234821 | 0.000156 | 0.010267 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.6 | 0.323309 | 0.237775 | 0.000160 | 0.006839 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.53 | 0.264634 | 0.227296 | 0.000178 | 0.008227 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.52 | 0.261809 | 0.211542 | 0.000180 | 0.010813 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.55 | 0.274025 | 0.231694 | 0.000182 | 0.007926 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.021561 | 0.247170 | 0.000157 | 0.007729 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.061874 | 0.251048 | 0.000454 | 0.007844 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.29 | 0.029215 | 0.242190 | 0.000447 | 0.006795 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.3 | 0.064617 | 0.220156 | 0.000417 | 0.008090 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.021568 | 0.237366 | 0.000172 | 0.007025 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.072667 | 0.239962 | 0.000157 | 0.006348 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.32 | 0.070160 | 0.238103 | 0.000433 | 0.007487 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.29 | 0.023906 | 0.246510 | 0.000428 | 0.006879 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.29 | 0.022049 | 0.251200 | 0.000179 | 0.013526 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.021119 | 0.257343 | 0.000186 | 0.006943 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.062624 | 0.218136 | 0.000189 | 0.012882 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.29 | 0.026649 | 0.242396 | 0.000191 | 0.012842 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.070753 | 0.244919 | 0.000203 | 0.010977 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.065665 | 0.249340 | 0.000431 | 0.006127 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.28 | 0.024163 | 0.243562 | 0.000178 | 0.009818 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.074062 | 0.243542 | 0.000255 | 0.006419 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.29 | 0.021618 | 0.256136 | 0.000166 | 0.008422 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.065512 | 0.232198 | 0.000186 | 0.007206 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.26 | 0.011172 | 0.238879 | 0.000180 | 0.007426 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.35 | 0.076285 | 0.252044 | 0.000543 | 0.007210 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.057679 | 0.256033 | 0.000489 | 0.006904 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.34 | 0.072521 | 0.246461 | 0.000427 | 0.007349 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.28 | 0.022269 | 0.243586 | 0.000178 | 0.007066 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.32 | 0.065718 | 0.235643 | 0.000180 | 0.007730 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.29 | 0.029659 | 0.243985 | 0.000169 | 0.006785 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.058646 | 0.253400 | 0.000170 | 0.008287 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.27 | 0.021290 | 0.230944 | 0.000183 | 0.009155 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.26 | 0.020992 | 0.226223 | 0.000182 | 0.008865 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.32 | 0.074456 | 0.238211 | 0.000172 | 0.006830 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.020025 | 0.222063 | 0.000176 | 0.007840 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.33 | 0.076298 | 0.240172 | 0.000167 | 0.007700 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.34 | 0.075023 | 0.250239 | 0.000172 | 0.007019 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.32 | 0.059831 | 0.250151 | 0.000183 | 0.008158 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.35 | 0.075657 | 0.259706 | 0.000518 | 0.007946 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.28 | 0.025073 | 0.243138 | 0.000200 | 0.006796 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.34 | 0.077146 | 0.243912 | 0.000185 | 0.011421 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.27 | 0.029710 | 0.231871 | 0.000405 | 0.006658 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.071268 | 0.252447 | 0.000179 | 0.009065 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.022696 | 0.256021 | 0.000164 | 0.007821 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.29 | 0.027085 | 0.249123 | 0.000158 | 0.006426 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.31 | 0.030457 | 0.268889 | 0.000459 | 0.007197 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.065376 | 0.252541 | 0.000209 | 0.011050 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.023350 | 0.252454 | 0.000469 | 0.008448 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.34 | 0.078323 | 0.253987 | 0.000160 | 0.007843 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.3 | 0.027386 | 0.261421 | 0.000183 | 0.006497 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.3 | 0.019361 | 0.260286 | 0.000470 | 0.007715 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.065467 | 0.229715 | 0.000180 | 0.009695 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.033356 | 0.233305 | 0.000161 | 0.010274 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.31 | 0.031016 | 0.256706 | 0.000611 | 0.017578 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.28 | 0.010601 | 0.249239 | 0.000239 | 0.009195 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.34 | 0.072426 | 0.249703 | 0.000221 | 0.007731 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.025339 | 0.234695 | 0.000287 | 0.007230 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.35 | 0.077437 | 0.256700 | 0.000214 | 0.007566 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.29 | 0.028998 | 0.245333 | 0.000499 | 0.006955 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.34 | 0.071486 | 0.250339 | 0.000170 | 0.008134 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.31 | 0.065020 | 0.232504 | 0.000200 | 0.006288 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.26 | 0.022250 | 0.226194 | 0.000170 | 0.007972 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.075926 | 0.224241 | 0.000193 | 0.007548 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.024697 | 0.224887 | 0.000173 | 0.007159 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.32 | 0.080969 | 0.229494 | 0.000212 | 0.007152 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.072245 | 0.236350 | 0.000465 | 0.007350 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.27 | 0.025992 | 0.230342 | 0.000180 | 0.006378 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.32 | 0.065791 | 0.244076 | 0.000165 | 0.006566 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.058994 | 0.246583 | 0.000429 | 0.007268 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.067406 | 0.254823 | 0.000413 | 0.007020 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.33 | 0.071535 | 0.245406 | 0.000180 | 0.007177 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.29 | 0.021710 | 0.248788 | 0.000162 | 0.007134 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.33 | 0.069247 | 0.242842 | 0.000177 | 0.009274 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.28 | 0.018349 | 0.244914 | 0.000174 | 0.006647 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.35 | 0.070340 | 0.262693 | 0.000457 | 0.006910 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.28 | 0.026481 | 0.238812 | 0.000207 | 0.007641 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.34 | 0.075044 | 0.255662 | 0.000251 | 0.006417 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.34 | 0.058556 | 0.270322 | 0.000184 | 0.007803 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.26 | 0.026014 | 0.221189 | 0.000251 | 0.006496 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.3 | 0.059567 | 0.230600 | 0.000200 | 0.009659 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.33 | 0.071630 | 0.249362 | 0.000155 | 0.007380 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.32 | 0.034147 | 0.270418 | 0.000179 | 0.006876 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.27 | 0.024066 | 0.233965 | 0.000181 | 0.007114 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.33 | 0.073199 | 0.243783 | 0.000182 | 0.007375 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.34 | 0.076852 | 0.248191 | 0.000173 | 0.007529 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.27 | 0.026530 | 0.229583 | 0.000178 | 0.011052 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.32 | 0.068606 | 0.235865 | 0.000176 | 0.006680 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.28 | 0.019502 | 0.245222 | 0.000426 | 0.007258 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.31 | 0.061116 | 0.234681 | 0.000208 | 0.007275 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.27 | 0.026658 | 0.233570 | 0.000201 | 0.006851 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.32 | 0.064464 | 0.243518 | 0.000160 | 0.007208 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.28 | 0.011697 | 0.251748 | 0.000179 | 0.007010 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.33 | 0.065257 | 0.239935 | 0.000164 | 0.010596 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.31 | 0.072754 | 0.222747 | 0.000153 | 0.007006 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.28 | 0.034722 | 0.231742 | 0.000187 | 0.007969 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.34 | 0.069432 | 0.259875 | 0.000184 | 0.007102 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.32 | 0.056953 | 0.250792 | 0.000178 | 0.010364 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.29 | 0.026956 | 0.254296 | 0.000183 | 0.007015 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.34 | 0.075144 | 0.254471 | 0.000176 | 0.010379 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.29 | 0.024168 | 0.251531 | 0.000192 | 0.007023 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.27 | 0.021960 | 0.232573 | 0.000473 | 0.006413 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.29 | 0.017897 | 0.251953 | 0.000173 | 0.008534 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.32 | 0.063476 | 0.239506 | 0.000182 | 0.009673 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.32 | 0.072677 | 0.234909 | 0.000203 | 0.006888 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.33 | 0.074087 | 0.233576 | 0.000183 | 0.013831 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.27 | 0.026064 | 0.233649 | 0.000182 | 0.007289 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.28 | 0.034536 | 0.231378 | 0.000203 | 0.007382 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.33 | 0.072504 | 0.242211 | 0.000419 | 0.007713 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.29 | 0.028691 | 0.251201 | 0.000171 | 0.006805 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.32 | 0.074298 | 0.234800 | 0.000455 | 0.006625 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.28 | 0.025759 | 0.247365 | 0.000180 | 0.006632 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.29 | 0.030217 | 0.239586 | 0.000630 | 0.007039 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.32 | 0.072255 | 0.237570 | 0.000177 | 0.008217 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.29 | 0.025252 | 0.247480 | 0.000177 | 0.009845 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.34 | 0.068340 | 0.242576 | 0.000183 | 0.018525 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.25 | 0.023719 | 0.215143 | 0.000157 | 0.006937 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.35 | 0.066501 | 0.270847 | 0.000462 | 0.008800 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.34 | 0.075546 | 0.252358 | 0.000175 | 0.007561 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.27 | 0.020342 | 0.233412 | 0.000213 | 0.009528 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.35 | 0.066213 | 0.271971 | 0.000704 | 0.009033 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.37 | 0.065146 | 0.292664 | 0.000224 | 0.011005 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.33 | 0.030410 | 0.284519 | 0.000672 | 0.007167 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.34 | 0.072800 | 0.251629 | 0.000273 | 0.011533 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.33 | 0.034479 | 0.283418 | 0.000245 | 0.008443 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.31 | 0.010839 | 0.280492 | 0.000203 | 0.013825 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.37 | 0.073519 | 0.275053 | 0.000200 | 0.007497 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.35 | 0.031444 | 0.307195 | 0.000476 | 0.006782 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.31 | 0.021894 | 0.273959 | 0.000180 | 0.007152 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.3 | 0.032778 | 0.253416 | 0.000187 | 0.007893 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.32 | 0.061261 | 0.247425 | 0.000187 | 0.008903 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.3 | 0.021513 | 0.259474 | 0.000181 | 0.007381 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.34 | 0.071222 | 0.257082 | 0.000195 | 0.007996 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.29 | 0.027293 | 0.247925 | 0.000176 | 0.006716 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.29 | 0.026886 | 0.244389 | 0.000186 | 0.006838 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.42 | 0.070953 | 0.331189 | 0.000654 | 0.007898 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.39 | 0.031701 | 0.339771 | 0.000892 | 0.008207 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.39 | 0.065458 | 0.310427 | 0.000902 | 0.008262 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.37 | 0.071120 | 0.280496 | 0.000479 | 0.007485 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.34 | 0.028317 | 0.297129 | 0.000434 | 0.006573 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.32 | 0.069185 | 0.236810 | 0.000882 | 0.006903 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.29 | 0.023969 | 0.256780 | 0.000592 | 0.008029 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |