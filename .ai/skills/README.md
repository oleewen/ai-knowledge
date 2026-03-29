# Cursor 项目配置

## Slash 命令（Skills）

上述命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行）。**不是** 仓库 `scripts/` 下的 Bash 可执行脚本；权威路径为仓库根下 `.ai/skills/`（本文件所在树；初始化脚本可将子集同步到目标工程的 `.ai/`）。

| 命令 | 说明 |
|------|------|
| `/document-indexing` | 文档索引：为代码库/文档库生成面向下游 AI 的 Index Guide（拓扑/结构/精读三 `read_mode`，**九章 + 附录** 金字塔，零幻觉路径精确）。 |
| `/document-change` | 变更文档索引：检查最近变动内容，建立变动内容索引与变动时间（毫秒）；支持 git commit / CHANGELOG / 文件 mtime 三路合并。 |
| `/agent-guide` | 生成/更新根目录 `AGENTS.md` 与 `README.md`；① document-indexing 产出 Index → ② agent-guide 产出 AGENTS/README |

在 Chat 中输入 `/` 后选择对应命令即可调用（如 `/agent-guide`）；或使用 `@技能名`（如 `@agent-guide`、`@sdx-solution`）将 Skill 作为上下文附加。

**说明**：斜杠命令由 `.ai/skills/<技能名>/SKILL.md` 提供，文件夹名即命令名（如 `skills/agent-guide` → `/agent-guide`）。执行时按 SKILL 步骤落盘产物（如 `document-change` → `changes-index.*`，`document-indexing` → 根 `INDEX_GUIDE.md`（`@docs/INDEX_GUIDE.md` 短入口）+ `indexing-log.jsonl`（以仓库约定为准）），无独立 `document-change.sh` 一类脚本。
