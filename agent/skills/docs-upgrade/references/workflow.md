# docs-upgrade 工作流

一次升级计划只处理一个工程的 `文档目录`。按 [parameters.md](parameters.md) 收口输入，选定整树或指定路径模式；参数未收口前不写盘。

## 源解析

两模式先校验同层来源，再读取模板；指定路径模式也必须先校验、后展开目录。

1. 读 `.docsconfig`；缺失则停止并提示 `/docs-install`。
2. 无 `--meta-path` 时，要求 links 恰好一条 `type: meta`；缺失或多条则停止，提示修复登记、install upsert 或本次覆盖。`dir` 缺省取 `KNOWLEDGE_TYPE`；显式值必须与之完全相等，错配时报告两者并停止。`--meta-path` 直接取本库层级，不读登记项的 `dir`。
3. 按下表解析工作区内的 path。结构源只能为 `{meta_root}/{KNOWLEDGE_TYPE}/`，不得借 `dir` 扫描其他层或 `agent/`。

| 来源 | 行为 |
| --- | --- |
| 有效 Git path，工作区脏（含未跟踪） | 停止；即使传了 `--ref` 也不继续 |
| 有效 Git path，已传 `--ref` | fetch 后优先 `origin/$ref`，其次本地 `$ref`；都不存在则停止 |
| 有效 Git path，未传 `--ref` | 不 fetch，以当前 HEAD 为所选历史边界，不默认对齐 main |
| 非 Git path，含 application / system / solution / company 任一层目录 | 直接使用；有版本号的整树仍须满足下节 Git 发布基线 |
| path 无效，登记有 repository | 临时 clone 完整历史，使用 `--ref` 或默认 main；分支不存在则停止，不回退 |
| path 无效且无 repository | 停止，不猜来源 |

## 版本范围与推进

| 模式 | 读取内容与范围 |
| --- | --- |
| 整树，目标根 `DESIGN.md` 有 `version` | 在元库所选 ref 可达历史中找当前版本和最高 `docs-publish: version YYYY.MMdd.patch` 发布提交；只处理两发布点间变化的本层模板，内容固定为目标发布快照 |
| 整树，无 `version` | 保留整树扫描，读取所选 HEAD/ref 或非 Git 目录 |
| 指定路径 | 读取所选 HEAD/ref 或非 Git 目录，按路径名单强制对齐，不做发布差异过滤、不推进整库版本 |

有版本号整树缺任一发布点、元库非 Git，或当前发布点不是目标发布点祖先时停止，不降级全量。基线来自**元库**，不用目标工程历史。目标发布号全仓选择，文件范围仅本层；其他层或 Agent 的新发布可推进目标号，但其文件不入清单。同发布号时，发布后 HEAD 不产生模板增量。

应用 README 按 `README-s.md` 源路径过滤后映射为 `README.md`；元库删除项保留本库文件。scaffold 后全树路径重写不受模板差异过滤限制。

`DESIGN.version` 保持四层统一内容发布版本的含义，不充当实体 schema、工具兼容性或验收通过标记。格式与实体约束的校验按[统一校验规范](../../../knowledge/knowledge-validation.md)执行。

**版本最后更新**：scaffold 覆盖 DESIGN 时保留当前版本；只有整单模板重填、未落位处理及下节真实实体兼容检查全部完成，并通过校核和 A/B 后，Agent 才写目标 `version`，再核对落盘值。失败、中断、兼容性待核实或跳过待处理项均保留原基线；恢复沿用原交接资料核对已完成步骤，不盲目重跑。指定模式覆盖已有 DESIGN 也须保留本库版本，不把单文件对齐当整库完成。

### 模板与实体兼容状态

升级报告须分别给出以下状态，不能用模板差异为空、示例跳过或旧脚本退出零替代：

| 检查面 | 范围与通过条件 |
| --- | --- |
| 模板对齐 | 当前计划中的骨架、结构重填、路径及未落位处理已完成 |
| 真实实体兼容 | 按目标规范核对本库真实实体的字段、身份、关系、引用及来源证据；本库独有或抑制示例的实体仍在检查范围 |
| 跨库兼容 | 核对受影响外库身份、消费关系及引用；外库不可读记待核实，不假称通过 |

模板可先报告已对齐；真实实体或适用跨库检查未通过时，整体升级保持未闭环。指定路径模式只报告已检查范围，不推定整库兼容。兼容问题需要实体迁移时，列出影响并交 docs-build 等所属流程；已有授权可沿用，未授权路径不得借升级静默扩写。升级脚本在预览及 scaffold 后自动输出只读兼容诊断；最终验收须使用下列严格入口。

### 兼容检查入口

```bash
# 在消费工程根运行；不读模板、不写文件
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --check-compat
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --check-compat --assessment /path/to/assessment.json
```

报告含 `assessment_template`，用于填写本次人工评估；无评估时列明未闭合项并非零退出。整树预览和 scaffold 后的自动诊断允许继续修复模板，不能据其退出零推进版本；指定路径流程也须主动运行诊断并按所选范围报告，不能当作整库验收。

评估的 `schema/doc/target_rules` 绑定文档根及完整目标规则哈希。`scope` 保留报告提供的 roots、files、sources，人工逐项确认后填写 affected（仓根相对实体路径）、reviewer（name/带时区 at）、conclusion。`template` 保留 files 快照，填写计划、未落位及路径校核结论和 reviewer。`old_baseline` 指向本库 governance 内已保存的原始统一校验 JSON，含仓根相对 path、文件 sha256、reviewer 和基线核实结论；未知旧基线不可用当前规则猜补。报告文件的保存由已授权工作流执行，诊断本身不落盘。

实体来源事实使用[证据工具](../../../knowledge/knowledge-evidence.md#工具生命周期)补核。受影响实体必须有当前核验；未受影响实体可继承可核实旧报告，但当前实现保守要求旧非规则输入全部仍被读取且哈希一致。范围、规则、证据或来源快照变化后旧评估失效，须重核；不能只把新哈希机械复制到旧人工结论。

最终 `--check-compat --assessment ...` 只有无 FAIL/UNVERIFIED/NOT_RUN 且五个检查面均闭合时返回零，并给出 `can_advance_version: true`。该结果是 Agent 推进版本的必要门禁，仍须完成原有 A/B 与整单条件；命令不改版本、不迁移实体、不修改 Profile 采用记录。版本或 Git 集成发生后重新核对实际状态，不继承过期通过结论。

## 整树执行

需要 Bash 5+、Git、Python 3；在目标工程根调用本技能脚本（路径可来自源码或安装副本）：

```bash
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --dry-run [--meta-path PATH] [--ref REF]
# 清单 C 后
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold [--meta-path PATH] [--ref REF]
```

1. **预览**：脚本生成 [动作桶](merge-rules.md#3-清单桶脚本)；有版本号时展示 from/to 及两个 commit。校核清单后按 [gates.md](gates.md) 等待 `C/M/S/F`。
2. **备份与 scaffold**：`C` 后运行 `--apply-scaffold`。写目标前将现有重填 / 覆盖项及路径重写的普通文本候选镜像备份到 `{仓库路径}/.docs-init/upgrade-{stamp}-<随机后缀>/`，根 README 也纳入；候选是安全超集，可能含未实际修改文件。备份保留原字节、同次不重复覆盖；备份失败不继续写目标。随后复制新增骨架并覆盖根 DESIGN。
3. **路径收尾**：按下节执行；新增桶为空仍执行。
4. **结构重填**：从脚本输出的 `重填交接` 目录读取 `source.txt` 和 `templates/`，按 [merge-rules.md §5](merge-rules.md#5-结构重填agent) 重填并列出未落位。该目录位于本次备份目录内，保留来源、固定提交、版本区间和重填清单；非 Git 源标为 `unversioned`，模板字节仍冻结。不要读取已清理的临时结构源，也不要改读后续 HEAD。中断时从同一交接目录与原文备份恢复，缺失则停止核实，不能猜测版本或重跑覆盖现场。交接资料不自动删除。`C` 已覆盖可处理项；未落位另按 gates 选择策略再写入，`M` 可下钻单文件。
5. **验收**：检查文档目录、links、备份与产物，分别完成模板、真实实体与适用跨库兼容检查，再按 [audience-and-language.md](../../../references/audience-and-language.md) 做 A/B；整体通过后按版本规则落盘并停等 `C/M/S/F`。

失败时停止整单，不静默改分类重试；未过 A/B 不得宣称完成。

源文件与本库同名目录、或源文件的本库父路径为普通文件时，清单列出路径类型冲突，预览和实跑均非零退出；在备份及目标写入前停止。先确定迁移方案再重新预览，不能删除本库目录或静默略过后推进版本。指定路径模式同样先检查类型冲突。

### 路径收尾

仅 `--apply-scaffold` 执行；dry-run 不建链、不重写、不改 README。

- 非 meta 建 / 修 `DOC_DIR/.agents` → `$AGENT_ROOT/$AGENT_DIR`。
- 对文档树普通文本文件，将裸 `agent/`、多层 `../agent/`、`~/.agents/` 改为按文件深度计算的相对 `.agents/`；meta 使用相对 `agent/`。不改 IDE 段，不跟随软链。
- 幂等更新普通根 `README.md` 的 Agent 路径注记；README 为软链时跳过。

结构重填和指定模式不强制补跑路径重写；它们后来写入的裸路径可能仍保留，这是当前执行边界。

## 指定路径执行

1. 完成源解析后，按 [parameters.md](parameters.md#指定路径展开) 取两侧文件并集并分类。总览显式列 `meta-only` scaffold、拒绝项及动作总数；提示本模式不强制 `.docs-init` 备份（依赖 Git）。
2. 总览 `C` 后执行全部可处理项；或 `M` 下钻，展示单文件预览并取得该文件 `C`。确认前不写任何名单项。
3. Agent 按 [merge-rules.md §7](merge-rules.md#7-指定路径强制对齐文件模式) 写 scaffold / DESIGN / 重填内容；拒绝项只报告。未落位确认与整树相同，不调用脚本 `--path` 或整树 apply。
4. 全部预定项处理完（含显式跳过）后分别报告模板与受影响实体/跨库兼容状态，整单做一次受众 A/B，停等 `C/M/S/F`；未通过或待核实部分仍未闭环，不推进整库版本。
