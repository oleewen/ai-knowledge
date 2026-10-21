# 排查与补救

| 症状 | 检查与处理 |
| --- | --- |
| incremental 无法启动 | 查目标指南正文锚点或显式 since；无基线时让用户选 full、补 since 或中止 |
| `--help` 之外的命令因配置失败 | 脚本需要 Bash 5+ 及完整 Agent 配置；报告缺项，勿代改配置；可按确认范围直接只读检查 |
| 输出在根目录，统计却来自 docs | `--output` 不改变 `DOC_DIR`；核对 Agent 与脚本各自扫描范围 |
| 暂存的新文件或重命名漏索引 | 按 [scan-spec.md](references/scan-spec.md) 检查全部四类 Git 变更及旧、新路径 |
| “扫描完成”后基线没有变化 | 正常；统计不等于指南完成，正文验证后才显式写锚点 |
| 旧文档出现主表、LOG 或双文件说法 | 以 [indexing-log-spec.md](references/indexing-log-spec.md) 的单文件 HTML 锚点为准 |
| 脚本成功但正文仍旧 | 脚本不阅读文件，也不生成九章；Agent 仍须完成正文工作 |
| `--rewrite` 拒绝更新 | 检查运行标记是否孤立、嵌套、多对或与 OKF/docs-build 块重叠；报告冲突，不自动删除保护块 |
| docs-build 块引用失效路径 | 保留块并报告给 docs-build，不在本技能中重建实体导航 |
| depth 3 仍有未读内容 | 第八章列出具体缺口，不能改称已覆盖或静默降深度 |

验收只维护于 [quality-standards.md](references/quality-standards.md)，不要另建重复检查表。
