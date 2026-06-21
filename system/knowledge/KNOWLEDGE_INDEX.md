---
type: Knowledge Index
title: 知识库 · 五视角实体 ID 索引（SSOT）
---
# 知识库 · 五视角实体 ID 索引（SSOT）

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BD → BSD → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BD | EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE/BD-EXAMPLE.md` |
| BSD | EXAMPLE |  | 示例业务子域 | `business/BD-EXAMPLE/BSD-EXAMPLE.md` |
| BC | EXAMPLE |  | 示例限界上下文 | `business/BD-EXAMPLE/BC-EXAMPLE.md` |
| AGG | EXAMPLE |  | 示例聚合 | `business/BD-EXAMPLE/AGG-EXAMPLE.md` |
| AB | EXAMPLE |  | 示例业务能力 | `business/BD-EXAMPLE/AB-EXAMPLE.md` |

---

## §2 产品视角（product · PL → PM → FT → UC）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE |  | 示例产品线 | `product/PM-EXAMPLE/PL-EXAMPLE.md` |
| PM | EXAMPLE |  | 示例产品模块 | `product/PM-EXAMPLE/PM-EXAMPLE.md` |
| FT | EXAMPLE |  | 示例功能 | `product/PM-EXAMPLE/FT-EXAMPLE.md` |
| UC | EXAMPLE-001 |  | 示例用例 | `product/PM-EXAMPLE/UC-EXAMPLE-001.md` |

---

## §3 应用视角（application · SYS → APP → MS → API）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | EXAMPLE |  | 示例系统边界 | `application/SYS-EXAMPLE.md` |
| APP | EXAMPLE |  | 示例应用 | `application/APP-EXAMPLE.md` |
| MS | EXAMPLE |  | 示例微服务 | `application/MS-EXAMPLE.md` |

---

## §4 数据视角（data · DS → ENT）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| DS | EXAMPLE |  | 示例数据源 | `data/DS-EXAMPLE.md` |
| ENT | EXAMPLE |  | 示例实体 | `data/ENT-EXAMPLE.md` |

---

## §5 技术视角（technical · MW → CMP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| — | — | — | — | — |

---

> 公司级 **TPL-***、系统级 **TSD-*** 不在本索引登记；见 `company/ea/technical/`、`system/knowledge/technical/`。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BD-EXAMPLE | `business/BD-EXAMPLE/` |
| PL-EXAMPLE | `product/PL-EXAMPLE/` |
| SYS-EXAMPLE | `application/SYS-EXAMPLE/` |
| DS-EXAMPLE | `data/DS-EXAMPLE/` |

---

## 交叉引用

- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
