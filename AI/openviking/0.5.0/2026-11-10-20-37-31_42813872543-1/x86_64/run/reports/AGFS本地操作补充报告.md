# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.419621 | 0.126230 | 0.293391 |
| noop | mkdir | 52 | 1.639180 | 0.181374 | 1.457806 |
| noop | pathlock_acquire_exact | 61 | 0.858127 | 0.453046 | 0.405081 |
| noop | pathlock_release | 61 | 0.465584 | 0.229312 | 0.236272 |
| noop | read | 7836 | 1.215946 | 0.206956 | 1.008990 |
| noop | stat | 5601 | 1.616095 | 0.265318 | 1.350778 |
| noop | write | 568 | 0.732519 | 0.372733 | 0.359786 |
| session.add_message | ensure_parent_dirs | 838 | 0.213398 | 0.068250 | 0.145148 |
| session.add_message | pathlock_acquire_exact | 838 | 0.560760 | 0.366418 | 0.194343 |
| session.add_message | pathlock_release | 838 | 0.280888 | 0.133502 | 0.147386 |
| session.add_message | read | 2095 | 0.182147 | 0.034442 | 0.147705 |
| session.add_message | stat | 2095 | 0.250895 | 0.066704 | 0.184191 |
| session.add_message | write | 838 | 0.476299 | 0.312543 | 0.163756 |
| session.commit | ensure_parent_dirs | 427 | 0.368964 | 0.096773 | 0.272191 |
| session.commit | mkdir | 4 | 0.130547 | 0.049778 | 0.080769 |
| session.commit | pathlock_acquire_exact | 61 | 0.727691 | 0.413137 | 0.314554 |
| session.commit | pathlock_release | 61 | 0.323242 | 0.141110 | 0.182132 |
| session.commit | read | 427 | 0.224469 | 0.043382 | 0.181087 |
| session.commit | stat | 2562 | 0.261420 | 0.074524 | 0.186896 |
| session.commit | write | 549 | 0.634293 | 0.424630 | 0.209663 |
| session.create | ensure_parent_dirs | 204 | 0.332866 | 0.130834 | 0.202031 |
| session.create | mkdir | 68 | 0.338070 | 0.121424 | 0.216645 |
| session.create | read | 840 | 1.136162 | 0.161527 | 0.974635 |
| session.create | stat | 1986 | 0.608252 | 0.143245 | 0.465007 |
| session.create | write | 148 | 0.759528 | 0.519793 | 0.239735 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.217065 | 0.065450 | 0.151615 |
| session_commit_phase2 | ls | 58 | 0.312104 | 0.169611 | 0.142493 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 1.429033 | 1.148072 | 0.280960 |
| session_commit_phase2 | pathlock_release | 58 | 0.460823 | 0.314491 | 0.146331 |
| session_commit_phase2 | read | 1345 | 0.778634 | 0.086473 | 0.692161 |
| session_commit_phase2 | stat | 955 | 0.262181 | 0.089673 | 0.172509 |
| session_commit_phase2 | write | 356 | 0.474824 | 0.306461 | 0.168363 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 4.307823 |
| 服务其他处理 | 2.427693 |
| 合计 | 6.735515 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
