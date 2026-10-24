---
name: docs-extract
description: >
  从文件、目录或内联文本提炼未覆盖知识，预览或写入四层 overview 第三列。
  用于 /docs-extract、从资料提炼 overview、按关键词筛选新 delta。
  联邦槽位全量上行用 docs-distill；已有 overview delta 归档用 docs-archive。
---

# docs-extract

将来源中命中目标关键词、且知识正文尚未覆盖的要点，作为 A/U/D delta 写入第三列。一次处理一个 overview 和一批来源；本技能由 Agent 执行，`--sources` 等是会话参数，不是 shell 程序。

## 输入与边界

| 输入 | 要求 |
| --- | --- |
| `--sources` | 文件、目录列表或内联文本；疑似路径但不存在时先澄清 |
| `--overview` | 已存在的单个 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`；四层均可 |
| 关键词 | 读取目标的 关键词附录（格式见 [extract-spec.md](references/extract-spec.md)），不能用标题猜词 |
| `--dry-run` | 可选；只预览，不改目标文件 |

联邦槽位全量上行、overview 归档分别交给 `docs-distill`、`docs-archive`；索引和 SDD 终稿不在本技能范围。

## 执行顺序

1. 按 [gates.md](references/gates.md) 核对参数与当前单元；明确的 dry-run 请求直接只读预览。正式写入完成写前澄清，沿用当前范围内的明确授权。
2. 按 [extract-spec.md](references/extract-spec.md) 读取来源、筛选段落、比对正文；无命中结束，有命中只形成未覆盖的 delta。
3. 按 [workflow.md](references/workflow.md) 预览或落盘，再做 [验收](references/quality-checklist.md) 与烤干；收敛后停等 `C/M/G/S/F`。

## 写入底线

- 只改本轮命中行的第三列；无命中、无新 delta 的行保持原样。已有待归档要点不得被无关新内容覆盖。
- 去重基准是链接指向的知识正文，不能拿旧第三列证明“已归档”。A/U/D 含义见 [federation-spec.md](../docs-distill/references/federation-spec.md)；缺少来源不等于删除证据。
- 可读 knowledge 外源；落盘必须符合 [knowledge-governance.md](../../knowledge/knowledge-governance.md)「业务 knowledge 引用边界」。第三列不留源文件路径、下层/槽位链接或手写爬层；上层实体有 parent 时用生成函数 HTTP，无 parent 用纯 ID。
- 写入失败撤销本轮改动；不覆盖他人编辑。只读预览与正式写入都须烤干。

## 按需参考

遇到异常查 [gotchas.md](gotchas.md)；受众要求见 [audience-and-language.md](references/audience-and-language.md)；完整导航见 [参考索引](references/README.md)。维护本技能时使用 [评测集](evals/evals.json) 与 [grader.md](agents/grader.md)，不把评测文件作为日常提炼的前置输入。
