# 各视角 README 填充规范

在全部目标视角的 `*_knowledge.json`（schema 2.1）已生成后、写入 **`{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md` 之前**，按本规范更新各视角目录下的 `README.md`。**不得**用占位示例行冒充真实提取结果；无实体时保留说明句并标注待补充，与 [quality-checklist.md](quality-checklist.md)、[gotchas.md](../gotchas.md)（「以模板占位行作为索引唯一内容」）一致。

---

## 原则

| 原则 | 说明 |
|------|------|
| 格式同源 | 表头、章节顺序、静态说明段与各视角 **现有** `README.md` 对齐；仅替换「索引表」数据行与必要的引导句 |
| 数据同源 | 表格行仅来自对应 `*_knowledge.json` 已存在实体，字段映射见下节 |
| 不删固定段 | 保留「层级结构」「关键字段」「与其他视角的映射」、Index Guide / DESIGN 链接等；除非该视角 README 模板整体改版 |
| 路径可点击 | Markdown 链接相对 **当前 README 文件** 指向 `*_knowledge.json`、`*_meta.yaml`、`../KNOWLEDGE_INDEX.md` 等 |

---

## 输出路径

| 视角 | README 路径 | JSON 来源 |
|------|-------------|-----------|
| technical | `{DOC_DIR}/knowledge/technical/README.md` | `technical/technical_knowledge.json` |
| data | `{DOC_DIR}/knowledge/data/README.md` | `data/data_knowledge.json` |
| business | `{DOC_DIR}/knowledge/business/README.md` | `business/business_knowledge.json` |
| product | `{DOC_DIR}/knowledge/product/README.md` | `product/product_knowledge.json` |

---

## 表格列与 JSON 映射

### technical —「技术索引表」

表头：`| 类型 | 名称 | ID (KNOWLEDGE_INDEX) | 路径 / 说明 |`

| 列 | 取值 |
|----|------|
| 类型 | 系统 / 应用 / 微服务（MS）/ 接口（与层级一致的中文） |
| 名称 | `name` |
| ID (KNOWLEDGE_INDEX) | SYS/APP：`full_id`；MS：`id`（如 `MS-…`）；API：`id`（如 `API-…`） |
| 路径 / 说明 | `technical_knowledge.json`（`hierarchy=…` / `full_id=…` 或 `id=…`）；可附 `alias` 或证据摘要 |

自 `entities` 分类对象遍历：`systems` → `applications` → `services` → `apis`。

### data —「数据线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 / 文件 |`（首行索引行可保留「数据视角」元信息）

| 列 | 取值 |
|----|------|
| 链序 | DS：`L1`；ENT：按父 DS 分组内序号 `L2` 或全局递增，与现有示例一致即可 |
| 层级 | `DS` / `ENT` |
| 类型 | `数据存储` / `数据实体` |
| 名称 | `name` |
| 锚点目录 / 文件 | `data_knowledge.json`（`hierarchy=DS|ENT` / `full_id=…`） |

扁平 `entities` 数组按 `hierarchy` 过滤；ENT 的 `parent_id` 可用于排序或链序说明。

### business —「业务索引表」

表头：`| 链序 | 层级 | ID | 名称 | 文件/目录 |`

| 列 | 取值 |
|----|------|
| 链序 | `L1`…`L5` 对应 BD → BSD → BC → AGG → AB |
| 层级 | `BD` / `BSD` / `BC` / `AGG` / `AB` |
| ID | `full_id` 或规范 `id` 字段（与 JSON 一致） |
| 名称 | `name` |
| 文件/目录 | `business_knowledge.json`（`hierarchy=…`） |

扁平数组按层级分组排序；**列名「示例」改为真实 ID 后，表标题可改为「业务索引表」**，引导句说明「完整清单以 `business_knowledge.json` 为准」。

### product —「产品线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 |`

| 列 | 取值 |
|----|------|
| 链序 | `L1`…`L4` 对应 PL → PM → FT → UC |
| 层级 | `PL` / `PM` / `FT` / `UC` |
| 类型 | 产品线 / 产品模块 / 功能 / 用例（与 README 示例一致） |
| 名称 | `name` |
| 锚点目录 | `product_knowledge.json`（`hierarchy=…` / `full_id` 或 `id`） |

---

## 与 KNOWLEDGE_INDEX 的顺序

1. 四视角 `*_knowledge.json` 就绪  
2. **本规范**更新各视角 `README.md`  
3. 再执行 [consolidation-spec.md](consolidation-spec.md) 更新 `{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`  

这样人类从视角目录进入时，README 与 JSON、主索引三者一致。
