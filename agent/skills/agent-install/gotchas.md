# agent-install 陷阱

- **`$HOME` Agent 树**：单份实体在 `~/.agents/`；写 home 前须明示。
- **工程级 target**：须已有 `.docsconfig`；否则先 docs-install。
- **README 不安装**：rsync 排除各层 README；勿期待目标出现中央库 README 副本。
- **生态 skills 追新**：本技能管本仓 `agent/skills` 树；`npx skills update` 走 `/skill-upgrade`。
- **bootstrap.sh**：自动化双轨用仓根 `bootstrap.sh`，对话双轨手动先 docs-install 后 agent-install。
- **Bash 5+** 必需。
