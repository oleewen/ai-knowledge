# agent-install 风险控制与确认点

见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，agent-install 为**低风险工程同步**族：写 `$HOME` 或工程树前须参数确认与风险校核。

非 `--dry-run` 写盘前，须在对话取得用户明确同意（轻流程 `C`）。

## 参数确认

至少按书写序收口：`--scope`、`--target`、`--agents`、`--workspace`（或可推断）、是否 dry-run 后真写（`--meta` 按需）。

宣称完成前须写后 **A/B**。

## 风险与动作

须先确认再执行：

- dry-run 摘要与预期不一致
- `--target $HOME` 或 `agent-scope=home` 写 Agent 树
- 工程级 `--target` 覆盖已有 Agent 链接
- 目标无 `.docsconfig`
- 未传 `--workspace` 且无法从 configs 推断 `WORK_SPACE`

推荐会话格式：

```text
即将执行 /agent-install，当前参数如下：
- meta: <路径|默认>
- scope: <a|r|s|h|sh|k>
- target: <路径>
- agents: <list>
- workspace: <路径|推断自 configs>
- dry-run: <yes|no>

C 确认 / M 修改 / S 跳过 / F 补齐
```
