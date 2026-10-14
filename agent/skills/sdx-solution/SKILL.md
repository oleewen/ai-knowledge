---
name: sdx-solution
description: >
  以当时最新的 knowledge 为事实基准，按五段叙事增量直写 SOLUTION-{IDEA-ID}.md。
  用户提到 /sdx-solution、写解决方案、交付包切分、范围内外、主数据主权或技术例外时，使用本技能。
  分流：需求分析 → /sdx-analysis；功能特性 → /sdx-feature；公司域 → /sdx-domains；docs-* → 对应技能。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-solution/scripts/validate-solution.sh（仅结构/内容校验）。
---

# sdx-solution

## 输出硬门禁（P0）

- 对象=当前段；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[simplify-principles.md](../../references/simplify-principles.md)；细节 [gates.md](references/gates.md)。
- 仅 `KNOWLEDGE_TYPE=solution`（别名 `sln`）。公司 → `/sdx-domains`。系统/应用需求分析 → `/sdx-analysis`。
- 选定的上一份已经有后继 → 硬停，不写第二份。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `SOLUTION-{IDEA-ID}.md` 交付包切分叙事、参数向导、意图澄清、分段生成、段内烤干 | `ANALYSIS/FEATURE/PRD/ASD/DSD/TDD`；docs-*；实体字段定义；需求条目；实现；`SYS` |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不改已经落盘的旧 `SOLUTION`
- 不把 `SOLUTION` 写成七章需求分析，或在正文出现 `SYS`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| IDEA-ID / 现行 | [core-concepts.md](references/core-concepts.md) |
| 模板 | [solution-template.md](assets/solution-template.md) |

## 最少输入

- 当时最新的 knowledge（`PD` / `BP` / `BSP` / `MDG` / `TS`）
- 主题或标题线索
- `{DOC_DIR}/solutions/` 可写
- 若已给 `IDEA-ID`、上一份 ID、章节范围，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md
```
