---
name: document-indexing
description: >-
  为代码库或文档库生成全局索引指南（Index Guide）：拓扑扫描、结构分析、精读提取；
  路径自根相对、MECE 分类；**本仓库**正文为 **九章 + 附录** 金字塔（见 §8）。
  执行前须先显式确认 data_mode（全量/增量），再确认 read_mode（1/2/3）；无默认；两步都选定后一行复述即执行，不要求第三次确认。
  在用户发起 /document-indexing、需要 RAG 导航地图、或建立 Agent 可读项目索引时使用。
---

# 文档索引（Index Guide）

## 1. 角色与使命

扮演 **AI 文档库架构师**。解析仓库，产出 **单一权威**、**检索导向**、**信息密度高** 的 **Index Guide**（**默认**落盘为 `INDEX_GUIDE.md`；可通过 `output_path` 覆盖），供 RAG、上下文理解与代码导航使用。

**Slash**：`/document-indexing` 指本 Skill（非 `scripts/` 下可执行文件）。**Step 3** 依赖 **document-change** Skill（[document-change/SKILL.md](../document-change/SKILL.md)），同样由 Agent 按步骤执行。

## 2. 何时使用

| 场景 | 使用本 Skill |
|------|----------------|
| 需要 **单一权威索引** 供多 Agent 共享 | ✅ |
| 新项目 onboarding、Monorepo 导航、文档站地图 | ✅ |
| 与 **knowledge-build** 区分 | 本 Skill 产出 **平面/分层索引与地图**；**四视角链上实体 ID**（BD/PL/SYS/DS，**不含** DIR 联邦/宪法/阶段）由 knowledge-build 写入 **`docs/knowledge/KNOWLEDGE_INDEX.md`** |

## 3. 输入 / 输出契约

| 符号 | 含义 |
|------|------|
| `data_mode` | `full`（全量）或 `incremental`（增量）；**禁止默认**，须 Step 2 显式选定 |
| `read_mode` | `1` 拓扑 / `2` 结构 / `3` 精读；与下文章「读取模式」对应 |
| `output_path` | 可选；索引正文路径，未指定则按 §4.1 |
| `since_time` | 增量时等于上次 `indexing_finished_at`；无历史则「不适用」 |

**输出**：

- **`INDEX_GUIDE.md`**（索引正文默认路径；若维护索引运行日志，路径可记在 **§2 文档结构** 树或附录；未指定 `output_path` 时见 §4.1）
- `<索引日志目录>/indexing-log.jsonl`（运行元信息，逐行追加 JSONL）

## 4. 目录判定

### 4.1 索引正文路径（默认 `INDEX_GUIDE.md`）

1. 用户指定 `output_path` → 从之  
2. 否则：存在 `./docs/` → `./docs/INDEX_GUIDE.md`；否则 `./doc/` → `./doc/INDEX_GUIDE.md`；否则 `./INDEX_GUIDE.md`

### 4.2 索引日志目录

- 存在 `./changelogs/` → 用之；否则搜索 `**/changelogs/`（多个取路径最短）；不存在则创建 `./changelogs/`  
- 日志文件：`<索引日志目录>/indexing-log.jsonl`

## 5. 硬性约束（速查）

1. **零幻觉**：只索引实际读过的文件；未读标 `[未索引]`。  
2. **路径精确**：自项目根相对路径（如 `./policy-appeal-service/pom.xml`）。  
3. **MECE**：分类互斥穷尽；同一文件不重复列入多模块（除非标「跨模块共享」）。  
4. **信息密度**：每条功能精要 **15–30 字**；禁空话。  
5. **幂等性**：同输入多次执行，层级语义一致。  
6. **可追溯增量**：每次记录索引结束时间（epoch ms）；下次若存在该时间，须 Step 2 在 **全量 / 增量** 间**显式**选择（无默认）；增量仅对 `since_time` 之后变更定向索引（见 Step 4）。  
7. **门禁**：未依次确定 `data_mode` 与 `read_mode` 前，**禁止** Step 3～6（含 document-change、按 read_mode 读文件、写索引正文（默认 `INDEX_GUIDE.md`）、追加日志、清理 changes-index）。**禁止**因「首次」「无日志」静默默认全量；首次也须先选 `data_mode`、再选 `read_mode`。用户仅说「开始索引」→ **停止并展示 Step 2.1**。  

**时间**：对用户与日志人类可读字段统一 `yyyy-MM-dd HH:mm:ss.SSS`；可选 `*_ms` 字段核对。

## 6. 执行流程（顺序固定）

> **原则**：**先**定 `data_mode`，**再**定 `read_mode`，然后跑变更基线与索引。在二者未都确定前，**仅允许** Step 1（读日志末条）。

### Step 1 — 读索引日志末条（若存在）

读 `indexing-log.jsonl` 最后一行，取得上次 `indexing_finished_at`、`index_output_path`（无则视为无历史）。

### Step 2 — 强制选择（不得默认；先 `data_mode`，后 `read_mode`）

在 `data_mode` 与 `read_mode` 未都确定前 **不得进入 Step 3**。

1. **展示上下文**：上次 `indexing_finished_at`、`since_time`（增量基准）或「无 / 不适用」。  

#### Step 2.1 第一步：确认 `data_mode`

**仅本步**：请用户必选 **全量** 或 **增量**（无默认）。

| 选项 | data_mode | 说明 |
|------|-----------|------|
| **1**（快捷） | `full` | 与「全量」等价；始终可选 |
| **2**（快捷） | `incremental` | 与「增量」等价；**仅当** Step 1 有有效 `indexing_finished_at` |
| **全量**（文字） | `full` | 同快捷 **1**；按后续选定的 `read_mode` **全量**扫描（忽略上次时间） |
| **增量**（文字） | `incremental` | 同快捷 **2**；**仅当** Step 1 有有效 `indexing_finished_at`；无基准时说明「只能全量」并**仅**保留 **1** / 全量 |

用户可只回复 **`1`** 或 **`2`**，或用「全量 / 增量」、**`full` / `incremental`** 等明确文字。  
> **与 Step 2.2 区分**：本步的 **`1`/`2`** 只表示 **data_mode**；下一步 **`1`/`2`/`3`** 才表示 **read_mode**，分两轮询问，不会混用。  
**禁止**在本步询问或推断 `read_mode`；**禁止**用单键同时绑定两种模式。

#### Step 2.2 第二步：确认 `read_mode`（仅 Step 2.1 已得到 `data_mode` 后）

**仅本步**：请用户必选 **read_mode 1 / 2 / 3**（与 §7 一致；无默认，可提示 **3** 为常见默认**推荐**，但仍须用户明确表态）。

| read_mode | 说明 |
|-----------|------|
| **1** | 拓扑扫描（轻） |
| **2** | 结构分析（中等） |
| **3** | 精读提取（重；知识逆向常选） |

用户回复 **`1` / `2` / `3`** 即选定对应 `read_mode`；也可用「拓扑 / 结构 / 精读」等同义表述。

3. **选定即生效**：Step 2.1 与 2.2 **均**完成后，Agent **一行复述** `将执行：data_mode=…，read_mode=…，since_time=…`，**立即** Step 3；**不要**在复述之外再索要单独「确认」「ok」。  
4. **记录**供 Step 4～5 与 JSONL 使用。

### Step 3 — document-change（强制；仅 Step 2 完成后）

按 [document-change](../document-change/SKILL.md) 生成 `changes-index.json` / `changes-index.md`。全量仍建议生成以便对照变更面；增量强依赖变更列表。

### Step 4 — 按 read_mode 索引

| data_mode | 行为 |
|-----------|------|
| `full` | 按本次 `read_mode` **全量**扫描/精读（忽略上次时间） |
| `incremental` | `since_time = 上次 indexing_finished_at`；**仅**对 changes-index 中变更路径定向探索；在 Index Guide **§8 索引边界**（或文首元信息）**明示本次增量覆盖边界** |

**读取模式**见 §7。

### Step 5 — 落盘

1. 向 `indexing-log.jsonl` **追加 1 行**（字段见 [reference.md](reference.md) 第 1 节）。  
2. 在索引正文（默认 `INDEX_GUIDE.md`）按仓库惯例更新 **索引运行日志** 的指向（如 **§2.4 文档结构** 中 `indexing-log.jsonl` 路径，或附录一行说明）。

### Step 6 — 清理 changes-index

仅保留滚动基线，规则见 [reference.md](reference.md) 第 3 节。

## 7. 读取模式（read_mode）

仍遵守：只对**已读**文件下结论；**未读**或**浅索引**范围写入 Index Guide **§8.2**（未索引或浅索引），与 **§8.1** 对仗。

| read_mode | 范围要点 | 输出深度 |
|-----------|----------|----------|
| **1** 拓扑 | 根配置、`docs/`/`doc/` 第一层文件名等 | 定位 + 技术栈 + **§1 快速导航 / 元信息** + **§2 项目结构**（模块、依赖、包树）；无函数级 |
| **2** 结构 | read_mode 1 基础上 + 源码前 50 行、入口、HTTP/Dubbo/MQ/Job 声明 + **domain**、DO/Mapper/XML + **配置文件**、构建/启动 | 模块功能 + **§3 接口** + **§4 领域** + **§5 逻辑** + **§6 数据** + **§7 配置** 骨架；**须覆盖对外入口与数据落点** |
| **3** 精读 | 约定目录与关键类尽量通读 | 函数级、业务规则、状态机/枚举、异常与配置语义；**§1～§9 正文**按深度填满；**附录**索引变更日志按需追加 |

## 8. Index Guide 正文结构（本仓库落地：`docs/INDEX_GUIDE.md`）

以下为 **policy-appeal** 当前索引正文的 **九章金字塔 + 附录**；其它仓库可删减子节，但宜保持 **MECE** 与「速查 → 结构 → 接口 → 领域 → 逻辑 → 数据 → 配置 → 边界 → 分流」的阅读顺序。

若某节不足：`[信息不足，需补充读取：<路径>]`。

| 章 | § 约定 | 要点（提炼） |
|----|--------|----------------|
| **一、快速导航** | §1.1 速查表；§1.2 元信息 | 入口表（链到 README、§3～§9 锚点）；项目名称、定位、技术栈、启动类、Doc Root |
| **二、项目结构** | §2.1 模块；§2.2 依赖图；§2.3 包结构（含子模块包树）；§2.4 文档结构 | Maven 模块树、mermaid 依赖、各子模块 `java` 包分层、`docs/` 树（可含 `indexing-log.jsonl` 指针） |
| **三、接口清单** | §3.1 HTTP（路径级）；§3.2 Dubbo；§3.3 定时任务；§3.4 MQ | 对外机器可读清单（与实现类绑定）；HTTP 常按路径前缀分子节 |
| **四、领域模型** | §4.1 业务术语；§4.4 领域对象（充血模型清单） | 术语表；**不含**状态机/枚举（在第五章） |
| **五、逻辑模型** | §5.1 状态机；§5.2 应用组件（Manager/Service/Repo）；§5.3 业务流程；§5.4 枚举 | 状态图、流程图；应用层组件与 **§6.3**（Mapper 索引 / XML 路径表）交叉引用 |
| **六、数据模型** | §6.1 数据源；§6.2 实体表（按业务链分子表）；§6.3 Mapper 索引 | 库/分片/Doris；表 ↔ 实体；**XML 路径表**（条内 SQL 可不展开，见 **§8.2**；正文标题以仓库为准，如「Mapper索引」） |
| **七、配置索引** | §7.1 配置中心 Key；§7.2 分布式锁等枚举；§7.3 其它 | Titans、锁前缀、本地 `application`/`mybatis` 等指针 |
| **八、索引边界** | §8.1 已索引范围；§8.2 未索引/浅索引；§8.3 维护规则 | 与 **§1.1** 速查对账；声明 Mapper 条内 SQL、DTO 字段级等浅索引 |
| **九、相关文档** | §9.1 核心文档；§9.2 文档分工（MECE）；§9.3 查阅建议 | README / AGENTS / KNOWLEDGE_INDEX 分流；与 knowledge-build 边界 |
| **附录** | 索引变更日志 | 按日期记录章节重排、交叉引用同步 |

**与 knowledge-build 分工**：四视角链上实体 ID（`PL-*`/`SYS-*`/`DS-*`…）**不**替代上表；登记见 **`docs/knowledge/KNOWLEDGE_INDEX.md`**，证据链可指回本章 **§3 / §6 / §2** 等。

可选文首元行见 [reference.md](reference.md) 第 2 节。

## 9. 相关 Skill

- **document-change**：变更基线与 `changes-index.*`（Step 3 前置）。  
- **knowledge-build**：结构化知识库、`docs/knowledge/**`；**`docs/knowledge/KNOWLEDGE_INDEX.md`** 仅登记 **四视角**链上 ID（见 knowledge-build §8.0.1），联邦 **DIR-*** / 宪法 / 阶段见主 **`INDEX_GUIDE.md`**（或由 `output_path` 指定的主 Index Guide）或 `*_meta.yaml`。与本文档索引 **分工**，不互相替代。

## 10. 延伸阅读

- [reference.md](reference.md) — JSONL 字段；Index Guide 文首元行（本仓库 / 泛用模板）；基线清理；document-change 路径。
