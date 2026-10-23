# agent-install 工作流

本页定义预览与验收证据。执行顺序见 [SKILL.md](../SKILL.md)，授权条件见 [gates.md](gates.md)。

## 预览摘要

| 项 | 应展示 |
| --- | --- |
| 来源与选择 | 元库绝对路径、scope、IDE 列表；用户指定 IDE 优先于默认值 |
| 实体树 | `$HOME/.agents` 下选中的资源、覆盖方式及[安装过滤](parameters.md#安装过滤)清理范围 |
| 链接 | target 下各 IDE 目录及链接目标，含所选分类内已有第三方资源；同名冲突项的备份计划 |
| 工作区 | 最终 `WORK_SPACE` 值、显式输入或推断来源；推断冲突时列出全局旧值与候选值，标记待用户选择 |
| 状态 | 仅预览 / 等待实跑授权 / 当前授权已覆盖计划 |

首次安装和更新都应说明本次 scope 的链接范围；脚本逐项列出新增或调整的链接，已有正确链接保持不变。dry-run 不改变文件树；输出计划不代表已安装。

## 产物校核

实跑后检查：

- 选中资源存在于实体树，IDE 链接指向对应实体；未选 scope 不新增链接。
- `configs` 的 `WORK_SPACE` 与计划一致，IDE 目录不链接 `configs`。
- 冲突项备份可找到；原工程 `.docsconfig` 内容不变，无则仍不创建。
- 受管同步资源不含[安装过滤名单](parameters.md#安装过滤)中的条目；运行时校验脚本仍可用。第三方资源只建链接时，其内容保持不变。
- 结果摘要包含实际 scope、IDE、target 和失败项；按 [轻流程受众 A/B](../../../references/audience-and-language.md#轻流程-ab含-okf) 检查后交付。

维护脚本时，在元库 `agent/skills/agent-install/` 用 Bash 5+ 运行 `tests/run.sh`，并检查仓根 `bootstrap.sh` 调用兼容性。技能决策用元库同目录的 `evals/evals.json` 验证；安装副本不提供这些研发资源。
