# docs-distill 工作流

主干：参数向导 → 写前澄清 → 全量比对 → 预览或写入 → 烤干。共享协议见 [intent-clarify.md](../../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../../references/grilling-skill.md)。

## 参数与路径

| 参数 | 要求 |
| --- | --- |
| `DOC_DIR` / `--doc-dir` | 实际文档相对目录；显式参数优先，其次环境变量、目标 `.docsconfig` |
| `KNOWLEDGE_TYPE` / `--layer` | system / solution / company；同样按显式参数、环境变量、配置顺序解析 |
| `--name` | 当前边的源名称；必须是单一安全标识 |
| `--dry-run` | 三分区预览；不写 overview |
| 当前单元 | 一个 `{NAME}-overview.md`，一次全量范围 |

按知识层选择源槽位前缀：system ← application、solution ← system、company ← solution。源路径为 `{DOC_DIR}/{下层}-slots/{下层}-{NAME}/`，目标为 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。

兼容旧调用：知识层缺失或为 meta 且文档目录恰为 system/solution/company 时，沿用该标准层名；自定义目录必须给出有效知识层，不从目录名猜测。拒绝绝对、爬层或实际越出目标仓的 DOC_DIR；目标 overview 目录不得越出文档根，目标文件软链及非普通文件均报冲突。联邦源槽位软链仍属正常输入。

前置条件：槽位已挂载、非空、根有 `README.md`；目标层有 `NAME-overview.md` 模板。缺任一项就停。

## 执行顺序

1. 收口参数、目标状态（新建或更新）和写入模式。
2. 读 [scope-clarity.md](scope-clarity.md) 的落盘契约；输出职责/粒度摘要。缺失、模糊或冲突时硬停，先落盘决策。
3. 正式写入输出公共六项与追加字段，核对有效授权；参数与契约齐备的明确 dry-run 请求直接预览。
4. 运行脚本校验路径；脚本不写正文或日志。
5. 全量读取槽位 knowledge 与 SDD，读取目标 overview 和同层表行。
6. 按 [federation-spec.md](federation-spec.md) 逐行去重，形成 `A/U/D` delta；无证据写 `—`。
7. `--dry-run` 时输出「将写入 / 跳过 / 无命中」，否则仅更新目标第三列；新建时同步替换文件名和标题。
8. 按 [quality-checklist.md](quality-checklist.md) 烤干，确认受众维 A/B/C/E，通过后停等用户动作。

## 写后默认

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个 overview（含 dry-run） | 必须 | 实际冲突、范围变化或影响未明的替换；已有同范围授权不重复询问 |

职责/粒度契约未闭合时不得用 dry-run 绕过。

## 脚本 I/O

```bash
bash "$SKILL_DIR/scripts/run-docs-distill.sh" \
  --root /path/to/repo --doc-dir docs --layer system --name billing-appeal --dry-run
```

`SKILL_DIR` 为已加载技能的绝对目录；需 Bash 5+ 与共享配置库。成功输出实际目录、知识层、边路径、目标状态和 `dry_run` 状态；失败返回非零。脚本只校验，不写 overview、不生成 `DISTILL-LOG`。
