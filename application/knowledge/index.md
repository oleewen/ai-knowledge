# knowledge

目录说明见 [README.md](README.md)。

## 子目录

* [application](application/README.md)
* [business](business/README.md)
* [data](data/README.md)
* [product](product/README.md)
* [technical](technical/README.md)

## 目录文件

* [knowledge-meta.md](knowledge-meta.md)
* [technical-debt.md](technical-debt.md)

## 阅读顺序

1. [README.md](README.md)
2. 五视角 README：business → product → application → data → technical
3. 各 `*-meta.md`（字段 SSOT）

## 关联索引

- 上一级索引：index.md（库外）
- 上一级说明：README.md（库外）

---


> 本文件仅保留本层首次定义 EXAMPLE，用于演示五视角索引结构与字段形状。

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称
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
| API | EXAMPLE-001 |  | 示例 API：创建 | `application/MS-EXAMPLE/API-EXAMPLE-001.md` |

---

## §4 数据视角（data · MDG → DS → ENT → TBL）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TBL | EXAMPLE |  | 示例数据表 | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |

---

## §5 技术视角（technical · TSD → MW → CMP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MW | EXAMPLE |  | 示例中间件绑定 | `technical/MW-EXAMPLE/MW-EXAMPLE.md` |
| CMP | EXAMPLE |  | 示例组件 | `technical/MW-EXAMPLE/CMP-EXAMPLE.md` |

---

> 本索引仅登记本层首次定义样例（API/TBL/MW/CMP）。上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。产品 **PL/SLN** 见公司；**PD/PM/MDG** 见系统层。

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| API-EXAMPLE-001 | `application/MS-EXAMPLE/API-EXAMPLE-001.md` |
| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |
| MW-EXAMPLE | `technical/MW-EXAMPLE/` |

---

## 交叉引用

- 应用：`application/`
- 业务：`business/`
- 产品：`product/`
- 数据：`data/`
- 技术：`technical/`
- 知识库总说明：`README.md`
