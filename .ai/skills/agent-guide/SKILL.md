---
name: agent-guide
description: >
  生成/更新根目录 README.md（GitHub 惯例）与 AGENTS.md（Agent 契约）。
  仅以当前落盘的 Index Guide（常见为 `docs/INDEX_GUIDE.md`；仓库根可有 `PROJECT_INDEX.md` 短入口）为唯一地图按需补读
  README 承载命令与文档表，AGENTS 引用之，三文件不重复堆叠。
---

# Agent 指引生成（agent-guide）

面向 **人类开发者（README）** 与 **AI Agent（AGENTS）** 各一份入口文档；**平面检索与路径级精要**留在 **Index Guide**，本 Skill 不负责再造一套「小 INDEX」。

**执行前提（硬约束）**：本 Skill **只**基于 **当前仓库已落盘、经 §3 解析到的 INDEX** 执行 §4–§7。

## 1. 何时使用 / 何时不做

| 场景 | 行动 |
|------|------|
| 初始化仓库、onboarding、`/knowledge-build` **第二阶段** | **执行本 Skill** |
| 仅要平面索引、**九章 + 附录** Index Guide | 用 **document-indexing**，不用本 Skill |
| 用户只要改 `system/knowledge/` 实体 | 不强制跑本 Skill；若 AGENTS/README 路径过时再对齐 |

## 2. 输入 / 输出契约

| 类型 | 内容 |
|------|------|
| **输入（可选）** | 用户目标（新建 / 增量更新）、`output` 范围（仅 README / 仅 AGENTS / 两者） |
| **硬输入（探索）** | **仅** §3 解析得到的 **落盘 INDEX 单一路径**；不以用户粘贴全文代替落盘文件（除非用户显式声明「本次无落盘 Index，仅以附件为临时地图」且仍须遵守 §3「无 Index 不编造」） |
| **输出（固定）** | 仓库根目录 **`README.md`**、**`AGENTS.md`**（路径以项目根为准；单应用工程若有约定根目录则跟约定） |
| **不产出** | 不替代 **主 Index Guide**（如 `docs/INDEX_GUIDE.md`）的 §3 字典；不把 Index 全文合并进 AGENTS |

## 3. Index 解析（启动必做，唯一地图）

### 3.1 落盘路径（命中即停）

按优先级查找 **当前仓库** 下的 Index Guide（命中即停，**记录实际相对路径**写入会话/说明，后续 §4–§6 一律称该文件为「当前 INDEX」）：

1. 项目根 **`PROJECT_INDEX.md`**（仓库短入口，可选）、**`INDEX.md`**（兼容别名）、**`INDEX-GUIDE.md`**（标题常含「AI文档库精要索引指南」）
2. **`docs/INDEX_GUIDE.md`**、`docs/INDEX-GUIDE.md`

### 3.2 命中后的行为

- **立即**以该落盘文件为 **唯一** 探索地图进入 §4，**禁止**在本 Skill 内调用 document-indexing 或征求「重做/沿用」。
- **禁止**用「用户粘贴的 Index 全文」**默认替代**落盘文件；若仓库存在 §3.1 路径，一律以磁盘版本为准。

### 3.3 未命中任何落盘 Index 时

- **不**生成或更新 README/AGENTS（避免无地图编造结构）。
- 向用户说明：请先 **`/document-indexing`**（或手动添加 `docs/INDEX_GUIDE.md` / 根目录 `PROJECT_INDEX.md`）再执行本 Skill。
- **例外（显式降级）**：仅当用户 **明确声明**「仓库 intentionally 无 Index、授权用根 `README`/`pom.xml`/顶层目录做最小摸底」时，可生成 **极简** README/AGENTS，并 **必须** 写明「无标准 INDEX、建议补 document-indexing」；**仍禁止**捏造 §2 级模块细节。

## 4. 探索：以 INDEX 为地图、最小阅读集

**原则**：Index 为 **导航与待办清单**；只打开与「README 首屏 / AGENTS 契约」相关的文件，**禁止**为写 AGENTS 通读全仓。

| Index 节 | 探索用途 | 写入去向（摘要） |
|----------|----------|------------------|
| §1 元信息 | 技术栈、入口、命令 | README：简介 + Quick start；AGENTS：≤3 行 + 指针 |
| §2 拓扑 | 目录边界、依赖方向 | README：**唯一**详写目录树/结构处；AGENTS：短列表 |
| §3 API 入口 | **按需**打开 ⭐⭐⭐ Dubbo/HTTP/MQ/Job 等行 | **不**粘贴进 AGENTS；一句指向 **当前 INDEX**（§3 路径） |
| §4–§5 | 领域对象/表/数据流；组件配置/环境变量/启动脚本（若存在） | 仅当 README 要写环境/运行方式时再读 |
| §6 未索引 | 盲区 | 须描述某路径 → **只补读该路径**；否则「详见 INDEX §6」 |
| §7 查阅指北 | 检索顺序 | AGENTS 与此 **一致**，不另写一套矛盾策略 |

**几乎总是要做的轻量校验（可与 Index 对照）**

- **`.cursor/rules/CONVENTIONS.md`**（常见 Cursor 布局）与 **`.ai/rules/CONVENTIONS.md`**、**`.ai/rules/`**：**择仓库实际存在者**做目录浏览与必要文件头校验；规范入口、模板路径须 **真实存在**。
- **已有根 `README.md`**：更新时 **合并重复段落**，保留有效表格/命令块结构。
- **`knowledge/` 或 `system/knowledge/`**：只读各层 **README / INDEX**，不通读实体文档。

## 5. 三文件分工与去重（单一事实源）

| 文件 | 读者 | 放什么 | 不放什么 |
|------|------|--------|----------|
| **当前 INDEX**（§3） | AI 检索 | 七段、路径精要、未索引声明 | 冗长教程、重复命令百科 |
| **README.md** | 人类、GitHub 首屏 | H1+一句话、Quick start、**文档索引表**、目录结构 | Agent 角色与禁止项长文 |
| **AGENTS.md** | AI | 角色、约束、工作流、禁止项、**短**关键路径 | 完整命令手册（指回 README）、§3 API 入口全表副本 |

**去重硬规则**

1. **命令块、选项说明、大链接表** → 只放在 **README**；AGENTS 用「详见 `README.md`」+ 可选 **一条**最常用示例。
2. **项目概述 / 技术栈**（AGENTS）各 **≤3 行**；细节见 README 与 INDEX §1。
3. **查阅顺序**（写进 AGENTS，一句话）：**§3 解析到的当前主 Index / Index Guide 相对路径** → `README.md` → 子域 `**/INDEX.md` 或规范路径（若根为 `PROJECT_INDEX.md` 且主指南在 `docs/INDEX_GUIDE.md`，则照实写，勿写假路径）。

## 6. 产出：README（GitHub 惯例）与 AGENTS（模板对齐）

### 6.1 建议顺序：**先 README，后 AGENTS**

避免 AGENTS 写满命令后再在 README 重复粘贴；AGENTS 内链指向 README 已定稿的小节。

### 6.2 README.md 推荐骨架

文档型/工具型仓库可删减小节，但 **推荐顺序**保持：

1. **H1 标题 + 单行摘要**
2. **（可选）徽章**
3. **简介**（2–5 句，细节链到 **当前 INDEX**（§3 相对路径）或子文档）
4. **Quick start**（可执行命令；复杂选项链到 `scripts/README.md` 等）
5. **（可选）Features**
6. **Documentation**：用途 | 链接表（人类导航；与 INDEX 互补）
7. **Project structure**：与 Index §2 **一致**，禁止第二套矛盾树
8. **Contributing / License**（按仓库实际）

**合格线**：新读者约 30 秒内知道「是什么、下一步点哪」；相对路径可点、表格不空洞。

### 6.3 AGENTS.md

- **基准**：`.ai/rules/agents-template.md`（可裁剪，**禁止**与模板语义冲突的「先读后改」原则）。
- **建议固定块**：角色与行为 → 与 Index 一致（一句）→ 关键路径（短列表）→ 技术栈（精要）→ 命令（**指针为主**）→ 开发规范 → 工作流 → 禁止事项 → 参考（**首条为 §3 确定的当前主 Index 相对路径**，勿默认写根 `INDEX.md` 若实际为 `PROJECT_INDEX.md` / `docs/INDEX_GUIDE.md`）。
- **事实**：INDEX §6 或未读路径不得写成已核实结论。

## 7. 验收与反模式

**发布前勾选**

- [ ] README 与 AGENTS **无大段重复**
- [ ] AGENTS **未**堆叠 INDEX §3 级 API 入口表
- [ ] README 文档表、AGENTS「参考」、**当前主 Index**（§3）内路径 **一致、可跳转**；AGENTS 首条参考 **非**误写路径（若实际为 `PROJECT_INDEX.md` + `docs/INDEX_GUIDE.md` 分工则照实写）
- [ ] 命令在 README 中 **可复制执行**（或明确链到含命令的子文档）
- [ ] 规范/模板路径在磁盘上 **存在**

**反模式（禁止）**

- 在 AGENTS 里重写一份「完整文档索引表」
- 在本 Skill 执行流程内 **调用 document-indexing** 或 **等待用户选择是否重做索引**
- 无 §3 落盘 Index 时（且用户未授权 §3.3 例外）编造目录/模块细节
- README 与 **当前** INDEX §2 目录树 **互相矛盾**
- 把「未索引」区域写死为已读事实

## 8. 与其他 Skill 的衔接

| Skill | 关系 |
|-------|------|
| **document-indexing** | **不**在本 Skill 内执行。INDEX 须已落盘；更新 INDEX 请用户 **单独** 运行 document-indexing，再跑 agent-guide |
| **knowledge-build** | 其 **第二阶段** 即本 Skill；完成后第三阶段才写 `knowledge/` |
| **knowledge-upgrade** | 通常 **不含**本阶段；应用内若有独立 AGENTS/README 约定则跟应用 INDEX |

## 9. 参考路径

- Index 结构与模式：`.cursor/skills/document-indexing/SKILL.md`
- Agent 文档模板：`.ai/rules/agents-template.md`
- 规范索引：`.cursor/rules/CONVENTIONS.md`（若存在）、`.ai/CONVENTIONS.md`（若存在）、`.ai/rules/`
