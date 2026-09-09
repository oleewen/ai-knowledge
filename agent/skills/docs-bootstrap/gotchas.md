# docs-bootstrap 陷阱

- **dry-run 与尚未存在的 `--target`**：`--dry-run` 不建目录；若 docs 路径尚不存在，拷贝预览可能仍打印，但 `.docsconfig` 步会报「DOC_ROOT 父目录不可解析」。冒烟/预览前先 `mkdir -p <target>`，或接受该步失败仍以拷贝预览为准。
- **超出 bootstrap 表面参**：含 `--force` / `--type` / `--mode` / docs|agent `--scope` / 分步 `--dry-run` 等 → 禁止 `docs-bootstrap.sh`，取得脚本树后分步透传。
- **`--components` 只存在于技能层**：`docs-bootstrap.sh` 固定跑 docs+agent；单选时必须直接调对应脚本。
- **本仓快路径三文件缺一不可**：缺任一则 `source=remote`；仅 remote + both + 表面三参时可走 `docs-bootstrap.sh`。
- **bootstrap 总会临时 clone**：即使从已克隆仓启动脚本也如此；要复用当前工作区树用 local 分步。
- **`--force` / 覆盖已有 docs**：默认交互冲突策略；Agent 会话须先确认再带 `--force`。
- **`$HOME` Agent 树**：单份实体在 `~/.agents/`，多 Agent 目录为链接/安装目标；写 home 前须明示。
- **`.docsconfig` 漂移**：装机后 `REPO_ROOT`/`DOC_ROOT` 与实际不一致 → 再跑 docs-install 修复（见 scripts README）。
- **Bash 5+**、Git（bootstrap）必需。
- **勿与 docs-link 混淆**：联邦 parent/child 登记不是本技能。
