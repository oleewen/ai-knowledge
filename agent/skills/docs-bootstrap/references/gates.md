# docs-bootstrap 风险控制与确认点

命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-bootstrap 为**低风险工程同步**族中的装机编排：按参数确认与风险校核推进（副作用大，闸门从严）。

非 `--dry-run` 写盘前，须在对话取得用户明确同意（轻流程 `C`）。

## 参数确认

参数向导至少收口：

- `--components`（`docs` | `agent` | `both`，默认 `both`）
- 源路径模式：本仓快路径 vs `docs-bootstrap.sh`（见 workflow 探测规则）
- docs（若选）：`--target` / `--doc-target`，以及透传的 `--type` / `--mode` / `--scope` / `--force` / `--dry-run` 等
- agent（若选）：`--agents`、`--target` 或 `--agent-scope`（`home`|`project`），以及透传的 agent `--scope` / `--dry-run`

建议默认先 **dry-run**（分步路径对两脚本加 `--dry-run`）。仅当走 `docs-bootstrap.sh`（remote + 表面参）时用计划摘要等价校核。

宣称完成前须写后 **A/B**（[audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表）。

## 风险与动作

须先给结论、推荐与数字/字母选项，确认后再执行：

- dry-run / 计划摘要与预期不一致
- `--force` 覆盖已有目标文档树
- Agent 安装到 `$HOME`（`agent-scope=home` 或 agent `--target $HOME`）
- 目标父目录不存在、`.docsconfig` 将被改写
- remote bootstrap（会临时 clone）

推荐会话格式（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)）：

```text
即将执行 /docs-bootstrap，当前参数如下：
- components: <docs|agent|both>
- source: <local|remote>
- doc-target: <路径或 —>
- agents: <list 或 —>
- agent-target: <路径或 —>
- dry-run: <yes|no>
- force: <yes|no>

C 确认当前装机计划 / M 修改参数 / S 跳过 / F 在已确认前提下补齐同类计划
```
