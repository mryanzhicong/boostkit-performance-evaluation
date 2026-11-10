# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.066071s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001423 | 2.154% |
| Query Embedding | 生成查询向量 | 0.048589 | 73.541% |
| 向量召回 | 召回语义相似记忆 | 0.009127 | 13.815% |
| 结果处理 | 整理候选并转换返回结构 | 0.000013 | 0.019% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.006918 | 10.471% |
|  |  | 0.066071 | 100.000% |

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

父阶段平均耗时：**0.066071s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001423 | 2.154% |
| Query Embedding | 生成查询向量 | 0.048589 | 73.541% |
| 向量召回 | 召回语义相似记忆 | 0.009127 | 13.815% |
| 结果处理 | 整理候选并转换返回结构 | 0.000013 | 0.019% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.006918 | 10.471% |
| 合计 |  | 0.066071 | 100.000% |

**结论：Query Embedding占73.541%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.001423s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000013 | 0.886% |
| 集合检查 | 检查目标集合与检索器 | 0.001411 | 99.114% |
| 合计 |  | 0.001423 | 100.000% |

**结论：集合检查占99.114%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000013s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000005 | 37.991% |
| 结构转换 | 构造接口返回对象 | 0.000001 | 10.309% |
| 结果处理内部 | 结果处理调度 | 0.000007 | 51.700% |
| 合计 |  | 0.000013 | 100.000% |

**结论：结果处理内部占51.701%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.397701s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.008410 | 2.115% |
| 记忆检索 | 查询相关记忆 | 0.046342 | 11.653% |
| 上下文筛选 | 选择候选记忆 | 0.000033 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.230685 | 58.005% |
| 重排 | 调整候选顺序 | 0.003310 | 0.832% |
| Prompt准备 | 构造回答输入 | 0.084647 | 21.284% |
| 回答LLM | 生成最终回答 | 0.024241 | 6.095% |
| 响应解析 | 解析回答结果 | 0.000033 | 0.008% |
| 合计 |  | 0.397701 | 100.000% |

**结论：记忆读取占58.005%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-10T18:48:19+08:00 |
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
| OV版本 | OpenViking v0.5.0 (official benchmark kit 48T96G, x86_64, container, out-of-the-box) |
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
| 检索耗时(s) | 0.066071 | 0.066856 | 0.070808 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_7315c26861c5401fa10220b6d0997398 | 39 | 0.039880 | 0.000025 | 0.002571 | 0.013587 | 0.014759 | 0.000005 | 0.000001 |
| 1 | sample_0_qa1 | tm_cb48607fb7a0401baaed7263897844eb | 39 | 0.038133 | 0.000014 | 0.001078 | 0.018346 | 0.008599 | 0.000005 | 0.000001 |
| 2 | sample_0_qa2 | tm_ba18c8c1df8f468a903062f1c6874433 | 39 | 0.036469 | 0.000012 | 0.002261 | 0.015614 | 0.009971 | 0.000005 | 0.000001 |
| 3 | sample_0_qa3 | tm_d0992e245f45424a83187be93d7d94ec | 39 | 0.034213 | 0.000011 | 0.000570 | 0.020428 | 0.002476 | 0.000005 | 0.000003 |
| 4 | sample_0_qa4 | tm_a8ba16152ba5484e8095648aa0187003 | 39 | 0.066691 | 0.000016 | 0.002196 | 0.046551 | 0.009314 | 0.000005 | 0.000002 |
| 5 | sample_0_qa5 | tm_3ac3bcd9f51b46d3b63f4069b0fa2caa | 39 | 0.069645 | 0.000011 | 0.001738 | 0.048599 | 0.012958 | 0.000004 | 0.000001 |
| 6 | sample_0_qa6 | tm_944e9e6c13f34a90ae61037db7b189dc | 39 | 0.065517 | 0.000011 | 0.001101 | 0.051097 | 0.007651 | 0.000005 | 0.000001 |
| 7 | sample_0_qa7 | tm_49289933de0d4f4aa5d81ce6eabe3e24 | 39 | 0.065572 | 0.000011 | 0.000377 | 0.053200 | 0.006961 | 0.000004 | 0.000001 |
| 8 | sample_0_qa8 | tm_2cab6c7de97747d2a6aac6668d566a39 | 39 | 0.071797 | 0.000017 | 0.002154 | 0.046313 | 0.015267 | 0.000005 | 0.000001 |
| 9 | sample_0_qa9 | tm_a35679e93ec14785bc1b99a49cc22769 | 39 | 0.066892 | 0.000011 | 0.001703 | 0.048726 | 0.009858 | 0.000005 | 0.000001 |
| 10 | sample_0_qa10 | tm_3d6b8f5e30844038b63f80f48817d78d | 39 | 0.062561 | 0.000010 | 0.001077 | 0.050768 | 0.004724 | 0.000005 | 0.000002 |
| 11 | sample_0_qa11 | tm_bb3885bcd08f4f8cb3271f418b01e2bf | 39 | 0.065518 | 0.000010 | 0.000354 | 0.053256 | 0.006871 | 0.000005 | 0.000001 |
| 12 | sample_0_qa12 | tm_da522dabb6874318a26ca9b8b58f21f0 | 39 | 0.069934 | 0.000017 | 0.002681 | 0.046285 | 0.012473 | 0.000005 | 0.000001 |
| 13 | sample_0_qa13 | tm_2b57f15aec464b1c816b3d68162bde4b | 39 | 0.064856 | 0.000012 | 0.001512 | 0.048465 | 0.007111 | 0.000005 | 0.000002 |
| 14 | sample_0_qa14 | tm_29f23e6606cd42118e67cf3282b2a1cd | 39 | 0.066963 | 0.000011 | 0.000918 | 0.050518 | 0.009417 | 0.000005 | 0.000001 |
| 15 | sample_0_qa15 | tm_c1b68d9d119540eeb30273cb053b063a | 39 | 0.066981 | 0.000010 | 0.000448 | 0.052899 | 0.008412 | 0.000005 | 0.000001 |
| 16 | sample_0_qa16 | tm_38ca140b338142acadc4178953d00184 | 39 | 0.070387 | 0.000017 | 0.002122 | 0.046155 | 0.013893 | 0.000005 | 0.000001 |
| 17 | sample_0_qa17 | tm_1228a6cbb0e7485a9dc3252755940a48 | 39 | 0.069667 | 0.000011 | 0.001659 | 0.048331 | 0.012920 | 0.000005 | 0.000001 |
| 18 | sample_0_qa18 | tm_9a06e44e641f49b18e617cbaeff1354d | 39 | 0.065112 | 0.000010 | 0.001061 | 0.050374 | 0.007619 | 0.000004 | 0.000001 |
| 19 | sample_0_qa19 | tm_7462704d573341b3bab95f50e90b7278 | 39 | 0.062113 | 0.000011 | 0.000386 | 0.052911 | 0.002696 | 0.000005 | 0.000002 |
| 20 | sample_0_qa20 | tm_ab39b46165954c688c36a0c0705d98c0 | 39 | 0.066894 | 0.000018 | 0.002457 | 0.046240 | 0.010310 | 0.000006 | 0.000007 |
| 21 | sample_0_qa21 | tm_d7c6d5d3a3264c06822552221304b1ea | 39 | 0.067507 | 0.000013 | 0.001529 | 0.048696 | 0.010246 | 0.000005 | 0.000001 |
| 22 | sample_0_qa22 | tm_68534327a2dc4bd68f4b09b8e7ba5617 | 39 | 0.067378 | 0.000011 | 0.000888 | 0.051137 | 0.009489 | 0.000004 | 0.000001 |
| 23 | sample_0_qa23 | tm_1ec2fc4a3b274646af93fbd532e72f43 | 39 | 0.067342 | 0.000010 | 0.000412 | 0.053245 | 0.008773 | 0.000004 | 0.000001 |
| 24 | sample_0_qa24 | tm_5d3d2838bec54d53884a265b3db78564 | 39 | 0.066886 | 0.000017 | 0.002474 | 0.046614 | 0.009076 | 0.000006 | 0.000002 |
| 25 | sample_0_qa25 | tm_175cd9961f3042749a805af71a0c114d | 39 | 0.069043 | 0.000011 | 0.001650 | 0.048652 | 0.011798 | 0.000005 | 0.000001 |
| 26 | sample_0_qa26 | tm_4a43875b35ce4f46a183b60d372f5694 | 39 | 0.065067 | 0.000011 | 0.001009 | 0.051121 | 0.006651 | 0.000004 | 0.000001 |
| 27 | sample_0_qa27 | tm_1bb1cb309c8a45ccbfb14059e0e769c2 | 39 | 0.067604 | 0.000010 | 0.000434 | 0.053173 | 0.008853 | 0.000004 | 0.000001 |
| 28 | sample_0_qa28 | tm_613773159ef348e78ee26dfb6c53dc90 | 39 | 0.071932 | 0.000017 | 0.002756 | 0.045961 | 0.014836 | 0.000004 | 0.000001 |
| 29 | sample_0_qa29 | tm_8c212aadb9854cc4b5d1c5cf7496d8c0 | 39 | 0.065502 | 0.000011 | 0.001836 | 0.048354 | 0.006888 | 0.000005 | 0.000002 |
| 30 | sample_0_qa30 | tm_b7991dd35e5b4913bc374200cdf65dcb | 39 | 0.064954 | 0.000012 | 0.000926 | 0.050162 | 0.007614 | 0.000004 | 0.000001 |
| 31 | sample_0_qa31 | tm_11f39aa6b6dd4dd1abc4199687cf1bdd | 39 | 0.064754 | 0.000010 | 0.000467 | 0.052553 | 0.006591 | 0.000004 | 0.000001 |
| 32 | sample_0_qa32 | tm_bf16c7a93d104fe48228fc0240d50af3 | 39 | 0.071101 | 0.000017 | 0.002201 | 0.045651 | 0.015593 | 0.000004 | 0.000001 |
| 33 | sample_0_qa33 | tm_cb8f18a7cca84036af2d0221158d57e2 | 39 | 0.066275 | 0.000011 | 0.001752 | 0.047997 | 0.010137 | 0.000004 | 0.000001 |
| 34 | sample_0_qa34 | tm_ebc3b36d93884302bf56d9c0c785141b | 39 | 0.066607 | 0.000011 | 0.001134 | 0.050638 | 0.009151 | 0.000004 | 0.000001 |
| 35 | sample_0_qa35 | tm_a8378529490f435ca886d670858d20f6 | 39 | 0.062275 | 0.000011 | 0.000387 | 0.052693 | 0.003014 | 0.000005 | 0.000002 |
| 36 | sample_0_qa36 | tm_8a5f2789cdf9406ca272dedee244e795 | 39 | 0.065937 | 0.000017 | 0.002451 | 0.046125 | 0.009966 | 0.000005 | 0.000002 |
| 37 | sample_0_qa37 | tm_a0028d4ddfe94a58a95b001c9e529703 | 39 | 0.069858 | 0.000011 | 0.001474 | 0.048356 | 0.013018 | 0.000004 | 0.000001 |
| 38 | sample_0_qa38 | tm_854434a39aab464d83396a822ae458ce | 39 | 0.064940 | 0.000011 | 0.000900 | 0.050418 | 0.007478 | 0.000004 | 0.000001 |
| 39 | sample_0_qa39 | tm_bdb0c4c5bc2349a4a5a1bd61f86dff1f | 39 | 0.065450 | 0.000010 | 0.000453 | 0.052814 | 0.007109 | 0.000004 | 0.000001 |
| 40 | sample_0_qa40 | tm_6f22ea46e5f741f69e1f3813d527576a | 39 | 0.068678 | 0.000017 | 0.002511 | 0.046069 | 0.012093 | 0.000004 | 0.000001 |
| 41 | sample_0_qa41 | tm_822a27f4bc71466f9073f1266e313847 | 39 | 0.068058 | 0.000011 | 0.001533 | 0.048537 | 0.011010 | 0.000004 | 0.000001 |
| 42 | sample_0_qa42 | tm_e6daeaa507c44722a4cb14d7e5dbd30a | 39 | 0.067883 | 0.000012 | 0.000918 | 0.050615 | 0.010511 | 0.000004 | 0.000001 |
| 43 | sample_0_qa43 | tm_815adc17bc6c45929d28dae97ced0807 | 39 | 0.061183 | 0.000010 | 0.000467 | 0.053209 | 0.002087 | 0.000014 | 0.000002 |
| 44 | sample_0_qa44 | tm_2ab4298b726845078cd6e0b3b65b1431 | 39 | 0.065185 | 0.000017 | 0.002258 | 0.045293 | 0.008932 | 0.000005 | 0.000002 |
| 45 | sample_0_qa45 | tm_3c4fddd792b244fc8a626e235f6d0b40 | 39 | 0.067008 | 0.000010 | 0.001805 | 0.047638 | 0.010965 | 0.000005 | 0.000001 |
| 46 | sample_0_qa46 | tm_59486b3c30154792a80101eb25733a64 | 39 | 0.064242 | 0.000012 | 0.001126 | 0.050108 | 0.006977 | 0.000004 | 0.000001 |
| 47 | sample_0_qa47 | tm_3b5e58452d714550b24605d023cdde4b | 39 | 0.065461 | 0.000011 | 0.000561 | 0.049572 | 0.007828 | 0.000005 | 0.000001 |
| 48 | sample_0_qa48 | tm_998af1a2a6b64ba7be2ef32c2e581fd1 | 39 | 0.070445 | 0.000019 | 0.002467 | 0.046945 | 0.012806 | 0.000005 | 0.000001 |
| 49 | sample_0_qa49 | tm_3fc9bc3501ba4a219eb7e58f593fdf3f | 39 | 0.066418 | 0.000011 | 0.001559 | 0.048841 | 0.009161 | 0.000004 | 0.000001 |
| 50 | sample_0_qa50 | tm_a473968b1cda450c8a441a0bc3cbeb67 | 39 | 0.063001 | 0.000011 | 0.000953 | 0.051240 | 0.004154 | 0.000005 | 0.000002 |
| 51 | sample_0_qa51 | tm_d3e8d5e0c4f544c988309bef82a44d37 | 39 | 0.066282 | 0.000010 | 0.000487 | 0.053285 | 0.007450 | 0.000004 | 0.000001 |
| 52 | sample_0_qa52 | tm_81e8f09b19724363b8e6ba9460ce9593 | 39 | 0.065465 | 0.000017 | 0.002166 | 0.046317 | 0.008778 | 0.000006 | 0.000002 |
| 53 | sample_0_qa53 | tm_96140570135c418090da4e6efd986c9c | 39 | 0.065793 | 0.000010 | 0.001738 | 0.048739 | 0.008450 | 0.000005 | 0.000001 |
| 54 | sample_0_qa54 | tm_059c636bc3a448359096330fee49d429 | 39 | 0.066826 | 0.000010 | 0.001147 | 0.050791 | 0.009158 | 0.000005 | 0.000001 |
| 55 | sample_0_qa55 | tm_3c7de6cf331a4476bff65746572bc882 | 39 | 0.066793 | 0.000011 | 0.000396 | 0.053285 | 0.008071 | 0.000004 | 0.000001 |
| 56 | sample_0_qa56 | tm_d66ffef57ae94bbfbea1ae93a0cb343d | 39 | 0.068016 | 0.000017 | 0.002594 | 0.047612 | 0.008806 | 0.000005 | 0.000002 |
| 57 | sample_0_qa57 | tm_c9765c9c902b4c159eb5edb86f7d47bb | 39 | 0.068775 | 0.000011 | 0.001811 | 0.049675 | 0.009770 | 0.000006 | 0.000001 |
| 58 | sample_0_qa58 | tm_2fb0e96ac9e2423c9f88118b0c120e04 | 39 | 0.067961 | 0.000012 | 0.000934 | 0.054245 | 0.007099 | 0.000005 | 0.000001 |
| 59 | sample_0_qa59 | tm_30b7353add2e458c99c6dd9297a54491 | 39 | 0.069120 | 0.000010 | 0.000455 | 0.052156 | 0.011622 | 0.000004 | 0.000001 |
| 60 | sample_0_qa60 | tm_754eeaa93f634846a93e9cc195b662d8 | 39 | 0.067751 | 0.000017 | 0.003294 | 0.046124 | 0.009770 | 0.000005 | 0.000002 |
| 61 | sample_0_qa61 | tm_a9497c939afa413883888ebd9f08ccc9 | 39 | 0.067586 | 0.000013 | 0.002035 | 0.047041 | 0.010184 | 0.000005 | 0.000001 |
| 62 | sample_0_qa62 | tm_db295c1e81544d66853925024cfd3a00 | 39 | 0.069257 | 0.000011 | 0.001442 | 0.048911 | 0.011709 | 0.000005 | 0.000001 |
| 63 | sample_0_qa63 | tm_6503f928fd2c45eebfabaa1ffc1ff7fd | 39 | 0.064974 | 0.000011 | 0.000607 | 0.051527 | 0.007240 | 0.000005 | 0.000001 |
| 64 | sample_0_qa64 | tm_022170528a1d4997aefd7e900c8c291e | 39 | 0.068475 | 0.000026 | 0.002391 | 0.047501 | 0.009070 | 0.000005 | 0.000002 |
| 65 | sample_0_qa65 | tm_1a674629b46c4cdda2c641c582cbe042 | 39 | 0.070569 | 0.000011 | 0.001946 | 0.049562 | 0.012583 | 0.000006 | 0.000001 |
| 66 | sample_0_qa66 | tm_908cd7184f16441d911c686e5c1796bf | 39 | 0.066353 | 0.000012 | 0.000897 | 0.054112 | 0.005186 | 0.000005 | 0.000001 |
| 67 | sample_0_qa67 | tm_ea3d452772b94c629d2b724fef1a6dd5 | 39 | 0.065926 | 0.000010 | 0.000427 | 0.052017 | 0.008690 | 0.000005 | 0.000001 |
| 68 | sample_0_qa68 | tm_2d3ac4d7e63040099fb78ae83da3bb13 | 39 | 0.070407 | 0.000018 | 0.002138 | 0.046959 | 0.013350 | 0.000005 | 0.000001 |
| 69 | sample_0_qa69 | tm_4941a5f1fe0c48e58a55da9ceab9cfdf | 39 | 0.064146 | 0.000010 | 0.001686 | 0.049022 | 0.006636 | 0.000005 | 0.000002 |
| 70 | sample_0_qa70 | tm_daa4c79610da45c9b8e7c036c1b95556 | 39 | 0.065446 | 0.000010 | 0.001099 | 0.051487 | 0.006782 | 0.000005 | 0.000001 |
| 71 | sample_0_qa71 | tm_98f50c8bb8324116bf40a3ea8ae39a5b | 39 | 0.067392 | 0.000011 | 0.000365 | 0.053652 | 0.008371 | 0.000005 | 0.000001 |
| 72 | sample_0_qa72 | tm_fa95f95f39ed4cc6bdfa7f9051cf2208 | 39 | 0.069631 | 0.000017 | 0.002312 | 0.046606 | 0.011890 | 0.000005 | 0.000001 |
| 73 | sample_0_qa73 | tm_7a209e9e44ce47f682bafb8987038e1f | 39 | 0.068350 | 0.000010 | 0.001858 | 0.048432 | 0.011197 | 0.000004 | 0.000001 |
| 74 | sample_0_qa74 | tm_85b2f1f040c341d5a486190791ec071e | 39 | 0.068472 | 0.000013 | 0.000985 | 0.050922 | 0.010395 | 0.000004 | 0.000001 |
| 75 | sample_0_qa75 | tm_4a0b5beb10674a83a5567ce59c3e85be | 39 | 0.062321 | 0.000011 | 0.000525 | 0.052993 | 0.003169 | 0.000005 | 0.000002 |
| 76 | sample_0_qa76 | tm_3897851e0b2f4fa49ff00039f439f066 | 39 | 0.068230 | 0.000017 | 0.002423 | 0.048727 | 0.009812 | 0.000005 | 0.000001 |
| 77 | sample_0_qa77 | tm_7a7f4406972744f2a39937fc4e0cefa9 | 39 | 0.068281 | 0.000010 | 0.001967 | 0.046628 | 0.013321 | 0.000005 | 0.000001 |
| 78 | sample_0_qa78 | tm_96c01f8b2e4645aaaa09aca7ef4d658d | 39 | 0.063706 | 0.000011 | 0.000875 | 0.051165 | 0.004514 | 0.000005 | 0.000002 |
| 79 | sample_0_qa79 | tm_256b1a95f4a64775ab4756cde401b69f | 39 | 0.066662 | 0.000010 | 0.000415 | 0.053234 | 0.008067 | 0.000005 | 0.000001 |
| 80 | sample_0_qa80 | tm_98fb9610c38b4be3a6598cd950339ba7 | 39 | 0.066453 | 0.000018 | 0.002180 | 0.046590 | 0.009086 | 0.000005 | 0.000002 |
| 81 | sample_0_qa81 | tm_0e3f3f9340d34ea4abccb75b8f6cac1c | 39 | 0.067071 | 0.000011 | 0.001748 | 0.049096 | 0.009669 | 0.000004 | 0.000001 |
| 82 | sample_0_qa82 | tm_1f8128652e7743958265d5622c38a344 | 39 | 0.068669 | 0.000010 | 0.001158 | 0.053220 | 0.008572 | 0.000004 | 0.000001 |
| 83 | sample_0_qa83 | tm_18b53d4d5aa046bd9598d7a09cbebde6 | 39 | 0.065735 | 0.000010 | 0.000435 | 0.051132 | 0.009133 | 0.000004 | 0.000001 |
| 84 | sample_0_qa84 | tm_bcfcd4981a634f4785654bf79a39d480 | 39 | 0.071942 | 0.000017 | 0.002180 | 0.046240 | 0.014993 | 0.000005 | 0.000001 |
| 85 | sample_0_qa85 | tm_d156a5060c824f23af5cf3773590f96c | 39 | 0.066779 | 0.000017 | 0.001731 | 0.048657 | 0.009721 | 0.000004 | 0.000001 |
| 86 | sample_0_qa86 | tm_7864e62bc601436988185b23c8347e40 | 39 | 0.062934 | 0.000011 | 0.001074 | 0.050706 | 0.004750 | 0.000005 | 0.000003 |
| 87 | sample_0_qa87 | tm_a72b50be28354caa816561f549bc8772 | 39 | 0.065229 | 0.000010 | 0.000361 | 0.053061 | 0.006722 | 0.000004 | 0.000001 |
| 88 | sample_0_qa88 | tm_2d55ddfc08b0459eb9f237aeb7626587 | 39 | 0.069309 | 0.000018 | 0.002284 | 0.046399 | 0.012139 | 0.000005 | 0.000001 |
| 89 | sample_0_qa89 | tm_645bfe8132d34c7da0e71542b80ad1f2 | 39 | 0.068351 | 0.000011 | 0.001840 | 0.048809 | 0.011197 | 0.000005 | 0.000001 |
| 90 | sample_0_qa90 | tm_e0e26f0d21d04b01b1570c2fa9dcdd74 | 39 | 0.068403 | 0.000011 | 0.001078 | 0.050884 | 0.010477 | 0.000005 | 0.000001 |
| 91 | sample_0_qa91 | tm_700004b691ce4aebaac0921e7aa55273 | 39 | 0.062387 | 0.000010 | 0.000398 | 0.053523 | 0.002146 | 0.000005 | 0.000002 |
| 92 | sample_0_qa92 | tm_95ab029c2fcb4949b348658b88cf009b | 39 | 0.067321 | 0.000017 | 0.002184 | 0.045463 | 0.011182 | 0.000006 | 0.000001 |
| 93 | sample_0_qa93 | tm_4659c0da3d3a452bbba4b855a5b07e15 | 39 | 0.067472 | 0.000011 | 0.001724 | 0.047565 | 0.011455 | 0.000006 | 0.000001 |
| 94 | sample_0_qa94 | tm_5098bd771c6c4d05998d81998e3669d5 | 39 | 0.061791 | 0.000011 | 0.001101 | 0.047881 | 0.004406 | 0.000006 | 0.000002 |
| 95 | sample_0_qa95 | tm_652986a1641d4cec98753635b068a393 | 39 | 0.065994 | 0.000011 | 0.000438 | 0.049974 | 0.008341 | 0.000004 | 0.000001 |
| 96 | sample_0_qa96 | tm_7154670db2964c22ad26dcea9cbf84e3 | 39 | 0.073203 | 0.000017 | 0.002698 | 0.045999 | 0.015928 | 0.000005 | 0.000001 |
| 97 | sample_0_qa97 | tm_42e491ddf598490290b4619a420e431b | 39 | 0.067640 | 0.000011 | 0.001554 | 0.048460 | 0.010190 | 0.000005 | 0.000001 |
| 98 | sample_0_qa98 | tm_05bf1d1373354342ad2f254ec427d906 | 39 | 0.064375 | 0.000011 | 0.000915 | 0.050605 | 0.005989 | 0.000005 | 0.000002 |
| 99 | sample_0_qa99 | tm_d40a3f661dd54d7cba28e1610fb10580 | 39 | 0.065771 | 0.000011 | 0.000440 | 0.052741 | 0.007083 | 0.000004 | 0.000001 |
| 100 | sample_0_qa100 | tm_5564824f102e41868fa9aed83cc56207 | 39 | 0.067358 | 0.000018 | 0.002410 | 0.046399 | 0.010606 | 0.000005 | 0.000002 |
| 101 | sample_0_qa101 | tm_b2432f92bdb94bce863fabbc37b01ba5 | 39 | 0.068744 | 0.000011 | 0.001933 | 0.048823 | 0.011176 | 0.000004 | 0.000001 |
| 102 | sample_0_qa102 | tm_811b6871adac46c5bc61a09d411ffd62 | 39 | 0.068727 | 0.000011 | 0.001090 | 0.050634 | 0.010539 | 0.000004 | 0.000001 |
| 103 | sample_0_qa103 | tm_0483c5a6df49419398318fbd6878eded | 39 | 0.064121 | 0.000010 | 0.000497 | 0.053309 | 0.005009 | 0.000004 | 0.000001 |
| 104 | sample_0_qa104 | tm_e332d9310403496da25baae41becc3d9 | 39 | 0.064883 | 0.000017 | 0.002231 | 0.045361 | 0.009475 | 0.000005 | 0.000002 |
| 105 | sample_0_qa105 | tm_71e70d4d9f924de9957d5a208a00de41 | 39 | 0.067654 | 0.000010 | 0.001776 | 0.046426 | 0.011513 | 0.000004 | 0.000001 |
| 106 | sample_0_qa106 | tm_f21ee8af9c3042c5b276b4229f8607ab | 39 | 0.067814 | 0.000011 | 0.001144 | 0.048966 | 0.010350 | 0.000005 | 0.000001 |
| 107 | sample_0_qa107 | tm_17a44b9f7418422fa1f16dadcc499b7d | 39 | 0.063438 | 0.000011 | 0.000402 | 0.051052 | 0.005197 | 0.000005 | 0.000001 |
| 108 | sample_0_qa108 | tm_168b949fb7614a97a206360b72c36057 | 39 | 0.071600 | 0.000018 | 0.002828 | 0.047626 | 0.012614 | 0.000006 | 0.000001 |
| 109 | sample_0_qa109 | tm_60c600da0d1742908b67fd4442273c00 | 39 | 0.071892 | 0.000011 | 0.001781 | 0.049685 | 0.013441 | 0.000004 | 0.000001 |
| 110 | sample_0_qa110 | tm_c4f376757c454afb9557beaf791ef248 | 39 | 0.066273 | 0.000011 | 0.000958 | 0.051940 | 0.006287 | 0.000005 | 0.000002 |
| 111 | sample_0_qa111 | tm_4c8c913cd8ce4f778c9574337bdf74f4 | 39 | 0.067500 | 0.000011 | 0.000492 | 0.053996 | 0.007425 | 0.000005 | 0.000001 |
| 112 | sample_0_qa112 | tm_b2785e1e58eb4d99a3eb66589de8ac92 | 39 | 0.066436 | 0.000017 | 0.002372 | 0.046633 | 0.009389 | 0.000005 | 0.000002 |
| 113 | sample_0_qa113 | tm_74b7fe6707454fd2a748eb290c8aba5a | 39 | 0.069281 | 0.000011 | 0.001906 | 0.049066 | 0.011658 | 0.000005 | 0.000001 |
| 114 | sample_0_qa114 | tm_197041a2e42a48fd82c94eb4829fbd9c | 39 | 0.069219 | 0.000011 | 0.001137 | 0.051121 | 0.011030 | 0.000005 | 0.000001 |
| 115 | sample_0_qa115 | tm_c04c5447b3f148768cfdaf9b8a8d4bdf | 39 | 0.064513 | 0.000011 | 0.000387 | 0.053548 | 0.004642 | 0.000005 | 0.000001 |
| 116 | sample_0_qa116 | tm_184ef0fcdae04dd584fc5162403bcad3 | 39 | 0.067973 | 0.000017 | 0.002401 | 0.045146 | 0.011880 | 0.000004 | 0.000001 |
| 117 | sample_0_qa117 | tm_17c2a34db44e4e958ede55319bc02c21 | 39 | 0.067452 | 0.000011 | 0.001496 | 0.046078 | 0.011484 | 0.000005 | 0.000001 |
| 118 | sample_0_qa118 | tm_c4883c2bcdb6467ea3cf704c826a79a8 | 39 | 0.067022 | 0.000011 | 0.000896 | 0.048743 | 0.010293 | 0.000004 | 0.000001 |
| 119 | sample_0_qa119 | tm_4eebd27b7061465194401006de62c6a8 | 39 | 0.059986 | 0.000010 | 0.000450 | 0.050805 | 0.002083 | 0.000005 | 0.000002 |
| 120 | sample_0_qa120 | tm_d193d79a93e144409aef3f4161a0265d | 39 | 0.068666 | 0.000018 | 0.002475 | 0.044919 | 0.012436 | 0.000004 | 0.000001 |
| 121 | sample_0_qa121 | tm_e6254a1e35d54299868062af98127b80 | 39 | 0.067504 | 0.000011 | 0.001730 | 0.045782 | 0.011562 | 0.000004 | 0.000001 |
| 122 | sample_0_qa122 | tm_3be9821e74a849d4ad4836b661614e58 | 39 | 0.062501 | 0.000011 | 0.001076 | 0.048462 | 0.004333 | 0.000005 | 0.000002 |
| 123 | sample_0_qa123 | tm_20a0f8bbd10b4a269585b502a53cfd5a | 39 | 0.065753 | 0.000010 | 0.000555 | 0.050355 | 0.008144 | 0.000004 | 0.000001 |
| 124 | sample_0_qa124 | tm_25497091c22b433e855d19827b259500 | 39 | 0.067946 | 0.000018 | 0.002108 | 0.047335 | 0.009373 | 0.000005 | 0.000002 |
| 125 | sample_0_qa125 | tm_e68edaacafa64301b6e1eddbae701e5f | 39 | 0.070304 | 0.000010 | 0.001655 | 0.049395 | 0.012875 | 0.000004 | 0.000001 |
| 126 | sample_0_qa126 | tm_e5761d8a2890421d85731ec849e9ed2a | 39 | 0.066018 | 0.000011 | 0.001067 | 0.051854 | 0.007278 | 0.000005 | 0.000001 |
| 127 | sample_0_qa127 | tm_d7583592eae443939b37a93ab451e54f | 39 | 0.066291 | 0.000011 | 0.000386 | 0.053916 | 0.006922 | 0.000004 | 0.000001 |
| 128 | sample_0_qa128 | tm_49412bc3e14545a5b507d786a1ca1eeb | 39 | 0.066621 | 0.000018 | 0.002533 | 0.049019 | 0.007590 | 0.000005 | 0.000002 |
| 129 | sample_0_qa129 | tm_a35a1d2131654fd8a04ae9b993f646f2 | 39 | 0.069875 | 0.000011 | 0.001476 | 0.046517 | 0.014993 | 0.000004 | 0.000001 |
| 130 | sample_0_qa130 | tm_41b7b7414e784ce4aec96ab92925a589 | 39 | 0.065218 | 0.000010 | 0.000861 | 0.051052 | 0.007413 | 0.000005 | 0.000001 |
| 131 | sample_0_qa131 | tm_ef972f7d7a6147a4b20585f64c551d6b | 39 | 0.065190 | 0.000010 | 0.000398 | 0.053427 | 0.006419 | 0.000005 | 0.000001 |
| 132 | sample_0_qa132 | tm_d6bafbf8c88647acbd17c64127f2cd1b | 39 | 0.068469 | 0.000017 | 0.002374 | 0.046147 | 0.012079 | 0.000004 | 0.000001 |
| 133 | sample_0_qa133 | tm_c7d35ec7b9a54808890ed09fd0219c57 | 39 | 0.068709 | 0.000010 | 0.001927 | 0.048568 | 0.011384 | 0.000005 | 0.000001 |
| 134 | sample_0_qa134 | tm_cabf0543081f47bc90a609eed47b9fc6 | 39 | 0.068765 | 0.000012 | 0.000990 | 0.050610 | 0.010771 | 0.000004 | 0.000001 |
| 135 | sample_0_qa135 | tm_e61aa291a10d48b2a63ef96d241841e7 | 39 | 0.062659 | 0.000010 | 0.000424 | 0.052976 | 0.003009 | 0.000005 | 0.000002 |
| 136 | sample_0_qa136 | tm_af567c4e6cdc453ba2684c44b50a34d3 | 39 | 0.066988 | 0.000017 | 0.002464 | 0.045440 | 0.011867 | 0.000005 | 0.000001 |
| 137 | sample_0_qa137 | tm_65a24c7ae456420096a626c66c1b10b4 | 39 | 0.063960 | 0.000011 | 0.001594 | 0.046403 | 0.007096 | 0.000005 | 0.000002 |
| 138 | sample_0_qa138 | tm_68c3d2a69b0c4fe282ad5968f176088f | 39 | 0.065658 | 0.000010 | 0.001156 | 0.049013 | 0.008573 | 0.000005 | 0.000001 |
| 139 | sample_0_qa139 | tm_6fb0c3124ee8442ab693a3da1112ade1 | 39 | 0.065607 | 0.000011 | 0.000561 | 0.051072 | 0.007893 | 0.000005 | 0.000001 |
| 140 | sample_0_qa140 | tm_a3e8a59b76e64bc6b2757cb2e2a77586 | 39 | 0.070230 | 0.000017 | 0.002588 | 0.046392 | 0.013541 | 0.000006 | 0.000001 |
| 141 | sample_0_qa141 | tm_d23c3f2e8571449bb8db9628cfc6f928 | 39 | 0.067009 | 0.000012 | 0.001563 | 0.048570 | 0.009654 | 0.000005 | 0.000001 |
| 142 | sample_0_qa142 | tm_901828aa528d4ef7920f98319e3a0144 | 39 | 0.062665 | 0.000011 | 0.000932 | 0.050624 | 0.004515 | 0.000005 | 0.000002 |
| 143 | sample_0_qa143 | tm_b9a8894b6fa74f0bb6d5fc0f2bc26328 | 39 | 0.067023 | 0.000010 | 0.000465 | 0.052960 | 0.008297 | 0.000005 | 0.000001 |
| 144 | sample_0_qa144 | tm_64b9c4f8a42d4a429e99c8dc6874cda6 | 39 | 0.072482 | 0.000018 | 0.002846 | 0.046176 | 0.015081 | 0.000004 | 0.000001 |
| 145 | sample_0_qa145 | tm_68396befcb42464daa391bb9a583697a | 39 | 0.064863 | 0.000012 | 0.001814 | 0.048593 | 0.006667 | 0.000005 | 0.000002 |
| 146 | sample_0_qa146 | tm_ed350b2a1c95417cbf11cc3eeb0503e3 | 39 | 0.066792 | 0.000011 | 0.000939 | 0.050058 | 0.008977 | 0.000004 | 0.000001 |
| 147 | sample_0_qa147 | tm_110fae93fea04a1bbaed717abebbcb0c | 39 | 0.063801 | 0.000010 | 0.000545 | 0.052427 | 0.005121 | 0.000004 | 0.000001 |
| 148 | sample_0_qa148 | tm_64603193a2354b79a046b9f5e1330e88 | 39 | 0.065783 | 0.000018 | 0.002380 | 0.045510 | 0.009302 | 0.000005 | 0.000002 |
| 149 | sample_0_qa149 | tm_f0e18dd3cb214385bb66d222e003574d | 39 | 0.065935 | 0.000010 | 0.001938 | 0.047876 | 0.009753 | 0.000004 | 0.000001 |
| 150 | sample_0_qa150 | tm_5f8c674c2b904d6b8ed1bc82ee882af1 | 39 | 0.067483 | 0.000011 | 0.000985 | 0.047922 | 0.010266 | 0.000004 | 0.000001 |
| 151 | sample_0_qa151 | tm_99e5b1caa5554aab8e1079cd94ae997a | 39 | 0.064501 | 0.000010 | 0.000411 | 0.049982 | 0.006696 | 0.000005 | 0.000001 |

问答端到端平均耗时：0.397763s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.56 | 0.011534 | 0.522585 | 1.600754 | 0.307337 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.56 | 0.093091 | 0.490949 | 1.602976 | 0.304799 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.56 | 0.036766 | 0.497249 | 1.601046 | 0.307012 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.56 | 0.079407 | 0.484588 | 1.602048 | 0.305967 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.56 | 0.059975 | 0.483270 | 1.601661 | 0.307196 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.56 | 0.029215 | 0.488430 | 1.601455 | 0.307417 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.56 | 0.092913 | 0.489460 | 1.602524 | 0.305859 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.56 | 0.033100 | 0.471716 | 1.602835 | 0.304577 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.011368 | 0.213831 | 0.000182 | 0.007915 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.041513 | 0.175990 | 0.000133 | 0.007403 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.27 | 0.035821 | 0.194528 | 0.000159 | 0.008604 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.33 | 0.093629 | 0.195441 | 0.000129 | 0.008262 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.31 | 0.064593 | 0.205054 | 0.000160 | 0.007006 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.26 | 0.029739 | 0.187448 | 0.000150 | 0.009623 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.33 | 0.076141 | 0.212189 | 0.000145 | 0.012009 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.31 | 0.092401 | 0.187678 | 0.000147 | 0.007224 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.022869 | 0.210433 | 0.000194 | 0.007200 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.056625 | 0.207438 | 0.000462 | 0.006771 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.23 | 0.020442 | 0.193138 | 0.000479 | 0.006990 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.28 | 0.066132 | 0.196955 | 0.000431 | 0.007706 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.057900 | 0.205287 | 0.000457 | 0.006776 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.23 | 0.017400 | 0.203242 | 0.000198 | 0.008793 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.31 | 0.071853 | 0.222018 | 0.000492 | 0.007333 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.28 | 0.064937 | 0.198000 | 0.000512 | 0.011586 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.22 | 0.019371 | 0.191403 | 0.000194 | 0.009205 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.065747 | 0.197044 | 0.000535 | 0.010252 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.24 | 0.023512 | 0.204548 | 0.000479 | 0.009692 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.3 | 0.067598 | 0.221333 | 0.000204 | 0.007649 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.064137 | 0.194224 | 0.000212 | 0.009980 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.017885 | 0.214243 | 0.000488 | 0.008138 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.29 | 0.070832 | 0.211740 | 0.000487 | 0.007048 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.058242 | 0.212357 | 0.000495 | 0.011868 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.23 | 0.021722 | 0.198357 | 0.000198 | 0.006890 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.021475 | 0.206195 | 0.000266 | 0.010384 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.28 | 0.071069 | 0.190448 | 0.000200 | 0.007307 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.020182 | 0.214702 | 0.000267 | 0.014016 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.065010 | 0.232821 | 0.000526 | 0.007943 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.3 | 0.063970 | 0.225109 | 0.000215 | 0.008742 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.29 | 0.059518 | 0.216438 | 0.000222 | 0.007262 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.31 | 0.060395 | 0.233644 | 0.000518 | 0.006533 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.25 | 0.018459 | 0.214884 | 0.000220 | 0.007380 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.021091 | 0.208657 | 0.000245 | 0.007501 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.29 | 0.059406 | 0.213696 | 0.000246 | 0.008544 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.25 | 0.018513 | 0.214491 | 0.000274 | 0.007528 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.24 | 0.014550 | 0.209523 | 0.000535 | 0.007218 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.069344 | 0.224622 | 0.000237 | 0.007153 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.25 | 0.016310 | 0.218845 | 0.000779 | 0.012821 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.29 | 0.065164 | 0.215043 | 0.000264 | 0.008776 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.3 | 0.061763 | 0.225598 | 0.000233 | 0.008616 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.059600 | 0.228987 | 0.000278 | 0.007517 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.27 | 0.021042 | 0.231040 | 0.000759 | 0.009003 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.29 | 0.067525 | 0.205472 | 0.000272 | 0.010237 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.26 | 0.014628 | 0.235050 | 0.000522 | 0.007365 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.017464 | 0.220788 | 0.000274 | 0.007824 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.060356 | 0.213381 | 0.000234 | 0.007192 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.24 | 0.023270 | 0.204226 | 0.000273 | 0.007920 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.28 | 0.058736 | 0.205214 | 0.000271 | 0.012558 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.063924 | 0.200746 | 0.000273 | 0.010891 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.017968 | 0.219129 | 0.000751 | 0.009185 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.28 | 0.058643 | 0.205433 | 0.000265 | 0.008450 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.25 | 0.026513 | 0.213550 | 0.000551 | 0.008830 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.3 | 0.066022 | 0.218084 | 0.000214 | 0.006957 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.021257 | 0.237702 | 0.000286 | 0.010784 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.061365 | 0.226602 | 0.000228 | 0.008666 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.28 | 0.069425 | 0.198005 | 0.000266 | 0.010406 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.24 | 0.022852 | 0.201259 | 0.000688 | 0.010271 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.29 | 0.068103 | 0.201939 | 0.000268 | 0.009339 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.025459 | 0.198821 | 0.000216 | 0.007450 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.31 | 0.066271 | 0.234856 | 0.000397 | 0.007284 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.31 | 0.058116 | 0.236788 | 0.000234 | 0.007570 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.25 | 0.018894 | 0.216951 | 0.000758 | 0.009741 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.3 | 0.055207 | 0.234402 | 0.000215 | 0.008304 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.053990 | 0.230125 | 0.000770 | 0.007822 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.025572 | 0.223493 | 0.000214 | 0.008400 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.061727 | 0.237574 | 0.000213 | 0.008571 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.26 | 0.017905 | 0.222259 | 0.000279 | 0.011967 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.023174 | 0.232070 | 0.000204 | 0.007198 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.29 | 0.056782 | 0.215270 | 0.000269 | 0.012929 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.25 | 0.027934 | 0.210845 | 0.000211 | 0.008068 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.017722 | 0.237815 | 0.000536 | 0.007540 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.061008 | 0.231362 | 0.000210 | 0.008528 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.24 | 0.024799 | 0.198459 | 0.000271 | 0.007993 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.3 | 0.069926 | 0.212635 | 0.000759 | 0.009344 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.25 | 0.023149 | 0.214146 | 0.000543 | 0.008409 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.26 | 0.053106 | 0.199181 | 0.000212 | 0.007302 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.28 | 0.054531 | 0.215200 | 0.000233 | 0.008335 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.26 | 0.026356 | 0.215320 | 0.000278 | 0.007827 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.3 | 0.060929 | 0.223611 | 0.000771 | 0.008420 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.26 | 0.019502 | 0.216573 | 0.000266 | 0.019096 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.3 | 0.070687 | 0.217062 | 0.000228 | 0.008151 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.25 | 0.021880 | 0.216321 | 0.000268 | 0.008303 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.31 | 0.063742 | 0.224954 | 0.000211 | 0.007615 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.3 | 0.062456 | 0.228042 | 0.000527 | 0.007596 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.31 | 0.068988 | 0.227157 | 0.000181 | 0.006822 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.27 | 0.017916 | 0.244053 | 0.000202 | 0.007775 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.31 | 0.058884 | 0.232205 | 0.000293 | 0.009352 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.24 | 0.020425 | 0.210603 | 0.000215 | 0.007976 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.29 | 0.052140 | 0.214917 | 0.000279 | 0.016869 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.24 | 0.018582 | 0.206461 | 0.000235 | 0.010292 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.31 | 0.072565 | 0.226302 | 0.000537 | 0.007406 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.27 | 0.023400 | 0.238160 | 0.000251 | 0.007922 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.28 | 0.027436 | 0.238482 | 0.000685 | 0.006997 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.31 | 0.065915 | 0.229536 | 0.000203 | 0.008735 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.26 | 0.017787 | 0.225850 | 0.000521 | 0.008043 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.25 | 0.017882 | 0.211037 | 0.000578 | 0.009848 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.28 | 0.074427 | 0.186119 | 0.000209 | 0.006830 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.26 | 0.027041 | 0.215090 | 0.000284 | 0.008390 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.25 | 0.025421 | 0.207194 | 0.000212 | 0.007231 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.27 | 0.061869 | 0.198663 | 0.000205 | 0.006753 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.26 | 0.067195 | 0.182466 | 0.000796 | 0.007777 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.25 | 0.025089 | 0.210024 | 0.000519 | 0.007699 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.26 | 0.063335 | 0.184575 | 0.000207 | 0.011312 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.29 | 0.057700 | 0.217041 | 0.000282 | 0.007959 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.28 | 0.065500 | 0.201393 | 0.000221 | 0.008984 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.28 | 0.062929 | 0.198536 | 0.000198 | 0.010131 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.27 | 0.058166 | 0.198970 | 0.000207 | 0.006494 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.29 | 0.076712 | 0.204675 | 0.000197 | 0.007151 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.25 | 0.027424 | 0.209301 | 0.000210 | 0.008204 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.3 | 0.062423 | 0.218115 | 0.000190 | 0.014598 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.29 | 0.060357 | 0.218196 | 0.000629 | 0.006909 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.29 | 0.060704 | 0.216253 | 0.000274 | 0.008962 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.3 | 0.063189 | 0.227727 | 0.000298 | 0.007529 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.25 | 0.020484 | 0.214677 | 0.000195 | 0.007123 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.25 | 0.016621 | 0.225985 | 0.000194 | 0.007627 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.23 | 0.009756 | 0.211693 | 0.000185 | 0.007070 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.29 | 0.064921 | 0.207387 | 0.000220 | 0.007241 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.3 | 0.064204 | 0.227028 | 0.000189 | 0.008563 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.23 | 0.021899 | 0.197631 | 0.000207 | 0.008342 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.28 | 0.056705 | 0.209924 | 0.000223 | 0.007045 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.26 | 0.017922 | 0.219849 | 0.000280 | 0.008900 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.28 | 0.070469 | 0.201377 | 0.000179 | 0.007034 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.23 | 0.017891 | 0.201384 | 0.000182 | 0.007768 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.29 | 0.056282 | 0.222415 | 0.000197 | 0.007214 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.29 | 0.070017 | 0.203063 | 0.000216 | 0.012983 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.24 | 0.017910 | 0.206335 | 0.000595 | 0.006566 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.26 | 0.060505 | 0.182653 | 0.000195 | 0.007200 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.25 | 0.024354 | 0.214659 | 0.000611 | 0.008783 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.27 | 0.061232 | 0.194746 | 0.000222 | 0.007592 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.25 | 0.022925 | 0.211786 | 0.000201 | 0.008102 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.3 | 0.067104 | 0.223797 | 0.000199 | 0.006818 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.4 | 0.063322 | 0.326102 | 0.000850 | 0.008522 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.37 | 0.027382 | 0.327059 | 0.000929 | 0.011124 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.41 | 0.064364 | 0.327753 | 0.001496 | 0.009566 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.37 | 0.018813 | 0.341178 | 0.001029 | 0.007502 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.4 | 0.056923 | 0.326994 | 0.001432 | 0.010883 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.35 | 0.010564 | 0.325266 | 0.001325 | 0.007524 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.41 | 0.069525 | 0.322872 | 0.000221 | 0.007115 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.35 | 0.143587 | 0.198673 | 0.000211 | 0.006808 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.2 | 0.010938 | 0.172966 | 0.000168 | 0.007277 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.22 | 0.064555 | 0.137442 | 0.000205 | 0.008081 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.17 | 0.057465 | 0.103260 | 0.000209 | 0.006823 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.16 | 0.019860 | 0.121490 | 0.000169 | 0.007499 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |