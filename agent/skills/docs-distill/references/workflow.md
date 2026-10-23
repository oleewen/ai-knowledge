# docs-distill 工作流

主干：参数向导 → 写前澄清 → 全量比对 → 预览或写入 → 烤干。共享协议见 [intent-clarify.md](../../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../../references/grilling-skill.md)。

## 参数与路径

| 参数 | 要求 |
| --- | --- |
| `DOC_DIR` / `--doc-dir` | `system`、`solution` 或 `company`；优先显式参数，再读环境变量和 `.docsconfig` |
| `--name` | 当前边的源名称；必须是单一安全标识 |
| `--dry-run` | 三分区预览；不写 overview |
| 当前单元 | 一个 `{NAME}-overview.md`，一次全量范围 |

边路径：

| `DOC_DIR` | 源槽位 | 目标 |
| --- | --- | --- |
| `system` | `system/application-slots/application-{NAME}/` | `system/knowledge/overview/{NAME}-overview.md` |
| `solution` | `solution/system-slots/system-{NAME}/` | `solution/knowledge/overview/{NAME}-overview.md` |
| `company` | `company/solution-slots/solution-{NAME}/` | `company/knowledge/overview/{NAME}-overview.md` |

前置条件：槽位已 pull、非空、根有 `README.md`；目标层有 `NAME-overview.md` 模板。缺任一项就停。

## 执行顺序

1. 收口参数、目标状态（新建或更新）和写入模式。
2. 读 [scope-clarity.md](scope-clarity.md) 的落盘契约；输出职责/粒度摘要。缺失、模糊或冲突时硬停，先落盘决策。
3. 输出公共六项与技能追加字段，获写前 `C`。
4. 运行脚本校验路径；脚本不写正文或日志。
5. 全量读取槽位 knowledge 与 SDD，读取目标 overview 和同层表行。
6. 按 [federation-spec.md](federation-spec.md) 逐行去重，形成 `A/U/D` delta；无证据写 `—`。
7. `--dry-run` 时输出「将写入 / 跳过 / 无命中」，否则仅更新目标第三列；新建时同步替换文件名和标题。
8. 按 [quality-checklist.md](quality-checklist.md) 烤干，确认受众维 A/B/C/E，通过后停等用户动作。

## 写后默认

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个 overview（含 dry-run） | 必须 | 首次创建、冲突消解、未确认决策写入、跳过预览直写 |

职责/粒度契约未闭合时不得用 dry-run 绕过。

## 脚本 I/O

```bash
bash agent/skills/docs-distill/scripts/run-docs-distill.sh \
  --root /path/to/repo --doc-dir system --name billing-appeal --dry-run
```

成功输出边路径、目标状态和 `dry_run` 状态；失败返回非零。脚本只校验，不写 overview、不生成 `DISTILL-LOG`。
