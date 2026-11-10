# OpenViking 检索阶段时延分析

## 1. 结论总览

平均检索HTTP耗时：**0.063146s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001048 | 1.659% |
| Query Embedding | 生成查询向量 | 0.049785 | 78.842% |
| 向量召回 | 召回语义相似记忆 | 0.006375 | 10.096% |
| 结果处理 | 整理候选并转换返回结构 | 0.000015 | 0.023% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005923 | 9.380% |
|  |  | 0.063146 | 100.000% |

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

父阶段平均耗时：**0.063146s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 查询准备 | 检查集合并准备查询 | 0.001048 | 1.659% |
| Query Embedding | 生成查询向量 | 0.049785 | 78.842% |
| 向量召回 | 召回语义相似记忆 | 0.006375 | 10.096% |
| 结果处理 | 整理候选并转换返回结构 | 0.000015 | 0.023% |
| HTTP边界与未细分余项 | HTTP耗时减去已计时内部阶段 | 0.005923 | 9.380% |
| 合计 |  | 0.063146 | 100.000% |

**结论：Query Embedding占78.842%，占比最大。**

### 3.2 查询准备

父阶段平均耗时：**0.001048s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 请求准备 | 解析请求并构造查询 | 0.000015 | 1.417% |
| 集合检查 | 检查目标集合与检索器 | 0.001033 | 98.583% |
| 合计 |  | 0.001048 | 100.000% |

**结论：集合检查占98.583%，占比最大。**

### 3.3 结果处理

父阶段平均耗时：**0.000015s/request**。

| 阶段 | 作用 | 平均耗时(s/request) | 占父阶段 |
|---|---|---:|---:|
| 候选处理 | 按记忆、资源和技能整理候选 | 0.000006 | 40.982% |
| 结构转换 | 构造接口返回对象 | 0.000002 | 11.116% |
| 结果处理内部 | 结果处理调度 | 0.000007 | 47.902% |
| 合计 |  | 0.000015 | 100.000% |

**结论：结果处理内部占47.902%，占比最大。**

### 3.4 检索到回答：已测阶段合计

父阶段平均耗时：**0.416916s/question**。

| 阶段 | 作用 | 平均耗时(s/question) | 占父阶段 |
|---|---|---:|---:|
| 客户端初始化 | 建立检索客户端 | 0.009741 | 2.336% |
| 记忆检索 | 查询相关记忆 | 0.047447 | 11.380% |
| 上下文筛选 | 选择候选记忆 | 0.000033 | 0.008% |
| 记忆读取 | 读取记忆正文 | 0.246993 | 59.244% |
| 重排 | 调整候选顺序 | 0.003700 | 0.887% |
| Prompt准备 | 构造回答输入 | 0.085640 | 20.541% |
| 回答LLM | 生成最终回答 | 0.023335 | 5.597% |
| 响应解析 | 解析回答结果 | 0.000028 | 0.007% |
| 合计 |  | 0.416916 | 100.000% |

**结论：记忆读取占59.243%，占比最大。**


## 4. 优化优先级

1. 优先降低Query Embedding延迟。
2. 回答链路优先降低回答LLM延迟。
3. 向量召回和结果整理无需优先优化。

## 附录

### A. 测试信息

| 项目 | 数据 |
|---|---|
| 工作负载 | LoCoMO sample0 |
| 测量日期 | 2026-11-10T19:11:51+08:00 |
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
| 检索耗时(s) | 0.063146 | 0.065683 | 0.075995 |

### F. 检索原始测量数据

| 序号 | 问题ID | Telemetry ID | 结果数 | 总耗时(s) | 请求准备(s) | 集合检查(s) | Embedding(s) | 向量召回(s) | 候选处理(s) | 结构转换(s) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | sample_0_qa0 | tm_d46e95ed27d14220918c582d6f1be767 | 39 | 0.038271 | 0.000020 | 0.002874 | 0.014442 | 0.010615 | 0.000008 | 0.000002 |
| 1 | sample_0_qa1 | tm_1795abe42e8e44b6a4394eb30632e7f5 | 39 | 0.043916 | 0.000013 | 0.001662 | 0.019471 | 0.012288 | 0.000006 | 0.000001 |
| 2 | sample_0_qa2 | tm_5d28cd9a94a24c0d93a04e32f89af87e | 39 | 0.042248 | 0.000016 | 0.002205 | 0.016701 | 0.013557 | 0.000005 | 0.000001 |
| 3 | sample_0_qa3 | tm_4a19c7df9ebf4b28aef7f2a8b8b68f25 | 39 | 0.040484 | 0.000013 | 0.000844 | 0.021686 | 0.006875 | 0.000006 | 0.000002 |
| 4 | sample_0_qa4 | tm_b490e24b5ac446e483198c861fee558b | 39 | 0.075859 | 0.000019 | 0.003134 | 0.054409 | 0.009011 | 0.000006 | 0.000002 |
| 5 | sample_0_qa5 | tm_984c5b7201b7472781bd19f91ff7b5ac | 39 | 0.076161 | 0.000014 | 0.002615 | 0.049916 | 0.016699 | 0.000005 | 0.000001 |
| 6 | sample_0_qa6 | tm_efe9916440bb4eb19d4e6b40eed7d4e6 | 39 | 0.073117 | 0.000018 | 0.001481 | 0.052062 | 0.012983 | 0.000006 | 0.000002 |
| 7 | sample_0_qa7 | tm_f95222ac18c4422ca782ac4e4f81a776 | 39 | 0.066886 | 0.000014 | 0.000459 | 0.056810 | 0.002948 | 0.000006 | 0.000002 |
| 8 | sample_0_qa8 | tm_20dc4120a34347269afafe1f0ae6aa26 | 39 | 0.076589 | 0.000017 | 0.002863 | 0.049414 | 0.015198 | 0.000006 | 0.000001 |
| 9 | sample_0_qa9 | tm_31924fa9091e4597b2a860c82b2cb35a | 39 | 0.075001 | 0.000014 | 0.001769 | 0.051597 | 0.014468 | 0.000006 | 0.000002 |
| 10 | sample_0_qa10 | tm_193035a57a8c404888f6779c534e7a81 | 39 | 0.068883 | 0.000014 | 0.001008 | 0.056452 | 0.004449 | 0.000006 | 0.000003 |
| 11 | sample_0_qa11 | tm_1006fa17b0f149aaa26f731e6843431b | 39 | 0.068862 | 0.000012 | 0.000470 | 0.054244 | 0.008672 | 0.000006 | 0.000002 |
| 12 | sample_0_qa12 | tm_673cdf8830234584a8b3eecdbbf888cc | 39 | 0.073877 | 0.000018 | 0.002497 | 0.053482 | 0.009930 | 0.000006 | 0.000001 |
| 13 | sample_0_qa13 | tm_6e2ab0e6f87c452e89c3de68eda234b8 | 39 | 0.068043 | 0.000013 | 0.001979 | 0.049109 | 0.009536 | 0.000007 | 0.000002 |
| 14 | sample_0_qa14 | tm_2a3d41262c7d4dd3b247f7b2c238d927 | 39 | 0.069320 | 0.000013 | 0.001240 | 0.051255 | 0.010388 | 0.000006 | 0.000001 |
| 15 | sample_0_qa15 | tm_6d3c4d2efc32477e811a6a146953b6a1 | 39 | 0.070906 | 0.000013 | 0.000428 | 0.055964 | 0.008830 | 0.000005 | 0.000001 |
| 16 | sample_0_qa16 | tm_ee6087020aeb454e8840f6f4a2609768 | 39 | 0.059514 | 0.000015 | 0.002940 | 0.046386 | 0.001221 | 0.000006 | 0.000002 |
| 17 | sample_0_qa17 | tm_557983e525ad4b58bcb01cdfa89d221c | 39 | 0.074129 | 0.000014 | 0.001764 | 0.056307 | 0.008715 | 0.000006 | 0.000001 |
| 18 | sample_0_qa18 | tm_e5860bd70b324fd48c87278ad708ba08 | 39 | 0.070127 | 0.000022 | 0.001025 | 0.053732 | 0.007802 | 0.000005 | 0.000002 |
| 19 | sample_0_qa19 | tm_b0ce16be15d141c9a420fe5ee3d687cf | 39 | 0.072575 | 0.000012 | 0.000529 | 0.051497 | 0.014734 | 0.000005 | 0.000001 |
| 20 | sample_0_qa20 | tm_7764a446809b4823a75aaea26dc3e27e | 39 | 0.059506 | 0.000017 | 0.000337 | 0.047160 | 0.001161 | 0.000006 | 0.000002 |
| 21 | sample_0_qa21 | tm_4dbd473dcf1a4d4baba5e470401104d2 | 39 | 0.069159 | 0.000017 | 0.001842 | 0.050363 | 0.009819 | 0.000006 | 0.000001 |
| 22 | sample_0_qa22 | tm_1c8a631968d94b7a8127c291dedd4093 | 39 | 0.064479 | 0.000014 | 0.001326 | 0.054798 | 0.002482 | 0.000006 | 0.000002 |
| 23 | sample_0_qa23 | tm_8d233afdcfa34df3b23e59a4bc0fd436 | 39 | 0.066838 | 0.000014 | 0.000393 | 0.052514 | 0.009205 | 0.000006 | 0.000001 |
| 24 | sample_0_qa24 | tm_03e4b8e6725f4d04b1f59a88c172b572 | 39 | 0.051844 | 0.000015 | 0.000265 | 0.046822 | 0.001136 | 0.000006 | 0.000002 |
| 25 | sample_0_qa25 | tm_8ed92fd868bc41b3b1ec7693280971c8 | 39 | 0.071445 | 0.000016 | 0.001792 | 0.052960 | 0.009720 | 0.000005 | 0.000001 |
| 26 | sample_0_qa26 | tm_7f9953485a964997ad6c89f4197c6bf6 | 39 | 0.055276 | 0.000013 | 0.001285 | 0.047408 | 0.001109 | 0.000006 | 0.000002 |
| 27 | sample_0_qa27 | tm_9c1b5229b77041f9b4117f30c43c173c | 39 | 0.065618 | 0.000014 | 0.000576 | 0.054548 | 0.005182 | 0.000006 | 0.000002 |
| 28 | sample_0_qa28 | tm_72daf046f11c426b826fd0f1ffaf5786 | 39 | 0.053197 | 0.000014 | 0.000268 | 0.047568 | 0.001947 | 0.000006 | 0.000002 |
| 29 | sample_0_qa29 | tm_dbb830c586d542a38b69582dbf3df162 | 39 | 0.059867 | 0.000016 | 0.000153 | 0.050265 | 0.001152 | 0.000007 | 0.000002 |
| 30 | sample_0_qa30 | tm_ab387770cfd4495bbdf836f4e625c6d9 | 39 | 0.066915 | 0.000016 | 0.001032 | 0.052543 | 0.007282 | 0.000007 | 0.000002 |
| 31 | sample_0_qa31 | tm_10136f2a4ef7449cb72cfb5cfbba73bc | 39 | 0.068120 | 0.000014 | 0.000271 | 0.054683 | 0.009584 | 0.000005 | 0.000001 |
| 32 | sample_0_qa32 | tm_aad80f1fbaf14fad9cf87b8a2914c317 | 39 | 0.055103 | 0.000016 | 0.000225 | 0.045946 | 0.005458 | 0.000006 | 0.000001 |
| 33 | sample_0_qa33 | tm_7f6b5b119b4443ba80e931201be2af40 | 39 | 0.051496 | 0.000016 | 0.000280 | 0.046811 | 0.000994 | 0.000006 | 0.000002 |
| 34 | sample_0_qa34 | tm_87cce2c32e194f0aa44666038e031a38 | 39 | 0.070729 | 0.000017 | 0.002025 | 0.055690 | 0.006694 | 0.000006 | 0.000001 |
| 35 | sample_0_qa35 | tm_b064484de33e469d9274339fb7297c8b | 39 | 0.065237 | 0.000013 | 0.001505 | 0.053301 | 0.004653 | 0.000006 | 0.000002 |
| 36 | sample_0_qa36 | tm_ce8525f341ed4e2caf5e917598d1b716 | 39 | 0.066134 | 0.000014 | 0.000596 | 0.050467 | 0.009634 | 0.000006 | 0.000001 |
| 37 | sample_0_qa37 | tm_12efd0191fbe472aa0135f6e93fb948b | 39 | 0.052412 | 0.000015 | 0.000221 | 0.046905 | 0.001788 | 0.000006 | 0.000002 |
| 38 | sample_0_qa38 | tm_65595954df4d47e7895402ffd261c371 | 39 | 0.077013 | 0.000017 | 0.001966 | 0.053836 | 0.014282 | 0.000006 | 0.000001 |
| 39 | sample_0_qa39 | tm_638dc35ba07142579fe34fd95f37891b | 39 | 0.068597 | 0.000013 | 0.001469 | 0.051632 | 0.009870 | 0.000007 | 0.000002 |
| 40 | sample_0_qa40 | tm_584f020549724965b7ef9750fdbec74e | 39 | 0.070135 | 0.000014 | 0.000592 | 0.055315 | 0.009075 | 0.000006 | 0.000001 |
| 41 | sample_0_qa41 | tm_8df635e53455483b97aa5d860a579f5e | 39 | 0.057233 | 0.000015 | 0.000257 | 0.046589 | 0.007144 | 0.000005 | 0.000001 |
| 42 | sample_0_qa42 | tm_391aceec46e240dea4a58b539a5d00d2 | 39 | 0.078023 | 0.000016 | 0.002921 | 0.053863 | 0.012182 | 0.000006 | 0.000001 |
| 43 | sample_0_qa43 | tm_4a5989bfb684485e988af3e8708a8fa8 | 39 | 0.068578 | 0.000014 | 0.001812 | 0.051553 | 0.007522 | 0.000007 | 0.000002 |
| 44 | sample_0_qa44 | tm_b61b2573612a443c90c4c9b78537a31b | 39 | 0.070379 | 0.000013 | 0.001122 | 0.049287 | 0.013324 | 0.000006 | 0.000001 |
| 45 | sample_0_qa45 | tm_203df55784dc4b258925ee5478dc39f9 | 39 | 0.070461 | 0.000012 | 0.000479 | 0.056313 | 0.007999 | 0.000006 | 0.000001 |
| 46 | sample_0_qa46 | tm_3245ec5dbad74d059e30c6e843eb3620 | 39 | 0.074527 | 0.000017 | 0.002876 | 0.053410 | 0.008575 | 0.000006 | 0.000001 |
| 47 | sample_0_qa47 | tm_ae3ee66e74444d9b8812ae647f1c60db | 39 | 0.068112 | 0.000014 | 0.001897 | 0.049064 | 0.009466 | 0.000006 | 0.000002 |
| 48 | sample_0_qa48 | tm_9c7550ba5b004da39814becc9a24557f | 39 | 0.071367 | 0.000013 | 0.001144 | 0.051184 | 0.012518 | 0.000006 | 0.000001 |
| 49 | sample_0_qa49 | tm_a1e03f3dadae454d8974cdc9325ce0b9 | 39 | 0.071501 | 0.000013 | 0.000504 | 0.055904 | 0.009373 | 0.000006 | 0.000001 |
| 50 | sample_0_qa50 | tm_6f9ccd02dafe451d87fc03ff1a5fa490 | 39 | 0.078097 | 0.000015 | 0.002854 | 0.054164 | 0.011682 | 0.000006 | 0.000001 |
| 51 | sample_0_qa51 | tm_288a55ae3b8041f483a77b74da048ccf | 39 | 0.071975 | 0.000013 | 0.001704 | 0.049768 | 0.012962 | 0.000006 | 0.000002 |
| 52 | sample_0_qa52 | tm_e84fb6de33484b57ae428cb6004c6144 | 39 | 0.068682 | 0.000013 | 0.000970 | 0.051672 | 0.008964 | 0.000007 | 0.000002 |
| 53 | sample_0_qa53 | tm_be7211ef5c7f43178d15ceec3662fac2 | 39 | 0.070041 | 0.000012 | 0.000444 | 0.056436 | 0.007593 | 0.000006 | 0.000001 |
| 54 | sample_0_qa54 | tm_acfd9c0fddeb4bc1a30c0cc3ae4a557c | 39 | 0.077116 | 0.000016 | 0.002518 | 0.054301 | 0.012265 | 0.000005 | 0.000002 |
| 55 | sample_0_qa55 | tm_dfddb214cdec4586a3bb7ff436e27826 | 39 | 0.072083 | 0.000013 | 0.002015 | 0.049833 | 0.013124 | 0.000006 | 0.000001 |
| 56 | sample_0_qa56 | tm_a1997acaea14400290e38e76e4b39573 | 39 | 0.067271 | 0.000014 | 0.001259 | 0.051992 | 0.007429 | 0.000007 | 0.000002 |
| 57 | sample_0_qa57 | tm_9a9daf2988884f23b9d2fb1421aa534d | 39 | 0.070790 | 0.000013 | 0.000439 | 0.056747 | 0.007911 | 0.000005 | 0.000002 |
| 58 | sample_0_qa58 | tm_027f81a931274450b6477e26964c0b0e | 39 | 0.076529 | 0.000016 | 0.003214 | 0.053470 | 0.010361 | 0.000005 | 0.000001 |
| 59 | sample_0_qa59 | tm_aff49866a5ad46db8863fa43ff0cc975 | 39 | 0.069828 | 0.000015 | 0.001958 | 0.048935 | 0.009965 | 0.000006 | 0.000002 |
| 60 | sample_0_qa60 | tm_9eae3e2a52354425ab66f876b0458e35 | 39 | 0.070082 | 0.000015 | 0.001067 | 0.051053 | 0.010953 | 0.000006 | 0.000001 |
| 61 | sample_0_qa61 | tm_04dc981ab2464a318b7add24fdd419e1 | 39 | 0.071249 | 0.000013 | 0.000547 | 0.055819 | 0.009189 | 0.000006 | 0.000001 |
| 62 | sample_0_qa62 | tm_91ddd8c30d314c7e8585b53901f029e7 | 39 | 0.073690 | 0.000016 | 0.002468 | 0.054112 | 0.008687 | 0.000006 | 0.000001 |
| 63 | sample_0_qa63 | tm_d72ddd4b7358476380debaa79c6ebfe3 | 39 | 0.073433 | 0.000013 | 0.001956 | 0.049705 | 0.014767 | 0.000005 | 0.000001 |
| 64 | sample_0_qa64 | tm_4f53e3b04aff42beb5202a0ff6467b5c | 39 | 0.067550 | 0.000013 | 0.001212 | 0.051895 | 0.007490 | 0.000006 | 0.000002 |
| 65 | sample_0_qa65 | tm_186431dbde154b199a93ae66945cb049 | 39 | 0.071978 | 0.000013 | 0.000427 | 0.056580 | 0.009313 | 0.000005 | 0.000001 |
| 66 | sample_0_qa66 | tm_bd0d2af547a643038f6261c086d5a311 | 39 | 0.074651 | 0.000017 | 0.002944 | 0.054250 | 0.008577 | 0.000005 | 0.000001 |
| 67 | sample_0_qa67 | tm_242efe87f5a24306a2e8e4f470c9571c | 39 | 0.070112 | 0.000014 | 0.001749 | 0.049808 | 0.010723 | 0.000006 | 0.000002 |
| 68 | sample_0_qa68 | tm_3ec3bd829b1043edafbb07cf495b18fa | 39 | 0.071724 | 0.000014 | 0.001014 | 0.051939 | 0.012400 | 0.000006 | 0.000001 |
| 69 | sample_0_qa69 | tm_7af680a3d1e8467aa4441949f2770f3a | 39 | 0.072218 | 0.000012 | 0.000477 | 0.056683 | 0.009444 | 0.000006 | 0.000001 |
| 70 | sample_0_qa70 | tm_ce8ac573dc3d467595fb6531991a623b | 39 | 0.073373 | 0.000016 | 0.002801 | 0.053397 | 0.008600 | 0.000006 | 0.000001 |
| 71 | sample_0_qa71 | tm_346b9edad0c343b38430abe75174752a | 39 | 0.073189 | 0.000013 | 0.002300 | 0.049032 | 0.014474 | 0.000006 | 0.000001 |
| 72 | sample_0_qa72 | tm_85e0815e86174f759d06bddf510e0ef4 | 39 | 0.066996 | 0.000014 | 0.000980 | 0.051176 | 0.007317 | 0.000006 | 0.000002 |
| 73 | sample_0_qa73 | tm_c4ca82bfb2c14fb88e4487b76a9c4bb9 | 39 | 0.071322 | 0.000013 | 0.000457 | 0.055907 | 0.009149 | 0.000005 | 0.000001 |
| 74 | sample_0_qa74 | tm_69ee54fc8ab64aaca54d6ef664ad41d7 | 39 | 0.078308 | 0.000016 | 0.003045 | 0.052412 | 0.013984 | 0.000005 | 0.000001 |
| 75 | sample_0_qa75 | tm_b5d3f69f6627466e8f75b1d5a6ae8c6d | 39 | 0.073581 | 0.000014 | 0.001752 | 0.053482 | 0.009792 | 0.000005 | 0.000002 |
| 76 | sample_0_qa76 | tm_e3074a83d2ac46c6b9261862ef6c0246 | 39 | 0.068136 | 0.000013 | 0.001007 | 0.048573 | 0.009786 | 0.000006 | 0.000002 |
| 77 | sample_0_qa77 | tm_18c092c7314e4a088c55b418ff9e19d5 | 39 | 0.068906 | 0.000012 | 0.000486 | 0.055603 | 0.005905 | 0.000006 | 0.000002 |
| 78 | sample_0_qa78 | tm_dfa636c782da4e7d8fa7e0e0b0ef0e66 | 39 | 0.074302 | 0.000017 | 0.002587 | 0.054068 | 0.008695 | 0.000006 | 0.000001 |
| 79 | sample_0_qa79 | tm_4bb50e6423214f99bbfd72989f85f68f | 39 | 0.068816 | 0.000013 | 0.002093 | 0.049716 | 0.009674 | 0.000007 | 0.000002 |
| 80 | sample_0_qa80 | tm_c1ba84ba1b2d4b19bbc60a56ef583104 | 39 | 0.071891 | 0.000013 | 0.001387 | 0.051840 | 0.012523 | 0.000006 | 0.000001 |
| 81 | sample_0_qa81 | tm_125b8bddbe18476d89a8e110733b91fd | 39 | 0.071877 | 0.000013 | 0.000475 | 0.056513 | 0.009326 | 0.000005 | 0.000001 |
| 82 | sample_0_qa82 | tm_e90e8c61124147adbf842e5428e46f99 | 39 | 0.071634 | 0.000016 | 0.003022 | 0.054009 | 0.005032 | 0.000006 | 0.000002 |
| 83 | sample_0_qa83 | tm_09d64eaceca046b0a7ea653ac35718ce | 39 | 0.071316 | 0.000014 | 0.001962 | 0.049647 | 0.012648 | 0.000006 | 0.000001 |
| 84 | sample_0_qa84 | tm_5e70a2281a2f4803aab98115ddf020de | 39 | 0.071284 | 0.000015 | 0.001030 | 0.051784 | 0.012018 | 0.000006 | 0.000001 |
| 85 | sample_0_qa85 | tm_596fc9d87bb8413c8f80baca4472acdc | 39 | 0.071210 | 0.000013 | 0.000463 | 0.056503 | 0.008756 | 0.000005 | 0.000001 |
| 86 | sample_0_qa86 | tm_478573f3399344ac83353178f08c8572 | 39 | 0.058942 | 0.000016 | 0.002966 | 0.046321 | 0.000997 | 0.000006 | 0.000002 |
| 87 | sample_0_qa87 | tm_6df2e45349d74b709cd32c015f837298 | 39 | 0.071286 | 0.000014 | 0.001739 | 0.049926 | 0.010573 | 0.000006 | 0.000002 |
| 88 | sample_0_qa88 | tm_b8932d80c395466c957096e08026bc93 | 39 | 0.073294 | 0.000014 | 0.001068 | 0.054812 | 0.009705 | 0.000006 | 0.000001 |
| 89 | sample_0_qa89 | tm_5b1aba87a37646b8b36c3fa2c91cab72 | 39 | 0.070005 | 0.000013 | 0.000575 | 0.052045 | 0.010504 | 0.000006 | 0.000002 |
| 90 | sample_0_qa90 | tm_deeddf2b09314d39a0352a18d29cc2d5 | 39 | 0.060120 | 0.000015 | 0.000212 | 0.048069 | 0.001070 | 0.000006 | 0.000002 |
| 91 | sample_0_qa91 | tm_e003c62408c8473e8c6a8c779e18eede | 39 | 0.060008 | 0.000014 | 0.002072 | 0.049339 | 0.002056 | 0.000006 | 0.000002 |
| 92 | sample_0_qa92 | tm_20c3b5ac2dde4710a4166bf8fbf621de | 39 | 0.059878 | 0.000013 | 0.001055 | 0.047154 | 0.006066 | 0.000006 | 0.000002 |
| 93 | sample_0_qa93 | tm_205a6720c0aa4591b512c2773d9b5c17 | 39 | 0.069271 | 0.000014 | 0.000361 | 0.057316 | 0.006899 | 0.000006 | 0.000002 |
| 94 | sample_0_qa94 | tm_dc58aafa02e24bd4916bce911e890a52 | 39 | 0.051682 | 0.000015 | 0.000265 | 0.046884 | 0.001073 | 0.000006 | 0.000002 |
| 95 | sample_0_qa95 | tm_0c21408d50a94a1f880a0a3baaf391f7 | 39 | 0.056677 | 0.000016 | 0.001182 | 0.047297 | 0.001067 | 0.000006 | 0.000002 |
| 96 | sample_0_qa96 | tm_b7be831166ea4c7185fc4af0b6400804 | 39 | 0.066930 | 0.000013 | 0.000422 | 0.052310 | 0.007329 | 0.000006 | 0.000002 |
| 97 | sample_0_qa97 | tm_6634fe639767464a81a06f411c9d54cc | 39 | 0.057534 | 0.000016 | 0.000141 | 0.048168 | 0.006006 | 0.000005 | 0.000001 |
| 98 | sample_0_qa98 | tm_ebc63f07d95f493a929ee453f3f14d27 | 39 | 0.051938 | 0.000018 | 0.000240 | 0.046990 | 0.001080 | 0.000006 | 0.000002 |
| 99 | sample_0_qa99 | tm_96155e2467e1450091123a22b5b5b541 | 39 | 0.055762 | 0.000016 | 0.002422 | 0.046441 | 0.000977 | 0.000006 | 0.000002 |
| 100 | sample_0_qa100 | tm_8bbb25fe54a746ab8d36efbf5448f779 | 39 | 0.060590 | 0.000016 | 0.001026 | 0.051063 | 0.003678 | 0.000006 | 0.000001 |
| 101 | sample_0_qa101 | tm_423f2644fe474b0aa29ae3c8df87468e | 39 | 0.057207 | 0.000013 | 0.000294 | 0.048701 | 0.004201 | 0.000006 | 0.000002 |
| 102 | sample_0_qa102 | tm_18c6c3f8594f4a988a51aa7411f00f7e | 39 | 0.052253 | 0.000017 | 0.000256 | 0.047043 | 0.001426 | 0.000006 | 0.000002 |
| 103 | sample_0_qa103 | tm_c02f8a7050894407b6b9a5f4dbe03bbc | 39 | 0.052073 | 0.000014 | 0.000261 | 0.047342 | 0.001070 | 0.000006 | 0.000002 |
| 104 | sample_0_qa104 | tm_7bd1354228ea405d84604f4c36db939f | 39 | 0.064398 | 0.000016 | 0.001005 | 0.052471 | 0.006333 | 0.000006 | 0.000001 |
| 105 | sample_0_qa105 | tm_1b073edfdcb84584b91353c07d798df8 | 39 | 0.058586 | 0.000013 | 0.000289 | 0.050261 | 0.003681 | 0.000006 | 0.000002 |
| 106 | sample_0_qa106 | tm_52f50d888c3c4e9b8b685f2b3595dbec | 39 | 0.059903 | 0.000016 | 0.000189 | 0.047246 | 0.009129 | 0.000006 | 0.000002 |
| 107 | sample_0_qa107 | tm_71371f7e1b474c67be5f53f13ef39a43 | 39 | 0.051836 | 0.000016 | 0.000268 | 0.046892 | 0.001079 | 0.000006 | 0.000002 |
| 108 | sample_0_qa108 | tm_dbd6a1a1963546418be8734a06c7946b | 39 | 0.056807 | 0.000016 | 0.001139 | 0.046723 | 0.001138 | 0.000006 | 0.000002 |
| 109 | sample_0_qa109 | tm_452d736b36f14325b6150ffbc63a5be7 | 39 | 0.066427 | 0.000013 | 0.000278 | 0.052195 | 0.009677 | 0.000006 | 0.000001 |
| 110 | sample_0_qa110 | tm_116653b837b34fb4a6128177c8cddf27 | 39 | 0.055696 | 0.000016 | 0.000162 | 0.046863 | 0.004882 | 0.000006 | 0.000002 |
| 111 | sample_0_qa111 | tm_b7df01b4f22345fb871294d899c8ca46 | 39 | 0.053481 | 0.000016 | 0.000271 | 0.048029 | 0.001529 | 0.000006 | 0.000002 |
| 112 | sample_0_qa112 | tm_9c6054bd357448ae82e1f0710185bc77 | 39 | 0.055215 | 0.000016 | 0.000251 | 0.045913 | 0.000888 | 0.000006 | 0.000002 |
| 113 | sample_0_qa113 | tm_6d423ea017ea4fd2bce4472b7b444364 | 39 | 0.055326 | 0.000016 | 0.000987 | 0.048398 | 0.001040 | 0.000006 | 0.000002 |
| 114 | sample_0_qa114 | tm_4d7f69e0d90342d683c364e8d1e1ad73 | 39 | 0.065076 | 0.000013 | 0.000276 | 0.053631 | 0.007300 | 0.000006 | 0.000002 |
| 115 | sample_0_qa115 | tm_f6a0930f3f454348b3007b40057ed2a1 | 39 | 0.055554 | 0.000016 | 0.000197 | 0.046085 | 0.005920 | 0.000006 | 0.000001 |
| 116 | sample_0_qa116 | tm_5c0845c3af804301b51dac3dfa6cc084 | 39 | 0.052314 | 0.000014 | 0.000245 | 0.047706 | 0.001078 | 0.000006 | 0.000002 |
| 117 | sample_0_qa117 | tm_b8691d4a0efe44fe85ceec22d5d10499 | 39 | 0.056250 | 0.000016 | 0.002800 | 0.046439 | 0.001236 | 0.000006 | 0.000002 |
| 118 | sample_0_qa118 | tm_d8973bd6322847938b7fa88d96d3f484 | 39 | 0.065747 | 0.000016 | 0.001023 | 0.055538 | 0.004027 | 0.000006 | 0.000002 |
| 119 | sample_0_qa119 | tm_2cdb93a1f79f4f0cbf7a7c43aa7da00a | 39 | 0.061646 | 0.000013 | 0.000275 | 0.053328 | 0.003771 | 0.000006 | 0.000002 |
| 120 | sample_0_qa120 | tm_29a154e31bbe44928965658d88909ff9 | 39 | 0.056071 | 0.000018 | 0.000230 | 0.050989 | 0.001145 | 0.000006 | 0.000002 |
| 121 | sample_0_qa121 | tm_8bc0db15c8b4439e968163bc369fc18d | 39 | 0.051329 | 0.000016 | 0.000181 | 0.046551 | 0.001033 | 0.000006 | 0.000002 |
| 122 | sample_0_qa122 | tm_666568a35b9240b8bd858ee2aa732371 | 39 | 0.061513 | 0.000016 | 0.000981 | 0.049764 | 0.006037 | 0.000006 | 0.000001 |
| 123 | sample_0_qa123 | tm_a6c114f994c64c1488bea972aeffe0d2 | 39 | 0.058032 | 0.000014 | 0.000263 | 0.051869 | 0.002033 | 0.000007 | 0.000002 |
| 124 | sample_0_qa124 | tm_261abe507fc849bfa81ca2e25217bcbe | 39 | 0.051965 | 0.000015 | 0.000244 | 0.046601 | 0.001712 | 0.000007 | 0.000002 |
| 125 | sample_0_qa125 | tm_5ccf0ad2fd0b4592a1b8fe445450fbba | 39 | 0.056206 | 0.000014 | 0.000225 | 0.051446 | 0.001118 | 0.000007 | 0.000002 |
| 126 | sample_0_qa126 | tm_a0a0632e4c6148d6a7dfddfd3f10e499 | 39 | 0.052720 | 0.000017 | 0.001050 | 0.045837 | 0.001081 | 0.000007 | 0.000002 |
| 127 | sample_0_qa127 | tm_e3cc5a5469574fde88c944f95a75c924 | 39 | 0.059178 | 0.000014 | 0.000307 | 0.051170 | 0.003931 | 0.000006 | 0.000001 |
| 128 | sample_0_qa128 | tm_28b0af49f2bb4ce0a1a48f504a2497cf | 39 | 0.055462 | 0.000014 | 0.000219 | 0.048246 | 0.003637 | 0.000006 | 0.000001 |
| 129 | sample_0_qa129 | tm_8f5f8d2fda744bc49206ee53b7f9b6cd | 39 | 0.051702 | 0.000016 | 0.000228 | 0.046849 | 0.001081 | 0.000006 | 0.000002 |
| 130 | sample_0_qa130 | tm_700635381c93402eac748894e891ae3e | 39 | 0.052201 | 0.000014 | 0.000294 | 0.044920 | 0.001514 | 0.000007 | 0.000002 |
| 131 | sample_0_qa131 | tm_9a063ac211804631b8fc11e1548de3da | 39 | 0.056051 | 0.000015 | 0.000391 | 0.048723 | 0.001364 | 0.000007 | 0.000002 |
| 132 | sample_0_qa132 | tm_aed18d0952344f8785e95342c28367b0 | 39 | 0.056526 | 0.000014 | 0.000152 | 0.049054 | 0.003907 | 0.000007 | 0.000002 |
| 133 | sample_0_qa133 | tm_f17713ddb52e4aa791567d6edef4b3be | 39 | 0.055830 | 0.000016 | 0.000157 | 0.050936 | 0.001150 | 0.000006 | 0.000002 |
| 134 | sample_0_qa134 | tm_10c5f3367b394fa998570ae6185d1b4b | 39 | 0.051385 | 0.000016 | 0.000260 | 0.046405 | 0.001157 | 0.000007 | 0.000002 |
| 135 | sample_0_qa135 | tm_8611a2cbc55f4f14afaa0e6203b19681 | 39 | 0.055402 | 0.000016 | 0.000174 | 0.048596 | 0.001070 | 0.000006 | 0.000002 |
| 136 | sample_0_qa136 | tm_13126ac3203746fab44043f340123694 | 39 | 0.055700 | 0.000016 | 0.000149 | 0.047679 | 0.004521 | 0.000006 | 0.000002 |
| 137 | sample_0_qa137 | tm_c700a5979cfc486382169b843e522c15 | 39 | 0.053658 | 0.000018 | 0.000206 | 0.047226 | 0.002759 | 0.000006 | 0.000002 |
| 138 | sample_0_qa138 | tm_7bf068b8c0924ab6a1c76adb73f610dc | 39 | 0.051752 | 0.000016 | 0.000163 | 0.046947 | 0.001077 | 0.000007 | 0.000002 |
| 139 | sample_0_qa139 | tm_a074ba3715cf4537aa577a3f39fd1c87 | 39 | 0.052088 | 0.000016 | 0.000175 | 0.045177 | 0.001364 | 0.000006 | 0.000002 |
| 140 | sample_0_qa140 | tm_617dca259c86487e8e528259cbfe575c | 39 | 0.055193 | 0.000016 | 0.000193 | 0.050375 | 0.001109 | 0.000006 | 0.000002 |
| 141 | sample_0_qa141 | tm_c34c235282be478b9a76293246df5447 | 39 | 0.053951 | 0.000015 | 0.000150 | 0.046525 | 0.003788 | 0.000007 | 0.000002 |
| 142 | sample_0_qa142 | tm_e2420e2effc34577a543b5e082cb9a5f | 39 | 0.051688 | 0.000016 | 0.000168 | 0.047187 | 0.000971 | 0.000006 | 0.000002 |
| 143 | sample_0_qa143 | tm_5d665e524b2244f6aa04000d20c2c82f | 39 | 0.052286 | 0.000016 | 0.000217 | 0.046993 | 0.001564 | 0.000007 | 0.000002 |
| 144 | sample_0_qa144 | tm_6a87487e331f4f6198f9aa51c683d10c | 39 | 0.051851 | 0.000015 | 0.000432 | 0.044863 | 0.001112 | 0.000007 | 0.000002 |
| 145 | sample_0_qa145 | tm_9121d11b8865496d8c2bcfd34f7a9c20 | 39 | 0.052860 | 0.000015 | 0.000161 | 0.047959 | 0.001483 | 0.000006 | 0.000002 |
| 146 | sample_0_qa146 | tm_2838a5d7558644a6ae15bb86cc964668 | 39 | 0.052358 | 0.000015 | 0.000162 | 0.047336 | 0.001419 | 0.000006 | 0.000002 |
| 147 | sample_0_qa147 | tm_af07f2bb65d5418daf7c25b5a51df361 | 39 | 0.050993 | 0.000016 | 0.000171 | 0.046413 | 0.000984 | 0.000006 | 0.000002 |
| 148 | sample_0_qa148 | tm_58bbf7a7097542858fc0ac13d8f1283c | 39 | 0.056216 | 0.000018 | 0.000161 | 0.051218 | 0.001203 | 0.000007 | 0.000002 |
| 149 | sample_0_qa149 | tm_4694658750ab43b080f25f6b1637c845 | 39 | 0.052880 | 0.000015 | 0.000152 | 0.047940 | 0.001198 | 0.000007 | 0.000002 |
| 150 | sample_0_qa150 | tm_f853f620cba14f5eb761cf666a308718 | 39 | 0.051696 | 0.000014 | 0.000177 | 0.046972 | 0.001102 | 0.000007 | 0.000002 |
| 151 | sample_0_qa151 | tm_2cfaed88594441a9b8e41a9c60ced22a | 39 | 0.052402 | 0.000014 | 0.000262 | 0.047191 | 0.001181 | 0.000007 | 0.000002 |

问答端到端平均耗时：0.417171s/question。原始time_cost按0.01s记录；3.4按未舍入的各阶段计时求和。


### G. 问答原始测量数据

| 序号 | 问题ID | 问题 | 标准答案 | 模型回答 | 总耗时(s) | 检索(s) | 读取(s) | Prompt(s) | 回答LLM(s) | Prompt Token | 记忆Token | 评分 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| 0 | sample_0_qa0 | When did Caroline go to the LGBTQ support group? | 7 May 2023 | Based on the provided context, the answer is not stated. | 2.29 | 0.016930 | 0.251115 | 1.622202 | 0.288993 | 3635 | 1762 |  |
| 1 | sample_0_qa1 | When did Melanie paint a sunrise? | 2022 | Based on the provided context, the answer is not stated. | 2.29 | 0.018859 | 0.260802 | 1.622915 | 0.287895 | 3631 | 1762 |  |
| 2 | sample_0_qa2 | What fields would Caroline be likely to pursue in her educaton? | Psychology, counseling certification | Based on the provided context, the answer is not stated. | 2.29 | 0.041204 | 0.225564 | 1.623235 | 0.286417 | 3639 | 1762 |  |
| 3 | sample_0_qa3 | What did Caroline research? | Adoption agencies | Based on the provided context, the answer is not stated. | 2.29 | 0.077585 | 0.206251 | 1.624414 | 0.285000 | 3630 | 1762 |  |
| 4 | sample_0_qa4 | What is Caroline's identity? | Transgender woman | Based on the provided context, the answer is not stated. | 2.29 | 0.031984 | 0.203813 | 1.621805 | 0.288716 | 3630 | 1762 |  |
| 5 | sample_0_qa5 | When did Melanie run a charity race? | The sunday before 25 May 2023 | Based on the provided context, the answer is not stated. | 2.29 | 0.091460 | 0.181633 | 1.623746 | 0.286636 | 3632 | 1762 |  |
| 6 | sample_0_qa6 | When is Melanie planning on going camping? | June 2023 | Based on the provided context, the answer is not stated. | 2.29 | 0.075619 | 0.206722 | 1.624128 | 0.286040 | 3634 | 1762 |  |
| 7 | sample_0_qa7 | What is Caroline's relationship status? | Single | Based on the provided context, the answer is not stated. | 2.29 | 0.034879 | 0.215837 | 1.622535 | 0.287588 | 3633 | 1762 |  |
| 8 | sample_0_qa8 | When did Caroline give a speech at a school? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.47 | 0.011248 | 0.445309 | 0.000192 | 0.008792 | 3634 | 1762 |  |
| 9 | sample_0_qa9 | When did Caroline meet up with her friends, family, and mentors? | The week before 9 June 2023 | Based on the provided context, the answer is not stated. | 0.51 | 0.038519 | 0.426298 | 0.000153 | 0.015863 | 3639 | 1762 |  |
| 10 | sample_0_qa10 | How long has Caroline had her current group of friends for? | 4 years | Based on the provided context, the answer is not stated. | 0.57 | 0.102682 | 0.427250 | 0.000186 | 0.007776 | 3638 | 1762 |  |
| 11 | sample_0_qa11 | Where did Caroline move from 4 years ago? | Sweden | Based on the provided context, the answer is not stated. | 0.56 | 0.095769 | 0.421978 | 0.000186 | 0.007354 | 3633 | 1762 |  |
| 12 | sample_0_qa12 | How long ago was Caroline's 18th birthday? | 10 years ago | Based on the provided context, the answer is not stated. | 0.51 | 0.044132 | 0.419391 | 0.000167 | 0.015046 | 3634 | 1762 |  |
| 13 | sample_0_qa13 | What career path has Caroline decided to persue? | counseling or mental health for Transgender people | Based on the provided context, the answer is not stated. | 0.58 | 0.097844 | 0.438601 | 0.000177 | 0.007573 | 3635 | 1762 |  |
| 14 | sample_0_qa14 | Would Caroline still want to pursue counseling as a career if she hadn't received support growing up? | Likely no | Based on the provided context, the answer is not stated. | 0.51 | 0.042424 | 0.420522 | 0.000175 | 0.013350 | 3648 | 1762 |  |
| 15 | sample_0_qa15 | What activities does Melanie partake in? | pottery, camping, painting, swimming | Based on the provided context, the answer is not stated. | 0.51 | 0.053407 | 0.412788 | 0.000195 | 0.013636 | 3633 | 1762 |  |
| 16 | sample_0_qa16 | When did Melanie sign up for a pottery class? | 2 July 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.021630 | 0.227612 | 0.000182 | 0.006728 | 3634 | 1762 |  |
| 17 | sample_0_qa17 | When is Caroline going to the transgender conference? | July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.011088 | 0.249980 | 0.000417 | 0.009131 | 3636 | 1762 |  |
| 18 | sample_0_qa18 | Where has Melanie camped? | beach, mountains, forest | Based on the provided context, the answer is not stated. | 0.37 | 0.074826 | 0.263215 | 0.000424 | 0.012112 | 3629 | 1762 |  |
| 19 | sample_0_qa19 | What do Melanie's kids like? | dinosaurs, nature | Based on the provided context, the answer is not stated. | 0.28 | 0.031513 | 0.216598 | 0.000442 | 0.007553 | 3630 | 1762 |  |
| 20 | sample_0_qa20 | When did Melanie go to the museum? | 5 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.034701 | 0.263675 | 0.000479 | 0.009245 | 3632 | 1762 |  |
| 21 | sample_0_qa21 | When did Caroline have a picnic? | The week before 6 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.074299 | 0.234502 | 0.000181 | 0.011540 | 3631 | 1762 |  |
| 22 | sample_0_qa22 | Would Caroline likely have Dr. Seuss books on her bookshelf? | Yes, since she collects classic children's books | Based on the provided context, the answer is not stated. | 0.31 | 0.064444 | 0.232218 | 0.000171 | 0.011358 | 3638 | 1762 |  |
| 23 | sample_0_qa23 | What books has Melanie read? | "Nothing is Impossible", "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.28 | 0.024005 | 0.245737 | 0.000153 | 0.008685 | 3630 | 1762 |  |
| 24 | sample_0_qa24 | What does Melanie do to destress? | Running, pottery | Based on the provided context, the answer is not stated. | 0.3 | 0.021043 | 0.267591 | 0.000174 | 0.007981 | 3631 | 1762 |  |
| 25 | sample_0_qa25 | When did Caroline go to the LGBTQ conference? | 10 July 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.012528 | 0.251356 | 0.000164 | 0.006865 | 3634 | 1762 |  |
| 26 | sample_0_qa26 | When did Melanie read the book "nothing is impossible"? | 2022 | Based on the provided context, the answer is not stated. | 0.35 | 0.080059 | 0.248248 | 0.000416 | 0.006428 | 3637 | 1762 |  |
| 27 | sample_0_qa27 | Would Caroline pursue writing as a career option? | LIkely no; though she likes reading, she wants to be a counselor | Based on the provided context, the answer is not stated. | 0.27 | 0.014849 | 0.246367 | 0.000177 | 0.008205 | 3635 | 1762 |  |
| 28 | sample_0_qa28 | When did Caroline go to the adoption meeting? | The friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.058490 | 0.237546 | 0.000421 | 0.006828 | 3634 | 1762 |  |
| 29 | sample_0_qa29 | When did Melanie go to the pottery workshop? | The Friday before 15 July 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.057250 | 0.241954 | 0.000456 | 0.010981 | 3634 | 1762 |  |
| 30 | sample_0_qa30 | Would Melanie be considered a member of the LGBTQ community? | Likely no, she does not refer to herself as part of it | Based on the provided context, the answer is not stated. | 0.3 | 0.030174 | 0.243359 | 0.000185 | 0.006733 | 3638 | 1762 |  |
| 31 | sample_0_qa31 | When did Melanie go camping in June? | The week before 27 June 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.069838 | 0.243535 | 0.000433 | 0.007878 | 3632 | 1762 |  |
| 32 | sample_0_qa32 | What LGBTQ+ events has Caroline participated in? | Pride parade, school speech, support group | Based on the provided context, the answer is not stated. | 0.28 | 0.021523 | 0.241143 | 0.000181 | 0.008318 | 3635 | 1762 |  |
| 33 | sample_0_qa33 | When did Caroline go to a pride parade during the summer? | The week before 3 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.067510 | 0.248336 | 0.000183 | 0.010292 | 3637 | 1762 |  |
| 34 | sample_0_qa34 | What events has Caroline participated in to help children? | Mentoring program, school speech | Based on the provided context, the answer is not stated. | 0.32 | 0.068460 | 0.239506 | 0.000182 | 0.006715 | 3638 | 1762 |  |
| 35 | sample_0_qa35 | When did Melanie go camping in July? | two weekends before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.27 | 0.019078 | 0.234185 | 0.000175 | 0.008408 | 3632 | 1762 |  |
| 36 | sample_0_qa36 | When did Caroline join a mentorship program? | The weekend before 17 July 2023 | Based on the provided context, the answer is not stated. | 0.33 | 0.070666 | 0.235033 | 0.000176 | 0.018947 | 3634 | 1762 |  |
| 37 | sample_0_qa37 | What did Melanie paint recently? | sunset | Based on the provided context, the answer is not stated. | 0.3 | 0.070544 | 0.214573 | 0.000171 | 0.011863 | 3631 | 1762 |  |
| 38 | sample_0_qa38 | What activities has Melanie done with her family? | Pottery, painting, camping, museum, swimming, hiking | Based on the provided context, the answer is not stated. | 0.28 | 0.032719 | 0.228940 | 0.000160 | 0.010042 | 3635 | 1762 |  |
| 39 | sample_0_qa39 | In what ways is Caroline participating in the LGBTQ community? | Joining activist group, going to pride parades, participating in an art show, mentoring program | Based on the provided context, the answer is not stated. | 0.33 | 0.070514 | 0.242680 | 0.000181 | 0.008704 | 3639 | 1762 |  |
| 40 | sample_0_qa40 | How many times has Melanie gone to the beach in 2023? | 2 | Based on the provided context, the answer is not stated. | 0.29 | 0.028832 | 0.249834 | 0.000460 | 0.008403 | 3636 | 1762 |  |
| 41 | sample_0_qa41 | When did Caroline join a new activist group? | The Tuesday before 20 July 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.010542 | 0.238047 | 0.000217 | 0.007120 | 3634 | 1762 |  |
| 42 | sample_0_qa42 | Would Melanie be more interested in going to a national park or a theme park? | National park; she likes the outdoors | Based on the provided context, the answer is not stated. | 0.35 | 0.076294 | 0.249715 | 0.000171 | 0.009109 | 3642 | 1762 |  |
| 43 | sample_0_qa43 | What kind of art does Caroline make? | abstract art | Based on the provided context, the answer is not stated. | 0.3 | 0.027150 | 0.263739 | 0.000181 | 0.007694 | 3632 | 1762 |  |
| 44 | sample_0_qa44 | When is Melanie's daughter's birthday? | 13 August | Based on the provided context, the answer is not stated. | 0.33 | 0.064544 | 0.253699 | 0.000177 | 0.007517 | 3633 | 1762 |  |
| 45 | sample_0_qa45 | When did Caroline attend a pride parade in August? | The Friday before 14 August 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.031698 | 0.224465 | 0.000161 | 0.006612 | 3636 | 1762 |  |
| 46 | sample_0_qa46 | Would Melanie be considered an ally to the transgender community? | Yes, she is supportive | Based on the provided context, the answer is not stated. | 0.29 | 0.033454 | 0.237916 | 0.000181 | 0.008004 | 3639 | 1762 |  |
| 47 | sample_0_qa47 | Who supports Caroline when she has a negative experience? | Her mentors, family, and friends | Based on the provided context, the answer is not stated. | 0.31 | 0.077592 | 0.213206 | 0.000167 | 0.010025 | 3637 | 1762 |  |
| 48 | sample_0_qa48 | What types of pottery have Melanie and her kids made? | bowls, cup | Based on the provided context, the answer is not stated. | 0.28 | 0.023013 | 0.239437 | 0.000179 | 0.007523 | 3636 | 1762 |  |
| 49 | sample_0_qa49 | When did Caroline and Melanie go to a pride fesetival together? | 2022 | Based on the provided context, the answer is not stated. | 0.26 | 0.019047 | 0.228633 | 0.000167 | 0.009391 | 3639 | 1762 |  |
| 50 | sample_0_qa50 | What would Caroline's political leaning likely be? | Liberal | Based on the provided context, the answer is not stated. | 0.28 | 0.030902 | 0.229322 | 0.000232 | 0.008425 | 3636 | 1762 |  |
| 51 | sample_0_qa51 | What has Melanie painted? | Horse, sunset, sunrise | Based on the provided context, the answer is not stated. | 0.3 | 0.069307 | 0.212402 | 0.000396 | 0.013574 | 3629 | 1762 |  |
| 52 | sample_0_qa52 | What are Melanie's pets' names? | Oliver, Luna, Bailey | Based on the provided context, the answer is not stated. | 0.26 | 0.022558 | 0.220748 | 0.000186 | 0.007285 | 3631 | 1762 |  |
| 53 | sample_0_qa53 | When did Caroline apply to adoption agencies? | The week of 23 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.072484 | 0.221511 | 0.000431 | 0.007194 | 3634 | 1762 |  |
| 54 | sample_0_qa54 | When did Caroline draw a self-portrait? | The week before 23 August 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.066772 | 0.226895 | 0.000187 | 0.007492 | 3633 | 1762 |  |
| 55 | sample_0_qa55 | What subject have Caroline and Melanie both painted? | Sunsets | Based on the provided context, the answer is not stated. | 0.31 | 0.074171 | 0.224142 | 0.000171 | 0.007294 | 3636 | 1762 |  |
| 56 | sample_0_qa56 | What symbols are important to Caroline? | Rainbow flag, transgender symbol | Based on the provided context, the answer is not stated. | 0.31 | 0.069742 | 0.225464 | 0.000175 | 0.006903 | 3633 | 1762 |  |
| 57 | sample_0_qa57 | When did Caroline encounter people on a hike and have a negative experience? | The week before 25 August 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.073177 | 0.254584 | 0.000184 | 0.008174 | 3642 | 1762 |  |
| 58 | sample_0_qa58 | When did Melanie make a plate in pottery class? | 24 August 2023 | Based on the provided context, the answer is not stated. | 0.3 | 0.029214 | 0.256846 | 0.000178 | 0.008309 | 3635 | 1762 |  |
| 59 | sample_0_qa59 | Would Caroline be considered religious? | Somewhat, but not extremely religious | Based on the provided context, the answer is not stated. | 0.34 | 0.078407 | 0.249620 | 0.000191 | 0.006902 | 3633 | 1762 |  |
| 60 | sample_0_qa60 | What instruments does Melanie play? | clarinet and violin | Based on the provided context, the answer is not stated. | 0.28 | 0.026143 | 0.237153 | 0.000245 | 0.007591 | 3632 | 1762 |  |
| 61 | sample_0_qa61 | What musical artists/bands has Melanie seen? | Summer Sounds, Matt Patterson | Based on the provided context, the answer is not stated. | 0.34 | 0.069904 | 0.255480 | 0.000167 | 0.010229 | 3634 | 1762 |  |
| 62 | sample_0_qa62 | When did Melanie go to the park? | 27 August 2023 | Based on the provided context, the answer is not stated. | 0.26 | 0.019984 | 0.230944 | 0.000179 | 0.006612 | 3631 | 1762 |  |
| 63 | sample_0_qa63 | When is Caroline's youth center putting on a talent show? | September 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.062455 | 0.260348 | 0.000335 | 0.007534 | 3637 | 1762 |  |
| 64 | sample_0_qa64 | Would Melanie likely enjoy the song "The Four Seasons" by Vivaldi? | Yes; it's classical music | Based on the provided context, the answer is not stated. | 0.28 | 0.021201 | 0.248506 | 0.000217 | 0.007212 | 3640 | 1762 |  |
| 65 | sample_0_qa65 | What are some changes Caroline has faced during her transition journey? | Changes to her body, losing unsupportive friends | Based on the provided context, the answer is not stated. | 0.28 | 0.013149 | 0.251794 | 0.000235 | 0.009127 | 3641 | 1762 |  |
| 66 | sample_0_qa66 | What does Melanie do with her family on hikes? | Roast marshmallows, tell stories | Based on the provided context, the answer is not stated. | 0.29 | 0.023525 | 0.251146 | 0.000198 | 0.007986 | 3635 | 1762 |  |
| 67 | sample_0_qa67 | When did Caroline go biking with friends? | The weekend before 13 September 2023 | Based on the provided context, the answer is not stated. | 0.34 | 0.076759 | 0.241200 | 0.000196 | 0.012537 | 3633 | 1762 |  |
| 68 | sample_0_qa68 | How long has Melanie been practicing art? | Since 2016 | Based on the provided context, the answer is not stated. | 0.29 | 0.018870 | 0.258066 | 0.000217 | 0.007379 | 3633 | 1762 |  |
| 69 | sample_0_qa69 | What personality traits might Melanie say Caroline has? | Thoughtful, authentic, driven | Based on the provided context, the answer is not stated. | 0.34 | 0.081131 | 0.239001 | 0.000177 | 0.009073 | 3637 | 1762 |  |
| 70 | sample_0_qa70 | What transgender-specific events has Caroline attended? | Poetry reading, conference | Based on the provided context, the answer is not stated. | 0.29 | 0.027706 | 0.253506 | 0.000269 | 0.008416 | 3637 | 1762 |  |
| 71 | sample_0_qa71 | What book did Melanie read from Caroline's suggestion? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.29 | 0.063015 | 0.207364 | 0.000236 | 0.009484 | 3637 | 1762 |  |
| 72 | sample_0_qa72 | When did Melanie's friend adopt a child? | 2022 | Based on the provided context, the answer is not stated. | 0.26 | 0.019771 | 0.226772 | 0.000179 | 0.008941 | 3633 | 1762 |  |
| 73 | sample_0_qa73 | When did Melanie get hurt? | September 2023 | Based on the provided context, the answer is not stated. | 0.31 | 0.059854 | 0.238147 | 0.000211 | 0.008636 | 3630 | 1762 |  |
| 74 | sample_0_qa74 | When did Melanie's family go on a roadtrip? | The weekend before 20 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.057518 | 0.246069 | 0.000176 | 0.009569 | 3634 | 1762 |  |
| 75 | sample_0_qa75 | How many children does Melanie have? | 3 | Based on the provided context, the answer is not stated. | 0.33 | 0.059189 | 0.253548 | 0.000165 | 0.006965 | 3632 | 1762 |  |
| 76 | sample_0_qa76 | When did Melanie go on a hike after the roadtrip? | 19 October 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.027138 | 0.239102 | 0.000175 | 0.007384 | 3635 | 1762 |  |
| 77 | sample_0_qa77 | Would Melanie go on another roadtrip soon? | Likely no; since this one went badly | Based on the provided context, the answer is not stated. | 0.32 | 0.063866 | 0.237616 | 0.000385 | 0.007217 | 3634 | 1762 |  |
| 78 | sample_0_qa78 | What items has Melanie bought? | Figurines, shoes | Based on the provided context, the answer is not stated. | 0.27 | 0.025082 | 0.225867 | 0.000175 | 0.007054 | 3631 | 1762 |  |
| 79 | sample_0_qa79 | When did Caroline pass the adoption interview? | The Friday before 22 October 2023 | Based on the provided context, the answer is not stated. | 0.32 | 0.059515 | 0.240222 | 0.000188 | 0.011163 | 3635 | 1762 |  |
| 80 | sample_0_qa80 | When did Melanie buy the figurines? | 21 October 2023 | Based on the provided context, the answer is not stated. | 0.28 | 0.029762 | 0.235210 | 0.000168 | 0.007705 | 3632 | 1762 |  |
| 81 | sample_0_qa81 | Would Caroline want to move back to her home country soon? | No; she's in the process of adopting children. | Based on the provided context, the answer is not stated. | 0.24 | 0.021944 | 0.203816 | 0.000185 | 0.006813 | 3638 | 1762 |  |
| 82 | sample_0_qa82 | What did the charity race raise awareness for? | mental health | Based on the provided context, the answer is not stated. | 0.29 | 0.022442 | 0.253255 | 0.000177 | 0.007864 | 3635 | 1762 |  |
| 83 | sample_0_qa83 | What did Melanie realize after the charity race? | self-care is important | Based on the provided context, the answer is not stated. | 0.31 | 0.076365 | 0.219517 | 0.000178 | 0.006761 | 3635 | 1762 |  |
| 84 | sample_0_qa84 | How does Melanie prioritize self-care? | by carving out some me-time each day for activities like running, reading, or playing the violin | Based on the provided context, the answer is not stated. | 0.28 | 0.031632 | 0.229844 | 0.000182 | 0.007710 | 3633 | 1762 |  |
| 85 | sample_0_qa85 | What are Caroline's plans for the summer? | researching adoption agencies | Based on the provided context, the answer is not stated. | 0.33 | 0.067649 | 0.254125 | 0.000180 | 0.006936 | 3633 | 1762 |  |
| 86 | sample_0_qa86 | What type of individuals does the adoption agency Caroline is considering support? | LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.28 | 0.033474 | 0.235715 | 0.000178 | 0.006973 | 3644 | 1762 |  |
| 87 | sample_0_qa87 | Why did Caroline choose the adoption agency? | because of their inclusivity and support for LGBTQ+ individuals | Based on the provided context, the answer is not stated. | 0.33 | 0.074922 | 0.237792 | 0.000176 | 0.011180 | 3634 | 1762 |  |
| 88 | sample_0_qa88 | What is Caroline excited about in the adoption process? | creating a family for kids who need one | Based on the provided context, the answer is not stated. | 0.32 | 0.066047 | 0.242796 | 0.000178 | 0.008027 | 3637 | 1762 |  |
| 89 | sample_0_qa89 | What does Melanie think about Caroline's decision to adopt? | she thinks Caroline is doing something amazing and will be an awesome mom | Based on the provided context, the answer is not stated. | 0.28 | 0.022121 | 0.249566 | 0.000179 | 0.007666 | 3638 | 1762 |  |
| 90 | sample_0_qa90 | How long have Mel and her husband been married? | Mel and her husband have been married for 5 years. | Based on the provided context, the answer is not stated. | 0.29 | 0.031167 | 0.237795 | 0.000204 | 0.010205 | 3635 | 1762 |  |
| 91 | sample_0_qa91 | What does Caroline's necklace symbolize? | love, faith, and strength | Based on the provided context, the answer is not stated. | 0.27 | 0.029137 | 0.226918 | 0.000173 | 0.008677 | 3633 | 1762 |  |
| 92 | sample_0_qa92 | What country is Caroline's grandma from? | Sweden | Based on the provided context, the answer is not stated. | 0.31 | 0.076624 | 0.220428 | 0.000196 | 0.008275 | 3633 | 1762 |  |
| 93 | sample_0_qa93 | What was grandma's gift to Caroline? | necklace | Based on the provided context, the answer is not stated. | 0.28 | 0.030913 | 0.232921 | 0.000188 | 0.007597 | 3632 | 1762 |  |
| 94 | sample_0_qa94 | What is Melanie's hand-painted bowl a reminder of? | art and self-expression | Based on the provided context, the answer is not stated. | 0.33 | 0.074466 | 0.237760 | 0.000185 | 0.008720 | 3636 | 1762 |  |
| 95 | sample_0_qa95 | What did Melanie and her family do while camping? | explored nature, roasted marshmallows, and went on a hike | Based on the provided context, the answer is not stated. | 0.26 | 0.015702 | 0.229457 | 0.000417 | 0.008874 | 3635 | 1762 |  |
| 96 | sample_0_qa96 | What kind of counseling and mental health services is Caroline interested in pursuing? | working with trans people, helping them accept themselves and supporting their mental health | Based on the provided context, the answer is not stated. | 0.31 | 0.070144 | 0.229266 | 0.000176 | 0.008083 | 3645 | 1762 |  |
| 97 | sample_0_qa97 | What workshop did Caroline attend recently? | LGBTQ+ counseling workshop | Based on the provided context, the answer is not stated. | 0.3 | 0.071517 | 0.213926 | 0.000176 | 0.007203 | 3634 | 1762 |  |
| 98 | sample_0_qa98 | What was discussed in the LGBTQ+ counseling workshop? | therapeutic methods and how to best work with trans people | Based on the provided context, the answer is not stated. | 0.26 | 0.020185 | 0.228131 | 0.000170 | 0.006490 | 3636 | 1762 |  |
| 99 | sample_0_qa99 | What motivated Caroline to pursue counseling? | her own journey and the support she received, and how counseling improved her life | Based on the provided context, the answer is not stated. | 0.34 | 0.076935 | 0.245899 | 0.000230 | 0.008373 | 3634 | 1762 |  |
| 100 | sample_0_qa100 | What kind of place does Caroline want to create for people? | a safe and inviting place for people to grow | Based on the provided context, the answer is not stated. | 0.32 | 0.076541 | 0.229666 | 0.000247 | 0.008357 | 3638 | 1762 |  |
| 101 | sample_0_qa101 | Did Melanie make the black and white bowl in the photo? | Yes | Based on the provided context, the answer is not stated. | 0.29 | 0.031475 | 0.244140 | 0.000189 | 0.007940 | 3637 | 1762 |  |
| 102 | sample_0_qa102 | What kind of books does Caroline have in her library? | kids' books - classics, stories from different cultures, educational books | Based on the provided context, the answer is not stated. | 0.36 | 0.065655 | 0.271137 | 0.000427 | 0.012674 | 3636 | 1762 |  |
| 103 | sample_0_qa103 | What was Melanie's favorite book from her childhood? | "Charlotte's Web" | Based on the provided context, the answer is not stated. | 0.33 | 0.074754 | 0.239029 | 0.000167 | 0.012505 | 3636 | 1762 |  |
| 104 | sample_0_qa104 | What book did Caroline recommend to Melanie? | "Becoming Nicole" | Based on the provided context, the answer is not stated. | 0.34 | 0.062257 | 0.267161 | 0.000194 | 0.007162 | 3634 | 1762 |  |
| 105 | sample_0_qa105 | What did Caroline take away from the book "Becoming Nicole"? | Lessons on self-acceptance and finding support | Based on the provided context, the answer is not stated. | 0.28 | 0.019012 | 0.246696 | 0.000179 | 0.008302 | 3638 | 1762 |  |
| 106 | sample_0_qa106 | What are the new shoes that Melanie got used for? | Running | Based on the provided context, the answer is not stated. | 0.29 | 0.030283 | 0.245555 | 0.000183 | 0.007333 | 3635 | 1762 |  |
| 107 | sample_0_qa107 | What is Melanie's reason for getting into running? | To de-stress and clear her mind | Based on the provided context, the answer is not stated. | 0.28 | 0.019503 | 0.247357 | 0.000327 | 0.007014 | 3636 | 1762 |  |
| 108 | sample_0_qa108 | What does Melanie say running has been great for? | Her mental health | Based on the provided context, the answer is not stated. | 0.3 | 0.063163 | 0.226601 | 0.000186 | 0.007663 | 3635 | 1762 |  |
| 109 | sample_0_qa109 | What did Mel and her kids make during the pottery workshop? | pots | Based on the provided context, the answer is not stated. | 0.28 | 0.027050 | 0.225698 | 0.000160 | 0.017907 | 3638 | 1762 |  |
| 110 | sample_0_qa110 | What kind of pot did Mel and her kids make with clay? | a cup with a dog face on it | Based on the provided context, the answer is not stated. | 0.29 | 0.015480 | 0.257076 | 0.000203 | 0.009143 | 3636 | 1762 |  |
| 111 | sample_0_qa111 | What creative project do Mel and her kids do together besides pottery? | painting | Based on the provided context, the answer is not stated. | 0.33 | 0.063329 | 0.252482 | 0.000436 | 0.006751 | 3641 | 1762 |  |
| 112 | sample_0_qa112 | What did Mel and her kids paint in their latest project in July 2023? | a sunset with a palm tree | Based on the provided context, the answer is not stated. | 0.31 | 0.026746 | 0.259921 | 0.000415 | 0.006479 | 3640 | 1762 |  |
| 113 | sample_0_qa113 | What did Caroline see at the council meeting for adoption? | many people wanting to create loving homes for children in need | Based on the provided context, the answer is not stated. | 0.35 | 0.089310 | 0.247196 | 0.000166 | 0.008227 | 3638 | 1762 |  |
| 114 | sample_0_qa114 | What do sunflowers represent according to Caroline? | warmth and happiness | Based on the provided context, the answer is not stated. | 0.28 | 0.030905 | 0.240819 | 0.000179 | 0.007519 | 3636 | 1762 |  |
| 115 | sample_0_qa115 | Why are flowers important to Melanie? | They remind her to appreciate the small moments and were a part of her wedding decor | Based on the provided context, the answer is not stated. | 0.3 | 0.022184 | 0.266803 | 0.000181 | 0.007088 | 3632 | 1762 |  |
| 116 | sample_0_qa116 | What inspired Caroline's painting for the art show? | visiting an LGBTQ center and wanting to capture unity and strength | Based on the provided context, the answer is not stated. | 0.3 | 0.056948 | 0.231265 | 0.000176 | 0.007843 | 3636 | 1762 |  |
| 117 | sample_0_qa117 | How often does Melanie go to the beach with her kids? | once or twice a year | Based on the provided context, the answer is not stated. | 0.3 | 0.028212 | 0.250988 | 0.000189 | 0.007244 | 3636 | 1762 |  |
| 118 | sample_0_qa118 | What did Melanie and her family see during their camping trip last year? | Perseid meteor shower | Based on the provided context, the answer is not stated. | 0.27 | 0.021180 | 0.231288 | 0.000176 | 0.009322 | 3641 | 1762 |  |
| 119 | sample_0_qa119 | How did Melanie feel while watching the meteor shower? | in awe of the universe | Based on the provided context, the answer is not stated. | 0.33 | 0.070431 | 0.239015 | 0.000182 | 0.009910 | 3637 | 1762 |  |
| 120 | sample_0_qa120 | Whose birthday did Melanie celebrate recently? | Melanie's daughter | Based on the provided context, the answer is not stated. | 0.25 | 0.019748 | 0.221575 | 0.000181 | 0.007560 | 3635 | 1762 |  |
| 121 | sample_0_qa121 | Who performed at the concert at Melanie's daughter's birthday? | Matt Patterson | Based on the provided context, the answer is not stated. | 0.32 | 0.068871 | 0.241510 | 0.000175 | 0.007812 | 3639 | 1762 |  |
| 122 | sample_0_qa122 | Why did Melanie choose to use colors and patterns in her pottery project? | She wanted to catch the eye and make people smile. | Based on the provided context, the answer is not stated. | 0.35 | 0.074287 | 0.263649 | 0.000222 | 0.009425 | 3641 | 1762 |  |
| 123 | sample_0_qa123 | What pet does Caroline have? | guinea pig | Based on the provided context, the answer is not stated. | 0.33 | 0.071353 | 0.242753 | 0.000178 | 0.006881 | 3630 | 1762 |  |
| 124 | sample_0_qa124 | What pets does Melanie have? | Two cats and a dog | Based on the provided context, the answer is not stated. | 0.28 | 0.010404 | 0.248515 | 0.000184 | 0.009648 | 3630 | 1762 |  |
| 125 | sample_0_qa125 | Where did Oliver hide his bone once? | In Melanie's slipper | Based on the provided context, the answer is not stated. | 0.33 | 0.063334 | 0.247951 | 0.000178 | 0.006981 | 3632 | 1762 |  |
| 126 | sample_0_qa126 | What activity did Caroline used to do with her dad? | Horseback riding | Based on the provided context, the answer is not stated. | 0.31 | 0.031906 | 0.260887 | 0.000638 | 0.008473 | 3636 | 1762 |  |
| 127 | sample_0_qa127 | What did Caroline make for a local church? | a stained glass window | Based on the provided context, the answer is not stated. | 0.31 | 0.066272 | 0.236177 | 0.000181 | 0.006747 | 3634 | 1762 |  |
| 128 | sample_0_qa128 | What did Caroline find in her neighborhood during her walk? | a rainbow sidewalk | Based on the provided context, the answer is not stated. | 0.3 | 0.070313 | 0.215792 | 0.000177 | 0.006977 | 3638 | 1762 |  |
| 129 | sample_0_qa129 | Which song motivates Caroline to be courageous? | Brave by Sara Bareilles | Based on the provided context, the answer is not stated. | 0.27 | 0.019443 | 0.233604 | 0.000177 | 0.009154 | 3635 | 1762 |  |
| 130 | sample_0_qa130 | Which  classical musicians does Melanie enjoy listening to? | Bach and Mozart | Based on the provided context, the answer is not stated. | 0.28 | 0.032354 | 0.232208 | 0.000173 | 0.015345 | 3638 | 1762 |  |
| 131 | sample_0_qa131 | Who is Melanie a fan of in terms of modern music? | Ed Sheeran | Based on the provided context, the answer is not stated. | 0.32 | 0.061035 | 0.249416 | 0.000483 | 0.007055 | 3635 | 1762 |  |
| 132 | sample_0_qa132 | How long has Melanie been creating art? | 7 years | Based on the provided context, the answer is not stated. | 0.27 | 0.023366 | 0.233398 | 0.000181 | 0.006459 | 3633 | 1762 |  |
| 133 | sample_0_qa133 | What precautionary sign did Melanie see at the café? | A sign stating that someone is not being able to leave | Based on the provided context, the answer is not stated. | 0.33 | 0.079755 | 0.234610 | 0.000498 | 0.010041 | 3636 | 1762 |  |
| 134 | sample_0_qa134 | What advice does Caroline give for getting started with adoption? | Do research, find an adoption agency or lawyer, gather necessary documents, and prepare emotionally. | Based on the provided context, the answer is not stated. | 0.29 | 0.028959 | 0.244933 | 0.000175 | 0.007674 | 3639 | 1762 |  |
| 135 | sample_0_qa135 | What setback did Melanie face in October 2023? | She got hurt and had to take a break from pottery. | Based on the provided context, the answer is not stated. | 0.32 | 0.065273 | 0.237565 | 0.000196 | 0.011161 | 3635 | 1762 |  |
| 136 | sample_0_qa136 | What does Melanie do to keep herself busy during her pottery break? | Read a book and paint. | Based on the provided context, the answer is not stated. | 0.28 | 0.019676 | 0.248125 | 0.000180 | 0.008538 | 3640 | 1762 |  |
| 137 | sample_0_qa137 | What painting did Melanie show to Caroline on October 13, 2023? | A painting inspired by sunsets with a pink sky. | Based on the provided context, the answer is not stated. | 0.36 | 0.077580 | 0.273096 | 0.000182 | 0.008030 | 3639 | 1762 |  |
| 138 | sample_0_qa138 | What kind of painting did Caroline share with Melanie on October 13, 2023? | An abstract painting with blue streaks on a wall. | Based on the provided context, the answer is not stated. | 0.31 | 0.063350 | 0.235855 | 0.000156 | 0.007946 | 3642 | 1762 |  |
| 139 | sample_0_qa139 | What was the poetry reading that Caroline attended about? | It was a transgender poetry reading where transgender people shared their stories. | Based on the provided context, the answer is not stated. | 0.28 | 0.026186 | 0.239332 | 0.000185 | 0.008151 | 3637 | 1762 |  |
| 140 | sample_0_qa140 | What did the posters at the poetry reading say? | "Trans Lives Matter" | Based on the provided context, the answer is not stated. | 0.33 | 0.063121 | 0.255683 | 0.000175 | 0.007980 | 3635 | 1762 |  |
| 141 | sample_0_qa141 | What does Caroline's drawing symbolize for her? | Freedom and being true to herself. | Based on the provided context, the answer is not stated. | 0.33 | 0.063666 | 0.249936 | 0.000206 | 0.010478 | 3635 | 1762 |  |
| 142 | sample_0_qa142 | How do Melanie and Caroline describe their journey through life together? | An ongoing adventure of learning and growing. | Based on the provided context, the answer is not stated. | 0.32 | 0.029170 | 0.272981 | 0.000504 | 0.007186 | 3641 | 1762 |  |
| 143 | sample_0_qa143 | What happened to Melanie's son on their road trip? | He got into an accident | Based on the provided context, the answer is not stated. | 0.34 | 0.061873 | 0.259955 | 0.000184 | 0.008770 | 3636 | 1762 |  |
| 144 | sample_0_qa144 | How did Melanie's son handle the accident? | He was scared but reassured by his family | Based on the provided context, the answer is not stated. | 0.32 | 0.029091 | 0.272661 | 0.000180 | 0.007865 | 3634 | 1762 |  |
| 145 | sample_0_qa145 | How did Melanie feel about her family after the accident? | They are important and mean the world to her | Based on the provided context, the answer is not stated. | 0.29 | 0.021512 | 0.251853 | 0.000196 | 0.006978 | 3637 | 1762 |  |
| 146 | sample_0_qa146 | How did Melanie's children handle the accident? | They were scared but resilient | Based on the provided context, the answer is not stated. | 0.29 | 0.060253 | 0.215050 | 0.000457 | 0.010916 | 3635 | 1762 |  |
| 147 | sample_0_qa147 | How did Melanie feel after the accident? | Grateful and thankful for her family | Based on the provided context, the answer is not stated. | 0.28 | 0.029427 | 0.232166 | 0.000178 | 0.008060 | 3633 | 1762 |  |
| 148 | sample_0_qa148 | What was Melanie's reaction to her children enjoying the Grand Canyon? | She was happy and thankful | Based on the provided context, the answer is not stated. | 0.26 | 0.060409 | 0.183371 | 0.000177 | 0.007884 | 3641 | 1762 |  |
| 149 | sample_0_qa149 | What do Melanie's family give her? | Strength and motivation | Based on the provided context, the answer is not stated. | 0.22 | 0.055968 | 0.147792 | 0.000158 | 0.007785 | 3632 | 1762 |  |
| 150 | sample_0_qa150 | How did Melanie feel about her family supporting her? | She appreciated them a lot | Based on the provided context, the answer is not stated. | 0.21 | 0.022665 | 0.163930 | 0.000160 | 0.008627 | 3636 | 1762 |  |
| 151 | sample_0_qa151 | What did Melanie do after the road trip to relax? | Went on a nature walk or hike | Based on the provided context, the answer is not stated. | 0.18 | 0.072720 | 0.088767 | 0.000174 | 0.006572 | 3635 | 1762 |  |

### H. Token对照

| 指标 | 总量 | 平均/question |
|---|---:|---:|
| 记忆上下文Prompt Token | 552,573 | 3635.35 |
| 完整上下文Prompt Token | 2,652,343 | 17449.62 |
| 节省Prompt Token | 2,099,770 | 13814.28 |
| 节省率 | 79.167% |  |