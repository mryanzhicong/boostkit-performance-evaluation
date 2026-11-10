# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.364189 | 0.082004 | 0.282185 |
| noop | mkdir | 52 | 1.625226 | 0.183788 | 1.441438 |
| noop | pathlock_acquire_exact | 61 | 0.384727 | 0.211849 | 0.172878 |
| noop | pathlock_release | 61 | 0.193653 | 0.092651 | 0.101003 |
| noop | read | 7905 | 1.109629 | 0.139953 | 0.969675 |
| noop | stat | 5601 | 1.171282 | 0.173747 | 0.997535 |
| noop | write | 568 | 0.585598 | 0.234258 | 0.351340 |
| session.add_message | ensure_parent_dirs | 838 | 0.127425 | 0.030732 | 0.096693 |
| session.add_message | pathlock_acquire_exact | 838 | 0.295008 | 0.169443 | 0.125566 |
| session.add_message | pathlock_release | 838 | 0.170071 | 0.075671 | 0.094401 |
| session.add_message | read | 2095 | 0.124195 | 0.022628 | 0.101568 |
| session.add_message | stat | 2095 | 0.150100 | 0.034173 | 0.115926 |
| session.add_message | write | 838 | 0.303206 | 0.201627 | 0.101579 |
| session.commit | ensure_parent_dirs | 427 | 0.265529 | 0.066395 | 0.199134 |
| session.commit | mkdir | 4 | 0.131960 | 0.044252 | 0.087707 |
| session.commit | pathlock_acquire_exact | 61 | 0.281205 | 0.166378 | 0.114827 |
| session.commit | pathlock_release | 61 | 0.168089 | 0.074229 | 0.093859 |
| session.commit | read | 427 | 0.123089 | 0.023278 | 0.099810 |
| session.commit | stat | 2562 | 0.139655 | 0.031060 | 0.108595 |
| session.commit | write | 549 | 0.400134 | 0.260666 | 0.139468 |
| session.create | ensure_parent_dirs | 204 | 0.164536 | 0.036837 | 0.127699 |
| session.create | mkdir | 68 | 0.248869 | 0.077558 | 0.171311 |
| session.create | read | 840 | 1.070586 | 0.145030 | 0.925556 |
| session.create | stat | 1986 | 0.389621 | 0.067793 | 0.321828 |
| session.create | write | 148 | 0.515383 | 0.308901 | 0.206482 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.179452 | 0.046913 | 0.132538 |
| session_commit_phase2 | ls | 58 | 0.210140 | 0.095961 | 0.114179 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 1.904349 | 1.715675 | 0.188674 |
| session_commit_phase2 | pathlock_release | 58 | 0.271922 | 0.166024 | 0.105898 |
| session_commit_phase2 | read | 1345 | 0.630583 | 0.077285 | 0.553298 |
| session_commit_phase2 | stat | 955 | 0.198723 | 0.046197 | 0.152526 |
| session_commit_phase2 | write | 356 | 0.328706 | 0.197955 | 0.130751 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 4.276823 |
| 服务其他处理 | 2.552642 |
| 合计 | 6.829465 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
