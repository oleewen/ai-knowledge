# docs-link 排障

| 症状 | 处理 |
| --- | --- |
| macOS 默认 Bash 3.2 | 指定已安装的 Bash 5+；版本不足不是测试通过 |
| 找不到 docs-core | 检查源 `.docsconfig` 的 `AGENT_ROOT/AGENT_DIR` 与安装树；可从元库技能路径调用，cwd 仍须为源 Git 根 |
| URL 未登记 | 首次建联用本地目标 Git 根；URL 不触发 clone |
| path 为 `~/…`、绝对路径或越界 | 按[路径契约](../../knowledge/knowledge-governance.md)授权迁移后再试，不自动改清单 |
| 清单 name/repository/dir 缺失或重复 | 先核对原登记；不能补猜后直接覆盖 |
| 槽位失效 | 已登记槽位回拉/修复用 docs-pull；真实目录冲突须用户处置 |
| 下级仓残留旧 scripts/docs-link.sh | 使用元库或已安装技能脚本；不自动删除残留 |

行为与授权以 [工作流](references/workflow.md)、[gates](references/gates.md) 为准。
