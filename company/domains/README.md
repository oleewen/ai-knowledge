---
type: Documentation
title: domains — 公司域架构
---
# domains — 公司域架构

公司层 SDD：**只**本目录。`/sdx-domains` 写总图 + `DOMAIN-{BD-ID}.md`（哪条 BD 支撑 VC）。**不**写 `solutions/` / `analysis/` / `features/` / `requirements/`。不在此新建 knowledge 实体。

| 项 | 约定 |
|----|------|
| 总图 | [DOMAIN-MAP.md](DOMAIN-MAP.md) |
| 分域 | `DOMAIN-{BD-ID}.md` 平铺 |
| 实体 ID | 引用 `knowledge/` 已有 VC/BD，不新造 |

| 文档 | 对应 BD | 状态 |
|------|---------|------|
| DOMAIN-EXAMPLE.md | BD-EXAMPLE | draft |

规范：[sdx-domains](../../agent/skills/sdx-domains/SKILL.md)
