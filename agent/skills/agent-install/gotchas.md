# agent-install 陷阱

- **`$HOME` Agent 树**：单份实体在 `~/.agents/`（契约 `AGENT_ROOT=~`、`AGENT_DIR=.agents`）；写 home 前须明示。
- **不写 `.docsconfig`**：`AGENT_ROOT`/`AGENT_DIR` 由 `/docs-install` 写入；工程级 `--target` 只链 IDE 目录。
- **README 不安装**：rsync 排除各层 README；勿期待目标出现中央库 README 副本。
- **生态 skills 追新**：本技能管本仓 `agent/skills` 树；`npx skills update` 走 `/skill-upgrade`。
- **bootstrap.sh**：自动化双轨用仓根 `bootstrap.sh`，对话双轨手动先 docs-install 后 agent-install。
- **Bash 5+** 必需。
