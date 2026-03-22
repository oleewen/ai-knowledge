---
name: knowledge-build
description: >
  四阶段建立结构化知识库，**机器可读约定以 YAML 为准**，本文件为执行流程与门禁。用于 /knowledge-build、知识库初始化与逆向工程。
  **先读** `{Doc Root}/knowledge/knowledge_meta.yaml` → `knowledge`；**以当前落盘的** 根 `README.md`、`AGENTS.md`、**主 Index Guide** 为入口基线，再按知识库任务 **按需加载** `meta_read_order`、各视角 `*_meta.yaml`、证据路径与代码；阶段一/二（document-indexing、agent-guide）**仅**在缺失或用户显式要求时执行。阶段三维护 `knowledge/KNOWLEDGE_INDEX.md` 与物化；阶段四验收。
---

# 知识库构建（knowledge-build）

## 0. 设计原则（Skill 模式）

| 原则 | 说明 |
|------|------|
| **契约外置** | 路径、SSOT、阶段顺序、对称规则、取证来源等 **预定义在** `{Doc Root}/knowledge/knowledge_meta.yaml` 的 **`knowledge`** 键下；执行时 **先读 YAML，再读本 Skill**。 |
| **现状优先（入口三件套）** | 在契约解析出 **Doc Root** 后，以 **当前仓库已落盘** 的 **根 `README.md`**、**`AGENTS.md`**、**主 Index Guide**（落盘路径见 **§3.1**，与 **agent-guide** §3 优先级一致）为 **导航基线**；**禁止**在未读这三者（存在则读）的情况下臆测 Doc Root、索引结构或与知识库无关的全仓细节。 |
| **按需加载** | `meta_read_order.paths`、各视角 `*_meta.yaml`、YAML **`evidence`** 所列工程/文档路径、实现代码：**仅在本轮任务需要时打开**（如仅物化 product 则优先读 `product_meta.yaml` 与 `knowledge/KNOWLEDGE_INDEX.md` 相关段）；**禁止**为「完整性」通读 `docs/**` 或全模块源码。 |
| **单一流程** | 固定四阶段（见 YAML `phases` 与下表 **§4**）；阶段一、二 **可跳过**（见 **§4**），阶段三、四语义不变。 |
| **上游 Skill 引用** | **document-indexing**、**agent-guide** 由 `knowledge.skill.upstream_skills` 声明：作为 **阶段一、二的规范实现**，**不得**被本 Skill 改写语义；**不在**本轮默认自动执行，见 **§4**。 |
| **链上 ID 与 knowledge-extract** | **阶段三物化（§7.2）** 依赖 **`knowledge/KNOWLEDGE_INDEX.md`** 中的链上实体 ID。若需从工程与主 Index **抽取并归并** ID，**宜先**执行 **knowledge-extract**（技术→数据→业务→产品），**再**进入本 Skill **阶段三**；INDEX 已由人工或其它流程维护完整时可跳过。技术视角 **`MS-*`** 与 **knowledge-extract §8.1.2** 对齐：**仅**入口宿主类聚类，**任意** Maven 模块 **不**映射为 MS。 |
| **零重复 SSOT** | 四视角链上实体 ID **只**维护在 `knowledge/KNOWLEDGE_INDEX.md`；联邦 `DIR-*` 在主 **`INDEX_GUIDE.md`**（见 YAML `ssot.federal_index_pointer`，相对 `doc_root`）。 |
| **可审计** | 变更写入 `changelogs/CHANGELOG.md`（路径由 YAML `phases[].changelog` 约定）。 |

---

## 1. 加载契约（**强制，先于 §2～§10**）

1. 若 Doc Root 未知：先按 YAML **`knowledge.doc_root`** 规则解析（可借助 **已有** 根 `README.md` / 主 INDEX 落盘路径 **推断**，见 **§3.1**）。  
2. 读取 **`{Doc Root}/knowledge/knowledge_meta.yaml`**，定位根键 **`knowledge`**（`schema_version: "1.0"`）。  
3. 将 YAML 中 **`ssot`**、**`symmetry`**、**`evidence`**、**`phases`**、**`meta_read_order`** 作为本轮执行的 **硬约束**；若 Skill 正文与 YAML 冲突，**以 YAML 为准**。  
4. **`meta_read_order.paths`**：**不要**在步骤 1 一次性全开；留待 **§7** 按本轮要写的视角与物化范围 **按需** 打开（存在则读）。

> 若仓库 **未**包含 `knowledge` 块：在 **`knowledge_meta.yaml`** 中按联邦模板补全（可参考本仓库 `docs/knowledge/knowledge_meta.yaml`），再执行；**禁止**在无契约时批量编造目录结构。

### 1.1 入口三件套（与契约衔接后**必读**，存在则读）

在 **§1 步骤 2** 完成后、进入 **§4** 判定前，对 **当前落盘** 文件做 **最小通读**（用于对齐 Doc Root、查阅顺序、知识库指针；**不**替代阶段三的精细取证）：

| 顺序 | 文件 | 作用 |
|------|------|------|
| 1 | 仓库根 **`README.md`** | Doc Root 声明、文档导航、与 Index 的交叉链接 |
| 2 | 仓库根 **`AGENTS.md`** | Agent 契约、文档分流、约束与锁表；技术栈与构建见 **README**；主 INDEX 见 **§3.1** |
| 3 | **主 Index Guide**（**§3.1** 解析到的单一路径，如 `docs/INDEX_GUIDE.md`） | 七段结构、§2（项目结构）/§3（对外接口）/§7（配置）等取证锚点、未索引声明 |

若某项缺失：**不**用粘贴全文代替落盘（除非用户显式声明临时替代）；缺失时的补救见 **§4**（按需执行阶段一/二或中止）。

---

## 2. 何时使用 / 与 knowledge-upgrade 区分

| 场景 | 使用本 Skill |
|------|----------------|
| 从零或大范围 **逆向** 理解系统并落 knowledge / requirements | ✅ |
| 根目录尚缺可用的 **Index Guide** 或 **AGENTS/README** 需一并补齐 | ✅ |
| **仅**某应用目录内增量更新应用知识库、且不跑 AGENTS/README 二阶段 | ❌ → **knowledge-upgrade** |

---

## 3. 核心概念（精简）

- **Doc Root**：文档根，以 **当前** 根 `README.md` 声明为准；推断规则见 YAML `doc_root`；与 **§1.1**、**§3.1** 一致。  
- **主 Index Guide（主 INDEX）**：七段主索引；落盘路径 **不以**「必须在 `{Doc Root}/INDEX_GUIDE.md`」为唯一形式，见 **§3.1**。由 **document-indexing** 产出或人工维护；**knowledge-build 默认使用磁盘上当前版本**。  
- **四视角 INDEX SSOT**：`{Doc Root}/knowledge/KNOWLEDGE_INDEX.md`；**前缀与排除项**见 YAML **`ssot.four_perspective_index`**（含 **`application_only_policy`**）。  
- **硬性原则**：目录与 ID 服从 `{Doc Root}/DESIGN.md`、`CONTRIBUTING.md`（或等价）；禁止用 **未读** 路径断言实现细节。

### 3.1 主 Index Guide 落盘路径（命中即停）

与 **agent-guide** §3.1 **完全一致**（用于 **§1.1**「主 Index Guide」与全文「主 INDEX」）：

1. 项目根 **`PROJECT_INDEX.md`**（仓库短入口，可选）、**`INDEX.md`**（兼容别名）、**`INDEX-GUIDE.md`**（标题常含「AI文档库精要索引指南」）  
2. **`docs/INDEX_GUIDE.md`**、**`docs/INDEX-GUIDE.md`**

**记录**实际相对路径到本轮说明；后续 **evidence**、README/AGENTS 交叉引用 **须与此路径一致**。

---

## 4. 四阶段一览

| 阶段 | 执行依据 | 主要产出 |
|------|----------|----------|
| **一** | `knowledge.phases[0]` → **document-indexing** Skill（**按需**，见下） | 主 Index Guide（落盘路径见 YAML） |
| **二** | `knowledge.phases[1]` → **agent-guide** Skill（**按需**，见下） | 根 `README.md`、`AGENTS.md` |
| **三** | `meta_read_order`（**按需打开**）+ 各视角 `{perspective}_meta.yaml` + **`knowledge/KNOWLEDGE_INDEX.md`** | 更新四视角 INDEX；按 `layers`/`directory_patterns` **物化**锚点；更新 knowledge/requirements；**CHANGELOG** |
| **四** | YAML `phases[3]` + 本节 **§8** | 验收、未索引项用户选择 |

### 4.1 默认入口：基于当前 README、AGENTS、主 INDEX

1. 完成 **§1** 与 **§1.1**（契约 + 入口三件套）。  
2. **若** 主 INDEX（**§3.1**）、根 `README.md`、根 `AGENTS.md` **均存在且足以支撑** YAML `evidence` 与本轮阶段三目标：**默认从阶段三开始**，**不**自动执行阶段一、二，**不**强制向用户征求「是否重做索引 / 是否重做 AGENTS」。  
3. **若** 缺少主 INDEX 或明显过时且用户要求刷新导航地图 → 执行 **阶段一**（document-indexing），再 **§1.1** 重读主 INDEX。  
4. **若** 缺少 `README`/`AGENTS` 或用户要求对齐 Agent 契约 → 执行 **阶段二**（agent-guide）；agent-guide **仅消费当前落盘 Index**，不在本 Skill 内嵌套触发 document-indexing。  
5. **若** 缺主 INDEX 且用户拒绝跑阶段一：**不**进入阶段三编造结构；可仅更新契约允许的纯元数据（若 YAML 允许），否则中止。  

**用户显式要求**「仅重做阶段一 / 仅重做阶段二 / 一、二重做」时，按用户指令执行对应 Skill 后再接 **§1.1** 与阶段三。

---

## 5. 阶段一：document-indexing（按需）

**仅**在 **§4.1** 判定需要时执行。完整遵循 **document-indexing** Skill（路径见 YAML `skill.upstream_skills`）。

- **read_mode**：逆向一般 **≥ 2**；超大仓可先 **1** 再加深。  
- **附加**：主 Index **§2** 与 **文档/知识路径**（以 Index 实际章节为准，与 **§3 API 入口**分工；常见为 §6 或独立小节）须覆盖或标注 `{Doc Root}/knowledge/`、`requirements/`、`specs/`、`openspec*`；未覆盖标 **`[未索引]`**。  
- 执行结束后：将新主 INDEX 视为 **当前** 主 INDEX，回到 **§1.1** 第 3 步再进入阶段三。

---

## 6. 阶段二：agent-guide（按需）

**仅**在 **§4.1** 判定需要时执行。完整遵循 **agent-guide** Skill；根 `README.md` 须写明 Doc Root 与索引表，并与 `AGENTS.md` 交叉引用主 Index / `knowledge/KNOWLEDGE_INDEX.md`（路径以 **§3.1** 实际解析为准）。

- 执行结束后：回到 **§1.1** 第 1～2 步更新心智，再进入阶段三。

---

## 7. 阶段三：写入 knowledge（核心算法）

**输入前提：** `knowledge/KNOWLEDGE_INDEX.md` 应已列出本轮要物化的链上 ID（及证据）。若尚未建立或缺口大，**先** **knowledge-extract** 再执行本节。

以下步骤与 **`knowledge_meta.yaml` → `knowledge`** 中 **`ssot`**、**`symmetry`**、**`cross_perspective`**、**`meta_shapes`** 一致；细节不重复粘贴，按 YAML 键执行。

### 7.0 按需加载（在 7.1～7.3 之前执行）

**已读基线**（本轮开始阶段三前应已具备）：**§1** 契约、**§1.1** 三件套、**§3.1** 主 INDEX 路径。

| 需求 | 加载 |
|------|------|
| 登记/核对四视角 ID | **`knowledge/KNOWLEDGE_INDEX.md`**（全文或相关 §）、YAML **`ssot`** / **`symmetry`** |
| 物化某一视角目录 | 该视角 **`{perspective}_meta.yaml`**（如 `business_meta.yaml`）、**`meta_shapes`** 匹配规则 |
| 取证链 | YAML **`evidence`**：主 INDEX 的 **§2（项目结构）、§3（对外接口）、§7（配置）、§8（索引边界）** 等 **按需打开对应小节**，`pom.xml` / **`AGENTS.md`** 等 **仅**在填 ID 或核对事实时读 |
| 联邦与变更 | **`application_meta.yaml`**、`changelogs_meta.yaml` 等：按 **`meta_read_order.paths`** **仅打开本轮会改动的项** |
| 实现细节 | **仅**在三件套或主 INDEX 已指向的路径内 **定点**阅读（类名、Mapper、表名）；**禁止**漫无目的扫 `src/**` |

### 7.1 维护 `knowledge/KNOWLEDGE_INDEX.md`（§8.0.1 语义）

1. **仅**登记 YAML `ssot.four_perspective_index.contains_prefixes` 所列前缀的链上 ID；**排除** `ssot.four_perspective_index.excludes.items`。  
2. **若** `application_only_policy.forbid_foreign_template_rows: true`：**禁止**在 `knowledge/KNOWLEDGE_INDEX.md` 与各视角 README 以非本应用模板 ID 作为唯一内容；缺口用 `allowed_gap_marker`。  
3. **证据**：按 YAML **`evidence`**（主 Index §2～§3、§7～§8，`pom.xml`、**当前** `AGENTS.md` 等）**按需**打开并逐行填写证据路径；**不**要求未参与本轮 ID 的章节全部精读。  
4. **对称**：遵守 YAML **`symmetry.rules`**（同轮四段、BC/AGG 联动、主 Index 优先于臆测）。  
5. **跨视角**：使用 `business_meta.integration.cross_perspective` 等；锚点未填字段时从 `evidence` 补证。

### 7.2 meta × Index 物化（§8.0.2 语义）

1. 按 **`meta_shapes`** 判定各文件形态，读取 `schema_version: "1.1"` 的 `repository` + `layers`。  
2. 仅从 **`knowledge/KNOWLEDGE_INDEX.md`** / 用户输入 / **§7.0 按需加载且已读的** 文档或代码 提取 ID；**禁止** invent。  
3. 将 ID 代入 `directory_patterns`、`child_directory_glob`，创建目录与 `layers.artifacts` 规定的文件。  
4. 部分链缺失时只生成已覆盖层，并在视角 `README.md` 标注 `[需补链：…]`。  
5. **无匹配 ID** 时记 `[需补 ID：…]`，不批量 `PLACEHOLDER`，除非用户显式要求示例脚手架。

### 7.3 落盘四步

1. **INDEX + 物化 + 实体正文**（不改已有 ID、不断裂引用）。  
2. **导航**：更新 `{Doc Root}/INDEX_GUIDE.md`（或 §3.1 解析到的主 Index Guide 路径）、子 README；联邦实体 **一行** 指 `knowledge/KNOWLEDGE_INDEX.md`。  
3. **CHANGELOG**：按 `changelogs_meta.yaml` 与人类可读 `CHANGELOG.md`。  
4. **自检**：链接可点、无冲突子树 `*_meta.yaml`、`knowledge/KNOWLEDGE_INDEX.md` 已覆盖本轮视角。

---

## 8. 阶段四：验收

### 8.1 未纳入 Index 的项（门禁）

仍存在 `[未索引]` 或高相关未落盘项时：**禁止**默认全补或默认忽略。须展示清单，提供 **多选纳入** / **「都不索引」** 及混合规则；处理与 **CHANGELOG** / 主 Index 声明一致（语义同原验收 **§9.1**）。

### 8.2 验收清单（勾选）

- [ ] 结构与各 `*_meta.yaml` 一致；**`knowledge/KNOWLEDGE_INDEX.md`** 已维护  
- [ ] **application_only_policy** 满足（若启用）  
- [ ] **8.1**（未纳入 Index 项）已执行（若适用）  
- [ ] 论述有据；changelog 有本轮摘要  

**反模式**：双 Doc Root、无主 INDEX（且未跑 §4.1 补救）盲写、**跳过 §1.1 三件套** 直接全仓摸索、一次性通读 `meta_read_order` 全部文件而无论本轮是否用到、只加文件不更索引、子目录重复 SSOT `*_meta.yaml`、阶段四默认替用户选择、**在已有可用三件套时仍默认征求重做阶段一/二**。

---

## 9. 参考

| 类型 | 路径 |
|------|------|
| **契约（本仓库示例）** | `docs/knowledge/knowledge_meta.yaml` → **`knowledge`** |
| 联邦根 | `{Doc Root}/application_meta.yaml`（含 `knowledge_meta.yaml` 指针） |
| 上游 Skill | `.cursor/skills/document-indexing/SKILL.md`、`.cursor/skills/agent-guide/SKILL.md` |
| 增量场景 | `.cursor/skills/knowledge-upgrade/SKILL.md` |
| 知识提取：四份 `*_entity.json` → 归并 `knowledge/KNOWLEDGE_INDEX.md`（本 Skill **不**执行） | `.cursor/skills/knowledge-extract/SKILL.md` |
| 命名 | `{Doc Root}/knowledge/constitution/standards/NAMING-CONVENTIONS.md` |

---

## 10. 执行节奏（可选）

阶段间若缺模板，请用户指定或采用仓库默认；重大变更后可简短确认再进入下一阶段。默认节奏：**契约 → 三件套 → 判定是否跑一/二 → 阶段三按需打开 meta 与证据 → 阶段四**；避免「为跑流程而读完全库」。
