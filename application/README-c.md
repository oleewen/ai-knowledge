# application — 应用知识库（mode=c）

`application/` 维护应用层面的稳定事实与治理线索，是全仓库的知识中枢。  
本文件面向 `docs-init --mode=central`（`mode=c`）阅读与维护场景，聚焦「按什么顺序读、到哪里写」；九章机器索引与 **central 登记**见 [INDEX_GUIDE.md](INDEX_GUIDE.md)。

## 推荐阅读路径

1. [INDEX_GUIDE.md](INDEX_GUIDE.md)：九章索引（docs-indexing 产出）、文末 **「十、中央知识库接入工程」** 为 `docs-init central` 登记
2. [DESIGN.md](DESIGN.md)：元模型与跨视角关系
3. [CONTRIBUTING.md](CONTRIBUTING.md)：新增/修改流程与模板约束

## 文档流（一页纸）

```text
constitution（治理基线：术语/原则/标准/ADR）
      │
      ├──→ knowledge（SSOT：四视角实体与映射）
      │          ↑
      │          └── 归档 / 回写（如 docs-archive）
      │
      └──→ changelogs（变更留痕与索引运维）
```

**推荐落地顺序**：先核对 **constitution** 治理约束，再查 / 补 **knowledge** 实体与 ID（读 [DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)），最后在 **changelogs** 留痕并维护索引链路。

## central 维护主线

| 主线 | 目录 | 主要内容 |
|------|------|----------|
| 治理基线 | [constitution](constitution/README.md) | 术语、原则、标准、ADR |
| 知识基线 | [knowledge](knowledge) | 四视角知识实体与映射 |
| 变更留痕 | [changelogs](changelogs/README.md) | 变更记录与索引运维文件 |

## 子目录入口

| 目录 | 入口说明 |
|------|----------|
| [constitution/README.md](constitution/README.md) | 宪法层：术语、原则、标准、ADR |
| [knowledge/README.md](knowledge/README.md) | 四视角知识实体组织与映射规则 |
| [changelogs/README.md](changelogs/README.md) | 变更记录与索引运维文件 |

## 机器可读元数据

- 根元数据：[docs_meta.yaml](docs_meta.yaml)
- 子目录元数据：`constitution/constitution_meta.yaml`、`knowledge_meta.yaml`、`changelogs_meta.yaml`

> 约束细则以对应 YAML 与 `DESIGN.md` 为准，本文件不复写字段定义。
