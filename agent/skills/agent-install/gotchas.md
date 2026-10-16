# agent-install 陷阱

- **书写序**：`meta → scope → target → agents → workspace → dry-run`（见 [parameters.md](references/parameters.md)）；勿与旧序混读。
- **默认 agents=`a`**：`a`/`all` 等价全量 IDE（不支持 `A`）；勿与 `--scope=a`（全量子树）混淆。
- **`$HOME` Agent 树**：单份实体在 `~/.agents/`（契约 `AGENT_ROOT=~`、`AGENT_DIR=.agents`）；写 home 前须明示。
- **不写 `.docsconfig`**：`AGENT_ROOT`/`AGENT_DIR` 由 `/docs-install` 写入；工程级 `--target` 只链 IDE 目录。
- **target ≠ workspace**：`--target` 是 IDE 软链父目录；`--workspace` 写 `WORK_SPACE`。默认常为 `$HOME` + `~/workspaces`，勿合并。
- **工作区文件**：未传 `--workspace` 时读 `.docsconfig` 的 `AGENT_ROOT`/`AGENT_DIR` → `configs` 内 `WORK_SPACE`；缺 AGENT_* 或 `WORK_SPACE` 则必须显式传入。实跑写入安装树 `configs`。链接 IDE 时跳过 `configs`。
- **README 不安装**：rsync 排除各层 README；勿期待目标出现元库 README 副本。
- **生态 skills 追新**：本技能管本仓 `agent/skills` 树；`npx skills update` 走 `/skill-upgrade`。
- **bootstrap.sh**：自动化双轨用仓根 `bootstrap.sh`，对话双轨手动先 docs-install 后 agent-install。
- **Bash 5+** 必需。
