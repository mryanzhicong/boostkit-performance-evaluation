# AGFS本地操作补充报告

## AGFS调用

| 所属操作 | AGFS方法 | 次数 | 平均耗时(ms) | 工作线程内(ms) | 线程交接与返回(ms) |
|---|---|---:|---:|---:|---:|
| noop | ensure_parent_dirs | 161 | 0.322637 | 0.087992 | 0.234646 |
| noop | mkdir | 52 | 1.665361 | 0.156206 | 1.509155 |
| noop | pathlock_acquire_exact | 61 | 0.775690 | 0.498865 | 0.276825 |
| noop | pathlock_release | 61 | 0.306018 | 0.197453 | 0.108564 |
| noop | read | 7888 | 1.476830 | 0.256951 | 1.219879 |
| noop | stat | 5601 | 1.549355 | 0.196378 | 1.352976 |
| noop | write | 568 | 0.667418 | 0.346391 | 0.321027 |
| session.add_message | ensure_parent_dirs | 838 | 0.144798 | 0.044737 | 0.100062 |
| session.add_message | pathlock_acquire_exact | 838 | 0.376968 | 0.252758 | 0.124210 |
| session.add_message | pathlock_release | 838 | 0.223326 | 0.120850 | 0.102477 |
| session.add_message | read | 2095 | 0.141770 | 0.035784 | 0.105985 |
| session.add_message | stat | 2095 | 0.185091 | 0.052326 | 0.132764 |
| session.add_message | write | 838 | 0.414739 | 0.304664 | 0.110075 |
| session.commit | ensure_parent_dirs | 427 | 0.324335 | 0.090282 | 0.234053 |
| session.commit | mkdir | 4 | 0.849078 | 0.424565 | 0.424513 |
| session.commit | pathlock_acquire_exact | 61 | 0.389954 | 0.248973 | 0.140981 |
| session.commit | pathlock_release | 61 | 0.236567 | 0.132401 | 0.104167 |
| session.commit | read | 427 | 0.154532 | 0.044361 | 0.110171 |
| session.commit | stat | 2562 | 0.162309 | 0.041982 | 0.120328 |
| session.commit | write | 549 | 0.575212 | 0.395487 | 0.179724 |
| session.create | ensure_parent_dirs | 204 | 0.201389 | 0.060684 | 0.140705 |
| session.create | mkdir | 68 | 0.300341 | 0.128577 | 0.171764 |
| session.create | read | 840 | 1.077048 | 0.212284 | 0.864764 |
| session.create | stat | 1986 | 0.500243 | 0.119687 | 0.380557 |
| session.create | write | 148 | 0.756122 | 0.549121 | 0.207001 |
| session_commit_phase2 | ensure_parent_dirs | 240 | 0.215773 | 0.086319 | 0.129454 |
| session_commit_phase2 | ls | 58 | 0.236596 | 0.129980 | 0.106616 |
| session_commit_phase2 | pathlock_acquire_exact_batch | 58 | 1.562448 | 1.311205 | 0.251243 |
| session_commit_phase2 | pathlock_release | 58 | 0.449890 | 0.332439 | 0.117451 |
| session_commit_phase2 | read | 1345 | 0.779125 | 0.095647 | 0.683478 |
| session_commit_phase2 | stat | 955 | 0.242575 | 0.083422 | 0.159153 |
| session_commit_phase2 | write | 356 | 0.453440 | 0.312554 | 0.140886 |

每行按AGFS方法调用统计；工作线程内包含原生调用与等待。写入流程中的read、stat、锁和write均保留。

## 记忆正文读取（服务端本地操作）

| 阶段 | 平均耗时(ms/请求) |
|---|---:|
| AGFS操作区间并集 | 5.310880 |
| 服务其他处理 | 3.137832 |
| 合计 | 8.448712 |

AGFS按同请求的时间区间并集计算；服务端请求边界包含响应编码与发送交接。
