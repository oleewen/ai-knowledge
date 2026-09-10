# skill-upgrade 陷阱

- **无清单实跑**：禁止；须 dry-run/计划勾选后 `C`。
- **无源强更**：禁止猜 GitHub；须搜前确认 → find-skills 流程 → 建议桶/待决策。
- **拒 find 仍搜**：禁止；拒绝则本段跳过。
- **建议桶免确认 add**：禁止；汇总确认后才 `skills add -g`。
- **多候选自动挑**：禁止；进待决策表。
- **overlap**：生态跳过；以本仓 agent-install 为准。
- **误用 docs-bootstrap both**：追新本仓用 `--components=agent` 或 `agent-install`。
- **bootstrap 再 clone**：本地树用 `agent-install` 或 `GIT_REPO_URL=/local/path`。
- **工程级 target**：须显式确认。
- **agents 探测**：只认 cursor/claude/trae/kiro/codex 映射目录。
- **`npx skills update` 无 dry-run**：用 lock 清单代替。
- **纯发现 ≠ 本技能**：无追新语境的「找 skill」走 `/find-skills`。
- **与 docs-upgrade**：不管 DOC_ROOT 模板。
- **Bash 5+**；生态/find 需 Node/`npx`；远程本仓需 Git。
