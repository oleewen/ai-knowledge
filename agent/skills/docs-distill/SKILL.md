---
name: docs-distill
description: >
  将已挂载联邦槽位的核实内容按目标层契约全量去重，写入 system、solution 或 company
  overview 第三列。适用于 /docs-distill、槽位上行、同步应用/系统/解决方案到上层 overview。
  仅处理联邦槽位；非槽位资料走 docs-extract，overview 归档走 docs-archive，索引走 docs-indexing。
---

# docs-distill

把一个已挂载、内容已核实的联邦槽位全量提炼到一个上层 `{NAME}-overview.md` 的第三列。Agent 负责正文蒸馏；脚本只做参数、路径和前置条件校验。

## 适用边界

`DOC_DIR` 是实际文档相对目录，`KNOWLEDGE_TYPE` 是知识层，不能互相代替。

| 知识层 | 相对 DOC_DIR 的源槽位 |
| --- | --- |
| `system` | `application-slots/application-{NAME}/` |
| `solution` | `system-slots/system-{NAME}/` |
| `company` | `solution-slots/solution-{NAME}/` |

目标均为 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。路径覆盖、旧调用兼容见 [workflow.md](references/workflow.md)。

- 模式恒为全量；不支持 `--since`，不写 `DISTILL-LOG`。
- `application/knowledge/overview` 不是本技能目标；请走 `docs-extract` 或 `docs-archive`。
- 一次只处理一个目标 overview；`--dry-run` 只输出预览，不改文件。

## 门禁

1. 先收口 `DOC_DIR`、知识层、`--name`、写入或 `--dry-run`，确认目标是单一 overview。
2. 按 [scope-clarity.md](references/scope-clarity.md) 读取落盘契约，闭合目标职责、源职责、表行粒度和跨层收束。契约缺失、模糊或冲突时硬停；结论先落盘，再继续。
3. 核对职责/粒度摘要；明确的只读预览可直接执行。正式写入完成公共六项澄清并核对授权，已有同范围有效授权沿用。
4. 全量读取槽位知识与 SDD，按 [federation-spec.md](references/federation-spec.md) 去重，只写第三列 delta（`A/U/D`）。
5. 写入或预览后按本地写后规则烤干；受众维 A/B/C/E 未通过，不得宣称收敛。当前单元收敛后停等 `C/M/G/S/F`。

落盘 overview 的 knowledge 引用遵守 [knowledge-governance.md](../../knowledge/knowledge-governance.md)：不链槽位或下层路径，不手写爬层关系；实体引用按既有 parent/ID 契约生成。

共享协议只在以下文件维护：

- 写前与动作：[意图澄清](../../references/intent-clarify.md)、[单元推进](../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling](../../references/grilling-skill.md)
- 精简原则：[精简原则](../../references/simplify-principles.md)

## 脚本

```bash
bash "$SKILL_DIR/scripts/run-docs-distill.sh" \
  --root /path/to/repo --doc-dir docs --layer system --name billing-appeal --dry-run
```

槽位异常先用 [docs-link](../docs-link/SKILL.md) 检查/修复；缺仓或内容过旧按各仓普通 Git 工作流处理。

`SKILL_DIR` 为已加载技能的绝对目录。脚本需要 Bash 5+ 与整套 Agent 共享配置库；仅执行前置校验，不生成正文。要求槽位存在且非空、槽位根有 `README.md`、目标层模板存在；通过后仍由 Agent 按契约生成正文。详见 [workflow.md](references/workflow.md)。

## 按需读取

| 任务 | 文件 |
| --- | --- |
| 参数、步骤、I/O | [workflow.md](references/workflow.md) |
| 风险、停顿、当前单元 | [gates.md](references/gates.md) |
| 职责与粒度闭合 | [scope-clarity.md](references/scope-clarity.md) |
| 第三列与 A/U/D | [federation-spec.md](references/federation-spec.md) |
| 受众质检 | [audience-and-language.md](references/audience-and-language.md) |
| 终检与易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

评测入口：[evals/evals.json](evals/evals.json)、[agents/grader.md](agents/grader.md)。
