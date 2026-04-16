# Cursor 项目钩子

| 钩子 | 事件 | 说明 |
|------|------|------|
| [sdx_gate_common.py](sdx_gate_common.py) | `preToolUse`（`Write` / `StrReplace`） | 统一实现：`python3 agent/hooks/sdx_gate_common.py --gate <name>`。`name` 与受管路径对应关系：`solution` → `**/solutions/SOLUTION-*.md`（[sdx-solution](../skills/sdx-solution/SKILL.md)）；`analysis` → `**/analysis/ANALYSIS-*.md`（[sdx-analysis](../skills/sdx-analysis/SKILL.md)）；`design` → `**/requirements/**/ADD-*.md`（[sdx-design](../skills/sdx-design/SKILL.md)）；`prd` → `**/requirements/**/PRD-*.md`（[sdx-prd](../skills/sdx-prd/SKILL.md)）；`test` → `**/requirements/**/TDD-*.md`（[sdx-test](../skills/sdx-test/SKILL.md)）。 |

### 同构闸门语义、尚无 preToolUse 脚本

| 技能 | 说明 |
|------|------|
| docs-archive | 与 sdx-* 相同「中间会话 spec + `PENDING`/`CONFIRMED` + 用户总确认」话语体系；规范见 [agent/skills/docs-archive/reference/interaction-gate.md](../skills/docs-archive/reference/interaction-gate.md)，规则总表见 [agent/rules/CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 第三节。当前**未**提供写入拦截脚本，以技能与会话执行为准。 |

## 如何自动生效（无需单独「Hooks 总开关」）

钩子配置 SSOT 为 [agent/hooks.json](../hooks.json)。在目标工程侧，`agent-install` 会将其复制为 **`${TARGET}/.cursor/hooks.json`**（与其它 Agent 资产一致）。保存后 Cursor 会重载钩子配置。本仓库已包含工作区设置 [.vscode/settings.json](../../.vscode/settings.json)（为 `agent/hooks.json` 与 `.cursor/hooks.json` 提供 JSON Schema，便于校验与补全）。

请同时满足：

1. **用文件夹打开仓库**（`File → Open Folder` / `cursor /path/to/ai-knowledge`）。仅打开单个文件时，工作区钩子往往**不会**加载。
2. **Agent 能执行工具**：`preToolUse` 在 Agent 调用 `Write` / `StrReplace` 时触发。请在 **Cursor Settings → Chat / Agent** 中将自动运行模式设为**非**「每次都询问」（例如允许自动运行终端/工具；具体文案随版本可能为 *Run Everything*、*Auto-run*、*YOLO* 等）。若始终停在确认每一步，钩子可能不按预期触发。
3. **排查**：菜单 **View → Output**，下拉选择 **Hooks**，查看是否已加载钩子及脚本是否报错。

未满足上述条件时，仓库内文档与闸门约定仍然有效，但 IDE 侧拦截可能不生效。
