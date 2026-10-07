---
type: Agent Index Guide
title: solution INDEX-GUIDE
---
# solution INDEX-GUIDE

> **最后更新**: 2026-10-05  
> **定位**: `solution/` 九章索引指南。目录索引：[index.md](index.md)。契约见 [DESIGN.md](DESIGN.md)。全量扫描由 `/docs-indexing` 回写。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口
* [index.md](index.md) — OKF 目录索引
* [DESIGN.md](DESIGN.md) — 本层设计入口
* [knowledge/README.md](knowledge/README.md) — 五视角
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单
* [changelogs/README.md](changelogs/README.md) — 变更/索引

### 1.2 元信息

* **角色**: 解决方案知识库；一仓一 SLN；`knowledge/` = SLN/PL/PD/BP/BSP/BSD-L2/BS/MDG/TSD SSOT；`system-slots/system-{NAME}` = 系统联邦槽位
* **栈**: Markdown、YAML
* **范围**: `knowledge/` · `solutions/` · `adr/` · `system-slots/` · `changelogs/`
* **装机**: `KNOWLEDGE_TYPE=solution`

---

## 二、架构视图

### 2.1 模块结构

```text
solution/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · adr/
├── system-slots/system-{NAME}/
└── changelogs/
```

parent：`application → system → solution → company`。

---

## 三、接口清单

文档型仓库，无运行时接口。对外契约：本层实体 ID、`/sdx-solution`、槽位软链。

---

## 四、数据模型与对象

### 4.1 业务术语

不适用贴表：术语 SSOT ∈ [glossary.md](../agent/knowledge/glossary.md) / [knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；本层只引不抄。

### 4.2 聚合根（知识组织）

| 聚合 | 职责 | 关键落点 |
|------|------|----------|
| 本层首次实体 | SLN / PD / BSD-L2 / MDG / TSD / BP | [knowledge/](knowledge/README.md)；台账 ∈ 各视角 README |
| overview 缓冲 | extract / archive / tag；distill 来自系统槽位 | [knowledge/overview/](knowledge/overview/README.md) |
| SDD | 仅方案正文 | `solutions/`（`/sdx-solution`） |
| 联邦槽位 | 系统 DOC_ROOT 软链 | `system-slots/system-{NAME}/` · [knowledge-links.yaml](knowledge-links.yaml) |

### 4.3 领域服务

不适用运行时服务：协作能力见根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §4.3。

### 4.4 领域事件

不适用运行时事件：索引运行见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)。

### 4.5 视角导航

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层登记 **SLN / PL / PD / BP / BSP / BSD-L2 / BS / MDG / TSD**。公司 VC/BD/L1/BL/TPL 与系统 SYS 链不在本层登记。

### 视角入口

- [知识库总说明](knowledge/README.md)
- [目录索引](knowledge/index.md)
- [业务](knowledge/business/README.md)
- [产品](knowledge/product/README.md)
- [应用](knowledge/application/README.md)
- [数据](knowledge/data/README.md)
- [技术](knowledge/technical/README.md)
<!-- docs-build:entity-index:end -->

---

## 五、工作流

装机 `docs-install --type=solution` → 建联 `/docs-link`（解决方案←系统）→ 蒸馏系统槽位进 overview。

---

## 六、配置与环境

`.docsconfig`：`KNOWLEDGE_TYPE=solution`，`DOC_DIR` 指向本树。

---

## 七、质量与测试

`docs-install` type=solution 用例；OKF validate 随模板实体。

---

## 八、变更与发布

[changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)

---

## 九、附录

治理：[knowledge-governance](../agent/knowledge/knowledge-governance.md) · 布局：[knowledge-layout](../agent/references/knowledge-layout.md)
