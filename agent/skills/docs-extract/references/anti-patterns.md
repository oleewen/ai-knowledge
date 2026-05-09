# docs-extract 反模式

与 [design-principles.md](design-principles.md) 互补；细节见 [../gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
|--------|------|
| 未 CONFIRMED 即写第三列 | dry-run + 总确认 / 合法例外；[gates.md](gates.md) |
| 4.1 无命中仍 4.3 | 无命中则 CLOSE，不落盘；[workflow.md](workflow.md) |
| overview 当 `--sources` | 只扫 sources；gotchas |
| 关键词过宽、命中爆炸 | 收窄或分批；先 dry-run；gates |
| 第三列整段粘贴源文 | [extract-spec.md](extract-spec.md) 提炼 |
| 4.3 失败留部分写入 | 回滚重试；workflow |
| 无命中章节清空 | 保持原样；gotchas |
| 第三列堆 `(来源：…)` | 删脚注，追溯放 spec；design-principles |
| 「直接写」即跳 HARD-GATE | 仍须门禁/证据，除非同会话**明示**例外；gates |
