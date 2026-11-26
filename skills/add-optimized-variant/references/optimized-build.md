# 优化版构建实现

以 `software/AI/numpy` 为参考。下文用 `<sw>`/`<SW>` 表示组件名（小写/大写），`<NAME>` 表示 `case.yaml` 里 `test_tools` 的条目名。原则：**只在构建阶段分流**，`start`/`test`/`stop` 与解析逻辑共用，靠 `EXPECTED` 变量感知取点。

## 1. 目录与命名

```
software/<category>/<software>/
├── case.yaml
├── README.md
├── scripts/
│   ├── common.sh                    # 取点常量、期望值加载、环境切换
│   ├── builders/{dispatch,base,optimized}.sh
│   ├── stages/{start,test,stop}.sh
│   └── results/parse_*.py
└── tests/
```

## 2. `scripts/builders/optimized.sh`

按用户要求**从 `base.sh` 拷贝**（`cp base.sh optimized.sh`），保留全部共享函数（装包、解释器、venv、子模块、构建 wheel、安装、套件、`asv machine`、运行期版本记录）逐字不动，只改下面四处：

1. **头部注释**：写清取点、测量语义、边界（不碰 OS/BIOS、不依赖 base 产物）。
2. **取点函数**：把 `numpy_clone_baseline` 换成 `<sw>_clone_optimized`：

```bash
<sw>_clone_optimized() {
    if ! <container_exec> test -d "${<SW>_REPO_DIR}/.git"; then
        <container_exec> mkdir -p "${SOURCE_DIR}"
        <container_exec> git clone --branch "${<SW>_OPTIMIZED_BRANCH}" \
            "${<SW>_REPOSITORY}" "${<SW>_REPO_DIR}" > "${log}" 2>&1
    fi
    branch="$(<container_exec> git -C "${<SW>_REPO_DIR}" rev-parse --abbrev-ref HEAD)"
    [ "${branch}" = "${<SW>_OPTIMIZED_BRANCH}" ] || { log "ERROR: ..."; return 30; }
    <SW>_HEAD_COMMIT="$(<sw>_repo_commit)"
    <SW>_HEAD_TREE="$(<sw>_repo_tree)"
    # range 的排除端也要存在，否则 asv 的 rev-list 直接失败
    <SW>_PARENT_COMMIT="$(<container_exec> git -C "${<SW>_REPO_DIR}" rev-parse 'HEAD~1^{commit}')"
    <SW>_PARENT_TREE="$(... 'HEAD~1^{tree}')"
    <sw>_write_source_record || return $?
}
```

3. **工具暴露**：把测量 venv 里、隔离构建缺了就失败的二进制放到 PATH：

```bash
<sw>_expose_build_tools() {
    for tool in patchelf ninja; do
        [ -x "${VENV_DIR}/bin/${tool}" ] || { log "ERROR: ..."; return 30; }
        <container_exec_root> install -m 0755 "${VENV_DIR}/bin/${tool}" "/usr/local/bin/${tool}" >> "${log}" 2>&1
    done
}
```

4. **`build_variant.json` 扩展**：在原有字段外补 `branch`、`parent_commit`、`parent_tree`、`commit_range`（以及 `parameters` 里的同名字段）。嵌入的 Python heredoc 必须显式校验参数个数，避免“少传一个参数”变成难查的错位：

```python
if len(sys.argv) != 24:
    raise SystemExit(f"expected 23 arguments, got {len(sys.argv) - 1}")
```

`build_<sw>_optimized()` 的步骤顺序：宿主工具检查 → 容器 → 装包 → 解释器 → venv → 取源码（写记录）→ 子模块 → 构建 wheel → 安装 → 套件 → `asv machine` → 暴露构建工具 → ASV/工具的 git 配置 → 运行期版本 → `build_variant.json` → 实际版本文件。

## 3. `scripts/common.sh`

新增，不要改动共用容器块：

```bash
<SW>_OPTIMIZED_BRANCH="master"          # 或 tag / 固定 hash
<SW>_OPTIMIZED_RANGE="HEAD~1..HEAD"     # 仅当测量工具支持 range 且需要时
<SW>_SOURCE_RECORD=""                   # configure_runtime_paths 里赋值为 ${PERF_WORK_DIR}/<sw>-source.txt
<SW>_EXPECTED_COMMIT=""; <SW>_EXPECTED_TREE=""
<SW>_EXPECTED_BRANCH=""; <SW>_EXPECTED_PARENT=""
```

- `configure_runtime_paths`：设置 `<SW>_SOURCE_RECORD` 并 export 全部 `EXPECTED_*`、`HEAD_*`、`PARENT_*`。
- 记录读取：`<sw>_source_record_value KEY` 从 `KEY=VALUE` 文件取值。
- 期望值加载 `<sw>_load_expected_source()`（幂等）：
  - base：`EXPECTED_COMMIT=<SW>_BASELINE_COMMIT`、`EXPECTED_TREE=<SW>_BASELINE_TREE`，分支/父提交为空；
  - optimized：读记录里的 `head`/`head_tree`/`branch`/`parent`，记录缺失或分支不符返回 30，并给出可操作的错误（“build 阶段必须先运行”）。
- 环境切换：基础版沿用“断网黑洞”环境；优化版在测量窗口导出 pip 镜像（`PIP_INDEX_URL`、`PIP_EXTRA_INDEX_URL`、`PIP_TRUSTED_HOST`、`PIP_DISABLE_PIP_VERSION_CHECK=1`），并去掉代理黑洞变量，因为工具的隔离构建需要取包。
- `verify_runtime_payload`：commit/tree 校验改用 `EXPECTED_*`，日志注明 `(${EXPECTED_BRANCH:-${PERF_VARIANT}})`。

## 4. `scripts/stages/start.sh`

`discover` 前调用 `<sw>_load_expected_source || return $?`，命令里的 `--set-commit-hash` 用 `${<SW>_EXPECTED_COMMIT}`。基础版行为不变（期望值等于钉住的基线）。

## 5. `scripts/stages/test.sh`

- 命令按 variant 分派：
  - base：保持 `--python=same --set-commit-hash "${EXPECTED_COMMIT}" --no-pull`；
  - optimized：去掉 `--python=same`（多数工具不允许“既有环境 + range”），换成 `<SW>_OPTIMIZED_RANGE`（或直接钉 commit），并让工具自行建环境/构建。
- 环境用 `mapfile -t run_env < <(<sw>_asv_env)` 生成，避免在命令里内联一长串 `env`。
- 结果收集用 `${EXPECTED_COMMIT:0:8}-*.json`；父提交记录**存在才收集**，缺失不失败。
- 解析阶段显式传 `EXPECTED_COMMIT`、`EXPECTED_BRANCH`、`EXPECTED_PARENT`、`COMMIT_RANGE`。

## 6. 解析器

```python
expected_commit = (
    os.environ.get("<SW>_EXPECTED_COMMIT") or os.environ["<SW>_BASELINE_COMMIT"]
).strip()
```

- 校验信息同时点名两个变量，便于排查；
- 只在 `variant == "optimized"` 时给文档补 `branch`/`parent_commit`/`commit_range`；
- 基础版输出逐字节保持，不要顺带改字段顺序或统计口径。

## 7. `case.yaml`

```yaml
test_tools:
  <NAME>: {version: "<version>", revision: "<baseline commit>"}
  <NAME>_optimized: {version: "<version>", revision: "<branch|tag|commit>"}
```

`framework/catalog.py` 只允许 `test_tools` 出现 `version`、`revision` 两个字段，两者都必须是非空字符串。

## 8. README 与测试

- README：两变体分列取点/命令；`与指导的差异` 每条写“原命令 → 实际命令 → 理由”；`已知限制` 写网络、工具链、未采用项、取点会移动。
- 测试（`tests/test_optimized_variant.py` 形态）：
  - 构建入口存在、不调用 `build_<sw>_base`、不出现 OS/BIOS 模式；
  - 记录往返、记录缺失返回 30、分支不符返回 30；
  - base 仍钉死基线 commit/tree；
  - 环境切换：优化版有 pip 镜像变量、无代理黑洞；基础版相反；
  - 解析器：期望 commit 命中/不命中（返回 50）、优化版元数据、基础版文档不变。

## 9. 自查清单

- [ ] `optimized.sh` 与 `base.sh` 的共享函数逐字一致（除取点相关）
- [ ] 没有任何 `sysctl`/`/sys`/governor/THP/hugepage/tuned/MSR/`--privileged`
- [ ] 容器启动参数与 base 逐字一致
- [ ] `build_variant.json.commit` 是实际被测 commit
- [ ] `results/<version>/optimized/<run-id>` 隔离未被破坏
- [ ] 网络/构建失败都会非零退出
- [ ] 未 commit、未 push（除非用户要求）
