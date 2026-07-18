# Cursor 项目钩子

配置 SSOT：[agent/hooks.json](../hooks.json)。当前 **`preToolUse` 为空**：不注册写前拦截。

主线正确性依赖技能协议（参数向导 → 澄清 → 生成 → 烤干 / 轻流程），见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)、[unit-cycle-protocol.md](../references/unit-cycle-protocol.md)、[light-flow-actions.md](../references/light-flow-actions.md)。

## 本目录

本目录不再包含 gate 脚本。`agent-install` 仍可同步空目录与 `hooks.json`，以便目标工程 `.cursor/hooks.json` 覆盖为「无拦截」。

## 升级目标工程（必做）

若目标工程仍挂着**旧版** `.cursor/hooks.json`（指向已删除的 `sdx_gate_common.py` / `sdx_session_gate.py` 等）：

1. 用当前仓库重新执行安装（含 hooks scope），或手动用本仓 [agent/hooks.json](../hooks.json) 覆盖目标 `.cursor/hooks.json`。
2. 用文件夹打开目标仓库，确认 Cursor **Hooks** 输出无报错脚本路径。
3. 勿再调用 `python3 agent/hooks/sdx_gate_common.py --gate …`（文件已移除）。

未刷新时，旧配置可能因脚本缺失而在 `preToolUse` 上报错；刷新为空配置后即恢复。

## 如何确认已生效

1. **用文件夹打开仓库**（勿只开单文件）。
2. **View → Output → Hooks**：应加载 `hooks.json`，且无已删除脚本的失败记录。
3. 写文件不再依赖 hook 放行；协议由 Agent 按技能执行。
