# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.064564s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000896 | 1.388% |
| Query Embedding | 生成查询向量 | 0.049998 | 77.439% |
| 向量召回 | 召回语义相似记忆 | 0.006167 | 9.551% |
| 结果处理 | 整理候选并转换返回结构 | 0.000020 | 0.031% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.007483 | 11.591% |
|  |  | 0.064564 | 100.000% |

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

父阶段平均耗时：**0.064564s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000896 | 1.388% |
| Query Embedding | 生成查询向量 | 0.049998 | 77.439% |
| 向量召回 | 召回语义相似记忆 | 0.006167 | 9.551% |
| 结果处理 | 整理候选并转换返回结构 | 0.000020 | 0.031% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.007483 | 11.591% |
| 合计 |  | 0.064564 | 100.000% |

**结论：Query Embedding占77.440%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.000896s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000021 | 2.317% |
| 集合检查 | 检查目标集合与检索器 | 0.000875 | 97.683% |
| 合计 |  | 0.000896 | 100.000% |

**结论：集合检查占97.683%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000020s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000009 | 43.123% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 11.130% |
| 结果处理内部 | 结果处理调度 | 0.000009 | 45.747% |
| 合计 |  | 0.000020 | 100.000% |

**结论：结果处理内部占45.748%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.624745s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.013190 | 2.111% |
| 记忆检索 | 查询相关记忆 | 0.052865 | 8.462% |
| 上下文筛选 | 选择候选记忆 | 0.000183 | 0.029% |
| 记忆读取 | 读取记忆正文 | 0.411750 | 65.907% |
| 重排 | 调整候选顺序 | 0.004171 | 0.668% |
| Prompt准备 | 构造回答输入 | 0.111664 | 17.874% |
| 回答LLM | 生成最终回答 | 0.030884 | 4.943% |
| 响应解析 | 解析回答结果 | 0.000037 | 0.006% |
| 合计 |  | 0.624745 | 100.000% |

**结论：记忆读取占65.907%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-08T22:46:43+08:00 |
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
| 检索耗时(s) | 0.064564 | 0.065443 | 0.074528 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_97b266dd632444e4bec7dddc7d727db8 | 39 | 0.056424 | 0.000030 | 0.005224 | 0.025434 | 0.014880 | 0.000008 | 0.000002 |
| 1 | sample_0_qa1 | tm_ce21dd37bcdd47fa9f2016d95051c08c | 39 | 0.050126 | 0.000021 | 0.004114 | 0.028312 | 0.006375 | 0.000007 | 0.000002 |
| 2 | sample_0_qa2 | tm_d138f21b872f435cb51eb48e8f4cfe47 | 39 | 0.066272 | 0.000018 | 0.001094 | 0.022385 | 0.028494 | 0.000009 | 0.000002 |
| 3 | sample_0_qa3 | tm_e9b7683174a94acf915699c31500e048 | 39 | 0.044104 | 0.000019 | 0.001967 | 0.019313 | 0.012865 | 0.000010 | 0.000003 |
| 4 | sample_0_qa4 | tm_ea38335b93ef44459f02976de7cc4142 | 39 | 0.071818 | 0.000023 | 0.001780 | 0.055201 | 0.006719 | 0.000008 | 0.000002 |
| 5 | sample_0_qa5 | tm_a17d1ff103314b13affe881c83290daf | 39 | 0.067466 | 0.000017 | 0.002368 | 0.051611 | 0.006418 | 0.000009 | 0.000002 |
| 6 | sample_0_qa6 | tm_b9a1be4eef734d2fa3b5e0a616424d01 | 39 | 0.024622 | 0.000020 | 0.001805 | 0.010237 | 0.004231 | 0.000007 | 0.000002 |
| 7 | sample_0_qa7 | tm_72412ec4305a471db6a1257a1338287c | 39 | 0.068963 | 0.000026 | 0.000197 | 0.053026 | 0.005564 | 0.000009 | 0.000003 |
| 8 | sample_0_qa8 | tm_1f0f46c1e5454c909a6a9a16be9e5a34 | 39 | 0.014586 | 0.000020 | 0.000229 | 0.006950 | 0.002217 | 0.000009 | 0.000002 |
| 9 | sample_0_qa9 | tm_2f207487a8fd4b9c9a4e2315dadfe1b7 | 39 | 0.057109 | 0.000022 | 0.000264 | 0.048918 | 0.002309 | 0.000009 | 0.000003 |
| 10 | sample_0_qa10 | tm_18d6a4681b26433c957b7d46d80f95d3 | 39 | 0.064215 | 0.000022 | 0.001806 | 0.051814 | 0.003885 | 0.000009 | 0.000003 |
| 11 | sample_0_qa11 | tm_dc4df2752d62463abb8fbd3611c5a9e1 | 39 | 0.079367 | 0.000018 | 0.000341 | 0.061363 | 0.011888 | 0.000008 | 0.000002 |
| 12 | sample_0_qa12 | tm_711fe62978944b5181e83487c5917601 | 39 | 0.061103 | 0.000022 | 0.000180 | 0.050494 | 0.004680 | 0.000008 | 0.000002 |
| 13 | sample_0_qa13 | tm_d4df12356e6c4e55835f06eebd9e2a9f | 39 | 0.060718 | 0.000022 | 0.000261 | 0.049749 | 0.005519 | 0.000008 | 0.000002 |
| 14 | sample_0_qa14 | tm_e3b706e9f03a4a65bfc0cf656712b10d | 39 | 0.078623 | 0.000026 | 0.003139 | 0.056274 | 0.002584 | 0.000009 | 0.000002 |
| 15 | sample_0_qa15 | tm_18e617a3dbc84a6491c0a613f0c5c678 | 39 | 0.086202 | 0.000022 | 0.006584 | 0.057014 | 0.013235 | 0.000009 | 0.000002 |
| 16 | sample_0_qa16 | tm_cfeb45998eda46dda053a5e4efeac426 | 39 | 0.088066 | 0.000020 | 0.000850 | 0.057992 | 0.014349 | 0.000008 | 0.000002 |
| 17 | sample_0_qa17 | tm_f4c786bda8e2440eaaf67c9c6ce40542 | 39 | 0.072055 | 0.000023 | 0.002159 | 0.055273 | 0.008036 | 0.000008 | 0.000002 |
| 18 | sample_0_qa18 | tm_b17408ba7a9a48cc89860fc0e00a82c7 | 39 | 0.066784 | 0.000023 | 0.000275 | 0.052216 | 0.001985 | 0.000009 | 0.000002 |
| 19 | sample_0_qa19 | tm_3867837687d44f5987657f855fc8118a | 39 | 0.078467 | 0.000026 | 0.002943 | 0.050105 | 0.016179 | 0.000008 | 0.000002 |
| 20 | sample_0_qa20 | tm_fa6680385dd64694bcc7c41e730e0ef3 | 39 | 0.071872 | 0.000023 | 0.002182 | 0.053141 | 0.005905 | 0.000008 | 0.000003 |
| 21 | sample_0_qa21 | tm_b7cda2ea370c4a96b1cd60c76a138d98 | 39 | 0.072574 | 0.000022 | 0.000577 | 0.056720 | 0.007338 | 0.000008 | 0.000002 |
| 22 | sample_0_qa22 | tm_77101ad37f074baea412396c9cf0dee4 | 39 | 0.056620 | 0.000020 | 0.000272 | 0.048439 | 0.002607 | 0.000009 | 0.000003 |
| 23 | sample_0_qa23 | tm_fc6a5402835748bf87ab4eec68106abe | 39 | 0.073799 | 0.000023 | 0.002370 | 0.057973 | 0.003393 | 0.000008 | 0.000002 |
| 24 | sample_0_qa24 | tm_a482e230cecb483885d8ba2ed8b887dc | 39 | 0.075219 | 0.000018 | 0.001680 | 0.051761 | 0.013760 | 0.000008 | 0.000002 |
| 25 | sample_0_qa25 | tm_e32226458e4c4f0996f114fd9a5b4c8d | 39 | 0.075399 | 0.000018 | 0.000466 | 0.054782 | 0.012942 | 0.000008 | 0.000002 |
| 26 | sample_0_qa26 | tm_4cff2277d814406c8d4e34722de539be | 39 | 0.065584 | 0.000021 | 0.000824 | 0.053435 | 0.005414 | 0.000009 | 0.000003 |
| 27 | sample_0_qa27 | tm_dd00711d8e08410ab4ef5abb5724d009 | 39 | 0.076254 | 0.000023 | 0.006242 | 0.055915 | 0.001996 | 0.000009 | 0.000002 |
| 28 | sample_0_qa28 | tm_329ebc5a9f6347819ffa325b4e08249b | 39 | 0.039239 | 0.000020 | 0.001891 | 0.014858 | 0.010304 | 0.000008 | 0.000002 |
| 29 | sample_0_qa29 | tm_c16191344eaf43008bc45607b6f911a0 | 39 | 0.035159 | 0.000018 | 0.001209 | 0.019172 | 0.003801 | 0.000008 | 0.000002 |
| 30 | sample_0_qa30 | tm_6e854d927f114c059cdf4f42ff1b3a67 | 39 | 0.072993 | 0.000023 | 0.001715 | 0.061214 | 0.002124 | 0.000009 | 0.000003 |
| 31 | sample_0_qa31 | tm_0996ecc2c6224a4186bbc4114e317606 | 39 | 0.060103 | 0.000020 | 0.000491 | 0.048854 | 0.003241 | 0.000009 | 0.000003 |
| 32 | sample_0_qa32 | tm_bf17e1d02e16433883f5e71fd1c88a83 | 39 | 0.017320 | 0.000018 | 0.000183 | 0.009243 | 0.001984 | 0.000009 | 0.000002 |
| 33 | sample_0_qa33 | tm_98a0842ce14d4c018db8fc17dc2ab11e | 39 | 0.059963 | 0.000021 | 0.000242 | 0.051404 | 0.002655 | 0.000009 | 0.000002 |
| 34 | sample_0_qa34 | tm_50c638dba0224b94849d03a91bb4bf8f | 39 | 0.058124 | 0.000023 | 0.000271 | 0.048344 | 0.004063 | 0.000008 | 0.000002 |
| 35 | sample_0_qa35 | tm_34cfbffd32b54ee0b9666e67009557e1 | 39 | 0.073203 | 0.000022 | 0.000245 | 0.052690 | 0.011112 | 0.000008 | 0.000002 |
| 36 | sample_0_qa36 | tm_ea151c5c248549d696ffcfa8dbb6e2e8 | 39 | 0.059230 | 0.000023 | 0.000193 | 0.049518 | 0.002964 | 0.000009 | 0.000002 |
| 37 | sample_0_qa37 | tm_245665c403a240beb65b23cb2d7873be | 39 | 0.061057 | 0.000023 | 0.000268 | 0.048359 | 0.003231 | 0.000009 | 0.000002 |
| 38 | sample_0_qa38 | tm_e6864c5866b4473184683b1da54a78cf | 39 | 0.058455 | 0.000022 | 0.000627 | 0.049088 | 0.002561 | 0.000008 | 0.000002 |
| 39 | sample_0_qa39 | tm_5a8825c241c94cc49c5f9ca9465a5894 | 39 | 0.066022 | 0.000020 | 0.001551 | 0.051150 | 0.005240 | 0.000008 | 0.000002 |
| 40 | sample_0_qa40 | tm_c200af84ce7a4b988880b0cdf9b748a7 | 39 | 0.065990 | 0.000018 | 0.000382 | 0.053715 | 0.004244 | 0.000008 | 0.000002 |
| 41 | sample_0_qa41 | tm_2ba72dd3294b4ef5877850322eb536cb | 39 | 0.072455 | 0.000021 | 0.004086 | 0.052811 | 0.009363 | 0.000008 | 0.000002 |
| 42 | sample_0_qa42 | tm_d5143e9c3d6b4c48b57ca164551b45e6 | 39 | 0.059553 | 0.000023 | 0.000257 | 0.049251 | 0.003149 | 0.000009 | 0.000002 |
| 43 | sample_0_qa43 | tm_e20aa550b1544434b42ce1ef0dff9eed | 39 | 0.060033 | 0.000022 | 0.000843 | 0.048207 | 0.002165 | 0.000009 | 0.000002 |
| 44 | sample_0_qa44 | tm_74d5067776724083879476ae41e9b8e5 | 39 | 0.065885 | 0.000019 | 0.000387 | 0.054008 | 0.004481 | 0.000009 | 0.000002 |
| 45 | sample_0_qa45 | tm_8542c9b25bad4d73b6b19dc40651d8b3 | 39 | 0.063547 | 0.000023 | 0.001598 | 0.048921 | 0.006516 | 0.000009 | 0.000003 |
| 46 | sample_0_qa46 | tm_191ae7db40e94eb3b3359a9bdc6762bd | 39 | 0.063570 | 0.000018 | 0.000412 | 0.052613 | 0.005009 | 0.000008 | 0.000002 |
| 47 | sample_0_qa47 | tm_fab3e9449cdd47299397aaa10bdf3f17 | 39 | 0.071052 | 0.000022 | 0.000193 | 0.052556 | 0.009134 | 0.000008 | 0.000002 |
| 48 | sample_0_qa48 | tm_10a1abe09dec4463ba1062de7a85b317 | 39 | 0.059240 | 0.000021 | 0.000188 | 0.048982 | 0.003121 | 0.000009 | 0.000002 |
| 49 | sample_0_qa49 | tm_1338a9c3f2114ede9b4e05f10ebdc2c2 | 39 | 0.069996 | 0.000022 | 0.001464 | 0.056988 | 0.005836 | 0.000008 | 0.000002 |
| 50 | sample_0_qa50 | tm_ba8fb7b9bc6b440693e0320a84061c58 | 39 | 0.065926 | 0.000019 | 0.000434 | 0.051062 | 0.006633 | 0.000009 | 0.000002 |
| 51 | sample_0_qa51 | tm_6fb12d3d639245048b640300428b89fe | 39 | 0.063307 | 0.000019 | 0.001920 | 0.048425 | 0.006112 | 0.000009 | 0.000003 |
| 52 | sample_0_qa52 | tm_a5d8877efe054fd6b58aa86d75ca6e00 | 39 | 0.063305 | 0.000020 | 0.001282 | 0.048439 | 0.004884 | 0.000008 | 0.000002 |
| 53 | sample_0_qa53 | tm_3af2010438d44bc9adefb7a4d9d25a57 | 39 | 0.063341 | 0.000023 | 0.001280 | 0.048750 | 0.006533 | 0.000008 | 0.000002 |
| 54 | sample_0_qa54 | tm_c4b5885fcb8349ad888d7c5ddefa183b | 39 | 0.063289 | 0.000018 | 0.000337 | 0.053197 | 0.004142 | 0.000008 | 0.000002 |
| 55 | sample_0_qa55 | tm_06a8df211e5f41e5bbc9284df6407499 | 39 | 0.063968 | 0.000023 | 0.001934 | 0.049423 | 0.005572 | 0.000009 | 0.000003 |
| 56 | sample_0_qa56 | tm_c4f1790e269d4b44b9192515a511697a | 39 | 0.064534 | 0.000018 | 0.000338 | 0.052809 | 0.005455 | 0.000008 | 0.000002 |
| 57 | sample_0_qa57 | tm_51a9fb4057e9444ab7fb15d1180ca21c | 39 | 0.064262 | 0.000020 | 0.001911 | 0.049305 | 0.006811 | 0.000009 | 0.000002 |
| 58 | sample_0_qa58 | tm_3e0db66eb1404973a1842be88e703a45 | 39 | 0.064232 | 0.000019 | 0.000362 | 0.052766 | 0.005507 | 0.000008 | 0.000002 |
| 59 | sample_0_qa59 | tm_8655087e6c5848dab110a562b7c4e8cd | 39 | 0.063281 | 0.000022 | 0.001976 | 0.048490 | 0.006144 | 0.000009 | 0.000002 |
| 60 | sample_0_qa60 | tm_51256965743e4f1ba829712d015de296 | 39 | 0.067239 | 0.000019 | 0.000368 | 0.054501 | 0.006454 | 0.000009 | 0.000002 |
| 61 | sample_0_qa61 | tm_ba9236bf9d0646b6880e44e17a3d11b3 | 39 | 0.063637 | 0.000019 | 0.001331 | 0.048868 | 0.007199 | 0.000009 | 0.000002 |
| 62 | sample_0_qa62 | tm_94c7ff72d1f64c8d9f9bfbe2f07970e4 | 39 | 0.065076 | 0.000016 | 0.000288 | 0.051940 | 0.007608 | 0.000008 | 0.000002 |
| 63 | sample_0_qa63 | tm_5184130152d243c8b55fcc7a2866ccac | 39 | 0.063985 | 0.000020 | 0.000233 | 0.051644 | 0.006153 | 0.000009 | 0.000003 |
| 64 | sample_0_qa64 | tm_48c505532f434ae9832d220fe7c78466 | 39 | 0.059659 | 0.000024 | 0.000554 | 0.048273 | 0.005018 | 0.000008 | 0.000002 |
| 65 | sample_0_qa65 | tm_d3e53ee4b5614f448396c7d3d149aa7b | 39 | 0.067114 | 0.000022 | 0.000367 | 0.052298 | 0.005939 | 0.000009 | 0.000002 |
| 66 | sample_0_qa66 | tm_00221a06035a4ccdaa7887b02b4c0b63 | 39 | 0.065661 | 0.000018 | 0.000162 | 0.055296 | 0.005139 | 0.000008 | 0.000002 |
| 67 | sample_0_qa67 | tm_95bf3bb44ced4ea0a365707b62789447 | 39 | 0.066584 | 0.000022 | 0.001259 | 0.049599 | 0.009125 | 0.000008 | 0.000002 |
| 68 | sample_0_qa68 | tm_1541c65802a54e2ebfde5a3960d25f41 | 39 | 0.061464 | 0.000018 | 0.000345 | 0.053001 | 0.002433 | 0.000009 | 0.000003 |
| 69 | sample_0_qa69 | tm_b8bda4ceefec400f9c504d743ea16b54 | 39 | 0.067550 | 0.000023 | 0.001887 | 0.049530 | 0.009919 | 0.000008 | 0.000002 |
| 70 | sample_0_qa70 | tm_2ac67ca730b5497782473407b30a8651 | 39 | 0.062202 | 0.000018 | 0.000328 | 0.053410 | 0.001931 | 0.000009 | 0.000003 |
| 71 | sample_0_qa71 | tm_4f56ce34cc8a43eaaedd247feb9e2771 | 39 | 0.065099 | 0.000022 | 0.000327 | 0.049628 | 0.006909 | 0.000009 | 0.000002 |
| 72 | sample_0_qa72 | tm_a77e1e97e0b34611a2d0fb6a413f0bce | 39 | 0.064115 | 0.000019 | 0.000184 | 0.053064 | 0.005774 | 0.000008 | 0.000002 |
| 73 | sample_0_qa73 | tm_8f7805e63e604779bcac3fdc18f9887b | 39 | 0.064396 | 0.000020 | 0.000346 | 0.049612 | 0.007164 | 0.000009 | 0.000003 |
| 74 | sample_0_qa74 | tm_bd82dfa17f0940f4b40a479ff0a2fd22 | 39 | 0.063072 | 0.000019 | 0.001244 | 0.050417 | 0.005524 | 0.000008 | 0.000002 |
| 75 | sample_0_qa75 | tm_060ab8105b98483cae3dec21bd19c38e | 39 | 0.061617 | 0.000022 | 0.000531 | 0.048499 | 0.005622 | 0.000008 | 0.000002 |
| 76 | sample_0_qa76 | tm_8c9a93490bd44d88abe6c0efad11cd5d | 39 | 0.064563 | 0.000018 | 0.000211 | 0.054008 | 0.004878 | 0.000009 | 0.000002 |
| 77 | sample_0_qa77 | tm_6d30570594b24277ba167e98b9e91abd | 39 | 0.066170 | 0.000023 | 0.001313 | 0.049633 | 0.005219 | 0.000009 | 0.000003 |
| 78 | sample_0_qa78 | tm_fb07048222eb40a0be94f77b9ff46d2e | 39 | 0.068292 | 0.000018 | 0.000370 | 0.054536 | 0.004417 | 0.000009 | 0.000002 |
| 79 | sample_0_qa79 | tm_d65479a57a224509bbccf26d9e69f599 | 39 | 0.065982 | 0.000023 | 0.000367 | 0.049019 | 0.007347 | 0.000010 | 0.000003 |
| 80 | sample_0_qa80 | tm_446116f76b87470cb44f7a72acb89c6e | 39 | 0.062836 | 0.000019 | 0.001210 | 0.048956 | 0.005368 | 0.000008 | 0.000002 |
| 81 | sample_0_qa81 | tm_24b0975e4bae4019a4306d6c7e9f5373 | 39 | 0.067249 | 0.000021 | 0.000308 | 0.052830 | 0.004799 | 0.000009 | 0.000002 |
| 82 | sample_0_qa82 | tm_f2716c57823e420b83b9136d40583f9c | 39 | 0.066376 | 0.000018 | 0.000170 | 0.055897 | 0.005035 | 0.000008 | 0.000002 |
| 83 | sample_0_qa83 | tm_eed9b75390974589a0a420a2f9de3f8a | 39 | 0.065840 | 0.000022 | 0.000465 | 0.055828 | 0.002523 | 0.000008 | 0.000002 |
| 84 | sample_0_qa84 | tm_44761a0b67b74b429a5ceaedb3cc2941 | 39 | 0.067327 | 0.000020 | 0.000202 | 0.052648 | 0.009069 | 0.000008 | 0.000002 |
| 85 | sample_0_qa85 | tm_6031624cb3ff4eff86fdddf105a68a02 | 39 | 0.065411 | 0.000020 | 0.000309 | 0.052931 | 0.003558 | 0.000009 | 0.000002 |
| 86 | sample_0_qa86 | tm_9e4fe4bb04a247cc88ef24d09801cc9a | 39 | 0.064165 | 0.000020 | 0.000651 | 0.047860 | 0.008938 | 0.000008 | 0.000002 |
| 87 | sample_0_qa87 | tm_2bad055076f84d00a5592f165c5dc2f1 | 39 | 0.064100 | 0.000019 | 0.000363 | 0.049821 | 0.005947 | 0.000009 | 0.000002 |
| 88 | sample_0_qa88 | tm_4fba6182b2854dc4b14cc8d33a3f6e6b | 39 | 0.066106 | 0.000018 | 0.000163 | 0.055642 | 0.004792 | 0.000008 | 0.000002 |
| 89 | sample_0_qa89 | tm_587f582485234d939727ec940c37abba | 39 | 0.069589 | 0.000023 | 0.001468 | 0.051480 | 0.008826 | 0.000008 | 0.000002 |
| 90 | sample_0_qa90 | tm_d091bdd3bc9947d6b8ed9e8289ada386 | 39 | 0.065474 | 0.000019 | 0.000169 | 0.054580 | 0.003392 | 0.000009 | 0.000003 |
| 91 | sample_0_qa91 | tm_0ac1c6a079214d62ae4a4aabe579e654 | 39 | 0.071027 | 0.000022 | 0.000291 | 0.050951 | 0.009217 | 0.000009 | 0.000002 |
| 92 | sample_0_qa92 | tm_4ab6a73e3e454fb789ddf6b6bfa41dc6 | 39 | 0.063766 | 0.000018 | 0.000167 | 0.053987 | 0.003773 | 0.000009 | 0.000003 |
| 93 | sample_0_qa93 | tm_1feec4993ed848d6a69ee8a84a563f47 | 39 | 0.066927 | 0.000022 | 0.001931 | 0.048652 | 0.010001 | 0.000008 | 0.000002 |
| 94 | sample_0_qa94 | tm_25e40c5a6290441abf0296886e740c6d | 39 | 0.062862 | 0.000018 | 0.000344 | 0.052391 | 0.003880 | 0.000009 | 0.000002 |
| 95 | sample_0_qa95 | tm_6b95e1b7954c4810ae97188784c07197 | 39 | 0.064368 | 0.000023 | 0.002000 | 0.048861 | 0.007403 | 0.000009 | 0.000002 |
| 96 | sample_0_qa96 | tm_bd9afe7330744c5fa59ed621bf93d791 | 39 | 0.064267 | 0.000018 | 0.000411 | 0.050514 | 0.005623 | 0.000008 | 0.000002 |
| 97 | sample_0_qa97 | tm_7d92c14342eb4972a75241bc59adb036 | 39 | 0.066951 | 0.000022 | 0.001993 | 0.052095 | 0.006583 | 0.000009 | 0.000003 |
| 98 | sample_0_qa98 | tm_f2461d3e4a1c49e1a25b4daa55c5f3f3 | 39 | 0.066957 | 0.000019 | 0.000361 | 0.055155 | 0.005658 | 0.000008 | 0.000002 |
| 99 | sample_0_qa99 | tm_88a0aac431114683b767638a3ee239d2 | 39 | 0.069331 | 0.000020 | 0.001885 | 0.051019 | 0.009570 | 0.000008 | 0.000002 |
| 100 | sample_0_qa100 | tm_e0760068e9d24bdba72cf2644e72b8a2 | 39 | 0.063937 | 0.000020 | 0.000878 | 0.052034 | 0.002504 | 0.000010 | 0.000003 |
| 101 | sample_0_qa101 | tm_2df913987e7d43fa8160bbd5f5d289b3 | 39 | 0.063973 | 0.000023 | 0.001405 | 0.048804 | 0.006822 | 0.000009 | 0.000002 |
| 102 | sample_0_qa102 | tm_156b8c807fa14eaf9ca0d275319d5f7b | 39 | 0.064027 | 0.000019 | 0.000335 | 0.052228 | 0.005636 | 0.000008 | 0.000002 |
| 103 | sample_0_qa103 | tm_c56e2e86d6d54e1697f305ddbfc78721 | 39 | 0.071405 | 0.000023 | 0.000552 | 0.052637 | 0.009456 | 0.000009 | 0.000002 |
| 104 | sample_0_qa104 | tm_d553042487134861a4e18bd969d80210 | 39 | 0.065863 | 0.000019 | 0.000193 | 0.056022 | 0.003710 | 0.000009 | 0.000002 |
| 105 | sample_0_qa105 | tm_879142ae0eda4466938133f1a48aa573 | 39 | 0.059427 | 0.000022 | 0.000393 | 0.048983 | 0.002608 | 0.000009 | 0.000002 |
| 106 | sample_0_qa106 | tm_fa302f4eda5c4adda74aa6576b38e813 | 39 | 0.067240 | 0.000018 | 0.000167 | 0.057192 | 0.004127 | 0.000008 | 0.000002 |
| 107 | sample_0_qa107 | tm_576f6afd135840259c64a8d0368aee7f | 39 | 0.067194 | 0.000023 | 0.000301 | 0.051897 | 0.006911 | 0.000009 | 0.000002 |
| 108 | sample_0_qa108 | tm_6e55abfcfbfb4eb1b3feaab9dae9d551 | 39 | 0.067126 | 0.000019 | 0.000224 | 0.054959 | 0.005915 | 0.000008 | 0.000002 |
| 109 | sample_0_qa109 | tm_105c878d74e94666aa60735d010b1c0f | 39 | 0.067154 | 0.000022 | 0.000180 | 0.051371 | 0.006024 | 0.000008 | 0.000002 |
| 110 | sample_0_qa110 | tm_9ae7b2d518294de2b747a169f70962fd | 39 | 0.062134 | 0.000019 | 0.000191 | 0.051037 | 0.004979 | 0.000009 | 0.000002 |
| 111 | sample_0_qa111 | tm_a83777e464ce4e0398fbd5617cb6f7f6 | 39 | 0.073962 | 0.000023 | 0.000401 | 0.052937 | 0.012572 | 0.000009 | 0.000002 |
| 112 | sample_0_qa112 | tm_74baf41072704961bf7a1ddb93a1e4d1 | 39 | 0.064853 | 0.000019 | 0.000164 | 0.056003 | 0.002494 | 0.000008 | 0.000002 |
| 113 | sample_0_qa113 | tm_f23d3711a20d43a8983a0f899d327575 | 39 | 0.067070 | 0.000022 | 0.000366 | 0.051507 | 0.005323 | 0.000009 | 0.000002 |
| 114 | sample_0_qa114 | tm_f00b9b30f00e49f188e953fce154e514 | 39 | 0.066729 | 0.000019 | 0.000192 | 0.056511 | 0.004742 | 0.000009 | 0.000002 |
| 115 | sample_0_qa115 | tm_b9509642cbfd47058f41ec81a4e5040b | 39 | 0.067521 | 0.000022 | 0.000223 | 0.051266 | 0.009723 | 0.000008 | 0.000002 |
| 116 | sample_0_qa116 | tm_b7c55b9d2cf24169a13d6370d15cdd4d | 39 | 0.057278 | 0.000025 | 0.000642 | 0.047763 | 0.002536 | 0.000010 | 0.000003 |
| 117 | sample_0_qa117 | tm_0927eae65cfe48b3bba2ac15e095214c | 39 | 0.063713 | 0.000020 | 0.000284 | 0.048555 | 0.005634 | 0.000009 | 0.000003 |
| 118 | sample_0_qa118 | tm_0a87abccff8c46c29c5f35105104ce4b | 39 | 0.064001 | 0.000018 | 0.000237 | 0.051928 | 0.004901 | 0.000008 | 0.000002 |
| 119 | sample_0_qa119 | tm_de8c608082194efe857eeed96665b798 | 39 | 0.067443 | 0.000021 | 0.000280 | 0.048725 | 0.009887 | 0.000009 | 0.000002 |
| 120 | sample_0_qa120 | tm_4a0d9a47da614af6927df099ac8ac4d7 | 39 | 0.060126 | 0.000020 | 0.000657 | 0.049893 | 0.002322 | 0.000009 | 0.000002 |
| 121 | sample_0_qa121 | tm_deb7e8eedd7e4c1895508eb946e49941 | 39 | 0.064494 | 0.000022 | 0.000405 | 0.049471 | 0.005542 | 0.000009 | 0.000003 |
| 122 | sample_0_qa122 | tm_bd58db1f0913406584f7285f0c3b0104 | 39 | 0.062897 | 0.000020 | 0.001273 | 0.049757 | 0.005583 | 0.000008 | 0.000002 |
| 123 | sample_0_qa123 | tm_c44a5690c0c74560963e9be27e478638 | 39 | 0.061149 | 0.000022 | 0.000406 | 0.047944 | 0.003880 | 0.000008 | 0.000003 |
| 124 | sample_0_qa124 | tm_8f9fa13446ed43528cf6ec40f0b15921 | 39 | 0.067648 | 0.000019 | 0.000301 | 0.057767 | 0.003875 | 0.000008 | 0.000003 |
| 125 | sample_0_qa125 | tm_e98dea6db0c7434286a04e85000d721d | 39 | 0.065612 | 0.000022 | 0.000297 | 0.048926 | 0.007550 | 0.000009 | 0.000002 |
| 126 | sample_0_qa126 | tm_12285a9927424b33b4df1046a1b7fe9b | 39 | 0.066226 | 0.000020 | 0.000634 | 0.050291 | 0.007707 | 0.000009 | 0.000002 |
| 127 | sample_0_qa127 | tm_c78b415c34e440c5b17fc077cd9c954c | 39 | 0.071083 | 0.000023 | 0.000189 | 0.053989 | 0.006867 | 0.000009 | 0.000003 |
| 128 | sample_0_qa128 | tm_24c2543ebfb74ed898aeb6088507534e | 39 | 0.064399 | 0.000023 | 0.000582 | 0.049312 | 0.006333 | 0.000008 | 0.000002 |
| 129 | sample_0_qa129 | tm_54413f22e674463bafd954aaddfc27ce | 39 | 0.068397 | 0.000022 | 0.000492 | 0.053478 | 0.005311 | 0.000008 | 0.000002 |
| 130 | sample_0_qa130 | tm_c3d171870fda4833a61ea72a23813c15 | 39 | 0.062478 | 0.000019 | 0.000167 | 0.050327 | 0.006120 | 0.000009 | 0.000002 |
| 131 | sample_0_qa131 | tm_98ab70961d2f4d4bb28795bad98fab87 | 39 | 0.071079 | 0.000023 | 0.000381 | 0.050968 | 0.009654 | 0.000009 | 0.000002 |
| 132 | sample_0_qa132 | tm_07129fd0135143a9b2253c3feab5bdf6 | 39 | 0.063062 | 0.000019 | 0.000187 | 0.053979 | 0.002558 | 0.000009 | 0.000003 |
| 133 | sample_0_qa133 | tm_9233ac446e81494b90e59c48b172968a | 39 | 0.065773 | 0.000023 | 0.001949 | 0.048583 | 0.008686 | 0.000009 | 0.000003 |
| 134 | sample_0_qa134 | tm_74a844cc408b407dad5a21d0add2e839 | 39 | 0.067463 | 0.000019 | 0.000359 | 0.052877 | 0.008215 | 0.000009 | 0.000002 |
| 135 | sample_0_qa135 | tm_ffe39d2d18144b978c9cf0604760f652 | 39 | 0.069142 | 0.000022 | 0.000462 | 0.055664 | 0.003776 | 0.000008 | 0.000002 |
| 136 | sample_0_qa136 | tm_40a813a7b363416b9c043439afe55458 | 39 | 0.067557 | 0.000019 | 0.000240 | 0.052494 | 0.009628 | 0.000008 | 0.000002 |
| 137 | sample_0_qa137 | tm_4632e285ed6d47ebbc096ae0ad6fbfcd | 39 | 0.063554 | 0.000023 | 0.000316 | 0.051048 | 0.003244 | 0.000009 | 0.000002 |
| 138 | sample_0_qa138 | tm_6a8e18665cd045f0badf40e258e64b92 | 39 | 0.069017 | 0.000019 | 0.000165 | 0.059752 | 0.003686 | 0.000008 | 0.000002 |
| 139 | sample_0_qa139 | tm_951f1a64e5fd4ad691b76833f0bed180 | 39 | 0.069348 | 0.000020 | 0.001642 | 0.050438 | 0.009080 | 0.000007 | 0.000002 |
| 140 | sample_0_qa140 | tm_fa78fe0eee0a425697c801a9ac5d0974 | 39 | 0.064791 | 0.000018 | 0.000913 | 0.053901 | 0.003425 | 0.000009 | 0.000002 |
| 141 | sample_0_qa141 | tm_7bb2d96e5eaf415f83e4b0b6e5d2ac7a | 39 | 0.070306 | 0.000020 | 0.000260 | 0.054870 | 0.006525 | 0.000009 | 0.000002 |
| 142 | sample_0_qa142 | tm_904885812f7d4e7a9c044753ce33b5b6 | 39 | 0.063120 | 0.000019 | 0.000177 | 0.051321 | 0.005670 | 0.000008 | 0.000002 |
| 143 | sample_0_qa143 | tm_7aaca907b8344303800ae0c93bc0d195 | 39 | 0.063899 | 0.000021 | 0.000877 | 0.049280 | 0.005777 | 0.000009 | 0.000002 |
| 144 | sample_0_qa144 | tm_6ccb6eca7fcd462085166e68599a9927 | 39 | 0.065474 | 0.000019 | 0.000175 | 0.053286 | 0.006303 | 0.000008 | 0.000002 |
| 145 | sample_0_qa145 | tm_4a05157656cb4318adcde40d4649f45a | 39 | 0.064959 | 0.000023 | 0.000300 | 0.049215 | 0.007295 | 0.000009 | 0.000002 |
| 146 | sample_0_qa146 | tm_83c5ed79b9c749a99865fd3af990b98b | 39 | 0.067312 | 0.000019 | 0.000162 | 0.053343 | 0.007997 | 0.000008 | 0.000002 |
| 147 | sample_0_qa147 | tm_7fe1a6373118476c8b09741cb64d4cf3 | 39 | 0.069812 | 0.000023 | 0.000287 | 0.051659 | 0.008801 | 0.000008 | 0.000002 |
| 148 | sample_0_qa148 | tm_4c1630474a0340b285a327687490cbe2 | 39 | 0.064212 | 0.000020 | 0.000184 | 0.054739 | 0.003497 | 0.000009 | 0.000002 |
| 149 | sample_0_qa149 | tm_e16a32bf797f49c68409489d5fb16cff | 39 | 0.072396 | 0.000025 | 0.000863 | 0.057154 | 0.005384 | 0.000009 | 0.000002 |
| 150 | sample_0_qa150 | tm_683013b7ef0644c69a3e6aafaad5c710 | 39 | 0.065594 | 0.000019 | 0.000280 | 0.052170 | 0.005113 | 0.000009 | 0.000003 |
| 151 | sample_0_qa151 | tm_664e0b0ba9a8407485a4c13e29482a01 | 39 | 0.058792 | 0.000019 | 0.000287 | 0.050109 | 0.001837 | 0.000008 | 0.000002 |

问答端到端平均耗时：0.624934s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 3.35 | 0.033937 | 0.686877 | 2.116266 | 0.380789 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 3.36 | 0.088352 | 0.657717 | 2.115541 | 0.384344 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 3.35 | 0.061031 | 0.628863 | 2.115745 | 0.381506 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 3.35 | 0.048135 | 0.673190 | 2.114965 | 0.381350 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 3.36 | 0.087796 | 0.630995 | 2.115762 | 0.384155 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 3.36 | 0.083727 | 0.634509 | 2.116431 | 0.387243 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 3.35 | 0.055492 | 0.633952 | 2.117937 | 0.380241 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 3.35 | 0.048255 | 0.675482 | 2.115698 | 0.385112 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.42 | 0.017238 | 0.376698 | 0.000239 | 0.010051 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.49 | 0.071533 | 0.375288 | 0.000232 | 0.012548 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.46 | 0.040525 | 0.378312 | 0.000238 | 0.010957 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.44 | 0.028249 | 0.368151 | 0.000245 | 0.009668 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.49 | 0.088645 | 0.378191 | 0.000218 | 0.009597 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.49 | 0.084092 | 0.378394 | 0.000234 | 0.009641 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.45 | 0.046382 | 0.364335 | 0.000221 | 0.014030 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.45 | 0.039666 | 0.373858 | 0.000237 | 0.016054 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.029652 | 0.408327 | 0.000537 | 0.010370 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.5 | 0.091588 | 0.392462 | 0.000227 | 0.008982 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.45 | 0.023984 | 0.402105 | 0.000486 | 0.012264 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.43 | 0.077399 | 0.324389 | 0.000522 | 0.010298 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.033194 | 0.361377 | 0.000611 | 0.010829 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.086524 | 0.357012 | 0.000502 | 0.010530 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.46 | 0.044170 | 0.383998 | 0.000219 | 0.014148 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.46 | 0.050023 | 0.379738 | 0.000203 | 0.014749 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.41 | 0.031088 | 0.366399 | 0.000222 | 0.008680 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.51 | 0.071432 | 0.410913 | 0.000448 | 0.014357 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.46 | 0.021382 | 0.417146 | 0.000493 | 0.009010 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.49 | 0.083225 | 0.386120 | 0.000509 | 0.008729 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.39 | 0.030197 | 0.345581 | 0.000223 | 0.009244 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.070837 | 0.367112 | 0.000215 | 0.013321 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.45 | 0.041529 | 0.377041 | 0.000222 | 0.013013 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.081353 | 0.342667 | 0.000535 | 0.016431 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.4 | 0.030031 | 0.348804 | 0.000217 | 0.010224 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.032969 | 0.378922 | 0.000527 | 0.011782 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.47 | 0.072567 | 0.379716 | 0.000229 | 0.012963 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.41 | 0.022741 | 0.366753 | 0.000249 | 0.009254 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.48 | 0.084196 | 0.374505 | 0.000228 | 0.010087 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.47 | 0.083469 | 0.367712 | 0.000224 | 0.011246 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.4 | 0.033747 | 0.334991 | 0.000226 | 0.013212 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.43 | 0.038770 | 0.368065 | 0.000216 | 0.008905 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.46 | 0.038628 | 0.405576 | 0.000216 | 0.009098 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.43 | 0.038774 | 0.368175 | 0.000237 | 0.009873 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.47 | 0.077707 | 0.379794 | 0.000236 | 0.010038 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.44 | 0.023515 | 0.397513 | 0.000573 | 0.010094 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.51 | 0.094301 | 0.392679 | 0.000556 | 0.009829 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.034784 | 0.395432 | 0.000506 | 0.009040 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.5 | 0.072276 | 0.406525 | 0.000213 | 0.009635 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.44 | 0.024755 | 0.385801 | 0.000225 | 0.015874 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.45 | 0.029905 | 0.400503 | 0.000213 | 0.009988 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.46 | 0.038305 | 0.396321 | 0.000225 | 0.009649 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.44 | 0.023998 | 0.397432 | 0.000225 | 0.011651 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.5 | 0.083211 | 0.392518 | 0.000220 | 0.008798 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.41 | 0.027374 | 0.366320 | 0.000220 | 0.012818 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.47 | 0.075497 | 0.373250 | 0.000233 | 0.009570 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.44 | 0.079733 | 0.342464 | 0.000237 | 0.011577 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.42 | 0.029694 | 0.371885 | 0.000217 | 0.009719 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.44 | 0.022982 | 0.402172 | 0.000237 | 0.009516 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.47 | 0.030358 | 0.417737 | 0.000246 | 0.009485 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.029611 | 0.405615 | 0.000197 | 0.008842 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.49 | 0.087818 | 0.357396 | 0.000479 | 0.013237 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.45 | 0.017363 | 0.401694 | 0.000534 | 0.013726 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.5 | 0.075497 | 0.404155 | 0.000250 | 0.011690 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.49 | 0.076226 | 0.385195 | 0.000221 | 0.019482 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.022817 | 0.416288 | 0.000223 | 0.008621 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.47 | 0.027481 | 0.420510 | 0.000494 | 0.013565 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.47 | 0.040550 | 0.410934 | 0.000260 | 0.009143 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.45 | 0.038107 | 0.389146 | 0.000234 | 0.011850 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.44 | 0.043637 | 0.380259 | 0.000465 | 0.009405 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.45 | 0.087999 | 0.341033 | 0.000693 | 0.012241 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.41 | 0.026944 | 0.353796 | 0.000416 | 0.012395 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.46 | 0.081676 | 0.365137 | 0.000264 | 0.011383 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.48 | 0.084530 | 0.384722 | 0.000237 | 0.009158 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.44 | 0.027647 | 0.397260 | 0.000224 | 0.010920 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.47 | 0.035520 | 0.413968 | 0.000232 | 0.009321 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.061006 | 0.370415 | 0.000218 | 0.011695 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.52 | 0.070501 | 0.424114 | 0.000605 | 0.010743 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.45 | 0.023023 | 0.406661 | 0.000209 | 0.010126 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.52 | 0.081553 | 0.421384 | 0.000251 | 0.009971 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.46 | 0.030406 | 0.406569 | 0.000255 | 0.010707 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.46 | 0.077611 | 0.357176 | 0.000228 | 0.014934 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.47 | 0.031451 | 0.425076 | 0.000238 | 0.009686 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.46 | 0.030459 | 0.405807 | 0.000232 | 0.009499 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.52 | 0.089010 | 0.403309 | 0.000224 | 0.013687 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.45 | 0.038430 | 0.392082 | 0.000213 | 0.008967 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.49 | 0.032083 | 0.432135 | 0.000578 | 0.009731 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.47 | 0.074841 | 0.370973 | 0.000217 | 0.015908 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.45 | 0.035595 | 0.396636 | 0.000214 | 0.011559 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.5 | 0.073604 | 0.405417 | 0.000265 | 0.009365 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.5 | 0.035713 | 0.448057 | 0.000253 | 0.009722 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.47 | 0.032469 | 0.414042 | 0.000241 | 0.009100 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.45 | 0.030316 | 0.398211 | 0.000218 | 0.009580 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.51 | 0.081779 | 0.410269 | 0.000229 | 0.009281 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.52 | 0.068133 | 0.414044 | 0.000221 | 0.026484 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.45 | 0.019631 | 0.409464 | 0.000226 | 0.011914 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.5 | 0.078150 | 0.377316 | 0.000210 | 0.019861 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.52 | 0.074547 | 0.431983 | 0.000218 | 0.009273 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.47 | 0.024580 | 0.425718 | 0.000602 | 0.011219 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.45 | 0.039895 | 0.386606 | 0.000214 | 0.014030 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.46 | 0.039533 | 0.399674 | 0.000226 | 0.013301 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.47 | 0.033310 | 0.416273 | 0.000548 | 0.010286 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.52 | 0.072689 | 0.424978 | 0.000253 | 0.012595 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.45 | 0.043370 | 0.374446 | 0.000277 | 0.012429 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.53 | 0.083507 | 0.424226 | 0.000245 | 0.013121 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.5 | 0.075255 | 0.403787 | 0.000274 | 0.009950 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.48 | 0.040369 | 0.415733 | 0.000242 | 0.009212 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.58 | 0.087651 | 0.468173 | 0.000564 | 0.011743 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.47 | 0.045609 | 0.405774 | 0.000578 | 0.011381 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.42 | 0.024918 | 0.375870 | 0.000252 | 0.010721 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.45 | 0.028564 | 0.406385 | 0.000600 | 0.010198 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.53 | 0.074333 | 0.433470 | 0.000272 | 0.010992 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.49 | 0.074287 | 0.393929 | 0.000258 | 0.010928 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.44 | 0.043248 | 0.378805 | 0.000253 | 0.011652 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.49 | 0.043091 | 0.422596 | 0.000226 | 0.011585 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.49 | 0.041969 | 0.418652 | 0.000262 | 0.009600 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.46 | 0.045626 | 0.383965 | 0.000252 | 0.010204 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.53 | 0.094684 | 0.420237 | 0.000222 | 0.010495 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.51 | 0.076857 | 0.411286 | 0.000240 | 0.009116 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.49 | 0.087183 | 0.381164 | 0.000272 | 0.009468 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.46 | 0.025757 | 0.411397 | 0.000238 | 0.010264 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.5 | 0.095276 | 0.382114 | 0.000233 | 0.009643 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.44 | 0.042915 | 0.372867 | 0.000226 | 0.009840 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.43 | 0.027026 | 0.384303 | 0.000536 | 0.011399 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.48 | 0.077627 | 0.387077 | 0.000245 | 0.010193 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.45 | 0.062469 | 0.366033 | 0.000538 | 0.010978 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.47 | 0.077321 | 0.378674 | 0.000234 | 0.009128 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.46 | 0.077981 | 0.366589 | 0.000225 | 0.010724 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.47 | 0.029680 | 0.416745 | 0.000241 | 0.012934 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.51 | 0.076459 | 0.413249 | 0.000241 | 0.010464 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.45 | 0.034201 | 0.396563 | 0.000233 | 0.013163 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.51 | 0.032486 | 0.454539 | 0.000522 | 0.011432 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.49 | 0.036084 | 0.432920 | 0.000238 | 0.008997 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.52 | 0.077530 | 0.423462 | 0.000237 | 0.011541 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.51 | 0.072152 | 0.415703 | 0.000220 | 0.012681 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.53 | 0.072919 | 0.433440 | 0.000238 | 0.016501 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.51 | 0.036442 | 0.446831 | 0.000225 | 0.016075 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.62 | 0.027851 | 0.572992 | 0.000773 | 0.009673 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.66 | 0.081146 | 0.561717 | 0.000243 | 0.011945 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.62 | 0.035939 | 0.561392 | 0.000245 | 0.009919 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.6 | 0.035511 | 0.538679 | 0.000802 | 0.009266 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.64 | 0.046356 | 0.575500 | 0.000253 | 0.009751 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.61 | 0.034948 | 0.549313 | 0.000969 | 0.009803 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.58 | 0.035052 | 0.521212 | 0.000246 | 0.015197 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.57 | 0.131475 | 0.413633 | 0.000228 | 0.016776 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.49 | 0.027281 | 0.436281 | 0.000252 | 0.015200 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.48 | 0.026495 | 0.426220 | 0.000244 | 0.015691 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.46 | 0.028123 | 0.406451 | 0.000264 | 0.010580 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.47 | 0.080856 | 0.372365 | 0.000252 | 0.010010 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.39 | 0.035832 | 0.336780 | 0.000271 | 0.009567 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.41 | 0.073999 | 0.318905 | 0.000228 | 0.009268 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.38 | 0.080472 | 0.281314 | 0.000220 | 0.009528 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.37 | 0.039683 | 0.305593 | 0.000537 | 0.009706 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.31 | 0.030986 | 0.256392 | 0.000224 | 0.009411 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |