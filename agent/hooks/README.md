# Cursor 项目钩子

| 钩子 | 事件 | 说明 |
|------|------|------|
| [sdx_session_gate.py](sdx_session_gate.py) | `preToolUse`（`Write` / `StrReplace`） | 会话激活前置脚本：检测会话内是否出现 `/sdx-*` 或 `/docs-distill`、`/docs-extract`、`/docs-archive`、`/docs-build`（见源码正则）。命中后标记当前会话为 SDX 激活态。 |
| [sdx_gate_common.py](sdx_gate_common.py) | `preToolUse`（`Write` / `StrReplace`） | 统一实现：`python3 agent/hooks/sdx_gate_common.py --gate <name>`。仅在 `sdx_session_gate.py` 已激活会话后生效。`architect` → `**/requirements/**/ASD-*.md`（[sdx-architect](../skills/sdx-architect/SKILL.md)）；`design` → `**/requirements/**/DSD-*.md`（[sdx-design](../skills/sdx-design/SKILL.md)）；另有 `solution`、`analysis`、`prd`、`test`、`distill`、`extract`、`archive`、`build` 等（见源码 `GATES`）。 |

### 同构闸门语义（docs-distill / docs-extract 等）

| 技能 | 说明 |
|------|------|
| docs-distill | 与 sdx-* 相同「中间会话 spec + `PENDING`/`CONFIRMED` + 用户总确认」话语体系；规范见 [agent/skills/docs-distill/references/interaction-gate.md](../skills/docs-distill/references/interaction-gate.md) 与 [agent/skills/docs-distill/references/gates.md](../skills/docs-distill/references/gates.md)，规则总表见 [agent/rules/CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 第三节。写入拦截由上文 `sdx_gate_common.py --gate distill` 与同表其他 gate 一致实现；须满足会话激活等条件，详见 Output 面板 Hooks 日志。 |
| docs-extract | 同上话语体系；规范见 [agent/skills/docs-extract/references/interaction-gate.md](../skills/docs-extract/references/interaction-gate.md) 与 [agent/skills/docs-extract/references/gates.md](../skills/docs-extract/references/gates.md)，规则总表见 [agent/rules/CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 第三节。写入拦截由 `sdx_gate_common.py --gate extract` 与同表其他 gate 一致实现。 |

**docs-pull（联邦镜像拉取）**：属 CONVENTIONS 表「低风险」——**不**强制 `docs/superpowers/specs` 门闩，**无** `sdx_gate_common.py` 对应 gate；写盘前对话内确认见 [agent/skills/docs-pull/references/gates.md](../skills/docs-pull/references/gates.md)。

## 如何自动生效（无需单独「Hooks 总开关」）

钩子配置 SSOT 为 [agent/hooks.json](../hooks.json)。在目标工程侧，`agent-install` 会将其复制为 **`${TARGET}/.cursor/hooks.json`**（与其它 Agent 资产一致）。保存后 Cursor 会重载钩子配置。本仓库已包含工作区设置 [.vscode/settings.json](../../.vscode/settings.json)（为 `agent/hooks.json` 与 `.cursor/hooks.json` 提供 JSON Schema，便于校验与补全）。

请同时满足：

1. **用文件夹打开仓库**（`File → Open Folder` / `cursor /path/to/ai-knowledge`）。仅打开单个文件时，工作区钩子往往**不会**加载。
2. **Agent 能执行工具**：`preToolUse` 在 Agent 调用 `Write` / `StrReplace` 时触发。请在 **Cursor Settings → Chat / Agent** 中将自动运行模式设为**非**「每次都询问」（例如允许自动运行终端/工具；具体文案随版本可能为 *Run Everything*、*Auto-run*、*YOLO* 等）。若始终停在确认每一步，钩子可能不按预期触发。
3. **排查**：菜单 **View → Output**，下拉选择 **Hooks**，查看是否已加载钩子及脚本是否报错。

未满足上述条件时，仓库内文档与闸门约定仍然有效，但 IDE 侧拦截可能不生效。

## 会话触发语义

- 默认不拦截：若当前会话从未出现 `/sdx-*` 指令，`sdx_gate_common.py` 将直接放行。
- 一次激活、会话内持续生效：同一会话内只要出现过一次 `/sdx-*`，后续对受管路径的写入都进入 SDX 闸门校验。
- 受管路径与 `CONFIRMED + 目标文件名引用` 的放行规则保持不变。
