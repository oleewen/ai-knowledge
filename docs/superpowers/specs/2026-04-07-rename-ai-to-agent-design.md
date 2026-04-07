# 设计说明：仓库根 `.ai/` 重命名为 `.agent/`（实施记录）

**日期**：2026-04-07  
**状态**：**已实施**（方案 B）  
**范围**：`ai-knowledge` 仓库内协作控制层目录更名与引用对齐

---

## 1. 背景

原 `.ai/` 目录承载 `rules/`、`skills/`、`scripts/`（共享 Bash 库），名称偏泛；现统一为 **`.agent/`**，与「Agent 规则与 Slash 技能」叙事一致，并与用户侧 `.cursor/`、`.trea/` 等并列时更易解释。

---

## 2. 已执行变更摘要

| 类别 | 说明 |
|------|------|
| 目录 | `git mv .ai .agent` |
| 站内路径 | 批量将字面量 `.ai/` 替换为 `.agent/`（Markdown、YAML、Shell 等） |
| `scripts/docs-init.sh` | 源路径改为 `${repo_root}/.agent/skills`、`/.agent/rules`；Perl 内容替换由 `s{\.agent/}` 将中央库路径改写为目标 Agent 前缀（如 `.cursor/`） |
| 仓库根探测 | `.agent/scripts/sdx-doc-root.sh` 存在性作为向上解析仓库根的锚点 |
| 手工补全 | 无尾斜杠写法（如「`.ai` 目录」、INDEX 小节标题）已改为 `.agent`；`.agent/README.md` 中保留对旧名 `.ai/` 的一句迁移提示 |

**未改动（刻意保留）**

- Java 示例包名 `com.ai.*`、`Claude.ai` 正文等，与目录名无关。

---

## 3. 对外破坏性说明

- **旧路径 `.ai/` 已废弃**；自动化、书签、站外文档中若仍写 `.ai/skills`、`/.ai/rules` 等，请改为 `.agent/` 下对应路径。
- 远程 raw 链接（如 GitHub）须按新路径更新。

---

## 4. 验证建议

- `bash .agent/skills/agent-guide/scripts/validate-guide.sh --root .`（若存在）
- `docs-init.sh --dry-run` 试跑，确认能解析 `${REPO_ROOT}/.agent/skills` 与 `/.agent/rules`
- `rg '\.ai/'` 审查剩余命中（应为迁移说明或无关内容如 `com.ai`）

---

## 5. 历史方案对比（归档）

| 方案 | 结论 |
|------|------|
| A. 保持 `.ai/` | 未采纳（已选 B） |
| B. 重命名为 `.agent/` | **已采纳** |
| C. 符号链接双路径 | 未采纳 |

---

## 6. 自审

- 本文与当前仓库结构一致；若再次更名，请同步更新 `docs-init.sh` 与根探测脚本。
