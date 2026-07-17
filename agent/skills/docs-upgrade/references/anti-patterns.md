# 反模式 → 纠正

原则 [design-principles.md](design-principles.md)。

| 反模式 | 纠正 |
| ------ | ------ |
| 跳过意图澄清直接多文件写 | [gates.md](gates.md)；澄清→生成→烤干 |
| 落盘后跳过烤干即推进下一批 | [workflow.md](workflow.md)；默认必须烤干 |
| 把写前澄清称作 grilling | [intent-clarify.md](../../../references/intent-clarify.md)；`G` 仅写后 |
| 未 C/S 已多文件写 | [gates.md](gates.md) |
| 过度统一 | [related-doc-discovery.md](related-doc-discovery.md)「同类」；gotchas |
| 短词全库一把梭 | 缩范围/确认；[semantic-keyword-discovery.md](semantic-keyword-discovery.md) |
| upgrade 当 archive/change | [gates.md](gates.md) 分流 |
| 编造不可核实事实 | [workflow.md](workflow.md)；上级 SKILL |
| 断链、破 fence | [workflow.md](workflow.md) 烤干；[quality-checklist.md](quality-checklist.md) |
