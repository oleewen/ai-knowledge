# docs-upgrade 风险控制与确认点

命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)、[merge-rules.md](merge-rules.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-upgrade 为**低风险工程同步**族中的升级编排：副作用写 `DOC_ROOT`，闸门从严。

非 `--dry-run` 写盘前，须在对话取得用户明确同意（轻流程 `C`）。

## 参数确认

参数向导至少收口：

- 工程根 / `.docsconfig` 可用（`DOC_ROOT`、`KNOWLEDGE_TYPE`）
- meta 源：links 唯一 `type: meta`，或本次 `--meta-path`
- ref（默认 `main`；meta 条或 CLI 可覆盖）
- 是否先 dry-run（默认是）

宣称完成前须写后 **A/B**（[audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表）。

## 风险与动作

须先给结论、推荐与数字/字母选项，确认后再执行：

- dry-run 清单与预期不一致
- 将改已有 md（结构重填桶非空）
- 未落位节将追加或改写目标文
- `--meta-path` 覆盖登记 meta
- 备份目录将写入 `{REPO_ROOT}/.docs-init/`

推荐会话格式（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)）：

```text
即将执行 /docs-upgrade，当前参数如下：
- DOC_ROOT: <路径>
- KNOWLEDGE_TYPE: <application|system|company>
- meta: <path 或 repository>
- ref: <main 或覆盖>
- dry-run: <yes|no>
- 清单: 忽略槽位 I / 新增骨架 N / 跳过 S / 结构重填 R / 本库独有 L

C 确认当前升级计划 / M 修改参数 / S 跳过 / F 在已确认前提下补齐同类计划
```

未落位阶段（写前 `C` 已批骨架+可对齐重填之后）一次只问一项，格式：

```text
未落位 i/N：<相对路径> § <标题>
推荐：追加到文末 / 并入候选节 / 丢弃（须明示）
请选：1 追加文末 / 2 并入 <节> / 3 跳过本项 / M 改推荐
```
