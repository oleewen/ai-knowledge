# docs-build 反模式

原则见 [design-principles.md](design-principles.md)；操作见 [gotchas.md](../gotchas.md)。

| 问题 | 纠正 |
|------|------|
| 参数未收口即写 knowledge | 先收口视角范围、输出路径与策略，再意图澄清后写入（[gates.md](gates.md)） |
| 跳过写前意图澄清 | 须六项清单 + 写前 `C`；见 [intent-clarify.md](../../../references/intent-clarify.md) |
| 路径/容器缺 knowledge 批次 | 第 6 项须写明视角/实体批次与 `{DOC_DIR}/knowledge/` 路径 |
| 乱序或回写前序 JSON | [workflow.md](workflow.md) |
| 无证据造 ID | [extraction-rules.md](extraction-rules.md)、gotchas |
| 用 build 更根 index | docs-indexing（[SKILL.md](../SKILL.md)） |
| 示例行冒充索引 | [readme-fill-spec.md](readme-fill-spec.md)、[quality-checklist.md](quality-checklist.md) |
| 不跑 validate 即完成 | [workflow.md](workflow.md) Unit Cycle |
| 跳过风险确认直接全量重建 | 先给推荐方案与数字选项（[gates.md](gates.md)） |
| 写前 grilling 混名 | 写前=意图澄清；写后=烤干 |
