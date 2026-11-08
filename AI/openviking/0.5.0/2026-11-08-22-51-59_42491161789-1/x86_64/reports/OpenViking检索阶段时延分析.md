# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.067153s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001447 | 2.155% |
| Query Embedding | 生成查询向量 | 0.048618 | 72.399% |
| 向量召回 | 召回语义相似记忆 | 0.009975 | 14.854% |
| 结果处理 | 整理候选并转换返回结构 | 0.000012 | 0.018% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.007101 | 10.574% |
|  |  | 0.067153 | 100.000% |

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

父阶段平均耗时：**0.067153s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001447 | 2.155% |
| Query Embedding | 生成查询向量 | 0.048618 | 72.399% |
| 向量召回 | 召回语义相似记忆 | 0.009975 | 14.854% |
| 结果处理 | 整理候选并转换返回结构 | 0.000012 | 0.018% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.007101 | 10.574% |
| 合计 |  | 0.067153 | 100.000% |

**结论：Query Embedding占72.399%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.001447s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000013 | 0.894% |
| 集合检查 | 检查目标集合与检索器 | 0.001434 | 99.106% |
| 合计 |  | 0.001447 | 100.000% |

**结论：集合检查占99.106%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000012s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000004 | 36.084% |
| 结构转换 | 构造接口返回对象 | 0.000001 | 11.057% |
| 结果处理内部 | 结果处理调度 | 0.000006 | 52.859% |
| 合计 |  | 0.000012 | 100.000% |

**结论：结果处理内部占52.859%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.398341s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.008785 | 2.205% |
| 记忆检索 | 查询相关记忆 | 0.045964 | 11.539% |
| 上下文筛选 | 选择候选记忆 | 0.000032 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.230256 | 57.804% |
| 重排 | 调整候选顺序 | 0.003830 | 0.962% |
| Prompt准备 | 构造回答输入 | 0.085062 | 21.354% |
| 回答LLM | 生成最终回答 | 0.024379 | 6.120% |
| 响应解析 | 解析回答结果 | 0.000033 | 0.008% |
| 合计 |  | 0.398341 | 100.000% |

**结论：记忆读取占57.804%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-08T22:46:07+08:00 |
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
| 检索耗时(s) | 0.067153 | 0.067767 | 0.072371 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_c3685baedf0a4b6ba76072d3c1e41e94 | 39 | 0.039844 | 0.000025 | 0.002522 | 0.014256 | 0.013961 | 0.000005 | 0.000001 |
| 1 | sample_0_qa1 | tm_d41a1c024aa84f4ab5107a8b6a73d16a | 39 | 0.042588 | 0.000011 | 0.000985 | 0.016895 | 0.014515 | 0.000004 | 0.000001 |
| 2 | sample_0_qa2 | tm_76ea04bba6154cb2a5269f978cfeb35b | 39 | 0.040726 | 0.000012 | 0.001679 | 0.018994 | 0.010835 | 0.000005 | 0.000001 |
| 3 | sample_0_qa3 | tm_5e3aacafb3d2442091f49b0ada023564 | 39 | 0.036168 | 0.000011 | 0.000499 | 0.021423 | 0.003654 | 0.000006 | 0.000003 |
| 4 | sample_0_qa4 | tm_d160a45eae6b46b8b8686f43ad6beb6c | 39 | 0.066839 | 0.000016 | 0.002687 | 0.045587 | 0.009731 | 0.000005 | 0.000003 |
| 5 | sample_0_qa5 | tm_1f206070ff6b42f9bc479c31a904597e | 39 | 0.067147 | 0.000011 | 0.001898 | 0.047949 | 0.010558 | 0.000005 | 0.000001 |
| 6 | sample_0_qa6 | tm_b8d0d413b8df428295a3478fcf889402 | 39 | 0.067105 | 0.000012 | 0.000958 | 0.050545 | 0.009586 | 0.000005 | 0.000001 |
| 7 | sample_0_qa7 | tm_23b13102cee54ad4a5900cf6f9234fd7 | 39 | 0.066958 | 0.000011 | 0.000459 | 0.052618 | 0.008919 | 0.000004 | 0.000001 |
| 8 | sample_0_qa8 | tm_2d019b799a56459aa976e11c2d06af8e | 39 | 0.068562 | 0.000024 | 0.002611 | 0.046321 | 0.010468 | 0.000005 | 0.000002 |
| 9 | sample_0_qa9 | tm_e203862844a64460b8469c4f9ec56b4a | 39 | 0.071283 | 0.000011 | 0.001546 | 0.048738 | 0.014109 | 0.000004 | 0.000001 |
| 10 | sample_0_qa10 | tm_58e402011ee54b5aa77d76731b560bca | 39 | 0.066327 | 0.000010 | 0.000908 | 0.050773 | 0.008252 | 0.000005 | 0.000002 |
| 11 | sample_0_qa11 | tm_2b0e1c2a812e486c8f1da3732e411fa2 | 39 | 0.066890 | 0.000010 | 0.000424 | 0.053108 | 0.008183 | 0.000005 | 0.000001 |
| 12 | sample_0_qa12 | tm_76ed91c9ce87407594773abb1bcfc7c1 | 39 | 0.068915 | 0.000019 | 0.002526 | 0.046019 | 0.011163 | 0.000005 | 0.000002 |
| 13 | sample_0_qa13 | tm_22c26f3dbd0f4fc6992d5277bb35f480 | 39 | 0.069456 | 0.000011 | 0.001522 | 0.048340 | 0.012306 | 0.000004 | 0.000001 |
| 14 | sample_0_qa14 | tm_f351a9c957634591a92282b3cb99a10a | 39 | 0.069191 | 0.000011 | 0.000890 | 0.052853 | 0.009509 | 0.000004 | 0.000001 |
| 15 | sample_0_qa15 | tm_624314e83020425e85c33198a7b44759 | 39 | 0.064627 | 0.000010 | 0.000426 | 0.050762 | 0.008409 | 0.000004 | 0.000001 |
| 16 | sample_0_qa16 | tm_27f0acece4c343cfa9cbf84b1e4bb602 | 39 | 0.066453 | 0.000018 | 0.002458 | 0.046039 | 0.009613 | 0.000004 | 0.000002 |
| 17 | sample_0_qa17 | tm_0eedc8507b934bd6b35bcb2665ea1931 | 39 | 0.068726 | 0.000011 | 0.002034 | 0.048366 | 0.011800 | 0.000004 | 0.000001 |
| 18 | sample_0_qa18 | tm_5412a8d0a5e545448cfdbaf2113f93a5 | 39 | 0.068707 | 0.000012 | 0.000956 | 0.052919 | 0.008380 | 0.000004 | 0.000001 |
| 19 | sample_0_qa19 | tm_4d68083e13294681ae362b007f7d7c6b | 39 | 0.064267 | 0.000010 | 0.000509 | 0.050794 | 0.007629 | 0.000004 | 0.000001 |
| 20 | sample_0_qa20 | tm_85f58f51ca4c44939f5ab449b24cd418 | 39 | 0.066283 | 0.000024 | 0.002188 | 0.044858 | 0.010092 | 0.000005 | 0.000002 |
| 21 | sample_0_qa21 | tm_6bc5d22bd04a44db9ae48d6c5c424674 | 39 | 0.067797 | 0.000010 | 0.001737 | 0.045771 | 0.012402 | 0.000006 | 0.000001 |
| 22 | sample_0_qa22 | tm_bd55616a263f444796ee86203bad60ec | 39 | 0.065067 | 0.000011 | 0.001123 | 0.050557 | 0.006090 | 0.000005 | 0.000001 |
| 23 | sample_0_qa23 | tm_4dc01409e5924aba8cb298c071e67675 | 39 | 0.066476 | 0.000013 | 0.000420 | 0.048084 | 0.011461 | 0.000004 | 0.000001 |
| 24 | sample_0_qa24 | tm_005ba34e6f8447a0b7e87db7695765ef | 39 | 0.068203 | 0.000019 | 0.002137 | 0.046133 | 0.010594 | 0.000005 | 0.000002 |
| 25 | sample_0_qa25 | tm_1024a44c67cd4c5299532679af848f38 | 39 | 0.067667 | 0.000011 | 0.001679 | 0.048463 | 0.010727 | 0.000005 | 0.000001 |
| 26 | sample_0_qa26 | tm_74ca22a45f0248318b01e5b50b471b38 | 39 | 0.069454 | 0.000011 | 0.001071 | 0.053246 | 0.009175 | 0.000005 | 0.000001 |
| 27 | sample_0_qa27 | tm_57c4ffd2a00c41ebada76c135352f8d5 | 39 | 0.066589 | 0.000011 | 0.000385 | 0.051155 | 0.009813 | 0.000005 | 0.000001 |
| 28 | sample_0_qa28 | tm_95344ca97165424ab508eb7022d69518 | 39 | 0.067686 | 0.000019 | 0.002385 | 0.046119 | 0.010086 | 0.000005 | 0.000003 |
| 29 | sample_0_qa29 | tm_eb1709f80b6248a6addbc7ae830be0a6 | 39 | 0.067427 | 0.000012 | 0.001767 | 0.047053 | 0.010189 | 0.000004 | 0.000001 |
| 30 | sample_0_qa30 | tm_f4b5d6f7cde1478fbabc4c7bedbc7e0d | 39 | 0.068811 | 0.000011 | 0.001161 | 0.049105 | 0.011280 | 0.000004 | 0.000001 |
| 31 | sample_0_qa31 | tm_7eb3823cbf4143d8bc2a009ea7a589fc | 39 | 0.065903 | 0.000010 | 0.000681 | 0.051403 | 0.007544 | 0.000005 | 0.000001 |
| 32 | sample_0_qa32 | tm_7099f1d5d9bc4aa98b973f6fd55c6f05 | 39 | 0.071094 | 0.000018 | 0.002584 | 0.046542 | 0.014467 | 0.000004 | 0.000001 |
| 33 | sample_0_qa33 | tm_fa339409c6e64e7db41d43c873f319ce | 39 | 0.067999 | 0.000011 | 0.001559 | 0.048750 | 0.010104 | 0.000004 | 0.000001 |
| 34 | sample_0_qa34 | tm_2fdc2cf0f4c843299b89c57ce9e8efb8 | 39 | 0.064683 | 0.000011 | 0.000889 | 0.050802 | 0.006182 | 0.000005 | 0.000002 |
| 35 | sample_0_qa35 | tm_b6e3acc421bb4c02b6196f9e4ac31538 | 39 | 0.068371 | 0.000010 | 0.000417 | 0.053487 | 0.009038 | 0.000004 | 0.000001 |
| 36 | sample_0_qa36 | tm_c8caebc1504c43d59d2a030a4a4707e6 | 39 | 0.071876 | 0.000019 | 0.002436 | 0.046041 | 0.015264 | 0.000010 | 0.000001 |
| 37 | sample_0_qa37 | tm_bde7371a366a4040856a54b04f22889b | 39 | 0.066833 | 0.000010 | 0.001980 | 0.048394 | 0.008462 | 0.000005 | 0.000003 |
| 38 | sample_0_qa38 | tm_cebc3e440fce443eab0ce0db1ff0c3ec | 39 | 0.069962 | 0.000012 | 0.000886 | 0.053221 | 0.009468 | 0.000004 | 0.000001 |
| 39 | sample_0_qa39 | tm_bbdc63e0b14a4dcc8d9c428bd507d51b | 39 | 0.065180 | 0.000010 | 0.000424 | 0.050889 | 0.008334 | 0.000004 | 0.000001 |
| 40 | sample_0_qa40 | tm_743c8849764a44918c835e53ab2b78c6 | 39 | 0.066994 | 0.000018 | 0.002582 | 0.046762 | 0.009551 | 0.000005 | 0.000002 |
| 41 | sample_0_qa41 | tm_06de109b9db44c4fb9d0330edc7cecde | 39 | 0.069741 | 0.000011 | 0.001555 | 0.048813 | 0.012399 | 0.000004 | 0.000001 |
| 42 | sample_0_qa42 | tm_eb1de23e5ced491cb849107237dc1535 | 39 | 0.066653 | 0.000010 | 0.000915 | 0.051310 | 0.008297 | 0.000004 | 0.000002 |
| 43 | sample_0_qa43 | tm_f24711da70374deb891c1cc7399375d2 | 39 | 0.068211 | 0.000010 | 0.000449 | 0.053381 | 0.009244 | 0.000004 | 0.000001 |
| 44 | sample_0_qa44 | tm_2af17c361b7049c9944de0b7fd93f6b3 | 39 | 0.073714 | 0.000020 | 0.002649 | 0.046354 | 0.015964 | 0.000004 | 0.000001 |
| 45 | sample_0_qa45 | tm_42b1ca4aa0684b88973367c07fb7771c | 39 | 0.066232 | 0.000011 | 0.001643 | 0.048791 | 0.007620 | 0.000004 | 0.000003 |
| 46 | sample_0_qa46 | tm_d1b7df1c854d4e55952fe603e3d5b724 | 39 | 0.067949 | 0.000011 | 0.001015 | 0.050864 | 0.010015 | 0.000004 | 0.000001 |
| 47 | sample_0_qa47 | tm_9471df458b3a4dfebc30f6e0efaac829 | 39 | 0.065032 | 0.000010 | 0.000444 | 0.053560 | 0.005881 | 0.000004 | 0.000001 |
| 48 | sample_0_qa48 | tm_cf2d9b808ff142708df679d051e1f51e | 39 | 0.070933 | 0.000019 | 0.002177 | 0.046328 | 0.014505 | 0.000005 | 0.000001 |
| 49 | sample_0_qa49 | tm_cd4e68b612a84c67a518498b17a46074 | 39 | 0.067738 | 0.000011 | 0.001723 | 0.048782 | 0.010550 | 0.000004 | 0.000001 |
| 50 | sample_0_qa50 | tm_81602b386c2a4f85bbb9f1b2573673bf | 39 | 0.064100 | 0.000011 | 0.001097 | 0.050899 | 0.005391 | 0.000005 | 0.000002 |
| 51 | sample_0_qa51 | tm_0c3a1df7e31c4987bedfb4808a1259de | 39 | 0.067854 | 0.000010 | 0.000376 | 0.053684 | 0.008548 | 0.000004 | 0.000001 |
| 52 | sample_0_qa52 | tm_1f6aaa10d1794bf797e8bb384b6d7cf7 | 39 | 0.072290 | 0.000018 | 0.002404 | 0.046161 | 0.015339 | 0.000005 | 0.000001 |
| 53 | sample_0_qa53 | tm_9728b864eb79481d9284fce2cdccbe98 | 39 | 0.068713 | 0.000011 | 0.001952 | 0.048632 | 0.011457 | 0.000004 | 0.000001 |
| 54 | sample_0_qa54 | tm_67e0227e47f44cef9098bb1db8960806 | 39 | 0.063706 | 0.000011 | 0.001157 | 0.050460 | 0.004892 | 0.000005 | 0.000003 |
| 55 | sample_0_qa55 | tm_266d098915d84d2db2f8cf537c6ceff0 | 39 | 0.064468 | 0.000011 | 0.000461 | 0.052826 | 0.005575 | 0.000004 | 0.000001 |
| 56 | sample_0_qa56 | tm_e99d869d3b6a4b9fae9bfd64d3aca845 | 39 | 0.066684 | 0.000019 | 0.002174 | 0.046049 | 0.009676 | 0.000004 | 0.000002 |
| 57 | sample_0_qa57 | tm_9e2f51133bf24cb98de4eb4fbf4e26be | 39 | 0.068895 | 0.000010 | 0.001734 | 0.048231 | 0.012004 | 0.000004 | 0.000001 |
| 58 | sample_0_qa58 | tm_1cb786cc353845879c78ffd125cc5e33 | 39 | 0.066005 | 0.000011 | 0.001126 | 0.050298 | 0.008417 | 0.000004 | 0.000001 |
| 59 | sample_0_qa59 | tm_a45bb6f7d7634a329029f08d7a9eccc2 | 39 | 0.067628 | 0.000011 | 0.000434 | 0.052653 | 0.009077 | 0.000004 | 0.000001 |
| 60 | sample_0_qa60 | tm_bc59afc87c1f424db76fd3309998e853 | 39 | 0.068722 | 0.000018 | 0.002606 | 0.046402 | 0.010132 | 0.000005 | 0.000002 |
| 61 | sample_0_qa61 | tm_82931572816a49cdafc49efede4a027c | 39 | 0.068246 | 0.000011 | 0.001847 | 0.048823 | 0.010909 | 0.000004 | 0.000001 |
| 62 | sample_0_qa62 | tm_b91506728bc74adf93d857bc71a8a2a4 | 39 | 0.069496 | 0.000012 | 0.000950 | 0.050895 | 0.011685 | 0.000004 | 0.000001 |
| 63 | sample_0_qa63 | tm_ca2dd15d537a4e1f919aeaed41513311 | 39 | 0.066646 | 0.000010 | 0.000468 | 0.053540 | 0.007640 | 0.000004 | 0.000001 |
| 64 | sample_0_qa64 | tm_a562336d0ae74383867dc5d013bbfccb | 39 | 0.066318 | 0.000019 | 0.002217 | 0.045913 | 0.009232 | 0.000004 | 0.000002 |
| 65 | sample_0_qa65 | tm_a54a86f5ba574c11a83475b91936fb57 | 39 | 0.066994 | 0.000011 | 0.001766 | 0.048295 | 0.009363 | 0.000004 | 0.000001 |
| 66 | sample_0_qa66 | tm_4c4854cc7ecc460cb6065ea62b5d57a7 | 39 | 0.069133 | 0.000011 | 0.001148 | 0.053039 | 0.008875 | 0.000004 | 0.000001 |
| 67 | sample_0_qa67 | tm_4f4cbee384644e6f99af4fb7a33c148b | 39 | 0.066254 | 0.000011 | 0.000581 | 0.050268 | 0.009422 | 0.000004 | 0.000001 |
| 68 | sample_0_qa68 | tm_d686046d896347db87190616851483ae | 39 | 0.072602 | 0.000018 | 0.002520 | 0.046445 | 0.014497 | 0.000004 | 0.000001 |
| 69 | sample_0_qa69 | tm_8308814009c04c26a0187312e854a953 | 39 | 0.068088 | 0.000011 | 0.001584 | 0.048842 | 0.010336 | 0.000004 | 0.000001 |
| 70 | sample_0_qa70 | tm_5f6c40843d2f434ba8eec75693fb5eb6 | 39 | 0.069172 | 0.000011 | 0.000903 | 0.053526 | 0.008795 | 0.000004 | 0.000001 |
| 71 | sample_0_qa71 | tm_bfb9a9a8aa7c4cf8b8b00b4ce9584d99 | 39 | 0.062999 | 0.000010 | 0.000427 | 0.051377 | 0.005229 | 0.000005 | 0.000003 |
| 72 | sample_0_qa72 | tm_d0c909a800f548e8aebbaaea6a73fbb4 | 39 | 0.071739 | 0.000020 | 0.002591 | 0.046450 | 0.015054 | 0.000004 | 0.000001 |
| 73 | sample_0_qa73 | tm_e4a322b0cafd4d1ba6c116000d6b273a | 39 | 0.068753 | 0.000011 | 0.001547 | 0.048708 | 0.011035 | 0.000004 | 0.000002 |
| 74 | sample_0_qa74 | tm_4e2d81736e204ffaa8d6675a8f802082 | 39 | 0.063691 | 0.000011 | 0.000968 | 0.050739 | 0.005240 | 0.000004 | 0.000002 |
| 75 | sample_0_qa75 | tm_4a1a1cc8ec714a0687aa6208edb5f0e7 | 39 | 0.068742 | 0.000010 | 0.000519 | 0.053389 | 0.009493 | 0.000004 | 0.000001 |
| 76 | sample_0_qa76 | tm_4f556ecf871a421a87cf82e3f4930243 | 39 | 0.067678 | 0.000019 | 0.002636 | 0.045750 | 0.009493 | 0.000005 | 0.000002 |
| 77 | sample_0_qa77 | tm_e81463df53884811af06af61255b6fe6 | 39 | 0.068592 | 0.000012 | 0.001684 | 0.047863 | 0.012021 | 0.000004 | 0.000001 |
| 78 | sample_0_qa78 | tm_e73f3b27e4c64860841bc46e4b3b09cf | 39 | 0.068726 | 0.000011 | 0.000888 | 0.050652 | 0.010660 | 0.000004 | 0.000001 |
| 79 | sample_0_qa79 | tm_95ac300f4b184d9b855ca6ead72fbc4e | 39 | 0.064124 | 0.000010 | 0.000427 | 0.052729 | 0.005628 | 0.000004 | 0.000001 |
| 80 | sample_0_qa80 | tm_75f90638c8b24f10938fb379246b16ef | 39 | 0.069566 | 0.000018 | 0.002575 | 0.048755 | 0.008846 | 0.000005 | 0.000002 |
| 81 | sample_0_qa81 | tm_75658243d0dd40acb81867845a171511 | 39 | 0.068195 | 0.000011 | 0.001748 | 0.046575 | 0.013198 | 0.000004 | 0.000001 |
| 82 | sample_0_qa82 | tm_9a57eff71f14458192b53611be36f5c8 | 39 | 0.068245 | 0.000010 | 0.001274 | 0.051002 | 0.010003 | 0.000004 | 0.000001 |
| 83 | sample_0_qa83 | tm_ce2a7e25f07f4f739ec2481e5e3b3b0e | 39 | 0.068455 | 0.000011 | 0.000447 | 0.053098 | 0.009638 | 0.000004 | 0.000001 |
| 84 | sample_0_qa84 | tm_799d7a17a71348578cd1663383d3071a | 39 | 0.067159 | 0.000018 | 0.002449 | 0.045831 | 0.010332 | 0.000005 | 0.000002 |
| 85 | sample_0_qa85 | tm_98d1a744a127472aa8035ada919196e6 | 39 | 0.069768 | 0.000011 | 0.002031 | 0.048169 | 0.012852 | 0.000004 | 0.000001 |
| 86 | sample_0_qa86 | tm_32c0ccbf5164444bb05bb67bf56da7b7 | 39 | 0.066903 | 0.000011 | 0.000917 | 0.053085 | 0.006372 | 0.000004 | 0.000001 |
| 87 | sample_0_qa87 | tm_dc1d64c97528463fae53739fa26c7261 | 39 | 0.068021 | 0.000010 | 0.000456 | 0.050739 | 0.011467 | 0.000004 | 0.000001 |
| 88 | sample_0_qa88 | tm_6c02f11d5c4d434aba87bb6885af9331 | 39 | 0.067722 | 0.000019 | 0.002236 | 0.046487 | 0.009777 | 0.000005 | 0.000002 |
| 89 | sample_0_qa89 | tm_9c92eac08fa042b5924f33d25a065a88 | 39 | 0.068216 | 0.000011 | 0.001781 | 0.048912 | 0.010670 | 0.000005 | 0.000001 |
| 90 | sample_0_qa90 | tm_cc9be04e76d4410781620dd5f8235370 | 39 | 0.068222 | 0.000011 | 0.001150 | 0.051069 | 0.010015 | 0.000004 | 0.000001 |
| 91 | sample_0_qa91 | tm_41124a047b2748b1b9bfe00856da9070 | 39 | 0.068379 | 0.000010 | 0.000400 | 0.053764 | 0.008872 | 0.000004 | 0.000001 |
| 92 | sample_0_qa92 | tm_3e3edeb68d104d31b6f6f59c05f24848 | 39 | 0.072550 | 0.000020 | 0.002672 | 0.046147 | 0.014915 | 0.000004 | 0.000001 |
| 93 | sample_0_qa93 | tm_14db14a07a65406cb8eae4b9be050a53 | 39 | 0.068194 | 0.000013 | 0.001737 | 0.048586 | 0.010937 | 0.000005 | 0.000001 |
| 94 | sample_0_qa94 | tm_52f0672318794f3182e83349a684186a | 39 | 0.069609 | 0.000011 | 0.000937 | 0.050644 | 0.011765 | 0.000004 | 0.000001 |
| 95 | sample_0_qa95 | tm_52ff9157de234b0db6c72c626a78dde2 | 39 | 0.063439 | 0.000010 | 0.000479 | 0.053280 | 0.002940 | 0.000004 | 0.000003 |
| 96 | sample_0_qa96 | tm_4bb75753eb634040aabee8c4b046a658 | 39 | 0.066655 | 0.000018 | 0.002161 | 0.045757 | 0.010255 | 0.000005 | 0.000002 |
| 97 | sample_0_qa97 | tm_996306eb49e4493e909fcee80a1e76ff | 39 | 0.069784 | 0.000010 | 0.001702 | 0.048228 | 0.012834 | 0.000005 | 0.000001 |
| 98 | sample_0_qa98 | tm_6700da0d69384fbfa4a3cc9c64d8b6f5 | 39 | 0.065878 | 0.000010 | 0.001116 | 0.050282 | 0.007999 | 0.000005 | 0.000001 |
| 99 | sample_0_qa99 | tm_dbbea9937fce44e295d6a2839f6a6edb | 39 | 0.068667 | 0.000011 | 0.000380 | 0.053106 | 0.009674 | 0.000004 | 0.000001 |
| 100 | sample_0_qa100 | tm_c3eb5557800c414f81ee42a4bfda0d3d | 39 | 0.072723 | 0.000018 | 0.002593 | 0.046433 | 0.014480 | 0.000004 | 0.000001 |
| 101 | sample_0_qa101 | tm_4d18cbd83c3d44738a6d239e08d72011 | 39 | 0.065920 | 0.000010 | 0.002035 | 0.048881 | 0.006900 | 0.000005 | 0.000002 |
| 102 | sample_0_qa102 | tm_5ce03cc212614f85b2ccc90f33bf3310 | 39 | 0.066438 | 0.000011 | 0.000879 | 0.050724 | 0.008346 | 0.000004 | 0.000001 |
| 103 | sample_0_qa103 | tm_2d7f79e3dd2441559637497c281dc06b | 39 | 0.067638 | 0.000010 | 0.000474 | 0.053407 | 0.008672 | 0.000004 | 0.000001 |
| 104 | sample_0_qa104 | tm_bf35251af4ef420e9612862c1e7b8d38 | 39 | 0.071591 | 0.000018 | 0.002838 | 0.045481 | 0.014698 | 0.000005 | 0.000001 |
| 105 | sample_0_qa105 | tm_0b3c0a6de43449889807b24568b84007 | 39 | 0.067172 | 0.000012 | 0.001794 | 0.046369 | 0.010785 | 0.000005 | 0.000002 |
| 106 | sample_0_qa106 | tm_7a0c1806f6e14a1a9a2488df0affa83c | 39 | 0.062649 | 0.000010 | 0.001342 | 0.049098 | 0.004618 | 0.000005 | 0.000002 |
| 107 | sample_0_qa107 | tm_caab4bb2262b41539f39e845404e3641 | 39 | 0.067375 | 0.000011 | 0.000496 | 0.051175 | 0.009071 | 0.000004 | 0.000001 |
| 108 | sample_0_qa108 | tm_b1ad16f773d64574b1b1a170e988fb3a | 39 | 0.072794 | 0.000019 | 0.002517 | 0.045943 | 0.015222 | 0.000004 | 0.000001 |
| 109 | sample_0_qa109 | tm_2c6141670aef4b0c98a281b249397192 | 39 | 0.066133 | 0.000011 | 0.001716 | 0.048040 | 0.008024 | 0.000005 | 0.000002 |
| 110 | sample_0_qa110 | tm_e3950326eef24812a42af6be4ea5eb1a | 39 | 0.066904 | 0.000011 | 0.001080 | 0.050762 | 0.008619 | 0.000005 | 0.000001 |
| 111 | sample_0_qa111 | tm_96c1009c490a48268accb1ef8b3cf3a4 | 39 | 0.068062 | 0.000010 | 0.000665 | 0.052352 | 0.009468 | 0.000004 | 0.000001 |
| 112 | sample_0_qa112 | tm_1cef043412314c2aa097b59842828bdf | 39 | 0.071627 | 0.000020 | 0.002206 | 0.048773 | 0.012182 | 0.000004 | 0.000001 |
| 113 | sample_0_qa113 | tm_704661415a35406bac265df8b137ef17 | 39 | 0.064823 | 0.000010 | 0.001754 | 0.046631 | 0.009313 | 0.000004 | 0.000003 |
| 114 | sample_0_qa114 | tm_56c1e09d59d2476a9db1c0fc30e06ae1 | 39 | 0.066442 | 0.000010 | 0.001146 | 0.051227 | 0.007981 | 0.000005 | 0.000001 |
| 115 | sample_0_qa115 | tm_2923fb409c6a403987445e230ab35fd2 | 39 | 0.068060 | 0.000011 | 0.000386 | 0.053307 | 0.009046 | 0.000004 | 0.000001 |
| 116 | sample_0_qa116 | tm_1e9ec2cfb3584709987371c2149bdc6b | 39 | 0.074635 | 0.000018 | 0.002652 | 0.046765 | 0.016484 | 0.000004 | 0.000002 |
| 117 | sample_0_qa117 | tm_958fd4eaabc648d68a2bb0729dc872c9 | 39 | 0.067055 | 0.000011 | 0.001539 | 0.048839 | 0.008965 | 0.000004 | 0.000002 |
| 118 | sample_0_qa118 | tm_d00e5cc5cdcc4e789cba7ec83e1912b5 | 39 | 0.068288 | 0.000011 | 0.000903 | 0.051407 | 0.010041 | 0.000004 | 0.000001 |
| 119 | sample_0_qa119 | tm_240daab7d5184e978c5408b1cbacaf15 | 39 | 0.065432 | 0.000010 | 0.000426 | 0.053772 | 0.006143 | 0.000004 | 0.000001 |
| 120 | sample_0_qa120 | tm_91a78167c9734f60a16b8e00581f2dac | 39 | 0.069969 | 0.000022 | 0.002407 | 0.045925 | 0.013892 | 0.000004 | 0.000001 |
| 121 | sample_0_qa121 | tm_4a03ca007ac3441ab9553814a6ebb6f7 | 39 | 0.065902 | 0.000011 | 0.001941 | 0.048263 | 0.008191 | 0.000005 | 0.000002 |
| 122 | sample_0_qa122 | tm_6f569b7e183c48e19af2b8f3aa0d5ff4 | 39 | 0.069978 | 0.000012 | 0.000862 | 0.051025 | 0.011772 | 0.000004 | 0.000001 |
| 123 | sample_0_qa123 | tm_6f0dc787521f4476a36b38a714e1e182 | 39 | 0.066773 | 0.000010 | 0.000396 | 0.053408 | 0.007895 | 0.000004 | 0.000001 |
| 124 | sample_0_qa124 | tm_64f8aa4aad8949faa83eccceb5115fd0 | 39 | 0.070236 | 0.000019 | 0.002601 | 0.046194 | 0.012088 | 0.000004 | 0.000001 |
| 125 | sample_0_qa125 | tm_1aca6d1ff62047f89f9f13e44212c0e5 | 39 | 0.064731 | 0.000011 | 0.001779 | 0.048637 | 0.007107 | 0.000005 | 0.000002 |
| 126 | sample_0_qa126 | tm_374bab3334bf43188ba74d9a0a53c832 | 39 | 0.069977 | 0.000011 | 0.001116 | 0.050707 | 0.012019 | 0.000004 | 0.000001 |
| 127 | sample_0_qa127 | tm_c3f97b698131497292b5a12b2e08eb9b | 39 | 0.066857 | 0.000011 | 0.000396 | 0.053505 | 0.007337 | 0.000004 | 0.000001 |
| 128 | sample_0_qa128 | tm_91545c9089804702878ef0772fffbe68 | 39 | 0.072470 | 0.000019 | 0.002667 | 0.046612 | 0.013595 | 0.000005 | 0.000001 |
| 129 | sample_0_qa129 | tm_d6052dfdff0942ceb569ce0ef8922f95 | 39 | 0.071134 | 0.000011 | 0.001730 | 0.048803 | 0.012608 | 0.000004 | 0.000001 |
| 130 | sample_0_qa130 | tm_c1db7732f8484ff58698661c0d2e6f9d | 39 | 0.064516 | 0.000011 | 0.000906 | 0.050858 | 0.005412 | 0.000004 | 0.000002 |
| 131 | sample_0_qa131 | tm_8ea8540a701e4b1890207ba1b4352eb5 | 39 | 0.068795 | 0.000011 | 0.000477 | 0.053184 | 0.009594 | 0.000004 | 0.000001 |
| 132 | sample_0_qa132 | tm_ffbfab37476c438490e1128e9c2c1eda | 39 | 0.069358 | 0.000019 | 0.002845 | 0.045769 | 0.011234 | 0.000005 | 0.000002 |
| 133 | sample_0_qa133 | tm_c8321889ef3e403a8eac65a19b20c39e | 39 | 0.067806 | 0.000012 | 0.001803 | 0.046534 | 0.011122 | 0.000004 | 0.000001 |
| 134 | sample_0_qa134 | tm_2efb27af8cff4515b311bdbfd46d91f7 | 39 | 0.069552 | 0.000011 | 0.001157 | 0.049261 | 0.011621 | 0.000004 | 0.000001 |
| 135 | sample_0_qa135 | tm_dc569c5bc5af4d4f9387323d927b2961 | 39 | 0.066409 | 0.000010 | 0.000701 | 0.051344 | 0.007787 | 0.000004 | 0.000001 |
| 136 | sample_0_qa136 | tm_dc12ab4b90ee4217b7c4703df6746fb7 | 39 | 0.065211 | 0.000019 | 0.002385 | 0.045587 | 0.009052 | 0.000005 | 0.000002 |
| 137 | sample_0_qa137 | tm_7b2ff2bb1dbb409cbcc972940a4f082b | 39 | 0.070422 | 0.000013 | 0.001949 | 0.047676 | 0.013781 | 0.000004 | 0.000001 |
| 138 | sample_0_qa138 | tm_6be6bb5e999b47e28bf1c2dcace133ec | 39 | 0.065686 | 0.000011 | 0.001073 | 0.050355 | 0.006735 | 0.000005 | 0.000001 |
| 139 | sample_0_qa139 | tm_a51d0a6c163147fdb71b1abba1325c02 | 39 | 0.065815 | 0.000011 | 0.000601 | 0.052025 | 0.007460 | 0.000004 | 0.000001 |
| 140 | sample_0_qa140 | tm_8d3b3a1fdb694fc68f73d530ad626f5a | 39 | 0.072548 | 0.000019 | 0.002619 | 0.045473 | 0.015131 | 0.000004 | 0.000001 |
| 141 | sample_0_qa141 | tm_ecc97e2ffb4f47968516127c409030fd | 39 | 0.064956 | 0.000011 | 0.001583 | 0.046501 | 0.007655 | 0.000005 | 0.000002 |
| 142 | sample_0_qa142 | tm_10cb9a5ad7d6414e8d88f725073ad1f1 | 39 | 0.065942 | 0.000013 | 0.000932 | 0.049190 | 0.008427 | 0.000004 | 0.000001 |
| 143 | sample_0_qa143 | tm_292c357c0b2f4d0495b98bc30d04d34e | 39 | 0.067360 | 0.000010 | 0.000444 | 0.051268 | 0.009295 | 0.000004 | 0.000001 |
| 144 | sample_0_qa144 | tm_622c411ebdff489d9ba41f1f868c6776 | 39 | 0.069805 | 0.000019 | 0.002861 | 0.046535 | 0.010911 | 0.000005 | 0.000002 |
| 145 | sample_0_qa145 | tm_357dc10615574c7aaa82dc159b510309 | 39 | 0.068631 | 0.000012 | 0.001744 | 0.048930 | 0.011022 | 0.000004 | 0.000001 |
| 146 | sample_0_qa146 | tm_f087a54e5c994b41a7c44526fa7e4392 | 39 | 0.068937 | 0.000011 | 0.001092 | 0.051064 | 0.010657 | 0.000004 | 0.000002 |
| 147 | sample_0_qa147 | tm_6d2941daec61416d9a7a434b7ebe6809 | 39 | 0.068955 | 0.000011 | 0.000620 | 0.053416 | 0.009748 | 0.000004 | 0.000001 |
| 148 | sample_0_qa148 | tm_2866981b9c5a4f3580426c3fb08b6de0 | 39 | 0.070237 | 0.000018 | 0.002558 | 0.045618 | 0.014369 | 0.000004 | 0.000001 |
| 149 | sample_0_qa149 | tm_7d3833de312341d5ba07befe376727c3 | 39 | 0.065867 | 0.000012 | 0.001559 | 0.047969 | 0.008323 | 0.000005 | 0.000002 |
| 150 | sample_0_qa150 | tm_2fc3a6daa38a418586ae894a61785f40 | 39 | 0.065517 | 0.000010 | 0.000896 | 0.050753 | 0.007702 | 0.000004 | 0.000001 |
| 151 | sample_0_qa151 | tm_81445d5b10694f56be9980b79cc7388a | 39 | 0.067134 | 0.000010 | 0.000429 | 0.052839 | 0.008693 | 0.000004 | 0.000001 |

问答端到端平均耗时：0.398355s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.28 | 0.019895 | 0.223757 | 1.609585 | 0.309825 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.28 | 0.029203 | 0.189371 | 1.610319 | 0.309516 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.28 | 0.017955 | 0.226310 | 1.610633 | 0.309301 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.27 | 0.081344 | 0.177342 | 1.611753 | 0.307129 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.27 | 0.038686 | 0.191059 | 1.610950 | 0.308105 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.27 | 0.068955 | 0.180879 | 1.611276 | 0.308563 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.27 | 0.070033 | 0.180135 | 1.611596 | 0.307342 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.27 | 0.030249 | 0.190999 | 1.609998 | 0.310383 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.57 | 0.011759 | 0.543801 | 0.000177 | 0.007336 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.6 | 0.043345 | 0.519982 | 0.000191 | 0.010743 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.61 | 0.041263 | 0.527029 | 0.000145 | 0.010940 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.64 | 0.063704 | 0.539980 | 0.000168 | 0.007921 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.65 | 0.077713 | 0.535025 | 0.000149 | 0.008239 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.61 | 0.038292 | 0.525806 | 0.000151 | 0.013182 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.61 | 0.044087 | 0.524302 | 0.000136 | 0.009245 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.65 | 0.083214 | 0.530587 | 0.000211 | 0.009606 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.027502 | 0.203195 | 0.000387 | 0.006701 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.062652 | 0.193032 | 0.000428 | 0.006618 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.26 | 0.036592 | 0.192142 | 0.000475 | 0.009637 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.25 | 0.030328 | 0.200324 | 0.000436 | 0.006346 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.029494 | 0.203357 | 0.000439 | 0.009290 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.086543 | 0.216242 | 0.000456 | 0.007611 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.3 | 0.079387 | 0.206624 | 0.000181 | 0.006824 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.31 | 0.075982 | 0.213993 | 0.000139 | 0.007843 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.25 | 0.021863 | 0.215920 | 0.000202 | 0.006723 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.011462 | 0.219332 | 0.000521 | 0.006865 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.31 | 0.065703 | 0.224992 | 0.000448 | 0.007371 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.25 | 0.029931 | 0.203710 | 0.000486 | 0.007106 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.064981 | 0.206398 | 0.000221 | 0.006955 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.062680 | 0.222927 | 0.000213 | 0.010673 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.29 | 0.062408 | 0.210776 | 0.000472 | 0.010527 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.021793 | 0.226220 | 0.000201 | 0.007192 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.24 | 0.022715 | 0.205399 | 0.000201 | 0.007484 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.021870 | 0.211619 | 0.000204 | 0.007381 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.28 | 0.068587 | 0.197348 | 0.000268 | 0.009134 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.022765 | 0.206054 | 0.000245 | 0.010239 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.075946 | 0.188302 | 0.000236 | 0.010013 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.22 | 0.018915 | 0.193848 | 0.000226 | 0.007552 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.29 | 0.064042 | 0.214700 | 0.000484 | 0.007040 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.28 | 0.062984 | 0.199381 | 0.000541 | 0.008185 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.29 | 0.065510 | 0.212092 | 0.000221 | 0.006797 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.056941 | 0.230418 | 0.000508 | 0.007953 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.27 | 0.058925 | 0.197453 | 0.000271 | 0.007897 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.23 | 0.014297 | 0.197780 | 0.000205 | 0.007016 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.28 | 0.058338 | 0.206149 | 0.000247 | 0.008770 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.025540 | 0.223260 | 0.000236 | 0.011108 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.27 | 0.057639 | 0.199579 | 0.000172 | 0.009164 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.26 | 0.026117 | 0.219325 | 0.000486 | 0.009445 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.32 | 0.071849 | 0.234504 | 0.000160 | 0.007662 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.31 | 0.076278 | 0.227276 | 0.000175 | 0.006273 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.25 | 0.023012 | 0.212348 | 0.000190 | 0.007705 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.29 | 0.061811 | 0.214901 | 0.000284 | 0.012355 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.26 | 0.029408 | 0.217581 | 0.001018 | 0.007743 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.064454 | 0.232359 | 0.000226 | 0.007285 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.057150 | 0.213530 | 0.000169 | 0.009091 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.28 | 0.027726 | 0.234788 | 0.000211 | 0.010420 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.26 | 0.020879 | 0.223253 | 0.000191 | 0.008324 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.059939 | 0.230049 | 0.000219 | 0.009072 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.070913 | 0.222130 | 0.000213 | 0.009965 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.27 | 0.022802 | 0.236002 | 0.000323 | 0.008913 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.31 | 0.070005 | 0.218334 | 0.000269 | 0.012580 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.26 | 0.028990 | 0.218472 | 0.000254 | 0.007743 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.056022 | 0.214317 | 0.000171 | 0.006574 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.026558 | 0.217628 | 0.000484 | 0.008612 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.28 | 0.057052 | 0.209458 | 0.000200 | 0.007046 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.3 | 0.072145 | 0.211174 | 0.000220 | 0.009895 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.26 | 0.029314 | 0.215337 | 0.000273 | 0.009647 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.077120 | 0.198051 | 0.000202 | 0.016460 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.3 | 0.058204 | 0.229947 | 0.000338 | 0.007536 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.25 | 0.022663 | 0.218935 | 0.000224 | 0.008212 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.27 | 0.027995 | 0.225297 | 0.000339 | 0.007297 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.3 | 0.064538 | 0.223327 | 0.000200 | 0.008144 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.060803 | 0.226797 | 0.000188 | 0.006976 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.053077 | 0.191793 | 0.000218 | 0.007806 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.027427 | 0.214409 | 0.000270 | 0.009233 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.27 | 0.066113 | 0.190877 | 0.000221 | 0.011919 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.025973 | 0.213535 | 0.000281 | 0.009082 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.28 | 0.060315 | 0.210583 | 0.000198 | 0.007243 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.3 | 0.062720 | 0.227607 | 0.000207 | 0.007455 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.071571 | 0.237460 | 0.000204 | 0.009786 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.067389 | 0.223255 | 0.000199 | 0.008616 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.25 | 0.010659 | 0.230785 | 0.000274 | 0.007529 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.33 | 0.075591 | 0.229127 | 0.000270 | 0.012182 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.25 | 0.010041 | 0.222845 | 0.000276 | 0.010854 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.33 | 0.081942 | 0.227605 | 0.000510 | 0.007885 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.25 | 0.026078 | 0.207950 | 0.000222 | 0.006977 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.31 | 0.058141 | 0.238938 | 0.000205 | 0.007527 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.28 | 0.062267 | 0.210043 | 0.000197 | 0.006537 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.23 | 0.009833 | 0.208008 | 0.000214 | 0.007121 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.29 | 0.074452 | 0.198780 | 0.000196 | 0.007414 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.25 | 0.017827 | 0.218069 | 0.000277 | 0.010603 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.28 | 0.073433 | 0.198575 | 0.000755 | 0.007716 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.25 | 0.020464 | 0.217002 | 0.000220 | 0.006883 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.31 | 0.068267 | 0.228570 | 0.000503 | 0.006556 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.28 | 0.064286 | 0.206376 | 0.000209 | 0.008906 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.26 | 0.035821 | 0.208490 | 0.000237 | 0.008067 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.3 | 0.076058 | 0.205124 | 0.000190 | 0.009932 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.24 | 0.023847 | 0.202484 | 0.000194 | 0.008233 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.32 | 0.076581 | 0.219487 | 0.000282 | 0.010704 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.24 | 0.022727 | 0.201843 | 0.000212 | 0.006667 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.32 | 0.075013 | 0.233129 | 0.000769 | 0.008899 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.29 | 0.059014 | 0.223509 | 0.000236 | 0.006917 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.29 | 0.056213 | 0.224354 | 0.000199 | 0.006622 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.26 | 0.021395 | 0.224249 | 0.000241 | 0.008159 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.29 | 0.058134 | 0.211936 | 0.001009 | 0.009703 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.26 | 0.021662 | 0.221881 | 0.000259 | 0.008641 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.31 | 0.069122 | 0.221792 | 0.000207 | 0.011715 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.28 | 0.018332 | 0.243001 | 0.000762 | 0.008782 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.26 | 0.021020 | 0.225337 | 0.000262 | 0.008628 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.25 | 0.015975 | 0.225969 | 0.000237 | 0.007523 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.31 | 0.062562 | 0.230851 | 0.000252 | 0.008658 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.25 | 0.025597 | 0.217479 | 0.000187 | 0.006897 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.31 | 0.074433 | 0.213731 | 0.000222 | 0.011913 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.28 | 0.024998 | 0.241860 | 0.000209 | 0.009209 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.26 | 0.009706 | 0.236459 | 0.000317 | 0.007026 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.31 | 0.066247 | 0.227839 | 0.000207 | 0.006436 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.27 | 0.023534 | 0.236909 | 0.000744 | 0.007837 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.27 | 0.031210 | 0.226176 | 0.000539 | 0.008458 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.25 | 0.020424 | 0.215310 | 0.000187 | 0.006632 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.3 | 0.073771 | 0.210825 | 0.000265 | 0.007966 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.23 | 0.011727 | 0.204410 | 0.000208 | 0.008183 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.31 | 0.067443 | 0.227881 | 0.000562 | 0.007958 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.3 | 0.066058 | 0.221249 | 0.000232 | 0.007581 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.29 | 0.059354 | 0.212372 | 0.000220 | 0.008906 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.24 | 0.021586 | 0.203146 | 0.000746 | 0.014266 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.32 | 0.072845 | 0.231758 | 0.000445 | 0.009807 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.29 | 0.025124 | 0.244941 | 0.000217 | 0.011854 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.31 | 0.062651 | 0.231229 | 0.000227 | 0.008298 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.27 | 0.014769 | 0.242605 | 0.000274 | 0.008632 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.27 | 0.020606 | 0.239579 | 0.000214 | 0.007382 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.24 | 0.018084 | 0.207752 | 0.000188 | 0.007581 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.3 | 0.065615 | 0.210520 | 0.000676 | 0.010553 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.27 | 0.027413 | 0.225847 | 0.000610 | 0.007679 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.24 | 0.010449 | 0.219300 | 0.000499 | 0.007533 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.3 | 0.071447 | 0.205643 | 0.000576 | 0.011777 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.26 | 0.029090 | 0.207941 | 0.000261 | 0.012771 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.31 | 0.075702 | 0.216613 | 0.000219 | 0.011812 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.25 | 0.024921 | 0.210436 | 0.000215 | 0.007341 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.31 | 0.063993 | 0.229390 | 0.000214 | 0.008582 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.28 | 0.056177 | 0.216707 | 0.000183 | 0.006336 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.26 | 0.017953 | 0.227440 | 0.000213 | 0.006678 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.31 | 0.058335 | 0.238585 | 0.000214 | 0.007206 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.3 | 0.053665 | 0.234135 | 0.000586 | 0.010831 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.27 | 0.026766 | 0.228808 | 0.000564 | 0.007948 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.28 | 0.060507 | 0.205738 | 0.000213 | 0.007662 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.24 | 0.017481 | 0.204627 | 0.000210 | 0.010616 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.28 | 0.065425 | 0.200170 | 0.000213 | 0.006704 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.23 | 0.015713 | 0.204668 | 0.000214 | 0.007158 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.26 | 0.062254 | 0.181091 | 0.000195 | 0.009497 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.18 | 0.018408 | 0.149026 | 0.000213 | 0.007452 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.18 | 0.064471 | 0.103382 | 0.000256 | 0.007882 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.15 | 0.021422 | 0.115717 | 0.000197 | 0.006712 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |