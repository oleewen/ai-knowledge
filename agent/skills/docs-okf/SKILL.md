---
name: docs-okf
description: >
  OKF bundle 迁移、校验与可视化：legacy *-entities.md → per-entity concept、index.md、validate-okf、viz.html。
  触发：/docs-okf、OKF 迁移、刷新 viz、对齐 application/system/company 与 OKF v0.1。
  分流：用户只要 docs-build 提取或 docs-indexing 九章为主路径 → 对应技能。
  门禁：全量迁移前确认 bundle 与 legacy 实体存在（见 workflow）；无 SDD HTML gate。
---

# docs-okf（OKF 迁移与校验）

判定路径 → 读 workflow → 调用 okf-migrate / validate-okf / visualize。

## 边界

| 负责 | 不负责 |
|------|--------|
| OKF 迁移编排、index、KNOWLEDGE_INDEX、validate-okf、viz | INDEX_GUIDE（docs-indexing）；新实体提取（docs-build）；SDD |

## 最短路径

1. [workflow.md](references/workflow.md)（含参数与脚本入口）
2. [naming-conventions.md](../../../agent/knowledge/naming-conventions.md) §OKF
3. INDEX 落盘后 index 刷新：见 [docs-indexing/SKILL.md](../docs-indexing/SKILL.md) 产出节

## 门禁

全量迁移需 legacy `*-entities.md`；`--dry-run` 预览不写盘。细则见 workflow。

## 产出

迁移后的 bundle、`viz.html`、校验报告（参数见 workflow）。

## 评测 / 脚本

```bash
bash scripts/okf-migrate.sh [--dry-run]
bash scripts/validate-okf.sh [--bundle application]
```

与 docs-build / docs-indexing 协作见 workflow 下游表。
