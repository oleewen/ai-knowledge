---
type: Documentation
title: application（mode=s · standalone）
---
# application（mode=s · standalone）

独立安装：本树同时承载 **knowledge SSOT** 与完整 **SDD**。共享入口 [README.md](README.md)；安装差异 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §7.2。

## SDD 文档流

```text
knowledge（实体 SSOT；本层首次：API / TBL / MW / CMP）
    │ 上行：docs-pull → system 槽位 → docs-distill → system overview
    │       （distill 不回写本库 knowledge）
    │
solutions ──→ analysis ──→ requirements
    └──────────────┴──────────────┴──→ 规约：需求包 specs/ 或 knowledge/application/
```

**落地顺序**：补 knowledge ID → 写 solutions / analysis → 建 requirements（`IDEA-ID` 对齐）。

## 阶段目录

| 阶段 | 目录 | 主要产物 |
|------|------|----------|
| 知识基线 | [knowledge](knowledge/README.md) | 五视角实体；治理 [agent/knowledge](../agent/knowledge/README.md) |
| 方案 | [solutions](solutions/README.md) | `SOLUTION-{IDEA-ID}.md` |
| 分析 | [analysis](analysis/README.md) | `ANALYSIS-{IDEA-ID}.md` |
| 交付 | [requirements](requirements/README.md) | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*` |

按需：[changelogs/README.md](changelogs/README.md) · [docs-meta.md](docs-meta.md)
