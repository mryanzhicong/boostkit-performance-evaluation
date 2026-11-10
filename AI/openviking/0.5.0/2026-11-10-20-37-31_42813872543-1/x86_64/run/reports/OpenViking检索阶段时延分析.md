# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.057634s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000917 | 1.590% |
| Query Embedding | 生成查询向量 | 0.045605 | 79.128% |
| 向量召回 | 召回语义相似记忆 | 0.005191 | 9.007% |
| 结果处理 | 整理候选并转换返回结构 | 0.000012 | 0.021% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005910 | 10.254% |
|  |  | 0.057634 | 100.000% |

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

父阶段平均耗时：**0.057634s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.000917 | 1.590% |
| Query Embedding | 生成查询向量 | 0.045605 | 79.128% |
| 向量召回 | 召回语义相似记忆 | 0.005191 | 9.007% |
| 结果处理 | 整理候选并转换返回结构 | 0.000012 | 0.021% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005910 | 10.254% |
| 合计 |  | 0.057634 | 100.000% |

**结论：Query Embedding占79.127%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.000917s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000013 | 1.445% |
| 集合检查 | 检查目标集合与检索器 | 0.000903 | 98.555% |
| 合计 |  | 0.000917 | 100.000% |

**结论：集合检查占98.555%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000012s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000005 | 38.589% |
| 结构转换 | 构造接口返回对象 | 0.000001 | 11.010% |
| 结果处理内部 | 结果处理调度 | 0.000006 | 50.401% |
| 合计 |  | 0.000012 | 100.000% |

**结论：结果处理内部占50.401%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.376218s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.008598 | 2.285% |
| 记忆检索 | 查询相关记忆 | 0.044543 | 11.840% |
| 上下文筛选 | 选择候选记忆 | 0.000031 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.225678 | 59.986% |
| 重排 | 调整候选顺序 | 0.000533 | 0.142% |
| Prompt准备 | 构造回答输入 | 0.072992 | 19.401% |
| 回答LLM | 生成最终回答 | 0.023810 | 6.329% |
| 响应解析 | 解析回答结果 | 0.000034 | 0.009% |
| 合计 |  | 0.376218 | 100.000% |

**结论：记忆读取占59.986%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-10T20:32:59+08:00 |
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
| 检索耗时(s) | 0.057634 | 0.060062 | 0.063174 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_0a431518c8c94cae95ee45b6254f6752 | 39 | 0.027744 | 0.000024 | 0.002702 | 0.010996 | 0.005527 | 0.000005 | 0.000003 |
| 1 | sample_0_qa1 | tm_52c3f823fd324d98a6ed10d75842c022 | 39 | 0.032366 | 0.000012 | 0.001994 | 0.010441 | 0.005398 | 0.000005 | 0.000001 |
| 2 | sample_0_qa2 | tm_34303977c9da40cbb1e1f71bfb186206 | 39 | 0.066875 | 0.000012 | 0.001080 | 0.049254 | 0.001297 | 0.000005 | 0.000002 |
| 3 | sample_0_qa3 | tm_b39e1a03007543ed97ece3147aae3f01 | 39 | 0.038733 | 0.000011 | 0.000602 | 0.015703 | 0.007085 | 0.000005 | 0.000001 |
| 4 | sample_0_qa4 | tm_1735578248a0442e814c2e160701be7b | 39 | 0.057846 | 0.000015 | 0.000711 | 0.044612 | 0.004473 | 0.000011 | 0.000002 |
| 5 | sample_0_qa5 | tm_2915bfb3c5114544aaa08180603561ae | 39 | 0.054238 | 0.000012 | 0.000341 | 0.045388 | 0.003666 | 0.000005 | 0.000001 |
| 6 | sample_0_qa6 | tm_a00f108b5eff48c0a704d767ac74f27b | 39 | 0.009105 | 0.000013 | 0.000162 | 0.004477 | 0.001279 | 0.000005 | 0.000002 |
| 7 | sample_0_qa7 | tm_62b727a40fd7422f893ba60dfb4ef3f0 | 39 | 0.049063 | 0.000013 | 0.000167 | 0.044577 | 0.000859 | 0.000005 | 0.000001 |
| 8 | sample_0_qa8 | tm_5524e064d15749bc832959a2f86f5301 | 39 | 0.049453 | 0.000014 | 0.000188 | 0.045063 | 0.001042 | 0.000005 | 0.000001 |
| 9 | sample_0_qa9 | tm_cb554ffce68a4b5da50cd0e8e2ae70fe | 39 | 0.058063 | 0.000014 | 0.000905 | 0.048540 | 0.004401 | 0.000004 | 0.000002 |
| 10 | sample_0_qa10 | tm_14a9b9be24d14240bdddf2ae80a59dba | 39 | 0.054592 | 0.000011 | 0.000272 | 0.046247 | 0.003952 | 0.000005 | 0.000002 |
| 11 | sample_0_qa11 | tm_3bd96afd31a443f6989ab3185c320f3b | 39 | 0.057711 | 0.000014 | 0.000256 | 0.046286 | 0.008023 | 0.000005 | 0.000002 |
| 12 | sample_0_qa12 | tm_e2def6e1445d40f1b0d74f2b380e4868 | 39 | 0.051229 | 0.000014 | 0.000181 | 0.045770 | 0.002142 | 0.000005 | 0.000001 |
| 13 | sample_0_qa13 | tm_affd1cd7b7a84647952c59aaeef8e934 | 39 | 0.019230 | 0.000015 | 0.001054 | 0.005451 | 0.005152 | 0.000005 | 0.000001 |
| 14 | sample_0_qa14 | tm_f543f0109127434383ebc368d11cded6 | 39 | 0.054617 | 0.000012 | 0.000678 | 0.045074 | 0.001397 | 0.000005 | 0.000001 |
| 15 | sample_0_qa15 | tm_38049a76a62141a4af6d7f102503d420 | 39 | 0.050169 | 0.000013 | 0.000144 | 0.044763 | 0.002058 | 0.000004 | 0.000001 |
| 16 | sample_0_qa16 | tm_9108f63d6c0b4b5cb4f3d2feeddcf908 | 39 | 0.052719 | 0.000012 | 0.002332 | 0.045376 | 0.001762 | 0.000005 | 0.000001 |
| 17 | sample_0_qa17 | tm_216a8c5a56a54b489979461d2061a41d | 39 | 0.052408 | 0.000014 | 0.000154 | 0.045522 | 0.003555 | 0.000005 | 0.000001 |
| 18 | sample_0_qa18 | tm_637a79bb249347c982553316b29146e0 | 39 | 0.051737 | 0.000014 | 0.000346 | 0.044484 | 0.001330 | 0.000005 | 0.000002 |
| 19 | sample_0_qa19 | tm_61ddd1f8ece34d699fd0fa5d0c9e7fd0 | 39 | 0.053081 | 0.000012 | 0.000199 | 0.048168 | 0.001461 | 0.000005 | 0.000001 |
| 20 | sample_0_qa20 | tm_f869487b697d462bafd97487d420f6c9 | 39 | 0.055080 | 0.000012 | 0.000132 | 0.044887 | 0.005080 | 0.000005 | 0.000001 |
| 21 | sample_0_qa21 | tm_11de9744f6884d839caff06b31cbb1e3 | 39 | 0.050663 | 0.000014 | 0.000163 | 0.044763 | 0.002678 | 0.000005 | 0.000001 |
| 22 | sample_0_qa22 | tm_32c70852af544819b05519f601cefa93 | 39 | 0.050047 | 0.000014 | 0.000216 | 0.045033 | 0.001414 | 0.000005 | 0.000001 |
| 23 | sample_0_qa23 | tm_0e831545d52d49eca9c01fc4dc79686a | 39 | 0.052284 | 0.000013 | 0.000269 | 0.045651 | 0.000906 | 0.000005 | 0.000002 |
| 24 | sample_0_qa24 | tm_9fd564ff1568414da20f747a937405e1 | 39 | 0.055349 | 0.000013 | 0.000496 | 0.044687 | 0.004607 | 0.000005 | 0.000002 |
| 25 | sample_0_qa25 | tm_bd8413cd76494969904e8deb93ca6fc6 | 39 | 0.054286 | 0.000012 | 0.000301 | 0.045721 | 0.004022 | 0.000005 | 0.000001 |
| 26 | sample_0_qa26 | tm_b4550d46705d47f69a795e38df93d5d4 | 39 | 0.049233 | 0.000014 | 0.000155 | 0.044816 | 0.000956 | 0.000005 | 0.000001 |
| 27 | sample_0_qa27 | tm_a21141ae8c2e448d960489cc723aa9f4 | 39 | 0.048775 | 0.000014 | 0.000202 | 0.044667 | 0.000841 | 0.000005 | 0.000001 |
| 28 | sample_0_qa28 | tm_7b25d0c82572489ea6a46277e5a117bf | 39 | 0.056779 | 0.000013 | 0.000908 | 0.046092 | 0.005592 | 0.000004 | 0.000001 |
| 29 | sample_0_qa29 | tm_823cdd439b4c4dfc93ad575aba342875 | 39 | 0.053817 | 0.000011 | 0.000258 | 0.048043 | 0.001907 | 0.000005 | 0.000002 |
| 30 | sample_0_qa30 | tm_809a6b4416314c37a5c121eaf51c8b36 | 39 | 0.049127 | 0.000015 | 0.000119 | 0.044563 | 0.001273 | 0.000005 | 0.000002 |
| 31 | sample_0_qa31 | tm_606024c89ac245f0951bde2e5beb13c4 | 39 | 0.049880 | 0.000013 | 0.000170 | 0.045528 | 0.000931 | 0.000005 | 0.000002 |
| 32 | sample_0_qa32 | tm_55327b7e5ff2415db2a499028fc17098 | 39 | 0.056420 | 0.000014 | 0.000925 | 0.045686 | 0.005713 | 0.000004 | 0.000001 |
| 33 | sample_0_qa33 | tm_03e3d8bbc854403d962fdc9051b18409 | 39 | 0.053221 | 0.000011 | 0.000299 | 0.047786 | 0.001480 | 0.000005 | 0.000001 |
| 34 | sample_0_qa34 | tm_cdacf5fe8c3247749968277d21dbae0e | 39 | 0.049335 | 0.000014 | 0.000214 | 0.045177 | 0.000875 | 0.000006 | 0.000001 |
| 35 | sample_0_qa35 | tm_45f3c5a8eaf945388c599cbce81afd4c | 39 | 0.049837 | 0.000013 | 0.000195 | 0.045584 | 0.000898 | 0.000005 | 0.000001 |
| 36 | sample_0_qa36 | tm_ca453aa482bc44f8b62ae72914085904 | 39 | 0.054091 | 0.000014 | 0.000964 | 0.044728 | 0.004004 | 0.000005 | 0.000002 |
| 37 | sample_0_qa37 | tm_7b81592cd615461b970d50522a765749 | 39 | 0.053793 | 0.000011 | 0.000276 | 0.045707 | 0.003193 | 0.000005 | 0.000001 |
| 38 | sample_0_qa38 | tm_a2d13f3a4e2f4540ba99b8000d16da55 | 39 | 0.051879 | 0.000013 | 0.000197 | 0.046623 | 0.001961 | 0.000005 | 0.000001 |
| 39 | sample_0_qa39 | tm_e635573adbb54a94aec6d0ecb27f120a | 39 | 0.049832 | 0.000013 | 0.000209 | 0.045673 | 0.000895 | 0.000004 | 0.000001 |
| 40 | sample_0_qa40 | tm_2ca41a4aafa446a1b2b25bd5922119c7 | 39 | 0.054114 | 0.000015 | 0.000977 | 0.045818 | 0.003223 | 0.000005 | 0.000002 |
| 41 | sample_0_qa41 | tm_cb20ab24b59a45d5a0b2a2d11cbdc8fa | 39 | 0.054876 | 0.000012 | 0.000253 | 0.048799 | 0.002367 | 0.000005 | 0.000001 |
| 42 | sample_0_qa42 | tm_7c13c13445bc4a5a982713415ea99df7 | 39 | 0.054929 | 0.000013 | 0.000143 | 0.045873 | 0.005732 | 0.000005 | 0.000001 |
| 43 | sample_0_qa43 | tm_92af8ba6ab62491c8537ec9dc06f1bb8 | 39 | 0.052154 | 0.000014 | 0.000235 | 0.045794 | 0.003083 | 0.000005 | 0.000001 |
| 44 | sample_0_qa44 | tm_92fa3d8e998c467387644066fcf6df81 | 39 | 0.060695 | 0.000015 | 0.001205 | 0.046118 | 0.004447 | 0.000005 | 0.000002 |
| 45 | sample_0_qa45 | tm_983180ee570b4dbba4bc79106afcd9cb | 39 | 0.062226 | 0.000011 | 0.000431 | 0.048605 | 0.006341 | 0.000004 | 0.000001 |
| 46 | sample_0_qa46 | tm_ff733101f9a84604aedb1c5beeaf466e | 39 | 0.064350 | 0.000013 | 0.000260 | 0.046228 | 0.012475 | 0.000004 | 0.000001 |
| 47 | sample_0_qa47 | tm_489e154b42f24e329d91a552f70c8487 | 39 | 0.055709 | 0.000012 | 0.000205 | 0.045421 | 0.006859 | 0.000005 | 0.000001 |
| 48 | sample_0_qa48 | tm_252f7c38a19444f596cfe92ba44d6070 | 39 | 0.062884 | 0.000017 | 0.001275 | 0.045935 | 0.006168 | 0.000005 | 0.000001 |
| 49 | sample_0_qa49 | tm_1f2542ee1d1d4800bb958b4c9d859253 | 39 | 0.057760 | 0.000012 | 0.000529 | 0.048278 | 0.002149 | 0.000005 | 0.000002 |
| 50 | sample_0_qa50 | tm_7b89cab4e4214b10b4ee8df2b36b62c0 | 39 | 0.061878 | 0.000013 | 0.000895 | 0.046923 | 0.009919 | 0.000004 | 0.000001 |
| 51 | sample_0_qa51 | tm_c9621245f4be434db22ec12e62ee93ef | 39 | 0.059144 | 0.000011 | 0.000303 | 0.047470 | 0.006240 | 0.000005 | 0.000001 |
| 52 | sample_0_qa52 | tm_d8283b22eaf349e1b38966d47fa3c6b1 | 39 | 0.061351 | 0.000017 | 0.001493 | 0.044862 | 0.006025 | 0.000006 | 0.000001 |
| 53 | sample_0_qa53 | tm_20f4a711aecb4c45adddedd4eebb2e49 | 39 | 0.058063 | 0.000010 | 0.000754 | 0.045903 | 0.001580 | 0.000005 | 0.000002 |
| 54 | sample_0_qa54 | tm_3b7ecfa50e3c462eb0f8ffed72b711a2 | 39 | 0.060357 | 0.000012 | 0.000893 | 0.046750 | 0.008491 | 0.000005 | 0.000002 |
| 55 | sample_0_qa55 | tm_d4a9b498532b424da12229dc18c7a581 | 39 | 0.061069 | 0.000010 | 0.000218 | 0.050090 | 0.007228 | 0.000004 | 0.000001 |
| 56 | sample_0_qa56 | tm_41026d139fd040cea5ba194f18295e11 | 39 | 0.060344 | 0.000017 | 0.003414 | 0.045595 | 0.003617 | 0.000005 | 0.000002 |
| 57 | sample_0_qa57 | tm_c09a56be7aef4c44a309515c2f405755 | 39 | 0.060071 | 0.000012 | 0.000449 | 0.047921 | 0.003180 | 0.000004 | 0.000001 |
| 58 | sample_0_qa58 | tm_a7b8f5fab84a4c10844d71aa69135691 | 39 | 0.059784 | 0.000012 | 0.000875 | 0.045737 | 0.008304 | 0.000004 | 0.000001 |
| 59 | sample_0_qa59 | tm_5563d354fa634c5086bf5c9e3db3b486 | 39 | 0.059877 | 0.000011 | 0.000271 | 0.048759 | 0.007478 | 0.000004 | 0.000001 |
| 60 | sample_0_qa60 | tm_0902c17b574e48bd87e532ceb31d3db7 | 39 | 0.063028 | 0.000016 | 0.003760 | 0.046430 | 0.006089 | 0.000004 | 0.000001 |
| 61 | sample_0_qa61 | tm_bc70038c2f4f421b8d6c82ee6be2a7ae | 39 | 0.060053 | 0.000012 | 0.000583 | 0.048761 | 0.002063 | 0.000005 | 0.000002 |
| 62 | sample_0_qa62 | tm_cc9e22eeab114bb0a07b9ec851891f3b | 39 | 0.061196 | 0.000013 | 0.001056 | 0.046675 | 0.008125 | 0.000005 | 0.000001 |
| 63 | sample_0_qa63 | tm_ad3e2a9bdfd043ae982f8baa295ed855 | 39 | 0.060843 | 0.000011 | 0.000339 | 0.048566 | 0.008059 | 0.000004 | 0.000001 |
| 64 | sample_0_qa64 | tm_db2fc20c64854f1d80443e1de5ec5f8f | 39 | 0.059834 | 0.000017 | 0.001145 | 0.045009 | 0.004513 | 0.000005 | 0.000002 |
| 65 | sample_0_qa65 | tm_4e20cb88cc6947b5adc2b8f38fcfef11 | 39 | 0.059784 | 0.000011 | 0.000407 | 0.047138 | 0.003685 | 0.000004 | 0.000001 |
| 66 | sample_0_qa66 | tm_003eaa96bad84952ac48b47bac933d34 | 39 | 0.060942 | 0.000013 | 0.000982 | 0.046080 | 0.009135 | 0.000005 | 0.000002 |
| 67 | sample_0_qa67 | tm_6c2a3562d1f149f29abdde90ed50fd62 | 39 | 0.061114 | 0.000011 | 0.000268 | 0.049238 | 0.008098 | 0.000005 | 0.000001 |
| 68 | sample_0_qa68 | tm_23cb874cb9874052ad5bde565335067d | 39 | 0.061527 | 0.000016 | 0.003805 | 0.045798 | 0.004590 | 0.000006 | 0.000007 |
| 69 | sample_0_qa69 | tm_f02ca81f66e145db9ae00c5b6102838b | 39 | 0.061599 | 0.000012 | 0.000786 | 0.048229 | 0.004008 | 0.000004 | 0.000001 |
| 70 | sample_0_qa70 | tm_2b4ddbaee8014741a227c924eddb0ec7 | 39 | 0.064191 | 0.000014 | 0.000946 | 0.046924 | 0.011792 | 0.000004 | 0.000001 |
| 71 | sample_0_qa71 | tm_c437ef898c1e4c909502f2eedebe0026 | 39 | 0.060181 | 0.000012 | 0.000241 | 0.047687 | 0.007401 | 0.000005 | 0.000001 |
| 72 | sample_0_qa72 | tm_0749950d5b6b40549193d2031951dca8 | 39 | 0.060738 | 0.000037 | 0.001391 | 0.045340 | 0.004115 | 0.000005 | 0.000002 |
| 73 | sample_0_qa73 | tm_1c4307a050c245a79f217eb31d65924c | 39 | 0.060685 | 0.000012 | 0.001201 | 0.047314 | 0.003294 | 0.000004 | 0.000001 |
| 74 | sample_0_qa74 | tm_f356993f5ef2488ebc440502defabbbf | 39 | 0.060043 | 0.000013 | 0.000869 | 0.047170 | 0.007202 | 0.000005 | 0.000001 |
| 75 | sample_0_qa75 | tm_fd9e0603b7c74b1880cbc6c4936f32f2 | 39 | 0.059376 | 0.000011 | 0.000220 | 0.049227 | 0.006643 | 0.000004 | 0.000001 |
| 76 | sample_0_qa76 | tm_0e33e79cb653457caa3751c53fe29dac | 39 | 0.060126 | 0.000015 | 0.000984 | 0.045684 | 0.003957 | 0.000005 | 0.000002 |
| 77 | sample_0_qa77 | tm_d4ea9766f37e41f38458e4159dbb4dcd | 39 | 0.060309 | 0.000012 | 0.004698 | 0.048048 | 0.003620 | 0.000005 | 0.000001 |
| 78 | sample_0_qa78 | tm_2c306c5c1a1e404aa5e9be8ae3988201 | 39 | 0.059622 | 0.000013 | 0.000926 | 0.045926 | 0.008429 | 0.000005 | 0.000001 |
| 79 | sample_0_qa79 | tm_4924ca356f1147d79a8396f2f9858ddd | 39 | 0.060040 | 0.000011 | 0.000234 | 0.048360 | 0.007969 | 0.000004 | 0.000001 |
| 80 | sample_0_qa80 | tm_fbd5a193d1fa4d5087b4bb01889c78f8 | 39 | 0.060920 | 0.000017 | 0.001302 | 0.048109 | 0.002186 | 0.000005 | 0.000002 |
| 81 | sample_0_qa81 | tm_bd69114b1b9941e2bdc8ba662a99545e | 39 | 0.061210 | 0.000011 | 0.000543 | 0.045783 | 0.005895 | 0.000004 | 0.000001 |
| 82 | sample_0_qa82 | tm_5baf855767654a2eb5870c9aff8c7f9e | 39 | 0.061684 | 0.000013 | 0.000924 | 0.047488 | 0.008412 | 0.000005 | 0.000002 |
| 83 | sample_0_qa83 | tm_8ce11e844c34482fbfa8c2f83dc9a4ca | 39 | 0.061233 | 0.000011 | 0.000229 | 0.049617 | 0.007715 | 0.000004 | 0.000001 |
| 84 | sample_0_qa84 | tm_1e7d4fcc754f42ff82ba0e8baba45494 | 39 | 0.060646 | 0.000017 | 0.001301 | 0.045037 | 0.004197 | 0.000005 | 0.000002 |
| 85 | sample_0_qa85 | tm_c255b0c785e04c83b3de68b8b488db47 | 39 | 0.060939 | 0.000011 | 0.000916 | 0.047342 | 0.003817 | 0.000004 | 0.000001 |
| 86 | sample_0_qa86 | tm_105f337d695f44c08f7de23e00cce0c9 | 39 | 0.059960 | 0.000012 | 0.000898 | 0.046826 | 0.007807 | 0.000005 | 0.000001 |
| 87 | sample_0_qa87 | tm_b6766a54ec964898bde6e06ceac1be15 | 39 | 0.060572 | 0.000011 | 0.000214 | 0.048933 | 0.007919 | 0.000004 | 0.000001 |
| 88 | sample_0_qa88 | tm_404c74c6676d47528530efad6acec7e7 | 39 | 0.060280 | 0.000017 | 0.001082 | 0.045561 | 0.003644 | 0.000005 | 0.000002 |
| 89 | sample_0_qa89 | tm_2348573574434ddfaa85e83b4b414473 | 39 | 0.060120 | 0.000011 | 0.000657 | 0.048203 | 0.002809 | 0.000004 | 0.000001 |
| 90 | sample_0_qa90 | tm_926f26f6723241e6a5a4d42ffb5d6921 | 39 | 0.063069 | 0.000013 | 0.000968 | 0.046020 | 0.011198 | 0.000004 | 0.000001 |
| 91 | sample_0_qa91 | tm_751c56523245433cb514dce0e68de715 | 39 | 0.059138 | 0.000011 | 0.000345 | 0.049209 | 0.005517 | 0.000005 | 0.000001 |
| 92 | sample_0_qa92 | tm_ef032479d6874a75b23b265e07235ab4 | 39 | 0.061523 | 0.000016 | 0.003600 | 0.046009 | 0.003998 | 0.000005 | 0.000003 |
| 93 | sample_0_qa93 | tm_fb553aab25a04c20a73e761a59882695 | 39 | 0.061282 | 0.000012 | 0.000305 | 0.048060 | 0.003856 | 0.000004 | 0.000001 |
| 94 | sample_0_qa94 | tm_3a823b0b22bb477d8e346339a84fde1d | 39 | 0.060827 | 0.000013 | 0.000879 | 0.046869 | 0.008234 | 0.000004 | 0.000001 |
| 95 | sample_0_qa95 | tm_20fd2a531ac54988b6c6038cd699bfa9 | 39 | 0.060513 | 0.000011 | 0.000280 | 0.047697 | 0.008211 | 0.000004 | 0.000001 |
| 96 | sample_0_qa96 | tm_9072bfd33c7647b4a6b3be7e64ed5824 | 39 | 0.062375 | 0.000016 | 0.001124 | 0.045743 | 0.006011 | 0.000005 | 0.000001 |
| 97 | sample_0_qa97 | tm_fbc0c987eb4649f0919c99420ff99b15 | 39 | 0.058949 | 0.000011 | 0.000414 | 0.048068 | 0.001466 | 0.000005 | 0.000002 |
| 98 | sample_0_qa98 | tm_b40d0a7be0b84cfcb4e7056720a096c0 | 39 | 0.060677 | 0.000013 | 0.000912 | 0.046917 | 0.008491 | 0.000004 | 0.000002 |
| 99 | sample_0_qa99 | tm_9b8422286515407792fa08981b7e00a3 | 39 | 0.060681 | 0.000011 | 0.000231 | 0.050138 | 0.006843 | 0.000004 | 0.000001 |
| 100 | sample_0_qa100 | tm_3905d1a94d7a409886d90363f7bcfbb2 | 39 | 0.060923 | 0.000016 | 0.003463 | 0.046087 | 0.004032 | 0.000005 | 0.000001 |
| 101 | sample_0_qa101 | tm_2cf6317a14534f6e9edb6702fd413b0c | 39 | 0.060879 | 0.000012 | 0.000547 | 0.049060 | 0.003131 | 0.000004 | 0.000001 |
| 102 | sample_0_qa102 | tm_6af41392b52a4d468009e31dbfdbcec3 | 39 | 0.059926 | 0.000013 | 0.000879 | 0.046585 | 0.007269 | 0.000005 | 0.000001 |
| 103 | sample_0_qa103 | tm_b7a5e46a520b49f7950dabf2be2210c4 | 39 | 0.061053 | 0.000011 | 0.000284 | 0.048722 | 0.007113 | 0.000005 | 0.000001 |
| 104 | sample_0_qa104 | tm_d18aedbff593403a8f1183b3ec63b828 | 39 | 0.062417 | 0.000017 | 0.003541 | 0.047846 | 0.003679 | 0.000005 | 0.000002 |
| 105 | sample_0_qa105 | tm_dfd9f2dc0af94d4d9b3b2a756bbdc5c8 | 39 | 0.064711 | 0.000011 | 0.000689 | 0.050629 | 0.005205 | 0.000004 | 0.000001 |
| 106 | sample_0_qa106 | tm_2d6f900c3cf54907aa5608036476044f | 39 | 0.064250 | 0.000014 | 0.001138 | 0.046111 | 0.010616 | 0.000005 | 0.000001 |
| 107 | sample_0_qa107 | tm_929625e06f50438aa100d0b0c0e11f21 | 39 | 0.063473 | 0.000011 | 0.000240 | 0.049842 | 0.009039 | 0.000004 | 0.000001 |
| 108 | sample_0_qa108 | tm_9bc694e59e8449f193138bcb45cb1bcf | 39 | 0.063066 | 0.000017 | 0.001198 | 0.045723 | 0.006115 | 0.000005 | 0.000001 |
| 109 | sample_0_qa109 | tm_75584260e897414a8c966b0547180f43 | 39 | 0.057612 | 0.000011 | 0.000519 | 0.047867 | 0.002053 | 0.000005 | 0.000002 |
| 110 | sample_0_qa110 | tm_78dd926bfcae41e3aee30644d36b4404 | 39 | 0.062545 | 0.000014 | 0.001103 | 0.045946 | 0.010646 | 0.000004 | 0.000001 |
| 111 | sample_0_qa111 | tm_b12ef7d026cf42ebaed157105b66453c | 39 | 0.059096 | 0.000011 | 0.000331 | 0.049112 | 0.005765 | 0.000005 | 0.000001 |
| 112 | sample_0_qa112 | tm_f21121c15e0040b99d487182b38b92da | 39 | 0.060901 | 0.000016 | 0.003138 | 0.045681 | 0.004544 | 0.000005 | 0.000002 |
| 113 | sample_0_qa113 | tm_39b8d9b5da014d0e8d977f81929fb6c0 | 39 | 0.060935 | 0.000011 | 0.000302 | 0.048073 | 0.003768 | 0.000004 | 0.000001 |
| 114 | sample_0_qa114 | tm_f800da8d54f34d1a983e48267ce08244 | 39 | 0.061499 | 0.000014 | 0.000919 | 0.046462 | 0.009952 | 0.000005 | 0.000001 |
| 115 | sample_0_qa115 | tm_a32d68745bca4ec28eac2ef84c8cba7c | 39 | 0.058741 | 0.000011 | 0.000257 | 0.048581 | 0.006197 | 0.000005 | 0.000001 |
| 116 | sample_0_qa116 | tm_6593bee08d0348c08fd3855e5f4bda49 | 39 | 0.059580 | 0.000017 | 0.001080 | 0.045911 | 0.003309 | 0.000005 | 0.000002 |
| 117 | sample_0_qa117 | tm_3c144caf719b499cbb84ee5ea3e5aa62 | 39 | 0.059871 | 0.000011 | 0.000365 | 0.047767 | 0.003084 | 0.000004 | 0.000001 |
| 118 | sample_0_qa118 | tm_6104e8b8c6da4a43923d94c8b9ef3fb4 | 39 | 0.060715 | 0.000014 | 0.000951 | 0.046321 | 0.009084 | 0.000004 | 0.000001 |
| 119 | sample_0_qa119 | tm_922d709f0e254f47b496a649ac9f676a | 39 | 0.061255 | 0.000012 | 0.000320 | 0.048326 | 0.007862 | 0.000004 | 0.000001 |
| 120 | sample_0_qa120 | tm_fc2e73afa487464c825c13f0d4cf1836 | 39 | 0.063303 | 0.000017 | 0.003664 | 0.045128 | 0.006885 | 0.000004 | 0.000001 |
| 121 | sample_0_qa121 | tm_48c6d2341daf4792b9b6938ff402203d | 39 | 0.059853 | 0.000012 | 0.000960 | 0.047410 | 0.002221 | 0.000005 | 0.000003 |
| 122 | sample_0_qa122 | tm_95fc6b9e70aa4da8ab5f6829ed585f91 | 39 | 0.060820 | 0.000013 | 0.000958 | 0.046948 | 0.008301 | 0.000005 | 0.000001 |
| 123 | sample_0_qa123 | tm_20041d7775be4f4a9f4ce0fbaa64db27 | 39 | 0.060873 | 0.000011 | 0.000253 | 0.049353 | 0.008024 | 0.000004 | 0.000001 |
| 124 | sample_0_qa124 | tm_c618ef24a5374f7c92fae1716a9c171e | 39 | 0.059817 | 0.000017 | 0.001135 | 0.045161 | 0.003668 | 0.000005 | 0.000002 |
| 125 | sample_0_qa125 | tm_37edc5b1a9974fffbf55de834dfb44c5 | 39 | 0.059534 | 0.000011 | 0.000544 | 0.046067 | 0.003324 | 0.000004 | 0.000001 |
| 126 | sample_0_qa126 | tm_74571d41addd4615b40e52485ceb6018 | 39 | 0.062677 | 0.000013 | 0.000855 | 0.045859 | 0.011394 | 0.000004 | 0.000001 |
| 127 | sample_0_qa127 | tm_7a978480e17649d0b6775d622e1fc282 | 39 | 0.058403 | 0.000011 | 0.000277 | 0.048044 | 0.005634 | 0.000005 | 0.000002 |
| 128 | sample_0_qa128 | tm_8f23d70350124068876f9b974e36135b | 39 | 0.061096 | 0.000017 | 0.003556 | 0.045939 | 0.004025 | 0.000005 | 0.000001 |
| 129 | sample_0_qa129 | tm_7052f34a692b42dfb94ab8ade243b087 | 39 | 0.061358 | 0.000012 | 0.000641 | 0.048241 | 0.003804 | 0.000004 | 0.000001 |
| 130 | sample_0_qa130 | tm_f04cbf6757374831a5bb2101ab7e6d09 | 39 | 0.061042 | 0.000013 | 0.001054 | 0.046287 | 0.008788 | 0.000005 | 0.000001 |
| 131 | sample_0_qa131 | tm_e69fa04e816b44d6ad84ff58f26d03e5 | 39 | 0.061060 | 0.000011 | 0.000234 | 0.048507 | 0.009045 | 0.000011 | 0.000001 |
| 132 | sample_0_qa132 | tm_ac98dfb95e3b42b5ba577746d0c68163 | 39 | 0.061809 | 0.000016 | 0.001514 | 0.045481 | 0.004935 | 0.000005 | 0.000002 |
| 133 | sample_0_qa133 | tm_774797f80ff1429fb1bb8064d95cd55e | 39 | 0.064069 | 0.000011 | 0.000505 | 0.048022 | 0.006897 | 0.000004 | 0.000001 |
| 134 | sample_0_qa134 | tm_1c90e856a0324e5eb024ccbd5ed52fa9 | 39 | 0.062236 | 0.000013 | 0.001001 | 0.045335 | 0.010742 | 0.000004 | 0.000001 |
| 135 | sample_0_qa135 | tm_9fb68d63fedb4655b1191abfb205f5b1 | 39 | 0.061901 | 0.000011 | 0.000308 | 0.049034 | 0.009009 | 0.000005 | 0.000001 |
| 136 | sample_0_qa136 | tm_b7985d7929064ec7a0a5089fc88c8300 | 39 | 0.060715 | 0.000017 | 0.001128 | 0.045662 | 0.003932 | 0.000005 | 0.000002 |
| 137 | sample_0_qa137 | tm_1e61f67b03ef43e9a88d971260ecb6d4 | 39 | 0.058579 | 0.000011 | 0.000578 | 0.047742 | 0.003722 | 0.000005 | 0.000001 |
| 138 | sample_0_qa138 | tm_b12eb9e00de9450ab29617718fb5a69d | 39 | 0.061425 | 0.000013 | 0.000902 | 0.045727 | 0.009790 | 0.000004 | 0.000001 |
| 139 | sample_0_qa139 | tm_9f688cb382c54d5dbc67ad16002c64f9 | 39 | 0.061038 | 0.000011 | 0.000229 | 0.048954 | 0.008175 | 0.000004 | 0.000001 |
| 140 | sample_0_qa140 | tm_e6e3033dd082447bbf47395f04d5bcc2 | 39 | 0.062554 | 0.000015 | 0.003398 | 0.045697 | 0.006061 | 0.000004 | 0.000001 |
| 141 | sample_0_qa141 | tm_8054e27c04ee4b81b14e652732ef40a5 | 39 | 0.059374 | 0.000013 | 0.000463 | 0.048015 | 0.002091 | 0.000005 | 0.000002 |
| 142 | sample_0_qa142 | tm_115cbb64717d40e6a29144bd65250ead | 39 | 0.060050 | 0.000013 | 0.000882 | 0.049084 | 0.005884 | 0.000005 | 0.000002 |
| 143 | sample_0_qa143 | tm_f71f382d76f5464ebedbdfbd469c063b | 39 | 0.059949 | 0.000011 | 0.000269 | 0.046460 | 0.009820 | 0.000004 | 0.000001 |
| 144 | sample_0_qa144 | tm_a10b4c0feecb4457b4275e1141ae869f | 39 | 0.062094 | 0.000016 | 0.005816 | 0.045981 | 0.005855 | 0.000004 | 0.000001 |
| 145 | sample_0_qa145 | tm_2bfa5b10db9b419aae8744064399ac99 | 39 | 0.059457 | 0.000013 | 0.000567 | 0.047850 | 0.002088 | 0.000005 | 0.000002 |
| 146 | sample_0_qa146 | tm_49453fe261f54d64992f52c8da307ad6 | 39 | 0.061048 | 0.000013 | 0.000953 | 0.046527 | 0.009414 | 0.000005 | 0.000001 |
| 147 | sample_0_qa147 | tm_d7c797392a124d8eb29195473fffab15 | 39 | 0.061189 | 0.000011 | 0.000312 | 0.049661 | 0.007791 | 0.000005 | 0.000001 |
| 148 | sample_0_qa148 | tm_a2ab9bd3673641288b5b3791ac730b8e | 39 | 0.060569 | 0.000016 | 0.003282 | 0.046052 | 0.003983 | 0.000005 | 0.000002 |
| 149 | sample_0_qa149 | tm_f22f26dea81e434e9c721c508ff5e2a4 | 39 | 0.061127 | 0.000012 | 0.000444 | 0.048383 | 0.003786 | 0.000004 | 0.000001 |
| 150 | sample_0_qa150 | tm_8cc2b5daa89a487bbafb86871584c989 | 39 | 0.054974 | 0.000013 | 0.000892 | 0.046078 | 0.003557 | 0.000004 | 0.000001 |
| 151 | sample_0_qa151 | tm_cb1dd1d75ec24c48a6939a524b320542 | 39 | 0.054819 | 0.000011 | 0.000282 | 0.046835 | 0.002922 | 0.000005 | 0.000001 |

问答端到端平均耗时：0.375789s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.27 | 0.011948 | 0.222495 | 1.634922 | 0.306520 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.27 | 0.062044 | 0.522986 | 1.333607 | 0.304948 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.27 | 0.036950 | 0.514366 | 1.365829 | 0.306523 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.27 | 0.089367 | 0.501949 | 1.327248 | 0.303682 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.27 | 0.087077 | 0.497680 | 1.332379 | 0.304332 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.27 | 0.034621 | 0.517366 | 1.365483 | 0.305972 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.27 | 0.088549 | 0.500445 | 1.327816 | 0.302886 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.27 | 0.029449 | 0.521057 | 1.364461 | 0.305853 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.011129 | 0.213366 | 0.000189 | 0.007242 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.085399 | 0.207432 | 0.000174 | 0.007318 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.3 | 0.062539 | 0.205016 | 0.000152 | 0.006517 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.32 | 0.073750 | 0.208351 | 0.000153 | 0.007970 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.28 | 0.033957 | 0.206808 | 0.000127 | 0.008347 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.26 | 0.037209 | 0.187531 | 0.000151 | 0.006780 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.28 | 0.032730 | 0.209460 | 0.000156 | 0.009717 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.29 | 0.048075 | 0.203384 | 0.000151 | 0.006522 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.027268 | 0.204127 | 0.000497 | 0.006764 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.067925 | 0.197314 | 0.000499 | 0.006850 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.24 | 0.009406 | 0.217419 | 0.000452 | 0.007279 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.27 | 0.065027 | 0.189289 | 0.000237 | 0.006873 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.23 | 0.012595 | 0.202519 | 0.000202 | 0.006652 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.072265 | 0.202544 | 0.000495 | 0.006743 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.28 | 0.073829 | 0.192948 | 0.000143 | 0.007689 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.25 | 0.025669 | 0.215964 | 0.000170 | 0.006980 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.25 | 0.020686 | 0.214377 | 0.000199 | 0.007758 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.014116 | 0.214821 | 0.000551 | 0.007323 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.3 | 0.063353 | 0.224147 | 0.000146 | 0.006784 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.24 | 0.015179 | 0.215559 | 0.000203 | 0.006866 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.053965 | 0.209441 | 0.000503 | 0.007139 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.064831 | 0.205705 | 0.000172 | 0.006704 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.28 | 0.059492 | 0.207971 | 0.000203 | 0.006996 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.028470 | 0.225007 | 0.000215 | 0.011273 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.25 | 0.024218 | 0.214827 | 0.000192 | 0.006931 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.063669 | 0.220015 | 0.000192 | 0.007805 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.26 | 0.024521 | 0.220179 | 0.000218 | 0.007500 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.059322 | 0.206007 | 0.000510 | 0.009488 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.021450 | 0.229840 | 0.000534 | 0.011470 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.31 | 0.062469 | 0.231736 | 0.000210 | 0.007476 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.24 | 0.021066 | 0.200892 | 0.000336 | 0.011163 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.32 | 0.074646 | 0.234259 | 0.000509 | 0.006944 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.27 | 0.027054 | 0.229084 | 0.000185 | 0.007563 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.018082 | 0.219156 | 0.000210 | 0.007003 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.27 | 0.053753 | 0.208530 | 0.000212 | 0.007699 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.28 | 0.058033 | 0.209798 | 0.000200 | 0.009230 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.25 | 0.023274 | 0.210319 | 0.000214 | 0.007396 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.030766 | 0.212427 | 0.000232 | 0.007851 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.3 | 0.069040 | 0.215191 | 0.000484 | 0.010441 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.26 | 0.030644 | 0.216171 | 0.000194 | 0.010546 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.31 | 0.060719 | 0.231873 | 0.000525 | 0.008018 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.31 | 0.068879 | 0.225104 | 0.000226 | 0.009609 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.26 | 0.021740 | 0.222830 | 0.000772 | 0.009056 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.27 | 0.018716 | 0.236170 | 0.000172 | 0.007770 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.3 | 0.068143 | 0.220481 | 0.000204 | 0.007649 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.012967 | 0.220693 | 0.000205 | 0.007812 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.055840 | 0.222761 | 0.000205 | 0.011983 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.26 | 0.022563 | 0.223957 | 0.000197 | 0.007394 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.24 | 0.017935 | 0.212465 | 0.000564 | 0.006883 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.24 | 0.010144 | 0.216702 | 0.000778 | 0.009242 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.29 | 0.071424 | 0.197643 | 0.000223 | 0.009267 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.25 | 0.017436 | 0.217232 | 0.000180 | 0.008343 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.31 | 0.070846 | 0.221823 | 0.000204 | 0.008076 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.24 | 0.017348 | 0.208147 | 0.000237 | 0.006591 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.063880 | 0.189949 | 0.000199 | 0.009004 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.21 | 0.018127 | 0.182521 | 0.000156 | 0.007173 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.28 | 0.056671 | 0.212525 | 0.000202 | 0.008318 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.29 | 0.061479 | 0.206825 | 0.000280 | 0.014223 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.27 | 0.055498 | 0.202715 | 0.000387 | 0.007996 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.024758 | 0.212521 | 0.000207 | 0.006436 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.3 | 0.064935 | 0.223607 | 0.000206 | 0.007391 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.3 | 0.067467 | 0.216240 | 0.000245 | 0.006790 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.3 | 0.063999 | 0.217980 | 0.000195 | 0.011944 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.28 | 0.027521 | 0.231573 | 0.000233 | 0.014917 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.27 | 0.021107 | 0.232812 | 0.000779 | 0.006753 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.019981 | 0.222000 | 0.000311 | 0.008699 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.060538 | 0.227123 | 0.000206 | 0.008673 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.28 | 0.024095 | 0.240508 | 0.000219 | 0.007299 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.025624 | 0.226229 | 0.000205 | 0.007520 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.27 | 0.059144 | 0.201254 | 0.000198 | 0.007760 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.24 | 0.009292 | 0.222517 | 0.000584 | 0.007157 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.064000 | 0.218339 | 0.000356 | 0.009950 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.25 | 0.020097 | 0.207435 | 0.000214 | 0.017971 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.24 | 0.018794 | 0.207153 | 0.001597 | 0.008635 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.24 | 0.009858 | 0.211839 | 0.001644 | 0.007832 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.3 | 0.070840 | 0.212878 | 0.000341 | 0.008014 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.26 | 0.018695 | 0.227856 | 0.000286 | 0.009054 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.28 | 0.057959 | 0.210403 | 0.000231 | 0.007600 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.3 | 0.056296 | 0.226783 | 0.000206 | 0.006294 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.29 | 0.058734 | 0.215051 | 0.000539 | 0.009108 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.31 | 0.068773 | 0.226604 | 0.000366 | 0.008835 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.25 | 0.024576 | 0.208584 | 0.000275 | 0.009920 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.25 | 0.019047 | 0.222174 | 0.000352 | 0.007693 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.23 | 0.014482 | 0.199144 | 0.000251 | 0.006673 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.29 | 0.069180 | 0.202711 | 0.000228 | 0.008784 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.24 | 0.027034 | 0.202040 | 0.000210 | 0.008436 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.29 | 0.066981 | 0.205954 | 0.000220 | 0.008570 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.28 | 0.062200 | 0.208676 | 0.000275 | 0.008627 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.24 | 0.021860 | 0.200431 | 0.000209 | 0.008093 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.28 | 0.068924 | 0.203040 | 0.000242 | 0.006817 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.27 | 0.069955 | 0.193282 | 0.000233 | 0.006675 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.33 | 0.063609 | 0.253652 | 0.000221 | 0.008292 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.24 | 0.009578 | 0.217425 | 0.000257 | 0.008635 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.31 | 0.069301 | 0.223261 | 0.000210 | 0.009121 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.31 | 0.072288 | 0.225809 | 0.000222 | 0.006776 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.23 | 0.021008 | 0.200587 | 0.000214 | 0.008081 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.3 | 0.066048 | 0.222288 | 0.000273 | 0.008164 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.24 | 0.014412 | 0.214477 | 0.000193 | 0.006966 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.29 | 0.058164 | 0.223532 | 0.000205 | 0.007522 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.23 | 0.018180 | 0.204282 | 0.000219 | 0.007444 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.29 | 0.061691 | 0.214958 | 0.000506 | 0.006687 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.29 | 0.060394 | 0.221758 | 0.000458 | 0.007251 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.26 | 0.025418 | 0.216506 | 0.000497 | 0.007081 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.29 | 0.059669 | 0.216303 | 0.000252 | 0.006423 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.23 | 0.018320 | 0.205270 | 0.000190 | 0.006645 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.3 | 0.062055 | 0.226078 | 0.000572 | 0.008114 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.25 | 0.037378 | 0.205280 | 0.000180 | 0.006603 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.31 | 0.066029 | 0.232578 | 0.000234 | 0.008998 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.29 | 0.071413 | 0.207383 | 0.000215 | 0.006817 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.25 | 0.021149 | 0.220976 | 0.000208 | 0.007204 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.26 | 0.065358 | 0.181233 | 0.000190 | 0.008415 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.25 | 0.026266 | 0.210570 | 0.000213 | 0.006870 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.28 | 0.063316 | 0.208185 | 0.000212 | 0.007580 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.3 | 0.057529 | 0.226022 | 0.000246 | 0.008633 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.26 | 0.019148 | 0.224651 | 0.000285 | 0.007911 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.3 | 0.060475 | 0.227461 | 0.000312 | 0.008958 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.26 | 0.024121 | 0.221404 | 0.000237 | 0.007331 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.28 | 0.064378 | 0.208051 | 0.000220 | 0.006729 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.3 | 0.052776 | 0.236481 | 0.000180 | 0.007833 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.25 | 0.016905 | 0.220381 | 0.000220 | 0.006913 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.26 | 0.021348 | 0.228946 | 0.000217 | 0.006443 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.27 | 0.018397 | 0.230504 | 0.000264 | 0.016232 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.3 | 0.060890 | 0.220197 | 0.000276 | 0.008309 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.28 | 0.056414 | 0.207036 | 0.000577 | 0.007657 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.25 | 0.023964 | 0.210942 | 0.000257 | 0.006748 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.28 | 0.058678 | 0.210421 | 0.000218 | 0.009285 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.31 | 0.067891 | 0.222159 | 0.000214 | 0.008583 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.24 | 0.021097 | 0.207859 | 0.000192 | 0.009002 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.27 | 0.064051 | 0.198839 | 0.000180 | 0.006596 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.28 | 0.059474 | 0.204687 | 0.000267 | 0.008330 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.29 | 0.070047 | 0.196234 | 0.000218 | 0.015145 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.24 | 0.016556 | 0.205885 | 0.000238 | 0.013875 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.28 | 0.069108 | 0.194438 | 0.000554 | 0.007655 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.22 | 0.009497 | 0.202380 | 0.000223 | 0.006774 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.29 | 0.068964 | 0.209801 | 0.000553 | 0.006908 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.29 | 0.066325 | 0.213376 | 0.000559 | 0.007381 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.3 | 0.072031 | 0.218846 | 0.000213 | 0.006969 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.27 | 0.059387 | 0.201999 | 0.000264 | 0.007731 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.26 | 0.054965 | 0.195072 | 0.000311 | 0.008232 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.24 | 0.024407 | 0.201299 | 0.000228 | 0.008693 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.24 | 0.065085 | 0.162220 | 0.000190 | 0.006980 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.21 | 0.018173 | 0.180344 | 0.000227 | 0.008507 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.19 | 0.064984 | 0.114472 | 0.000208 | 0.007240 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.17 | 0.024426 | 0.133789 | 0.000177 | 0.006184 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |