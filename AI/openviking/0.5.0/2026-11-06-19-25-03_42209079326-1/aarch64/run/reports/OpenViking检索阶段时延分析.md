# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.067495s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001666 | 2.469% |
| Query Embedding | 生成查询向量 | 0.048591 | 71.992% |
| 向量召回 | 召回语义相似记忆 | 0.008141 | 12.062% |
| 结果处理 | 整理候选并转换返回结构 | 0.000019 | 0.028% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.009078 | 13.449% |
|  |  | 0.067495 | 100.000% |

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

父阶段平均耗时：**0.067495s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001666 | 2.469% |
| Query Embedding | 生成查询向量 | 0.048591 | 71.992% |
| 向量召回 | 召回语义相似记忆 | 0.008141 | 12.062% |
| 结果处理 | 整理候选并转换返回结构 | 0.000019 | 0.028% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.009078 | 13.449% |
| 合计 |  | 0.067495 | 100.000% |

**结论：Query Embedding占71.993%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.001666s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000021 | 1.260% |
| 集合检查 | 检查目标集合与检索器 | 0.001645 | 98.740% |
| 合计 |  | 0.001666 | 100.000% |

**结论：集合检查占98.740%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000019s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000008 | 42.406% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 11.119% |
| 结果处理内部 | 结果处理调度 | 0.000009 | 46.475% |
| 合计 |  | 0.000019 | 100.000% |

**结论：结果处理内部占46.475%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.627947s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.012856 | 2.047% |
| 记忆检索 | 查询相关记忆 | 0.067488 | 10.747% |
| 上下文筛选 | 选择候选记忆 | 0.000040 | 0.006% |
| 记忆读取 | 读取记忆正文 | 0.397930 | 63.370% |
| 重排 | 调整候选顺序 | 0.003796 | 0.605% |
| Prompt准备 | 构造回答输入 | 0.114115 | 18.173% |
| 回答LLM | 生成最终回答 | 0.031688 | 5.046% |
| 响应解析 | 解析回答结果 | 0.000035 | 0.006% |
| 合计 |  | 0.627947 | 100.000% |

**结论：记忆读取占63.370%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-06T19:20:58+08:00 |
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
| 内存 | 1505.33 GiB |
| Python | 3.11.6 |
| OpenViking | OpenViking v0.5.0 (official benchmark kit 48T96G, aarch64, container, out-of-the-box) |
| OV版本 | 0.4.21 |
| 源码提交 | 309645cafee3897459fcd819d26e60fad89e9c81 |
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
| 检索耗时(s) | 0.067495 | 0.071096 | 0.086966 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_8f4590d8564f47629cd6bc76d61d5a7c | 39 | 0.036711 | 0.000027 | 0.005223 | 0.016797 | 0.004232 | 0.000010 | 0.000003 |
| 1 | sample_0_qa1 | tm_7c38d35ee39e46c4b3bd6bfddc356c92 | 39 | 0.055300 | 0.000019 | 0.005351 | 0.019083 | 0.014368 | 0.000008 | 0.000002 |
| 2 | sample_0_qa2 | tm_10fd7205b74a4646844ed3e57a7794d2 | 39 | 0.046474 | 0.000020 | 0.002295 | 0.023266 | 0.004322 | 0.000009 | 0.000003 |
| 3 | sample_0_qa3 | tm_4c624ecb719345d0b9ddf7ffcfe7f60f | 39 | 0.081613 | 0.000018 | 0.000910 | 0.060834 | 0.003472 | 0.000008 | 0.000002 |
| 4 | sample_0_qa4 | tm_aa4ce56cd4e74d1f9ee06b8c98b18d0f | 39 | 0.068259 | 0.000026 | 0.001516 | 0.050387 | 0.002097 | 0.000009 | 0.000002 |
| 5 | sample_0_qa5 | tm_a27d18bec9d24a1bb1c92a77ff4697b5 | 39 | 0.063402 | 0.000023 | 0.000777 | 0.049080 | 0.003358 | 0.000008 | 0.000002 |
| 6 | sample_0_qa6 | tm_25b53e8e46a447a2bfe14d34e69e9fbe | 39 | 0.018012 | 0.000018 | 0.000161 | 0.010261 | 0.002152 | 0.000008 | 0.000003 |
| 7 | sample_0_qa7 | tm_96e13a578564448192bd9dc18bc51b8f | 39 | 0.074867 | 0.000022 | 0.004692 | 0.056412 | 0.005880 | 0.000008 | 0.000002 |
| 8 | sample_0_qa8 | tm_850f7c0f7f9244dfb769309127499e82 | 39 | 0.063866 | 0.000024 | 0.000641 | 0.050989 | 0.005011 | 0.000007 | 0.000002 |
| 9 | sample_0_qa9 | tm_c615743be3c64586b14c700023a567a1 | 39 | 0.068095 | 0.000024 | 0.000185 | 0.050374 | 0.006867 | 0.000008 | 0.000002 |
| 10 | sample_0_qa10 | tm_7b7df1fd00c7437daf2691343718c9ba | 39 | 0.060994 | 0.000023 | 0.000515 | 0.050594 | 0.004304 | 0.000007 | 0.000002 |
| 11 | sample_0_qa11 | tm_68fb5b5eeb3847ebb8488e470c2ffc2d | 39 | 0.063095 | 0.000023 | 0.001473 | 0.049395 | 0.006059 | 0.000008 | 0.000002 |
| 12 | sample_0_qa12 | tm_c3a05ff551eb4ae298f2accf2aa14064 | 39 | 0.069434 | 0.000018 | 0.000351 | 0.055336 | 0.007833 | 0.000009 | 0.000002 |
| 13 | sample_0_qa13 | tm_7b9cc7e9cc044d3d80e2d1893640ea2a | 39 | 0.065763 | 0.000020 | 0.001898 | 0.052804 | 0.005015 | 0.000008 | 0.000003 |
| 14 | sample_0_qa14 | tm_dd0c2bfb13d34e37a6e62072ce3fd8d4 | 39 | 0.065696 | 0.000019 | 0.000421 | 0.049410 | 0.010311 | 0.000008 | 0.000002 |
| 15 | sample_0_qa15 | tm_ab4615bb84664b42acf89847aeef84db | 39 | 0.057297 | 0.000020 | 0.000185 | 0.049069 | 0.003145 | 0.000008 | 0.000002 |
| 16 | sample_0_qa16 | tm_cf66ad8dca7245fead1cea5844c94468 | 39 | 0.065947 | 0.000025 | 0.000546 | 0.056401 | 0.003199 | 0.000008 | 0.000003 |
| 17 | sample_0_qa17 | tm_cacacf60f40b4cb7992857f6f1d3c865 | 39 | 0.068489 | 0.000025 | 0.001343 | 0.056079 | 0.004647 | 0.000007 | 0.000002 |
| 18 | sample_0_qa18 | tm_193ca30bcc2548e2851156fec31dfbca | 39 | 0.018007 | 0.000018 | 0.000334 | 0.009394 | 0.001810 | 0.000008 | 0.000002 |
| 19 | sample_0_qa19 | tm_3075c1a0f9cb45ac85af234acc5dc04e | 39 | 0.065964 | 0.000022 | 0.001463 | 0.050252 | 0.002748 | 0.000008 | 0.000002 |
| 20 | sample_0_qa20 | tm_b4120e315cd94308a7b2a68fabaa89af | 39 | 0.071969 | 0.000035 | 0.004331 | 0.053095 | 0.002821 | 0.000008 | 0.000002 |
| 21 | sample_0_qa21 | tm_673979f4dca2445c8a7ef83de93bca71 | 39 | 0.019620 | 0.000019 | 0.000648 | 0.007240 | 0.005748 | 0.000008 | 0.000003 |
| 22 | sample_0_qa22 | tm_f5528b3c0e394b2c9bd5c560c8e767f8 | 39 | 0.068938 | 0.000022 | 0.001462 | 0.051846 | 0.009153 | 0.000008 | 0.000002 |
| 23 | sample_0_qa23 | tm_72638aa0e383410592d6bd169d2eee14 | 39 | 0.063625 | 0.000018 | 0.000415 | 0.054813 | 0.002189 | 0.000008 | 0.000002 |
| 24 | sample_0_qa24 | tm_313986fa96324dabb123ca9165b64e83 | 39 | 0.060130 | 0.000039 | 0.000271 | 0.049337 | 0.004949 | 0.000008 | 0.000002 |
| 25 | sample_0_qa25 | tm_39bcae021d564b32afc45e45c11eac19 | 39 | 0.060258 | 0.000023 | 0.000267 | 0.050410 | 0.003900 | 0.000008 | 0.000002 |
| 26 | sample_0_qa26 | tm_ea084f9108c04d5dab36f63aa7cc1165 | 39 | 0.080010 | 0.000025 | 0.001533 | 0.053842 | 0.009356 | 0.000008 | 0.000002 |
| 27 | sample_0_qa27 | tm_33307bc2d6d0418c9d13be52c16e437a | 39 | 0.080695 | 0.000019 | 0.002194 | 0.056826 | 0.010831 | 0.000008 | 0.000002 |
| 28 | sample_0_qa28 | tm_de93608a426442feae6126d19ac2d137 | 39 | 0.072472 | 0.000019 | 0.000951 | 0.054706 | 0.009479 | 0.000008 | 0.000002 |
| 29 | sample_0_qa29 | tm_c8af067c0b024fce8fd004af2adc0803 | 39 | 0.015287 | 0.000024 | 0.000272 | 0.007391 | 0.002278 | 0.000008 | 0.000002 |
| 30 | sample_0_qa30 | tm_f70167f3cd524bcebddf870f94213ddc | 39 | 0.059716 | 0.000023 | 0.000324 | 0.051556 | 0.002450 | 0.000008 | 0.000002 |
| 31 | sample_0_qa31 | tm_b07d5c793d564f93b59254293af8930f | 39 | 0.075812 | 0.000024 | 0.003081 | 0.052367 | 0.009537 | 0.000008 | 0.000003 |
| 32 | sample_0_qa32 | tm_73a312bea4b544b2b9b97ce46e09c096 | 39 | 0.082225 | 0.000018 | 0.002039 | 0.055384 | 0.017483 | 0.000008 | 0.000002 |
| 33 | sample_0_qa33 | tm_c2031c04c788451497afe86f1743980a | 39 | 0.071485 | 0.000017 | 0.000874 | 0.058854 | 0.005319 | 0.000007 | 0.000002 |
| 34 | sample_0_qa34 | tm_8377d24abffd4bc699b870572aea765c | 39 | 0.066132 | 0.000024 | 0.000275 | 0.052503 | 0.008166 | 0.000008 | 0.000002 |
| 35 | sample_0_qa35 | tm_3444e9a49c8a4abaa296cfeca20da3d1 | 39 | 0.090040 | 0.000026 | 0.005102 | 0.053548 | 0.015080 | 0.000008 | 0.000002 |
| 36 | sample_0_qa36 | tm_c85cef6fa25e4572b772eb31b752cabe | 39 | 0.090349 | 0.000020 | 0.005537 | 0.055138 | 0.015476 | 0.000008 | 0.000002 |
| 37 | sample_0_qa37 | tm_5b5d43a3083b40c99974d6ee0b620afe | 39 | 0.086100 | 0.000019 | 0.002140 | 0.057518 | 0.013259 | 0.000008 | 0.000002 |
| 38 | sample_0_qa38 | tm_ab3a2ac12ef34c3cadb129882f4bf385 | 39 | 0.078529 | 0.000017 | 0.000774 | 0.054353 | 0.013977 | 0.000007 | 0.000002 |
| 39 | sample_0_qa39 | tm_352fafc326de4205a5d3cf8147502797 | 39 | 0.096622 | 0.000024 | 0.004549 | 0.057079 | 0.024263 | 0.000008 | 0.000002 |
| 40 | sample_0_qa40 | tm_5ea5f5c93e1148bcbd402c8a92fff484 | 39 | 0.026694 | 0.000017 | 0.003878 | 0.010969 | 0.002113 | 0.000008 | 0.000002 |
| 41 | sample_0_qa41 | tm_cc43a3eb42b94d71b0e4aea80ce087fa | 39 | 0.068118 | 0.000018 | 0.001524 | 0.051425 | 0.005222 | 0.000008 | 0.000002 |
| 42 | sample_0_qa42 | tm_47b24bd7935548e588ded0fa535e03ff | 39 | 0.087943 | 0.000017 | 0.000618 | 0.062216 | 0.016396 | 0.000007 | 0.000002 |
| 43 | sample_0_qa43 | tm_983a23fca4924278a415e95f3d0d9241 | 39 | 0.059249 | 0.000025 | 0.000283 | 0.049443 | 0.003811 | 0.000008 | 0.000002 |
| 44 | sample_0_qa44 | tm_1e39602431ae4faf8bb807eb81465edb | 39 | 0.072617 | 0.000032 | 0.000792 | 0.055235 | 0.001933 | 0.000008 | 0.000002 |
| 45 | sample_0_qa45 | tm_8e440862705146a7ac20868bf1864c47 | 39 | 0.076647 | 0.000023 | 0.002501 | 0.051218 | 0.009373 | 0.000007 | 0.000002 |
| 46 | sample_0_qa46 | tm_ccb9b24b8805479b9861992317d9a117 | 39 | 0.021238 | 0.000019 | 0.001694 | 0.009147 | 0.002186 | 0.000008 | 0.000002 |
| 47 | sample_0_qa47 | tm_4f3b2d19dfe441d58a73042ed8536f8e | 39 | 0.065772 | 0.000019 | 0.000397 | 0.051460 | 0.002543 | 0.000008 | 0.000002 |
| 48 | sample_0_qa48 | tm_fc5979b1df1245f796d5c5f9fee80453 | 39 | 0.060020 | 0.000020 | 0.000253 | 0.051364 | 0.003845 | 0.000008 | 0.000002 |
| 49 | sample_0_qa49 | tm_fcb1109d978042169be7f49ead38d70f | 39 | 0.060226 | 0.000023 | 0.000255 | 0.052601 | 0.002206 | 0.000008 | 0.000002 |
| 50 | sample_0_qa50 | tm_f20cd78704e647919de1e216547fee81 | 39 | 0.082060 | 0.000022 | 0.004789 | 0.055567 | 0.013350 | 0.000007 | 0.000002 |
| 51 | sample_0_qa51 | tm_a433b08171f04a0185f507292d9b6005 | 39 | 0.081400 | 0.000018 | 0.000420 | 0.058544 | 0.012297 | 0.000008 | 0.000002 |
| 52 | sample_0_qa52 | tm_c6f106ba823442c2821132fb0c4391d9 | 39 | 0.066361 | 0.000024 | 0.001497 | 0.052973 | 0.004480 | 0.000008 | 0.000002 |
| 53 | sample_0_qa53 | tm_1dc5634fb4bf4fbb8c34042d47fbe366 | 39 | 0.059198 | 0.000024 | 0.000268 | 0.048266 | 0.005114 | 0.000008 | 0.000002 |
| 54 | sample_0_qa54 | tm_a7c2cffb4e0540b594ea5c4379d9835d | 39 | 0.076126 | 0.000023 | 0.002621 | 0.053108 | 0.011408 | 0.000008 | 0.000002 |
| 55 | sample_0_qa55 | tm_f4ce2311384c4d00ade62ef7e14ace58 | 39 | 0.078462 | 0.000016 | 0.001941 | 0.056154 | 0.012618 | 0.000008 | 0.000002 |
| 56 | sample_0_qa56 | tm_c7d7ddb91ea44e4f95c71381651e41ff | 39 | 0.073957 | 0.000017 | 0.000463 | 0.059644 | 0.007092 | 0.000007 | 0.000002 |
| 57 | sample_0_qa57 | tm_ad7078bf6c79456ebf819ac60a12e8c4 | 39 | 0.014392 | 0.000019 | 0.000182 | 0.007186 | 0.001916 | 0.000008 | 0.000003 |
| 58 | sample_0_qa58 | tm_bea09f9e2aa44d019b3bf3238a40c937 | 39 | 0.063553 | 0.000024 | 0.000264 | 0.049891 | 0.007896 | 0.000008 | 0.000002 |
| 59 | sample_0_qa59 | tm_7bb7075237a243a2a4240bbf6048b740 | 39 | 0.083403 | 0.000024 | 0.002751 | 0.062040 | 0.009226 | 0.000007 | 0.000002 |
| 60 | sample_0_qa60 | tm_41efde5dcb514986bef299ab827536fe | 39 | 0.077515 | 0.000016 | 0.002083 | 0.055838 | 0.011040 | 0.000008 | 0.000002 |
| 61 | sample_0_qa61 | tm_23b84c8f8c1b41cab8f0c6890e8c1cbf | 39 | 0.077046 | 0.000018 | 0.000470 | 0.058876 | 0.010268 | 0.000008 | 0.000002 |
| 62 | sample_0_qa62 | tm_2620a07982484d7e9a33a6b1dbb5133f | 39 | 0.077389 | 0.000022 | 0.000216 | 0.058730 | 0.013064 | 0.000008 | 0.000002 |
| 63 | sample_0_qa63 | tm_9b56d6fe1b724e1ab2121c2bbf58f247 | 39 | 0.079518 | 0.000022 | 0.002303 | 0.048907 | 0.015151 | 0.000008 | 0.000002 |
| 64 | sample_0_qa64 | tm_9b0ea46e8bae476bab87ccf187dc5aae | 39 | 0.081483 | 0.000018 | 0.001613 | 0.053133 | 0.015111 | 0.000007 | 0.000002 |
| 65 | sample_0_qa65 | tm_9c8bebf68b264fefa09e7238cde96a2a | 39 | 0.077478 | 0.000017 | 0.000491 | 0.056511 | 0.009683 | 0.000007 | 0.000002 |
| 66 | sample_0_qa66 | tm_3d17c3a98fb74bdaba0dd2c745089492 | 39 | 0.070323 | 0.000023 | 0.000195 | 0.051179 | 0.013425 | 0.000008 | 0.000002 |
| 67 | sample_0_qa67 | tm_a79fd52ab32e4a25b9c070f02856dc8b | 39 | 0.033474 | 0.000034 | 0.002237 | 0.016008 | 0.004622 | 0.000008 | 0.000002 |
| 68 | sample_0_qa68 | tm_f071e5ed59c843468802012e9edc51c9 | 39 | 0.081160 | 0.000016 | 0.001544 | 0.062862 | 0.006740 | 0.000008 | 0.000002 |
| 69 | sample_0_qa69 | tm_494b689b42a44f75ad57dddd676dac01 | 39 | 0.081232 | 0.000016 | 0.000492 | 0.059746 | 0.012339 | 0.000008 | 0.000002 |
| 70 | sample_0_qa70 | tm_a1110ec1e43748959322d5b14de1e49b | 39 | 0.079749 | 0.000024 | 0.000609 | 0.059361 | 0.010463 | 0.000008 | 0.000002 |
| 71 | sample_0_qa71 | tm_5431ffbd01834f0ebd849baa44e3ddb4 | 39 | 0.016009 | 0.000024 | 0.000562 | 0.007261 | 0.002386 | 0.000009 | 0.000002 |
| 72 | sample_0_qa72 | tm_2e5e290952854f9cb9d653290549a23c | 39 | 0.059461 | 0.000021 | 0.000271 | 0.049326 | 0.004573 | 0.000008 | 0.000002 |
| 73 | sample_0_qa73 | tm_22ee3542cca24ef784f45bf1065d617f | 39 | 0.072012 | 0.000021 | 0.001283 | 0.051697 | 0.010460 | 0.000008 | 0.000002 |
| 74 | sample_0_qa74 | tm_ad3a15c067154f26978a86b1eddca1b6 | 39 | 0.081617 | 0.000017 | 0.000531 | 0.053495 | 0.018362 | 0.000008 | 0.000002 |
| 75 | sample_0_qa75 | tm_eee021b0963e4dc5b8d2df3a45089431 | 39 | 0.066775 | 0.000020 | 0.001361 | 0.048009 | 0.006493 | 0.000008 | 0.000002 |
| 76 | sample_0_qa76 | tm_e31c46aa3e234918a46a181e78ef07ae | 39 | 0.065861 | 0.000023 | 0.000264 | 0.051791 | 0.008484 | 0.000009 | 0.000002 |
| 77 | sample_0_qa77 | tm_c1fe3ac41a1244aaaf636c752f9e7127 | 39 | 0.096148 | 0.000019 | 0.006850 | 0.058775 | 0.019834 | 0.000008 | 0.000002 |
| 78 | sample_0_qa78 | tm_b44f9548ea654c44a7cc8cf4804b900c | 39 | 0.082710 | 0.000018 | 0.001454 | 0.055604 | 0.014176 | 0.000008 | 0.000002 |
| 79 | sample_0_qa79 | tm_703bf8373f644458a1d4826eea94c02a | 39 | 0.078384 | 0.000017 | 0.000294 | 0.062237 | 0.010369 | 0.000008 | 0.000002 |
| 80 | sample_0_qa80 | tm_9ec5bc4e370f4bc986fd9ce894576e55 | 39 | 0.072198 | 0.000020 | 0.002014 | 0.054187 | 0.008758 | 0.000007 | 0.000002 |
| 81 | sample_0_qa81 | tm_5ce17225423444569dde7e1878c603e6 | 39 | 0.074528 | 0.000023 | 0.003605 | 0.051819 | 0.005250 | 0.000008 | 0.000002 |
| 82 | sample_0_qa82 | tm_ddd4913a7ebd4807bc6ec2600f8344bd | 39 | 0.031096 | 0.000017 | 0.002920 | 0.012585 | 0.003308 | 0.000008 | 0.000002 |
| 83 | sample_0_qa83 | tm_84cffdebc957403dbfae499135ec2659 | 39 | 0.082417 | 0.000017 | 0.001617 | 0.056858 | 0.012733 | 0.000008 | 0.000002 |
| 84 | sample_0_qa84 | tm_be877bca77794e399a221184b5d219ce | 39 | 0.076364 | 0.000017 | 0.000648 | 0.062574 | 0.004563 | 0.000008 | 0.000002 |
| 85 | sample_0_qa85 | tm_b1a67c5719a44c02a661f0f38531e7a6 | 39 | 0.066368 | 0.000023 | 0.000259 | 0.054065 | 0.006582 | 0.000008 | 0.000002 |
| 86 | sample_0_qa86 | tm_5285dfe1b5c948e1ac6c1496c6675a95 | 39 | 0.072617 | 0.000023 | 0.000183 | 0.057940 | 0.001828 | 0.000008 | 0.000002 |
| 87 | sample_0_qa87 | tm_a50797cb0b3c4c8eb082cd8c83a999bc | 39 | 0.077314 | 0.000023 | 0.004390 | 0.050029 | 0.009341 | 0.000008 | 0.000002 |
| 88 | sample_0_qa88 | tm_a5a91afe8aec4e4d823a9deae506d9f2 | 39 | 0.089749 | 0.000019 | 0.005629 | 0.057369 | 0.014078 | 0.000008 | 0.000002 |
| 89 | sample_0_qa89 | tm_49e64dd52dc64d408546a2b6144a1224 | 39 | 0.067207 | 0.000019 | 0.001800 | 0.050462 | 0.008248 | 0.000008 | 0.000002 |
| 90 | sample_0_qa90 | tm_ba9e982901fe484290666b67dd4db1d2 | 39 | 0.076053 | 0.000023 | 0.009144 | 0.053814 | 0.001923 | 0.000008 | 0.000002 |
| 91 | sample_0_qa91 | tm_3ae813bfe9b649cbafe129b066b431ad | 39 | 0.079531 | 0.000020 | 0.002641 | 0.049832 | 0.012916 | 0.000008 | 0.000003 |
| 92 | sample_0_qa92 | tm_4eae6674b2494584913b3e788b3b9723 | 39 | 0.078900 | 0.000019 | 0.000751 | 0.054155 | 0.012730 | 0.000007 | 0.000002 |
| 93 | sample_0_qa93 | tm_5eab560893024075b4ef2667a572a3a1 | 39 | 0.066995 | 0.000024 | 0.002099 | 0.050754 | 0.006247 | 0.000007 | 0.000002 |
| 94 | sample_0_qa94 | tm_2f3e1449192840139b4c2b06df930126 | 39 | 0.080853 | 0.000024 | 0.007714 | 0.056736 | 0.003047 | 0.000008 | 0.000002 |
| 95 | sample_0_qa95 | tm_ced79ca320e54310b240b2f59dbdda9b | 39 | 0.080806 | 0.000023 | 0.004109 | 0.053427 | 0.013347 | 0.000008 | 0.000002 |
| 96 | sample_0_qa96 | tm_5c2f0a123af14fcabed46b8e49b0fadf | 39 | 0.080885 | 0.000018 | 0.003424 | 0.060642 | 0.008409 | 0.000008 | 0.000002 |
| 97 | sample_0_qa97 | tm_3f75246a9d404048ba4d0b38616338db | 39 | 0.080435 | 0.000018 | 0.000676 | 0.057489 | 0.013582 | 0.000008 | 0.000002 |
| 98 | sample_0_qa98 | tm_6375992af7424eb5a2fe181a19041da7 | 39 | 0.079615 | 0.000024 | 0.000871 | 0.055786 | 0.003081 | 0.000008 | 0.000002 |
| 99 | sample_0_qa99 | tm_a7653ade6acb4ec59e55df03c45ca460 | 39 | 0.085060 | 0.000024 | 0.004172 | 0.056187 | 0.015220 | 0.000008 | 0.000002 |
| 100 | sample_0_qa100 | tm_a82a8d9c92934dbd990858a1bf1ca197 | 39 | 0.085231 | 0.000018 | 0.003478 | 0.059148 | 0.014760 | 0.000008 | 0.000002 |
| 101 | sample_0_qa101 | tm_1d56b8d1798842f8bcfa748b7e38f20f | 39 | 0.078214 | 0.000019 | 0.000626 | 0.052970 | 0.013882 | 0.000008 | 0.000003 |
| 102 | sample_0_qa102 | tm_88e4a25656324921afe4d9fee54c9b28 | 39 | 0.067266 | 0.000022 | 0.001402 | 0.048669 | 0.002419 | 0.000008 | 0.000002 |
| 103 | sample_0_qa103 | tm_cdf5065eb5c54364899c16c034a33dbd | 39 | 0.072028 | 0.000024 | 0.002261 | 0.050041 | 0.008402 | 0.000008 | 0.000002 |
| 104 | sample_0_qa104 | tm_e1ff31f078604ccb9aa1821bc7bd60c9 | 39 | 0.073825 | 0.000016 | 0.001576 | 0.055254 | 0.007850 | 0.000008 | 0.000002 |
| 105 | sample_0_qa105 | tm_0ac04c7525344fbbae8718a6aaf580ba | 39 | 0.076450 | 0.000017 | 0.000514 | 0.058271 | 0.009587 | 0.000008 | 0.000002 |
| 106 | sample_0_qa106 | tm_556907ee88f44326a218f8a503d7f706 | 39 | 0.055375 | 0.000019 | 0.000258 | 0.047859 | 0.002137 | 0.000008 | 0.000002 |
| 107 | sample_0_qa107 | tm_76ef7bd7499c4fe2ae26dc8ec784fc02 | 39 | 0.068555 | 0.000023 | 0.004028 | 0.049080 | 0.005298 | 0.000008 | 0.000003 |
| 108 | sample_0_qa108 | tm_20cbafec51dc4fe2b82582714ecd24f4 | 39 | 0.073563 | 0.000018 | 0.001448 | 0.051113 | 0.009623 | 0.000008 | 0.000002 |
| 109 | sample_0_qa109 | tm_7e7eb8d8bebb46a8acaebaef8ac329af | 39 | 0.083132 | 0.000018 | 0.000930 | 0.056748 | 0.018519 | 0.000008 | 0.000002 |
| 110 | sample_0_qa110 | tm_7794e055093e40018d300dd904fd3134 | 39 | 0.066743 | 0.000023 | 0.000204 | 0.048551 | 0.012449 | 0.000009 | 0.000002 |
| 111 | sample_0_qa111 | tm_afdb66f047604fe5a7295ae4020dd842 | 39 | 0.103234 | 0.000024 | 0.001938 | 0.059845 | 0.026248 | 0.000008 | 0.000002 |
| 112 | sample_0_qa112 | tm_a1cdda0f3a014f60a3eca958c1d96672 | 39 | 0.096453 | 0.000020 | 0.001683 | 0.073054 | 0.013451 | 0.000007 | 0.000002 |
| 113 | sample_0_qa113 | tm_6220f832227449f3b717796ba667722b | 39 | 0.021040 | 0.000024 | 0.000409 | 0.009066 | 0.002493 | 0.000008 | 0.000002 |
| 114 | sample_0_qa114 | tm_efbb51f6c69c47ac8371b14f107f3a15 | 39 | 0.080357 | 0.000018 | 0.000167 | 0.062895 | 0.011989 | 0.000007 | 0.000002 |
| 115 | sample_0_qa115 | tm_9a724c7084a848a494d721f768c5370a | 39 | 0.068051 | 0.000023 | 0.000256 | 0.050201 | 0.012197 | 0.000008 | 0.000002 |
| 116 | sample_0_qa116 | tm_de0a4b6804724a4f85a7e2064bdb8895 | 39 | 0.049141 | 0.000023 | 0.003509 | 0.014843 | 0.016465 | 0.000008 | 0.000002 |
| 117 | sample_0_qa117 | tm_eb4213e73961439784822ce501580de5 | 39 | 0.036522 | 0.000017 | 0.002812 | 0.010804 | 0.010166 | 0.000008 | 0.000002 |
| 118 | sample_0_qa118 | tm_afe8fd0a69964044b4730bc0e84c8df8 | 39 | 0.068282 | 0.000019 | 0.001797 | 0.052919 | 0.002320 | 0.000008 | 0.000002 |
| 119 | sample_0_qa119 | tm_5f1b38c4316e411b889d926910198648 | 39 | 0.031656 | 0.000017 | 0.000660 | 0.018414 | 0.005571 | 0.000008 | 0.000002 |
| 120 | sample_0_qa120 | tm_4f0c7a1d57994b60954411d2f82a9cc4 | 39 | 0.077013 | 0.000022 | 0.001261 | 0.054477 | 0.013325 | 0.000008 | 0.000002 |
| 121 | sample_0_qa121 | tm_1b2cea5bda1143a28cd1780a34cadb94 | 39 | 0.076538 | 0.000018 | 0.000329 | 0.057435 | 0.012436 | 0.000008 | 0.000002 |
| 122 | sample_0_qa122 | tm_9143cf9e6d6f4b0cbe087d9d8be27129 | 39 | 0.062733 | 0.000024 | 0.001671 | 0.051477 | 0.002518 | 0.000008 | 0.000002 |
| 123 | sample_0_qa123 | tm_0bb83ce153e245128f588885112d46e1 | 39 | 0.056545 | 0.000022 | 0.000250 | 0.048938 | 0.001961 | 0.000008 | 0.000002 |
| 124 | sample_0_qa124 | tm_3af6b203388c4abe981993a60dc77bc5 | 39 | 0.080963 | 0.000019 | 0.001680 | 0.057114 | 0.006393 | 0.000008 | 0.000002 |
| 125 | sample_0_qa125 | tm_8db6a737055542c594652a9e062fbdbe | 39 | 0.032572 | 0.000018 | 0.005098 | 0.016888 | 0.002761 | 0.000008 | 0.000002 |
| 126 | sample_0_qa126 | tm_9060252d31b6403ab9b315c896f57dfe | 39 | 0.079273 | 0.000018 | 0.003756 | 0.063357 | 0.004757 | 0.000008 | 0.000002 |
| 127 | sample_0_qa127 | tm_d5322bbeacc14888a60fba855fcb3135 | 39 | 0.027791 | 0.000021 | 0.002249 | 0.013302 | 0.003217 | 0.000009 | 0.000002 |
| 128 | sample_0_qa128 | tm_1c9901b8aaf74bfa97a8d1fb5c989ab2 | 39 | 0.067871 | 0.000020 | 0.000179 | 0.054229 | 0.003315 | 0.000008 | 0.000002 |
| 129 | sample_0_qa129 | tm_f7f53f3ffc92473f97cde06e78ab072c | 39 | 0.061545 | 0.000019 | 0.000213 | 0.047331 | 0.008582 | 0.000008 | 0.000002 |
| 130 | sample_0_qa130 | tm_10331f0f72ba4e998b4098a9473723f0 | 39 | 0.070707 | 0.000023 | 0.000283 | 0.051307 | 0.009501 | 0.000008 | 0.000002 |
| 131 | sample_0_qa131 | tm_a5ce7359ac2a496e87cfb1086180d63a | 39 | 0.061873 | 0.000017 | 0.000161 | 0.054271 | 0.002324 | 0.000008 | 0.000002 |
| 132 | sample_0_qa132 | tm_fb38f64bef5143eea914ae583f2605c2 | 39 | 0.070140 | 0.000020 | 0.000769 | 0.053444 | 0.008770 | 0.000008 | 0.000002 |
| 133 | sample_0_qa133 | tm_48692c163b87418cb180bdd105242ae4 | 39 | 0.064536 | 0.000017 | 0.000158 | 0.050330 | 0.008517 | 0.000008 | 0.000002 |
| 134 | sample_0_qa134 | tm_9acc7eb820a6481ba3829a66cb7f5c4c | 39 | 0.071858 | 0.000020 | 0.000498 | 0.056148 | 0.005222 | 0.000009 | 0.000002 |
| 135 | sample_0_qa135 | tm_f9add8361ce84897b4de0d7474b7c680 | 39 | 0.071537 | 0.000019 | 0.000187 | 0.052685 | 0.003974 | 0.000008 | 0.000002 |
| 136 | sample_0_qa136 | tm_26b26e32d55642009b50424f24139a12 | 39 | 0.018656 | 0.000019 | 0.000393 | 0.007458 | 0.002417 | 0.000008 | 0.000002 |
| 137 | sample_0_qa137 | tm_5098500a4da3461289727abe00eb230c | 39 | 0.063715 | 0.000019 | 0.000165 | 0.049415 | 0.008537 | 0.000008 | 0.000002 |
| 138 | sample_0_qa138 | tm_170fe289b0bf407db2928ec635936884 | 39 | 0.058908 | 0.000024 | 0.000255 | 0.049793 | 0.003684 | 0.000008 | 0.000002 |
| 139 | sample_0_qa139 | tm_233026941e6d4dc182f802a72513e934 | 39 | 0.076693 | 0.000023 | 0.003844 | 0.052603 | 0.010266 | 0.000008 | 0.000002 |
| 140 | sample_0_qa140 | tm_383a5410ab0c450bb828f44e408ea19c | 39 | 0.069728 | 0.000019 | 0.000277 | 0.057061 | 0.002577 | 0.000008 | 0.000002 |
| 141 | sample_0_qa141 | tm_4a512b5a0a4346e58c023d4e346cf2cd | 39 | 0.073933 | 0.000023 | 0.000383 | 0.049861 | 0.011379 | 0.000008 | 0.000002 |
| 142 | sample_0_qa142 | tm_f20808dab9504371a5773f2f3ed3bdce | 39 | 0.072809 | 0.000020 | 0.000252 | 0.050999 | 0.015658 | 0.000008 | 0.000002 |
| 143 | sample_0_qa143 | tm_192447609b1a442ebe1ac6cccb6768b2 | 39 | 0.066786 | 0.000020 | 0.005779 | 0.048628 | 0.002237 | 0.000008 | 0.000002 |
| 144 | sample_0_qa144 | tm_4a3cf8653788410d8352bd03c6d78e3a | 39 | 0.079923 | 0.000018 | 0.000650 | 0.052656 | 0.010732 | 0.000008 | 0.000002 |
| 145 | sample_0_qa145 | tm_629647ed8684474d8caaa656d1028980 | 39 | 0.060744 | 0.000020 | 0.000188 | 0.050958 | 0.003079 | 0.000008 | 0.000002 |
| 146 | sample_0_qa146 | tm_14a5e045e9e444d5b1093f692bc8cc7b | 39 | 0.069939 | 0.000024 | 0.000323 | 0.053437 | 0.010761 | 0.000008 | 0.000003 |
| 147 | sample_0_qa147 | tm_2eae94163eee4d698b646ac755dbc0ca | 39 | 0.079253 | 0.000023 | 0.003450 | 0.059773 | 0.005986 | 0.000008 | 0.000002 |
| 148 | sample_0_qa148 | tm_84174a14538441f3b5db131e3c7ccdda | 39 | 0.086167 | 0.000018 | 0.001647 | 0.051310 | 0.020718 | 0.000008 | 0.000002 |
| 149 | sample_0_qa149 | tm_f5c9e96fd7d94924941d16af4bb62bdb | 39 | 0.085956 | 0.000018 | 0.001162 | 0.056985 | 0.017279 | 0.000008 | 0.000002 |
| 150 | sample_0_qa150 | tm_ef14e3a8954d4681bdfd24a613a9239c | 39 | 0.060217 | 0.000023 | 0.000568 | 0.051206 | 0.002950 | 0.000008 | 0.000003 |
| 151 | sample_0_qa151 | tm_e86b6db8a3744a0f843b1e26cd371913 | 39 | 0.068097 | 0.000023 | 0.003530 | 0.052719 | 0.001982 | 0.000008 | 0.000002 |

问答端到端平均耗时：0.628224s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 3.13 | 0.015852 | 0.423504 | 2.161774 | 0.384737 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 3.13 | 0.042067 | 0.386783 | 2.162334 | 0.385649 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 3.13 | 0.113108 | 0.373664 | 2.161912 | 0.382783 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 3.13 | 0.097915 | 0.386448 | 2.164186 | 0.383602 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 3.13 | 0.045116 | 0.383886 | 2.163472 | 0.384932 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 3.13 | 0.058699 | 0.364391 | 2.161205 | 0.383873 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 3.13 | 0.097425 | 0.366356 | 2.163413 | 0.383566 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 3.12 | 0.065127 | 0.354776 | 2.162238 | 0.385904 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.68 | 0.316903 | 0.328686 | 0.000229 | 0.014424 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.66 | 0.285792 | 0.343998 | 0.000306 | 0.010090 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.72 | 0.344084 | 0.351645 | 0.000247 | 0.010404 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.69 | 0.295549 | 0.344179 | 0.000253 | 0.016144 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.68 | 0.290031 | 0.344522 | 0.000237 | 0.010903 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.76 | 0.339712 | 0.379688 | 0.000214 | 0.009348 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.75 | 0.345390 | 0.360708 | 0.000228 | 0.010030 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.68 | 0.294021 | 0.346666 | 0.000225 | 0.015143 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.037968 | 0.386532 | 0.000550 | 0.015994 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.44 | 0.086304 | 0.338544 | 0.000235 | 0.009613 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.4 | 0.016773 | 0.358262 | 0.000544 | 0.013153 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.49 | 0.077679 | 0.374721 | 0.000537 | 0.013009 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.48 | 0.086415 | 0.364754 | 0.000545 | 0.012033 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.038698 | 0.399219 | 0.000263 | 0.013982 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.5 | 0.073250 | 0.401093 | 0.000224 | 0.011112 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.49 | 0.080056 | 0.390760 | 0.000228 | 0.009205 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.44 | 0.026025 | 0.395497 | 0.000577 | 0.009791 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.53 | 0.070576 | 0.436191 | 0.000550 | 0.009141 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.48 | 0.036397 | 0.421031 | 0.000227 | 0.009633 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.5 | 0.062927 | 0.416279 | 0.000240 | 0.015254 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.42 | 0.028806 | 0.363328 | 0.000576 | 0.011928 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.5 | 0.085762 | 0.378322 | 0.000709 | 0.011814 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.47 | 0.068807 | 0.378516 | 0.000240 | 0.012628 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.51 | 0.079287 | 0.405105 | 0.000223 | 0.012991 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.46 | 0.030650 | 0.409999 | 0.000231 | 0.010462 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.065150 | 0.345878 | 0.000231 | 0.009042 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.47 | 0.033629 | 0.412687 | 0.000233 | 0.010036 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.48 | 0.092871 | 0.365771 | 0.000215 | 0.016779 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.44 | 0.037630 | 0.365051 | 0.000592 | 0.024308 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.5 | 0.105465 | 0.381341 | 0.000262 | 0.010196 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.47 | 0.080654 | 0.366955 | 0.000232 | 0.011921 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.48 | 0.083606 | 0.381331 | 0.000231 | 0.010370 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.44 | 0.029325 | 0.393590 | 0.000842 | 0.011353 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.52 | 0.075187 | 0.424603 | 0.000237 | 0.009400 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.46 | 0.082575 | 0.360644 | 0.000241 | 0.009768 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.45 | 0.023433 | 0.408413 | 0.000237 | 0.009557 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.48 | 0.091029 | 0.367455 | 0.000226 | 0.009657 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.023814 | 0.389705 | 0.000237 | 0.010181 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.5 | 0.090482 | 0.393679 | 0.000244 | 0.013416 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.45 | 0.039624 | 0.385695 | 0.000223 | 0.015758 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.44 | 0.037196 | 0.384660 | 0.000263 | 0.010782 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.46 | 0.030803 | 0.408262 | 0.000570 | 0.009078 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.5 | 0.091950 | 0.389660 | 0.000232 | 0.009105 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.45 | 0.029723 | 0.400465 | 0.000251 | 0.013347 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.47 | 0.072154 | 0.369629 | 0.000226 | 0.009763 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.038049 | 0.394811 | 0.000564 | 0.015568 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.052753 | 0.377841 | 0.000222 | 0.008879 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.48 | 0.077266 | 0.385720 | 0.000228 | 0.012443 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.45 | 0.032208 | 0.398281 | 0.000231 | 0.009334 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.024234 | 0.391208 | 0.000221 | 0.009901 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.068054 | 0.369518 | 0.000569 | 0.010947 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.46 | 0.033983 | 0.406740 | 0.000234 | 0.009901 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.51 | 0.084038 | 0.407631 | 0.000516 | 0.009155 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.44 | 0.036874 | 0.379302 | 0.000278 | 0.009235 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.5 | 0.090519 | 0.391291 | 0.000482 | 0.009137 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.040141 | 0.400975 | 0.000255 | 0.011289 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.46 | 0.032191 | 0.409457 | 0.000382 | 0.009759 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.49 | 0.034870 | 0.430690 | 0.000456 | 0.010936 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.46 | 0.039256 | 0.399200 | 0.000258 | 0.009920 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.51 | 0.073847 | 0.411795 | 0.000333 | 0.010938 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.52 | 0.047216 | 0.454153 | 0.000260 | 0.009855 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.48 | 0.043662 | 0.411876 | 0.000542 | 0.014694 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.47 | 0.033599 | 0.406144 | 0.000210 | 0.009037 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.53 | 0.088664 | 0.422967 | 0.000230 | 0.008959 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.45 | 0.037149 | 0.399490 | 0.000223 | 0.009549 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.42 | 0.036300 | 0.364328 | 0.000225 | 0.010913 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.52 | 0.074013 | 0.416729 | 0.000227 | 0.017744 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.46 | 0.067061 | 0.370737 | 0.000262 | 0.009909 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.41 | 0.028998 | 0.357271 | 0.000220 | 0.019466 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.48 | 0.076010 | 0.389988 | 0.000557 | 0.009620 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.5 | 0.085893 | 0.398143 | 0.000242 | 0.010854 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.49 | 0.077962 | 0.392534 | 0.000219 | 0.009823 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.51 | 0.075620 | 0.411725 | 0.000232 | 0.010570 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.49 | 0.075990 | 0.393463 | 0.000236 | 0.010235 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.45 | 0.023693 | 0.407890 | 0.000228 | 0.012078 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.51 | 0.080608 | 0.403705 | 0.000210 | 0.009852 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.45 | 0.030197 | 0.398118 | 0.000225 | 0.015199 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.49 | 0.045697 | 0.419696 | 0.000218 | 0.012340 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.47 | 0.032785 | 0.415035 | 0.000230 | 0.012016 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.48 | 0.036805 | 0.419949 | 0.000595 | 0.009844 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.5 | 0.038091 | 0.444075 | 0.000233 | 0.011187 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.49 | 0.035427 | 0.431112 | 0.000226 | 0.010881 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.45 | 0.023720 | 0.407623 | 0.000231 | 0.008864 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.51 | 0.083271 | 0.408990 | 0.000220 | 0.009135 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.45 | 0.036927 | 0.398887 | 0.000235 | 0.009292 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.45 | 0.033027 | 0.396369 | 0.000221 | 0.008973 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.45 | 0.036036 | 0.397881 | 0.000248 | 0.009139 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.49 | 0.033203 | 0.424211 | 0.000238 | 0.023489 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.45 | 0.027017 | 0.403009 | 0.000276 | 0.010156 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.47 | 0.038213 | 0.411088 | 0.000563 | 0.009855 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.45 | 0.036448 | 0.396426 | 0.000545 | 0.010058 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.57 | 0.024665 | 0.521785 | 0.000542 | 0.010486 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.6 | 0.081917 | 0.504827 | 0.000234 | 0.009353 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.58 | 0.033360 | 0.524982 | 0.000230 | 0.014572 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.53 | 0.038652 | 0.469912 | 0.000249 | 0.013499 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.53 | 0.033149 | 0.479328 | 0.000231 | 0.009294 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.58 | 0.037414 | 0.520916 | 0.000236 | 0.009209 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.56 | 0.036109 | 0.492669 | 0.000232 | 0.023804 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.56 | 0.146205 | 0.396997 | 0.000226 | 0.009053 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.43 | 0.023821 | 0.383364 | 0.000234 | 0.009073 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.44 | 0.024883 | 0.399561 | 0.000225 | 0.010260 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.48 | 0.066330 | 0.392818 | 0.000234 | 0.009964 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.46 | 0.034469 | 0.404563 | 0.000240 | 0.011539 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.45 | 0.029905 | 0.404780 | 0.000228 | 0.010363 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.48 | 0.043943 | 0.414531 | 0.000224 | 0.010751 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.44 | 0.036674 | 0.381879 | 0.000234 | 0.011434 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.47 | 0.077687 | 0.373524 | 0.000236 | 0.010797 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.39 | 0.027858 | 0.343724 | 0.000232 | 0.011008 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.42 | 0.033208 | 0.371348 | 0.000230 | 0.011315 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.4 | 0.026931 | 0.351065 | 0.000242 | 0.009472 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.49 | 0.086379 | 0.380315 | 0.000206 | 0.008663 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.5 | 0.081732 | 0.403336 | 0.000239 | 0.008926 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.47 | 0.035418 | 0.410165 | 0.000274 | 0.015023 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.51 | 0.081998 | 0.407524 | 0.000213 | 0.011630 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.43 | 0.027599 | 0.382127 | 0.000216 | 0.009685 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.45 | 0.073163 | 0.359078 | 0.000214 | 0.009573 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.43 | 0.041071 | 0.373765 | 0.000252 | 0.009462 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.5 | 0.065738 | 0.414412 | 0.000230 | 0.009277 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.43 | 0.035077 | 0.378765 | 0.000228 | 0.010660 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.45 | 0.035235 | 0.398755 | 0.000270 | 0.009304 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.43 | 0.021975 | 0.391523 | 0.000239 | 0.009304 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.5 | 0.077914 | 0.395543 | 0.000238 | 0.009284 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.46 | 0.032525 | 0.405638 | 0.000590 | 0.011375 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.5 | 0.074586 | 0.396711 | 0.000234 | 0.010650 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.48 | 0.068620 | 0.389706 | 0.000230 | 0.010683 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.47 | 0.023945 | 0.421575 | 0.000414 | 0.011279 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.46 | 0.063010 | 0.374464 | 0.000281 | 0.012291 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.43 | 0.024051 | 0.383643 | 0.000253 | 0.011176 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.6 | 0.039398 | 0.421093 | 0.000264 | 0.127782 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.56 | 0.033179 | 0.512817 | 0.000861 | 0.009148 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.59 | 0.085163 | 0.486149 | 0.000791 | 0.014175 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.56 | 0.041219 | 0.495215 | 0.000842 | 0.010313 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.6 | 0.089053 | 0.488762 | 0.000234 | 0.010524 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.61 | 0.029511 | 0.560214 | 0.000539 | 0.012190 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.59 | 0.083905 | 0.485569 | 0.000801 | 0.010592 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.59 | 0.040657 | 0.534500 | 0.000234 | 0.008708 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.48 | 0.036166 | 0.420420 | 0.000239 | 0.010216 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.45 | 0.071560 | 0.363763 | 0.000222 | 0.011406 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.47 | 0.081122 | 0.362161 | 0.000233 | 0.011677 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.44 | 0.033804 | 0.372274 | 0.000224 | 0.020211 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.43 | 0.067782 | 0.345333 | 0.000239 | 0.009298 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.34 | 0.024990 | 0.289435 | 0.000237 | 0.009836 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.36 | 0.082149 | 0.253804 | 0.000516 | 0.010107 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.31 | 0.084206 | 0.212564 | 0.000225 | 0.008842 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |