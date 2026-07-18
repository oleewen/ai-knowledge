---
type: Documentation
title: application INDEX-GUIDE
---
# application INDEX-GUIDE

> **最后更新**: 2026-07-18  
> **定位**: `application/` 九章索引指南。目录索引见 [index.md](index.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口（standalone → [README-s.md](README-s.md)；central → [README-c.md](README-c.md)）  
* [index.md](index.md) — OKF 目录索引  
* [DESIGN.md](DESIGN.md) — 设计契约与 §2.2.1  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [CONTRIBUTING.md](CONTRIBUTING.md) — 贡献约定  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 应用知识库；实现级实体（API/TBL/MW/CMP）SSOT + 五视角映射  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `requirements/` · `adr/` · `changelogs/`  

---

## 二、架构视图

```text
application/
├── README.md / INDEX-GUIDE.md / index.md / DESIGN.md / docs-meta.md
├── knowledge/ · solutions/ · analysis/ · requirements/ · adr/
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [requirements/](requirements/README.md) · [adr/](adr/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + 实体 `{ID}.md`。

---

## 四、模块依赖

* `knowledge/` ↔ `system/knowledge/`：系统 SSOT / 本层实现映射  
* `knowledge/` ↔ `company/knowledge/`：公司实体 reference  
* `solutions/` → `analysis/` → `requirements/`  

---

## 五、详细索引

样本实体：[knowledge/index.md](knowledge/index.md)

应用层首次：`API` · `TBL` · `MW` · `CMP`（见 [DESIGN.md](DESIGN.md) §2.2.1）

---

## 六、API / 字典边界

API/TBL 实体在 `knowledge/`；不承载运行时 OpenAPI/DDL 全文（可链外部）。

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`CHANGE-LOG.md` · `INDEXING-LOG.md`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`  
* `/docs-build` · `/docs-indexing` — 实体与九章  
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)  

---

## 九、附录

[viz.html](viz.html) · [manifest.md](manifest.md) · 系统对照 [../system/INDEX-GUIDE.md](../system/INDEX-GUIDE.md)
