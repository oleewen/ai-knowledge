# KNOWLEDGE-INDEX

> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `BU-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BD → BSD → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BSD | BSD-EXAMPLE |  | 示例业务子域 | `business/BSD-EXAMPLE/BSD-EXAMPLE.md` |
| BC | BC-EXAMPLE |  | 示例限界上下文 | `business/BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md` |
| AGG | AGG-EXAMPLE |  | 示例聚合 | `business/BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md` |
| AB | AB-EXAMPLE |  | 示例能力 | `business/BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md` |

---

## §2 产品视角（product · PD → PM → FT → FR → UC/BR · BP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PD | PD-EXAMPLE |  | 示例产品服务 | `product/PD-EXAMPLE/PD-EXAMPLE.md` |
| PM | PM-EXAMPLE |  | 示例产品模块 | `product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md` |
| FT | FT-EXAMPLE |  | 示例功能 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md` |
| FR | FR-EXAMPLE |  | 示例功能需求 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md` |
| UC | UC-EXAMPLE |  | 示例用例 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md` |
| BR | BR-EXAMPLE |  | 示例规则 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md` |
| BP | BP-EXAMPLE |  | 示例业务流程（BP） | `product/BP-EXAMPLE.md` |

---

## §3 应用视角（application · SYS → APP → MS）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | SYS-EXAMPLE |  | 示例系统 | `application/SYS-EXAMPLE.md` |
| APP | APP-EXAMPLE |  | 示例应用 | `application/APP-EXAMPLE/APP-EXAMPLE.md` |
| MS | MS-EXAMPLE |  | 示例微服务 | `application/APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md` |

---

## §4 数据视角（data · MDG → DS → ENT）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MDG | MDG-EXAMPLE |  | 示例主数据域 | `data/MDG-EXAMPLE.md` |
| DS | DS-EXAMPLE |  | 示例数据源 | `data/DS-EXAMPLE/DS-EXAMPLE.md` |
| ENT | ENT-EXAMPLE |  | 示例实体 | `data/DS-EXAMPLE/ENT-EXAMPLE.md` |

---

## §5 技术视角（technical · TSD → MW）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TSD | TSD-EXAMPLE |  | 中间件域 | `technical/TSD-EXAMPLE.md` |

---

> 公司级 **TPL-*** / **SLN-*** / **PL-*** 不在本索引登记。本层 **PD / SYS / MDG** 首次定义；产品自 **PD** 起；应用自 **SYS** 起。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BSD-EXAMPLE | `business/BSD-EXAMPLE/` |
| PD-EXAMPLE | `product/PD-EXAMPLE/` |
| PM-EXAMPLE | `product/PD-EXAMPLE/PM-EXAMPLE/` |
| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |
| APP-EXAMPLE | `application/APP-EXAMPLE/` |
| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |
| DS-EXAMPLE | `data/DS-EXAMPLE/` |
| TSD-EXAMPLE | `technical/TSD-EXAMPLE.md` |

---

## 交叉引用

- 目录索引：`index.md`
- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
