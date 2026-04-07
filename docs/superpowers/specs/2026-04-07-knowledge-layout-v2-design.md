# 知识库顶层结构重构 — 详细评估与设计草案

**日期**：2026-04-07  
**状态**：**方案 B 分阶段实施中** — 阶段① 目录骨架（`application/` SSOT、`system/` / `company/` 占位）、阶段② 脚本与探测（`docs-init` 源根、`sdx-doc-root`）、阶段③ `applications/app-*` 模板移除与联邦入口迁移说明 **已落地**；阶段④ 全量索引刷新与 **`docs-init` 的 `type` × `mode` 完整矩阵**（见 §6）**待补**。  
**范围**：`applications/` 删除、`system`↔`application` 语义调整、新增 `system/`（架构与联邦槽位）、新增 `company/`、`docs-init.sh` 参数模型扩展

**已决议**：

1. **无须**单独参数 `**--sync=full|core`**。
2. **未指定 `type` 时，默认 `type=application`**；**例外**：`**--mode=central` 且未指定 `type`** 时，默认 `**type=system**`（见 §2.3）。
3. **需求 5.1**（针对 `**type=application**` 的 `application/` **全量** vs **核心子集**）**仅由** `**--mode=standalone|central**`（`**mode=s|c**`）表达：
  - `**s` / standalone**：将 `**application/**` **全部**同步至目标工程文档目录（**全量**）。  
  - `**c` / central 且 `type=application`（显式）**：仅 `**application/**` 下 **§2.1 核心子集** + **central 既有行为**（**子集**）。
4. `**type=system**`：目标工程**文档目录**即 **系统知识库根**；其下 `**application-{name}/**` 供后续 **fetch** 同步应用镜像。
5. `**type=company**`：目标工程**文档目录**即 **公司知识库根**；其下 `**system-{name}/**` 供 fetch 同步系统镜像，`**architecture/**` 承载公司级架构文档（与系统知识库侧 `architecture/` 对照）。
6. **§2.1** 仅在 `**mode=central` 且 `type=application**` 时适用；**不**用新建顶层 `system/` 作为该子集之源。

---

## 0. 与当前仓库的差异（基线）

当前（本仓库 **迁移后** 基线）大致为：


| 顶层                                        | 角色（摘要）                                                                                                                                                   |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `application/`                            | **应用知识库 SSOT**（原中央 `system/` 整树）：`knowledge/`、`solutions/`、`analysis/`、`requirements/`、`changelogs/`、`specs/`、`DESIGN.md`、`SYSTEM_INDEX.md` 等 |
| `system/`                                 | **新语义**：组织级系统知识库壳 — `architecture/`、`application-{name}/` 联邦槽位（占位 README）                                                                                |
| `company/`                                | **公司知识库壳** — `architecture/`、`system-{name}/` 槽位                                                                                                   |
| `applications/`                           | **不再含 `app-*` 模板**；仅存迁移说明与 `APPLICATIONS_INDEX.md` 入口                                                                                         |
| `.agent/`                                 | 规则与 Slash 技能                                                                                                                                             |
| `scripts/docs-init.sh` + `docs-config.sh` | `--mode=standalone|central`；安装源根已指向 `application/`；**`--type` 全矩阵仍按 §6 待实现**                                                                               |


**要点**：`application/DESIGN.md` 等仍使用「系统知识库」等历史术语处，需随对外叙述逐步与「应用知识库 SSOT」对齐；实体 **ID** 仍以 `application/knowledge` 下 YAML 为准，**禁止**未经同步批量改 ID。

**目标态注意**：`**mode=central` 且 `type=application`** 时，对中央库 `**application/**` 的落盘范围按 **§2.1**（与旧版「整库拷贝」可能不一致），须在 `SDX_VERSION` 与 README **显式说明**。`**mode=central` 且未传 `type`**（故为 `**type=system**`）时的行为见 **§2.3**。

---

## 1. 需求复述（你的 5 点）

1. **删除 `applications/`**
2. **将现有 `system/` 整体视为「应用知识库」并重命名为 `application/`**（承载原四视角 + 阶段交付等）
3. **新建顶层 `system/`（新语义）**：其下含
  - `application-{app-name}/`（占位/后续从其他应用知识库 fetch）  
  - `architecture/`（业务/产品/系统/数据架构文档）
4. **新建顶层 `company/`**：其下含 `system-{system-name}/`（占位/fetch）、`**architecture/**`（公司级架构文档，与 `system/architecture/` 对照）
5. `**docs-init.sh**`
  - **5.1**：**即** `**--mode=standalone|central`**（`**mode=s|c**`）。**在 `type=application` 时**，**全量 vs 核心子集**见文首「已决议」与 §2.1；**不**增加 `--sync`。  
  - **5.2 `type`**：`application` / `system` / `company`。**未传时默认 `type=application`**；**例外**：`**--mode=central` 且省略 `type`** 时默认 `**type=system**`。目标目录与 fetch 槽位见 §2.3、§6。

---

## 2. 关键歧义（实施前必须拍板）

### 2.1 「核心子集」路径枚举 — **已拍板**（**仅 `type=application` + `mode=central`**）

在 `**mode=central`（`c`）** 且 `**type=application`**（须**显式**传入：因 `**mode=central` 且未传 `type`** 时默认为 `**type=system**`，见 §2.3、§6）时，**仅**将下列相对 `**application/`** 的内容同步到目标（迁名后以实际文件为准）：

`changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml`

**源根**：均为 `**application/`**，**不**使用新建顶层 `system/` 作为上述子集的源。

### 2.2 `mode=s|c` 与 `--mode=standalone|central` — **已拍板**

**决议**：`**mode=s|c` 即 `--mode=standalone|central`**：


| 简写      | 完整值            | 对 `type=application` 时的含义（与需求 5.1 对齐）                                                                              |
| ------- | -------------- | ------------------------------------------------------------------------------------------------------------------ |
| `**s**` | **standalone** | 在 `**type=application`** 时：`**application/` 全量**同步至目标文档目录                                                          |
| `**c`** | **central**    | **未传 `type` 时默认 `type=system`**（§2.3，覆盖全局默认 `application`）。若显式 `**type=application**`：**§2.1 核心子集** + central 既有行为 |


**文档要求**：README 用表格列出 `**--mode=standalone|central`** 与 `**s|c` 简写**；并分表说明 `**type=application` + central** 与 **默认 `type=system` + central** 的差异。

### 2.3 central 模式、`type` 默认值与目标目录语义 — **已拍板**

- **central 模式继续沿用**（`--mode=central` / `c`），不废弃。  
- **全局**：未指定 `type` 时，**默认 `type=application`**（§6）。  
- **例外**：`**--mode=central` 且未指定 `type`** 时，**默认 `type=system`**（仅此组合覆盖上述全局默认）。


| `type`                                                 | 中央库源目录（目标态）                                                           | **目标工程文档目录**语义                 | 子目录与后续 fetch                                                                                    |
| ------------------------------------------------------ | --------------------------------------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------- |
| `**system`**（`**mode=central` 且未传 `type` 时的默认**，或显式指定） | 仓库顶层 `**system/`**（新语义：含 `architecture/`、`application-{app-name}/` 等） | **即「系统知识库根目录」**（该路径即用户传入的文档目录） | 其下 `**application-{name}/`** 内内容后续可通过 **fetch** 等方式同步为各应用知识库镜像                                  |
| `**company`**                                          | 仓库顶层 `**company/**`（含 `**architecture/**` 与 `**system-{name}/**`）     | **即「公司知识库根目录」**                | `**system-{name}/`**：fetch 同步各系统镜像；`**architecture/**`：公司级架构文档（与 `**system/architecture/**` 对照） |
| `**application**`                                      | `**application/**`                                                    | 由现有约定/参数解析（通常为应用知识库落点）         | **§2.1** 在 `**mode=central` + `type=application`** 时定义核心子集                                      |


**删除 `applications/`**：联邦/镜像落点改为 `**system/application-{name}/**`（在**目标**系统知识库根下）或依赖 **fetch** 填入，不再依赖已删除的 `applications/app-APPNAME` 模板目录；`**APP_ID`、登记行**写入文件需随 `**application/` 内索引**（如迁入后的 `APPLICATION_INDEX.md` 或专用 manifest）**另行定稿**（实现阶段补全）。

### 2.4 删除 `applications/`（模板移除）

中央库内 `**applications/`** 目录按需求删除；与 §2.3 中 **目标侧** `application-{name}/`、`system-{name}/` **槽位**区分：后者为**目标工程文档树**上的目录名模式，**不是**旧模板路径 `applications/app-APPNAME/`。

---

## 3. 影响面评估（按严重度）

### 3.1 高 — 契约与导航

- `AGENTS.md`、`README.md`、`INDEX_GUIDE.md`、`system/SYSTEM_INDEX.md` 等：**凡写 `system/` 的路径与「系统知识库」措辞**都要系统性重写；否则 Agent 与人类入口全部失真。  
- **禁止破坏**（见当前 `AGENTS.md`）：`system/knowledge/` 实体 **ID** 与跨视角引用；若仅**目录改名**（`system`→`application`）而文件内容不变，ID 可保留，但 **所有文档内路径、YAML 指针、meta 中的相对路径** 必须批量校验。

### 3.2 高 — 工具链

- `scripts/docs-init.sh`：源从 `system/` 改为按 `type` 多根；`map_path_system_to_application`、`SDX_*_TEMPLATE_PATH`、排除列表、`install_system_to_docs` 等需重构。  
- `scripts/docs-config.sh`：`SDX_SYSTEM_TEMPLATE_PATH`、文件名替换规则与「系统→应用」文案替换是否与**新**语义冲突（例如新 `system` 是否还要替换为 `application`）。  
- `.agent/skills/` 中 `docs-indexing`、`docs-build`、`docs-fetch`、`sdx-*`：**扫描根、`sdx-doc-root` 探测、`INDEX_GUIDE` 模板** 多数假设 `system/knowledge` 等路径，需逐项对齐或增加配置项。

### 3.3 中 — 外部消费者

- 已使用 `docs-bootstrap` / `docs-init` 的仓库：路径与参数行为可能 **破坏性变更**；需要 **版本号 + 迁移说明**（`SDX_VERSION` 与 README 醒目标注）。

### 3.4 中 — 概念模型

- 原「系统知识库 = SSOT + 四视角」将迁移到 `**application/`** 名下；新 `**system/**` 承载「多应用槽位 + 架构文档」。需在 `DESIGN.md` 等价物中重新定义 **词汇表**，避免「系统」「应用」在中文叙述中与旧文档对不上。

### 3.5 低 — 占位目录

- `application-{app-name}/`、`system-{system-name}/` 可先放 `README.md` + 空 manifest 占位，与后续 `docs-fetch` 对接。

---

## 4. 方案对比（2～3 种）


| 方案              | 做法                                                                                                                                        | 优点                   | 缺点                 |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | ------------------ |
| **A. 一次性切换**    | 按你的 1～5 点直接改目录、改脚本、改全库链接                                                                                                                  | 目标态清晰                | PR 极大、难以分步验证；回滚成本高 |
| **B. 分阶段（推荐）**  | ① 新增 `application/`（拷贝或移动自 `system/`）与占位型新 `system/`、`company/`；② 工具链支持 `type` 与双根；③ 冻结后删 `applications/`、废弃旧入口；④ 全量 `/docs-indexing` 与校验 | 每步可测、可回滚；便于并行改 Skill | 过渡期需维护「别名/重定向说明」   |
| **C. 仅加前缀命名空间** | 保留顶层 `system/` 名称不变，用 `system/legacy/` + `system/v2/` 等减少改名                                                                               | 对外链接部分兼容             | 结构别扭，长期技术债；与你目标不一致 |


**推荐**：**B**，并在第一阶段只落地**目录骨架 + 参数设计**，实体 ID 与知识文件**移动不改内容**（除路径引用）。

---

## 5. 建议的目标态目录（逻辑草图）

```text
仓库根/
├── .agent/
├── application/                 # 原「中央 system 知识库」整体迁此
│   ├── knowledge/
│   ├── solutions/ | analysis/ | requirements/
│   ├── changelogs/ | specs/
│   ├── README.md | INDEX_GUIDE.md | DESIGN.md | …
│   └── …
├── system/                      # 新语义：组织级/多应用视图（与 application/ 的 SSOT 分工见 §2.1）
│   ├── application-{app-name}/  # 联邦槽位（fetch 目标）
│   └── architecture/            # 业务/产品/系统/数据 架构文档（子结构需另表）
├── company/                     # 公司知识库（与顶层 system/ 对照）
│   ├── system-{system-name}/    # 公司视角下的系统镜像槽位（fetch）
│   └── architecture/            # 公司级架构文档（业务/产品/系统/数据等；与 system/architecture 对照，子结构需另表）
├── scripts/
└── README.md | AGENTS.md | INDEX_GUIDE.md
```

**索引文件命名**：原 `SYSTEM_INDEX.md`、`system_meta.yaml` 若随目录迁入 `application/`，是否改名为 `APPLICATION_INDEX.md`、`application_meta.yaml` 需单独决议（与现有 `docs-config` 中 `SYSTEM_INDEX`→`APPLICATION_INDEX` 的**安装时**替换规则区分清楚：那是目标工程内的路径替换，不是仓库内源文件名）。

---

## 6. `docs-init` 参数建议


| 参数                                      | 含义                                                                                              |
| --------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `**--mode=standalone|central`**         | **简写 `s|c`**。与 `**type**` 组合见下表。                                                                |
| `**--type=application|system|company**` | **未传时默认 `type=application`**；**例外**：`**mode=central` 且未传 `type`** 时，默认 `**type=system**`（§2.3）。 |


**组合语义（摘要）**：


| mode       | type（默认行为）                             | 中央库源                             | 目标工程文档目录语义                                                      |
| ---------- | -------------------------------------- | -------------------------------- | --------------------------------------------------------------- |
| standalone | **application**（**未传 type 时即此**，见上表默认） | `application/` 全量                | 应用知识库落点（与现网 standalone 对齐）                                      |
| central    | **application**（须显式）                   | `application/` §2.1 子集           | 应用知识库落点 + central 行为                                            |
| central    | **system**（**未传 `type` 时由 §2.3 例外默认**） | 顶层 `system/`                     | **系统知识库根**；其下 `application-{name}/` 供后续 fetch 填镜像               |
| central    | **company**                            | 顶层 `company/`（含 `architecture/`） | **公司知识库根**；`system-{name}/` 为 fetch 槽位，`architecture/` 为公司级架构文档 |


**校验规则（示例）**：

- `**mode=central` + 默认 `type=system`**：源 `**system/**`，目标目录 = **系统知识库根**。  
- `**mode=central` + `type=application`**：源 `**application/**`，落盘 **§2.1**。  
- `**type=company`**：源 `**company/**`（含 `**architecture/**` 与 `**system-{name}/**`），目标目录 = **公司知识库根**。

---

## 7. 测试与验收（建议）

- `docs-init --dry-run` 覆盖：`type` × `mode=standalone|central`（含 `**s|c` 简写**）；**重点**：`central` **无 type**（应默认 **system**）、`central`+`application`、`central`+`company`、`standalone`+`application`。  
- 安装后：`validate-guide.sh`、关键 `validate-*.sh`、`rg` 检查断链。  
- 可选：快照对比目标目录文件清单（golden list）。

---

## 8. 自审

- **范围**：本文仅为评估与设计草案，**不**包含具体 `git mv` 列表与 PR 任务拆分。  
- **待确认**：无（§2.3、§2.4 已按最新口径写入）；实现阶段补全 **登记文件路径** 等细节。  
- **一致性**：若采纳「`application` = 原 system 主体」，则对外叙述「应用知识库」与旧文档「系统知识库」需统一迁移说明。

---

## 9. 后续步骤

1. ~~§2.1～§2.4~~（已写入）。
2. ~~目录迁移（`git mv system`→`application`）、新 `system/` / `company/` 骨架、`applications/app-*` 移除~~（方案 B ①～③ 已做）。
3. 补全 **`docs-init`**：`--type`、central 无 type → system、central+application → §2.1 子集、`type=system|company` 源根与目标语义；同步 **`.agent` Skills**（`docs-fetch` / `docs-archive` 等）与 `system/application-{name}/` 叙事一致。
4. 择机全量 **`/docs-indexing`** 刷新 `INDEX_GUIDE.md` 元信息与 §3 字典；持续 `rg` 断链与 Skill 文案清理。
5. **禁止**未经同步批量修改 `application/knowledge` 实体 **ID**。

