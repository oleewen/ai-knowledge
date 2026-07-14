# Cursor 项目钩子

| 钩子 | 事件 | 说明 |
| --- | --- | --- |
| [sdx_session_gate.py](sdx_session_gate.py) | 遗留兼容 | 保留旧会话激活识别逻辑，供历史安装产物或调试脚本兼容读取；当前默认不再挂载为 `preToolUse` 写前拦截。 |
| [sdx_gate_common.py](sdx_gate_common.py) | 遗留兼容 | 兼容旧 `python3 agent/hooks/sdx_gate_common.py --gate <name>` 调用，但已退化为始终 `allow` 的 no-op shim，用于防止历史目标工程在未刷新 Hook 配置时直接报错。 |

## 当前状态

- `agent/hooks.json` 当前不再注册任何 `preToolUse` 写前拦截，`sdx-*` 与 `docs-*` 主链默认依赖技能内的参数向导、当前段/当前单元、自动 grilling 与动作推进协议。
- `sdx_session_gate.py` 与 `sdx_gate_common.py` 仅为历史兼容保留；若目标工程仍携带旧 `.cursor/hooks.json`，刷新安装产物后即可移除旧拦截行为。
- docs 主链的正式规则以 [AGENTS.md](../../AGENTS.md)、[CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 与各技能 `SKILL.md` 为准，默认按参数向导、当前段/当前单元、自动 grilling 与动作推进协议执行。

## 如何自动生效（无需单独「Hooks 总开关」）

钩子配置 SSOT 为 [agent/hooks.json](../hooks.json)。在目标工程侧，`agent-install` 会将其复制为 **`${TARGET}/.cursor/hooks.json`**（与其它 Agent 资产一致）。保存后 Cursor 会重载钩子配置。本仓库已包含工作区设置 [.vscode/settings.json](../../.vscode/settings.json)（为 `agent/hooks.json` 与 `.cursor/hooks.json` 提供 JSON Schema，便于校验与补全）。

请同时满足：

1. **用文件夹打开仓库**（`File → Open Folder` / `cursor /path/to/ai-knowledge`）。仅打开单个文件时，工作区钩子往往**不会**加载。
2. **Agent 能执行工具**：`preToolUse` 在 Agent 调用 `Write` / `StrReplace` 时触发。请在 **Cursor Settings → Chat / Agent** 中将自动运行模式设为**非**「每次都询问」（例如允许自动运行终端/工具；具体文案随版本可能为 *Run Everything*、*Auto-run*、*YOLO* 等）。若始终停在确认每一步，钩子可能不按预期触发。
3. **排查**：菜单 **View → Output**，下拉选择 **Hooks**，查看是否已加载钩子及脚本是否报错。

未满足上述条件时，不影响当前主协议；是否拦截已不再作为默认正确性前提。

## 兼容说明

- 若目标工程仍挂着旧版 `.cursor/hooks.json`，`sdx_gate_common.py` 会兼容接受旧 `--gate` 参数，但只返回 `allow`。
- `sdx_session_gate.py` 仍会识别 `/sdx-*` 与部分 `/docs-*` 指令，方便历史状态文件或调试脚本继续读取“会话曾激活”这一事实。
- 后续若全仓不再需要历史兼容，可删除这两个脚本及其测试。
