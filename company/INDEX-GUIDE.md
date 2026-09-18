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
* [DESIGN.md](DESIGN.md) — 本层设计入口（契约短表 + 治理引用）  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 公司知识库；`knowledge/` = VC/BD/一级 BSD/CAP/PL/SLN/TPL SSOT（无二级 BSD/PD/SYS/MDG）；`system-slots/system-{NAME}` = 软链槽位  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `system-slots/` · `changelogs/`  

---

## 二、架构视图

```text
company/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · analysis/
├── system-slots/
│   ├── system-{NAME}           # 软链 → 系统 DOC_ROOT
│   └── changelogs/             # 层共用 ARCHIVE-LOG；同步追溯 git / SYNC_OK
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [system-slots/](system-slots/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`。

---

## 四、模块依赖

* `knowledge/` ↔ `system/knowledge/`：公司实体参照  
* `solutions/` → `analysis/` → 各系统 `requirements/`  
* `knowledge-links.yaml` → `system-slots/system-{NAME}/`  

---

## 五、详细索引

<!-- docs-build:entity-index:begin -->
> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。九章骨架由 `/docs-indexing` 维护；本块由 `/docs-build` 写入。

### 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `VC-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

### §1 业务视角（business · VC / BD / 一级 BSD / CAP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| VC | VC-EXAMPLE |  | 示例价值链 | `business/VC-EXAMPLE/VC-EXAMPLE.md` |
| BD | BD-EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE.md` |
| BSD | BSD-EXAMPLE |  | 示例一级业务子域 | `business/BSD-EXAMPLE.md` |
| CAP | CAP-EXAMPLE |  | 示例业务能力 | `business/VC-EXAMPLE/CAP-EXAMPLE.md` |

### §2 产品视角（product · PL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | PL-EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE.md` |

### §3 应用视角（application · SLN）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SLN | SLN-EXAMPLE |  | 示例解决方案 | `application/SLN-EXAMPLE.md` |

### §4 技术视角（technical · TPL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TPL | TPL-EXAMPLE |  | 示例技术平台能力 | `technical/TPL-EXAMPLE.md` |

> 本索引登记公司级 **VC / BD / 一级 BSD / CAP / PL / SLN / TPL**；SLN ∈ application（AA）；无二级 BSD/PD/SYS/MDG（见系统库）。

---

### 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| VC-EXAMPLE | `business/VC-EXAMPLE/` |
| BD-EXAMPLE | `business/BD-EXAMPLE.md` |
| BSD-EXAMPLE | `business/BSD-EXAMPLE.md` |
| CAP-EXAMPLE | `business/VC-EXAMPLE/CAP-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE.md` |
| SLN-EXAMPLE | `application/SLN-EXAMPLE.md` |
| TPL-EXAMPLE | `technical/TPL-EXAMPLE.md` |

---

### 交叉引用

- 目录索引：`knowledge/index.md`
- 应用：`knowledge/application/`
- 业务：`knowledge/business/`
- 产品：`knowledge/product/`
- 数据：`knowledge/data/`
- 技术：`knowledge/technical/`
- 知识库总说明：`knowledge/README.md`
<!-- docs-build:entity-index:end -->

## 六、API / 字典边界

不承载运行时 API。overview：[knowledge/overview/](knowledge/overview/README.md)

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`INDEXING-LOG.md`；变更溯源 `git log` / `git diff`；槽位蒸馏日志 ∈ `system-slots/changelogs/ARCHIVE-LOG.md`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`  
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)  

---

## 九、附录

[viz.html](viz.html) · 索引记录 [INDEXING-LOG.md](changelogs/INDEXING-LOG.md)
