---
type: Documentation
title: company INDEX-GUIDE
---
# company INDEX-GUIDE

> **最后更新**: 2026-07-22  
> **定位**: `company/` 九章索引指南。目录索引：[index.md](index.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口  
* [index.md](index.md) — OKF 目录索引  
* [DESIGN.md](DESIGN.md) — 设计契约  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 公司知识库；`knowledge/` = BD/CAP/PL/SYS/MDG/TPL SSOT；`system-{name}/` = 镜像槽位  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `system-{name}/` · `changelogs/`  

---

## 二、架构视图

```text
company/
├── README.md / INDEX-GUIDE.md / index.md / DESIGN.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · analysis/
├── system-SYSNAME/
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [system-SYSNAME/](system-SYSNAME/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`。

---

## 四、模块依赖

* `knowledge/` ↔ `system/knowledge/`：公司实体参照  
* `solutions/` → `analysis/` → 各系统 `requirements/`  
* `knowledge-links.yaml` → `system-{name}/`  

---

## 五、详细索引

样本实体与视角：[knowledge/index.md](knowledge/index.md)

---

## 六、API / 字典边界

不承载运行时 API。overview：[knowledge/overview/](knowledge/overview/README.md)

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`CHANGE-LOG.md` · `INDEXING-LOG.md`；槽位日志 ∈ `system-{name}/changelogs/`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`  
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)  

---

## 九、附录

[viz.html](viz.html) · 索引记录 [INDEXING-LOG.md](changelogs/INDEXING-LOG.md)
