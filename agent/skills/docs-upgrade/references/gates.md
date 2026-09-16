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
- 模式：整树（默认 dry-run）或文件（指定路径已解析）

宣称完成前须写后 **A/B**（[audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表）。文件模式：整单结束一次 A/B。

## 风险与动作

须先给结论、推荐与数字/字母选项，确认后再执行：

- dry-run / 文件总览与预期不一致
- 将改已有 md（结构重填或强制重填）
- 未落位节将挂靠、追加或改写目标文
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

C 执行全部可处理项（对齐节按元库结构重填；未落位在本流程内逐项确认挂靠/追加/跳过）
M 改参数或下钻单文件
S 跳过 / F 在已确认前提下补齐同类计划
```

### 文件模式会话格式

总览：

```text
即将执行 /docs-upgrade（指定路径强制对齐），当前参数如下：
- DOC_ROOT: <路径>
- KNOWLEDGE_TYPE: <application|system|company>
- meta: <path 或 repository>
- ref: <main 或覆盖>
- 备份: 不强制 .docs-init（依赖 git）
- 名单 N=<n>：
  - <相对或 scripts/…> → 强制重填 | scaffold | 非md跳过覆盖 | 元缺拒绝 | 软链拒绝 | 遗留槽位拒绝 | changelogs本库胜 | 建联覆盖
C 执行全部可处理项（未落位在本流程内逐项） / M 改路径名单或下钻单文件 / S 取消整单 / F 不适用扩整树
```

单文件（总览 `M` 下钻后）：

```text
文件 i/N：<路径> 动作=<强制重填|scaffold|建联覆盖>
预览：<短摘要>
C 整文件写入（对齐节重填；未落位在本流程内逐项） / M 改本文件参数或预览 / S 跳过本文件继续 / F 不适用扩整树
```

### 未落位逐项（清单/总览或单文件 `C` 流程内）

所有 md（含根级 `CONTRIBUTING.md`）一律一次一项：

```text
未落位 i/N：<相对路径> § <标题>
可选父标题（元库骨架）：
- 1 <节A>
- 2 <节B>
- …
请选：<编号> 挂靠该标题下 / A 追加文末（原样保留层级） / S 跳过本项
```

挂靠：子标题级 = min(父级+1, 6) + 正文相对该子标题平移（含 H6 封顶；见 [merge-rules.md](merge-rules.md) §5）。追加文末：原样保留本库层级。轻流程 `S` 仍是跳过本文件/本单元，不拿来当「全跳过未落位」——未落位项用上方 `S` 跳过本项。

### 中途动作

| 动作 | 效果 |
| --- | --- |
| 清单/总览 `C` | 执行全部可处理项；对齐节按元库结构重填；未落位在本流程内逐项 |
| 清单/总览 `M` | 改参数/路径名单，或下钻到单文件 |
| 总览 `S` | 取消整单，不写盘 |
| 单文件 `C` | 与总览 `C` 同语义（范围=该文件） |
| 单文件 `M` | 改本文件参数或预览 |
| 文件 `S` | 跳过当前文件，继续下一文件；已写盘不回滚 |
| `F` | 不把本单元扩成整树（模式互斥） |
