# knowledge

目录说明见 [README.md](README.md)。

## 子目录

* [application](application/README.md)
* [business](business/README.md)
* [data](data/README.md)
* [overview](overview/README.md)
* [product](product/README.md)
* [technical](technical/README.md)

## 目录文件

* [knowledge-meta.md](knowledge-meta.md)

## 阅读顺序

1. [README.md](README.md) — 先理解五视角职责、实体 SSOT 与 overview 缓冲区
2. [overview/README.md](overview/README.md) — 确认 overview 模板与自动回写入口
3. 各视角 `README.md` — 按业务、产品、应用、数据、技术顺序下钻
4. 视角 `chapters/` 与 `*-EXAMPLE` 实体 — 查看模板章节和最小样例链

## 关联索引

* 上一级索引：[../index.md](../index.md)
* 上一级说明：[../README.md](../README.md)

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BD / CAP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BD | EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE/BD-EXAMPLE.md` |
| CAP | EXAMPLE-L1 |  | 示例一级能力 | `business/BD-EXAMPLE/CAP-EXAMPLE-L1.md` |
| CAP | EXAMPLE |  | 示例二级能力 | `business/BD-EXAMPLE/CAP-EXAMPLE.md` |

---

## §2 产品视角（product · PL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE.md` |

---

## §3 应用视角（application · SYS）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | EXAMPLE |  | 示例系统 | `application/SYS-EXAMPLE.md` |

---

## §4 数据视角（data · MDG）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MDG | EXAMPLE |  | 示例主数据域 | `data/MDG-EXAMPLE.md` |

---

## §5 技术视角（technical · TPL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TPL | EXAMPLE |  | 示例技术平台能力 | `technical/TPL-EXAMPLE.md` |

---

> 本索引登记公司级 **BD / CAP / PL / SYS / MDG / TPL**；系统层与应用层实体见对应 bundle 的 `knowledge/index.md`。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BD-EXAMPLE | `business/BD-EXAMPLE/` |
| CAP-EXAMPLE-L1 | `business/BD-EXAMPLE/CAP-EXAMPLE-L1.md` |
| CAP-EXAMPLE | `business/BD-EXAMPLE/CAP-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE.md` |
| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |
| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |
| TPL-EXAMPLE | `technical/TPL-EXAMPLE.md` |

---

## 交叉引用

- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
