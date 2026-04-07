# 知识库顶层结构重构 — 详细评估与设计草案

**日期**：2026-04-07  
**状态**：设计评估（**未实施**）  
**范围**：`applications/` 删除、`system`↔`application` 语义调整、新增 `system/`（架构与联邦槽位）、新增 `company/`、`docs-init.sh` 参数模型扩展

**已决议**：

1. **§2.1（核心子集落盘范围）**：当选择**仅同步「核心子集」**（相对 `application/` 全量而言）时，**源根为 `application/`**，且仅包含  
`changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml`（迁名后以实际文件为准）。**不**从新建顶层 `system/` 拷贝上述目录。**该维度与下文 `mode` 无关**，建议用独立参数表达，见 §2.2 与 §6（避免与 **central** 的字母 **c** 混淆）。  
2. **§2.2**：**`mode=s|c` 即 `--mode=standalone|central`**：**`s` = standalone**，**`c` = central**（联邦登记 + 镜像等），语义与**当前** `docs-init` 一致；**不**再引入 `--init-mode`。

---

## 0. 与当前仓库的差异（基线）

当前（本仓库已实现）大致为：

| 顶层 | 角色（摘要） |
|------|----------------|
| `system/` | **中央「系统知识库」**：`knowledge/`（四视角 + 宪法层）、`solutions/`、`analysis/`、`requirements/`、`changelogs/`、`specs/`、`DESIGN.md`、`SYSTEM_INDEX.md`、`system_meta.yaml` 等 |
| `applications/` | **联邦应用模板**（如 `app-APPNAME/`），与 `system/` 对齐，由 `docs-init` central 模式登记/镜像 |
| `.agent/` | 规则与 Slash 技能 |
| `scripts/docs-init.sh` + `docs-config.sh` | `--mode=standalone|central`、`--scope=...`；从 **`system/`** 拷贝到目标文档目录；路径段 `system`→`application` 等映射见 `docs-config.sh` |

**要点**：`DESIGN.md` 中「系统知识库根目录」与 `system_meta.yaml`、`system/knowledge` 实体 **ID** 约束、以及全库数千处 `system/` 字面路径，均建立在上述结构上。

---

## 1. 需求复述（你的 5 点）

1. **删除 `applications/`**  
2. **将现有 `system/` 整体视为「应用知识库」并重命名为 `application/`**（承载原四视角 + 阶段交付等）  
3. **新建顶层 `system/`（新语义）**：其下含  
   - `application-{app-name}/`（占位/后续从其他应用知识库 fetch）  
   - `architecture/`（业务/产品/系统/数据架构文档）  
4. **新建顶层 `company/`**：其下含 `system-{system-name}/`（占位/后续从他系统知识库 fetch）  
5. **`docs-init.sh`**  
   - **5.1 同步体量**：**全量** vs **核心子集**（路径列表见 §2.1）。**不得**再用单独字母 `c` 表示「核心子集」，以免与 **`mode=c` = central** 冲突；建议参数名如 **`--sync=full|core`**（或 `--payload=full|core`）。  
   - **5.2 `mode=s|c`**：**即** **`--mode=standalone|central`**（**s**=standalone，**c**=central），与现有联邦/初始化语义对齐。  
   - **5.3 `type`**：`a|application` 同步 application；`s|system` 同步 system；`c|company` 同步 company（注意：`type` 里的 `c` 表示 company，与 `mode=c` 的 central 不同语境）。

---

## 2. 关键歧义（实施前必须拍板）

### 2.1 「核心子集」的源目录 — **已拍板**

你最初列出的路径在**当前仓库**里写在 `system/` 下；迁移后 **SSOT 主体**在 **`application/`**。

| 理解 | 状态 |
|------|------|
| **A. 核心子集从新顶层 `system/` 拷贝** | **已否决** |
| **B. 核心子集从 `application/` 取上述子树** | **已采纳**（维护者选项 **1**） |

**实施注意**：帮助文与 CI 须写 **`REPO_ROOT/application/changelogs`** 等。**四视角与阶段文档的 SSOT** 在 **`application/`**；新建 **`system/`** 仅承载架构与联邦槽位，**不**与 `application/knowledge` 争 SSOT。

### 2.2 `mode=s|c` 与 `--mode=standalone|central` — **已拍板**

**决议**：**`mode=s|c` 即 `--mode=standalone|central`**，一一对应：

| 简写 | 完整值 | 含义（与当前 `docs-init` 一致） |
|------|--------|--------------------------------|
| **`s`** | **standalone** | 仅目标工程落盘等，不跑 central 登记/镜像（细节以实现为准） |
| **`c`** | **central** | 含联邦登记、建应用镜像等 central 行为 |

**与 §2.1 的区分**：**`mode` 不负责「全量 vs 核心子集」**；后者用 **§1 的 5.1** 单独参数（如 **`--sync=full|core`**）。否则 **`c`** 同时表示 central 与 core（核心子集）会无法读。

**文档要求**：README 中应用表格同时列出 **`--mode=standalone|central`** 与 **`mode=s|c` 简写对照**，避免运维误读。

### 2.3 删除 `applications/` 与 central 模式

`docs-config.sh` 仍引用 `applications/app-APPNAME`，`docs-init` central 流程会建联邦镜像。删除 `applications/` 后需定义：

- central 是否**废弃**，或改为在 **`system/application-{name}/` 或 `company/system-{name}/`** 下建镜像；  
- `APP_ID`、登记行写入哪个索引文件（原 `system/SYSTEM_INDEX.md` 将随目录迁移而改名/换路径）。

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

- 原「系统知识库 = SSOT + 四视角」将迁移到 **`application/`** 名下；新 **`system/`** 承载「多应用槽位 + 架构文档」。需在 `DESIGN.md` 等价物中重新定义 **词汇表**，避免「系统」「应用」在中文叙述中与旧文档对不上。

### 3.5 低 — 占位目录

- `application-{app-name}/`、`system-{system-name}/` 可先放 `README.md` + 空 manifest 占位，与后续 `docs-fetch` 对接。

---

## 4. 方案对比（2～3 种）

| 方案 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| **A. 一次性切换** | 按你的 1～5 点直接改目录、改脚本、改全库链接 | 目标态清晰 | PR 极大、难以分步验证；回滚成本高 |
| **B. 分阶段（推荐）** | ① 新增 `application/`（拷贝或移动自 `system/`）与占位型新 `system/`、`company/`；② 工具链支持 `type` 与双根；③ 冻结后删 `applications/`、废弃旧入口；④ 全量 `/docs-indexing` 与校验 | 每步可测、可回滚；便于并行改 Skill | 过渡期需维护「别名/重定向说明」 |
| **C. 仅加前缀命名空间** | 保留顶层 `system/` 名称不变，用 `system/legacy/` + `system/v2/` 等减少改名 | 对外链接部分兼容 | 结构别扭，长期技术债；与你目标不一致 |

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
├── company/
│   └── system-{system-name}/    # 公司视角下的系统镜像槽位
├── scripts/
└── README.md | AGENTS.md | INDEX_GUIDE.md
```

**索引文件命名**：原 `SYSTEM_INDEX.md`、`system_meta.yaml` 若随目录迁入 `application/`，是否改名为 `APPLICATION_INDEX.md`、`application_meta.yaml` 需单独决议（与现有 `docs-config` 中 `SYSTEM_INDEX`→`APPLICATION_INDEX` 的**安装时**替换规则区分清楚：那是目标工程内的路径替换，不是仓库内源文件名）。

---

## 6. `docs-init` 参数建议（与 §2.2 一致）

| 参数 | 含义 |
|------|------|
| **`--mode=standalone\|central`** | 与现网一致；**简写**：**`s`** → standalone，**`c`** → central（**即用户所述 `mode=s|c` = 本行**） |
| **`--sync=full\|core`**（建议名） | **full**：`type=application` 时同步 `application/` 全量；**core**：仅 §2.1 所列子集（源根 `application/`）。**勿**用单独字母 `c` 表示 core，以免与 **`mode=c`（central）** 混淆。 |
| **`--type=…`** | `application` / `system` / `company`（与需求 5.3 的 type 对齐） |

**校验规则（示例）**：

- **`sync=core` 且 `type=application`**：源根 **`application/`**，路径集合见 §2.1。  
- **`type=company`**：默认同步 `company/` 下哪些子树（是否含所有 `system-*`）需定义。

---

## 7. 测试与验收（建议）

- `docs-init --dry-run` 覆盖：`type` × `sync=full|core` × `mode=standalone|central`（及 `s|c` 简写）合法组合。  
- 安装后：`validate-guide.sh`、关键 `validate-*.sh`、`rg` 检查断链。  
- 可选：快照对比目标目录文件清单（golden list）。

---

## 8. 自审

- **范围**：本文仅为评估与设计草案，**不**包含具体 `git mv` 列表与 PR 任务拆分。  
- **待确认**：§2.3（central 去向）。§2.1、§2.2 已按最新口径确认。  
- **一致性**：若采纳「`application` = 原 system 主体」，则对外叙述「应用知识库」与旧文档「系统知识库」需统一迁移说明。

---

## 9. 后续步骤

1. ~~§2.1、§2.2~~（已完成）。待确认 §2.3。  
2. 评审通过后，使用 **writing-plans** 拆分为可执行子任务（目录迁移、脚本、Skill、全库链接、版本与 README）。  
3. **禁止**在未批准前批量修改 `system/knowledge` 实体 ID 或删除 `applications/` 内仍被引用的模板路径。
