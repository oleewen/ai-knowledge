---
type: Documentation
title: application（mode=c · central）
---
# application（mode=c · central）

## 维护主线

```text
agent/knowledge（治理 / 命名）
  ├──→ knowledge（五视角 + 实现级实体 SSOT）
```

**落地顺序**：核 [DESIGN.md](DESIGN.md)（→ [knowledge-governance](../agent/knowledge/knowledge-governance.md)）→ 补 knowledge ID → git 溯源。

本库：`docs-extract` / `docs-archive` 写 `knowledge/overview/{NAME}-overview.md`。上行：`docs-link` 挂载系统槽位；**docs-distill 只写 system overview**。

## 主线目录

| 主线 | 目录 | 内容 |
|------|------|------|
| 本层设计入口 | [DESIGN.md](DESIGN.md) | 契约短表 + 治理引用；语义 SSOT → [knowledge-governance](../agent/knowledge/knowledge-governance.md) |
| 治理基线 | [agent/knowledge](../agent/knowledge/README.md) | 术语、原则、命名、ADR |
| 知识基线 | [knowledge](knowledge/README.md) | 五视角与实现级实体 |
| 变更溯源 | git | 变更溯源 git |
