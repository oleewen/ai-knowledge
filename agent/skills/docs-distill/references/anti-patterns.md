# 反模式 → 纠正

原则 [design-principles.md](design-principles.md)；实操 [gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
| ------ | ------ |
| 参数未收口即写 overview | 先收口 `DOC_DIR`、`--name`、是否 `--dry-run`；[gates.md](gates.md) |
| 跳过写前意图澄清 | 须六项清单 + 写前 C；[intent-clarify.md](../../../references/intent-clarify.md) |
| 仍写 DISTILL-LOG / 用 `--since` | 已废止；仅全量写第三列 |
| 非槽位 path 当 distill | 走 [docs-extract](../../docs-extract/SKILL.md) |
| 槽位空仍写 | 停；先 docs-pull |
| 全量无预览直盖 | gates + gotchas |
| 第三列贴原文或重复已覆盖要点 | [federation-spec.md](federation-spec.md) |
| 五视角跳行 | 全表处理，`—` 占位；gotchas |
| 新建 overview 只改名不改标题 | 文件名 + `# …架构概览` 同步 `{NAME}` |
| 第三列堆来源脚注 | [design-principles.md](design-principles.md) |
| 无 `--name` 深读全库 | 轻扫槽位列表；单源收口；gates |
| 用错目标层表行 | system / company 表行分列；见 federation-spec |
