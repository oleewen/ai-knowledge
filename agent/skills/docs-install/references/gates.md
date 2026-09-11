# docs-install 风险控制与确认点

命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-install 为**低风险工程同步**族中的装机步骤：按参数确认与风险校核推进（副作用大，闸门从严）。

非 `--dry-run` 写盘前，须在对话取得用户明确同意（轻流程 `C`）。

## 参数确认

参数向导至少收口：

- `--target`（必填）
- `--scope`（`knowledge` | `config`）
- knowledge 时：`--type` / `--mode` / `--force` / `--dry-run` 等
- 是否已完成 dry-run 并授权真写

建议默认先 **--dry-run**。宣称完成前须写后 **A/B**（[audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表）。

## 风险与动作

须先给结论、推荐与数字/字母选项，确认后再执行：

- dry-run 摘要与预期不一致
- `--force` 覆盖已有目标文档树
- `--scope=knowledge` 将重置 DOC_DIR 内容
- 目标父目录不存在、`.docsconfig` 将被改写

推荐会话格式（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)）：

```text
即将执行 /docs-install，当前参数如下：
- target: <路径>
- scope: <knowledge|config>
- type: <application|system|company 或 —>
- mode: <standalone|central 或 —>
- dry-run: <yes|no>
- force: <yes|no>

C 确认当前装机计划 / M 修改参数 / S 跳过 / F 在已确认前提下补齐同类计划
```
