# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.060364s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000836 | 1.385% |
| Query Embedding | 生成查询向量 | 0.048804 | 80.850% |
| 向量召回 | 召回语义相似记忆 | 0.005160 | 8.548% |
| 结果处理 | 整理候选并转换返回结构 | 0.000015 | 0.025% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005549 | 9.192% |
|  |  | 0.060364 | 100.000% |

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

父阶段平均耗时：**0.060364s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000836 | 1.385% |
| Query Embedding | 生成查询向量 | 0.048804 | 80.850% |
| 向量召回 | 召回语义相似记忆 | 0.005160 | 8.548% |
| 结果处理 | 整理候选并转换返回结构 | 0.000015 | 0.025% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005549 | 9.192% |
| 合计 |  | 0.060364 | 100.000% |

**结论：Query Embedding占80.849%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.000836s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000015 | 1.824% |
| 集合检查 | 检查目标集合与检索器 | 0.000821 | 98.176% |
| 合计 |  | 0.000836 | 100.000% |

**结论：集合检查占98.176%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000015s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000006 | 41.920% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 11.990% |
| 结果处理内部 | 结果处理调度 | 0.000007 | 46.090% |
| 合计 |  | 0.000015 | 100.000% |

**结论：结果处理内部占46.090%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.408185s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.009322 | 2.284% |
| 记忆检索 | 查询相关记忆 | 0.049713 | 12.179% |
| 上下文筛选 | 选择候选记忆 | 0.000033 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.241047 | 59.054% |
| 重排 | 调整候选顺序 | 0.002037 | 0.499% |
| Prompt准备 | 构造回答输入 | 0.082645 | 20.247% |
| 回答LLM | 生成最终回答 | 0.023358 | 5.722% |
| 响应解析 | 解析回答结果 | 0.000028 | 0.007% |
| 合计 |  | 0.408185 | 100.000% |

**结论：记忆读取占59.054%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-10T23:03:25+08:00 |
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
| 检索耗时(s) | 0.060364 | 0.058984 | 0.073165 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_014fbcfc16fd4055a179e519b13d42bc | 39 | 0.046278 | 0.000016 | 0.001924 | 0.016768 | 0.016570 | 0.000006 | 0.000001 |
| 1 | sample_0_qa1 | tm_9bf98dde67064ac6a4d1ffc6681705cc | 39 | 0.039285 | 0.000022 | 0.002621 | 0.013941 | 0.012263 | 0.000008 | 0.000003 |
| 2 | sample_0_qa2 | tm_37b1f7f2a78345918c3adfa7dc5ce2d4 | 39 | 0.043925 | 0.000013 | 0.000565 | 0.023798 | 0.007825 | 0.000005 | 0.000002 |
| 3 | sample_0_qa3 | tm_a79b3e17dbfd42e490bc57f1f25ae149 | 39 | 0.042040 | 0.000013 | 0.001102 | 0.019808 | 0.010111 | 0.000006 | 0.000002 |
| 4 | sample_0_qa4 | tm_8522129df9e640cd92ab72f669f0ba99 | 39 | 0.076354 | 0.000019 | 0.003009 | 0.051060 | 0.012784 | 0.000006 | 0.000001 |
| 5 | sample_0_qa5 | tm_07e88fff6515427db4055c7f588d2973 | 39 | 0.074503 | 0.000014 | 0.001876 | 0.047183 | 0.016477 | 0.000005 | 0.000002 |
| 6 | sample_0_qa6 | tm_e93a1995102342509a68ec7d72f4e643 | 39 | 0.069887 | 0.000013 | 0.001141 | 0.051945 | 0.008558 | 0.000006 | 0.000001 |
| 7 | sample_0_qa7 | tm_42ef7ddf7fd34d47a69579fb1953087d | 39 | 0.065195 | 0.000012 | 0.000487 | 0.054144 | 0.002897 | 0.000007 | 0.000002 |
| 8 | sample_0_qa8 | tm_a55c630c2ca84f5ca61d37b767ebc587 | 39 | 0.072271 | 0.000018 | 0.003289 | 0.048911 | 0.009954 | 0.000007 | 0.000002 |
| 9 | sample_0_qa9 | tm_fd7aca584d1847f9adc1e5afbbd08d69 | 39 | 0.071605 | 0.000014 | 0.001909 | 0.051167 | 0.011008 | 0.000006 | 0.000002 |
| 10 | sample_0_qa10 | tm_d762ce07196d4f01bb7e8e8d9f83780d | 39 | 0.073119 | 0.000013 | 0.001391 | 0.053953 | 0.011324 | 0.000006 | 0.000002 |
| 11 | sample_0_qa11 | tm_8a8b98e74f34439b929021ce3fc77ce6 | 39 | 0.070076 | 0.000013 | 0.000601 | 0.056129 | 0.007616 | 0.000005 | 0.000001 |
| 12 | sample_0_qa12 | tm_928a2221f2a748908051bb7f1540355e | 39 | 0.074729 | 0.000018 | 0.002499 | 0.053937 | 0.009298 | 0.000006 | 0.000002 |
| 13 | sample_0_qa13 | tm_f3bcf31ec03040fe8a1b5f6219936993 | 39 | 0.073937 | 0.000013 | 0.001983 | 0.051708 | 0.013061 | 0.000005 | 0.000002 |
| 14 | sample_0_qa14 | tm_8756e2fa27734224b2ea21c7a514c8c5 | 39 | 0.068027 | 0.000013 | 0.001216 | 0.049469 | 0.010350 | 0.000007 | 0.000002 |
| 15 | sample_0_qa15 | tm_5a3fe339cee342b493a2eb38806aba2a | 39 | 0.072412 | 0.000013 | 0.000432 | 0.056623 | 0.009590 | 0.000006 | 0.000002 |
| 16 | sample_0_qa16 | tm_e01d94390fec48108369eb68becb792d | 39 | 0.058148 | 0.000017 | 0.002995 | 0.044973 | 0.001104 | 0.000007 | 0.000002 |
| 17 | sample_0_qa17 | tm_67ac7debbec34a7281a4f137661d020a | 39 | 0.069986 | 0.000014 | 0.001788 | 0.048857 | 0.010247 | 0.000006 | 0.000002 |
| 18 | sample_0_qa18 | tm_056d00f062eb49d384e6882c67b8f1f5 | 39 | 0.070739 | 0.000013 | 0.001017 | 0.051006 | 0.010764 | 0.000005 | 0.000001 |
| 19 | sample_0_qa19 | tm_2a6a5d2478284536b86675f6195d4394 | 39 | 0.070703 | 0.000012 | 0.000528 | 0.053976 | 0.009322 | 0.000005 | 0.000001 |
| 20 | sample_0_qa20 | tm_a44f7111c1364650b5fb5d9f23d42833 | 39 | 0.063988 | 0.000017 | 0.000638 | 0.051515 | 0.001069 | 0.000007 | 0.000002 |
| 21 | sample_0_qa21 | tm_ee71e1304d7942b5ab96f1dc01b2c079 | 39 | 0.065279 | 0.000015 | 0.001817 | 0.047339 | 0.008829 | 0.000007 | 0.000002 |
| 22 | sample_0_qa22 | tm_6e7109712c3a4df5a212105fe5c34a0d | 39 | 0.067480 | 0.000013 | 0.001304 | 0.053550 | 0.007481 | 0.000006 | 0.000001 |
| 23 | sample_0_qa23 | tm_52998f804ff4450dae3637e6c7b27123 | 39 | 0.064495 | 0.000013 | 0.000368 | 0.051333 | 0.008003 | 0.000006 | 0.000001 |
| 24 | sample_0_qa24 | tm_1ab27c3b5b3f4cdea40c9fd8a2dc389e | 39 | 0.059949 | 0.000018 | 0.000230 | 0.054293 | 0.001111 | 0.000007 | 0.000003 |
| 25 | sample_0_qa25 | tm_c295b343bdd1401e966b7fb2dbdc0395 | 39 | 0.055578 | 0.000017 | 0.002203 | 0.044811 | 0.001188 | 0.000007 | 0.000002 |
| 26 | sample_0_qa26 | tm_a34925c36f18476ebfab9706d5b754f6 | 39 | 0.065763 | 0.000013 | 0.001187 | 0.052329 | 0.005073 | 0.000006 | 0.000002 |
| 27 | sample_0_qa27 | tm_ec45d94b008747288c5051275dddca17 | 39 | 0.065883 | 0.000012 | 0.000683 | 0.054546 | 0.004992 | 0.000006 | 0.000002 |
| 28 | sample_0_qa28 | tm_48c84f35fade479bb033f2b13015610f | 39 | 0.051687 | 0.000018 | 0.000270 | 0.046126 | 0.001248 | 0.000007 | 0.000002 |
| 29 | sample_0_qa29 | tm_c3adf4e450ce4d68ab910c0d58643d45 | 39 | 0.057294 | 0.000018 | 0.000241 | 0.050883 | 0.001182 | 0.000008 | 0.000007 |
| 30 | sample_0_qa30 | tm_4eca0622840c4eca82f180a78ec75684 | 39 | 0.058167 | 0.000017 | 0.000986 | 0.050037 | 0.002339 | 0.000006 | 0.000002 |
| 31 | sample_0_qa31 | tm_966574c6354a481c8c5077c232bf91ba | 39 | 0.058019 | 0.000013 | 0.000266 | 0.047800 | 0.006207 | 0.000005 | 0.000002 |
| 32 | sample_0_qa32 | tm_2d91f5811ddf458d863f69afd2bb57d3 | 39 | 0.051427 | 0.000017 | 0.000218 | 0.046563 | 0.001088 | 0.000007 | 0.000002 |
| 33 | sample_0_qa33 | tm_18c2422db2a14e189d6ed01988976e4c | 39 | 0.058534 | 0.000031 | 0.000308 | 0.053289 | 0.001109 | 0.000007 | 0.000002 |
| 34 | sample_0_qa34 | tm_e512004d12ee49f5a542c208a329293a | 39 | 0.057324 | 0.000016 | 0.001151 | 0.046346 | 0.004952 | 0.000006 | 0.000002 |
| 35 | sample_0_qa35 | tm_100f348446c046588fe1ee3fa04030cb | 39 | 0.057826 | 0.000013 | 0.000384 | 0.047424 | 0.004207 | 0.000006 | 0.000002 |
| 36 | sample_0_qa36 | tm_21a9a4c379a348e186231b2fd991bc28 | 39 | 0.055862 | 0.000021 | 0.000293 | 0.050630 | 0.001064 | 0.000007 | 0.000002 |
| 37 | sample_0_qa37 | tm_2f273c7e4bf748148064057884b4d30d | 39 | 0.059914 | 0.000016 | 0.000143 | 0.055030 | 0.001126 | 0.000007 | 0.000002 |
| 38 | sample_0_qa38 | tm_766daabe5c3148fc9293d7d38735cbb1 | 39 | 0.059890 | 0.000018 | 0.000995 | 0.050678 | 0.003162 | 0.000006 | 0.000002 |
| 39 | sample_0_qa39 | tm_667f3545259a425c96ac90f2725835ea | 39 | 0.059515 | 0.000013 | 0.000269 | 0.048413 | 0.007132 | 0.000006 | 0.000002 |
| 40 | sample_0_qa40 | tm_5702bb73c5a64428bdf82f3698f23244 | 39 | 0.054543 | 0.000015 | 0.000216 | 0.048135 | 0.002503 | 0.000006 | 0.000002 |
| 41 | sample_0_qa41 | tm_299b72dcb4ad42a8a1f401e48be849bf | 39 | 0.059737 | 0.000016 | 0.000263 | 0.054680 | 0.001110 | 0.000007 | 0.000002 |
| 42 | sample_0_qa42 | tm_3d8a85cdb6ef4212b8ca84e543717d8a | 39 | 0.073221 | 0.000018 | 0.000937 | 0.055591 | 0.011607 | 0.000006 | 0.000002 |
| 43 | sample_0_qa43 | tm_4dd04c510cc640068f4c9687b79725b2 | 39 | 0.068397 | 0.000012 | 0.000268 | 0.057758 | 0.005349 | 0.000007 | 0.000002 |
| 44 | sample_0_qa44 | tm_7c998f3edb58460494c17c7983b254da | 39 | 0.057769 | 0.000017 | 0.000298 | 0.049075 | 0.004998 | 0.000005 | 0.000001 |
| 45 | sample_0_qa45 | tm_ca08cb4dd6784b929038604e8406b487 | 39 | 0.051799 | 0.000017 | 0.000256 | 0.046664 | 0.001109 | 0.000007 | 0.000002 |
| 46 | sample_0_qa46 | tm_59602cfe1c74499c9b8a97ee354b767b | 39 | 0.063116 | 0.000016 | 0.002104 | 0.049373 | 0.004936 | 0.000006 | 0.000002 |
| 47 | sample_0_qa47 | tm_09721d80f96e4e909845f8409d0fd251 | 39 | 0.063843 | 0.000013 | 0.001387 | 0.046905 | 0.009818 | 0.000006 | 0.000001 |
| 48 | sample_0_qa48 | tm_c10268ec80de4f59aead8e4a4e93fcc2 | 39 | 0.063636 | 0.000014 | 0.000514 | 0.051296 | 0.006758 | 0.000005 | 0.000001 |
| 49 | sample_0_qa49 | tm_44972f2c97534156b2e97ee8e56c61c6 | 39 | 0.051923 | 0.000016 | 0.000278 | 0.046469 | 0.001501 | 0.000007 | 0.000002 |
| 50 | sample_0_qa50 | tm_921fb5e3644748ea94adfbb885dd65fd | 39 | 0.064331 | 0.000016 | 0.001771 | 0.047725 | 0.007624 | 0.000006 | 0.000002 |
| 51 | sample_0_qa51 | tm_0693beb3b4134a58a11ac53e478d7e2f | 39 | 0.069032 | 0.000013 | 0.001265 | 0.048386 | 0.012769 | 0.000006 | 0.000001 |
| 52 | sample_0_qa52 | tm_d01358b3ad4d49d083a9a9bea97609a6 | 39 | 0.065547 | 0.000012 | 0.000366 | 0.050901 | 0.008088 | 0.000006 | 0.000001 |
| 53 | sample_0_qa53 | tm_19b907e825524fa1ac08375c6ec2375c | 39 | 0.063718 | 0.000018 | 0.000297 | 0.047415 | 0.012390 | 0.000006 | 0.000002 |
| 54 | sample_0_qa54 | tm_d980a8d713bc48119c23fae3f709c71b | 39 | 0.069857 | 0.000015 | 0.002286 | 0.049799 | 0.007694 | 0.000007 | 0.000002 |
| 55 | sample_0_qa55 | tm_9a68ee3a1fe0462996959371ffe063e4 | 39 | 0.069147 | 0.000013 | 0.001258 | 0.046204 | 0.014459 | 0.000005 | 0.000001 |
| 56 | sample_0_qa56 | tm_7b7ebe9afc9f4c53ab537f0cd25a4842 | 39 | 0.065755 | 0.000013 | 0.000474 | 0.050766 | 0.008183 | 0.000005 | 0.000001 |
| 57 | sample_0_qa57 | tm_e7b55544da9c4b37a20ec8e691ee60f1 | 39 | 0.058402 | 0.000014 | 0.000401 | 0.046743 | 0.007961 | 0.000005 | 0.000002 |
| 58 | sample_0_qa58 | tm_13663f64e12a4a31aa33f3e7b436e244 | 39 | 0.058988 | 0.000015 | 0.002752 | 0.046136 | 0.001263 | 0.000006 | 0.000002 |
| 59 | sample_0_qa59 | tm_83d9ca158584446291048d7d62ca6614 | 39 | 0.073789 | 0.000013 | 0.001834 | 0.053729 | 0.011296 | 0.000006 | 0.000001 |
| 60 | sample_0_qa60 | tm_5afd961c4351434095b7b36e493b1311 | 39 | 0.068967 | 0.000013 | 0.001167 | 0.051527 | 0.009634 | 0.000006 | 0.000002 |
| 61 | sample_0_qa61 | tm_e27c32ec4e854a04bfb98b2be87e259f | 39 | 0.069100 | 0.000012 | 0.000551 | 0.055862 | 0.007419 | 0.000005 | 0.000002 |
| 62 | sample_0_qa62 | tm_0b82477680ed4ff48d859d15fc5f727a | 39 | 0.059852 | 0.000015 | 0.000274 | 0.047878 | 0.001166 | 0.000007 | 0.000002 |
| 63 | sample_0_qa63 | tm_ea0d4f18bc294338a309cc7fefed29bf | 39 | 0.063221 | 0.000015 | 0.001993 | 0.047855 | 0.006659 | 0.000006 | 0.000002 |
| 64 | sample_0_qa64 | tm_590d5a649f58495290e4e35041057d38 | 39 | 0.066012 | 0.000013 | 0.001198 | 0.050008 | 0.009373 | 0.000006 | 0.000001 |
| 65 | sample_0_qa65 | tm_edfa965af3ef41189d4072cd33e7d534 | 39 | 0.062272 | 0.000013 | 0.000394 | 0.052537 | 0.004601 | 0.000006 | 0.000001 |
| 66 | sample_0_qa66 | tm_f99b5a03d8ff494e8b4091f0c217d63e | 39 | 0.051688 | 0.000017 | 0.000256 | 0.046810 | 0.001056 | 0.000007 | 0.000002 |
| 67 | sample_0_qa67 | tm_7084d1c081a6461d9ab76a26d9a9622c | 39 | 0.067062 | 0.000014 | 0.002118 | 0.047613 | 0.009969 | 0.000006 | 0.000002 |
| 68 | sample_0_qa68 | tm_4e24640b3dc646c38af6eaf7da5c29d3 | 39 | 0.066094 | 0.000013 | 0.001331 | 0.048263 | 0.009376 | 0.000006 | 0.000001 |
| 69 | sample_0_qa69 | tm_f6edf050f464446cb45b3a3aa38f4313 | 39 | 0.060557 | 0.000013 | 0.000385 | 0.050575 | 0.002627 | 0.000006 | 0.000002 |
| 70 | sample_0_qa70 | tm_be4ca1ef73004b70bb23541c8365bb01 | 39 | 0.056330 | 0.000018 | 0.000239 | 0.050823 | 0.001472 | 0.000007 | 0.000002 |
| 71 | sample_0_qa71 | tm_1a9f77e8bfeb4f91aacf025e61fa5bd2 | 39 | 0.069163 | 0.000016 | 0.001774 | 0.053761 | 0.007079 | 0.000006 | 0.000001 |
| 72 | sample_0_qa72 | tm_5aaaa460a2f14b47939944dd613bc10c | 39 | 0.068698 | 0.000012 | 0.001269 | 0.051554 | 0.010894 | 0.000005 | 0.000001 |
| 73 | sample_0_qa73 | tm_47e582caf8ae497cb4f411c80696d47d | 39 | 0.063934 | 0.000012 | 0.000564 | 0.055506 | 0.002084 | 0.000007 | 0.000002 |
| 74 | sample_0_qa74 | tm_f90e820990434900bae3c2e343305c6b | 39 | 0.057951 | 0.000016 | 0.000259 | 0.047346 | 0.006873 | 0.000006 | 0.000002 |
| 75 | sample_0_qa75 | tm_e735fe2571b64353b918749b45bb5c72 | 39 | 0.078810 | 0.000016 | 0.004397 | 0.056805 | 0.010898 | 0.000005 | 0.000001 |
| 76 | sample_0_qa76 | tm_c2e76991048042f7aad9bf38271271ef | 39 | 0.059751 | 0.000012 | 0.003905 | 0.049108 | 0.001153 | 0.000007 | 0.000002 |
| 77 | sample_0_qa77 | tm_8b6ed778c3cf49a09d23d59372db3aff | 39 | 0.076967 | 0.000016 | 0.000850 | 0.051927 | 0.014737 | 0.000005 | 0.000001 |
| 78 | sample_0_qa78 | tm_00637d2915244d04bab32a34a34b1731 | 39 | 0.060878 | 0.000018 | 0.000214 | 0.050687 | 0.005476 | 0.000007 | 0.000002 |
| 79 | sample_0_qa79 | tm_fea9cf35ac764a569e0b391123268721 | 39 | 0.059909 | 0.000015 | 0.000292 | 0.047522 | 0.001125 | 0.000007 | 0.000002 |
| 80 | sample_0_qa80 | tm_4114a4a197a8428fadfaccdc13d76723 | 39 | 0.056226 | 0.000016 | 0.002122 | 0.046115 | 0.001092 | 0.000006 | 0.000002 |
| 81 | sample_0_qa81 | tm_713739ae4bdc4fffb062ba1c0477b492 | 39 | 0.066400 | 0.000013 | 0.001627 | 0.051290 | 0.007313 | 0.000006 | 0.000002 |
| 82 | sample_0_qa82 | tm_49937ba2b6064b8e8031d5223c53541f | 39 | 0.066593 | 0.000013 | 0.000457 | 0.053234 | 0.007370 | 0.000005 | 0.000001 |
| 83 | sample_0_qa83 | tm_19ddab0985634de4966c13c8a1fa455e | 39 | 0.055756 | 0.000017 | 0.000248 | 0.050713 | 0.001127 | 0.000007 | 0.000002 |
| 84 | sample_0_qa84 | tm_502e1333e681480f989a41362e549c87 | 39 | 0.055644 | 0.000016 | 0.000162 | 0.046108 | 0.001127 | 0.000007 | 0.000002 |
| 85 | sample_0_qa85 | tm_71484ee4613f4a46964dd0217cf82f10 | 39 | 0.058746 | 0.000016 | 0.000989 | 0.048841 | 0.003835 | 0.000007 | 0.000002 |
| 86 | sample_0_qa86 | tm_62e07d80f83648fba3430a9c2cdd14e1 | 39 | 0.058981 | 0.000013 | 0.000274 | 0.051113 | 0.003941 | 0.000005 | 0.000002 |
| 87 | sample_0_qa87 | tm_51689e934b4742d6aba5454824876b71 | 39 | 0.055809 | 0.000018 | 0.000262 | 0.050806 | 0.001079 | 0.000007 | 0.000002 |
| 88 | sample_0_qa88 | tm_aa00dde1303046e9bcdc00ed8bf5b574 | 39 | 0.053018 | 0.000017 | 0.000233 | 0.047427 | 0.001768 | 0.000006 | 0.000002 |
| 89 | sample_0_qa89 | tm_3b7b8cd1d92d45768674707f85ad1659 | 39 | 0.052980 | 0.000015 | 0.000980 | 0.045981 | 0.001075 | 0.000007 | 0.000002 |
| 90 | sample_0_qa90 | tm_771d9f7325034748916d6251be3697f4 | 39 | 0.059268 | 0.000013 | 0.000276 | 0.051255 | 0.004051 | 0.000005 | 0.000001 |
| 91 | sample_0_qa91 | tm_d1a6f3fe277b403291c9825d7182eb0a | 39 | 0.055812 | 0.000015 | 0.000254 | 0.051009 | 0.000957 | 0.000007 | 0.000002 |
| 92 | sample_0_qa92 | tm_8b04b9f948c946f1bfefe99d117224bc | 39 | 0.054683 | 0.000019 | 0.000264 | 0.047232 | 0.003650 | 0.000006 | 0.000001 |
| 93 | sample_0_qa93 | tm_39907dfb2b7247b3a0b869f50d146067 | 39 | 0.051206 | 0.000016 | 0.000288 | 0.044690 | 0.000866 | 0.000006 | 0.000002 |
| 94 | sample_0_qa94 | tm_3fe310feaf354110ac3821e0a0c2287e | 39 | 0.051890 | 0.000015 | 0.000162 | 0.047011 | 0.001232 | 0.000007 | 0.000002 |
| 95 | sample_0_qa95 | tm_96fe19a9d07c45dd90b285e3269a3ace | 39 | 0.055928 | 0.000015 | 0.000308 | 0.048846 | 0.001114 | 0.000007 | 0.000002 |
| 96 | sample_0_qa96 | tm_d367fd40578d4879901ecb89a4196307 | 39 | 0.056129 | 0.000014 | 0.000143 | 0.048771 | 0.003794 | 0.000007 | 0.000002 |
| 97 | sample_0_qa97 | tm_8df2f47b6cc34d2ea9b1522db7ded019 | 39 | 0.054607 | 0.000014 | 0.000216 | 0.048013 | 0.002997 | 0.000006 | 0.000002 |
| 98 | sample_0_qa98 | tm_26b05cb2448d43f78fa8d2deef38e1c0 | 39 | 0.053890 | 0.000014 | 0.000151 | 0.046781 | 0.003506 | 0.000006 | 0.000002 |
| 99 | sample_0_qa99 | tm_9b79d2dc8a554a438349c849db2ef6e0 | 39 | 0.059339 | 0.000016 | 0.000346 | 0.052743 | 0.000892 | 0.000006 | 0.000002 |
| 100 | sample_0_qa100 | tm_940ab2ca00c54b0689e08760d3c28778 | 39 | 0.059823 | 0.000016 | 0.000152 | 0.051741 | 0.004519 | 0.000006 | 0.000002 |
| 101 | sample_0_qa101 | tm_5a94917f887b4d12b8de17f40a4497ec | 39 | 0.061428 | 0.000016 | 0.000337 | 0.047929 | 0.006956 | 0.000007 | 0.000002 |
| 102 | sample_0_qa102 | tm_78deec59aa414dc88fbc5cba8ea9aaae | 39 | 0.055395 | 0.000015 | 0.000191 | 0.044981 | 0.007003 | 0.000006 | 0.000002 |
| 103 | sample_0_qa103 | tm_9f65837223874b52b6d922d94c4588f0 | 39 | 0.052241 | 0.000015 | 0.000288 | 0.045651 | 0.001041 | 0.000007 | 0.000002 |
| 104 | sample_0_qa104 | tm_de136d8cc9414b4ba6601f85f16d595f | 39 | 0.055515 | 0.000016 | 0.000419 | 0.045716 | 0.001117 | 0.000007 | 0.000002 |
| 105 | sample_0_qa105 | tm_98033668b2824affb75223c10b86e53b | 39 | 0.061318 | 0.000016 | 0.000972 | 0.051031 | 0.004266 | 0.000006 | 0.000002 |
| 106 | sample_0_qa106 | tm_66138612ba1e4eb99e5c4dfa20f037bc | 39 | 0.057244 | 0.000013 | 0.000301 | 0.048512 | 0.004044 | 0.000007 | 0.000002 |
| 107 | sample_0_qa107 | tm_47212ba8b7184b1595f981257d95a911 | 39 | 0.055931 | 0.000019 | 0.000251 | 0.050839 | 0.001145 | 0.000007 | 0.000002 |
| 108 | sample_0_qa108 | tm_afedf599baf34c71902c7b96b88af87f | 39 | 0.053143 | 0.000017 | 0.000243 | 0.047312 | 0.001881 | 0.000006 | 0.000002 |
| 109 | sample_0_qa109 | tm_392761f2502743efb6113b787e4ab35b | 39 | 0.052703 | 0.000016 | 0.001059 | 0.045696 | 0.001085 | 0.000006 | 0.000002 |
| 110 | sample_0_qa110 | tm_f65a5c28311a4d20ad5bbeceb1965e75 | 39 | 0.059051 | 0.000013 | 0.000300 | 0.049649 | 0.004074 | 0.000006 | 0.000002 |
| 111 | sample_0_qa111 | tm_d56a388c4f3946ad964d0b29d5ee4b42 | 39 | 0.055815 | 0.000015 | 0.000223 | 0.050875 | 0.001093 | 0.000007 | 0.000002 |
| 112 | sample_0_qa112 | tm_d3e3ed756109407f845e0214aa53fc9f | 39 | 0.054658 | 0.000017 | 0.000194 | 0.047245 | 0.003762 | 0.000006 | 0.000002 |
| 113 | sample_0_qa113 | tm_0b3aea332ad4493a8e53072a0d4577d2 | 39 | 0.055935 | 0.000015 | 0.000173 | 0.048994 | 0.001113 | 0.000007 | 0.000002 |
| 114 | sample_0_qa114 | tm_e334f263309f451595ed856145a38a77 | 39 | 0.056167 | 0.000016 | 0.000160 | 0.048285 | 0.004280 | 0.000007 | 0.000002 |
| 115 | sample_0_qa115 | tm_b13da59f680046b5997eeda3cf856f5a | 39 | 0.055818 | 0.000016 | 0.000151 | 0.048872 | 0.001093 | 0.000007 | 0.000002 |
| 116 | sample_0_qa116 | tm_5e8a6fa66d7441d0a16f0b499eb0f34a | 39 | 0.055917 | 0.000016 | 0.000153 | 0.048541 | 0.003719 | 0.000007 | 0.000002 |
| 117 | sample_0_qa117 | tm_8a5ba53af52140c38ee1de05a237925e | 39 | 0.056260 | 0.000016 | 0.000204 | 0.048629 | 0.001673 | 0.000007 | 0.000002 |
| 118 | sample_0_qa118 | tm_f7d649375f4f4e25bb8655b4fc5b3ad9 | 39 | 0.056245 | 0.000016 | 0.000154 | 0.048158 | 0.003603 | 0.000008 | 0.000002 |
| 119 | sample_0_qa119 | tm_d7b3f1a16ee3459b8cfbb6fabec6cc82 | 39 | 0.065929 | 0.000016 | 0.000374 | 0.055070 | 0.005189 | 0.000006 | 0.000001 |
| 120 | sample_0_qa120 | tm_0be3a19e7a0946ee90d0faa173817b8d | 39 | 0.056031 | 0.000016 | 0.000158 | 0.047055 | 0.004908 | 0.000007 | 0.000002 |
| 121 | sample_0_qa121 | tm_d721549d1ff34575a577df58fbfc1b2e | 39 | 0.055292 | 0.000015 | 0.000387 | 0.048299 | 0.001110 | 0.000007 | 0.000002 |
| 122 | sample_0_qa122 | tm_d85042d9dd1840d3879aff43125545f9 | 39 | 0.054644 | 0.000019 | 0.000258 | 0.046525 | 0.003795 | 0.000006 | 0.000002 |
| 123 | sample_0_qa123 | tm_df54652ff5354d49be169f955f5bc29b | 39 | 0.060692 | 0.000016 | 0.001146 | 0.050510 | 0.004107 | 0.000006 | 0.000002 |
| 124 | sample_0_qa124 | tm_24bd855deb2f40eb8755ada38b3a19fe | 39 | 0.057037 | 0.000013 | 0.000390 | 0.048271 | 0.004604 | 0.000006 | 0.000002 |
| 125 | sample_0_qa125 | tm_2c3d14342961417c9351e2c37b6ea8e4 | 39 | 0.058914 | 0.000017 | 0.000365 | 0.048927 | 0.004173 | 0.000006 | 0.000001 |
| 126 | sample_0_qa126 | tm_7e8a1b698e794da1a97a0a522cb42ffb | 39 | 0.056714 | 0.000015 | 0.000159 | 0.047413 | 0.005766 | 0.000006 | 0.000002 |
| 127 | sample_0_qa127 | tm_ce34124008ca4c949a88ea648473ce13 | 39 | 0.060912 | 0.000016 | 0.001028 | 0.049278 | 0.005983 | 0.000006 | 0.000001 |
| 128 | sample_0_qa128 | tm_3fde480e260e4d299c0616d8210309fb | 39 | 0.057669 | 0.000013 | 0.000277 | 0.051525 | 0.001924 | 0.000007 | 0.000002 |
| 129 | sample_0_qa129 | tm_b1a83a7d19fa467b9e6c46671d4ffb73 | 39 | 0.059306 | 0.000014 | 0.000146 | 0.048117 | 0.007388 | 0.000007 | 0.000002 |
| 130 | sample_0_qa130 | tm_13d0df977ce9461f9a3393be332718e3 | 39 | 0.056226 | 0.000016 | 0.000148 | 0.046764 | 0.006070 | 0.000006 | 0.000002 |
| 131 | sample_0_qa131 | tm_ee0ac7721a70449c81c064a222e16682 | 39 | 0.056994 | 0.000016 | 0.001017 | 0.047846 | 0.001097 | 0.000007 | 0.000002 |
| 132 | sample_0_qa132 | tm_fd16c61360ca486da186139cf86bad15 | 39 | 0.070502 | 0.000013 | 0.002809 | 0.052314 | 0.007653 | 0.000006 | 0.000002 |
| 133 | sample_0_qa133 | tm_d5b71aa98c4c4cb4b187494b9054fe2c | 39 | 0.058724 | 0.000016 | 0.001190 | 0.045527 | 0.006739 | 0.000005 | 0.000001 |
| 134 | sample_0_qa134 | tm_5f175b59c8b642b8957944f1cc09450d | 39 | 0.064380 | 0.000013 | 0.000281 | 0.048093 | 0.010470 | 0.000006 | 0.000001 |
| 135 | sample_0_qa135 | tm_f744912200294b4ba3bf8921af42bcd4 | 39 | 0.055751 | 0.000016 | 0.000168 | 0.050939 | 0.001136 | 0.000007 | 0.000002 |
| 136 | sample_0_qa136 | tm_81a96e00718d47f98eb9d2cfc2905ffe | 39 | 0.056683 | 0.000017 | 0.001103 | 0.048739 | 0.001092 | 0.000014 | 0.000002 |
| 137 | sample_0_qa137 | tm_7a0a9571079a4d93a7be75bbbc69edf3 | 39 | 0.067928 | 0.000013 | 0.000319 | 0.054157 | 0.009365 | 0.000006 | 0.000001 |
| 138 | sample_0_qa138 | tm_f52d9c2d79b9408b80249d45e8a2b137 | 39 | 0.058258 | 0.000017 | 0.000507 | 0.048665 | 0.005500 | 0.000006 | 0.000002 |
| 139 | sample_0_qa139 | tm_805e96c59c0b4f0ea8a22d012686b441 | 39 | 0.051893 | 0.000016 | 0.000196 | 0.046957 | 0.001152 | 0.000007 | 0.000002 |
| 140 | sample_0_qa140 | tm_9ad1f9e7a8ff48e7bd30bb487326a972 | 39 | 0.055801 | 0.000016 | 0.000159 | 0.046259 | 0.001133 | 0.000007 | 0.000002 |
| 141 | sample_0_qa141 | tm_4d253b2f245d4d24a9bad58bbeb44a23 | 39 | 0.058913 | 0.000016 | 0.001062 | 0.051104 | 0.002059 | 0.000007 | 0.000002 |
| 142 | sample_0_qa142 | tm_30ad8304a1c84155850a9d5eecb9090f | 39 | 0.059016 | 0.000013 | 0.000283 | 0.048873 | 0.006082 | 0.000006 | 0.000001 |
| 143 | sample_0_qa143 | tm_dce6b608c90541d3acd861e2263752aa | 39 | 0.051833 | 0.000016 | 0.000162 | 0.047031 | 0.001151 | 0.000007 | 0.000002 |
| 144 | sample_0_qa144 | tm_2e2ad10a33264ab28776adc5da8f58b7 | 39 | 0.052265 | 0.000018 | 0.000283 | 0.046838 | 0.001459 | 0.000007 | 0.000002 |
| 145 | sample_0_qa145 | tm_609d830577bf48cca5769a3e3dd21d96 | 39 | 0.060008 | 0.000016 | 0.001057 | 0.050032 | 0.004172 | 0.000007 | 0.000002 |
| 146 | sample_0_qa146 | tm_e325863c4bdd461c9404db2fc725148d | 39 | 0.059962 | 0.000013 | 0.000313 | 0.050488 | 0.003841 | 0.000006 | 0.000001 |
| 147 | sample_0_qa147 | tm_dde51ba78da74258abb79ad514270526 | 39 | 0.056070 | 0.000016 | 0.000189 | 0.047214 | 0.005241 | 0.000006 | 0.000002 |
| 148 | sample_0_qa148 | tm_90307d867e8e48eb8289611901b952e8 | 39 | 0.051440 | 0.000017 | 0.000252 | 0.046270 | 0.001245 | 0.000007 | 0.000002 |
| 149 | sample_0_qa149 | tm_f3e69120b92248eb89aa15af89cc042d | 39 | 0.056738 | 0.000015 | 0.001016 | 0.047218 | 0.001091 | 0.000007 | 0.000002 |
| 150 | sample_0_qa150 | tm_3502990862994754ae2621210f1aad95 | 39 | 0.065766 | 0.000013 | 0.002762 | 0.052419 | 0.006506 | 0.000005 | 0.000001 |
| 151 | sample_0_qa151 | tm_a05ab961a4644702b3bfa4b0560645ca | 39 | 0.052681 | 0.000016 | 0.000172 | 0.046820 | 0.002070 | 0.000007 | 0.000002 |

问答端到端平均耗时：0.407697s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.32 | 0.011315 | 0.264991 | 1.651712 | 0.292584 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.32 | 0.033979 | 0.220002 | 1.652064 | 0.292442 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.32 | 0.049743 | 0.432069 | 1.494982 | 0.290942 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.32 | 0.099598 | 0.406924 | 1.473598 | 0.290113 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.32 | 0.033009 | 0.209003 | 1.651386 | 0.293866 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.32 | 0.084158 | 0.421536 | 1.473661 | 0.290941 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.32 | 0.083819 | 0.418716 | 1.477508 | 0.290849 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.32 | 0.049506 | 0.206929 | 1.652453 | 0.291292 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.011713 | 0.231250 | 0.000197 | 0.008145 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.043211 | 0.224444 | 0.000186 | 0.009169 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.32 | 0.052945 | 0.216643 | 0.000171 | 0.016370 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.39 | 0.095030 | 0.251735 | 0.000168 | 0.008130 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.39 | 0.099709 | 0.247403 | 0.000171 | 0.009194 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.37 | 0.101145 | 0.227471 | 0.000175 | 0.008635 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.31 | 0.045897 | 0.220524 | 0.000188 | 0.009121 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.3 | 0.044091 | 0.213171 | 0.000178 | 0.007287 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.021076 | 0.240560 | 0.000428 | 0.006815 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.016525 | 0.247274 | 0.000182 | 0.007309 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.33 | 0.069510 | 0.247745 | 0.000447 | 0.009488 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.29 | 0.031188 | 0.239882 | 0.000472 | 0.006980 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.033860 | 0.234500 | 0.000386 | 0.007345 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.072837 | 0.249734 | 0.000446 | 0.007670 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.26 | 0.010331 | 0.237678 | 0.000421 | 0.010524 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.34 | 0.080211 | 0.239355 | 0.000189 | 0.008355 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.26 | 0.020569 | 0.229564 | 0.000182 | 0.006926 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.027986 | 0.237427 | 0.000185 | 0.006771 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.064738 | 0.225911 | 0.000194 | 0.006765 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.27 | 0.019569 | 0.235620 | 0.000184 | 0.007968 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.060952 | 0.226147 | 0.000197 | 0.006884 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.073695 | 0.236261 | 0.000174 | 0.006822 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.33 | 0.072030 | 0.240719 | 0.000172 | 0.009833 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.065213 | 0.246690 | 0.000182 | 0.008501 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.34 | 0.069088 | 0.261919 | 0.000183 | 0.007326 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.064497 | 0.255980 | 0.000168 | 0.007789 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.28 | 0.029111 | 0.235188 | 0.000176 | 0.006927 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.073774 | 0.236945 | 0.000179 | 0.008762 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.019308 | 0.233164 | 0.000186 | 0.007967 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.35 | 0.070954 | 0.268377 | 0.000432 | 0.007203 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.32 | 0.072642 | 0.233464 | 0.000173 | 0.006970 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.29 | 0.027932 | 0.250936 | 0.000429 | 0.009194 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.29 | 0.026803 | 0.251071 | 0.000416 | 0.006624 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.061319 | 0.241021 | 0.000444 | 0.010239 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.28 | 0.026196 | 0.235618 | 0.000234 | 0.009160 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.33 | 0.078575 | 0.240762 | 0.000187 | 0.006759 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.27 | 0.030223 | 0.225883 | 0.000187 | 0.009335 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.033665 | 0.224457 | 0.000179 | 0.007207 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.31 | 0.075737 | 0.224344 | 0.000174 | 0.008641 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.29 | 0.029110 | 0.244004 | 0.000183 | 0.007016 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.31 | 0.060347 | 0.241937 | 0.000172 | 0.006959 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.31 | 0.063247 | 0.236861 | 0.000201 | 0.007801 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.29 | 0.027442 | 0.245220 | 0.000461 | 0.007204 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.3 | 0.062370 | 0.226808 | 0.000215 | 0.007876 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.32 | 0.060271 | 0.244800 | 0.000184 | 0.006841 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.071355 | 0.208039 | 0.000185 | 0.007394 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.034510 | 0.220880 | 0.000185 | 0.006785 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.32 | 0.066624 | 0.237155 | 0.000175 | 0.006911 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.31 | 0.066661 | 0.233736 | 0.000183 | 0.006672 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.017616 | 0.221257 | 0.000172 | 0.007827 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.056642 | 0.231863 | 0.000169 | 0.007028 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.3 | 0.072330 | 0.211639 | 0.000210 | 0.006675 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.3 | 0.071082 | 0.219452 | 0.000195 | 0.007258 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.25 | 0.019061 | 0.222732 | 0.000190 | 0.007473 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.073998 | 0.249061 | 0.000183 | 0.009539 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.073427 | 0.245254 | 0.000179 | 0.007771 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.33 | 0.074971 | 0.237934 | 0.000569 | 0.009919 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.27 | 0.027323 | 0.222091 | 0.000173 | 0.019067 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.34 | 0.077534 | 0.247773 | 0.000200 | 0.011315 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.025939 | 0.245692 | 0.000210 | 0.008194 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.33 | 0.067333 | 0.244149 | 0.000190 | 0.009615 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.29 | 0.017545 | 0.257264 | 0.000204 | 0.007957 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.25 | 0.017052 | 0.218515 | 0.000182 | 0.007422 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.29 | 0.029631 | 0.237364 | 0.000186 | 0.008823 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.34 | 0.078631 | 0.245044 | 0.000184 | 0.006534 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.027869 | 0.236511 | 0.000489 | 0.007102 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.067256 | 0.235522 | 0.000183 | 0.008190 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.33 | 0.062586 | 0.255102 | 0.000159 | 0.010832 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.35 | 0.070443 | 0.251507 | 0.000182 | 0.018892 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.34 | 0.068915 | 0.258941 | 0.000188 | 0.006833 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.28 | 0.017479 | 0.248849 | 0.000179 | 0.006789 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.023475 | 0.248340 | 0.000312 | 0.006935 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.026552 | 0.263310 | 0.000485 | 0.007227 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.34 | 0.068228 | 0.264712 | 0.000285 | 0.006911 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.32 | 0.029149 | 0.270129 | 0.000303 | 0.009451 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.28 | 0.021194 | 0.244904 | 0.000432 | 0.008554 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.32 | 0.068055 | 0.238707 | 0.000190 | 0.010225 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.26 | 0.017080 | 0.221943 | 0.000184 | 0.012041 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.34 | 0.063015 | 0.259806 | 0.000184 | 0.008126 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.29 | 0.028133 | 0.248238 | 0.000192 | 0.007349 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.29 | 0.029828 | 0.243062 | 0.000177 | 0.007749 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.28 | 0.026303 | 0.237129 | 0.000427 | 0.007293 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.32 | 0.068036 | 0.236832 | 0.000181 | 0.007029 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.27 | 0.020278 | 0.233709 | 0.000187 | 0.007968 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.3 | 0.070175 | 0.221580 | 0.000402 | 0.006661 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.31 | 0.073360 | 0.224164 | 0.000462 | 0.006592 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.32 | 0.071090 | 0.235270 | 0.000181 | 0.008673 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.25 | 0.023425 | 0.216308 | 0.000185 | 0.009817 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.31 | 0.061608 | 0.235495 | 0.000177 | 0.006685 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.31 | 0.066778 | 0.225497 | 0.000415 | 0.009385 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.24 | 0.018469 | 0.211160 | 0.000177 | 0.007101 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.33 | 0.059266 | 0.257017 | 0.000456 | 0.007750 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.35 | 0.076638 | 0.255346 | 0.000189 | 0.010605 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.33 | 0.065004 | 0.255531 | 0.000190 | 0.007740 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.33 | 0.071638 | 0.246831 | 0.000185 | 0.008178 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.29 | 0.033689 | 0.242893 | 0.000182 | 0.008470 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.29 | 0.029908 | 0.242413 | 0.000183 | 0.009986 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.34 | 0.081891 | 0.246680 | 0.000183 | 0.008033 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.28 | 0.020059 | 0.247664 | 0.000188 | 0.007344 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.27 | 0.022202 | 0.223298 | 0.000169 | 0.018483 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.31 | 0.056687 | 0.240840 | 0.000476 | 0.007208 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.26 | 0.020504 | 0.230447 | 0.000185 | 0.008411 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.3 | 0.062002 | 0.226562 | 0.000178 | 0.006599 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.26 | 0.026959 | 0.213557 | 0.000195 | 0.011825 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.35 | 0.076639 | 0.265522 | 0.000176 | 0.007174 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.31 | 0.067454 | 0.229625 | 0.000183 | 0.008323 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.26 | 0.019395 | 0.228986 | 0.000202 | 0.008909 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.32 | 0.064741 | 0.242601 | 0.000166 | 0.007403 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.33 | 0.070132 | 0.238401 | 0.000187 | 0.019407 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.28 | 0.020513 | 0.241235 | 0.000180 | 0.006788 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.33 | 0.066917 | 0.254475 | 0.000188 | 0.007366 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.32 | 0.067874 | 0.239678 | 0.000183 | 0.008247 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.29 | 0.018885 | 0.259338 | 0.000190 | 0.007238 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.31 | 0.057185 | 0.234491 | 0.000402 | 0.006964 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.3 | 0.026582 | 0.254885 | 0.000185 | 0.008479 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.3 | 0.061718 | 0.228095 | 0.000171 | 0.006841 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.27 | 0.022420 | 0.238435 | 0.000182 | 0.008777 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.32 | 0.078384 | 0.231895 | 0.000186 | 0.007230 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.29 | 0.025233 | 0.249905 | 0.000535 | 0.007539 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.33 | 0.065608 | 0.249822 | 0.000170 | 0.007246 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.32 | 0.067198 | 0.240108 | 0.000193 | 0.007484 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.28 | 0.010207 | 0.250682 | 0.000414 | 0.009309 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.33 | 0.074287 | 0.236698 | 0.000187 | 0.008021 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.32 | 0.064768 | 0.243585 | 0.000178 | 0.007535 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.27 | 0.025761 | 0.236685 | 0.000188 | 0.007138 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.27 | 0.024243 | 0.229705 | 0.000820 | 0.011458 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.34 | 0.066711 | 0.259356 | 0.000239 | 0.007168 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.33 | 0.070565 | 0.245296 | 0.000230 | 0.011804 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.28 | 0.033122 | 0.231276 | 0.000303 | 0.007625 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.31 | 0.077449 | 0.210688 | 0.000194 | 0.019371 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.3 | 0.031095 | 0.259071 | 0.000196 | 0.007623 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.34 | 0.075408 | 0.251979 | 0.000174 | 0.007019 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.29 | 0.024732 | 0.255474 | 0.000457 | 0.006753 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.34 | 0.064057 | 0.267301 | 0.000485 | 0.006536 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.34 | 0.066874 | 0.258546 | 0.000215 | 0.007816 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.31 | 0.065883 | 0.224792 | 0.000267 | 0.007661 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.3 | 0.021659 | 0.270402 | 0.000181 | 0.007445 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.32 | 0.068714 | 0.237483 | 0.000185 | 0.008856 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.26 | 0.019872 | 0.229892 | 0.000187 | 0.009109 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.28 | 0.059738 | 0.196116 | 0.000184 | 0.013021 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.23 | 0.017493 | 0.198020 | 0.000180 | 0.007203 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.21 | 0.029597 | 0.163124 | 0.000179 | 0.007712 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.17 | 0.027711 | 0.124301 | 0.000162 | 0.007193 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.17 | 0.063259 | 0.091903 | 0.000172 | 0.006622 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |