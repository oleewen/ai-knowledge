---
type: Documentation
title: application（应用知识库，mode=c）
---
# application（应用知识库，mode=c）

`application/` 维护应用侧稳定事实、实现登记与治理线索，是全仓库的重要知识中枢。  
本文件面向中央知识库挂载建联（`mode=c`）阅读与维护场景，聚焦「按什么顺序读、到哪里写」；九章机器索引与 **中央知识库挂载建联登记**见 [index.md](index.md)。

## 推荐阅读路径

1. [index.md](index.md)：九章索引（docs-indexing 产出）、文末 **「十、中央知识库接入工程」** 为中央知识库挂载建联之登记
2. [DESIGN.md](DESIGN.md)：元模型与跨视角关系
3. [CONTRIBUTING.md](CONTRIBUTING.md)：新增/修改流程与模板约束

## 文档流（一页纸）

```text
agent/rules（治理基线：术语/原则/命名/ADR）
      │
      ├──→ knowledge（五视角实体登记、实现映射与应用层实体主库）
      │          ↑
      │          └── 蒸馏 / 回写（如 docs-distill）
      │
      └──→ changelogs（变更留痕与索引运维）
```

**推荐落地顺序**：先核对 [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md) 治理约束，再查 / 补 **knowledge** 实体与 ID（读 [DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)），最后在 **changelogs** 留痕并维护索引链路。

## 中央知识库挂载建联维护主线

| 主线 | 目录 | 主要内容 |
|------|------|----------|
| 治理基线 | [agent/knowledge/](../agent/knowledge/knowledge-governance.md) | 术语、原则、命名、ADR |
| 知识基线 | [knowledge](knowledge) | 五视角实体登记、实现映射与应用层实体主库 |
| 变更留痕 | [changelogs](changelogs/README.md) | 变更记录与索引运维文件 |

## 子目录入口

| 目录 | 入口说明 |
|------|----------|
| [knowledge/README.md](knowledge/README.md) | 五视角知识实体组织与映射规则 |
| [changelogs/README.md](changelogs/README.md) | 变更记录与索引运维文件 |

## 机器可读元数据

- 根元数据：[docs-meta.md](docs-meta.md)
- 子目录元数据：`knowledge/knowledge-meta.md`（阶段目录见各 `README.md`，含 [changelogs/README.md](changelogs/README.md)）

> 约束细则以 `docs-meta.md` 与 `DESIGN.md` 为准，本文件不复写字段定义。
