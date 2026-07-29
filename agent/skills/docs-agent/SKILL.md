---
name: docs-agent
description: >
  维护或初始化仓库根目录 README.md 与 AGENTS.md。
  用户提到 /docs-agent、入口与 INDEX 不同步、口述「写 README」「更新 AGENTS」时，使用本技能。
  分流：用户只要 docs-indexing/docs-build/docs-upgrade 或 SDD/distill/extract → 对应技能。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/docs-agent/scripts/validate-guide.sh。
---

# docs-agent

## 输出硬约束（P0）

- 当前单元：`README.md` 或 `AGENTS.md`（一次只其一）。
- 写前澄清 / 推进环 `C/M/G/S/F` / 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；细节 [gates.md](references/gates.md)。未获写前 `C` 不得写入；收敛后停等用户，不得自动推进下一入口文件。
- **INDEX 锚点**：须已落盘 `INDEX-GUIDE.md`（例外见 execution-spec）；不在本技能内重写 INDEX。
- `both` 默认先 README 后 AGENTS；前一单元未收敛前不得静默写后一单元。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 根 README.md、AGENTS.md；`--output` / `--mode`；与 `INDEX-GUIDE.md` 对齐 | index（docs-indexing）；实体（docs-build）；术语批量（docs-upgrade）；SDD / distill / extract 主流程 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后「澄清 → 生成 → 烤干」
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不在本技能内重写或替代 `INDEX-GUIDE.md`；INDEX 主路径仍是 `docs-indexing`
- 不把术语链式替换、overview 维护、实体索引等任务收成 `docs-agent`

## 路由

| 目的 | 文件 |
| ---- | ---- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 受众与语言 | [audience-and-language.md](references/audience-and-language.md) |
| 执行细则 | [execution-spec.md](references/execution-spec.md)、[three-file-spec.md](references/three-file-spec.md) |
| 质量 / 易错 | [quality-standards.md](references/quality-standards.md)、[gotchas.md](gotchas.md) |
| 模板 | [readme-skeleton.md](assets/readme-skeleton.md)、[agents-skeleton.md](assets/agents-skeleton.md) |
| docs 族结构 | [docs-skill-skeleton.md](references/docs-skill-skeleton.md) |

## 最少输入

- 已落盘的 `INDEX-GUIDE.md`
- `output`、`mode` 已收口
- 根入口文件目标路径可解析
- 若涉及覆盖/合并边界，已确认风险策略

## 产出与校验

- 正式：默认 `{REPO_ROOT}` 下 README.md、AGENTS.md（`--output` 可只其一）
- 收敛后动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（本技能有 `S`）

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。聚焦：意图澄清、当前单元推进、INDEX 驱动边界。
