# docs-upgrade 风险控制与确认点

命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)、[merge-rules.md](merge-rules.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-upgrade 为**低风险工程同步**族中的升级编排：副作用写 `DOC_ROOT`（文件模式另可写允许的建联脚本），闸门从严。

非 dry-run / 非总览确认的写盘前，须在对话取得用户明确同意（轻流程 `C`）。

## 参数确认

参数向导至少收口：

- 工程根 / `.docsconfig` 可用（`DOC_ROOT`、`KNOWLEDGE_TYPE`）
- meta 源：links 唯一 `type: meta`，或本次 `--meta-path`
- ref（默认 `main`；meta 条或 CLI 可覆盖）
- 模式：整树（默认 dry-run）或文件（`@` 已解析）

宣称完成前须写后 **A/B**（[audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表）。文件模式：整单结束一次 A/B。

## 风险与动作

须先给结论、推荐与数字/字母选项，确认后再执行：

- dry-run / 文件总览与预期不一致
- 将改已有 md（结构重填或强制重填）
- 未落位节将追加或改写目标文
- `--meta-path` 覆盖登记 meta
- 整树备份目录将写入 `{REPO_ROOT}/.docs-init/`
- 文件模式无 `.docs-init` 备份（依赖 git）——须在总览或首文件前提示
- 建联脚本整文件覆盖

### 整树会话格式

推荐会话格式（字母见 [light-flow-actions.md](../../../references/light-flow-actions.md)）：

```text
即将执行 /docs-upgrade（整树），当前参数如下：
- DOC_ROOT: <路径>
- KNOWLEDGE_TYPE: <application|system|company>
- meta: <path 或 repository>
- ref: <main 或覆盖>
- dry-run: <yes|no>
- 清单: 忽略遗留槽位 I / 跳过软链 Y / 新增骨架 N / 跳过 S / 结构重填 R / 本库独有 L / 工具脚本 T

C 确认当前升级计划 / M 修改参数 / S 跳过 / F 在已确认前提下补齐同类计划
```

### 文件模式会话格式

总览：

```text
即将执行 /docs-upgrade（文件强制对齐），当前参数如下：
- DOC_ROOT: <路径>
- KNOWLEDGE_TYPE: <application|system|company>
- meta: <path 或 repository>
- ref: <main 或覆盖>
- 备份: 不强制 .docs-init（依赖 git）
- 名单 N=<n>：
  - <相对或 scripts/…> → 强制重填 | scaffold | 非md跳过覆盖 | 元缺拒绝 | 软链拒绝 | 遗留槽位拒绝 | changelogs本库胜 | 建联覆盖
C 确认名单 / M 改 @ 或参数 / S 取消整单 / F 不适用扩整树
```

逐文件：

```text
文件 i/N：<路径> 动作=<强制重填|scaffold|建联覆盖>
预览：<短摘要>
C 写入本文件 / M 改本文件推荐 / S 跳过本文件继续 / F 不适用扩整树
```

未落位阶段（该文件已 `C` 进入重填后）一次只问一项：

```text
未落位 i/N：<相对路径> § <标题>
推荐：追加到文末 / 并入候选节 / 丢弃（须明示）
请选：1 追加文末 / 2 并入 <节> / 3 跳过本项 / M 改推荐
```

### 中途动作（文件模式）

| 动作 | 效果 |
| --- | --- |
| 总览 `S` | 取消整单，不写盘 |
| 文件 `S` | 跳过当前文件，继续下一文件；已写盘不回滚 |
| 文件 `M` | 只重开当前文件；不重开整个 N 列表 |
| `F` | 不把本单元扩成整树（模式互斥） |
