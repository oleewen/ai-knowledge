# README 填充规范

 `{perspective}-entities.md` 就绪后、**写 `KNOWLEDGE_INDEX.md` 前**，按此更新各视角 `README.md`。禁止示例行冒充；无实体则说明+待补充（[quality-checklist.md](quality-checklist.md)、[gotchas.md](../gotchas.md)）。

## 原则

| 原则 | 说明 |
|------|------|
| 格式同源 | 沿用现有 README 表头/章节/静态段；只换索引表数据行 |
| 数据同源 | 行只来自对应 JSON，映射见下 |
| 不删固定段 | 保留层级说明、跨视角、INDEX/DESIGN 链等 |
| 链接可点 | 相对当前 README 指向 JSON、meta、`../KNOWLEDGE_INDEX.md` |

---

## 输出路径

| 视角 | README 路径 | JSON 来源 |
|------|-------------|-----------|
| application | `{DOC_DIR}/knowledge/application/README.md` | `application/application-entities.md` |
| data | `{DOC_DIR}/knowledge/data/README.md` | `data/data-entities.md` |
| business | `{DOC_DIR}/knowledge/business/README.md` | `business/business-entities.md` |
| product | `{DOC_DIR}/knowledge/product/README.md` | `product/product-entities.md` |

---

## 表格列与 JSON 映射

### application —「技术索引表」

表头：`| 类型 | 名称 | ID (KNOWLEDGE_INDEX) | 路径 / 说明 |`

| 列 | 取值 |
|----|------|
| 类型 | 系统 / 应用 / 微服务（MS）/ 接口（与层级一致的中文） |
| 名称 | `name` |
| ID (KNOWLEDGE_INDEX) | SYS/APP：`full_id`；MS：`id`（如 `MS-…`）；API：`id`（如 `API-…`） |
| 路径 / 说明 | `application-entities.md`（`hierarchy=…` / `full_id=…` 或 `id=…`）；可附 `alias` 或证据摘要 |

自 `entities` 分类对象遍历：`systems` → `applications` → `services` → `apis`。

### data —「数据线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 / 文件 |`（首行索引行可保留「数据视角」元信息）

| 列 | 取值 |
|----|------|
| 链序 | DS：`L1`；ENT：按父 DS 分组内序号 `L2` 或全局递增，与现有示例一致即可 |
| 层级 | `DS` / `ENT` |
| 类型 | `数据存储` / `数据实体` |
| 名称 | `name` |
| 锚点目录 / 文件 | `data-entities.md`（`hierarchy=DS|ENT` / `full_id=…`） |

扁平 `entities` 数组按 `hierarchy` 过滤；ENT 的 `parent_id` 可用于排序或链序说明。

### business —「业务索引表」

表头：`| 链序 | 层级 | ID | 名称 | 文件/目录 |`

| 列 | 取值 |
|----|------|
| 链序 | `L1`…`L5` 对应 BD → BSD → BC → AGG → AB |
| 层级 | `BD` / `BSD` / `BC` / `AGG` / `AB` |
| ID | `full_id` 或规范 `id` 字段（与 JSON 一致） |
| 名称 | `name` |
| 文件/目录 | `business-entities.md`（`hierarchy=…`） |

扁平分组排序；有真实 ID 后标题可改「业务索引表」，并注「以 `business-entities.md` 为准」。

### product —「产品线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 |`

| 列 | 取值 |
|----|------|
| 链序 | `L1`…`L4` 对应 PL → PM → FT → UC |
| 层级 | `PL` / `PM` / `FT` / `UC` |
| 类型 | 产品线 / 产品模块 / 功能 / 用例（与 README 示例一致） |
| 名称 | `name` |
| 锚点目录 | `product-entities.md`（`hierarchy=…` / `full_id` 或 `id`） |

---

## 相对 KNOWLEDGE_INDEX 的顺序

1. 四 JSON 就绪  
2. 本规范更 README  
3. [consolidation-spec.md](consolidation-spec.md) 写 `KNOWLEDGE_INDEX.md`  

保证 README、JSON、INDEX 一致。
