# Cursor 项目钩子

| 钩子 | 事件 | 说明 |
|------|------|------|
| [sdx-solution-gate-write.py](sdx-solution-gate-write.py) | `preToolUse`（`Write` / `StrReplace`） | 拦截在未完成中间 spec 总确认前对 `**/solutions/SOLUTION-*.md` 的写入；详见 [.cursor/skills/sdx-solution/SKILL.md](../skills/sdx-solution/SKILL.md) |
| [sdx-analysis-gate-write.py](sdx-analysis-gate-write.py) | `preToolUse`（`Write` / `StrReplace`） | 拦截在未完成中间 spec 总确认前对 `**/analysis/ANALYSIS-*.md` 的写入；详见 [.cursor/skills/sdx-analysis/SKILL.md](../skills/sdx-analysis/SKILL.md) |

## 如何自动生效（无需单独「Hooks 总开关」）

Cursor 会加载仓库根目录下的 [hooks.json](../hooks.json)：保存该文件后会重载钩子配置。本仓库已包含工作区设置 [.vscode/settings.json](../../.vscode/settings.json)（为 `hooks.json` 提供 JSON Schema，便于校验与补全）。

请同时满足：

1. **用文件夹打开仓库**（`File → Open Folder` / `cursor /path/to/ai-knowledge`）。仅打开单个文件时，工作区钩子往往**不会**加载。
2. **Agent 能执行工具**：`preToolUse` 在 Agent 调用 `Write` / `StrReplace` 时触发。请在 **Cursor Settings → Chat / Agent** 中将自动运行模式设为**非**「每次都询问」（例如允许自动运行终端/工具；具体文案随版本可能为 *Run Everything*、*Auto-run*、*YOLO* 等）。若始终停在确认每一步，钩子可能不按预期触发。
3. **排查**：菜单 **View → Output**，下拉选择 **Hooks**，查看是否已加载钩子及脚本是否报错。

未满足上述条件时，仓库内文档与闸门约定仍然有效，但 IDE 侧拦截可能不生效。
