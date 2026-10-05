---
name: sdx-feature
description: >
  在已共识 ANALYSIS 上按六章分段「澄清 → 生成 → 烤干」细化特性/FR/MVP，
  并直写 FEATURE-{IDEA-ID}.md；每段写前意图澄清，写入后自动 grilling 至收敛。
  用户提到 /sdx-feature、写 features/、特性拆解且可对齐上游 ANALYSIS 时，使用本技能。
  分流：无 ANALYSIS → /sdx-analysis；PRD/ASD/DSD/TDD 或 docs-* → 对应技能。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-feature/scripts/validate-feature.sh。
---

# sdx-feature

## 输出硬门禁（P0）

- 对象=当前段；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[simplify-principles.md](../../references/simplify-principles.md)、[sdx-adr-protocol.md](../../references/sdx-adr-protocol.md)；细节 [gates.md](references/gates.md)。
- 无已共识 ANALYSIS → 引导 [sdx-analysis](../sdx-analysis/SKILL.md)，不以本技能代写。
- 仅 `KNOWLEDGE_TYPE=system|application`。公司 → `/sdx-domains`；解决方案 → `/sdx-solution`。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `{DOC_DIR}/features/FEATURE-{IDEA-ID}.md` | SOLUTION；PRD/ASD/DSD/TDD；docs-*；公司/解决方案仓 |

## 不这样用

- 不在 `company/` 或 `solution/` 写 `features/`
- 不把本技能偷换成 `/sdx-analysis` 或 `/sdx-prd`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 模板 | [feature-template.md](assets/feature-template.md) |

## 最少输入

- 可对齐的 **`ANALYSIS-{IDEA-ID}.md`**
- `{DOC_DIR}/features/` 可写

## 产出与校验

- 正式：`{DOC_DIR}/features/FEATURE-{IDEA-ID}.md`

```bash
agent/skills/sdx-feature/scripts/validate-feature.sh
```
