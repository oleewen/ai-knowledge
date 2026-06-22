---
name: docs-okf
description: >
  OKF bundle 迁移、校验与可视化：legacy *-entities.md → per-entity concept、index.md、validate-okf、viz.html。
  须先读 .docsconfig：DOC_DIR→--bundle，KNOWLEDGE_TYPE→viz --out/--name；无 config 或缺 KNOWLEDGE_TYPE 硬中止。
  触发：/docs-okf、OKF 迁移、刷新 viz、DOC_DIR、DOC_ROOT、KNOWLEDGE_TYPE、目标工程 OKF。
  分流：用户只要 docs-build 提取或 docs-indexing 九章为主路径 → 对应技能。
  门禁：全量迁移前确认 bundle 与 legacy 实体存在（见 workflow）；无 SDD HTML gate。
---

# docs-okf（OKF 迁移与校验）

判定路径 → 读 path-resolution → 读 workflow → 调用 okf-migrate / validate-okf / visualize。

## 边界

| 负责 | 不负责 |
|------|--------|
| OKF 迁移编排、index、KNOWLEDGE_INDEX、validate-okf、viz | INDEX_GUIDE（docs-indexing）；新实体提取（docs-build）；SDD |

## 最短路径

1. [path-resolution.md](references/path-resolution.md) → [workflow.md](references/workflow.md)
2. [naming-conventions.md](../../../agent/knowledge/naming-conventions.md) §OKF
3. INDEX 落盘后 index 刷新：见 [docs-indexing/SKILL.md](../docs-indexing/SKILL.md) 产出节

## 门禁

全量迁移需 legacy `*-entities.md`；`--dry-run` 预览不写盘。须有效 `.docsconfig`（含 `KNOWLEDGE_TYPE`）。细则见 workflow。

## 产出

迁移后的 bundle、`viz.html`、校验报告（参数见 workflow）。

## 评测 / 脚本

```bash
bash scripts/okf-migrate.sh [--dry-run]    # 须 .docsconfig + KNOWLEDGE_TYPE
bash scripts/validate-okf.sh [--bundle "${DOC_DIR}"]
```

与 docs-build / docs-indexing 协作见 workflow 下游表。
