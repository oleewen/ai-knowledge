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

**版本最后更新**：scaffold 覆盖 DESIGN 时保留当前版本；只有整单重填、未落位处理全部完成并通过校核和 A/B 后，Agent 才写目标 `version`，再核对落盘值。失败、中断或跳过待处理项均保留原基线，重试使用原发布区间。指定模式覆盖已有 DESIGN 也须保留本库版本，不把单文件对齐当整库完成。

## 整树执行

需要 Bash 5+、Git；在目标工程根调用本技能脚本（路径可来自源码或安装副本）：

```bash
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --dry-run [--meta-path PATH] [--ref REF]
# 清单 C 后
bash /path/to/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold [--meta-path PATH] [--ref REF]
```

1. **预览**：脚本生成 [动作桶](merge-rules.md#3-清单桶脚本)；有版本号时展示 from/to 及两个 commit。校核清单后按 [gates.md](gates.md) 等待 `C/M/S/F`。
2. **备份与 scaffold**：`C` 后运行 `--apply-scaffold`。写目标前将现有重填 / 覆盖项及路径重写的普通文本候选镜像备份到 `{仓库路径}/.docs-init/upgrade-{stamp}-<随机后缀>/`，根 README 也纳入；候选是安全超集，可能含未实际修改文件。备份保留原字节、同次不重复覆盖；备份失败不继续写目标。随后复制新增骨架并覆盖根 DESIGN。
3. **路径收尾**：按下节执行；新增桶为空仍执行。
4. **结构重填**：Agent 从本次固定快照读取元库文件，按 [merge-rules.md §5](merge-rules.md#5-结构重填agent) 重填并列出未落位。`C` 已覆盖可处理项；未落位另按 gates 选择策略再写入，`M` 可下钻单文件。
5. **验收**：检查文档目录、links、备份与产物，按 [audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表做 A/B；通过后按版本规则落盘并停等 `C/M/S/F`。

失败时停止整单，不静默改分类重试；未过 A/B 不得宣称完成。

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
4. 全部预定项处理完（含显式跳过）后校核产物，整单做一次受众 A/B，停等 `C/M/S/F`；不推进整库版本。
