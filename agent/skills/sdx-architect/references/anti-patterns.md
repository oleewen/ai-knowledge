# sdx-architect 反模式

| 反模式 | 纠正 |
|--------|------|
| 未确认即写 `ASD-*.md` | 草稿 → 总确认 → 落盘；或登记例外 |
| ASD 塞进 API/DDL/规约全文 | 边界 + 摘要；详情 → `/sdx-design` |
| 缺 §1/§2/§3 仅留图 | 按 `asd-template.md` 补三节再填 |
| 结论对上无 PRD/ANALYSIS | 补引用，删臆断 |
| 路径或占位不合规 | 统一命名并替换占位 |
| 会话 spec 无 `PENDING`/`CONFIRMED` | 见 `gates.md` |
| 有图无决策 | 补决策表（备选、取舍） |
| 未跑 `validate-asd.sh` | 收尾必跑 |
| system/company 在本库强写 DSD 或全套 `specs/` | 联邦 ASD 即可；详设 → 应用库 `/sdx-design`（[knowledge-type-modes.md](knowledge-type-modes.md)）|
