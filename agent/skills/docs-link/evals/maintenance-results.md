# 槽位维护验收记录

2026-10-23：新增 check/repair 的脚本回归、安装验证和独立复审通过。行为场景库共 26 项，其中新增维护场景 12 项；新增场景未逐项执行完整 Agent 评分，状态为 `not_run`。

| 检查 | 结果 |
| --- | --- |
| Bash 5 `tests/run.sh` | 30/30 通过；维护用例 22–30 |
| 聚合回归 `agent/scripts/tests/run.sh --full` | 11 个套件全部通过，退出 0 |
| 结构、Shell 语法、Markdown 引用、补丁格式 | 通过；命令见[评测方法](../references/evaluation.md) |
| 安装副本 | 与源脚本一致；临时双仓验证 check、缺槽失败、repair dry-run、实际 repair 与复查通过 |
| 安装副本写入边界 | dry-run 前后快照一致；实际 repair 只改变选中槽位 |
| 独立复审 | 三层映射检查通过；发现并修复空数组清单后追加条目仍被接受的问题 |
| 缺陷复核 | case27 通过；额外覆盖源/目标歧义清单的 8 次检查/修复调用，均非零且快照不变 |
| 后续审查修复 | 拒绝嵌套身份字段；重复/旧字段不再中断后续 child 检查；重复 type 直接拒绝，防止隐藏 child |
| 后续独立复审 | 28–30 通过；另验 4 种源/目标重复 type，检查与修复预览均拒绝、快照不变，无新发现 |
| 本机修复版本 | 已同步运行文件；使用已安装共享库独立执行 28–30，全部通过 |

回归先记录失败，再验证修复。临时原始日志为 `/tmp/docs-link-maintenance-red.log`、`/tmp/docs-link-ambiguous-red.log` 和 `/tmp/docs-link-maintenance-green-final.log`；临时文件可能被系统清理，可按评测方法复跑。

后续修复失败证据为 `/tmp/docs-link-review-fix-{28,29,30}-red.log`；最终聚合日志为 `/tmp/docs-link-review-fix-final-full.log`。

命令级验证和代码审查不等于 Agent 行为评分。既有 link/unlink 记录保留在 [results.md](results.md)，不回写历史成绩。未测试权限竞争、磁盘故障或进程中断。
