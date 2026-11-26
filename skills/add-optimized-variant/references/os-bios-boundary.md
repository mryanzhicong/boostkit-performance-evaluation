# OS/BIOS 边界

优化版用例比较的是“同一套开箱环境下，两份源码的表现”。一旦优化逻辑顺手改了系统参数，`base` 与 `optimized` 就不再可比，结果也不能用于评估优化方案本身。因此：

> **优化逻辑只允许修改容器用户态与被测源码，不得修改 OS/BIOS 参数。**

## 1. 允许

- 容器内包管理（`dnf`/`apt`/`pip`）与容器内工具安装；
- 把测量环境里的构建工具放到 `/usr/local/bin`（`patchelf`、`ninja` 等）；
- `$HOME` 内配置：`git config --global`（`protocol.file.allow`、镜像 `insteadOf`）、`pip.conf`；
- 构建产物、wheel、安装到测量 venv；
- 结果目录、日志、`build_variant.json` 等产物写入；
- 与基础版**完全一致**的容器启动参数（网络、`--ulimit nofile=…`、挂载、用户）。

## 2. 禁止（可执行行）

| 类别 | 模式 |
|---|---|
| 内核参数 | `sysctl`、`/proc/sys`、`--sysctl` |
| sysfs / 设备调优 | `/sys/`、`/sys/kernel/mm`、`transparent_hugepage`、`hugepage` |
| CPU 调频/隔离 | `cpupower`、`tuned-adm`、`governor`、`irqbalance`、`taskset`/`numactl` 绑核 |
| 固件/寄存器 | `wrmsr`、`msr`、`setpci`、`dmidecode` 写操作 |
| 权限扩张 | `--privileged`、`--cap-add`、挂宿主 `/proc` 或 `/sys` |
| NMI/PMU 常驻 | `/proc/sys/kernel/nmi_watchdog`、`perf_event_paranoid` |

**扫描命令**（对可执行行，排除注释行）：

```bash
grep -nE '\b(sysctl|cpupower|tuned-adm|governor|irqbalance|numactl|taskset|wrmsr|msr|setpci|dmidecode)\b|/proc/sys|/sys/|transparent_hugepage|hugepages?|--privileged|--cap-add|--sysctl' \
  software/AI/<sw>/scripts/builders/optimized.sh \
  software/AI/<sw>/scripts/stages/{start,test}.sh
```

结果必须是“零命中”。唯一的共享项是 `scripts/common.sh` 生成容器块里的 `--ulimit nofile=…`（容器进程 rlimit，两变体逐字相同，且该块不得手改时针）。

## 3. 容器启动参数一致性

- `numpy_configure_container`/`<sw>_configure_container` 等生成块对两变体共用，不要用 `if [ "$PERF_VARIANT" = optimized ]` 增加参数。
- 需要新增挂载或环境变量时，先问用户；新增项必须同时作用于 base 与 optimized，否则两变体不可比。
- 容器名、label、工作目录可以按 run-id 变化，这不影响可比性。

## 4. 方案本身要求 OS 调优时

1. **先停下**，向用户说明：该调优会改变宿主/容器内核状态，破坏开箱可比性，且可能影响同机其他任务。
2. 默认不实现，把该项记录到 README 的“未采用/未验证”，并在交付说明里点名方案中的该条目。
3. 若用户明确要求并书面确认，需要：
   - 在 README 写明改动内容、生效范围、回滚方式；
   - 保证 base 与 optimized 施加**相同**的系统改动（否则不可比）；
   - 把系统改动放在用例之外（例如 Runner 预置），而不是塞进优化版构建脚本。

## 5. 如何证明遵守

- 静态：`tests/` 里的 OS/BIOS 模式回归测试（可执行行零命中）；
- 运行期：交付运行时附 `docker inspect` 的 `HostConfig`/`Cmd` 对比，确认两变体一致；
- 交付报告：贴出扫描命令与结果（零命中），并写明未采用项。
