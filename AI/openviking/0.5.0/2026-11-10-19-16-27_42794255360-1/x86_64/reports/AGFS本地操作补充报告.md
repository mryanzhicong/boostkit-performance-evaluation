# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.446147 | 0.096502 | 0.349644 |
| noop | mkdir | 52 | 4.447555 | 0.474103 | 3.973452 |
| noop | pathlock_acquire_exact | 61 | 0.612330 | 0.401522 | 0.210808 |
| noop | pathlock_release | 61 | 0.244608 | 0.151212 | 0.093396 |
| noop | read | 7798 | 1.127758 | 0.195926 | 0.931832 |
| noop | stat | 5601 | 1.380704 | 0.165701 | 1.215004 |
| noop | write | 568 | 0.762202 | 0.347438 | 0.414764 |
| session.add_message | ensure_parent_dirs | 838 | 0.110826 | 0.034543 | 0.076284 |
| session.add_message | pathlock_acquire_exact | 838 | 0.314902 | 0.223357 | 0.091545 |
| session.add_message | pathlock_release | 838 | 0.169103 | 0.095821 | 0.073282 |
| session.add_message | read | 2095 | 0.104009 | 0.028120 | 0.075889 |
| session.add_message | stat | 2095 | 0.130444 | 0.037657 | 0.092787 |
| session.add_message | write | 838 | 0.336336 | 0.255513 | 0.080823 |
| session.commit | ensure_parent_dirs | 427 | 0.247497 | 0.065375 | 0.182122 |
| session.commit | mkdir | 4 | 0.277846 | 0.139964 | 0.137881 |
| session.commit | pathlock_acquire_exact | 61 | 0.311847 | 0.214202 | 0.097645 |
| session.commit | pathlock_release | 61 | 0.169671 | 0.092367 | 0.077304 |
| session.commit | read | 427 | 0.105697 | 0.028699 | 0.076998 |
| session.commit | stat | 2562 | 0.114555 | 0.030627 | 0.083928 |
| session.commit | write | 549 | 0.471132 | 0.344224 | 0.126908 |
| session.create | ensure_parent_dirs | 204 | 0.164460 | 0.048340 | 0.116120 |
| session.create | mkdir | 68 | 0.214832 | 0.097928 | 0.116903 |
| session.create | read | 840 | 0.940719 | 0.195933 | 0.744787 |
| session.create | stat | 1986 | 0.366135 | 0.085592 | 0.280544 |
| session.create | write | 148 | 0.604532 | 0.441862 | 0.162670 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.194888 | 0.072958 | 0.121930 |
| session_commit_phase2 | ls | 58 | 0.194306 | 0.102108 | 0.092198 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 0.965081 | 0.765856 | 0.199226 |
| session_commit_phase2 | pathlock_release | 58 | 0.368856 | 0.268678 | 0.100178 |
| session_commit_phase2 | read | 1345 | 0.613449 | 0.074745 | 0.538704 |
| session_commit_phase2 | stat | 955 | 0.182436 | 0.059423 | 0.123013 |
| session_commit_phase2 | write | 356 | 0.390069 | 0.276284 | 0.113785 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 3.741634 |
| 服务其他处理 | 2.232519 |
| 合计 | 5.974153 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
