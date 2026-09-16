# docs-install 陷阱

- **dry-run 与尚未存在的 `--target`**：`--dry-run` 不建目录；若 docs 路径尚不存在，拷贝预览可能仍打印，但 `.docsconfig` 步会报「DOC_ROOT 父目录不可解析」。冒烟前先 `mkdir -p <target>`，或接受该步失败仍以拷贝预览为准。
- **`--force` / 覆盖已有 docs**：默认交互冲突策略；会话须先确认再带 `--force`。`--scope=knowledge` 先备份清空再复制，根级 `CONTRIBUTING.md` 与 `DESIGN.md` 亦整文件来自模板（standalone 全量与 central 子集均种；源无则不造）。`DESIGN.md` 为层入口模板；语义 SSOT 在 `agent/knowledge/knowledge-governance.md`。保正文结构重填走 `/docs-upgrade`（根级 `DESIGN.md` 为整文件覆盖特例），不要用重装当升级。
- **建联脚本不落盘**：`docs-link.sh` / `link-config.sh` 仅在 `agent/skills/docs-link/scripts/`；联邦登记走 `/docs-link`，勿期待 install 拷贝到目标 `scripts/`。
- **`.docsconfig` 漂移**：装机后 `REPO_ROOT`/`DOC_ROOT` 与实际不一致 → 再跑 docs-install 修复（`--scope=config` 或 knowledge）。
- **Agent 树**：本技能不管；走 `/agent-install` 或双轨时在其之后执行。
- **路径重写**：knowledge 实跑收尾将裸 `agent/` 与已知 IDE 段重写为字面 `~/.agents/`；dry-run 不重写。
- **`.docsconfig` AGENT_***：只写 `AGENT_ROOT`（默认/`agent-install` 工程级写回均为 `~/.agents`）。
- **Bash 5+** 必需。
