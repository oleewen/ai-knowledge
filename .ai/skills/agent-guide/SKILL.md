---
name: agent-guide
description: >
  生成/更新根目录 README.md（GitHub 惯例）与 AGENTS.md（Agent 契约）。
  仅以当前落盘的 Index Guide（常见为仓库根 `INDEX_GUIDE.md`，或 `system/INDEX_GUIDE.md`）为唯一地图按需补读，
  README 承载命令与文档表，AGENTS 引用之，三文件不重复堆叠。
  在用户执行 /agent-guide 或仓库 onboarding 时使用。
---

# Agent 指引生成（agent-guide）

面向 **人类开发者（README）** 与 **AI Agent（AGENTS）** 各一份入口文档；平面检索与路径级精要留在 Index Guide。

## 输入与输出

**输入**：落盘 INDEX + 代码库（可选：用户指定 output 范围）
**输出**：仓库根 `README.md`、`AGENTS.md`

| 类型 | 内容 |
|------|------|
| 硬输入 | 仅落盘 INDEX 单一路径（§1 解析）；无落盘 Index 不编造 |
| 可选输入 | 用户目标（新建/增量）、output 范围（仅 README / 仅 AGENTS / 两者） |
| 固定输出 | 仓库根 `README.md`、`AGENTS.md` |
| 不产出 | 不替代主 Index Guide；不把 Index 全文合并进 AGENTS |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--output` | 否 | `both` | `readme` / `agents` / `both` |
| `--mode` | 否 | `update` | `create`（初始化）或 `update`（增量合并） |

## 工作流（五步）

### 步骤 1：Index 解析

按优先级查找落盘 Index Guide（命中即停）：

1. 仓库根 `INDEX_GUIDE.md`、`INDEX.md`（兼容别名）、`INDEX-GUIDE.md`
2. `system/INDEX_GUIDE.md`、`system/INDEX-GUIDE.md`

未命中 → 终止并提示用户运行 `/document-indexing`。
详细规则见 [.ai/skills/agent-guide/reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 2：最小阅读集探索

以 INDEX 为地图，仅打开与 README 首屏 / AGENTS 契约相关的文件：

- §1 元信息 → 技术栈、入口、命令
- §2 拓扑 → 目录边界、依赖方向
- §3 API → **不**粘贴进 AGENTS，仅指针
- 已有 README → 合并而非覆盖

详细策略见 [.ai/skills/agent-guide/reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 3：生成 README

按 [.ai/skills/agent-guide/assets/readme-skeleton.md](assets/readme-skeleton.md) 骨架生成，先 README 后 AGENTS。

合格线：新读者 30 秒内知道「是什么、下一步点哪」；相对路径可点、表格不空洞。

### 步骤 4：生成 AGENTS

按 [.ai/skills/agent-guide/assets/agents-skeleton.md](assets/agents-skeleton.md) 骨架生成（该文件即权威基准）。

三文件去重规则见 [.ai/skills/agent-guide/reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 5：验证

按 [.ai/skills/agent-guide/reference/execution-spec.md](reference/execution-spec.md) 验收清单执行。可使用辅助脚本：

```bash
scripts/validate-guide.sh --root .
```

检查项：路径一致性、无大段重复、INDEX 引用正确。

## 核心约束

| 约束 | 说明 |
|------|------|
| 零幻觉 | 无落盘 INDEX 不编造结构；未读路径不写成已核实结论 |
| 单一事实源 | 命令块只在 README；AGENTS 概述 ≤3 行；不复制 INDEX §3 表 |
| 先 README 后 AGENTS | 避免 AGENTS 写满命令后 README 重复粘贴 |
| INDEX 只读 | 禁止在本 Skill 内调用 document-indexing 或重做索引 |
| 合并优先 | 更新已有 README 时合并重复段落，保留有效表格/命令块 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `document-indexing` | INDEX 须已落盘；更新 INDEX 请单独运行 |

## 参考

| 资源 | 路径 |
|------|------|
| 执行规范与验证清单 | [.ai/skills/agent-guide/reference/execution-spec.md](reference/execution-spec.md) |
| README 输出骨架 | [.ai/skills/agent-guide/assets/readme-skeleton.md](assets/readme-skeleton.md) |
| AGENTS 输出骨架与基准 | [.ai/skills/agent-guide/assets/agents-skeleton.md](assets/agents-skeleton.md) |
| 路径验证脚本 | [.ai/skills/agent-guide/scripts/validate-guide.sh](scripts/validate-guide.sh) |
