---
name: docs-build
description: >
  从五视角提取实体 ID，产出 per-entity {ID}.md、各视角 README、扫描生成 KNOWLEDGE_INDEX.md。依赖主 Index Guide。
  触发：初始化/同步知识实体、对齐 ID、docs-indexing 下游要实体等。
  分流：用户只要 INDEX、overview、归档或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/gates.md、intent-clarify、unit-cycle-protocol、grilling-skill。
---

# docs-build

主路径：依赖主 Index Guide，按视角/路径/实体批次生成 `{DOC_DIR}/knowledge/`。

## 输出硬约束（P0）

- 当前单元：单个视角批次、单个路径组，或单批实体集合。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)；未获写前 `C` 不得写 `{DOC_DIR}/knowledge/`。
- 推进环 `C/M/G/S/F` → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)。
- 烤干 → [grilling-skill.md](../../references/grilling-skill.md)；收敛后停等用户，不得自动推进下一批。
- 意图澄清第 6 项须写明当前批次及本轮 `{DOC_DIR}/knowledge/` 下仓库根相对路径（含 `{ID}.md`、README、`KNOWLEDGE_INDEX.md` 等）。
- 校验失败、路径不明或规则未覆盖时须停下澄清，不得静默继续。

## 边界

- 负责：五视角 per-entity、README、`KNOWLEDGE_INDEX.md`、`validate-extraction.sh`
- 不负责：index；docs-okf 迁移；distill/extract；docs-archive；SDD

## 不这样用

- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-build` 偷换成 `docs-indexing`、overview、归档或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 配置 / 规则 | [builtin-config.md](references/builtin-config.md)、[extraction-rules.md](references/extraction-rules.md) |
| README / 归并 | [readme-fill-spec.md](references/readme-fill-spec.md)、[consolidation-spec.md](references/consolidation-spec.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 主 Index Guide 可用
- `{DOC_DIR}` 可解析
- 可确定的视角范围
- `--skip-existing`、`--confidence-threshold`、`--emit-report` 等策略已收口

## 当前单元

- 单个视角批次、路径组，或单批实体集合

收敛后用户动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)；本技能有 `S`。

## 产出

- 产物：各视角 `{ID}.md`、README、KNOWLEDGE_INDEX.md

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
评测重点：意图澄清、单单元停顿、路径/容器含 knowledge 批次、校验后再继续。
