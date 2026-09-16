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
| — | — | — | — | — |

---

## §2 产品视角（product · PD → PM → FT → FR → UC/BR · BP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| — | — | — | — | — |

---

## §3 应用视角（application · SYS → APP → MS → API）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| API | API-EXAMPLE-001 |  | 示例 API：创建 | `application/MS-EXAMPLE/API-EXAMPLE-001.md` |

---

## §4 数据视角（data · MDG → DS → ENT → TBL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TBL | TBL-EXAMPLE |  | 示例数据表 | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |

---

## §5 技术视角（technical · TSD → MW → CMP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MW | MW-EXAMPLE |  | 示例中间件绑定 | `technical/MW-EXAMPLE/MW-EXAMPLE.md` |
| CMP | CMP-EXAMPLE |  | 示例组件 | `technical/MW-EXAMPLE/CMP-EXAMPLE.md` |

---

> 本索引仅登记本层首次定义样例（API/TBL/MW/CMP）。上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。产品 **PL/SLN** 见公司；**PD/PM** 见系统层。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| API-EXAMPLE-001 | `application/MS-EXAMPLE/API-EXAMPLE-001.md` |
| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |
| MW-EXAMPLE | `technical/MW-EXAMPLE/` |

---

## 交叉引用

- 目录索引：`index.md`
- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
