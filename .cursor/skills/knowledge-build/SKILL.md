---
name: knowledge-build
description: >
  四阶段建立结构化知识库：① document-indexing → Index Guide；② agent-guide → 根 README/AGENTS；
  ③ 以 Index + README/AGENTS + SDD 规约（specs/openspec*）按需阅读，写入 Doc Root 下 knowledge/requirements，
  更新 INDEX/README，追加 changelogs/changelog.md；④ 验收。用于 /knowledge-build、知识库初始化与逆向工程。
---

# 知识库构建（knowledge-build）

在仓库内建立 **可导航、可追溯、与 SDD 目录一致** 的结构化知识：**Index → 人类/Agent 入口 → 知识实体与需求交付 → 验收**。

## 1. 何时使用 / 与 knowledge-upgrade 区分

| 场景 | 使用本 Skill |
|------|----------------|
| 从零或大范围 **逆向** 理解系统并落 knowledge / requirements | ✅ |
| 根目录尚缺可用的 **Index Guide** 或 **AGENTS/README** 需一并补齐 | ✅ |
| **仅**某应用目录内增量更新应用知识库、且不跑 AGENTS/README 二阶段 | ❌ → 用 **knowledge-upgrade** |

## 2. 核心概念

- **文档根（Doc Root）**：知识库体系统辖的根路径，**以根 `README.md` 声明为准**（常见 `docs/`、`system/`、`docs/system/`）。所有 `{Doc Root}/...` 均相对仓库根。
- **Index Guide**：七段《AI文档库精要索引指南》，常见落盘为根 **`INDEX.md`** 或 **`docs/INDEX.md`**（路径以 document-indexing 与用户约定为准）。
- **硬性原则**：输出目录、视角、实体 ID 与 YAML 字段 **服从** `{Doc Root}/DESIGN.md`、`CONTRIBUTING.md`（或项目等价文件）；**禁止**用 Index §6 或未读路径编造实现细节。

## 2.1 Doc Root 可指定（执行时规则）

执行本 Skill 时，**允许用户指定要构建的知识库目录**（Doc Root）：

- 若指定目录不存在：**直接报错**（停止流程，不进入阶段一～四）
- 若用户未指定：查找有 `knowledge` 目录的文件夹进行推算，若同时检测到多个候选 Doc Root：**列出候选列表并要求用户选择**（不得默认）

## 3. 前置门禁：防「双套知识库」

> **未完成本节不得进入阶段一～四**，避免写错根、断链、Agent 误读。

**Doc Root 解析**

1. 读根 `README.md` 中的文档体系说明。  
2. 若未写明：用 Index 落盘位置推断（如 Index 在 `docs/INDEX.md` → Doc Root 倾向 `docs/`），并在会话中 **写明依据**。

## 4. 四阶段一览

| 阶段 | 执行依据 | 主要产出 |
|------|----------|----------|
| **一** | `.cursor/skills/document-indexing/SKILL.md` | Index Guide（建议落盘；与仓库约定一致） |
| **二** | `.cursor/skills/agent-guide/SKILL.md` | 根目录 `AGENTS.md`、`README.md`（须含文档体系与索引） |
| **三** | 阶段一二产出 + 规约树 + Doc Root 内模板 | `{Doc Root}/knowledge/`、`requirements/` 及 YAML；更新 `{Doc Root}/INDEX.md` 与相关 `README.md`；**changelog** |
| **四** | 本节清单 | 结构、链接、可追溯、零幻觉复核 |

## 5. 入口：是否跳过阶段一、二

**快速检测**

- **阶段一完成**：存在可用 Index（落盘或用户粘贴全文）。  
- **阶段二完成**：根目录存在 `AGENTS.md` 与 `README.md`，且 README 描述 Doc Root 与目录体系。

**若一、二均已完成** → **须展示检测结果**并 **请用户选择**（禁止默认）：

| 选择 | 动作 |
|------|------|
| 从阶段三继续 | Index + AGENTS/README 为输入；无落盘 Index 须 **粘贴或指定路径** |
| 仅重做阶段一 | 重做后再问是否重做阶段二 |
| 仅重做阶段二 | Index 过旧时建议先重做阶段一 |
| 一、二重做 | 从阶段一起顺序执行 |

**缺口**：仅有二无一 → 要求补阶段一或提供 Index；仅有一无二 → 建议补阶段二后再三。

## 6. 阶段一：document-indexing

完整遵循 **document-indexing** Skill。

- **Mode**：知识库逆向一般 **≥ Mode 2**；超大仓可先 Mode 1 再加深。  
- **本流程附加**：§2/§3 **必须** 覆盖或标注 **`{Doc Root}/knowledge/`**、相关 **`requirements/`**、**`specs/`** 及项目约定的 **`openspec*`** 路径；未覆盖的标 **`[未索引]`**。  
- **落盘**：强烈建议写入仓库约定路径，供阶段二、三与后续 Agent 复用。

## 7. 阶段二：agent-guide

完整遵循 **agent-guide** Skill（以阶段一 Index 为地图）。

- 根 `README.md` **必须** 写清 Doc Root、目录结构、文档索引表。  
- 可与 `AGENTS.md` 交叉注明 Index 路径，避免与阶段三检索顺序矛盾。

## 8. 阶段三：写入 knowledge / requirements（核心）

### 8.1 输入清单（齐套后再写）

| 输入 | 要求 |
|------|------|
| Index Guide | 七段可用；**无 Index 禁止盲写** |
| 根 `AGENTS.md`、`README.md` | 文档体系、禁止项、规范入口与知识写入 **一致** |
| SDD 规约 | `{Doc Root}/specs/`、根 `specs/`（若 README 约定）、`openspec/`、`openspecs/` 等——**按 Index + 用户范围按需打开** |
| 结构准绳 | `{Doc Root}/knowledge/`、`requirements/` 下 README、模板、`_meta.yaml` / 实体 YAML 示例；`DESIGN.md`、`CONTRIBUTING.md` |

### 8.2 阅读顺序（按需、不通读）

1. **Index §1–§7** 定优先级；§6 仅在 **本条知识依赖** 时定向补读。  
2. **规约树**：扫描后按 **服务/子目录** 精读；与交付强相关 → **`requirements/`** 既有 MVP/Phase 结构。  
3. **源码/配置**：仅当 Index §3 或规约 **显式指向** 且 **必须** 核实时再读。  
4. 产出不得与 **AGENTS 禁止项**、**CONTRIBUTING** 冲突。

**Index → 落点（简表）**

| Index | 落点思路 |
|-------|----------|
| §1 | 总览、技术栈 → 宪法层/总述 |
| §2 | 模块边界、规约树位置 → 视角划分 |
| §3 ⭐ | 领域/API/数据/规约行 → knowledge 子树或 requirements |
| §4–§5 | 数据流、配置 → 技术/数据视角 |
| §6 | 补读后写或标注范围外 |
| §7 | 交叉引用与 AGENTS「查阅顺序」对齐 |

### 8.3 落盘四步（同一轮次内连续完成）

1. **写实体**：更新/新建 `{Doc Root}/knowledge/**/*.md` 与 YAML；`{Doc Root}/requirements/**` 按目录与模板 **提炼** 规约/分析内容。**不改已有实体 ID**、不断裂 ID 引用。  
2. **更导航**：更新 **`{Doc Root}/INDEX.md`**；必要时更新 `{Doc Root}/README.md` 导航段；受影响视角子目录 **`knowledge/*/README.md`** 索引表。  
3. **changelog**：在 **`{Doc Root}/changelogs/changelog.md`** 追加一条（无则建目录）；若仓库已仅用 **`CHANGELOG.md`**，则 **追加到该文件**，避免双文件并行（除非项目规定小写文件名）。  
4. **自检**：新增路径在 INDEX/子 README 中 **可点击**、无死链。

## 9. 阶段四：验收

**勾选**

- [ ] `knowledge/`、`requirements/` 路径与命名符合 README/模板  
- [ ] `{Doc Root}/INDEX.md` 与子域 README 已更新  
- [ ] Index §3 高相关项已覆盖或 **书面声明未纳入**  
- [ ] 已打开规约/源码的论述有据；未读处无「已实现」式断言  
- [ ] changelog 已记录本轮摘要  

**反模式**

- Doc Root 未统一即写入 → 双 SSOT  
- 无 Index 或跳过规约核对即大段编造  
- 只加 `.md` 不更 INDEX/README → 孤儿文件  
- 漏写 changelog → 无法审计  

## 10. 参考

- `.cursor/skills/document-indexing/SKILL.md`  
- `.cursor/skills/agent-guide/SKILL.md`  
- `.cursor/skills/knowledge-upgrade/SKILL.md`（应用内增量）  
- 根 `README.md`；`{Doc Root}/DESIGN.md`、`CONTRIBUTING.md`；`.ai/rules/`、`.ai/CONVENTIONS.md`

## 11. 执行节奏（可选）

每阶段前：缺模板则请用户指定或采用仓库默认。每阶段后：重大变更可简短确认再进入下一阶段。
