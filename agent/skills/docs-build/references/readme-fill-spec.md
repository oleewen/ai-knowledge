# README 填充规范

各视角 per-entity `{ID}.md` 就绪后、**写 `INDEX-GUIDE.md` 前**，按此更新各视角 `README.md`。禁止示例行冒充；无实体则说明+待补充（[quality-checklist.md](quality-checklist.md)、[gotchas.md](../gotchas.md)）。
这些视角 `README.md` 归属仓库文档分类矩阵中的 **A 类：人类入口文档**：默认保留可见 `# H1`；若因既有 frontmatter `title` 触发 `MD025`，须按全局文档规则判断是否保留必要豁免，不得自行假设可删除 `title`。

## 原则

|原则|说明|
|------|------|
|格式同源|沿用现有 README 表头/章节/静态段；只换索引表数据行|
|数据同源|行只来自对应 per-entity concept，字段取自 frontmatter 与正文|
|不删固定段|保留层级说明、跨视角、INDEX / knowledge-governance 链等|
|链接可点|相对当前 README 指向 per-entity `{ID}.md`、meta、`../INDEX-GUIDE.md`|

---

## 输出路径

|视角|README 路径|数据来源|
|------|-------------|-----------|
|application|`{DOC_DIR}/knowledge/application/README.md`|`application/{ID}.md`（含子目录 MS/API）|
|data|`{DOC_DIR}/knowledge/data/README.md`|`data/**/{ID}.md`|
|business|`{DOC_DIR}/knowledge/business/README.md`|`business/**/{ID}.md`|
|product|`{DOC_DIR}/knowledge/product/README.md`|`product/**/{ID}.md`|
|technical|`{DOC_DIR}/knowledge/technical/README.md`|`technical/**/{ID}.md`|

---

## 表格列与 per-entity 映射

### application —「技术索引表」

表头：`| 类型 | 名称 | ID (INDEX-GUIDE) | 路径 / 说明 |`

|列|取值|
|----|------|
|类型|解决方案 / 系统 / 应用 / 微服务（MS）/ 接口（与 `hierarchy` 一致的中文）|
|名称|frontmatter `title`|
|ID (INDEX-GUIDE)|SLN/SYS/APP：`id`；MS/API：`id`|
|路径 / 说明|相对链接至 concept 文件（示例路径：`SLN-EXAMPLE.md`、`SYS-EXAMPLE.md`、`MS-EXAMPLE/MS-EXAMPLE.md`）|

按 `hierarchy` 分组遍历：`SLN` → `SYS` → `APP` → `MS` → `API`。链序 `L1`…`L5` 对应这条链。各层只登记本层首次定义。

### data —「数据线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 / 文件 |`（首行索引行可保留「数据视角」元信息）

|列|取值|
|----|------|
|链序|`L1`…`L4` 对应 MDG → DS → ENT → TBL|
|层级|`MDG` / `DS` / `ENT` / `TBL`|
|类型|`主数据域` / `数据存储` / `数据实体` / `数据表`|
|名称|frontmatter `title`|
|锚点目录 / 文件|相对链接至 `{ID}.md`（示例：`MDG-EXAMPLE.md`、`DS-EXAMPLE.md`、`ENT-EXAMPLE/ENT-EXAMPLE.md`、`ENT-EXAMPLE/TBL-EXAMPLE.md`）|

ENT 的路径父级取自关系段同层 `parent`，否则同层 `implements_to`，可用于排序或链序说明。

### business —「业务索引表」

表头：`| 链序 | 层级 | ID | 名称 | 文件/目录 |`

|列|取值|
|----|------|
|链序|域模型 `L1`…`L7` 对应 BD → BSD-L1 → BSD-L2 → BSD-L3 → BC → AGG → AB。能力链 `L1` VC、`L2` CAP。BL、BS 为 `—`|
|层级|`VC` / `CAP` / `BD` / `BSD-L1` / `BSD-L2` / `BSD-L3` / `BC` / `AGG` / `AB` / `BL` / `BS`|
|ID|`id`|
|名称|frontmatter `title`|
|文件/目录|相对链接至 concept（示例：`BD-EXAMPLE.md`）|

公司业务台账：`能力目录` 为 L1 VC、L2 CAP；`域模型` 为 L1 BD、L2 BSD-L1。BL 不进链，链序为 `—`。层级用 VC / CAP / BD / BSD-L1 / BL。公司台账不写 `../INDEX-GUIDE.md` 注。

扁平分组排序；有真实 ID 后标题可改「业务索引表」，并注「以 per-entity `{ID}.md` 与 `../INDEX-GUIDE.md`（相对视角 README）为准」。

### product —「产品线索引表」

表头：`| 链序 | 层级 | 类型 | 名称 | 锚点目录 |`

|列|取值|
|----|------|
|链序|`L1`…`L7` 对应 PL → PD → PM → FT → FR → UC → BR。流程链另起 `L1` BP、`L2` BSP|
|层级|`PL` / `PD` / `BP` / `BSP` / `PM` / `FT` / `FR` / `UC` / `BR`|
|类型|产品线 / 产品 / 业务流程 / 业务子流程 / 产品模块 / 功能 / 功能需求 / 用例 / 业务规则|
|名称|frontmatter `title`|
|锚点目录|相对链接至 concept（解决方案 PL / PD；系统 PM 起，示例：`PM-EXAMPLE/`）|

解决方案产品台账：`产品线` 为 L1 PL、L2 PD；`流程` 为 L1 BP、L2 BSP。含 PM 的长链用 `L1`…`L7`（PL→PD→PM→FT→FR→UC→BR）。

### technical —「技术索引表」

表头：`| 链序 | 层级 | ID | 名称 | 文件/目录 |`

|列|取值|
|----|------|
|链序|`L1`…`L4` 对应 TPL → TS → MW → CMP|
|层级|`TPL` / `TS` / `MW` / `CMP`|
|ID|`id`|
|名称|frontmatter `title`|
|文件/目录|相对链接至 concept（示例：`TPL-EXAMPLE.md`、`TS-EXAMPLE.md`、`MW-EXAMPLE/MW-EXAMPLE.md`）|

各层只登记本层首次定义：公司 TPL、解决方案 TS、应用 MW/CMP。上游不建本层文件，只写纯 ID。

---

## 相对 INDEX-GUIDE 第四章 的顺序

1. 各视角 per-entity `{ID}.md` 就绪  
2. 本规范更 README  
3. [consolidation-spec.md](consolidation-spec.md) 写入 `INDEX-GUIDE.md` 第四章视角导航块  

保证 README、per-entity、INDEX 导航一致（实体台账 ∈ README）。
