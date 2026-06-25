# docs-build 反模式

原则见 [design-principles.md](design-principles.md)；操作见 [gotchas.md](../gotchas.md)。

| 问题 | 纠正 |
|------|------|
| 未 CONFIRMED 写 knowledge | Qclose-1 + gate（[gates.md](gates.md)） |
| 乱序或回写前序 JSON | [workflow.md](workflow.md) |
| 无证据造 ID | [extraction-rules.md](extraction-rules.md)、gotchas |
| 用 build 更根 index | docs-indexing（[SKILL.md](../SKILL.md)） |
| 示例行冒充索引 | [readme-fill-spec.md](readme-fill-spec.md)、[quality-checklist.md](quality-checklist.md) |
| 不跑 validate 即完成 | [workflow.md](workflow.md) 阶段 4 |
| 虚假 gate 逃钩子 | 真 spec + 文件名引用（[gates.md](gates.md)） |
