---
type: Knowledge Index
title: 知识库 · 五视角实体 ID 索引（SSOT）
---
# 知识库 · 五视角实体 ID 索引（SSOT）

> 本文件仅保留示例，用于演示五视角索引结构与字段形状。

---

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BD → BSD → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BD | EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE.md` |
| BSD | EXAMPLE |  | 示例业务子域 | `business/BSD-EXAMPLE/BSD-EXAMPLE.md` |
| BC | EXAMPLE |  | 示例限界上下文 | `business/BSD-EXAMPLE/BC-EXAMPLE.md` |
| AGG | EXAMPLE |  | 示例聚合 | `business/BSD-EXAMPLE/AGG-EXAMPLE.md` |
| AB | EXAMPLE |  | 示例能力 | `business/BSD-EXAMPLE/AB-EXAMPLE.md` |

---

## §2 产品视角（product · PL → PM → FT → UC）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE.md` |
| PM | EXAMPLE |  | 示例产品模块 | `product/PM-EXAMPLE/PM-EXAMPLE.md` |
| FT | EXAMPLE |  | 示例功能 | `product/PM-EXAMPLE/FT-EXAMPLE.md` |
| UC | EXAMPLE-001 |  | 示例用例 | `product/PM-EXAMPLE/UC-EXAMPLE-001.md` |

---

## §3 应用视角（application · SYS → APP → MS → API）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | EXAMPLE |  | 示例系统 | `application/SYS-EXAMPLE.md` |
| APP | EXAMPLE |  | 示例应用 | `application/APP-EXAMPLE.md` |
| MS | EXAMPLE |  | 示例微服务 | `application/MS-EXAMPLE/MS-EXAMPLE.md` |
| API | EXAMPLE-001 | ExampleService.create | 示例 API：创建 | `application/MS-EXAMPLE/API-EXAMPLE-001.md` |

---

## §4 数据视角（data · DS → ENT）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| DS | EXAMPLE |  | 示例数据源 | `data/DS-EXAMPLE.md` |
| ENT | EXAMPLE |  | 示例实体 | `data/ENT-EXAMPLE/ENT-EXAMPLE.md` |

---

## §5 技术视角（technical · MW → CMP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MW | EXAMPLE |  | 示例中间件绑定 | `technical/MW-EXAMPLE/MW-EXAMPLE.md` |
| CMP | EXAMPLE |  | 示例组件 | `technical/MW-EXAMPLE/CMP-EXAMPLE.md` |

---

> 公司级 **TPL-***、系统级 **TSD-*** 不在本索引登记；见 `company/knowledge/technical/`、`system/knowledge/technical/`。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BD-EXAMPLE | `business/BSD-EXAMPLE/BSD-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE.md` |
| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |
| DS-EXAMPLE | `data/DS-EXAMPLE.md` |

---

## 交叉引用

- 应用：[application/index.md](application/index.md) · [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §3
- 业务：[business/index.md](business/index.md) · §1
- 产品：[product/index.md](product/index.md) · §2
- 数据：[data/index.md](data/index.md) · §4
- 技术：[technical/index.md](technical/index.md) · §5
- 知识库总说明：[README.md](README.md)

