# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 1.477193 | 0.520874 | 0.956319 |
| noop | mkdir | 52 | 3.454947 | 0.565306 | 2.889641 |
| noop | pathlock_acquire_exact | 61 | 2.116342 | 1.118012 | 0.998330 |
| noop | pathlock_release | 61 | 1.263450 | 0.558933 | 0.704516 |
| noop | read | 8718 | 2.192809 | 0.204145 | 1.988664 |
| noop | stat | 5601 | 3.096815 | 0.800717 | 2.296098 |
| noop | write | 568 | 1.752457 | 0.737135 | 1.015321 |
| session.add_message | ensure_parent_dirs | 838 | 1.082601 | 0.452821 | 0.629780 |
| session.add_message | pathlock_acquire_exact | 838 | 1.769212 | 1.116406 | 0.652806 |
| session.add_message | pathlock_release | 838 | 1.164927 | 0.543973 | 0.620953 |
| session.add_message | read | 2095 | 0.687428 | 0.058682 | 0.628745 |
| session.add_message | stat | 2095 | 1.101870 | 0.472335 | 0.629535 |
| session.add_message | write | 838 | 1.553402 | 0.926535 | 0.626867 |
| session.commit | ensure_parent_dirs | 427 | 1.432468 | 0.543701 | 0.888767 |
| session.commit | mkdir | 4 | 0.548670 | 0.083559 | 0.465111 |
| session.commit | pathlock_acquire_exact | 61 | 1.556603 | 1.037014 | 0.519589 |
| session.commit | pathlock_release | 61 | 1.192308 | 0.557750 | 0.634558 |
| session.commit | read | 427 | 0.672644 | 0.056587 | 0.616058 |
| session.commit | stat | 2562 | 1.091116 | 0.461222 | 0.629893 |
| session.commit | write | 549 | 2.117464 | 1.445614 | 0.671850 |
| session.create | ensure_parent_dirs | 204 | 1.144175 | 0.482924 | 0.661251 |
| session.create | mkdir | 68 | 0.789361 | 0.115007 | 0.674354 |
| session.create | read | 840 | 1.689951 | 0.141312 | 1.548639 |
| session.create | stat | 1986 | 1.632217 | 0.630665 | 1.001552 |
| session.create | write | 148 | 2.351306 | 1.553750 | 0.797556 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 1.239803 | 0.540859 | 0.698945 |
| session_commit_phase2 | ls | 58 | 1.158519 | 0.555256 | 0.603264 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 3.207476 | 2.432525 | 0.774952 |
| session_commit_phase2 | pathlock_release | 58 | 1.911507 | 1.164000 | 0.747507 |
| session_commit_phase2 | read | 1345 | 1.273839 | 0.070597 | 1.203242 |
| session_commit_phase2 | stat | 955 | 1.190030 | 0.500908 | 0.689122 |
| session_commit_phase2 | write | 356 | 1.481677 | 0.778004 | 0.703673 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 8.790513 |
| 服务其他处理 | 3.427128 |
| 合计 | 12.217641 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
