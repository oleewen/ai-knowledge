# docs-extract 反模式

与 [design-principles.md](design-principles.md) 互补；细节见 [../gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
| ------ | ------ |
| 参数未收口即写第三列 | 先收口 `--sources`、`--overview`、关键词口径与是否 `--dry-run`；[gates.md](gates.md) |
| 跳过写前意图澄清 | 须六项清单 + 写前 C；[intent-clarify.md](../../../references/intent-clarify.md) |
| 4.1 无命中仍 4.3 | 无命中则 CLOSE，不落盘；[workflow.md](workflow.md) |
| overview 当 `--sources` | 只扫 sources；gotchas |
| 关键词过宽、命中爆炸 | 收窄或分批；先 dry-run；gates |
| 第三列整段粘贴源文 | [extract-spec.md](extract-spec.md) 提炼 |
| 4.3 失败留部分写入 | 回滚重试；workflow |
| 无命中章节清空 | 保持原样；gotchas |
| 第三列堆 `(来源：…)` | 删脚注，追溯放 spec；design-principles |
| 「直接写」即跳预览与会话确认 | 仍须先给推荐方案与数字选项；gates |
