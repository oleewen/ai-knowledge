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

1. 读 [workflow.md](references/workflow.md) 与 [gates.md](references/gates.md)，确认已有参数、当前文件与写入策略。
2. 按 [execution-spec.md](references/execution-spec.md) 定位落盘 Index；按当前文件需要读取证据、生成并校验。
3. 去重时读 [three-file-spec.md](references/three-file-spec.md)，其他场景按 [参考索引](references/README.md) 下钻。

## 硬约束

- 仅消费已落盘 `INDEX-GUIDE.md`；本技能不替代 `docs-indexing`。
- `output` 为 `readme`、`agents` 或 `both`；`mode` 为 `create` 或 `update`。
- 当前单元只有一个根入口文件；`both` 默认 `README.md` 后 `AGENTS.md`，前者未收敛不推进后者。
- 写前完成公共六项澄清与技能追加字段，获得写前 `C` 后才写入；写后必须烤干并等待 `C/M/G/S/F`。
- `update` 合并已有正文；覆盖边界、职责分工或保留策略不清时先给选项并停下。

## 产出与校验

正式产出是目标仓库根的 `README.md`、`AGENTS.md`（按 `output` 可只写一个）。

```bash
bash "$SKILL_DIR/scripts/validate-guide.sh" --root <repo> --output readme
```

`SKILL_DIR` 为当前已加载技能的绝对目录，与目标工程分开解析；`--output` 传当前单元 `readme` 或 `agents`，两文件均完成后用 `both` 检查重复度。仅技能维护者运行 `scripts/test-validate-guide.sh`，普通入口更新无需运行技能自测。

骨架见 [assets/readme-skeleton.md](assets/readme-skeleton.md) 和 [assets/agents-skeleton.md](assets/agents-skeleton.md)；质量清单见 [references/quality-standards.md](references/quality-standards.md)。
