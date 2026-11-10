# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.329772 | 0.055383 | 0.274389 |
| noop | mkdir | 52 | 1.681015 | 0.202313 | 1.478702 |
| noop | pathlock_acquire_exact | 61 | 0.384108 | 0.215219 | 0.168889 |
| noop | pathlock_release | 61 | 0.186779 | 0.088007 | 0.098772 |
| noop | read | 7867 | 1.103572 | 0.128406 | 0.975166 |
| noop | stat | 5601 | 1.293325 | 0.147361 | 1.145964 |
| noop | write | 568 | 0.604327 | 0.253839 | 0.350489 |
| session.add_message | ensure_parent_dirs | 838 | 0.133311 | 0.031069 | 0.102242 |
| session.add_message | pathlock_acquire_exact | 838 | 0.296396 | 0.175515 | 0.120880 |
| session.add_message | pathlock_release | 838 | 0.181367 | 0.076424 | 0.104943 |
| session.add_message | read | 2095 | 0.124555 | 0.023107 | 0.101448 |
| session.add_message | stat | 2095 | 0.149128 | 0.033095 | 0.116033 |
| session.add_message | write | 838 | 0.308436 | 0.198031 | 0.110405 |
| session.commit | ensure_parent_dirs | 427 | 0.280960 | 0.061588 | 0.219373 |
| session.commit | mkdir | 4 | 0.204052 | 0.062750 | 0.141302 |
| session.commit | pathlock_acquire_exact | 61 | 0.276723 | 0.159477 | 0.117246 |
| session.commit | pathlock_release | 61 | 0.176858 | 0.072027 | 0.104831 |
| session.commit | read | 427 | 0.126109 | 0.024188 | 0.101921 |
| session.commit | stat | 2562 | 0.144572 | 0.032228 | 0.112344 |
| session.commit | write | 549 | 0.415852 | 0.267882 | 0.147970 |
| session.create | ensure_parent_dirs | 204 | 0.170880 | 0.038662 | 0.132218 |
| session.create | mkdir | 68 | 0.243368 | 0.092022 | 0.151346 |
| session.create | read | 840 | 1.074492 | 0.143131 | 0.931361 |
| session.create | stat | 1986 | 0.394767 | 0.070308 | 0.324459 |
| session.create | write | 148 | 0.517498 | 0.307194 | 0.210305 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.168648 | 0.048997 | 0.119650 |
| session_commit_phase2 | ls | 58 | 0.173109 | 0.068398 | 0.104710 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 1.314905 | 1.118912 | 0.195992 |
| session_commit_phase2 | pathlock_release | 58 | 0.267543 | 0.163475 | 0.104069 |
| session_commit_phase2 | read | 1345 | 0.614699 | 0.082982 | 0.531717 |
| session_commit_phase2 | stat | 955 | 0.187652 | 0.042496 | 0.145155 |
| session_commit_phase2 | write | 356 | 0.349210 | 0.211889 | 0.137322 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 4.188835 |
| 服务其他处理 | 2.718329 |
| 合计 | 6.907164 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
