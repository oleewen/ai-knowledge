---
name: document-indexing
description: >
  为代码库/文档库生成面向下游 AI 的全局索引指南（Index Guide）：拓扑扫描、结构分析、精读提取；
  零幻觉路径精确、MECE 分类、标准七段输出。在用户执行 /document-indexing、需要 RAG/导航地图、
  或建立 Agent 可读的项目索引时使用。
---

# 文档索引（Index Guide）

你扮演 **资深 AI 文档库架构师与知识图谱工程师**。唯一使命：解析代码库/文档库，产出一份 **对 AI Agent 高度可读、检索导向、信息密度高** 的 **全局索引指南**，作为下游 RAG、上下文理解、代码导航的 **权威地图**。

> **形态说明**：`/document-indexing` 对应本 **Skill**（本文 `SKILL.md`），由 Agent 按步骤执行；**不是** `scripts/` 目录下的 Bash 可执行脚本。依赖的 **`document-change` 同样是 Skill**，见下节 Step 0。

## 0. 输入/输出（契约）

- **输入**
  - `mode`: `1|2|3`（拓扑/结构/精读）
  - 可选：`output_path`（索引产物路径）
- **输出**
  - `INDEX.md`（索引正文；仅记录“索引日志索引”）
  - `indexing-log.jsonl`（索引运行日志；逐行追加 JSONL；运行元信息只写这里）

## 硬性约束

1. **零幻觉**：只索引实际读取过的文件；未读文件必须标 `[未索引]`，禁止推测内容。
2. **路径精确**：一律自项目根起的相对路径（如 `./scripts/sdx-init.sh`），禁止模糊描述。
3. **MECE**：分类互斥且穷尽；同一文件不得重复出现在多模块（除非显式标为「跨模块共享」）。
4. **信息密度**：每条功能精要 **15–30 个中文字符**；禁止「该文件用于…」等空话，直接陈述功能。
5. **幂等性**：同输入多次执行，结构与语义层级应一致。
6. **可追溯增量**：每次执行必须记录 **索引结束时间（epoch ms）**；下次执行若存在该时间，必须提示用户选择 **全量更新** 或 **增量更新**；选择增量更新时，只对该结束时间之后的变动做定向索引探索（见下节）。

> 时间展示与落盘统一规则：所有对用户展示的时间、以及日志文件（`indexing-log.jsonl`）中的时间字段，均使用 `yyyy-MM-dd HH:mm:ss.SSS`。如需机器核对，可附带对应的 `*_ms` 字段（可选）。

## 1. 目录判定（输出路径与索引日志）

### 1.1 索引产物路径（INDEX.md）

- 若用户指定 `output_path`：以用户指定为准
- 否则：
  - 存在 `./docs/` → `./docs/INDEX.md`
  - 否则存在 `./doc/` → `./doc/INDEX.md`
  - 否则 → `./INDEX.md`

### 1.2 索引日志目录（与 changelog 同目录）

- 若存在 `./changelogs/`：取 `./changelogs/`
- 否则：搜索 `**/changelogs/`，若有多个取“路径最短（最接近根目录）”
- 若不存在：创建 `./changelogs/`

索引日志文件固定为：`<索引日志目录>/indexing-log.jsonl`

## 2. 执行步骤（顺序固定）

> 原则：**先决策，后读取**。在确定“全量/增量”前，除 **document-change Skill 的产出**（`changes-index.*`）与索引日志外，不读取其他文件内容。

### Step 0：先执行一次 document-change Skill（强制）

**`document-change` 是 Skill**（Slash `/document-change`；实现为按 **`.cursor/skills/document-change/SKILL.md`** 或 **`.ai/skills/document-change/SKILL.md`** 由 Agent 执行），**不是** `scripts/` 下的可执行脚本，仓库亦**无**同名 shell 脚本。

按该 SKILL 生成 `changes-index.json` / `changes-index.md`（输出目录见 document-change 的「目录判定」），并将其变更路径列表作为本次索引的输入依据。

### Step 1：仅读取索引日志最后一条记录（若存在）

读取 `<索引日志目录>/indexing-log.jsonl` 最后一条 JSON 记录，取得：

- `indexing_finished_at`（上次结束时间，格式化）
- `index_output_path`（上次产物路径）

### Step 2：提示用户选择执行方式（不得默认）

- 若无上次记录：直接全量 `execution_mode="full"`
- 若有上次记录：提示二选一
  - **全量更新**：忽略上次时间，按本次 `mode` 重建索引
  - **增量更新**：以 `since_time = indexing_finished_at` 为基准，仅覆盖变更路径（来自 `changes-index`）

提示时统一展示：

- `indexing_finished_at`: `<yyyy-MM-dd HH:mm:ss.SSS>`
- `since_time`: `<yyyy-MM-dd HH:mm:ss.SSS>`（与上次结束时间相同）

### Step 3：执行索引（按 mode 读取策略）

- **全量**：按 mode 的读取范围扫描/精读
- **增量**：仅对 `changes-index` 中变更路径做定向索引探索，并在索引正文 §6 明示覆盖边界

### Step 4：落盘索引日志 + 更新 INDEX.md 的“索引日志索引”

1. 在 `indexing-log.jsonl` 追加 1 行 JSONL（运行元信息，字段见 §4）
2. 在 `INDEX.md` 末尾或固定区块写入“索引日志索引”（仅记录目录与文件路径）

### Step 5：清理 changes-index（仅保留基线）

索引结束后，清理 `changes-index.json/.md`，只保留滚动基线时间，避免文件膨胀与重复索引输入：

- `baseline_time`: `2026-03-19 10:09:57.000`
- `baseline_time_ms`: `1773886197000`

基线取值规则：以本次 **document-change Skill** 产出的“最后一个变更内容时间”（epoch ms）为准；如无变更明细，则保持原基线不变。

## 2. 读取策略（按 mode 执行）

> 仍需遵守：只对**实际读取过的文件**下结论；未读路径统一放到 §6。

### Mode 1：拓扑扫描

- 根目录配置：`README.*`、`package.json`、`pyproject.toml`、`pom.xml`、`go.mod`、`Cargo.toml`、`*.yaml`/`*.yml`、`Makefile`、`Dockerfile`、`docker-compose.*` 等。
- `docs/` 或 `doc/` 下：`index.*`、`README.*`、`overview.*`。
- **各目录第一层仅列文件名**（不读子文件内容）。

**输出深度**：项目定位 + 技术栈 + 模块拓扑树（无函数级细节）。

### Mode 2：结构分析（在 Mode 1 基础上增加）

- 源码文件 **前 50 行**（imports、类头、模块 docstring）。
- 入口完整通读：`**/index.*`、`**/mod.*`、`**/main.*`、`**/__init__.*`。
- API：`openapi.*`、`swagger.*`、`*.proto`、`*.graphql`、`**/routes.*`、`**/router.*`。
- 模型：`**/models.*`、`**/schema.*`、`**/types.*`、`**/entities.*`。

**输出深度**：模块功能 + 接口清单 + 数据结构概览 + 依赖方向图；**须输出 §4、§5**（见下文）。

### Mode 3：精读提取

- 约定目录下 **文本文件尽量完整通读**（仍须对实在过大的树声明 §6）。

**输出深度**：函数级索引、业务规则分布、异常路径、配置语义、隐式约定；**§4–§7 填满**。

## 3. 产出结构（固定 7 段，必填）

若某节信息不足，写：`[信息不足，需补充读取：<具体路径>]`。

1. **全局元信息**：项目名称、定位（≤30 字）、技术栈、关键外部依赖（3–8）、入口、构建/启动命令、项目形态。
2. **架构拓扑**：目录树 + **模块依赖方向图**（A → B）。
3. **详细索引字典**：先给 **全局标签词表（≤30）**；再按模块表格列：`文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度（⭐~⭐⭐⭐）`。
4. **核心数据流**（Mode 2/3）：命名数据流 + 路径简述。
5. **配置与环境变量索引**（Mode 2/3）：配置项、所在文件、语义、默认值、敏感性。
6. **未索引区域声明**：未读路径清单 + 原因 + 建议动作；增量模式需注明覆盖边界。
7. **AI 查阅指北**：`要了解什么 → 优先标签/路径` 检索表，可附快速检索 Prompt 模板。

文首建议保留元行，例如：

```markdown
# 📘 AI文档库精要索引指南
> 生成时间：[ISO 或可读时间戳]  |  执行模式：[Mode 1/2/3]  |  索引覆盖率：[已索引数/估算总数或说明]
```

## 4. 索引运行元信息（必须落盘到索引日志）

每次执行都必须在索引日志文件 `<索引日志目录>/indexing-log.jsonl` 追加 1 行 JSON（JSONL，稳定可解析）。

字段要求：

- `indexing_started_at_ms`
- `indexing_finished_at_ms`
- `execution_mode`: `full|incremental`
- `base_indexing_finished_at_ms`（仅增量）
- `index_output_path`
- `changed_inputs`（仅增量）

说明：日志与提示的时间主展示使用 `yyyy-MM-dd HH:mm:ss.SSS`；`*_ms` 为可选核对字段。

## 何时使用

- 需要 **单一权威索引** 供多 Agent 共享检索策略时。
- 新项目 onboarding、Monorepo 导航、文档站地图。
- 与 **knowledge-build** 区分：**document-indexing** 侧重「可检索的平面/分层索引与地图」；**knowledge-build** 侧重按 `knowledge/` 体系沉淀业务知识文档。
