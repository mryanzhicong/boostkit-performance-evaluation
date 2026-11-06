# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境：128 passed、5 deselected。
- 精确排除已有的两项 Bash 4 与三项 Linux /proc 测试，不计为通过。
- 覆盖 Hudi decimal 精度调整（保留 scale）、配置及数据库选择、非 ARM/optimized 早期拒绝、迁移行数变化/失败/缺表/重复表、来源校验和结果解析失败路径。
- Python compileall、全部所含 Shell bash -n、目录注册、工作流矩阵与 git diff --check 通过。
- 所附 Hudi 0.15.0 JAR SHA-1 与 Maven Central 官方摘要一致，清单另固定实际 SHA-256；未提交 109MB 二进制包。
- 参考原始迁移脚本保持原样（其混合缩进按 vendored 参考文件单独设置 Git whitespace 属性），执行版整理了该处缩进；执行版明确串行、零重试、COW，迁移输出和源目标行数必须通过独立校验。
- 未 SSH、未运行 Docker 服务链路或 GitHub Action，没有性能实测值；真实 ORC COW 写入、Schema/行数与 SF10000 查询仍待 ARM 验证。

## SF100 与磁盘检查更新

- 默认规模改为 SF100；上轮 SF10000 是旧默认值，不再用于本轮配置。SQL 数量、测量轮次和 CPU/内存参数保持不变。
- 磁盘只记录，不设硬性容量拦截；运行时每 10 秒及阶段结束采样文件系统空间，采样日志写满不另行触发阈值停止。实际业务写入错误仍返回失败并执行清理。
- 本轮本地检查：65 项通过（组件、公共 Spark 与目录/矩阵子集）；新增低磁盘不拦截、CPU 检查保留和磁盘日志写满容错测试。
- 未启动 Action、未部署服务器或执行性能测试。
