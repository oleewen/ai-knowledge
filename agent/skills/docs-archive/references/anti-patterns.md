# 反模式 → 纠正

原则总览 [design-principles.md](design-principles.md)；操作 [gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
| ------ | --- |
| 确认书与意图澄清两套停顿 | [gates.md](gates.md)；确认书 = 意图澄清门禁，六项并入一次写前 `C` |
| 确认书未收口即写目标 | [gates.md](gates.md)；先收口六项 + 来源/目标/冲突/清理策略 |
| 批次确认后仍逐单元重复六项全清单 | [workflow.md](workflow.md)；仅摘取本单元目标与路径即可落盘 |
| 落盘后跳过烤干即推进下一单元 | [workflow.md](workflow.md)；默认必须烤干，收敛后再 `C` |
| 把写前澄清称作 grilling | [intent-clarify.md](../../../references/intent-clarify.md)；`G` 仅写后 |
| 冲突静默合并 | 冲突清单；单次一问；[workflow.md](workflow.md)、[quality-checklist.md](quality-checklist.md) |
| 正文堆 `(来源：…)`、参见链 | [design-principles.md](design-principles.md) |
| 照搬来源结构 | 服从目标体例；[workflow.md](workflow.md) 步骤 3 |
| 缺/断副标题链仍写 | 先冲突清单；[core-concepts.md](core-concepts.md) |
| 与 docs-build / docs-upgrade 抢活 | 分流；上级 `SKILL.md` 边界 |
| 确认书外扩写 | 先更确认书再获写前 `C`；[gates.md](gates.md) |
| 步骤 5 前就硬删 overview | 按行+自检；索引壳优先；[gotchas.md](../gotchas.md) |
| `[D]` 只清第三列不改目标章 | federation-spec + [workflow.md](workflow.md) 第三列 delta |
| 归档后第三列仍留 delta/`[D]` | 回写 `—` 或索引壳 |
