# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境：128 passed、5 deselected。
- 精确排除已有两项 Bash 4 与三项 Linux /proc 测试，不计为通过。
- 直接执行修正后的分区解析函数，确认能读取带括号的分区列；校验 CREATE TABLE 显式设置 write.format.default=orc。
- 覆盖有效参数路径、源目标数据库、非 ARM/optimized 拒绝、迁移缺表/行数不符和结果样本错误路径。
- Python compileall、全部 Shell bash -n、框架目录/矩阵及 git diff --check 通过。
- 所附 Iceberg 1.5.0 JAR 与 Maven Central 官方 SHA-1 一致，清单另锁定实际 SHA-256。原始迁移脚本保留，执行版修复 Catalog、分区解析及格式配置。
- 未运行 Docker/服务器、SSH 或 Action，没有性能数值；实际 Hive Catalog、ORC 文件和 SF10000 全量查询仍待 ARM 验证。

## SF100 与磁盘检查更新

- 默认规模改为 SF100；上轮 SF10000 是旧默认值，不再用于本轮配置。SQL 数量、测量轮次和 CPU/内存参数保持不变。
- 磁盘只记录，不设硬性容量拦截；运行时每 10 秒及阶段结束采样文件系统空间，采样日志写满不另行触发阈值停止。实际业务写入错误仍返回失败并执行清理。
- 本轮本地检查：65 项通过（组件、公共 Spark 与目录/矩阵子集）；新增低磁盘不拦截、CPU 检查保留和磁盘日志写满容错测试。
- 未启动 Action、未部署服务器或执行性能测试。
