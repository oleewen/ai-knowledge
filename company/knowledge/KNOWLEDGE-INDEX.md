# KNOWLEDGE-INDEX

> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `BU-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BU / BD / CAP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BU | BU-EXAMPLE |  | 示例业务单元 | `business/BU-EXAMPLE/BU-EXAMPLE.md` |
| BD | BD-EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE.md` |
| CAP | CAP-EXAMPLE |  | 示例业务能力 | `business/BU-EXAMPLE/CAP-EXAMPLE.md` |

---

## §2 产品视角（product · PL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | PL-EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE.md` |

---

## §3 应用视角（application · SLN）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SLN | SLN-EXAMPLE |  | 示例解决方案 | `application/SLN-EXAMPLE.md` |

---

## §4 技术视角（technical · TPL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TPL | TPL-EXAMPLE |  | 示例技术平台能力 | `technical/TPL-EXAMPLE.md` |

---

> 本索引登记公司级 **BU / BD / CAP / PL / SLN / TPL**；SLN ∈ application（AA）；无 PD/SYS/MDG（见系统库）。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BU-EXAMPLE | `business/BU-EXAMPLE/` |
| BD-EXAMPLE | `business/BD-EXAMPLE.md` |
| CAP-EXAMPLE | `business/BU-EXAMPLE/CAP-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE.md` |
| SLN-EXAMPLE | `application/SLN-EXAMPLE.md` |
| TPL-EXAMPLE | `technical/TPL-EXAMPLE.md` |

---

## 交叉引用

- 目录索引：`index.md`
- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
