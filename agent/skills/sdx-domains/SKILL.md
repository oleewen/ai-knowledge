---
name: sdx-domains
description: >
  仅公司库：按「澄清 → 生成 → 烤干」写域架构总图 DOMAIN-MAP.md 与 DOMAIN-{BD-ID}.md（哪条 BD 支撑 VC）。
  用户提到 /sdx-domains、写 company/domains、域架构总图时，使用本技能。
  分流：SOLUTION → /sdx-solution（仅解决方案库）；系统/应用分析 → /sdx-analysis；docs-* → 对应技能。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-domains/scripts/validate-domains.sh。
---

# sdx-domains

## 输出硬门禁（P0）

- 对象=当前段（总图或单个 `DOMAIN-{BD-ID}`）；一次一段。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)；细节 [gates.md](references/gates.md)。
- **仅** `KNOWLEDGE_TYPE=company`。禁止写 `solutions/` / `analysis/` / `requirements/`。禁止在本技能新建 knowledge 实体。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `company/domains/DOMAIN-MAP.md`、`DOMAIN-{BD-ID}.md` | SOLUTION/ANALYSIS/PRD；knowledge 实体正文；系统 PRD |

## 不这样用

- 不把公司域架构写成 `SOLUTION-*.md`
- 不直拆系统 `requirements/`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 模板 | [domain-template.md](assets/domain-template.md) |

## 最少输入

- 已有 VC/BD 实体 ID（`company/knowledge/`）
- `company/domains/` 可写

## 产出与校验

```bash
agent/skills/sdx-domains/scripts/validate-domains.sh
```
