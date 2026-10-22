---
name: docs-install
description: >
  初始化应用、系统、解决方案或公司知识库，或重建工程的 .docsconfig 安装路径配置。
  用户要求 /docs-install、首次安装知识库、配置知识库文档目录时使用。
  保留已有正文的模板升级用 docs-upgrade；仅安装 Agent 用 agent-install。
---

# docs-install

将元库模板安装到 `--target`，或仅重建工程的 `.docsconfig`。重装会备份并重置目标文档树；保留正文的更新用 `docs-upgrade`。

## 执行

1. 收口目标与 scope；knowledge 再定模板源、层级与模式。沿用已明确输入，缺项按 [parameters.md](references/parameters.md) 收口。
2. 按 [workflow.md](references/workflow.md) 检查前置，用 **Bash 5+** 运行 [docs-install.sh](scripts/docs-install.sh) `--dry-run`。
3. 展示路径、配置与覆盖影响，按 [gates.md](references/gates.md) 核对当前计划的写入授权，再执行同一参数集。预览失败则停止并报告阻塞。
4. 核对产物与退出状态，给出装机摘要；轻流程动作及写后 A/B 见 [light-flow-actions.md](../../references/light-flow-actions.md)。

## 边界

- 默认只预览；`--force`、重置已有目标、创建缺失工程根须用户明示。预览期间不补建目标、不改文件来绕过错误。
- `--scope=config` 只重写配置，不同步模板、建链或重写文档；已有 `KNOWLEDGE_TYPE` 不保留。
- knowledge 保留已有建联关系，并登记安装源 `type:meta`。路径遵守 [knowledge-governance.md](../../knowledge/knowledge-governance.md)「knowledge-links 路径契约」；缺配置、旧格式或越界先停止。
- Agent 树用 `agent-install`，联邦登记用 `docs-link`，生态技能追新用 `skill-upgrade`；本技能不向目标复制建联脚本。

故障处理见 [gotchas.md](gotchas.md)；维护、测试与评测见 [维护入口](references/README.md)。
