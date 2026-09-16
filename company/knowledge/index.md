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

## §1 业务视角（business · BU / BD / CAP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BU | EXAMPLE |  | 示例业务单元 | `business/BU-EXAMPLE/BU-EXAMPLE.md` |
| BD | EXAMPLE |  | 示例业务域 | `business/BD-EXAMPLE.md` |
| CAP | EXAMPLE |  | 示例业务能力 | `business/BU-EXAMPLE/CAP-EXAMPLE.md` |

---

## §2 产品视角（product · PL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE |  | 示例产品线 | `product/PL-EXAMPLE.md` |

---

## §3 应用视角（application · SLN）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SLN | EXAMPLE |  | 示例解决方案 | `application/SLN-EXAMPLE.md` |

---

## §4 数据视角（data · MDG）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| — | — | — | — | — |

---

## §5 技术视角（technical · TPL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TPL | EXAMPLE |  | 示例技术平台能力 | `technical/TPL-EXAMPLE.md` |

---

> 本索引登记公司级 **BU / BD / CAP / PL / SLN / MDG / TPL**；SLN ∈ application（AA）；无 PD/SYS（见系统库）。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BU-EXAMPLE | `business/BU-EXAMPLE/` |
| BD-EXAMPLE | `business/BD-EXAMPLE.md` |
| CAP-EXAMPLE | `business/BU-EXAMPLE/CAP-EXAMPLE.md` |
| PL-EXAMPLE | `product/PL-EXAMPLE.md` |
| SLN-EXAMPLE | `application/SLN-EXAMPLE.md` |
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
