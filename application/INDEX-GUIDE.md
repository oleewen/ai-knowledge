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
* [DESIGN.md](DESIGN.md) — 本层设计入口（契约短表 + 治理引用）
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
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge/ · solutions/ · analysis/ · requirements/ · adr/
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [requirements/](requirements/README.md) · [adr/](adr/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + 实体 `{ID}.md`。

---

## 四、模块依赖

* `knowledge/` ↔ `system/knowledge/`：系统 SSOT / 本层实现映射；上行 pull → distill（系统 overview）
* `knowledge/` ↔ `company/knowledge/`：公司实体 reference
* `solutions/` → `analysis/` → `requirements/`（mode=s）

---

## 五、详细索引

<!-- docs-build:entity-index:begin -->
> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。九章骨架由 `/docs-indexing` 维护；本块由 `/docs-build` 写入。

### 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `VC-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

### §1 业务视角（business · BSD(L1) → BSD(L2) → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| — | — | — | — | — |

### §2 产品视角（product · PD → PM → FT → FR → UC/BR · BP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| — | — | — | — | — |

### §3 应用视角（application · SYS → APP → MS → API）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| API | API-EXAMPLE |  | 示例 API：创建 | `application/MS-EXAMPLE/API-EXAMPLE.md` |

### §4 数据视角（data · MDG → DS → ENT → TBL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TBL | TBL-EXAMPLE |  | 示例数据表 | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |

### §5 技术视角（technical · TSD → MW → CMP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MW | MW-EXAMPLE |  | 示例中间件绑定 | `technical/MW-EXAMPLE/MW-EXAMPLE.md` |
| CMP | CMP-EXAMPLE |  | 示例组件 | `technical/MW-EXAMPLE/CMP-EXAMPLE.md` |

> 本索引仅登记本层首次定义样例（API/TBL/MW/CMP）。上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。产品 **PL/SLN** 见公司；**PD/PM** 见系统层。

---

### 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| API-EXAMPLE | `application/MS-EXAMPLE/API-EXAMPLE.md` |
| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |
| MW-EXAMPLE | `technical/MW-EXAMPLE/` |

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

API/TBL 实体在 `knowledge/`；不承载运行时 OpenAPI/DDL 全文（可链外部）。

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`INDEXING-LOG.md`；变更溯源 `git log` / `git diff`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`
* `/docs-build` · `/docs-indexing` — 实体与九章
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)

---

## 九、附录

[viz.html](viz.html) · [manifest.md](manifest.md) · 系统对照 [../system/INDEX-GUIDE.md](../system/INDEX-GUIDE.md)

---

## 十、中央知识库接入

standalone / central 差异与安装约定见仓库根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §7.2 与 [agent/skills/docs-install/SKILL.md](../agent/skills/docs-install/SKILL.md)。本库 mode 入口：[README-s.md](README-s.md) · [README-c.md](README-c.md)。
