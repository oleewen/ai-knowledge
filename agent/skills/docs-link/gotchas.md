# docs-link 排障

| 症状 | 处理 |
| --- | --- |
| macOS 默认 Bash 3.2 | 指定已安装的 Bash 5+；版本不足不是测试通过 |
| 找不到 docs-core | 检查源 `.docsconfig` 的 `AGENT_ROOT/AGENT_DIR` 与安装树；可从元库技能路径调用，cwd 仍须为源 Git 根 |
| URL 未登记 | 首次建联用本地目标 Git 根；URL 不触发 clone |
| path 为 `~/…`、绝对路径或越界 | 按[路径契约](../../knowledge/federation-config.md#knowledge-links-路径契约)授权迁移后再试，不自动改清单 |
| 清单 name/repository/dir 缺失或重复 | 先核对原登记；不能补猜后直接覆盖 |
| 清单结构非法（如 `links: []` 后仍有条目） | link/unlink 与 check/repair 均拒绝；先确认数据修订，不能借建联自动解释或修复 |
| 名称仅大小写不同 | link 将名称规范化为小写；按实际目录项识别旧槽位，避免大小写不敏感磁盘上删掉有效链接，写后核对双边清单与槽位 |
| 槽位失效 | 先 `--check`，再对已登记 target 预览 `--repair`；真实文件/目录保留 |
| 缺仓、配置或反向 parent 不符 | 停止维护；按登记 path 准备仓库或定向纠正登记，不自动 clone、安装或改 YAML |
| dirty/detached | 允许槽位检查/修复；内容更新另走该仓 Git 工作流，不 stash/reset/切分支 |
| 下级仓残留旧 scripts/docs-link.sh | 使用元库或已安装技能脚本；不自动删除残留 |

行为与授权以 [工作流](references/workflow.md)、[gates](references/gates.md) 为准。
