# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.069724s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001503 | 2.156% |
| Query Embedding | 生成查询向量 | 0.048772 | 69.950% |
| 向量召回 | 召回语义相似记忆 | 0.011419 | 16.378% |
| 结果处理 | 整理候选并转换返回结构 | 0.000013 | 0.018% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.008017 | 11.498% |
|  |  | 0.069724 | 100.000% |

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

父阶段平均耗时：**0.069724s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001503 | 2.156% |
| Query Embedding | 生成查询向量 | 0.048772 | 69.950% |
| 向量召回 | 召回语义相似记忆 | 0.011419 | 16.378% |
| 结果处理 | 整理候选并转换返回结构 | 0.000013 | 0.018% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.008017 | 11.498% |
| 合计 |  | 0.069724 | 100.000% |

**结论：Query Embedding占69.950%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.001503s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000014 | 0.962% |
| 集合检查 | 检查目标集合与检索器 | 0.001489 | 99.038% |
| 合计 |  | 0.001503 | 100.000% |

**结论：集合检查占99.038%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000013s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000005 | 36.382% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 12.621% |
| 结果处理内部 | 结果处理调度 | 0.000007 | 50.997% |
| 合计 |  | 0.000013 | 100.000% |

**结论：结果处理内部占50.996%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.421252s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.008240 | 1.956% |
| 记忆检索 | 查询相关记忆 | 0.047690 | 11.321% |
| 上下文筛选 | 选择候选记忆 | 0.000030 | 0.007% |
| 记忆读取 | 读取记忆正文 | 0.254444 | 60.403% |
| 重排 | 调整候选顺序 | 0.003489 | 0.828% |
| Prompt准备 | 构造回答输入 | 0.084020 | 19.945% |
| 回答LLM | 生成最终回答 | 0.023307 | 5.533% |
| 响应解析 | 解析回答结果 | 0.000031 | 0.007% |
| 合计 |  | 0.421252 | 100.000% |

**结论：记忆读取占60.402%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-06T19:20:30+08:00 |
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
| 操作系统 | Linux-6.6.0-x86_64-with-glibc2.38 |
| 架构 | x86_64 |
| CPU | 384 vCPU / AMD EPYC 9654 96-Core Processor |
| 内存 | 1510.92 GiB |
| Python | 3.11.6 |
| OpenViking | OpenViking v0.5.0 (official benchmark kit 48T96G, x86_64, container, out-of-the-box) |
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
| 检索耗时(s) | 0.069724 | 0.070514 | 0.075340 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_7ac55b524881421daee0aaf20f037ea9 | 39 | 0.044093 | 0.000014 | 0.002740 | 0.018294 | 0.010734 | 0.000007 | 0.000003 |
| 1 | sample_0_qa1 | tm_feb0837b95bb43aea9ba493b0579946e | 39 | 0.050416 | 0.000011 | 0.001257 | 0.025132 | 0.010715 | 0.000005 | 0.000001 |
| 2 | sample_0_qa2 | tm_7c3244a55b164730b18558e9615fe0a1 | 39 | 0.046798 | 0.000034 | 0.003366 | 0.015888 | 0.017516 | 0.000005 | 0.000002 |
| 3 | sample_0_qa3 | tm_5d4df175401646089106b0b59fc9c1eb | 39 | 0.048124 | 0.000012 | 0.001829 | 0.023291 | 0.011439 | 0.000004 | 0.000001 |
| 4 | sample_0_qa4 | tm_a68f56161fe844fcb608ea12d8ef35a0 | 39 | 0.077349 | 0.000020 | 0.002664 | 0.046811 | 0.018336 | 0.000004 | 0.000001 |
| 5 | sample_0_qa5 | tm_4e541c4660ad446a8cf8c64a2303d3a9 | 39 | 0.068485 | 0.000012 | 0.001613 | 0.049376 | 0.008475 | 0.000006 | 0.000004 |
| 6 | sample_0_qa6 | tm_791a0a6ec4554cc0bc7ba4b8e5af0afd | 39 | 0.069335 | 0.000012 | 0.000920 | 0.051482 | 0.010502 | 0.000005 | 0.000001 |
| 7 | sample_0_qa7 | tm_cbd74b98c7344396a21f7404dc1f5a8b | 39 | 0.069125 | 0.000011 | 0.000413 | 0.053951 | 0.009637 | 0.000004 | 0.000001 |
| 8 | sample_0_qa8 | tm_cf652a2b7eab4e08ab4fefc15bde2094 | 39 | 0.071730 | 0.000026 | 0.002203 | 0.046218 | 0.011908 | 0.000005 | 0.000003 |
| 9 | sample_0_qa9 | tm_647d65e816494f19abfbec6a3864b870 | 39 | 0.070926 | 0.000011 | 0.001738 | 0.048668 | 0.012885 | 0.000005 | 0.000002 |
| 10 | sample_0_qa10 | tm_6ffb48f8d2234c12a764603b6ef3ef64 | 39 | 0.071010 | 0.000010 | 0.001135 | 0.051629 | 0.011494 | 0.000004 | 0.000001 |
| 11 | sample_0_qa11 | tm_6ae41ecb6d8647039b36b6debad7bd59 | 39 | 0.070912 | 0.000011 | 0.000427 | 0.053731 | 0.010852 | 0.000005 | 0.000001 |
| 12 | sample_0_qa12 | tm_be75e06881624d74b654ead6d880e82f | 39 | 0.068485 | 0.000024 | 0.002405 | 0.047167 | 0.010362 | 0.000005 | 0.000001 |
| 13 | sample_0_qa13 | tm_98b75c210706424c8f92488a59662d00 | 39 | 0.071024 | 0.000011 | 0.001714 | 0.049277 | 0.012429 | 0.000005 | 0.000001 |
| 14 | sample_0_qa14 | tm_0babb9981af94070b3f51280176714a4 | 39 | 0.017748 | 0.000011 | 0.001063 | 0.008066 | 0.001696 | 0.000005 | 0.000001 |
| 15 | sample_0_qa15 | tm_ed232928d8c94ee783b3498a5731416c | 39 | 0.062139 | 0.000011 | 0.000474 | 0.051817 | 0.003246 | 0.000005 | 0.000003 |
| 16 | sample_0_qa16 | tm_b3de96bd133b4b7e98791ed2010f6fa7 | 39 | 0.060827 | 0.000014 | 0.000291 | 0.047914 | 0.009234 | 0.000005 | 0.000002 |
| 17 | sample_0_qa17 | tm_009b911969c74f0389e55812011f32eb | 39 | 0.075200 | 0.000022 | 0.002661 | 0.048362 | 0.015000 | 0.000004 | 0.000001 |
| 18 | sample_0_qa18 | tm_8626d09a78fd44ffb21f3a96e53f2145 | 39 | 0.071721 | 0.000011 | 0.001415 | 0.050504 | 0.010074 | 0.000005 | 0.000003 |
| 19 | sample_0_qa19 | tm_9247fcb4eb054107923271c88bb10fd2 | 39 | 0.072843 | 0.000012 | 0.000537 | 0.052939 | 0.013671 | 0.000005 | 0.000001 |
| 20 | sample_0_qa20 | tm_7a1a16abf22d40f7ba7943d2dffb5f39 | 39 | 0.061816 | 0.000015 | 0.000329 | 0.047464 | 0.009284 | 0.000005 | 0.000001 |
| 21 | sample_0_qa21 | tm_b7142f4618a342d9b12f9fd92c43f872 | 39 | 0.073646 | 0.000023 | 0.002480 | 0.046503 | 0.015943 | 0.000005 | 0.000002 |
| 22 | sample_0_qa22 | tm_abce95b74e994ebea1bfb028633fb135 | 39 | 0.068553 | 0.000011 | 0.001684 | 0.048947 | 0.009245 | 0.000006 | 0.000003 |
| 23 | sample_0_qa23 | tm_032628966b314b1786cd2fa60095cfe4 | 39 | 0.073220 | 0.000010 | 0.000894 | 0.051979 | 0.013642 | 0.000005 | 0.000001 |
| 24 | sample_0_qa24 | tm_1e4d3705476f4e3ab02412f80fd19c13 | 39 | 0.069917 | 0.000010 | 0.000431 | 0.054170 | 0.009857 | 0.000004 | 0.000001 |
| 25 | sample_0_qa25 | tm_3d349cc471fe42a6be536e85e11e653d | 39 | 0.074149 | 0.000025 | 0.002782 | 0.046607 | 0.014254 | 0.000005 | 0.000001 |
| 26 | sample_0_qa26 | tm_4ffab5dd81d94043a3d02d760878ba8b | 39 | 0.074248 | 0.000011 | 0.001717 | 0.049033 | 0.016050 | 0.000004 | 0.000001 |
| 27 | sample_0_qa27 | tm_69292d79ad5444fba052222849732736 | 39 | 0.066313 | 0.000011 | 0.001043 | 0.051538 | 0.005883 | 0.000005 | 0.000003 |
| 28 | sample_0_qa28 | tm_bf89b262f5cb4c2bb6e2d5bb94ab2ad5 | 39 | 0.069411 | 0.000011 | 0.000456 | 0.053693 | 0.009436 | 0.000005 | 0.000001 |
| 29 | sample_0_qa29 | tm_22853a6038b742e28daef3ef1a481578 | 39 | 0.071515 | 0.000025 | 0.002645 | 0.046461 | 0.010747 | 0.000006 | 0.000003 |
| 30 | sample_0_qa30 | tm_6c5af0a16fd34612acdab1b5c8772ac0 | 39 | 0.073495 | 0.000011 | 0.002192 | 0.048991 | 0.015112 | 0.000004 | 0.000001 |
| 31 | sample_0_qa31 | tm_b5832a65305243899b600fad5639d5bb | 39 | 0.070397 | 0.000010 | 0.000939 | 0.051193 | 0.011408 | 0.000004 | 0.000001 |
| 32 | sample_0_qa32 | tm_80dd27fc98b2461186c4f9e22bb1cf40 | 39 | 0.067121 | 0.000010 | 0.000459 | 0.053282 | 0.007458 | 0.000004 | 0.000001 |
| 33 | sample_0_qa33 | tm_c32deb57c453470eb261fa2ee3e51858 | 39 | 0.070168 | 0.000025 | 0.002319 | 0.046963 | 0.011472 | 0.000005 | 0.000003 |
| 34 | sample_0_qa34 | tm_1cc76c6f904d482f997fa7d61cef2882 | 39 | 0.072979 | 0.000010 | 0.001853 | 0.049547 | 0.014082 | 0.000005 | 0.000001 |
| 35 | sample_0_qa35 | tm_2940eaca7f1e417699606198b3cc77c9 | 39 | 0.073596 | 0.000011 | 0.001170 | 0.051667 | 0.013532 | 0.000005 | 0.000001 |
| 36 | sample_0_qa36 | tm_b2baefe63f634c46b014b6776da9e54b | 39 | 0.068120 | 0.000010 | 0.000442 | 0.054420 | 0.006607 | 0.000004 | 0.000001 |
| 37 | sample_0_qa37 | tm_88e6bd39f8ad482cabb4f5525366f4fd | 39 | 0.070421 | 0.000025 | 0.003299 | 0.045265 | 0.011081 | 0.000005 | 0.000003 |
| 38 | sample_0_qa38 | tm_f8c8c1fe11c7456cb9cd821fe949d714 | 39 | 0.071647 | 0.000012 | 0.001639 | 0.046109 | 0.012969 | 0.000005 | 0.000002 |
| 39 | sample_0_qa39 | tm_c4fd334bc1cd4fbe82c6bc48cd7bf4f9 | 39 | 0.072814 | 0.000010 | 0.001253 | 0.048499 | 0.013329 | 0.000005 | 0.000001 |
| 40 | sample_0_qa40 | tm_75422046cd2d43339755e74974bd81d0 | 39 | 0.069119 | 0.000010 | 0.000594 | 0.050495 | 0.009564 | 0.000004 | 0.000001 |
| 41 | sample_0_qa41 | tm_5e06b3494f274cb4b131b355023591b6 | 39 | 0.076248 | 0.000025 | 0.002846 | 0.045402 | 0.018140 | 0.000004 | 0.000001 |
| 42 | sample_0_qa42 | tm_5b7c390f465048148667b4169931f23c | 39 | 0.066587 | 0.000012 | 0.001539 | 0.046252 | 0.008473 | 0.000005 | 0.000003 |
| 43 | sample_0_qa43 | tm_65eec38162fc4593be1a1ddfaa4752ea | 39 | 0.067895 | 0.000011 | 0.000921 | 0.048758 | 0.010100 | 0.000005 | 0.000002 |
| 44 | sample_0_qa44 | tm_cb263caf8bb14631a62d2566d98e7a84 | 39 | 0.067707 | 0.000010 | 0.000493 | 0.050872 | 0.009559 | 0.000004 | 0.000001 |
| 45 | sample_0_qa45 | tm_6a84a51e72d4437481f7e69ff889aebe | 39 | 0.074933 | 0.000025 | 0.002584 | 0.046696 | 0.016254 | 0.000005 | 0.000001 |
| 46 | sample_0_qa46 | tm_5d72166b3b654e50a82a32ae6a7850b1 | 39 | 0.067844 | 0.000011 | 0.001712 | 0.049267 | 0.008337 | 0.000005 | 0.000003 |
| 47 | sample_0_qa47 | tm_30830fbfe62a4fd182900cdc5b2b3a31 | 39 | 0.073805 | 0.000011 | 0.001037 | 0.051460 | 0.014741 | 0.000005 | 0.000001 |
| 48 | sample_0_qa48 | tm_06ba554082474ca09c4576ba0bc4a748 | 39 | 0.070807 | 0.000011 | 0.000455 | 0.054456 | 0.010158 | 0.000004 | 0.000001 |
| 49 | sample_0_qa49 | tm_dc245b32015a48abbdb7692e7a7545f8 | 39 | 0.072476 | 0.000024 | 0.002516 | 0.046416 | 0.012148 | 0.000005 | 0.000003 |
| 50 | sample_0_qa50 | tm_7bb59cf00aef4faca0228e50c629e1e8 | 39 | 0.070354 | 0.000012 | 0.001690 | 0.048963 | 0.012254 | 0.000005 | 0.000001 |
| 51 | sample_0_qa51 | tm_5e430467ce58459394676e4bd89a5ec0 | 39 | 0.072165 | 0.000011 | 0.001060 | 0.051093 | 0.013536 | 0.000005 | 0.000001 |
| 52 | sample_0_qa52 | tm_8aeb435af29c446d9177ff2d4635d175 | 39 | 0.068792 | 0.000010 | 0.000468 | 0.053574 | 0.009215 | 0.000004 | 0.000001 |
| 53 | sample_0_qa53 | tm_1dab17b3d72745c1a2a64b039460ec96 | 39 | 0.069535 | 0.000024 | 0.002423 | 0.046747 | 0.011016 | 0.000005 | 0.000004 |
| 54 | sample_0_qa54 | tm_61b715c60a314f1c9abacd9527139fd0 | 39 | 0.072583 | 0.000011 | 0.001962 | 0.049288 | 0.014154 | 0.000004 | 0.000001 |
| 55 | sample_0_qa55 | tm_3d73ee5a41fc403ab640a3d5fcc844a5 | 39 | 0.069616 | 0.000012 | 0.000993 | 0.051528 | 0.010229 | 0.000005 | 0.000002 |
| 56 | sample_0_qa56 | tm_f64b09a4f30f436e9b9a8700eeafb77f | 39 | 0.070747 | 0.000010 | 0.000413 | 0.054000 | 0.010888 | 0.000004 | 0.000001 |
| 57 | sample_0_qa57 | tm_5b96075b8e9f4695a0e7c860ec122660 | 39 | 0.073069 | 0.000024 | 0.002702 | 0.046953 | 0.012690 | 0.000005 | 0.000003 |
| 58 | sample_0_qa58 | tm_bf7146ef352e4fd289df276cad1473b0 | 39 | 0.073485 | 0.000012 | 0.001606 | 0.049070 | 0.015541 | 0.000004 | 0.000001 |
| 59 | sample_0_qa59 | tm_615b7b188f6046ffb7f814d8e6a6ab1b | 39 | 0.070172 | 0.000011 | 0.000908 | 0.052417 | 0.010191 | 0.000005 | 0.000001 |
| 60 | sample_0_qa60 | tm_559bdbd33ba24791b09d9fa6beab25eb | 39 | 0.072339 | 0.000010 | 0.000424 | 0.054565 | 0.011510 | 0.000005 | 0.000001 |
| 61 | sample_0_qa61 | tm_1d1e407b702947cba077dd53d42d3091 | 39 | 0.069059 | 0.000024 | 0.003103 | 0.045388 | 0.010398 | 0.000005 | 0.000004 |
| 62 | sample_0_qa62 | tm_24141bf734754620b6087f62a62eb220 | 39 | 0.072523 | 0.000012 | 0.001611 | 0.046213 | 0.014113 | 0.000004 | 0.000001 |
| 63 | sample_0_qa63 | tm_582e20bf3cdd46b09686edaa7bcb597d | 39 | 0.072179 | 0.000017 | 0.001141 | 0.049124 | 0.012682 | 0.000004 | 0.000001 |
| 64 | sample_0_qa64 | tm_1eae4d8a9bfb4b9787dbf5a4ff1b7a33 | 39 | 0.067226 | 0.000010 | 0.000540 | 0.051435 | 0.007014 | 0.000005 | 0.000002 |
| 65 | sample_0_qa65 | tm_f589e0383b224ce1809ed7a8bcd94404 | 39 | 0.072064 | 0.000023 | 0.002666 | 0.046079 | 0.011623 | 0.000005 | 0.000003 |
| 66 | sample_0_qa66 | tm_ba1cfd1bf0fa45378494d277e99fd76c | 39 | 0.072834 | 0.000012 | 0.001636 | 0.048235 | 0.015569 | 0.000004 | 0.000001 |
| 67 | sample_0_qa67 | tm_0f5558929a994e539022ca37047cd552 | 39 | 0.067974 | 0.000011 | 0.001188 | 0.051266 | 0.009200 | 0.000004 | 0.000001 |
| 68 | sample_0_qa68 | tm_208b3e9e178347c994b92515abf76008 | 39 | 0.068285 | 0.000010 | 0.000570 | 0.053395 | 0.008900 | 0.000004 | 0.000002 |
| 69 | sample_0_qa69 | tm_2b8defe4ac204342962df5bda3cf6388 | 39 | 0.069989 | 0.000023 | 0.002511 | 0.045211 | 0.013279 | 0.000006 | 0.000003 |
| 70 | sample_0_qa70 | tm_54c9303b64b8429db559ac8150ebba58 | 39 | 0.072460 | 0.000011 | 0.001621 | 0.047093 | 0.014578 | 0.000005 | 0.000001 |
| 71 | sample_0_qa71 | tm_94a6ba5cf5fe4e9ab2f88db030d0c349 | 39 | 0.073769 | 0.000011 | 0.000993 | 0.049519 | 0.015259 | 0.000004 | 0.000002 |
| 72 | sample_0_qa72 | tm_f9f38b22ff204d2480adb39f7f200204 | 39 | 0.070740 | 0.000010 | 0.000538 | 0.052439 | 0.010690 | 0.000005 | 0.000001 |
| 73 | sample_0_qa73 | tm_2124bed4affb4a8a8a12a39585621866 | 39 | 0.074444 | 0.000024 | 0.002945 | 0.046608 | 0.014919 | 0.000005 | 0.000001 |
| 74 | sample_0_qa74 | tm_f7c082cbc2904b39b403fb2b0a9bb91c | 39 | 0.072051 | 0.000012 | 0.001627 | 0.047490 | 0.013968 | 0.000005 | 0.000002 |
| 75 | sample_0_qa75 | tm_4a338f5bd5304749ad22e78463850ce8 | 39 | 0.072012 | 0.000011 | 0.000951 | 0.049568 | 0.013362 | 0.000004 | 0.000001 |
| 76 | sample_0_qa76 | tm_00a60c50b1b34b24a4adad19a91143a7 | 39 | 0.064267 | 0.000010 | 0.000463 | 0.052442 | 0.003321 | 0.000005 | 0.000003 |
| 77 | sample_0_qa77 | tm_7f40e52d647549a8b8d9c3adbc29123b | 39 | 0.074582 | 0.000025 | 0.003109 | 0.046812 | 0.015348 | 0.000005 | 0.000001 |
| 78 | sample_0_qa78 | tm_22d63c204c4c41e7b7db7d47352b5260 | 39 | 0.073043 | 0.000011 | 0.001874 | 0.049577 | 0.014202 | 0.000005 | 0.000001 |
| 79 | sample_0_qa79 | tm_f18a93c95450402e90eb71bdea21000e | 39 | 0.073453 | 0.000011 | 0.000959 | 0.051674 | 0.014034 | 0.000005 | 0.000001 |
| 80 | sample_0_qa80 | tm_9c6b8f3609c343fa99b9d684f22a230e | 39 | 0.064694 | 0.000010 | 0.000473 | 0.054053 | 0.003842 | 0.000005 | 0.000003 |
| 81 | sample_0_qa81 | tm_9b065571614541a58fd6aa76770ba167 | 39 | 0.078622 | 0.000026 | 0.002806 | 0.049134 | 0.016322 | 0.000004 | 0.000002 |
| 82 | sample_0_qa82 | tm_cb031067393d4a17910291f53ab172ff | 39 | 0.073367 | 0.000012 | 0.001576 | 0.046946 | 0.016956 | 0.000005 | 0.000001 |
| 83 | sample_0_qa83 | tm_b202cfa57b4d461fa2100bbfefa06937 | 39 | 0.066755 | 0.000011 | 0.000887 | 0.052280 | 0.006042 | 0.000005 | 0.000003 |
| 84 | sample_0_qa84 | tm_aad439c216fb4b0383646a2f7753f958 | 39 | 0.068341 | 0.000010 | 0.000415 | 0.054405 | 0.007856 | 0.000005 | 0.000001 |
| 85 | sample_0_qa85 | tm_53f38a3c01c845a6b296b7b7c4359d08 | 39 | 0.071364 | 0.000024 | 0.002856 | 0.046229 | 0.011633 | 0.000005 | 0.000003 |
| 86 | sample_0_qa86 | tm_44821e130fde4d7599ab1af61ca9c730 | 39 | 0.070195 | 0.000011 | 0.001627 | 0.048254 | 0.012299 | 0.000005 | 0.000001 |
| 87 | sample_0_qa87 | tm_83f713685c9141b3ba6cc52e0082df8b | 39 | 0.070500 | 0.000011 | 0.000967 | 0.051152 | 0.011317 | 0.000005 | 0.000001 |
| 88 | sample_0_qa88 | tm_e3cc181dc5b84004aea586b1f4938395 | 39 | 0.070452 | 0.000010 | 0.000489 | 0.053419 | 0.010511 | 0.000004 | 0.000001 |
| 89 | sample_0_qa89 | tm_be3bb14b2b7c4e05b6c8080b78d68da6 | 39 | 0.069980 | 0.000025 | 0.002608 | 0.046756 | 0.011112 | 0.000005 | 0.000003 |
| 90 | sample_0_qa90 | tm_61d8756f0d2d464fb63b217e4541a8c0 | 39 | 0.073010 | 0.000011 | 0.001566 | 0.049014 | 0.014447 | 0.000004 | 0.000001 |
| 91 | sample_0_qa91 | tm_31400076daa04a90aa8f4c60a0183ff7 | 39 | 0.069616 | 0.000010 | 0.000929 | 0.051238 | 0.010489 | 0.000004 | 0.000002 |
| 92 | sample_0_qa92 | tm_d4b196d7632541e795246d3eb34504ec | 39 | 0.071386 | 0.000010 | 0.000459 | 0.054084 | 0.010996 | 0.000005 | 0.000001 |
| 93 | sample_0_qa93 | tm_68cec948739c4f3fae83e8b7f58589b0 | 39 | 0.072138 | 0.000025 | 0.002589 | 0.046367 | 0.011561 | 0.000005 | 0.000003 |
| 94 | sample_0_qa94 | tm_10a6ef0f64ce444aba3d64aa1a9afed6 | 39 | 0.070254 | 0.000012 | 0.001635 | 0.048906 | 0.012100 | 0.000004 | 0.000001 |
| 95 | sample_0_qa95 | tm_9e12a7f2c8984a7d8ca3ac93ecf41b8c | 39 | 0.070501 | 0.000010 | 0.001186 | 0.054304 | 0.008602 | 0.000004 | 0.000001 |
| 96 | sample_0_qa96 | tm_6dbb7cd8a6454541bf8dbe729071eda9 | 39 | 0.070329 | 0.000010 | 0.000593 | 0.051829 | 0.012568 | 0.000004 | 0.000001 |
| 97 | sample_0_qa97 | tm_ad261110b2134f83ad9bab2fe75218b7 | 39 | 0.071872 | 0.000026 | 0.002738 | 0.046771 | 0.013507 | 0.000004 | 0.000001 |
| 98 | sample_0_qa98 | tm_13a03456526c421c85f81e9439bb5bec | 39 | 0.073567 | 0.000011 | 0.001565 | 0.049382 | 0.014944 | 0.000005 | 0.000001 |
| 99 | sample_0_qa99 | tm_495a9609a30f4612bd7c1ba1bc2782f8 | 39 | 0.065875 | 0.000011 | 0.000904 | 0.051498 | 0.006317 | 0.000005 | 0.000003 |
| 100 | sample_0_qa100 | tm_a51d5993d61045aab6971eae218899be | 39 | 0.068819 | 0.000010 | 0.000426 | 0.054351 | 0.008364 | 0.000005 | 0.000001 |
| 101 | sample_0_qa101 | tm_4452829b196f4aa5bb37f43350369f06 | 39 | 0.071398 | 0.000025 | 0.002662 | 0.046465 | 0.011184 | 0.000005 | 0.000003 |
| 102 | sample_0_qa102 | tm_15920c276a214a15ac04fc70e8d67029 | 39 | 0.073914 | 0.000012 | 0.001594 | 0.049328 | 0.015260 | 0.000004 | 0.000001 |
| 103 | sample_0_qa103 | tm_215949e6766f4cd2bef49c047d317ff7 | 39 | 0.070528 | 0.000011 | 0.000927 | 0.051588 | 0.011457 | 0.000005 | 0.000001 |
| 104 | sample_0_qa104 | tm_e000a08436c84fd3baf2fc5c6bb6cdaf | 39 | 0.067526 | 0.000010 | 0.000450 | 0.053909 | 0.007538 | 0.000005 | 0.000001 |
| 105 | sample_0_qa105 | tm_ca187b1a3dd6493392a4913600e6eac3 | 39 | 0.075818 | 0.000025 | 0.002363 | 0.046688 | 0.018244 | 0.000004 | 0.000001 |
| 106 | sample_0_qa106 | tm_2f0d97a9bff1448ba46e1617083d85c9 | 39 | 0.067495 | 0.000011 | 0.001916 | 0.048945 | 0.008185 | 0.000005 | 0.000003 |
| 107 | sample_0_qa107 | tm_d2b1f4284218450f8d789b66375f3654 | 39 | 0.070898 | 0.000011 | 0.001261 | 0.051030 | 0.012061 | 0.000004 | 0.000001 |
| 108 | sample_0_qa108 | tm_540dbf021d1f45bfa129350abd448173 | 39 | 0.068023 | 0.000011 | 0.000476 | 0.053917 | 0.007535 | 0.000004 | 0.000002 |
| 109 | sample_0_qa109 | tm_3cbc6977a9bf4600bb4f90f6fffbb063 | 39 | 0.076979 | 0.000025 | 0.002931 | 0.046529 | 0.018063 | 0.000004 | 0.000001 |
| 110 | sample_0_qa110 | tm_8ec3f4d88d944c8b9bd01fb860df0640 | 39 | 0.072097 | 0.000011 | 0.001632 | 0.049076 | 0.013984 | 0.000004 | 0.000001 |
| 111 | sample_0_qa111 | tm_9a1769c67ad645d399c651f403463f88 | 39 | 0.066797 | 0.000012 | 0.000927 | 0.051192 | 0.006758 | 0.000005 | 0.000003 |
| 112 | sample_0_qa112 | tm_217fad19ada74f4c9947cd8afb2680b1 | 39 | 0.067365 | 0.000010 | 0.000445 | 0.053666 | 0.007496 | 0.000005 | 0.000001 |
| 113 | sample_0_qa113 | tm_159a22b19f1e44acb3cb15ad694e1bbb | 39 | 0.075793 | 0.000024 | 0.002709 | 0.046933 | 0.017655 | 0.000004 | 0.000001 |
| 114 | sample_0_qa114 | tm_9570ebd05bad4c80847fbf6d5290e578 | 39 | 0.072334 | 0.000012 | 0.001598 | 0.049512 | 0.013584 | 0.000004 | 0.000001 |
| 115 | sample_0_qa115 | tm_de5f9c60ed604a3388abb4f17328f3eb | 39 | 0.069081 | 0.000013 | 0.000942 | 0.051706 | 0.009767 | 0.000005 | 0.000001 |
| 116 | sample_0_qa116 | tm_6959c1d5d34640f7a80a411880538e59 | 39 | 0.064946 | 0.000012 | 0.000479 | 0.054175 | 0.003602 | 0.000006 | 0.000003 |
| 117 | sample_0_qa117 | tm_269a299ede304967ba705aa5086dee89 | 39 | 0.071184 | 0.000025 | 0.002659 | 0.046901 | 0.010883 | 0.000005 | 0.000003 |
| 118 | sample_0_qa118 | tm_63d2c5e6fd1c4dc8b4aa2b86423b4dba | 39 | 0.073326 | 0.000011 | 0.001783 | 0.049061 | 0.014720 | 0.000004 | 0.000001 |
| 119 | sample_0_qa119 | tm_e8cfe5e795424ad5a738c1b461ec951c | 39 | 0.068630 | 0.000011 | 0.001150 | 0.051704 | 0.008679 | 0.000004 | 0.000001 |
| 120 | sample_0_qa120 | tm_ef51adb1513d4f6e84d34406d4480768 | 39 | 0.068940 | 0.000010 | 0.000484 | 0.053898 | 0.008329 | 0.000004 | 0.000002 |
| 121 | sample_0_qa121 | tm_e03f5eb3273a46be926cb6567ed715d9 | 39 | 0.067474 | 0.000025 | 0.002606 | 0.045438 | 0.010519 | 0.000005 | 0.000003 |
| 122 | sample_0_qa122 | tm_e489c97c0e75487f8438a3f36706b752 | 39 | 0.073227 | 0.000012 | 0.001709 | 0.046505 | 0.015525 | 0.000005 | 0.000001 |
| 123 | sample_0_qa123 | tm_7c32e423a65e4fa9b8f8ada564f3f91f | 39 | 0.069679 | 0.000011 | 0.001023 | 0.048964 | 0.011182 | 0.000005 | 0.000001 |
| 124 | sample_0_qa124 | tm_d6155cc623e74da596f85983ea598d25 | 39 | 0.066555 | 0.000011 | 0.000543 | 0.051113 | 0.007282 | 0.000005 | 0.000001 |
| 125 | sample_0_qa125 | tm_9f3dda24a7944ad2aee161d2e6b194ca | 39 | 0.069717 | 0.000023 | 0.002668 | 0.045924 | 0.010315 | 0.000006 | 0.000003 |
| 126 | sample_0_qa126 | tm_aace5838805341f49a2d95c8c7ea5225 | 39 | 0.071176 | 0.000011 | 0.001834 | 0.046820 | 0.013598 | 0.000004 | 0.000001 |
| 127 | sample_0_qa127 | tm_16403d248fbb41f1944614222ed99776 | 39 | 0.067937 | 0.000011 | 0.001074 | 0.049756 | 0.008855 | 0.000005 | 0.000001 |
| 128 | sample_0_qa128 | tm_ec6335c408bd4d1fa532c1267e3d82b8 | 39 | 0.069506 | 0.000010 | 0.000603 | 0.051893 | 0.009978 | 0.000004 | 0.000001 |
| 129 | sample_0_qa129 | tm_d3afe50cd8244f7fa347c188a1d2e518 | 39 | 0.072088 | 0.000024 | 0.003926 | 0.046281 | 0.010564 | 0.000005 | 0.000004 |
| 130 | sample_0_qa130 | tm_5937a29b7beb4f16930fa5a770a19c8b | 39 | 0.075512 | 0.000012 | 0.001854 | 0.048436 | 0.015804 | 0.000005 | 0.000001 |
| 131 | sample_0_qa131 | tm_5e38889e4f174bdb8d706ff93099e51b | 39 | 0.069051 | 0.000011 | 0.001194 | 0.051493 | 0.007780 | 0.000005 | 0.000001 |
| 132 | sample_0_qa132 | tm_c787ecc7cca14e7ea9a10fbb0d6e4297 | 39 | 0.070716 | 0.000010 | 0.000720 | 0.053628 | 0.008949 | 0.000005 | 0.000001 |
| 133 | sample_0_qa133 | tm_50374b69cdc44b97a160a43d76b6c45f | 39 | 0.078275 | 0.000025 | 0.002454 | 0.047011 | 0.018519 | 0.000004 | 0.000001 |
| 134 | sample_0_qa134 | tm_b71f4e4b10174b7c8f7da353cf1e1937 | 39 | 0.071146 | 0.000010 | 0.001987 | 0.049118 | 0.009696 | 0.000005 | 0.000003 |
| 135 | sample_0_qa135 | tm_910f539f24e34012aefe4e08a5d4a5dc | 39 | 0.069260 | 0.000012 | 0.000907 | 0.051792 | 0.010141 | 0.000005 | 0.000001 |
| 136 | sample_0_qa136 | tm_95fdbbac97fa4e18bd5d24abb4f660d8 | 39 | 0.069689 | 0.000010 | 0.000433 | 0.053989 | 0.009892 | 0.000005 | 0.000001 |
| 137 | sample_0_qa137 | tm_88e6c600b6eb4198b74590555e1887a9 | 39 | 0.074275 | 0.000026 | 0.002704 | 0.046021 | 0.016859 | 0.000004 | 0.000001 |
| 138 | sample_0_qa138 | tm_4308152e975e47a0b0e8628d5f610dd2 | 39 | 0.074740 | 0.000011 | 0.001930 | 0.048293 | 0.016417 | 0.000005 | 0.000001 |
| 139 | sample_0_qa139 | tm_b2e2e940ff814263a0b47c21788e91fb | 39 | 0.068834 | 0.000010 | 0.001488 | 0.051200 | 0.007354 | 0.000005 | 0.000003 |
| 140 | sample_0_qa140 | tm_f775dca0741040edbb563c4fc80ee06b | 39 | 0.072956 | 0.000011 | 0.000891 | 0.052653 | 0.012905 | 0.000005 | 0.000001 |
| 141 | sample_0_qa141 | tm_0b86668a329b4bb2b40ca6ff31a09b21 | 39 | 0.071166 | 0.000024 | 0.002616 | 0.046587 | 0.011358 | 0.000005 | 0.000003 |
| 142 | sample_0_qa142 | tm_f790196b4f484008bc526d17bea4e8c9 | 39 | 0.074505 | 0.000011 | 0.001664 | 0.049060 | 0.015331 | 0.000004 | 0.000001 |
| 143 | sample_0_qa143 | tm_ec0d039c510344c988a4f03843fc2010 | 39 | 0.069414 | 0.000010 | 0.001063 | 0.052028 | 0.009050 | 0.000004 | 0.000001 |
| 144 | sample_0_qa144 | tm_cdcd559bece341f0aa80cb7f9872d7ab | 39 | 0.069489 | 0.000011 | 0.000485 | 0.054179 | 0.008708 | 0.000004 | 0.000001 |
| 145 | sample_0_qa145 | tm_e8ac06b7011d4e9589b457e0b3a15377 | 39 | 0.069576 | 0.000024 | 0.002485 | 0.046915 | 0.010534 | 0.000005 | 0.000003 |
| 146 | sample_0_qa146 | tm_94897dde5d8b48de8b9c4cee74d0b9e2 | 39 | 0.070571 | 0.000011 | 0.001696 | 0.049469 | 0.011687 | 0.000005 | 0.000001 |
| 147 | sample_0_qa147 | tm_1f8afa53fb7749f19e53e4635d048234 | 39 | 0.072004 | 0.000011 | 0.001027 | 0.051681 | 0.012566 | 0.000004 | 0.000001 |
| 148 | sample_0_qa148 | tm_7c202461d77643fdb9609722a210b325 | 39 | 0.068885 | 0.000011 | 0.000460 | 0.054121 | 0.008495 | 0.000004 | 0.000001 |
| 149 | sample_0_qa149 | tm_e2b0761268ef4ae7b5faab4544885730 | 39 | 0.067493 | 0.000025 | 0.001796 | 0.046241 | 0.008421 | 0.000005 | 0.000003 |
| 150 | sample_0_qa150 | tm_7d75df2177384b6e8b9722fbd96b5bd2 | 39 | 0.068135 | 0.000012 | 0.000999 | 0.048600 | 0.010865 | 0.000004 | 0.000001 |
| 151 | sample_0_qa151 | tm_011080bdbad1477290f7d8e34f6cb27c | 39 | 0.065217 | 0.000012 | 0.000473 | 0.050803 | 0.007066 | 0.000004 | 0.000001 |

问答端到端平均耗时：0.421316s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.81 | 0.019325 | 0.792049 | 1.591176 | 0.303307 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.81 | 0.020977 | 0.799985 | 1.591827 | 0.303437 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.81 | 0.070509 | 0.751646 | 1.592590 | 0.301916 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.81 | 0.038700 | 0.753292 | 1.591523 | 0.303042 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.81 | 0.029866 | 0.753210 | 1.592908 | 0.302002 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.81 | 0.081481 | 0.749901 | 1.593102 | 0.302419 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.81 | 0.065903 | 0.745684 | 1.592160 | 0.301944 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.81 | 0.029628 | 0.753604 | 1.590738 | 0.304519 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.012970 | 0.231562 | 0.000191 | 0.008227 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.025756 | 0.220409 | 0.000163 | 0.007226 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.36 | 0.097752 | 0.223456 | 0.000164 | 0.009671 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.34 | 0.080497 | 0.219429 | 0.000197 | 0.009147 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.31 | 0.047628 | 0.225482 | 0.000153 | 0.008077 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.29 | 0.047568 | 0.201405 | 0.000140 | 0.007422 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.33 | 0.075288 | 0.221777 | 0.000156 | 0.006484 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.3 | 0.052007 | 0.209051 | 0.000150 | 0.007800 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.026806 | 0.225566 | 0.000488 | 0.006948 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.056924 | 0.221653 | 0.000447 | 0.007713 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.25 | 0.018501 | 0.209050 | 0.000536 | 0.009076 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.28 | 0.061675 | 0.208488 | 0.000182 | 0.006840 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.023959 | 0.230934 | 0.000219 | 0.007565 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.063211 | 0.233445 | 0.000187 | 0.008464 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.3 | 0.066992 | 0.220323 | 0.000197 | 0.006344 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.31 | 0.069974 | 0.225743 | 0.000474 | 0.011481 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.27 | 0.030426 | 0.225240 | 0.000201 | 0.007518 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.081579 | 0.218104 | 0.000205 | 0.006776 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.26 | 0.029828 | 0.212385 | 0.000215 | 0.009445 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.33 | 0.076075 | 0.234259 | 0.000517 | 0.011050 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.074268 | 0.229682 | 0.000190 | 0.007463 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.067453 | 0.220851 | 0.000174 | 0.007242 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.3 | 0.065784 | 0.215802 | 0.000182 | 0.008366 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.023739 | 0.220408 | 0.000456 | 0.007269 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.28 | 0.029262 | 0.243507 | 0.000203 | 0.006951 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.061941 | 0.241602 | 0.000198 | 0.007232 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.26 | 0.024016 | 0.221767 | 0.000206 | 0.006989 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.020417 | 0.226767 | 0.000205 | 0.008162 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.073700 | 0.213311 | 0.000177 | 0.007205 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.27 | 0.017073 | 0.236959 | 0.000187 | 0.007012 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.3 | 0.070329 | 0.214369 | 0.000481 | 0.007197 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.27 | 0.032302 | 0.218098 | 0.000199 | 0.009903 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.28 | 0.029775 | 0.239288 | 0.000172 | 0.006524 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.068383 | 0.238958 | 0.000507 | 0.007254 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.33 | 0.061062 | 0.251225 | 0.000176 | 0.008539 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.3 | 0.029439 | 0.259706 | 0.000510 | 0.009850 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.32 | 0.070930 | 0.234314 | 0.000194 | 0.008250 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.023130 | 0.221188 | 0.000200 | 0.009611 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.31 | 0.060509 | 0.235036 | 0.000166 | 0.007149 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.28 | 0.029724 | 0.234798 | 0.000208 | 0.007959 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.28 | 0.033968 | 0.235536 | 0.000209 | 0.006966 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.28 | 0.032144 | 0.233844 | 0.000202 | 0.008264 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.26 | 0.019977 | 0.229872 | 0.000224 | 0.007915 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.33 | 0.069611 | 0.241780 | 0.000211 | 0.008281 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.29 | 0.028999 | 0.242814 | 0.000206 | 0.007781 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.058030 | 0.237462 | 0.000190 | 0.006909 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.029452 | 0.222087 | 0.000334 | 0.008381 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.31 | 0.066128 | 0.231817 | 0.000205 | 0.006613 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.28 | 0.030938 | 0.236123 | 0.000213 | 0.009723 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.020229 | 0.236044 | 0.000206 | 0.007999 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.022023 | 0.243052 | 0.000221 | 0.007527 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.31 | 0.064855 | 0.228442 | 0.000199 | 0.009029 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.26 | 0.020845 | 0.222897 | 0.000242 | 0.006840 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.31 | 0.067778 | 0.228488 | 0.000187 | 0.009460 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.073793 | 0.224610 | 0.000183 | 0.010190 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.022418 | 0.231226 | 0.000213 | 0.007264 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.26 | 0.029611 | 0.216528 | 0.000780 | 0.006564 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.29 | 0.066352 | 0.211566 | 0.000209 | 0.006646 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.3 | 0.066804 | 0.224966 | 0.000213 | 0.007073 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.018066 | 0.237458 | 0.000502 | 0.006780 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.32 | 0.067689 | 0.238295 | 0.000198 | 0.010695 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.25 | 0.012952 | 0.221103 | 0.000206 | 0.009414 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.31 | 0.061269 | 0.230255 | 0.000163 | 0.007952 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.32 | 0.070727 | 0.234383 | 0.000528 | 0.007251 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.32 | 0.074360 | 0.230134 | 0.000203 | 0.007054 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.022127 | 0.221634 | 0.000174 | 0.006717 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.025050 | 0.245228 | 0.000204 | 0.007152 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.3 | 0.073927 | 0.216832 | 0.000171 | 0.006193 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.020457 | 0.247184 | 0.000184 | 0.006953 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.31 | 0.068881 | 0.230446 | 0.000157 | 0.007056 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.27 | 0.025247 | 0.231692 | 0.000194 | 0.006791 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.068753 | 0.239160 | 0.000203 | 0.007807 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.018226 | 0.244082 | 0.000189 | 0.006235 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.31 | 0.069215 | 0.225306 | 0.000188 | 0.006462 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.27 | 0.026487 | 0.234811 | 0.000201 | 0.006674 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.3 | 0.059436 | 0.228633 | 0.000197 | 0.006592 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.28 | 0.028980 | 0.240887 | 0.000205 | 0.009552 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.29 | 0.058168 | 0.224958 | 0.000203 | 0.007336 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.29 | 0.022635 | 0.252573 | 0.000164 | 0.008523 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.29 | 0.057876 | 0.216907 | 0.000178 | 0.012337 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.26 | 0.026176 | 0.224518 | 0.000208 | 0.006847 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.33 | 0.060846 | 0.254524 | 0.000187 | 0.006865 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.28 | 0.023818 | 0.246246 | 0.000209 | 0.006808 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.27 | 0.019388 | 0.238684 | 0.000179 | 0.007060 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.32 | 0.075400 | 0.230518 | 0.000187 | 0.008811 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.32 | 0.080291 | 0.224788 | 0.000180 | 0.006787 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.27 | 0.035740 | 0.227385 | 0.000202 | 0.006646 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.3 | 0.069335 | 0.215529 | 0.000216 | 0.007008 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.25 | 0.024832 | 0.213825 | 0.000219 | 0.007011 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.27 | 0.020898 | 0.239044 | 0.000199 | 0.006894 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.3 | 0.062960 | 0.224809 | 0.000201 | 0.006662 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.32 | 0.078483 | 0.232685 | 0.000177 | 0.006552 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.26 | 0.023703 | 0.222631 | 0.000209 | 0.008054 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.32 | 0.069277 | 0.236076 | 0.000151 | 0.007647 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.28 | 0.016985 | 0.247837 | 0.000241 | 0.007497 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.29 | 0.066021 | 0.213175 | 0.000205 | 0.009796 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.28 | 0.028033 | 0.243717 | 0.000208 | 0.008483 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.28 | 0.028648 | 0.234682 | 0.000204 | 0.006549 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.27 | 0.021661 | 0.235386 | 0.000207 | 0.007333 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.26 | 0.019664 | 0.225058 | 0.000227 | 0.008054 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.31 | 0.062924 | 0.231494 | 0.000174 | 0.007616 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.29 | 0.055585 | 0.223863 | 0.000207 | 0.007871 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.26 | 0.027302 | 0.215040 | 0.000205 | 0.007535 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.3 | 0.059666 | 0.224440 | 0.000186 | 0.007758 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.3 | 0.061613 | 0.221829 | 0.000206 | 0.007392 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.32 | 0.076232 | 0.226615 | 0.000196 | 0.007144 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.27 | 0.036533 | 0.225419 | 0.000221 | 0.006562 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.3 | 0.060150 | 0.230435 | 0.000214 | 0.009572 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.31 | 0.072683 | 0.227738 | 0.000177 | 0.007346 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.27 | 0.022538 | 0.237830 | 0.000523 | 0.006789 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.29 | 0.067709 | 0.214988 | 0.000202 | 0.007130 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.25 | 0.018080 | 0.217537 | 0.000532 | 0.008233 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.3 | 0.071644 | 0.221285 | 0.000227 | 0.006451 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.3 | 0.059403 | 0.231990 | 0.000210 | 0.006718 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.26 | 0.028239 | 0.210328 | 0.000213 | 0.008939 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.25 | 0.020472 | 0.218331 | 0.000215 | 0.007153 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.3 | 0.059457 | 0.233030 | 0.000538 | 0.007480 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.26 | 0.026713 | 0.221673 | 0.000212 | 0.006614 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.32 | 0.070527 | 0.235121 | 0.000723 | 0.008133 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.33 | 0.074780 | 0.244945 | 0.000240 | 0.007755 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.32 | 0.073716 | 0.231897 | 0.000214 | 0.006430 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.27 | 0.021283 | 0.234938 | 0.000509 | 0.006857 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.32 | 0.068324 | 0.239687 | 0.000189 | 0.005981 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.25 | 0.021009 | 0.213224 | 0.000288 | 0.007372 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.25 | 0.023005 | 0.218805 | 0.000218 | 0.007084 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.29 | 0.070521 | 0.206744 | 0.000185 | 0.007224 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.29 | 0.068034 | 0.210628 | 0.000283 | 0.008979 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.23 | 0.017634 | 0.200872 | 0.000175 | 0.010562 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.31 | 0.068104 | 0.230448 | 0.000519 | 0.007240 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.33 | 0.071951 | 0.245972 | 0.000188 | 0.006812 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.3 | 0.072947 | 0.216998 | 0.000212 | 0.006876 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.31 | 0.066230 | 0.232417 | 0.000186 | 0.007057 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.31 | 0.064701 | 0.232984 | 0.000204 | 0.007207 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.28 | 0.033201 | 0.231571 | 0.000184 | 0.006376 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.28 | 0.059867 | 0.208393 | 0.000180 | 0.006308 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.32 | 0.078838 | 0.223052 | 0.000276 | 0.008939 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.31 | 0.071473 | 0.228924 | 0.000212 | 0.007524 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.27 | 0.023548 | 0.222499 | 0.000225 | 0.013717 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.31 | 0.070223 | 0.225337 | 0.000221 | 0.007415 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.26 | 0.024196 | 0.216839 | 0.000288 | 0.010003 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.26 | 0.056213 | 0.188842 | 0.000209 | 0.010965 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.24 | 0.029961 | 0.195763 | 0.000266 | 0.009798 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.23 | 0.069131 | 0.149701 | 0.000203 | 0.007490 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.16 | 0.030874 | 0.118052 | 0.000274 | 0.007996 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |