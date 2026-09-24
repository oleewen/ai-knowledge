---
type: Documentation
title: company INDEX-GUIDE
---
# company INDEX-GUIDE

> **最后更新**: 2026-09-24  
> **定位**: `company/` 九章索引指南。目录索引：[index.md](index.md)。契约见 [DESIGN.md](DESIGN.md)。

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

* **角色**: 公司知识库；`knowledge/` = VC/BD/BSD(L1)/CAP/PL/SLN/TPL SSOT（无 BSD(L2)/PD/SYS/MDG）；`system-slots/system-{NAME}` = 联邦槽位（软链）  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `adr/` · `system-slots/` · `changelogs/`  

---

## 二、架构视图

```text
company/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · analysis/ · adr/
├── system-slots/
│   ├── system-{NAME}           # 软链 → 系统 DOC_ROOT
│   └── changelogs/             # ARCHIVE-LOG；同步追溯 git / SYNC_OK
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [adr/](adr/README.md) · [system-slots/](system-slots/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`（细则 [DESIGN.md](DESIGN.md)）。

---

## 四、模块依赖

* `knowledge/` ↔ `system/knowledge/`：公司实体参照  
* `solutions/` → `analysis/` → 各系统 `requirements/`  
* `knowledge-links.yaml` → `system-slots/system-{NAME}/`  

门禁与同步：[DESIGN.md](DESIGN.md) § 同步与门禁。

---

## 五、详细索引

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层登记公司级 **VC / BD / BSD(L1) / CAP / PL / SLN / TPL**。

### 视角入口

- [知识库总说明](knowledge/README.md)
- [目录索引](knowledge/index.md)
- [业务](knowledge/business/README.md)
- [产品](knowledge/product/README.md)
- [应用](knowledge/application/README.md)
- [数据](knowledge/data/README.md)
- [技术](knowledge/technical/README.md)
<!-- docs-build:entity-index:end -->

## 六、API / 字典边界

不承载运行时 API。overview：[knowledge/overview/](knowledge/overview/README.md)

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`INDEXING-LOG`；溯源 git；槽位日志 ∈ `system-slots/changelogs/ARCHIVE-LOG.md`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`  
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)  

---

## 九、附录

[viz.html](viz.html) · [INDEXING-LOG.md](changelogs/INDEXING-LOG.md)
