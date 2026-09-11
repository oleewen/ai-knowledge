# docs-install 陷阱

- **dry-run 与尚未存在的 `--target`**：`--dry-run` 不建目录；若 docs 路径尚不存在，拷贝预览可能仍打印，但 `.docsconfig` 步会报「DOC_ROOT 父目录不可解析」。冒烟前先 `mkdir -p <target>`，或接受该步失败仍以拷贝预览为准。
- **`--force` / 覆盖已有 docs**：默认交互冲突策略；会话须先确认再带 `--force`。
- **建联脚本不落盘**：`docs-link.sh` / `link-config.sh` 仅在 `agent/skills/docs-link/scripts/`；联邦登记走 `/docs-link`，勿期待 install 拷贝到目标 `scripts/`。
- **`.docsconfig` 漂移**：装机后 `REPO_ROOT`/`DOC_ROOT` 与实际不一致 → 再跑 docs-install 修复（`--scope=config` 或 knowledge）。
- **Agent 树**：本技能不管；走 `/agent-install` 或双轨时在其之后执行。
- **Bash 5+** 必需。
