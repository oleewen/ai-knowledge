---
name: agent-guide
description: >
  生成或更新仓库根目录的 README.md（面向人类开发者）与 AGENTS.md（面向 AI Agent 的契约文件）。
  以落盘 INDEX_GUIDE.md 为唯一地图，最小阅读集探索，三文件职责不重叠。
  当用户执行 /agent-guide、需要初始化或更新仓库入口文档、做仓库 onboarding、
  更新 Agent 契约、README 过时需要同步、或新成员/新 Agent 需要快速上手时，务必使用本技能。
  即使用户只说"帮我写个 README"、"更新一下 AGENTS"、"整理一下项目文档入口"，也应触发本技能。
---

# Agent 指引生成（agent-guide）

面向**人类开发者（README）**与 **AI Agent（AGENTS）**各一份入口文档；平面检索与路径级精要留在 Index Guide，三文件不重叠。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 落盘 INDEX（§1 解析）；无落盘 Index 不编造 |
| 可选输入 | 用户目标（新建/增量）、`--output` 范围（readme / agents / both） |
| 固定输出 | `{REPO_ROOT}` 下 `README.md`、`AGENTS.md` |
| 不产出 | 不替代 Index Guide；不把 Index 全文合并进 AGENTS |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--output` | 否 | `both` | `readme` / `agents` / `both` |
| `--mode` | 否 | `update` | `create`（初始化）或 `update`（增量合并） |

## 工作流（五步）

### 步骤 1：Index 解析

先推断 `REPO_DOC_ROOT`（知识库根目录绝对路径），再推断 `REPO_ROOT`（仓库根绝对路径）。

```bash
REPO_DOC_ROOT="$(sdx_resolve_repo_doc_root)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
```

按优先级查找落盘 Index Guide，命中即停，记录实际相对路径：

1. `REPO_ROOT` 下 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`
2. `REPO_DOC_ROOT` 下 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`

未命中 → 终止，提示用户先运行 `/docs-indexing`。详细规则与降级例外见 [reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 2：最小阅读集探索

以 INDEX 为地图，只打开与「README 首屏 / AGENTS 契约」直接相关的文件。各章节用途：

| INDEX 章节 | 用途 | 写入去向 |
|-----------|------|---------|
| §1 元信息 | 技术栈、入口、命令 | README 简介 + Quick start；AGENTS ≤3 行 + 指针 |
| §2 拓扑 | 目录边界、依赖方向 | README 目录树（唯一详写处）；AGENTS 短列表 |
| §3 API 入口 | 按需打开 ⭐⭐⭐ 条目 | 不粘贴进 AGENTS；一句指向 INDEX §3 |
| §6 未索引 | 盲区 | 须描述某路径时只补读该路径；否则「详见 INDEX §6」 |

禁止为写 AGENTS 通读全仓。

### 步骤 3：生成 README

按 [assets/readme-skeleton.md](assets/readme-skeleton.md) 骨架生成。合格线：新读者 30 秒内知道「是什么、下一步点哪」；相对路径可点、表格不空洞；目录树与 INDEX §2 一致。

### 步骤 4：生成 AGENTS

按 [assets/agents-skeleton.md](assets/agents-skeleton.md) 骨架生成。三文件去重规则见 [reference/three-file-spec.md](reference/three-file-spec.md)。AGENTS 项目概述 ≤3 行，命令块只在 README，AGENTS 用指针。

### 步骤 5：验证

```bash
bash .agent/skills/agent-guide/scripts/validate-guide.sh --root .
```

完整验收清单与反模式见 [reference/quality-standards.md](reference/quality-standards.md)。

## 核心约束

| 约束 | 说明 |
|------|------|
| 零幻觉 | 无落盘 INDEX 不编造结构；未读路径不写成已核实结论 |
| 单一事实源 | 命令块只在 README；AGENTS 概述 ≤3 行；不复制 INDEX §3 表 |
| 先 README 后 AGENTS | 避免命令块在两处重复 |
| INDEX 只读 | 禁止在本 Skill 内调用 docs-indexing 或重做索引 |
| 合并优先 | `--mode update` 时合并重复段落，保留有效表格/命令块 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `docs-indexing` | INDEX 须已落盘；更新 INDEX 请单独运行 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 执行规范（Index 解析 + 探索策略 + 错误处理） | [reference/execution-spec.md](reference/execution-spec.md) | Index 解析规则不确定、遇到降级场景时 |
| 三文件分工去重与产出规范 | [reference/three-file-spec.md](reference/three-file-spec.md) | 不确定某内容该放哪个文件时 |
| 验收清单与反模式 | [reference/quality-standards.md](reference/quality-standards.md) | 步骤 5 验证时 |
| README 输出骨架 | [assets/readme-skeleton.md](assets/readme-skeleton.md) | 生成 README 时 |
| AGENTS 输出骨架 | [assets/agents-skeleton.md](assets/agents-skeleton.md) | 生成 AGENTS 时 |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) | 遇到 Index/生成/验证相关问题时 |
| 路径验证脚本 | [scripts/validate-guide.sh](scripts/validate-guide.sh) | 步骤 5 自动验证时 |
