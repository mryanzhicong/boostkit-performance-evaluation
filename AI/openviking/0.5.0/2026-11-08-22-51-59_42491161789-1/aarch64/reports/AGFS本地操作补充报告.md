# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 1.748806 | 0.789745 | 0.959061 |
| noop | mkdir | 52 | 2.982221 | 0.181285 | 2.800936 |
| noop | pathlock_acquire_exact | 61 | 2.265914 | 1.254774 | 1.011140 |
| noop | pathlock_release | 61 | 1.485112 | 0.666418 | 0.818694 |
| noop | read | 8935 | 2.309098 | 0.230532 | 2.078566 |
| noop | stat | 5601 | 3.820783 | 0.988469 | 2.832313 |
| noop | write | 568 | 2.799730 | 1.698102 | 1.101628 |
| session.add_message | ensure_parent_dirs | 838 | 1.285942 | 0.560565 | 0.725377 |
| session.add_message | pathlock_acquire_exact | 838 | 2.099206 | 1.315880 | 0.783326 |
| session.add_message | pathlock_release | 838 | 1.352131 | 0.623519 | 0.728612 |
| session.add_message | read | 2095 | 0.810243 | 0.062116 | 0.748126 |
| session.add_message | stat | 2095 | 1.335995 | 0.583670 | 0.752325 |
| session.add_message | write | 838 | 1.813313 | 1.059368 | 0.753945 |
| session.commit | ensure_parent_dirs | 427 | 1.561761 | 0.612429 | 0.949332 |
| session.commit | mkdir | 4 | 0.737595 | 0.083575 | 0.654020 |
| session.commit | pathlock_acquire_exact | 61 | 1.852423 | 1.219968 | 0.632455 |
| session.commit | pathlock_release | 61 | 1.378340 | 0.629375 | 0.748966 |
| session.commit | read | 427 | 0.782590 | 0.057409 | 0.725181 |
| session.commit | stat | 2562 | 1.276643 | 0.549714 | 0.726929 |
| session.commit | write | 549 | 2.441495 | 1.679741 | 0.761753 |
| session.create | ensure_parent_dirs | 204 | 1.417107 | 0.606011 | 0.811096 |
| session.create | mkdir | 68 | 0.961885 | 0.154222 | 0.807663 |
| session.create | read | 840 | 1.763839 | 0.148378 | 1.615461 |
| session.create | stat | 1986 | 2.016564 | 0.845708 | 1.170856 |
| session.create | write | 148 | 2.999535 | 1.874991 | 1.124544 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 1.376974 | 0.597896 | 0.779078 |
| session_commit_phase2 | ls | 58 | 1.283459 | 0.583517 | 0.699941 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 3.930804 | 3.008258 | 0.922546 |
| session_commit_phase2 | pathlock_release | 58 | 1.987258 | 1.215615 | 0.771644 |
| session_commit_phase2 | read | 1345 | 1.399664 | 0.066202 | 1.333462 |
| session_commit_phase2 | stat | 955 | 1.386552 | 0.601250 | 0.785301 |
| session_commit_phase2 | write | 356 | 1.619501 | 0.837770 | 0.781731 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 9.642543 |
| 服务其他处理 | 3.523735 |
| 合计 | 13.166278 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
