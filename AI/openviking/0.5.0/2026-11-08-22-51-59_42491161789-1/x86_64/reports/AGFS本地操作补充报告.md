# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.359173 | 0.085090 | 0.274083 |
| noop | mkdir | 52 | 1.615220 | 0.188104 | 1.427115 |
| noop | pathlock_acquire_exact | 61 | 0.617857 | 0.387836 | 0.230021 |
| noop | pathlock_release | 61 | 0.255638 | 0.155562 | 0.100076 |
| noop | read | 7854 | 1.170913 | 0.186361 | 0.984553 |
| noop | stat | 5601 | 1.356950 | 0.233452 | 1.123498 |
| noop | write | 568 | 0.585723 | 0.289244 | 0.296479 |
| session.add_message | ensure_parent_dirs | 838 | 0.114148 | 0.033772 | 0.080376 |
| session.add_message | pathlock_acquire_exact | 838 | 0.318303 | 0.222587 | 0.095716 |
| session.add_message | pathlock_release | 838 | 0.174720 | 0.095138 | 0.079581 |
| session.add_message | read | 2095 | 0.110439 | 0.028384 | 0.082055 |
| session.add_message | stat | 2095 | 0.138245 | 0.037783 | 0.100462 |
| session.add_message | write | 838 | 0.345957 | 0.258943 | 0.087014 |
| session.commit | ensure_parent_dirs | 427 | 0.254170 | 0.070390 | 0.183780 |
| session.commit | mkdir | 4 | 0.118009 | 0.052482 | 0.065527 |
| session.commit | pathlock_acquire_exact | 61 | 0.320465 | 0.213990 | 0.106476 |
| session.commit | pathlock_release | 61 | 0.169085 | 0.090429 | 0.078657 |
| session.commit | read | 427 | 0.111787 | 0.028341 | 0.083446 |
| session.commit | stat | 2562 | 0.121597 | 0.030504 | 0.091094 |
| session.commit | write | 549 | 0.464913 | 0.334427 | 0.130485 |
| session.create | ensure_parent_dirs | 204 | 0.151539 | 0.043347 | 0.108192 |
| session.create | mkdir | 68 | 0.235949 | 0.099904 | 0.136045 |
| session.create | read | 840 | 0.945182 | 0.140113 | 0.805069 |
| session.create | stat | 1986 | 0.378795 | 0.084314 | 0.294481 |
| session.create | write | 148 | 0.590658 | 0.422432 | 0.168226 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.167253 | 0.057075 | 0.110178 |
| session_commit_phase2 | ls | 58 | 0.193250 | 0.104968 | 0.088282 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 0.959501 | 0.753726 | 0.205775 |
| session_commit_phase2 | pathlock_release | 58 | 0.394817 | 0.270813 | 0.124004 |
| session_commit_phase2 | read | 1345 | 0.622448 | 0.079539 | 0.542909 |
| session_commit_phase2 | stat | 955 | 0.187918 | 0.060611 | 0.127307 |
| session_commit_phase2 | write | 356 | 0.383411 | 0.265954 | 0.117457 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 4.018682 |
| 服务其他处理 | 2.480138 |
| 合计 | 6.498820 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
