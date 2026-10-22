# agent-install 工作流

本页定义预览与验收证据。执行顺序见 [SKILL.md](../SKILL.md)，授权条件见 [gates.md](gates.md)。

## 预览摘要

| 项 | 应展示 |
| --- | --- |
| 来源与选择 | 元库绝对路径、scope、IDE 列表；用户指定 IDE 优先于默认值 |
| 实体树 | `$HOME/.agents` 下选中的资源、覆盖方式 |
| 链接 | target 下各 IDE 目录及链接目标；已有冲突项的备份计划 |
| 工作区 | 最终 `WORK_SPACE` 值、显式输入或推断来源 |
| 状态 | 仅预览 / 等待实跑授权 / 当前授权已覆盖计划 |

首次安装和更新都应列出本次 scope 的链接。dry-run 不改变文件树；输出计划不代表已安装。

## 产物校核

实跑后检查：

- 选中资源存在于实体树，IDE 链接指向对应实体；未选 scope 不新增链接。
- `configs` 的 `WORK_SPACE` 与计划一致，IDE 目录不链接 `configs`。
- 冲突项备份可找到；原工程 `.docsconfig` 内容不变，无则仍不创建。
- 结果摘要包含实际 scope、IDE、target 和失败项；按 [轻流程受众 A/B](../../../references/audience-and-language.md#轻流程-ab含-okf) 检查后交付。

维护脚本时，用 Bash 5+ 运行 [tests/run.sh](../tests/run.sh)，并检查仓根 `bootstrap.sh` 调用兼容性。技能决策用 [evals.json](../evals/evals.json) 验证。
