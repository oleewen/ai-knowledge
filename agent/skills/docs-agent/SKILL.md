---
name: docs-agent
description: >
  维护仓库根 README.md 与 AGENTS.md，并按已落盘 INDEX-GUIDE.md 对齐入口信息。
  适用于 /docs-agent、写 README/AGENTS、根入口与索引不同步。
  不重写 INDEX-GUIDE.md、index.md、knowledge 实体或 SDD 产物；这些任务分别转 docs-indexing、docs-build、docs-revise 或 sdx-*。
---

# docs-agent

维护仓库根 `README.md` 与 `AGENTS.md`。入口只保留职责、约束和下钻路径，细节按需读取参考文件。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 根 `README.md`、`AGENTS.md`；`output` / `mode`；按 `INDEX-GUIDE.md` 对齐 | `INDEX-GUIDE.md`、`index.md`、knowledge 实体、术语链式修订、SDD / overview 主流程 |

分流：索引重建用 `docs-indexing`，实体构建用 `docs-build`，术语或事实修订用 `docs-revise`，SDD 产物用对应 `sdx-*`。

## 最短路径

1. [references/README.md](references/README.md)：按场景选参考文件。
2. [references/gates.md](references/gates.md)：收口参数、写入策略和停顿条件。
3. [references/workflow.md](references/workflow.md)：解析 Index、选择当前单元、生成与校验。
4. 按需读取 [references/execution-spec.md](references/execution-spec.md)、[references/three-file-spec.md](references/three-file-spec.md) 和模板。

## 硬约束

- 仅消费已落盘 `INDEX-GUIDE.md`；本技能不替代 `docs-indexing`。
- `output` 为 `readme`、`agents` 或 `both`；`mode` 为 `create` 或 `update`。
- 当前单元只有一个根入口文件；`both` 默认 `README.md` 后 `AGENTS.md`，前者未收敛不推进后者。
- 写前完成公共六项澄清与技能追加字段，获得写前 `C` 后才写入；写后必须烤干并等待 `C/M/G/S/F`。
- `update` 合并已有正文；覆盖边界、职责分工或保留策略不清时先给选项并停下。

## 产出与校验

正式产出是目标仓库根的 `README.md`、`AGENTS.md`（按 `output` 可只写一个）。

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root <repo>
bash agent/skills/docs-agent/scripts/test-validate-guide.sh
```

骨架见 [assets/readme-skeleton.md](assets/readme-skeleton.md) 和 [assets/agents-skeleton.md](assets/agents-skeleton.md)；质量清单见 [references/quality-standards.md](references/quality-standards.md)。
