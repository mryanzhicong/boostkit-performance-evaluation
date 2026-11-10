# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.364151 | 0.063792 | 0.300358 |
| noop | mkdir | 52 | 1.643226 | 0.173366 | 1.469860 |
| noop | pathlock_acquire_exact | 61 | 0.384245 | 0.210466 | 0.173778 |
| noop | pathlock_release | 61 | 0.201150 | 0.093056 | 0.108094 |
| noop | read | 7835 | 1.139607 | 0.137927 | 1.001679 |
| noop | stat | 5601 | 1.261759 | 0.145720 | 1.116039 |
| noop | write | 568 | 0.572810 | 0.248153 | 0.324656 |
| session.add_message | ensure_parent_dirs | 838 | 0.135902 | 0.031468 | 0.104434 |
| session.add_message | pathlock_acquire_exact | 838 | 0.298568 | 0.177340 | 0.121229 |
| session.add_message | pathlock_release | 838 | 0.181278 | 0.077738 | 0.103540 |
| session.add_message | read | 2095 | 0.124182 | 0.022223 | 0.101960 |
| session.add_message | stat | 2095 | 0.149057 | 0.033253 | 0.115805 |
| session.add_message | write | 838 | 0.312485 | 0.199586 | 0.112899 |
| session.commit | ensure_parent_dirs | 427 | 0.270027 | 0.066441 | 0.203586 |
| session.commit | mkdir | 4 | 0.141307 | 0.041915 | 0.099392 |
| session.commit | pathlock_acquire_exact | 61 | 0.278638 | 0.157610 | 0.121028 |
| session.commit | pathlock_release | 61 | 0.178772 | 0.073990 | 0.104782 |
| session.commit | read | 427 | 0.123757 | 0.022852 | 0.100905 |
| session.commit | stat | 2562 | 0.144889 | 0.032275 | 0.112613 |
| session.commit | write | 549 | 0.415813 | 0.268905 | 0.146908 |
| session.create | ensure_parent_dirs | 204 | 0.170360 | 0.035095 | 0.135265 |
| session.create | mkdir | 68 | 0.237514 | 0.073514 | 0.164000 |
| session.create | read | 840 | 1.110767 | 0.186150 | 0.924617 |
| session.create | stat | 1986 | 0.437740 | 0.076529 | 0.361211 |
| session.create | write | 148 | 0.535117 | 0.331568 | 0.203549 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.173056 | 0.041264 | 0.131793 |
| session_commit_phase2 | ls | 58 | 0.182941 | 0.070066 | 0.112874 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 0.643366 | 0.465266 | 0.178099 |
| session_commit_phase2 | pathlock_release | 58 | 0.292117 | 0.176811 | 0.115307 |
| session_commit_phase2 | read | 1345 | 0.630909 | 0.079173 | 0.551737 |
| session_commit_phase2 | stat | 955 | 0.187356 | 0.043877 | 0.143479 |
| session_commit_phase2 | write | 356 | 0.339431 | 0.205042 | 0.134389 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 4.186992 |
| 服务其他处理 | 2.545097 |
| 合计 | 6.732089 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
