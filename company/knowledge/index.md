# knowledge

目录说明：[README.md](README.md)。

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

1. [README.md](README.md) — 五视角与实体 SSOT  
2. [overview/README.md](overview/README.md) — overview 缓冲  
3. 各视角 `README.md` — 业务→产品→应用→数据→技术  
4. `chapters/` 与 `*-EXAMPLE` — 章节骨架与样例  

## 关联索引

* 上一级索引：index.md（库外）
* 上一级说明：README.md（库外）

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
| CAP | EXAMPLE |  | 示例业务能力 | `business/BD-EXAMPLE/CAP-EXAMPLE.md` |

---

## §2 产品视角（product · PL → PD）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE/PL-EXAMPLE.md` |
| PD | EXAMPLE |  | 示例产品 | `product/PL-EXAMPLE/PD-EXAMPLE.md` |

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

> 本索引登记公司级 **BD / CAP / PL / PD / SYS / MDG / TPL**；系统层与应用层实体见对应 bundle 的 `knowledge/index.md`。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BD-EXAMPLE | `business/BD-EXAMPLE/` |
| CAP-EXAMPLE | `business/BD-EXAMPLE/CAP-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE/` |
| PD-EXAMPLE | `product/PL-EXAMPLE/PD-EXAMPLE.md` |
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
