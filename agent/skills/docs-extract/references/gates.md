# docs-extract 推进协议（binding）

本文件只绑定技能差异；不重定义共享协议。

| 契约 | 用途 |
| --- | --- |
| [intent-clarify.md](../../../references/intent-clarify.md) | 写前六项清单与写前 `C` |
| [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) | `C/M/G/S/F`、阶段横幅、重开与收尾 |
| [grilling-skill.md](../../../references/grilling-skill.md) | 写后烤干及 fallback |
| [simplify-principles.md](../../../references/simplify-principles.md) | 生成时精简与修订后的 simplify 遍 |

## 单元定义

单个 `--overview` + 一批来源的命中段落及其 A/U/D 集合；dry-run 也属于当前单元。

公共六项之外须明确：

- `--sources`：路径列表或内联文本及本批范围。
- `--overview`：单个存在的目标路径。
- 模式：正式写入或 `--dry-run`。
- 关键词：已读取的 `## 文档关键词` 与筛选口径。

未获写前 `C`，不写第三列、不输出正式预览结论。缺目标或有效附录时停在澄清，不暗建目标或猜词。

## 风险与停顿

首次实质写第三列、命中异常多、敏感来源、大范围 `[U]`，或要求跳过预览时，先给结论、推荐方案和数字选项，确认后执行。推荐 dry-run，不把它视作免澄清入口。

来源、关键词、目标或写入策略发生变化时重新收口；新旧待归档项冲突也须先确认。无命中不得写入。失败时撤销当前单元改动，不能留下部分写入；并发编辑与恢复方式见 [workflow.md](workflow.md)「落盘与失败」。

## 写后

默认必须烤干，含预览；唯一默认表在 [workflow.md](workflow.md)。通过 [quality-checklist.md](quality-checklist.md) 后停等用户动作。未收敛不得扩批；写后 `C` 不等于自动授权后续来源或另一个 overview。
